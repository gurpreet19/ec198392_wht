
 -- START PKG_GEN_PKGS.sf_get_functions at:11/15/2018 07.16.12 AM


CREATE or REPLACE PACKAGE RP_T_BASIS_ROLE
IS

   FUNCTION APPROVAL_BY(
      P_ROLE_ID IN VARCHAR2,
      P_APP_ID IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_STATE(
      P_ROLE_ID IN VARCHAR2,
      P_APP_ID IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION RECORD_STATUS(
      P_ROLE_ID IN VARCHAR2,
      P_APP_ID IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_DATE(
      P_ROLE_ID IN VARCHAR2,
      P_APP_ID IN NUMBER)
      RETURN DATE;
      TYPE REC_ROW_BY_PK IS RECORD (
         ROLE_ID VARCHAR2 (30) ,
         APP_ID NUMBER ,
         ROLE_NAME VARCHAR2 (50) ,
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
      P_ROLE_ID IN VARCHAR2,
      P_APP_ID IN NUMBER)
      RETURN REC_ROW_BY_PK;
   FUNCTION REC_ID(
      P_ROLE_ID IN VARCHAR2,
      P_APP_ID IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION ROLE_NAME(
      P_ROLE_ID IN VARCHAR2,
      P_APP_ID IN NUMBER)
      RETURN VARCHAR2;

END RP_T_BASIS_ROLE;

/



CREATE or REPLACE PACKAGE BODY RP_T_BASIS_ROLE
IS

   FUNCTION APPROVAL_BY(
      P_ROLE_ID IN VARCHAR2,
      P_APP_ID IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (30) ;
   BEGIN
      ret_value := EC_T_BASIS_ROLE.APPROVAL_BY      (
         P_ROLE_ID,
         P_APP_ID );
         RETURN ret_value;
   END APPROVAL_BY;
   FUNCTION APPROVAL_STATE(
      P_ROLE_ID IN VARCHAR2,
      P_APP_ID IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_T_BASIS_ROLE.APPROVAL_STATE      (
         P_ROLE_ID,
         P_APP_ID );
         RETURN ret_value;
   END APPROVAL_STATE;
   FUNCTION RECORD_STATUS(
      P_ROLE_ID IN VARCHAR2,
      P_APP_ID IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_T_BASIS_ROLE.RECORD_STATUS      (
         P_ROLE_ID,
         P_APP_ID );
         RETURN ret_value;
   END RECORD_STATUS;
   FUNCTION APPROVAL_DATE(
      P_ROLE_ID IN VARCHAR2,
      P_APP_ID IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_T_BASIS_ROLE.APPROVAL_DATE      (
         P_ROLE_ID,
         P_APP_ID );
         RETURN ret_value;
   END APPROVAL_DATE;
   FUNCTION ROW_BY_PK(
      P_ROLE_ID IN VARCHAR2,
      P_APP_ID IN NUMBER)
      RETURN REC_ROW_BY_PK
   IS
      ret_value    REC_ROW_BY_PK ;
   BEGIN
      ret_value := EC_T_BASIS_ROLE.ROW_BY_PK      (
         P_ROLE_ID,
         P_APP_ID );
         RETURN ret_value;
   END ROW_BY_PK;
   FUNCTION REC_ID(
      P_ROLE_ID IN VARCHAR2,
      P_APP_ID IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_T_BASIS_ROLE.REC_ID      (
         P_ROLE_ID,
         P_APP_ID );
         RETURN ret_value;
   END REC_ID;
   FUNCTION ROLE_NAME(
      P_ROLE_ID IN VARCHAR2,
      P_APP_ID IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (50) ;
   BEGIN
      ret_value := EC_T_BASIS_ROLE.ROLE_NAME      (
         P_ROLE_ID,
         P_APP_ID );
         RETURN ret_value;
   END ROLE_NAME;

END RP_T_BASIS_ROLE;

/
--GRANT EXECUTE ON ECKERNEL_WST.RP_T_BASIS_ROLE TO REPORT_ROLE_XXX;



 -- FINISH PKG_GEN_PKGS.sf_get_functions at:11/15/2018 07.16.14 AM


