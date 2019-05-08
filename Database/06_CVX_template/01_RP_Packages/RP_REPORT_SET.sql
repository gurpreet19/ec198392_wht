
 -- START PKG_GEN_PKGS.sf_get_functions at:05/07/2019 07.43.30 AM


CREATE or REPLACE PACKAGE RP_REPORT_SET
IS

   FUNCTION UPDATED_DATE(
      P_REPORT_SET_NO IN NUMBER)
      RETURN DATE;
   FUNCTION APPROVAL_BY(
      P_REPORT_SET_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_STATE(
      P_REPORT_SET_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION FUNCTIONAL_AREA_ID(
      P_REPORT_SET_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION RECORD_STATUS(
      P_REPORT_SET_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_DATE(
      P_REPORT_SET_NO IN NUMBER)
      RETURN DATE;
   FUNCTION NAME(
      P_REPORT_SET_NO IN NUMBER)
      RETURN VARCHAR2;
      TYPE REC_ROW_BY_PK IS RECORD (
         REPORT_SET_NO NUMBER ,
         NAME VARCHAR2 (240) ,
         FUNCTIONAL_AREA_ID VARCHAR2 (32) ,
         RECORD_STATUS VARCHAR2 (1) ,
         CREATED_BY VARCHAR2 (30) ,
         CREATED_DATE  DATE ,
         UPDATED_BY VARCHAR2 (30) ,
         UPDATED_DATE  DATE ,
         LAST_UPDATED_BY VARCHAR2 (30) ,
         LAST_UPDATED_DATE  DATE ,
         REV_NO NUMBER ,
         REV_TEXT VARCHAR2 (2000) ,
         APPROVAL_BY VARCHAR2 (30) ,
         APPROVAL_DATE  DATE ,
         APPROVAL_STATE VARCHAR2 (1) ,
         REC_ID VARCHAR2 (32)  );
   FUNCTION ROW_BY_PK(
      P_REPORT_SET_NO IN NUMBER)
      RETURN REC_ROW_BY_PK;
   FUNCTION UPDATED_BY(
      P_REPORT_SET_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION REC_ID(
      P_REPORT_SET_NO IN NUMBER)
      RETURN VARCHAR2;

END RP_REPORT_SET;

/



CREATE or REPLACE PACKAGE BODY RP_REPORT_SET
IS

   FUNCTION UPDATED_DATE(
      P_REPORT_SET_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_REPORT_SET.UPDATED_DATE      (
         P_REPORT_SET_NO );
         RETURN ret_value;
   END UPDATED_DATE;
   FUNCTION APPROVAL_BY(
      P_REPORT_SET_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (30) ;
   BEGIN
      ret_value := EC_REPORT_SET.APPROVAL_BY      (
         P_REPORT_SET_NO );
         RETURN ret_value;
   END APPROVAL_BY;
   FUNCTION APPROVAL_STATE(
      P_REPORT_SET_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_REPORT_SET.APPROVAL_STATE      (
         P_REPORT_SET_NO );
         RETURN ret_value;
   END APPROVAL_STATE;
   FUNCTION FUNCTIONAL_AREA_ID(
      P_REPORT_SET_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_REPORT_SET.FUNCTIONAL_AREA_ID      (
         P_REPORT_SET_NO );
         RETURN ret_value;
   END FUNCTIONAL_AREA_ID;
   FUNCTION RECORD_STATUS(
      P_REPORT_SET_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_REPORT_SET.RECORD_STATUS      (
         P_REPORT_SET_NO );
         RETURN ret_value;
   END RECORD_STATUS;
   FUNCTION APPROVAL_DATE(
      P_REPORT_SET_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_REPORT_SET.APPROVAL_DATE      (
         P_REPORT_SET_NO );
         RETURN ret_value;
   END APPROVAL_DATE;
   FUNCTION NAME(
      P_REPORT_SET_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_REPORT_SET.NAME      (
         P_REPORT_SET_NO );
         RETURN ret_value;
   END NAME;
   FUNCTION ROW_BY_PK(
      P_REPORT_SET_NO IN NUMBER)
      RETURN REC_ROW_BY_PK
   IS
      ret_value    REC_ROW_BY_PK ;
   BEGIN
      ret_value := EC_REPORT_SET.ROW_BY_PK      (
         P_REPORT_SET_NO );
         RETURN ret_value;
   END ROW_BY_PK;
   FUNCTION UPDATED_BY(
      P_REPORT_SET_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (30) ;
   BEGIN
      ret_value := EC_REPORT_SET.UPDATED_BY      (
         P_REPORT_SET_NO );
         RETURN ret_value;
   END UPDATED_BY;
   FUNCTION REC_ID(
      P_REPORT_SET_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_REPORT_SET.REC_ID      (
         P_REPORT_SET_NO );
         RETURN ret_value;
   END REC_ID;

END RP_REPORT_SET;

/
--GRANT EXECUTE ON ECKERNEL_WST.RP_REPORT_SET TO REPORT_ROLE_XXX;



 -- FINISH PKG_GEN_PKGS.sf_get_functions at:05/07/2019 07.43.35 AM


