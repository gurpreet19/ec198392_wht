CREATE OR REPLACE FORCE EDITIONABLE VIEW "V_CONT_JS_REPORT" ("OBJECT_ID", "COMPANY_ID", "FISCAL_YEAR", "DAYTIME", "PERIOD", "DOCUMENT_KEY", "LIST_ITEM_KEY", "SUMMARY_SETUP_ID", "DATASET", "FIN_ACCOUNT_ID", "FIN_COST_CENTER_ID", "FIN_COST_OBJECT_ID", "FIN_REVENUE_ORDER_ID", "FIN_WBS_ID", "DEBIT_CREDIT", "ACTUAL_AMOUNT", "AMOUNT_ADJUSTMENT", "ACTUAL_QTY_1", "QTY_ADJUSTMENT", "FORECAST_AMOUNT", "FORECAST_QTY_1", "AMEND_AMOUNT", "AMEND_QTY_1", "UOM1_CODE", "CURRENCY_ID", "TAG", "LABEL", "COMMENTS", "TEXT_1", "TEXT_2", "TEXT_3", "TEXT_4", "TEXT_5", "TEXT_6", "TEXT_7", "TEXT_8", "TEXT_9", "TEXT_10", "VALUE_1", "VALUE_2", "VALUE_3", "VALUE_4", "VALUE_5", "DATE_1", "DATE_2", "DATE_3", "DATE_4", "DATE_5", "REF_OBJECT_ID_1", "REF_OBJECT_ID_2", "REF_OBJECT_ID_3", "REF_OBJECT_ID_4", "REF_OBJECT_ID_5", "UPDATE_CLASS_AMOUNT", "UPDATE_REF_ID_AMOUNT", "UPDATE_CLASS_QTY", "UPDATE_REF_ID_QTY", "PRE_UPDATE_AMOUNT", "PRE_UPDATE_QTY1", "RECORD_STATUS", "CREATED_BY", "CREATED_DATE", "LAST_UPDATED_BY", "LAST_UPDATED_DATE", "REV_NO", "REV_TEXT", "APPROVAL_BY", "APPROVAL_DATE", "APPROVAL_STATE", "REC_ID") AS 
  SELECT "OBJECT_ID","COMPANY_ID","FISCAL_YEAR","DAYTIME","PERIOD","DOCUMENT_KEY","LIST_ITEM_KEY","SUMMARY_SETUP_ID","DATASET","FIN_ACCOUNT_ID","FIN_COST_CENTER_ID","FIN_COST_OBJECT_ID","FIN_REVENUE_ORDER_ID","FIN_WBS_ID","DEBIT_CREDIT","ACTUAL_AMOUNT","AMOUNT_ADJUSTMENT","ACTUAL_QTY_1","QTY_ADJUSTMENT","FORECAST_AMOUNT","FORECAST_QTY_1","AMEND_AMOUNT","AMEND_QTY_1","UOM1_CODE","CURRENCY_ID","TAG","LABEL","COMMENTS","TEXT_1","TEXT_2","TEXT_3","TEXT_4","TEXT_5","TEXT_6","TEXT_7","TEXT_8","TEXT_9","TEXT_10","VALUE_1","VALUE_2","VALUE_3","VALUE_4","VALUE_5","DATE_1","DATE_2","DATE_3","DATE_4","DATE_5","REF_OBJECT_ID_1","REF_OBJECT_ID_2","REF_OBJECT_ID_3","REF_OBJECT_ID_4","REF_OBJECT_ID_5","UPDATE_CLASS_AMOUNT","UPDATE_REF_ID_AMOUNT","UPDATE_CLASS_QTY","UPDATE_REF_ID_QTY","PRE_UPDATE_AMOUNT","PRE_UPDATE_QTY1","RECORD_STATUS","CREATED_BY","CREATED_DATE","LAST_UPDATED_BY","LAST_UPDATED_DATE","REV_NO","REV_TEXT","APPROVAL_BY","APPROVAL_DATE","APPROVAL_STATE","REC_ID" FROM cont_journal_summary js
WHERE js.document_key = ecdp_rr_revn_summary.GetLastAppSummaryDoc(js.object_id, js.summary_setup_id, js.period, ec_cont_doc.inventory_id(js.document_key))