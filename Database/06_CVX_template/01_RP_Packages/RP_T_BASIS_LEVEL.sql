
 -- START PKG_GEN_PKGS.sf_get_functions at:05/07/2019 05.27.15 AM


CREATE or REPLACE PACKAGE RP_T_BASIS_LEVEL
IS

   FUNCTION APPROVAL_BY(
      P_LEVEL_ID IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_STATE(
      P_LEVEL_ID IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION LEVEL_NAME(
      P_LEVEL_ID IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION RECORD_STATUS(
      P_LEVEL_ID IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_DATE(
      P_LEVEL_ID IN NUMBER)
      RETURN DATE;
      TYPE REC_ROW_BY_PK IS RECORD (
         LEVEL_ID NUMBER ,
         LEVEL_NAME VARCHAR2 (40) ,
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
      P_LEVEL_ID IN NUMBER)
      RETURN REC_ROW_BY_PK;
   FUNCTION REC_ID(
      P_LEVEL_ID IN NUMBER)
      RETURN VARCHAR2;

END RP_T_BASIS_LEVEL;

/



CREATE or REPLACE PACKAGE BODY RP_T_BASIS_LEVEL
IS

   FUNCTION APPROVAL_BY(
      P_LEVEL_ID IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (30) ;
   BEGIN
      ret_value := EC_T_BASIS_LEVEL.APPROVAL_BY      (
         P_LEVEL_ID );
         RETURN ret_value;
   END APPROVAL_BY;
   FUNCTION APPROVAL_STATE(
      P_LEVEL_ID IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_T_BASIS_LEVEL.APPROVAL_STATE      (
         P_LEVEL_ID );
         RETURN ret_value;
   END APPROVAL_STATE;
   FUNCTION LEVEL_NAME(
      P_LEVEL_ID IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (40) ;
   BEGIN
      ret_value := EC_T_BASIS_LEVEL.LEVEL_NAME      (
         P_LEVEL_ID );
         RETURN ret_value;
   END LEVEL_NAME;
   FUNCTION RECORD_STATUS(
      P_LEVEL_ID IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_T_BASIS_LEVEL.RECORD_STATUS      (
         P_LEVEL_ID );
         RETURN ret_value;
   END RECORD_STATUS;
   FUNCTION APPROVAL_DATE(
      P_LEVEL_ID IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_T_BASIS_LEVEL.APPROVAL_DATE      (
         P_LEVEL_ID );
         RETURN ret_value;
   END APPROVAL_DATE;
   FUNCTION ROW_BY_PK(
      P_LEVEL_ID IN NUMBER)
      RETURN REC_ROW_BY_PK
   IS
      ret_value    REC_ROW_BY_PK ;
   BEGIN
      ret_value := EC_T_BASIS_LEVEL.ROW_BY_PK      (
         P_LEVEL_ID );
         RETURN ret_value;
   END ROW_BY_PK;
   FUNCTION REC_ID(
      P_LEVEL_ID IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_T_BASIS_LEVEL.REC_ID      (
         P_LEVEL_ID );
         RETURN ret_value;
   END REC_ID;

END RP_T_BASIS_LEVEL;

/
--GRANT EXECUTE ON ECKERNEL_WST.RP_T_BASIS_LEVEL TO REPORT_ROLE_XXX;



 -- FINISH PKG_GEN_PKGS.sf_get_functions at:05/07/2019 05.27.17 AM


