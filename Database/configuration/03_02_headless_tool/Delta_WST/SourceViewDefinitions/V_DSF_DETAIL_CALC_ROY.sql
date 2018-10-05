CREATE OR REPLACE FORCE EDITIONABLE VIEW "V_DSF_DETAIL_CALC_ROY" ("REFERENCE_ID", "TYPE", "DIRECTION", "OBJECT_ID", "VALUE", "PARAMETERS", "MAPPING_TYPE", "MAPPING_ID", "MAPPING_DATE", "ID", "LINE_TAG", "OTHER_TYPE", "OTHER_REF_ID", "OTHER_ID", "SUM_DOC", "VALUE_TYPE", "OTHER_MAPPING_TYPE", "DAYTIME", "RECORD_STATUS", "CREATED_BY", "CREATED_DATE", "LAST_UPDATED_BY", "LAST_UPDATED_DATE", "REV_NO", "REV_TEXT", "TO_ID", "FROM_ID", "CONNECTION_ID", "COMMENTS") AS 
  SELECT
       doc.reference_id,
       'CALC_REF_ROY'  type,
       'IN' direction,
       --CLASS CA_CLASS,
       --ATTRIBUTE CA_ATTRIBUTE,
       OBJECT_ID,
       DECODE(TO_ID, 'AMOUNT', NVL(ACTUAL_AMOUNT,0) + NVL(AMOUNT_ADJUSTMENT,0),NVL(ACTUAL_QTY_1,0) + NVL(QTY_ADJUSTMENT,0)) VALUE,
       NULL PARAMETERS,
       dfdc.mapping_type,
       substr(dfdc.mapping_id,1,decode(instr(dfdc.mapping_id,'|'),0,length(dfdc.mapping_id),instr(dfdc.mapping_id,'|')-1)) mapping_id,
       TO_DATE(decode(instr(dfdc.mapping_id,'|'),0, null, substr(dfdc.mapping_id,instr(dfdc.mapping_id,'|')+1)),'YYYY-MM-DD"T"HH24:MI:SS') mapping_date,
       tO_ID||'$' ID,
       cjs.tag  line_tag,
       doc_conn.from_type other_type,
       doc_conn.from_reference_id other_ref_id,
       cjs.tag||'$' other_id,
       doc_conn.from_reference_id sum_doc,
       to_id value_type,
       'JOURNAL_SUMMARY' other_mapping_type,
       doc.process_date DAYTIME,
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
        cjs.comments
  FROM CONT_JOURNAL_SUMMARY cjs,
       DATASET_FLOW_DETAIL_CONN dfdc,
       DATASET_FLOW_DOC_CONN doc_conn,
       DATASET_FLOW_DOCUMENT doc
 WHERE cjs.tag = dfdc.FROM_id
   AND cjs.document_key = doc_conn.from_reference_id
   AND doc_conn.from_type = 'CONT_JOURNAL_SUMMARY'
   and doc.TYPE = 'CALC_REF_ROY'
   AND doc.reference_id = doc_conn.TO_reference_id
   AND doc.type = doc_conn.TO_type
   AND dfdc.connection_id = doc_conn.connection_id
   AND dfdc.mapping_type IN ( 'EQUATION')
UNION ALL
SELECT
       doc.reference_id,
       'CALC_REF_ROY'  type,
       'OUT' direction,
       --CLASS CA_CLASS,
       --ATTRIBUTE CA_ATTRIBUTE,
       OBJECT_ID,
       DECODE(from_ID, 'AMOUNT', NVL(ACTUAL_AMOUNT,0) + NVL(AMOUNT_ADJUSTMENT,0),NVL(ACTUAL_QTY_1,0) + NVL(QTY_ADJUSTMENT,0)) value,
       NULL PARAMETERS,
       dfdc.mapping_type,
       substr(dfdc.mapping_id,1,decode(instr(dfdc.mapping_id,'|'),0,length(dfdc.mapping_id),instr(dfdc.mapping_id,'|')-1)) mapping_id,
       TO_DATE(decode(instr(dfdc.mapping_id,'|'),0, null, substr(dfdc.mapping_id,instr(dfdc.mapping_id,'|')+1)),'YYYY-MM-DD"T"HH24:MI:SS') mapping_date,
       from_id||'$' ID,
        cjs.tag  extract_line,
       doc_conn.to_type other_type,
       doc_conn.to_reference_id other_ref_id,
       cjs.tag||'$' other_id,
       doc_conn.to_reference_id sum_doc,
       from_id value_type,
       'JOURNAL_SUMMARY' other_mapping_type,
       doc.process_date DAYTIME,
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
        cjs.comments
  FROM CONT_JOURNAL_SUMMARY cjs,
       DATASET_FLOW_DETAIL_CONN dfdc,
       DATASET_FLOW_DOC_CONN doc_conn,
       DATASET_FLOW_DOCUMENT doc
 WHERE cjs.tag = dfdc.to_id
   AND cjs.document_key = doc_conn.TO_reference_id
   AND doc_conn.TO_type = 'CONT_JOURNAL_SUMMARY'
   and doc.TYPE = 'CALC_REF_ROY'
   AND doc.reference_id = doc_conn.FROM_reference_id
   AND doc.type = doc_conn.FROM_type
   AND dfdc.connection_id = doc_conn.connection_id
   AND dfdc.mapping_type IN ( 'EQUATION')
   AND (ACTUAL_AMOUNT IS NOT NULL OR ACTUAL_QTY_1 IS NOT NULL)
union all
-- Contract Accounts
SELECT
       doc.reference_id,
       'CALC_REF_ROY'  type,
       'OUT' direction,
       --CLASS CA_CLASS,
       --ATTRIBUTE CA_ATTRIBUTE,
       OBJECT_ID,
        value,
       NULL PARAMETERS,
       dfdc.mapping_type,
       substr(dfdc.mapping_id,1,decode(instr(dfdc.mapping_id,'|'),0,length(dfdc.mapping_id),instr(dfdc.mapping_id,'|')-1)) mapping_id,
       dfd.daytime mapping_date,
       from_id||'$' ID,
       dfdc.from_id extract_line,
       doc_conn.to_type other_type,
       doc_conn.from_reference_id || '$'|| doc_conn.to_reference_id other_ref_id,
       to_id ||'$'||dfd.class||'$'|| to_char(dfd.daytime,'MM-DD-YYYY') ||'$' other_id,
       ec_calc_reference.ref_object_id_1(doc_conn.from_reference_id) sum_doc,
       dfd.class value_type,
       'CONTRACT_ACCOUNT' other_mapping_type,
        DAYTIME,
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
        null comments
  FROM DATASET_FLOW_DETAIL dfd,
       DATASET_FLOW_DETAIL_CONN dfdc,
       DATASET_FLOW_DOC_CONN doc_conn,
       DATASET_FLOW_DOCUMENT doc
 WHERE dfd.ref_id = dfdc.to_id
   AND doc_conn.TO_type = 'CONTRACT_ACCOUNT'
   and doc.TYPE = 'CALC_REF_ROY'
   AND doc.reference_id = doc_conn.FROM_reference_id
   AND doc.type = doc_conn.FROM_type
   AND dfdc.connection_id = doc_conn.connection_id
   AND dfdc.mapping_type IN ( 'EQUATION')
UNION ALL
--Contract doc
SELECT
       DISTINCT
       doc.reference_id reference_id,
       'CALC_REF_ROY'  type,
       'OUT' direction,
       --CLASS CA_CLASS,
       --ATTRIBUTE CA_ATTRIBUTE,
       dfd.OBJECT_ID,
       VALUE,
       NULL PARAMETERS,
       'TRANSACTION' mapping_type,
       ct.trans_template_id mapping_id,
       ct.transaction_date,
       dfd.ref_id ||'$'|| CLASS||'$'|| to_char(dfd.daytime,'MM-DD-YYYY')||'$' ID,
       attribute,
       'CONT_DOCUMENT' other_type,
       CT.DOCUMENT_KEY other_ref_id,
       CT.TRANSACTION_KEY||'$' other_id,
       ATTRIBUTE,
       dfd.class,
       'CONT_DOC' other_mapping_type,
       doc.process_date DAYTIME,
        to_char(null) record_status,
        to_char(null) created_by,
        to_date(null) created_date,
        to_char(null) last_updated_by,
        to_date(null) last_updated_date,
        to_number(null) rev_no,
        to_char(null) rev_text,
        ct.transaction_key TO_ID,
        to_Id,
        dfdc.Connection_Id,
        ct.comments comments
  FROM CONT_TRANSACTION ct,
       DATASET_FLOW_DETAIL dfd,
       DATASET_FLOW_DETAIL_CONN dfdc,
       DATASET_FLOW_DOC_CONN doc_conn,
       DATASET_FLOW_DOCUMENT doc
 WHERE to_char(ct.calc_run_no) = doc.reference_id
   AND ct.contract_account = attribute
   AND dfd.ref_id = dfdc.to_id
   and DFD.TYPE = 'CONTRACT_ACCOUNT'
   AND doc.reference_id = doc_conn.FROM_reference_id
   AND doc.type = doc_conn.FROM_type
   AND dfdc.connection_id = doc_conn.connection_id
   AND dfdc.mapping_type  IN ( 'TI_CONTRACT','EQUATION')