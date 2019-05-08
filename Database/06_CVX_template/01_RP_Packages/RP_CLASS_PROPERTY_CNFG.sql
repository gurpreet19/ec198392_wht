
 -- START PKG_GEN_PKGS.sf_get_functions at:05/07/2019 11.00.36 AM


CREATE or REPLACE PACKAGE RP_CLASS_PROPERTY_CNFG
IS

   FUNCTION APPROVAL_BY(
      P_CLASS_NAME IN VARCHAR2,
      P_PROPERTY_CODE IN VARCHAR2,
      P_PROPERTY_TYPE IN VARCHAR2,
      P_OWNER_CNTX IN NUMBER,
      P_PRESENTATION_CNTX IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_STATE(
      P_CLASS_NAME IN VARCHAR2,
      P_PROPERTY_CODE IN VARCHAR2,
      P_PROPERTY_TYPE IN VARCHAR2,
      P_OWNER_CNTX IN NUMBER,
      P_PRESENTATION_CNTX IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION PROPERTY_VALUE(
      P_CLASS_NAME IN VARCHAR2,
      P_PROPERTY_CODE IN VARCHAR2,
      P_PROPERTY_TYPE IN VARCHAR2,
      P_OWNER_CNTX IN NUMBER,
      P_PRESENTATION_CNTX IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION RECORD_STATUS(
      P_CLASS_NAME IN VARCHAR2,
      P_PROPERTY_CODE IN VARCHAR2,
      P_PROPERTY_TYPE IN VARCHAR2,
      P_OWNER_CNTX IN NUMBER,
      P_PRESENTATION_CNTX IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_DATE(
      P_CLASS_NAME IN VARCHAR2,
      P_PROPERTY_CODE IN VARCHAR2,
      P_PROPERTY_TYPE IN VARCHAR2,
      P_OWNER_CNTX IN NUMBER,
      P_PRESENTATION_CNTX IN VARCHAR2)
      RETURN DATE;
      TYPE REC_ROW_BY_PK IS RECORD (
         CLASS_NAME VARCHAR2 (24) ,
         PROPERTY_CODE VARCHAR2 (100) ,
         OWNER_CNTX NUMBER ,
         PRESENTATION_CNTX VARCHAR2 (250) ,
         PROPERTY_TYPE VARCHAR2 (24) ,
         PROPERTY_VALUE VARCHAR2 (4000) ,
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
      P_CLASS_NAME IN VARCHAR2,
      P_PROPERTY_CODE IN VARCHAR2,
      P_PROPERTY_TYPE IN VARCHAR2,
      P_OWNER_CNTX IN NUMBER,
      P_PRESENTATION_CNTX IN VARCHAR2)
      RETURN REC_ROW_BY_PK;
   FUNCTION REC_ID(
      P_CLASS_NAME IN VARCHAR2,
      P_PROPERTY_CODE IN VARCHAR2,
      P_PROPERTY_TYPE IN VARCHAR2,
      P_OWNER_CNTX IN NUMBER,
      P_PRESENTATION_CNTX IN VARCHAR2)
      RETURN VARCHAR2;

END RP_CLASS_PROPERTY_CNFG;

/



CREATE or REPLACE PACKAGE BODY RP_CLASS_PROPERTY_CNFG
IS

   FUNCTION APPROVAL_BY(
      P_CLASS_NAME IN VARCHAR2,
      P_PROPERTY_CODE IN VARCHAR2,
      P_PROPERTY_TYPE IN VARCHAR2,
      P_OWNER_CNTX IN NUMBER,
      P_PRESENTATION_CNTX IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (30) ;
   BEGIN
      ret_value := EC_CLASS_PROPERTY_CNFG.APPROVAL_BY      (
         P_CLASS_NAME,
         P_PROPERTY_CODE,
         P_PROPERTY_TYPE,
         P_OWNER_CNTX,
         P_PRESENTATION_CNTX );
         RETURN ret_value;
   END APPROVAL_BY;
   FUNCTION APPROVAL_STATE(
      P_CLASS_NAME IN VARCHAR2,
      P_PROPERTY_CODE IN VARCHAR2,
      P_PROPERTY_TYPE IN VARCHAR2,
      P_OWNER_CNTX IN NUMBER,
      P_PRESENTATION_CNTX IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_CLASS_PROPERTY_CNFG.APPROVAL_STATE      (
         P_CLASS_NAME,
         P_PROPERTY_CODE,
         P_PROPERTY_TYPE,
         P_OWNER_CNTX,
         P_PRESENTATION_CNTX );
         RETURN ret_value;
   END APPROVAL_STATE;
   FUNCTION PROPERTY_VALUE(
      P_CLASS_NAME IN VARCHAR2,
      P_PROPERTY_CODE IN VARCHAR2,
      P_PROPERTY_TYPE IN VARCHAR2,
      P_OWNER_CNTX IN NUMBER,
      P_PRESENTATION_CNTX IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (4000) ;
   BEGIN
      ret_value := EC_CLASS_PROPERTY_CNFG.PROPERTY_VALUE      (
         P_CLASS_NAME,
         P_PROPERTY_CODE,
         P_PROPERTY_TYPE,
         P_OWNER_CNTX,
         P_PRESENTATION_CNTX );
         RETURN ret_value;
   END PROPERTY_VALUE;
   FUNCTION RECORD_STATUS(
      P_CLASS_NAME IN VARCHAR2,
      P_PROPERTY_CODE IN VARCHAR2,
      P_PROPERTY_TYPE IN VARCHAR2,
      P_OWNER_CNTX IN NUMBER,
      P_PRESENTATION_CNTX IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_CLASS_PROPERTY_CNFG.RECORD_STATUS      (
         P_CLASS_NAME,
         P_PROPERTY_CODE,
         P_PROPERTY_TYPE,
         P_OWNER_CNTX,
         P_PRESENTATION_CNTX );
         RETURN ret_value;
   END RECORD_STATUS;
   FUNCTION APPROVAL_DATE(
      P_CLASS_NAME IN VARCHAR2,
      P_PROPERTY_CODE IN VARCHAR2,
      P_PROPERTY_TYPE IN VARCHAR2,
      P_OWNER_CNTX IN NUMBER,
      P_PRESENTATION_CNTX IN VARCHAR2)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CLASS_PROPERTY_CNFG.APPROVAL_DATE      (
         P_CLASS_NAME,
         P_PROPERTY_CODE,
         P_PROPERTY_TYPE,
         P_OWNER_CNTX,
         P_PRESENTATION_CNTX );
         RETURN ret_value;
   END APPROVAL_DATE;
   FUNCTION ROW_BY_PK(
      P_CLASS_NAME IN VARCHAR2,
      P_PROPERTY_CODE IN VARCHAR2,
      P_PROPERTY_TYPE IN VARCHAR2,
      P_OWNER_CNTX IN NUMBER,
      P_PRESENTATION_CNTX IN VARCHAR2)
      RETURN REC_ROW_BY_PK
   IS
      ret_value    REC_ROW_BY_PK ;
   BEGIN
      ret_value := EC_CLASS_PROPERTY_CNFG.ROW_BY_PK      (
         P_CLASS_NAME,
         P_PROPERTY_CODE,
         P_PROPERTY_TYPE,
         P_OWNER_CNTX,
         P_PRESENTATION_CNTX );
         RETURN ret_value;
   END ROW_BY_PK;
   FUNCTION REC_ID(
      P_CLASS_NAME IN VARCHAR2,
      P_PROPERTY_CODE IN VARCHAR2,
      P_PROPERTY_TYPE IN VARCHAR2,
      P_OWNER_CNTX IN NUMBER,
      P_PRESENTATION_CNTX IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_CLASS_PROPERTY_CNFG.REC_ID      (
         P_CLASS_NAME,
         P_PROPERTY_CODE,
         P_PROPERTY_TYPE,
         P_OWNER_CNTX,
         P_PRESENTATION_CNTX );
         RETURN ret_value;
   END REC_ID;

END RP_CLASS_PROPERTY_CNFG;

/
--GRANT EXECUTE ON ECKERNEL_WST.RP_CLASS_PROPERTY_CNFG TO REPORT_ROLE_XXX;



 -- FINISH PKG_GEN_PKGS.sf_get_functions at:05/07/2019 11.00.38 AM


