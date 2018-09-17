CREATE OR REPLACE FORCE EDITIONABLE VIEW "V_DSF_DETAIL_CLASS_MAPPING" ("REFERENCE_ID", "TYPE", "DIRECTION", "CA_CLASS", "CA_ATTRIBUTE", "VALUE", "ID", "MAPPING_TYPE", "OBJECT", "MAPPING_ID", "PARAMETERS", "DAYTIME", "OTHER_TYPE", "OTHER_REF_ID", "OTHER_MAPPING_TYPE", "OTHER_ID", "RECORD_STATUS", "CREATED_BY", "CREATED_DATE", "LAST_UPDATED_BY", "LAST_UPDATED_DATE", "REV_NO", "REV_TEXT", "TO_ID", "FROM_ID", "CONNECTION_ID", "COMMENTS") AS 
  SELECT
         doc.reference_id,
         doc.type,
         'IN' direction,
         ref_class_name CA_CLASS,
         ref_attribute_name CA_ATTRIBUTE,
         orig_cls_map_value VALUE,
         dfdc.to_id id,
         'CLASS_MAPPING' mapping_type,
         doc.object,
         dfdc.mapping_id,
         class_map_params parameters,
         doc.process_date DAYTIME,
        CASE WHEN ref_class_name
           LIKE '%RR_CONTRACT%' THEN
           'CONT_DOCUMENT'
           ELSE
             'CLASS_MAPPING' END
           other_type,
         doc_conn.FROM_reference_id other_ref_id,
         'JOURNAL_MAPPING' other_mapping_type,
         dfdc.to_id other_id,
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
    FROM CONT_JOURNAL_ENTRY cje,
         DATASET_FLOW_DETAIL_CONN dfdc,
         DATASET_FLOW_DOC_CONN doc_conn,
         DATASET_FLOW_DOCUMENT doc
   WHERE doc.type = 'CONT_JOURNAL_ENTRY'
     AND doc.reference_id = doc_conn.to_reference_id
     AND doc.type = doc_conn.to_type
     AND dfdc.connection_id = doc_conn.connection_id
     AND doc_conn.to_type = 'CONT_JOURNAL_ENTRY'
     AND dfdc.mapping_type = 'JOURNAL_MAPPING'
     AND to_char(cje.journal_entry_no) = dfdc.to_id
     AND NVL(orig_cls_map_value,0) != 0
union all
  SELECT
          doc.reference_id,
             'CLASS_MAPPING',
         'OUT' direction,
         ref_class_name CA_CLASS,
         ref_attribute_name CA_ATTRIBUTE,
         orig_cls_map_value VALUE,
         dfdc.to_id id,
         'JOURNAL_MAPPING' mapping_type,
         doc.object,
         dfdc.mapping_id,
         class_map_params parameters,
         doc.process_date DAYTIME,
         doc.type other_type,
         doc_conn.to_reference_id  other_ref_id,
         'CLASS_MAPPING' other_mapping_type,
         dfdc.TO_id other_id,
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
    FROM CONT_JOURNAL_ENTRY cje,
         DATASET_FLOW_DETAIL_CONN dfdc,
         DATASET_FLOW_DOC_CONN doc_conn,
         DATASET_FLOW_DOCUMENT doc
   WHERE doc.type = 'CONT_JOURNAL_ENTRY'
     AND doc.reference_id = doc_conn.to_reference_id
     AND doc.type = doc_conn.to_type
     AND dfdc.connection_id = doc_conn.connection_id
     AND doc_conn.to_type = 'CONT_JOURNAL_ENTRY'
     AND dfdc.mapping_type = 'JOURNAL_MAPPING'
     AND to_char(cje.journal_entry_no) = dfdc.to_id
     AND NVL(orig_cls_map_value,0) != 0