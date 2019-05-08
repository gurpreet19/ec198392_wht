
 -- START PKG_GEN_PKGS.sf_get_functions at:05/07/2019 09.08.13 AM


CREATE or REPLACE PACKAGE RP_MESSAGE_DISTR_PARAM
IS

   FUNCTION PARAMETER_SUB_TYPE(
      P_MESSAGE_DISTRIBUTION_NO IN NUMBER,
      P_PARAMETER_NAME IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_BY(
      P_MESSAGE_DISTRIBUTION_NO IN NUMBER,
      P_PARAMETER_NAME IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_STATE(
      P_MESSAGE_DISTRIBUTION_NO IN NUMBER,
      P_PARAMETER_NAME IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION RECORD_STATUS(
      P_MESSAGE_DISTRIBUTION_NO IN NUMBER,
      P_PARAMETER_NAME IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_DATE(
      P_MESSAGE_DISTRIBUTION_NO IN NUMBER,
      P_PARAMETER_NAME IN VARCHAR2)
      RETURN DATE;
   FUNCTION PARAMETER_VALUE(
      P_MESSAGE_DISTRIBUTION_NO IN NUMBER,
      P_PARAMETER_NAME IN VARCHAR2)
      RETURN VARCHAR2;
      TYPE REC_ROW_BY_PK IS RECORD (
         MESSAGE_DISTRIBUTION_NO NUMBER ,
         PARAMETER_NAME VARCHAR2 (240) ,
         PARAMETER_TYPE VARCHAR2 (32) ,
         PARAMETER_SUB_TYPE VARCHAR2 (32) ,
         PARAMETER_VALUE VARCHAR2 (2000) ,
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
      P_MESSAGE_DISTRIBUTION_NO IN NUMBER,
      P_PARAMETER_NAME IN VARCHAR2)
      RETURN REC_ROW_BY_PK;
   FUNCTION PARAMETER_TYPE(
      P_MESSAGE_DISTRIBUTION_NO IN NUMBER,
      P_PARAMETER_NAME IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION REC_ID(
      P_MESSAGE_DISTRIBUTION_NO IN NUMBER,
      P_PARAMETER_NAME IN VARCHAR2)
      RETURN VARCHAR2;

END RP_MESSAGE_DISTR_PARAM;

/



CREATE or REPLACE PACKAGE BODY RP_MESSAGE_DISTR_PARAM
IS

   FUNCTION PARAMETER_SUB_TYPE(
      P_MESSAGE_DISTRIBUTION_NO IN NUMBER,
      P_PARAMETER_NAME IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_MESSAGE_DISTR_PARAM.PARAMETER_SUB_TYPE      (
         P_MESSAGE_DISTRIBUTION_NO,
         P_PARAMETER_NAME );
         RETURN ret_value;
   END PARAMETER_SUB_TYPE;
   FUNCTION APPROVAL_BY(
      P_MESSAGE_DISTRIBUTION_NO IN NUMBER,
      P_PARAMETER_NAME IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (30) ;
   BEGIN
      ret_value := EC_MESSAGE_DISTR_PARAM.APPROVAL_BY      (
         P_MESSAGE_DISTRIBUTION_NO,
         P_PARAMETER_NAME );
         RETURN ret_value;
   END APPROVAL_BY;
   FUNCTION APPROVAL_STATE(
      P_MESSAGE_DISTRIBUTION_NO IN NUMBER,
      P_PARAMETER_NAME IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_MESSAGE_DISTR_PARAM.APPROVAL_STATE      (
         P_MESSAGE_DISTRIBUTION_NO,
         P_PARAMETER_NAME );
         RETURN ret_value;
   END APPROVAL_STATE;
   FUNCTION RECORD_STATUS(
      P_MESSAGE_DISTRIBUTION_NO IN NUMBER,
      P_PARAMETER_NAME IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_MESSAGE_DISTR_PARAM.RECORD_STATUS      (
         P_MESSAGE_DISTRIBUTION_NO,
         P_PARAMETER_NAME );
         RETURN ret_value;
   END RECORD_STATUS;
   FUNCTION APPROVAL_DATE(
      P_MESSAGE_DISTRIBUTION_NO IN NUMBER,
      P_PARAMETER_NAME IN VARCHAR2)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_MESSAGE_DISTR_PARAM.APPROVAL_DATE      (
         P_MESSAGE_DISTRIBUTION_NO,
         P_PARAMETER_NAME );
         RETURN ret_value;
   END APPROVAL_DATE;
   FUNCTION PARAMETER_VALUE(
      P_MESSAGE_DISTRIBUTION_NO IN NUMBER,
      P_PARAMETER_NAME IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_MESSAGE_DISTR_PARAM.PARAMETER_VALUE      (
         P_MESSAGE_DISTRIBUTION_NO,
         P_PARAMETER_NAME );
         RETURN ret_value;
   END PARAMETER_VALUE;
   FUNCTION ROW_BY_PK(
      P_MESSAGE_DISTRIBUTION_NO IN NUMBER,
      P_PARAMETER_NAME IN VARCHAR2)
      RETURN REC_ROW_BY_PK
   IS
      ret_value    REC_ROW_BY_PK ;
   BEGIN
      ret_value := EC_MESSAGE_DISTR_PARAM.ROW_BY_PK      (
         P_MESSAGE_DISTRIBUTION_NO,
         P_PARAMETER_NAME );
         RETURN ret_value;
   END ROW_BY_PK;
   FUNCTION PARAMETER_TYPE(
      P_MESSAGE_DISTRIBUTION_NO IN NUMBER,
      P_PARAMETER_NAME IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_MESSAGE_DISTR_PARAM.PARAMETER_TYPE      (
         P_MESSAGE_DISTRIBUTION_NO,
         P_PARAMETER_NAME );
         RETURN ret_value;
   END PARAMETER_TYPE;
   FUNCTION REC_ID(
      P_MESSAGE_DISTRIBUTION_NO IN NUMBER,
      P_PARAMETER_NAME IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_MESSAGE_DISTR_PARAM.REC_ID      (
         P_MESSAGE_DISTRIBUTION_NO,
         P_PARAMETER_NAME );
         RETURN ret_value;
   END REC_ID;

END RP_MESSAGE_DISTR_PARAM;

/
--GRANT EXECUTE ON ECKERNEL_WST.RP_MESSAGE_DISTR_PARAM TO REPORT_ROLE_XXX;



 -- FINISH PKG_GEN_PKGS.sf_get_functions at:05/07/2019 09.08.15 AM


