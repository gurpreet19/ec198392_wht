
 -- START PKG_GEN_PKGS.sf_get_functions at:11/15/2018 07.20.59 AM


CREATE or REPLACE PACKAGE RP_TRANS_DTO_STORAGE
IS

   FUNCTION APPROVAL_BY(
      P_DTO_ID IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_STATE(
      P_DTO_ID IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION DTO(
      P_DTO_ID IN VARCHAR2)
      RETURN BLOB;
   FUNCTION RECORD_STATUS(
      P_DTO_ID IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION STATUS(
      P_DTO_ID IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_DATE(
      P_DTO_ID IN VARCHAR2)
      RETURN DATE;
      TYPE REC_ROW_BY_PK IS RECORD (
         DTO_ID VARCHAR2 (255) ,
         DTO  BLOB ,
         STATUS VARCHAR2 (255) ,
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
      P_DTO_ID IN VARCHAR2)
      RETURN REC_ROW_BY_PK;
   FUNCTION REC_ID(
      P_DTO_ID IN VARCHAR2)
      RETURN VARCHAR2;

END RP_TRANS_DTO_STORAGE;

/



CREATE or REPLACE PACKAGE BODY RP_TRANS_DTO_STORAGE
IS

   FUNCTION APPROVAL_BY(
      P_DTO_ID IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (30) ;
   BEGIN
      ret_value := EC_TRANS_DTO_STORAGE.APPROVAL_BY      (
         P_DTO_ID );
         RETURN ret_value;
   END APPROVAL_BY;
   FUNCTION APPROVAL_STATE(
      P_DTO_ID IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_TRANS_DTO_STORAGE.APPROVAL_STATE      (
         P_DTO_ID );
         RETURN ret_value;
   END APPROVAL_STATE;
   FUNCTION DTO(
      P_DTO_ID IN VARCHAR2)
      RETURN BLOB
   IS
      ret_value    BLOB ;
   BEGIN
      ret_value := EC_TRANS_DTO_STORAGE.DTO      (
         P_DTO_ID );
         RETURN ret_value;
   END DTO;
   FUNCTION RECORD_STATUS(
      P_DTO_ID IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_TRANS_DTO_STORAGE.RECORD_STATUS      (
         P_DTO_ID );
         RETURN ret_value;
   END RECORD_STATUS;
   FUNCTION STATUS(
      P_DTO_ID IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (255) ;
   BEGIN
      ret_value := EC_TRANS_DTO_STORAGE.STATUS      (
         P_DTO_ID );
         RETURN ret_value;
   END STATUS;
   FUNCTION APPROVAL_DATE(
      P_DTO_ID IN VARCHAR2)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_TRANS_DTO_STORAGE.APPROVAL_DATE      (
         P_DTO_ID );
         RETURN ret_value;
   END APPROVAL_DATE;
   FUNCTION ROW_BY_PK(
      P_DTO_ID IN VARCHAR2)
      RETURN REC_ROW_BY_PK
   IS
      ret_value    REC_ROW_BY_PK ;
   BEGIN
      ret_value := EC_TRANS_DTO_STORAGE.ROW_BY_PK      (
         P_DTO_ID );
         RETURN ret_value;
   END ROW_BY_PK;
   FUNCTION REC_ID(
      P_DTO_ID IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_TRANS_DTO_STORAGE.REC_ID      (
         P_DTO_ID );
         RETURN ret_value;
   END REC_ID;

END RP_TRANS_DTO_STORAGE;

/
--GRANT EXECUTE ON ECKERNEL_WST.RP_TRANS_DTO_STORAGE TO REPORT_ROLE_XXX;



 -- FINISH PKG_GEN_PKGS.sf_get_functions at:11/15/2018 07.21.02 AM


