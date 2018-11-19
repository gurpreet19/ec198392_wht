
 -- START PKG_GEN_PKGS.sf_get_functions at:11/15/2018 11.00.22 AM


CREATE or REPLACE PACKAGE RP_CALC_COMPONENT_TEMPLATE
IS

   FUNCTION APPROVAL_BY(
      P_CALC_CONTEXT_ID IN VARCHAR2,
      P_TEMPLATE_CODE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_STATE(
      P_CALC_CONTEXT_ID IN VARCHAR2,
      P_TEMPLATE_CODE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION NAME(
      P_CALC_CONTEXT_ID IN VARCHAR2,
      P_TEMPLATE_CODE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION RECORD_STATUS(
      P_CALC_CONTEXT_ID IN VARCHAR2,
      P_TEMPLATE_CODE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_DATE(
      P_CALC_CONTEXT_ID IN VARCHAR2,
      P_TEMPLATE_CODE IN VARCHAR2)
      RETURN DATE;
      TYPE REC_ROW_BY_PK IS RECORD (
         CALC_CONTEXT_ID VARCHAR2 (32) ,
         TEMPLATE_CODE VARCHAR2 (32) ,
         NAME VARCHAR2 (32) ,
         CLASS_NAME VARCHAR2 (32) ,
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
      P_TEMPLATE_CODE IN VARCHAR2)
      RETURN REC_ROW_BY_PK;
   FUNCTION CLASS_NAME(
      P_CALC_CONTEXT_ID IN VARCHAR2,
      P_TEMPLATE_CODE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION REC_ID(
      P_CALC_CONTEXT_ID IN VARCHAR2,
      P_TEMPLATE_CODE IN VARCHAR2)
      RETURN VARCHAR2;

END RP_CALC_COMPONENT_TEMPLATE;

/



CREATE or REPLACE PACKAGE BODY RP_CALC_COMPONENT_TEMPLATE
IS

   FUNCTION APPROVAL_BY(
      P_CALC_CONTEXT_ID IN VARCHAR2,
      P_TEMPLATE_CODE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (30) ;
   BEGIN
      ret_value := EC_CALC_COMPONENT_TEMPLATE.APPROVAL_BY      (
         P_CALC_CONTEXT_ID,
         P_TEMPLATE_CODE );
         RETURN ret_value;
   END APPROVAL_BY;
   FUNCTION APPROVAL_STATE(
      P_CALC_CONTEXT_ID IN VARCHAR2,
      P_TEMPLATE_CODE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_CALC_COMPONENT_TEMPLATE.APPROVAL_STATE      (
         P_CALC_CONTEXT_ID,
         P_TEMPLATE_CODE );
         RETURN ret_value;
   END APPROVAL_STATE;
   FUNCTION NAME(
      P_CALC_CONTEXT_ID IN VARCHAR2,
      P_TEMPLATE_CODE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_CALC_COMPONENT_TEMPLATE.NAME      (
         P_CALC_CONTEXT_ID,
         P_TEMPLATE_CODE );
         RETURN ret_value;
   END NAME;
   FUNCTION RECORD_STATUS(
      P_CALC_CONTEXT_ID IN VARCHAR2,
      P_TEMPLATE_CODE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_CALC_COMPONENT_TEMPLATE.RECORD_STATUS      (
         P_CALC_CONTEXT_ID,
         P_TEMPLATE_CODE );
         RETURN ret_value;
   END RECORD_STATUS;
   FUNCTION APPROVAL_DATE(
      P_CALC_CONTEXT_ID IN VARCHAR2,
      P_TEMPLATE_CODE IN VARCHAR2)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CALC_COMPONENT_TEMPLATE.APPROVAL_DATE      (
         P_CALC_CONTEXT_ID,
         P_TEMPLATE_CODE );
         RETURN ret_value;
   END APPROVAL_DATE;
   FUNCTION ROW_BY_PK(
      P_CALC_CONTEXT_ID IN VARCHAR2,
      P_TEMPLATE_CODE IN VARCHAR2)
      RETURN REC_ROW_BY_PK
   IS
      ret_value    REC_ROW_BY_PK ;
   BEGIN
      ret_value := EC_CALC_COMPONENT_TEMPLATE.ROW_BY_PK      (
         P_CALC_CONTEXT_ID,
         P_TEMPLATE_CODE );
         RETURN ret_value;
   END ROW_BY_PK;
   FUNCTION CLASS_NAME(
      P_CALC_CONTEXT_ID IN VARCHAR2,
      P_TEMPLATE_CODE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_CALC_COMPONENT_TEMPLATE.CLASS_NAME      (
         P_CALC_CONTEXT_ID,
         P_TEMPLATE_CODE );
         RETURN ret_value;
   END CLASS_NAME;
   FUNCTION REC_ID(
      P_CALC_CONTEXT_ID IN VARCHAR2,
      P_TEMPLATE_CODE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_CALC_COMPONENT_TEMPLATE.REC_ID      (
         P_CALC_CONTEXT_ID,
         P_TEMPLATE_CODE );
         RETURN ret_value;
   END REC_ID;

END RP_CALC_COMPONENT_TEMPLATE;

/
--GRANT EXECUTE ON ECKERNEL_WST.RP_CALC_COMPONENT_TEMPLATE TO REPORT_ROLE_XXX;



 -- FINISH PKG_GEN_PKGS.sf_get_functions at:11/15/2018 11.00.24 AM


