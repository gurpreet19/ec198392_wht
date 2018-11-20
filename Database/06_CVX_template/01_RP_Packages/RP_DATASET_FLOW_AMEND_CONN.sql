
 -- START PKG_GEN_PKGS.sf_get_functions at:11/15/2018 10.12.35 AM


CREATE or REPLACE PACKAGE RP_DATASET_FLOW_AMEND_CONN
IS

   FUNCTION APPROVAL_BY(
      P_REF_ID IN VARCHAR2,
      P_PREVIOUS_REF_ID IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_STATE(
      P_REF_ID IN VARCHAR2,
      P_PREVIOUS_REF_ID IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION RECORD_STATUS(
      P_REF_ID IN VARCHAR2,
      P_PREVIOUS_REF_ID IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_DATE(
      P_REF_ID IN VARCHAR2,
      P_PREVIOUS_REF_ID IN VARCHAR2)
      RETURN DATE;
      TYPE REC_ROW_BY_PK IS RECORD (
         REF_ID VARCHAR2 (100) ,
         PREVIOUS_REF_ID VARCHAR2 (100) ,
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
      P_REF_ID IN VARCHAR2,
      P_PREVIOUS_REF_ID IN VARCHAR2)
      RETURN REC_ROW_BY_PK;
   FUNCTION REC_ID(
      P_REF_ID IN VARCHAR2,
      P_PREVIOUS_REF_ID IN VARCHAR2)
      RETURN VARCHAR2;

END RP_DATASET_FLOW_AMEND_CONN;

/



CREATE or REPLACE PACKAGE BODY RP_DATASET_FLOW_AMEND_CONN
IS

   FUNCTION APPROVAL_BY(
      P_REF_ID IN VARCHAR2,
      P_PREVIOUS_REF_ID IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (30) ;
   BEGIN
      ret_value := EC_DATASET_FLOW_AMEND_CONN.APPROVAL_BY      (
         P_REF_ID,
         P_PREVIOUS_REF_ID );
         RETURN ret_value;
   END APPROVAL_BY;
   FUNCTION APPROVAL_STATE(
      P_REF_ID IN VARCHAR2,
      P_PREVIOUS_REF_ID IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_DATASET_FLOW_AMEND_CONN.APPROVAL_STATE      (
         P_REF_ID,
         P_PREVIOUS_REF_ID );
         RETURN ret_value;
   END APPROVAL_STATE;
   FUNCTION RECORD_STATUS(
      P_REF_ID IN VARCHAR2,
      P_PREVIOUS_REF_ID IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_DATASET_FLOW_AMEND_CONN.RECORD_STATUS      (
         P_REF_ID,
         P_PREVIOUS_REF_ID );
         RETURN ret_value;
   END RECORD_STATUS;
   FUNCTION APPROVAL_DATE(
      P_REF_ID IN VARCHAR2,
      P_PREVIOUS_REF_ID IN VARCHAR2)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_DATASET_FLOW_AMEND_CONN.APPROVAL_DATE      (
         P_REF_ID,
         P_PREVIOUS_REF_ID );
         RETURN ret_value;
   END APPROVAL_DATE;
   FUNCTION ROW_BY_PK(
      P_REF_ID IN VARCHAR2,
      P_PREVIOUS_REF_ID IN VARCHAR2)
      RETURN REC_ROW_BY_PK
   IS
      ret_value    REC_ROW_BY_PK ;
   BEGIN
      ret_value := EC_DATASET_FLOW_AMEND_CONN.ROW_BY_PK      (
         P_REF_ID,
         P_PREVIOUS_REF_ID );
         RETURN ret_value;
   END ROW_BY_PK;
   FUNCTION REC_ID(
      P_REF_ID IN VARCHAR2,
      P_PREVIOUS_REF_ID IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_DATASET_FLOW_AMEND_CONN.REC_ID      (
         P_REF_ID,
         P_PREVIOUS_REF_ID );
         RETURN ret_value;
   END REC_ID;

END RP_DATASET_FLOW_AMEND_CONN;

/
--GRANT EXECUTE ON ECKERNEL_WST.RP_DATASET_FLOW_AMEND_CONN TO REPORT_ROLE_XXX;



 -- FINISH PKG_GEN_PKGS.sf_get_functions at:11/15/2018 10.12.36 AM

