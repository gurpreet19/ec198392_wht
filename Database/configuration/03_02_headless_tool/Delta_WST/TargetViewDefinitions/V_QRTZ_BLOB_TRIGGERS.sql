CREATE OR REPLACE FORCE VIEW "V_QRTZ_BLOB_TRIGGERS" ("TRIGGER_NAME", "TRIGGER_GROUP", "BLOB_DATA", "RECORD_STATUS", "CREATED_BY", "CREATED_DATE", "LAST_UPDATED_BY", "LAST_UPDATED_DATE", "REV_NO", "REV_TEXT") AS 
  (
----------------------------------------------------------------------------------------------------
-- File name: v_qrtz_blob_triggers.sql
-- View name: v_qrtz_blob_triggers
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
select "TRIGGER_NAME","TRIGGER_GROUP","BLOB_DATA","RECORD_STATUS","CREATED_BY","CREATED_DATE","LAST_UPDATED_BY","LAST_UPDATED_DATE","REV_NO","REV_TEXT" from qrtz_blob_triggers t
)