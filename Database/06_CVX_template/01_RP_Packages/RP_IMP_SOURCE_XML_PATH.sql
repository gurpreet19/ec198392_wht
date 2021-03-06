
 -- START PKG_GEN_PKGS.sf_get_functions at:05/07/2019 09.19.46 AM


CREATE or REPLACE PACKAGE RP_IMP_SOURCE_XML_PATH
IS

   FUNCTION SORT_ORDER(
      P_IMP_SOURCE_XML_PATH_NO IN NUMBER,
      P_IMP_SOURCE_MAPPING_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION TEXT_4(
      P_IMP_SOURCE_XML_PATH_NO IN NUMBER,
      P_IMP_SOURCE_MAPPING_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_BY(
      P_IMP_SOURCE_XML_PATH_NO IN NUMBER,
      P_IMP_SOURCE_MAPPING_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_STATE(
      P_IMP_SOURCE_XML_PATH_NO IN NUMBER,
      P_IMP_SOURCE_MAPPING_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION ALT_PATH(
      P_IMP_SOURCE_XML_PATH_NO IN NUMBER,
      P_IMP_SOURCE_MAPPING_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION PATH(
      P_IMP_SOURCE_XML_PATH_NO IN NUMBER,
      P_IMP_SOURCE_MAPPING_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_5(
      P_IMP_SOURCE_XML_PATH_NO IN NUMBER,
      P_IMP_SOURCE_MAPPING_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION CONDITION(
      P_IMP_SOURCE_XML_PATH_NO IN NUMBER,
      P_IMP_SOURCE_MAPPING_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION RECORD_STATUS(
      P_IMP_SOURCE_XML_PATH_NO IN NUMBER,
      P_IMP_SOURCE_MAPPING_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_DATE(
      P_IMP_SOURCE_XML_PATH_NO IN NUMBER,
      P_IMP_SOURCE_MAPPING_NO IN NUMBER)
      RETURN DATE;
      TYPE REC_ROW_BY_PK IS RECORD (
         IMP_SOURCE_XML_PATH_NO NUMBER ,
         IMP_SOURCE_MAPPING_NO NUMBER ,
         SORT_ORDER NUMBER ,
         PATH VARCHAR2 (2000) ,
         ALT_PATH VARCHAR2 (2000) ,
         CONDITION VARCHAR2 (2000) ,
         PARENT_MAPPING_CODE VARCHAR2 (32) ,
         TEXT_1 VARCHAR2 (2000) ,
         TEXT_2 VARCHAR2 (2000) ,
         TEXT_3 VARCHAR2 (2000) ,
         TEXT_4 VARCHAR2 (2000) ,
         TEXT_5 VARCHAR2 (2000) ,
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
      P_IMP_SOURCE_XML_PATH_NO IN NUMBER,
      P_IMP_SOURCE_MAPPING_NO IN NUMBER)
      RETURN REC_ROW_BY_PK;
   FUNCTION TEXT_2(
      P_IMP_SOURCE_XML_PATH_NO IN NUMBER,
      P_IMP_SOURCE_MAPPING_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION PARENT_MAPPING_CODE(
      P_IMP_SOURCE_XML_PATH_NO IN NUMBER,
      P_IMP_SOURCE_MAPPING_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION REC_ID(
      P_IMP_SOURCE_XML_PATH_NO IN NUMBER,
      P_IMP_SOURCE_MAPPING_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_1(
      P_IMP_SOURCE_XML_PATH_NO IN NUMBER,
      P_IMP_SOURCE_MAPPING_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_3(
      P_IMP_SOURCE_XML_PATH_NO IN NUMBER,
      P_IMP_SOURCE_MAPPING_NO IN NUMBER)
      RETURN VARCHAR2;

END RP_IMP_SOURCE_XML_PATH;

/



CREATE or REPLACE PACKAGE BODY RP_IMP_SOURCE_XML_PATH
IS

   FUNCTION SORT_ORDER(
      P_IMP_SOURCE_XML_PATH_NO IN NUMBER,
      P_IMP_SOURCE_MAPPING_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_IMP_SOURCE_XML_PATH.SORT_ORDER      (
         P_IMP_SOURCE_XML_PATH_NO,
         P_IMP_SOURCE_MAPPING_NO );
         RETURN ret_value;
   END SORT_ORDER;
   FUNCTION TEXT_4(
      P_IMP_SOURCE_XML_PATH_NO IN NUMBER,
      P_IMP_SOURCE_MAPPING_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_IMP_SOURCE_XML_PATH.TEXT_4      (
         P_IMP_SOURCE_XML_PATH_NO,
         P_IMP_SOURCE_MAPPING_NO );
         RETURN ret_value;
   END TEXT_4;
   FUNCTION APPROVAL_BY(
      P_IMP_SOURCE_XML_PATH_NO IN NUMBER,
      P_IMP_SOURCE_MAPPING_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (30) ;
   BEGIN
      ret_value := EC_IMP_SOURCE_XML_PATH.APPROVAL_BY      (
         P_IMP_SOURCE_XML_PATH_NO,
         P_IMP_SOURCE_MAPPING_NO );
         RETURN ret_value;
   END APPROVAL_BY;
   FUNCTION APPROVAL_STATE(
      P_IMP_SOURCE_XML_PATH_NO IN NUMBER,
      P_IMP_SOURCE_MAPPING_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_IMP_SOURCE_XML_PATH.APPROVAL_STATE      (
         P_IMP_SOURCE_XML_PATH_NO,
         P_IMP_SOURCE_MAPPING_NO );
         RETURN ret_value;
   END APPROVAL_STATE;
   FUNCTION ALT_PATH(
      P_IMP_SOURCE_XML_PATH_NO IN NUMBER,
      P_IMP_SOURCE_MAPPING_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_IMP_SOURCE_XML_PATH.ALT_PATH      (
         P_IMP_SOURCE_XML_PATH_NO,
         P_IMP_SOURCE_MAPPING_NO );
         RETURN ret_value;
   END ALT_PATH;
   FUNCTION PATH(
      P_IMP_SOURCE_XML_PATH_NO IN NUMBER,
      P_IMP_SOURCE_MAPPING_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_IMP_SOURCE_XML_PATH.PATH      (
         P_IMP_SOURCE_XML_PATH_NO,
         P_IMP_SOURCE_MAPPING_NO );
         RETURN ret_value;
   END PATH;
   FUNCTION TEXT_5(
      P_IMP_SOURCE_XML_PATH_NO IN NUMBER,
      P_IMP_SOURCE_MAPPING_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_IMP_SOURCE_XML_PATH.TEXT_5      (
         P_IMP_SOURCE_XML_PATH_NO,
         P_IMP_SOURCE_MAPPING_NO );
         RETURN ret_value;
   END TEXT_5;
   FUNCTION CONDITION(
      P_IMP_SOURCE_XML_PATH_NO IN NUMBER,
      P_IMP_SOURCE_MAPPING_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_IMP_SOURCE_XML_PATH.CONDITION      (
         P_IMP_SOURCE_XML_PATH_NO,
         P_IMP_SOURCE_MAPPING_NO );
         RETURN ret_value;
   END CONDITION;
   FUNCTION RECORD_STATUS(
      P_IMP_SOURCE_XML_PATH_NO IN NUMBER,
      P_IMP_SOURCE_MAPPING_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_IMP_SOURCE_XML_PATH.RECORD_STATUS      (
         P_IMP_SOURCE_XML_PATH_NO,
         P_IMP_SOURCE_MAPPING_NO );
         RETURN ret_value;
   END RECORD_STATUS;
   FUNCTION APPROVAL_DATE(
      P_IMP_SOURCE_XML_PATH_NO IN NUMBER,
      P_IMP_SOURCE_MAPPING_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_IMP_SOURCE_XML_PATH.APPROVAL_DATE      (
         P_IMP_SOURCE_XML_PATH_NO,
         P_IMP_SOURCE_MAPPING_NO );
         RETURN ret_value;
   END APPROVAL_DATE;
   FUNCTION ROW_BY_PK(
      P_IMP_SOURCE_XML_PATH_NO IN NUMBER,
      P_IMP_SOURCE_MAPPING_NO IN NUMBER)
      RETURN REC_ROW_BY_PK
   IS
      ret_value    REC_ROW_BY_PK ;
   BEGIN
      ret_value := EC_IMP_SOURCE_XML_PATH.ROW_BY_PK      (
         P_IMP_SOURCE_XML_PATH_NO,
         P_IMP_SOURCE_MAPPING_NO );
         RETURN ret_value;
   END ROW_BY_PK;
   FUNCTION TEXT_2(
      P_IMP_SOURCE_XML_PATH_NO IN NUMBER,
      P_IMP_SOURCE_MAPPING_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_IMP_SOURCE_XML_PATH.TEXT_2      (
         P_IMP_SOURCE_XML_PATH_NO,
         P_IMP_SOURCE_MAPPING_NO );
         RETURN ret_value;
   END TEXT_2;
   FUNCTION PARENT_MAPPING_CODE(
      P_IMP_SOURCE_XML_PATH_NO IN NUMBER,
      P_IMP_SOURCE_MAPPING_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_IMP_SOURCE_XML_PATH.PARENT_MAPPING_CODE      (
         P_IMP_SOURCE_XML_PATH_NO,
         P_IMP_SOURCE_MAPPING_NO );
         RETURN ret_value;
   END PARENT_MAPPING_CODE;
   FUNCTION REC_ID(
      P_IMP_SOURCE_XML_PATH_NO IN NUMBER,
      P_IMP_SOURCE_MAPPING_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_IMP_SOURCE_XML_PATH.REC_ID      (
         P_IMP_SOURCE_XML_PATH_NO,
         P_IMP_SOURCE_MAPPING_NO );
         RETURN ret_value;
   END REC_ID;
   FUNCTION TEXT_1(
      P_IMP_SOURCE_XML_PATH_NO IN NUMBER,
      P_IMP_SOURCE_MAPPING_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_IMP_SOURCE_XML_PATH.TEXT_1      (
         P_IMP_SOURCE_XML_PATH_NO,
         P_IMP_SOURCE_MAPPING_NO );
         RETURN ret_value;
   END TEXT_1;
   FUNCTION TEXT_3(
      P_IMP_SOURCE_XML_PATH_NO IN NUMBER,
      P_IMP_SOURCE_MAPPING_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_IMP_SOURCE_XML_PATH.TEXT_3      (
         P_IMP_SOURCE_XML_PATH_NO,
         P_IMP_SOURCE_MAPPING_NO );
         RETURN ret_value;
   END TEXT_3;

END RP_IMP_SOURCE_XML_PATH;

/
--GRANT EXECUTE ON ECKERNEL_WST.RP_IMP_SOURCE_XML_PATH TO REPORT_ROLE_XXX;



 -- FINISH PKG_GEN_PKGS.sf_get_functions at:05/07/2019 09.19.50 AM


