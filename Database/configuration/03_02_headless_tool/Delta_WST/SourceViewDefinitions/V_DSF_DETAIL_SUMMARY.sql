CREATE OR REPLACE FORCE EDITIONABLE VIEW "V_DSF_DETAIL_SUMMARY" ("REFERENCE_ID", "TYPE", "DIRECTION", "CA_CLASS", "OBJECT_ID", "QTY_1", "AMOUNT", "QTY_1_ADJ", "AMOUNT_ADJ", "LIST_ITEM_KEY", "DATASET", "ID", "MAPPING_TYPE", "MAPPING_ID", "DAYTIME", "OTHER_TYPE", "OTHER_REF_ID", "OTHER_MAPPING_TYPE", "OTHER_ID", "RECORD_STATUS", "CREATED_BY", "CREATED_DATE", "LAST_UPDATED_BY", "LAST_UPDATED_DATE", "REV_NO", "REV_TEXT", "TO_ID", "FROM_ID", "CONNECTION_ID", "COMMENTS") AS 
  SELECT
       doc.reference_id,
       doc.type,
       'OUT' direction,
       'CONT_JOURNAL_SUMMARY' CA_CLASS,
       --ATTRIBUTE CA_ATTRIBUTE,
       doc.object OBJECT_ID,
       cjs.Actual_Qty_1 QTY_1,
       cjs.Actual_Amount Amount,
       cjs.Qty_Adjustment QTY_1_ADJ,
       cjs.Amount_Adjustment Amount_ADJ,
       cjs.list_item_key,
       doc.dataset,
      dfdc.from_id ||'$' id,
       mapping_type,
       dfdc.mapping_id,
       doc.process_date DAYTIME,
       doc_conn.to_type other_type,
       doc_conn.to_reference_id other_ref_id,
       mapping_type other_mapping_type,
       dfdc.to_id ||'$' other_id,
        to_char(null) record_status,
        to_char(null) created_by,
        to_date(null) created_date,
        to_char(null) last_updated_by,
        to_date(null) last_updated_date,
        to_number(null) rev_no,
        to_char(null) rev_text,
        dfdc.TO_ID,
        dfdc.From_Id,
        dfdc.Connection_Id,
        dfdc.comments
  FROM CONT_JOURNAL_SUMMARY cjs,
       DATASET_FLOW_DETAIL_CONN dfdc,
       DATASET_FLOW_DOC_CONN doc_conn,
       DATASET_FLOW_DOCUMENT doc
 WHERE doc.type = 'CONT_JOURNAL_SUMMARY'
   AND doc.reference_id = doc_conn.from_reference_id
   AND doc.type = doc_conn.from_type
   AND dfdc.connection_id = doc_conn.connection_id
   AND dfdc.mapping_type IN ( 'EQUATION','TI_LINE_PROD_EXT')
   AND to_char(cjs.tag) = dfdc.from_id
   AND cjs.document_key= doc.reference_id
UNION ALL
SELECT
       distinct
       doc.reference_id,
       doc.type,
       'IN' direction,
       DECODE(MAPPING_TYPE,'EQUATION','CALC_REF','CONT_JOURNAL_ENTRY') CA_CLASS,
       --ATTRIBUTE CA_ATTRIBUTE,
       doc.object OBJECT_ID,
       cjs.Actual_Qty_1 QTY_1,
       cjs.Actual_Amount Amount,
       cjs.Qty_Adjustment QTY_1_ADJ,
       cjs.Amount_Adjustment Amount_ADJ,
       cjs.list_item_key,
       doc.dataset,
       dfdc.to_id||'$' id,
       mapping_type,
       dfdc.mapping_id,
       doc.process_date DAYTIME,
       doc_conn.from_type other_type,
       doc_conn.from_reference_id other_ref_id,
       mapping_type other_mapping_type,
       NULL, --dfdc.from_id other_id,
        to_char(null) record_status,
        to_char(null) created_by,
        to_date(null) created_date,
        to_char(null) last_updated_by,
        to_date(null) last_updated_date,
        to_number(null) rev_no,
        to_char(null) rev_text,
        dfdc.TO_ID,
        null from_id, --dfdc.From_Id,
        dfdc.Connection_Id,
        cjs.comments
  FROM CONT_JOURNAL_SUMMARY cjs,
       DATASET_FLOW_DETAIL_CONN dfdc,
       DATASET_FLOW_DOC_CONN doc_conn,
       DATASET_FLOW_DOCUMENT doc
 WHERE doc.type = 'CONT_JOURNAL_SUMMARY'
   AND doc.reference_id = doc_conn.to_reference_id
   AND doc.type = doc_conn.to_type
   AND cjs.document_key = doc.reference_id
   AND dfdc.connection_id = doc_conn.connection_id
   AND doc_conn.to_type = 'CONT_JOURNAL_SUMMARY'
   AND cjs.document_key = doc.reference_id
   AND dfdc.mapping_type IN ('JOURNAL_SUMMARY','EQUATION')
   AND cjs.Tag = dfdc.to_id