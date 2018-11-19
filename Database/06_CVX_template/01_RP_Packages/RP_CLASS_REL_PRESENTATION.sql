
 -- START PKG_GEN_PKGS.sf_get_functions at:11/15/2018 10.43.56 AM


CREATE or REPLACE PACKAGE RP_CLASS_REL_PRESENTATION
IS

   FUNCTION APPROVAL_BY(
      P_FROM_CLASS_NAME IN VARCHAR2,
      P_TO_CLASS_NAME IN VARCHAR2,
      P_ROLE_NAME IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_STATE(
      P_FROM_CLASS_NAME IN VARCHAR2,
      P_TO_CLASS_NAME IN VARCHAR2,
      P_ROLE_NAME IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION STATIC_PRESENTATION_SYNTAX(
      P_FROM_CLASS_NAME IN VARCHAR2,
      P_TO_CLASS_NAME IN VARCHAR2,
      P_ROLE_NAME IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION DB_PRES_SYNTAX(
      P_FROM_CLASS_NAME IN VARCHAR2,
      P_TO_CLASS_NAME IN VARCHAR2,
      P_ROLE_NAME IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION RECORD_STATUS(
      P_FROM_CLASS_NAME IN VARCHAR2,
      P_TO_CLASS_NAME IN VARCHAR2,
      P_ROLE_NAME IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_DATE(
      P_FROM_CLASS_NAME IN VARCHAR2,
      P_TO_CLASS_NAME IN VARCHAR2,
      P_ROLE_NAME IN VARCHAR2)
      RETURN DATE;
   FUNCTION PRESENTATION_SYNTAX(
      P_FROM_CLASS_NAME IN VARCHAR2,
      P_TO_CLASS_NAME IN VARCHAR2,
      P_ROLE_NAME IN VARCHAR2)
      RETURN VARCHAR2;
      TYPE REC_ROW_BY_PK IS RECORD (
         FROM_CLASS_NAME VARCHAR2 (24) ,
         TO_CLASS_NAME VARCHAR2 (24) ,
         ROLE_NAME VARCHAR2 (24) ,
         STATIC_PRESENTATION_SYNTAX VARCHAR2 (4000) ,
         PRESENTATION_SYNTAX VARCHAR2 (4000) ,
         DB_PRES_SYNTAX VARCHAR2 (4000) ,
         LABEL VARCHAR2 (64) ,
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
      P_FROM_CLASS_NAME IN VARCHAR2,
      P_TO_CLASS_NAME IN VARCHAR2,
      P_ROLE_NAME IN VARCHAR2)
      RETURN REC_ROW_BY_PK;
   FUNCTION REC_ID(
      P_FROM_CLASS_NAME IN VARCHAR2,
      P_TO_CLASS_NAME IN VARCHAR2,
      P_ROLE_NAME IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION LABEL(
      P_FROM_CLASS_NAME IN VARCHAR2,
      P_TO_CLASS_NAME IN VARCHAR2,
      P_ROLE_NAME IN VARCHAR2)
      RETURN VARCHAR2;

END RP_CLASS_REL_PRESENTATION;

/



CREATE or REPLACE PACKAGE BODY RP_CLASS_REL_PRESENTATION
IS

   FUNCTION APPROVAL_BY(
      P_FROM_CLASS_NAME IN VARCHAR2,
      P_TO_CLASS_NAME IN VARCHAR2,
      P_ROLE_NAME IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (30) ;
   BEGIN
      ret_value := EC_CLASS_REL_PRESENTATION.APPROVAL_BY      (
         P_FROM_CLASS_NAME,
         P_TO_CLASS_NAME,
         P_ROLE_NAME );
         RETURN ret_value;
   END APPROVAL_BY;
   FUNCTION APPROVAL_STATE(
      P_FROM_CLASS_NAME IN VARCHAR2,
      P_TO_CLASS_NAME IN VARCHAR2,
      P_ROLE_NAME IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_CLASS_REL_PRESENTATION.APPROVAL_STATE      (
         P_FROM_CLASS_NAME,
         P_TO_CLASS_NAME,
         P_ROLE_NAME );
         RETURN ret_value;
   END APPROVAL_STATE;
   FUNCTION STATIC_PRESENTATION_SYNTAX(
      P_FROM_CLASS_NAME IN VARCHAR2,
      P_TO_CLASS_NAME IN VARCHAR2,
      P_ROLE_NAME IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (4000) ;
   BEGIN
      ret_value := EC_CLASS_REL_PRESENTATION.STATIC_PRESENTATION_SYNTAX      (
         P_FROM_CLASS_NAME,
         P_TO_CLASS_NAME,
         P_ROLE_NAME );
         RETURN ret_value;
   END STATIC_PRESENTATION_SYNTAX;
   FUNCTION DB_PRES_SYNTAX(
      P_FROM_CLASS_NAME IN VARCHAR2,
      P_TO_CLASS_NAME IN VARCHAR2,
      P_ROLE_NAME IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (4000) ;
   BEGIN
      ret_value := EC_CLASS_REL_PRESENTATION.DB_PRES_SYNTAX      (
         P_FROM_CLASS_NAME,
         P_TO_CLASS_NAME,
         P_ROLE_NAME );
         RETURN ret_value;
   END DB_PRES_SYNTAX;
   FUNCTION RECORD_STATUS(
      P_FROM_CLASS_NAME IN VARCHAR2,
      P_TO_CLASS_NAME IN VARCHAR2,
      P_ROLE_NAME IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_CLASS_REL_PRESENTATION.RECORD_STATUS      (
         P_FROM_CLASS_NAME,
         P_TO_CLASS_NAME,
         P_ROLE_NAME );
         RETURN ret_value;
   END RECORD_STATUS;
   FUNCTION APPROVAL_DATE(
      P_FROM_CLASS_NAME IN VARCHAR2,
      P_TO_CLASS_NAME IN VARCHAR2,
      P_ROLE_NAME IN VARCHAR2)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CLASS_REL_PRESENTATION.APPROVAL_DATE      (
         P_FROM_CLASS_NAME,
         P_TO_CLASS_NAME,
         P_ROLE_NAME );
         RETURN ret_value;
   END APPROVAL_DATE;
   FUNCTION PRESENTATION_SYNTAX(
      P_FROM_CLASS_NAME IN VARCHAR2,
      P_TO_CLASS_NAME IN VARCHAR2,
      P_ROLE_NAME IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (4000) ;
   BEGIN
      ret_value := EC_CLASS_REL_PRESENTATION.PRESENTATION_SYNTAX      (
         P_FROM_CLASS_NAME,
         P_TO_CLASS_NAME,
         P_ROLE_NAME );
         RETURN ret_value;
   END PRESENTATION_SYNTAX;
   FUNCTION ROW_BY_PK(
      P_FROM_CLASS_NAME IN VARCHAR2,
      P_TO_CLASS_NAME IN VARCHAR2,
      P_ROLE_NAME IN VARCHAR2)
      RETURN REC_ROW_BY_PK
   IS
      ret_value    REC_ROW_BY_PK ;
   BEGIN
      ret_value := EC_CLASS_REL_PRESENTATION.ROW_BY_PK      (
         P_FROM_CLASS_NAME,
         P_TO_CLASS_NAME,
         P_ROLE_NAME );
         RETURN ret_value;
   END ROW_BY_PK;
   FUNCTION REC_ID(
      P_FROM_CLASS_NAME IN VARCHAR2,
      P_TO_CLASS_NAME IN VARCHAR2,
      P_ROLE_NAME IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_CLASS_REL_PRESENTATION.REC_ID      (
         P_FROM_CLASS_NAME,
         P_TO_CLASS_NAME,
         P_ROLE_NAME );
         RETURN ret_value;
   END REC_ID;
   FUNCTION LABEL(
      P_FROM_CLASS_NAME IN VARCHAR2,
      P_TO_CLASS_NAME IN VARCHAR2,
      P_ROLE_NAME IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (64) ;
   BEGIN
      ret_value := EC_CLASS_REL_PRESENTATION.LABEL      (
         P_FROM_CLASS_NAME,
         P_TO_CLASS_NAME,
         P_ROLE_NAME );
         RETURN ret_value;
   END LABEL;

END RP_CLASS_REL_PRESENTATION;

/
--GRANT EXECUTE ON ECKERNEL_WST.RP_CLASS_REL_PRESENTATION TO REPORT_ROLE_XXX;



 -- FINISH PKG_GEN_PKGS.sf_get_functions at:11/15/2018 10.43.58 AM


