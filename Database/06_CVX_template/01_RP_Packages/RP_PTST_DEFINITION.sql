
 -- START PKG_GEN_PKGS.sf_get_functions at:11/15/2018 08.17.26 AM


CREATE or REPLACE PACKAGE RP_PTST_DEFINITION
IS

   FUNCTION TEXT_3(
      P_TEST_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_4(
      P_TEST_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_BY(
      P_TEST_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_STATE(
      P_TEST_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_5(
      P_TEST_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION NEXT_DAYTIME(
      P_TEST_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION PREV_EQUAL_DAYTIME(
      P_TEST_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION COMMENTS(
      P_TEST_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION NEXT_EQUAL_DAYTIME(
      P_TEST_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION VALUE_6(
      P_TEST_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION END_DATE(
      P_TEST_NO IN NUMBER)
      RETURN DATE;
   FUNCTION PREV_DAYTIME(
      P_TEST_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION RECORD_STATUS(
      P_TEST_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_1(
      P_TEST_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION APPROVAL_DATE(
      P_TEST_NO IN NUMBER)
      RETURN DATE;
      TYPE REC_ROW_BY_PK IS RECORD (
         TEST_NO NUMBER ,
         DAYTIME  DATE ,
         END_DATE  DATE ,
         TEST_TYPE VARCHAR2 (32) ,
         COMMENTS VARCHAR2 (2000) ,
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
         TEXT_1 VARCHAR2 (16) ,
         TEXT_2 VARCHAR2 (32) ,
         TEXT_3 VARCHAR2 (240) ,
         TEXT_4 VARCHAR2 (2000) ,
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
      P_TEST_NO IN NUMBER)
      RETURN REC_ROW_BY_PK;
   FUNCTION VALUE_2(
      P_TEST_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_3(
      P_TEST_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_4(
      P_TEST_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION REC_ID(
      P_TEST_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_1(
      P_TEST_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_2(
      P_TEST_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_7(
      P_TEST_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_9(
      P_TEST_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION DAYTIME(
      P_TEST_NO IN NUMBER)
      RETURN DATE;
   FUNCTION TEST_TYPE(
      P_TEST_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_10(
      P_TEST_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_8(
      P_TEST_NO IN NUMBER)
      RETURN NUMBER;

END RP_PTST_DEFINITION;

/



CREATE or REPLACE PACKAGE BODY RP_PTST_DEFINITION
IS

   FUNCTION TEXT_3(
      P_TEST_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_PTST_DEFINITION.TEXT_3      (
         P_TEST_NO );
         RETURN ret_value;
   END TEXT_3;
   FUNCTION TEXT_4(
      P_TEST_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_PTST_DEFINITION.TEXT_4      (
         P_TEST_NO );
         RETURN ret_value;
   END TEXT_4;
   FUNCTION APPROVAL_BY(
      P_TEST_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (30) ;
   BEGIN
      ret_value := EC_PTST_DEFINITION.APPROVAL_BY      (
         P_TEST_NO );
         RETURN ret_value;
   END APPROVAL_BY;
   FUNCTION APPROVAL_STATE(
      P_TEST_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_PTST_DEFINITION.APPROVAL_STATE      (
         P_TEST_NO );
         RETURN ret_value;
   END APPROVAL_STATE;
   FUNCTION VALUE_5(
      P_TEST_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_PTST_DEFINITION.VALUE_5      (
         P_TEST_NO );
         RETURN ret_value;
   END VALUE_5;
   FUNCTION NEXT_DAYTIME(
      P_TEST_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_PTST_DEFINITION.NEXT_DAYTIME      (
         P_TEST_NO,
         P_NUM_ROWS );
         RETURN ret_value;
   END NEXT_DAYTIME;
   FUNCTION PREV_EQUAL_DAYTIME(
      P_TEST_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_PTST_DEFINITION.PREV_EQUAL_DAYTIME      (
         P_TEST_NO,
         P_NUM_ROWS );
         RETURN ret_value;
   END PREV_EQUAL_DAYTIME;
   FUNCTION COMMENTS(
      P_TEST_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_PTST_DEFINITION.COMMENTS      (
         P_TEST_NO );
         RETURN ret_value;
   END COMMENTS;
   FUNCTION NEXT_EQUAL_DAYTIME(
      P_TEST_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_PTST_DEFINITION.NEXT_EQUAL_DAYTIME      (
         P_TEST_NO,
         P_NUM_ROWS );
         RETURN ret_value;
   END NEXT_EQUAL_DAYTIME;
   FUNCTION VALUE_6(
      P_TEST_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_PTST_DEFINITION.VALUE_6      (
         P_TEST_NO );
         RETURN ret_value;
   END VALUE_6;
   FUNCTION END_DATE(
      P_TEST_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_PTST_DEFINITION.END_DATE      (
         P_TEST_NO );
         RETURN ret_value;
   END END_DATE;
   FUNCTION PREV_DAYTIME(
      P_TEST_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_PTST_DEFINITION.PREV_DAYTIME      (
         P_TEST_NO,
         P_NUM_ROWS );
         RETURN ret_value;
   END PREV_DAYTIME;
   FUNCTION RECORD_STATUS(
      P_TEST_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_PTST_DEFINITION.RECORD_STATUS      (
         P_TEST_NO );
         RETURN ret_value;
   END RECORD_STATUS;
   FUNCTION VALUE_1(
      P_TEST_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_PTST_DEFINITION.VALUE_1      (
         P_TEST_NO );
         RETURN ret_value;
   END VALUE_1;
   FUNCTION APPROVAL_DATE(
      P_TEST_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_PTST_DEFINITION.APPROVAL_DATE      (
         P_TEST_NO );
         RETURN ret_value;
   END APPROVAL_DATE;
   FUNCTION ROW_BY_PK(
      P_TEST_NO IN NUMBER)
      RETURN REC_ROW_BY_PK
   IS
      ret_value    REC_ROW_BY_PK ;
   BEGIN
      ret_value := EC_PTST_DEFINITION.ROW_BY_PK      (
         P_TEST_NO );
         RETURN ret_value;
   END ROW_BY_PK;
   FUNCTION VALUE_2(
      P_TEST_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_PTST_DEFINITION.VALUE_2      (
         P_TEST_NO );
         RETURN ret_value;
   END VALUE_2;
   FUNCTION VALUE_3(
      P_TEST_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_PTST_DEFINITION.VALUE_3      (
         P_TEST_NO );
         RETURN ret_value;
   END VALUE_3;
   FUNCTION VALUE_4(
      P_TEST_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_PTST_DEFINITION.VALUE_4      (
         P_TEST_NO );
         RETURN ret_value;
   END VALUE_4;
   FUNCTION REC_ID(
      P_TEST_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_PTST_DEFINITION.REC_ID      (
         P_TEST_NO );
         RETURN ret_value;
   END REC_ID;
   FUNCTION TEXT_1(
      P_TEST_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (16) ;
   BEGIN
      ret_value := EC_PTST_DEFINITION.TEXT_1      (
         P_TEST_NO );
         RETURN ret_value;
   END TEXT_1;
   FUNCTION TEXT_2(
      P_TEST_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_PTST_DEFINITION.TEXT_2      (
         P_TEST_NO );
         RETURN ret_value;
   END TEXT_2;
   FUNCTION VALUE_7(
      P_TEST_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_PTST_DEFINITION.VALUE_7      (
         P_TEST_NO );
         RETURN ret_value;
   END VALUE_7;
   FUNCTION VALUE_9(
      P_TEST_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_PTST_DEFINITION.VALUE_9      (
         P_TEST_NO );
         RETURN ret_value;
   END VALUE_9;
   FUNCTION DAYTIME(
      P_TEST_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_PTST_DEFINITION.DAYTIME      (
         P_TEST_NO );
         RETURN ret_value;
   END DAYTIME;
   FUNCTION TEST_TYPE(
      P_TEST_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_PTST_DEFINITION.TEST_TYPE      (
         P_TEST_NO );
         RETURN ret_value;
   END TEST_TYPE;
   FUNCTION VALUE_10(
      P_TEST_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_PTST_DEFINITION.VALUE_10      (
         P_TEST_NO );
         RETURN ret_value;
   END VALUE_10;
   FUNCTION VALUE_8(
      P_TEST_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_PTST_DEFINITION.VALUE_8      (
         P_TEST_NO );
         RETURN ret_value;
   END VALUE_8;

END RP_PTST_DEFINITION;

/
--GRANT EXECUTE ON ECKERNEL_WST.RP_PTST_DEFINITION TO REPORT_ROLE_XXX;



 -- FINISH PKG_GEN_PKGS.sf_get_functions at:11/15/2018 08.17.32 AM


