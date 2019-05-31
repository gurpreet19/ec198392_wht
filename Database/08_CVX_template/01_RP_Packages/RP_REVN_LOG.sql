
 -- START PKG_GEN_PKGS.sf_get_functions at:05/07/2019 07.40.03 AM


CREATE or REPLACE PACKAGE RP_REVN_LOG
IS

   FUNCTION DESCRIPTION(
      P_LOG_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION PARAM_VALUE_1(
      P_LOG_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION TEXT_4(
      P_LOG_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_BY(
      P_LOG_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_STATE(
      P_LOG_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION NEXT_DAYTIME(
      P_LOG_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION PARAM_TEXT_1(
      P_LOG_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION PARAM_TEXT_2(
      P_LOG_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION PARAM_TEXT_3(
      P_LOG_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION PREV_EQUAL_DAYTIME(
      P_LOG_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION TEXT_5(
      P_LOG_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION NEXT_EQUAL_DAYTIME(
      P_LOG_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION PARAM_TEXT_4(
      P_LOG_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION CONTRACT_ID(
      P_LOG_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION PREV_DAYTIME(
      P_LOG_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION RECORD_STATUS(
      P_LOG_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_1(
      P_LOG_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION APPROVAL_DATE(
      P_LOG_NO IN NUMBER)
      RETURN DATE;
      TYPE REC_ROW_BY_PK IS RECORD (
         LOG_NO NUMBER ,
         CATEGORY VARCHAR2 (240) ,
         DAYTIME  DATE ,
         DESCRIPTION VARCHAR2 (2000) ,
         STATUS VARCHAR2 (30) ,
         PARAM_TEXT_1 VARCHAR2 (2000) ,
         PARAM_TEXT_2 VARCHAR2 (2000) ,
         PARAM_TEXT_3 VARCHAR2 (2000) ,
         PARAM_TEXT_4 VARCHAR2 (2000) ,
         PARAM_TEXT_5 VARCHAR2 (2000) ,
         PARAM_DATE_1  DATE ,
         PARAM_VALUE_1 NUMBER ,
         TEXT_1 VARCHAR2 (2000) ,
         TEXT_2 VARCHAR2 (2000) ,
         TEXT_3 VARCHAR2 (2000) ,
         TEXT_4 VARCHAR2 (2000) ,
         TEXT_5 VARCHAR2 (2000) ,
         DATE_1  DATE ,
         VALUE_1 NUMBER ,
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
         REC_ID VARCHAR2 (32) ,
         CONTRACT_ID VARCHAR2 (32)  );
   FUNCTION ROW_BY_PK(
      P_LOG_NO IN NUMBER)
      RETURN REC_ROW_BY_PK;
   FUNCTION TEXT_2(
      P_LOG_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION PARAM_DATE_1(
      P_LOG_NO IN NUMBER)
      RETURN DATE;
   FUNCTION PARAM_TEXT_5(
      P_LOG_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION REC_ID(
      P_LOG_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION STATUS(
      P_LOG_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_1(
      P_LOG_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION CATEGORY(
      P_LOG_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION DATE_1(
      P_LOG_NO IN NUMBER)
      RETURN DATE;
   FUNCTION DAYTIME(
      P_LOG_NO IN NUMBER)
      RETURN DATE;
   FUNCTION TEXT_3(
      P_LOG_NO IN NUMBER)
      RETURN VARCHAR2;

END RP_REVN_LOG;

/



CREATE or REPLACE PACKAGE BODY RP_REVN_LOG
IS

   FUNCTION DESCRIPTION(
      P_LOG_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_REVN_LOG.DESCRIPTION      (
         P_LOG_NO );
         RETURN ret_value;
   END DESCRIPTION;
   FUNCTION PARAM_VALUE_1(
      P_LOG_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_REVN_LOG.PARAM_VALUE_1      (
         P_LOG_NO );
         RETURN ret_value;
   END PARAM_VALUE_1;
   FUNCTION TEXT_4(
      P_LOG_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_REVN_LOG.TEXT_4      (
         P_LOG_NO );
         RETURN ret_value;
   END TEXT_4;
   FUNCTION APPROVAL_BY(
      P_LOG_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (30) ;
   BEGIN
      ret_value := EC_REVN_LOG.APPROVAL_BY      (
         P_LOG_NO );
         RETURN ret_value;
   END APPROVAL_BY;
   FUNCTION APPROVAL_STATE(
      P_LOG_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_REVN_LOG.APPROVAL_STATE      (
         P_LOG_NO );
         RETURN ret_value;
   END APPROVAL_STATE;
   FUNCTION NEXT_DAYTIME(
      P_LOG_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_REVN_LOG.NEXT_DAYTIME      (
         P_LOG_NO,
         P_NUM_ROWS );
         RETURN ret_value;
   END NEXT_DAYTIME;
   FUNCTION PARAM_TEXT_1(
      P_LOG_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_REVN_LOG.PARAM_TEXT_1      (
         P_LOG_NO );
         RETURN ret_value;
   END PARAM_TEXT_1;
   FUNCTION PARAM_TEXT_2(
      P_LOG_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_REVN_LOG.PARAM_TEXT_2      (
         P_LOG_NO );
         RETURN ret_value;
   END PARAM_TEXT_2;
   FUNCTION PARAM_TEXT_3(
      P_LOG_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_REVN_LOG.PARAM_TEXT_3      (
         P_LOG_NO );
         RETURN ret_value;
   END PARAM_TEXT_3;
   FUNCTION PREV_EQUAL_DAYTIME(
      P_LOG_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_REVN_LOG.PREV_EQUAL_DAYTIME      (
         P_LOG_NO,
         P_NUM_ROWS );
         RETURN ret_value;
   END PREV_EQUAL_DAYTIME;
   FUNCTION TEXT_5(
      P_LOG_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_REVN_LOG.TEXT_5      (
         P_LOG_NO );
         RETURN ret_value;
   END TEXT_5;
   FUNCTION NEXT_EQUAL_DAYTIME(
      P_LOG_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_REVN_LOG.NEXT_EQUAL_DAYTIME      (
         P_LOG_NO,
         P_NUM_ROWS );
         RETURN ret_value;
   END NEXT_EQUAL_DAYTIME;
   FUNCTION PARAM_TEXT_4(
      P_LOG_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_REVN_LOG.PARAM_TEXT_4      (
         P_LOG_NO );
         RETURN ret_value;
   END PARAM_TEXT_4;
   FUNCTION CONTRACT_ID(
      P_LOG_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_REVN_LOG.CONTRACT_ID      (
         P_LOG_NO );
         RETURN ret_value;
   END CONTRACT_ID;
   FUNCTION PREV_DAYTIME(
      P_LOG_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_REVN_LOG.PREV_DAYTIME      (
         P_LOG_NO,
         P_NUM_ROWS );
         RETURN ret_value;
   END PREV_DAYTIME;
   FUNCTION RECORD_STATUS(
      P_LOG_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_REVN_LOG.RECORD_STATUS      (
         P_LOG_NO );
         RETURN ret_value;
   END RECORD_STATUS;
   FUNCTION VALUE_1(
      P_LOG_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_REVN_LOG.VALUE_1      (
         P_LOG_NO );
         RETURN ret_value;
   END VALUE_1;
   FUNCTION APPROVAL_DATE(
      P_LOG_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_REVN_LOG.APPROVAL_DATE      (
         P_LOG_NO );
         RETURN ret_value;
   END APPROVAL_DATE;
   FUNCTION ROW_BY_PK(
      P_LOG_NO IN NUMBER)
      RETURN REC_ROW_BY_PK
   IS
      ret_value    REC_ROW_BY_PK ;
   BEGIN
      ret_value := EC_REVN_LOG.ROW_BY_PK      (
         P_LOG_NO );
         RETURN ret_value;
   END ROW_BY_PK;
   FUNCTION TEXT_2(
      P_LOG_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_REVN_LOG.TEXT_2      (
         P_LOG_NO );
         RETURN ret_value;
   END TEXT_2;
   FUNCTION PARAM_DATE_1(
      P_LOG_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_REVN_LOG.PARAM_DATE_1      (
         P_LOG_NO );
         RETURN ret_value;
   END PARAM_DATE_1;
   FUNCTION PARAM_TEXT_5(
      P_LOG_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_REVN_LOG.PARAM_TEXT_5      (
         P_LOG_NO );
         RETURN ret_value;
   END PARAM_TEXT_5;
   FUNCTION REC_ID(
      P_LOG_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_REVN_LOG.REC_ID      (
         P_LOG_NO );
         RETURN ret_value;
   END REC_ID;
   FUNCTION STATUS(
      P_LOG_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (30) ;
   BEGIN
      ret_value := EC_REVN_LOG.STATUS      (
         P_LOG_NO );
         RETURN ret_value;
   END STATUS;
   FUNCTION TEXT_1(
      P_LOG_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_REVN_LOG.TEXT_1      (
         P_LOG_NO );
         RETURN ret_value;
   END TEXT_1;
   FUNCTION CATEGORY(
      P_LOG_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_REVN_LOG.CATEGORY      (
         P_LOG_NO );
         RETURN ret_value;
   END CATEGORY;
   FUNCTION DATE_1(
      P_LOG_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_REVN_LOG.DATE_1      (
         P_LOG_NO );
         RETURN ret_value;
   END DATE_1;
   FUNCTION DAYTIME(
      P_LOG_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_REVN_LOG.DAYTIME      (
         P_LOG_NO );
         RETURN ret_value;
   END DAYTIME;
   FUNCTION TEXT_3(
      P_LOG_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_REVN_LOG.TEXT_3      (
         P_LOG_NO );
         RETURN ret_value;
   END TEXT_3;

END RP_REVN_LOG;

/
--GRANT EXECUTE ON ECKERNEL_WST.RP_REVN_LOG TO REPORT_ROLE_XXX;



 -- FINISH PKG_GEN_PKGS.sf_get_functions at:05/07/2019 07.40.13 AM


