
 -- START PKG_GEN_PKGS.sf_get_functions at:11/15/2018 08.20.19 AM


CREATE or REPLACE PACKAGE RP_PRODUCT_PRICE_DIM1_VALUE
IS

   FUNCTION TEXT_3(
      P_OBJECT_ID IN VARCHAR2,
      P_PRICE_CONCEPT_CODE IN VARCHAR2,
      P_PRICE_ELEMENT_CODE IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_DIM1_KEY IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2;
   FUNCTION TEXT_4(
      P_OBJECT_ID IN VARCHAR2,
      P_PRICE_CONCEPT_CODE IN VARCHAR2,
      P_PRICE_ELEMENT_CODE IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_DIM1_KEY IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2;
   FUNCTION APPROVAL_BY(
      P_OBJECT_ID IN VARCHAR2,
      P_PRICE_CONCEPT_CODE IN VARCHAR2,
      P_PRICE_ELEMENT_CODE IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_DIM1_KEY IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2;
   FUNCTION APPROVAL_STATE(
      P_OBJECT_ID IN VARCHAR2,
      P_PRICE_CONCEPT_CODE IN VARCHAR2,
      P_PRICE_ELEMENT_CODE IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_DIM1_KEY IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2;
   FUNCTION CALC_PRICE_VALUE(
      P_OBJECT_ID IN VARCHAR2,
      P_PRICE_CONCEPT_CODE IN VARCHAR2,
      P_PRICE_ELEMENT_CODE IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_DIM1_KEY IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER;
   FUNCTION VALUE_5(
      P_OBJECT_ID IN VARCHAR2,
      P_PRICE_CONCEPT_CODE IN VARCHAR2,
      P_PRICE_ELEMENT_CODE IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_DIM1_KEY IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER;
   FUNCTION NEXT_DAYTIME(
      P_OBJECT_ID IN VARCHAR2,
      P_PRICE_CONCEPT_CODE IN VARCHAR2,
      P_PRICE_ELEMENT_CODE IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_DIM1_KEY IN VARCHAR2,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION PARCEL_KEY(
      P_OBJECT_ID IN VARCHAR2,
      P_PRICE_CONCEPT_CODE IN VARCHAR2,
      P_PRICE_ELEMENT_CODE IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_DIM1_KEY IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2;
   FUNCTION PREV_EQUAL_DAYTIME(
      P_OBJECT_ID IN VARCHAR2,
      P_PRICE_CONCEPT_CODE IN VARCHAR2,
      P_PRICE_ELEMENT_CODE IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_DIM1_KEY IN VARCHAR2,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION ADJ_PRICE_VALUE(
      P_OBJECT_ID IN VARCHAR2,
      P_PRICE_CONCEPT_CODE IN VARCHAR2,
      P_PRICE_ELEMENT_CODE IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_DIM1_KEY IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER;
   FUNCTION COMMENTS(
      P_OBJECT_ID IN VARCHAR2,
      P_PRICE_CONCEPT_CODE IN VARCHAR2,
      P_PRICE_ELEMENT_CODE IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_DIM1_KEY IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2;
   FUNCTION NEXT_EQUAL_DAYTIME(
      P_OBJECT_ID IN VARCHAR2,
      P_PRICE_CONCEPT_CODE IN VARCHAR2,
      P_PRICE_ELEMENT_CODE IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_DIM1_KEY IN VARCHAR2,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION VALUE_6(
      P_OBJECT_ID IN VARCHAR2,
      P_PRICE_CONCEPT_CODE IN VARCHAR2,
      P_PRICE_ELEMENT_CODE IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_DIM1_KEY IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER;
   FUNCTION PREV_DAYTIME(
      P_OBJECT_ID IN VARCHAR2,
      P_PRICE_CONCEPT_CODE IN VARCHAR2,
      P_PRICE_ELEMENT_CODE IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_DIM1_KEY IN VARCHAR2,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION RECORD_STATUS(
      P_OBJECT_ID IN VARCHAR2,
      P_PRICE_CONCEPT_CODE IN VARCHAR2,
      P_PRICE_ELEMENT_CODE IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_DIM1_KEY IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2;
   FUNCTION VALUE_1(
      P_OBJECT_ID IN VARCHAR2,
      P_PRICE_CONCEPT_CODE IN VARCHAR2,
      P_PRICE_ELEMENT_CODE IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_DIM1_KEY IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER;
   FUNCTION APPROVAL_DATE(
      P_OBJECT_ID IN VARCHAR2,
      P_PRICE_CONCEPT_CODE IN VARCHAR2,
      P_PRICE_ELEMENT_CODE IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_DIM1_KEY IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN DATE;
      TYPE REC_ROW_BY_PK IS RECORD (
         OBJECT_ID VARCHAR2 (32) ,
         PRICE_CONCEPT_CODE VARCHAR2 (32) ,
         PRICE_ELEMENT_CODE VARCHAR2 (32) ,
         DAYTIME  DATE ,
         DIM1_KEY VARCHAR2 (32) ,
         CALC_PRICE_VALUE NUMBER ,
         ADJ_PRICE_VALUE NUMBER ,
         PARCEL_KEY VARCHAR2 (300) ,
         COMMENTS VARCHAR2 (2000) ,
         TEXT_1 VARCHAR2 (16) ,
         TEXT_2 VARCHAR2 (32) ,
         TEXT_3 VARCHAR2 (240) ,
         TEXT_4 VARCHAR2 (2000) ,
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
         RECORD_STATUS VARCHAR2 (1) ,
         CREATED_BY VARCHAR2 (30) ,
         CREATED_DATE  DATE ,
         LAST_UPDATED_BY VARCHAR2 (30) ,
         LAST_UPDATED_DATE  DATE ,
         REV_NO NUMBER ,
         REV_TEXT VARCHAR2 (2000) ,
         APPROVAL_STATE VARCHAR2 (1) ,
         APPROVAL_BY VARCHAR2 (30) ,
         APPROVAL_DATE  DATE ,
         REC_ID VARCHAR2 (32)  );
   FUNCTION ROW_BY_PK(
      P_OBJECT_ID IN VARCHAR2,
      P_PRICE_CONCEPT_CODE IN VARCHAR2,
      P_PRICE_ELEMENT_CODE IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_DIM1_KEY IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN REC_ROW_BY_PK;
      TYPE REC_ROW_BY_REL_OPERATOR IS RECORD (
         OBJECT_ID VARCHAR2 (32) ,
         PRICE_CONCEPT_CODE VARCHAR2 (32) ,
         PRICE_ELEMENT_CODE VARCHAR2 (32) ,
         DAYTIME  DATE ,
         DIM1_KEY VARCHAR2 (32) ,
         CALC_PRICE_VALUE NUMBER ,
         ADJ_PRICE_VALUE NUMBER ,
         PARCEL_KEY VARCHAR2 (300) ,
         COMMENTS VARCHAR2 (2000) ,
         TEXT_1 VARCHAR2 (16) ,
         TEXT_2 VARCHAR2 (32) ,
         TEXT_3 VARCHAR2 (240) ,
         TEXT_4 VARCHAR2 (2000) ,
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
         RECORD_STATUS VARCHAR2 (1) ,
         CREATED_BY VARCHAR2 (30) ,
         CREATED_DATE  DATE ,
         LAST_UPDATED_BY VARCHAR2 (30) ,
         LAST_UPDATED_DATE  DATE ,
         REV_NO NUMBER ,
         REV_TEXT VARCHAR2 (2000) ,
         APPROVAL_STATE VARCHAR2 (1) ,
         APPROVAL_BY VARCHAR2 (30) ,
         APPROVAL_DATE  DATE ,
         REC_ID VARCHAR2 (32)  );
   FUNCTION ROW_BY_REL_OPERATOR(
      P_OBJECT_ID IN VARCHAR2,
      P_PRICE_CONCEPT_CODE IN VARCHAR2,
      P_PRICE_ELEMENT_CODE IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_DIM1_KEY IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN REC_ROW_BY_REL_OPERATOR;
   FUNCTION VALUE_2(
      P_OBJECT_ID IN VARCHAR2,
      P_PRICE_CONCEPT_CODE IN VARCHAR2,
      P_PRICE_ELEMENT_CODE IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_DIM1_KEY IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER;
   FUNCTION VALUE_3(
      P_OBJECT_ID IN VARCHAR2,
      P_PRICE_CONCEPT_CODE IN VARCHAR2,
      P_PRICE_ELEMENT_CODE IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_DIM1_KEY IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER;
   FUNCTION VALUE_4(
      P_OBJECT_ID IN VARCHAR2,
      P_PRICE_CONCEPT_CODE IN VARCHAR2,
      P_PRICE_ELEMENT_CODE IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_DIM1_KEY IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER;
   FUNCTION REC_ID(
      P_OBJECT_ID IN VARCHAR2,
      P_PRICE_CONCEPT_CODE IN VARCHAR2,
      P_PRICE_ELEMENT_CODE IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_DIM1_KEY IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2;
   FUNCTION TEXT_1(
      P_OBJECT_ID IN VARCHAR2,
      P_PRICE_CONCEPT_CODE IN VARCHAR2,
      P_PRICE_ELEMENT_CODE IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_DIM1_KEY IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2;
   FUNCTION TEXT_2(
      P_OBJECT_ID IN VARCHAR2,
      P_PRICE_CONCEPT_CODE IN VARCHAR2,
      P_PRICE_ELEMENT_CODE IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_DIM1_KEY IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2;
   FUNCTION VALUE_7(
      P_OBJECT_ID IN VARCHAR2,
      P_PRICE_CONCEPT_CODE IN VARCHAR2,
      P_PRICE_ELEMENT_CODE IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_DIM1_KEY IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER;
   FUNCTION VALUE_9(
      P_OBJECT_ID IN VARCHAR2,
      P_PRICE_CONCEPT_CODE IN VARCHAR2,
      P_PRICE_ELEMENT_CODE IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_DIM1_KEY IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER;
   FUNCTION VALUE_10(
      P_OBJECT_ID IN VARCHAR2,
      P_PRICE_CONCEPT_CODE IN VARCHAR2,
      P_PRICE_ELEMENT_CODE IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_DIM1_KEY IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER;
   FUNCTION VALUE_8(
      P_OBJECT_ID IN VARCHAR2,
      P_PRICE_CONCEPT_CODE IN VARCHAR2,
      P_PRICE_ELEMENT_CODE IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_DIM1_KEY IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER;

END RP_PRODUCT_PRICE_DIM1_VALUE;

/



CREATE or REPLACE PACKAGE BODY RP_PRODUCT_PRICE_DIM1_VALUE
IS

   FUNCTION TEXT_3(
      P_OBJECT_ID IN VARCHAR2,
      P_PRICE_CONCEPT_CODE IN VARCHAR2,
      P_PRICE_ELEMENT_CODE IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_DIM1_KEY IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_PRODUCT_PRICE_DIM1_VALUE.TEXT_3      (
         P_OBJECT_ID,
         P_PRICE_CONCEPT_CODE,
         P_PRICE_ELEMENT_CODE,
         P_DAYTIME,
         P_DIM1_KEY,
         P_COMPARE_OPER );
         RETURN ret_value;
   END TEXT_3;
   FUNCTION TEXT_4(
      P_OBJECT_ID IN VARCHAR2,
      P_PRICE_CONCEPT_CODE IN VARCHAR2,
      P_PRICE_ELEMENT_CODE IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_DIM1_KEY IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_PRODUCT_PRICE_DIM1_VALUE.TEXT_4      (
         P_OBJECT_ID,
         P_PRICE_CONCEPT_CODE,
         P_PRICE_ELEMENT_CODE,
         P_DAYTIME,
         P_DIM1_KEY,
         P_COMPARE_OPER );
         RETURN ret_value;
   END TEXT_4;
   FUNCTION APPROVAL_BY(
      P_OBJECT_ID IN VARCHAR2,
      P_PRICE_CONCEPT_CODE IN VARCHAR2,
      P_PRICE_ELEMENT_CODE IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_DIM1_KEY IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (30) ;
   BEGIN
      ret_value := EC_PRODUCT_PRICE_DIM1_VALUE.APPROVAL_BY      (
         P_OBJECT_ID,
         P_PRICE_CONCEPT_CODE,
         P_PRICE_ELEMENT_CODE,
         P_DAYTIME,
         P_DIM1_KEY,
         P_COMPARE_OPER );
         RETURN ret_value;
   END APPROVAL_BY;
   FUNCTION APPROVAL_STATE(
      P_OBJECT_ID IN VARCHAR2,
      P_PRICE_CONCEPT_CODE IN VARCHAR2,
      P_PRICE_ELEMENT_CODE IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_DIM1_KEY IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_PRODUCT_PRICE_DIM1_VALUE.APPROVAL_STATE      (
         P_OBJECT_ID,
         P_PRICE_CONCEPT_CODE,
         P_PRICE_ELEMENT_CODE,
         P_DAYTIME,
         P_DIM1_KEY,
         P_COMPARE_OPER );
         RETURN ret_value;
   END APPROVAL_STATE;
   FUNCTION CALC_PRICE_VALUE(
      P_OBJECT_ID IN VARCHAR2,
      P_PRICE_CONCEPT_CODE IN VARCHAR2,
      P_PRICE_ELEMENT_CODE IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_DIM1_KEY IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_PRODUCT_PRICE_DIM1_VALUE.CALC_PRICE_VALUE      (
         P_OBJECT_ID,
         P_PRICE_CONCEPT_CODE,
         P_PRICE_ELEMENT_CODE,
         P_DAYTIME,
         P_DIM1_KEY,
         P_COMPARE_OPER );
         RETURN ret_value;
   END CALC_PRICE_VALUE;
   FUNCTION VALUE_5(
      P_OBJECT_ID IN VARCHAR2,
      P_PRICE_CONCEPT_CODE IN VARCHAR2,
      P_PRICE_ELEMENT_CODE IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_DIM1_KEY IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_PRODUCT_PRICE_DIM1_VALUE.VALUE_5      (
         P_OBJECT_ID,
         P_PRICE_CONCEPT_CODE,
         P_PRICE_ELEMENT_CODE,
         P_DAYTIME,
         P_DIM1_KEY,
         P_COMPARE_OPER );
         RETURN ret_value;
   END VALUE_5;
   FUNCTION NEXT_DAYTIME(
      P_OBJECT_ID IN VARCHAR2,
      P_PRICE_CONCEPT_CODE IN VARCHAR2,
      P_PRICE_ELEMENT_CODE IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_DIM1_KEY IN VARCHAR2,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_PRODUCT_PRICE_DIM1_VALUE.NEXT_DAYTIME      (
         P_OBJECT_ID,
         P_PRICE_CONCEPT_CODE,
         P_PRICE_ELEMENT_CODE,
         P_DAYTIME,
         P_DIM1_KEY,
         P_NUM_ROWS );
         RETURN ret_value;
   END NEXT_DAYTIME;
   FUNCTION PARCEL_KEY(
      P_OBJECT_ID IN VARCHAR2,
      P_PRICE_CONCEPT_CODE IN VARCHAR2,
      P_PRICE_ELEMENT_CODE IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_DIM1_KEY IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (300) ;
   BEGIN
      ret_value := EC_PRODUCT_PRICE_DIM1_VALUE.PARCEL_KEY      (
         P_OBJECT_ID,
         P_PRICE_CONCEPT_CODE,
         P_PRICE_ELEMENT_CODE,
         P_DAYTIME,
         P_DIM1_KEY,
         P_COMPARE_OPER );
         RETURN ret_value;
   END PARCEL_KEY;
   FUNCTION PREV_EQUAL_DAYTIME(
      P_OBJECT_ID IN VARCHAR2,
      P_PRICE_CONCEPT_CODE IN VARCHAR2,
      P_PRICE_ELEMENT_CODE IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_DIM1_KEY IN VARCHAR2,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_PRODUCT_PRICE_DIM1_VALUE.PREV_EQUAL_DAYTIME      (
         P_OBJECT_ID,
         P_PRICE_CONCEPT_CODE,
         P_PRICE_ELEMENT_CODE,
         P_DAYTIME,
         P_DIM1_KEY,
         P_NUM_ROWS );
         RETURN ret_value;
   END PREV_EQUAL_DAYTIME;
   FUNCTION ADJ_PRICE_VALUE(
      P_OBJECT_ID IN VARCHAR2,
      P_PRICE_CONCEPT_CODE IN VARCHAR2,
      P_PRICE_ELEMENT_CODE IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_DIM1_KEY IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_PRODUCT_PRICE_DIM1_VALUE.ADJ_PRICE_VALUE      (
         P_OBJECT_ID,
         P_PRICE_CONCEPT_CODE,
         P_PRICE_ELEMENT_CODE,
         P_DAYTIME,
         P_DIM1_KEY,
         P_COMPARE_OPER );
         RETURN ret_value;
   END ADJ_PRICE_VALUE;
   FUNCTION COMMENTS(
      P_OBJECT_ID IN VARCHAR2,
      P_PRICE_CONCEPT_CODE IN VARCHAR2,
      P_PRICE_ELEMENT_CODE IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_DIM1_KEY IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_PRODUCT_PRICE_DIM1_VALUE.COMMENTS      (
         P_OBJECT_ID,
         P_PRICE_CONCEPT_CODE,
         P_PRICE_ELEMENT_CODE,
         P_DAYTIME,
         P_DIM1_KEY,
         P_COMPARE_OPER );
         RETURN ret_value;
   END COMMENTS;
   FUNCTION NEXT_EQUAL_DAYTIME(
      P_OBJECT_ID IN VARCHAR2,
      P_PRICE_CONCEPT_CODE IN VARCHAR2,
      P_PRICE_ELEMENT_CODE IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_DIM1_KEY IN VARCHAR2,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_PRODUCT_PRICE_DIM1_VALUE.NEXT_EQUAL_DAYTIME      (
         P_OBJECT_ID,
         P_PRICE_CONCEPT_CODE,
         P_PRICE_ELEMENT_CODE,
         P_DAYTIME,
         P_DIM1_KEY,
         P_NUM_ROWS );
         RETURN ret_value;
   END NEXT_EQUAL_DAYTIME;
   FUNCTION VALUE_6(
      P_OBJECT_ID IN VARCHAR2,
      P_PRICE_CONCEPT_CODE IN VARCHAR2,
      P_PRICE_ELEMENT_CODE IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_DIM1_KEY IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_PRODUCT_PRICE_DIM1_VALUE.VALUE_6      (
         P_OBJECT_ID,
         P_PRICE_CONCEPT_CODE,
         P_PRICE_ELEMENT_CODE,
         P_DAYTIME,
         P_DIM1_KEY,
         P_COMPARE_OPER );
         RETURN ret_value;
   END VALUE_6;
   FUNCTION PREV_DAYTIME(
      P_OBJECT_ID IN VARCHAR2,
      P_PRICE_CONCEPT_CODE IN VARCHAR2,
      P_PRICE_ELEMENT_CODE IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_DIM1_KEY IN VARCHAR2,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_PRODUCT_PRICE_DIM1_VALUE.PREV_DAYTIME      (
         P_OBJECT_ID,
         P_PRICE_CONCEPT_CODE,
         P_PRICE_ELEMENT_CODE,
         P_DAYTIME,
         P_DIM1_KEY,
         P_NUM_ROWS );
         RETURN ret_value;
   END PREV_DAYTIME;
   FUNCTION RECORD_STATUS(
      P_OBJECT_ID IN VARCHAR2,
      P_PRICE_CONCEPT_CODE IN VARCHAR2,
      P_PRICE_ELEMENT_CODE IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_DIM1_KEY IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_PRODUCT_PRICE_DIM1_VALUE.RECORD_STATUS      (
         P_OBJECT_ID,
         P_PRICE_CONCEPT_CODE,
         P_PRICE_ELEMENT_CODE,
         P_DAYTIME,
         P_DIM1_KEY,
         P_COMPARE_OPER );
         RETURN ret_value;
   END RECORD_STATUS;
   FUNCTION VALUE_1(
      P_OBJECT_ID IN VARCHAR2,
      P_PRICE_CONCEPT_CODE IN VARCHAR2,
      P_PRICE_ELEMENT_CODE IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_DIM1_KEY IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_PRODUCT_PRICE_DIM1_VALUE.VALUE_1      (
         P_OBJECT_ID,
         P_PRICE_CONCEPT_CODE,
         P_PRICE_ELEMENT_CODE,
         P_DAYTIME,
         P_DIM1_KEY,
         P_COMPARE_OPER );
         RETURN ret_value;
   END VALUE_1;
   FUNCTION APPROVAL_DATE(
      P_OBJECT_ID IN VARCHAR2,
      P_PRICE_CONCEPT_CODE IN VARCHAR2,
      P_PRICE_ELEMENT_CODE IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_DIM1_KEY IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_PRODUCT_PRICE_DIM1_VALUE.APPROVAL_DATE      (
         P_OBJECT_ID,
         P_PRICE_CONCEPT_CODE,
         P_PRICE_ELEMENT_CODE,
         P_DAYTIME,
         P_DIM1_KEY,
         P_COMPARE_OPER );
         RETURN ret_value;
   END APPROVAL_DATE;
   FUNCTION ROW_BY_PK(
      P_OBJECT_ID IN VARCHAR2,
      P_PRICE_CONCEPT_CODE IN VARCHAR2,
      P_PRICE_ELEMENT_CODE IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_DIM1_KEY IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN REC_ROW_BY_PK
   IS
      ret_value    REC_ROW_BY_PK ;
   BEGIN
      ret_value := EC_PRODUCT_PRICE_DIM1_VALUE.ROW_BY_PK      (
         P_OBJECT_ID,
         P_PRICE_CONCEPT_CODE,
         P_PRICE_ELEMENT_CODE,
         P_DAYTIME,
         P_DIM1_KEY,
         P_COMPARE_OPER );
         RETURN ret_value;
   END ROW_BY_PK;
   FUNCTION ROW_BY_REL_OPERATOR(
      P_OBJECT_ID IN VARCHAR2,
      P_PRICE_CONCEPT_CODE IN VARCHAR2,
      P_PRICE_ELEMENT_CODE IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_DIM1_KEY IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN REC_ROW_BY_REL_OPERATOR
   IS
      ret_value    REC_ROW_BY_REL_OPERATOR ;
   BEGIN
      ret_value := EC_PRODUCT_PRICE_DIM1_VALUE.ROW_BY_REL_OPERATOR      (
         P_OBJECT_ID,
         P_PRICE_CONCEPT_CODE,
         P_PRICE_ELEMENT_CODE,
         P_DAYTIME,
         P_DIM1_KEY,
         P_COMPARE_OPER );
         RETURN ret_value;
   END ROW_BY_REL_OPERATOR;
   FUNCTION VALUE_2(
      P_OBJECT_ID IN VARCHAR2,
      P_PRICE_CONCEPT_CODE IN VARCHAR2,
      P_PRICE_ELEMENT_CODE IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_DIM1_KEY IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_PRODUCT_PRICE_DIM1_VALUE.VALUE_2      (
         P_OBJECT_ID,
         P_PRICE_CONCEPT_CODE,
         P_PRICE_ELEMENT_CODE,
         P_DAYTIME,
         P_DIM1_KEY,
         P_COMPARE_OPER );
         RETURN ret_value;
   END VALUE_2;
   FUNCTION VALUE_3(
      P_OBJECT_ID IN VARCHAR2,
      P_PRICE_CONCEPT_CODE IN VARCHAR2,
      P_PRICE_ELEMENT_CODE IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_DIM1_KEY IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_PRODUCT_PRICE_DIM1_VALUE.VALUE_3      (
         P_OBJECT_ID,
         P_PRICE_CONCEPT_CODE,
         P_PRICE_ELEMENT_CODE,
         P_DAYTIME,
         P_DIM1_KEY,
         P_COMPARE_OPER );
         RETURN ret_value;
   END VALUE_3;
   FUNCTION VALUE_4(
      P_OBJECT_ID IN VARCHAR2,
      P_PRICE_CONCEPT_CODE IN VARCHAR2,
      P_PRICE_ELEMENT_CODE IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_DIM1_KEY IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_PRODUCT_PRICE_DIM1_VALUE.VALUE_4      (
         P_OBJECT_ID,
         P_PRICE_CONCEPT_CODE,
         P_PRICE_ELEMENT_CODE,
         P_DAYTIME,
         P_DIM1_KEY,
         P_COMPARE_OPER );
         RETURN ret_value;
   END VALUE_4;
   FUNCTION REC_ID(
      P_OBJECT_ID IN VARCHAR2,
      P_PRICE_CONCEPT_CODE IN VARCHAR2,
      P_PRICE_ELEMENT_CODE IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_DIM1_KEY IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_PRODUCT_PRICE_DIM1_VALUE.REC_ID      (
         P_OBJECT_ID,
         P_PRICE_CONCEPT_CODE,
         P_PRICE_ELEMENT_CODE,
         P_DAYTIME,
         P_DIM1_KEY,
         P_COMPARE_OPER );
         RETURN ret_value;
   END REC_ID;
   FUNCTION TEXT_1(
      P_OBJECT_ID IN VARCHAR2,
      P_PRICE_CONCEPT_CODE IN VARCHAR2,
      P_PRICE_ELEMENT_CODE IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_DIM1_KEY IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (16) ;
   BEGIN
      ret_value := EC_PRODUCT_PRICE_DIM1_VALUE.TEXT_1      (
         P_OBJECT_ID,
         P_PRICE_CONCEPT_CODE,
         P_PRICE_ELEMENT_CODE,
         P_DAYTIME,
         P_DIM1_KEY,
         P_COMPARE_OPER );
         RETURN ret_value;
   END TEXT_1;
   FUNCTION TEXT_2(
      P_OBJECT_ID IN VARCHAR2,
      P_PRICE_CONCEPT_CODE IN VARCHAR2,
      P_PRICE_ELEMENT_CODE IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_DIM1_KEY IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_PRODUCT_PRICE_DIM1_VALUE.TEXT_2      (
         P_OBJECT_ID,
         P_PRICE_CONCEPT_CODE,
         P_PRICE_ELEMENT_CODE,
         P_DAYTIME,
         P_DIM1_KEY,
         P_COMPARE_OPER );
         RETURN ret_value;
   END TEXT_2;
   FUNCTION VALUE_7(
      P_OBJECT_ID IN VARCHAR2,
      P_PRICE_CONCEPT_CODE IN VARCHAR2,
      P_PRICE_ELEMENT_CODE IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_DIM1_KEY IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_PRODUCT_PRICE_DIM1_VALUE.VALUE_7      (
         P_OBJECT_ID,
         P_PRICE_CONCEPT_CODE,
         P_PRICE_ELEMENT_CODE,
         P_DAYTIME,
         P_DIM1_KEY,
         P_COMPARE_OPER );
         RETURN ret_value;
   END VALUE_7;
   FUNCTION VALUE_9(
      P_OBJECT_ID IN VARCHAR2,
      P_PRICE_CONCEPT_CODE IN VARCHAR2,
      P_PRICE_ELEMENT_CODE IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_DIM1_KEY IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_PRODUCT_PRICE_DIM1_VALUE.VALUE_9      (
         P_OBJECT_ID,
         P_PRICE_CONCEPT_CODE,
         P_PRICE_ELEMENT_CODE,
         P_DAYTIME,
         P_DIM1_KEY,
         P_COMPARE_OPER );
         RETURN ret_value;
   END VALUE_9;
   FUNCTION VALUE_10(
      P_OBJECT_ID IN VARCHAR2,
      P_PRICE_CONCEPT_CODE IN VARCHAR2,
      P_PRICE_ELEMENT_CODE IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_DIM1_KEY IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_PRODUCT_PRICE_DIM1_VALUE.VALUE_10      (
         P_OBJECT_ID,
         P_PRICE_CONCEPT_CODE,
         P_PRICE_ELEMENT_CODE,
         P_DAYTIME,
         P_DIM1_KEY,
         P_COMPARE_OPER );
         RETURN ret_value;
   END VALUE_10;
   FUNCTION VALUE_8(
      P_OBJECT_ID IN VARCHAR2,
      P_PRICE_CONCEPT_CODE IN VARCHAR2,
      P_PRICE_ELEMENT_CODE IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_DIM1_KEY IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_PRODUCT_PRICE_DIM1_VALUE.VALUE_8      (
         P_OBJECT_ID,
         P_PRICE_CONCEPT_CODE,
         P_PRICE_ELEMENT_CODE,
         P_DAYTIME,
         P_DIM1_KEY,
         P_COMPARE_OPER );
         RETURN ret_value;
   END VALUE_8;

END RP_PRODUCT_PRICE_DIM1_VALUE;

/
--GRANT EXECUTE ON ECKERNEL_WST.RP_PRODUCT_PRICE_DIM1_VALUE TO REPORT_ROLE_XXX;



 -- FINISH PKG_GEN_PKGS.sf_get_functions at:11/15/2018 08.20.25 AM

