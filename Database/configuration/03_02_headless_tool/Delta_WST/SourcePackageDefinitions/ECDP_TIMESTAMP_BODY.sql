CREATE OR REPLACE PACKAGE BODY EcDp_Timestamp IS
/****************************************************************
** Package            :   EcDp_Timestamp, body part
**
** Purpose            :   Definition of date and time methods
**
** Documentation   :   www.energy-components.com
**
** Created   : 16.08.2017
**
** Modification history:
**
** Date            Whom   	Change description:
** ------         ----- 	-----------------------------------
**
*****************************************************************/

lv2_main_time_zone    T_PREFERANSE.PREF_VERDI%TYPE;

CURSOR c_preference (cp_pref_id VARCHAR2) IS
   SELECT pref_verdi
      FROM t_preferanse
    WHERE pref_id = cp_pref_id;

CURSOR c_object_prod_day_version (cp_object_id VARCHAR2, cp_daytime DATE) IS
 SELECT pdv.*
 FROM objects_version_table ovt
 INNER JOIN production_day_version pdv ON pdv.object_id = ovt.production_day_id
                                      AND nvl(cp_daytime, pdv.daytime) >= pdv.daytime
									  AND nvl(cp_daytime, pdv.daytime) < Nvl(pdv.end_date,cp_daytime+1)
 WHERE ovt.object_id = cp_object_id
   AND nvl(cp_daytime, ovt.daytime) >= ovt.daytime
   AND nvl(cp_daytime, ovt.daytime) < Nvl(ovt.end_date,cp_daytime+1)
 ORDER BY ovt.daytime, pdv.daytime;

CURSOR c_default_productionday(cp_daytime DATE) IS
   SELECT   pv.*
   FROM     production_day_version pv
   WHERE    nvl(cp_daytime,pv.daytime) >= pv.daytime
   AND      nvl(cp_daytime,pv.daytime) < Nvl(pv.end_date,cp_daytime+1)
   AND      pv.default_ind = 'Y'
   ORDER BY pv.object_id;

PROCEDURE flush_buffer IS

BEGIN
   lv2_main_time_zone := NULL;
END flush_buffer;

FUNCTION getTimeZone(p_object_id VARCHAR2, p_daytime DATE) RETURN VARCHAR2
IS
   lv_time_zone VARCHAR2(65);
BEGIN
   IF p_object_id IS NOT NULL THEN
      FOR one IN (
        SELECT ovt.time_zone
        FROM objects_version_table ovt
        WHERE ovt.object_id = p_object_id
        AND NVL(p_daytime, ovt.daytime) >= ovt.daytime
        AND NVL(p_daytime, ovt.daytime) < NVL(ovt.end_date, p_daytime+1)
	  ) LOOP
         lv_time_zone := one.time_zone;
      END LOOP;
   END IF;

   -- default fallback
   IF lv_time_zone IS NULL THEN
      FOR one IN c_preference('TIME_ZONE_REGION') LOOP
         lv_time_zone := one.pref_verdi;
      END LOOP;
   END IF;

   RETURN lv_time_zone;
END getTimeZone;

FUNCTION getCurrentSysdate(p_time_zone VARCHAR2 DEFAULT NULL) RETURN DATE
IS

   lv_time_zone t_preferanse.pref_verdi%TYPE;

BEGIN
   IF p_time_zone IS NOT NULL THEN
      lv_time_zone := p_time_zone;
   ELSE
      lv_time_zone := getTimeZone(NULL, SYSDATE);
   END IF;

   RETURN CAST(CURRENT_TIMESTAMP AT TIME ZONE lv_time_zone AS DATE);

END getCurrentSysdate;

FUNCTION utc2local(p_object_id VARCHAR2, p_daytime DATE) RETURN DATE IS

   lv_timezone    VARCHAR2(240);

BEGIN
   lv_timezone := getTimeZone(p_object_id, p_daytime);

   RETURN CAST(FROM_TZ(CAST(p_daytime AS TIMESTAMP),
                              'UTC') AT TIME ZONE lv_timezone AS DATE);

END utc2local;


FUNCTION local2utc(p_object_id VARCHAR2, p_daytime DATE, p_switch_hr_fix BOOLEAN DEFAULT FALSE) RETURN DATE IS

   lv_timezone       VARCHAR2(240);
   ld_return_date    DATE;

BEGIN

   lv_timezone := getTimeZone(p_object_id, p_daytime);

   BEGIN
      ld_return_date := CAST(FROM_TZ(CAST(p_daytime AS TIMESTAMP), lv_timezone) AT TIME ZONE 'UTC' AS DATE);
   EXCEPTION WHEN OTHERS THEN
      IF SQLCODE = -1878 THEN
         -- Invalid date. Return NULL according to previous code, or next hour based on p_switch_hr_fix
         IF p_switch_hr_fix THEN
            ld_return_date := CAST(FROM_TZ(CAST(p_daytime + 1/24 AS TIMESTAMP), lv_timezone) AT TIME ZONE 'UTC' AS DATE);
         ELSE
            ld_return_date := NULL;
         END IF;
      ELSE
         RAISE;
      END IF;
   END;

   IF p_switch_hr_fix AND utc2local(p_object_id, ld_return_date - 1/24) = p_daytime THEN
      ld_return_date := ld_return_date - 1/24;
   END IF;
   RETURN ld_return_date;
END local2utc;

/*
The original code uses UTC conversion before calculation, while the offset is most probably local...
*/
FUNCTION getNumHours(p_object_id VARCHAR2, p_daytime DATE)
RETURN NUMBER IS
   -- start of production day, end of day, and the differences
   ld_start    DATE;
   ld_end      DATE;
   ln_offset   NUMBER;

BEGIN

   FOR one IN c_object_prod_day_version(p_object_id, p_daytime) LOOP
      ln_offset := one.production_day_offset_hrs/24;
   END LOOP;

   IF ln_offset IS NULL THEN
      FOR one IN c_default_productionday(p_daytime) LOOP
         ln_offset := one.production_day_offset_hrs/24;
      END LOOP;
   END IF;

   -- start and end in local date
   ld_start := TRUNC(p_daytime) + ln_offset;
   ld_end   := ld_start + 1;

   -- convert to utc for better precision. Takes first hour in duplicated hour
   ld_start := local2utc(p_object_id, ld_start, TRUE);
   ld_end   := local2utc(p_object_id, ld_end, TRUE);

   RETURN Nvl(TRUNC(24 * (ld_end - ld_start)), 24);

END getNumHours;

FUNCTION getProductionDay(p_object_id     VARCHAR2,
                          p_daytime       DATE)
RETURN DATE
--</EC-DOC>
IS
BEGIN
   RETURN getProductionDayFromLocal(p_object_id, p_daytime);
END getProductionDay;

FUNCTION getProductionDayFromLocal(p_object_id IN VARCHAR2, p_daytime IN DATE)
RETURN DATE
IS
BEGIN
   FOR cur IN c_object_prod_day_version(p_object_id, p_daytime) LOOP
      RETURN trunc(p_daytime - cur.production_day_offset_hrs/24);
   END LOOP;

   -- default fallback when p_object_id is null
   FOR cur IN c_default_productionday(p_daytime) LOOP
      RETURN trunc(p_daytime - cur.production_day_offset_hrs/24);
   END LOOP;
   RETURN NULL;
END getProductionDayFromLocal;

/*
* Returns the production day version that applies to the given object.
* @param p_object_id Object id (nulls are not supported)
* @param p_daytime Object version daytime
*/
FUNCTION getProductionDayVersion(p_object_id IN VARCHAR2, p_daytime IN DATE)
RETURN PRODUCTION_DAY_VERSION%ROWTYPE
IS
BEGIN
   FOR cur IN c_object_prod_day_version(p_object_id, p_daytime) LOOP
      RETURN cur;
   END LOOP;

   -- default fallback when p_object_id is null
   FOR cur IN c_default_productionday(p_daytime) LOOP
      RETURN cur;
   END LOOP;
   RETURN NULL;
END getProductionDayVersion;

FUNCTION getNumHours(p_class_name VARCHAR2, p_object_id VARCHAR2, p_daytime DATE) RETURN NUMBER
IS
BEGIN
    RETURN getNumHours(p_object_id, p_daytime);
END getNumHours;

FUNCTION utc2local(p_class_name VARCHAR2, p_object_id VARCHAR2, p_daytime DATE) RETURN DATE
IS
BEGIN
    RETURN utc2local(p_object_id, p_daytime);
END utc2local;

FUNCTION local2utc(p_class_name VARCHAR2, p_object_id VARCHAR2, p_daytime DATE) RETURN DATE
IS
BEGIN
    RETURN local2utc(p_object_id, p_daytime);
END local2utc;

FUNCTION getProductionDay(p_class_name VARCHAR2, p_object_id VARCHAR2, p_utc_daytime DATE) RETURN DATE
IS
BEGIN
    RETURN getProductionDay(p_object_id, p_utc_daytime);
END getProductionDay;

END EcDp_Timestamp;