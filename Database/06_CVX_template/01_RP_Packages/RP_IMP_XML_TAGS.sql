
 -- START PKG_GEN_PKGS.sf_get_functions at:05/07/2019 09.19.34 AM


CREATE or REPLACE PACKAGE RP_IMP_XML_TAGS
IS

   FUNCTION NAME(
      P_INTERFACE_CODE IN VARCHAR2,
      P_PATH IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION TEXT_4(
      P_INTERFACE_CODE IN VARCHAR2,
      P_PATH IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_BY(
      P_INTERFACE_CODE IN VARCHAR2,
      P_PATH IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_STATE(
      P_INTERFACE_CODE IN VARCHAR2,
      P_PATH IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION TEXT_5(
      P_INTERFACE_CODE IN VARCHAR2,
      P_PATH IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION RECORD_STATUS(
      P_INTERFACE_CODE IN VARCHAR2,
      P_PATH IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_DATE(
      P_INTERFACE_CODE IN VARCHAR2,
      P_PATH IN VARCHAR2)
      RETURN DATE;
      TYPE REC_ROW_BY_PK IS RECORD (
         INTERFACE_CODE VARCHAR2 (255) ,
         NAME VARCHAR2 (255) ,
         PATH VARCHAR2 (255) ,
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
      P_INTERFACE_CODE IN VARCHAR2,
      P_PATH IN VARCHAR2)
      RETURN REC_ROW_BY_PK;
   FUNCTION TEXT_2(
      P_INTERFACE_CODE IN VARCHAR2,
      P_PATH IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION REC_ID(
      P_INTERFACE_CODE IN VARCHAR2,
      P_PATH IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION TEXT_1(
      P_INTERFACE_CODE IN VARCHAR2,
      P_PATH IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION TEXT_3(
      P_INTERFACE_CODE IN VARCHAR2,
      P_PATH IN VARCHAR2)
      RETURN VARCHAR2;

END RP_IMP_XML_TAGS;

/



CREATE or REPLACE PACKAGE BODY RP_IMP_XML_TAGS
IS

   FUNCTION NAME(
      P_INTERFACE_CODE IN VARCHAR2,
      P_PATH IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (255) ;
   BEGIN
      ret_value := EC_IMP_XML_TAGS.NAME      (
         P_INTERFACE_CODE,
         P_PATH );
         RETURN ret_value;
   END NAME;
   FUNCTION TEXT_4(
      P_INTERFACE_CODE IN VARCHAR2,
      P_PATH IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_IMP_XML_TAGS.TEXT_4      (
         P_INTERFACE_CODE,
         P_PATH );
         RETURN ret_value;
   END TEXT_4;
   FUNCTION APPROVAL_BY(
      P_INTERFACE_CODE IN VARCHAR2,
      P_PATH IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (30) ;
   BEGIN
      ret_value := EC_IMP_XML_TAGS.APPROVAL_BY      (
         P_INTERFACE_CODE,
         P_PATH );
         RETURN ret_value;
   END APPROVAL_BY;
   FUNCTION APPROVAL_STATE(
      P_INTERFACE_CODE IN VARCHAR2,
      P_PATH IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_IMP_XML_TAGS.APPROVAL_STATE      (
         P_INTERFACE_CODE,
         P_PATH );
         RETURN ret_value;
   END APPROVAL_STATE;
   FUNCTION TEXT_5(
      P_INTERFACE_CODE IN VARCHAR2,
      P_PATH IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_IMP_XML_TAGS.TEXT_5      (
         P_INTERFACE_CODE,
         P_PATH );
         RETURN ret_value;
   END TEXT_5;
   FUNCTION RECORD_STATUS(
      P_INTERFACE_CODE IN VARCHAR2,
      P_PATH IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_IMP_XML_TAGS.RECORD_STATUS      (
         P_INTERFACE_CODE,
         P_PATH );
         RETURN ret_value;
   END RECORD_STATUS;
   FUNCTION APPROVAL_DATE(
      P_INTERFACE_CODE IN VARCHAR2,
      P_PATH IN VARCHAR2)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_IMP_XML_TAGS.APPROVAL_DATE      (
         P_INTERFACE_CODE,
         P_PATH );
         RETURN ret_value;
   END APPROVAL_DATE;
   FUNCTION ROW_BY_PK(
      P_INTERFACE_CODE IN VARCHAR2,
      P_PATH IN VARCHAR2)
      RETURN REC_ROW_BY_PK
   IS
      ret_value    REC_ROW_BY_PK ;
   BEGIN
      ret_value := EC_IMP_XML_TAGS.ROW_BY_PK      (
         P_INTERFACE_CODE,
         P_PATH );
         RETURN ret_value;
   END ROW_BY_PK;
   FUNCTION TEXT_2(
      P_INTERFACE_CODE IN VARCHAR2,
      P_PATH IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_IMP_XML_TAGS.TEXT_2      (
         P_INTERFACE_CODE,
         P_PATH );
         RETURN ret_value;
   END TEXT_2;
   FUNCTION REC_ID(
      P_INTERFACE_CODE IN VARCHAR2,
      P_PATH IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_IMP_XML_TAGS.REC_ID      (
         P_INTERFACE_CODE,
         P_PATH );
         RETURN ret_value;
   END REC_ID;
   FUNCTION TEXT_1(
      P_INTERFACE_CODE IN VARCHAR2,
      P_PATH IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_IMP_XML_TAGS.TEXT_1      (
         P_INTERFACE_CODE,
         P_PATH );
         RETURN ret_value;
   END TEXT_1;
   FUNCTION TEXT_3(
      P_INTERFACE_CODE IN VARCHAR2,
      P_PATH IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_IMP_XML_TAGS.TEXT_3      (
         P_INTERFACE_CODE,
         P_PATH );
         RETURN ret_value;
   END TEXT_3;

END RP_IMP_XML_TAGS;

/
--GRANT EXECUTE ON ECKERNEL_WST.RP_IMP_XML_TAGS TO REPORT_ROLE_XXX;



 -- FINISH PKG_GEN_PKGS.sf_get_functions at:05/07/2019 09.19.37 AM


