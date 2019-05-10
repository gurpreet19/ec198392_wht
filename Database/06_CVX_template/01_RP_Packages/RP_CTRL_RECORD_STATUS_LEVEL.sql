
 -- START PKG_GEN_PKGS.sf_get_functions at:05/07/2019 10.33.17 AM


CREATE or REPLACE PACKAGE RP_CTRL_RECORD_STATUS_LEVEL
IS

   FUNCTION APPROVAL_BY(
      P_RECORD_STATUS_LEVEL IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_STATE(
      P_RECORD_STATUS_LEVEL IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION LABEL(
      P_RECORD_STATUS_LEVEL IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION LEVEL_ID(
      P_RECORD_STATUS_LEVEL IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION RECORD_STATUS(
      P_RECORD_STATUS_LEVEL IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_DATE(
      P_RECORD_STATUS_LEVEL IN VARCHAR2)
      RETURN DATE;
      TYPE REC_ROW_BY_PK IS RECORD (
         RECORD_STATUS_LEVEL VARCHAR2 (1) ,
         LABEL VARCHAR2 (16) ,
         LEVEL_ID NUMBER ,
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
      P_RECORD_STATUS_LEVEL IN VARCHAR2)
      RETURN REC_ROW_BY_PK;
   FUNCTION REC_ID(
      P_RECORD_STATUS_LEVEL IN VARCHAR2)
      RETURN VARCHAR2;

END RP_CTRL_RECORD_STATUS_LEVEL;

/



CREATE or REPLACE PACKAGE BODY RP_CTRL_RECORD_STATUS_LEVEL
IS

   FUNCTION APPROVAL_BY(
      P_RECORD_STATUS_LEVEL IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (30) ;
   BEGIN
      ret_value := EC_CTRL_RECORD_STATUS_LEVEL.APPROVAL_BY      (
         P_RECORD_STATUS_LEVEL );
         RETURN ret_value;
   END APPROVAL_BY;
   FUNCTION APPROVAL_STATE(
      P_RECORD_STATUS_LEVEL IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_CTRL_RECORD_STATUS_LEVEL.APPROVAL_STATE      (
         P_RECORD_STATUS_LEVEL );
         RETURN ret_value;
   END APPROVAL_STATE;
   FUNCTION LABEL(
      P_RECORD_STATUS_LEVEL IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (16) ;
   BEGIN
      ret_value := EC_CTRL_RECORD_STATUS_LEVEL.LABEL      (
         P_RECORD_STATUS_LEVEL );
         RETURN ret_value;
   END LABEL;
   FUNCTION LEVEL_ID(
      P_RECORD_STATUS_LEVEL IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CTRL_RECORD_STATUS_LEVEL.LEVEL_ID      (
         P_RECORD_STATUS_LEVEL );
         RETURN ret_value;
   END LEVEL_ID;
   FUNCTION RECORD_STATUS(
      P_RECORD_STATUS_LEVEL IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_CTRL_RECORD_STATUS_LEVEL.RECORD_STATUS      (
         P_RECORD_STATUS_LEVEL );
         RETURN ret_value;
   END RECORD_STATUS;
   FUNCTION APPROVAL_DATE(
      P_RECORD_STATUS_LEVEL IN VARCHAR2)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CTRL_RECORD_STATUS_LEVEL.APPROVAL_DATE      (
         P_RECORD_STATUS_LEVEL );
         RETURN ret_value;
   END APPROVAL_DATE;
   FUNCTION ROW_BY_PK(
      P_RECORD_STATUS_LEVEL IN VARCHAR2)
      RETURN REC_ROW_BY_PK
   IS
      ret_value    REC_ROW_BY_PK ;
   BEGIN
      ret_value := EC_CTRL_RECORD_STATUS_LEVEL.ROW_BY_PK      (
         P_RECORD_STATUS_LEVEL );
         RETURN ret_value;
   END ROW_BY_PK;
   FUNCTION REC_ID(
      P_RECORD_STATUS_LEVEL IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_CTRL_RECORD_STATUS_LEVEL.REC_ID      (
         P_RECORD_STATUS_LEVEL );
         RETURN ret_value;
   END REC_ID;

END RP_CTRL_RECORD_STATUS_LEVEL;

/
--GRANT EXECUTE ON ECKERNEL_WST.RP_CTRL_RECORD_STATUS_LEVEL TO REPORT_ROLE_XXX;



 -- FINISH PKG_GEN_PKGS.sf_get_functions at:05/07/2019 10.33.19 AM

