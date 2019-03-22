CREATE OR REPLACE PACKAGE ecdp_timestamp_utils IS
/*
*  <b>Package</b>        :  ecdp_timestamp_utils<br/>
* <br/>
*  <b>Purpose</b>        :  Support package for ecdp_timestamp<br/>
* <br/>
*  <b>Documentation</b>  :  www.energy-components.com<br/>
* <br/>
*  <b>Created</b>  : 25.01.2018<br/>
* <br/>
*
*
*
*
* @headcom
************************************************************************************/

/*
* Sync utc_daytime, daytime, summer_time. If both utc_daytime and daytime are set, no action will be performed, i.e. take the value as is.
*
* @param p_object_id Object ID to be used to get production day definition, for summer_time flag and ecdp_date_time.local2utc
* @param p_utc_daytime UTC date column to be sync. Two way sync with daytime
* @param p_daytime local date to be two way sync with utc_daytime
* @param p_summertime summer time tag for local date p_daytime
*/
PROCEDURE syncUtcDate(p_object_id VARCHAR2
                     ,p_utc_daytime IN OUT NOCOPY DATE
                     ,p_daytime IN OUT NOCOPY DATE
                     ,p_summertime IN OUT NOCOPY VARCHAR2);


/*
* Sync utc_daytime, daytime. Overloaded without summertime. If both utc_daytime and daytime are set, no action will be performed,
* i.e. take the value as is.
*
* @param p_object_id Object ID to be used to get production day definition, for summer_time flag and ecdp_date_time.local2utc
* @param p_utc_daytime UTC date column to be sync. Two way sync with daytime
* @param p_daytime local date to be two way sync with utc_daytime
*/
PROCEDURE syncUtcDate(p_object_id VARCHAR2
                     ,p_utc_daytime IN OUT NOCOPY DATE
                     ,p_daytime IN OUT NOCOPY DATE);

/*
* Update utc_daytime from daytime and summer_time. If both utc_daytime and daytime are updated, take the value as is without modification
*
* @param p_object_id Object ID to be used to get production day definition, for summer_time flag and ecdp_date_time.local2utc
* @param p_old_utc_daytime UTC date column to be sync with daytime. The corresponding parameter is :OLD.utc_daytime image
* @param p_new_utc_daytime UTC date column to be sync with daytime. The corresponding parameter is :NEW.utc_daytime image
* @param p_old_daytime local date as reference for utc_daytime. The corresponding parameter is :OLD.daytime image
* @param p_new_daytime local date as reference for utc_daytime. The corresponding parameter is :NEW.daytime image
* @param p_old_summertime summer time as reference for utc_daytime. The corresponding parameter is :OLD.summer_time image
* @param p_new_summertime summer time as reference for utc_daytime. The corresponding parameter is :NEW.summer_time image
*/
PROCEDURE updateUtcAndDaytime(p_object_id VARCHAR2
                     ,p_old_utc_daytime DATE
                     ,p_new_utc_daytime IN OUT NOCOPY DATE
                     ,p_old_daytime DATE
                     ,p_new_daytime IN OUT NOCOPY DATE
                     ,p_old_summertime VARCHAR2
                     ,p_new_summertime IN OUT NOCOPY VARCHAR2);

/*
* Update utc_daytime from daytime. Overloaded without summer_time. If both utc_daytime and daytime are updated, take the value
* as is without modification
*
* @param p_object_id Object ID to be used to get production day definition, for summer_time flag and ecdp_date_time.local2utc
* @param p_old_utc_daytime UTC date column to be sync with daytime. The corresponding parameter is :OLD.utc_daytime image
* @param p_new_utc_daytime UTC date column to be sync with daytime. The corresponding parameter is :NEW.utc_daytime image
* @param p_old_daytime local date as reference for utc_daytime. The corresponding parameter is :OLD.daytime image
* @param p_new_daytime local date as reference for utc_daytime. The corresponding parameter is :NEW.daytime image
*/
PROCEDURE updateUtcAndDaytime(p_object_id VARCHAR2
                     ,p_old_utc_daytime DATE
                     ,p_new_utc_daytime IN OUT NOCOPY DATE
                     ,p_old_daytime DATE
                     ,p_new_daytime IN OUT NOCOPY DATE);

/*
* Sync production_day
*
* @param p_object_id Object ID for ecdp_timestamp call
* @param p_production_day Production day to be set. Production day is expected to be NULL. Normally production_day column but can be event_day, day..
* @param p_utc_daytime UTC date column to be sync. Two way sync with daytime
*/
PROCEDURE setProductionDay(p_object_id VARCHAR2
                          ,p_utc_daytime DATE
                          ,p_production_day IN OUT NOCOPY DATE);

/*
* Sync production_day, with the production day can be not null
*
* @param p_object_id Object ID for ecdp_timestamp call
* @param p_old_utc_daytime UTC date column to be sync. Two way sync with daytime. Typically named :OLD.utc_daytime.
* @param p_new_utc_daytime UTC date column to be sync. Two way sync with daytime. Typically named :NEW.utc_daytime.
* @param p_old_production_day old production_day
* @param p_new_production_day Production day to be set. Production day can already be set. Normally production_day column but can be event_day, day..
*/
PROCEDURE updateProductionDay(p_object_id VARCHAR2
                          ,p_old_utc_daytime DATE
                          ,p_new_utc_daytime DATE
                          ,p_old_production_day DATE
                          ,p_new_production_day IN OUT NOCOPY DATE);

/*
* Support function for DST switch in UTC. Given a date without time component, find the dst switch time, i.e. 1 am UTC in Oslo and most of Europe.
* If the given date is not a DST switch date, return NULL, and the process to return NULL is slow.
* The given date is expected to be production day, i.e. no time component.
*
* @param p_time_zone The time zone to test the value
* @param p_date The DST Switch date. If non dst switch given, NULL will be returned, and the process to get NULL will be slow
* @return the date with time, in UTC, when DST time switches. It is generally 1 am in Europe, and 10 am during W-S and 9am during S-W in Los Angeles
*/
FUNCTION getDSTTime(p_time_zone VARCHAR2, p_day DATE) RETURN DATE;

/**
 * Converts time offset text string to a number of hours. The input string must be in hh:mm format with an optional sign.
 * Note that the function returns NULL if the offset string is incorrect. Strict mode requires that the <hh> is between
 * 00 and 23, and <mm> between 00 and 59.
 * <br/><br/>
 * <u>Strict mode:</u>
 * <pre class="sql">
 * ecdp_timestamp_utils.timeOffsetToHrs('06:00')  =>  6
 * ecdp_timestamp_utils.timeOffsetToHrs('+06:00') =>  6
 * ecdp_timestamp_utils.timeOffsetToHrs('-06:00') => -6
 * ecdp_timestamp_utils.timeOffsetToHrs('-04:30') => -4.5
 * ecdp_timestamp_utils.timeOffsetToHrs('4:30')   => null
 * ecdp_timestamp_utils.timeOffsetToHrs('48:90')  => null
 * </pre>
 * <u>Lenient mode:</u>
 * <pre class="sql">
 * ecdp_timestamp_utils.timeOffsetToHrs('4:30', 'N')  => null
 * ecdp_timestamp_utils.timeOffsetToHrs('48:90', 'N') => 49.5
 * </pre>
 *
 * @param p_time_offset Time offset string
 * @param p_strict Strict mode or not
 */
FUNCTION timeOffsetToHrs(p_time_offset VARCHAR2, p_strict VARCHAR2 DEFAULT 'Y') RETURN NUMBER RESULT_CACHE;

END ecdp_timestamp_utils;