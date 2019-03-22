CREATE OR REPLACE FORCE VIEW "V_QRTZ_TRIGGER_LISTENERS" ("TRIGGER_NAME", "TRIGGER_GROUP", "TRIGGER_LISTENER", "RECORD_STATUS", "CREATED_BY", "CREATED_DATE", "LAST_UPDATED_BY", "LAST_UPDATED_DATE", "REV_NO", "REV_TEXT") AS 
  (
----------------------------------------------------------------------------------------------------
-- File name: v_qrtz_trigger_listeners.sql
-- View name: v_qrtz_trigger_listeners
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
select "TRIGGER_NAME","TRIGGER_GROUP","TRIGGER_LISTENER","RECORD_STATUS","CREATED_BY","CREATED_DATE","LAST_UPDATED_BY","LAST_UPDATED_DATE","REV_NO","REV_TEXT" FROM qrtz_trigger_listeners t
)