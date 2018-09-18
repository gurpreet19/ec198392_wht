CREATE OR REPLACE PACKAGE EcDp_ProductionDay IS
/****************************************************************
** Package        :  EcDp_ProductionDay, header part
**
** $Revision: 1.10 $
**
** Purpose        :  DUMMY version will be replaced after code freeze
**
** Documentation  :  www.energy-components.com
**
** Created  : 28.04.2006  Arild Vervik
**
** Modification history:
**
** Date        Whom  Change description:
** ------      ----- -----------------------------------
** 28.04.2006  AV     Initial version
** 19.12.2008 leeeewei Modified wrong function name in
** OBSOLETE use Ecdp_Timestamp instead
*****************************************************************/

/*
* Flush the internal cache of the production day
*/
PROCEDURE flush_buffer;

/*
* findProductionDayDefinition accepts class name, object_id and daytime, returning production day definition
* class name is optional, p_object_id may be null, p_daytime is mandatory
* first test: if p_object_id is null then use default production day definition, then exit
* next: if class_name is null, take def from object_id
* 1st group: these classes finds parent fcty due to missing production_day_id
* WELL, STORAGE, TANK, WELL_HOOKUP, CHEM_TANK
* 2nd group: these classes fallback straight to default if production day is not set:
* FACILITY, FCTY_VERSION_1, FCTY_VERSION_2, PIPELINE, SEPARATOR
* 3rd group: these classes fallback to parent facility
* FLOWLINE, STREAM, EQPM, TEST_DEVICE, TESTSEPARATOR, PRODSEPARATOR
* Additional classes for EC Transport:
* CONTRACT, TRAN_CONTRACT AND METER fallback straight to default if production day is not set.
* CONTRACT_CAPACITY, DELIVERY_POINT, NOMINATION_POINT are called but expected to return the default definition.
*
* @param p_class_name Class Name can be NULL; if NULL then get the value from p_object_id. If both class_name and object_id are NULL, default is taken instead
* @param p_object_id object_id can be NULL; to get the production day. If NULL then the default production day is used
* @param p_daytime mandatory value and expected to be UTC.
* @return the ID of the production_day
* @Obsolete expected to be used internally by Ecdp_Timestamp only
*/
FUNCTION findProductionDayDefinition(p_class_name VARCHAR2, p_object_id  VARCHAR2, p_daytime  DATE)
RETURN VARCHAR2;

/*
* Support function to convert the given time zone offset to number of days for usage in date calculations.
*
* @param p_time_zone_offset The offset of production_day start or time zone offset. e.g. -06:00
* @return the offset in term of days. for -06:00, the returned value is -0.25
* @Obsolete use replacement
*/
FUNCTION getTZoffsetInDays(p_time_zone_offset VARCHAR2)
RETURN NUMBER;

/*
* Get the production day of the given date.
* @param p_class_name Used to find the production day definition
* @param p_object_id Used to find the production day definition
* @param date to get production day
* @param p_summertime_flag summer time flag for the date
* @return The production day of the given parameters
* @Obsolete use Ecdp_Timestamp instead
*/
FUNCTION getProductionDay(p_class_name VARCHAR2, p_object_id  VARCHAR2, p_daytime  DATE, p_summertime_flag VARCHAR2 DEFAULT NULL)
RETURN DATE;

--

PROCEDURE validateDaytimeVsFreq(p_class_name VARCHAR2,
                                p_object_id  VARCHAR2,
                                p_daytime  DATE,
                                p_summertime_flag VARCHAR2
                                );

--

FUNCTION findSubDailyFreq(p_class_name  VARCHAR2,
                          p_object_id   VARCHAR2,
                          p_daytime     DATE
                         )
RETURN VARCHAR2;

--

FUNCTION getProductionDayDaytimes(p_class_name  VARCHAR2,
                                  p_object_id   VARCHAR2,
                                  p_day         DATE)
RETURN Ecdp_Date_Time.Ec_Unique_Daytimes;

--

FUNCTION getProductionDayFraction(p_class_name        VARCHAR2,
                                  p_object_id         VARCHAR2,
                                  p_day               DATE,
                                  p_from_daytime      DATE,
                                  p_from_summer_time  VARCHAR2,
                                  p_to_daytime        DATE,
                                  p_to_summer_time    VARCHAR2
                                  )
RETURN NUMBER;

--

FUNCTION getProductionDayStartTime(p_class_name VARCHAR2,
                                   p_object_id  VARCHAR2,
                                   p_day        DATE
                                   )
RETURN Ecdp_Date_Time.Ec_Unique_Daytime;

--
FUNCTION getProductionDayStart(p_class_name VARCHAR2,
                                   p_object_id  VARCHAR2,
                                   p_day        DATE
                                   )
RETURN DATE;

--
FUNCTION getProductionDayOffset(p_class_name VARCHAR2,
                                p_object_id VARCHAR2,
                                p_daytime DATE,
                                p_summer_time VARCHAR2 DEFAULT NULL)
RETURN NUMBER;


END;