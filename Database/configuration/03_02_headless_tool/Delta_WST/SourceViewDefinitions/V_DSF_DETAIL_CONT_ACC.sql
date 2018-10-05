CREATE OR REPLACE FORCE EDITIONABLE VIEW "V_DSF_DETAIL_CONT_ACC" ("REFERENCE_ID", "TYPE", "DIRECTION", "CA_CLASS", "CA_ATTRIBUTE", "OBJECT_ID", "VALUE", "VALUE_TYPE", "PARAMETERS", "MAPPING_TYPE", "MAPPING_ID", "ID", "OTHER_TYPE", "OTHER_REF_ID", "OTHER_ID", "OTHER_MAPPING_TYPE", "CA_DAYTIME", "DAYTIME", "RECORD_STATUS", "CREATED_BY", "CREATED_DATE", "LAST_UPDATED_BY", "LAST_UPDATED_DATE", "REV_NO", "REV_TEXT", "TO_ID", "FROM_ID", "CONNECTION_ID", "COMMENTS") AS 
  SELECT
       DISTINCT
       doc.reference_id||'$'||OBJECT_ID  reference_id,
       'CONTRACT_ACCOUNT'  type,
       'IN' direction,
       CLASS CA_CLASS,
       ATTRIBUTE CA_ATTRIBUTE,
       OBJECT_ID,
       VALUE,
       dfd.class value_type,
       NULL PARAMETERS,
       dfdc.mapping_type,
       NULL mapping_id,
       dfd.ref_id ||'$'|| CLASS || '$'|| to_char(dfd.daytime,'MM-DD-YYYY') ||'$' ID,
       doc_conn.from_type other_type,
       doc_conn.from_reference_id other_ref_id,
       --from_id
       null other_id,
       'CONTRACT_ACCOUNT' other_mapping_type,
       dfd.daytime CA_DAYTIME,
       doc.process_date DAYTIME,
        to_char(null) record_status,
        to_char(null) created_by,
        to_date(null) created_date,
        to_char(null) last_updated_by,
        to_date(null) last_updated_date,
        to_number(null) rev_no,
        to_char(null) rev_text,
        dfdc.TO_ID,
        null From_Id, --dfdc.From_Id,
        dfdc.Connection_Id,
        null comments
  FROM DATASET_FLOW_DETAIL dfd,
       DATASET_FLOW_DETAIL_CONN dfdc,
       DATASET_FLOW_DOC_CONN doc_conn,
       DATASET_FLOW_DOCUMENT doc
 WHERE dfd.ref_id = dfdc.to_id
   and DFD.TYPE = 'CONTRACT_ACCOUNT'
   AND doc.reference_id = doc_conn.FROM_reference_id
   AND doc.type = doc_conn.FROM_type
   AND dfdc.connection_id = doc_conn.connection_id
   AND dfdc.mapping_type  IN ( 'TI_CONTRACT','EQUATION')
UNION ALL
SELECT
       DISTINCT
       doc.reference_id reference_id,
       doc.type,
       'OUT' direction,
       CLASS CA_CLASS,
       ATTRIBUTE CA_ATTRIBUTE,
       DFD.OBJECT_ID,
       VALUE,
       dfd.class value_type,
       NULL PARAMETERS,
       dfdc.mapping_type,
       NULL mapping_id,
       dfd.ref_id ||'$'|| CLASS ||'$' ID,
       'CONT_DOCUMENT' other_type,
       ct.document_key other_ref_id,
       ct.transaction_key other_id,
       'CONT_DOCUMENT' other_mapping_type,
       dfd.daytime CA_DAYTIME,
       doc.process_date DAYTIME,
        to_char(null) record_status,
        to_char(null) created_by,
        to_date(null) created_date,
        to_char(null) last_updated_by,
        to_date(null) last_updated_date,
        to_number(null) rev_no,
        to_char(null) rev_text,
        dfdc.TO_ID,
        null From_Id, --dfdc.From_Id,
        dfdc.Connection_Id,
        null comments
  FROM DATASET_FLOW_DETAIL dfd,
       DATASET_FLOW_DETAIL_CONN dfdc,
       DATASET_FLOW_DOC_CONN doc_conn,
       DATASET_FLOW_DOCUMENT doc,
       CONT_TRANSACTION ct
 WHERE ct.CALC_RUN_NO = DOC.REFERENCE_ID
   AND doc.tYPE like 'CALC_REF%'
   AND dfd.ref_id = substr(dfdc.from_id,0, instr(dfdc.from_id,'$',-1)-1)
   and DFD.TYPE = 'CONTRACT_ACCOUNT'
   and trunc(dfd.daytime,'mm') = trunc(ct.transaction_date, 'mm')
   AND doc.reference_id = doc_conn.FROM_reference_id
   AND ct.transaction_key = to_id
   AND doc.type = doc_conn.FROM_type
   AND dfdc.connection_id = doc_conn.connection_id
   AND dfdc.mapping_type  IN ( 'SCTR_ACC_MTH_STATUS')