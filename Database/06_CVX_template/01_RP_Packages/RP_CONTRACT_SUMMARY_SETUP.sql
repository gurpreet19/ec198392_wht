
 -- START PKG_GEN_PKGS.sf_get_functions at:05/07/2019 10.40.51 AM


CREATE or REPLACE PACKAGE RP_CONTRACT_SUMMARY_SETUP
IS

   FUNCTION APPROVAL_BY(
      P_OBJECT_ID IN VARCHAR2,
      P_SUMMARY_SETUP_ID IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_STATE(
      P_OBJECT_ID IN VARCHAR2,
      P_SUMMARY_SETUP_ID IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION COMMENTS(
      P_OBJECT_ID IN VARCHAR2,
      P_SUMMARY_SETUP_ID IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION RECORD_STATUS(
      P_OBJECT_ID IN VARCHAR2,
      P_SUMMARY_SETUP_ID IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_DATE(
      P_OBJECT_ID IN VARCHAR2,
      P_SUMMARY_SETUP_ID IN VARCHAR2)
      RETURN DATE;
      TYPE REC_ROW_BY_PK IS RECORD (
         OBJECT_ID VARCHAR2 (32) ,
         SUMMARY_SETUP_ID VARCHAR2 (32) ,
         COMMENTS VARCHAR2 (2000) ,
         RECORD_STATUS VARCHAR2 (1) ,
         CREATED_BY VARCHAR2 (30) ,
         CREATED_DATE  DATE ,
         LAST_UPDATED_BY VARCHAR2 (30) ,
         LAST_UPDATED_DATE  DATE ,
         REV_NO NUMBER ,
         REV_TEXT VARCHAR2 (2000) ,
         APPROVAL_BY VARCHAR2 (30) ,
         APPROVAL_DATE  DATE ,
         APPROVAL_STATE VARCHAR2 (1) ,
         REC_ID VARCHAR2 (32)  );
   FUNCTION ROW_BY_PK(
      P_OBJECT_ID IN VARCHAR2,
      P_SUMMARY_SETUP_ID IN VARCHAR2)
      RETURN REC_ROW_BY_PK;
   FUNCTION REC_ID(
      P_OBJECT_ID IN VARCHAR2,
      P_SUMMARY_SETUP_ID IN VARCHAR2)
      RETURN VARCHAR2;

END RP_CONTRACT_SUMMARY_SETUP;

/



CREATE or REPLACE PACKAGE BODY RP_CONTRACT_SUMMARY_SETUP
IS

   FUNCTION APPROVAL_BY(
      P_OBJECT_ID IN VARCHAR2,
      P_SUMMARY_SETUP_ID IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (30) ;
   BEGIN
      ret_value := EC_CONTRACT_SUMMARY_SETUP.APPROVAL_BY      (
         P_OBJECT_ID,
         P_SUMMARY_SETUP_ID );
         RETURN ret_value;
   END APPROVAL_BY;
   FUNCTION APPROVAL_STATE(
      P_OBJECT_ID IN VARCHAR2,
      P_SUMMARY_SETUP_ID IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_CONTRACT_SUMMARY_SETUP.APPROVAL_STATE      (
         P_OBJECT_ID,
         P_SUMMARY_SETUP_ID );
         RETURN ret_value;
   END APPROVAL_STATE;
   FUNCTION COMMENTS(
      P_OBJECT_ID IN VARCHAR2,
      P_SUMMARY_SETUP_ID IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_CONTRACT_SUMMARY_SETUP.COMMENTS      (
         P_OBJECT_ID,
         P_SUMMARY_SETUP_ID );
         RETURN ret_value;
   END COMMENTS;
   FUNCTION RECORD_STATUS(
      P_OBJECT_ID IN VARCHAR2,
      P_SUMMARY_SETUP_ID IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_CONTRACT_SUMMARY_SETUP.RECORD_STATUS      (
         P_OBJECT_ID,
         P_SUMMARY_SETUP_ID );
         RETURN ret_value;
   END RECORD_STATUS;
   FUNCTION APPROVAL_DATE(
      P_OBJECT_ID IN VARCHAR2,
      P_SUMMARY_SETUP_ID IN VARCHAR2)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CONTRACT_SUMMARY_SETUP.APPROVAL_DATE      (
         P_OBJECT_ID,
         P_SUMMARY_SETUP_ID );
         RETURN ret_value;
   END APPROVAL_DATE;
   FUNCTION ROW_BY_PK(
      P_OBJECT_ID IN VARCHAR2,
      P_SUMMARY_SETUP_ID IN VARCHAR2)
      RETURN REC_ROW_BY_PK
   IS
      ret_value    REC_ROW_BY_PK ;
   BEGIN
      ret_value := EC_CONTRACT_SUMMARY_SETUP.ROW_BY_PK      (
         P_OBJECT_ID,
         P_SUMMARY_SETUP_ID );
         RETURN ret_value;
   END ROW_BY_PK;
   FUNCTION REC_ID(
      P_OBJECT_ID IN VARCHAR2,
      P_SUMMARY_SETUP_ID IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_CONTRACT_SUMMARY_SETUP.REC_ID      (
         P_OBJECT_ID,
         P_SUMMARY_SETUP_ID );
         RETURN ret_value;
   END REC_ID;

END RP_CONTRACT_SUMMARY_SETUP;

/
--GRANT EXECUTE ON ECKERNEL_WST.RP_CONTRACT_SUMMARY_SETUP TO REPORT_ROLE_XXX;



 -- FINISH PKG_GEN_PKGS.sf_get_functions at:05/07/2019 10.40.53 AM


