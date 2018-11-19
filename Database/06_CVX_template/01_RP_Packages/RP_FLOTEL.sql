
 -- START PKG_GEN_PKGS.sf_get_functions at:11/15/2018 09.14.12 AM


CREATE or REPLACE PACKAGE RP_FLOTEL
IS

   FUNCTION APPROVAL_BY(
      P_FLOTEL IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_STATE(
      P_FLOTEL IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION NAME(
      P_FLOTEL IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION TOTAL_BEDS(
      P_FLOTEL IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION END_DATE(
      P_FLOTEL IN VARCHAR2)
      RETURN DATE;
   FUNCTION RECORD_STATUS(
      P_FLOTEL IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION START_DATE(
      P_FLOTEL IN VARCHAR2)
      RETURN DATE;
   FUNCTION APPROVAL_DATE(
      P_FLOTEL IN VARCHAR2)
      RETURN DATE;
      TYPE REC_ROW_BY_PK IS RECORD (
         FLOTEL VARCHAR2 (16) ,
         NAME VARCHAR2 (30) ,
         START_DATE  DATE ,
         END_DATE  DATE ,
         PROD_FCTY_ID VARCHAR2 (32) ,
         BLOCK VARCHAR2 (16) ,
         TOTAL_BEDS NUMBER (4) ,
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
      P_FLOTEL IN VARCHAR2)
      RETURN REC_ROW_BY_PK;
   FUNCTION BLOCK(
      P_FLOTEL IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION REC_ID(
      P_FLOTEL IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION PROD_FCTY_ID(
      P_FLOTEL IN VARCHAR2)
      RETURN VARCHAR2;

END RP_FLOTEL;

/



CREATE or REPLACE PACKAGE BODY RP_FLOTEL
IS

   FUNCTION APPROVAL_BY(
      P_FLOTEL IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (30) ;
   BEGIN
      ret_value := EC_FLOTEL.APPROVAL_BY      (
         P_FLOTEL );
         RETURN ret_value;
   END APPROVAL_BY;
   FUNCTION APPROVAL_STATE(
      P_FLOTEL IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_FLOTEL.APPROVAL_STATE      (
         P_FLOTEL );
         RETURN ret_value;
   END APPROVAL_STATE;
   FUNCTION NAME(
      P_FLOTEL IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (30) ;
   BEGIN
      ret_value := EC_FLOTEL.NAME      (
         P_FLOTEL );
         RETURN ret_value;
   END NAME;
   FUNCTION TOTAL_BEDS(
      P_FLOTEL IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER (4) ;
   BEGIN
      ret_value := EC_FLOTEL.TOTAL_BEDS      (
         P_FLOTEL );
         RETURN ret_value;
   END TOTAL_BEDS;
   FUNCTION END_DATE(
      P_FLOTEL IN VARCHAR2)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_FLOTEL.END_DATE      (
         P_FLOTEL );
         RETURN ret_value;
   END END_DATE;
   FUNCTION RECORD_STATUS(
      P_FLOTEL IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_FLOTEL.RECORD_STATUS      (
         P_FLOTEL );
         RETURN ret_value;
   END RECORD_STATUS;
   FUNCTION START_DATE(
      P_FLOTEL IN VARCHAR2)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_FLOTEL.START_DATE      (
         P_FLOTEL );
         RETURN ret_value;
   END START_DATE;
   FUNCTION APPROVAL_DATE(
      P_FLOTEL IN VARCHAR2)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_FLOTEL.APPROVAL_DATE      (
         P_FLOTEL );
         RETURN ret_value;
   END APPROVAL_DATE;
   FUNCTION ROW_BY_PK(
      P_FLOTEL IN VARCHAR2)
      RETURN REC_ROW_BY_PK
   IS
      ret_value    REC_ROW_BY_PK ;
   BEGIN
      ret_value := EC_FLOTEL.ROW_BY_PK      (
         P_FLOTEL );
         RETURN ret_value;
   END ROW_BY_PK;
   FUNCTION BLOCK(
      P_FLOTEL IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (16) ;
   BEGIN
      ret_value := EC_FLOTEL.BLOCK      (
         P_FLOTEL );
         RETURN ret_value;
   END BLOCK;
   FUNCTION REC_ID(
      P_FLOTEL IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_FLOTEL.REC_ID      (
         P_FLOTEL );
         RETURN ret_value;
   END REC_ID;
   FUNCTION PROD_FCTY_ID(
      P_FLOTEL IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_FLOTEL.PROD_FCTY_ID      (
         P_FLOTEL );
         RETURN ret_value;
   END PROD_FCTY_ID;

END RP_FLOTEL;

/
--GRANT EXECUTE ON ECKERNEL_WST.RP_FLOTEL TO REPORT_ROLE_XXX;



 -- FINISH PKG_GEN_PKGS.sf_get_functions at:11/15/2018 09.14.15 AM


