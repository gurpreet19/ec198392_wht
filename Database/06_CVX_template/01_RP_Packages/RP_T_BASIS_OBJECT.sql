
 -- START PKG_GEN_PKGS.sf_get_functions at:11/15/2018 07.16.17 AM


CREATE or REPLACE PACKAGE RP_T_BASIS_OBJECT
IS

   FUNCTION APPROVAL_BY(
      P_OBJECT_ID IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_STATE(
      P_OBJECT_ID IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION OBJECT_NAME(
      P_OBJECT_ID IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION APP_ID(
      P_OBJECT_ID IN NUMBER)
      RETURN NUMBER;
   FUNCTION OBJECT_DESCR(
      P_OBJECT_ID IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION RECORD_STATUS(
      P_OBJECT_ID IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_DATE(
      P_OBJECT_ID IN NUMBER)
      RETURN DATE;
   FUNCTION FUNC_OBJECT_ID(
      P_OBJECT_ID IN NUMBER)
      RETURN NUMBER;
   FUNCTION OBJECT_TYPE(
      P_OBJECT_ID IN NUMBER)
      RETURN VARCHAR2;
      TYPE REC_ROW_BY_OBJECT_ID IS RECORD (
         OBJECT_ID NUMBER ,
         APP_ID NUMBER ,
         OBJECT_NAME VARCHAR2 (2000) ,
         OBJECT_TYPE VARCHAR2 (32) ,
         OBJECT_DESCR VARCHAR2 (255) ,
         FUNC_OBJECT_ID NUMBER ,
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
   FUNCTION ROW_BY_OBJECT_ID(
      P_OBJECT_ID IN VARCHAR2)
      RETURN REC_ROW_BY_OBJECT_ID;
      TYPE REC_ROW_BY_PK IS RECORD (
         OBJECT_ID NUMBER ,
         APP_ID NUMBER ,
         OBJECT_NAME VARCHAR2 (2000) ,
         OBJECT_TYPE VARCHAR2 (32) ,
         OBJECT_DESCR VARCHAR2 (255) ,
         FUNC_OBJECT_ID NUMBER ,
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
      P_OBJECT_ID IN NUMBER)
      RETURN REC_ROW_BY_PK;
   FUNCTION REC_ID(
      P_OBJECT_ID IN NUMBER)
      RETURN VARCHAR2;

END RP_T_BASIS_OBJECT;

/



CREATE or REPLACE PACKAGE BODY RP_T_BASIS_OBJECT
IS

   FUNCTION APPROVAL_BY(
      P_OBJECT_ID IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (30) ;
   BEGIN
      ret_value := EC_T_BASIS_OBJECT.APPROVAL_BY      (
         P_OBJECT_ID );
         RETURN ret_value;
   END APPROVAL_BY;
   FUNCTION APPROVAL_STATE(
      P_OBJECT_ID IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_T_BASIS_OBJECT.APPROVAL_STATE      (
         P_OBJECT_ID );
         RETURN ret_value;
   END APPROVAL_STATE;
   FUNCTION OBJECT_NAME(
      P_OBJECT_ID IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_T_BASIS_OBJECT.OBJECT_NAME      (
         P_OBJECT_ID );
         RETURN ret_value;
   END OBJECT_NAME;
   FUNCTION APP_ID(
      P_OBJECT_ID IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_T_BASIS_OBJECT.APP_ID      (
         P_OBJECT_ID );
         RETURN ret_value;
   END APP_ID;
   FUNCTION OBJECT_DESCR(
      P_OBJECT_ID IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (255) ;
   BEGIN
      ret_value := EC_T_BASIS_OBJECT.OBJECT_DESCR      (
         P_OBJECT_ID );
         RETURN ret_value;
   END OBJECT_DESCR;
   FUNCTION RECORD_STATUS(
      P_OBJECT_ID IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_T_BASIS_OBJECT.RECORD_STATUS      (
         P_OBJECT_ID );
         RETURN ret_value;
   END RECORD_STATUS;
   FUNCTION APPROVAL_DATE(
      P_OBJECT_ID IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_T_BASIS_OBJECT.APPROVAL_DATE      (
         P_OBJECT_ID );
         RETURN ret_value;
   END APPROVAL_DATE;
   FUNCTION FUNC_OBJECT_ID(
      P_OBJECT_ID IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_T_BASIS_OBJECT.FUNC_OBJECT_ID      (
         P_OBJECT_ID );
         RETURN ret_value;
   END FUNC_OBJECT_ID;
   FUNCTION OBJECT_TYPE(
      P_OBJECT_ID IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_T_BASIS_OBJECT.OBJECT_TYPE      (
         P_OBJECT_ID );
         RETURN ret_value;
   END OBJECT_TYPE;
   FUNCTION ROW_BY_OBJECT_ID(
      P_OBJECT_ID IN VARCHAR2)
      RETURN REC_ROW_BY_OBJECT_ID
   IS
      ret_value    REC_ROW_BY_OBJECT_ID ;
   BEGIN
      ret_value := EC_T_BASIS_OBJECT.ROW_BY_OBJECT_ID      (
         P_OBJECT_ID );
         RETURN ret_value;
   END ROW_BY_OBJECT_ID;
   FUNCTION ROW_BY_PK(
      P_OBJECT_ID IN NUMBER)
      RETURN REC_ROW_BY_PK
   IS
      ret_value    REC_ROW_BY_PK ;
   BEGIN
      ret_value := EC_T_BASIS_OBJECT.ROW_BY_PK      (
         P_OBJECT_ID );
         RETURN ret_value;
   END ROW_BY_PK;
   FUNCTION REC_ID(
      P_OBJECT_ID IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_T_BASIS_OBJECT.REC_ID      (
         P_OBJECT_ID );
         RETURN ret_value;
   END REC_ID;

END RP_T_BASIS_OBJECT;

/
--GRANT EXECUTE ON ECKERNEL_WST.RP_T_BASIS_OBJECT TO REPORT_ROLE_XXX;



 -- FINISH PKG_GEN_PKGS.sf_get_functions at:11/15/2018 07.16.20 AM


