
 -- START PKG_GEN_PKGS.sf_get_functions at:11/15/2018 08.01.41 AM


CREATE or REPLACE PACKAGE RP_SCHEDULE_HISTORY
IS

   FUNCTION APPROVAL_BY(
      P_SCHEDULE_NO IN NUMBER,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2;
   FUNCTION APPROVAL_STATE(
      P_SCHEDULE_NO IN NUMBER,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2;
   FUNCTION CLUSTER_NODE(
      P_SCHEDULE_NO IN NUMBER,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2;
   FUNCTION FROM_DAYTIME(
      P_SCHEDULE_NO IN NUMBER,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN DATE;
   FUNCTION NEXT_DAYTIME(
      P_SCHEDULE_NO IN NUMBER,
      P_DAYTIME IN DATE,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION PREV_EQUAL_DAYTIME(
      P_SCHEDULE_NO IN NUMBER,
      P_DAYTIME IN DATE,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION NEXT_EQUAL_DAYTIME(
      P_SCHEDULE_NO IN NUMBER,
      P_DAYTIME IN DATE,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION PREV_DAYTIME(
      P_SCHEDULE_NO IN NUMBER,
      P_DAYTIME IN DATE,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION RECORD_STATUS(
      P_SCHEDULE_NO IN NUMBER,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2;
   FUNCTION APPROVAL_DATE(
      P_SCHEDULE_NO IN NUMBER,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN DATE;
      TYPE REC_ROW_BY_PK IS RECORD (
         SCHEDULE_NO NUMBER ,
         DAYTIME  DATE ,
         FROM_DAYTIME  DATE ,
         TO_DAYTIME  DATE ,
         SERIALIZED_XML_CONFIG  CLOB ,
         DETAILED_LOG  CLOB ,
         CLUSTER_NODE VARCHAR2 (1000) ,
         RUN_STATUS VARCHAR2 (32) ,
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
      P_SCHEDULE_NO IN NUMBER,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN REC_ROW_BY_PK;
      TYPE REC_ROW_BY_REL_OPERATOR IS RECORD (
         SCHEDULE_NO NUMBER ,
         DAYTIME  DATE ,
         FROM_DAYTIME  DATE ,
         TO_DAYTIME  DATE ,
         SERIALIZED_XML_CONFIG  CLOB ,
         DETAILED_LOG  CLOB ,
         CLUSTER_NODE VARCHAR2 (1000) ,
         RUN_STATUS VARCHAR2 (32) ,
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
      P_SCHEDULE_NO IN NUMBER,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN REC_ROW_BY_REL_OPERATOR;
   FUNCTION TO_DAYTIME(
      P_SCHEDULE_NO IN NUMBER,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN DATE;
   FUNCTION REC_ID(
      P_SCHEDULE_NO IN NUMBER,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2;
   FUNCTION SERIALIZED_XML_CONFIG(
      P_SCHEDULE_NO IN NUMBER,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN CLOB;
   FUNCTION DETAILED_LOG(
      P_SCHEDULE_NO IN NUMBER,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN CLOB;
   FUNCTION RUN_STATUS(
      P_SCHEDULE_NO IN NUMBER,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2;

END RP_SCHEDULE_HISTORY;

/



CREATE or REPLACE PACKAGE BODY RP_SCHEDULE_HISTORY
IS

   FUNCTION APPROVAL_BY(
      P_SCHEDULE_NO IN NUMBER,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (30) ;
   BEGIN
      ret_value := EC_SCHEDULE_HISTORY.APPROVAL_BY      (
         P_SCHEDULE_NO,
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END APPROVAL_BY;
   FUNCTION APPROVAL_STATE(
      P_SCHEDULE_NO IN NUMBER,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_SCHEDULE_HISTORY.APPROVAL_STATE      (
         P_SCHEDULE_NO,
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END APPROVAL_STATE;
   FUNCTION CLUSTER_NODE(
      P_SCHEDULE_NO IN NUMBER,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1000) ;
   BEGIN
      ret_value := EC_SCHEDULE_HISTORY.CLUSTER_NODE      (
         P_SCHEDULE_NO,
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END CLUSTER_NODE;
   FUNCTION FROM_DAYTIME(
      P_SCHEDULE_NO IN NUMBER,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_SCHEDULE_HISTORY.FROM_DAYTIME      (
         P_SCHEDULE_NO,
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END FROM_DAYTIME;
   FUNCTION NEXT_DAYTIME(
      P_SCHEDULE_NO IN NUMBER,
      P_DAYTIME IN DATE,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_SCHEDULE_HISTORY.NEXT_DAYTIME      (
         P_SCHEDULE_NO,
         P_DAYTIME,
         P_NUM_ROWS );
         RETURN ret_value;
   END NEXT_DAYTIME;
   FUNCTION PREV_EQUAL_DAYTIME(
      P_SCHEDULE_NO IN NUMBER,
      P_DAYTIME IN DATE,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_SCHEDULE_HISTORY.PREV_EQUAL_DAYTIME      (
         P_SCHEDULE_NO,
         P_DAYTIME,
         P_NUM_ROWS );
         RETURN ret_value;
   END PREV_EQUAL_DAYTIME;
   FUNCTION NEXT_EQUAL_DAYTIME(
      P_SCHEDULE_NO IN NUMBER,
      P_DAYTIME IN DATE,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_SCHEDULE_HISTORY.NEXT_EQUAL_DAYTIME      (
         P_SCHEDULE_NO,
         P_DAYTIME,
         P_NUM_ROWS );
         RETURN ret_value;
   END NEXT_EQUAL_DAYTIME;
   FUNCTION PREV_DAYTIME(
      P_SCHEDULE_NO IN NUMBER,
      P_DAYTIME IN DATE,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_SCHEDULE_HISTORY.PREV_DAYTIME      (
         P_SCHEDULE_NO,
         P_DAYTIME,
         P_NUM_ROWS );
         RETURN ret_value;
   END PREV_DAYTIME;
   FUNCTION RECORD_STATUS(
      P_SCHEDULE_NO IN NUMBER,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_SCHEDULE_HISTORY.RECORD_STATUS      (
         P_SCHEDULE_NO,
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END RECORD_STATUS;
   FUNCTION APPROVAL_DATE(
      P_SCHEDULE_NO IN NUMBER,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_SCHEDULE_HISTORY.APPROVAL_DATE      (
         P_SCHEDULE_NO,
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END APPROVAL_DATE;
   FUNCTION ROW_BY_PK(
      P_SCHEDULE_NO IN NUMBER,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN REC_ROW_BY_PK
   IS
      ret_value    REC_ROW_BY_PK ;
   BEGIN
      ret_value := EC_SCHEDULE_HISTORY.ROW_BY_PK      (
         P_SCHEDULE_NO,
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END ROW_BY_PK;
   FUNCTION ROW_BY_REL_OPERATOR(
      P_SCHEDULE_NO IN NUMBER,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN REC_ROW_BY_REL_OPERATOR
   IS
      ret_value    REC_ROW_BY_REL_OPERATOR ;
   BEGIN
      ret_value := EC_SCHEDULE_HISTORY.ROW_BY_REL_OPERATOR      (
         P_SCHEDULE_NO,
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END ROW_BY_REL_OPERATOR;
   FUNCTION TO_DAYTIME(
      P_SCHEDULE_NO IN NUMBER,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_SCHEDULE_HISTORY.TO_DAYTIME      (
         P_SCHEDULE_NO,
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END TO_DAYTIME;
   FUNCTION REC_ID(
      P_SCHEDULE_NO IN NUMBER,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_SCHEDULE_HISTORY.REC_ID      (
         P_SCHEDULE_NO,
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END REC_ID;
   FUNCTION SERIALIZED_XML_CONFIG(
      P_SCHEDULE_NO IN NUMBER,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN CLOB
   IS
      ret_value    CLOB ;
   BEGIN
      ret_value := EC_SCHEDULE_HISTORY.SERIALIZED_XML_CONFIG      (
         P_SCHEDULE_NO,
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END SERIALIZED_XML_CONFIG;
   FUNCTION DETAILED_LOG(
      P_SCHEDULE_NO IN NUMBER,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN CLOB
   IS
      ret_value    CLOB ;
   BEGIN
      ret_value := EC_SCHEDULE_HISTORY.DETAILED_LOG      (
         P_SCHEDULE_NO,
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END DETAILED_LOG;
   FUNCTION RUN_STATUS(
      P_SCHEDULE_NO IN NUMBER,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_SCHEDULE_HISTORY.RUN_STATUS      (
         P_SCHEDULE_NO,
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END RUN_STATUS;

END RP_SCHEDULE_HISTORY;

/
--GRANT EXECUTE ON ECKERNEL_WST.RP_SCHEDULE_HISTORY TO REPORT_ROLE_XXX;



 -- FINISH PKG_GEN_PKGS.sf_get_functions at:11/15/2018 08.01.44 AM


