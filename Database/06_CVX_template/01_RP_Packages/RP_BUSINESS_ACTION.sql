
 -- START PKG_GEN_PKGS.sf_get_functions at:05/07/2019 11.18.10 AM


CREATE or REPLACE PACKAGE RP_BUSINESS_ACTION
IS

   FUNCTION ACTION_CLASS_NAME(
      P_BUSINESS_ACTION_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION BA_TYPE(
      P_BUSINESS_ACTION_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_BY(
      P_BUSINESS_ACTION_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_STATE(
      P_BUSINESS_ACTION_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION FUNCTIONAL_AREA_ID(
      P_BUSINESS_ACTION_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION JBPM_DEPLOYMENT_ID(
      P_BUSINESS_ACTION_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION JBPM_PROCESS_VERSION(
      P_BUSINESS_ACTION_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION RECORD_STATUS(
      P_BUSINESS_ACTION_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_DATE(
      P_BUSINESS_ACTION_NO IN NUMBER)
      RETURN DATE;
   FUNCTION NAME(
      P_BUSINESS_ACTION_NO IN NUMBER)
      RETURN VARCHAR2;
      TYPE REC_ROW_BY_PK IS RECORD (
         BUSINESS_ACTION_NO NUMBER ,
         NAME VARCHAR2 (240) ,
         ACTION_CLASS_NAME VARCHAR2 (256) ,
         FUNCTIONAL_AREA_ID VARCHAR2 (32) ,
         BA_TYPE VARCHAR2 (32) ,
         JBPM_PROCESS_NAME VARCHAR2 (255) ,
         JBPM_PROCESS_VERSION NUMBER ,
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
         JBPM_DEPLOYMENT_ID VARCHAR2 (255)  );
   FUNCTION ROW_BY_PK(
      P_BUSINESS_ACTION_NO IN NUMBER)
      RETURN REC_ROW_BY_PK;
   FUNCTION REC_ID(
      P_BUSINESS_ACTION_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION JBPM_PROCESS_NAME(
      P_BUSINESS_ACTION_NO IN NUMBER)
      RETURN VARCHAR2;

END RP_BUSINESS_ACTION;

/



CREATE or REPLACE PACKAGE BODY RP_BUSINESS_ACTION
IS

   FUNCTION ACTION_CLASS_NAME(
      P_BUSINESS_ACTION_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (256) ;
   BEGIN
      ret_value := EC_BUSINESS_ACTION.ACTION_CLASS_NAME      (
         P_BUSINESS_ACTION_NO );
         RETURN ret_value;
   END ACTION_CLASS_NAME;
   FUNCTION BA_TYPE(
      P_BUSINESS_ACTION_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_BUSINESS_ACTION.BA_TYPE      (
         P_BUSINESS_ACTION_NO );
         RETURN ret_value;
   END BA_TYPE;
   FUNCTION APPROVAL_BY(
      P_BUSINESS_ACTION_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (30) ;
   BEGIN
      ret_value := EC_BUSINESS_ACTION.APPROVAL_BY      (
         P_BUSINESS_ACTION_NO );
         RETURN ret_value;
   END APPROVAL_BY;
   FUNCTION APPROVAL_STATE(
      P_BUSINESS_ACTION_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_BUSINESS_ACTION.APPROVAL_STATE      (
         P_BUSINESS_ACTION_NO );
         RETURN ret_value;
   END APPROVAL_STATE;
   FUNCTION FUNCTIONAL_AREA_ID(
      P_BUSINESS_ACTION_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_BUSINESS_ACTION.FUNCTIONAL_AREA_ID      (
         P_BUSINESS_ACTION_NO );
         RETURN ret_value;
   END FUNCTIONAL_AREA_ID;
   FUNCTION JBPM_DEPLOYMENT_ID(
      P_BUSINESS_ACTION_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (255) ;
   BEGIN
      ret_value := EC_BUSINESS_ACTION.JBPM_DEPLOYMENT_ID      (
         P_BUSINESS_ACTION_NO );
         RETURN ret_value;
   END JBPM_DEPLOYMENT_ID;
   FUNCTION JBPM_PROCESS_VERSION(
      P_BUSINESS_ACTION_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_BUSINESS_ACTION.JBPM_PROCESS_VERSION      (
         P_BUSINESS_ACTION_NO );
         RETURN ret_value;
   END JBPM_PROCESS_VERSION;
   FUNCTION RECORD_STATUS(
      P_BUSINESS_ACTION_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_BUSINESS_ACTION.RECORD_STATUS      (
         P_BUSINESS_ACTION_NO );
         RETURN ret_value;
   END RECORD_STATUS;
   FUNCTION APPROVAL_DATE(
      P_BUSINESS_ACTION_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_BUSINESS_ACTION.APPROVAL_DATE      (
         P_BUSINESS_ACTION_NO );
         RETURN ret_value;
   END APPROVAL_DATE;
   FUNCTION NAME(
      P_BUSINESS_ACTION_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_BUSINESS_ACTION.NAME      (
         P_BUSINESS_ACTION_NO );
         RETURN ret_value;
   END NAME;
   FUNCTION ROW_BY_PK(
      P_BUSINESS_ACTION_NO IN NUMBER)
      RETURN REC_ROW_BY_PK
   IS
      ret_value    REC_ROW_BY_PK ;
   BEGIN
      ret_value := EC_BUSINESS_ACTION.ROW_BY_PK      (
         P_BUSINESS_ACTION_NO );
         RETURN ret_value;
   END ROW_BY_PK;
   FUNCTION REC_ID(
      P_BUSINESS_ACTION_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_BUSINESS_ACTION.REC_ID      (
         P_BUSINESS_ACTION_NO );
         RETURN ret_value;
   END REC_ID;
   FUNCTION JBPM_PROCESS_NAME(
      P_BUSINESS_ACTION_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (255) ;
   BEGIN
      ret_value := EC_BUSINESS_ACTION.JBPM_PROCESS_NAME      (
         P_BUSINESS_ACTION_NO );
         RETURN ret_value;
   END JBPM_PROCESS_NAME;

END RP_BUSINESS_ACTION;

/
--GRANT EXECUTE ON ECKERNEL_WST.RP_BUSINESS_ACTION TO REPORT_ROLE_XXX;



 -- FINISH PKG_GEN_PKGS.sf_get_functions at:05/07/2019 11.18.13 AM

