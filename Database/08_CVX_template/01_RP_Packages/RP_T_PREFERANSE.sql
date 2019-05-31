
 -- START PKG_GEN_PKGS.sf_get_functions at:05/07/2019 05.26.49 AM


CREATE or REPLACE PACKAGE RP_T_PREFERANSE
IS

   FUNCTION APPROVAL_BY(
      P_PREF_ID IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_STATE(
      P_PREF_ID IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION PREF_VERDI(
      P_PREF_ID IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION RECORD_STATUS(
      P_PREF_ID IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_DATE(
      P_PREF_ID IN VARCHAR2)
      RETURN DATE;
      TYPE REC_ROW_BY_PK IS RECORD (
         PREF_ID VARCHAR2 (16) ,
         PREF_VERDI VARCHAR2 (100) ,
         PREF_BESKR VARCHAR2 (240) ,
         BRUKER_IND VARCHAR2 (1) ,
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
      P_PREF_ID IN VARCHAR2)
      RETURN REC_ROW_BY_PK;
   FUNCTION PREF_BESKR(
      P_PREF_ID IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION REC_ID(
      P_PREF_ID IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION BRUKER_IND(
      P_PREF_ID IN VARCHAR2)
      RETURN VARCHAR2;

END RP_T_PREFERANSE;

/



CREATE or REPLACE PACKAGE BODY RP_T_PREFERANSE
IS

   FUNCTION APPROVAL_BY(
      P_PREF_ID IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (30) ;
   BEGIN
      ret_value := EC_T_PREFERANSE.APPROVAL_BY      (
         P_PREF_ID );
         RETURN ret_value;
   END APPROVAL_BY;
   FUNCTION APPROVAL_STATE(
      P_PREF_ID IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_T_PREFERANSE.APPROVAL_STATE      (
         P_PREF_ID );
         RETURN ret_value;
   END APPROVAL_STATE;
   FUNCTION PREF_VERDI(
      P_PREF_ID IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (100) ;
   BEGIN
      ret_value := EC_T_PREFERANSE.PREF_VERDI      (
         P_PREF_ID );
         RETURN ret_value;
   END PREF_VERDI;
   FUNCTION RECORD_STATUS(
      P_PREF_ID IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_T_PREFERANSE.RECORD_STATUS      (
         P_PREF_ID );
         RETURN ret_value;
   END RECORD_STATUS;
   FUNCTION APPROVAL_DATE(
      P_PREF_ID IN VARCHAR2)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_T_PREFERANSE.APPROVAL_DATE      (
         P_PREF_ID );
         RETURN ret_value;
   END APPROVAL_DATE;
   FUNCTION ROW_BY_PK(
      P_PREF_ID IN VARCHAR2)
      RETURN REC_ROW_BY_PK
   IS
      ret_value    REC_ROW_BY_PK ;
   BEGIN
      ret_value := EC_T_PREFERANSE.ROW_BY_PK      (
         P_PREF_ID );
         RETURN ret_value;
   END ROW_BY_PK;
   FUNCTION PREF_BESKR(
      P_PREF_ID IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_T_PREFERANSE.PREF_BESKR      (
         P_PREF_ID );
         RETURN ret_value;
   END PREF_BESKR;
   FUNCTION REC_ID(
      P_PREF_ID IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_T_PREFERANSE.REC_ID      (
         P_PREF_ID );
         RETURN ret_value;
   END REC_ID;
   FUNCTION BRUKER_IND(
      P_PREF_ID IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_T_PREFERANSE.BRUKER_IND      (
         P_PREF_ID );
         RETURN ret_value;
   END BRUKER_IND;

END RP_T_PREFERANSE;

/
--GRANT EXECUTE ON ECKERNEL_WST.RP_T_PREFERANSE TO REPORT_ROLE_XXX;



 -- FINISH PKG_GEN_PKGS.sf_get_functions at:05/07/2019 05.26.51 AM


