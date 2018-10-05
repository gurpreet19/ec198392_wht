CREATE OR REPLACE FORCE EDITIONABLE VIEW "V_TRANS_INVENTORY_HISTORY" ("CLASS_NAME", "OBJECT_ID", "ALLOC_NETWORK_ID", "NODE_ID", "OBJECT_CODE", "NAME", "OBJECT_START_DATE", "OBJECT_END_DATE", "DESCRIPTION", "JN_DATETIME", "DAYTIME", "END_DATE", "SEQ_NO", "INVENTORY_TYPE", "COUNTRY_ID", "SUMMARY_SETUP_ID", "VALUATION_METHOD", "CONFIG_TEMPLATE", "QUANTITY_DECIMALS", "VALUE_DECIMALS", "DIMENSION_OVER_MONTH_IND", "EXCL_OVERLIFT_PRICE_IND", "OVERLIFT_TO_XFER_OUT_IND", "COST_ASSET_TYPE", "DEPRECIATION", "CAPACITY", "LONG_TERM_BOND_RATE_ID", "NEB_EQUITY_RATE_ID", "CORPORATE_TAX_RATE_ID", "COMMENTS", "RECORD_STATUS", "CREATED_BY", "CREATED_DATE", "LAST_UPDATED_BY", "LAST_UPDATED_DATE", "REV_NO", "REV_TEXT", "APPROVAL_STATE", "APPROVAL_BY", "APPROVAL_DATE", "REC_ID") AS 
  (
------------------------------------------------------------------------------------
--  v_trans_inventory_history
--
-- $Revision: 1.0 $
--
--  Purpose:   Use in Transaction Inventory Historical
--  Note:
--
--  Date           Whom 		Change description:
--  -------------- --------		--------
--  25-10-2016     hannnyii     Intial version
-------------------------------------------------------------------------------------
SELECT
'v_trans_inventory_history' AS CLASS_NAME
,o.OBJECT_ID
,o.ALLOC_NETWORK_ID
,o.NODE_ID
,o.OBJECT_CODE
,oa.NAME
,o.START_DATE AS OBJECT_START_DATE
,o.END_DATE AS OBJECT_END_DATE
,o.DESCRIPTION
,oa.jn_datetime
,oa.DAYTIME
,oa.END_DATE
,oa.SEQ_NO
,oa.INVENTORY_TYPE
,oa.COUNTRY_ID
,oa.SUMMARY_SETUP_ID
,oa.VALUATION_METHOD
,oa.CONFIG_TEMPLATE
,oa.QUANTITY_DECIMALS
,oa.VALUE_DECIMALS
,oa.DIMENSION_OVER_MONTH_IND
,oa.EXCL_OVERLIFT_PRICE_IND
,oa.OVERLIFT_TO_XFER_OUT_IND
,oa.COST_ASSET_TYPE
,oa.DEPRECIATION
,oa.CAPACITY
,oa.LONG_TERM_BOND_RATE_ID
,oa.NEB_EQUITY_RATE_ID
,oa.CORPORATE_TAX_RATE_ID
,oa.COMMENTS
,oa.record_status
,oa.created_by
,oa.created_date
,oa.last_updated_by
,oa.last_updated_date
,oa.rev_no
,oa.rev_text
,oa.approval_state
,oa.approval_by
,oa.approval_date
,oa.rec_id
FROM V_TRANS_INVENTORY_VERSION_HIST oa, TRANS_INVENTORY o
WHERE oa.object_id = o.object_id
)