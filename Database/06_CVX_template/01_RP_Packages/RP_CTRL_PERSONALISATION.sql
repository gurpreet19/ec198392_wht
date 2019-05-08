
 -- START PKG_GEN_PKGS.sf_get_functions at:05/07/2019 10.33.23 AM


CREATE or REPLACE PACKAGE RP_CTRL_PERSONALISATION
IS

   FUNCTION PRES_CLOB_VALUE(
      P_PRES_NO IN NUMBER)
      RETURN CLOB;
   FUNCTION USER_ID(
      P_PRES_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_BY(
      P_PRES_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_STATE(
      P_PRES_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION PRES_FORMAT(
      P_PRES_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION PRES_KEY(
      P_PRES_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION RECORD_STATUS(
      P_PRES_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_DATE(
      P_PRES_NO IN NUMBER)
      RETURN DATE;
      TYPE REC_ROW_BY_PK IS RECORD (
         PRES_NO NUMBER ,
         PRES_KEY VARCHAR2 (2000) ,
         USER_ID VARCHAR2 (30) ,
         PROFILE_CODE VARCHAR2 (255) ,
         PRES_CLOB_VALUE  CLOB ,
         PRES_FORMAT VARCHAR2 (32) ,
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
      P_PRES_NO IN NUMBER)
      RETURN REC_ROW_BY_PK;
   FUNCTION REC_ID(
      P_PRES_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION PROFILE_CODE(
      P_PRES_NO IN NUMBER)
      RETURN VARCHAR2;

END RP_CTRL_PERSONALISATION;

/



CREATE or REPLACE PACKAGE BODY RP_CTRL_PERSONALISATION
IS

   FUNCTION PRES_CLOB_VALUE(
      P_PRES_NO IN NUMBER)
      RETURN CLOB
   IS
      ret_value    CLOB ;
   BEGIN
      ret_value := EC_CTRL_PERSONALISATION.PRES_CLOB_VALUE      (
         P_PRES_NO );
         RETURN ret_value;
   END PRES_CLOB_VALUE;
   FUNCTION USER_ID(
      P_PRES_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (30) ;
   BEGIN
      ret_value := EC_CTRL_PERSONALISATION.USER_ID      (
         P_PRES_NO );
         RETURN ret_value;
   END USER_ID;
   FUNCTION APPROVAL_BY(
      P_PRES_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (30) ;
   BEGIN
      ret_value := EC_CTRL_PERSONALISATION.APPROVAL_BY      (
         P_PRES_NO );
         RETURN ret_value;
   END APPROVAL_BY;
   FUNCTION APPROVAL_STATE(
      P_PRES_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_CTRL_PERSONALISATION.APPROVAL_STATE      (
         P_PRES_NO );
         RETURN ret_value;
   END APPROVAL_STATE;
   FUNCTION PRES_FORMAT(
      P_PRES_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_CTRL_PERSONALISATION.PRES_FORMAT      (
         P_PRES_NO );
         RETURN ret_value;
   END PRES_FORMAT;
   FUNCTION PRES_KEY(
      P_PRES_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_CTRL_PERSONALISATION.PRES_KEY      (
         P_PRES_NO );
         RETURN ret_value;
   END PRES_KEY;
   FUNCTION RECORD_STATUS(
      P_PRES_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_CTRL_PERSONALISATION.RECORD_STATUS      (
         P_PRES_NO );
         RETURN ret_value;
   END RECORD_STATUS;
   FUNCTION APPROVAL_DATE(
      P_PRES_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CTRL_PERSONALISATION.APPROVAL_DATE      (
         P_PRES_NO );
         RETURN ret_value;
   END APPROVAL_DATE;
   FUNCTION ROW_BY_PK(
      P_PRES_NO IN NUMBER)
      RETURN REC_ROW_BY_PK
   IS
      ret_value    REC_ROW_BY_PK ;
   BEGIN
      ret_value := EC_CTRL_PERSONALISATION.ROW_BY_PK      (
         P_PRES_NO );
         RETURN ret_value;
   END ROW_BY_PK;
   FUNCTION REC_ID(
      P_PRES_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_CTRL_PERSONALISATION.REC_ID      (
         P_PRES_NO );
         RETURN ret_value;
   END REC_ID;
   FUNCTION PROFILE_CODE(
      P_PRES_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (255) ;
   BEGIN
      ret_value := EC_CTRL_PERSONALISATION.PROFILE_CODE      (
         P_PRES_NO );
         RETURN ret_value;
   END PROFILE_CODE;

END RP_CTRL_PERSONALISATION;

/
--GRANT EXECUTE ON ECKERNEL_WST.RP_CTRL_PERSONALISATION TO REPORT_ROLE_XXX;



 -- FINISH PKG_GEN_PKGS.sf_get_functions at:05/07/2019 10.33.26 AM


