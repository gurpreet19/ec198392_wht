CREATE OR REPLACE FORCE VIEW "V_QRTZ_JOB_DETAILS" ("JOB_NAME", "JOB_GROUP", "DESCRIPTION", "JOB_CLASS_NAME", "IS_DURABLE", "IS_VOLATILE", "IS_STATEFUL", "REQUESTS_RECOVERY", "JOB_DATA", "RECORD_STATUS", "CREATED_BY", "CREATED_DATE", "LAST_UPDATED_BY", "LAST_UPDATED_DATE", "REV_NO", "REV_TEXT") AS 
  (
----------------------------------------------------------------------------------------------------
-- File name: v_qrtz_job_details.sql
-- View name: v_qrtz_job_details
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
select "JOB_NAME","JOB_GROUP","DESCRIPTION","JOB_CLASS_NAME","IS_DURABLE","IS_VOLATILE","IS_STATEFUL","REQUESTS_RECOVERY","JOB_DATA","RECORD_STATUS","CREATED_BY","CREATED_DATE","LAST_UPDATED_BY","LAST_UPDATED_DATE","REV_NO","REV_TEXT" from qrtz_job_details t
)