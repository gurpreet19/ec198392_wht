
 -- START PKG_GEN_PKGS.sf_get_functions at:05/07/2019 07.33.26 AM


CREATE or REPLACE PACKAGE RP_STAT_PROCESS_ROLE
IS

   FUNCTION APPROVAL_BY(
      P_PROCESS_ID IN VARCHAR2,
      P_ROLE_ID IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_STATE(
      P_PROCESS_ID IN VARCHAR2,
      P_ROLE_ID IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION RECORD_STATUS(
      P_PROCESS_ID IN VARCHAR2,
      P_ROLE_ID IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_DATE(
      P_PROCESS_ID IN VARCHAR2,
      P_ROLE_ID IN VARCHAR2)
      RETURN DATE;
      TYPE REC_ROW_BY_PK IS RECORD (
         PROCESS_ID VARCHAR2 (16) ,
         ROLE_ID VARCHAR2 (30) ,
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
      P_PROCESS_ID IN VARCHAR2,
      P_ROLE_ID IN VARCHAR2)
      RETURN REC_ROW_BY_PK;
   FUNCTION REC_ID(
      P_PROCESS_ID IN VARCHAR2,
      P_ROLE_ID IN VARCHAR2)
      RETURN VARCHAR2;

END RP_STAT_PROCESS_ROLE;

/



CREATE or REPLACE PACKAGE BODY RP_STAT_PROCESS_ROLE
IS

   FUNCTION APPROVAL_BY(
      P_PROCESS_ID IN VARCHAR2,
      P_ROLE_ID IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (30) ;
   BEGIN
      ret_value := EC_STAT_PROCESS_ROLE.APPROVAL_BY      (
         P_PROCESS_ID,
         P_ROLE_ID );
         RETURN ret_value;
   END APPROVAL_BY;
   FUNCTION APPROVAL_STATE(
      P_PROCESS_ID IN VARCHAR2,
      P_ROLE_ID IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_STAT_PROCESS_ROLE.APPROVAL_STATE      (
         P_PROCESS_ID,
         P_ROLE_ID );
         RETURN ret_value;
   END APPROVAL_STATE;
   FUNCTION RECORD_STATUS(
      P_PROCESS_ID IN VARCHAR2,
      P_ROLE_ID IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_STAT_PROCESS_ROLE.RECORD_STATUS      (
         P_PROCESS_ID,
         P_ROLE_ID );
         RETURN ret_value;
   END RECORD_STATUS;
   FUNCTION APPROVAL_DATE(
      P_PROCESS_ID IN VARCHAR2,
      P_ROLE_ID IN VARCHAR2)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_STAT_PROCESS_ROLE.APPROVAL_DATE      (
         P_PROCESS_ID,
         P_ROLE_ID );
         RETURN ret_value;
   END APPROVAL_DATE;
   FUNCTION ROW_BY_PK(
      P_PROCESS_ID IN VARCHAR2,
      P_ROLE_ID IN VARCHAR2)
      RETURN REC_ROW_BY_PK
   IS
      ret_value    REC_ROW_BY_PK ;
   BEGIN
      ret_value := EC_STAT_PROCESS_ROLE.ROW_BY_PK      (
         P_PROCESS_ID,
         P_ROLE_ID );
         RETURN ret_value;
   END ROW_BY_PK;
   FUNCTION REC_ID(
      P_PROCESS_ID IN VARCHAR2,
      P_ROLE_ID IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_STAT_PROCESS_ROLE.REC_ID      (
         P_PROCESS_ID,
         P_ROLE_ID );
         RETURN ret_value;
   END REC_ID;

END RP_STAT_PROCESS_ROLE;

/
--GRANT EXECUTE ON ECKERNEL_WST.RP_STAT_PROCESS_ROLE TO REPORT_ROLE_XXX;



 -- FINISH PKG_GEN_PKGS.sf_get_functions at:05/07/2019 07.33.29 AM


