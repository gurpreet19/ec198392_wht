CREATE OR REPLACE FORCE EDITIONABLE VIEW "V_REVN_PROD_STREAM_HISTORY" ("CLASS_NAME", "OBJECT_ID", "CODE", "NAME", "OBJECT_START_DATE", "OBJECT_END_DATE", "JN_DATETIME", "DAYTIME", "END_DATE", "REVN_IND", "BF_PROFILE", "TEMPLATE_CODE", "SORT_ORDER", "CONTRACT_GROUP_CODE", "CONTRACT_RESPONSIBLE", "FINANCIAL_CODE", "CALC_APPROVAL_CHECK", "CONTRACT_AREA_ID", "CONTRACT_AREA_CODE", "COMPANY_ID", "COMPANY_CODE", "RECORD_STATUS", "CREATED_BY", "CREATED_DATE", "LAST_UPDATED_BY", "LAST_UPDATED_DATE", "REV_NO", "REV_TEXT", "APPROVAL_STATE", "APPROVAL_BY", "APPROVAL_DATE", "REC_ID") AS 
  (
----------------------------------------------------------------------------------------------------
-- File name: v_revn_prod_stream_history.sql
-- View name: v_revn_prod_stream_history
--
-- $Revision: 1.0 $
--
-- Purpose  : combine both Historical and Current version of records.
--
-- Modification history:
--
-- Date       Whom       Change description:
-- ---------- ----       --------------------------------------------------------------------------------
-- 25.10.2016 hannnyii
----------------------------------------------------------------------------------------------------
  SELECT
  'v_revn_prod_stream_history' AS CLASS_NAME
  ,o.OBJECT_ID AS OBJECT_ID
  ,o.OBJECT_CODE AS CODE
  ,oa.NAME AS NAME
  ,o.START_DATE AS OBJECT_START_DATE
  ,o.END_DATE AS OBJECT_END_DATE
  ,oa.JN_DATETIME AS JN_DATETIME
  ,oa.DAYTIME AS DAYTIME
  ,oa.END_DATE AS END_DATE
  ,o.REVN_IND AS REVN_IND
  ,o.BF_PROFILE AS BF_PROFILE
  ,o.TEMPLATE_CODE AS TEMPLATE_CODE
  ,oa.SORT_ORDER AS SORT_ORDER
  ,oa.CONTRACT_GROUP_CODE AS CONTRACT_GROUP_CODE
  ,oa.CONTRACT_RESPONSIBLE AS CONTRACT_RESPONSIBLE
  ,oa.FINANCIAL_CODE AS FINANCIAL_CODE
  ,oa.CALC_APPROVAL_CHECK AS CALC_APPROVAL_CHECK
  ,oa.CONTRACT_AREA_ID AS CONTRACT_AREA_ID
  ,EC_CONTRACT_AREA.object_code(oa.CONTRACT_AREA_ID) AS CONTRACT_AREA_CODE
  ,oa.COMPANY_ID AS COMPANY_ID
  ,EC_COMPANY.object_code(oa.COMPANY_ID) AS COMPANY_CODE
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
  FROM v_CONTRACT_VERSION_hist oa, CONTRACT o
  WHERE oa.object_id = o.object_id
  AND FINANCIAL_CODE= 'REVENUE_STREAM')