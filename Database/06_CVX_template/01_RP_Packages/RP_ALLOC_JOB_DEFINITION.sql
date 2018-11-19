
 -- START PKG_GEN_PKGS.sf_get_functions at:11/15/2018 11.04.06 AM


CREATE or REPLACE PACKAGE RP_ALLOC_JOB_DEFINITION
IS

   FUNCTION CALC_CONTEXT_ID(
      P_JOB_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_BY(
      P_JOB_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_STATE(
      P_JOB_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION RECORD_STATUS(
      P_JOB_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_DATE(
      P_JOB_NO IN NUMBER)
      RETURN DATE;
   FUNCTION NAME(
      P_JOB_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION PERIOD(
      P_JOB_NO IN NUMBER)
      RETURN VARCHAR2;
      TYPE REC_ROW_BY_PK IS RECORD (
         JOB_NO NUMBER ,
         CODE VARCHAR2 (32) ,
         NAME VARCHAR2 (240) ,
         VALID_FROM_DATE  DATE ,
         PERIOD VARCHAR2 (32) ,
         CALC_CONTEXT_ID VARCHAR2 (32) ,
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
      P_JOB_NO IN NUMBER)
      RETURN REC_ROW_BY_PK;
   FUNCTION CODE(
      P_JOB_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION REC_ID(
      P_JOB_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALID_FROM_DATE(
      P_JOB_NO IN NUMBER)
      RETURN DATE;

END RP_ALLOC_JOB_DEFINITION;

/



CREATE or REPLACE PACKAGE BODY RP_ALLOC_JOB_DEFINITION
IS

   FUNCTION CALC_CONTEXT_ID(
      P_JOB_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_ALLOC_JOB_DEFINITION.CALC_CONTEXT_ID      (
         P_JOB_NO );
         RETURN ret_value;
   END CALC_CONTEXT_ID;
   FUNCTION APPROVAL_BY(
      P_JOB_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (30) ;
   BEGIN
      ret_value := EC_ALLOC_JOB_DEFINITION.APPROVAL_BY      (
         P_JOB_NO );
         RETURN ret_value;
   END APPROVAL_BY;
   FUNCTION APPROVAL_STATE(
      P_JOB_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_ALLOC_JOB_DEFINITION.APPROVAL_STATE      (
         P_JOB_NO );
         RETURN ret_value;
   END APPROVAL_STATE;
   FUNCTION RECORD_STATUS(
      P_JOB_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_ALLOC_JOB_DEFINITION.RECORD_STATUS      (
         P_JOB_NO );
         RETURN ret_value;
   END RECORD_STATUS;
   FUNCTION APPROVAL_DATE(
      P_JOB_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_ALLOC_JOB_DEFINITION.APPROVAL_DATE      (
         P_JOB_NO );
         RETURN ret_value;
   END APPROVAL_DATE;
   FUNCTION NAME(
      P_JOB_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_ALLOC_JOB_DEFINITION.NAME      (
         P_JOB_NO );
         RETURN ret_value;
   END NAME;
   FUNCTION PERIOD(
      P_JOB_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_ALLOC_JOB_DEFINITION.PERIOD      (
         P_JOB_NO );
         RETURN ret_value;
   END PERIOD;
   FUNCTION ROW_BY_PK(
      P_JOB_NO IN NUMBER)
      RETURN REC_ROW_BY_PK
   IS
      ret_value    REC_ROW_BY_PK ;
   BEGIN
      ret_value := EC_ALLOC_JOB_DEFINITION.ROW_BY_PK      (
         P_JOB_NO );
         RETURN ret_value;
   END ROW_BY_PK;
   FUNCTION CODE(
      P_JOB_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_ALLOC_JOB_DEFINITION.CODE      (
         P_JOB_NO );
         RETURN ret_value;
   END CODE;
   FUNCTION REC_ID(
      P_JOB_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_ALLOC_JOB_DEFINITION.REC_ID      (
         P_JOB_NO );
         RETURN ret_value;
   END REC_ID;
   FUNCTION VALID_FROM_DATE(
      P_JOB_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_ALLOC_JOB_DEFINITION.VALID_FROM_DATE      (
         P_JOB_NO );
         RETURN ret_value;
   END VALID_FROM_DATE;

END RP_ALLOC_JOB_DEFINITION;

/
--GRANT EXECUTE ON ECKERNEL_WST.RP_ALLOC_JOB_DEFINITION TO REPORT_ROLE_XXX;



 -- FINISH PKG_GEN_PKGS.sf_get_functions at:11/15/2018 11.04.09 AM


