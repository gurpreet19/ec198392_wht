CREATE OR REPLACE FORCE EDITIONABLE VIEW "V_SUMMARY_SETUP_HISTORY" ("CLASS_NAME", "OBJECT_ID", "CODE", "JN_DATETIME", "NAME", "OBJECT_START_DATE", "OBJECT_END_DATE", "DAYTIME", "END_DATE", "DESCRIPTION", "SUMMARY_TYPE", "POPULATE_METHOD", "PARENT_SUM_SETUP_ID", "PARENT_SUM_SETUP_CODE", "SET_WHEN_VERIFIED", "RECORD_STATUS", "CREATED_BY", "CREATED_DATE", "LAST_UPDATED_BY", "LAST_UPDATED_DATE", "REV_NO", "REV_TEXT", "APPROVAL_STATE", "APPROVAL_BY", "APPROVAL_DATE", "REC_ID") AS 
  SELECT
-- Generated by EcDp_GenClassCode
'SUMMARY_SETUP' AS CLASS_NAME
,o.OBJECT_ID AS OBJECT_ID
,o.OBJECT_CODE AS CODE
,oa.jn_datetime
,oa.NAME AS NAME
,o.START_DATE AS OBJECT_START_DATE
,o.END_DATE AS OBJECT_END_DATE
,oa.DAYTIME AS DAYTIME
,oa.END_DATE AS END_DATE
,o.DESCRIPTION AS DESCRIPTION
,oa.SUMMARY_TYPE AS SUMMARY_TYPE
,oa.POPULATE_METHOD AS POPULATE_METHOD
--,oa.STREAM AS STREAM
--,oa.RRCA_DATASET AS RRCA_DATASET
,oa.PARENT_SUM_SETUP_ID AS PARENT_SUM_SETUP_ID
,EC_SUMMARY_SETUP.object_code(oa.PARENT_SUM_SETUP_ID) AS PARENT_SUM_SETUP_CODE
,o.SET_WHEN_VERIFIED AS SET_WHEN_VERIFIED
,oa.record_status AS RECORD_STATUS
,oa.created_by AS CREATED_BY
,oa.created_date AS CREATED_DATE
,decode(sign(nvl(o.last_updated_date,o.created_date)-nvl(oa.last_updated_date,oa.created_date)),1,o.last_updated_by,oa.last_updated_by) AS LAST_UPDATED_BY
,decode(sign(nvl(o.last_updated_date,o.created_date)-nvl(oa.last_updated_date,oa.created_date)),1,o.last_updated_date,oa.last_updated_date) AS LAST_UPDATED_DATE
,o.rev_no||'.'||oa.rev_no AS REV_NO
,decode(sign(nvl(o.last_updated_date,o.created_date)-nvl(oa.last_updated_date,oa.created_date)),1,o.rev_text,oa.rev_text) AS REV_TEXT
,oa.approval_state AS APPROVAL_STATE
,oa.approval_by AS APPROVAL_BY
,oa.approval_date AS APPROVAL_DATE
,oa.rec_id AS REC_ID
FROM V_SUMMARY_SETUP_VERSION_HIST oa, SUMMARY_SETUP o
WHERE oa.object_id = o.object_id