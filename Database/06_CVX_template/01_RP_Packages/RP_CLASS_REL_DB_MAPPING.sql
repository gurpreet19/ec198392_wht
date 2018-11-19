
 -- START PKG_GEN_PKGS.sf_get_functions at:11/15/2018 10.43.58 AM


CREATE or REPLACE PACKAGE RP_CLASS_REL_DB_MAPPING
IS

   FUNCTION SORT_ORDER(
      P_FROM_CLASS_NAME IN VARCHAR2,
      P_TO_CLASS_NAME IN VARCHAR2,
      P_ROLE_NAME IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION APPROVAL_BY(
      P_FROM_CLASS_NAME IN VARCHAR2,
      P_TO_CLASS_NAME IN VARCHAR2,
      P_ROLE_NAME IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_STATE(
      P_FROM_CLASS_NAME IN VARCHAR2,
      P_TO_CLASS_NAME IN VARCHAR2,
      P_ROLE_NAME IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION DB_MAPPING_TYPE(
      P_FROM_CLASS_NAME IN VARCHAR2,
      P_TO_CLASS_NAME IN VARCHAR2,
      P_ROLE_NAME IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION DB_SQL_SYNTAX(
      P_FROM_CLASS_NAME IN VARCHAR2,
      P_TO_CLASS_NAME IN VARCHAR2,
      P_ROLE_NAME IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION RECORD_STATUS(
      P_FROM_CLASS_NAME IN VARCHAR2,
      P_TO_CLASS_NAME IN VARCHAR2,
      P_ROLE_NAME IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_DATE(
      P_FROM_CLASS_NAME IN VARCHAR2,
      P_TO_CLASS_NAME IN VARCHAR2,
      P_ROLE_NAME IN VARCHAR2)
      RETURN DATE;
      TYPE REC_ROW_BY_PK IS RECORD (
         FROM_CLASS_NAME VARCHAR2 (24) ,
         TO_CLASS_NAME VARCHAR2 (24) ,
         ROLE_NAME VARCHAR2 (24) ,
         DB_MAPPING_TYPE VARCHAR2 (32) ,
         DB_SQL_SYNTAX VARCHAR2 (4000) ,
         SORT_ORDER NUMBER ,
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
      P_FROM_CLASS_NAME IN VARCHAR2,
      P_TO_CLASS_NAME IN VARCHAR2,
      P_ROLE_NAME IN VARCHAR2)
      RETURN REC_ROW_BY_PK;
   FUNCTION REC_ID(
      P_FROM_CLASS_NAME IN VARCHAR2,
      P_TO_CLASS_NAME IN VARCHAR2,
      P_ROLE_NAME IN VARCHAR2)
      RETURN VARCHAR2;

END RP_CLASS_REL_DB_MAPPING;

/



CREATE or REPLACE PACKAGE BODY RP_CLASS_REL_DB_MAPPING
IS

   FUNCTION SORT_ORDER(
      P_FROM_CLASS_NAME IN VARCHAR2,
      P_TO_CLASS_NAME IN VARCHAR2,
      P_ROLE_NAME IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CLASS_REL_DB_MAPPING.SORT_ORDER      (
         P_FROM_CLASS_NAME,
         P_TO_CLASS_NAME,
         P_ROLE_NAME );
         RETURN ret_value;
   END SORT_ORDER;
   FUNCTION APPROVAL_BY(
      P_FROM_CLASS_NAME IN VARCHAR2,
      P_TO_CLASS_NAME IN VARCHAR2,
      P_ROLE_NAME IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (30) ;
   BEGIN
      ret_value := EC_CLASS_REL_DB_MAPPING.APPROVAL_BY      (
         P_FROM_CLASS_NAME,
         P_TO_CLASS_NAME,
         P_ROLE_NAME );
         RETURN ret_value;
   END APPROVAL_BY;
   FUNCTION APPROVAL_STATE(
      P_FROM_CLASS_NAME IN VARCHAR2,
      P_TO_CLASS_NAME IN VARCHAR2,
      P_ROLE_NAME IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_CLASS_REL_DB_MAPPING.APPROVAL_STATE      (
         P_FROM_CLASS_NAME,
         P_TO_CLASS_NAME,
         P_ROLE_NAME );
         RETURN ret_value;
   END APPROVAL_STATE;
   FUNCTION DB_MAPPING_TYPE(
      P_FROM_CLASS_NAME IN VARCHAR2,
      P_TO_CLASS_NAME IN VARCHAR2,
      P_ROLE_NAME IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_CLASS_REL_DB_MAPPING.DB_MAPPING_TYPE      (
         P_FROM_CLASS_NAME,
         P_TO_CLASS_NAME,
         P_ROLE_NAME );
         RETURN ret_value;
   END DB_MAPPING_TYPE;
   FUNCTION DB_SQL_SYNTAX(
      P_FROM_CLASS_NAME IN VARCHAR2,
      P_TO_CLASS_NAME IN VARCHAR2,
      P_ROLE_NAME IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (4000) ;
   BEGIN
      ret_value := EC_CLASS_REL_DB_MAPPING.DB_SQL_SYNTAX      (
         P_FROM_CLASS_NAME,
         P_TO_CLASS_NAME,
         P_ROLE_NAME );
         RETURN ret_value;
   END DB_SQL_SYNTAX;
   FUNCTION RECORD_STATUS(
      P_FROM_CLASS_NAME IN VARCHAR2,
      P_TO_CLASS_NAME IN VARCHAR2,
      P_ROLE_NAME IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_CLASS_REL_DB_MAPPING.RECORD_STATUS      (
         P_FROM_CLASS_NAME,
         P_TO_CLASS_NAME,
         P_ROLE_NAME );
         RETURN ret_value;
   END RECORD_STATUS;
   FUNCTION APPROVAL_DATE(
      P_FROM_CLASS_NAME IN VARCHAR2,
      P_TO_CLASS_NAME IN VARCHAR2,
      P_ROLE_NAME IN VARCHAR2)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CLASS_REL_DB_MAPPING.APPROVAL_DATE      (
         P_FROM_CLASS_NAME,
         P_TO_CLASS_NAME,
         P_ROLE_NAME );
         RETURN ret_value;
   END APPROVAL_DATE;
   FUNCTION ROW_BY_PK(
      P_FROM_CLASS_NAME IN VARCHAR2,
      P_TO_CLASS_NAME IN VARCHAR2,
      P_ROLE_NAME IN VARCHAR2)
      RETURN REC_ROW_BY_PK
   IS
      ret_value    REC_ROW_BY_PK ;
   BEGIN
      ret_value := EC_CLASS_REL_DB_MAPPING.ROW_BY_PK      (
         P_FROM_CLASS_NAME,
         P_TO_CLASS_NAME,
         P_ROLE_NAME );
         RETURN ret_value;
   END ROW_BY_PK;
   FUNCTION REC_ID(
      P_FROM_CLASS_NAME IN VARCHAR2,
      P_TO_CLASS_NAME IN VARCHAR2,
      P_ROLE_NAME IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_CLASS_REL_DB_MAPPING.REC_ID      (
         P_FROM_CLASS_NAME,
         P_TO_CLASS_NAME,
         P_ROLE_NAME );
         RETURN ret_value;
   END REC_ID;

END RP_CLASS_REL_DB_MAPPING;

/
--GRANT EXECUTE ON ECKERNEL_WST.RP_CLASS_REL_DB_MAPPING TO REPORT_ROLE_XXX;



 -- FINISH PKG_GEN_PKGS.sf_get_functions at:11/15/2018 10.44.01 AM


