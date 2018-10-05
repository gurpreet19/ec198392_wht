CREATE OR REPLACE FORCE EDITIONABLE VIEW "V_DSF_DETAIL_JOUR_MAPPING" ("REFERENCE_ID", "TYPE", "DIRECTION", "CA_CLASS", "QTY_1", "AMOUNT", "JOURNAL_ENTRY_NO", "COMPANY_CODE", "FISCAL_YEAR", "PERIOD", "CONTRACT_CODE", "DATASET", "LINE_ITEM_KEY", "POSTING_KEY", "ACCOUNT_TYPE", "DEBIT_CREDIT_CODE", "TAX_CODE", "TAX_AMOUNT", "UOM1_CODE", "DOCUMENT_TYPE", "FIN_ACCOUNT_CODE", "FIN_COST_OBJECT_CODE", "FIN_COST_CENTER_CODE", "FIN_REVENUE_ORDER_CODE", "FIN_WBS_CODE", "MATERIAL", "PLANT", "JOINT_VENTURE", "RECOVERY_IND", "EQUITY_GROUP", "PROFIT_CENTER_CODE", "FIN_WBS_DESCR", "FIN_ACCOUNT_DESCR", "EXPENDITURE_TYPE", "TRANSACTION_TYPE", "CURRENCY_CODE", "PERIOD_CODE", "TEXT_1", "TEXT_2", "TEXT_3", "TEXT_4", "TEXT_5", "TEXT_6", "TEXT_7", "TEXT_8", "TEXT_9", "TEXT_10", "TEXT_11", "TEXT_12", "TEXT_13", "TEXT_14", "TEXT_15", "TEXT_16", "TEXT_17", "TEXT_18", "TEXT_19", "TEXT_20", "VALUE_1", "VALUE_2", "VALUE_3", "VALUE_4", "VALUE_5", "VALUE_6", "VALUE_7", "VALUE_8", "VALUE_9", "VALUE_10", "DATE_1", "DATE_2", "DATE_3", "DATE_4", "DATE_5", "DATE_6", "DATE_7", "DATE_8", "DATE_9", "DATE_10", "REF_OBJECT_ID_1", "REF_OBJECT_ID_2", "REF_OBJECT_ID_3", "REF_OBJECT_ID_4", "REF_OBJECT_ID_5", "REF_OBJECT_ID_6", "REF_OBJECT_ID_7", "REF_OBJECT_ID_8", "REF_OBJECT_ID_9", "REF_OBJECT_ID_10", "ID", "MAPPING_TYPE", "OBJECT_ID", "MAPPING_ID", "DAYTIME", "OTHER_TYPE", "OTHER_REF_ID", "OTHER_MAPPING_TYPE", "OTHER_ID", "RECORD_STATUS", "CREATED_BY", "CREATED_DATE", "LAST_UPDATED_BY", "LAST_UPDATED_DATE", "REV_NO", "REV_TEXT", "TO_ID", "FROM_ID", "CONNECTION_ID", "COMMENTS") AS 
  SELECT
       doc.reference_id,
       doc.type,
       'OUT' direction,
       'CONT_JOURNAL_ENTRY' CA_CLASS,
       --ATTRIBUTE CA_ATTRIBUTE,
       cje.qty_1,
       cje.Amount
       ,cje.JOURNAL_ENTRY_NO
       ,cje.COMPANY_CODE
       ,cje.FISCAL_YEAR
       ,cje.PERIOD
       ,cje.CONTRACT_CODE
       ,cje.DATASET
       ,cje.LINE_ITEM_KEY
       ,cje.POSTING_KEY
       ,cje.ACCOUNT_TYPE
       ,cje.DEBIT_CREDIT_CODE
       ,cje.TAX_CODE
       ,cje.TAX_AMOUNT
       ,cje.UOM1_CODE
       ,cje.DOCUMENT_TYPE
       ,cje.FIN_ACCOUNT_CODE
       ,cje.FIN_COST_OBJECT_CODE
       ,cje.FIN_COST_CENTER_CODE
       ,cje.FIN_REVENUE_ORDER_CODE
       ,cje.FIN_WBS_CODE
       ,cje.MATERIAL
       ,cje.PLANT
       ,cje.JOINT_VENTURE
       ,cje.RECOVERY_IND
       ,cje.EQUITY_GROUP
       ,cje.PROFIT_CENTER_CODE
       ,cje.FIN_WBS_DESCR
       ,cje.FIN_ACCOUNT_DESCR
       ,cje.EXPENDITURE_TYPE
       ,cje.TRANSACTION_TYPE
       ,cje.CURRENCY_CODE
       ,cje.PERIOD_CODE
       ,cje.TEXT_1
       ,cje.TEXT_2
       ,cje.TEXT_3
       ,cje.TEXT_4
       ,cje.TEXT_5
       ,cje.TEXT_6
       ,cje.TEXT_7
       ,cje.TEXT_8
       ,cje.TEXT_9
       ,cje.TEXT_10
       ,cje.TEXT_11
       ,cje.TEXT_12
       ,cje.TEXT_13
       ,cje.TEXT_14
       ,cje.TEXT_15
       ,cje.TEXT_16
       ,cje.TEXT_17
       ,cje.TEXT_18
       ,cje.TEXT_19
       ,cje.TEXT_20
       ,cje.VALUE_1
       ,cje.VALUE_2
       ,cje.VALUE_3
       ,cje.VALUE_4
       ,cje.VALUE_5
       ,cje.VALUE_6
       ,cje.VALUE_7
       ,cje.VALUE_8
       ,cje.VALUE_9
       ,cje.VALUE_10
       ,cje.DATE_1
       ,cje.DATE_2
       ,cje.DATE_3
       ,cje.DATE_4
       ,cje.DATE_5
       ,cje.DATE_6
       ,cje.DATE_7
       ,cje.DATE_8
       ,cje.DATE_9
       ,cje.DATE_10
       ,cje.REF_OBJECT_ID_1
       ,cje.REF_OBJECT_ID_2
       ,cje.REF_OBJECT_ID_3
       ,cje.REF_OBJECT_ID_4
       ,cje.REF_OBJECT_ID_5
       ,cje.REF_OBJECT_ID_6
       ,cje.REF_OBJECT_ID_7
       ,cje.REF_OBJECT_ID_8
       ,cje.REF_OBJECT_ID_9
       ,cje.REF_OBJECT_ID_10,
       dfdc.from_id id,
       mapping_type,
       doc.object object_id,
       dfdc.mapping_id,
       doc.process_date DAYTIME,
       doc_conn.to_type other_type,
       doc_conn.to_reference_id other_ref_id,
       'JOURNAL_SUMMARY' other_mapping_type,
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
   AND doc.reference_id = doc_conn.from_reference_id
   AND doc.type = doc_conn.from_type
   AND dfdc.connection_id = doc_conn.connection_id
   AND dfdc.mapping_type = 'JOURNAL_SUMMARY'
   AND to_char(cje.journal_entry_no) = dfdc.from_id
UNION ALL
SELECT
       doc.reference_id,
       doc.type,
       'IN' direction,
       'CONT_JOURNAL_ENTRY' CA_CLASS,
       --ATTRIBUTE CA_ATTRIBUTE,
       cje.qty_1,
       cje.Amount,
       cje.JOURNAL_ENTRY_NO
       ,cje.COMPANY_CODE
       ,cje.FISCAL_YEAR
       ,cje.PERIOD
       ,cje.CONTRACT_CODE
       ,cje.DATASET
       ,cje.LINE_ITEM_KEY
       ,cje.POSTING_KEY
       ,cje.ACCOUNT_TYPE
       ,cje.DEBIT_CREDIT_CODE
       ,cje.TAX_CODE
       ,cje.TAX_AMOUNT
       ,cje.UOM1_CODE
       ,cje.DOCUMENT_TYPE
       ,cje.FIN_ACCOUNT_CODE
       ,cje.FIN_COST_OBJECT_CODE
       ,cje.FIN_COST_CENTER_CODE
       ,cje.FIN_REVENUE_ORDER_CODE
       ,cje.FIN_WBS_CODE
       ,cje.MATERIAL
       ,cje.PLANT
       ,cje.JOINT_VENTURE
       ,cje.RECOVERY_IND
       ,cje.EQUITY_GROUP
       ,cje.PROFIT_CENTER_CODE
       ,cje.FIN_WBS_DESCR
       ,cje.FIN_ACCOUNT_DESCR
       ,cje.EXPENDITURE_TYPE
       ,cje.TRANSACTION_TYPE
       ,cje.CURRENCY_CODE
       ,cje.PERIOD_CODE
       ,cje.TEXT_1
       ,cje.TEXT_2
       ,cje.TEXT_3
       ,cje.TEXT_4
       ,cje.TEXT_5
       ,cje.TEXT_6
       ,cje.TEXT_7
       ,cje.TEXT_8
       ,cje.TEXT_9
       ,cje.TEXT_10
       ,cje.TEXT_11
       ,cje.TEXT_12
       ,cje.TEXT_13
       ,cje.TEXT_14
       ,cje.TEXT_15
       ,cje.TEXT_16
       ,cje.TEXT_17
       ,cje.TEXT_18
       ,cje.TEXT_19
       ,cje.TEXT_20
       ,cje.VALUE_1
       ,cje.VALUE_2
       ,cje.VALUE_3
       ,cje.VALUE_4
       ,cje.VALUE_5
       ,cje.VALUE_6
       ,cje.VALUE_7
       ,cje.VALUE_8
       ,cje.VALUE_9
       ,cje.VALUE_10
       ,cje.DATE_1
       ,cje.DATE_2
       ,cje.DATE_3
       ,cje.DATE_4
       ,cje.DATE_5
       ,cje.DATE_6
       ,cje.DATE_7
       ,cje.DATE_8
       ,cje.DATE_9
       ,cje.DATE_10
       ,cje.REF_OBJECT_ID_1
       ,cje.REF_OBJECT_ID_2
       ,cje.REF_OBJECT_ID_3
       ,cje.REF_OBJECT_ID_4
       ,cje.REF_OBJECT_ID_5
       ,cje.REF_OBJECT_ID_6
       ,cje.REF_OBJECT_ID_7
       ,cje.REF_OBJECT_ID_8
       ,cje.REF_OBJECT_ID_9
       ,cje.REF_OBJECT_ID_10,
       dfdc.to_id id,
       mapping_type,
       doc.object,
       mapping_id,
       doc.process_date DAYTIME,
       doc_conn.from_type other_type,
       doc_conn.from_reference_id other_ref_id,
       DECODE(
          ec_cost_mapping_version.journal_entry_source(dfdc.mapping_id,doc.process_date,'<='),
                 'IFAC','IFAC_JOURNAL_ENTRY','CLASS','CONT_DOCUMENT', mapping_type)
                  other_mapping_type,
       dfdc.from_id other_id,
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
 WHERE from_id != 'CLASS_MAPPING'
   AND doc.type = 'CONT_JOURNAL_ENTRY'
   AND doc.reference_id = doc_conn.to_reference_id
   AND doc.type = doc_conn.to_type
   AND dfdc.connection_id = doc_conn.connection_id
   AND doc_conn.to_type = 'CONT_JOURNAL_ENTRY'
   AND dfdc.mapping_type IN ('JOURNAL_MAPPING','CLASS')
   AND to_char(cje.journal_entry_no) = dfdc.to_id
UNION ALL
SELECT
       doc.reference_id,
       doc.type,
       'IN' direction,
       'CONT_JOURNAL_ENTRY' CA_CLASS,
       --ATTRIBUTE CA_ATTRIBUTE,
       cje.qty_1,
       cje.Amount,
       cje.JOURNAL_ENTRY_NO
       ,cje.COMPANY_CODE
       ,cje.FISCAL_YEAR
       ,cje.PERIOD
       ,cje.CONTRACT_CODE
       ,cje.DATASET
       ,cje.LINE_ITEM_KEY
       ,cje.POSTING_KEY
       ,cje.ACCOUNT_TYPE
       ,cje.DEBIT_CREDIT_CODE
       ,cje.TAX_CODE
       ,cje.TAX_AMOUNT
       ,cje.UOM1_CODE
       ,cje.DOCUMENT_TYPE
       ,cje.FIN_ACCOUNT_CODE
       ,cje.FIN_COST_OBJECT_CODE
       ,cje.FIN_COST_CENTER_CODE
       ,cje.FIN_REVENUE_ORDER_CODE
       ,cje.FIN_WBS_CODE
       ,cje.MATERIAL
       ,cje.PLANT
       ,cje.JOINT_VENTURE
       ,cje.RECOVERY_IND
       ,cje.EQUITY_GROUP
       ,cje.PROFIT_CENTER_CODE
       ,cje.FIN_WBS_DESCR
       ,cje.FIN_ACCOUNT_DESCR
       ,cje.EXPENDITURE_TYPE
       ,cje.TRANSACTION_TYPE
       ,cje.CURRENCY_CODE
       ,cje.PERIOD_CODE
       ,cje.TEXT_1
       ,cje.TEXT_2
       ,cje.TEXT_3
       ,cje.TEXT_4
       ,cje.TEXT_5
       ,cje.TEXT_6
       ,cje.TEXT_7
       ,cje.TEXT_8
       ,cje.TEXT_9
       ,cje.TEXT_10
       ,cje.TEXT_11
       ,cje.TEXT_12
       ,cje.TEXT_13
       ,cje.TEXT_14
       ,cje.TEXT_15
       ,cje.TEXT_16
       ,cje.TEXT_17
       ,cje.TEXT_18
       ,cje.TEXT_19
       ,cje.TEXT_20
       ,cje.VALUE_1
       ,cje.VALUE_2
       ,cje.VALUE_3
       ,cje.VALUE_4
       ,cje.VALUE_5
       ,cje.VALUE_6
       ,cje.VALUE_7
       ,cje.VALUE_8
       ,cje.VALUE_9
       ,cje.VALUE_10
       ,cje.DATE_1
       ,cje.DATE_2
       ,cje.DATE_3
       ,cje.DATE_4
       ,cje.DATE_5
       ,cje.DATE_6
       ,cje.DATE_7
       ,cje.DATE_8
       ,cje.DATE_9
       ,cje.DATE_10
       ,cje.REF_OBJECT_ID_1
       ,cje.REF_OBJECT_ID_2
       ,cje.REF_OBJECT_ID_3
       ,cje.REF_OBJECT_ID_4
       ,cje.REF_OBJECT_ID_5
       ,cje.REF_OBJECT_ID_6
       ,cje.REF_OBJECT_ID_7
       ,cje.REF_OBJECT_ID_8
       ,cje.REF_OBJECT_ID_9
       ,cje.REF_OBJECT_ID_10,
       dfdc.to_id id,
       mapping_type,
       doc.object,
       mapping_ID,
       doc.process_date DAYTIME,
       'CLASS_MAPPING' other_type,
       doc.reference_id other_ref_id,
       'JOURNAL_MAPPING' other_mapping_type,
       to_char(JOURNAL_ENTRY_NO) other_id,
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