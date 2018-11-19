
 -- START PKG_GEN_PKGS.sf_get_functions at:11/15/2018 11.00.24 AM


CREATE or REPLACE PACKAGE RP_CALC_COMPONENT_ROW
IS

   FUNCTION DESCRIPTION(
      P_CALC_CONTEXT_ID IN VARCHAR2,
      P_TEMPLATE_CODE IN VARCHAR2,
      P_COMPONENT_CODE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION SORT_ORDER(
      P_CALC_CONTEXT_ID IN VARCHAR2,
      P_TEMPLATE_CODE IN VARCHAR2,
      P_COMPONENT_CODE IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION APPROVAL_BY(
      P_CALC_CONTEXT_ID IN VARCHAR2,
      P_TEMPLATE_CODE IN VARCHAR2,
      P_COMPONENT_CODE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_STATE(
      P_CALC_CONTEXT_ID IN VARCHAR2,
      P_TEMPLATE_CODE IN VARCHAR2,
      P_COMPONENT_CODE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION LABEL(
      P_CALC_CONTEXT_ID IN VARCHAR2,
      P_TEMPLATE_CODE IN VARCHAR2,
      P_COMPONENT_CODE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION RECORD_STATUS(
      P_CALC_CONTEXT_ID IN VARCHAR2,
      P_TEMPLATE_CODE IN VARCHAR2,
      P_COMPONENT_CODE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_DATE(
      P_CALC_CONTEXT_ID IN VARCHAR2,
      P_TEMPLATE_CODE IN VARCHAR2,
      P_COMPONENT_CODE IN VARCHAR2)
      RETURN DATE;
      TYPE REC_ROW_BY_PK IS RECORD (
         CALC_CONTEXT_ID VARCHAR2 (32) ,
         TEMPLATE_CODE VARCHAR2 (32) ,
         COMPONENT_CODE VARCHAR2 (32) ,
         LABEL VARCHAR2 (240) ,
         TYPE VARCHAR2 (32) ,
         DESCRIPTION VARCHAR2 (2000) ,
         SORT_ORDER NUMBER ,
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
      P_COMPONENT_CODE IN VARCHAR2)
      RETURN REC_ROW_BY_PK;
   FUNCTION TYPE(
      P_CALC_CONTEXT_ID IN VARCHAR2,
      P_TEMPLATE_CODE IN VARCHAR2,
      P_COMPONENT_CODE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION REC_ID(
      P_CALC_CONTEXT_ID IN VARCHAR2,
      P_TEMPLATE_CODE IN VARCHAR2,
      P_COMPONENT_CODE IN VARCHAR2)
      RETURN VARCHAR2;

END RP_CALC_COMPONENT_ROW;

/



CREATE or REPLACE PACKAGE BODY RP_CALC_COMPONENT_ROW
IS

   FUNCTION DESCRIPTION(
      P_CALC_CONTEXT_ID IN VARCHAR2,
      P_TEMPLATE_CODE IN VARCHAR2,
      P_COMPONENT_CODE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_CALC_COMPONENT_ROW.DESCRIPTION      (
         P_CALC_CONTEXT_ID,
         P_TEMPLATE_CODE,
         P_COMPONENT_CODE );
         RETURN ret_value;
   END DESCRIPTION;
   FUNCTION SORT_ORDER(
      P_CALC_CONTEXT_ID IN VARCHAR2,
      P_TEMPLATE_CODE IN VARCHAR2,
      P_COMPONENT_CODE IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CALC_COMPONENT_ROW.SORT_ORDER      (
         P_CALC_CONTEXT_ID,
         P_TEMPLATE_CODE,
         P_COMPONENT_CODE );
         RETURN ret_value;
   END SORT_ORDER;
   FUNCTION APPROVAL_BY(
      P_CALC_CONTEXT_ID IN VARCHAR2,
      P_TEMPLATE_CODE IN VARCHAR2,
      P_COMPONENT_CODE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (30) ;
   BEGIN
      ret_value := EC_CALC_COMPONENT_ROW.APPROVAL_BY      (
         P_CALC_CONTEXT_ID,
         P_TEMPLATE_CODE,
         P_COMPONENT_CODE );
         RETURN ret_value;
   END APPROVAL_BY;
   FUNCTION APPROVAL_STATE(
      P_CALC_CONTEXT_ID IN VARCHAR2,
      P_TEMPLATE_CODE IN VARCHAR2,
      P_COMPONENT_CODE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_CALC_COMPONENT_ROW.APPROVAL_STATE      (
         P_CALC_CONTEXT_ID,
         P_TEMPLATE_CODE,
         P_COMPONENT_CODE );
         RETURN ret_value;
   END APPROVAL_STATE;
   FUNCTION LABEL(
      P_CALC_CONTEXT_ID IN VARCHAR2,
      P_TEMPLATE_CODE IN VARCHAR2,
      P_COMPONENT_CODE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_CALC_COMPONENT_ROW.LABEL      (
         P_CALC_CONTEXT_ID,
         P_TEMPLATE_CODE,
         P_COMPONENT_CODE );
         RETURN ret_value;
   END LABEL;
   FUNCTION RECORD_STATUS(
      P_CALC_CONTEXT_ID IN VARCHAR2,
      P_TEMPLATE_CODE IN VARCHAR2,
      P_COMPONENT_CODE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_CALC_COMPONENT_ROW.RECORD_STATUS      (
         P_CALC_CONTEXT_ID,
         P_TEMPLATE_CODE,
         P_COMPONENT_CODE );
         RETURN ret_value;
   END RECORD_STATUS;
   FUNCTION APPROVAL_DATE(
      P_CALC_CONTEXT_ID IN VARCHAR2,
      P_TEMPLATE_CODE IN VARCHAR2,
      P_COMPONENT_CODE IN VARCHAR2)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CALC_COMPONENT_ROW.APPROVAL_DATE      (
         P_CALC_CONTEXT_ID,
         P_TEMPLATE_CODE,
         P_COMPONENT_CODE );
         RETURN ret_value;
   END APPROVAL_DATE;
   FUNCTION ROW_BY_PK(
      P_CALC_CONTEXT_ID IN VARCHAR2,
      P_TEMPLATE_CODE IN VARCHAR2,
      P_COMPONENT_CODE IN VARCHAR2)
      RETURN REC_ROW_BY_PK
   IS
      ret_value    REC_ROW_BY_PK ;
   BEGIN
      ret_value := EC_CALC_COMPONENT_ROW.ROW_BY_PK      (
         P_CALC_CONTEXT_ID,
         P_TEMPLATE_CODE,
         P_COMPONENT_CODE );
         RETURN ret_value;
   END ROW_BY_PK;
   FUNCTION TYPE(
      P_CALC_CONTEXT_ID IN VARCHAR2,
      P_TEMPLATE_CODE IN VARCHAR2,
      P_COMPONENT_CODE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_CALC_COMPONENT_ROW.TYPE      (
         P_CALC_CONTEXT_ID,
         P_TEMPLATE_CODE,
         P_COMPONENT_CODE );
         RETURN ret_value;
   END TYPE;
   FUNCTION REC_ID(
      P_CALC_CONTEXT_ID IN VARCHAR2,
      P_TEMPLATE_CODE IN VARCHAR2,
      P_COMPONENT_CODE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_CALC_COMPONENT_ROW.REC_ID      (
         P_CALC_CONTEXT_ID,
         P_TEMPLATE_CODE,
         P_COMPONENT_CODE );
         RETURN ret_value;
   END REC_ID;

END RP_CALC_COMPONENT_ROW;

/
--GRANT EXECUTE ON ECKERNEL_WST.RP_CALC_COMPONENT_ROW TO REPORT_ROLE_XXX;



 -- FINISH PKG_GEN_PKGS.sf_get_functions at:11/15/2018 11.00.27 AM


