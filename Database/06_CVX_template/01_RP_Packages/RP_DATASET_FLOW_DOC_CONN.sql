
 -- START PKG_GEN_PKGS.sf_get_functions at:05/07/2019 10.27.36 AM


CREATE or REPLACE PACKAGE RP_DATASET_FLOW_DOC_CONN
IS

   FUNCTION APPROVAL_BY(
      P_CONNECTION_ID IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_STATE(
      P_CONNECTION_ID IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION FROM_TYPE(
      P_CONNECTION_ID IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION TO_REFERENCE_ID(
      P_CONNECTION_ID IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION RECORD_STATUS(
      P_CONNECTION_ID IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_DATE(
      P_CONNECTION_ID IN VARCHAR2)
      RETURN DATE;
      TYPE REC_ROW_BY_PK IS RECORD (
         CONNECTION_ID VARCHAR2 (32) ,
         TO_TYPE VARCHAR2 (32) ,
         TO_REFERENCE_ID VARCHAR2 (100) ,
         FROM_TYPE VARCHAR2 (32) ,
         FROM_REFERENCE_ID VARCHAR2 (100) ,
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
      P_CONNECTION_ID IN VARCHAR2)
      RETURN REC_ROW_BY_PK;
   FUNCTION FROM_REFERENCE_ID(
      P_CONNECTION_ID IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION REC_ID(
      P_CONNECTION_ID IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION TO_TYPE(
      P_CONNECTION_ID IN VARCHAR2)
      RETURN VARCHAR2;

END RP_DATASET_FLOW_DOC_CONN;

/



CREATE or REPLACE PACKAGE BODY RP_DATASET_FLOW_DOC_CONN
IS

   FUNCTION APPROVAL_BY(
      P_CONNECTION_ID IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (30) ;
   BEGIN
      ret_value := EC_DATASET_FLOW_DOC_CONN.APPROVAL_BY      (
         P_CONNECTION_ID );
         RETURN ret_value;
   END APPROVAL_BY;
   FUNCTION APPROVAL_STATE(
      P_CONNECTION_ID IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_DATASET_FLOW_DOC_CONN.APPROVAL_STATE      (
         P_CONNECTION_ID );
         RETURN ret_value;
   END APPROVAL_STATE;
   FUNCTION FROM_TYPE(
      P_CONNECTION_ID IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_DATASET_FLOW_DOC_CONN.FROM_TYPE      (
         P_CONNECTION_ID );
         RETURN ret_value;
   END FROM_TYPE;
   FUNCTION TO_REFERENCE_ID(
      P_CONNECTION_ID IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (100) ;
   BEGIN
      ret_value := EC_DATASET_FLOW_DOC_CONN.TO_REFERENCE_ID      (
         P_CONNECTION_ID );
         RETURN ret_value;
   END TO_REFERENCE_ID;
   FUNCTION RECORD_STATUS(
      P_CONNECTION_ID IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_DATASET_FLOW_DOC_CONN.RECORD_STATUS      (
         P_CONNECTION_ID );
         RETURN ret_value;
   END RECORD_STATUS;
   FUNCTION APPROVAL_DATE(
      P_CONNECTION_ID IN VARCHAR2)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_DATASET_FLOW_DOC_CONN.APPROVAL_DATE      (
         P_CONNECTION_ID );
         RETURN ret_value;
   END APPROVAL_DATE;
   FUNCTION ROW_BY_PK(
      P_CONNECTION_ID IN VARCHAR2)
      RETURN REC_ROW_BY_PK
   IS
      ret_value    REC_ROW_BY_PK ;
   BEGIN
      ret_value := EC_DATASET_FLOW_DOC_CONN.ROW_BY_PK      (
         P_CONNECTION_ID );
         RETURN ret_value;
   END ROW_BY_PK;
   FUNCTION FROM_REFERENCE_ID(
      P_CONNECTION_ID IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (100) ;
   BEGIN
      ret_value := EC_DATASET_FLOW_DOC_CONN.FROM_REFERENCE_ID      (
         P_CONNECTION_ID );
         RETURN ret_value;
   END FROM_REFERENCE_ID;
   FUNCTION REC_ID(
      P_CONNECTION_ID IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_DATASET_FLOW_DOC_CONN.REC_ID      (
         P_CONNECTION_ID );
         RETURN ret_value;
   END REC_ID;
   FUNCTION TO_TYPE(
      P_CONNECTION_ID IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_DATASET_FLOW_DOC_CONN.TO_TYPE      (
         P_CONNECTION_ID );
         RETURN ret_value;
   END TO_TYPE;

END RP_DATASET_FLOW_DOC_CONN;

/
--GRANT EXECUTE ON ECKERNEL_WST.RP_DATASET_FLOW_DOC_CONN TO REPORT_ROLE_XXX;



 -- FINISH PKG_GEN_PKGS.sf_get_functions at:05/07/2019 10.27.38 AM


