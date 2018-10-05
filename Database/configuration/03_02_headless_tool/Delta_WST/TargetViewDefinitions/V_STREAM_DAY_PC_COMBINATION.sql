CREATE OR REPLACE FORCE VIEW "V_STREAM_DAY_PC_COMBINATION" ("OBJECT_ID", "PRODUCTION_DAY", "PROFIT_CENTRE_ID", "RECORD_STATUS", "CREATED_BY", "CREATED_DATE", "LAST_UPDATED_BY", "LAST_UPDATED_DATE", "REV_NO", "REV_TEXT") AS 
  (
-------------------------------------------------------------------------------------
--  v_stream_day_pc_combination
--
-- $Revision: 1.2 $
--
--  Purpose: Get all distinct combinations of STREAM, PRODUCTION_DAY and PROFIT_CENTRE_ID for a given day
--           The other columns are required by the view generator.
--
--
--  History:
--
--  Date      Modified by    Comment
--  30-Oct-06 austahan       Tracker 3804: Initial version
--  31-Oct-06 seongkok       Tracker 3804: Modified default values for the auxiliary columns
-------------------------------------------------------------------------------------
SELECT DISTINCT
s.object_id,
s.production_day,
s.profit_centre_id,
'P' as record_status,
user as created_by,
ecdp_date_time.getCurrentSysdate as created_date, -- sysdate?
null as last_updated_by, -- user?
null as last_updated_date, -- sysdate?
0 as rev_no,
null as rev_text
FROM strm_transport_event s
WHERE s.profit_centre_id is not null
)