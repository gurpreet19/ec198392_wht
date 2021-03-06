CREATE OR REPLACE EDITIONABLE TRIGGER "I_IFAC_DOCUMENT" 
INSTEAD OF INSERT ON V_IFAC_DOCUMENT
FOR EACH ROW

DECLARE

  lrec IFAC_DOCUMENT%ROWTYPE;

BEGIN


lrec.CONTRACT_CODE	:= :new.CONTRACT_CODE;
lrec.CONTRACT_ID	:= :new.CONTRACT_ID;
lrec.DAYTIME	:= :new.DAYTIME;
lrec.DOCUMENT_KEY	:= :new.DOCUMENT_KEY;
lrec.EXT_DOC_KEY	:= :new.EXT_DOC_KEY;
lrec.CONTRACT_DOC_ID	:= :new.CONTRACT_DOC_ID;
lrec.CONTRACT_DOC_CODE	:= :new.CONTRACT_DOC_CODE;
lrec.DOCUMENT_TYPE	:= :new.DOCUMENT_TYPE;
lrec.PRODUCTION_PERIOD := :new.production_period;
lrec.CONTRACT_NAME	:= :new.CONTRACT_NAME;
lrec.PRECEDING_DOCUMENT_KEY	:= :new.PRECEDING_DOCUMENT_KEY;
lrec.REVERSAL_CODE	:= :new.REVERSAL_CODE;
lrec.DOC_TEMPLATE_ID	:= :new.DOC_TEMPLATE_ID;
lrec.DOC_TEMPLATE_CODE	:= :new.DOC_TEMPLATE_CODE;
lrec.INV_DOC_TEMPLATE_ID	:= :new.INV_DOC_TEMPLATE_ID;
lrec.INV_DOC_TEMPLATE_CODE	:= :new.INV_DOC_TEMPLATE_CODE;
lrec.DOC_TEMPLATE_NAME	:= :new.DOC_TEMPLATE_NAME;
lrec.INV_DOC_TEMPLATE_NAME	:= :new.INV_DOC_TEMPLATE_NAME;
lrec.CUR_DOC_TEMPLATE_NAME	:= :new.CUR_DOC_TEMPLATE_NAME;
lrec.PERFORM_CALC_IND	:= :new.PERFORM_CALC_IND;
lrec.REVERSAL_DATE	:= :new.REVERSAL_DATE;
lrec.TRANSFER_DATE	:= :new.TRANSFER_DATE;
lrec.BOOKING_DATE	:= :new.BOOKING_DATE;
lrec.REV_ACCRUAL_DATE	:= :new.REV_ACCRUAL_DATE;
lrec.SET_TO_BOOKED_DATE	:= :new.SET_TO_BOOKED_DATE;
lrec.ACTUAL_REVERSAL_DATE	:= :new.ACTUAL_REVERSAL_DATE;
lrec.DOCUMENT_NUMBER	:= :new.DOCUMENT_NUMBER;
lrec.BOOK_DOCUMENT_IND	:= :new.BOOK_DOCUMENT_IND;
lrec.STATUS_CODE	:= :new.STATUS_CODE;
lrec.REFERENCE	:= :new.REFERENCE;
lrec.CONTRACT_REFERENCE	:= :new.CONTRACT_REFERENCE;
lrec.OUR_CONTACT	:= :new.OUR_CONTACT;
lrec.OUR_CONTACT_PHONE	:= :new.OUR_CONTACT_PHONE;
lrec.YOUR_CONTACT	:= :new.YOUR_CONTACT;
lrec.AMOUNT_IN_WORDS_IND	:= :new.AMOUNT_IN_WORDS_IND;
lrec.AMOUNT_IN_WORDS	:= :new.AMOUNT_IN_WORDS;
lrec.CONTRACT_AREA_ID	:= :new.CONTRACT_AREA_ID;
lrec.CONTRACT_AREA_CODE	:= :new.CONTRACT_AREA_CODE;
lrec.CONTRACT_GROUP_ID	:= :new.CONTRACT_GROUP_ID;
lrec.CONTRACT_GROUP_CODE	:= :new.CONTRACT_GROUP_CODE;
lrec.CONTRACT_TERM_CODE	:= :new.CONTRACT_TERM_CODE;
lrec.OWNER_COMPANY_ID	:= :new.OWNER_COMPANY_ID;
lrec.OWNER_COMPANY_CODE	:= :new.OWNER_COMPANY_CODE;
lrec.BOOKING_CURRENCY_ID  := :new.BOOKING_CURRENCY_ID;
lrec.BOOKING_CURRENCY_CODE  := :new.BOOKING_CURRENCY_CODE;
lrec.MEMO_CURRENCY_ID  := :new.MEMO_CURRENCY_ID;
lrec.MEMO_CURRENCY_CODE  := :new.MEMO_CURRENCY_CODE;
lrec.PRICE_BASIS  := :new.PRICE_BASIS;
lrec.DOC_BOOKING_VALUE  := :new.DOC_BOOKING_VALUE;
lrec.DOC_BOOKING_VAT  := :new.DOC_BOOKING_VAT;
lrec.DOC_BOOKING_TOTAL  := :new.DOC_BOOKING_TOTAL;
lrec.DOC_MEMO_VALUE  := :new.DOC_MEMO_VALUE;
lrec.DOC_MEMO_VAT  := :new.DOC_MEMO_VAT;
lrec.DOC_MEMO_TOTAL  := :new.DOC_MEMO_TOTAL;
lrec.DOC_DATE_CAL_COLL_ID  := :new.DOC_DATE_CAL_COLL_ID;
lrec.DOC_DATE_CAL_COLL_CODE  := :new.DOC_DATE_CAL_COLL_CODE;
lrec.DOC_DATE_TERM_ID  := :new.DOC_DATE_TERM_ID;
lrec.DOC_DATE_TERM_CODE  := :new.DOC_DATE_TERM_CODE;
lrec.DOC_RECEIVED_BASE_CODE  := :new.DOC_RECEIVED_BASE_CODE;
lrec.DOC_RECEIVED_TERM_CODE  := :new.DOC_RECEIVED_TERM_CODE;
lrec.DOC_RECEIVED_TERM_ID  := :new.DOC_RECEIVED_TERM_ID;
lrec.DOC_REC_CAL_COLL_ID  := :new.DOC_REC_CAL_COLL_ID;
lrec.DOC_REC_CAL_COLL_CODE  := :new.DOC_REC_CAL_COLL_CODE;
lrec.DEBIT_CREDIT_IND  := :new.DEBIT_CREDIT_IND;
lrec.USE_CURRENCY_100_IND  := :new.USE_CURRENCY_100_IND;
lrec.PAYMENT_TERM_ID  := :new.PAYMENT_TERM_ID;
lrec.PAYMENT_TERM_CODE  := :new.PAYMENT_TERM_CODE;
lrec.PAYMENT_TERM_NAME  := :new.PAYMENT_TERM_NAME;
lrec.PAYMENT_DUE_BASE_DATE  := :new.PAYMENT_DUE_BASE_DATE;
lrec.PAY_DATE  := :new.PAY_DATE;
lrec.PAY_TERM_DAYS  := :new.PAY_TERM_DAYS;
lrec.PAYMENT_CAL_COLL_ID  := :new.PAYMENT_CAL_COLL_ID;
lrec.PAYMENT_CAL_COLL_CODE  := :new.PAYMENT_CAL_COLL_CODE;
lrec.PAYMENT_TERM_BASE_CODE  := :new.PAYMENT_TERM_BASE_CODE;
lrec.FINANCIAL_CODE  := :new.FINANCIAL_CODE;
lrec.SEND_UNIT_PRICE_IND  := :new.SEND_UNIT_PRICE_IND;
lrec.FIN_INTERFACE_FILE  := :new.FIN_INTERFACE_FILE;
lrec.BOOKING_PERIOD  := :new.BOOKING_PERIOD;
lrec.TAXABLE_IND  := :new.TAXABLE_IND;
lrec.BANK_DETAILS_LEVEL_CODE  := :new.BANK_DETAILS_LEVEL_CODE;
lrec.INT_BASE_AMOUNT_SRC  := :new.INT_BASE_AMOUNT_SRC;
lrec.DOCUMENT_CONCEPT  := :new.DOCUMENT_CONCEPT;
lrec.DOCUMENT_RECEIVED_DATE  := :new.DOCUMENT_RECEIVED_DATE;
lrec.DOC_RECEIVED_BASE_DATE  := :new.DOC_RECEIVED_BASE_DATE;
lrec.DOC_NUMBER_FORMAT_ACCR  := :new.DOC_NUMBER_FORMAT_ACCR;
lrec.DOC_NUMBER_FORMAT_FINAL  := :new.DOC_NUMBER_FORMAT_FINAL;
lrec.DOC_SEQ_ACCRUAL_ID  := :new.DOC_SEQ_ACCRUAL_ID;
lrec.DOC_SEQ_ACCRUAL_CODE  := :new.DOC_SEQ_ACCRUAL_CODE;
lrec.DOC_SEQ_FINAL_ID  := :new.DOC_SEQ_FINAL_ID;
lrec.DOC_SEQ_FINAL_CODE  := :new.DOC_SEQ_FINAL_CODE;
lrec.DOC_GROUP_TOTAL  := :new.DOC_GROUP_TOTAL;
lrec.DOC_GROUP_VALUE  := :new.DOC_GROUP_VALUE;
lrec.DOC_GROUP_VAT  := :new.DOC_GROUP_VAT;
lrec.DOC_LOCAL_TOTAL  := :new.DOC_LOCAL_TOTAL;
lrec.DOC_LOCAL_VALUE  := :new.DOC_LOCAL_VALUE;
lrec.DOC_LOCAL_VAT  := :new.DOC_LOCAL_VAT;
lrec.REVERSAL_IND  := :new.REVERSAL_IND;
lrec.PAYMENT_SCHEME_ID  := :new.PAYMENT_SCHEME_ID;
lrec.PAYMENT_SCHEME_CODE  := :new.PAYMENT_SCHEME_CODE;
lrec.ACTION_CODE  := :new.ACTION_CODE;
lrec.ERP_FEEDBACK_DATE  := :new.ERP_FEEDBACK_DATE;
lrec.ERP_FEEDBACK_ERROR_MESS  := :new.ERP_FEEDBACK_ERROR_MESS;
lrec.ERP_FEEDBACK_REF  := :new.ERP_FEEDBACK_REF;
lrec.ERP_FEEDBACK_STATUS  := :new.ERP_FEEDBACK_STATUS;
lrec.SYSTEM_ACTION_CODE  := :new.SYSTEM_ACTION_CODE;
lrec.USER_ACTION_CODE  := :new.USER_ACTION_CODE;
lrec.COMMENTS  := :new.COMMENTS;
lrec.VALUE_1  := :new.VALUE_1;
lrec.VALUE_2  := :new.VALUE_2;
lrec.VALUE_3  := :new.VALUE_3;
lrec.VALUE_4  := :new.VALUE_4;
lrec.VALUE_5  := :new.VALUE_5;
lrec.VALUE_6  := :new.VALUE_6;
lrec.VALUE_7  := :new.VALUE_7;
lrec.VALUE_8  := :new.VALUE_8;
lrec.VALUE_9  := :new.VALUE_9;
lrec.VALUE_10  := :new.VALUE_10;
lrec.TEXT_1  := :new.TEXT_1;
lrec.TEXT_2  := :new.TEXT_2;
lrec.TEXT_3  := :new.TEXT_3;
lrec.TEXT_4  := :new.TEXT_4;
lrec.TEXT_5  := :new.TEXT_5;
lrec.TEXT_6  := :new.TEXT_6;
lrec.TEXT_7  := :new.TEXT_7;
lrec.TEXT_8  := :new.TEXT_8;
lrec.TEXT_9  := :new.TEXT_9;
lrec.TEXT_10  := :new.TEXT_10;
lrec.DATE_1  := :new.DATE_1;
lrec.DATE_2  := :new.DATE_2;
lrec.DATE_3  := :new.DATE_3;
lrec.DATE_4  := :new.DATE_4;
lrec.DATE_5  := :new.DATE_5;
lrec.DATE_6  := :new.DATE_6;
lrec.DATE_7  := :new.DATE_7;
lrec.DATE_8  := :new.DATE_8;
lrec.DATE_9  := :new.DATE_9;
lrec.DATE_10  := :new.DATE_10;
lrec.REF_OBJECT_ID_1  := :new.REF_OBJECT_ID_1;
lrec.REF_OBJECT_ID_2  := :new.REF_OBJECT_ID_2;
lrec.REF_OBJECT_ID_3  := :new.REF_OBJECT_ID_3;
lrec.REF_OBJECT_ID_4  := :new.REF_OBJECT_ID_4;
lrec.REF_OBJECT_ID_5  := :new.REF_OBJECT_ID_5;




  Ecdp_Inbound_Interface.ReceiveIfacDocRecord(lrec, USER, Ecdp_Timestamp.getCurrentSysdate);

END;
