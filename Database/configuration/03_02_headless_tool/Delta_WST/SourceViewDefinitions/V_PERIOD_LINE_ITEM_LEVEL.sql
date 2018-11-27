CREATE OR REPLACE FORCE EDITIONABLE VIEW "V_PERIOD_LINE_ITEM_LEVEL" ("TRANS_TEMP_ID", "PRODUCT_ID", "PRODUCT_CODE", "PRICE_OBJECT_ID", "PRICE_OBJECT_CODE", "DELIVERY_POINT_ID", "DELIVERY_POINT_CODE", "CUSTOMER_ID", "PRICE_CONCEPT_CODE", "QTY_STATUS", "DOC_STATUS", "UOM1_CODE", "UNIQUE_KEY_1", "UNIQUE_KEY_2", "IFAC_TT_CONN_CODE", "PERIOD_START_DATE", "PERIOD_END_DATE", "PROCESSING_PERIOD", "CONTRACT_ID", "CONTRACT_CODE", "DOC_SETUP_CODE", "DOC_SETUP_ID", "TRANS_TEMP_CODE", "PRECEDING_DOC_KEY", "PRECEDING_TRANS_KEY", "IGNORE_IND", "TRANSACTION_KEY", "ALLOC_NO_MAX_IND", "TRANS_KEY_SET_IND", "LINE_ITEM_CODE", "LINE_ITEM_BASED_TYPE", "LINE_ITEM_TEMPLATE_ID", "UNIT_PRICE_UNIT", "INT_TYPE", "INT_BASE_AMOUNT", "INT_COMPOUNDING_PERIOD", "INT_BASE_RATE", "INT_RATE_OFFSET", "INT_FROM_DATE", "INT_TO_DATE", "PERCENTAGE_VALUE", "PERCENTAGE_BASE_AMOUNT", "PRICING_VALUE", "LINE_ITEM_TYPE", "LINE_ITEM_KEY", "IFAC_LI_CONN_CODE", "PRECEDING_LI_KEY", "LI_PRICE_OBJECT_CODE", "LI_PRICE_OBJECT_ID", "REV_TEXT", "REV_NO", "LAST_UPDATED_DATE", "LAST_UPDATED_BY", "CREATED_DATE", "CREATED_BY", "RECORD_STATUS", "SAMPLE_SOURCE_ENTRY_NO", "TYPE") AS 
  SELECT  trans_temp_id
       ,product_id
       ,product_code
       ,price_object_id
       ,price_object_code
       ,delivery_point_id
       ,delivery_point_code
       ,customer_id
       ,price_concept_code
       ,qty_status
       ,doc_status
       ,uom1_code
       ,unique_key_1
       ,unique_key_2
       ,ifac_tt_conn_code
       ,period_start_date
       ,period_end_date
       ,processing_period
       ,contract_id
       ,contract_code
       ,doc_setup_code
       ,doc_setup_id
       ,trans_temp_code
       ,preceding_doc_key
       ,preceding_trans_key
       ,ignore_ind
       ,transaction_key
       ,alloc_no_max_ind
       ,trans_key_set_ind
       ,LINE_ITEM_CODE
       ,LINE_ITEM_BASED_TYPE
       ,LINE_ITEM_TEMPLATE_ID
       ,UNIT_PRICE_UNIT
       ,INT_TYPE
       ,INT_BASE_AMOUNT
       ,INT_COMPOUNDING_PERIOD
       ,INT_BASE_RATE
       ,INT_RATE_OFFSET
       ,INT_FROM_DATE
       ,INT_TO_DATE
       ,PERCENTAGE_VALUE
       ,PERCENTAGE_BASE_AMOUNT
       ,PRICING_VALUE
       ,LINE_ITEM_TYPE
       ,LINE_ITEM_KEY
       ,IFAC_LI_CONN_CODE
       ,PRECEDING_LI_KEY
--       ,LI_PRICE_CONCEPT_CODE
       ,LI_PRICE_OBJECT_CODE
       ,LI_PRICE_OBJECT_ID
       ,NULL AS rev_text
       ,NULL AS rev_no
       ,NULL AS last_updated_date
       ,NULL AS last_updated_by
       ,NULL AS created_date
       ,NULL AS created_by
       ,NULL AS record_status
       ,source_entry_no AS sample_source_entry_no   -- this is to get source_entry_no from any one record.
       ,'PERIOD' as "TYPE"
FROM ifac_sales_qty isq
WHERE
       trans_key_set_ind = 'N'
       AND alloc_no_max_ind = 'Y'
       AND ignore_ind = 'N'
       AND vendor_id IS NOT NULL
       AND customer_id IS NOT NULL
       AND profit_center_id IS NOT NULL
       AND product_id IS NOT NULL
       AND delivery_point_id IS NOT NULL
       AND source_entry_no in(
                              SELECT MAX(source_entry_no)
                              FROM ifac_sales_qty
                              WHERE customer_id = isq.customer_id
                                     AND product_id = isq.product_id
                                     AND nvl(delivery_point_id,'xxx') = nvl(isq.delivery_point_id,'xxx')
                                     AND NVL(price_object_id,'XX') = nvl(isq.price_object_id,NVL(price_object_id,'XX'))
                                     AND qty_status = isq.qty_status
                                     AND nvl(preceding_trans_key,'xxx') = nvl(isq.preceding_trans_key,'xxx')
                                     AND price_concept_code = isq.price_concept_code
                                     AND trans_key_set_ind = 'N'
                                     AND alloc_no_max_ind = 'Y'
                                     AND ignore_ind = 'N'
                                     AND nvl(doc_status,'FINAL')  = nvl(isq.doc_status,nvl(doc_status,'FINAL'))
                                     AND nvl(uom1_code,'XX') = nvl(isq.uom1_code,nvl(uom1_code,'XX'))
                                     AND period_start_date = isq.period_start_date
                                     AND period_end_date = isq.period_end_date
                                     AND processing_period = isq.processing_period
                                     AND doc_setup_id = isq.doc_setup_id
                                     AND trans_temp_id = isq.trans_temp_id
                                     AND nvl(unique_key_1,'xxx') = nvl(isq.unique_key_1,'xxx')
                                     AND nvl(unique_key_2,'xxx') = nvl(isq.unique_key_2,'xxx')
                                     AND line_item_based_type = isq.line_item_based_type
                             )