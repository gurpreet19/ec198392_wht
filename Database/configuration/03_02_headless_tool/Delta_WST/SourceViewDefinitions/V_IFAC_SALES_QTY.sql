CREATE OR REPLACE FORCE EDITIONABLE VIEW "V_IFAC_SALES_QTY" ("SOURCE_ENTRY_NO", "CONTRACT_ID", "CONTRACT_CODE", "PROFIT_CENTER_ID", "PROFIT_CENTER_CODE", "PRICE_CONCEPT_CODE", "DELIVERY_POINT_ID", "DELIVERY_POINT_CODE", "PRODUCT_ID", "PRODUCT_CODE", "VENDOR_ID", "VENDOR_CODE", "CUSTOMER_ID", "CUSTOMER_CODE", "PROCESSING_PERIOD", "PERIOD_START_DATE", "PERIOD_END_DATE", "ALLOC_NO", "ALLOC_NO_MAX_IND", "TRANSACTION_KEY", "TRANS_KEY_SET_IND", "PRECEDING_DOC_KEY", "PRECEDING_TRANS_KEY", "DOC_SETUP_ID", "DOC_SETUP_CODE", "TRANS_TEMP_ID", "TRANS_TEMP_CODE", "IGNORE_IND", "PRICE_DATE", "PRICE_OBJECT_CODE", "PRICE_OBJECT_ID", "PRICE_STATUS", "SALES_ORDER", "UNIT_PRICE", "SOURCE_NODE_CODE", "SOURCE_NODE_ID", "UNIQUE_KEY_1", "UNIQUE_KEY_2", "LI_UNIQUE_KEY_1", "LI_UNIQUE_KEY_2", "IFAC_TT_CONN_CODE", "IFAC_LI_CONN_CODE", "VAT_CODE", "QTY1", "UOM1_CODE", "QTY2", "UOM2_CODE", "QTY3", "UOM3_CODE", "QTY4", "UOM4_CODE", "QTY5", "UOM5_CODE", "QTY6", "UOM6_CODE", "DOC_STATUS", "QTY_STATUS", "STATUS", "DESCRIPTION", "DATE_1", "DATE_2", "DATE_3", "DATE_4", "DATE_5", "DATE_6", "DATE_7", "DATE_8", "DATE_9", "DATE_10", "TEXT_1", "TEXT_2", "TEXT_3", "TEXT_4", "TEXT_5", "TEXT_6", "TEXT_7", "TEXT_8", "TEXT_9", "TEXT_10", "VALUE_1", "VALUE_2", "VALUE_3", "VALUE_4", "VALUE_5", "VALUE_6", "VALUE_7", "VALUE_8", "VALUE_9", "VALUE_10", "REF_OBJECT_ID_1", "REF_OBJECT_ID_2", "REF_OBJECT_ID_3", "REF_OBJECT_ID_4", "REF_OBJECT_ID_5", "REF_OBJECT_ID_6", "REF_OBJECT_ID_7", "REF_OBJECT_ID_8", "REF_OBJECT_ID_9", "REF_OBJECT_ID_10", "RECORD_STATUS", "CREATED_BY", "CREATED_DATE", "LAST_UPDATED_BY", "LAST_UPDATED_DATE", "REV_NO", "REV_TEXT", "APPROVAL_BY", "APPROVAL_DATE", "APPROVAL_STATE", "REC_ID", "OBJECT_TYPE", "DIST_TYPE", "LINE_ITEM_BASED_TYPE", "PRICING_VALUE", "LINE_ITEM_TYPE", "INT_FROM_DATE", "INT_TO_DATE", "PERCENTAGE_VALUE", "PERCENTAGE_BASE_AMOUNT", "INT_BASE_RATE", "INT_RATE_OFFSET", "UNIT_PRICE_UNIT", "INT_TYPE", "INT_BASE_AMOUNT", "INT_COMPOUNDING_PERIOD", "LINE_ITEM_KEY", "LI_PRICE_OBJECT_CODE", "LI_PRICE_OBJECT_ID", "CONTRACT_ACCOUNT_CLASS", "CALC_RUN_NO", "CONTRACT_ACCOUNT") AS 
  SELECT isq.source_entry_no,
         isq.contract_id,
         isq.contract_code,
         isq.profit_center_id,
         isq.profit_center_code,
         isq.price_concept_code,
         isq.delivery_point_id,
         isq.delivery_point_code,
         isq.product_id,
         isq.product_code,
         isq.vendor_id,
         isq.vendor_code,
         isq.customer_id,
         isq.customer_code,
         isq.processing_period,
         isq.period_start_date,
         isq.period_end_date,
         isq.alloc_no,
         isq.alloc_no_max_ind,
         isq.transaction_key,
         isq.trans_key_set_ind,
         isq.preceding_doc_key,
         isq.preceding_trans_key,
         isq.doc_setup_id,
         isq.doc_setup_code,
         isq.trans_temp_id,
         isq.trans_temp_code,
         isq.ignore_ind,
         isq.price_date,
         isq.price_object_code,
         isq.price_object_id,
         isq.price_status,
         isq.sales_order,
         isq.unit_price,
         isq.source_node_code,
         isq.source_node_id,
         isq.unique_key_1,
         isq.unique_key_2,
         isq.li_unique_key_1,
         isq.li_unique_key_2,
         isq.ifac_tt_conn_code,
         isq.ifac_li_conn_code,
         isq.vat_code,
         isq.qty1,
         isq.uom1_code,
         isq.qty2,
         isq.uom2_code,
         isq.qty3,
         isq.uom3_code,
         isq.qty4,
         isq.uom4_code,
         isq.qty5,
         isq.uom5_code,
         isq.qty6,
         isq.uom6_code,
         isq.doc_status,
         isq.qty_status,
         isq.status,
         isq.description,
         isq.date_1,
         isq.date_2,
         isq.date_3,
         isq.date_4,
         isq.date_5,
         isq.date_6,
         isq.date_7,
         isq.date_8,
         isq.date_9,
         isq.date_10,
         isq.text_1,
         isq.text_2,
         isq.text_3,
         isq.text_4,
         isq.text_5,
         isq.text_6,
         isq.text_7,
         isq.text_8,
         isq.text_9,
         isq.text_10,
         isq.value_1,
         isq.value_2,
         isq.value_3,
         isq.value_4,
         isq.value_5,
         isq.value_6,
         isq.value_7,
         isq.value_8,
         isq.value_9,
         isq.value_10,
         isq.ref_object_id_1,
         isq.ref_object_id_2,
         isq.ref_object_id_3,
         isq.ref_object_id_4,
         isq.ref_object_id_5,
         isq.ref_object_id_6,
         isq.ref_object_id_7,
         isq.ref_object_id_8,
         isq.ref_object_id_9,
         isq.ref_object_id_10,
         isq.record_status,
         isq.created_by,
         isq.created_date,
         isq.last_updated_by,
         isq.last_updated_date,
         isq.rev_no,
         isq.rev_text,
         isq.approval_by,
         isq.approval_date,
         isq.approval_state,
         isq.rec_id,
         isq.object_type,
         isq.dist_type,
         isq.line_item_based_type,
         isq.pricing_value,
         isq.line_item_type,
         isq.int_from_date,
         isq.int_to_date,
         isq.percentage_value,
         isq.percentage_base_amount,
         isq.int_base_rate,
         isq.int_rate_offset,
         isq.unit_price_unit,
         isq.int_type,
         isq.int_base_amount,
         isq.int_compounding_period,
         isq.line_item_key,
         isq.li_price_object_code,
         isq.li_price_object_id,
         isq.contract_account_class,
         isq.calc_run_no,
         isq.contract_account
    FROM ifac_sales_qty isq