
 -- START PKG_GEN_PKGS.sf_get_functions at:11/15/2018 08.04.28 AM


CREATE or REPLACE PACKAGE RP_REPORT_REF_CONNECTION
IS

   FUNCTION DATE_10(
      P_ID IN NUMBER)
      RETURN DATE;
   FUNCTION DISABLED_IND(
      P_ID IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION DOCUMENT_TYPE(
      P_ID IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION PRODUCT(
      P_ID IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION REF_OBJECT_ID_7(
      P_ID IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION SORT_ORDER(
      P_ID IN NUMBER)
      RETURN NUMBER;
   FUNCTION TEXT_3(
      P_ID IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_BY(
      P_ID IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_STATE(
      P_ID IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION DATASET(
      P_ID IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION REF_OBJECT_ID_4(
      P_ID IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION REF_OBJECT_ID_8(
      P_ID IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION REPORT_REF_ID(
      P_ID IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_5(
      P_ID IN NUMBER)
      RETURN NUMBER;
   FUNCTION DATE_7(
      P_ID IN NUMBER)
      RETURN DATE;
   FUNCTION DATE_9(
      P_ID IN NUMBER)
      RETURN DATE;
   FUNCTION MATERIAL(
      P_ID IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION NEXT_DAYTIME(
      P_ID IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION PREV_EQUAL_DAYTIME(
      P_ID IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION PRODUCT_ID(
      P_ID IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION PROFIT_CENTRE_ID(
      P_ID IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION REF_CLASS(
      P_ID IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION REF_ID(
      P_ID IN NUMBER)
      RETURN NUMBER;
   FUNCTION TEXT_7(
      P_ID IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_8(
      P_ID IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TRANSACTION_TYPE(
      P_ID IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION DATE_3(
      P_ID IN NUMBER)
      RETURN DATE;
   FUNCTION DATE_5(
      P_ID IN NUMBER)
      RETURN DATE;
   FUNCTION NEXT_EQUAL_DAYTIME(
      P_ID IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION REF_OBJECT_ID_2(
      P_ID IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION REF_OBJECT_ID_3(
      P_ID IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION REF_OBJECT_ID_9(
      P_ID IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_1(
      P_ID IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_6(
      P_ID IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_9(
      P_ID IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_6(
      P_ID IN NUMBER)
      RETURN NUMBER;
   FUNCTION COMPANY_ID(
      P_ID IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION DATE_2(
      P_ID IN NUMBER)
      RETURN DATE;
   FUNCTION DIMENSION_IND(
      P_ID IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION END_DATE(
      P_ID IN NUMBER)
      RETURN DATE;
   FUNCTION PREV_DAYTIME(
      P_ID IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION RECORD_STATUS(
      P_ID IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION REF_OBJECT_ID_5(
      P_ID IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION REPORT_REF_CONN_ID(
      P_ID IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION REVERSE_IND(
      P_ID IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TRANS_INV_IND(
      P_ID IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_1(
      P_ID IN NUMBER)
      RETURN NUMBER;
   FUNCTION VAL_COLUMN(
      P_ID IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_DATE(
      P_ID IN NUMBER)
      RETURN DATE;
   FUNCTION DATE_6(
      P_ID IN NUMBER)
      RETURN DATE;
   FUNCTION DOCUMENT_LEVEL(
      P_ID IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION PROD_MTH_IND(
      P_ID IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION QTY_COLUMN(
      P_ID IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION REF_OBJECT_ID_1(
      P_ID IN NUMBER)
      RETURN VARCHAR2;
      TYPE REC_ROW_BY_PK IS RECORD (
         REPORT_REF_CONN_ID VARCHAR2 (32) ,
         REPORT_REF_ID VARCHAR2 (32) ,
         ALT_KEY VARCHAR2 (32) ,
         DAYTIME  DATE ,
         END_DATE  DATE ,
         DOCUMENT_LEVEL VARCHAR2 (32) ,
         PROFIT_CENTRE_ID VARCHAR2 (32) ,
         COMPANY_ID VARCHAR2 (32) ,
         TRANS_INV_IND VARCHAR2 (1) ,
         DIMENSION_IND VARCHAR2 (1) ,
         LAYER_IND VARCHAR2 (1) ,
         TRANS_LINE_IND VARCHAR2 (1) ,
         PROD_MTH_IND VARCHAR2 (1) ,
         DIMENSION_2_IND VARCHAR2 (1) ,
         DISABLED_IND VARCHAR2 (1) ,
         ID NUMBER ,
         REF_ID NUMBER ,
         VAL_COLUMN VARCHAR2 (32) ,
         QTY_COLUMN VARCHAR2 (32) ,
         REVERSE_IND VARCHAR2 (1) ,
         RECORD_STATUS VARCHAR2 (1) ,
         CREATED_BY VARCHAR2 (30) ,
         CREATED_DATE  DATE ,
         LAST_UPDATED_BY VARCHAR2 (30) ,
         LAST_UPDATED_DATE  DATE ,
         REV_NO NUMBER ,
         REV_TEXT VARCHAR2 (2000) ,
         APPROVAL_BY VARCHAR2 (30) ,
         APPROVAL_DATE  DATE ,
         APPROVAL_STATE VARCHAR2 (1) ,
         REC_ID VARCHAR2 (32) ,
         DATASET VARCHAR2 (32) ,
         PRODUCT_ID VARCHAR2 (32) ,
         PRICE_CONCEPT_CODE VARCHAR2 (32) ,
         PRICE_ELEMENT_CODE VARCHAR2 (32) ,
         LINE_ITEM_TYPE VARCHAR2 (32) ,
         DATASET_TYPE VARCHAR2 (32) ,
         SORT_ORDER NUMBER ,
         REF_CLASS VARCHAR2 (32) ,
         DOCUMENT_TYPE VARCHAR2 (240) ,
         MATERIAL VARCHAR2 (240) ,
         PRODUCT VARCHAR2 (240) ,
         TRANSACTION_TYPE VARCHAR2 (240) ,
         TEXT_1 VARCHAR2 (240) ,
         TEXT_2 VARCHAR2 (240) ,
         TEXT_3 VARCHAR2 (240) ,
         TEXT_4 VARCHAR2 (240) ,
         TEXT_5 VARCHAR2 (240) ,
         TEXT_6 VARCHAR2 (240) ,
         TEXT_7 VARCHAR2 (240) ,
         TEXT_8 VARCHAR2 (240) ,
         TEXT_9 VARCHAR2 (240) ,
         TEXT_10 VARCHAR2 (240) ,
         VALUE_1 NUMBER ,
         VALUE_2 NUMBER ,
         VALUE_3 NUMBER ,
         VALUE_4 NUMBER ,
         VALUE_5 NUMBER ,
         VALUE_6 NUMBER ,
         VALUE_7 NUMBER ,
         VALUE_8 NUMBER ,
         VALUE_9 NUMBER ,
         VALUE_10 NUMBER ,
         DATE_1  DATE ,
         DATE_2  DATE ,
         DATE_3  DATE ,
         DATE_4  DATE ,
         DATE_5  DATE ,
         DATE_6  DATE ,
         DATE_7  DATE ,
         DATE_8  DATE ,
         DATE_9  DATE ,
         DATE_10  DATE ,
         REF_OBJECT_ID_1 VARCHAR2 (32) ,
         REF_OBJECT_ID_2 VARCHAR2 (32) ,
         REF_OBJECT_ID_3 VARCHAR2 (32) ,
         REF_OBJECT_ID_4 VARCHAR2 (32) ,
         REF_OBJECT_ID_5 VARCHAR2 (32) ,
         REF_OBJECT_ID_6 VARCHAR2 (32) ,
         REF_OBJECT_ID_7 VARCHAR2 (32) ,
         REF_OBJECT_ID_8 VARCHAR2 (32) ,
         REF_OBJECT_ID_9 VARCHAR2 (32) ,
         REF_OBJECT_ID_10 VARCHAR2 (32)  );
   FUNCTION ROW_BY_PK(
      P_ID IN NUMBER)
      RETURN REC_ROW_BY_PK;
   FUNCTION TEXT_2(
      P_ID IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_4(
      P_ID IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_5(
      P_ID IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_2(
      P_ID IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_3(
      P_ID IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_4(
      P_ID IN NUMBER)
      RETURN NUMBER;
   FUNCTION ALT_KEY(
      P_ID IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION DATASET_TYPE(
      P_ID IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION DATE_4(
      P_ID IN NUMBER)
      RETURN DATE;
   FUNCTION LINE_ITEM_TYPE(
      P_ID IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION PRICE_ELEMENT_CODE(
      P_ID IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION REC_ID(
      P_ID IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION REF_OBJECT_ID_10(
      P_ID IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION REF_OBJECT_ID_6(
      P_ID IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_7(
      P_ID IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_9(
      P_ID IN NUMBER)
      RETURN NUMBER;
   FUNCTION DATE_1(
      P_ID IN NUMBER)
      RETURN DATE;
   FUNCTION DATE_8(
      P_ID IN NUMBER)
      RETURN DATE;
   FUNCTION DAYTIME(
      P_ID IN NUMBER)
      RETURN DATE;
   FUNCTION DIMENSION_2_IND(
      P_ID IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION LAYER_IND(
      P_ID IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION PRICE_CONCEPT_CODE(
      P_ID IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_10(
      P_ID IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TRANS_LINE_IND(
      P_ID IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_10(
      P_ID IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_8(
      P_ID IN NUMBER)
      RETURN NUMBER;

END RP_REPORT_REF_CONNECTION;

/



CREATE or REPLACE PACKAGE BODY RP_REPORT_REF_CONNECTION
IS

   FUNCTION DATE_10(
      P_ID IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_REPORT_REF_CONNECTION.DATE_10      (
         P_ID );
         RETURN ret_value;
   END DATE_10;
   FUNCTION DISABLED_IND(
      P_ID IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_REPORT_REF_CONNECTION.DISABLED_IND      (
         P_ID );
         RETURN ret_value;
   END DISABLED_IND;
   FUNCTION DOCUMENT_TYPE(
      P_ID IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_REPORT_REF_CONNECTION.DOCUMENT_TYPE      (
         P_ID );
         RETURN ret_value;
   END DOCUMENT_TYPE;
   FUNCTION PRODUCT(
      P_ID IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_REPORT_REF_CONNECTION.PRODUCT      (
         P_ID );
         RETURN ret_value;
   END PRODUCT;
   FUNCTION REF_OBJECT_ID_7(
      P_ID IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_REPORT_REF_CONNECTION.REF_OBJECT_ID_7      (
         P_ID );
         RETURN ret_value;
   END REF_OBJECT_ID_7;
   FUNCTION SORT_ORDER(
      P_ID IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_REPORT_REF_CONNECTION.SORT_ORDER      (
         P_ID );
         RETURN ret_value;
   END SORT_ORDER;
   FUNCTION TEXT_3(
      P_ID IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_REPORT_REF_CONNECTION.TEXT_3      (
         P_ID );
         RETURN ret_value;
   END TEXT_3;
   FUNCTION APPROVAL_BY(
      P_ID IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (30) ;
   BEGIN
      ret_value := EC_REPORT_REF_CONNECTION.APPROVAL_BY      (
         P_ID );
         RETURN ret_value;
   END APPROVAL_BY;
   FUNCTION APPROVAL_STATE(
      P_ID IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_REPORT_REF_CONNECTION.APPROVAL_STATE      (
         P_ID );
         RETURN ret_value;
   END APPROVAL_STATE;
   FUNCTION DATASET(
      P_ID IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_REPORT_REF_CONNECTION.DATASET      (
         P_ID );
         RETURN ret_value;
   END DATASET;
   FUNCTION REF_OBJECT_ID_4(
      P_ID IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_REPORT_REF_CONNECTION.REF_OBJECT_ID_4      (
         P_ID );
         RETURN ret_value;
   END REF_OBJECT_ID_4;
   FUNCTION REF_OBJECT_ID_8(
      P_ID IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_REPORT_REF_CONNECTION.REF_OBJECT_ID_8      (
         P_ID );
         RETURN ret_value;
   END REF_OBJECT_ID_8;
   FUNCTION REPORT_REF_ID(
      P_ID IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_REPORT_REF_CONNECTION.REPORT_REF_ID      (
         P_ID );
         RETURN ret_value;
   END REPORT_REF_ID;
   FUNCTION VALUE_5(
      P_ID IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_REPORT_REF_CONNECTION.VALUE_5      (
         P_ID );
         RETURN ret_value;
   END VALUE_5;
   FUNCTION DATE_7(
      P_ID IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_REPORT_REF_CONNECTION.DATE_7      (
         P_ID );
         RETURN ret_value;
   END DATE_7;
   FUNCTION DATE_9(
      P_ID IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_REPORT_REF_CONNECTION.DATE_9      (
         P_ID );
         RETURN ret_value;
   END DATE_9;
   FUNCTION MATERIAL(
      P_ID IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_REPORT_REF_CONNECTION.MATERIAL      (
         P_ID );
         RETURN ret_value;
   END MATERIAL;
   FUNCTION NEXT_DAYTIME(
      P_ID IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_REPORT_REF_CONNECTION.NEXT_DAYTIME      (
         P_ID,
         P_NUM_ROWS );
         RETURN ret_value;
   END NEXT_DAYTIME;
   FUNCTION PREV_EQUAL_DAYTIME(
      P_ID IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_REPORT_REF_CONNECTION.PREV_EQUAL_DAYTIME      (
         P_ID,
         P_NUM_ROWS );
         RETURN ret_value;
   END PREV_EQUAL_DAYTIME;
   FUNCTION PRODUCT_ID(
      P_ID IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_REPORT_REF_CONNECTION.PRODUCT_ID      (
         P_ID );
         RETURN ret_value;
   END PRODUCT_ID;
   FUNCTION PROFIT_CENTRE_ID(
      P_ID IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_REPORT_REF_CONNECTION.PROFIT_CENTRE_ID      (
         P_ID );
         RETURN ret_value;
   END PROFIT_CENTRE_ID;
   FUNCTION REF_CLASS(
      P_ID IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_REPORT_REF_CONNECTION.REF_CLASS      (
         P_ID );
         RETURN ret_value;
   END REF_CLASS;
   FUNCTION REF_ID(
      P_ID IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_REPORT_REF_CONNECTION.REF_ID      (
         P_ID );
         RETURN ret_value;
   END REF_ID;
   FUNCTION TEXT_7(
      P_ID IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_REPORT_REF_CONNECTION.TEXT_7      (
         P_ID );
         RETURN ret_value;
   END TEXT_7;
   FUNCTION TEXT_8(
      P_ID IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_REPORT_REF_CONNECTION.TEXT_8      (
         P_ID );
         RETURN ret_value;
   END TEXT_8;
   FUNCTION TRANSACTION_TYPE(
      P_ID IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_REPORT_REF_CONNECTION.TRANSACTION_TYPE      (
         P_ID );
         RETURN ret_value;
   END TRANSACTION_TYPE;
   FUNCTION DATE_3(
      P_ID IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_REPORT_REF_CONNECTION.DATE_3      (
         P_ID );
         RETURN ret_value;
   END DATE_3;
   FUNCTION DATE_5(
      P_ID IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_REPORT_REF_CONNECTION.DATE_5      (
         P_ID );
         RETURN ret_value;
   END DATE_5;
   FUNCTION NEXT_EQUAL_DAYTIME(
      P_ID IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_REPORT_REF_CONNECTION.NEXT_EQUAL_DAYTIME      (
         P_ID,
         P_NUM_ROWS );
         RETURN ret_value;
   END NEXT_EQUAL_DAYTIME;
   FUNCTION REF_OBJECT_ID_2(
      P_ID IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_REPORT_REF_CONNECTION.REF_OBJECT_ID_2      (
         P_ID );
         RETURN ret_value;
   END REF_OBJECT_ID_2;
   FUNCTION REF_OBJECT_ID_3(
      P_ID IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_REPORT_REF_CONNECTION.REF_OBJECT_ID_3      (
         P_ID );
         RETURN ret_value;
   END REF_OBJECT_ID_3;
   FUNCTION REF_OBJECT_ID_9(
      P_ID IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_REPORT_REF_CONNECTION.REF_OBJECT_ID_9      (
         P_ID );
         RETURN ret_value;
   END REF_OBJECT_ID_9;
   FUNCTION TEXT_1(
      P_ID IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_REPORT_REF_CONNECTION.TEXT_1      (
         P_ID );
         RETURN ret_value;
   END TEXT_1;
   FUNCTION TEXT_6(
      P_ID IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_REPORT_REF_CONNECTION.TEXT_6      (
         P_ID );
         RETURN ret_value;
   END TEXT_6;
   FUNCTION TEXT_9(
      P_ID IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_REPORT_REF_CONNECTION.TEXT_9      (
         P_ID );
         RETURN ret_value;
   END TEXT_9;
   FUNCTION VALUE_6(
      P_ID IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_REPORT_REF_CONNECTION.VALUE_6      (
         P_ID );
         RETURN ret_value;
   END VALUE_6;
   FUNCTION COMPANY_ID(
      P_ID IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_REPORT_REF_CONNECTION.COMPANY_ID      (
         P_ID );
         RETURN ret_value;
   END COMPANY_ID;
   FUNCTION DATE_2(
      P_ID IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_REPORT_REF_CONNECTION.DATE_2      (
         P_ID );
         RETURN ret_value;
   END DATE_2;
   FUNCTION DIMENSION_IND(
      P_ID IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_REPORT_REF_CONNECTION.DIMENSION_IND      (
         P_ID );
         RETURN ret_value;
   END DIMENSION_IND;
   FUNCTION END_DATE(
      P_ID IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_REPORT_REF_CONNECTION.END_DATE      (
         P_ID );
         RETURN ret_value;
   END END_DATE;
   FUNCTION PREV_DAYTIME(
      P_ID IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_REPORT_REF_CONNECTION.PREV_DAYTIME      (
         P_ID,
         P_NUM_ROWS );
         RETURN ret_value;
   END PREV_DAYTIME;
   FUNCTION RECORD_STATUS(
      P_ID IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_REPORT_REF_CONNECTION.RECORD_STATUS      (
         P_ID );
         RETURN ret_value;
   END RECORD_STATUS;
   FUNCTION REF_OBJECT_ID_5(
      P_ID IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_REPORT_REF_CONNECTION.REF_OBJECT_ID_5      (
         P_ID );
         RETURN ret_value;
   END REF_OBJECT_ID_5;
   FUNCTION REPORT_REF_CONN_ID(
      P_ID IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_REPORT_REF_CONNECTION.REPORT_REF_CONN_ID      (
         P_ID );
         RETURN ret_value;
   END REPORT_REF_CONN_ID;
   FUNCTION REVERSE_IND(
      P_ID IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_REPORT_REF_CONNECTION.REVERSE_IND      (
         P_ID );
         RETURN ret_value;
   END REVERSE_IND;
   FUNCTION TRANS_INV_IND(
      P_ID IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_REPORT_REF_CONNECTION.TRANS_INV_IND      (
         P_ID );
         RETURN ret_value;
   END TRANS_INV_IND;
   FUNCTION VALUE_1(
      P_ID IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_REPORT_REF_CONNECTION.VALUE_1      (
         P_ID );
         RETURN ret_value;
   END VALUE_1;
   FUNCTION VAL_COLUMN(
      P_ID IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_REPORT_REF_CONNECTION.VAL_COLUMN      (
         P_ID );
         RETURN ret_value;
   END VAL_COLUMN;
   FUNCTION APPROVAL_DATE(
      P_ID IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_REPORT_REF_CONNECTION.APPROVAL_DATE      (
         P_ID );
         RETURN ret_value;
   END APPROVAL_DATE;
   FUNCTION DATE_6(
      P_ID IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_REPORT_REF_CONNECTION.DATE_6      (
         P_ID );
         RETURN ret_value;
   END DATE_6;
   FUNCTION DOCUMENT_LEVEL(
      P_ID IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_REPORT_REF_CONNECTION.DOCUMENT_LEVEL      (
         P_ID );
         RETURN ret_value;
   END DOCUMENT_LEVEL;
   FUNCTION PROD_MTH_IND(
      P_ID IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_REPORT_REF_CONNECTION.PROD_MTH_IND      (
         P_ID );
         RETURN ret_value;
   END PROD_MTH_IND;
   FUNCTION QTY_COLUMN(
      P_ID IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_REPORT_REF_CONNECTION.QTY_COLUMN      (
         P_ID );
         RETURN ret_value;
   END QTY_COLUMN;
   FUNCTION REF_OBJECT_ID_1(
      P_ID IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_REPORT_REF_CONNECTION.REF_OBJECT_ID_1      (
         P_ID );
         RETURN ret_value;
   END REF_OBJECT_ID_1;
   FUNCTION ROW_BY_PK(
      P_ID IN NUMBER)
      RETURN REC_ROW_BY_PK
   IS
      ret_value    REC_ROW_BY_PK ;
   BEGIN
      ret_value := EC_REPORT_REF_CONNECTION.ROW_BY_PK      (
         P_ID );
         RETURN ret_value;
   END ROW_BY_PK;
   FUNCTION TEXT_2(
      P_ID IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_REPORT_REF_CONNECTION.TEXT_2      (
         P_ID );
         RETURN ret_value;
   END TEXT_2;
   FUNCTION TEXT_4(
      P_ID IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_REPORT_REF_CONNECTION.TEXT_4      (
         P_ID );
         RETURN ret_value;
   END TEXT_4;
   FUNCTION TEXT_5(
      P_ID IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_REPORT_REF_CONNECTION.TEXT_5      (
         P_ID );
         RETURN ret_value;
   END TEXT_5;
   FUNCTION VALUE_2(
      P_ID IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_REPORT_REF_CONNECTION.VALUE_2      (
         P_ID );
         RETURN ret_value;
   END VALUE_2;
   FUNCTION VALUE_3(
      P_ID IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_REPORT_REF_CONNECTION.VALUE_3      (
         P_ID );
         RETURN ret_value;
   END VALUE_3;
   FUNCTION VALUE_4(
      P_ID IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_REPORT_REF_CONNECTION.VALUE_4      (
         P_ID );
         RETURN ret_value;
   END VALUE_4;
   FUNCTION ALT_KEY(
      P_ID IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_REPORT_REF_CONNECTION.ALT_KEY      (
         P_ID );
         RETURN ret_value;
   END ALT_KEY;
   FUNCTION DATASET_TYPE(
      P_ID IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_REPORT_REF_CONNECTION.DATASET_TYPE      (
         P_ID );
         RETURN ret_value;
   END DATASET_TYPE;
   FUNCTION DATE_4(
      P_ID IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_REPORT_REF_CONNECTION.DATE_4      (
         P_ID );
         RETURN ret_value;
   END DATE_4;
   FUNCTION LINE_ITEM_TYPE(
      P_ID IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_REPORT_REF_CONNECTION.LINE_ITEM_TYPE      (
         P_ID );
         RETURN ret_value;
   END LINE_ITEM_TYPE;
   FUNCTION PRICE_ELEMENT_CODE(
      P_ID IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_REPORT_REF_CONNECTION.PRICE_ELEMENT_CODE      (
         P_ID );
         RETURN ret_value;
   END PRICE_ELEMENT_CODE;
   FUNCTION REC_ID(
      P_ID IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_REPORT_REF_CONNECTION.REC_ID      (
         P_ID );
         RETURN ret_value;
   END REC_ID;
   FUNCTION REF_OBJECT_ID_10(
      P_ID IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_REPORT_REF_CONNECTION.REF_OBJECT_ID_10      (
         P_ID );
         RETURN ret_value;
   END REF_OBJECT_ID_10;
   FUNCTION REF_OBJECT_ID_6(
      P_ID IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_REPORT_REF_CONNECTION.REF_OBJECT_ID_6      (
         P_ID );
         RETURN ret_value;
   END REF_OBJECT_ID_6;
   FUNCTION VALUE_7(
      P_ID IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_REPORT_REF_CONNECTION.VALUE_7      (
         P_ID );
         RETURN ret_value;
   END VALUE_7;
   FUNCTION VALUE_9(
      P_ID IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_REPORT_REF_CONNECTION.VALUE_9      (
         P_ID );
         RETURN ret_value;
   END VALUE_9;
   FUNCTION DATE_1(
      P_ID IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_REPORT_REF_CONNECTION.DATE_1      (
         P_ID );
         RETURN ret_value;
   END DATE_1;
   FUNCTION DATE_8(
      P_ID IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_REPORT_REF_CONNECTION.DATE_8      (
         P_ID );
         RETURN ret_value;
   END DATE_8;
   FUNCTION DAYTIME(
      P_ID IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_REPORT_REF_CONNECTION.DAYTIME      (
         P_ID );
         RETURN ret_value;
   END DAYTIME;
   FUNCTION DIMENSION_2_IND(
      P_ID IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_REPORT_REF_CONNECTION.DIMENSION_2_IND      (
         P_ID );
         RETURN ret_value;
   END DIMENSION_2_IND;
   FUNCTION LAYER_IND(
      P_ID IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_REPORT_REF_CONNECTION.LAYER_IND      (
         P_ID );
         RETURN ret_value;
   END LAYER_IND;
   FUNCTION PRICE_CONCEPT_CODE(
      P_ID IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_REPORT_REF_CONNECTION.PRICE_CONCEPT_CODE      (
         P_ID );
         RETURN ret_value;
   END PRICE_CONCEPT_CODE;
   FUNCTION TEXT_10(
      P_ID IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_REPORT_REF_CONNECTION.TEXT_10      (
         P_ID );
         RETURN ret_value;
   END TEXT_10;
   FUNCTION TRANS_LINE_IND(
      P_ID IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_REPORT_REF_CONNECTION.TRANS_LINE_IND      (
         P_ID );
         RETURN ret_value;
   END TRANS_LINE_IND;
   FUNCTION VALUE_10(
      P_ID IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_REPORT_REF_CONNECTION.VALUE_10      (
         P_ID );
         RETURN ret_value;
   END VALUE_10;
   FUNCTION VALUE_8(
      P_ID IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_REPORT_REF_CONNECTION.VALUE_8      (
         P_ID );
         RETURN ret_value;
   END VALUE_8;

END RP_REPORT_REF_CONNECTION;

/
--GRANT EXECUTE ON ECKERNEL_WST.RP_REPORT_REF_CONNECTION TO REPORT_ROLE_XXX;



 -- FINISH PKG_GEN_PKGS.sf_get_functions at:11/15/2018 08.04.44 AM


