
 -- START PKG_GEN_PKGS.sf_get_functions at:05/07/2019 05.30.15 AM


CREATE or REPLACE PACKAGE RP_TRANS_INV_LI_PR_CNTRACC
IS

   FUNCTION CONTRACT_TYPE(
      P_ID IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION DIM_2(
      P_ID IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION DISABLED_IND(
      P_ID IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION LINE_TAG(
      P_ID IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION SORT_ORDER(
      P_ID IN NUMBER)
      RETURN NUMBER;
   FUNCTION TEXT_3(
      P_ID IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TRANS_DEF_DIMENSION(
      P_ID IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION ALT_PROD_STREAM_ID(
      P_ID IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_BY(
      P_ID IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_STATE(
      P_ID IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION REF_OBJECT_ID_4(
      P_ID IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_5(
      P_ID IN NUMBER)
      RETURN NUMBER;
   FUNCTION ACCOUNT_CODE(
      P_ID IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION NEXT_DAYTIME(
      P_ID IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION OBJECT_ID(
      P_ID IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION PREV_EQUAL_DAYTIME(
      P_ID IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION PRODUCT_ID(
      P_ID IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION REF_ID(
      P_ID IN NUMBER)
      RETURN NUMBER;
   FUNCTION REVERSE_QUANTITY_IND(
      P_ID IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION ROUND_VALUE_IND(
      P_ID IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_7(
      P_ID IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_8(
      P_ID IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION DATE_3(
      P_ID IN NUMBER)
      RETURN DATE;
   FUNCTION DATE_5(
      P_ID IN NUMBER)
      RETURN DATE;
   FUNCTION DIM_1(
      P_ID IN NUMBER)
      RETURN VARCHAR2;
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
   FUNCTION TEXT_1(
      P_ID IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_6(
      P_ID IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_9(
      P_ID IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION DATE_2(
      P_ID IN NUMBER)
      RETURN DATE;
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
   FUNCTION VALUE_1(
      P_ID IN NUMBER)
      RETURN NUMBER;
   FUNCTION APPROVAL_DATE(
      P_ID IN NUMBER)
      RETURN DATE;
   FUNCTION PROD_STREAM_ID(
      P_ID IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION REF_OBJECT_ID_1(
      P_ID IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION ROUND_QUANTITY_IND(
      P_ID IN NUMBER)
      RETURN VARCHAR2;
      TYPE REC_ROW_BY_PK IS RECORD (
         OBJECT_ID VARCHAR2 (32) ,
         DAYTIME  DATE ,
         LINE_TAG VARCHAR2 (200) ,
         PRODUCT_ID VARCHAR2 (32) ,
         COST_TYPE VARCHAR2 (32) ,
         ACCOUNT_CODE VARCHAR2 (32) ,
         END_DATE  DATE ,
         REVERSE_VALUE_IND VARCHAR2 (1) ,
         REVERSE_QUANTITY_IND VARCHAR2 (1) ,
         ROUND_QUANTITY_IND VARCHAR2 (1) ,
         ROUND_VALUE_IND VARCHAR2 (1) ,
         DIM_1 VARCHAR2 (200) ,
         DIM_2 VARCHAR2 (200) ,
         SOURCE_TYPE VARCHAR2 (100) ,
         CONTRACT_TYPE VARCHAR2 (100) ,
         COUNTRY_IND VARCHAR2 (1) ,
         PROD_STREAM_ID VARCHAR2 (32) ,
         TYPE VARCHAR2 (32) ,
         SORT_ORDER NUMBER ,
         ID NUMBER ,
         REF_ID NUMBER ,
         ALT_PROD_STREAM_ID VARCHAR2 (32) ,
         ALT_INVENTORY_ID VARCHAR2 (32) ,
         DISABLED_IND VARCHAR2 (1) ,
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
         DATE_1  DATE ,
         DATE_2  DATE ,
         DATE_3  DATE ,
         DATE_4  DATE ,
         DATE_5  DATE ,
         REF_OBJECT_ID_1 VARCHAR2 (32) ,
         REF_OBJECT_ID_2 VARCHAR2 (32) ,
         REF_OBJECT_ID_3 VARCHAR2 (32) ,
         REF_OBJECT_ID_4 VARCHAR2 (32) ,
         REF_OBJECT_ID_5 VARCHAR2 (32) ,
         TRANS_DEF_DIMENSION VARCHAR2 (100) ,
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
         REC_ID VARCHAR2 (32)  );
   FUNCTION ROW_BY_PK(
      P_ID IN NUMBER)
      RETURN REC_ROW_BY_PK;
   FUNCTION SOURCE_TYPE(
      P_ID IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_2(
      P_ID IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_4(
      P_ID IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_5(
      P_ID IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TYPE(
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
   FUNCTION ALT_INVENTORY_ID(
      P_ID IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION COST_TYPE(
      P_ID IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION COUNTRY_IND(
      P_ID IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION DATE_4(
      P_ID IN NUMBER)
      RETURN DATE;
   FUNCTION REC_ID(
      P_ID IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION DATE_1(
      P_ID IN NUMBER)
      RETURN DATE;
   FUNCTION DAYTIME(
      P_ID IN NUMBER)
      RETURN DATE;
   FUNCTION REVERSE_VALUE_IND(
      P_ID IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_10(
      P_ID IN NUMBER)
      RETURN VARCHAR2;

END RP_TRANS_INV_LI_PR_CNTRACC;

/



CREATE or REPLACE PACKAGE BODY RP_TRANS_INV_LI_PR_CNTRACC
IS

   FUNCTION CONTRACT_TYPE(
      P_ID IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (100) ;
   BEGIN
      ret_value := EC_TRANS_INV_LI_PR_CNTRACC.CONTRACT_TYPE      (
         P_ID );
         RETURN ret_value;
   END CONTRACT_TYPE;
   FUNCTION DIM_2(
      P_ID IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (200) ;
   BEGIN
      ret_value := EC_TRANS_INV_LI_PR_CNTRACC.DIM_2      (
         P_ID );
         RETURN ret_value;
   END DIM_2;
   FUNCTION DISABLED_IND(
      P_ID IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_TRANS_INV_LI_PR_CNTRACC.DISABLED_IND      (
         P_ID );
         RETURN ret_value;
   END DISABLED_IND;
   FUNCTION LINE_TAG(
      P_ID IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (200) ;
   BEGIN
      ret_value := EC_TRANS_INV_LI_PR_CNTRACC.LINE_TAG      (
         P_ID );
         RETURN ret_value;
   END LINE_TAG;
   FUNCTION SORT_ORDER(
      P_ID IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_TRANS_INV_LI_PR_CNTRACC.SORT_ORDER      (
         P_ID );
         RETURN ret_value;
   END SORT_ORDER;
   FUNCTION TEXT_3(
      P_ID IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_TRANS_INV_LI_PR_CNTRACC.TEXT_3      (
         P_ID );
         RETURN ret_value;
   END TEXT_3;
   FUNCTION TRANS_DEF_DIMENSION(
      P_ID IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (100) ;
   BEGIN
      ret_value := EC_TRANS_INV_LI_PR_CNTRACC.TRANS_DEF_DIMENSION      (
         P_ID );
         RETURN ret_value;
   END TRANS_DEF_DIMENSION;
   FUNCTION ALT_PROD_STREAM_ID(
      P_ID IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_TRANS_INV_LI_PR_CNTRACC.ALT_PROD_STREAM_ID      (
         P_ID );
         RETURN ret_value;
   END ALT_PROD_STREAM_ID;
   FUNCTION APPROVAL_BY(
      P_ID IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (30) ;
   BEGIN
      ret_value := EC_TRANS_INV_LI_PR_CNTRACC.APPROVAL_BY      (
         P_ID );
         RETURN ret_value;
   END APPROVAL_BY;
   FUNCTION APPROVAL_STATE(
      P_ID IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_TRANS_INV_LI_PR_CNTRACC.APPROVAL_STATE      (
         P_ID );
         RETURN ret_value;
   END APPROVAL_STATE;
   FUNCTION REF_OBJECT_ID_4(
      P_ID IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_TRANS_INV_LI_PR_CNTRACC.REF_OBJECT_ID_4      (
         P_ID );
         RETURN ret_value;
   END REF_OBJECT_ID_4;
   FUNCTION VALUE_5(
      P_ID IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_TRANS_INV_LI_PR_CNTRACC.VALUE_5      (
         P_ID );
         RETURN ret_value;
   END VALUE_5;
   FUNCTION ACCOUNT_CODE(
      P_ID IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_TRANS_INV_LI_PR_CNTRACC.ACCOUNT_CODE      (
         P_ID );
         RETURN ret_value;
   END ACCOUNT_CODE;
   FUNCTION NEXT_DAYTIME(
      P_ID IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_TRANS_INV_LI_PR_CNTRACC.NEXT_DAYTIME      (
         P_ID,
         P_NUM_ROWS );
         RETURN ret_value;
   END NEXT_DAYTIME;
   FUNCTION OBJECT_ID(
      P_ID IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_TRANS_INV_LI_PR_CNTRACC.OBJECT_ID      (
         P_ID );
         RETURN ret_value;
   END OBJECT_ID;
   FUNCTION PREV_EQUAL_DAYTIME(
      P_ID IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_TRANS_INV_LI_PR_CNTRACC.PREV_EQUAL_DAYTIME      (
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
      ret_value := EC_TRANS_INV_LI_PR_CNTRACC.PRODUCT_ID      (
         P_ID );
         RETURN ret_value;
   END PRODUCT_ID;
   FUNCTION REF_ID(
      P_ID IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_TRANS_INV_LI_PR_CNTRACC.REF_ID      (
         P_ID );
         RETURN ret_value;
   END REF_ID;
   FUNCTION REVERSE_QUANTITY_IND(
      P_ID IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_TRANS_INV_LI_PR_CNTRACC.REVERSE_QUANTITY_IND      (
         P_ID );
         RETURN ret_value;
   END REVERSE_QUANTITY_IND;
   FUNCTION ROUND_VALUE_IND(
      P_ID IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_TRANS_INV_LI_PR_CNTRACC.ROUND_VALUE_IND      (
         P_ID );
         RETURN ret_value;
   END ROUND_VALUE_IND;
   FUNCTION TEXT_7(
      P_ID IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_TRANS_INV_LI_PR_CNTRACC.TEXT_7      (
         P_ID );
         RETURN ret_value;
   END TEXT_7;
   FUNCTION TEXT_8(
      P_ID IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_TRANS_INV_LI_PR_CNTRACC.TEXT_8      (
         P_ID );
         RETURN ret_value;
   END TEXT_8;
   FUNCTION DATE_3(
      P_ID IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_TRANS_INV_LI_PR_CNTRACC.DATE_3      (
         P_ID );
         RETURN ret_value;
   END DATE_3;
   FUNCTION DATE_5(
      P_ID IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_TRANS_INV_LI_PR_CNTRACC.DATE_5      (
         P_ID );
         RETURN ret_value;
   END DATE_5;
   FUNCTION DIM_1(
      P_ID IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (200) ;
   BEGIN
      ret_value := EC_TRANS_INV_LI_PR_CNTRACC.DIM_1      (
         P_ID );
         RETURN ret_value;
   END DIM_1;
   FUNCTION NEXT_EQUAL_DAYTIME(
      P_ID IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_TRANS_INV_LI_PR_CNTRACC.NEXT_EQUAL_DAYTIME      (
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
      ret_value := EC_TRANS_INV_LI_PR_CNTRACC.REF_OBJECT_ID_2      (
         P_ID );
         RETURN ret_value;
   END REF_OBJECT_ID_2;
   FUNCTION REF_OBJECT_ID_3(
      P_ID IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_TRANS_INV_LI_PR_CNTRACC.REF_OBJECT_ID_3      (
         P_ID );
         RETURN ret_value;
   END REF_OBJECT_ID_3;
   FUNCTION TEXT_1(
      P_ID IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_TRANS_INV_LI_PR_CNTRACC.TEXT_1      (
         P_ID );
         RETURN ret_value;
   END TEXT_1;
   FUNCTION TEXT_6(
      P_ID IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_TRANS_INV_LI_PR_CNTRACC.TEXT_6      (
         P_ID );
         RETURN ret_value;
   END TEXT_6;
   FUNCTION TEXT_9(
      P_ID IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_TRANS_INV_LI_PR_CNTRACC.TEXT_9      (
         P_ID );
         RETURN ret_value;
   END TEXT_9;
   FUNCTION DATE_2(
      P_ID IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_TRANS_INV_LI_PR_CNTRACC.DATE_2      (
         P_ID );
         RETURN ret_value;
   END DATE_2;
   FUNCTION END_DATE(
      P_ID IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_TRANS_INV_LI_PR_CNTRACC.END_DATE      (
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
      ret_value := EC_TRANS_INV_LI_PR_CNTRACC.PREV_DAYTIME      (
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
      ret_value := EC_TRANS_INV_LI_PR_CNTRACC.RECORD_STATUS      (
         P_ID );
         RETURN ret_value;
   END RECORD_STATUS;
   FUNCTION REF_OBJECT_ID_5(
      P_ID IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_TRANS_INV_LI_PR_CNTRACC.REF_OBJECT_ID_5      (
         P_ID );
         RETURN ret_value;
   END REF_OBJECT_ID_5;
   FUNCTION VALUE_1(
      P_ID IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_TRANS_INV_LI_PR_CNTRACC.VALUE_1      (
         P_ID );
         RETURN ret_value;
   END VALUE_1;
   FUNCTION APPROVAL_DATE(
      P_ID IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_TRANS_INV_LI_PR_CNTRACC.APPROVAL_DATE      (
         P_ID );
         RETURN ret_value;
   END APPROVAL_DATE;
   FUNCTION PROD_STREAM_ID(
      P_ID IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_TRANS_INV_LI_PR_CNTRACC.PROD_STREAM_ID      (
         P_ID );
         RETURN ret_value;
   END PROD_STREAM_ID;
   FUNCTION REF_OBJECT_ID_1(
      P_ID IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_TRANS_INV_LI_PR_CNTRACC.REF_OBJECT_ID_1      (
         P_ID );
         RETURN ret_value;
   END REF_OBJECT_ID_1;
   FUNCTION ROUND_QUANTITY_IND(
      P_ID IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_TRANS_INV_LI_PR_CNTRACC.ROUND_QUANTITY_IND      (
         P_ID );
         RETURN ret_value;
   END ROUND_QUANTITY_IND;
   FUNCTION ROW_BY_PK(
      P_ID IN NUMBER)
      RETURN REC_ROW_BY_PK
   IS
      ret_value    REC_ROW_BY_PK ;
   BEGIN
      ret_value := EC_TRANS_INV_LI_PR_CNTRACC.ROW_BY_PK      (
         P_ID );
         RETURN ret_value;
   END ROW_BY_PK;
   FUNCTION SOURCE_TYPE(
      P_ID IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (100) ;
   BEGIN
      ret_value := EC_TRANS_INV_LI_PR_CNTRACC.SOURCE_TYPE      (
         P_ID );
         RETURN ret_value;
   END SOURCE_TYPE;
   FUNCTION TEXT_2(
      P_ID IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_TRANS_INV_LI_PR_CNTRACC.TEXT_2      (
         P_ID );
         RETURN ret_value;
   END TEXT_2;
   FUNCTION TEXT_4(
      P_ID IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_TRANS_INV_LI_PR_CNTRACC.TEXT_4      (
         P_ID );
         RETURN ret_value;
   END TEXT_4;
   FUNCTION TEXT_5(
      P_ID IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_TRANS_INV_LI_PR_CNTRACC.TEXT_5      (
         P_ID );
         RETURN ret_value;
   END TEXT_5;
   FUNCTION TYPE(
      P_ID IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_TRANS_INV_LI_PR_CNTRACC.TYPE      (
         P_ID );
         RETURN ret_value;
   END TYPE;
   FUNCTION VALUE_2(
      P_ID IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_TRANS_INV_LI_PR_CNTRACC.VALUE_2      (
         P_ID );
         RETURN ret_value;
   END VALUE_2;
   FUNCTION VALUE_3(
      P_ID IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_TRANS_INV_LI_PR_CNTRACC.VALUE_3      (
         P_ID );
         RETURN ret_value;
   END VALUE_3;
   FUNCTION VALUE_4(
      P_ID IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_TRANS_INV_LI_PR_CNTRACC.VALUE_4      (
         P_ID );
         RETURN ret_value;
   END VALUE_4;
   FUNCTION ALT_INVENTORY_ID(
      P_ID IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_TRANS_INV_LI_PR_CNTRACC.ALT_INVENTORY_ID      (
         P_ID );
         RETURN ret_value;
   END ALT_INVENTORY_ID;
   FUNCTION COST_TYPE(
      P_ID IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_TRANS_INV_LI_PR_CNTRACC.COST_TYPE      (
         P_ID );
         RETURN ret_value;
   END COST_TYPE;
   FUNCTION COUNTRY_IND(
      P_ID IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_TRANS_INV_LI_PR_CNTRACC.COUNTRY_IND      (
         P_ID );
         RETURN ret_value;
   END COUNTRY_IND;
   FUNCTION DATE_4(
      P_ID IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_TRANS_INV_LI_PR_CNTRACC.DATE_4      (
         P_ID );
         RETURN ret_value;
   END DATE_4;
   FUNCTION REC_ID(
      P_ID IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_TRANS_INV_LI_PR_CNTRACC.REC_ID      (
         P_ID );
         RETURN ret_value;
   END REC_ID;
   FUNCTION DATE_1(
      P_ID IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_TRANS_INV_LI_PR_CNTRACC.DATE_1      (
         P_ID );
         RETURN ret_value;
   END DATE_1;
   FUNCTION DAYTIME(
      P_ID IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_TRANS_INV_LI_PR_CNTRACC.DAYTIME      (
         P_ID );
         RETURN ret_value;
   END DAYTIME;
   FUNCTION REVERSE_VALUE_IND(
      P_ID IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_TRANS_INV_LI_PR_CNTRACC.REVERSE_VALUE_IND      (
         P_ID );
         RETURN ret_value;
   END REVERSE_VALUE_IND;
   FUNCTION TEXT_10(
      P_ID IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_TRANS_INV_LI_PR_CNTRACC.TEXT_10      (
         P_ID );
         RETURN ret_value;
   END TEXT_10;

END RP_TRANS_INV_LI_PR_CNTRACC;

/
--GRANT EXECUTE ON ECKERNEL_WST.RP_TRANS_INV_LI_PR_CNTRACC TO REPORT_ROLE_XXX;



 -- FINISH PKG_GEN_PKGS.sf_get_functions at:05/07/2019 05.30.28 AM


