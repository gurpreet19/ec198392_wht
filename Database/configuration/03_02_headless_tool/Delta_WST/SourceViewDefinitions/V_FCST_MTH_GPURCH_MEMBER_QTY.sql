CREATE OR REPLACE FORCE EDITIONABLE VIEW "V_FCST_MTH_GPURCH_MEMBER_QTY" ("SORT_ORDER", "OBJECT_ID", "MEMBER_NO", "MEMBER_TYPE", "PRODUCT_ID", "PRODUCT_CODE", "CONTRACT_ID", "CONTRACT_CODE", "DAYTIME", "MONTH_LABEL", "STATUS", "NET_QTY", "UOM", "NQ_EDITABLE_IND", "RECORD_STATUS", "CREATED_BY", "CREATED_DATE", "LAST_UPDATED_BY", "LAST_UPDATED_DATE", "REV_NO", "REV_TEXT", "APPROVAL_BY", "APPROVAL_DATE", "APPROVAL_STATE", "REC_ID") AS 
  (
    SELECT '1_MTH' SORT_ORDER,
           fc.object_id OBJECT_ID,
           fm.member_no MEMBER_NO,
           fm.member_type MEMBER_TYPE,
           fm.product_id PRODUCT_ID,
           ec_product.object_code(fm.product_id) PRODUCT_CODE,
           fm.contract_id CONTRACT_ID,
           ec_contract.object_code(fm.contract_id) CONTRACT_CODE,
           fms.daytime DAYTIME,
           INITCAP(TO_CHAR(fms.daytime, 'MON')) MONTH_LABEL,
           fms.status STATUS,
           fms.net_qty NET_QTY,
           fms.uom UOM,
           DECODE(ec_forecast_version.populate_method(fc.object_id,fc.start_date,'<='),'PLAN', 'Y',
                 DECODE(ecdp_revn_forecast.isPriorToPlanDate(fc.object_id,fms.daytime),'TRUE', 'N', 'Y')) NQ_EDITABLE_IND,
           fms.RECORD_STATUS,
           fms.CREATED_BY,
           fms.CREATED_DATE,
           fms.LAST_UPDATED_BY,
           fms.LAST_UPDATED_DATE,
           fms.REV_NO,
           fms.REV_TEXT,
           fms.APPROVAL_BY,
           fms.APPROVAL_DATE,
           fms.APPROVAL_STATE,
           fms.REC_ID
      FROM forecast fc, fcst_member fm, fcst_mth_status fms
     WHERE fc.object_id = fm.object_id
       AND fm.member_no = fms.member_no
       AND fm.product_collection_type = 'GAS_PURCHASE'
UNION ALL
  -- Prior Year Adjustment
    SELECT '3_YR' SORT_ORDER,
           fc.object_id OBJECT_ID,
           fm.member_no MEMBER_NO,
           fm.member_type MEMBER_TYPE,
           fm.product_id PRODUCT_ID,
           ec_product.object_code(fm.product_id) PRODUCT_CODE,
           fm.contract_id CONTRACT_ID,
           ec_contract.object_code(fm.contract_id) CONTRACT_CODE,
           fys.daytime DAYTIME,
           'Prior Year' MONTH_LABEL,
           'Adjustment' STATUS,
           fys.net_qty NET_QTY,
           fys.uom UOM,
           'N' NQ_EDITABLE_IND,
           fys.RECORD_STATUS,
           fys.CREATED_BY,
           fys.CREATED_DATE,
           fys.LAST_UPDATED_BY,
           fys.LAST_UPDATED_DATE,
           fys.REV_NO,
           fys.REV_TEXT,
           fys.APPROVAL_BY,
           fys.APPROVAL_DATE,
           fys.APPROVAL_STATE,
           fys.REC_ID
     FROM forecast fc, fcst_member fm, fcst_yr_status fys
     WHERE fc.object_id = fm.object_id
       AND fm.member_no = fys.member_no
       AND fm.product_collection_type = 'GAS_PURCHASE'
)