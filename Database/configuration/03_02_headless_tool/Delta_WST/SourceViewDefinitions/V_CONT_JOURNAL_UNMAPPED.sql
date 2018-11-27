CREATE OR REPLACE FORCE EDITIONABLE VIEW "V_CONT_JOURNAL_UNMAPPED" ("TRG_DOC_KEY", "TRG_DATASET", "TRG_RECORD_STATUS", "JOURNAL_ENTRY_NO", "COMPANY_CODE", "FISCAL_YEAR", "DAYTIME", "PERIOD", "CONTRACT_CODE", "DATASET", "LINE_ITEM_KEY", "POSTING_KEY", "ACCOUNT_TYPE", "DEBIT_CREDIT_CODE", "TAX_CODE", "AMOUNT", "TAX_AMOUNT", "QTY_1", "UOM1_CODE", "DOCUMENT_TYPE", "FIN_ACCOUNT_CODE", "FIN_COST_OBJECT_CODE", "FIN_COST_CENTER_CODE", "FIN_REVENUE_ORDER_CODE", "FIN_WBS_CODE", "MATERIAL", "PLANT", "JOINT_VENTURE", "RECOVERY_IND", "EQUITY_GROUP", "PROFIT_CENTER_CODE", "FIN_WBS_DESCR", "FIN_ACCOUNT_DESCR", "EXPENDITURE_TYPE", "TRANSACTION_TYPE", "CURRENCY_CODE", "PERIOD_CODE", "COMMENTS", "SOURCE_DOC_NAME", "SOURCE_DOC_VER", "IS_MAX_SOURCE_DOC_VER_IND", "TEXT_1", "TEXT_2", "TEXT_3", "TEXT_4", "TEXT_5", "TEXT_6", "TEXT_7", "TEXT_8", "TEXT_9", "TEXT_10", "TEXT_11", "TEXT_12", "TEXT_13", "TEXT_14", "TEXT_15", "TEXT_16", "TEXT_17", "TEXT_18", "TEXT_19", "TEXT_20", "VALUE_1", "VALUE_2", "VALUE_3", "VALUE_4", "VALUE_5", "VALUE_6", "VALUE_7", "VALUE_8", "VALUE_9", "VALUE_10", "DATE_1", "DATE_2", "DATE_3", "DATE_4", "DATE_5", "DATE_6", "DATE_7", "DATE_8", "DATE_9", "DATE_10", "REF_OBJECT_ID_1", "REF_OBJECT_ID_2", "REF_OBJECT_ID_3", "REF_OBJECT_ID_4", "REF_OBJECT_ID_5", "REF_OBJECT_ID_6", "REF_OBJECT_ID_7", "REF_OBJECT_ID_8", "REF_OBJECT_ID_9", "REF_OBJECT_ID_10", "RECORD_STATUS", "CREATED_BY", "CREATED_DATE", "LAST_UPDATED_BY", "LAST_UPDATED_DATE", "REV_NO", "REV_TEXT", "APPROVAL_BY", "APPROVAL_DATE", "APPROVAL_STATE", "REC_ID") AS 
  SELECT DOC.DOCUMENT_KEY TRG_DOC_KEY,
       DOC.DATASET TRG_DATASET,
       DOC.RECORD_STATUS TRG_RECORD_STATUS,
        UNMAPPED.JOURNAL_ENTRY_NO  ,
        UNMAPPED.COMPANY_CODE  ,
        UNMAPPED.FISCAL_YEAR  ,
        UNMAPPED.DAYTIME  ,
        UNMAPPED.PERIOD  ,
        UNMAPPED.CONTRACT_CODE  ,
        UNMAPPED.DATASET  ,
        UNMAPPED.LINE_ITEM_KEY  ,
        UNMAPPED.POSTING_KEY  ,
        UNMAPPED.ACCOUNT_TYPE  ,
        UNMAPPED.DEBIT_CREDIT_CODE  ,
        UNMAPPED.TAX_CODE  ,
        UNMAPPED.AMOUNT  ,
        UNMAPPED.TAX_AMOUNT  ,
        UNMAPPED.QTY_1  ,
        UNMAPPED.UOM1_CODE  ,
        UNMAPPED.DOCUMENT_TYPE  ,
        UNMAPPED.FIN_ACCOUNT_CODE  ,
        UNMAPPED.FIN_COST_OBJECT_CODE  ,
        UNMAPPED.FIN_COST_CENTER_CODE  ,
        UNMAPPED.FIN_REVENUE_ORDER_CODE  ,
        UNMAPPED.FIN_WBS_CODE  ,
        UNMAPPED.MATERIAL  ,
        UNMAPPED.PLANT  ,
        UNMAPPED.JOINT_VENTURE  ,
        UNMAPPED.RECOVERY_IND  ,
        UNMAPPED.EQUITY_GROUP  ,
        UNMAPPED.PROFIT_CENTER_CODE  ,
        UNMAPPED.FIN_WBS_DESCR  ,
        UNMAPPED.FIN_ACCOUNT_DESCR  ,
        UNMAPPED.EXPENDITURE_TYPE  ,
        UNMAPPED.TRANSACTION_TYPE  ,
        UNMAPPED.CURRENCY_CODE  ,
        UNMAPPED.PERIOD_CODE  ,
        UNMAPPED.COMMENTS  ,
        UNMAPPED.SOURCE_DOC_NAME  ,
        UNMAPPED.SOURCE_DOC_VER  ,
        UNMAPPED.IS_MAX_SOURCE_DOC_VER_IND  ,
        UNMAPPED.TEXT_1  ,
        UNMAPPED.TEXT_2  ,
        UNMAPPED.TEXT_3  ,
        UNMAPPED.TEXT_4  ,
        UNMAPPED.TEXT_5  ,
        UNMAPPED.TEXT_6  ,
        UNMAPPED.TEXT_7  ,
        UNMAPPED.TEXT_8  ,
        UNMAPPED.TEXT_9  ,
        UNMAPPED.TEXT_10  ,
        UNMAPPED.TEXT_11  ,
        UNMAPPED.TEXT_12  ,
        UNMAPPED.TEXT_13  ,
        UNMAPPED.TEXT_14  ,
        UNMAPPED.TEXT_15  ,
        UNMAPPED.TEXT_16  ,
        UNMAPPED.TEXT_17  ,
        UNMAPPED.TEXT_18  ,
        UNMAPPED.TEXT_19  ,
        UNMAPPED.TEXT_20  ,
        UNMAPPED.VALUE_1  ,
        UNMAPPED.VALUE_2  ,
        UNMAPPED.VALUE_3  ,
        UNMAPPED.VALUE_4  ,
        UNMAPPED.VALUE_5  ,
        UNMAPPED.VALUE_6  ,
        UNMAPPED.VALUE_7  ,
        UNMAPPED.VALUE_8  ,
        UNMAPPED.VALUE_9  ,
        UNMAPPED.VALUE_10  ,
        UNMAPPED.DATE_1  ,
        UNMAPPED.DATE_2  ,
        UNMAPPED.DATE_3  ,
        UNMAPPED.DATE_4  ,
        UNMAPPED.DATE_5  ,
        UNMAPPED.DATE_6  ,
        UNMAPPED.DATE_7  ,
        UNMAPPED.DATE_8  ,
        UNMAPPED.DATE_9  ,
        UNMAPPED.DATE_10  ,
        UNMAPPED.REF_OBJECT_ID_1  ,
        UNMAPPED.REF_OBJECT_ID_2  ,
        UNMAPPED.REF_OBJECT_ID_3  ,
        UNMAPPED.REF_OBJECT_ID_4  ,
        UNMAPPED.REF_OBJECT_ID_5  ,
        UNMAPPED.REF_OBJECT_ID_6  ,
        UNMAPPED.REF_OBJECT_ID_7  ,
        UNMAPPED.REF_OBJECT_ID_8  ,
        UNMAPPED.REF_OBJECT_ID_9  ,
        UNMAPPED.REF_OBJECT_ID_10  ,
        DOC.RECORD_STATUS  ,
        DOC.CREATED_BY  ,
        DOC.CREATED_DATE  ,
        DOC.LAST_UPDATED_BY  ,
        DOC.LAST_UPDATED_DATE	,
        DOC.REV_NO	,
        DOC.REV_TEXT	,
        DOC.APPROVAL_BY	,
        DOC.APPROVAL_DATE	,
        DOC.APPROVAL_STATE	,
        DOC.REC_ID
  FROM IFAC_JOURNAL_ENTRY UNMAPPED,
       CONT_JOURNAL_ENTRY MAPPED,
       CONT_DOC DOC
 WHERE DOC.DATASET IS NOT NULL
   AND DOC.DOCUMENT_KEY IS NOT NULL
   AND DOC.PERIOD = UNMAPPED.PERIOD
   AND MAPPED.PERIOD (+) = UNMAPPED.PERIOD
   AND MAPPED.REF_JOURNAL_ENTRY_NO (+) = UNMAPPED.JOURNAL_ENTRY_NO
   AND MAPPED.DOCUMENT_KEY IS NULL
   AND UNMAPPED.DATASET = 'COST_LOAD'