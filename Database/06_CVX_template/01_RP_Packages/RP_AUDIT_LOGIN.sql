
 -- START PKG_GEN_PKGS.sf_get_functions at:11/15/2018 11.03.14 AM


CREATE or REPLACE PACKAGE RP_AUDIT_LOGIN
IS

   FUNCTION APPROVAL_BY(
      P_REC_ID IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_STATE(
      P_REC_ID IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION REMOTE_USER(
      P_REC_ID IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION NEXT_DAYTIME(
      P_REC_ID IN VARCHAR2,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION PREV_EQUAL_DAYTIME(
      P_REC_ID IN VARCHAR2,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION REMOTE_HOST(
      P_REC_ID IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION NEXT_EQUAL_DAYTIME(
      P_REC_ID IN VARCHAR2,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION REMOTE_ADDRESS(
      P_REC_ID IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION PREV_DAYTIME(
      P_REC_ID IN VARCHAR2,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION RECORD_STATUS(
      P_REC_ID IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_DATE(
      P_REC_ID IN VARCHAR2)
      RETURN DATE;
      TYPE REC_ROW_BY_PK IS RECORD (
         REC_ID VARCHAR2 (32) ,
         DAYTIME  DATE ,
         REMOTE_ADDRESS VARCHAR2 (64) ,
         REMOTE_HOST VARCHAR2 (4000) ,
         REMOTE_USER VARCHAR2 (4000) ,
         SERVER_NAME VARCHAR2 (4000) ,
         SERVER_PORT NUMBER ,
         AUTHENTICATED_IND VARCHAR2 (1) ,
         RECORD_STATUS VARCHAR2 (1) ,
         CREATED_BY VARCHAR2 (30) ,
         CREATED_DATE  DATE ,
         LAST_UPDATED_BY VARCHAR2 (30) ,
         LAST_UPDATED_DATE  DATE ,
         REV_NO NUMBER ,
         REV_TEXT VARCHAR2 (2000) ,
         APPROVAL_BY VARCHAR2 (30) ,
         APPROVAL_DATE  DATE ,
         APPROVAL_STATE VARCHAR2 (1)  );
   FUNCTION ROW_BY_PK(
      P_REC_ID IN VARCHAR2)
      RETURN REC_ROW_BY_PK;
   FUNCTION AUTHENTICATED_IND(
      P_REC_ID IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION DAYTIME(
      P_REC_ID IN VARCHAR2)
      RETURN DATE;
   FUNCTION SERVER_NAME(
      P_REC_ID IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION SERVER_PORT(
      P_REC_ID IN VARCHAR2)
      RETURN NUMBER;

END RP_AUDIT_LOGIN;

/



CREATE or REPLACE PACKAGE BODY RP_AUDIT_LOGIN
IS

   FUNCTION APPROVAL_BY(
      P_REC_ID IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (30) ;
   BEGIN
      ret_value := EC_AUDIT_LOGIN.APPROVAL_BY      (
         P_REC_ID );
         RETURN ret_value;
   END APPROVAL_BY;
   FUNCTION APPROVAL_STATE(
      P_REC_ID IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_AUDIT_LOGIN.APPROVAL_STATE      (
         P_REC_ID );
         RETURN ret_value;
   END APPROVAL_STATE;
   FUNCTION REMOTE_USER(
      P_REC_ID IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (4000) ;
   BEGIN
      ret_value := EC_AUDIT_LOGIN.REMOTE_USER      (
         P_REC_ID );
         RETURN ret_value;
   END REMOTE_USER;
   FUNCTION NEXT_DAYTIME(
      P_REC_ID IN VARCHAR2,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_AUDIT_LOGIN.NEXT_DAYTIME      (
         P_REC_ID,
         P_NUM_ROWS );
         RETURN ret_value;
   END NEXT_DAYTIME;
   FUNCTION PREV_EQUAL_DAYTIME(
      P_REC_ID IN VARCHAR2,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_AUDIT_LOGIN.PREV_EQUAL_DAYTIME      (
         P_REC_ID,
         P_NUM_ROWS );
         RETURN ret_value;
   END PREV_EQUAL_DAYTIME;
   FUNCTION REMOTE_HOST(
      P_REC_ID IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (4000) ;
   BEGIN
      ret_value := EC_AUDIT_LOGIN.REMOTE_HOST      (
         P_REC_ID );
         RETURN ret_value;
   END REMOTE_HOST;
   FUNCTION NEXT_EQUAL_DAYTIME(
      P_REC_ID IN VARCHAR2,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_AUDIT_LOGIN.NEXT_EQUAL_DAYTIME      (
         P_REC_ID,
         P_NUM_ROWS );
         RETURN ret_value;
   END NEXT_EQUAL_DAYTIME;
   FUNCTION REMOTE_ADDRESS(
      P_REC_ID IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (64) ;
   BEGIN
      ret_value := EC_AUDIT_LOGIN.REMOTE_ADDRESS      (
         P_REC_ID );
         RETURN ret_value;
   END REMOTE_ADDRESS;
   FUNCTION PREV_DAYTIME(
      P_REC_ID IN VARCHAR2,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_AUDIT_LOGIN.PREV_DAYTIME      (
         P_REC_ID,
         P_NUM_ROWS );
         RETURN ret_value;
   END PREV_DAYTIME;
   FUNCTION RECORD_STATUS(
      P_REC_ID IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_AUDIT_LOGIN.RECORD_STATUS      (
         P_REC_ID );
         RETURN ret_value;
   END RECORD_STATUS;
   FUNCTION APPROVAL_DATE(
      P_REC_ID IN VARCHAR2)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_AUDIT_LOGIN.APPROVAL_DATE      (
         P_REC_ID );
         RETURN ret_value;
   END APPROVAL_DATE;
   FUNCTION ROW_BY_PK(
      P_REC_ID IN VARCHAR2)
      RETURN REC_ROW_BY_PK
   IS
      ret_value    REC_ROW_BY_PK ;
   BEGIN
      ret_value := EC_AUDIT_LOGIN.ROW_BY_PK      (
         P_REC_ID );
         RETURN ret_value;
   END ROW_BY_PK;
   FUNCTION AUTHENTICATED_IND(
      P_REC_ID IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_AUDIT_LOGIN.AUTHENTICATED_IND      (
         P_REC_ID );
         RETURN ret_value;
   END AUTHENTICATED_IND;
   FUNCTION DAYTIME(
      P_REC_ID IN VARCHAR2)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_AUDIT_LOGIN.DAYTIME      (
         P_REC_ID );
         RETURN ret_value;
   END DAYTIME;
   FUNCTION SERVER_NAME(
      P_REC_ID IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (4000) ;
   BEGIN
      ret_value := EC_AUDIT_LOGIN.SERVER_NAME      (
         P_REC_ID );
         RETURN ret_value;
   END SERVER_NAME;
   FUNCTION SERVER_PORT(
      P_REC_ID IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_AUDIT_LOGIN.SERVER_PORT      (
         P_REC_ID );
         RETURN ret_value;
   END SERVER_PORT;

END RP_AUDIT_LOGIN;

/
--GRANT EXECUTE ON ECKERNEL_WST.RP_AUDIT_LOGIN TO REPORT_ROLE_XXX;



 -- FINISH PKG_GEN_PKGS.sf_get_functions at:11/15/2018 11.03.18 AM


