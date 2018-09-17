CREATE OR REPLACE PACKAGE EcDp_Date_Time IS
/****************************************************************
** Package        :  EcDp_Date_Time, header part
**
** $Revision: 1.16 $
**
** Purpose        :  Definition of date and time methods
**
** Documentation  :  www.energy-components.com
**
** Created  : 27.12.1999  Carl-Fredrik S?sen
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

FUNCTION getCurrentDBSysdate(p_daytime DATE) RETURN DATE;

FUNCTION getTZoffsetInDays(p_time_zone_offset VARCHAR2) RETURN NUMBER;

FUNCTION getNumHours(p_class_name VARCHAR2, p_object_id VARCHAR2, p_daytime DATE)
RETURN INTEGER;

FUNCTION  utc2local(p_datetime DATE, p_pday_object_id VARCHAR2 DEFAULT NULL) RETURN DATE;

FUNCTION  local2utc(p_datetime DATE,p_summertime_flag varchar2 DEFAULT 'N', p_pday_object_id VARCHAR2 DEFAULT NULL) RETURN DATE;

FUNCTION summertime_flag(
  p_date DATE,
  p_default_utc_offset NUMBER DEFAULT NULL, -- Null means use attribute from ctrl_system_attribute
  p_pday_object_id VARCHAR2 DEFAULT NULL
) RETURN VARCHAR2;

FUNCTION getProductionDay(pdd_object_id VARCHAR2,
                          p_daytime     DATE,
                          p_summer_time VARCHAR2
                          )
RETURN DATE;

FUNCTION getProductionDayStartTime(pdd_object_id VARCHAR2,
                                   p_day     DATE
                                   )
RETURN Ec_Unique_daytime;

FUNCTION getProductionDayFraction(pdd_object_id       VARCHAR2,
                                  p_day               DATE,
                                  p_from_daytime      DATE,
                                  p_from_summer_time  VARCHAR2,
                                  p_to_daytime        DATE,
                                  p_to_summer_time    VARCHAR2
                                  )
RETURN NUMBER;

FUNCTION getProductionDayDaytimes(pdd_object_id VARCHAR2,
                                  p_sub_day_freq_code VARCHAR2,
                                  p_day     DATE)
RETURN Ec_Unique_daytimes;

PROCEDURE validateDaytimeVsFreq(pdd_object_id VARCHAR2,
                                p_sub_day_freq_code VARCHAR2,
                                p_daytime     DATE,
                                p_summer_time VARCHAR2
                                );

FUNCTION getDateDiff(p_what VARCHAR2, p_dt1 DATE, p_dt2 DATE)
RETURN NUMBER;

FUNCTION getProductionDayOffset(p_object_id VARCHAR2,
                                p_daytime DATE,
                                p_summer_time VARCHAR2 DEFAULT NULL)
RETURN NUMBER;

FUNCTION getNextHour(p_date DATE, p_summer_time VARCHAR2) RETURN EcDp_Date_Time.Ec_Unique_Daytime;

END;