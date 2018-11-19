
 -- START PKG_GEN_PKGS.sf_get_functions at:11/15/2018 07.16.24 AM


CREATE or REPLACE PACKAGE RP_T_BASIS_LANGUAGE_SOURCE
IS

   FUNCTION APPROVAL_BY(
      P_SOURCE_ID IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_STATE(
      P_SOURCE_ID IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION RECORD_STATUS(
      P_SOURCE_ID IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION SOURCE_TEXT(
      P_SOURCE_ID IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_DATE(
      P_SOURCE_ID IN NUMBER)
      RETURN DATE;
      TYPE REC_ROW_BY_PK IS RECORD (
         SOURCE_ID NUMBER ,
         SOURCE_TEXT VARCHAR2 (2000) ,
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
      P_SOURCE_ID IN NUMBER)
      RETURN REC_ROW_BY_PK;
   FUNCTION REC_ID(
      P_SOURCE_ID IN NUMBER)
      RETURN VARCHAR2;

END RP_T_BASIS_LANGUAGE_SOURCE;

/



CREATE or REPLACE PACKAGE BODY RP_T_BASIS_LANGUAGE_SOURCE
IS

   FUNCTION APPROVAL_BY(
      P_SOURCE_ID IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (30) ;
   BEGIN
      ret_value := EC_T_BASIS_LANGUAGE_SOURCE.APPROVAL_BY      (
         P_SOURCE_ID );
         RETURN ret_value;
   END APPROVAL_BY;
   FUNCTION APPROVAL_STATE(
      P_SOURCE_ID IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_T_BASIS_LANGUAGE_SOURCE.APPROVAL_STATE      (
         P_SOURCE_ID );
         RETURN ret_value;
   END APPROVAL_STATE;
   FUNCTION RECORD_STATUS(
      P_SOURCE_ID IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_T_BASIS_LANGUAGE_SOURCE.RECORD_STATUS      (
         P_SOURCE_ID );
         RETURN ret_value;
   END RECORD_STATUS;
   FUNCTION SOURCE_TEXT(
      P_SOURCE_ID IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_T_BASIS_LANGUAGE_SOURCE.SOURCE_TEXT      (
         P_SOURCE_ID );
         RETURN ret_value;
   END SOURCE_TEXT;
   FUNCTION APPROVAL_DATE(
      P_SOURCE_ID IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_T_BASIS_LANGUAGE_SOURCE.APPROVAL_DATE      (
         P_SOURCE_ID );
         RETURN ret_value;
   END APPROVAL_DATE;
   FUNCTION ROW_BY_PK(
      P_SOURCE_ID IN NUMBER)
      RETURN REC_ROW_BY_PK
   IS
      ret_value    REC_ROW_BY_PK ;
   BEGIN
      ret_value := EC_T_BASIS_LANGUAGE_SOURCE.ROW_BY_PK      (
         P_SOURCE_ID );
         RETURN ret_value;
   END ROW_BY_PK;
   FUNCTION REC_ID(
      P_SOURCE_ID IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_T_BASIS_LANGUAGE_SOURCE.REC_ID      (
         P_SOURCE_ID );
         RETURN ret_value;
   END REC_ID;

END RP_T_BASIS_LANGUAGE_SOURCE;

/
--GRANT EXECUTE ON ECKERNEL_WST.RP_T_BASIS_LANGUAGE_SOURCE TO REPORT_ROLE_XXX;



 -- FINISH PKG_GEN_PKGS.sf_get_functions at:11/15/2018 07.16.26 AM


