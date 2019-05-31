
 -- START PKG_GEN_PKGS.sf_get_functions at:05/07/2019 09.25.26 AM


CREATE or REPLACE PACKAGE RP_FT_ST_DOCUMENT
IS

   FUNCTION DATE_10(
      P_FT_ST_DOCUMENT_NO IN NUMBER)
      RETURN DATE;
   FUNCTION TEXT_3(
      P_FT_ST_DOCUMENT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_BY(
      P_FT_ST_DOCUMENT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_STATE(
      P_FT_ST_DOCUMENT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION CONTRACT_DOC_ID(
      P_FT_ST_DOCUMENT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION PRECEDING_DOCUMENT_KEY(
      P_FT_ST_DOCUMENT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION REF_OBJECT_ID_4(
      P_FT_ST_DOCUMENT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_5(
      P_FT_ST_DOCUMENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION DATE_7(
      P_FT_ST_DOCUMENT_NO IN NUMBER)
      RETURN DATE;
   FUNCTION DATE_9(
      P_FT_ST_DOCUMENT_NO IN NUMBER)
      RETURN DATE;
   FUNCTION NEXT_DAYTIME(
      P_FT_ST_DOCUMENT_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION OBJECT_ID(
      P_FT_ST_DOCUMENT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION PERIOD_END_DATE(
      P_FT_ST_DOCUMENT_NO IN NUMBER)
      RETURN DATE;
   FUNCTION PREV_EQUAL_DAYTIME(
      P_FT_ST_DOCUMENT_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION STAGING_DOC_STATUS(
      P_FT_ST_DOCUMENT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_7(
      P_FT_ST_DOCUMENT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_8(
      P_FT_ST_DOCUMENT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION DATE_3(
      P_FT_ST_DOCUMENT_NO IN NUMBER)
      RETURN DATE;
   FUNCTION DATE_5(
      P_FT_ST_DOCUMENT_NO IN NUMBER)
      RETURN DATE;
   FUNCTION NEXT_EQUAL_DAYTIME(
      P_FT_ST_DOCUMENT_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION REF_OBJECT_ID_2(
      P_FT_ST_DOCUMENT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION REF_OBJECT_ID_3(
      P_FT_ST_DOCUMENT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_1(
      P_FT_ST_DOCUMENT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_6(
      P_FT_ST_DOCUMENT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_9(
      P_FT_ST_DOCUMENT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_6(
      P_FT_ST_DOCUMENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION DATE_2(
      P_FT_ST_DOCUMENT_NO IN NUMBER)
      RETURN DATE;
   FUNCTION PERIOD_START_DATE(
      P_FT_ST_DOCUMENT_NO IN NUMBER)
      RETURN DATE;
   FUNCTION PREV_DAYTIME(
      P_FT_ST_DOCUMENT_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION RECORD_STATUS(
      P_FT_ST_DOCUMENT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION REF_OBJECT_ID_5(
      P_FT_ST_DOCUMENT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION SYSTEM_ACTION_CODE(
      P_FT_ST_DOCUMENT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_1(
      P_FT_ST_DOCUMENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION APPROVAL_DATE(
      P_FT_ST_DOCUMENT_NO IN NUMBER)
      RETURN DATE;
   FUNCTION DATE_6(
      P_FT_ST_DOCUMENT_NO IN NUMBER)
      RETURN DATE;
   FUNCTION DOCUMENT_DATE(
      P_FT_ST_DOCUMENT_NO IN NUMBER)
      RETURN DATE;
   FUNCTION REF_OBJECT_ID_1(
      P_FT_ST_DOCUMENT_NO IN NUMBER)
      RETURN VARCHAR2;
      TYPE REC_ROW_BY_PK IS RECORD (
         FT_ST_DOCUMENT_NO NUMBER ,
         OBJECT_ID VARCHAR2 (32) ,
         DAYTIME  DATE ,
         DOCUMENT_DATE  DATE ,
         PRODUCTION_PERIOD  DATE ,
         PERIOD_START_DATE  DATE ,
         PERIOD_END_DATE  DATE ,
         STAGING_DOC_STATUS VARCHAR2 (32) ,
         CALCULATION_KEY VARCHAR2 (32) ,
         PRECEDING_DOCUMENT_KEY VARCHAR2 (32) ,
         CONTRACT_DOC_CODE VARCHAR2 (32) ,
         CONTRACT_DOC_ID VARCHAR2 (32) ,
         STATUS_CODE VARCHAR2 (32) ,
         SYSTEM_ACTION_CODE VARCHAR2 (32) ,
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
      P_FT_ST_DOCUMENT_NO IN NUMBER)
      RETURN REC_ROW_BY_PK;
   FUNCTION STATUS_CODE(
      P_FT_ST_DOCUMENT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_2(
      P_FT_ST_DOCUMENT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_4(
      P_FT_ST_DOCUMENT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_5(
      P_FT_ST_DOCUMENT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_2(
      P_FT_ST_DOCUMENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_3(
      P_FT_ST_DOCUMENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_4(
      P_FT_ST_DOCUMENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION DATE_4(
      P_FT_ST_DOCUMENT_NO IN NUMBER)
      RETURN DATE;
   FUNCTION PRODUCTION_PERIOD(
      P_FT_ST_DOCUMENT_NO IN NUMBER)
      RETURN DATE;
   FUNCTION REC_ID(
      P_FT_ST_DOCUMENT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_7(
      P_FT_ST_DOCUMENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_9(
      P_FT_ST_DOCUMENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION CALCULATION_KEY(
      P_FT_ST_DOCUMENT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION CONTRACT_DOC_CODE(
      P_FT_ST_DOCUMENT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION DATE_1(
      P_FT_ST_DOCUMENT_NO IN NUMBER)
      RETURN DATE;
   FUNCTION DATE_8(
      P_FT_ST_DOCUMENT_NO IN NUMBER)
      RETURN DATE;
   FUNCTION DAYTIME(
      P_FT_ST_DOCUMENT_NO IN NUMBER)
      RETURN DATE;
   FUNCTION TEXT_10(
      P_FT_ST_DOCUMENT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_10(
      P_FT_ST_DOCUMENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_8(
      P_FT_ST_DOCUMENT_NO IN NUMBER)
      RETURN NUMBER;

END RP_FT_ST_DOCUMENT;

/



CREATE or REPLACE PACKAGE BODY RP_FT_ST_DOCUMENT
IS

   FUNCTION DATE_10(
      P_FT_ST_DOCUMENT_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_FT_ST_DOCUMENT.DATE_10      (
         P_FT_ST_DOCUMENT_NO );
         RETURN ret_value;
   END DATE_10;
   FUNCTION TEXT_3(
      P_FT_ST_DOCUMENT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_FT_ST_DOCUMENT.TEXT_3      (
         P_FT_ST_DOCUMENT_NO );
         RETURN ret_value;
   END TEXT_3;
   FUNCTION APPROVAL_BY(
      P_FT_ST_DOCUMENT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (30) ;
   BEGIN
      ret_value := EC_FT_ST_DOCUMENT.APPROVAL_BY      (
         P_FT_ST_DOCUMENT_NO );
         RETURN ret_value;
   END APPROVAL_BY;
   FUNCTION APPROVAL_STATE(
      P_FT_ST_DOCUMENT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_FT_ST_DOCUMENT.APPROVAL_STATE      (
         P_FT_ST_DOCUMENT_NO );
         RETURN ret_value;
   END APPROVAL_STATE;
   FUNCTION CONTRACT_DOC_ID(
      P_FT_ST_DOCUMENT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_FT_ST_DOCUMENT.CONTRACT_DOC_ID      (
         P_FT_ST_DOCUMENT_NO );
         RETURN ret_value;
   END CONTRACT_DOC_ID;
   FUNCTION PRECEDING_DOCUMENT_KEY(
      P_FT_ST_DOCUMENT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_FT_ST_DOCUMENT.PRECEDING_DOCUMENT_KEY      (
         P_FT_ST_DOCUMENT_NO );
         RETURN ret_value;
   END PRECEDING_DOCUMENT_KEY;
   FUNCTION REF_OBJECT_ID_4(
      P_FT_ST_DOCUMENT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_FT_ST_DOCUMENT.REF_OBJECT_ID_4      (
         P_FT_ST_DOCUMENT_NO );
         RETURN ret_value;
   END REF_OBJECT_ID_4;
   FUNCTION VALUE_5(
      P_FT_ST_DOCUMENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FT_ST_DOCUMENT.VALUE_5      (
         P_FT_ST_DOCUMENT_NO );
         RETURN ret_value;
   END VALUE_5;
   FUNCTION DATE_7(
      P_FT_ST_DOCUMENT_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_FT_ST_DOCUMENT.DATE_7      (
         P_FT_ST_DOCUMENT_NO );
         RETURN ret_value;
   END DATE_7;
   FUNCTION DATE_9(
      P_FT_ST_DOCUMENT_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_FT_ST_DOCUMENT.DATE_9      (
         P_FT_ST_DOCUMENT_NO );
         RETURN ret_value;
   END DATE_9;
   FUNCTION NEXT_DAYTIME(
      P_FT_ST_DOCUMENT_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_FT_ST_DOCUMENT.NEXT_DAYTIME      (
         P_FT_ST_DOCUMENT_NO,
         P_NUM_ROWS );
         RETURN ret_value;
   END NEXT_DAYTIME;
   FUNCTION OBJECT_ID(
      P_FT_ST_DOCUMENT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_FT_ST_DOCUMENT.OBJECT_ID      (
         P_FT_ST_DOCUMENT_NO );
         RETURN ret_value;
   END OBJECT_ID;
   FUNCTION PERIOD_END_DATE(
      P_FT_ST_DOCUMENT_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_FT_ST_DOCUMENT.PERIOD_END_DATE      (
         P_FT_ST_DOCUMENT_NO );
         RETURN ret_value;
   END PERIOD_END_DATE;
   FUNCTION PREV_EQUAL_DAYTIME(
      P_FT_ST_DOCUMENT_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_FT_ST_DOCUMENT.PREV_EQUAL_DAYTIME      (
         P_FT_ST_DOCUMENT_NO,
         P_NUM_ROWS );
         RETURN ret_value;
   END PREV_EQUAL_DAYTIME;
   FUNCTION STAGING_DOC_STATUS(
      P_FT_ST_DOCUMENT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_FT_ST_DOCUMENT.STAGING_DOC_STATUS      (
         P_FT_ST_DOCUMENT_NO );
         RETURN ret_value;
   END STAGING_DOC_STATUS;
   FUNCTION TEXT_7(
      P_FT_ST_DOCUMENT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_FT_ST_DOCUMENT.TEXT_7      (
         P_FT_ST_DOCUMENT_NO );
         RETURN ret_value;
   END TEXT_7;
   FUNCTION TEXT_8(
      P_FT_ST_DOCUMENT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_FT_ST_DOCUMENT.TEXT_8      (
         P_FT_ST_DOCUMENT_NO );
         RETURN ret_value;
   END TEXT_8;
   FUNCTION DATE_3(
      P_FT_ST_DOCUMENT_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_FT_ST_DOCUMENT.DATE_3      (
         P_FT_ST_DOCUMENT_NO );
         RETURN ret_value;
   END DATE_3;
   FUNCTION DATE_5(
      P_FT_ST_DOCUMENT_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_FT_ST_DOCUMENT.DATE_5      (
         P_FT_ST_DOCUMENT_NO );
         RETURN ret_value;
   END DATE_5;
   FUNCTION NEXT_EQUAL_DAYTIME(
      P_FT_ST_DOCUMENT_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_FT_ST_DOCUMENT.NEXT_EQUAL_DAYTIME      (
         P_FT_ST_DOCUMENT_NO,
         P_NUM_ROWS );
         RETURN ret_value;
   END NEXT_EQUAL_DAYTIME;
   FUNCTION REF_OBJECT_ID_2(
      P_FT_ST_DOCUMENT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_FT_ST_DOCUMENT.REF_OBJECT_ID_2      (
         P_FT_ST_DOCUMENT_NO );
         RETURN ret_value;
   END REF_OBJECT_ID_2;
   FUNCTION REF_OBJECT_ID_3(
      P_FT_ST_DOCUMENT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_FT_ST_DOCUMENT.REF_OBJECT_ID_3      (
         P_FT_ST_DOCUMENT_NO );
         RETURN ret_value;
   END REF_OBJECT_ID_3;
   FUNCTION TEXT_1(
      P_FT_ST_DOCUMENT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_FT_ST_DOCUMENT.TEXT_1      (
         P_FT_ST_DOCUMENT_NO );
         RETURN ret_value;
   END TEXT_1;
   FUNCTION TEXT_6(
      P_FT_ST_DOCUMENT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_FT_ST_DOCUMENT.TEXT_6      (
         P_FT_ST_DOCUMENT_NO );
         RETURN ret_value;
   END TEXT_6;
   FUNCTION TEXT_9(
      P_FT_ST_DOCUMENT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_FT_ST_DOCUMENT.TEXT_9      (
         P_FT_ST_DOCUMENT_NO );
         RETURN ret_value;
   END TEXT_9;
   FUNCTION VALUE_6(
      P_FT_ST_DOCUMENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FT_ST_DOCUMENT.VALUE_6      (
         P_FT_ST_DOCUMENT_NO );
         RETURN ret_value;
   END VALUE_6;
   FUNCTION DATE_2(
      P_FT_ST_DOCUMENT_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_FT_ST_DOCUMENT.DATE_2      (
         P_FT_ST_DOCUMENT_NO );
         RETURN ret_value;
   END DATE_2;
   FUNCTION PERIOD_START_DATE(
      P_FT_ST_DOCUMENT_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_FT_ST_DOCUMENT.PERIOD_START_DATE      (
         P_FT_ST_DOCUMENT_NO );
         RETURN ret_value;
   END PERIOD_START_DATE;
   FUNCTION PREV_DAYTIME(
      P_FT_ST_DOCUMENT_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_FT_ST_DOCUMENT.PREV_DAYTIME      (
         P_FT_ST_DOCUMENT_NO,
         P_NUM_ROWS );
         RETURN ret_value;
   END PREV_DAYTIME;
   FUNCTION RECORD_STATUS(
      P_FT_ST_DOCUMENT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_FT_ST_DOCUMENT.RECORD_STATUS      (
         P_FT_ST_DOCUMENT_NO );
         RETURN ret_value;
   END RECORD_STATUS;
   FUNCTION REF_OBJECT_ID_5(
      P_FT_ST_DOCUMENT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_FT_ST_DOCUMENT.REF_OBJECT_ID_5      (
         P_FT_ST_DOCUMENT_NO );
         RETURN ret_value;
   END REF_OBJECT_ID_5;
   FUNCTION SYSTEM_ACTION_CODE(
      P_FT_ST_DOCUMENT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_FT_ST_DOCUMENT.SYSTEM_ACTION_CODE      (
         P_FT_ST_DOCUMENT_NO );
         RETURN ret_value;
   END SYSTEM_ACTION_CODE;
   FUNCTION VALUE_1(
      P_FT_ST_DOCUMENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FT_ST_DOCUMENT.VALUE_1      (
         P_FT_ST_DOCUMENT_NO );
         RETURN ret_value;
   END VALUE_1;
   FUNCTION APPROVAL_DATE(
      P_FT_ST_DOCUMENT_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_FT_ST_DOCUMENT.APPROVAL_DATE      (
         P_FT_ST_DOCUMENT_NO );
         RETURN ret_value;
   END APPROVAL_DATE;
   FUNCTION DATE_6(
      P_FT_ST_DOCUMENT_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_FT_ST_DOCUMENT.DATE_6      (
         P_FT_ST_DOCUMENT_NO );
         RETURN ret_value;
   END DATE_6;
   FUNCTION DOCUMENT_DATE(
      P_FT_ST_DOCUMENT_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_FT_ST_DOCUMENT.DOCUMENT_DATE      (
         P_FT_ST_DOCUMENT_NO );
         RETURN ret_value;
   END DOCUMENT_DATE;
   FUNCTION REF_OBJECT_ID_1(
      P_FT_ST_DOCUMENT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_FT_ST_DOCUMENT.REF_OBJECT_ID_1      (
         P_FT_ST_DOCUMENT_NO );
         RETURN ret_value;
   END REF_OBJECT_ID_1;
   FUNCTION ROW_BY_PK(
      P_FT_ST_DOCUMENT_NO IN NUMBER)
      RETURN REC_ROW_BY_PK
   IS
      ret_value    REC_ROW_BY_PK ;
   BEGIN
      ret_value := EC_FT_ST_DOCUMENT.ROW_BY_PK      (
         P_FT_ST_DOCUMENT_NO );
         RETURN ret_value;
   END ROW_BY_PK;
   FUNCTION STATUS_CODE(
      P_FT_ST_DOCUMENT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_FT_ST_DOCUMENT.STATUS_CODE      (
         P_FT_ST_DOCUMENT_NO );
         RETURN ret_value;
   END STATUS_CODE;
   FUNCTION TEXT_2(
      P_FT_ST_DOCUMENT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_FT_ST_DOCUMENT.TEXT_2      (
         P_FT_ST_DOCUMENT_NO );
         RETURN ret_value;
   END TEXT_2;
   FUNCTION TEXT_4(
      P_FT_ST_DOCUMENT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_FT_ST_DOCUMENT.TEXT_4      (
         P_FT_ST_DOCUMENT_NO );
         RETURN ret_value;
   END TEXT_4;
   FUNCTION TEXT_5(
      P_FT_ST_DOCUMENT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_FT_ST_DOCUMENT.TEXT_5      (
         P_FT_ST_DOCUMENT_NO );
         RETURN ret_value;
   END TEXT_5;
   FUNCTION VALUE_2(
      P_FT_ST_DOCUMENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FT_ST_DOCUMENT.VALUE_2      (
         P_FT_ST_DOCUMENT_NO );
         RETURN ret_value;
   END VALUE_2;
   FUNCTION VALUE_3(
      P_FT_ST_DOCUMENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FT_ST_DOCUMENT.VALUE_3      (
         P_FT_ST_DOCUMENT_NO );
         RETURN ret_value;
   END VALUE_3;
   FUNCTION VALUE_4(
      P_FT_ST_DOCUMENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FT_ST_DOCUMENT.VALUE_4      (
         P_FT_ST_DOCUMENT_NO );
         RETURN ret_value;
   END VALUE_4;
   FUNCTION DATE_4(
      P_FT_ST_DOCUMENT_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_FT_ST_DOCUMENT.DATE_4      (
         P_FT_ST_DOCUMENT_NO );
         RETURN ret_value;
   END DATE_4;
   FUNCTION PRODUCTION_PERIOD(
      P_FT_ST_DOCUMENT_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_FT_ST_DOCUMENT.PRODUCTION_PERIOD      (
         P_FT_ST_DOCUMENT_NO );
         RETURN ret_value;
   END PRODUCTION_PERIOD;
   FUNCTION REC_ID(
      P_FT_ST_DOCUMENT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_FT_ST_DOCUMENT.REC_ID      (
         P_FT_ST_DOCUMENT_NO );
         RETURN ret_value;
   END REC_ID;
   FUNCTION VALUE_7(
      P_FT_ST_DOCUMENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FT_ST_DOCUMENT.VALUE_7      (
         P_FT_ST_DOCUMENT_NO );
         RETURN ret_value;
   END VALUE_7;
   FUNCTION VALUE_9(
      P_FT_ST_DOCUMENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FT_ST_DOCUMENT.VALUE_9      (
         P_FT_ST_DOCUMENT_NO );
         RETURN ret_value;
   END VALUE_9;
   FUNCTION CALCULATION_KEY(
      P_FT_ST_DOCUMENT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_FT_ST_DOCUMENT.CALCULATION_KEY      (
         P_FT_ST_DOCUMENT_NO );
         RETURN ret_value;
   END CALCULATION_KEY;
   FUNCTION CONTRACT_DOC_CODE(
      P_FT_ST_DOCUMENT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_FT_ST_DOCUMENT.CONTRACT_DOC_CODE      (
         P_FT_ST_DOCUMENT_NO );
         RETURN ret_value;
   END CONTRACT_DOC_CODE;
   FUNCTION DATE_1(
      P_FT_ST_DOCUMENT_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_FT_ST_DOCUMENT.DATE_1      (
         P_FT_ST_DOCUMENT_NO );
         RETURN ret_value;
   END DATE_1;
   FUNCTION DATE_8(
      P_FT_ST_DOCUMENT_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_FT_ST_DOCUMENT.DATE_8      (
         P_FT_ST_DOCUMENT_NO );
         RETURN ret_value;
   END DATE_8;
   FUNCTION DAYTIME(
      P_FT_ST_DOCUMENT_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_FT_ST_DOCUMENT.DAYTIME      (
         P_FT_ST_DOCUMENT_NO );
         RETURN ret_value;
   END DAYTIME;
   FUNCTION TEXT_10(
      P_FT_ST_DOCUMENT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_FT_ST_DOCUMENT.TEXT_10      (
         P_FT_ST_DOCUMENT_NO );
         RETURN ret_value;
   END TEXT_10;
   FUNCTION VALUE_10(
      P_FT_ST_DOCUMENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FT_ST_DOCUMENT.VALUE_10      (
         P_FT_ST_DOCUMENT_NO );
         RETURN ret_value;
   END VALUE_10;
   FUNCTION VALUE_8(
      P_FT_ST_DOCUMENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FT_ST_DOCUMENT.VALUE_8      (
         P_FT_ST_DOCUMENT_NO );
         RETURN ret_value;
   END VALUE_8;

END RP_FT_ST_DOCUMENT;

/
--GRANT EXECUTE ON ECKERNEL_WST.RP_FT_ST_DOCUMENT TO REPORT_ROLE_XXX;



 -- FINISH PKG_GEN_PKGS.sf_get_functions at:05/07/2019 09.25.38 AM


