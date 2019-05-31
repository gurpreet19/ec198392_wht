
 -- START PKG_GEN_PKGS.sf_get_functions at:05/07/2019 10.39.52 AM


CREATE or REPLACE PACKAGE RP_CONT_DOC
IS

   FUNCTION DATE_10(
      P_DOCUMENT_KEY IN VARCHAR2)
      RETURN DATE;
   FUNCTION DOCUMENT_TYPE(
      P_DOCUMENT_KEY IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION IS_MANUAL_IND(
      P_DOCUMENT_KEY IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION PARENT_DOCUMENT_KEY(
      P_DOCUMENT_KEY IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION SUMMARY_SETUP_ID(
      P_DOCUMENT_KEY IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION TEXT_3(
      P_DOCUMENT_KEY IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_BY(
      P_DOCUMENT_KEY IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_STATE(
      P_DOCUMENT_KEY IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION DATASET(
      P_DOCUMENT_KEY IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION PRECEDING_DOCUMENT_KEY(
      P_DOCUMENT_KEY IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION REF_OBJECT_ID_4(
      P_DOCUMENT_KEY IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION REPORTING_PERIOD(
      P_DOCUMENT_KEY IN VARCHAR2)
      RETURN DATE;
   FUNCTION VALUE_5(
      P_DOCUMENT_KEY IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION ACCRUAL_IND(
      P_DOCUMENT_KEY IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION DATE_7(
      P_DOCUMENT_KEY IN VARCHAR2)
      RETURN DATE;
   FUNCTION DATE_9(
      P_DOCUMENT_KEY IN VARCHAR2)
      RETURN DATE;
   FUNCTION DOCUMENT_NUMBER(
      P_DOCUMENT_KEY IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION NEXT_DAYTIME(
      P_DOCUMENT_KEY IN VARCHAR2,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION OBJECT_ID(
      P_DOCUMENT_KEY IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION PREV_EQUAL_DAYTIME(
      P_DOCUMENT_KEY IN VARCHAR2,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION TEXT_7(
      P_DOCUMENT_KEY IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION TEXT_8(
      P_DOCUMENT_KEY IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION COMMENTS(
      P_DOCUMENT_KEY IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION DATE_3(
      P_DOCUMENT_KEY IN VARCHAR2)
      RETURN DATE;
   FUNCTION DATE_5(
      P_DOCUMENT_KEY IN VARCHAR2)
      RETURN DATE;
   FUNCTION DOCUMENT_LEVEL_CODE(
      P_DOCUMENT_KEY IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION NEXT_EQUAL_DAYTIME(
      P_DOCUMENT_KEY IN VARCHAR2,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION REF_OBJECT_ID_2(
      P_DOCUMENT_KEY IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION REF_OBJECT_ID_3(
      P_DOCUMENT_KEY IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION REVERSAL_DATE(
      P_DOCUMENT_KEY IN VARCHAR2)
      RETURN DATE;
   FUNCTION TEXT_1(
      P_DOCUMENT_KEY IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION TEXT_6(
      P_DOCUMENT_KEY IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION TEXT_9(
      P_DOCUMENT_KEY IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION VALUE_6(
      P_DOCUMENT_KEY IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION CONTRACT_ID(
      P_DOCUMENT_KEY IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION DATE_2(
      P_DOCUMENT_KEY IN VARCHAR2)
      RETURN DATE;
   FUNCTION INVENTORY_ID(
      P_DOCUMENT_KEY IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION PREV_DAYTIME(
      P_DOCUMENT_KEY IN VARCHAR2,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION RECORD_STATUS(
      P_DOCUMENT_KEY IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION REF_OBJECT_ID_5(
      P_DOCUMENT_KEY IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION VALUE_1(
      P_DOCUMENT_KEY IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION APPROVAL_DATE(
      P_DOCUMENT_KEY IN VARCHAR2)
      RETURN DATE;
   FUNCTION DATE_6(
      P_DOCUMENT_KEY IN VARCHAR2)
      RETURN DATE;
   FUNCTION REF_OBJECT_ID_1(
      P_DOCUMENT_KEY IN VARCHAR2)
      RETURN VARCHAR2;
      TYPE REC_ROW_BY_PK IS RECORD (
         OBJECT_ID VARCHAR2 (32) ,
         DAYTIME  DATE ,
         DOCUMENT_KEY VARCHAR2 (32) ,
         DOCUMENT_TYPE VARCHAR2 (32) ,
         DOCUMENT_LEVEL_CODE VARCHAR2 (32) ,
         FINANCIAL_CODE VARCHAR2 (32) ,
         DATASET VARCHAR2 (32) ,
         PRECEDING_DOCUMENT_KEY VARCHAR2 (32) ,
         REVERSAL_DATE  DATE ,
         DOCUMENT_NUMBER VARCHAR2 (240) ,
         STATUS_CODE VARCHAR2 (32) ,
         REFERENCE VARCHAR2 (2000) ,
         SUMMARY_SETUP_ID VARCHAR2 (32) ,
         PARENT_DOCUMENT_KEY VARCHAR2 (32) ,
         CONTRACT_ID VARCHAR2 (32) ,
         PERIOD  DATE ,
         REPORTING_PERIOD  DATE ,
         COMMENTS VARCHAR2 (2000) ,
         IS_MANUAL_IND VARCHAR2 (1) ,
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
         ACCRUAL_IND VARCHAR2 (1) ,
         INVENTORY_ID VARCHAR2 (32) ,
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
      P_DOCUMENT_KEY IN VARCHAR2)
      RETURN REC_ROW_BY_PK;
   FUNCTION STATUS_CODE(
      P_DOCUMENT_KEY IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION TEXT_2(
      P_DOCUMENT_KEY IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION TEXT_4(
      P_DOCUMENT_KEY IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION TEXT_5(
      P_DOCUMENT_KEY IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION VALUE_2(
      P_DOCUMENT_KEY IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION VALUE_3(
      P_DOCUMENT_KEY IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION VALUE_4(
      P_DOCUMENT_KEY IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION DATE_4(
      P_DOCUMENT_KEY IN VARCHAR2)
      RETURN DATE;
   FUNCTION PERIOD(
      P_DOCUMENT_KEY IN VARCHAR2)
      RETURN DATE;
   FUNCTION REC_ID(
      P_DOCUMENT_KEY IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION REFERENCE(
      P_DOCUMENT_KEY IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION VALUE_7(
      P_DOCUMENT_KEY IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION VALUE_9(
      P_DOCUMENT_KEY IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION DATE_1(
      P_DOCUMENT_KEY IN VARCHAR2)
      RETURN DATE;
   FUNCTION DATE_8(
      P_DOCUMENT_KEY IN VARCHAR2)
      RETURN DATE;
   FUNCTION DAYTIME(
      P_DOCUMENT_KEY IN VARCHAR2)
      RETURN DATE;
   FUNCTION FINANCIAL_CODE(
      P_DOCUMENT_KEY IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION TEXT_10(
      P_DOCUMENT_KEY IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION VALUE_10(
      P_DOCUMENT_KEY IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION VALUE_8(
      P_DOCUMENT_KEY IN VARCHAR2)
      RETURN NUMBER;

END RP_CONT_DOC;

/



CREATE or REPLACE PACKAGE BODY RP_CONT_DOC
IS

   FUNCTION DATE_10(
      P_DOCUMENT_KEY IN VARCHAR2)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CONT_DOC.DATE_10      (
         P_DOCUMENT_KEY );
         RETURN ret_value;
   END DATE_10;
   FUNCTION DOCUMENT_TYPE(
      P_DOCUMENT_KEY IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_CONT_DOC.DOCUMENT_TYPE      (
         P_DOCUMENT_KEY );
         RETURN ret_value;
   END DOCUMENT_TYPE;
   FUNCTION IS_MANUAL_IND(
      P_DOCUMENT_KEY IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_CONT_DOC.IS_MANUAL_IND      (
         P_DOCUMENT_KEY );
         RETURN ret_value;
   END IS_MANUAL_IND;
   FUNCTION PARENT_DOCUMENT_KEY(
      P_DOCUMENT_KEY IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_CONT_DOC.PARENT_DOCUMENT_KEY      (
         P_DOCUMENT_KEY );
         RETURN ret_value;
   END PARENT_DOCUMENT_KEY;
   FUNCTION SUMMARY_SETUP_ID(
      P_DOCUMENT_KEY IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_CONT_DOC.SUMMARY_SETUP_ID      (
         P_DOCUMENT_KEY );
         RETURN ret_value;
   END SUMMARY_SETUP_ID;
   FUNCTION TEXT_3(
      P_DOCUMENT_KEY IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_CONT_DOC.TEXT_3      (
         P_DOCUMENT_KEY );
         RETURN ret_value;
   END TEXT_3;
   FUNCTION APPROVAL_BY(
      P_DOCUMENT_KEY IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (30) ;
   BEGIN
      ret_value := EC_CONT_DOC.APPROVAL_BY      (
         P_DOCUMENT_KEY );
         RETURN ret_value;
   END APPROVAL_BY;
   FUNCTION APPROVAL_STATE(
      P_DOCUMENT_KEY IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_CONT_DOC.APPROVAL_STATE      (
         P_DOCUMENT_KEY );
         RETURN ret_value;
   END APPROVAL_STATE;
   FUNCTION DATASET(
      P_DOCUMENT_KEY IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_CONT_DOC.DATASET      (
         P_DOCUMENT_KEY );
         RETURN ret_value;
   END DATASET;
   FUNCTION PRECEDING_DOCUMENT_KEY(
      P_DOCUMENT_KEY IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_CONT_DOC.PRECEDING_DOCUMENT_KEY      (
         P_DOCUMENT_KEY );
         RETURN ret_value;
   END PRECEDING_DOCUMENT_KEY;
   FUNCTION REF_OBJECT_ID_4(
      P_DOCUMENT_KEY IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_CONT_DOC.REF_OBJECT_ID_4      (
         P_DOCUMENT_KEY );
         RETURN ret_value;
   END REF_OBJECT_ID_4;
   FUNCTION REPORTING_PERIOD(
      P_DOCUMENT_KEY IN VARCHAR2)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CONT_DOC.REPORTING_PERIOD      (
         P_DOCUMENT_KEY );
         RETURN ret_value;
   END REPORTING_PERIOD;
   FUNCTION VALUE_5(
      P_DOCUMENT_KEY IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CONT_DOC.VALUE_5      (
         P_DOCUMENT_KEY );
         RETURN ret_value;
   END VALUE_5;
   FUNCTION ACCRUAL_IND(
      P_DOCUMENT_KEY IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_CONT_DOC.ACCRUAL_IND      (
         P_DOCUMENT_KEY );
         RETURN ret_value;
   END ACCRUAL_IND;
   FUNCTION DATE_7(
      P_DOCUMENT_KEY IN VARCHAR2)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CONT_DOC.DATE_7      (
         P_DOCUMENT_KEY );
         RETURN ret_value;
   END DATE_7;
   FUNCTION DATE_9(
      P_DOCUMENT_KEY IN VARCHAR2)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CONT_DOC.DATE_9      (
         P_DOCUMENT_KEY );
         RETURN ret_value;
   END DATE_9;
   FUNCTION DOCUMENT_NUMBER(
      P_DOCUMENT_KEY IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_CONT_DOC.DOCUMENT_NUMBER      (
         P_DOCUMENT_KEY );
         RETURN ret_value;
   END DOCUMENT_NUMBER;
   FUNCTION NEXT_DAYTIME(
      P_DOCUMENT_KEY IN VARCHAR2,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CONT_DOC.NEXT_DAYTIME      (
         P_DOCUMENT_KEY,
         P_NUM_ROWS );
         RETURN ret_value;
   END NEXT_DAYTIME;
   FUNCTION OBJECT_ID(
      P_DOCUMENT_KEY IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_CONT_DOC.OBJECT_ID      (
         P_DOCUMENT_KEY );
         RETURN ret_value;
   END OBJECT_ID;
   FUNCTION PREV_EQUAL_DAYTIME(
      P_DOCUMENT_KEY IN VARCHAR2,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CONT_DOC.PREV_EQUAL_DAYTIME      (
         P_DOCUMENT_KEY,
         P_NUM_ROWS );
         RETURN ret_value;
   END PREV_EQUAL_DAYTIME;
   FUNCTION TEXT_7(
      P_DOCUMENT_KEY IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_CONT_DOC.TEXT_7      (
         P_DOCUMENT_KEY );
         RETURN ret_value;
   END TEXT_7;
   FUNCTION TEXT_8(
      P_DOCUMENT_KEY IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_CONT_DOC.TEXT_8      (
         P_DOCUMENT_KEY );
         RETURN ret_value;
   END TEXT_8;
   FUNCTION COMMENTS(
      P_DOCUMENT_KEY IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_CONT_DOC.COMMENTS      (
         P_DOCUMENT_KEY );
         RETURN ret_value;
   END COMMENTS;
   FUNCTION DATE_3(
      P_DOCUMENT_KEY IN VARCHAR2)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CONT_DOC.DATE_3      (
         P_DOCUMENT_KEY );
         RETURN ret_value;
   END DATE_3;
   FUNCTION DATE_5(
      P_DOCUMENT_KEY IN VARCHAR2)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CONT_DOC.DATE_5      (
         P_DOCUMENT_KEY );
         RETURN ret_value;
   END DATE_5;
   FUNCTION DOCUMENT_LEVEL_CODE(
      P_DOCUMENT_KEY IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_CONT_DOC.DOCUMENT_LEVEL_CODE      (
         P_DOCUMENT_KEY );
         RETURN ret_value;
   END DOCUMENT_LEVEL_CODE;
   FUNCTION NEXT_EQUAL_DAYTIME(
      P_DOCUMENT_KEY IN VARCHAR2,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CONT_DOC.NEXT_EQUAL_DAYTIME      (
         P_DOCUMENT_KEY,
         P_NUM_ROWS );
         RETURN ret_value;
   END NEXT_EQUAL_DAYTIME;
   FUNCTION REF_OBJECT_ID_2(
      P_DOCUMENT_KEY IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_CONT_DOC.REF_OBJECT_ID_2      (
         P_DOCUMENT_KEY );
         RETURN ret_value;
   END REF_OBJECT_ID_2;
   FUNCTION REF_OBJECT_ID_3(
      P_DOCUMENT_KEY IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_CONT_DOC.REF_OBJECT_ID_3      (
         P_DOCUMENT_KEY );
         RETURN ret_value;
   END REF_OBJECT_ID_3;
   FUNCTION REVERSAL_DATE(
      P_DOCUMENT_KEY IN VARCHAR2)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CONT_DOC.REVERSAL_DATE      (
         P_DOCUMENT_KEY );
         RETURN ret_value;
   END REVERSAL_DATE;
   FUNCTION TEXT_1(
      P_DOCUMENT_KEY IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_CONT_DOC.TEXT_1      (
         P_DOCUMENT_KEY );
         RETURN ret_value;
   END TEXT_1;
   FUNCTION TEXT_6(
      P_DOCUMENT_KEY IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_CONT_DOC.TEXT_6      (
         P_DOCUMENT_KEY );
         RETURN ret_value;
   END TEXT_6;
   FUNCTION TEXT_9(
      P_DOCUMENT_KEY IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_CONT_DOC.TEXT_9      (
         P_DOCUMENT_KEY );
         RETURN ret_value;
   END TEXT_9;
   FUNCTION VALUE_6(
      P_DOCUMENT_KEY IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CONT_DOC.VALUE_6      (
         P_DOCUMENT_KEY );
         RETURN ret_value;
   END VALUE_6;
   FUNCTION CONTRACT_ID(
      P_DOCUMENT_KEY IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_CONT_DOC.CONTRACT_ID      (
         P_DOCUMENT_KEY );
         RETURN ret_value;
   END CONTRACT_ID;
   FUNCTION DATE_2(
      P_DOCUMENT_KEY IN VARCHAR2)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CONT_DOC.DATE_2      (
         P_DOCUMENT_KEY );
         RETURN ret_value;
   END DATE_2;
   FUNCTION INVENTORY_ID(
      P_DOCUMENT_KEY IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_CONT_DOC.INVENTORY_ID      (
         P_DOCUMENT_KEY );
         RETURN ret_value;
   END INVENTORY_ID;
   FUNCTION PREV_DAYTIME(
      P_DOCUMENT_KEY IN VARCHAR2,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CONT_DOC.PREV_DAYTIME      (
         P_DOCUMENT_KEY,
         P_NUM_ROWS );
         RETURN ret_value;
   END PREV_DAYTIME;
   FUNCTION RECORD_STATUS(
      P_DOCUMENT_KEY IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_CONT_DOC.RECORD_STATUS      (
         P_DOCUMENT_KEY );
         RETURN ret_value;
   END RECORD_STATUS;
   FUNCTION REF_OBJECT_ID_5(
      P_DOCUMENT_KEY IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_CONT_DOC.REF_OBJECT_ID_5      (
         P_DOCUMENT_KEY );
         RETURN ret_value;
   END REF_OBJECT_ID_5;
   FUNCTION VALUE_1(
      P_DOCUMENT_KEY IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CONT_DOC.VALUE_1      (
         P_DOCUMENT_KEY );
         RETURN ret_value;
   END VALUE_1;
   FUNCTION APPROVAL_DATE(
      P_DOCUMENT_KEY IN VARCHAR2)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CONT_DOC.APPROVAL_DATE      (
         P_DOCUMENT_KEY );
         RETURN ret_value;
   END APPROVAL_DATE;
   FUNCTION DATE_6(
      P_DOCUMENT_KEY IN VARCHAR2)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CONT_DOC.DATE_6      (
         P_DOCUMENT_KEY );
         RETURN ret_value;
   END DATE_6;
   FUNCTION REF_OBJECT_ID_1(
      P_DOCUMENT_KEY IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_CONT_DOC.REF_OBJECT_ID_1      (
         P_DOCUMENT_KEY );
         RETURN ret_value;
   END REF_OBJECT_ID_1;
   FUNCTION ROW_BY_PK(
      P_DOCUMENT_KEY IN VARCHAR2)
      RETURN REC_ROW_BY_PK
   IS
      ret_value    REC_ROW_BY_PK ;
   BEGIN
      ret_value := EC_CONT_DOC.ROW_BY_PK      (
         P_DOCUMENT_KEY );
         RETURN ret_value;
   END ROW_BY_PK;
   FUNCTION STATUS_CODE(
      P_DOCUMENT_KEY IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_CONT_DOC.STATUS_CODE      (
         P_DOCUMENT_KEY );
         RETURN ret_value;
   END STATUS_CODE;
   FUNCTION TEXT_2(
      P_DOCUMENT_KEY IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_CONT_DOC.TEXT_2      (
         P_DOCUMENT_KEY );
         RETURN ret_value;
   END TEXT_2;
   FUNCTION TEXT_4(
      P_DOCUMENT_KEY IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_CONT_DOC.TEXT_4      (
         P_DOCUMENT_KEY );
         RETURN ret_value;
   END TEXT_4;
   FUNCTION TEXT_5(
      P_DOCUMENT_KEY IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_CONT_DOC.TEXT_5      (
         P_DOCUMENT_KEY );
         RETURN ret_value;
   END TEXT_5;
   FUNCTION VALUE_2(
      P_DOCUMENT_KEY IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CONT_DOC.VALUE_2      (
         P_DOCUMENT_KEY );
         RETURN ret_value;
   END VALUE_2;
   FUNCTION VALUE_3(
      P_DOCUMENT_KEY IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CONT_DOC.VALUE_3      (
         P_DOCUMENT_KEY );
         RETURN ret_value;
   END VALUE_3;
   FUNCTION VALUE_4(
      P_DOCUMENT_KEY IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CONT_DOC.VALUE_4      (
         P_DOCUMENT_KEY );
         RETURN ret_value;
   END VALUE_4;
   FUNCTION DATE_4(
      P_DOCUMENT_KEY IN VARCHAR2)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CONT_DOC.DATE_4      (
         P_DOCUMENT_KEY );
         RETURN ret_value;
   END DATE_4;
   FUNCTION PERIOD(
      P_DOCUMENT_KEY IN VARCHAR2)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CONT_DOC.PERIOD      (
         P_DOCUMENT_KEY );
         RETURN ret_value;
   END PERIOD;
   FUNCTION REC_ID(
      P_DOCUMENT_KEY IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_CONT_DOC.REC_ID      (
         P_DOCUMENT_KEY );
         RETURN ret_value;
   END REC_ID;
   FUNCTION REFERENCE(
      P_DOCUMENT_KEY IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_CONT_DOC.REFERENCE      (
         P_DOCUMENT_KEY );
         RETURN ret_value;
   END REFERENCE;
   FUNCTION VALUE_7(
      P_DOCUMENT_KEY IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CONT_DOC.VALUE_7      (
         P_DOCUMENT_KEY );
         RETURN ret_value;
   END VALUE_7;
   FUNCTION VALUE_9(
      P_DOCUMENT_KEY IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CONT_DOC.VALUE_9      (
         P_DOCUMENT_KEY );
         RETURN ret_value;
   END VALUE_9;
   FUNCTION DATE_1(
      P_DOCUMENT_KEY IN VARCHAR2)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CONT_DOC.DATE_1      (
         P_DOCUMENT_KEY );
         RETURN ret_value;
   END DATE_1;
   FUNCTION DATE_8(
      P_DOCUMENT_KEY IN VARCHAR2)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CONT_DOC.DATE_8      (
         P_DOCUMENT_KEY );
         RETURN ret_value;
   END DATE_8;
   FUNCTION DAYTIME(
      P_DOCUMENT_KEY IN VARCHAR2)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CONT_DOC.DAYTIME      (
         P_DOCUMENT_KEY );
         RETURN ret_value;
   END DAYTIME;
   FUNCTION FINANCIAL_CODE(
      P_DOCUMENT_KEY IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_CONT_DOC.FINANCIAL_CODE      (
         P_DOCUMENT_KEY );
         RETURN ret_value;
   END FINANCIAL_CODE;
   FUNCTION TEXT_10(
      P_DOCUMENT_KEY IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_CONT_DOC.TEXT_10      (
         P_DOCUMENT_KEY );
         RETURN ret_value;
   END TEXT_10;
   FUNCTION VALUE_10(
      P_DOCUMENT_KEY IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CONT_DOC.VALUE_10      (
         P_DOCUMENT_KEY );
         RETURN ret_value;
   END VALUE_10;
   FUNCTION VALUE_8(
      P_DOCUMENT_KEY IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CONT_DOC.VALUE_8      (
         P_DOCUMENT_KEY );
         RETURN ret_value;
   END VALUE_8;

END RP_CONT_DOC;

/
--GRANT EXECUTE ON ECKERNEL_WST.RP_CONT_DOC TO REPORT_ROLE_XXX;



 -- FINISH PKG_GEN_PKGS.sf_get_functions at:05/07/2019 10.40.06 AM


