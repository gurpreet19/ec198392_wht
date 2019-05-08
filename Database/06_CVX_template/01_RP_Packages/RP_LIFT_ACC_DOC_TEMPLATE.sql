
 -- START PKG_GEN_PKGS.sf_get_functions at:05/07/2019 09.10.56 AM


CREATE or REPLACE PACKAGE RP_LIFT_ACC_DOC_TEMPLATE
IS

   FUNCTION TEXT_3(
      P_OBJECT_ID IN VARCHAR2,
      P_TEMPLATE_CODE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION TEXT_4(
      P_OBJECT_ID IN VARCHAR2,
      P_TEMPLATE_CODE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_BY(
      P_OBJECT_ID IN VARCHAR2,
      P_TEMPLATE_CODE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_STATE(
      P_OBJECT_ID IN VARCHAR2,
      P_TEMPLATE_CODE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION TEMPLATE_NAME(
      P_OBJECT_ID IN VARCHAR2,
      P_TEMPLATE_CODE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION VALUE_5(
      P_OBJECT_ID IN VARCHAR2,
      P_TEMPLATE_CODE IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION DEFAULT_IND(
      P_OBJECT_ID IN VARCHAR2,
      P_TEMPLATE_CODE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION VALUE_6(
      P_OBJECT_ID IN VARCHAR2,
      P_TEMPLATE_CODE IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION CARGO_DOC_TEMPLATE_CODE(
      P_OBJECT_ID IN VARCHAR2,
      P_TEMPLATE_CODE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION RECORD_STATUS(
      P_OBJECT_ID IN VARCHAR2,
      P_TEMPLATE_CODE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION VALUE_1(
      P_OBJECT_ID IN VARCHAR2,
      P_TEMPLATE_CODE IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION APPROVAL_DATE(
      P_OBJECT_ID IN VARCHAR2,
      P_TEMPLATE_CODE IN VARCHAR2)
      RETURN DATE;
      TYPE REC_ROW_BY_PK IS RECORD (
         OBJECT_ID VARCHAR2 (32) ,
         TEMPLATE_CODE VARCHAR2 (32) ,
         TEMPLATE_NAME VARCHAR2 (32) ,
         DEFAULT_IND VARCHAR2 (32) ,
         CARGO_DOC_TEMPLATE_CODE VARCHAR2 (32) ,
         VALUE_1 NUMBER ,
         VALUE_2 NUMBER ,
         VALUE_3 NUMBER ,
         VALUE_4 NUMBER ,
         VALUE_5 NUMBER ,
         VALUE_6 NUMBER ,
         VALUE_7 NUMBER ,
         VALUE_8 NUMBER ,
         VALUE_9 NUMBER ,
         VALUE_10 NUMBER ,
         TEXT_1 VARCHAR2 (16) ,
         TEXT_2 VARCHAR2 (32) ,
         TEXT_3 VARCHAR2 (240) ,
         TEXT_4 VARCHAR2 (2000) ,
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
      P_OBJECT_ID IN VARCHAR2,
      P_TEMPLATE_CODE IN VARCHAR2)
      RETURN REC_ROW_BY_PK;
   FUNCTION VALUE_2(
      P_OBJECT_ID IN VARCHAR2,
      P_TEMPLATE_CODE IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION VALUE_3(
      P_OBJECT_ID IN VARCHAR2,
      P_TEMPLATE_CODE IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION VALUE_4(
      P_OBJECT_ID IN VARCHAR2,
      P_TEMPLATE_CODE IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION REC_ID(
      P_OBJECT_ID IN VARCHAR2,
      P_TEMPLATE_CODE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION TEXT_1(
      P_OBJECT_ID IN VARCHAR2,
      P_TEMPLATE_CODE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION TEXT_2(
      P_OBJECT_ID IN VARCHAR2,
      P_TEMPLATE_CODE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION VALUE_7(
      P_OBJECT_ID IN VARCHAR2,
      P_TEMPLATE_CODE IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION VALUE_9(
      P_OBJECT_ID IN VARCHAR2,
      P_TEMPLATE_CODE IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION VALUE_10(
      P_OBJECT_ID IN VARCHAR2,
      P_TEMPLATE_CODE IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION VALUE_8(
      P_OBJECT_ID IN VARCHAR2,
      P_TEMPLATE_CODE IN VARCHAR2)
      RETURN NUMBER;

END RP_LIFT_ACC_DOC_TEMPLATE;

/



CREATE or REPLACE PACKAGE BODY RP_LIFT_ACC_DOC_TEMPLATE
IS

   FUNCTION TEXT_3(
      P_OBJECT_ID IN VARCHAR2,
      P_TEMPLATE_CODE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_LIFT_ACC_DOC_TEMPLATE.TEXT_3      (
         P_OBJECT_ID,
         P_TEMPLATE_CODE );
         RETURN ret_value;
   END TEXT_3;
   FUNCTION TEXT_4(
      P_OBJECT_ID IN VARCHAR2,
      P_TEMPLATE_CODE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_LIFT_ACC_DOC_TEMPLATE.TEXT_4      (
         P_OBJECT_ID,
         P_TEMPLATE_CODE );
         RETURN ret_value;
   END TEXT_4;
   FUNCTION APPROVAL_BY(
      P_OBJECT_ID IN VARCHAR2,
      P_TEMPLATE_CODE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (30) ;
   BEGIN
      ret_value := EC_LIFT_ACC_DOC_TEMPLATE.APPROVAL_BY      (
         P_OBJECT_ID,
         P_TEMPLATE_CODE );
         RETURN ret_value;
   END APPROVAL_BY;
   FUNCTION APPROVAL_STATE(
      P_OBJECT_ID IN VARCHAR2,
      P_TEMPLATE_CODE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_LIFT_ACC_DOC_TEMPLATE.APPROVAL_STATE      (
         P_OBJECT_ID,
         P_TEMPLATE_CODE );
         RETURN ret_value;
   END APPROVAL_STATE;
   FUNCTION TEMPLATE_NAME(
      P_OBJECT_ID IN VARCHAR2,
      P_TEMPLATE_CODE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_LIFT_ACC_DOC_TEMPLATE.TEMPLATE_NAME      (
         P_OBJECT_ID,
         P_TEMPLATE_CODE );
         RETURN ret_value;
   END TEMPLATE_NAME;
   FUNCTION VALUE_5(
      P_OBJECT_ID IN VARCHAR2,
      P_TEMPLATE_CODE IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_LIFT_ACC_DOC_TEMPLATE.VALUE_5      (
         P_OBJECT_ID,
         P_TEMPLATE_CODE );
         RETURN ret_value;
   END VALUE_5;
   FUNCTION DEFAULT_IND(
      P_OBJECT_ID IN VARCHAR2,
      P_TEMPLATE_CODE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_LIFT_ACC_DOC_TEMPLATE.DEFAULT_IND      (
         P_OBJECT_ID,
         P_TEMPLATE_CODE );
         RETURN ret_value;
   END DEFAULT_IND;
   FUNCTION VALUE_6(
      P_OBJECT_ID IN VARCHAR2,
      P_TEMPLATE_CODE IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_LIFT_ACC_DOC_TEMPLATE.VALUE_6      (
         P_OBJECT_ID,
         P_TEMPLATE_CODE );
         RETURN ret_value;
   END VALUE_6;
   FUNCTION CARGO_DOC_TEMPLATE_CODE(
      P_OBJECT_ID IN VARCHAR2,
      P_TEMPLATE_CODE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_LIFT_ACC_DOC_TEMPLATE.CARGO_DOC_TEMPLATE_CODE      (
         P_OBJECT_ID,
         P_TEMPLATE_CODE );
         RETURN ret_value;
   END CARGO_DOC_TEMPLATE_CODE;
   FUNCTION RECORD_STATUS(
      P_OBJECT_ID IN VARCHAR2,
      P_TEMPLATE_CODE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_LIFT_ACC_DOC_TEMPLATE.RECORD_STATUS      (
         P_OBJECT_ID,
         P_TEMPLATE_CODE );
         RETURN ret_value;
   END RECORD_STATUS;
   FUNCTION VALUE_1(
      P_OBJECT_ID IN VARCHAR2,
      P_TEMPLATE_CODE IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_LIFT_ACC_DOC_TEMPLATE.VALUE_1      (
         P_OBJECT_ID,
         P_TEMPLATE_CODE );
         RETURN ret_value;
   END VALUE_1;
   FUNCTION APPROVAL_DATE(
      P_OBJECT_ID IN VARCHAR2,
      P_TEMPLATE_CODE IN VARCHAR2)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_LIFT_ACC_DOC_TEMPLATE.APPROVAL_DATE      (
         P_OBJECT_ID,
         P_TEMPLATE_CODE );
         RETURN ret_value;
   END APPROVAL_DATE;
   FUNCTION ROW_BY_PK(
      P_OBJECT_ID IN VARCHAR2,
      P_TEMPLATE_CODE IN VARCHAR2)
      RETURN REC_ROW_BY_PK
   IS
      ret_value    REC_ROW_BY_PK ;
   BEGIN
      ret_value := EC_LIFT_ACC_DOC_TEMPLATE.ROW_BY_PK      (
         P_OBJECT_ID,
         P_TEMPLATE_CODE );
         RETURN ret_value;
   END ROW_BY_PK;
   FUNCTION VALUE_2(
      P_OBJECT_ID IN VARCHAR2,
      P_TEMPLATE_CODE IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_LIFT_ACC_DOC_TEMPLATE.VALUE_2      (
         P_OBJECT_ID,
         P_TEMPLATE_CODE );
         RETURN ret_value;
   END VALUE_2;
   FUNCTION VALUE_3(
      P_OBJECT_ID IN VARCHAR2,
      P_TEMPLATE_CODE IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_LIFT_ACC_DOC_TEMPLATE.VALUE_3      (
         P_OBJECT_ID,
         P_TEMPLATE_CODE );
         RETURN ret_value;
   END VALUE_3;
   FUNCTION VALUE_4(
      P_OBJECT_ID IN VARCHAR2,
      P_TEMPLATE_CODE IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_LIFT_ACC_DOC_TEMPLATE.VALUE_4      (
         P_OBJECT_ID,
         P_TEMPLATE_CODE );
         RETURN ret_value;
   END VALUE_4;
   FUNCTION REC_ID(
      P_OBJECT_ID IN VARCHAR2,
      P_TEMPLATE_CODE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_LIFT_ACC_DOC_TEMPLATE.REC_ID      (
         P_OBJECT_ID,
         P_TEMPLATE_CODE );
         RETURN ret_value;
   END REC_ID;
   FUNCTION TEXT_1(
      P_OBJECT_ID IN VARCHAR2,
      P_TEMPLATE_CODE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (16) ;
   BEGIN
      ret_value := EC_LIFT_ACC_DOC_TEMPLATE.TEXT_1      (
         P_OBJECT_ID,
         P_TEMPLATE_CODE );
         RETURN ret_value;
   END TEXT_1;
   FUNCTION TEXT_2(
      P_OBJECT_ID IN VARCHAR2,
      P_TEMPLATE_CODE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_LIFT_ACC_DOC_TEMPLATE.TEXT_2      (
         P_OBJECT_ID,
         P_TEMPLATE_CODE );
         RETURN ret_value;
   END TEXT_2;
   FUNCTION VALUE_7(
      P_OBJECT_ID IN VARCHAR2,
      P_TEMPLATE_CODE IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_LIFT_ACC_DOC_TEMPLATE.VALUE_7      (
         P_OBJECT_ID,
         P_TEMPLATE_CODE );
         RETURN ret_value;
   END VALUE_7;
   FUNCTION VALUE_9(
      P_OBJECT_ID IN VARCHAR2,
      P_TEMPLATE_CODE IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_LIFT_ACC_DOC_TEMPLATE.VALUE_9      (
         P_OBJECT_ID,
         P_TEMPLATE_CODE );
         RETURN ret_value;
   END VALUE_9;
   FUNCTION VALUE_10(
      P_OBJECT_ID IN VARCHAR2,
      P_TEMPLATE_CODE IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_LIFT_ACC_DOC_TEMPLATE.VALUE_10      (
         P_OBJECT_ID,
         P_TEMPLATE_CODE );
         RETURN ret_value;
   END VALUE_10;
   FUNCTION VALUE_8(
      P_OBJECT_ID IN VARCHAR2,
      P_TEMPLATE_CODE IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_LIFT_ACC_DOC_TEMPLATE.VALUE_8      (
         P_OBJECT_ID,
         P_TEMPLATE_CODE );
         RETURN ret_value;
   END VALUE_8;

END RP_LIFT_ACC_DOC_TEMPLATE;

/
--GRANT EXECUTE ON ECKERNEL_WST.RP_LIFT_ACC_DOC_TEMPLATE TO REPORT_ROLE_XXX;



 -- FINISH PKG_GEN_PKGS.sf_get_functions at:05/07/2019 09.11.02 AM


