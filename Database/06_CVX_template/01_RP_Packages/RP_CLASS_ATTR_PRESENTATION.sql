
 -- START PKG_GEN_PKGS.sf_get_functions at:11/15/2018 10.44.33 AM


CREATE or REPLACE PACKAGE RP_CLASS_ATTR_PRESENTATION
IS

   FUNCTION SORT_ORDER(
      P_CLASS_NAME IN VARCHAR2,
      P_ATTRIBUTE_NAME IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION APPROVAL_BY(
      P_CLASS_NAME IN VARCHAR2,
      P_ATTRIBUTE_NAME IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_STATE(
      P_CLASS_NAME IN VARCHAR2,
      P_ATTRIBUTE_NAME IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION LABEL_ID(
      P_CLASS_NAME IN VARCHAR2,
      P_ATTRIBUTE_NAME IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION STATIC_PRESENTATION_SYNTAX(
      P_CLASS_NAME IN VARCHAR2,
      P_ATTRIBUTE_NAME IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION DB_PRES_SYNTAX(
      P_CLASS_NAME IN VARCHAR2,
      P_ATTRIBUTE_NAME IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION RECORD_STATUS(
      P_CLASS_NAME IN VARCHAR2,
      P_ATTRIBUTE_NAME IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION UOM_CODE(
      P_CLASS_NAME IN VARCHAR2,
      P_ATTRIBUTE_NAME IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_DATE(
      P_CLASS_NAME IN VARCHAR2,
      P_ATTRIBUTE_NAME IN VARCHAR2)
      RETURN DATE;
   FUNCTION PRESENTATION_SYNTAX(
      P_CLASS_NAME IN VARCHAR2,
      P_ATTRIBUTE_NAME IN VARCHAR2)
      RETURN VARCHAR2;
      TYPE REC_ROW_BY_PK IS RECORD (
         CLASS_NAME VARCHAR2 (24) ,
         ATTRIBUTE_NAME VARCHAR2 (24) ,
         PRESENTATION_SYNTAX VARCHAR2 (4000) ,
         STATIC_PRESENTATION_SYNTAX VARCHAR2 (4000) ,
         SORT_ORDER NUMBER ,
         DB_PRES_SYNTAX VARCHAR2 (4000) ,
         LABEL_ID VARCHAR2 (32) ,
         LABEL VARCHAR2 (64) ,
         UOM_CODE VARCHAR2 (32) ,
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
   FUNCTION REC_ID(
      P_CLASS_NAME IN VARCHAR2,
      P_ATTRIBUTE_NAME IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION LABEL(
      P_CLASS_NAME IN VARCHAR2,
      P_ATTRIBUTE_NAME IN VARCHAR2)
      RETURN VARCHAR2;

END RP_CLASS_ATTR_PRESENTATION;

/



CREATE or REPLACE PACKAGE BODY RP_CLASS_ATTR_PRESENTATION
IS

   FUNCTION SORT_ORDER(
      P_CLASS_NAME IN VARCHAR2,
      P_ATTRIBUTE_NAME IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CLASS_ATTR_PRESENTATION.SORT_ORDER      (
         P_CLASS_NAME,
         P_ATTRIBUTE_NAME );
         RETURN ret_value;
   END SORT_ORDER;
   FUNCTION APPROVAL_BY(
      P_CLASS_NAME IN VARCHAR2,
      P_ATTRIBUTE_NAME IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (30) ;
   BEGIN
      ret_value := EC_CLASS_ATTR_PRESENTATION.APPROVAL_BY      (
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
      ret_value := EC_CLASS_ATTR_PRESENTATION.APPROVAL_STATE      (
         P_CLASS_NAME,
         P_ATTRIBUTE_NAME );
         RETURN ret_value;
   END APPROVAL_STATE;
   FUNCTION LABEL_ID(
      P_CLASS_NAME IN VARCHAR2,
      P_ATTRIBUTE_NAME IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_CLASS_ATTR_PRESENTATION.LABEL_ID      (
         P_CLASS_NAME,
         P_ATTRIBUTE_NAME );
         RETURN ret_value;
   END LABEL_ID;
   FUNCTION STATIC_PRESENTATION_SYNTAX(
      P_CLASS_NAME IN VARCHAR2,
      P_ATTRIBUTE_NAME IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (4000) ;
   BEGIN
      ret_value := EC_CLASS_ATTR_PRESENTATION.STATIC_PRESENTATION_SYNTAX      (
         P_CLASS_NAME,
         P_ATTRIBUTE_NAME );
         RETURN ret_value;
   END STATIC_PRESENTATION_SYNTAX;
   FUNCTION DB_PRES_SYNTAX(
      P_CLASS_NAME IN VARCHAR2,
      P_ATTRIBUTE_NAME IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (4000) ;
   BEGIN
      ret_value := EC_CLASS_ATTR_PRESENTATION.DB_PRES_SYNTAX      (
         P_CLASS_NAME,
         P_ATTRIBUTE_NAME );
         RETURN ret_value;
   END DB_PRES_SYNTAX;
   FUNCTION RECORD_STATUS(
      P_CLASS_NAME IN VARCHAR2,
      P_ATTRIBUTE_NAME IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_CLASS_ATTR_PRESENTATION.RECORD_STATUS      (
         P_CLASS_NAME,
         P_ATTRIBUTE_NAME );
         RETURN ret_value;
   END RECORD_STATUS;
   FUNCTION UOM_CODE(
      P_CLASS_NAME IN VARCHAR2,
      P_ATTRIBUTE_NAME IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_CLASS_ATTR_PRESENTATION.UOM_CODE      (
         P_CLASS_NAME,
         P_ATTRIBUTE_NAME );
         RETURN ret_value;
   END UOM_CODE;
   FUNCTION APPROVAL_DATE(
      P_CLASS_NAME IN VARCHAR2,
      P_ATTRIBUTE_NAME IN VARCHAR2)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CLASS_ATTR_PRESENTATION.APPROVAL_DATE      (
         P_CLASS_NAME,
         P_ATTRIBUTE_NAME );
         RETURN ret_value;
   END APPROVAL_DATE;
   FUNCTION PRESENTATION_SYNTAX(
      P_CLASS_NAME IN VARCHAR2,
      P_ATTRIBUTE_NAME IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (4000) ;
   BEGIN
      ret_value := EC_CLASS_ATTR_PRESENTATION.PRESENTATION_SYNTAX      (
         P_CLASS_NAME,
         P_ATTRIBUTE_NAME );
         RETURN ret_value;
   END PRESENTATION_SYNTAX;
   FUNCTION ROW_BY_PK(
      P_CLASS_NAME IN VARCHAR2,
      P_ATTRIBUTE_NAME IN VARCHAR2)
      RETURN REC_ROW_BY_PK
   IS
      ret_value    REC_ROW_BY_PK ;
   BEGIN
      ret_value := EC_CLASS_ATTR_PRESENTATION.ROW_BY_PK      (
         P_CLASS_NAME,
         P_ATTRIBUTE_NAME );
         RETURN ret_value;
   END ROW_BY_PK;
   FUNCTION REC_ID(
      P_CLASS_NAME IN VARCHAR2,
      P_ATTRIBUTE_NAME IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_CLASS_ATTR_PRESENTATION.REC_ID      (
         P_CLASS_NAME,
         P_ATTRIBUTE_NAME );
         RETURN ret_value;
   END REC_ID;
   FUNCTION LABEL(
      P_CLASS_NAME IN VARCHAR2,
      P_ATTRIBUTE_NAME IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (64) ;
   BEGIN
      ret_value := EC_CLASS_ATTR_PRESENTATION.LABEL      (
         P_CLASS_NAME,
         P_ATTRIBUTE_NAME );
         RETURN ret_value;
   END LABEL;

END RP_CLASS_ATTR_PRESENTATION;

/
--GRANT EXECUTE ON ECKERNEL_WST.RP_CLASS_ATTR_PRESENTATION TO REPORT_ROLE_XXX;



 -- FINISH PKG_GEN_PKGS.sf_get_functions at:11/15/2018 10.44.36 AM

