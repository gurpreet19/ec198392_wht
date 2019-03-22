CREATE OR REPLACE FORCE EDITIONABLE VIEW "V_QRTZ_SIMPLE_TRIGGERS" ("SCHED_NAME", "TRIGGER_NAME", "TRIGGER_GROUP", "REPEAT_COUNT", "REPEAT_INTERVAL", "TIMES_TRIGGERED", "RECORD_STATUS", "CREATED_BY", "CREATED_DATE", "LAST_UPDATED_BY", "LAST_UPDATED_DATE", "REV_NO", "REV_TEXT") AS 
  (
----------------------------------------------------------------------------------------------------
-- File name: v_qrtz_simple_triggers.sql
-- View name: v_qrtz_simple_triggers
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
select "SCHED_NAME","TRIGGER_NAME","TRIGGER_GROUP","REPEAT_COUNT","REPEAT_INTERVAL","TIMES_TRIGGERED","RECORD_STATUS","CREATED_BY","CREATED_DATE","LAST_UPDATED_BY","LAST_UPDATED_DATE","REV_NO","REV_TEXT" FROM qrtz_simple_triggers t
)