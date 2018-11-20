
 -- START PKG_GEN_PKGS.sf_get_functions at:11/15/2018 10.18.10 AM


CREATE or REPLACE PACKAGE RP_CTRL_CHECK_LOG
IS

   FUNCTION APPROVAL_BY(
      P_CHECK_ID IN NUMBER,
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2;
   FUNCTION APPROVAL_STATE(
      P_CHECK_ID IN NUMBER,
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2;
   FUNCTION LOG_MESSAGE(
      P_CHECK_ID IN NUMBER,
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2;
   FUNCTION CHECK_GROUP(
      P_CHECK_ID IN NUMBER,
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2;
   FUNCTION NEXT_DAYTIME(
      P_CHECK_ID IN NUMBER,
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION PREV_EQUAL_DAYTIME(
      P_CHECK_ID IN NUMBER,
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION STATUS(
      P_CHECK_ID IN NUMBER,
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2;
   FUNCTION CLASS_NAME(
      P_CHECK_ID IN NUMBER,
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2;
   FUNCTION COMMENTS(
      P_CHECK_ID IN NUMBER,
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2;
   FUNCTION NEXT_EQUAL_DAYTIME(
      P_CHECK_ID IN NUMBER,
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION PREV_DAYTIME(
      P_CHECK_ID IN NUMBER,
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION RECORD_STATUS(
      P_CHECK_ID IN NUMBER,
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2;
   FUNCTION APPROVAL_DATE(
      P_CHECK_ID IN NUMBER,
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN DATE;
      TYPE REC_ROW_BY_PK IS RECORD (
         CHECK_ID NUMBER ,
         OBJECT_ID VARCHAR2 (32) ,
         DAYTIME  DATE ,
         CLASS_NAME VARCHAR2 (24) ,
         CHECK_GROUP VARCHAR2 (30) ,
         CHECK_DAYTIME  DATE ,
         SEVERITY_LEVEL VARCHAR2 (16) ,
         STATUS VARCHAR2 (20) ,
         LOG_MESSAGE VARCHAR2 (2000) ,
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
         COMMENTS VARCHAR2 (2000)  );
   FUNCTION ROW_BY_PK(
      P_CHECK_ID IN NUMBER,
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN REC_ROW_BY_PK;
      TYPE REC_ROW_BY_REL_OPERATOR IS RECORD (
         CHECK_ID NUMBER ,
         OBJECT_ID VARCHAR2 (32) ,
         DAYTIME  DATE ,
         CLASS_NAME VARCHAR2 (24) ,
         CHECK_GROUP VARCHAR2 (30) ,
         CHECK_DAYTIME  DATE ,
         SEVERITY_LEVEL VARCHAR2 (16) ,
         STATUS VARCHAR2 (20) ,
         LOG_MESSAGE VARCHAR2 (2000) ,
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
         COMMENTS VARCHAR2 (2000)  );
   FUNCTION ROW_BY_REL_OPERATOR(
      P_CHECK_ID IN NUMBER,
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN REC_ROW_BY_REL_OPERATOR;
   FUNCTION REC_ID(
      P_CHECK_ID IN NUMBER,
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2;
   FUNCTION CHECK_DAYTIME(
      P_CHECK_ID IN NUMBER,
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN DATE;
   FUNCTION SEVERITY_LEVEL(
      P_CHECK_ID IN NUMBER,
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2;

END RP_CTRL_CHECK_LOG;

/



CREATE or REPLACE PACKAGE BODY RP_CTRL_CHECK_LOG
IS

   FUNCTION APPROVAL_BY(
      P_CHECK_ID IN NUMBER,
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (30) ;
   BEGIN
      ret_value := EC_CTRL_CHECK_LOG.APPROVAL_BY      (
         P_CHECK_ID,
         P_OBJECT_ID,
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END APPROVAL_BY;
   FUNCTION APPROVAL_STATE(
      P_CHECK_ID IN NUMBER,
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_CTRL_CHECK_LOG.APPROVAL_STATE      (
         P_CHECK_ID,
         P_OBJECT_ID,
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END APPROVAL_STATE;
   FUNCTION LOG_MESSAGE(
      P_CHECK_ID IN NUMBER,
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_CTRL_CHECK_LOG.LOG_MESSAGE      (
         P_CHECK_ID,
         P_OBJECT_ID,
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END LOG_MESSAGE;
   FUNCTION CHECK_GROUP(
      P_CHECK_ID IN NUMBER,
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (30) ;
   BEGIN
      ret_value := EC_CTRL_CHECK_LOG.CHECK_GROUP      (
         P_CHECK_ID,
         P_OBJECT_ID,
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END CHECK_GROUP;
   FUNCTION NEXT_DAYTIME(
      P_CHECK_ID IN NUMBER,
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CTRL_CHECK_LOG.NEXT_DAYTIME      (
         P_CHECK_ID,
         P_OBJECT_ID,
         P_DAYTIME,
         P_NUM_ROWS );
         RETURN ret_value;
   END NEXT_DAYTIME;
   FUNCTION PREV_EQUAL_DAYTIME(
      P_CHECK_ID IN NUMBER,
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CTRL_CHECK_LOG.PREV_EQUAL_DAYTIME      (
         P_CHECK_ID,
         P_OBJECT_ID,
         P_DAYTIME,
         P_NUM_ROWS );
         RETURN ret_value;
   END PREV_EQUAL_DAYTIME;
   FUNCTION STATUS(
      P_CHECK_ID IN NUMBER,
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (20) ;
   BEGIN
      ret_value := EC_CTRL_CHECK_LOG.STATUS      (
         P_CHECK_ID,
         P_OBJECT_ID,
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END STATUS;
   FUNCTION CLASS_NAME(
      P_CHECK_ID IN NUMBER,
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (24) ;
   BEGIN
      ret_value := EC_CTRL_CHECK_LOG.CLASS_NAME      (
         P_CHECK_ID,
         P_OBJECT_ID,
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END CLASS_NAME;
   FUNCTION COMMENTS(
      P_CHECK_ID IN NUMBER,
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_CTRL_CHECK_LOG.COMMENTS      (
         P_CHECK_ID,
         P_OBJECT_ID,
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END COMMENTS;
   FUNCTION NEXT_EQUAL_DAYTIME(
      P_CHECK_ID IN NUMBER,
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CTRL_CHECK_LOG.NEXT_EQUAL_DAYTIME      (
         P_CHECK_ID,
         P_OBJECT_ID,
         P_DAYTIME,
         P_NUM_ROWS );
         RETURN ret_value;
   END NEXT_EQUAL_DAYTIME;
   FUNCTION PREV_DAYTIME(
      P_CHECK_ID IN NUMBER,
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CTRL_CHECK_LOG.PREV_DAYTIME      (
         P_CHECK_ID,
         P_OBJECT_ID,
         P_DAYTIME,
         P_NUM_ROWS );
         RETURN ret_value;
   END PREV_DAYTIME;
   FUNCTION RECORD_STATUS(
      P_CHECK_ID IN NUMBER,
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_CTRL_CHECK_LOG.RECORD_STATUS      (
         P_CHECK_ID,
         P_OBJECT_ID,
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END RECORD_STATUS;
   FUNCTION APPROVAL_DATE(
      P_CHECK_ID IN NUMBER,
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CTRL_CHECK_LOG.APPROVAL_DATE      (
         P_CHECK_ID,
         P_OBJECT_ID,
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END APPROVAL_DATE;
   FUNCTION ROW_BY_PK(
      P_CHECK_ID IN NUMBER,
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN REC_ROW_BY_PK
   IS
      ret_value    REC_ROW_BY_PK ;
   BEGIN
      ret_value := EC_CTRL_CHECK_LOG.ROW_BY_PK      (
         P_CHECK_ID,
         P_OBJECT_ID,
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END ROW_BY_PK;
   FUNCTION ROW_BY_REL_OPERATOR(
      P_CHECK_ID IN NUMBER,
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN REC_ROW_BY_REL_OPERATOR
   IS
      ret_value    REC_ROW_BY_REL_OPERATOR ;
   BEGIN
      ret_value := EC_CTRL_CHECK_LOG.ROW_BY_REL_OPERATOR      (
         P_CHECK_ID,
         P_OBJECT_ID,
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END ROW_BY_REL_OPERATOR;
   FUNCTION REC_ID(
      P_CHECK_ID IN NUMBER,
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_CTRL_CHECK_LOG.REC_ID      (
         P_CHECK_ID,
         P_OBJECT_ID,
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END REC_ID;
   FUNCTION CHECK_DAYTIME(
      P_CHECK_ID IN NUMBER,
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CTRL_CHECK_LOG.CHECK_DAYTIME      (
         P_CHECK_ID,
         P_OBJECT_ID,
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END CHECK_DAYTIME;
   FUNCTION SEVERITY_LEVEL(
      P_CHECK_ID IN NUMBER,
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (16) ;
   BEGIN
      ret_value := EC_CTRL_CHECK_LOG.SEVERITY_LEVEL      (
         P_CHECK_ID,
         P_OBJECT_ID,
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END SEVERITY_LEVEL;

END RP_CTRL_CHECK_LOG;

/
--GRANT EXECUTE ON ECKERNEL_WST.RP_CTRL_CHECK_LOG TO REPORT_ROLE_XXX;



 -- FINISH PKG_GEN_PKGS.sf_get_functions at:11/15/2018 10.18.14 AM

