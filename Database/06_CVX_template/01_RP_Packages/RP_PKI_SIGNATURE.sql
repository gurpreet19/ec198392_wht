
 -- START PKG_GEN_PKGS.sf_get_functions at:11/15/2018 08.26.12 AM


CREATE or REPLACE PACKAGE RP_PKI_SIGNATURE
IS

   FUNCTION SIGNED_DOCUMENT(
      P_SIGN_ID IN VARCHAR2)
      RETURN CLOB;
   FUNCTION APPROVAL_BY(
      P_SIGN_ID IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_STATE(
      P_SIGN_ID IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION SCR_ID(
      P_SIGN_ID IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION SIGN_LAST_VERIFIED(
      P_SIGN_ID IN VARCHAR2)
      RETURN DATE;
   FUNCTION COMP_ID(
      P_SIGN_ID IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION RECORD_STATUS(
      P_SIGN_ID IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_DATE(
      P_SIGN_ID IN VARCHAR2)
      RETURN DATE;
      TYPE REC_ROW_BY_PK IS RECORD (
         SIGN_ID VARCHAR2 (32) ,
         COMP_ID VARCHAR2 (1000) ,
         SCR_ID VARCHAR2 (250) ,
         DOCUMENT  CLOB ,
         SIGNED_DOCUMENT  CLOB ,
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
         SIGN_IS_VALID_IND VARCHAR2 (1) ,
         SIGN_LAST_VERIFIED  DATE  );
   FUNCTION ROW_BY_PK(
      P_SIGN_ID IN VARCHAR2)
      RETURN REC_ROW_BY_PK;
   FUNCTION REC_ID(
      P_SIGN_ID IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION SIGN_IS_VALID_IND(
      P_SIGN_ID IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION DOCUMENT(
      P_SIGN_ID IN VARCHAR2)
      RETURN CLOB;

END RP_PKI_SIGNATURE;

/



CREATE or REPLACE PACKAGE BODY RP_PKI_SIGNATURE
IS

   FUNCTION SIGNED_DOCUMENT(
      P_SIGN_ID IN VARCHAR2)
      RETURN CLOB
   IS
      ret_value    CLOB ;
   BEGIN
      ret_value := EC_PKI_SIGNATURE.SIGNED_DOCUMENT      (
         P_SIGN_ID );
         RETURN ret_value;
   END SIGNED_DOCUMENT;
   FUNCTION APPROVAL_BY(
      P_SIGN_ID IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (30) ;
   BEGIN
      ret_value := EC_PKI_SIGNATURE.APPROVAL_BY      (
         P_SIGN_ID );
         RETURN ret_value;
   END APPROVAL_BY;
   FUNCTION APPROVAL_STATE(
      P_SIGN_ID IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_PKI_SIGNATURE.APPROVAL_STATE      (
         P_SIGN_ID );
         RETURN ret_value;
   END APPROVAL_STATE;
   FUNCTION SCR_ID(
      P_SIGN_ID IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (250) ;
   BEGIN
      ret_value := EC_PKI_SIGNATURE.SCR_ID      (
         P_SIGN_ID );
         RETURN ret_value;
   END SCR_ID;
   FUNCTION SIGN_LAST_VERIFIED(
      P_SIGN_ID IN VARCHAR2)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_PKI_SIGNATURE.SIGN_LAST_VERIFIED      (
         P_SIGN_ID );
         RETURN ret_value;
   END SIGN_LAST_VERIFIED;
   FUNCTION COMP_ID(
      P_SIGN_ID IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1000) ;
   BEGIN
      ret_value := EC_PKI_SIGNATURE.COMP_ID      (
         P_SIGN_ID );
         RETURN ret_value;
   END COMP_ID;
   FUNCTION RECORD_STATUS(
      P_SIGN_ID IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_PKI_SIGNATURE.RECORD_STATUS      (
         P_SIGN_ID );
         RETURN ret_value;
   END RECORD_STATUS;
   FUNCTION APPROVAL_DATE(
      P_SIGN_ID IN VARCHAR2)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_PKI_SIGNATURE.APPROVAL_DATE      (
         P_SIGN_ID );
         RETURN ret_value;
   END APPROVAL_DATE;
   FUNCTION ROW_BY_PK(
      P_SIGN_ID IN VARCHAR2)
      RETURN REC_ROW_BY_PK
   IS
      ret_value    REC_ROW_BY_PK ;
   BEGIN
      ret_value := EC_PKI_SIGNATURE.ROW_BY_PK      (
         P_SIGN_ID );
         RETURN ret_value;
   END ROW_BY_PK;
   FUNCTION REC_ID(
      P_SIGN_ID IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_PKI_SIGNATURE.REC_ID      (
         P_SIGN_ID );
         RETURN ret_value;
   END REC_ID;
   FUNCTION SIGN_IS_VALID_IND(
      P_SIGN_ID IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_PKI_SIGNATURE.SIGN_IS_VALID_IND      (
         P_SIGN_ID );
         RETURN ret_value;
   END SIGN_IS_VALID_IND;
   FUNCTION DOCUMENT(
      P_SIGN_ID IN VARCHAR2)
      RETURN CLOB
   IS
      ret_value    CLOB ;
   BEGIN
      ret_value := EC_PKI_SIGNATURE.DOCUMENT      (
         P_SIGN_ID );
         RETURN ret_value;
   END DOCUMENT;

END RP_PKI_SIGNATURE;

/
--GRANT EXECUTE ON ECKERNEL_WST.RP_PKI_SIGNATURE TO REPORT_ROLE_XXX;



 -- FINISH PKG_GEN_PKGS.sf_get_functions at:11/15/2018 08.26.15 AM


