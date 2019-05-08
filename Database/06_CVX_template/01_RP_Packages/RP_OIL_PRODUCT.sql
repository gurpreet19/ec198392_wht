
 -- START PKG_GEN_PKGS.sf_get_functions at:05/07/2019 08.35.40 AM


CREATE or REPLACE PACKAGE RP_OIL_PRODUCT
IS

   FUNCTION SORT_ORDER(
      P_PRODUCT_ID IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION APPROVAL_BY(
      P_PRODUCT_ID IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_STATE(
      P_PRODUCT_ID IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION NAME(
      P_PRODUCT_ID IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION RECORD_STATUS(
      P_PRODUCT_ID IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_DATE(
      P_PRODUCT_ID IN VARCHAR2)
      RETURN DATE;
      TYPE REC_ROW_BY_PK IS RECORD (
         PRODUCT_ID VARCHAR2 (20) ,
         PRODUCT_TYPE VARCHAR2 (16) ,
         NAME VARCHAR2 (30) ,
         SORT_ORDER NUMBER ,
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
      P_PRODUCT_ID IN VARCHAR2)
      RETURN REC_ROW_BY_PK;
   FUNCTION PRODUCT_TYPE(
      P_PRODUCT_ID IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION REC_ID(
      P_PRODUCT_ID IN VARCHAR2)
      RETURN VARCHAR2;

END RP_OIL_PRODUCT;

/



CREATE or REPLACE PACKAGE BODY RP_OIL_PRODUCT
IS

   FUNCTION SORT_ORDER(
      P_PRODUCT_ID IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_OIL_PRODUCT.SORT_ORDER      (
         P_PRODUCT_ID );
         RETURN ret_value;
   END SORT_ORDER;
   FUNCTION APPROVAL_BY(
      P_PRODUCT_ID IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (30) ;
   BEGIN
      ret_value := EC_OIL_PRODUCT.APPROVAL_BY      (
         P_PRODUCT_ID );
         RETURN ret_value;
   END APPROVAL_BY;
   FUNCTION APPROVAL_STATE(
      P_PRODUCT_ID IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_OIL_PRODUCT.APPROVAL_STATE      (
         P_PRODUCT_ID );
         RETURN ret_value;
   END APPROVAL_STATE;
   FUNCTION NAME(
      P_PRODUCT_ID IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (30) ;
   BEGIN
      ret_value := EC_OIL_PRODUCT.NAME      (
         P_PRODUCT_ID );
         RETURN ret_value;
   END NAME;
   FUNCTION RECORD_STATUS(
      P_PRODUCT_ID IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_OIL_PRODUCT.RECORD_STATUS      (
         P_PRODUCT_ID );
         RETURN ret_value;
   END RECORD_STATUS;
   FUNCTION APPROVAL_DATE(
      P_PRODUCT_ID IN VARCHAR2)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_OIL_PRODUCT.APPROVAL_DATE      (
         P_PRODUCT_ID );
         RETURN ret_value;
   END APPROVAL_DATE;
   FUNCTION ROW_BY_PK(
      P_PRODUCT_ID IN VARCHAR2)
      RETURN REC_ROW_BY_PK
   IS
      ret_value    REC_ROW_BY_PK ;
   BEGIN
      ret_value := EC_OIL_PRODUCT.ROW_BY_PK      (
         P_PRODUCT_ID );
         RETURN ret_value;
   END ROW_BY_PK;
   FUNCTION PRODUCT_TYPE(
      P_PRODUCT_ID IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (16) ;
   BEGIN
      ret_value := EC_OIL_PRODUCT.PRODUCT_TYPE      (
         P_PRODUCT_ID );
         RETURN ret_value;
   END PRODUCT_TYPE;
   FUNCTION REC_ID(
      P_PRODUCT_ID IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_OIL_PRODUCT.REC_ID      (
         P_PRODUCT_ID );
         RETURN ret_value;
   END REC_ID;

END RP_OIL_PRODUCT;

/
--GRANT EXECUTE ON ECKERNEL_WST.RP_OIL_PRODUCT TO REPORT_ROLE_XXX;



 -- FINISH PKG_GEN_PKGS.sf_get_functions at:05/07/2019 08.35.43 AM


