CREATE OR REPLACE FORCE EDITIONABLE VIEW "V_PERIOD_MTH_CONTRACT" ("QTY1", "UOM1_CODE", "QTY2", "UOM2_CODE", "QTY3", "UOM3_CODE", "QTY4", "UOM4_CODE", "PROFIT_CENTER_ID", "PRICE_CONCEPT_CODE", "PRODUCT_ID", "DELIVERY_POINT_ID", "CONTRACT_ID", "DOC_SETUP_ID", "VENDOR_ID", "CUSTOMER_ID", "QTY_STATUS", "PROCESSING_PERIOD", "PRICE_OBJECT_ID", "UNIT_PRICE", "UNIQUE_KEY_1", "UNIQUE_KEY_2", "PERIOD_START_DATE", "PERIOD_END_DATE", "DOC_STATUS", "SOURCE_ENTRY_NO", "SOURCE_NODE_ID", "VAT_CODE", "IFAC_TT_CONN_CODE") AS 
  SELECT
     sm.qty1
    ,sm.uom1_code
    ,sm.qty2
    ,sm.uom2_code
    ,sm.qty3
    ,sm.uom3_code
    ,sm.qty4
    ,sm.uom4_code
    ,sm.profit_center_id
    ,sm.price_concept_code
    ,sm.product_id
    ,sm.delivery_point_id
    ,sm.contract_id
    ,sm.doc_setup_id
    ,sm.Vendor_Id
    ,sm.Customer_Id
    ,sm.qty_status
    ,sm.Processing_Period
    ,sm.price_object_id
    ,sm.unit_price
    ,sm.unique_key_1
    ,sm.unique_key_2
    ,sm.period_start_date
    ,sm.period_end_date
    ,sm.doc_status
    ,sm.source_entry_no
    ,sm.source_node_id
    ,sm.vat_code
    ,sm.ifac_tt_conn_code
  FROM ifac_sales_qty sm
WHERE sm.trans_key_set_ind = 'N'
   AND sm.alloc_no_max_ind = 'Y'
   AND sm.ignore_ind = 'N'
   AND NOT EXISTS (SELECT 1 -- Will exclude result if a higher allocation exists (means that the record with lower alloc_no is invalid)
                     FROM ifac_sales_qty sm3
                    WHERE sm3.price_concept_code = sm.price_concept_code
                      AND sm3.product_id = sm.product_id
                      AND sm3.delivery_point_id = sm.delivery_point_id
                      AND sm3.Processing_Period = sm.Processing_Period
                      AND sm3.contract_id = sm.contract_id
                      AND sm3.profit_center_id = sm.profit_center_id
                      AND sm3.vendor_id = sm.vendor_id
                      AND NVL(sm3.customer_id, '$NULL$') = NVL(sm.customer_id, '$NVL$')
                      AND sm3.qty_status = sm.qty_status
                      AND sm3.uom1_code = sm.uom1_code
                      AND NVL(sm3.price_object_id, 'X') = NVL(sm.price_object_id, 'X')
                      AND NVL(sm3.unique_key_1, 'X') = NVL(sm.unique_key_1, 'X')
                      AND NVL(sm3.unique_key_2, 'X') = NVL(sm.unique_key_2, 'X')
                      AND NVL(sm3.ifac_tt_conn_code, 'X') = NVL(sm.ifac_tt_conn_code, 'X')
                      AND sm3.period_start_date = sm.period_start_date
                      AND sm3.period_end_date = sm.period_end_date
                      AND sm3.alloc_no > sm.alloc_no)