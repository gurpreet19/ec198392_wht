CREATE OR REPLACE FORCE EDITIONABLE VIEW "V_TRANS_INV_SUMMARY_ITEM_H" ("CLASS_NAME", "OBJECT_ID", "OBJECT_CODE", "JN_DATETIME", "DAYTIME", "END_DATE", "SRC_TRANS_INV_LINE", "SORT_ORDER", "LAYER_METHOD", "REVERSE_IND", "DIMENSIONS", "PROD_MTH", "SOURCE_TRANS_INV_KEY", "TRANS_INVENTORY_ID", "TRANS_INVENTORY_CODE", "SOURCE_TRANS_INV_ID", "SOURCE_TRANS_INV_CODE", "SOURCE_PROD_STREAM_ID", "SOURCE_PROD_STREAM_CODE", "RECORD_STATUS", "CREATED_BY", "CREATED_DATE", "LAST_UPDATED_BY", "LAST_UPDATED_DATE", "REV_NO", "REV_TEXT", "APPROVAL_STATE", "APPROVAL_BY", "APPROVAL_DATE", "REC_ID") AS 
  (
----------------------------------------------------------------------------------------------------
-- File name: v_trans_inventory_version_hist.sql
-- View name: v_trans_inventory_version_hist
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
'v_trans_inv_summary_item_hi' AS CLASS_NAME,
v_trans_inv_summary_item_hist.OBJECT_ID AS OBJECT_ID,
o.OBJECT_CODE OBJECT_CODE,
v_trans_inv_summary_item_hist.JN_DATETIME,
v_trans_inv_summary_item_hist.DAYTIME AS DAYTIME,
v_trans_inv_summary_item_hist.END_DATE AS END_DATE,
v_trans_inv_summary_item_hist.SOURCE_TRANS_INV_LINE AS SRC_TRANS_INV_LINE,
v_trans_inv_summary_item_hist.SORT_ORDER AS SORT_ORDER,
v_trans_inv_summary_item_hist.LAYER_METHOD AS LAYER_METHOD,
v_trans_inv_summary_item_hist.REVERSE_IND AS REVERSE_IND,
v_trans_inv_summary_item_hist.DIMENSIONS AS DIMENSIONS,
v_trans_inv_summary_item_hist.PROD_MTH AS PROD_MTH,
SOURCE_TRANS_INV_ID||'$'||SOURCE_TRANS_INV_LINE||'$'||SOURCE_PROD_STREAM_ID AS SOURCE_TRANS_INV_KEY,
v_trans_inv_summary_item_hist.TRANS_INV_ID AS TRANS_INVENTORY_ID,
EC_TRANS_INVENTORY.object_code(v_trans_inv_summary_item_hist.TRANS_INV_ID) AS TRANS_INVENTORY_CODE,
v_trans_inv_summary_item_hist.SOURCE_TRANS_INV_ID AS SOURCE_TRANS_INV_ID,
EC_TRANS_INVENTORY.object_code(v_trans_inv_summary_item_hist.SOURCE_TRANS_INV_ID) AS SOURCE_TRANS_INV_CODE,
v_trans_inv_summary_item_hist.SOURCE_PROD_STREAM_ID AS SOURCE_PROD_STREAM_ID,
EC_CONTRACT.object_code(v_trans_inv_summary_item_hist.SOURCE_PROD_STREAM_ID) AS SOURCE_PROD_STREAM_CODE,
v_trans_inv_summary_item_hist.RECORD_STATUS AS RECORD_STATUS,
v_trans_inv_summary_item_hist.CREATED_BY AS CREATED_BY,
v_trans_inv_summary_item_hist.CREATED_DATE AS CREATED_DATE,
v_trans_inv_summary_item_hist.LAST_UPDATED_BY AS LAST_UPDATED_BY,
v_trans_inv_summary_item_hist.LAST_UPDATED_DATE AS LAST_UPDATED_DATE,
v_trans_inv_summary_item_hist.REV_NO AS REV_NO,
v_trans_inv_summary_item_hist.REV_TEXT AS REV_TEXT,
v_trans_inv_summary_item_hist.APPROVAL_STATE AS APPROVAL_STATE,
v_trans_inv_summary_item_hist.APPROVAL_BY AS APPROVAL_BY,
v_trans_inv_summary_item_hist.APPROVAL_DATE AS APPROVAL_DATE,
v_trans_inv_summary_item_hist.REC_ID AS REC_ID
FROM v_trans_inv_summary_item_hist
, CONTRACT_VERSION oa, CONTRACT o
WHERE v_trans_inv_summary_item_hist.object_id = oa.object_id
AND oa.object_id = o.object_id
AND v_trans_inv_summary_item_hist.daytime >= TRUNC(oa.daytime,'MONTH')
AND oa.daytime = (
SELECT MIN(daytime) FROM CONTRACT_VERSION v2
WHERE v2.object_id = oa.object_id
AND   v_trans_inv_summary_item_hist.daytime >= trunc(v2.daytime,'MONTH')
AND v_trans_inv_summary_item_hist.daytime < nvl(v2.end_date,v_trans_inv_summary_item_hist.daytime + 1))
)