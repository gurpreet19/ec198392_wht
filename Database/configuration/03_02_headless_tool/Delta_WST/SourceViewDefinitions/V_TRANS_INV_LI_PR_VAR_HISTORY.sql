CREATE OR REPLACE FORCE EDITIONABLE VIEW "V_TRANS_INV_LI_PR_VAR_HISTORY" ("CLASS_NAME", "OBJECT_ID", "OBJECT_CODE", "REVERSE_VALUE_IND", "JN_DATETIME", "DAYTIME", "END_DATE", "NET_ZERO_IND", "NAME", "LINE_TAG", "ROUND_IND", "POST_PROCESS_IND", "TYPE", "EXEC_ORDER", "COST_TYPE", "VAR_KEY", "DIMENSION_KEY", "TRANS_DEF_DIMENSION", "ID", "TRANS_PROD_SET_ITEM_ID", "CONFIG_VARIABLE_ID", "CONFIG_VARIABLE_CODE", "PRODUCT_ID", "PRODUCT_CODE", "PROD_STREAM_ID", "PROD_STREAM_CODE", "RECORD_STATUS", "CREATED_BY", "CREATED_DATE", "LAST_UPDATED_BY", "LAST_UPDATED_DATE", "REV_NO", "REV_TEXT", "APPROVAL_STATE", "APPROVAL_BY", "APPROVAL_DATE", "REC_ID", "DISABLED_IND", "OVER_IND", "JN_OPERATION") AS 
  (
----------------------------------------------------------------------------------------------------
-- File name: v_trans_inv_li_pr_var_hist.sql
-- View name: v_trans_inv_li_pr_var_hist
--
-- $Revision: 1.0 $
--
-- Purpose  : combine both Historical and Current version of records.
--
-- Modification history:
--9
-- Date       Whom       Change description:
-- ---------- ----       --------------------------------------------------------------------------------
-- 25.10.2016 hannnyii
----------------------------------------------------------------------------------------------------
SELECT
'v_trans_inv_li_pr_var_history' AS CLASS_NAME,
v_trans_inv_li_pr_var_over_h.OBJECT_ID AS OBJECT_ID,
o.OBJECT_CODE OBJECT_CODE,
v_trans_inv_li_pr_var_over_h.REVERSE_VALUE_IND AS REVERSE_VALUE_IND,
v_trans_inv_li_pr_var_over_h.JN_DATETIME AS JN_DATETIME,
v_trans_inv_li_pr_var_over_h.DAYTIME AS DAYTIME,
v_trans_inv_li_pr_var_over_h.END_DATE AS END_DATE,
v_trans_inv_li_pr_var_over_h.NET_ZERO_IND AS NET_ZERO_IND,
v_trans_inv_li_pr_var_over_h.NAME AS NAME,
v_trans_inv_li_pr_var_over_h.LINE_TAG AS LINE_TAG,
v_trans_inv_li_pr_var_over_h.ROUND_IND AS ROUND_IND,
v_trans_inv_li_pr_var_over_h.POST_PROCESS_IND AS POST_PROCESS_IND,
v_trans_inv_li_pr_var_over_h.TYPE AS TYPE,
v_trans_inv_li_pr_var_over_h.VAR_EXEC_ORDER AS EXEC_ORDER,
v_trans_inv_li_pr_var_over_h.COST_TYPE AS COST_TYPE,
PROD_STREAM_ID ||'|'|| VAR_EXEC_ORDER ||'|'|| CONFIG_VARIABLE_ID AS VAR_KEY,
v_trans_inv_li_pr_var_over_h.DIMENSION AS DIMENSION_KEY,
v_trans_inv_li_pr_var_over_h.TRANS_DEF_DIMENSION AS TRANS_DEF_DIMENSION,
v_trans_inv_li_pr_var_over_h.ID AS ID,
PRODUCT_ID ||'|'|| COST_TYPE AS TRANS_PROD_SET_ITEM_ID,
v_trans_inv_li_pr_var_over_h.CONFIG_VARIABLE_ID AS CONFIG_VARIABLE_ID,
EC_CONFIG_VARIABLE.object_code(v_trans_inv_li_pr_var_over_h.CONFIG_VARIABLE_ID) AS CONFIG_VARIABLE_CODE,
v_trans_inv_li_pr_var_over_h.PRODUCT_ID AS PRODUCT_ID,
EC_PRODUCT.object_code(v_trans_inv_li_pr_var_over_h.PRODUCT_ID) AS PRODUCT_CODE,
v_trans_inv_li_pr_var_over_h.PROD_STREAM_ID AS PROD_STREAM_ID,
EC_CONTRACT.object_code(v_trans_inv_li_pr_var_over_h.PROD_STREAM_ID) AS PROD_STREAM_CODE,
v_trans_inv_li_pr_var_over_h.RECORD_STATUS AS RECORD_STATUS,
v_trans_inv_li_pr_var_over_h.CREATED_BY AS CREATED_BY,
v_trans_inv_li_pr_var_over_h.CREATED_DATE AS CREATED_DATE,
v_trans_inv_li_pr_var_over_h.LAST_UPDATED_BY AS LAST_UPDATED_BY,
v_trans_inv_li_pr_var_over_h.LAST_UPDATED_DATE AS LAST_UPDATED_DATE,
v_trans_inv_li_pr_var_over_h.REV_NO AS REV_NO,
v_trans_inv_li_pr_var_over_h.REV_TEXT AS REV_TEXT,
v_trans_inv_li_pr_var_over_h.APPROVAL_STATE AS APPROVAL_STATE,
v_trans_inv_li_pr_var_over_h.APPROVAL_BY AS APPROVAL_BY,
v_trans_inv_li_pr_var_over_h.APPROVAL_DATE AS APPROVAL_DATE,
v_trans_inv_li_pr_var_over_h.REC_ID AS REC_ID,
v_trans_inv_li_pr_var_over_h.DISABLED_IND AS DISABLED_IND,
v_trans_inv_li_pr_var_over_h.OVER_IND AS OVER_IND,
v_trans_inv_li_pr_var_over_h.JN_OPERATION As JN_OPERATION
FROM v_trans_inv_li_pr_var_over_h
, TRANS_INVENTORY_VERSION oa, TRANS_INVENTORY o
WHERE v_trans_inv_li_pr_var_over_h.object_id = oa.object_id
AND oa.object_id = o.object_id
AND v_trans_inv_li_pr_var_over_h.daytime >= oa.daytime
AND (oa.end_date is NULL OR v_trans_inv_li_pr_var_over_h.daytime < oa.end_date)
AND PRODUCT_ID != 'MESSAGE')