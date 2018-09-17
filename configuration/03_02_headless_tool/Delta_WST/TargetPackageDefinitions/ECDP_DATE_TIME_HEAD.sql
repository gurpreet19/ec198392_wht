CREATE OR REPLACE PACKAGE EcDp_Date_Time IS
/****************************************************************
** Package        :  EcDp_Date_Time, header part
**
** $Revision: 1.15.26.1 $
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
** 14.09.2001  AV    	Changed local2utc to use summertime flag
** 20.09.2001  AV    	Made function getutc2local_timediff visible
** 10.10.2001  AV    	Introduced new paramater p_default_utc_offset
**                   	for function summertime flag
** 11.01.2002  FBa   	Added function getNumDaysInMonth
** 10.11.2003  DN    	Addded time zone functions. (Ref. 7.3 inc.1 )
** 19.11.2003  DN    	Added getSystemName here.
** 29.06.2004  DN    	Added getCurrentDBSysdate and calcDBSysdateByForeignTimeZone.
** 01.04.2008  RAJARSAR ECPD-7844:Modified getNumHours and getNumHalfHours.
** 25.08.2008  LEEEEWEI ECPD-7979: Added procedure checkFutureDate
** 08.07.2009  LEONGWEN ECPD-11578: Support Multiple Timezones
**                      I used the variable name (p_pday_object_id) for parameter_productionday_object_id.
**                      The (pdd_object_id) variable is also used for the same productionday_object_id by other developer.
**                      I just used (p_pday_object_id) variable to differentiate my works for ECPD-11578 only.
** 08.10.2012  meisihil ECPD-20961: Added new function getNextHour
*****************************************************************/

TYPE Ec_Unique_Daytime IS RECORD (daytime DATE, summertime_flag VARCHAR2(1));
TYPE Ec_Unique_Daytimes IS TABLE OF Ec_Unique_Daytime INDEX BY BINARY_INTEGER;

FUNCTION getCurrentSysdate RETURN DATE;
PRAGMA RESTRICT_REFERENCES(getCurrentSysdate, WNDS, WNPS, RNPS);

FUNCTION getForeignSysdate(p_tz_region VARCHAR2) RETURN DATE;
PRAGMA RESTRICT_REFERENCES(getForeignSysdate, WNDS, WNPS, RNPS);

FUNCTION getCurrentDBSysdate(p_daytime DATE) RETURN DATE;
PRAGMA RESTRICT_REFERENCES(getCurrentDBSysdate, WNDS, WNPS, RNPS);

FUNCTION calcDBSysdateByForeignTimeZone(p_daytime DATE, p_tz_region VARCHAR2) RETURN DATE;
PRAGMA RESTRICT_REFERENCES(calcDBSysdateByForeignTimeZone, WNDS, WNPS, RNPS);

FUNCTION getTZoffsetInDays(p_time_zone_offset VARCHAR2) RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES(getTZoffsetInDays, WNDS, WNPS, RNPS);

FUNCTION getSystemName
RETURN VARCHAR2;

PRAGMA RESTRICT_REFERENCES(getSystemName, WNDS, WNPS, RNPS);

FUNCTION getNumHours(p_class_name VARCHAR2, p_object_id VARCHAR2, p_daytime DATE)
RETURN INTEGER;

PRAGMA RESTRICT_REFERENCES(getNumHours, WNDS, WNPS, RNPS);

--

FUNCTION getNumHalfHours(p_class_name VARCHAR2, p_object_id VARCHAR2, p_daytime DATE)
RETURN INTEGER;

PRAGMA RESTRICT_REFERENCES(getNumHalfHours, WNDS, WNPS, RNPS);

--
FUNCTION getPDTimeZoneRegion(p_pday_object_id VARCHAR2)
RETURN VARCHAR2;

PRAGMA RESTRICT_REFERENCES(getPDTimeZoneRegion, WNDS, WNPS, RNPS);


FUNCTION getutc2local_default (p_pday_object_id VARCHAR2 DEFAULT NULL, p_daytime DATE DEFAULT NULL) RETURN NUMBER;

PRAGMA RESTRICT_REFERENCES(getutc2local_default, WNDS, WNPS, RNPS);


--FUNCTION  getutc2local_timediff(p_sysnam VARCHAR2,p_datetime DATE) RETURN NUMBER;
FUNCTION  getutc2local_timediff(p_datetime DATE, p_pday_object_id VARCHAR2 DEFAULT NULL) RETURN NUMBER;

PRAGMA RESTRICT_REFERENCES(getutc2local_timediff, WNDS, WNPS, RNPS);

--

FUNCTION  utc2local(p_datetime DATE, p_pday_object_id VARCHAR2 DEFAULT NULL) RETURN DATE;

PRAGMA RESTRICT_REFERENCES(utc2local, WNDS, WNPS, RNPS);

--

FUNCTION  local2utc(p_datetime DATE,p_summertime_flag varchar2 DEFAULT 'N', p_pday_object_id VARCHAR2 DEFAULT NULL) RETURN DATE;

PRAGMA RESTRICT_REFERENCES(local2utc, WNDS, WNPS, RNPS);

FUNCTION summertime_flag(
  p_date DATE,
  p_default_utc_offset NUMBER DEFAULT NULL, -- Null means use attribute from ctrl_system_attribute
  p_pday_object_id VARCHAR2 DEFAULT NULL
) RETURN VARCHAR2;

PRAGMA RESTRICT_REFERENCES(summertime_flag, WNDS, WNPS, RNPS);

--

FUNCTION getNumDaysInMonth(p_month DATE)
RETURN INTEGER;

PRAGMA RESTRICT_REFERENCES(getNumDaysInMonth, WNDS, WNPS, RNPS);

--

FUNCTION interceptsWinterAndSummerTime(p_daytime DATE, p_pday_object_id VARCHAR2 DEFAULT NULL)
RETURN VARCHAR2;

PRAGMA RESTRICT_REFERENCES(interceptsWinterAndSummerTime, WNDS, WNPS, RNPS);

--


FUNCTION get_summertime_flag(p_date DATE,p_flag VARCHAR2,p_pday_object_id VARCHAR2 DEFAULT NULL)
RETURN VARCHAR2;


PRAGMA RESTRICT_REFERENCES(get_summertime_flag, WNDS, WNPS, RNPS);

--

FUNCTION getDefaultProdDayDefinition(p_daytime DATE)

RETURN VARCHAR2;
PRAGMA RESTRICT_REFERENCES(getDefaultProdDayDefinition, WNDS, WNPS, RNPS);

--


FUNCTION getProductionDay(pdd_object_id VARCHAR2,
                          p_daytime     DATE,
                          p_summer_time VARCHAR2
                          )
RETURN DATE;
PRAGMA RESTRICT_REFERENCES(getProductionDay, WNDS, WNPS, RNPS);

--

FUNCTION getProductionDayStartTimeUTC(pdd_object_id VARCHAR2,
                                      p_day         DATE
                                      )
RETURN DATE;
PRAGMA RESTRICT_REFERENCES(getProductionDayStartTimeUTC, WNDS, WNPS, RNPS);

--

FUNCTION getProductionDayStartTime(pdd_object_id VARCHAR2,
                                   p_day     DATE
                                   )
RETURN Ec_Unique_daytime;
PRAGMA RESTRICT_REFERENCES(getProductionDayStartTime, WNDS, WNPS, RNPS);

--

FUNCTION getProductionDayFraction(pdd_object_id       VARCHAR2,
                                  p_day               DATE,
                                  p_from_daytime      DATE,
                                  p_from_summer_time  VARCHAR2,
                                  p_to_daytime        DATE,
                                  p_to_summer_time    VARCHAR2
                                  )
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES(getProductionDayFraction, WNDS, WNPS, RNPS);

--

FUNCTION getProductionDayDaytimes(pdd_object_id VARCHAR2,
                                  p_sub_day_freq_code VARCHAR2,
                                  p_day     DATE)
RETURN Ec_Unique_daytimes;
PRAGMA RESTRICT_REFERENCES(getProductionDayDaytimes, WNDS, WNPS, RNPS);

--

PROCEDURE validateDaytimeVsFreq(pdd_object_id VARCHAR2,
                                p_sub_day_freq_code VARCHAR2,
                                p_daytime     DATE,
                                p_summer_time VARCHAR2
                                );
PRAGMA RESTRICT_REFERENCES(validateDaytimeVsFreq, WNDS, WNPS, RNPS);
--


FUNCTION getDateDiff(p_what VARCHAR2, p_dt1 DATE, p_dt2 DATE)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES(getDateDiff, WNDS, WNPS, RNPS);

--

FUNCTION getProductionDayOffset(p_object_id VARCHAR2,
                                p_daytime DATE,
                                p_summer_time VARCHAR2 DEFAULT NULL)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES(getProductionDayOffset, WNDS, WNPS, RNPS);

PROCEDURE checkFutureDate(p_daytime DATE,p_offset_hour NUMBER);

FUNCTION getAltTZDefaultOffset(p_timeZoneRegion VARCHAR2) RETURN VARCHAR2;
PRAGMA RESTRICT_REFERENCES(getAltTZDefaultOffset, WNDS, WNPS, RNPS);

FUNCTION getAltTZOffsetinDays(p_pday_object_id VARCHAR2, p_daytime DATE DEFAULT NULL)RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES(getAltTZOffsetinDays, WNDS, WNPS, RNPS);

FUNCTION getNextHour(p_date DATE, p_summer_time VARCHAR2) RETURN EcDp_Date_Time.Ec_Unique_Daytime;
PRAGMA RESTRICT_REFERENCES(getNextHour, WNDS, WNPS, RNPS);

END;