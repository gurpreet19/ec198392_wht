
 -- START PKG_GEN_PKGS.sf_get_functions at:11/15/2018 11.02.00 AM


CREATE or REPLACE PACKAGE RP_BF_COMPONENT
IS

   FUNCTION COMP_CODE(
      P_BF_COMPONENT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION URL(
      P_BF_COMPONENT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_BY(
      P_BF_COMPONENT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_STATE(
      P_BF_COMPONENT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION BUSINESS_FUNCTION_NO(
      P_BF_COMPONENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION CLASS_NAME(
      P_BF_COMPONENT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION SIGNING_REQ_IND(
      P_BF_COMPONENT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION RECORD_STATUS(
      P_BF_COMPONENT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_DATE(
      P_BF_COMPONENT_NO IN NUMBER)
      RETURN DATE;
   FUNCTION BF_CODE(
      P_BF_COMPONENT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION NAME(
      P_BF_COMPONENT_NO IN NUMBER)
      RETURN VARCHAR2;
      TYPE REC_ROW_BY_PK IS RECORD (
         BF_COMPONENT_NO NUMBER ,
         BUSINESS_FUNCTION_NO NUMBER ,
         BF_CODE VARCHAR2 (32) ,
         COMP_CODE VARCHAR2 (100) ,
         NAME VARCHAR2 (240) ,
         CLASS_NAME VARCHAR2 (24) ,
         URL VARCHAR2 (1000) ,
         SIGNING_REQ_IND VARCHAR2 (1) ,
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
      P_BF_COMPONENT_NO IN NUMBER)
      RETURN REC_ROW_BY_PK;
   FUNCTION REC_ID(
      P_BF_COMPONENT_NO IN NUMBER)
      RETURN VARCHAR2;

END RP_BF_COMPONENT;

/



CREATE or REPLACE PACKAGE BODY RP_BF_COMPONENT
IS

   FUNCTION COMP_CODE(
      P_BF_COMPONENT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (100) ;
   BEGIN
      ret_value := EC_BF_COMPONENT.COMP_CODE      (
         P_BF_COMPONENT_NO );
         RETURN ret_value;
   END COMP_CODE;
   FUNCTION URL(
      P_BF_COMPONENT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1000) ;
   BEGIN
      ret_value := EC_BF_COMPONENT.URL      (
         P_BF_COMPONENT_NO );
         RETURN ret_value;
   END URL;
   FUNCTION APPROVAL_BY(
      P_BF_COMPONENT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (30) ;
   BEGIN
      ret_value := EC_BF_COMPONENT.APPROVAL_BY      (
         P_BF_COMPONENT_NO );
         RETURN ret_value;
   END APPROVAL_BY;
   FUNCTION APPROVAL_STATE(
      P_BF_COMPONENT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_BF_COMPONENT.APPROVAL_STATE      (
         P_BF_COMPONENT_NO );
         RETURN ret_value;
   END APPROVAL_STATE;
   FUNCTION BUSINESS_FUNCTION_NO(
      P_BF_COMPONENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_BF_COMPONENT.BUSINESS_FUNCTION_NO      (
         P_BF_COMPONENT_NO );
         RETURN ret_value;
   END BUSINESS_FUNCTION_NO;
   FUNCTION CLASS_NAME(
      P_BF_COMPONENT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (24) ;
   BEGIN
      ret_value := EC_BF_COMPONENT.CLASS_NAME      (
         P_BF_COMPONENT_NO );
         RETURN ret_value;
   END CLASS_NAME;
   FUNCTION SIGNING_REQ_IND(
      P_BF_COMPONENT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_BF_COMPONENT.SIGNING_REQ_IND      (
         P_BF_COMPONENT_NO );
         RETURN ret_value;
   END SIGNING_REQ_IND;
   FUNCTION RECORD_STATUS(
      P_BF_COMPONENT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_BF_COMPONENT.RECORD_STATUS      (
         P_BF_COMPONENT_NO );
         RETURN ret_value;
   END RECORD_STATUS;
   FUNCTION APPROVAL_DATE(
      P_BF_COMPONENT_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_BF_COMPONENT.APPROVAL_DATE      (
         P_BF_COMPONENT_NO );
         RETURN ret_value;
   END APPROVAL_DATE;
   FUNCTION BF_CODE(
      P_BF_COMPONENT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_BF_COMPONENT.BF_CODE      (
         P_BF_COMPONENT_NO );
         RETURN ret_value;
   END BF_CODE;
   FUNCTION NAME(
      P_BF_COMPONENT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_BF_COMPONENT.NAME      (
         P_BF_COMPONENT_NO );
         RETURN ret_value;
   END NAME;
   FUNCTION ROW_BY_PK(
      P_BF_COMPONENT_NO IN NUMBER)
      RETURN REC_ROW_BY_PK
   IS
      ret_value    REC_ROW_BY_PK ;
   BEGIN
      ret_value := EC_BF_COMPONENT.ROW_BY_PK      (
         P_BF_COMPONENT_NO );
         RETURN ret_value;
   END ROW_BY_PK;
   FUNCTION REC_ID(
      P_BF_COMPONENT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_BF_COMPONENT.REC_ID      (
         P_BF_COMPONENT_NO );
         RETURN ret_value;
   END REC_ID;

END RP_BF_COMPONENT;

/
--GRANT EXECUTE ON ECKERNEL_WST.RP_BF_COMPONENT TO REPORT_ROLE_XXX;



 -- FINISH PKG_GEN_PKGS.sf_get_functions at:11/15/2018 11.02.03 AM


