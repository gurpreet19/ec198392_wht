CREATE OR REPLACE FORCE EDITIONABLE VIEW "V_DSF_DETAIL_IFAC_MAPPING" ("REFERENCE_ID", "TYPE", "DIRECTION", "CA_CLASS", "QTY_1", "AMOUNT", "ID", "MAPPING_TYPE", "OBJECT_ID", "MAPPING_ID", "DAYTIME", "OTHER_TYPE", "OTHER_REF_ID", "OTHER_ID", "OTHER_MAPPING_TYPE", "RECORD_STATUS", "CREATED_BY", "CREATED_DATE", "LAST_UPDATED_BY", "LAST_UPDATED_DATE", "REV_NO", "REV_TEXT", "JOURNAL_ENTRY_NO", "COMPANY_CODE", "FISCAL_YEAR", "PERIOD", "CONTRACT_CODE", "DATASET", "LINE_ITEM_KEY", "POSTING_KEY", "ACCOUNT_TYPE", "DEBIT_CREDIT_CODE", "TAX_CODE", "TAX_AMOUNT", "UOM1_CODE", "DOCUMENT_TYPE", "FIN_ACCOUNT_CODE", "FIN_COST_OBJECT_CODE", "FIN_COST_CENTER_CODE", "FIN_REVENUE_ORDER_CODE", "FIN_WBS_CODE", "MATERIAL", "PLANT", "JOINT_VENTURE", "RECOVERY_IND", "EQUITY_GROUP", "PROFIT_CENTER_CODE", "FIN_WBS_DESCR", "FIN_ACCOUNT_DESCR", "EXPENDITURE_TYPE", "TRANSACTION_TYPE", "CURRENCY_CODE", "PERIOD_CODE", "SOURCE_DOC_NAME", "SOURCE_DOC_VER", "IS_MAX_SOURCE_DOC_VER_IND", "TRANS_INVENTORY_CODE", "TRANS_INVENTORY_ID", "TEXT_1", "TEXT_2", "TEXT_3", "TEXT_4", "TEXT_5", "TEXT_6", "TEXT_7", "TEXT_8", "TEXT_9", "TEXT_10", "TEXT_11", "TEXT_12", "TEXT_13", "TEXT_14", "TEXT_15", "TEXT_16", "TEXT_17", "TEXT_18", "TEXT_19", "TEXT_20", "VALUE_1", "VALUE_2", "VALUE_3", "VALUE_4", "VALUE_5", "VALUE_6", "VALUE_7", "VALUE_8", "VALUE_9", "VALUE_10", "DATE_1", "DATE_2", "DATE_3", "DATE_4", "DATE_5", "DATE_6", "DATE_7", "DATE_8", "DATE_9", "DATE_10", "REF_OBJECT_ID_1", "REF_OBJECT_ID_2", "REF_OBJECT_ID_3", "REF_OBJECT_ID_4", "REF_OBJECT_ID_5", "REF_OBJECT_ID_6", "REF_OBJECT_ID_7", "REF_OBJECT_ID_8", "REF_OBJECT_ID_9", "REF_OBJECT_ID_10", "TO_ID", "FROM_ID", "CONNECTION_ID", "COMMENTS") AS 
  SELECT
       doc.reference_id,
       doc.type,
       'OUT' direction,
       'IFAC_JOURNAL_ENTRY' CA_CLASS,
       --ATTRIBUTE CA_ATTRIBUTE,
       --OBJECT_ID,
       ije.qty_1,
       ije.Amount,
       dfdc.from_id id,
       mapping_type,
       'NONE' object_id,
       dfdc.mapping_id,
       doc.process_date DAYTIME,
       doc_conn.to_type other_type,
       doc_conn.to_reference_id other_ref_id,
       dfdc.to_id other_id,
       'JOURNAL_MAPPING' other_mapping_type,
        to_char(null) record_status,
        to_char(null) created_by,
        to_date(null) created_date,
        to_char(null) last_updated_by,
        to_date(null) last_updated_date,
        to_number(null) rev_no,
        to_char(null) rev_text
		,ije.JOURNAL_ENTRY_NO
		 ,ije.COMPANY_CODE
		 ,ije.FISCAL_YEAR
		 ,ije.PERIOD
		 ,ije.CONTRACT_CODE
		 ,ije.DATASET
		 ,ije.LINE_ITEM_KEY
		 ,ije.POSTING_KEY
		 ,ije.ACCOUNT_TYPE
		 ,ije.DEBIT_CREDIT_CODE
		 ,ije.TAX_CODE
		 ,ije.TAX_AMOUNT
		 ,ije.UOM1_CODE
		 ,ije.DOCUMENT_TYPE
		 ,ije.FIN_ACCOUNT_CODE
		 ,ije.FIN_COST_OBJECT_CODE
		 ,ije.FIN_COST_CENTER_CODE
		 ,ije.FIN_REVENUE_ORDER_CODE
		 ,ije.FIN_WBS_CODE
		 ,ije.MATERIAL
		 ,ije.PLANT
		 ,ije.JOINT_VENTURE
		 ,ije.RECOVERY_IND
		 ,ije.EQUITY_GROUP
		 ,ije.PROFIT_CENTER_CODE
		 ,ije.FIN_WBS_DESCR
		 ,ije.FIN_ACCOUNT_DESCR
		 ,ije.EXPENDITURE_TYPE
		 ,ije.TRANSACTION_TYPE
		 ,ije.CURRENCY_CODE
		 ,ije.PERIOD_CODE
		 ,ije.SOURCE_DOC_NAME
		 ,ije.SOURCE_DOC_VER
		 ,ije.IS_MAX_SOURCE_DOC_VER_IND
		 ,ije.TRANS_INVENTORY_CODE
		 ,ije.TRANS_INVENTORY_ID
		 ,ije.TEXT_1
		 ,ije.TEXT_2
		 ,ije.TEXT_3
		 ,ije.TEXT_4
		 ,ije.TEXT_5
		 ,ije.TEXT_6
		 ,ije.TEXT_7
		 ,ije.TEXT_8
		 ,ije.TEXT_9
		 ,ije.TEXT_10
		 ,ije.TEXT_11
		 ,ije.TEXT_12
		 ,ije.TEXT_13
		 ,ije.TEXT_14
		 ,ije.TEXT_15
		 ,ije.TEXT_16
		 ,ije.TEXT_17
		 ,ije.TEXT_18
		 ,ije.TEXT_19
		 ,ije.TEXT_20
		 ,ije.VALUE_1
		 ,ije.VALUE_2
		 ,ije.VALUE_3
		 ,ije.VALUE_4
		 ,ije.VALUE_5
		 ,ije.VALUE_6
		 ,ije.VALUE_7
		 ,ije.VALUE_8
		 ,ije.VALUE_9
		 ,ije.VALUE_10
		 ,ije.DATE_1
		 ,ije.DATE_2
		 ,ije.DATE_3
		 ,ije.DATE_4
		 ,ije.DATE_5
		 ,ije.DATE_6
		 ,ije.DATE_7
		 ,ije.DATE_8
		 ,ije.DATE_9
		 ,ije.DATE_10
		 ,ije.REF_OBJECT_ID_1
		 ,ije.REF_OBJECT_ID_2
		 ,ije.REF_OBJECT_ID_3
		 ,ije.REF_OBJECT_ID_4
		 ,ije.REF_OBJECT_ID_5
		 ,ije.REF_OBJECT_ID_6
		 ,ije.REF_OBJECT_ID_7
		 ,ije.REF_OBJECT_ID_8
		 ,ije.REF_OBJECT_ID_9
		 ,ije.REF_OBJECT_ID_10
     ,dfdc.TO_ID
     ,dfdc.From_Id
     ,dfdc.Connection_Id,
     dfdc.comments
  FROM IFAC_JOURNAL_ENTRY ije,
       DATASET_FLOW_DETAIL_CONN dfdc,
       DATASET_FLOW_DOC_CONN doc_conn,
       DATASET_FLOW_DOCUMENT doc
 WHERE doc.type = 'IFAC_JOURNAL_ENTRY'
   AND doc.reference_id = doc_conn.from_reference_id
   AND doc.type = doc_conn.from_type
   AND dfdc.connection_id = doc_conn.connection_id
   AND dfdc.mapping_type = 'JOURNAL_MAPPING'
   AND to_char(ije.journal_entry_no) = dfdc.from_id