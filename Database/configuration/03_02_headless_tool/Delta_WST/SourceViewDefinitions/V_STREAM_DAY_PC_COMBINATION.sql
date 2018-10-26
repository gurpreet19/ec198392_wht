CREATE OR REPLACE FORCE EDITIONABLE VIEW "V_STREAM_DAY_PC_COMBINATION" ("OBJECT_ID", "PRODUCTION_DAY", "PROFIT_CENTRE_ID", "RECORD_STATUS", "CREATED_BY", "CREATED_DATE", "LAST_UPDATED_BY", "LAST_UPDATED_DATE", "REV_NO", "REV_TEXT") AS 
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
--  13.07.2017    kashisag  ECPD-45817: Replaced sysdate with Ecdp_Timestamp.getCurrentSysdate
-------------------------------------------------------------------------------------
SELECT DISTINCT
s.object_id,
s.production_day,
s.profit_centre_id,
'P' as record_status,
user as created_by,
Ecdp_Timestamp.getCurrentSysdate as created_date,
USER as last_updated_by,
Ecdp_Timestamp.getCurrentSysdate as last_updated_date,
0 as rev_no,
null as rev_text
FROM strm_transport_event s
WHERE s.profit_centre_id is not null
)