
 -- START PKG_GEN_PKGS.sf_get_functions at:11/15/2018 10.44.45 AM


CREATE or REPLACE PACKAGE RP_CLASS_ATTRIBUTE
IS

   FUNCTION DISABLED_IND(
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
   FUNCTION DEFAULT_VALUE(
      P_CLASS_NAME IN VARCHAR2,
      P_ATTRIBUTE_NAME IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION DESCRIPTION(
      P_CLASS_NAME IN VARCHAR2,
      P_ATTRIBUTE_NAME IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION PRECISION(
      P_CLASS_NAME IN VARCHAR2,
      P_ATTRIBUTE_NAME IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION CALC_MAPPING_SYNTAX(
      P_CLASS_NAME IN VARCHAR2,
      P_ATTRIBUTE_NAME IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION DISABLED_CALC_IND(
      P_CLASS_NAME IN VARCHAR2,
      P_ATTRIBUTE_NAME IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION RECORD_STATUS(
      P_CLASS_NAME IN VARCHAR2,
      P_ATTRIBUTE_NAME IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION REPORT_ONLY_IND(
      P_CLASS_NAME IN VARCHAR2,
      P_ATTRIBUTE_NAME IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_DATE(
      P_CLASS_NAME IN VARCHAR2,
      P_ATTRIBUTE_NAME IN VARCHAR2)
      RETURN DATE;
   FUNCTION IS_MANDATORY(
      P_CLASS_NAME IN VARCHAR2,
      P_ATTRIBUTE_NAME IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION NAME(
      P_CLASS_NAME IN VARCHAR2,
      P_ATTRIBUTE_NAME IN VARCHAR2)
      RETURN VARCHAR2;
      TYPE REC_ROW_BY_PK IS RECORD (
         CLASS_NAME VARCHAR2 (24) ,
         ATTRIBUTE_NAME VARCHAR2 (24) ,
         IS_KEY VARCHAR2 (1) ,
         IS_MANDATORY VARCHAR2 (1) ,
         CONTEXT_CODE VARCHAR2 (32) ,
         DATA_TYPE VARCHAR2 (32) ,
         CALC_MAPPING_SYNTAX VARCHAR2 (4000) ,
         PRECISION VARCHAR2 (32) ,
         DEFAULT_VALUE VARCHAR2 (4000) ,
         DISABLED_IND VARCHAR2 (1) ,
         DISABLED_CALC_IND VARCHAR2 (1) ,
         REPORT_ONLY_IND VARCHAR2 (1) ,
         DESCRIPTION VARCHAR2 (4000) ,
         NAME VARCHAR2 (240) ,
         DEFAULT_CLIENT_VALUE VARCHAR2 (240) ,
         READ_ONLY_IND VARCHAR2 (1) ,
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
   FUNCTION CONTEXT_CODE(
      P_CLASS_NAME IN VARCHAR2,
      P_ATTRIBUTE_NAME IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION DEFAULT_CLIENT_VALUE(
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

END RP_CLASS_ATTRIBUTE;

/



CREATE or REPLACE PACKAGE BODY RP_CLASS_ATTRIBUTE
IS

   FUNCTION DISABLED_IND(
      P_CLASS_NAME IN VARCHAR2,
      P_ATTRIBUTE_NAME IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_CLASS_ATTRIBUTE.DISABLED_IND      (
         P_CLASS_NAME,
         P_ATTRIBUTE_NAME );
         RETURN ret_value;
   END DISABLED_IND;
   FUNCTION APPROVAL_BY(
      P_CLASS_NAME IN VARCHAR2,
      P_ATTRIBUTE_NAME IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (30) ;
   BEGIN
      ret_value := EC_CLASS_ATTRIBUTE.APPROVAL_BY      (
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
      ret_value := EC_CLASS_ATTRIBUTE.APPROVAL_STATE      (
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
      ret_value := EC_CLASS_ATTRIBUTE.DATA_TYPE      (
         P_CLASS_NAME,
         P_ATTRIBUTE_NAME );
         RETURN ret_value;
   END DATA_TYPE;
   FUNCTION DEFAULT_VALUE(
      P_CLASS_NAME IN VARCHAR2,
      P_ATTRIBUTE_NAME IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (4000) ;
   BEGIN
      ret_value := EC_CLASS_ATTRIBUTE.DEFAULT_VALUE      (
         P_CLASS_NAME,
         P_ATTRIBUTE_NAME );
         RETURN ret_value;
   END DEFAULT_VALUE;
   FUNCTION DESCRIPTION(
      P_CLASS_NAME IN VARCHAR2,
      P_ATTRIBUTE_NAME IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (4000) ;
   BEGIN
      ret_value := EC_CLASS_ATTRIBUTE.DESCRIPTION      (
         P_CLASS_NAME,
         P_ATTRIBUTE_NAME );
         RETURN ret_value;
   END DESCRIPTION;
   FUNCTION PRECISION(
      P_CLASS_NAME IN VARCHAR2,
      P_ATTRIBUTE_NAME IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_CLASS_ATTRIBUTE.PRECISION      (
         P_CLASS_NAME,
         P_ATTRIBUTE_NAME );
         RETURN ret_value;
   END PRECISION;
   FUNCTION CALC_MAPPING_SYNTAX(
      P_CLASS_NAME IN VARCHAR2,
      P_ATTRIBUTE_NAME IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (4000) ;
   BEGIN
      ret_value := EC_CLASS_ATTRIBUTE.CALC_MAPPING_SYNTAX      (
         P_CLASS_NAME,
         P_ATTRIBUTE_NAME );
         RETURN ret_value;
   END CALC_MAPPING_SYNTAX;
   FUNCTION DISABLED_CALC_IND(
      P_CLASS_NAME IN VARCHAR2,
      P_ATTRIBUTE_NAME IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_CLASS_ATTRIBUTE.DISABLED_CALC_IND      (
         P_CLASS_NAME,
         P_ATTRIBUTE_NAME );
         RETURN ret_value;
   END DISABLED_CALC_IND;
   FUNCTION RECORD_STATUS(
      P_CLASS_NAME IN VARCHAR2,
      P_ATTRIBUTE_NAME IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_CLASS_ATTRIBUTE.RECORD_STATUS      (
         P_CLASS_NAME,
         P_ATTRIBUTE_NAME );
         RETURN ret_value;
   END RECORD_STATUS;
   FUNCTION REPORT_ONLY_IND(
      P_CLASS_NAME IN VARCHAR2,
      P_ATTRIBUTE_NAME IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_CLASS_ATTRIBUTE.REPORT_ONLY_IND      (
         P_CLASS_NAME,
         P_ATTRIBUTE_NAME );
         RETURN ret_value;
   END REPORT_ONLY_IND;
   FUNCTION APPROVAL_DATE(
      P_CLASS_NAME IN VARCHAR2,
      P_ATTRIBUTE_NAME IN VARCHAR2)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CLASS_ATTRIBUTE.APPROVAL_DATE      (
         P_CLASS_NAME,
         P_ATTRIBUTE_NAME );
         RETURN ret_value;
   END APPROVAL_DATE;
   FUNCTION IS_MANDATORY(
      P_CLASS_NAME IN VARCHAR2,
      P_ATTRIBUTE_NAME IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_CLASS_ATTRIBUTE.IS_MANDATORY      (
         P_CLASS_NAME,
         P_ATTRIBUTE_NAME );
         RETURN ret_value;
   END IS_MANDATORY;
   FUNCTION NAME(
      P_CLASS_NAME IN VARCHAR2,
      P_ATTRIBUTE_NAME IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_CLASS_ATTRIBUTE.NAME      (
         P_CLASS_NAME,
         P_ATTRIBUTE_NAME );
         RETURN ret_value;
   END NAME;
   FUNCTION ROW_BY_PK(
      P_CLASS_NAME IN VARCHAR2,
      P_ATTRIBUTE_NAME IN VARCHAR2)
      RETURN REC_ROW_BY_PK
   IS
      ret_value    REC_ROW_BY_PK ;
   BEGIN
      ret_value := EC_CLASS_ATTRIBUTE.ROW_BY_PK      (
         P_CLASS_NAME,
         P_ATTRIBUTE_NAME );
         RETURN ret_value;
   END ROW_BY_PK;
   FUNCTION CONTEXT_CODE(
      P_CLASS_NAME IN VARCHAR2,
      P_ATTRIBUTE_NAME IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_CLASS_ATTRIBUTE.CONTEXT_CODE      (
         P_CLASS_NAME,
         P_ATTRIBUTE_NAME );
         RETURN ret_value;
   END CONTEXT_CODE;
   FUNCTION DEFAULT_CLIENT_VALUE(
      P_CLASS_NAME IN VARCHAR2,
      P_ATTRIBUTE_NAME IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_CLASS_ATTRIBUTE.DEFAULT_CLIENT_VALUE      (
         P_CLASS_NAME,
         P_ATTRIBUTE_NAME );
         RETURN ret_value;
   END DEFAULT_CLIENT_VALUE;
   FUNCTION IS_KEY(
      P_CLASS_NAME IN VARCHAR2,
      P_ATTRIBUTE_NAME IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_CLASS_ATTRIBUTE.IS_KEY      (
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
      ret_value := EC_CLASS_ATTRIBUTE.REC_ID      (
         P_CLASS_NAME,
         P_ATTRIBUTE_NAME );
         RETURN ret_value;
   END REC_ID;

END RP_CLASS_ATTRIBUTE;

/
--GRANT EXECUTE ON ECKERNEL_WST.RP_CLASS_ATTRIBUTE TO REPORT_ROLE_XXX;



 -- FINISH PKG_GEN_PKGS.sf_get_functions at:11/15/2018 10.44.50 AM

