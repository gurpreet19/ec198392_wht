CREATE OR REPLACE FORCE VIEW "V_QRTZ_FIRED_TRIGGERS" ("ENTRY_ID", "TRIGGER_NAME", "TRIGGER_GROUP", "IS_VOLATILE", "INSTANCE_NAME", "FIRED_TIME", "STATE", "JOB_NAME", "JOB_GROUP", "IS_STATEFUL", "REQUESTS_RECOVERY", "RECORD_STATUS", "CREATED_BY", "CREATED_DATE", "LAST_UPDATED_BY", "LAST_UPDATED_DATE", "REV_NO", "REV_TEXT") AS 
  (
----------------------------------------------------------------------------------------------------
-- File name: v_qrtz_fired_triggers.sql
-- View name: v_qrtz_fired_triggers
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
select "ENTRY_ID","TRIGGER_NAME","TRIGGER_GROUP","IS_VOLATILE","INSTANCE_NAME","FIRED_TIME","STATE","JOB_NAME","JOB_GROUP","IS_STATEFUL","REQUESTS_RECOVERY","RECORD_STATUS","CREATED_BY","CREATED_DATE","LAST_UPDATED_BY","LAST_UPDATED_DATE","REV_NO","REV_TEXT" from qrtz_fired_triggers t
)