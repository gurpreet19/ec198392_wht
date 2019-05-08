
 -- START PKG_GEN_PKGS.sf_get_functions at:05/07/2019 11.21.10 AM


CREATE or REPLACE PACKAGE RP_ACTION_INSTANCE_HISTORY
IS

   FUNCTION APPROVAL_BY(
      P_ACTION_INSTANCE_NO IN NUMBER,
      P_DAYTIME IN DATE,
      P_RUN_ID IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2;
   FUNCTION APPROVAL_STATE(
      P_ACTION_INSTANCE_NO IN NUMBER,
      P_DAYTIME IN DATE,
      P_RUN_ID IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2;
   FUNCTION FROM_DAYTIME(
      P_ACTION_INSTANCE_NO IN NUMBER,
      P_DAYTIME IN DATE,
      P_RUN_ID IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN DATE;
   FUNCTION MESSAGE_DETAIL(
      P_ACTION_INSTANCE_NO IN NUMBER,
      P_DAYTIME IN DATE,
      P_RUN_ID IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN CLOB;
   FUNCTION NEXT_DAYTIME(
      P_ACTION_INSTANCE_NO IN NUMBER,
      P_DAYTIME IN DATE,
      P_RUN_ID IN VARCHAR2,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION PREV_EQUAL_DAYTIME(
      P_ACTION_INSTANCE_NO IN NUMBER,
      P_DAYTIME IN DATE,
      P_RUN_ID IN VARCHAR2,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION NEXT_EQUAL_DAYTIME(
      P_ACTION_INSTANCE_NO IN NUMBER,
      P_DAYTIME IN DATE,
      P_RUN_ID IN VARCHAR2,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION PREV_DAYTIME(
      P_ACTION_INSTANCE_NO IN NUMBER,
      P_DAYTIME IN DATE,
      P_RUN_ID IN VARCHAR2,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION RECORD_STATUS(
      P_ACTION_INSTANCE_NO IN NUMBER,
      P_DAYTIME IN DATE,
      P_RUN_ID IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2;
   FUNCTION APPROVAL_DATE(
      P_ACTION_INSTANCE_NO IN NUMBER,
      P_DAYTIME IN DATE,
      P_RUN_ID IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN DATE;
      TYPE REC_ROW_BY_PK IS RECORD (
         ACTION_INSTANCE_NO NUMBER ,
         DAYTIME  DATE ,
         FROM_DAYTIME  DATE ,
         TO_DAYTIME  DATE ,
         MESSAGE_DETAIL  CLOB ,
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
         REC_ID VARCHAR2 (32) ,
         RUN_ID VARCHAR2 (2000)  );
   FUNCTION ROW_BY_PK(
      P_ACTION_INSTANCE_NO IN NUMBER,
      P_DAYTIME IN DATE,
      P_RUN_ID IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN REC_ROW_BY_PK;
      TYPE REC_ROW_BY_REL_OPERATOR IS RECORD (
         ACTION_INSTANCE_NO NUMBER ,
         DAYTIME  DATE ,
         FROM_DAYTIME  DATE ,
         TO_DAYTIME  DATE ,
         MESSAGE_DETAIL  CLOB ,
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
         REC_ID VARCHAR2 (32) ,
         RUN_ID VARCHAR2 (2000)  );
   FUNCTION ROW_BY_REL_OPERATOR(
      P_ACTION_INSTANCE_NO IN NUMBER,
      P_DAYTIME IN DATE,
      P_RUN_ID IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN REC_ROW_BY_REL_OPERATOR;
   FUNCTION TO_DAYTIME(
      P_ACTION_INSTANCE_NO IN NUMBER,
      P_DAYTIME IN DATE,
      P_RUN_ID IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN DATE;
   FUNCTION REC_ID(
      P_ACTION_INSTANCE_NO IN NUMBER,
      P_DAYTIME IN DATE,
      P_RUN_ID IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2;
   FUNCTION RUN_STATUS(
      P_ACTION_INSTANCE_NO IN NUMBER,
      P_DAYTIME IN DATE,
      P_RUN_ID IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2;

END RP_ACTION_INSTANCE_HISTORY;

/



CREATE or REPLACE PACKAGE BODY RP_ACTION_INSTANCE_HISTORY
IS

   FUNCTION APPROVAL_BY(
      P_ACTION_INSTANCE_NO IN NUMBER,
      P_DAYTIME IN DATE,
      P_RUN_ID IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (30) ;
   BEGIN
      ret_value := EC_ACTION_INSTANCE_HISTORY.APPROVAL_BY      (
         P_ACTION_INSTANCE_NO,
         P_DAYTIME,
         P_RUN_ID,
         P_COMPARE_OPER );
         RETURN ret_value;
   END APPROVAL_BY;
   FUNCTION APPROVAL_STATE(
      P_ACTION_INSTANCE_NO IN NUMBER,
      P_DAYTIME IN DATE,
      P_RUN_ID IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_ACTION_INSTANCE_HISTORY.APPROVAL_STATE      (
         P_ACTION_INSTANCE_NO,
         P_DAYTIME,
         P_RUN_ID,
         P_COMPARE_OPER );
         RETURN ret_value;
   END APPROVAL_STATE;
   FUNCTION FROM_DAYTIME(
      P_ACTION_INSTANCE_NO IN NUMBER,
      P_DAYTIME IN DATE,
      P_RUN_ID IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_ACTION_INSTANCE_HISTORY.FROM_DAYTIME      (
         P_ACTION_INSTANCE_NO,
         P_DAYTIME,
         P_RUN_ID,
         P_COMPARE_OPER );
         RETURN ret_value;
   END FROM_DAYTIME;
   FUNCTION MESSAGE_DETAIL(
      P_ACTION_INSTANCE_NO IN NUMBER,
      P_DAYTIME IN DATE,
      P_RUN_ID IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN CLOB
   IS
      ret_value    CLOB ;
   BEGIN
      ret_value := EC_ACTION_INSTANCE_HISTORY.MESSAGE_DETAIL      (
         P_ACTION_INSTANCE_NO,
         P_DAYTIME,
         P_RUN_ID,
         P_COMPARE_OPER );
         RETURN ret_value;
   END MESSAGE_DETAIL;
   FUNCTION NEXT_DAYTIME(
      P_ACTION_INSTANCE_NO IN NUMBER,
      P_DAYTIME IN DATE,
      P_RUN_ID IN VARCHAR2,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_ACTION_INSTANCE_HISTORY.NEXT_DAYTIME      (
         P_ACTION_INSTANCE_NO,
         P_DAYTIME,
         P_RUN_ID,
         P_NUM_ROWS );
         RETURN ret_value;
   END NEXT_DAYTIME;
   FUNCTION PREV_EQUAL_DAYTIME(
      P_ACTION_INSTANCE_NO IN NUMBER,
      P_DAYTIME IN DATE,
      P_RUN_ID IN VARCHAR2,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_ACTION_INSTANCE_HISTORY.PREV_EQUAL_DAYTIME      (
         P_ACTION_INSTANCE_NO,
         P_DAYTIME,
         P_RUN_ID,
         P_NUM_ROWS );
         RETURN ret_value;
   END PREV_EQUAL_DAYTIME;
   FUNCTION NEXT_EQUAL_DAYTIME(
      P_ACTION_INSTANCE_NO IN NUMBER,
      P_DAYTIME IN DATE,
      P_RUN_ID IN VARCHAR2,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_ACTION_INSTANCE_HISTORY.NEXT_EQUAL_DAYTIME      (
         P_ACTION_INSTANCE_NO,
         P_DAYTIME,
         P_RUN_ID,
         P_NUM_ROWS );
         RETURN ret_value;
   END NEXT_EQUAL_DAYTIME;
   FUNCTION PREV_DAYTIME(
      P_ACTION_INSTANCE_NO IN NUMBER,
      P_DAYTIME IN DATE,
      P_RUN_ID IN VARCHAR2,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_ACTION_INSTANCE_HISTORY.PREV_DAYTIME      (
         P_ACTION_INSTANCE_NO,
         P_DAYTIME,
         P_RUN_ID,
         P_NUM_ROWS );
         RETURN ret_value;
   END PREV_DAYTIME;
   FUNCTION RECORD_STATUS(
      P_ACTION_INSTANCE_NO IN NUMBER,
      P_DAYTIME IN DATE,
      P_RUN_ID IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_ACTION_INSTANCE_HISTORY.RECORD_STATUS      (
         P_ACTION_INSTANCE_NO,
         P_DAYTIME,
         P_RUN_ID,
         P_COMPARE_OPER );
         RETURN ret_value;
   END RECORD_STATUS;
   FUNCTION APPROVAL_DATE(
      P_ACTION_INSTANCE_NO IN NUMBER,
      P_DAYTIME IN DATE,
      P_RUN_ID IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_ACTION_INSTANCE_HISTORY.APPROVAL_DATE      (
         P_ACTION_INSTANCE_NO,
         P_DAYTIME,
         P_RUN_ID,
         P_COMPARE_OPER );
         RETURN ret_value;
   END APPROVAL_DATE;
   FUNCTION ROW_BY_PK(
      P_ACTION_INSTANCE_NO IN NUMBER,
      P_DAYTIME IN DATE,
      P_RUN_ID IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN REC_ROW_BY_PK
   IS
      ret_value    REC_ROW_BY_PK ;
   BEGIN
      ret_value := EC_ACTION_INSTANCE_HISTORY.ROW_BY_PK      (
         P_ACTION_INSTANCE_NO,
         P_DAYTIME,
         P_RUN_ID,
         P_COMPARE_OPER );
         RETURN ret_value;
   END ROW_BY_PK;
   FUNCTION ROW_BY_REL_OPERATOR(
      P_ACTION_INSTANCE_NO IN NUMBER,
      P_DAYTIME IN DATE,
      P_RUN_ID IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN REC_ROW_BY_REL_OPERATOR
   IS
      ret_value    REC_ROW_BY_REL_OPERATOR ;
   BEGIN
      ret_value := EC_ACTION_INSTANCE_HISTORY.ROW_BY_REL_OPERATOR      (
         P_ACTION_INSTANCE_NO,
         P_DAYTIME,
         P_RUN_ID,
         P_COMPARE_OPER );
         RETURN ret_value;
   END ROW_BY_REL_OPERATOR;
   FUNCTION TO_DAYTIME(
      P_ACTION_INSTANCE_NO IN NUMBER,
      P_DAYTIME IN DATE,
      P_RUN_ID IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_ACTION_INSTANCE_HISTORY.TO_DAYTIME      (
         P_ACTION_INSTANCE_NO,
         P_DAYTIME,
         P_RUN_ID,
         P_COMPARE_OPER );
         RETURN ret_value;
   END TO_DAYTIME;
   FUNCTION REC_ID(
      P_ACTION_INSTANCE_NO IN NUMBER,
      P_DAYTIME IN DATE,
      P_RUN_ID IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_ACTION_INSTANCE_HISTORY.REC_ID      (
         P_ACTION_INSTANCE_NO,
         P_DAYTIME,
         P_RUN_ID,
         P_COMPARE_OPER );
         RETURN ret_value;
   END REC_ID;
   FUNCTION RUN_STATUS(
      P_ACTION_INSTANCE_NO IN NUMBER,
      P_DAYTIME IN DATE,
      P_RUN_ID IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_ACTION_INSTANCE_HISTORY.RUN_STATUS      (
         P_ACTION_INSTANCE_NO,
         P_DAYTIME,
         P_RUN_ID,
         P_COMPARE_OPER );
         RETURN ret_value;
   END RUN_STATUS;

END RP_ACTION_INSTANCE_HISTORY;

/
--GRANT EXECUTE ON ECKERNEL_WST.RP_ACTION_INSTANCE_HISTORY TO REPORT_ROLE_XXX;



 -- FINISH PKG_GEN_PKGS.sf_get_functions at:05/07/2019 11.21.14 AM


