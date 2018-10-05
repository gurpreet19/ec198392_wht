CREATE OR REPLACE FORCE EDITIONABLE VIEW "V_DSF_DETAIL_CONT_DOC" ("REFERENCE_ID", "TYPE", "DIRECTION", "CA_CLASS", "CA_ATTRIBUTE", "OBJECT_ID", "PARAMETERS", "MAPPING_TYPE", "MAPPING_ID", "ID", "OTHER_TYPE", "OTHER_REF_ID", "BOOKING_VALUE", "BOOKING_CURRENCY", "QTY_1", "UOM1_CODE", "OTHER_ID", "OTHER_MAPPING_TYPE", "DAYTIME", "RECORD_STATUS", "CREATED_BY", "CREATED_DATE", "LAST_UPDATED_BY", "LAST_UPDATED_DATE", "REV_NO", "REV_TEXT", "TO_ID", "FROM_ID", "CONNECTION_ID", "COMMENTS", "PRODUCT_NAME") AS 
  SELECT
       doc.reference_id  reference_id,
       'CONT_DOCUMENT'  type,
       'IN' direction,
       ct.contract_account_class CA_CLASS,
       ct.contract_account CA_ATTRIBUTE,
       ct.OBJECT_ID,
       NULL PARAMETERS,
       dfdc.mapping_type,
       ct.trans_template_id mapping_id,
       ct.transaction_key || '$' ID,
       doc_conn.from_type other_type,
       doc_conn.from_reference_id other_ref_id,
       ct.TRANS_BOOKING_VALUE booking_Value,
       ec_cont_document.booking_currency_id(document_key) booking_currency,
       ec_cont_transaction_qty.NET_QTY1(transaction_key) qty_1,
       ec_cont_transaction_qty.UOM1_CODE(transaction_key) AS UOM1_CODE,
      substr(dfdc.from_id,0, instr(dfdc.from_id,'$',-1)-1) other_id,
       'CONTRACT_ACCOUNT' other_mapping_type,
       doc.process_date DAYTIME,
        to_char(null) record_status,
        to_char(null) created_by,
        to_date(null) created_date,
        to_char(null) last_updated_by,
        to_date(null) last_updated_date,
        to_number(null) rev_no,
        to_char(null) rev_text,
        dfdc.TO_ID,
        From_Id,
        dfdc.Connection_Id,
        ct.comments,
        ec_product_version.name(ct.product_id,ct.transaction_date,'<=') PRODUCT_NAME
FROM CONT_TRANSACTION ct,
       DATASET_FLOW_DETAIL_CONN dfdc,
       DATASET_FLOW_DOC_CONN doc_conn,
       DATASET_FLOW_DOCUMENT doc
 WHERE ct.transaction_key = dfdc.to_id
   and ct.document_key = doc.reference_id
   and doc_conn.to_TYPE = 'CONT_DOCUMENT'
   AND doc.reference_id = doc_conn.to_reference_id
   AND doc.type = doc_conn.to_type
   AND dfdc.connection_id = doc_conn.connection_id
   AND dfdc.mapping_type  like 'SCTR_ACC%'
UNION ALL
SELECT
       doc.reference_id  reference_id,
       'CONT_DOCUMENT'  type,
       'OUT' direction,
       'N/A' CA_CLASS,
       'n/a' CA_ATTRIBUTE,
       ct.OBJECT_ID,
       NULL PARAMETERS,
       dfdc.mapping_type,
       ct.trans_template_id mapping_id,
       ct.transaction_key || '$' ID,
       doc_conn.to_type other_type,
       doc_conn.to_reference_id other_ref_id,
       ct.TRANS_BOOKING_VALUE booking_Value,
       ec_cont_document.booking_currency_id(document_key) booking_currency,
       ec_cont_transaction_qty.NET_QTY1(transaction_key) qty_1,
       ec_cont_transaction_qty.UOM1_CODE(transaction_key) AS UOM1_CODE,
       dfdc.to_id other_id,
       'CONTRACT_ACCOUNT' other_mapping_type,
       doc.process_date DAYTIME,
        to_char(null) record_status,
        to_char(null) created_by,
        to_date(null) created_date,
        to_char(null) last_updated_by,
        to_date(null) last_updated_date,
        to_number(null) rev_no,
        to_char(null) rev_text,
        dfdc.TO_ID,
        From_Id,
        dfdc.Connection_Id,
        ct.comments,
        ec_product_version.name(ct.product_id,ct.transaction_date,'<=') PRODUCT_NAME
FROM CONT_TRANSACTION ct,
       DATASET_FLOW_DETAIL_CONN dfdc,
       DATASET_FLOW_DOC_CONN doc_conn,
       DATASET_FLOW_DOCUMENT doc
 WHERE ct.transaction_key = dfdc.FROM_id
   and ct.document_key = doc.reference_id
   and doc_conn.FROM_TYPE = 'CONT_DOCUMENT'
   AND doc.reference_id = doc_conn.from_reference_id
   AND doc.type = doc_conn.FROM_type
   AND dfdc.connection_id = doc_conn.connection_id
/*union all
SELECT
       ct.document_key  reference_id,
       'CONT_DOCUMENT'  type,
       'OUT' direction,
       'N/A-A' CA_CLASS,
       'n/a' CA_ATTRIBUTE,
       ct.OBJECT_ID,
       NULL PARAMETERS,
       dfdc.mapping_type,
       ct.trans_template_id mapping_id,
       ct.transaction_key || '$' ID,
       doc_conn.to_type other_type,
       doc.reference_id other_ref_id,
       ct.TRANS_BOOKING_VALUE booking_Value,
       ec_cont_document.booking_currency_id(document_key) booking_currency,
       ec_cont_transaction_qty.NET_QTY1(transaction_key) qty_1,
       ec_cont_transaction_qty.UOM1_CODE(transaction_key) AS UOM1_CODE,
       dfdc.to_id other_id,
       'CONTRACT_ACCOUNT' other_mapping_type,
       doc.process_date DAYTIME,
        to_char(null) record_status,
        to_char(null) created_by,
        to_date(null) created_date,
        to_char(null) last_updated_by,
        to_date(null) last_updated_date,
        to_number(null) rev_no,
        to_char(null) rev_text,
        dfdc.TO_ID,
        From_Id,
        dfdc.Connection_Id,
        ct.comments
FROM CONT_TRANSACTION ct,
       DATASET_FLOW_DETAIL_CONN dfdc,
       DATASET_FLOW_DOC_CONN doc_conn,
       DATASET_FLOW_DOCUMENT doc
 WHERE ct.transaction_key = dfdc.FROM_id
   and doc_conn.to_reference_id = doc.reference_id
   and doc_conn.FROM_TYPE = 'CONT_DOCUMENT'
   AND doc.type = doc_conn.to_type
   AND dfdc.connection_id = doc_conn.connection_id*/