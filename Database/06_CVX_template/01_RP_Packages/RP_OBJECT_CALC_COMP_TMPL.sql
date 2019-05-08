
 -- START PKG_GEN_PKGS.sf_get_functions at:05/07/2019 08.57.55 AM


CREATE or REPLACE PACKAGE RP_OBJECT_CALC_COMP_TMPL
IS

   FUNCTION APPROVAL_BY(
      P_CALC_CONTEXT_ID IN VARCHAR2,
      P_TEMPLATE_CODE IN VARCHAR2,
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2;
   FUNCTION APPROVAL_STATE(
      P_CALC_CONTEXT_ID IN VARCHAR2,
      P_TEMPLATE_CODE IN VARCHAR2,
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2;
   FUNCTION NEXT_DAYTIME(
      P_CALC_CONTEXT_ID IN VARCHAR2,
      P_TEMPLATE_CODE IN VARCHAR2,
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION PREV_EQUAL_DAYTIME(
      P_CALC_CONTEXT_ID IN VARCHAR2,
      P_TEMPLATE_CODE IN VARCHAR2,
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION NEXT_EQUAL_DAYTIME(
      P_CALC_CONTEXT_ID IN VARCHAR2,
      P_TEMPLATE_CODE IN VARCHAR2,
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION END_DATE(
      P_CALC_CONTEXT_ID IN VARCHAR2,
      P_TEMPLATE_CODE IN VARCHAR2,
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN DATE;
   FUNCTION PREV_DAYTIME(
      P_CALC_CONTEXT_ID IN VARCHAR2,
      P_TEMPLATE_CODE IN VARCHAR2,
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION RECORD_STATUS(
      P_CALC_CONTEXT_ID IN VARCHAR2,
      P_TEMPLATE_CODE IN VARCHAR2,
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2;
   FUNCTION APPROVAL_DATE(
      P_CALC_CONTEXT_ID IN VARCHAR2,
      P_TEMPLATE_CODE IN VARCHAR2,
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN DATE;
      TYPE REC_ROW_BY_PK IS RECORD (
         CALC_CONTEXT_ID VARCHAR2 (32) ,
         TEMPLATE_CODE VARCHAR2 (32) ,
         OBJECT_ID VARCHAR2 (32) ,
         DAYTIME  DATE ,
         END_DATE  DATE ,
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
      P_CALC_CONTEXT_ID IN VARCHAR2,
      P_TEMPLATE_CODE IN VARCHAR2,
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN REC_ROW_BY_PK;
      TYPE REC_ROW_BY_REL_OPERATOR IS RECORD (
         CALC_CONTEXT_ID VARCHAR2 (32) ,
         TEMPLATE_CODE VARCHAR2 (32) ,
         OBJECT_ID VARCHAR2 (32) ,
         DAYTIME  DATE ,
         END_DATE  DATE ,
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
      P_CALC_CONTEXT_ID IN VARCHAR2,
      P_TEMPLATE_CODE IN VARCHAR2,
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN REC_ROW_BY_REL_OPERATOR;
   FUNCTION REC_ID(
      P_CALC_CONTEXT_ID IN VARCHAR2,
      P_TEMPLATE_CODE IN VARCHAR2,
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2;

END RP_OBJECT_CALC_COMP_TMPL;

/



CREATE or REPLACE PACKAGE BODY RP_OBJECT_CALC_COMP_TMPL
IS

   FUNCTION APPROVAL_BY(
      P_CALC_CONTEXT_ID IN VARCHAR2,
      P_TEMPLATE_CODE IN VARCHAR2,
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (30) ;
   BEGIN
      ret_value := EC_OBJECT_CALC_COMP_TMPL.APPROVAL_BY      (
         P_CALC_CONTEXT_ID,
         P_TEMPLATE_CODE,
         P_OBJECT_ID,
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END APPROVAL_BY;
   FUNCTION APPROVAL_STATE(
      P_CALC_CONTEXT_ID IN VARCHAR2,
      P_TEMPLATE_CODE IN VARCHAR2,
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_OBJECT_CALC_COMP_TMPL.APPROVAL_STATE      (
         P_CALC_CONTEXT_ID,
         P_TEMPLATE_CODE,
         P_OBJECT_ID,
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END APPROVAL_STATE;
   FUNCTION NEXT_DAYTIME(
      P_CALC_CONTEXT_ID IN VARCHAR2,
      P_TEMPLATE_CODE IN VARCHAR2,
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_OBJECT_CALC_COMP_TMPL.NEXT_DAYTIME      (
         P_CALC_CONTEXT_ID,
         P_TEMPLATE_CODE,
         P_OBJECT_ID,
         P_DAYTIME,
         P_NUM_ROWS );
         RETURN ret_value;
   END NEXT_DAYTIME;
   FUNCTION PREV_EQUAL_DAYTIME(
      P_CALC_CONTEXT_ID IN VARCHAR2,
      P_TEMPLATE_CODE IN VARCHAR2,
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_OBJECT_CALC_COMP_TMPL.PREV_EQUAL_DAYTIME      (
         P_CALC_CONTEXT_ID,
         P_TEMPLATE_CODE,
         P_OBJECT_ID,
         P_DAYTIME,
         P_NUM_ROWS );
         RETURN ret_value;
   END PREV_EQUAL_DAYTIME;
   FUNCTION NEXT_EQUAL_DAYTIME(
      P_CALC_CONTEXT_ID IN VARCHAR2,
      P_TEMPLATE_CODE IN VARCHAR2,
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_OBJECT_CALC_COMP_TMPL.NEXT_EQUAL_DAYTIME      (
         P_CALC_CONTEXT_ID,
         P_TEMPLATE_CODE,
         P_OBJECT_ID,
         P_DAYTIME,
         P_NUM_ROWS );
         RETURN ret_value;
   END NEXT_EQUAL_DAYTIME;
   FUNCTION END_DATE(
      P_CALC_CONTEXT_ID IN VARCHAR2,
      P_TEMPLATE_CODE IN VARCHAR2,
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_OBJECT_CALC_COMP_TMPL.END_DATE      (
         P_CALC_CONTEXT_ID,
         P_TEMPLATE_CODE,
         P_OBJECT_ID,
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END END_DATE;
   FUNCTION PREV_DAYTIME(
      P_CALC_CONTEXT_ID IN VARCHAR2,
      P_TEMPLATE_CODE IN VARCHAR2,
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_OBJECT_CALC_COMP_TMPL.PREV_DAYTIME      (
         P_CALC_CONTEXT_ID,
         P_TEMPLATE_CODE,
         P_OBJECT_ID,
         P_DAYTIME,
         P_NUM_ROWS );
         RETURN ret_value;
   END PREV_DAYTIME;
   FUNCTION RECORD_STATUS(
      P_CALC_CONTEXT_ID IN VARCHAR2,
      P_TEMPLATE_CODE IN VARCHAR2,
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_OBJECT_CALC_COMP_TMPL.RECORD_STATUS      (
         P_CALC_CONTEXT_ID,
         P_TEMPLATE_CODE,
         P_OBJECT_ID,
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END RECORD_STATUS;
   FUNCTION APPROVAL_DATE(
      P_CALC_CONTEXT_ID IN VARCHAR2,
      P_TEMPLATE_CODE IN VARCHAR2,
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_OBJECT_CALC_COMP_TMPL.APPROVAL_DATE      (
         P_CALC_CONTEXT_ID,
         P_TEMPLATE_CODE,
         P_OBJECT_ID,
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END APPROVAL_DATE;
   FUNCTION ROW_BY_PK(
      P_CALC_CONTEXT_ID IN VARCHAR2,
      P_TEMPLATE_CODE IN VARCHAR2,
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN REC_ROW_BY_PK
   IS
      ret_value    REC_ROW_BY_PK ;
   BEGIN
      ret_value := EC_OBJECT_CALC_COMP_TMPL.ROW_BY_PK      (
         P_CALC_CONTEXT_ID,
         P_TEMPLATE_CODE,
         P_OBJECT_ID,
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END ROW_BY_PK;
   FUNCTION ROW_BY_REL_OPERATOR(
      P_CALC_CONTEXT_ID IN VARCHAR2,
      P_TEMPLATE_CODE IN VARCHAR2,
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN REC_ROW_BY_REL_OPERATOR
   IS
      ret_value    REC_ROW_BY_REL_OPERATOR ;
   BEGIN
      ret_value := EC_OBJECT_CALC_COMP_TMPL.ROW_BY_REL_OPERATOR      (
         P_CALC_CONTEXT_ID,
         P_TEMPLATE_CODE,
         P_OBJECT_ID,
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END ROW_BY_REL_OPERATOR;
   FUNCTION REC_ID(
      P_CALC_CONTEXT_ID IN VARCHAR2,
      P_TEMPLATE_CODE IN VARCHAR2,
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_OBJECT_CALC_COMP_TMPL.REC_ID      (
         P_CALC_CONTEXT_ID,
         P_TEMPLATE_CODE,
         P_OBJECT_ID,
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END REC_ID;

END RP_OBJECT_CALC_COMP_TMPL;

/
--GRANT EXECUTE ON ECKERNEL_WST.RP_OBJECT_CALC_COMP_TMPL TO REPORT_ROLE_XXX;



 -- FINISH PKG_GEN_PKGS.sf_get_functions at:05/07/2019 08.58.03 AM


