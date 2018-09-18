CREATE OR REPLACE FORCE EDITIONABLE VIEW "V_DATASET_FLOW_MAPPING" ("TYPE", "OBJECT", "REFERENCE_ID", "DIRECTION", "MAPPING_TYPE", "OTHER_REF_ID", "SCREEN_CLASS", "OTHER_TYPE", "OTHER_DATE", "RECORD_STATUS", "CREATED_BY", "CREATED_DATE", "LAST_UPDATED_BY", "LAST_UPDATED_DATE", "REV_NO", "REV_TEXT") AS 
  select distinct doc.type,
    ec_dataset_flow_document.object(doc_conn.from_type,doc_conn.from_reference_id) object,
    decode(doc_conn.to_type,'CONTRACT_ACCOUNT',doc_conn.from_reference_id || '$' ) || doc.reference_id reference_id,
    'IN' direction,mapping_type,
   decode(doc_conn.from_type,'CONTRACT_ACCOUNT',doc_conn.to_reference_id|| '$' ) || decode(doc_conn.from_reference_id,'CLASS_MAP', doc.reference_id,doc_conn.from_reference_id) other_ref_id,
   ecdp_dataset_flow.getMappingScreen(mapping_type,'IN',type, doc_conn.from_type,decode(doc_conn.from_type,'CONTRACT_ACCOUNT',doc_conn.to_reference_id|| '$' ) || doc_conn.from_reference_id) SCREEN_CLASS,
    doc_conn.from_type other_type,
    ec_dataset_flow_document.process_date(doc_conn.from_type,doc_conn.from_reference_id) other_date,
    to_char(null) record_status,
    to_char(null) created_by,
    to_date(null) created_date,
		to_char(null) last_updated_by,
		to_date(null) last_updated_date,
		to_number(null) rev_no,
		to_char(null) rev_text
from dataset_flow_doc_conn doc_conn,
     dataset_flow_document doc,
     dataset_flow_detail_conn detail_con
WHERE doc.reference_id = doc_conn.to_reference_id
  AND doc.type = doc_conn.to_type
  AND doc_conn.connection_id = detail_con.connection_id
UNION ALL
select distinct doc.type,
    ec_dataset_flow_document.object(doc_conn.from_type,doc_conn.from_reference_id) object,
    decode(doc_conn.from_type,'CONTRACT_ACCOUNT',doc_conn.to_reference_id || '$' ) || doc.reference_id,
    'OUT' direction,
    mapping_type,
    decode(doc_conn.to_type,'CONTRACT_ACCOUNT',doc_conn.from_reference_id || '$' )  || doc_conn.to_reference_id other_ref_id,
   ecdp_dataset_flow.getMappingScreen(mapping_type,'OUT' ,type, doc_conn.to_type ,decode(doc_conn.to_type,'CONTRACT_ACCOUNT',doc_conn.from_reference_id || '$' )  || doc_conn.to_reference_id ) SCREEN_CLASS,
    doc_conn.to_type other_type,
    ec_dataset_flow_document.process_date(doc_conn.to_type,doc_conn.to_reference_id) other_date,
		to_char(null) record_status,
		to_char(null) created_by,
		to_date(null) created_date,
		to_char(null) last_updated_by,
		to_date(null) last_updated_date,
		to_number(null) rev_no,
		to_char(null) rev_text
from dataset_flow_doc_conn doc_conn,
     dataset_flow_document doc,
     dataset_flow_detail_conn detail_con
WHERE doc.reference_id = doc_conn.from_reference_id
  AND doc.type = doc_conn.from_type
  AND doc_conn.connection_id = detail_con.connection_id