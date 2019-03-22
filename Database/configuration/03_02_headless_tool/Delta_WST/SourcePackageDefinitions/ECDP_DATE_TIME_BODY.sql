CREATE OR REPLACE PACKAGE BODY EcDp_Date_Time IS
/****************************************************************
** Package        :  EcDp_Date_Time, body part
**
** $Revision: 1.37 $
**
** Purpose        :  Definition of date and time methods
**
** Documentation  :  www.energy-components.com
**
** Created  : 27.12.1999  Carl-Fredrik Sørensen
**
** Modification history:
**
** Date        Whom  	Change description:
** ------      ----- 	-----------------------------------
** 27.12.1999  CFS   	Initial version
** 13.09.2001  AV    	Moved ut2local and Summertime handling here
** 14.09.2001  AV    	Changed local2utc to use summertime flag
** 28.09.2001  AV    	Bugfix in local2utc, extended getNumHours,getNumHalfHours
** 10.10.2001  AV    	Introduced new paramater p_default_utc_offset
**                   	for function summertime flag
** 23.11.2001  AV    	Changed getNumHours to check production day
**                   	start in ctrl_system_attribute
** 11.01.2002  FBa   	Added function getNumDaysInMonth
** 10.11.2003  DN    	Addded time zone functions. (Ref. 7.3 inc.1 )
** 19.11.2003  DN    	Added getSystemName here.
** 25.11.2003  DN    	Bug fix in getCurrentSysdate. More robust UTC-calculation in getforeignSysdate.
** 17.03.2004  DN    	Bug fix in getCurrentSysdate. Replaced sys_extract_utc with with dbTimeZone.
** 25.05.2004  DN    	More robust cast of dbtimezone return value in getForeignSysdate.
** 26.05.2004  FBa   	Modified function summertime_flag to return Y/N instead of S/W
** 29.06.2004  DN    	Added getCurrentDBSysdate and calcDBSysdateByForeignTimeZone.
** 02.09.2004  DN    	EBF TI 1532: Bug fix in use of dbTimeZone function. Added cast command in new function getDBTimeZone.
** 07.04.2008  RAJARSAR ECPD-8081:Modified getNumHours and getNumHalfHours.
** 21.08.2008  LEEEEWEI ECPD-7979: Added new procedure checkFutureDate
** 08.07.2009  LEONGWEN ECPD-11578: Support Multiple Timezones
**                      I used the variable name (p_pday_object_id) for parameter_productionday_object_id.
**                      The (pdd_object_id) variable is also used for the same productionday_object_id by other developer.
**                      I just used (p_pday_object_id) variable to differentiate my works for ECPD-11578 only.
**											Created the new function getAltTZOffsetinDays() to get the alternative code for Time Zone Offset.
** 31.07.2009  Toha     ECPD-11578:Modified getAltTZDefaultOffset to use internal cursor instead of ec_prosty_code call (package not created yet during build)
** 03.08.2009  AV       ECPD-11578:Correcting findings from code review
** 08.10.2012  meisihil ECPD-20961: Added new function getNextHour
*****************************************************************/

CURSOR c_prosty_alt_codes(cp_code VARCHAR2, cp_code_type VARCHAR2) IS
   SELECT alt_code col
   FROM PROSTY_CODES
   WHERE code = cp_code
   AND code_type = cp_code_type;

TYPE t_dst_switch IS RECORD (time_zone  VARCHAR2(65),
                             dst_year   DATE,
                             summer     DATE,  -- switch to summer
                             winter     DATE); -- switch to winter

lc_dst_switch t_dst_switch;

PROCEDURE resetDstCache(p_time_zone VARCHAR2, p_date DATE)
IS
  CURSOR c_cte(cp_timezone VARCHAR2, cp_daytime DATE) IS
    WITH date_cte AS
     (     SELECT TRUNC(cp_daytime, 'YY') + rownum -1 daytime
         FROM ctrl_db_version WHERE db_version = 1
         CONNECT BY rownum <= ADD_MONTHS(TRUNC(cp_daytime, 'yy'), 12) - TRUNC(cp_daytime, 'yy')),
    dst_sub AS
     (SELECT daytime,
             TO_NUMBER(TO_CHAR(FROM_TZ(CAST(daytime AS TIMESTAMP), cp_timezone),
                               'TZH')) +
             TO_NUMBER(TO_CHAR(FROM_TZ(CAST(daytime AS TIMESTAMP), cp_timezone),
                               'TZM')) / 60 offset,
             TO_NUMBER(TO_CHAR(FROM_TZ(CAST(daytime + 1 AS TIMESTAMP),
                                       cp_timezone),
                               'TZH')) +
             TO_NUMBER(TO_CHAR(FROM_TZ(CAST(daytime + 1 AS TIMESTAMP),
                                       cp_timezone),
                               'TZM')) / 60 next_offset
        FROM date_cte)
    SELECT daytime, Ecdp_Timestamp_Utils.getDSTTime(cp_timezone, daytime) dst_switch, offset, next_offset
      FROM dst_sub
     WHERE offset <> next_offset
     ORDER BY daytime;

  cp_year   DATE := TRUNC(p_date, 'YY');
BEGIN
  lc_dst_switch.time_zone := p_time_zone;
  lc_dst_switch.dst_year  := cp_year;

  FOR one IN c_cte(p_time_zone, p_date) LOOP
    IF one.offset > one.next_offset THEN
      lc_dst_switch.winter := one.dst_switch;
    ELSE
      lc_dst_switch.summer := one.dst_switch;
    END IF;
  END LOOP;
END resetDstCache;

FUNCTION getDSTCache(p_time_zone VARCHAR2, p_date DATE) RETURN t_dst_switch
IS
BEGIN

  IF lc_dst_switch.dst_year IS NULL OR lc_dst_switch.time_zone <> p_time_zone OR lc_dst_switch.dst_year <> TRUNC(p_date, 'YY') THEN
    resetDstCache(p_time_zone, p_date);
  END IF;
  RETURN lc_dst_switch;
END getDSTCache;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getCurrentSysdate
-- Description    : Returns the date and time of the current operation.
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : T_PREFERANSE
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getCurrentSysdate RETURN DATE
--</EC-DOC>
IS

BEGIN

   RETURN Ecdp_Timestamp.getCurrentSysdate;

END getCurrentSysdate;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getCurrentDBSysdate
-- Description    : Calculates the corresponding local database datetime for a certain datetime
--                  within the time zone it operates.
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
-- Using functions: calcDBSysdateByForeignTimeZone
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getCurrentDBSysdate(p_daytime DATE) RETURN DATE
--</EC-DOC>
IS

BEGIN
   RETURN Ecdp_Timestamp.getCurrentSysdate(dbtimezone);

END getCurrentDBSysdate;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getTZoffsetInDays
-- Description    : Convert the given time zone offset to number of days for usage in date calculations.
--
-- Preconditions  : p_time_zone_offset must be a string on format +-HH:MM
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getTZoffsetInDays(p_time_zone_offset VARCHAR2) RETURN NUMBER
--</EC-DOC>
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

FUNCTION getNumHours(p_class_name VARCHAR2, p_object_id VARCHAR2, p_daytime DATE)
RETURN INTEGER IS

BEGIN

    RETURN Ecdp_Timestamp.getNumHours(p_class_name, p_object_id, p_daytime);

END getNumHours;
--

FUNCTION getNumHalfHours(p_class_name VARCHAR2, p_object_id VARCHAR2, p_daytime DATE)
RETURN INTEGER IS
BEGIN
	RETURN getNumHours(p_class_name,p_object_id, p_daytime)*2;
END getNumHalfHours;


FUNCTION utc2local(p_datetime DATE, p_pday_object_id VARCHAR2 DEFAULT NULL) RETURN DATE IS

BEGIN

    RETURN Ecdp_Timestamp.utc2local('PRODUCTION_DAY', p_pday_object_id, p_datetime);

END utc2local;


FUNCTION local2utc(p_datetime DATE,p_summertime_flag varchar2 DEFAULT 'N', p_pday_object_id VARCHAR2 DEFAULT NULL) RETURN DATE IS

  ld_return         DATE;
  lv_timezone       VARCHAR2(65);
  lr_dst_switch     t_dst_switch;

BEGIN
  ld_return := Ecdp_Timestamp.local2utc('PRODUCTION_DAY', p_pday_object_id, p_datetime);
  lv_timezone := Ecdp_Timestamp.getTimeZone(p_pday_object_id, p_datetime);
  lr_dst_switch := getDSTCache(lv_timezone, p_datetime);

  IF lr_dst_switch.winter = ld_return THEN
    IF p_summertime_flag = 'Y' THEN
      ld_return := ld_return - 1/24;
    END IF;
  END IF;

  RETURN ld_return;
END local2utc;

------------------------------------------------------------------
-- FUNCTION: summertime_flag
-- Returns Y if summertime or N if not
-- Based on Norwegian rules
------------------------------------------------------------------
FUNCTION summertime_flag(p_date DATE,p_default_utc_offset NUMBER default NULL, p_pday_object_id VARCHAR2 DEFAULT NULL  )
RETURN VARCHAR2
IS

  lv_timezone       VARCHAR2(50);
  ln_from_offset    NUMBER;
  ln_to_offset      NUMBER;
  ld_from           DATE;
  ld_to             DATE;
  lv_result         VARCHAR2(5) := 'N';
  lr_dst_switch     t_dst_switch;
BEGIN

  lv_timezone := Ecdp_Timestamp.getTimeZone(p_pday_object_id, p_date);
  lr_dst_switch := getDSTCache(lv_timezone, p_date);

  IF lc_dst_switch.summer IS NULL THEN
    -- DST not observed
    lv_result := 'N';
  ELSIF p_date >= lc_dst_switch.summer AND p_date < lc_dst_switch.winter THEN
    lv_result := 'Y';
  ELSE
    lv_result := 'N';
  END IF;

  RETURN lv_result;

END summertime_flag;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getProductionDay
-- Description    : take a Production Day object_id and a sub-daily daytime as inputs,
--                  and return the production day
--
-- Preconditions  : Given p_daytime is local time, if invalid offset in config, uses 0 offset
--                  offset is assumed to be refering to local time.
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
-- The User Exit package ue_xxx.getProductionDay should be called first,
-- and if that returns a non-NULL value then that value should be used.
-- Calculations in this function is designed to handle daylight savings time transitions correctly.
--
---------------------------------------------------------------------------------------------------
FUNCTION getProductionDay(pdd_object_id VARCHAR2,
                          p_daytime     DATE,
                          p_summer_time VARCHAR2
                          )
RETURN DATE
--</EC-DOC>
IS

  ld_productionDay  DATE;
  ld_pd_start       DATE;
  ld_daytime        DATE;
  ld_nextProductionDayStart        Ec_Unique_Daytime;
  ln_offset         NUMBER;
  l_ec_unique_daytime Ec_Unique_Daytime;

BEGIN

  RETURN Ecdp_ProductionDay.getProductionDay('PRODUCTION_DAY', pdd_object_id, p_daytime);

END getProductionDay;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getProductionDayStartTime
-- Description    : take a Production Day object_id and a production day as inputs, and
--                  return the sub-daily daytime (in local time) when this production day starts.
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
--This function should use getProductionDayStartTimeUTC to do the actual job and then convert the result back to local time.
---------------------------------------------------------------------------------------------------
FUNCTION getProductionDayStartTime(pdd_object_id VARCHAR2,
                                   p_day     DATE
                                   )
RETURN Ec_Unique_daytime
--</EC-DOC>

IS

BEGIN

  RETURN Ecdp_ProductionDay.getProductionDayStartTime('PRODUCTION_DAY', pdd_object_id, p_day);

END getProductionDayStartTime;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getProductionDayFraction
-- Description    : take a Production Day object_id, a production day and sub-daily from and
--                  to daytimes as inputs, and return the fraction of overlap between
--                  the production day and the interval [from_daytime, to_daytime>.
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
--    The function should convert the interval from/to values to UTC and use
--    getProductionDayStartTimeUTC to find the start and end time of the production day in UTC.
--    The overlap can then be calculated as a fraction from 0 to 1.
--
---------------------------------------------------------------------------------------------------
FUNCTION getProductionDayFraction(pdd_object_id       VARCHAR2,
                                  p_day               DATE,
                                  p_from_daytime      DATE,
                                  p_from_summer_time  VARCHAR2,
                                  p_to_daytime        DATE,
                                  p_to_summer_time    VARCHAR2
                                  )
RETURN NUMBER
--</EC-DOC>

IS

BEGIN
  RETURN Ecdp_ProductionDay.getProductionDayFraction('PRODUCTION_DAY', pdd_object_id, p_day, p_from_daytime, p_from_summer_time, p_to_daytime, p_to_summer_time);

END getProductionDayFraction;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getProductionDayDaytimes
-- Description    : take a Production Day object_id, a sub-day frequency code and a production day as inputs,
--                  and return a list of all sub-daily daytimes within that production day.
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--    The function should use getProductionDayStartTimeUTC to find the start and end times for the day in UTC.
--    The frequency interval (in minutes) should be found from the ALT_CODE for the sub day frequency code.
--    The function should then step through the day (in UTC) from the start time to the end time with
--    the intervals given by the frequency. Each daytime must be converted to local time and added to the list.
--
---------------------------------------------------------------------------------------------------
FUNCTION getProductionDayDaytimes(pdd_object_id VARCHAR2,
                                  p_sub_day_freq_code VARCHAR2,
                                  p_day     DATE)
RETURN Ec_Unique_daytimes

--</EC-DOC>

IS
BEGIN

  RETURN Ecdp_ProductionDay.getProductionDayDaytimes('PRODUCTION_DAY', pdd_object_id, p_day);

END getProductionDayDaytimes;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : validateDaytimeVsFreq
-- Description    : take a Production Day object_id, a sub-day frequency code and a sub-daily daytime
--                  as inputs, and validate that daytime against the sub-daily data frequency.
--                  So for instance if the data frequency is set to 1H and the production day start
--                  at 06:00, then 06:00, 07:00 and so on are valid daytimes but e.g. 06:15 is not.
--                  An error should be raised if the validation fails.
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
--   This function should convert the daytime to UTC and use first getProductionDay and then
--   getProductionDayStartTimeUTC to find the start time of the production day the daytime belongs to.
--   Based on this information, calculate the number of minutes into the production day that the daytime
--   represents. E.g. if the daytime is 08:15 and the production day starts at 06:00 then the daytime
--   is 135 minutes into the production day.
--   Finally the frequency interval (in minutes) should be found from the ALT_CODE for the sub day
--   frequency code and used to validate the daytime. So if the interval is 15min then everything
--   is ok since 15 divides 135 (135 mod 15 == 0), but if the interval is 60 then there is
--   an error (135 mod 60 == 15 != 0).

---------------------------------------------------------------------------------------------------
PROCEDURE validateDaytimeVsFreq(pdd_object_id VARCHAR2,
                                p_sub_day_freq_code VARCHAR2,
                                p_daytime     DATE,
                                p_summer_time VARCHAR2
                                )
--</EC-DOC>

IS
  l_ec_unique_daytime         Ec_Unique_Daytime;
  l_ec_unique_daytimes        Ec_Unique_Daytimes;
  ld_daytime_utc              DATE;
  ld_productionday_start      DATE;
  ld_productionday_start_utc  DATE;
  ln_elapsed                  NUMBER;
  ln_freq_interval            NUMBER;


BEGIN

  ld_daytime_utc := Ecdp_Timestamp.local2utc('PRODUCTION_DAY', pdd_object_id, p_daytime);

  ld_productionday_start := Ecdp_ProductionDay.getProductionDay('PRODUCTION_DAY', pdd_object_id, p_daytime);

  ld_productionday_start_utc := Ecdp_Timestamp.local2utc('PRODUCTION_DAY', pdd_object_id, ld_productionday_start);

  ln_elapsed := getDateDiff('MI',ld_daytime_utc,ld_productionday_start_utc);

  FOR cur_code IN c_prosty_alt_codes(UPPER(p_sub_day_freq_code),'METER_FREQ') LOOP
    ln_freq_interval := to_number(Nvl(cur_code.col,0));  -- convert to hour
  END LOOP;

  IF MOD(ln_elapsed,ln_freq_interval) <> 0 THEN
    RAISE_APPLICATION_ERROR(-20000,to_char(p_daytime,'yyyy-mm-dd hh24:mi')||' is not a valid time according to sub-daily data frequency.');
  END IF;

END validateDaytimeVsFreq;

--<EC-DOC>
FUNCTION getDateDiff(p_what VARCHAR2, p_dt1 DATE, p_dt2 DATE)

RETURN NUMBER
--</EC-DOC>
IS
  ln_result  NUMBER;
BEGIN
  SELECT (p_dt2 - p_dt1) *
          DECODE(UPPER(p_what),
          'SS', 24*60*60,
          'MI', 24*60,
          'HH', 24,
          NULL)
          INTO ln_result FROM dual;

  RETURN ln_result;
END getDateDiff;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getProductionDayOffset
-- Description    :
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getProductionDayOffset(p_object_id VARCHAR2,
                                p_daytime DATE,
                                p_summer_time VARCHAR2 DEFAULT NULL)
RETURN NUMBER
--</EC-DOC>
IS

BEGIN
  RETURN Ecdp_ProductionDay.getProductionDayOffset('PRODUCTION_DAY', p_object_id, p_daytime, p_summer_time);

END getProductionDayOffset;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getNextHour
-- Description    : Returns next hour
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      : Converts the hour given to utc, adds one hour and converts back to local time
---------------------------------------------------------------------------------------------------
FUNCTION getNextHour(p_date DATE, p_summer_time VARCHAR2)
RETURN EcDp_Date_Time.Ec_Unique_Daytime
--</EC-DOC>
IS
	ld_date DATE := NULL;
	lv_summer_time VARCHAR2(1);
	lv_date VARCHAR2(32);

	lud_result EcDp_Date_Time.Ec_Unique_Daytime;
BEGIN
	ld_date := ecdp_date_time.local2utc(p_date, p_summer_time);
	ld_date := ld_date + 1/24;
	lv_summer_time := ecdp_date_time.summertime_flag(ld_date);
	ld_date := ecdp_date_time.utc2local(ld_date);
	lv_date := to_char(ld_date, 'dd-mm-yyyy hh24:mi');

	lud_result.daytime := ld_date;
	lud_result.summertime_flag := lv_summer_time;

	RETURN lud_result;
END getNextHour;

END;