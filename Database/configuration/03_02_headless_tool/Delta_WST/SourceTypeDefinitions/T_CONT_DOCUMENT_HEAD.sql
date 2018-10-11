CREATE OR REPLACE TYPE T_CONT_DOCUMENT IS OBJECT
(
	OBJECT_ID               VARCHAR2(32)
	,DAYTIME                 DATE
	,DOCUMENT_DATE           DATE
	,DOCUMENT_KEY            VARCHAR2(32)
	,CONTRACT_DOC_ID         VARCHAR2(32)
	,DOCUMENT_TYPE           VARCHAR2(32)
	,PRECEDING_DOCUMENT_KEY  VARCHAR2(32)
	,PARENT_DOCUMENT_KEY     VARCHAR2(32)
	,OPEN_USER_ID            VARCHAR2(32)
	,VALID1_USER_ID          VARCHAR2(32)
	,VALID2_USER_ID          VARCHAR2(32)
	,TRANSFER_USER_ID        VARCHAR2(32)
	,BOOKED_USER_ID          VARCHAR2(32)
	,REVERSAL_CODE           VARCHAR2(32)
	,PERFORM_CALC_IND        VARCHAR2(1)
	,REVERSAL_DATE           DATE
	,TRANSFER_DATE           DATE
	,BOOKING_DATE            DATE
	,REV_ACCRUAL_DATE        DATE
	,SET_TO_BOOKED_DATE      DATE
	,ACTUAL_REVERSAL_DATE    DATE
	,DOCUMENT_NUMBER         VARCHAR2(240)
	,BOOK_DOCUMENT_IND       VARCHAR2(1)
	,DOCUMENT_LEVEL_CODE     VARCHAR2(32)
	,STATUS_CODE             VARCHAR2(32)
	,CONTRACT_AREA_CODE      VARCHAR2(32)
	,CONTRACT_GROUP_CODE     VARCHAR2(32)
	,CONTRACT_TERM_CODE      VARCHAR2(32)
	,OWNER_COMPANY_ID        VARCHAR2(32)
	,BOOKING_CURRENCY_ID     VARCHAR2(32)
	,MEMO_CURRENCY_ID        VARCHAR2(32)
	,PRICE_BASIS             VARCHAR2(32)
	,DOC_BOOKING_TOTAL       NUMBER
	,DOC_MEMO_TOTAL          NUMBER
	,PAY_DATE                DATE
	,FINANCIAL_CODE          VARCHAR2(32)
	,FIN_INTERFACE_FILE      VARCHAR2(240)
	,BOOKING_PERIOD          DATE
	,TAXABLE_IND             VARCHAR2(1)
	,INT_BASE_AMOUNT_SRC     VARCHAR2(32)
	,DOCUMENT_CONCEPT        VARCHAR2(32)
	,DOCUMENT_RECEIVED_DATE  DATE
	,DOC_RECEIVED_BASE_DATE  DATE
	,DOC_GROUP_TOTAL         NUMBER
	,DOC_LOCAL_TOTAL         NUMBER
	,REVERSAL_IND            VARCHAR2(1)
	,PAYMENT_SCHEME_ID       VARCHAR2(32)
	,ERP_FEEDBACK_DATE       DATE
	,ERP_FEEDBACK_ERROR_MESS VARCHAR2(2000)
	,ERP_FEEDBACK_REF        VARCHAR2(240)
	,ERP_FEEDBACK_STATUS     VARCHAR2(240)
	,EXT_DOCUMENT_KEY        VARCHAR2(32)
	,PRODUCTION_PERIOD       DATE
	,PROCESSING_PERIOD       DATE
	,SINGLE_PARCEL_DOC_IND   VARCHAR2(1)
	,DOC_SCOPE               VARCHAR2(32)
	,CUSTOMER_ID             VARCHAR2(32)
);