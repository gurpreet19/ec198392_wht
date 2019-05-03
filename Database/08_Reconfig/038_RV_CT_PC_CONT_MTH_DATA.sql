
  CREATE OR REPLACE VIEW "RV_CT_PC_CONT_MTH_DATA" ("DATA_CLASS_NAME", "OWNER_CLASS_NAME", "PRODUCTION_MTH", "OBJECT_ID", "CODE", "NAME", "OBJECT_START_DATE", "OBJECT_END_DATE", "DESCRIPTION", "COMMENTS", "COMPANY_NAME", "START_YEAR", "TRAN_IND", "SALE_IND", "REVN_IND", "BF_PROFILE", "TEMPLATE_CODE", "DAY_OFFSET_HOURS", "SORT_ORDER", "CALC_RULE_ID", "CALC_RULE_CODE", "CALC_SEQ_NO", "ACTIVE_CNTR_DAY", "CONTRACT_GROUP_CODE", "FINANCIAL_CODE", "PRODUCT_TYPE", "CONTRACT_TERM_CODE", "DIST_CLASS", "USE_DISTRIBUTION_IND", "PRICE_DECIMALS", "UOM1_TMPL", "UOM2_TMPL", "UOM3_TMPL", "UOM4_TMPL", "SYSTEM_OWNER", "CONTRACT_STAGE_CODE", "CONTRACT_RESPONSIBLE", "LEGAL_OWNER", "PROCESSABLE_CODE", "FIRST_DELIVERY_DATE", "BANK_DETAILS_LEVEL_CODE", "LAST_DELIVERY_DATE", "DOCUMENT_HANDLING_CODE", "OBJECT_ID_FILTER1", "OBJECT_ID_FILTER2", "PRODUCTION_DAY_ID", "PRODUCTION_DAY_CODE", "COMPANY_ID", "COMPANY_CODE", "PARENT_CONTRACT_ID", "PARENT_CONTRACT_CODE", "CONTRACT_AREA_ID", "CONTRACT_AREA_CODE", "PRICING_CURRENCY_ID", "PRICING_CURRENCY_CODE", "MEMO_CURRENCY_ID", "MEMO_CURRENCY_CODE", "BOOKING_CURRENCY_ID", "BOOKING_CURRENCY_CODE", "SA_DAY_CALC_ID", "SA_DAY_CALC_CODE", "SA_MTH_CALC_ID", "SA_MTH_CALC_CODE", "SA_YR_CALC_ID", "SA_YR_CALC_CODE", "DAYTIME", "OBJECT_CODE", "PROFIT_CENTRE_ID", "PROFIT_CENTRE_CODE", "CONFIRMED_EX_QTY", "EX_LIFT_ENERGY_PRORATE", "RECORD_STATUS", "CREATED_BY", "CREATED_DATE", "LAST_UPDATED_BY", "LAST_UPDATED_DATE", "REV_NO", "REV_TEXT", "APPROVAL_STATE", "APPROVAL_BY", "APPROVAL_DATE", "REC_ID") AS 
  SELECT
-- Generated by EcDp_GenClassCode 
 'CT_PC_CONT_MTH_DATA' AS DATA_CLASS_NAME
 ,'CONTRACT' AS OWNER_CLASS_NAME
 ,cv_dates_pc_contract.DAYTIME AS PRODUCTION_MTH
 ,cv_dates_pc_contract.OBJECT_ID AS OBJECT_ID
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
 ,cv_dates_pc_contract.DAYTIME AS DAYTIME
 ,cv_dates_pc_contract.OBJECT_CODE AS OBJECT_CODE
 ,cv_dates_pc_contract.PROFIT_CENTRE_ID AS PROFIT_CENTRE_ID
 ,cv_dates_pc_contract.PROFIT_CENTRE_CODE AS PROFIT_CENTRE_CODE
 ,UE_CT_UPG_MTH_ALLOC.CEQEnergyMonthTotal(CV_DATES_PC_CONTRACT.DAYTIME, CV_DATES_PC_CONTRACT.PROFIT_CENTRE_ID) AS CONFIRMED_EX_QTY
 ,UE_CT_UPG_MTH_ALLOC.LNGExLiftEnergyProRatedByPC(CV_DATES_PC_CONTRACT.DAYTIME, CV_DATES_PC_CONTRACT.PROFIT_CENTRE_ID) AS EX_LIFT_ENERGY_PRORATE
 ,cv_dates_pc_contract.RECORD_STATUS
 ,cv_dates_pc_contract.CREATED_BY
 ,cv_dates_pc_contract.CREATED_DATE
 ,cv_dates_pc_contract.LAST_UPDATED_BY
 ,cv_dates_pc_contract.LAST_UPDATED_DATE
 ,cv_dates_pc_contract.REV_NO
 ,cv_dates_pc_contract.REV_TEXT
,NULL AS APPROVAL_STATE
,NULL AS APPROVAL_BY
,NULL AS APPROVAL_DATE
,NULL AS REC_ID
FROM CONTRACT_VERSION oa, CONTRACT o, cv_dates_pc_contract
WHERE oa.object_id = cv_dates_pc_contract.object_id
AND cv_dates_pc_contract.object_id =   o.object_id
AND cv_dates_pc_contract.daytime >= TRUNC(oa.daytime,'MONTH')
AND oa.daytime = (
   SELECT MIN(daytime) FROM CONTRACT_VERSION oa2
   WHERE oa2.object_id = oa.object_id
   AND   cv_dates_pc_contract.DAYTIME >= trunc(oa2.daytime,'MONTH')
AND cv_dates_pc_contract.DAYTIME < nvl(oa2.end_date,cv_dates_pc_contract.DAYTIME + 1))
;
/