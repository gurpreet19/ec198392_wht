CREATE OR REPLACE PACKAGE EcDp_Timestamp IS
/*
*  <b>Package</b>        :  EcDp_Timestamp<br/>
* <br/>
*  <b>Purpose</b>        :  Definition of date and time methods<br/>
* <br/>
*  <b>Documentation</b>  :  www.energy-components.com<br/>
* <br/>
*  <b>Created</b>  : 16.08.2017<br/>
* <br/>
*
* The date and time calculation uses database functions to calculate date. This package should render ctrl_system_attribute.UTC2LOCAL_DIFF
* and table pday_dst to be obsolete. It return, the database DST configuration must be up to date.
*
* @headcom
************************************************************************************/


/*
* Returns the date and time of the current operation.
*
* @param p_time_zone time zone used for system date calculation
* @return the current date of operation.
*/
FUNCTION getCurrentSysdate(p_time_zone VARCHAR2 DEFAULT NULL) RETURN DATE;

/*
* Function to get time zone of the production day. This function supports only one time zone setting in t_preferanse.
* The parameters are kept for future use.
*
* @param p_class_name Class name for the object. Null value is allowed.
* @param p_object_id Object ID of the object, used to find it's corresponding production day ID
* @param p_daytime date to identify the active version in production day
*/
FUNCTION getTimeZone(p_class_name VARCHAR2, p_object_id VARCHAR2, p_daytime DATE) RETURN VARCHAR2;
/*
* Return the number of hours in the given date for particular object.
* p_daytime is expected to be local time between the current production day and the next day.
*
* @param p_class_name Class name for the object. Null value is allowed.
* @param p_object_id Object ID of the object, used to find it's corresponding production day ID
* @param p_daytime date to check number of hours. Date is expected to be production day and will be truncated internally
* @return The number of hours
*/
FUNCTION getNumHours(p_class_name VARCHAR2, p_object_id VARCHAR2, p_daytime DATE) RETURN NUMBER;

/*
* Convert utc_date to local.
*
* @param p_class_name to identify the production day ID. NULL is accepted, according to findProductionDayDefinition
* @param p_object_id to get the production day ID. NULL is accepted, according to findProductionDayDefinition
* @param p_daytime UTC date to convert to local
* @return converted date. Duplicated date will not be differentiated.
*/
FUNCTION utc2local(p_class_name VARCHAR2, p_object_id VARCHAR2, p_daytime DATE) RETURN DATE;

/*
 Convert local date to utc. Invalid date during DST switch returns NULL.Duplicate date returns the second date (winter date)
*
* @param p_class_name to identify the production day ID. NULL is accepted, according to findProductionDayDefinition
* @param p_object_id to get the production day ID. NULL is accepted, according to findProductionDayDefinition
* @param p_daytime date to convert to utc. Invalid date returns NULL. Duplicate date returns the second date
* @return converted date
*/
FUNCTION local2utc(p_class_name VARCHAR2, p_object_id VARCHAR2, p_daytime DATE) RETURN DATE;

/*
* Take a Class Name and object_id and a sub-daily daytime as inputs, and return the production day.
* Production Day has no associated time, so p_utc_daytime is converted to local before calculating the
* Production Day.
* Class name, object ID and daytime is used to identify production day ID.
* Calculations in this function is designed to handle daylight savings time transitions correctly.
*
* @param p_class_name Class Name of the object ID
* @param p_object_id object ID. If NULL, the production day uses default
* @param p_utc_daytime Date to get the production day from, in UTC
* @return the production day for the given daytime
*/
FUNCTION getProductionDay(p_class_name      VARCHAR2,
                          p_object_id       VARCHAR2,
                          p_utc_daytime     DATE)
RETURN DATE;

/*
* Flush the internal cache of the time zone
*/
PROCEDURE flush_buffer;

END EcDp_Timestamp;