
 -- START PKG_GEN_PKGS.sf_get_functions at:05/07/2019 07.43.11 AM


CREATE or REPLACE PACKAGE RP_REPORT_TEMPLATE
IS

   FUNCTION APPROVAL_BY(
      P_TEMPLATE_CODE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_STATE(
      P_TEMPLATE_CODE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION TEMPLATE_BLOB(
      P_TEMPLATE_CODE IN VARCHAR2)
      RETURN BLOB;
   FUNCTION REPORTING_PERIOD(
      P_TEMPLATE_CODE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION REPORT_SYSTEM_CODE(
      P_TEMPLATE_CODE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION RECORD_STATUS(
      P_TEMPLATE_CODE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_DATE(
      P_TEMPLATE_CODE IN VARCHAR2)
      RETURN DATE;
   FUNCTION NAME(
      P_TEMPLATE_CODE IN VARCHAR2)
      RETURN VARCHAR2;
      TYPE REC_ROW_BY_PK IS RECORD (
         TEMPLATE_CODE VARCHAR2 (32) ,
         NAME VARCHAR2 (240) ,
         REPORT_SYSTEM_CODE VARCHAR2 (32) ,
         REPORTING_PERIOD VARCHAR2 (32) ,
         TEMPLATE_BLOB  BLOB ,
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
      P_TEMPLATE_CODE IN VARCHAR2)
      RETURN REC_ROW_BY_PK;
   FUNCTION REC_ID(
      P_TEMPLATE_CODE IN VARCHAR2)
      RETURN VARCHAR2;

END RP_REPORT_TEMPLATE;

/



CREATE or REPLACE PACKAGE BODY RP_REPORT_TEMPLATE
IS

   FUNCTION APPROVAL_BY(
      P_TEMPLATE_CODE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (30) ;
   BEGIN
      ret_value := EC_REPORT_TEMPLATE.APPROVAL_BY      (
         P_TEMPLATE_CODE );
         RETURN ret_value;
   END APPROVAL_BY;
   FUNCTION APPROVAL_STATE(
      P_TEMPLATE_CODE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_REPORT_TEMPLATE.APPROVAL_STATE      (
         P_TEMPLATE_CODE );
         RETURN ret_value;
   END APPROVAL_STATE;
   FUNCTION TEMPLATE_BLOB(
      P_TEMPLATE_CODE IN VARCHAR2)
      RETURN BLOB
   IS
      ret_value    BLOB ;
   BEGIN
      ret_value := EC_REPORT_TEMPLATE.TEMPLATE_BLOB      (
         P_TEMPLATE_CODE );
         RETURN ret_value;
   END TEMPLATE_BLOB;
   FUNCTION REPORTING_PERIOD(
      P_TEMPLATE_CODE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_REPORT_TEMPLATE.REPORTING_PERIOD      (
         P_TEMPLATE_CODE );
         RETURN ret_value;
   END REPORTING_PERIOD;
   FUNCTION REPORT_SYSTEM_CODE(
      P_TEMPLATE_CODE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_REPORT_TEMPLATE.REPORT_SYSTEM_CODE      (
         P_TEMPLATE_CODE );
         RETURN ret_value;
   END REPORT_SYSTEM_CODE;
   FUNCTION RECORD_STATUS(
      P_TEMPLATE_CODE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_REPORT_TEMPLATE.RECORD_STATUS      (
         P_TEMPLATE_CODE );
         RETURN ret_value;
   END RECORD_STATUS;
   FUNCTION APPROVAL_DATE(
      P_TEMPLATE_CODE IN VARCHAR2)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_REPORT_TEMPLATE.APPROVAL_DATE      (
         P_TEMPLATE_CODE );
         RETURN ret_value;
   END APPROVAL_DATE;
   FUNCTION NAME(
      P_TEMPLATE_CODE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_REPORT_TEMPLATE.NAME      (
         P_TEMPLATE_CODE );
         RETURN ret_value;
   END NAME;
   FUNCTION ROW_BY_PK(
      P_TEMPLATE_CODE IN VARCHAR2)
      RETURN REC_ROW_BY_PK
   IS
      ret_value    REC_ROW_BY_PK ;
   BEGIN
      ret_value := EC_REPORT_TEMPLATE.ROW_BY_PK      (
         P_TEMPLATE_CODE );
         RETURN ret_value;
   END ROW_BY_PK;
   FUNCTION REC_ID(
      P_TEMPLATE_CODE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_REPORT_TEMPLATE.REC_ID      (
         P_TEMPLATE_CODE );
         RETURN ret_value;
   END REC_ID;

END RP_REPORT_TEMPLATE;

/
--GRANT EXECUTE ON ECKERNEL_WST.RP_REPORT_TEMPLATE TO REPORT_ROLE_XXX;



 -- FINISH PKG_GEN_PKGS.sf_get_functions at:05/07/2019 07.43.15 AM


