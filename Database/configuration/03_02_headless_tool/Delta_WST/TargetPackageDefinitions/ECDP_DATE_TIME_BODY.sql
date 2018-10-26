CREATE OR REPLACE PACKAGE BODY EcDp_Date_Time IS
/****************************************************************
** Package        :  EcDp_Date_Time, body part
**
** $Revision: 1.36.4.3 $
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

CURSOR c_preference (cp_pref_id VARCHAR2) IS
SELECT pref_verdi
FROM t_preferanse
WHERE pref_id = cp_pref_id;

CURSOR c_productionday(cpdd_object_id VARCHAR2, cp_daytime DATE) IS
  SELECT offset
  FROM  production_day_version pv
  WHERE   nvl(cp_daytime,pv.daytime) >= pv.daytime
  AND     nvl(cp_daytime,pv.daytime) < Nvl(pv.end_date,cp_daytime+1)
  AND   (object_id = cpdd_object_id OR ( cpdd_object_id IS NULL AND pv.default_ind = 'Y'))
  ORDER BY pv.object_id ;  -- To make it deterministic in case of error in config (more than 1 default)

CURSOR c_default_productionday(cp_daytime DATE) IS
  SELECT  pv.object_id
  FROM    production_day_version pv
  WHERE   nvl(cp_daytime,pv.daytime) >= pv.daytime
  AND     nvl(cp_daytime,pv.daytime) < Nvl(pv.end_date,cp_daytime+1)
  AND     pv.default_ind = 'Y'
  ORDER BY pv.object_id ;  -- To make it deterministic in case of error in config (more than 1 default)

CURSOR c_prosty_alt_codes(cp_code VARCHAR2, cp_code_type VARCHAR2) IS
   SELECT alt_code col
   FROM PROSTY_CODES
   WHERE code = cp_code
   AND code_type = cp_code_type;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getDBTimeZone
-- Description    : Returns the time zone code the database instance is set up with as a character string.
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
FUNCTION getDBTimeZone RETURN VARCHAR2
--</EC-DOC>
IS

CURSOR c_tz IS
SELECT cast (dbtimezone AS VARCHAR2(100)) tz_string
FROM dual;

lv2_db_time_zone VARCHAR2(100);

BEGIN

   FOR cur_rec IN c_tz LOOP

      lv2_db_time_zone := cur_rec.tz_string;

   END LOOP;

   RETURN lv2_db_time_zone;

END getDBTimeZone;



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

ld_ret_val DATE;

BEGIN

   FOR lr_current IN c_preference('TIME_ZONE_REGION') LOOP

        ld_ret_val := getForeignSysdate(lr_current.pref_verdi);

   END LOOP;

   RETURN ld_ret_val;

END getCurrentSysdate;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getForeignSysdate
-- Description    : Will return the date and time for a foreign timezone based on the database time zone.
--                  Usage ex: select to_char(getForeignSysdate('Australia/Melbourne'),'yyyy.mm.dd hh24:mi') Melbourne from dual;
--
-- Preconditions  : p_tz_region must be a valid textual time zone region. See the V_$TIMEZONE_NAMES view.
-- Postconditions :
--
-- Using tables   :
--
-- Using functions: getTZoffsetInDays, tz_offset, sysdate
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getForeignSysdate(p_tz_region VARCHAR2) RETURN DATE
--</EC-DOC>
IS

lv2_db_time_zone VARCHAR2(100);

BEGIN

   lv2_db_time_zone := getDBTimeZone;

   RETURN sysdate + (getTZoffsetInDays(tz_offset(p_tz_region)) - getTZoffsetInDays(tz_offset(lv2_db_time_zone)));

END getForeignSysdate;

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

ld_ret_val DATE;

BEGIN

   FOR lr_current IN c_preference('TIME_ZONE_REGION') LOOP

        ld_ret_val := calcDBSysdateByForeignTimeZone(p_daytime, lr_current.pref_verdi);

   END LOOP;

   RETURN ld_ret_val;

END getCurrentDBSysdate;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : calcDBSysdateByForeignTimeZone
-- Description    : Calculates the corresponding datetime on the local database given any foreign
--                  datetime and time zone.
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
-- Using functions: getTZoffsetInDays
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION calcDBSysdateByForeignTimeZone(p_daytime DATE, p_tz_region VARCHAR2) RETURN DATE
--</EC-DOC>
IS

lv2_db_time_zone VARCHAR2(100);

BEGIN

   lv2_db_time_zone := getDBTimeZone;

   RETURN p_daytime - (getTZoffsetInDays(tz_offset(p_tz_region)) - getTZoffsetInDays(tz_offset(lv2_db_time_zone)));

END calcDBSysdateByForeignTimeZone;


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


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getSystemName                                                                --
-- Description    : Returns current system name from system preferences.                         --
--                                                                                               --
-- Preconditions  :                                                                              --
-- Postcondition  :                                                                              --
-- Using Tables   : t_preferanse                                                                 --
--                                                                                               --
-- Using functions:                                                                              --
--                                                                                               --
-- Configuration                                                                                 --
-- required       :                                                                              --
--                                                                                               --
-- Behaviour      :                                                                              --
--                                                                                               --
---------------------------------------------------------------------------------------------------
FUNCTION getSystemName
RETURN VARCHAR2
--</EC-DOC>
IS

lv2_return_id t_preferanse.pref_id%TYPE;

BEGIN

   FOR lr_current IN c_preference('SYSNAM') LOOP

        lv2_return_id := lr_current.pref_verdi;

   END LOOP;

   RETURN lv2_return_id;

END getSystemName;


FUNCTION getNumHours(p_class_name VARCHAR2, p_object_id VARCHAR2, p_daytime DATE)
RETURN INTEGER IS
ld_utc_daystart DATE;
ln_timediff_start NUMBER;
ln_timediff_end NUMBER;
ln_numhours NUMBER;
ln_offset NUMBER;
ln_next_offset NUMBER;
lv_pday_object_id VARCHAR2(32);

BEGIN

	-- this is to handle the production day object id
		lv_pday_object_id := EcDp_ProductionDay.findProductionDayDefinition(p_class_name, p_object_id, p_daytime);

   -- Assuming that the input here is local time, and that we want
   -- to find if there has been a change in UTC2LOCAL this day
   -- do the following
   -- 1. Truncate to find start of day, and covert the result to UTC
   ld_utc_daystart := local2utc(trunc(p_daytime),NULL,lv_pday_object_id);

   -- Get production day offsetCheck
   -- I.E. If production day starts at 06:00 we need to use a 6 hour
   -- offset to  find if a change has occured within the offset day.

   ln_offset :=  EcDp_ProductionDay.getProductionDayOffset(p_class_name,p_object_id,p_daytime);
   ln_next_offset :=  EcDp_ProductionDay.getProductionDayOffset(p_class_name,p_object_id,p_daytime+1);
   ld_utc_daystart := ld_utc_daystart + ln_offset/24;

   -- 2. Check if there has been a change in this period
   ln_timediff_start := nvl(getutc2local_timediff(ld_utc_daystart, lv_pday_object_id ),0);
   ln_timediff_end := nvl(getutc2local_timediff(ld_utc_daystart+1, lv_pday_object_id),0);

   IF  ln_timediff_start = ln_timediff_end THEN -- No changes
      ln_numhours := 24 ;
   ELSE  -- There has been a change, calculate number of hours
      ln_numhours := 24 + round((ln_timediff_start - ln_timediff_end)*24,0);
   END IF;

   -- 3. adds production day start diff
   ln_numhours := ln_numhours - ln_offset + ln_next_offset;

	RETURN ln_numhours;

END getNumHours;
--

FUNCTION getNumHalfHours(p_class_name VARCHAR2, p_object_id VARCHAR2, p_daytime DATE)
RETURN INTEGER IS
BEGIN
	RETURN getNumHours(p_class_name,p_object_id, p_daytime)*2;
END getNumHalfHours;

FUNCTION getPDTimeZoneRegion(p_pday_object_id VARCHAR2)
RETURN VARCHAR2
IS
  CURSOR c_pd_time_zone IS
	SELECT time_zone_region
	FROM production_day_version pdv, production_day pd
	WHERE pdv.object_id = pd.object_id
	AND   pd.object_id = p_pday_object_id
  AND		pdv.daytime = pd.START_DATE;  -- Given by limitiation that we will always pick the first Time zone

  lc_time_zone_region production_day_version.time_zone_region%TYPE;

BEGIN

  FOR cpd IN c_pd_time_zone LOOP
      lc_time_zone_region := cpd.time_zone_region;
  END LOOP;

  RETURN lc_time_zone_region;

END;



FUNCTION getutc2local_default (p_pday_object_id VARCHAR2 DEFAULT NULL, p_daytime DATE DEFAULT NULL) RETURN NUMBER
IS

 CURSOR c_defaultoffset IS
 SELECT to_number(Nvl(csa.attribute_value,0))/24 offset
 FROM ctrl_system_attribute csa
 WHERE csa.attribute_type='UTC2LOCALDEFAULT';



  ln_utcDefaultDiff NUMBER;
  lc_time_zone_region  VARCHAR2(100);

BEGIN

  IF p_pday_object_id IS NOT NULL THEN

    lc_time_zone_region := getPDTimeZoneRegion(p_pday_object_id);

	  IF lc_time_zone_region IS NOT NULL THEN
			ln_utcDefaultDiff := Ecdp_date_time.getAltTZOffsetinDays(p_pday_object_id, p_daytime);
    END IF;

  END IF;

  IF ln_utcDefaultDiff IS NULL THEN

		FOR curDefault IN c_defaultoffset LOOP
  		ln_utcDefaultDiff := curDefault.offset;
 		END LOOP;

  END IF;

  RETURN Nvl(ln_utcDefaultDiff,0);

END;

FUNCTION getutc2local_timediff(p_datetime DATE, p_pday_object_id VARCHAR2 DEFAULT NULL) RETURN NUMBER
IS
CURSOR c_ctrl_system_attribute IS
       SELECT *
       FROM ctrl_system_attribute
       WHERE attribute_type = 'UTC2LOCAL_DIFF'
       AND daytime =
           (SELECT MAX(daytime)
            FROM ctrl_system_attribute
            WHERE attribute_type = 'UTC2LOCAL_DIFF'
            AND daytime <= p_datetime);

CURSOR c_pday_dst IS
       SELECT *
       FROM pday_dst
       WHERE object_id = p_pday_object_id
       AND daytime =
           (SELECT MAX(daytime)
            FROM pday_dst
            WHERE object_id = p_pday_object_id
            AND daytime <= p_datetime);

 ln_utc2local NUMBER;
 ln_utcDefaultDiff NUMBER;
 lc_time_zone_region  VARCHAR2(100);

BEGIN

  ln_utcDefaultDiff := getutc2local_default (p_pday_object_id);
  ln_utc2local := 0;  -- Default value used if no valid entries found.

  IF p_pday_object_id IS NOT NULL THEN
    lc_time_zone_region := getPDTimeZoneRegion(p_pday_object_id);
  END IF;

	IF lc_time_zone_region IS NOT NULL THEN
	  FOR pday_curDST IN c_pday_dst LOOP
 	    ln_utc2local := pday_curDST.dst_flag/24;
 		END LOOP;
	ELSE
	  FOR curAttribute IN  c_ctrl_system_attribute LOOP
  		ln_utc2local := curAttribute.ATTRIBUTE_VALUE/24;
  	END LOOP;
	END IF;

  RETURN ln_utc2local + ln_utcDefaultDiff;

END getutc2local_timediff;


FUNCTION utc2local(p_datetime DATE, p_pday_object_id VARCHAR2 DEFAULT NULL) RETURN DATE IS

  ln_utc2local NUMBER;

BEGIN

    Return p_datetime + getutc2local_timediff(p_datetime, p_pday_object_id);

END utc2local;


FUNCTION local2utc(p_datetime DATE,p_summertime_flag varchar2 DEFAULT 'N', p_pday_object_id VARCHAR2 DEFAULT NULL) RETURN DATE IS

CURSOR c_ctrl_system_attribute IS
       SELECT *
       FROM ctrl_system_attribute
       WHERE attribute_type = 'UTC2LOCAL_DIFF'
       AND daytime between p_datetime-1 AND p_datetime + 1
       order by daytime;    -- there should only be one but to make it deterministic

CURSOR c_pday_dst IS
       SELECT daytime
       FROM pday_dst
       WHERE object_id = p_pday_object_id
       AND daytime between p_datetime-1 AND p_datetime + 1
       order by daytime;    -- there should only be one but to make it deterministic

  ln_timediff_start NUMBER;
  ln_timediff_end NUMBER;
  ld_daytime_change_utc DATE;
  ld_datime_change_local_start DATE;
  ld_datime_change_local_end  DATE;
  ld_daytime_return DATE;
	lc_time_zone_region  VARCHAR2(100);

BEGIN
	-- This one can be a bit tricky need to find if there was a change for the date:

  ln_timediff_start := getutc2local_timediff(p_datetime-1, p_pday_object_id);
  ln_timediff_end := getutc2local_timediff(p_datetime+1, p_pday_object_id);

  IF  ln_timediff_start = ln_timediff_end THEN -- No changes
		ld_daytime_return := p_datetime - ln_timediff_start ;
	ELSE  -- There has been a change


    IF p_pday_object_id IS NOT NULL THEN
      lc_time_zone_region := getPDTimeZoneRegion(p_pday_object_id);
    END IF;

		IF lc_time_zone_region IS NOT NULL THEN

     	FOR curPday_dsT IN c_pday_dst LOOP
      	ld_daytime_change_utc := curPday_dst.daytime;
     	END LOOP;

		ELSE

 	   	FOR curAttribute IN  c_ctrl_system_attribute LOOP
  	  	ld_daytime_change_utc := curAttribute.daytime;
   		END LOOP;

		END IF;

		-- Ok now we should have all the information we need, just have to sort
    -- how to use it. Need to determin the buffer zone where the summertime
    -- flag must be used.

    ld_datime_change_local_start := ld_daytime_change_utc + ln_timediff_start;
    ld_datime_change_local_end := ld_daytime_change_utc + ln_timediff_end;

    -- We only have a problem if p_daytime is in the buffer zone

    IF p_datetime < LEAST(ld_datime_change_local_start,ld_datime_change_local_end) THEN
			ld_daytime_return := p_datetime - ln_timediff_start ;
		ELSIF p_datetime >= GREATEST(ld_datime_change_local_start,ld_datime_change_local_end) THEN
     	ld_daytime_return := p_datetime - ln_timediff_end ;
		ELSE  -- we are in the buffer zone

     	-- Now we got 2 possibilties:
    	IF ln_timediff_start > ln_timediff_end THEN -- we got an overlap period
				-- use summertime parameter to determin
        IF p_summertime_flag = 'N' THEN  -- Use the least offsett
					ld_daytime_return := p_datetime - least(ln_timediff_start,ln_timediff_end) ;
				ELSE
          ld_daytime_return := p_datetime - GREATEST(ln_timediff_start,ln_timediff_end) ;
				END IF;
			ELSE  -- The given local time does not exist due to the gap in local time
            -- when changing from winter to summer time.
            -- so returning NULL in that case
				ld_daytime_return := NULL;
			END IF;
		END IF;
  END IF;

  RETURN ld_daytime_return;

END local2utc;

------------------------------------------------------------------
-- FUNCTION: summertime_flag
-- Returns S if summertime or W if not
-- Based on Norwegian rules
-- Parameter in is assumed to be UTC_TIME
------------------------------------------------------------------
FUNCTION summertime_flag(p_date DATE,p_default_utc_offset NUMBER default NULL, p_pday_object_id VARCHAR2 DEFAULT NULL  )
RETURN VARCHAR2
IS

  ln_default_utc_offset NUMBER ;
  lc_time_zone_region  VARCHAR2(100);

BEGIN

  IF p_default_utc_offset IS NULL THEN

	  ln_default_utc_offset := getutc2local_default (p_pday_object_id);

	ELSE
	  ln_default_utc_offset := p_default_utc_offset/24;

	END IF;


	IF getutc2local_timediff(p_date, p_pday_object_id) =  ln_default_utc_offset THEN
  	RETURN 'N';
	ELSE
		RETURN 'Y';  -- Summer
	END IF;

END summertime_flag;


------------------------------------------------------------------
-- FUNCTION: getNumDaysInMonth
------------------------------------------------------------------
FUNCTION getNumDaysInMonth(p_month DATE)
RETURN INTEGER
IS

ln_month DATE;
ln_retval INTEGER;

BEGIN

	ln_month := TRUNC(p_month,'month');

	ln_retval := LAST_DAY(ln_month) - ln_month + 1;

	RETURN ln_retval;

END getNumDaysInMonth;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : interceptsWinterAndSummerTime
-- Description    : take a UTC datetime and return Y if close to a daylighsaving switch
--
-- Preconditions  : Original written for UTC time as parameter, but is beeing used with local time
--                  so it now will operate with a bigger window to also answe yes for local time.
-- Postconditions :
--
-- Using tables   : ctrl_system_attribute
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--   InterceptsWinterAndSummerTime  must be as fast as possible since it is used in many triggers
--   the following approach is suggested:
--
--   1) Check  if getutc2local_timediff(p_daytime-1) = getutc2local_timediff(p_daytime+1)   then  return N --No switch
--   2) else
--       Find UTC2LOCALDEFAULT and use it so that the function returns Y if DAYTIME between UTC2LOCAL_DIFF.DAYTIME +/-  (UTC2LOCALDEFAULT+1)
--
--  Still not a perfect solution but the best we can do without doing a big cleanup job, and risk of introducing more errors.
--  This is at least a step in the right direction.
---------------------------------------------------------------------------------------------------
FUNCTION interceptsWinterAndSummerTime(p_daytime DATE, p_pday_object_id VARCHAR2 DEFAULT NULL)
RETURN VARCHAR2
--</EC-DOC>

IS

CURSOR c_ctrl_system_attribute(cp_from_date DATE, cp_to_date DATE) IS
       SELECT daytime, attribute_value
       FROM ctrl_system_attribute
       WHERE attribute_type = 'UTC2LOCAL_DIFF'
       AND daytime BETWEEN cp_from_date AND cp_to_date;

CURSOR c_pday_dst(cp_from_date  DATE, cp_to_date DATE, p_pday_object_id VARCHAR2) IS
       SELECT daytime, dst_flag
       FROM pday_dst
       WHERE object_id = p_pday_object_id
       AND daytime BETWEEN cp_from_date AND cp_to_date;

lv2_result     VARCHAR2(1);
ln_utc_offset  NUMBER;
ld_switchtime  DATE;
ln_switchvalue NUMBER;
ln_offset      NUMBER;
ld_periodStart DATE;
ld_periodEnd   DATE;
lc_time_zone_region  VARCHAR2(100);

BEGIN
	IF  getutc2local_timediff(p_daytime-1, p_pday_object_id) = getutc2local_timediff(p_daytime+1, p_pday_object_id) THEN
		lv2_result := 'N' ;  -- Outside switch period
	ELSE

		ln_utc_offset := getutc2local_default(p_pday_object_id, p_daytime);
    lc_time_zone_region := getPDTimeZoneRegion(p_pday_object_id);

		IF lc_time_zone_region IS NOT NULL THEN

			FOR pdaySwitch IN c_pday_dst(p_daytime-1,p_daytime+1,p_pday_object_id) LOOP
	    	ld_switchtime  := pdaySwitch.daytime;
				ln_switchvalue := pdaySwitch.dst_flag;
			END LOOP;

		ELSE

			FOR curSwitch IN c_ctrl_system_attribute(p_daytime-1,p_daytime+1) LOOP
   			ld_switchtime  := curSwitch.daytime;
				ln_switchvalue := curSwitch.attribute_value;
			END LOOP;

		END IF;

		IF ln_utc_offset >= 0 THEN    -- when in a timezone with positive ofset to UTC i.e. Australia, Europe etc
    	IF ln_switchvalue = 0 THEN  -- switching from S to W
				ln_offset := ln_utc_offset+1/24;
			ELSE -- switching from W to S
				ln_offset := ln_utc_offset + ln_switchvalue/24+1/24;
			END IF;
			ld_periodStart:= ld_switchtime;
			ld_periodEnd:= ld_switchtime + ln_offset;
		ELSE  -- USA etc
			IF ln_switchvalue = 0 THEN  -- switching from S to W
				ln_offset := ln_utc_offset;
			ELSE -- switching from W to S
				ln_offset := ln_utc_offset - ln_switchvalue/24;
			END IF;
			ld_periodStart:= ld_switchtime + ln_offset;
			ld_periodEnd:= ld_switchtime;
		END IF;
		IF  p_daytime BETWEEN ld_periodStart AND ld_periodEnd THEN
			lv2_result := 'Y' ;  -- Inside switch period
		ELSE
			lv2_result := 'N' ;  -- Outside switch period
		END IF;
	END IF;
	RETURN lv2_result;
END interceptsWinterAndSummerTime;

------------------------------------------------------------------
-- FUNCTION: summertime_flag
-- Returns S if summertime or W if not
-- Based on Norwegian rules
-- Parameter in is assumed to be UTC_TIME
------------------------------------------------------------------
FUNCTION get_summertime_flag(p_date DATE,p_flag VARCHAR2,p_pday_object_id VARCHAR2 DEFAULT NULL)
RETURN VARCHAR2
IS
BEGIN
	IF interceptsWinterAndSummerTime(p_date, p_pday_object_id) = 'Y' THEN
  	RETURN p_flag;
	ELSE
		RETURN summertime_flag(p_date,NULL,p_pday_object_id);
	END IF;

END get_summertime_flag;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getDefaultProdDayDefinition
-- Description    : get default production day object id
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
FUNCTION getDefaultProdDayDefinition(p_daytime DATE)

RETURN VARCHAR2
--</EC-DOC>
IS
  ld_daytime DATE;
  lv2_pdd_object_id   VARCHAR2(32);

BEGIN

  ld_daytime := Nvl(p_daytime,TRUNC(SYSDATE));

  FOR curPD IN c_default_productionday(ld_daytime) LOOP
    lv2_pdd_object_id := curPD.object_id;
    IF lv2_pdd_object_id IS NOT NULL THEN
      EXIT;
    END IF;
  END LOOP;

  RETURN lv2_pdd_object_id;
END getDefaultProdDayDefinition;


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

  ld_productionDay := ue_Date_Time.getProductionDay(pdd_object_id, p_daytime, p_summer_time);

  IF ld_productionDay IS NULL THEN

    ld_daytime := Nvl(p_daytime,TRUNC(SYSDATE));

    l_ec_unique_daytime := getProductionDayStartTime(pdd_object_id,TRUNC(ld_daytime));
	ld_nextProductionDayStart := getProductionDayStartTime(pdd_object_id,(TRUNC(ld_daytime)+1));

    IF ld_daytime < l_ec_unique_daytime.daytime THEN
      ld_productionDay := TRUNC(ld_daytime) - 1 ;
    ELSE
      IF ld_daytime >= ld_nextProductionDayStart.daytime THEN
         ld_productionDay := TRUNC(ld_daytime) + 1;
      ELSE
         ld_productionDay := TRUNC(ld_daytime);
      END IF;
    END IF;

  END IF;

  RETURN ld_productionDay;
END getProductionDay;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getProductionDayStartTimeUTC
-- Description    : take a Production Day object_id and a production day as inputs, and return
--                  the sub-daily daytime (in UTC) when this production day starts.
--
-- Preconditions  : Given p_day is local time, if invalid offset in config, uses 0 offset
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
-- The User Exit package ue_xxx.getProductionDayStartTimeUTC should be called first, and if that returns a non-NULL value then that value should be used.
-- Please note that the calculations in this function must be carefully designed (and tested) to handle daylight savings time transitions correctly.
---------------------------------------------------------------------------------------------------
FUNCTION getProductionDayStartTimeUTC(pdd_object_id VARCHAR2,
                                      p_day         DATE
                                      )
RETURN DATE
--</EC-DOC>

IS
  l_ec_unique_daytime Ec_Unique_Daytime;
  lutc_daytime       DATE;
  ld_productionDay   DATE;
  ld_day             DATE;
  llocal_pd_start    DATE;
  lutc_pd_start      DATE;
  lv2_offset         VARCHAR2(10);
  ln_offset          NUMBER;



BEGIN

  lutc_pd_start := ue_Date_Time.getProductionDayStartTimeUTC(pdd_object_id, p_day);

  IF lutc_pd_start IS NULL THEN

--      ld_day := Nvl(p_day,TRUNC(SYSDATE));
      ld_day := TRUNC(Nvl(p_day,SYSDATE));

      FOR curPD IN c_productionday(pdd_object_id,ld_day) LOOP

        lv2_offset := curPD.offset;

      END LOOP;

      IF lv2_offset IS NULL THEN
        RAISE_APPLICATION_ERROR(-20000,'The offset of production day should not be null.');
      END IF;

      -- convert offset to minutes
      IF(SUBSTR(lv2_offset,1,1)= '-') THEN

          lv2_offset := TO_CHAR(TO_DATE(SUBSTR(lv2_offset,2,5),'HH24:MI'),'HH24:MI'); -- parse it
          ln_offset  := (TO_NUMBER(SUBSTR(lv2_offset,1,2))*60 + TO_NUMBER(SUBSTR(lv2_offset,4,2)))* -1;

      ELSE

          lv2_offset := TO_CHAR(TO_DATE(lv2_offset,'HH24:MI'),'HH24:MI'); -- parse it
          ln_offset  := TO_NUMBER(SUBSTR(lv2_offset,1,2))*60 + TO_NUMBER(SUBSTR(lv2_offset,4,2));

      END IF;

      -- First find production day start in local time (ignoring daylight saving changes)

      llocal_pd_start :=  ld_day + (ln_offset/(24*60));  -- Yes it will always be 24 in this case

      -- convert it to utc using the offset that applies at production start date
      -- if this should be the odd case where there are 2 local times, simply select the first one that should be the
      -- S.

      lutc_pd_start := EcDp_Date_Time.local2utc(llocal_pd_start,'Y',pdd_object_id);

      IF lutc_pd_start IS NULL THEN

        -- This only happens if the local time doesn't exist because of the timegap
        -- during daylight savings spring transitions.
        -- In this case we just add one hour to the local time...
        lutc_pd_start := EcDp_Date_Time.local2utc(llocal_pd_start+1/24,NULL,pdd_object_id);  -- NOTYET handle cases where daylight saving diff <> 1 hour

      END IF;

   END IF;

  RETURN lutc_pd_start;

END getProductionDayStartTimeUTC;


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
  lutc_pd_start  DATE;
  l_ec_unique_daytime Ec_Unique_Daytime;

BEGIN

  lutc_pd_start :=  getProductionDayStartTimeUTC(pdd_object_id,p_day);

  l_ec_unique_daytime.daytime := EcDp_Date_Time.utc2local(lutc_pd_start, pdd_object_id);
  l_ec_unique_daytime.summertime_flag :=  EcDp_Date_Time.summertime_flag(lutc_pd_start,NULL,pdd_object_id);

  RETURN l_ec_unique_daytime;

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
  l_ec_unique_daytime Ec_Unique_Daytime;
  ld_day_start_utc  DATE;
  ld_day_end_utc    DATE;
  ld_from_utc       DATE;
  ld_to_utc         DATE;

BEGIN
  -- Validate p_day
  IF p_day IS NULL OR p_day <> TRUNC(p_day) THEN
    RAISE_APPLICATION_ERROR(-20000,'getProductionDayFraction requires p_day to be a non-NULL day value.');
  END IF;

  -- Convert everything to UTC and check for invalid from/to daytime due to daylight savings time
  -- Also limit from and to daytime to the day start / end daytimes
  ld_day_start_utc := getProductionDayStartTimeUtc(pdd_object_id,p_day);
  ld_day_end_utc := getProductionDayStartTimeUtc(pdd_object_id,p_day+1);

  IF p_from_daytime IS NULL THEN
    ld_from_utc := ld_day_start_utc;
  ELSE
    ld_from_utc := local2utc(p_from_daytime,p_from_summer_time,pdd_object_id);
    IF ld_from_utc IS NULL THEN
       RAISE_APPLICATION_ERROR(-20504,to_char(p_from_daytime,'yyyy-mm-dd hh24:mi')||' is not a valid time due to daylight savings time.');
    END IF;
    IF ld_from_utc < ld_day_start_utc THEN
       ld_from_utc := ld_day_start_utc;
    END IF;
  END IF;
  IF p_to_daytime IS NULL THEN
    ld_to_utc := ld_day_end_utc;
  ELSE
    ld_to_utc := local2utc(p_to_daytime, p_to_summer_time,pdd_object_id);
    IF ld_to_utc IS NULL THEN
       RAISE_APPLICATION_ERROR(-20504,to_char(p_to_daytime,'yyyy-mm-dd hh24:mi')||' is not a valid time due to daylight savings time.');
    END IF;
    IF ld_to_utc > ld_day_end_utc THEN
       ld_to_utc := ld_day_end_utc;
    END IF;
  END IF;
  -- Then we simply find the fraction, with an additional check for negative (might happen due to the limiting)
  IF ld_from_utc >= ld_to_utc THEN
    RETURN 0;
  ELSE
    RETURN (ld_to_utc - ld_from_utc) / (ld_day_end_utc - ld_day_start_utc);
  END IF;
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
   li_index     BINARY_INTEGER;
   ld_utc       DATE;
   ld_end_utc   DATE;
   lua_times    Ec_Unique_Daytimes;
   ln_freq_hrs  NUMBER;
BEGIN

   ld_utc:= getProductionDayStartTimeUtc(pdd_object_id,p_day);
   ld_end_utc:= getProductionDayStartTimeUtc(pdd_object_id,p_day+1);

   FOR cur_code IN c_prosty_alt_codes(UPPER(p_sub_day_freq_code),'METER_FREQ') LOOP
      -- assuming 60 minutes is the default
      ln_freq_hrs := to_number(Nvl(cur_code.col,60))/60;  -- convert to hour
   END LOOP;

   WHILE ld_utc < ld_end_utc LOOP
      li_index:=lua_times.COUNT+1;
      lua_times(li_index).daytime := Ecdp_Date_Time.utc2local(ld_utc, pdd_object_id);
      lua_times(li_index).summertime_flag := Ecdp_Date_Time.summertime_flag(ld_utc,NULL,pdd_object_id);
      ld_utc:=ld_utc + ln_freq_hrs/24;  -- There is always 24 hours in a UTC day
   END LOOP;
   RETURN lua_times;
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

  ld_daytime_utc := local2utc(p_daytime,p_summer_time,pdd_object_id);

  ld_productionday_start := getProductionDay(pdd_object_id,p_daytime,p_summer_time);

  ld_productionday_start_utc := getProductionDayStartTimeUtc(pdd_object_id,trunc(ld_productionday_start));

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
  lv2_pdd_object_id  VARCHAR2(32);
  lv2_pdd_offset     VARCHAR2(32);
  ln_day_offset      NUMBER;

  CURSOR c_PRODUCTION_DAY_VERSION IS
  SELECT offset
  FROM PRODUCTION_DAY_VERSION
  WHERE object_id = p_object_id
  AND daytime =
   (SELECT max(daytime)
    FROM PRODUCTION_DAY_VERSION
    WHERE object_id = p_object_id
    AND daytime <= Nvl(p_daytime,daytime));


BEGIN

  FOR curOff IN c_PRODUCTION_DAY_VERSION LOOP
     lv2_pdd_offset := curOff.offset;
  END LOOP;

  IF lv2_pdd_offset IS NULL THEN
    ln_day_offset := 0;
  ELSE

    IF(SUBSTR(lv2_pdd_offset,1,1)= '-') THEN

     lv2_pdd_offset := TO_CHAR(TO_DATE(SUBSTR(lv2_pdd_offset,2,5),'HH24:MI'),'HH24:MI'); -- parse it
     ln_day_offset := (TO_NUMBER(SUBSTR(lv2_pdd_offset,1,2)) + TO_NUMBER(SUBSTR(lv2_pdd_offset,4,2))/60)* -1;

    ELSE

     lv2_pdd_offset := TO_CHAR(TO_DATE(lv2_pdd_offset,'HH24:MI'),'HH24:MI'); -- parse it
     ln_day_offset := TO_NUMBER(SUBSTR(lv2_pdd_offset,1,2)) + TO_NUMBER(SUBSTR(lv2_pdd_offset,4,2))/60;

    END IF;

  END IF;

  RETURN ln_day_offset;

END getProductionDayOffset;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : checkFutureDate
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
-- Behaviour      : Checks for future date. This procedure should raise an exception if the parameter
--                  p_daytime + p_offset_hour is greater than current system date and time
--
---------------------------------------------------------------------------------------------------
PROCEDURE checkFutureDate(p_daytime DATE,p_offset_hour NUMBER)

--</EC-DOC>

IS

ln_offset_hour NUMBER := 0;

BEGIN

IF(p_daytime + (nvl(p_offset_hour,ln_offset_hour)/24) > getCurrentSysdate) THEN

  RAISE_APPLICATION_ERROR(-20000,'Daytime is greater than the system date');

END IF;

END checkFutureDate;

FUNCTION getAltTZDefaultOffset(p_timeZoneRegion VARCHAR2)
RETURN VARCHAR2
--</EC-DOC>
IS
  lv_TimeZoneDefaultOffset  VARCHAR2(100);

  CURSOR c_prosty_codes (cp_code VARCHAR2) IS
   SELECT alt_code
     FROM PROSTY_CODES
     WHERE code = cp_code
     AND code_type = 'TZ_NAME';

BEGIN
   FOR c_cur IN c_prosty_codes (p_timeZoneRegion) LOOP
     lv_TimeZoneDefaultOffset := c_cur.alt_code;
   END LOOP;

   RETURN lv_TimeZoneDefaultOffset;
END getAltTZDefaultOffset;

---------------------------------------------------------------------------------------------------
-- Function       : getAltTZOffsetinDays
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
-- Behaviour      : function getAltTZOffsetinDays() is to get the TimeZone Offset from ALT_CODE from EC_Codes for
-- 									(Code_type = 'TZ_NAME') and return the Offset in Days (Numeric). This is the alternative way to get
--                  TimeZone Offset rather than getting the UTC2LOCALDEFAULT from ctrl_system_attribute. (ECPD-11578)
-----------------------------------------------------------------------------------------------------------------------
FUNCTION getAltTZOffsetinDays(p_pday_object_id VARCHAR2, p_daytime DATE DEFAULT NULL)
RETURN NUMBER
--</EC-DOC>
IS

	lc_TZ_region_name VARCHAR2(100);
	lc_TZDefaultOffset VARCHAR2(100);
	ln_ALTTZOffsetinDays NUMBER;
BEGIN

	lc_TZ_region_name :=   ecdp_date_time.getPDTimeZoneRegion(p_pday_object_id);
	lc_TZDefaultOffset := ecdp_date_time.getAltTZDefaultOffset(lc_TZ_region_name);
  ln_ALTTZOffsetinDays := ecdp_date_time.gettzoffsetindays(lc_TZDefaultOffset);

  RETURN ln_ALTTZOffsetinDays;

END getAltTZOffsetinDays;

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