
 -- START PKG_GEN_PKGS.sf_get_functions at:05/07/2019 10.33.49 AM


CREATE or REPLACE PACKAGE RP_CTRL_CHECK_COMBINATION
IS

   FUNCTION DESCRIPTION(
      P_CHECK_ID IN NUMBER,
      P_CHECK_GROUP IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_BY(
      P_CHECK_ID IN NUMBER,
      P_CHECK_GROUP IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_STATE(
      P_CHECK_ID IN NUMBER,
      P_CHECK_GROUP IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION RECORD_STATUS(
      P_CHECK_ID IN NUMBER,
      P_CHECK_GROUP IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_DATE(
      P_CHECK_ID IN NUMBER,
      P_CHECK_GROUP IN VARCHAR2)
      RETURN DATE;
      TYPE REC_ROW_BY_PK IS RECORD (
         CHECK_ID NUMBER ,
         CHECK_GROUP VARCHAR2 (30) ,
         DESCRIPTION VARCHAR2 (2000) ,
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
      P_CHECK_ID IN NUMBER,
      P_CHECK_GROUP IN VARCHAR2)
      RETURN REC_ROW_BY_PK;
   FUNCTION REC_ID(
      P_CHECK_ID IN NUMBER,
      P_CHECK_GROUP IN VARCHAR2)
      RETURN VARCHAR2;

END RP_CTRL_CHECK_COMBINATION;

/



CREATE or REPLACE PACKAGE BODY RP_CTRL_CHECK_COMBINATION
IS

   FUNCTION DESCRIPTION(
      P_CHECK_ID IN NUMBER,
      P_CHECK_GROUP IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_CTRL_CHECK_COMBINATION.DESCRIPTION      (
         P_CHECK_ID,
         P_CHECK_GROUP );
         RETURN ret_value;
   END DESCRIPTION;
   FUNCTION APPROVAL_BY(
      P_CHECK_ID IN NUMBER,
      P_CHECK_GROUP IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (30) ;
   BEGIN
      ret_value := EC_CTRL_CHECK_COMBINATION.APPROVAL_BY      (
         P_CHECK_ID,
         P_CHECK_GROUP );
         RETURN ret_value;
   END APPROVAL_BY;
   FUNCTION APPROVAL_STATE(
      P_CHECK_ID IN NUMBER,
      P_CHECK_GROUP IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_CTRL_CHECK_COMBINATION.APPROVAL_STATE      (
         P_CHECK_ID,
         P_CHECK_GROUP );
         RETURN ret_value;
   END APPROVAL_STATE;
   FUNCTION RECORD_STATUS(
      P_CHECK_ID IN NUMBER,
      P_CHECK_GROUP IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_CTRL_CHECK_COMBINATION.RECORD_STATUS      (
         P_CHECK_ID,
         P_CHECK_GROUP );
         RETURN ret_value;
   END RECORD_STATUS;
   FUNCTION APPROVAL_DATE(
      P_CHECK_ID IN NUMBER,
      P_CHECK_GROUP IN VARCHAR2)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CTRL_CHECK_COMBINATION.APPROVAL_DATE      (
         P_CHECK_ID,
         P_CHECK_GROUP );
         RETURN ret_value;
   END APPROVAL_DATE;
   FUNCTION ROW_BY_PK(
      P_CHECK_ID IN NUMBER,
      P_CHECK_GROUP IN VARCHAR2)
      RETURN REC_ROW_BY_PK
   IS
      ret_value    REC_ROW_BY_PK ;
   BEGIN
      ret_value := EC_CTRL_CHECK_COMBINATION.ROW_BY_PK      (
         P_CHECK_ID,
         P_CHECK_GROUP );
         RETURN ret_value;
   END ROW_BY_PK;
   FUNCTION REC_ID(
      P_CHECK_ID IN NUMBER,
      P_CHECK_GROUP IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_CTRL_CHECK_COMBINATION.REC_ID      (
         P_CHECK_ID,
         P_CHECK_GROUP );
         RETURN ret_value;
   END REC_ID;

END RP_CTRL_CHECK_COMBINATION;

/
--GRANT EXECUTE ON ECKERNEL_WST.RP_CTRL_CHECK_COMBINATION TO REPORT_ROLE_XXX;



 -- FINISH PKG_GEN_PKGS.sf_get_functions at:05/07/2019 10.33.52 AM


