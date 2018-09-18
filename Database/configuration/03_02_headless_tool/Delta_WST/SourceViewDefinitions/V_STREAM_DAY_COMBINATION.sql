CREATE OR REPLACE FORCE EDITIONABLE VIEW "V_STREAM_DAY_COMBINATION" ("OBJECT_ID", "DAYTIME", "RECORD_STATUS", "CREATED_BY", "CREATED_DATE", "LAST_UPDATED_BY", "LAST_UPDATED_DATE", "REV_NO", "REV_TEXT") AS 
  (
-------------------------------------------------------------------------------------
--  v_stream_day_combination
--
-- $Revision: 1.19 $
--
--  Purpose: Get all combinations of streams and system days.
--           This is needed by the allocation stream data views
--           who need to know all stream/day combinations for streams with
--	     daily values, but that do not have instantiated daily records.
--
--  Note:
--  ROV - Tracker 1894: Modified sql to also use attribute STRM_METER_FREQ
--  ROV - Tracker 1894: Modified sql to only return the first day of the month
--                      for streams only to be included in mothly allocation.
--  ROV - Tracker 1496: fixing error in previos script
--  MOT - Tracker 1496: fixing error in previous script
--  MOT - Tracker 1496: only list streams included in allocation
--  HAK - 2004-06-23 - Initial version
--  DN  - 2005-02-24    TI 1965: Renamed from_Date to start_Date.
--  RON - 2005-02-28	Performance Upgrade: Replace reference to ec_strm_attribute to ec_strm_version.
--  DN  - 2006-02-03    TI#3259: Performance improvement by using join instead of ec-package in where-clause.
--  LAU - 2006-03-09	TI#3277: Include allocation to read streams having strm_meter_freq='EVENT'
--  HUS - 2006-05-03	TI#3704: Only read streams with daily data and without instantiated daily records.
--  HUS - 2006-05-04	TI#3704: Renamed strm_version.stream_meter_method to strm_version.strm_meter_method
--  HNE ? 2007-04-24  Jira 4944 : Introduced alloc_data_freq and excluded stream_type=M strm_meter_freq=DAY
--  limmmchu ? 2012-06-25  Jira 21218 : Added nvl() funtion in strm_meter_freq
-------------------------------------------------------------------------------------
SELECT s.object_id,
       sd.daytime,
       s.record_status,
       s.created_by,
       s.created_date,
       s.last_updated_by,
       s.last_updated_date,
       s.rev_no,
       s.rev_text
  FROM stream s,
       strm_version sv,
       system_days sd
 WHERE s.object_id = sv.object_id
   AND sd.daytime >= s.start_date
   AND (s.end_date IS NULL OR sd.daytime < s.end_date)
   AND sd.daytime >= sv.daytime AND (sv.end_date IS NULL OR sd.daytime < sv.end_date)
   AND sv.alloc_data_freq = 'DAY'
   AND NOT (sv.stream_type='M' and nvl(sv.strm_meter_freq,'NA')= 'DAY')
)