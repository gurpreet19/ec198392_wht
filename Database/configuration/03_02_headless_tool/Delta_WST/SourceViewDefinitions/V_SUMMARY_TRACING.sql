CREATE OR REPLACE FORCE EDITIONABLE VIEW "V_SUMMARY_TRACING" ("JOURNAL_ENTRY_NO", "SUMMARY_TRACING_NO", "CONTRACT_CODE", "PERIOD", "TAG", "DOCUMENT_TYPE", "COST_MAPPING_CODE", "LOAD_ACCOUNT", "LOAD_WBS", "LOAD_QTY", "LOAD_AMOUNT", "CALC_SPLIT", "MAPPING_SPLIT", "SPLIT_KEY_CODE", "SPLIT_ITEM_OTHER_CODE", "COST_MAPP_DOC_KEY", "COST_MAPP_QTY1", "COST_MAPP_AMOUNT", "SUMMARY_DOC_KEY", "DATASET", "LABEL", "FIN_ACCOUNT_CODE", "FIN_COST_CENTER_CODE", "FIN_WBS_CODE", "SUMMARY_AMOUNT", "SUMMARY_QTY_1", "RECORD_STATUS", "COMBINED_OBJ_ID", "COST_MAPP_JOURNAL_ENTRY_NO", "COST_MAPP_REF_JOURNAL_ENTRY_NO", "COST_MAPP_REVERSAL_DATE", "SUMMARY_ADJUSTMENT", "CREATED_BY", "DAYTIME", "CREATED_DATE", "LAST_UPDATED_BY", "LAST_UPDATED_DATE", "REV_NO", "REV_TEXT", "APPROVAL_STATE", "APPROVAL_BY", "APPROVAL_DATE") AS 
  SELECT  cje.journal_entry_no,
        ECDP_SYSTEM_KEY.ASSIGNNEXTNUMBER('SUMMARY_TRACING')SUMMARY_TRACING_NO,
        ec_contract.object_code(cjs.object_id) contract_code,
        cjs.period AS period,
        cjs.tag AS Tag,
        DECODE(cje.ref_journal_entry_src,'CONT',cje.document_type,cje_source.document_type) document_type,
        cm.object_code COST_MAPPING_CODE,
        DECODE(cje.ref_journal_entry_src,'CONT',cje.fin_account_code,cje_source.fin_account_code) load_account,
        DECODE(cje.ref_journal_entry_src,'CONT',cje.fin_wbs_code,cje_source.fin_wbs_code) load_wbs,
        DECODE(cje.ref_journal_entry_src,'CONT',cje.qty_1,cje_source.qty_1) load_qty,
        DECODE(cje.ref_journal_entry_src,'CONT',cje.amount,cje_source.amount) load_amount,
        (SELECT nvl(abs(DECODE(sum(cje_source.amount), 0, 1, sum(cje.amount) / sum(cje_source.amount))),1) * DECODE(cje.reversal_date,NULL,1,-1) FROM dual) calc_split,
        NVL(sks.split_share_mth,1) * DECODE(cje.reversal_date,NULL,1,-1) mapping_split,
        ec_split_key.object_code(cmv.split_key_id) AS split_key_code,
        ec_split_item_other.object_code(cmv.other_split_item_id) AS SPLIT_ITEM_OTHER_CODE,
        cje.document_key cost_mapp_doc_key,
        cje.qty_1 cost_mapp_qty1,
        cje.AMOUNT cost_mapp_amount,
        cjs.document_key AS summary_doc_key,
        cje.dataset,
        cjs.label AS label,
        ec_fin_account.object_code(cjs.fin_account_id) AS fin_account_code,
        ec_fin_cost_center.object_code(cjs.fin_cost_center_id)  AS fin_cost_center_code,
        ec_fin_wbs.object_code(CJS.fin_wbs_id) AS fin_wbs_code,
        cjs.actual_amount summary_amount,
        cjs.ACTUAL_QTY_1 summary_qty_1,
        'P' RECORD_STATUS,
        cjs.document_key || '-' || cjs.list_item_key || '-' || EC_SUMMARY_SETUP.object_code(ssl.object_id) || '-' || cje.journal_entry_no COMBINED_OBJ_ID,
        cje.JOURNAL_ENTRY_NO COST_MAPP_JOURNAL_ENTRY_NO,
        cje.REF_JOURNAL_ENTRY_NO COST_MAPP_REF_JOURNAL_ENTRY_NO,
        cje.REVERSAL_DATE COST_MAPP_REVERSAL_DATE ,
        NULL AS summary_adjustment,
        NULL AS CREATED_BY,
        NULL AS DAYTIME,
        NULL AS CREATED_DATE,
        NULL AS LAST_UPDATED_BY,
        NULL AS LAST_UPDATED_DATE,
        NULL AS REV_NO,
        NULL AS REV_TEXT,
        NULL AS APPROVAL_STATE,
        NULL AS APPROVAL_BY,
        NULL AS APPROVAL_DATE
  FROM  (SELECT DISTINCT d1.connection_id,d.to_reference_id,d1.mapping_id,d.from_reference_id
           FROM dataset_flow_doc_conn d,dataset_flow_detail_conn d1
          WHERE d.to_type='CONT_JOURNAL_SUMMARY'
            AND d.connection_id=d1.connection_id) dataset
        join cont_journal_summary cjs
          on cjs.document_key=dataset.to_reference_id
         and cjs.summary_setup_id=dataset.mapping_id
        join cont_journal_entry cje
          on cje.document_key=dataset.from_reference_id
         and cje.period = cjs.period
         and cje.CONTRACT_CODE = ec_contract.object_code(cjs.object_id)
        join summary_setup_list ssl
          on ssl.object_id=cjs.summary_setup_id
         and ssl.tag=cjs.tag
         and cje.dataset = ssl.dataset
         and cje.tag=ssl.tag
         and nvl(cje.inventory_id,'null') =nvl(ssl.inventory_id,'null')
        join cost_mapping cm
          on cm.object_id = cje.cost_mapping_id
        join cost_mapping_version cmv
          on cm.object_id=cmv.object_id
        left join ifac_journal_entry cje_source
          on cjs.period = cje_source.period
         and cje.ref_journal_entry_no = TO_CHAR(cje_source.journal_entry_no)
        left join split_key_setup sks
          on cmv.split_key_id = sks.object_id
         and cmv.other_split_item_id=sks.split_member_id
 WHERE  cje.reversal_date IS NULL
   AND  NVL(sks.daytime,to_date('1/1/2010','mm/dd/yyyy')) = (SELECT NVL(MAX (daytime),to_date('1/1/2010','mm/dd/yyyy'))
                                                               FROM split_key_setup
                                                              WHERE object_id = cmv.split_key_id
                                                                AND split_member_id = cmv.other_split_item_id
                                                                AND daytime <= cje.period)