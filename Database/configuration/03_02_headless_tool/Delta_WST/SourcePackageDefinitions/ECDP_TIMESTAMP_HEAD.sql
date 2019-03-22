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
* Function to get time zone of the object.
* The parameters are kept for future use.
*
* @param p_object_id Object ID of the object
* @param p_daytime date to identify the object
*/
FUNCTION getTimeZone(p_object_id VARCHAR2, p_daytime DATE) RETURN VARCHAR2;

-- @Obsolete use getNumHours(object_id, daytime) instead
FUNCTION getNumHours(p_class_name VARCHAR2, p_object_id VARCHAR2, p_daytime DATE) RETURN NUMBER;

-- @Obsolete use utc2local(object_id, daytime) instead
FUNCTION utc2local(p_class_name VARCHAR2, p_object_id VARCHAR2, p_daytime DATE) RETURN DATE;

-- @Overloaded use local2utc(object_id, daytime) instead
FUNCTION local2utc(p_class_name VARCHAR2, p_object_id VARCHAR2, p_daytime DATE) RETURN DATE;

-- @Obsolete use getProductionDay(object_id, daytime) instead
FUNCTION getProductionDay(p_class_name VARCHAR2, p_object_id VARCHAR2, p_utc_daytime DATE) RETURN DATE;

/*
* Return the number of hours in the given date for particular object.
* p_daytime is expected to be production day. Time component of p_daytime will be truncated
*
* @param p_object_id Object ID of the object, used to find it's corresponding production day ID
* @param p_daytime date to check number of hours. Date is expected to be production day and will be truncated internally
* @return The number of hours
*/
FUNCTION getNumHours(p_object_id VARCHAR2, p_daytime DATE) RETURN NUMBER;

/*
* Convert utc_date to local.
*
* @param p_object_id to get the production day ID. NULL is accepted, according to findProductionDayDefinition
* @param p_daytime UTC date to convert to local
* @return converted date. Duplicated date will not be differentiated.
*/
FUNCTION utc2local(p_object_id VARCHAR2, p_daytime DATE) RETURN DATE;

/*
* Convert local date to utc. Default behavior during switch: Invalid date during DST switch returns NULL, while duplicated date
* returns the second date (winter date)
* Parameter p_switch_hr_fix inverted the default behavior: Invalid date returns the next hour, while duplicated date returns the
* first hour (summer time hour)
*
* @param p_object_id to get the production day ID. NULL is accepted, according to findProductionDayDefinition
* @param p_daytime date to convert to utc. Invalid date returns NULL. Duplicate date returns the second date
* @param p_switch_hr_fix For duplicated hour, take the first hour (summer time) instead of default 2nd hour (winter time). Invalid
*  hour returns the next hour
* @return converted date
*/
FUNCTION local2utc(p_object_id      VARCHAR2,
                   p_daytime        DATE,
                   p_switch_hr_fix  BOOLEAN DEFAULT FALSE)
RETURN DATE;

/*
* Take a Class Name and object_id and a sub-daily daytime as inputs, and return the production day.
* The logic: if the date is equal or above production day start, the production day is today, else previous day.
* Calculations in this function is designed to handle daylight savings time transitions correctly - nonexistent date
* means the production day start is next hour. Duplicated hour has no effect on production day
*
* @param p_object_id object ID. If NULL, the production day uses default
* @param p_utc_daytime Date to get the production day from, in local date
* @return the production day for the given daytime
*/
FUNCTION getProductionDay(p_object_id       VARCHAR2,
                          p_daytime         DATE)
RETURN DATE;

/*
* Returns the production date for the input object and localtime (sub-daily datetime).
* @param p_object_id Object id (nulls are not supported)
* @param p_daytime Sub-daily localtime (sub-daily datetime)
*/
FUNCTION getProductionDayFromLocal(p_object_id IN VARCHAR2, p_daytime IN DATE)
RETURN DATE;

/*
* Returns the production day version that applies to the given object.
* <br/><br/>
* <u>Examples:</u>
* <pre class="sql">
* DECLARE
*   l_production_day_version PRODUCTION_DAY_VERSION%ROWTYPE;
* BEGIN
*   FOR cur IN (SELECT object_id, daytime, name FROM ov_storage WHERE product_code='TS1_LNG')
*   LOOP
*     l_production_day_version := ecdp_timestamp.getProductionDayVersion(cur.object_id, cur.daytime);
*     dbms_output.put_line(cur.name
*        ||chr(10)||'    '||'production_day_version.object_id = '||l_production_day_version.object_id
*        ||chr(10)||'    '||'production_day_version.daytime = '||to_char(l_production_day_version.daytime, 'yyyy-mm-dd')
*        ||chr(10)||'    '||'production_day_version.name = '||l_production_day_version.name
*        ||chr(10)||'    '||'production_day_version.offset = '||l_production_day_version.offset
*        ||chr(10)||'    '||'production_day_version.production_day_offset_hrs = '||to_char(l_production_day_version.production_day_offset_hrs)
*     );
*   END LOOP;
* END;
* </pre>
* <u>Result:</u>
* <pre class="sql">
* TS1 Lng Import
*     production_day_version.object_id = 7A7A3913CEC9027DE053020011AC3CFA
*     production_day_version.daytime = 1900-01-01
*     production_day_version.name = EC Default
*     production_day_version.offset = 00:00
*     production_day_version.production_day_offset_hrs = 0
* TS1 Lng Import SubDay
*     production_day_version.object_id = 7A7C5AE0C8210A67E053020011ACDBD8
*     production_day_version.daytime = 2010-12-01
*     production_day_version.name = TS1 0600
*     production_day_version.offset = 06:00
*     production_day_version.production_day_offset_hrs = 6
* </pre>
*
* @param p_object_id Object id (nulls are not supported)
* @param p_daytime Object version daytime
*/
FUNCTION getProductionDayVersion(p_object_id IN VARCHAR2, p_daytime IN DATE)
RETURN PRODUCTION_DAY_VERSION%ROWTYPE;

/*
* Flush the internal cache of the time zone
*/
PROCEDURE flush_buffer;

END EcDp_Timestamp;