
 -- START PKG_GEN_PKGS.sf_get_functions at:11/15/2018 08.17.06 AM


CREATE or REPLACE PACKAGE RP_PTST_OBJECT
IS

   FUNCTION TEXT_3(
      P_TEST_NO IN NUMBER,
      P_OBJECT_ID IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION TEXT_4(
      P_TEST_NO IN NUMBER,
      P_OBJECT_ID IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_BY(
      P_TEST_NO IN NUMBER,
      P_OBJECT_ID IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_STATE(
      P_TEST_NO IN NUMBER,
      P_OBJECT_ID IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION OIL_METER_CODE(
      P_TEST_NO IN NUMBER,
      P_OBJECT_ID IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION VALUE_5(
      P_TEST_NO IN NUMBER,
      P_OBJECT_ID IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION CLASS_NAME(
      P_TEST_NO IN NUMBER,
      P_OBJECT_ID IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION VALUE_6(
      P_TEST_NO IN NUMBER,
      P_OBJECT_ID IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION RECORD_STATUS(
      P_TEST_NO IN NUMBER,
      P_OBJECT_ID IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION VALUE_1(
      P_TEST_NO IN NUMBER,
      P_OBJECT_ID IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION APPROVAL_DATE(
      P_TEST_NO IN NUMBER,
      P_OBJECT_ID IN VARCHAR2)
      RETURN DATE;
      TYPE REC_ROW_BY_PK IS RECORD (
         TEST_NO NUMBER ,
         OBJECT_ID VARCHAR2 (32) ,
         CLASS_NAME VARCHAR2 (24) ,
         OIL_METER_CODE VARCHAR2 (32) ,
         COND_METER_CODE VARCHAR2 (32) ,
         GAS_METER_CODE VARCHAR2 (32) ,
         WATER_METER_CODE VARCHAR2 (32) ,
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
      P_TEST_NO IN NUMBER,
      P_OBJECT_ID IN VARCHAR2)
      RETURN REC_ROW_BY_PK;
   FUNCTION VALUE_2(
      P_TEST_NO IN NUMBER,
      P_OBJECT_ID IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION VALUE_3(
      P_TEST_NO IN NUMBER,
      P_OBJECT_ID IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION VALUE_4(
      P_TEST_NO IN NUMBER,
      P_OBJECT_ID IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION REC_ID(
      P_TEST_NO IN NUMBER,
      P_OBJECT_ID IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION TEXT_1(
      P_TEST_NO IN NUMBER,
      P_OBJECT_ID IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION TEXT_2(
      P_TEST_NO IN NUMBER,
      P_OBJECT_ID IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION VALUE_7(
      P_TEST_NO IN NUMBER,
      P_OBJECT_ID IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION VALUE_9(
      P_TEST_NO IN NUMBER,
      P_OBJECT_ID IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION COND_METER_CODE(
      P_TEST_NO IN NUMBER,
      P_OBJECT_ID IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION GAS_METER_CODE(
      P_TEST_NO IN NUMBER,
      P_OBJECT_ID IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION VALUE_10(
      P_TEST_NO IN NUMBER,
      P_OBJECT_ID IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION VALUE_8(
      P_TEST_NO IN NUMBER,
      P_OBJECT_ID IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION WATER_METER_CODE(
      P_TEST_NO IN NUMBER,
      P_OBJECT_ID IN VARCHAR2)
      RETURN VARCHAR2;

END RP_PTST_OBJECT;

/



CREATE or REPLACE PACKAGE BODY RP_PTST_OBJECT
IS

   FUNCTION TEXT_3(
      P_TEST_NO IN NUMBER,
      P_OBJECT_ID IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_PTST_OBJECT.TEXT_3      (
         P_TEST_NO,
         P_OBJECT_ID );
         RETURN ret_value;
   END TEXT_3;
   FUNCTION TEXT_4(
      P_TEST_NO IN NUMBER,
      P_OBJECT_ID IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_PTST_OBJECT.TEXT_4      (
         P_TEST_NO,
         P_OBJECT_ID );
         RETURN ret_value;
   END TEXT_4;
   FUNCTION APPROVAL_BY(
      P_TEST_NO IN NUMBER,
      P_OBJECT_ID IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (30) ;
   BEGIN
      ret_value := EC_PTST_OBJECT.APPROVAL_BY      (
         P_TEST_NO,
         P_OBJECT_ID );
         RETURN ret_value;
   END APPROVAL_BY;
   FUNCTION APPROVAL_STATE(
      P_TEST_NO IN NUMBER,
      P_OBJECT_ID IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_PTST_OBJECT.APPROVAL_STATE      (
         P_TEST_NO,
         P_OBJECT_ID );
         RETURN ret_value;
   END APPROVAL_STATE;
   FUNCTION OIL_METER_CODE(
      P_TEST_NO IN NUMBER,
      P_OBJECT_ID IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_PTST_OBJECT.OIL_METER_CODE      (
         P_TEST_NO,
         P_OBJECT_ID );
         RETURN ret_value;
   END OIL_METER_CODE;
   FUNCTION VALUE_5(
      P_TEST_NO IN NUMBER,
      P_OBJECT_ID IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_PTST_OBJECT.VALUE_5      (
         P_TEST_NO,
         P_OBJECT_ID );
         RETURN ret_value;
   END VALUE_5;
   FUNCTION CLASS_NAME(
      P_TEST_NO IN NUMBER,
      P_OBJECT_ID IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (24) ;
   BEGIN
      ret_value := EC_PTST_OBJECT.CLASS_NAME      (
         P_TEST_NO,
         P_OBJECT_ID );
         RETURN ret_value;
   END CLASS_NAME;
   FUNCTION VALUE_6(
      P_TEST_NO IN NUMBER,
      P_OBJECT_ID IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_PTST_OBJECT.VALUE_6      (
         P_TEST_NO,
         P_OBJECT_ID );
         RETURN ret_value;
   END VALUE_6;
   FUNCTION RECORD_STATUS(
      P_TEST_NO IN NUMBER,
      P_OBJECT_ID IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_PTST_OBJECT.RECORD_STATUS      (
         P_TEST_NO,
         P_OBJECT_ID );
         RETURN ret_value;
   END RECORD_STATUS;
   FUNCTION VALUE_1(
      P_TEST_NO IN NUMBER,
      P_OBJECT_ID IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_PTST_OBJECT.VALUE_1      (
         P_TEST_NO,
         P_OBJECT_ID );
         RETURN ret_value;
   END VALUE_1;
   FUNCTION APPROVAL_DATE(
      P_TEST_NO IN NUMBER,
      P_OBJECT_ID IN VARCHAR2)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_PTST_OBJECT.APPROVAL_DATE      (
         P_TEST_NO,
         P_OBJECT_ID );
         RETURN ret_value;
   END APPROVAL_DATE;
   FUNCTION ROW_BY_PK(
      P_TEST_NO IN NUMBER,
      P_OBJECT_ID IN VARCHAR2)
      RETURN REC_ROW_BY_PK
   IS
      ret_value    REC_ROW_BY_PK ;
   BEGIN
      ret_value := EC_PTST_OBJECT.ROW_BY_PK      (
         P_TEST_NO,
         P_OBJECT_ID );
         RETURN ret_value;
   END ROW_BY_PK;
   FUNCTION VALUE_2(
      P_TEST_NO IN NUMBER,
      P_OBJECT_ID IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_PTST_OBJECT.VALUE_2      (
         P_TEST_NO,
         P_OBJECT_ID );
         RETURN ret_value;
   END VALUE_2;
   FUNCTION VALUE_3(
      P_TEST_NO IN NUMBER,
      P_OBJECT_ID IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_PTST_OBJECT.VALUE_3      (
         P_TEST_NO,
         P_OBJECT_ID );
         RETURN ret_value;
   END VALUE_3;
   FUNCTION VALUE_4(
      P_TEST_NO IN NUMBER,
      P_OBJECT_ID IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_PTST_OBJECT.VALUE_4      (
         P_TEST_NO,
         P_OBJECT_ID );
         RETURN ret_value;
   END VALUE_4;
   FUNCTION REC_ID(
      P_TEST_NO IN NUMBER,
      P_OBJECT_ID IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_PTST_OBJECT.REC_ID      (
         P_TEST_NO,
         P_OBJECT_ID );
         RETURN ret_value;
   END REC_ID;
   FUNCTION TEXT_1(
      P_TEST_NO IN NUMBER,
      P_OBJECT_ID IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (16) ;
   BEGIN
      ret_value := EC_PTST_OBJECT.TEXT_1      (
         P_TEST_NO,
         P_OBJECT_ID );
         RETURN ret_value;
   END TEXT_1;
   FUNCTION TEXT_2(
      P_TEST_NO IN NUMBER,
      P_OBJECT_ID IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_PTST_OBJECT.TEXT_2      (
         P_TEST_NO,
         P_OBJECT_ID );
         RETURN ret_value;
   END TEXT_2;
   FUNCTION VALUE_7(
      P_TEST_NO IN NUMBER,
      P_OBJECT_ID IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_PTST_OBJECT.VALUE_7      (
         P_TEST_NO,
         P_OBJECT_ID );
         RETURN ret_value;
   END VALUE_7;
   FUNCTION VALUE_9(
      P_TEST_NO IN NUMBER,
      P_OBJECT_ID IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_PTST_OBJECT.VALUE_9      (
         P_TEST_NO,
         P_OBJECT_ID );
         RETURN ret_value;
   END VALUE_9;
   FUNCTION COND_METER_CODE(
      P_TEST_NO IN NUMBER,
      P_OBJECT_ID IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_PTST_OBJECT.COND_METER_CODE      (
         P_TEST_NO,
         P_OBJECT_ID );
         RETURN ret_value;
   END COND_METER_CODE;
   FUNCTION GAS_METER_CODE(
      P_TEST_NO IN NUMBER,
      P_OBJECT_ID IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_PTST_OBJECT.GAS_METER_CODE      (
         P_TEST_NO,
         P_OBJECT_ID );
         RETURN ret_value;
   END GAS_METER_CODE;
   FUNCTION VALUE_10(
      P_TEST_NO IN NUMBER,
      P_OBJECT_ID IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_PTST_OBJECT.VALUE_10      (
         P_TEST_NO,
         P_OBJECT_ID );
         RETURN ret_value;
   END VALUE_10;
   FUNCTION VALUE_8(
      P_TEST_NO IN NUMBER,
      P_OBJECT_ID IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_PTST_OBJECT.VALUE_8      (
         P_TEST_NO,
         P_OBJECT_ID );
         RETURN ret_value;
   END VALUE_8;
   FUNCTION WATER_METER_CODE(
      P_TEST_NO IN NUMBER,
      P_OBJECT_ID IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_PTST_OBJECT.WATER_METER_CODE      (
         P_TEST_NO,
         P_OBJECT_ID );
         RETURN ret_value;
   END WATER_METER_CODE;

END RP_PTST_OBJECT;

/
--GRANT EXECUTE ON ECKERNEL_WST.RP_PTST_OBJECT TO REPORT_ROLE_XXX;



 -- FINISH PKG_GEN_PKGS.sf_get_functions at:11/15/2018 08.17.12 AM


