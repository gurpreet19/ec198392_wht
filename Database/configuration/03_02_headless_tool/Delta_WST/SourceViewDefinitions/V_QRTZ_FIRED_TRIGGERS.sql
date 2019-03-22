CREATE OR REPLACE FORCE EDITIONABLE VIEW "V_QRTZ_FIRED_TRIGGERS" ("SCHED_NAME", "ENTRY_ID", "TRIGGER_NAME", "TRIGGER_GROUP", "INSTANCE_NAME", "FIRED_TIME", "SCHED_TIME", "PRIORITY", "STATE", "JOB_NAME", "JOB_GROUP", "IS_NONCONCURRENT", "REQUESTS_RECOVERY", "RECORD_STATUS", "CREATED_BY", "CREATED_DATE", "LAST_UPDATED_BY", "LAST_UPDATED_DATE", "REV_NO", "REV_TEXT") AS 
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
select "SCHED_NAME","ENTRY_ID","TRIGGER_NAME","TRIGGER_GROUP","INSTANCE_NAME","FIRED_TIME","SCHED_TIME","PRIORITY","STATE","JOB_NAME","JOB_GROUP","IS_NONCONCURRENT","REQUESTS_RECOVERY","RECORD_STATUS","CREATED_BY","CREATED_DATE","LAST_UPDATED_BY","LAST_UPDATED_DATE","REV_NO","REV_TEXT" from qrtz_fired_triggers t
)