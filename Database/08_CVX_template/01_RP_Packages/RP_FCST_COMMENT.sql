
 -- START PKG_GEN_PKGS.sf_get_functions at:05/07/2019 10.13.23 AM


CREATE or REPLACE PACKAGE RP_FCST_COMMENT
IS

   FUNCTION APPROVAL_BY(
      P_COMMENT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_STATE(
      P_COMMENT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION COMMENT_TYPE(
      P_COMMENT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION OBJECT_ID(
      P_COMMENT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION PRODUCT_ID(
      P_COMMENT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION COMMENTS(
      P_COMMENT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION CONTRACT_ID(
      P_COMMENT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION RECORD_STATUS(
      P_COMMENT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_DATE(
      P_COMMENT_NO IN NUMBER)
      RETURN DATE;
      TYPE REC_ROW_BY_PK IS RECORD (
         OBJECT_ID VARCHAR2 (32) ,
         COMMENT_NO NUMBER ,
         COMMENT_TYPE VARCHAR2 (32) ,
         FIELD_ID VARCHAR2 (32) ,
         PRODUCT_ID VARCHAR2 (32) ,
         CONTRACT_ID VARCHAR2 (32) ,
         COMMENTS VARCHAR2 (2000) ,
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
      P_COMMENT_NO IN NUMBER)
      RETURN REC_ROW_BY_PK;
   FUNCTION REC_ID(
      P_COMMENT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION FIELD_ID(
      P_COMMENT_NO IN NUMBER)
      RETURN VARCHAR2;

END RP_FCST_COMMENT;

/



CREATE or REPLACE PACKAGE BODY RP_FCST_COMMENT
IS

   FUNCTION APPROVAL_BY(
      P_COMMENT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (30) ;
   BEGIN
      ret_value := EC_FCST_COMMENT.APPROVAL_BY      (
         P_COMMENT_NO );
         RETURN ret_value;
   END APPROVAL_BY;
   FUNCTION APPROVAL_STATE(
      P_COMMENT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_FCST_COMMENT.APPROVAL_STATE      (
         P_COMMENT_NO );
         RETURN ret_value;
   END APPROVAL_STATE;
   FUNCTION COMMENT_TYPE(
      P_COMMENT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_FCST_COMMENT.COMMENT_TYPE      (
         P_COMMENT_NO );
         RETURN ret_value;
   END COMMENT_TYPE;
   FUNCTION OBJECT_ID(
      P_COMMENT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_FCST_COMMENT.OBJECT_ID      (
         P_COMMENT_NO );
         RETURN ret_value;
   END OBJECT_ID;
   FUNCTION PRODUCT_ID(
      P_COMMENT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_FCST_COMMENT.PRODUCT_ID      (
         P_COMMENT_NO );
         RETURN ret_value;
   END PRODUCT_ID;
   FUNCTION COMMENTS(
      P_COMMENT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_FCST_COMMENT.COMMENTS      (
         P_COMMENT_NO );
         RETURN ret_value;
   END COMMENTS;
   FUNCTION CONTRACT_ID(
      P_COMMENT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_FCST_COMMENT.CONTRACT_ID      (
         P_COMMENT_NO );
         RETURN ret_value;
   END CONTRACT_ID;
   FUNCTION RECORD_STATUS(
      P_COMMENT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_FCST_COMMENT.RECORD_STATUS      (
         P_COMMENT_NO );
         RETURN ret_value;
   END RECORD_STATUS;
   FUNCTION APPROVAL_DATE(
      P_COMMENT_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_FCST_COMMENT.APPROVAL_DATE      (
         P_COMMENT_NO );
         RETURN ret_value;
   END APPROVAL_DATE;
   FUNCTION ROW_BY_PK(
      P_COMMENT_NO IN NUMBER)
      RETURN REC_ROW_BY_PK
   IS
      ret_value    REC_ROW_BY_PK ;
   BEGIN
      ret_value := EC_FCST_COMMENT.ROW_BY_PK      (
         P_COMMENT_NO );
         RETURN ret_value;
   END ROW_BY_PK;
   FUNCTION REC_ID(
      P_COMMENT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_FCST_COMMENT.REC_ID      (
         P_COMMENT_NO );
         RETURN ret_value;
   END REC_ID;
   FUNCTION FIELD_ID(
      P_COMMENT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_FCST_COMMENT.FIELD_ID      (
         P_COMMENT_NO );
         RETURN ret_value;
   END FIELD_ID;

END RP_FCST_COMMENT;

/
--GRANT EXECUTE ON ECKERNEL_WST.RP_FCST_COMMENT TO REPORT_ROLE_XXX;



 -- FINISH PKG_GEN_PKGS.sf_get_functions at:05/07/2019 10.13.26 AM


