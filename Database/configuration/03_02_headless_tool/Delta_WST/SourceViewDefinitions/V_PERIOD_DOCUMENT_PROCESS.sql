CREATE OR REPLACE FORCE EDITIONABLE VIEW "V_PERIOD_DOCUMENT_PROCESS" ("PROCESSING_PERIOD", "PERIOD_START_DATE", "PERIOD_END_DATE", "CONTRACT_ID", "CONTRACT_CODE", "CONTRACT_NAME", "DOC_SETUP_ID", "FINANCIAL_CODE", "CONTRACT_AREA_CODE", "CONTRACT_AREA_ID", "BUSINESS_UNIT_CODE", "BUSINESS_UNIT_ID", "PRICING_CURRENCY_ID", "CUSTOMER_ID", "DOC_DATE", "DOC_STATUS", "ACTION", "PREC_DOC_KEY", "DELIVERY_POINT_ID", "SOURCE_NODE_ID", "SOURCE_ENTRY_NO", "RECORD_STATUS", "CREATED_BY", "CREATED_DATE", "LAST_UPDATED_BY", "LAST_UPDATED_DATE", "REV_NO", "REV_TEXT", "APPROVAL_STATE", "APPROVAL_BY", "APPROVAL_DATE", "REC_ID") AS 
  SELECT isqs.processing_period,
         isqs.period_start_date,
         isqs.period_end_date,
         isqs.contract_id contract_id,
         c.code contract_code,
         c.name contract_name,
         isqs.doc_setup_id,
         c.financial_code financial_code,
         ca.code contract_area_code,
         c.contract_area_id,
         ec_business_unit.object_code(ca.business_unit_id) business_unit_code,
         ca.business_unit_id,
         c.pricing_currency_id pricing_currency_id,
         isqs.customer_id,
         trunc((CASE WHEN isqs.preceding_doc_key IS NULL THEN nvl(isqs.processing_period, Ecdp_Timestamp.getCurrentSysdate())
                     ELSE greatest(isqs.processing_period, ec_cont_document.daytime(isqs.preceding_doc_key)) END), 'DD') doc_date,
         isqs.doc_status,
         ecdp_document_gen_util.getperioddocaction(isqs.contract_id, isqs.doc_setup_id, isqs.customer_id, isqs.processing_period, isqs.preceding_doc_key,isqs.doc_status) action,
         isqs.preceding_doc_key prec_doc_key,
         isqs.delivery_point_id,
         isqs.source_node_id,
         isqs.source_entry_no,
         NULL AS RECORD_STATUS,
         NULL AS CREATED_BY,
         NULL AS CREATED_DATE,
         NULL AS LAST_UPDATED_BY,
         NULL AS LAST_UPDATED_DATE,
         NULL AS REV_NO,
         NULL AS REV_TEXT,
         NULL AS APPROVAL_STATE,
         NULL AS APPROVAL_BY,
         NULL AS APPROVAL_DATE,
         NULL AS REC_ID
    FROM (SELECT DISTINCT isq.contract_id,
                          isq.doc_setup_id,
                          isq.processing_period,
                          isq.preceding_doc_key,
                          isq.doc_status,
                          trunc(isq.period_start_date,'MM') period_start_date,
                          add_months(trunc(isq.period_end_date,'MM'),1)-1 period_end_date,
                          isq.customer_id,
                          NULL                  delivery_point_id, -- isq.delivery_point_id,
                          NULL                  source_node_id, -- isq.source_node_id
                          MAX(source_entry_no) OVER (PARTITION BY contract_id,doc_setup_id,processing_period,doc_status,customer_id) source_entry_no
            FROM ifac_sales_qty isq
           WHERE isq.alloc_no_max_ind = 'Y'
             AND isq.ignore_ind = 'N'
             AND isq.trans_key_set_ind = 'N'
             AND isq.processing_period >= add_months(trunc(Ecdp_Timestamp.getCurrentSysdate,'MM'), (NVL(ec_ctrl_system_attribute.attribute_value(trunc(Ecdp_Timestamp.getCurrentSysdate,'MM'), 'DOC_GEN_MONTHS', '<='), 120)*-1))
             AND isq.delivery_point_id IS NOT NULL
             AND isq.profit_center_id IS NOT NULL
             AND isq.product_id IS NOT NULL
             AND isq.vendor_id IS NOT NULL
             AND NVL(ec_contract_doc_version.doc_concept_code(isq.doc_setup_id, isq.processing_period, '<='),'X') != 'MULTI_PERIOD'
             ) isqs,
         ov_contract c,
         ov_contract_area ca,
         ov_business_unit bu
   WHERE isqs.contract_id = c.object_id
        -- Resolving contract
--     AND c.object_id = nvl(p_contract_id, c.object_id)
     AND c.daytime <= isqs.processing_period
     AND nvl(c.end_date, isqs.processing_period + 1) > isqs.processing_period
        -- Resolving contract area
     AND c.contract_area_id = ca.object_id
--     AND ca.object_id = nvl(p_contract_area_id, ca.object_id)
     AND ca.daytime <= isqs.processing_period
     AND nvl(ca.end_date, isqs.processing_period + 1) > isqs.processing_period
        -- Resolving business unit
     AND ca.business_unit_id = bu.object_id
--     AND bu.object_id = nvl(p_business_unit_id, bu.object_id)
     AND bu.daytime <= isqs.processing_period
     AND nvl(bu.end_date, isqs.processing_period + 1) > isqs.processing_period
UNION
-- MPD Specific part:
  SELECT
         isqs.processing_period,
         isqs.period_start_date,
         isqs.period_end_date,
         isqs.contract_id contract_id,
         c.code contract_code,
         c.name contract_name,
         isqs.doc_setup_id,
         c.financial_code financial_code,
         ca.code contract_area_code,
         c.contract_area_id,
         ec_business_unit.object_code(ca.business_unit_id) business_unit_code,
         ca.business_unit_id,
         c.pricing_currency_id pricing_currency_id,
         isqs.customer_id,
         trunc((case when decode(isqs.preceding_doc_key,'MULTIPLE',NULL,isqs.preceding_doc_key) is null then NVL(isqs.processing_period, Ecdp_Timestamp.getCurrentSysdate()) else greatest(isqs.processing_period, ec_cont_document.daytime(isqs.preceding_doc_key)) end), 'DD') doc_date,
         isqs.doc_status,
         ecdp_document_gen_util.getperioddocaction(isqs.contract_id, isqs.doc_setup_id, isqs.customer_id, isqs.processing_period,
         isqs.preceding_doc_key,
         isqs.doc_status) action,
         'MULTIPLE' prec_doc_key,
         isqs.delivery_point_id,
         isqs.source_node_id,
         isqs.source_entry_no,
         NULL AS RECORD_STATUS,
         NULL AS CREATED_BY,
         NULL AS CREATED_DATE,
         NULL AS LAST_UPDATED_BY,
         NULL AS LAST_UPDATED_DATE,
         NULL AS REV_NO,
         NULL AS REV_TEXT,
         NULL AS APPROVAL_STATE,
         NULL AS APPROVAL_BY,
         NULL AS APPROVAL_DATE,
         NULL AS REC_ID
    FROM (SELECT
                isq.contract_id,
                isq.doc_setup_id,
                isq.processing_period,
                MAX(isq.preceding_doc_key) preceding_doc_key,
                isq.doc_status,
                MIN(trunc(isq.period_start_date,'MM')) period_start_date,
                MAX(add_months(trunc(isq.period_end_date,'MM'),1)-1) period_end_date,
                isq.customer_id,
                NULL delivery_point_id, -- isq.delivery_point_id,
                NULL source_node_id, -- isq.source_node_id,
                MAX(source_entry_no) source_entry_no,
                min(created_date) created_date
            FROM ifac_sales_qty isq
           WHERE isq.alloc_no_max_ind = 'Y'
             AND isq.ignore_ind = 'N'
             AND isq.trans_key_set_ind = 'N'
             AND isq.processing_period >= add_months(trunc(Ecdp_Timestamp.getCurrentSysdate,'MM'), (NVL(ec_ctrl_system_attribute.attribute_value(trunc(Ecdp_Timestamp.getCurrentSysdate,'MM'), 'DOC_GEN_MONTHS', '<='), 120)*-1))
             AND isq.delivery_point_id IS NOT NULL
             AND isq.profit_center_id IS NOT NULL
             AND isq.product_id IS NOT NULL
             AND isq.vendor_id IS NOT NULL
             AND NVL(ec_contract_doc_version.doc_concept_code(isq.doc_setup_id, isq.processing_period, '<='),'X') = 'MULTI_PERIOD'
             GROUP BY
                    isq.contract_id,
                    isq.doc_setup_id,
                    isq.processing_period,
                    isq.doc_status,
                    isq.customer_id
                    ) isqs,
         ov_contract c,
         ov_contract_area ca,
         ov_business_unit bu
   WHERE isqs.contract_id = c.object_id
        -- Resolving contract
--     AND c.object_id = nvl(p_contract_id, c.object_id)
     AND c.daytime <= isqs.processing_period
     AND nvl(c.end_date, isqs.processing_period + 1) > isqs.processing_period
        -- Resolving contract area
     AND c.contract_area_id = ca.object_id
--     AND ca.object_id = nvl(p_contract_area_id, ca.object_id)
     AND ca.daytime <= isqs.processing_period
     AND nvl(ca.end_date, isqs.processing_period + 1) > isqs.processing_period
        -- Resolving business unit
     AND ca.business_unit_id = bu.object_id
--     AND bu.object_id = nvl(p_business_unit_id, bu.object_id)
     AND bu.daytime <= isqs.processing_period
     AND nvl(bu.end_date, isqs.processing_period + 1) > isqs.processing_period
   -- Must take old periods on same contract first to eliminate cases of multiple processing periods for same contract
   ORDER BY contract_id, processing_period,prec_doc_key, created_date