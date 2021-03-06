CREATE OR REPLACE TYPE "T_TRANS_INV" IS OBJECT (
	object_id varchar2(32)
   ,SORT_ITEM NUMBER
   ,REPORT_LEVEL VARCHAR2(1000)
   ,PROD_STREAM_NAME               VARCHAR2(1000)
   ,INVENTORY_NAME           VARCHAR2(1000)
   ,Country           VARCHAR2(1000)
   ,DELIVERY_POINT      VARCHAR2(1000)
   ,REPORT_VISIBLE          VARCHAR2(1000)
   ,TRANSACTION_TAG         VARCHAR2(1000)
   ,LAYER_MONTH     DATE
   ,PROD_DATE                           DATE
   ,DIM_1          VARCHAR2(1000)
   ,DIM_2          VARCHAR2(1000)
   ,REPORT_VALUE            NUMBER
   ,COLUMN_NAME   VARCHAR2(1000)
   ,daytime date
   ,RUN_NO NUMBER
   ,TEMPLATE_CODE VARCHAR2(100)
)
;