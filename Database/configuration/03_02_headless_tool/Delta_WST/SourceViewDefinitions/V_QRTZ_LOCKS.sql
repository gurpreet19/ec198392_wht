CREATE OR REPLACE FORCE EDITIONABLE VIEW "V_QRTZ_LOCKS" ("SCHED_NAME", "LOCK_NAME", "RECORD_STATUS", "CREATED_BY", "CREATED_DATE", "LAST_UPDATED_BY", "LAST_UPDATED_DATE", "REV_NO", "REV_TEXT") AS 
  (
----------------------------------------------------------------------------------------------------
-- File name: v_qrtz_locks.sql
-- View name: v_qrtz_locks
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
select "SCHED_NAME","LOCK_NAME","RECORD_STATUS","CREATED_BY","CREATED_DATE","LAST_UPDATED_BY","LAST_UPDATED_DATE","REV_NO","REV_TEXT" from qrtz_locks t
)