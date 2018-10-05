CREATE OR REPLACE EDITIONABLE TRIGGER "I_IFAC_JOURNAL_ENTRY" 
INSTEAD OF INSERT ON V_IFAC_JOURNAL_ENTRY
FOR EACH ROW
DECLARE
    lrec_ifac_record IFAC_JOURNAL_ENTRY%ROWTYPE;
BEGIN
    lrec_ifac_record.JOURNAL_ENTRY_NO             := :NEW.JOURNAL_ENTRY_NO            ;
    lrec_ifac_record.COMPANY_CODE                 := :NEW.COMPANY_CODE                ;
    lrec_ifac_record.FISCAL_YEAR                  := :NEW.FISCAL_YEAR                 ;
    lrec_ifac_record.DAYTIME                      := :NEW.DAYTIME                     ;
    lrec_ifac_record.PERIOD                       := :NEW.PERIOD                      ;
    lrec_ifac_record.CONTRACT_CODE                := :NEW.CONTRACT_CODE               ;
    lrec_ifac_record.DATASET                      := :NEW.DATASET                     ;
    lrec_ifac_record.LINE_ITEM_KEY                := :NEW.LINE_ITEM_KEY               ;
    lrec_ifac_record.POSTING_KEY                  := :NEW.POSTING_KEY                 ;
    lrec_ifac_record.ACCOUNT_TYPE                 := :NEW.ACCOUNT_TYPE                ;
    lrec_ifac_record.DEBIT_CREDIT_CODE            := :NEW.DEBIT_CREDIT_CODE           ;
    lrec_ifac_record.TAX_CODE                     := :NEW.TAX_CODE                    ;
    lrec_ifac_record.AMOUNT                       := :NEW.AMOUNT                      ;
    lrec_ifac_record.TAX_AMOUNT                   := :NEW.TAX_AMOUNT                  ;
    lrec_ifac_record.QTY_1                        := :NEW.QTY_1                       ;
    lrec_ifac_record.UOM1_CODE                    := :NEW.UOM1_CODE                   ;
    lrec_ifac_record.DOCUMENT_TYPE                := :NEW.DOCUMENT_TYPE               ;
    lrec_ifac_record.FIN_ACCOUNT_CODE             := :NEW.FIN_ACCOUNT_CODE            ;
    lrec_ifac_record.FIN_COST_OBJECT_CODE         := :NEW.FIN_COST_OBJECT_CODE        ;
    lrec_ifac_record.FIN_COST_CENTER_CODE         := :NEW.FIN_COST_CENTER_CODE        ;
    lrec_ifac_record.FIN_COST_CENTER_DESCR        := :NEW.FIN_COST_CENTER_DESCR       ;
    lrec_ifac_record.FIN_REVENUE_ORDER_CODE       := :NEW.FIN_REVENUE_ORDER_CODE      ;
    lrec_ifac_record.FIN_REVENUE_ORDER_DESCR      := :NEW.FIN_REVENUE_ORDER_DESCR     ;
    lrec_ifac_record.FIN_WBS_CODE                 := :NEW.FIN_WBS_CODE                ;
    lrec_ifac_record.MATERIAL                     := :NEW.MATERIAL                    ;
    lrec_ifac_record.PLANT                        := :NEW.PLANT                       ;
    lrec_ifac_record.JOINT_VENTURE                := :NEW.JOINT_VENTURE               ;
    lrec_ifac_record.RECOVERY_IND                 := :NEW.RECOVERY_IND                ;
    lrec_ifac_record.EQUITY_GROUP                 := :NEW.EQUITY_GROUP                ;
    lrec_ifac_record.PROFIT_CENTER_CODE           := :NEW.PROFIT_CENTER_CODE          ;
    lrec_ifac_record.FIN_WBS_DESCR                := :NEW.FIN_WBS_DESCR               ;
    lrec_ifac_record.FIN_ACCOUNT_DESCR            := :NEW.FIN_ACCOUNT_DESCR           ;
    lrec_ifac_record.TRANS_INVENTORY_CODE         := :NEW.TRANS_INVENTORY_CODE        ;
    lrec_ifac_record.EXPENDITURE_TYPE             := :NEW.EXPENDITURE_TYPE            ;
    lrec_ifac_record.TRANSACTION_TYPE             := :NEW.TRANSACTION_TYPE            ;
    lrec_ifac_record.CURRENCY_CODE                := :NEW.CURRENCY_CODE               ;
    lrec_ifac_record.PERIOD_CODE                  := :NEW.PERIOD_CODE                 ;
    lrec_ifac_record.COMMENTS                     := :NEW.COMMENTS                    ;
    lrec_ifac_record.SOURCE_DOC_NAME              := :NEW.SOURCE_DOC_NAME             ;
    lrec_ifac_record.SOURCE_DOC_VER               := :NEW.SOURCE_DOC_VER              ;
    lrec_ifac_record.TEXT_1                       := :NEW.TEXT_1                      ;
    lrec_ifac_record.TEXT_2                       := :NEW.TEXT_2                      ;
    lrec_ifac_record.TEXT_3                       := :NEW.TEXT_3                      ;
    lrec_ifac_record.TEXT_4                       := :NEW.TEXT_4                      ;
    lrec_ifac_record.TEXT_5                       := :NEW.TEXT_5                      ;
    lrec_ifac_record.TEXT_6                       := :NEW.TEXT_6                      ;
    lrec_ifac_record.TEXT_7                       := :NEW.TEXT_7                      ;
    lrec_ifac_record.TEXT_8                       := :NEW.TEXT_8                      ;
    lrec_ifac_record.TEXT_9                       := :NEW.TEXT_9                      ;
    lrec_ifac_record.TEXT_10                      := :NEW.TEXT_10                     ;
    lrec_ifac_record.TEXT_11                      := :NEW.TEXT_11                     ;
    lrec_ifac_record.TEXT_12                      := :NEW.TEXT_12                     ;
    lrec_ifac_record.TEXT_13                      := :NEW.TEXT_13                     ;
    lrec_ifac_record.TEXT_14                      := :NEW.TEXT_14                     ;
    lrec_ifac_record.TEXT_15                      := :NEW.TEXT_15                     ;
    lrec_ifac_record.TEXT_16                      := :NEW.TEXT_16                     ;
    lrec_ifac_record.TEXT_17                      := :NEW.TEXT_17                     ;
    lrec_ifac_record.TEXT_18                      := :NEW.TEXT_18                     ;
    lrec_ifac_record.TEXT_19                      := :NEW.TEXT_19                     ;
    lrec_ifac_record.TEXT_20                      := :NEW.TEXT_20                     ;
    lrec_ifac_record.VALUE_1                      := :NEW.VALUE_1                     ;
    lrec_ifac_record.VALUE_2                      := :NEW.VALUE_2                     ;
    lrec_ifac_record.VALUE_3                      := :NEW.VALUE_3                     ;
    lrec_ifac_record.VALUE_4                      := :NEW.VALUE_4                     ;
    lrec_ifac_record.VALUE_5                      := :NEW.VALUE_5                     ;
    lrec_ifac_record.VALUE_6                      := :NEW.VALUE_6                     ;
    lrec_ifac_record.VALUE_7                      := :NEW.VALUE_7                     ;
    lrec_ifac_record.VALUE_8                      := :NEW.VALUE_8                     ;
    lrec_ifac_record.VALUE_9                      := :NEW.VALUE_9                     ;
    lrec_ifac_record.VALUE_10                     := :NEW.VALUE_10                    ;
    lrec_ifac_record.DATE_1                       := :NEW.DATE_1                      ;
    lrec_ifac_record.DATE_2                       := :NEW.DATE_2                      ;
    lrec_ifac_record.DATE_3                       := :NEW.DATE_3                      ;
    lrec_ifac_record.DATE_4                       := :NEW.DATE_4                      ;
    lrec_ifac_record.DATE_5                       := :NEW.DATE_5                      ;
    lrec_ifac_record.DATE_6                       := :NEW.DATE_6                      ;
    lrec_ifac_record.DATE_7                       := :NEW.DATE_7                      ;
    lrec_ifac_record.DATE_8                       := :NEW.DATE_8                      ;
    lrec_ifac_record.DATE_9                       := :NEW.DATE_9                      ;
    lrec_ifac_record.DATE_10                      := :NEW.DATE_10                     ;
    lrec_ifac_record.REF_OBJECT_ID_1              := :NEW.REF_OBJECT_ID_1             ;
    lrec_ifac_record.REF_OBJECT_ID_2              := :NEW.REF_OBJECT_ID_2             ;
    lrec_ifac_record.REF_OBJECT_ID_3              := :NEW.REF_OBJECT_ID_3             ;
    lrec_ifac_record.REF_OBJECT_ID_4              := :NEW.REF_OBJECT_ID_4             ;
    lrec_ifac_record.REF_OBJECT_ID_5              := :NEW.REF_OBJECT_ID_5             ;
    lrec_ifac_record.REF_OBJECT_ID_6              := :NEW.REF_OBJECT_ID_6             ;
    lrec_ifac_record.REF_OBJECT_ID_7              := :NEW.REF_OBJECT_ID_7             ;
    lrec_ifac_record.REF_OBJECT_ID_8              := :NEW.REF_OBJECT_ID_8             ;
    lrec_ifac_record.REF_OBJECT_ID_9              := :NEW.REF_OBJECT_ID_9             ;
    lrec_ifac_record.REF_OBJECT_ID_10             := :NEW.REF_OBJECT_ID_10            ;
    lrec_ifac_record.OBJECT_ID                    := :NEW.OBJECT_ID                   ;
    lrec_ifac_record.PRODUCT_CODE                 := :NEW.PRODUCT_CODE                ;

    ECDP_RR_REVN_MAPPING_INTERFACE.ReceiveJournalEntry(lrec_ifac_record);

END;
