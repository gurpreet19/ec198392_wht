
 -- START PKG_GEN_PKGS.sf_get_functions at:11/15/2018 08.03.48 AM


CREATE or REPLACE PACKAGE RP_REPORT_SET_PARAM_GEN
IS

   FUNCTION APPROVAL_BY(
      P_SEQ_NO IN NUMBER,
      P_REPORT_SET_NO IN NUMBER,
      P_DAYTIME IN DATE,
      P_PARAMETER_NAME IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2;
   FUNCTION APPROVAL_STATE(
      P_SEQ_NO IN NUMBER,
      P_REPORT_SET_NO IN NUMBER,
      P_DAYTIME IN DATE,
      P_PARAMETER_NAME IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2;
   FUNCTION NEXT_DAYTIME(
      P_SEQ_NO IN NUMBER,
      P_REPORT_SET_NO IN NUMBER,
      P_DAYTIME IN DATE,
      P_PARAMETER_NAME IN VARCHAR2,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION PREV_EQUAL_DAYTIME(
      P_SEQ_NO IN NUMBER,
      P_REPORT_SET_NO IN NUMBER,
      P_DAYTIME IN DATE,
      P_PARAMETER_NAME IN VARCHAR2,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION NEXT_EQUAL_DAYTIME(
      P_SEQ_NO IN NUMBER,
      P_REPORT_SET_NO IN NUMBER,
      P_DAYTIME IN DATE,
      P_PARAMETER_NAME IN VARCHAR2,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION PREV_DAYTIME(
      P_SEQ_NO IN NUMBER,
      P_REPORT_SET_NO IN NUMBER,
      P_DAYTIME IN DATE,
      P_PARAMETER_NAME IN VARCHAR2,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION RECORD_STATUS(
      P_SEQ_NO IN NUMBER,
      P_REPORT_SET_NO IN NUMBER,
      P_DAYTIME IN DATE,
      P_PARAMETER_NAME IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2;
   FUNCTION APPROVAL_DATE(
      P_SEQ_NO IN NUMBER,
      P_REPORT_SET_NO IN NUMBER,
      P_DAYTIME IN DATE,
      P_PARAMETER_NAME IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN DATE;
   FUNCTION PARAMETER_VALUE(
      P_SEQ_NO IN NUMBER,
      P_REPORT_SET_NO IN NUMBER,
      P_DAYTIME IN DATE,
      P_PARAMETER_NAME IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2;
      TYPE REC_ROW_BY_PK IS RECORD (
         SEQ_NO NUMBER ,
         REPORT_SET_NO NUMBER ,
         PARAMETER_NAME VARCHAR2 (240) ,
         DAYTIME  DATE ,
         PARAMETER_VALUE VARCHAR2 (2000) ,
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
      P_SEQ_NO IN NUMBER,
      P_REPORT_SET_NO IN NUMBER,
      P_DAYTIME IN DATE,
      P_PARAMETER_NAME IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN REC_ROW_BY_PK;
      TYPE REC_ROW_BY_REL_OPERATOR IS RECORD (
         SEQ_NO NUMBER ,
         REPORT_SET_NO NUMBER ,
         PARAMETER_NAME VARCHAR2 (240) ,
         DAYTIME  DATE ,
         PARAMETER_VALUE VARCHAR2 (2000) ,
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
   FUNCTION ROW_BY_REL_OPERATOR(
      P_SEQ_NO IN NUMBER,
      P_REPORT_SET_NO IN NUMBER,
      P_DAYTIME IN DATE,
      P_PARAMETER_NAME IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN REC_ROW_BY_REL_OPERATOR;
   FUNCTION REC_ID(
      P_SEQ_NO IN NUMBER,
      P_REPORT_SET_NO IN NUMBER,
      P_DAYTIME IN DATE,
      P_PARAMETER_NAME IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2;

END RP_REPORT_SET_PARAM_GEN;

/



CREATE or REPLACE PACKAGE BODY RP_REPORT_SET_PARAM_GEN
IS

   FUNCTION APPROVAL_BY(
      P_SEQ_NO IN NUMBER,
      P_REPORT_SET_NO IN NUMBER,
      P_DAYTIME IN DATE,
      P_PARAMETER_NAME IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (30) ;
   BEGIN
      ret_value := EC_REPORT_SET_PARAM_GEN.APPROVAL_BY      (
         P_SEQ_NO,
         P_REPORT_SET_NO,
         P_DAYTIME,
         P_PARAMETER_NAME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END APPROVAL_BY;
   FUNCTION APPROVAL_STATE(
      P_SEQ_NO IN NUMBER,
      P_REPORT_SET_NO IN NUMBER,
      P_DAYTIME IN DATE,
      P_PARAMETER_NAME IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_REPORT_SET_PARAM_GEN.APPROVAL_STATE      (
         P_SEQ_NO,
         P_REPORT_SET_NO,
         P_DAYTIME,
         P_PARAMETER_NAME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END APPROVAL_STATE;
   FUNCTION NEXT_DAYTIME(
      P_SEQ_NO IN NUMBER,
      P_REPORT_SET_NO IN NUMBER,
      P_DAYTIME IN DATE,
      P_PARAMETER_NAME IN VARCHAR2,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_REPORT_SET_PARAM_GEN.NEXT_DAYTIME      (
         P_SEQ_NO,
         P_REPORT_SET_NO,
         P_DAYTIME,
         P_PARAMETER_NAME,
         P_NUM_ROWS );
         RETURN ret_value;
   END NEXT_DAYTIME;
   FUNCTION PREV_EQUAL_DAYTIME(
      P_SEQ_NO IN NUMBER,
      P_REPORT_SET_NO IN NUMBER,
      P_DAYTIME IN DATE,
      P_PARAMETER_NAME IN VARCHAR2,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_REPORT_SET_PARAM_GEN.PREV_EQUAL_DAYTIME      (
         P_SEQ_NO,
         P_REPORT_SET_NO,
         P_DAYTIME,
         P_PARAMETER_NAME,
         P_NUM_ROWS );
         RETURN ret_value;
   END PREV_EQUAL_DAYTIME;
   FUNCTION NEXT_EQUAL_DAYTIME(
      P_SEQ_NO IN NUMBER,
      P_REPORT_SET_NO IN NUMBER,
      P_DAYTIME IN DATE,
      P_PARAMETER_NAME IN VARCHAR2,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_REPORT_SET_PARAM_GEN.NEXT_EQUAL_DAYTIME      (
         P_SEQ_NO,
         P_REPORT_SET_NO,
         P_DAYTIME,
         P_PARAMETER_NAME,
         P_NUM_ROWS );
         RETURN ret_value;
   END NEXT_EQUAL_DAYTIME;
   FUNCTION PREV_DAYTIME(
      P_SEQ_NO IN NUMBER,
      P_REPORT_SET_NO IN NUMBER,
      P_DAYTIME IN DATE,
      P_PARAMETER_NAME IN VARCHAR2,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_REPORT_SET_PARAM_GEN.PREV_DAYTIME      (
         P_SEQ_NO,
         P_REPORT_SET_NO,
         P_DAYTIME,
         P_PARAMETER_NAME,
         P_NUM_ROWS );
         RETURN ret_value;
   END PREV_DAYTIME;
   FUNCTION RECORD_STATUS(
      P_SEQ_NO IN NUMBER,
      P_REPORT_SET_NO IN NUMBER,
      P_DAYTIME IN DATE,
      P_PARAMETER_NAME IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_REPORT_SET_PARAM_GEN.RECORD_STATUS      (
         P_SEQ_NO,
         P_REPORT_SET_NO,
         P_DAYTIME,
         P_PARAMETER_NAME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END RECORD_STATUS;
   FUNCTION APPROVAL_DATE(
      P_SEQ_NO IN NUMBER,
      P_REPORT_SET_NO IN NUMBER,
      P_DAYTIME IN DATE,
      P_PARAMETER_NAME IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_REPORT_SET_PARAM_GEN.APPROVAL_DATE      (
         P_SEQ_NO,
         P_REPORT_SET_NO,
         P_DAYTIME,
         P_PARAMETER_NAME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END APPROVAL_DATE;
   FUNCTION PARAMETER_VALUE(
      P_SEQ_NO IN NUMBER,
      P_REPORT_SET_NO IN NUMBER,
      P_DAYTIME IN DATE,
      P_PARAMETER_NAME IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_REPORT_SET_PARAM_GEN.PARAMETER_VALUE      (
         P_SEQ_NO,
         P_REPORT_SET_NO,
         P_DAYTIME,
         P_PARAMETER_NAME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END PARAMETER_VALUE;
   FUNCTION ROW_BY_PK(
      P_SEQ_NO IN NUMBER,
      P_REPORT_SET_NO IN NUMBER,
      P_DAYTIME IN DATE,
      P_PARAMETER_NAME IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN REC_ROW_BY_PK
   IS
      ret_value    REC_ROW_BY_PK ;
   BEGIN
      ret_value := EC_REPORT_SET_PARAM_GEN.ROW_BY_PK      (
         P_SEQ_NO,
         P_REPORT_SET_NO,
         P_DAYTIME,
         P_PARAMETER_NAME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END ROW_BY_PK;
   FUNCTION ROW_BY_REL_OPERATOR(
      P_SEQ_NO IN NUMBER,
      P_REPORT_SET_NO IN NUMBER,
      P_DAYTIME IN DATE,
      P_PARAMETER_NAME IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN REC_ROW_BY_REL_OPERATOR
   IS
      ret_value    REC_ROW_BY_REL_OPERATOR ;
   BEGIN
      ret_value := EC_REPORT_SET_PARAM_GEN.ROW_BY_REL_OPERATOR      (
         P_SEQ_NO,
         P_REPORT_SET_NO,
         P_DAYTIME,
         P_PARAMETER_NAME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END ROW_BY_REL_OPERATOR;
   FUNCTION REC_ID(
      P_SEQ_NO IN NUMBER,
      P_REPORT_SET_NO IN NUMBER,
      P_DAYTIME IN DATE,
      P_PARAMETER_NAME IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_REPORT_SET_PARAM_GEN.REC_ID      (
         P_SEQ_NO,
         P_REPORT_SET_NO,
         P_DAYTIME,
         P_PARAMETER_NAME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END REC_ID;

END RP_REPORT_SET_PARAM_GEN;

/
--GRANT EXECUTE ON ECKERNEL_WST.RP_REPORT_SET_PARAM_GEN TO REPORT_ROLE_XXX;



 -- FINISH PKG_GEN_PKGS.sf_get_functions at:11/15/2018 08.03.51 AM


