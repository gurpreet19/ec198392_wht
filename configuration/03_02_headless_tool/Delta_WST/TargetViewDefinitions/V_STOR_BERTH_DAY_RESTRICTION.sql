CREATE OR REPLACE FORCE VIEW "V_STOR_BERTH_DAY_RESTRICTION" ("OBJECT_ID", "DAYTIME", "BERTH_ID", "RESTRICTION_TYPE", "COMMENTS", "RECORD_STATUS", "CREATED_BY", "CREATED_DATE", "LAST_UPDATED_BY", "LAST_UPDATED_DATE", "REV_NO", "REV_TEXT") AS 
  (
----------------------------------------------------------------------------------------------------
-- File name: V_STOR_BERTH_DAY_RESTRICTION.sql
-- View name: V_STOR_BERTH_DAY_RESTRICTION
--
-- $Revision: 1.1.2.2 $
--
-- Purpose  : The storage and berth on maintenance
--
-- Modification history:
--
-- Date       Whom  	Change description:
-- ---------- ----  	--------------------------------------------------------------------------------
-- 12.04.2013 leeeewei   Intial version
----------------------------------------------------------------------------------------------------
SELECT s.OBJECT_ID,
       o.DAYTIME,
       s.BERTH_ID,
	   o.RESTRICTION_TYPE,
	   o.COMMENTS,
       o.record_status record_status,
       o.created_by created_by,
       o.created_date created_date,
       o.last_updated_by last_updated_by,
       o.last_updated_date last_updated_date,
       o.rev_no rev_no,
       o.rev_text rev_text
  FROM oploc_daily_restriction o, storage_berth s
 where s.berth_id = o.object_id
 and o.daytime >= s.daytime
 and o.daytime <= nvl(s.end_date, o.daytime+1)
)