CREATE OR REPLACE FORCE VIEW "V_QRTZ_SCHEDULER_STATE" ("INSTANCE_NAME", "LAST_CHECKIN_TIME", "CHECKIN_INTERVAL", "RECOVERER", "RECORD_STATUS", "CREATED_BY", "CREATED_DATE", "LAST_UPDATED_BY", "LAST_UPDATED_DATE", "REV_NO", "REV_TEXT") AS 
  (
----------------------------------------------------------------------------------------------------
-- File name: v_qrtz_scheduler_state.sql
-- View name: v_qrtz_scheduler_state
--
-- $Revision: 1.1 $
--
-- Purpose  : wrap quartz table to support pinning
--
-- Modification history:
--
-- Date       Whom  Change description:
-- ---------- ----  --------------------------------------------------------------------------------
-- 3-2-2006  rupermic	 ininital checkin
----------------------------------------------------------------------------------------------------
select "INSTANCE_NAME","LAST_CHECKIN_TIME","CHECKIN_INTERVAL","RECOVERER","RECORD_STATUS","CREATED_BY","CREATED_DATE","LAST_UPDATED_BY","LAST_UPDATED_DATE","REV_NO","REV_TEXT" FROM qrtz_scheduler_state t
)