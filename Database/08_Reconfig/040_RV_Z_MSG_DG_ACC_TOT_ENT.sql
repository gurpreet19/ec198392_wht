
  CREATE OR REPLACE VIEW "RV_Z_MSG_DG_ACC_TOT_ENT" ("DATA_CLASS_NAME", "OWNER_CLASS_NAME", "PRODUCTION_YR", "OBJECT_ID", "CODE", "NAME", "OBJECT_START_DATE", "OBJECT_END_DATE", "DESCRIPTION", "COMMENTS", "COMPANY_NAME", "START_YEAR", "TRAN_IND", "SALE_IND", "REVN_IND", "BF_PROFILE", "TEMPLATE_CODE", "DAY_OFFSET_HOURS", "SORT_ORDER", "CALC_RULE_ID", "CALC_RULE_CODE", "CALC_SEQ_NO", "ACTIVE_CNTR_DAY", "CONTRACT_GROUP_CODE", "FINANCIAL_CODE", "PRODUCT_TYPE", "CONTRACT_TERM_CODE", "DIST_CLASS", "USE_DISTRIBUTION_IND", "PRICE_DECIMALS", "UOM1_TMPL", "UOM2_TMPL", "UOM3_TMPL", "UOM4_TMPL", "SYSTEM_OWNER", "CONTRACT_STAGE_CODE", "CONTRACT_RESPONSIBLE", "LEGAL_OWNER", "PROCESSABLE_CODE", "FIRST_DELIVERY_DATE", "BANK_DETAILS_LEVEL_CODE", "LAST_DELIVERY_DATE", "DOCUMENT_HANDLING_CODE", "OBJECT_ID_FILTER1", "OBJECT_ID_FILTER2", "PRODUCTION_DAY_ID", "PRODUCTION_DAY_CODE", "COMPANY_ID", "COMPANY_CODE", "PARENT_CONTRACT_ID", "PARENT_CONTRACT_CODE", "CONTRACT_AREA_ID", "CONTRACT_AREA_CODE", "PRICING_CURRENCY_ID", "PRICING_CURRENCY_CODE", "MEMO_CURRENCY_ID", "MEMO_CURRENCY_CODE", "BOOKING_CURRENCY_ID", "BOOKING_CURRENCY_CODE", "SA_DAY_CALC_ID", "SA_DAY_CALC_CODE", "SA_MTH_CALC_ID", "SA_MTH_CALC_CODE", "SA_YR_CALC_ID", "SA_YR_CALC_CODE", "DAYTIME", "FORECAST_ID", "PRODUCTION_YEAR", "IS_SUMMARY", "DELIVERY_POINT_CODE", "AVG_EFFECTIVE_PI", "CAPACITY_ENT", "DELIVERABILITY_ENT", "REFERENCE_ENT", "INSTALLED_CAPACITY", "MAX_DELIVERABILITY", "JOINT_RESERVATION", "NET_EQUITY_DEL", "REFERENCE_PROD", "DEFAULT_UOM", "REFERENCE_ENT_VOL", "REFERENCE_PROD_VOL", "VOLUME_UOM", "RECORD_STATUS", "CREATED_BY", "CREATED_DATE", "LAST_UPDATED_BY", "LAST_UPDATED_DATE", "REV_NO", "REV_TEXT", "APPROVAL_STATE", "APPROVAL_BY", "APPROVAL_DATE", "REC_ID") AS 
  SELECT
-- Generated by EcDp_GenClassCode 
 'Z_MSG_DG_ACC_TOT_ENT' AS DATA_CLASS_NAME
 ,'CONTRACT' AS OWNER_CLASS_NAME
 ,zv_fcst_dg_ref_total.DAYTIME AS PRODUCTION_YR
 ,zv_fcst_dg_ref_total.OBJECT_ID AS OBJECT_ID
 ,o.object_code AS CODE
 ,oa.name AS NAME
 ,o.start_date AS OBJECT_START_DATE
 ,o.end_date AS OBJECT_END_DATE
 ,o.description AS DESCRIPTION
 ,oa.comments AS COMMENTS
 ,ec_company_version.name(oa.COMPANY_ID, oa.DAYTIME, '<=') AS COMPANY_NAME
 ,o.start_year AS START_YEAR
 ,o.tran_ind AS TRAN_IND
 ,o.sale_ind AS SALE_IND
 ,o.revn_ind AS REVN_IND
 ,o.bf_profile AS BF_PROFILE
 ,o.template_code AS TEMPLATE_CODE
 ,EcDp_ContractDay.getProductionDayOffset('CONTRACT', o.object_id, oa.daytime) AS DAY_OFFSET_HOURS
 ,oa.sort_order AS SORT_ORDER
 ,oa.calc_rule_id AS CALC_RULE_ID
 ,ecdp_objects.GetObjCode(CALC_RULE_ID) AS CALC_RULE_CODE
 ,oa.calc_seq AS CALC_SEQ_NO
 ,EcDp_ContractDay.findProductionDayDefinition('CONTRACT', O.OBJECT_ID, oa.DAYTIME) AS ACTIVE_CNTR_DAY
 ,oa.contract_group_code AS CONTRACT_GROUP_CODE
 ,oa.financial_code AS FINANCIAL_CODE
 ,oa.product_type AS PRODUCT_TYPE
 ,oa.contract_term_code AS CONTRACT_TERM_CODE
 ,oa.DIST_OBJECT_TYPE AS DIST_CLASS
 ,oa.use_distribution_ind AS USE_DISTRIBUTION_IND
 ,oa.price_decimals AS PRICE_DECIMALS
 ,oa.uom1_tmpl AS UOM1_TMPL
 ,oa.uom2_tmpl AS UOM2_TMPL
 ,oa.uom3_tmpl AS UOM3_TMPL
 ,oa.uom4_tmpl AS UOM4_TMPL
 ,oa.system_owner AS SYSTEM_OWNER
 ,oa.contract_stage_code AS CONTRACT_STAGE_CODE
 ,oa.contract_responsible AS CONTRACT_RESPONSIBLE
 ,oa.legal_owner AS LEGAL_OWNER
 ,oa.processable_code AS PROCESSABLE_CODE
 ,oa.first_delivery_date AS FIRST_DELIVERY_DATE
 ,oa.bank_details_level_code AS BANK_DETAILS_LEVEL_CODE
 ,oa.last_delivery_date AS LAST_DELIVERY_DATE
 ,oa.document_handling_code AS DOCUMENT_HANDLING_CODE
 ,o.OBJECT_ID AS OBJECT_ID_FILTER1
 ,o.OBJECT_ID AS OBJECT_ID_FILTER2
 ,oa.production_day_id AS PRODUCTION_DAY_ID
 ,EC_PRODUCTION_DAY.object_code(oa.PRODUCTION_DAY_ID) AS PRODUCTION_DAY_CODE
 ,oa.company_id AS COMPANY_ID
 ,EC_COMPANY.object_code(oa.COMPANY_ID) AS COMPANY_CODE
 ,oa.parent_contract_id AS PARENT_CONTRACT_ID
 ,EC_CONTRACT.object_code(oa.PARENT_CONTRACT_ID) AS PARENT_CONTRACT_CODE
 ,oa.contract_area_id AS CONTRACT_AREA_ID
 ,EC_CONTRACT_AREA.object_code(oa.CONTRACT_AREA_ID) AS CONTRACT_AREA_CODE
 ,oa.pricing_currency_id AS PRICING_CURRENCY_ID
 ,EC_CURRENCY.object_code(oa.PRICING_CURRENCY_ID) AS PRICING_CURRENCY_CODE
 ,oa.memo_currency_id AS MEMO_CURRENCY_ID
 ,EC_CURRENCY.object_code(oa.MEMO_CURRENCY_ID) AS MEMO_CURRENCY_CODE
 ,oa.booking_currency_id AS BOOKING_CURRENCY_ID
 ,EC_CURRENCY.object_code(oa.BOOKING_CURRENCY_ID) AS BOOKING_CURRENCY_CODE
 ,oa.sa_day_calc_id AS SA_DAY_CALC_ID
 ,EC_CALCULATION.object_code(oa.SA_DAY_CALC_ID) AS SA_DAY_CALC_CODE
 ,oa.sa_mth_calc_id AS SA_MTH_CALC_ID
 ,EC_CALCULATION.object_code(oa.SA_MTH_CALC_ID) AS SA_MTH_CALC_CODE
 ,oa.sa_yr_calc_id AS SA_YR_CALC_ID
 ,EC_CALCULATION.object_code(oa.SA_YR_CALC_ID) AS SA_YR_CALC_CODE
 ,zv_fcst_dg_ref_total.DAYTIME AS DAYTIME
 ,zv_fcst_dg_ref_total.FORECAST_OBJECT_ID AS FORECAST_ID
 ,PRODUCTION_YEAR AS PRODUCTION_YEAR
 ,IS_SUMMARY AS IS_SUMMARY
 ,DELIVERY_POINT_CODE AS DELIVERY_POINT_CODE
 ,ROUND(NVL(ZV_FCST_DG_REF_TOTAL.AVG_EFFECTIVE_PI, 0),6) AS AVG_EFFECTIVE_PI
 ,CASE WHEN ec_contract_area.object_code(oa.contract_area_id) = 'CA_DOMGAS_EQUITY' THEN NVL(ZV_FCST_DG_REF_TOTAL.VALUE_2, 0) ELSE NULL END AS CAPACITY_ENT
 ,CASE WHEN ec_contract_area.object_code(oa.contract_area_id) = 'CA_DOMGAS_EQUITY' THEN NVL(ZV_FCST_DG_REF_TOTAL.VALUE_1, 0) ELSE NULL END AS DELIVERABILITY_ENT
 ,CASE WHEN ec_contract_area.object_code(oa.contract_area_id) = 'CA_WST_DOMGAS_SELLERS' THEN NVL(ZV_FCST_DG_REF_TOTAL.VALUE_2, 0) ELSE NULL END AS REFERENCE_ENT
 ,CASE WHEN ec_contract_area.object_code(oa.contract_area_id) = 'CA_DOMGAS_DELIVERY' THEN NVL(ZV_FCST_DG_REF_TOTAL.VALUE_2, 0) ELSE NULL END AS INSTALLED_CAPACITY
 ,CASE WHEN ec_contract_area.object_code(oa.contract_area_id) = 'CA_DOMGAS_DELIVERY' THEN NVL(ZV_FCST_DG_REF_TOTAL.VALUE_1, 0) ELSE NULL END AS MAX_DELIVERABILITY
 ,CASE WHEN ec_contract_area.object_code(ec_contract_version.contract_area_id(ZV_FCST_DG_REF_TOTAL.object_id, sysdate, '<=')) LIKE 'CA_DOMGAS%' THEN ZV_FCST_DG_REF_TOTAL.VALUE_4 ELSE NULL END AS JOINT_RESERVATION
 ,CASE WHEN ec_contract_area.object_code(ec_contract_version.contract_area_id(ZV_FCST_DG_REF_TOTAL.object_id, sysdate, '<=')) LIKE 'CA_DOMGAS%' THEN (NVL(ZV_FCST_DG_REF_TOTAL.VALUE_1, 0) - ZV_FCST_DG_REF_TOTAL.VALUE_4) ELSE NULL END AS NET_EQUITY_DEL
 ,CASE WHEN ec_contract_area.object_code(oa.contract_area_id) = 'CA_WST_DOMGAS_DELIVERY' THEN NVL(ZV_FCST_DG_REF_TOTAL.VALUE_2, 0) ELSE NULL END AS REFERENCE_PROD
 ,ecdp_contract_attribute.getAttributeString(o.object_id, 'NOM_UOM_1', ZV_FCST_DG_REF_TOTAL.daytime) AS DEFAULT_UOM
 ,CASE WHEN ec_contract_area.object_code(oa.contract_area_id) = 'CA_WST_DOMGAS_SELLERS' THEN NVL(ZV_FCST_DG_REF_TOTAL.VALUE_1, 0) ELSE NULL END AS REFERENCE_ENT_VOL
 ,CASE WHEN ec_contract_area.object_code(oa.contract_area_id) = 'CA_WST_DOMGAS_DELIVERY' THEN NVL(ZV_FCST_DG_REF_TOTAL.VALUE_1, 0) ELSE NULL END AS REFERENCE_PROD_VOL
 ,ecdp_contract_attribute.getAttributeString(o.object_id, 'NOM_UOM_2', ZV_FCST_DG_REF_TOTAL.daytime) AS VOLUME_UOM
 ,zv_fcst_dg_ref_total.RECORD_STATUS
 ,zv_fcst_dg_ref_total.CREATED_BY
 ,zv_fcst_dg_ref_total.CREATED_DATE
 ,zv_fcst_dg_ref_total.LAST_UPDATED_BY
 ,zv_fcst_dg_ref_total.LAST_UPDATED_DATE
 ,zv_fcst_dg_ref_total.REV_NO
 ,zv_fcst_dg_ref_total.REV_TEXT
,zv_fcst_dg_ref_total.APPROVAL_STATE AS APPROVAL_STATE
,zv_fcst_dg_ref_total.APPROVAL_BY AS APPROVAL_BY
,zv_fcst_dg_ref_total.APPROVAL_DATE AS APPROVAL_DATE
,zv_fcst_dg_ref_total.REC_ID AS REC_ID
FROM CONTRACT_VERSION oa, CONTRACT o, zv_fcst_dg_ref_total
WHERE oa.object_id = zv_fcst_dg_ref_total.object_id
AND zv_fcst_dg_ref_total.object_id =   o.object_id
AND zv_fcst_dg_ref_total.daytime >= TRUNC(oa.daytime,'YEAR')
AND oa.daytime = (
   SELECT MIN(daytime) FROM CONTRACT_VERSION oa2
   WHERE oa2.object_id = oa.object_id
   AND   zv_fcst_dg_ref_total.DAYTIME >= trunc(oa2.daytime,'YEAR')
AND zv_fcst_dg_ref_total.DAYTIME < nvl(oa2.end_date,zv_fcst_dg_ref_total.DAYTIME + 1))
AND ECDP_Objects.getObjCode(ZV_FCST_DG_REF_TOTAL.contract_area_id) IN ('CA_WST_DOMGAS_SELLERS', 'CA_WST_DOMGAS_DELIVERY', 'CA_DOMGAS_DELIVERY', 'CA_DOMGAS_EQUITY')
;
/