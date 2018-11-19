
 -- START PKG_GEN_PKGS.sf_get_functions at:11/15/2018 10.18.07 AM


CREATE or REPLACE PACKAGE RP_CTRL_CHECK_RULES
IS

   FUNCTION CHECK_MESSAGE(
      P_CHECK_ID IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION CHECK_NAME(
      P_CHECK_ID IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION DESCRIPTION(
      P_CHECK_ID IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_BY(
      P_CHECK_ID IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_STATE(
      P_CHECK_ID IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION SELECT_CLAUSE(
      P_CHECK_ID IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION WHERE_CLAUSE(
      P_CHECK_ID IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION RECORD_STATUS(
      P_CHECK_ID IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_DATE(
      P_CHECK_ID IN NUMBER)
      RETURN DATE;
      TYPE REC_ROW_BY_PK IS RECORD (
         CHECK_ID NUMBER ,
         CHECK_NAME VARCHAR2 (30) ,
         TABLE_ID VARCHAR2 (30) ,
         SELECT_CLAUSE VARCHAR2 (2000) ,
         WHERE_CLAUSE VARCHAR2 (2000) ,
         SEVERITY_LEVEL VARCHAR2 (16) ,
         CHECK_MESSAGE VARCHAR2 (240) ,
         DESCRIPTION VARCHAR2 (2000) ,
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
      P_CHECK_ID IN NUMBER)
      RETURN REC_ROW_BY_PK;
   FUNCTION REC_ID(
      P_CHECK_ID IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION SEVERITY_LEVEL(
      P_CHECK_ID IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TABLE_ID(
      P_CHECK_ID IN NUMBER)
      RETURN VARCHAR2;

END RP_CTRL_CHECK_RULES;

/



CREATE or REPLACE PACKAGE BODY RP_CTRL_CHECK_RULES
IS

   FUNCTION CHECK_MESSAGE(
      P_CHECK_ID IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_CTRL_CHECK_RULES.CHECK_MESSAGE      (
         P_CHECK_ID );
         RETURN ret_value;
   END CHECK_MESSAGE;
   FUNCTION CHECK_NAME(
      P_CHECK_ID IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (30) ;
   BEGIN
      ret_value := EC_CTRL_CHECK_RULES.CHECK_NAME      (
         P_CHECK_ID );
         RETURN ret_value;
   END CHECK_NAME;
   FUNCTION DESCRIPTION(
      P_CHECK_ID IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_CTRL_CHECK_RULES.DESCRIPTION      (
         P_CHECK_ID );
         RETURN ret_value;
   END DESCRIPTION;
   FUNCTION APPROVAL_BY(
      P_CHECK_ID IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (30) ;
   BEGIN
      ret_value := EC_CTRL_CHECK_RULES.APPROVAL_BY      (
         P_CHECK_ID );
         RETURN ret_value;
   END APPROVAL_BY;
   FUNCTION APPROVAL_STATE(
      P_CHECK_ID IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_CTRL_CHECK_RULES.APPROVAL_STATE      (
         P_CHECK_ID );
         RETURN ret_value;
   END APPROVAL_STATE;
   FUNCTION SELECT_CLAUSE(
      P_CHECK_ID IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_CTRL_CHECK_RULES.SELECT_CLAUSE      (
         P_CHECK_ID );
         RETURN ret_value;
   END SELECT_CLAUSE;
   FUNCTION WHERE_CLAUSE(
      P_CHECK_ID IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_CTRL_CHECK_RULES.WHERE_CLAUSE      (
         P_CHECK_ID );
         RETURN ret_value;
   END WHERE_CLAUSE;
   FUNCTION RECORD_STATUS(
      P_CHECK_ID IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_CTRL_CHECK_RULES.RECORD_STATUS      (
         P_CHECK_ID );
         RETURN ret_value;
   END RECORD_STATUS;
   FUNCTION APPROVAL_DATE(
      P_CHECK_ID IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CTRL_CHECK_RULES.APPROVAL_DATE      (
         P_CHECK_ID );
         RETURN ret_value;
   END APPROVAL_DATE;
   FUNCTION ROW_BY_PK(
      P_CHECK_ID IN NUMBER)
      RETURN REC_ROW_BY_PK
   IS
      ret_value    REC_ROW_BY_PK ;
   BEGIN
      ret_value := EC_CTRL_CHECK_RULES.ROW_BY_PK      (
         P_CHECK_ID );
         RETURN ret_value;
   END ROW_BY_PK;
   FUNCTION REC_ID(
      P_CHECK_ID IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_CTRL_CHECK_RULES.REC_ID      (
         P_CHECK_ID );
         RETURN ret_value;
   END REC_ID;
   FUNCTION SEVERITY_LEVEL(
      P_CHECK_ID IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (16) ;
   BEGIN
      ret_value := EC_CTRL_CHECK_RULES.SEVERITY_LEVEL      (
         P_CHECK_ID );
         RETURN ret_value;
   END SEVERITY_LEVEL;
   FUNCTION TABLE_ID(
      P_CHECK_ID IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (30) ;
   BEGIN
      ret_value := EC_CTRL_CHECK_RULES.TABLE_ID      (
         P_CHECK_ID );
         RETURN ret_value;
   END TABLE_ID;

END RP_CTRL_CHECK_RULES;

/
--GRANT EXECUTE ON ECKERNEL_WST.RP_CTRL_CHECK_RULES TO REPORT_ROLE_XXX;



 -- FINISH PKG_GEN_PKGS.sf_get_functions at:11/15/2018 10.18.10 AM


