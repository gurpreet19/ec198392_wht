CREATE OR REPLACE FORCE EDITIONABLE VIEW "V_STREAM_MTH_COMBINATION" ("OBJECT_ID", "DAYTIME", "RECORD_STATUS", "CREATED_BY", "CREATED_DATE", "LAST_UPDATED_BY", "LAST_UPDATED_DATE", "REV_NO", "REV_TEXT") AS 
  (
-------------------------------------------------------------------------------------
--  v_stream_mth_combination
--
-- $Revision: 1.4 $
--
--  Purpose: Get all combinations of streams and system months.
--           This is needed by the allocation stream data views
--           who needs to know all stream/month combinations for
--           streams with monthly values but without instantiated
--	     monthly records.
--
--  Note:
--  HUS - Tracker 3704: Initial version
--  HUS - 2006-05-04	TI#3704: Renamed strm_version.stream_meter_method to strm_version.strm_meter_method
--  HNE ? 2007-04-24  Jira 4944 : Introduced alloc_data_freq and excluded stream_type=M strm_meter_freq=MTH
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
       system_month sd
 WHERE s.object_id = sv.object_id
   AND sd.daytime >= TRUNC(s.start_date,'MM')
   AND (s.end_date IS NULL OR sd.daytime < s.end_date)
   AND sd.daytime >= TRUNC(sv.daytime,'MM') AND (sv.end_date IS NULL OR sd.daytime < sv.end_date)
   AND sv.alloc_data_freq = 'MTH'
   AND NOT (sv.stream_type='M' AND sv.strm_meter_freq='MTH')
)