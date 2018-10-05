CREATE OR REPLACE FORCE EDITIONABLE VIEW "V_IFAC_JOURNAL_ENTRY" ("JOURNAL_ENTRY_NO", "COMPANY_CODE", "FISCAL_YEAR", "DAYTIME", "PERIOD", "CONTRACT_CODE", "DATASET", "LINE_ITEM_KEY", "POSTING_KEY", "ACCOUNT_TYPE", "DEBIT_CREDIT_CODE", "TAX_CODE", "AMOUNT", "TAX_AMOUNT", "QTY_1", "UOM1_CODE", "DOCUMENT_TYPE", "FIN_ACCOUNT_CODE", "FIN_COST_OBJECT_CODE", "FIN_COST_CENTER_CODE", "FIN_REVENUE_ORDER_CODE", "FIN_WBS_CODE", "MATERIAL", "PLANT", "JOINT_VENTURE", "RECOVERY_IND", "EQUITY_GROUP", "PROFIT_CENTER_CODE", "FIN_WBS_DESCR", "FIN_ACCOUNT_DESCR", "EXPENDITURE_TYPE", "TRANSACTION_TYPE", "CURRENCY_CODE", "PERIOD_CODE", "COMMENTS", "SOURCE_DOC_NAME", "SOURCE_DOC_VER", "IS_MAX_SOURCE_DOC_VER_IND", "TRANS_INVENTORY_CODE", "TRANS_INVENTORY_ID", "TEXT_1", "TEXT_2", "TEXT_3", "TEXT_4", "TEXT_5", "TEXT_6", "TEXT_7", "TEXT_8", "TEXT_9", "TEXT_10", "TEXT_11", "TEXT_12", "TEXT_13", "TEXT_14", "TEXT_15", "TEXT_16", "TEXT_17", "TEXT_18", "TEXT_19", "TEXT_20", "VALUE_1", "VALUE_2", "VALUE_3", "VALUE_4", "VALUE_5", "VALUE_6", "VALUE_7", "VALUE_8", "VALUE_9", "VALUE_10", "DATE_1", "DATE_2", "DATE_3", "DATE_4", "DATE_5", "DATE_6", "DATE_7", "DATE_8", "DATE_9", "DATE_10", "REF_OBJECT_ID_1", "REF_OBJECT_ID_2", "REF_OBJECT_ID_3", "REF_OBJECT_ID_4", "REF_OBJECT_ID_5", "REF_OBJECT_ID_6", "REF_OBJECT_ID_7", "REF_OBJECT_ID_8", "REF_OBJECT_ID_9", "REF_OBJECT_ID_10", "FIN_COST_CENTER_DESCR", "FIN_REVENUE_ORDER_DESCR", "OBJECT_ID", "PRODUCT_CODE", "RECORD_STATUS", "CREATED_BY", "CREATED_DATE", "LAST_UPDATED_BY", "LAST_UPDATED_DATE", "REV_NO", "REV_TEXT", "APPROVAL_BY", "APPROVAL_DATE", "APPROVAL_STATE", "REC_ID") AS 
  SELECT "JOURNAL_ENTRY_NO","COMPANY_CODE","FISCAL_YEAR","DAYTIME","PERIOD","CONTRACT_CODE","DATASET","LINE_ITEM_KEY","POSTING_KEY","ACCOUNT_TYPE","DEBIT_CREDIT_CODE","TAX_CODE","AMOUNT","TAX_AMOUNT","QTY_1","UOM1_CODE","DOCUMENT_TYPE","FIN_ACCOUNT_CODE","FIN_COST_OBJECT_CODE","FIN_COST_CENTER_CODE","FIN_REVENUE_ORDER_CODE","FIN_WBS_CODE","MATERIAL","PLANT","JOINT_VENTURE","RECOVERY_IND","EQUITY_GROUP","PROFIT_CENTER_CODE","FIN_WBS_DESCR","FIN_ACCOUNT_DESCR","EXPENDITURE_TYPE","TRANSACTION_TYPE","CURRENCY_CODE","PERIOD_CODE","COMMENTS","SOURCE_DOC_NAME","SOURCE_DOC_VER","IS_MAX_SOURCE_DOC_VER_IND","TRANS_INVENTORY_CODE","TRANS_INVENTORY_ID","TEXT_1","TEXT_2","TEXT_3","TEXT_4","TEXT_5","TEXT_6","TEXT_7","TEXT_8","TEXT_9","TEXT_10","TEXT_11","TEXT_12","TEXT_13","TEXT_14","TEXT_15","TEXT_16","TEXT_17","TEXT_18","TEXT_19","TEXT_20","VALUE_1","VALUE_2","VALUE_3","VALUE_4","VALUE_5","VALUE_6","VALUE_7","VALUE_8","VALUE_9","VALUE_10","DATE_1","DATE_2","DATE_3","DATE_4","DATE_5","DATE_6","DATE_7","DATE_8","DATE_9","DATE_10","REF_OBJECT_ID_1","REF_OBJECT_ID_2","REF_OBJECT_ID_3","REF_OBJECT_ID_4","REF_OBJECT_ID_5","REF_OBJECT_ID_6","REF_OBJECT_ID_7","REF_OBJECT_ID_8","REF_OBJECT_ID_9","REF_OBJECT_ID_10","FIN_COST_CENTER_DESCR","FIN_REVENUE_ORDER_DESCR","OBJECT_ID","PRODUCT_CODE","RECORD_STATUS","CREATED_BY","CREATED_DATE","LAST_UPDATED_BY","LAST_UPDATED_DATE","REV_NO","REV_TEXT","APPROVAL_BY","APPROVAL_DATE","APPROVAL_STATE","REC_ID"
    FROM IFAC_JOURNAL_ENTRY