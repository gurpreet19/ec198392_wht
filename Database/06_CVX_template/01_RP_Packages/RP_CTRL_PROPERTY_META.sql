
 -- START PKG_GEN_PKGS.sf_get_functions at:11/15/2018 10.17.51 AM


CREATE or REPLACE PACKAGE RP_CTRL_PROPERTY_META
IS

   FUNCTION DEFAULT_VALUE_NUMBER(
      P_KEY IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION LABEL(
      P_KEY IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION LIST_OF_VALUES(
      P_KEY IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_BY(
      P_KEY IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_STATE(
      P_KEY IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION VERSION_TYPE(
      P_KEY IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION RECORD_STATUS(
      P_KEY IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_DATE(
      P_KEY IN VARCHAR2)
      RETURN DATE;
   FUNCTION DATATYPE(
      P_KEY IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION DEFAULT_VALUE_DATE(
      P_KEY IN VARCHAR2)
      RETURN DATE;
   FUNCTION DESCRIPTION(
      P_KEY IN VARCHAR2)
      RETURN VARCHAR2;
      TYPE REC_ROW_BY_PK IS RECORD (
         KEY VARCHAR2 (1000) ,
         VERSION_TYPE VARCHAR2 (32) ,
         DATATYPE VARCHAR2 (32) ,
         REQUIRED VARCHAR2 (1) ,
         DEFAULT_VALUE_STRING VARCHAR2 (2000) ,
         DEFAULT_VALUE_NUMBER NUMBER ,
         DEFAULT_VALUE_DATE  DATE ,
         LIST_OF_VALUES VARCHAR2 (2000) ,
         LABEL VARCHAR2 (255) ,
         CATEGORY VARCHAR2 (32) ,
         DESCRIPTION VARCHAR2 (240) ,
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
      P_KEY IN VARCHAR2)
      RETURN REC_ROW_BY_PK;
   FUNCTION CATEGORY(
      P_KEY IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION DEFAULT_VALUE_STRING(
      P_KEY IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION REC_ID(
      P_KEY IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION REQUIRED(
      P_KEY IN VARCHAR2)
      RETURN VARCHAR2;

END RP_CTRL_PROPERTY_META;

/



CREATE or REPLACE PACKAGE BODY RP_CTRL_PROPERTY_META
IS

   FUNCTION DEFAULT_VALUE_NUMBER(
      P_KEY IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CTRL_PROPERTY_META.DEFAULT_VALUE_NUMBER      (
         P_KEY );
         RETURN ret_value;
   END DEFAULT_VALUE_NUMBER;
   FUNCTION LABEL(
      P_KEY IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (255) ;
   BEGIN
      ret_value := EC_CTRL_PROPERTY_META.LABEL      (
         P_KEY );
         RETURN ret_value;
   END LABEL;
   FUNCTION LIST_OF_VALUES(
      P_KEY IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_CTRL_PROPERTY_META.LIST_OF_VALUES      (
         P_KEY );
         RETURN ret_value;
   END LIST_OF_VALUES;
   FUNCTION APPROVAL_BY(
      P_KEY IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (30) ;
   BEGIN
      ret_value := EC_CTRL_PROPERTY_META.APPROVAL_BY      (
         P_KEY );
         RETURN ret_value;
   END APPROVAL_BY;
   FUNCTION APPROVAL_STATE(
      P_KEY IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_CTRL_PROPERTY_META.APPROVAL_STATE      (
         P_KEY );
         RETURN ret_value;
   END APPROVAL_STATE;
   FUNCTION VERSION_TYPE(
      P_KEY IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_CTRL_PROPERTY_META.VERSION_TYPE      (
         P_KEY );
         RETURN ret_value;
   END VERSION_TYPE;
   FUNCTION RECORD_STATUS(
      P_KEY IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_CTRL_PROPERTY_META.RECORD_STATUS      (
         P_KEY );
         RETURN ret_value;
   END RECORD_STATUS;
   FUNCTION APPROVAL_DATE(
      P_KEY IN VARCHAR2)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CTRL_PROPERTY_META.APPROVAL_DATE      (
         P_KEY );
         RETURN ret_value;
   END APPROVAL_DATE;
   FUNCTION DATATYPE(
      P_KEY IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_CTRL_PROPERTY_META.DATATYPE      (
         P_KEY );
         RETURN ret_value;
   END DATATYPE;
   FUNCTION DEFAULT_VALUE_DATE(
      P_KEY IN VARCHAR2)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CTRL_PROPERTY_META.DEFAULT_VALUE_DATE      (
         P_KEY );
         RETURN ret_value;
   END DEFAULT_VALUE_DATE;
   FUNCTION DESCRIPTION(
      P_KEY IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_CTRL_PROPERTY_META.DESCRIPTION      (
         P_KEY );
         RETURN ret_value;
   END DESCRIPTION;
   FUNCTION ROW_BY_PK(
      P_KEY IN VARCHAR2)
      RETURN REC_ROW_BY_PK
   IS
      ret_value    REC_ROW_BY_PK ;
   BEGIN
      ret_value := EC_CTRL_PROPERTY_META.ROW_BY_PK      (
         P_KEY );
         RETURN ret_value;
   END ROW_BY_PK;
   FUNCTION CATEGORY(
      P_KEY IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_CTRL_PROPERTY_META.CATEGORY      (
         P_KEY );
         RETURN ret_value;
   END CATEGORY;
   FUNCTION DEFAULT_VALUE_STRING(
      P_KEY IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_CTRL_PROPERTY_META.DEFAULT_VALUE_STRING      (
         P_KEY );
         RETURN ret_value;
   END DEFAULT_VALUE_STRING;
   FUNCTION REC_ID(
      P_KEY IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_CTRL_PROPERTY_META.REC_ID      (
         P_KEY );
         RETURN ret_value;
   END REC_ID;
   FUNCTION REQUIRED(
      P_KEY IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_CTRL_PROPERTY_META.REQUIRED      (
         P_KEY );
         RETURN ret_value;
   END REQUIRED;

END RP_CTRL_PROPERTY_META;

/
--GRANT EXECUTE ON ECKERNEL_WST.RP_CTRL_PROPERTY_META TO REPORT_ROLE_XXX;



 -- FINISH PKG_GEN_PKGS.sf_get_functions at:11/15/2018 10.17.54 AM


