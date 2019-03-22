CREATE OR REPLACE FORCE EDITIONABLE VIEW "V_DSF_DETAIL_CALC_TIN" ("LINE_TAG", "TRANS_PROD_SET_ITEM_ID", "CONFIG_VARIABLE_ID", "REFERENCE_ID", "TYPE", "DIRECTION", "CA_CLASS", "CA_ATTRIBUTE", "OBJECT_ID", "VALUE", "VALUE_TYPE", "PARAM_DATE", "PARAMETERS", "MAPPING_TYPE", "MAPPING_ID", "ID", "DAYTIME", "OTHER_TYPE", "OTHER_ID", "OTHER_MAPPING_TYPE", "OTHER_REF_ID", "RECORD_STATUS", "CREATED_BY", "CREATED_DATE", "LAST_UPDATED_BY", "LAST_UPDATED_DATE", "REV_NO", "REV_TEXT", "TO_ID", "FROM_ID", "CONNECTION_ID", "COMMENTS") AS 
  SELECT line_tag,
       product_id ||'-'||cost_type trans_prod_set_item_id,
       config_variable_id,
       doc.reference_id,
       doc.type,
       'IN' direction,
       CLASS CA_CLASS,
       ATTRIBUTE CA_ATTRIBUTE,
       TILPV.Config_Variable_Id object_id,
       VALUE,
       tilpv.type VALUE_TYPE,
       to_date(substr(from_id,length(from_id)-18),'YYYY-MM-DD"T"HH24:MI:SS') Param_Date,
       ecdp_dataset_flow.GetMappingParameters( doc.process_date,doc.reference_id ,dfdc.mapping_type,dfd.class,PARAMETERS) PARAMETERS,
       dfdc.mapping_type,
       dfdc.mapping_id,
       dfdc.from_id||'$' id,
       doc.process_date DAYTIME,
       doc_conn.from_type other_type,
       dfdc.to_id||'$' other_id,
       'NONE' other_mapping_type,
       doc_conn.from_reference_id other_ref_id,
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
  FROM DATASET_FLOW_DETAIL dfd,
       DATASET_FLOW_DETAIL_CONN dfdc,
       DATASET_FLOW_DOC_CONN doc_conn,
       DATASET_FLOW_DOCUMENT doc,
       TRANS_INV_LI_PR_VAR tilpv
 WHERE tilpv.id = dfdc.mapping_id
   AND dfd.ref_id = dfdc.from_id
   AND doc.type = DFD.TYPE
   AND doc.reference_id = doc_conn.to_reference_id
   AND doc.type = doc_conn.to_type
   AND dfdc.connection_id = doc_conn.connection_id
   AND dfdc.mapping_type = 'TI_VARIABLE'
UNION ALL
SELECT
       CJS.TAG,
       NULL,
       NULL,
       doc.reference_id,
       'CALC_REF_TIN'  type,
       'IN' direction,
       'CONT_JOURNAL_SUMMARY' CA_CLASS,
       decode(TO_ID, 'VALUE','Amount','Quantity') CA_ATTRIBUTE,
       OBJECT_ID,
       DECODE(TO_ID, 'VALUE', NVL(ACTUAL_AMOUNT,0)+NVL(cjs.Amount_Adjustment,0),NVL(cjs.ACTUAL_QTY_1,0) + NVL(cjs.Qty_Adjustment,0)) VALUE,
       to_id value_type,
     cjs.period mapping_date,
       'N/A' PARAMETERS,
       dfdc.mapping_type,
       mapping_id,
       tO_ID||'$' ID,
     doc.process_date DAYTIME,
       doc_conn.from_type other_type,
       cjs.tag||'$' other_id,
       'JOURNAL_SUMMARY' other_mapping_type,
       doc_conn.from_reference_id other_ref_id,
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
   and doc.TYPE = 'CALC_REF_TIN'
   AND doc.reference_id = doc_conn.TO_reference_id
   AND doc.type = doc_conn.TO_type
   AND dfdc.connection_id = doc_conn.connection_id
   AND dfdc.mapping_type IN ( 'TI_LINE_PROD_EXT')
UNION ALL
SELECT
       line_tag,
        product_id ||'-'||cost_type,
       tilpca.account_code,
       doc.reference_id,
       doc.type,
       'OUT' direction,
       CLASS CA_CLASS,
       ATTRIBUTE CA_ATTRIBUTE,
       tilpca.PROD_STREAM_ID OBJECT_ID,
       VALUE,
       tilpca.type VALUE_TYPE,
       to_date(substr(from_id,length(from_id)-18),'YYYY-MM-DD"T"HH24:MI:SS') Param_Date,
       ec_product_version.name(tilpca.product_id,doc.process_date,'<=') || ' ' || tilpca.cost_type||'-'||
       decode(instr(dfdc.mapping_id,'$'),0,'',decode(substr(dfdc.mapping_id,instr(dfdc.mapping_id,'$')+1),'Y','Reversed','')) PARAMETERS,
       dfdc.mapping_type,
       dfdc.mapping_id,
       dfd.id,
       doc.process_date DAYTIME,
       doc_conn.to_type other_type,
       dfdc.to_id other_id,
       'CONTRACT_ACCOUNT' other_mapping_type,
        reference_id ||'$' || doc_conn.to_reference_id other_ref_id,
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
  FROM DATASET_FLOW_DETAIL dfd,
       DATASET_FLOW_DETAIL_CONN dfdc,
       DATASET_FLOW_DOC_CONN doc_conn,
       DATASET_FLOW_DOCUMENT doc,
       TRANS_INV_LI_PR_CNTRACC tilpca
 WHERE DOC.TYPE = 'CALC_REF_TIN'
   AND DFD.TYPE = 'CONTRACT_ACCOUNT'
   AND doc_conn.connection_id = dfdc.connection_id
   AND doc.reference_id = doc_conn.from_reference_id
   AND doc.type = doc_conn.from_type
   AND dfdc.mapping_type IN ( 'TI_CONTRACT')
   AND dfd.ref_id = dfdc.from_iD
   AND tilpca.OBJECT_ID ||'-'||tilpca.LINE_TAG ||'-'|| tilpca.product_id ||'-'||cost_type = substr(dfd.OBJECT_ID,instr(dfd.OBJECT_ID,'$')+1)
   union all
--Contract doc
SELECT   distinct
       null,
       null,
       CT.Contract_Account,
       doc.reference_id reference_id,
       'CALC_REF_TIN'  type,
       'OUT' direction,
       CT.CONTRACT_ACCOUNT_CLASS CA_CLASS,
       CLASS CA_ATTRIBUTE,
       dfd.OBJECT_ID,
       VALUE,
       'BOTH',
       ct.transaction_date,
       'N/A' PARAMETERS,
       'TRANSACTION' mapping_type,
       ct.trans_template_id mapping_id,
       dfd.ref_id ||'$'|| CLASS||'$' ID,
       doc.process_date DAYTIME,
       'CONT_DOCUMENT' other_type,
       CT.TRANSACTION_KEY||'$' other_id,
       'CONT_DOC' other_mapping_type,
       CT.DOCUMENT_KEY other_ref_id,
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
   AND dfdc.mapping_type  IN ( 'TI_CONTRACT')