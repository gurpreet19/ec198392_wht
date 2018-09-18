CREATE OR REPLACE FORCE EDITIONABLE VIEW "V_CARGO_LINE_ITEM_LEVEL" ("NET_QTY1", "GRS_QTY1", "UOM1_CODE", "NET_QTY2", "GRS_QTY2", "UOM2_CODE", "NET_QTY3", "UOM3_CODE", "NET_QTY4", "UOM4_CODE", "CONTRACT_CODE", "CONTRACT_ID", "VENDOR_ID", "CUSTOMER_ID", "DOC_SETUP_ID", "CARGO_NO", "PARCEL_NO", "VENDOR_CODE", "CUSTOMER_CODE", "QTY_TYPE", "PROFIT_CENTER_CODE", "PROFIT_CENTER_ID", "ALLOC_NO", "SO_NUMBER", "PRICE_CONCEPT_CODE", "PRODUCT_ID", "PRICE_OBJECT_ID", "LOADING_PORT_ID", "DISCHARGE_PORT_ID", "LOADING_COMM_DATE", "LOADING_DATE", "DELIVERY_COMM_DATE", "DELIVERY_DATE", "POINT_OF_SALE_DATE", "BL_DATE", "PRICE_DATE", "PRICE_OBJECT_CODE", "PRICE_STATUS", "DISCHARGE_BERTH_CODE", "LOADING_BERTH_CODE", "DISCHARGE_PORT_CODE", "LOADING_PORT_CODE", "CONSIGNOR_CODE", "CONSIGNEE_CODE", "CARRIER_CODE", "VOYAGE_NO", "PRODUCT_CODE", "STATUS", "DESCRIPTION", "DOC_SETUP_CODE", "PRECEDING_DOC_KEY", "SOURCE_NODE_CODE", "TRANS_TEMP_CODE", "UNIT_PRICE", "DOC_STATUS", "PRODUCT_SALES_ORDER_ID", "PRODUCT_SALES_ORDER_CODE", "CARRIER_ID", "CONSIGNOR_ID", "CONSIGNEE_ID", "SOURCE_ENTRY_NO", "SOURCE_NODE_ID", "TRANS_TEMP_ID", "VAT_CODE", "IFAC_TT_CONN_CODE", "RECORD_STATUS", "CREATED_BY", "CREATED_DATE", "LAST_UPDATED_BY", "LAST_UPDATED_DATE", "REV_NO", "REV_TEXT", "LINE_ITEM_CODE", "LINE_ITEM_BASED_TYPE", "LINE_ITEM_TEMPLATE_ID", "UNIT_PRICE_UNIT", "INT_TYPE", "INT_BASE_AMOUNT", "INT_COMPOUNDING_PERIOD", "INT_BASE_RATE", "INT_RATE_OFFSET", "INT_FROM_DATE", "INT_TO_DATE", "PERCENTAGE_VALUE", "PERCENTAGE_BASE_AMOUNT", "PRICING_VALUE", "LINE_ITEM_TYPE", "LINE_ITEM_KEY", "IFAC_LI_CONN_CODE", "PRECEDING_LI_KEY", "LI_PRICE_OBJECT_CODE", "LI_PRICE_OBJECT_ID", "SAMPLE_SOURCE_ENTRY_NO", "TYPE") AS 
  SELECT
    sm.net_qty1
    ,sm.grs_qty1
    ,sm.uom1_code
    ,sm.net_qty2
    ,sm.grs_qty2
    ,sm.uom2_code
    ,sm.net_qty3
    ,sm.uom3_code
    ,sm.net_qty4
    ,sm.uom4_code
    ,sm.contract_code
    ,sm.contract_id
    ,sm.vendor_id
    ,sm.customer_id
    ,sm.doc_setup_id
    ,sm.cargo_no
    ,sm.parcel_no
    ,sm.vendor_code
    ,sm.customer_code
    ,sm.qty_type
    ,sm.profit_center_code
    ,sm.profit_center_id
    ,sm.alloc_no
    ,sm.so_number
    ,sm.price_concept_code
    ,sm.product_id
    ,sm.price_object_id
    ,sm.loading_port_id
    ,sm.discharge_port_id
    ,sm.loading_comm_date
    ,sm.loading_date
    ,sm.delivery_comm_date
    ,sm.delivery_date
    ,sm.point_of_sale_date
    ,sm.bl_date
    ,sm.price_date
    ,sm.price_object_code
    ,sm.price_status
    ,sm.discharge_berth_code
    ,sm.loading_berth_code
    ,sm.discharge_port_code
    ,sm.loading_port_code
    ,sm.consignor_code
    ,sm.consignee_code
    ,sm.carrier_code
    ,sm.voyage_no
    ,sm.product_code
    ,sm.status
    ,sm.description
    ,sm.doc_setup_code
    ,sm.preceding_doc_key
    ,sm.source_node_code
    ,sm.trans_temp_code
    ,sm.unit_price
    ,sm.doc_status
    ,sm.product_sales_order_id
    ,sm.product_sales_order_code
    ,sm.carrier_id
    ,sm.consignor_id
    ,sm.consignee_id
    ,sm.source_entry_no
    ,sm.source_node_id
    ,sm.trans_temp_id
    ,sm.vat_code
    ,sm.ifac_tt_conn_code
    ,sm.record_status
    ,sm.created_by
    ,sm.created_date
    ,sm.last_updated_by
    ,sm.last_updated_date
    ,sm.rev_no
    ,sm.rev_text
    ,sm.Line_Item_Code
    ,sm.Line_Item_Based_Type
    ,sm.Line_Item_Template_Id
    ,sm.unit_price_unit
    ,sm.Int_Type
    ,sm.Int_Base_Amount
    ,sm.Int_Compounding_Period
    ,sm.Int_Base_Rate
    ,sm.Int_Rate_Offset
    ,sm.Int_From_Date
    ,sm.Int_To_Date
    ,sm.Percentage_Value
    ,sm.Percentage_Base_Amount
    ,sm.Pricing_Value
    ,sm.Line_Item_Type
    ,sm.Line_Item_Key
    ,sm.Ifac_Li_Conn_Code
    ,sm.Preceding_Li_Key
    --,sm.Li_Price_Concept_Code
    ,sm.Li_Price_Object_Code
    ,sm.Li_Price_Object_Id
    ,sm.source_entry_no AS sample_source_entry_no,   -- this is to get source_entry_no from any one record.
    'CARGO' as "TYPE"
FROM ifac_cargo_value sm
WHERE sm.trans_key_set_ind = 'N'
   AND sm.alloc_no_max_ind = 'Y'
   AND sm.ignore_ind = 'N'
   AND NOT EXISTS (SELECT 1 -- Will exclude result if a higher allocation exists (means that the record with lower alloc_no is invalid)
                   FROM ifac_cargo_value sm3
                   WHERE sm3.contract_id = sm.contract_id
                      AND sm3.vendor_id = sm.vendor_id
                      AND NVL(sm3.customer_id, '$NULL$') = NVL(sm.customer_id, '$NULL$')
                      AND sm3.cargo_no = sm.cargo_no
                      AND sm3.parcel_no = sm.parcel_no
                      AND sm3.qty_type = sm.qty_type
                      AND sm3.profit_center_id = sm.profit_center_id
                      AND sm3.price_concept_code = sm.price_concept_code
                      AND sm3.product_id = sm.product_id
                      AND sm3.uom1_code = sm.uom1_code
                      AND NVL(sm3.price_object_id,'X') = NVL(sm.price_object_id,'X')
                      AND NVL(sm3.ifac_tt_conn_code, 'X') = NVL(sm.ifac_tt_conn_code, 'X')
                      AND sm3.alloc_no > sm.alloc_no)
   AND source_entry_no in(SELECT MAX(source_entry_no) -- Will limit so only one per transaction
                          FROM ifac_cargo_value sm3
                          WHERE sm3.contract_id = sm.contract_id
                            AND NVL(sm3.customer_id, '$NULL$') = NVL(sm.customer_id, '$NULL$')
                            AND sm3.cargo_no = sm.cargo_no
                            AND sm3.parcel_no = sm.parcel_no
                            AND sm3.qty_type = sm.qty_type
                            AND sm3.price_concept_code = sm.price_concept_code
                            AND sm3.product_id = sm.product_id
                            AND nvl(sm3.uom1_code,'XX') = nvl(sm.uom1_code,nvl(sm3.uom1_code,'XX'))
                            AND nvl(sm3.doc_status,'FINAL')  = nvl(sm.doc_status,nvl(sm3.doc_status,'FINAL'))
                            AND sm3.Trans_Temp_Id = sm.Trans_Temp_Id
                            AND NVL(sm3.Price_Object_Id,'XX') = nvl(sm.Price_Object_Id,NVL(sm3.Price_Object_Id,'XX'))
                            AND nvl(sm3.preceding_doc_key,'X') = nvl(sm.preceding_doc_key,'X')
                            AND NVL(sm3.Doc_Status,'X') = NVL(sm.Doc_Status,'X')
                            AND NVL(sm3.ifac_tt_conn_code, 'X') = NVL(sm.ifac_tt_conn_code, 'X')
                            AND sm3.line_item_based_type = sm.line_item_based_type
  )