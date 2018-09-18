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
* Sync utc_daytime, time_zone, daytime, summer_time
*
* @param p_class_name Class name to be used to get production day definition, for summer_time flag and ecdp_date_time.local2utc
* @param p_object_id Object ID to be used to get production day definition, for summer_time flag and ecdp_date_time.local2utc
* @param p_utc_daytime UTC date column to be sync. Two way sync with daytime
* @param p_time_zone set together with p_utc_daytime
* @param p_daytime local date to be two way sync with utc_daytime
* @param p_summertime summer time tag for local date p_daytime
*/
PROCEDURE syncUtcDate(p_class_name VARCHAR2
                     ,p_object_id VARCHAR2
                     ,p_utc_daytime IN OUT NOCOPY DATE
                     ,p_time_zone IN OUT NOCOPY VARCHAR2
                     ,p_daytime IN OUT NOCOPY DATE
                     ,p_summertime IN OUT NOCOPY VARCHAR2);

/*
* Sync utc_daytime from daytime, summer_time. Time zone is not expected to change
*
* @param p_class_name Class name to be used to get production day definition, for summer_time flag and ecdp_date_time.local2utc
* @param p_object_id Object ID to be used to get production day definition, for summer_time flag and ecdp_date_time.local2utc
* @param p_daytime local date as reference for utc_daytime
* @param p_summertime summer time as reference for utc_daytime
* @param p_utc_daytime UTC date column to be sync with daytime
*/
PROCEDURE updateUtcDate(p_class_name VARCHAR2
                     ,p_object_id VARCHAR2
                     ,p_daytime DATE
                     ,p_summertime VARCHAR2
                     ,p_utc_daytime IN OUT NOCOPY DATE);

/*
* Sync daytime, summer_time from utc_daytime
*
* @param p_class_name Class name to be used to get production day definition, for summer_time flag and ecdp_date_time.local2utc
* @param p_object_id Object ID to be used to get production day definition, for summer_time flag and ecdp_date_time.local2utc
* @param p_utc_daytime UTC date column to be sync with daytime
* @param p_daytime local date to be sync with utc_daytime
* @param p_summertime summer time to be sync with utc_daytime
*/
PROCEDURE updateDaytime(p_class_name VARCHAR2
                     ,p_object_id VARCHAR2
                     ,p_utc_daytime DATE
                     ,p_daytime IN OUT NOCOPY DATE
                     ,p_summertime IN OUT NOCOPY VARCHAR2);

/*
* Sync production_day
*
* @param p_class_name Class name for ecdp_timestamp call
* @param p_object_id Object ID for ecdp_timestamp call
* @param p_production_day Production day to be set. Production day is expected to be NULL. Normally production_day column but can be event_day, day..
* @param p_utc_daytime UTC date column to be sync. Two way sync with daytime
*/
PROCEDURE setProductionDay(p_class_name VARCHAR2
                          ,p_object_id VARCHAR2
                          ,p_utc_daytime DATE
                          ,p_production_day IN OUT NOCOPY DATE
                          ,p_update BOOLEAN DEFAULT FALSE);

/*
* Sync production_day, with the production day can be not null
*
* @param p_class_name Class name for ecdp_timestamp call
* @param p_object_id Object ID for ecdp_timestamp call
* @param p_production_day Production day to be set. Production day can already be set. Normally production_day column but can be event_day, day..
* @param p_utc_daytime UTC date column to be sync. Two way sync with daytime
*/
PROCEDURE updateProductionDay(p_class_name VARCHAR2
                          ,p_object_id VARCHAR2
                          ,p_utc_daytime DATE
                          ,p_production_day IN OUT NOCOPY DATE);

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

END ecdp_timestamp_utils;