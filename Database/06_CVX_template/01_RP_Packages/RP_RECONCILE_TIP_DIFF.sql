
 -- START PKG_GEN_PKGS.sf_get_functions at:05/07/2019 07.47.42 AM


CREATE or REPLACE PACKAGE RP_RECONCILE_TIP_DIFF
IS

   FUNCTION APPROVAL_BY(
      P_RECON_TIP_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_STATE(
      P_RECON_TIP_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION FROM_RUN_TIME(
      P_RECON_TIP_NO IN NUMBER)
      RETURN DATE;
   FUNCTION RECONCILIATION_NO(
      P_RECON_TIP_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION PRODUCT_DESC(
      P_RECON_TIP_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION PRODUCT_ID(
      P_RECON_TIP_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TO_NUMBER(
      P_RECON_TIP_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION TO_RUN_TIME(
      P_RECON_TIP_NO IN NUMBER)
      RETURN DATE;
   FUNCTION COMMENTS(
      P_RECON_TIP_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TO_DOC(
      P_RECON_TIP_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION FROM_DOC(
      P_RECON_TIP_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION INVENTORY_ID(
      P_RECON_TIP_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION RECORD_STATUS(
      P_RECON_TIP_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_DATE(
      P_RECON_TIP_NO IN NUMBER)
      RETURN DATE;
   FUNCTION COLUMN_TYPE(
      P_RECON_TIP_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION FROM_NUMBER(
      P_RECON_TIP_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION PROD_STREAM_ID(
      P_RECON_TIP_NO IN NUMBER)
      RETURN VARCHAR2;
      TYPE REC_ROW_BY_PK IS RECORD (
         RECONCILIATION_NO NUMBER ,
         RECON_TIP_NO NUMBER ,
         FROM_DOC VARCHAR2 (32) ,
         TO_DOC VARCHAR2 (32) ,
         PROD_STREAM_ID VARCHAR2 (32) ,
         INVENTORY_ID VARCHAR2 (32) ,
         LAYER_MONTH  DATE ,
         PRODUCT_DESC VARCHAR2 (1000) ,
         PRODUCT_ID VARCHAR2 (32) ,
         COST_TYPE VARCHAR2 (32) ,
         COLUMN_TYPE VARCHAR2 (32) ,
         FROM_NUMBER NUMBER ,
         TO_NUMBER NUMBER ,
         COMMENTS VARCHAR2 (2000) ,
         FROM_RUN_TIME  DATE ,
         TO_RUN_TIME  DATE ,
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
      P_RECON_TIP_NO IN NUMBER)
      RETURN REC_ROW_BY_PK;
   FUNCTION COST_TYPE(
      P_RECON_TIP_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION REC_ID(
      P_RECON_TIP_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION LAYER_MONTH(
      P_RECON_TIP_NO IN NUMBER)
      RETURN DATE;

END RP_RECONCILE_TIP_DIFF;

/



CREATE or REPLACE PACKAGE BODY RP_RECONCILE_TIP_DIFF
IS

   FUNCTION APPROVAL_BY(
      P_RECON_TIP_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (30) ;
   BEGIN
      ret_value := EC_RECONCILE_TIP_DIFF.APPROVAL_BY      (
         P_RECON_TIP_NO );
         RETURN ret_value;
   END APPROVAL_BY;
   FUNCTION APPROVAL_STATE(
      P_RECON_TIP_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_RECONCILE_TIP_DIFF.APPROVAL_STATE      (
         P_RECON_TIP_NO );
         RETURN ret_value;
   END APPROVAL_STATE;
   FUNCTION FROM_RUN_TIME(
      P_RECON_TIP_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_RECONCILE_TIP_DIFF.FROM_RUN_TIME      (
         P_RECON_TIP_NO );
         RETURN ret_value;
   END FROM_RUN_TIME;
   FUNCTION RECONCILIATION_NO(
      P_RECON_TIP_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_RECONCILE_TIP_DIFF.RECONCILIATION_NO      (
         P_RECON_TIP_NO );
         RETURN ret_value;
   END RECONCILIATION_NO;
   FUNCTION PRODUCT_DESC(
      P_RECON_TIP_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1000) ;
   BEGIN
      ret_value := EC_RECONCILE_TIP_DIFF.PRODUCT_DESC      (
         P_RECON_TIP_NO );
         RETURN ret_value;
   END PRODUCT_DESC;
   FUNCTION PRODUCT_ID(
      P_RECON_TIP_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_RECONCILE_TIP_DIFF.PRODUCT_ID      (
         P_RECON_TIP_NO );
         RETURN ret_value;
   END PRODUCT_ID;
   FUNCTION TO_NUMBER(
      P_RECON_TIP_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_RECONCILE_TIP_DIFF.TO_NUMBER      (
         P_RECON_TIP_NO );
         RETURN ret_value;
   END TO_NUMBER;
   FUNCTION TO_RUN_TIME(
      P_RECON_TIP_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_RECONCILE_TIP_DIFF.TO_RUN_TIME      (
         P_RECON_TIP_NO );
         RETURN ret_value;
   END TO_RUN_TIME;
   FUNCTION COMMENTS(
      P_RECON_TIP_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_RECONCILE_TIP_DIFF.COMMENTS      (
         P_RECON_TIP_NO );
         RETURN ret_value;
   END COMMENTS;
   FUNCTION TO_DOC(
      P_RECON_TIP_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_RECONCILE_TIP_DIFF.TO_DOC      (
         P_RECON_TIP_NO );
         RETURN ret_value;
   END TO_DOC;
   FUNCTION FROM_DOC(
      P_RECON_TIP_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_RECONCILE_TIP_DIFF.FROM_DOC      (
         P_RECON_TIP_NO );
         RETURN ret_value;
   END FROM_DOC;
   FUNCTION INVENTORY_ID(
      P_RECON_TIP_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_RECONCILE_TIP_DIFF.INVENTORY_ID      (
         P_RECON_TIP_NO );
         RETURN ret_value;
   END INVENTORY_ID;
   FUNCTION RECORD_STATUS(
      P_RECON_TIP_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_RECONCILE_TIP_DIFF.RECORD_STATUS      (
         P_RECON_TIP_NO );
         RETURN ret_value;
   END RECORD_STATUS;
   FUNCTION APPROVAL_DATE(
      P_RECON_TIP_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_RECONCILE_TIP_DIFF.APPROVAL_DATE      (
         P_RECON_TIP_NO );
         RETURN ret_value;
   END APPROVAL_DATE;
   FUNCTION COLUMN_TYPE(
      P_RECON_TIP_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_RECONCILE_TIP_DIFF.COLUMN_TYPE      (
         P_RECON_TIP_NO );
         RETURN ret_value;
   END COLUMN_TYPE;
   FUNCTION FROM_NUMBER(
      P_RECON_TIP_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_RECONCILE_TIP_DIFF.FROM_NUMBER      (
         P_RECON_TIP_NO );
         RETURN ret_value;
   END FROM_NUMBER;
   FUNCTION PROD_STREAM_ID(
      P_RECON_TIP_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_RECONCILE_TIP_DIFF.PROD_STREAM_ID      (
         P_RECON_TIP_NO );
         RETURN ret_value;
   END PROD_STREAM_ID;
   FUNCTION ROW_BY_PK(
      P_RECON_TIP_NO IN NUMBER)
      RETURN REC_ROW_BY_PK
   IS
      ret_value    REC_ROW_BY_PK ;
   BEGIN
      ret_value := EC_RECONCILE_TIP_DIFF.ROW_BY_PK      (
         P_RECON_TIP_NO );
         RETURN ret_value;
   END ROW_BY_PK;
   FUNCTION COST_TYPE(
      P_RECON_TIP_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_RECONCILE_TIP_DIFF.COST_TYPE      (
         P_RECON_TIP_NO );
         RETURN ret_value;
   END COST_TYPE;
   FUNCTION REC_ID(
      P_RECON_TIP_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_RECONCILE_TIP_DIFF.REC_ID      (
         P_RECON_TIP_NO );
         RETURN ret_value;
   END REC_ID;
   FUNCTION LAYER_MONTH(
      P_RECON_TIP_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_RECONCILE_TIP_DIFF.LAYER_MONTH      (
         P_RECON_TIP_NO );
         RETURN ret_value;
   END LAYER_MONTH;

END RP_RECONCILE_TIP_DIFF;

/
--GRANT EXECUTE ON ECKERNEL_WST.RP_RECONCILE_TIP_DIFF TO REPORT_ROLE_XXX;



 -- FINISH PKG_GEN_PKGS.sf_get_functions at:05/07/2019 07.47.50 AM


