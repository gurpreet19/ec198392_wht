CREATE OR REPLACE PACKAGE BODY EcDp_Timestamp IS
/****************************************************************
** Package        :  EcDp_Timestamp, body part
**
** Purpose        :  Definition of date and time methods
**
** Documentation  :  www.energy-components.com
**
** Created  : 16.08.2017
**
** Modification history:
**
** Date        Whom  	Change description:
** ------      ----- 	-----------------------------------
**
*****************************************************************/

lv2_main_time_zone   T_PREFERANSE.PREF_VERDI%TYPE;

CURSOR c_preference (cp_pref_id VARCHAR2) IS
  SELECT pref_verdi
    FROM t_preferanse
   WHERE pref_id = cp_pref_id;

CURSOR c_productionday(cpdd_object_id VARCHAR2, cp_daytime DATE) IS
  SELECT offset, time_zone_region
  FROM  production_day_version pv
  WHERE   nvl(cp_daytime,pv.daytime) >= pv.daytime
  AND     nvl(cp_daytime,pv.daytime) < Nvl(pv.end_date,cp_daytime+1)
  AND   (object_id = cpdd_object_id OR ( cpdd_object_id IS NULL AND pv.default_ind = 'Y'))
  ORDER BY pv.object_id ;  -- To make it deterministic in case of error in config (more than 1 default)

PROCEDURE flush_buffer IS

BEGIN
  lv2_main_time_zone := NULL;
END flush_buffer;

/*
* Return given offset, return it in day. May start with '-', '+', or none.
* Regular expression is: ^[+-]?(0[0-9]|1[0-9]|2[0-3]):[0-5][0-9]$
* Didnt use regex for performance reason
*/
FUNCTION getTZoffsetInDays(p_time_zone_offset VARCHAR2) RETURN NUMBER
IS

lv_prefix VARCHAR2(1);
ln_hour NUMBER;
ln_min NUMBER;
ln_result NUMBER;

BEGIN

   lv_prefix := substr(p_time_zone_offset,1,1);
   IF  lv_prefix = '-' THEN -- Negative number
      ln_hour := to_number(substr(p_time_zone_offset,2,2));
      ln_min := to_number(substr(p_time_zone_offset,5,2))/60;
      ln_result := (ln_hour + ln_min) * (-1);
   ELSIF lv_prefix = '+' THEN -- Positive number
      ln_hour := to_number(substr(p_time_zone_offset,2,2));
      ln_min := to_number(substr(p_time_zone_offset,5,2))/60;
      ln_result := (ln_hour + ln_min);
   ELSE -- Positive number without prefix
      ln_hour := to_number(substr(p_time_zone_offset,1,2));
      ln_min := to_number(substr(p_time_zone_offset,4,2))/60;
      ln_result := (ln_hour + ln_min);
   END IF;

   RETURN ln_result/24;
   --(to_number(substr(p_time_zone_offset,1,3)) + to_number(substr(p_time_zone_offset,5,2))/60 ) / 24;

END getTZoffsetInDays;

FUNCTION getTimeZone(p_class_name VARCHAR2, p_object_id VARCHAR2, p_daytime DATE) RETURN VARCHAR2
IS
  lv_time_zone      VARCHAR2(65);
  lv_pdd_object_id  VARCHAR2(32);
BEGIN

   IF lv2_main_time_zone IS NULL THEN
     FOR one IN c_preference('TIME_ZONE_REGION') LOOP
       lv2_main_time_zone := one.pref_verdi;
     END LOOP;
   END IF;
  IF p_object_id IS NOT NULL THEN
    -- object id is provided. Probably slow op
    lv_pdd_object_id := Ecdp_ProductionDay.findProductionDayDefinition(p_class_name, p_object_id, p_daytime);
    FOR one IN c_productionday(lv_pdd_object_id, p_daytime) LOOP
      lv_time_zone := one.time_zone_region;
    END LOOP;
  END IF;

  IF lv_time_zone IS NULL THEN
    lv_time_zone := lv2_main_time_zone;
  END IF;

  RETURN lv_time_zone;
END;

FUNCTION getCurrentSysdate(p_time_zone VARCHAR2 DEFAULT NULL) RETURN DATE
IS

lv_time_zone t_preferanse.pref_verdi%TYPE;

BEGIN
    IF p_time_zone IS NOT NULL THEN
      lv_time_zone := p_time_zone;
    ELSE
      lv_time_zone := getTimeZone(NULL,NULL, SYSDATE);
    END IF;

    RETURN CAST(CURRENT_TIMESTAMP AT TIME ZONE lv_time_zone AS DATE);

END getCurrentSysdate;

/*
* Take a Production Day object_id and a production day as inputs, and
* return the sub-daily daytime in UTC when this production day starts.
* This function is used by getNumHours and getProductionDay
*
* @param p_class_name Class name for the object. Null value is allowed.
* @param p_object_id Object ID of the object, used to find it's corresponding production day ID
* @param p_day given date
* @return The start time of the date
*/
FUNCTION getProductionDayStartTime(p_class_name VARCHAR2,
                                   p_object_id  VARCHAR2,
                                   p_day     DATE
                                   )
RETURN DATE
--</EC-DOC>

IS
  ld_pd_start       DATE;
  ld_pd_utc_start   DATE;
  lv2_offset        NUMBER;
  ld_day            DATE;
  lv_pdd_object_id  VARCHAR2(32);
  lv_timezone       VARCHAR2(240);

BEGIN
  ld_day := TRUNC(Nvl(p_day,SYSDATE));

  lv_pdd_object_id := Ecdp_ProductionDay.findProductionDayDefinition(p_class_name, p_object_id, ld_day);

  FOR one IN c_productionday(lv_pdd_object_id, ld_day) LOOP
    lv2_offset := gettzoffsetindays(one.offset);
  END LOOP;

  IF lv2_offset IS NULL THEN
    RAISE_APPLICATION_ERROR(-20000,'The offset of production day should not be null.');
  END IF;

  ld_pd_start := ld_day + lv2_offset;

  -- Check if the date is invalid
  -- TODO more check before performing this query
  lv_timezone := getTimeZone(p_class_name, p_object_id, ld_day);
  BEGIN
    ld_pd_utc_start := CAST(FROM_TZ(CAST(ld_pd_start AS TIMESTAMP), lv_timezone) AT TIME ZONE 'UTC' AS DATE);
  EXCEPTION WHEN OTHERS THEN
    IF SQLCODE = -1878 THEN
      -- Invalid date..
      ld_pd_utc_start := CAST(FROM_TZ(CAST((ld_pd_start + 1/24) AS TIMESTAMP), lv_timezone) AT TIME ZONE 'UTC' AS DATE);
    ELSE
      RAISE;
    END IF;
  END;

  RETURN ld_pd_utc_start;

END getProductionDayStartTime;

FUNCTION utc2local(p_class_name VARCHAR2, p_object_id VARCHAR2, p_daytime DATE) RETURN DATE IS

  lv_timezone       VARCHAR2(240);

BEGIN
  lv_timezone := getTimeZone(p_class_name, p_object_id, p_daytime);

  RETURN CAST(FROM_TZ(CAST(p_daytime AS TIMESTAMP),
                    'UTC') AT TIME ZONE lv_timezone AS DATE);

END utc2local;


FUNCTION local2utc(p_class_name VARCHAR2, p_object_id VARCHAR2, p_daytime DATE) RETURN DATE IS

  lv_timezone       VARCHAR2(240);
  ld_return_date    DATE;

BEGIN

  lv_timezone := getTimeZone(p_class_name, p_object_id, p_daytime);

  BEGIN
    ld_return_date := CAST(FROM_TZ(CAST(p_daytime AS TIMESTAMP), lv_timezone) AT TIME ZONE 'UTC' AS DATE);
  EXCEPTION WHEN OTHERS THEN
    IF SQLCODE = -1878 THEN
     -- Invalid date. Return NULL, according to previous code
     ld_return_date := NULL;
    ELSE
      RAISE;
    END IF;
  END;

  RETURN ld_return_date;
END local2utc;

/*
The original code uses UTC conversion before calculation, while the offset is most probably local...
*/
FUNCTION getNumHours(p_class_name VARCHAR2, p_object_id VARCHAR2, p_daytime DATE)
RETURN NUMBER IS

  lv_timezone       VARCHAR2(240);

  -- start of production day, end of day, and the differences
  ld_start          DATE;
  ld_end            DATE;
  li_interval       INTERVAL DAY TO SECOND;

  ln_hours          NUMBER;

BEGIN

  lv_timezone := getTimeZone(p_class_name, p_object_id, p_daytime);

  -- start and end does not care about dst
  -- to make it less complicated, convert the utc production_day start to local
  ld_start := utc2local(p_class_name, p_object_id, getProductionDayStartTime(p_class_name, p_object_id, p_daytime));
  ld_end   := ld_start + 1;

  -- get the interval. date is internally converted to timestamp with time zone
  li_interval := from_tz(CAST(ld_end AS TIMESTAMP), lv_timezone)
                  - from_tz(CAST(ld_start AS TIMESTAMP), lv_timezone);

  ln_hours := EXTRACT(DAY FROM li_interval) * 24
             + EXTRACT(HOUR FROM li_interval)
             + EXTRACT(MINUTE FROM li_interval) / 60
             + EXTRACT(SECOND FROM li_interval) / 3600;

  RETURN ln_hours;

END getNumHours;

FUNCTION getProductionDay(p_class_name      VARCHAR2,
                          p_object_id       VARCHAR2,
                          p_utc_daytime     DATE)
RETURN DATE
--</EC-DOC>
IS
  ld_productionDay  DATE;
  ld_daytime        DATE;
  ld_nextDayStart   DATE;
  ld_dayStart       DATE;
BEGIN

  ld_daytime := Nvl(p_utc_daytime,TRUNC(SYSDATE));
  ld_daytime := utc2local(p_class_name, p_object_id, ld_daytime);

  ld_dayStart := utc2local(p_class_name, p_object_id, getProductionDayStartTime(p_class_name, p_object_id,TRUNC(ld_daytime)));
  ld_nextDayStart := utc2local(p_class_name, p_object_id, getProductionDayStartTime(p_class_name, p_object_id,(TRUNC(ld_daytime)+1)));

  IF ld_daytime < ld_dayStart THEN
    ld_productionDay := TRUNC(ld_daytime) - 1 ;
  ELSE
    IF ld_daytime >= ld_nextDayStart THEN
       ld_productionDay := TRUNC(ld_daytime) + 1;
    ELSE
       ld_productionDay := TRUNC(ld_daytime);
    END IF;
  END IF;


  RETURN ld_productionDay;
END getProductionDay;


END EcDp_Timestamp;