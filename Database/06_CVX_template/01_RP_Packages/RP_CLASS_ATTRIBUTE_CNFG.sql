
 -- START PKG_GEN_PKGS.sf_get_functions at:11/15/2018 10.44.42 AM


CREATE or REPLACE PACKAGE RP_CLASS_ATTRIBUTE_CNFG
IS

   FUNCTION DB_JOIN_TABLE(
      P_CLASS_NAME IN VARCHAR2,
      P_ATTRIBUTE_NAME IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION REFERENCE_VALUE(
      P_CLASS_NAME IN VARCHAR2,
      P_ATTRIBUTE_NAME IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_BY(
      P_CLASS_NAME IN VARCHAR2,
      P_ATTRIBUTE_NAME IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_STATE(
      P_CLASS_NAME IN VARCHAR2,
      P_ATTRIBUTE_NAME IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION DATA_TYPE(
      P_CLASS_NAME IN VARCHAR2,
      P_ATTRIBUTE_NAME IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION DB_MAPPING_TYPE(
      P_CLASS_NAME IN VARCHAR2,
      P_ATTRIBUTE_NAME IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION REFERENCE_TYPE(
      P_CLASS_NAME IN VARCHAR2,
      P_ATTRIBUTE_NAME IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION DB_SQL_SYNTAX(
      P_CLASS_NAME IN VARCHAR2,
      P_ATTRIBUTE_NAME IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION REFERENCE_KEY(
      P_CLASS_NAME IN VARCHAR2,
      P_ATTRIBUTE_NAME IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION RECORD_STATUS(
      P_CLASS_NAME IN VARCHAR2,
      P_ATTRIBUTE_NAME IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_DATE(
      P_CLASS_NAME IN VARCHAR2,
      P_ATTRIBUTE_NAME IN VARCHAR2)
      RETURN DATE;
   FUNCTION DB_JOIN_WHERE(
      P_CLASS_NAME IN VARCHAR2,
      P_ATTRIBUTE_NAME IN VARCHAR2)
      RETURN VARCHAR2;
      TYPE REC_ROW_BY_PK IS RECORD (
         CLASS_NAME VARCHAR2 (24) ,
         ATTRIBUTE_NAME VARCHAR2 (24) ,
         APP_SPACE_CNTX VARCHAR2 (32) ,
         IS_KEY VARCHAR2 (1) ,
         DATA_TYPE VARCHAR2 (32) ,
         DB_MAPPING_TYPE VARCHAR2 (32) ,
         DB_SQL_SYNTAX VARCHAR2 (4000) ,
         DB_JOIN_TABLE VARCHAR2 (32) ,
         DB_JOIN_WHERE VARCHAR2 (4000) ,
         REFERENCE_KEY VARCHAR2 (30) ,
         REFERENCE_TYPE VARCHAR2 (24) ,
         REFERENCE_VALUE VARCHAR2 (32) ,
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
      P_CLASS_NAME IN VARCHAR2,
      P_ATTRIBUTE_NAME IN VARCHAR2)
      RETURN REC_ROW_BY_PK;
   FUNCTION APP_SPACE_CNTX(
      P_CLASS_NAME IN VARCHAR2,
      P_ATTRIBUTE_NAME IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION IS_KEY(
      P_CLASS_NAME IN VARCHAR2,
      P_ATTRIBUTE_NAME IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION REC_ID(
      P_CLASS_NAME IN VARCHAR2,
      P_ATTRIBUTE_NAME IN VARCHAR2)
      RETURN VARCHAR2;

END RP_CLASS_ATTRIBUTE_CNFG;

/



CREATE or REPLACE PACKAGE BODY RP_CLASS_ATTRIBUTE_CNFG
IS

   FUNCTION DB_JOIN_TABLE(
      P_CLASS_NAME IN VARCHAR2,
      P_ATTRIBUTE_NAME IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_CLASS_ATTRIBUTE_CNFG.DB_JOIN_TABLE      (
         P_CLASS_NAME,
         P_ATTRIBUTE_NAME );
         RETURN ret_value;
   END DB_JOIN_TABLE;
   FUNCTION REFERENCE_VALUE(
      P_CLASS_NAME IN VARCHAR2,
      P_ATTRIBUTE_NAME IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_CLASS_ATTRIBUTE_CNFG.REFERENCE_VALUE      (
         P_CLASS_NAME,
         P_ATTRIBUTE_NAME );
         RETURN ret_value;
   END REFERENCE_VALUE;
   FUNCTION APPROVAL_BY(
      P_CLASS_NAME IN VARCHAR2,
      P_ATTRIBUTE_NAME IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (30) ;
   BEGIN
      ret_value := EC_CLASS_ATTRIBUTE_CNFG.APPROVAL_BY      (
         P_CLASS_NAME,
         P_ATTRIBUTE_NAME );
         RETURN ret_value;
   END APPROVAL_BY;
   FUNCTION APPROVAL_STATE(
      P_CLASS_NAME IN VARCHAR2,
      P_ATTRIBUTE_NAME IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_CLASS_ATTRIBUTE_CNFG.APPROVAL_STATE      (
         P_CLASS_NAME,
         P_ATTRIBUTE_NAME );
         RETURN ret_value;
   END APPROVAL_STATE;
   FUNCTION DATA_TYPE(
      P_CLASS_NAME IN VARCHAR2,
      P_ATTRIBUTE_NAME IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_CLASS_ATTRIBUTE_CNFG.DATA_TYPE      (
         P_CLASS_NAME,
         P_ATTRIBUTE_NAME );
         RETURN ret_value;
   END DATA_TYPE;
   FUNCTION DB_MAPPING_TYPE(
      P_CLASS_NAME IN VARCHAR2,
      P_ATTRIBUTE_NAME IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_CLASS_ATTRIBUTE_CNFG.DB_MAPPING_TYPE      (
         P_CLASS_NAME,
         P_ATTRIBUTE_NAME );
         RETURN ret_value;
   END DB_MAPPING_TYPE;
   FUNCTION REFERENCE_TYPE(
      P_CLASS_NAME IN VARCHAR2,
      P_ATTRIBUTE_NAME IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (24) ;
   BEGIN
      ret_value := EC_CLASS_ATTRIBUTE_CNFG.REFERENCE_TYPE      (
         P_CLASS_NAME,
         P_ATTRIBUTE_NAME );
         RETURN ret_value;
   END REFERENCE_TYPE;
   FUNCTION DB_SQL_SYNTAX(
      P_CLASS_NAME IN VARCHAR2,
      P_ATTRIBUTE_NAME IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (4000) ;
   BEGIN
      ret_value := EC_CLASS_ATTRIBUTE_CNFG.DB_SQL_SYNTAX      (
         P_CLASS_NAME,
         P_ATTRIBUTE_NAME );
         RETURN ret_value;
   END DB_SQL_SYNTAX;
   FUNCTION REFERENCE_KEY(
      P_CLASS_NAME IN VARCHAR2,
      P_ATTRIBUTE_NAME IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (30) ;
   BEGIN
      ret_value := EC_CLASS_ATTRIBUTE_CNFG.REFERENCE_KEY      (
         P_CLASS_NAME,
         P_ATTRIBUTE_NAME );
         RETURN ret_value;
   END REFERENCE_KEY;
   FUNCTION RECORD_STATUS(
      P_CLASS_NAME IN VARCHAR2,
      P_ATTRIBUTE_NAME IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_CLASS_ATTRIBUTE_CNFG.RECORD_STATUS      (
         P_CLASS_NAME,
         P_ATTRIBUTE_NAME );
         RETURN ret_value;
   END RECORD_STATUS;
   FUNCTION APPROVAL_DATE(
      P_CLASS_NAME IN VARCHAR2,
      P_ATTRIBUTE_NAME IN VARCHAR2)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CLASS_ATTRIBUTE_CNFG.APPROVAL_DATE      (
         P_CLASS_NAME,
         P_ATTRIBUTE_NAME );
         RETURN ret_value;
   END APPROVAL_DATE;
   FUNCTION DB_JOIN_WHERE(
      P_CLASS_NAME IN VARCHAR2,
      P_ATTRIBUTE_NAME IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (4000) ;
   BEGIN
      ret_value := EC_CLASS_ATTRIBUTE_CNFG.DB_JOIN_WHERE      (
         P_CLASS_NAME,
         P_ATTRIBUTE_NAME );
         RETURN ret_value;
   END DB_JOIN_WHERE;
   FUNCTION ROW_BY_PK(
      P_CLASS_NAME IN VARCHAR2,
      P_ATTRIBUTE_NAME IN VARCHAR2)
      RETURN REC_ROW_BY_PK
   IS
      ret_value    REC_ROW_BY_PK ;
   BEGIN
      ret_value := EC_CLASS_ATTRIBUTE_CNFG.ROW_BY_PK      (
         P_CLASS_NAME,
         P_ATTRIBUTE_NAME );
         RETURN ret_value;
   END ROW_BY_PK;
   FUNCTION APP_SPACE_CNTX(
      P_CLASS_NAME IN VARCHAR2,
      P_ATTRIBUTE_NAME IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_CLASS_ATTRIBUTE_CNFG.APP_SPACE_CNTX      (
         P_CLASS_NAME,
         P_ATTRIBUTE_NAME );
         RETURN ret_value;
   END APP_SPACE_CNTX;
   FUNCTION IS_KEY(
      P_CLASS_NAME IN VARCHAR2,
      P_ATTRIBUTE_NAME IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_CLASS_ATTRIBUTE_CNFG.IS_KEY      (
         P_CLASS_NAME,
         P_ATTRIBUTE_NAME );
         RETURN ret_value;
   END IS_KEY;
   FUNCTION REC_ID(
      P_CLASS_NAME IN VARCHAR2,
      P_ATTRIBUTE_NAME IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_CLASS_ATTRIBUTE_CNFG.REC_ID      (
         P_CLASS_NAME,
         P_ATTRIBUTE_NAME );
         RETURN ret_value;
   END REC_ID;

END RP_CLASS_ATTRIBUTE_CNFG;

/
--GRANT EXECUTE ON ECKERNEL_WST.RP_CLASS_ATTRIBUTE_CNFG TO REPORT_ROLE_XXX;



 -- FINISH PKG_GEN_PKGS.sf_get_functions at:11/15/2018 10.44.45 AM


