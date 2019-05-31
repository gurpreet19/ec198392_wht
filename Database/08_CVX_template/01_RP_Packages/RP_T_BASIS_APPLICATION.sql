
 -- START PKG_GEN_PKGS.sf_get_functions at:05/07/2019 05.27.33 AM


CREATE or REPLACE PACKAGE RP_T_BASIS_APPLICATION
IS

   FUNCTION APPROVAL_BY(
      P_APP_ID IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_STATE(
      P_APP_ID IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION APP_NAME(
      P_APP_ID IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION RECORD_STATUS(
      P_APP_ID IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_DATE(
      P_APP_ID IN NUMBER)
      RETURN DATE;
      TYPE REC_ROW_BY_PK IS RECORD (
         APP_ID NUMBER ,
         APP_NAME VARCHAR2 (40) ,
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
      P_APP_ID IN NUMBER)
      RETURN REC_ROW_BY_PK;
   FUNCTION REC_ID(
      P_APP_ID IN NUMBER)
      RETURN VARCHAR2;

END RP_T_BASIS_APPLICATION;

/



CREATE or REPLACE PACKAGE BODY RP_T_BASIS_APPLICATION
IS

   FUNCTION APPROVAL_BY(
      P_APP_ID IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (30) ;
   BEGIN
      ret_value := EC_T_BASIS_APPLICATION.APPROVAL_BY      (
         P_APP_ID );
         RETURN ret_value;
   END APPROVAL_BY;
   FUNCTION APPROVAL_STATE(
      P_APP_ID IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_T_BASIS_APPLICATION.APPROVAL_STATE      (
         P_APP_ID );
         RETURN ret_value;
   END APPROVAL_STATE;
   FUNCTION APP_NAME(
      P_APP_ID IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (40) ;
   BEGIN
      ret_value := EC_T_BASIS_APPLICATION.APP_NAME      (
         P_APP_ID );
         RETURN ret_value;
   END APP_NAME;
   FUNCTION RECORD_STATUS(
      P_APP_ID IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_T_BASIS_APPLICATION.RECORD_STATUS      (
         P_APP_ID );
         RETURN ret_value;
   END RECORD_STATUS;
   FUNCTION APPROVAL_DATE(
      P_APP_ID IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_T_BASIS_APPLICATION.APPROVAL_DATE      (
         P_APP_ID );
         RETURN ret_value;
   END APPROVAL_DATE;
   FUNCTION ROW_BY_PK(
      P_APP_ID IN NUMBER)
      RETURN REC_ROW_BY_PK
   IS
      ret_value    REC_ROW_BY_PK ;
   BEGIN
      ret_value := EC_T_BASIS_APPLICATION.ROW_BY_PK      (
         P_APP_ID );
         RETURN ret_value;
   END ROW_BY_PK;
   FUNCTION REC_ID(
      P_APP_ID IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_T_BASIS_APPLICATION.REC_ID      (
         P_APP_ID );
         RETURN ret_value;
   END REC_ID;

END RP_T_BASIS_APPLICATION;

/
--GRANT EXECUTE ON ECKERNEL_WST.RP_T_BASIS_APPLICATION TO REPORT_ROLE_XXX;



 -- FINISH PKG_GEN_PKGS.sf_get_functions at:05/07/2019 05.27.36 AM


