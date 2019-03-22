CREATE OR REPLACE FORCE VIEW "V_QRTZ_TRIGGERS" ("TRIGGER_NAME", "TRIGGER_GROUP", "JOB_NAME", "JOB_GROUP", "IS_VOLATILE", "DESCRIPTION", "NEXT_FIRE_TIME", "PREV_FIRE_TIME", "TRIGGER_STATE", "TRIGGER_TYPE", "START_TIME", "END_TIME", "CALENDAR_NAME", "MISFIRE_INSTR", "JOB_DATA", "RECORD_STATUS", "CREATED_BY", "CREATED_DATE", "LAST_UPDATED_BY", "LAST_UPDATED_DATE", "REV_NO", "REV_TEXT") AS 
  (
----------------------------------------------------------------------------------------------------
-- File name: v_qrtz_triggers.sql
-- View name: v_qrtz_triggers
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
select "TRIGGER_NAME","TRIGGER_GROUP","JOB_NAME","JOB_GROUP","IS_VOLATILE","DESCRIPTION","NEXT_FIRE_TIME","PREV_FIRE_TIME",
ecdp_scheduler.statusOrPinStatus(trigger_name, trigger_group, trigger_state) "TRIGGER_STATE",
"TRIGGER_TYPE","START_TIME","END_TIME","CALENDAR_NAME","MISFIRE_INSTR","JOB_DATA","RECORD_STATUS","CREATED_BY","CREATED_DATE","LAST_UPDATED_BY","LAST_UPDATED_DATE","REV_NO","REV_TEXT" FROM qrtz_triggers t
)