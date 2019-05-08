
 -- START PKG_GEN_PKGS.sf_get_functions at:05/07/2019 10.28.02 AM


CREATE or REPLACE PACKAGE RP_CURVE
IS

   FUNCTION TEXT_3(
      P_CURVE_ID IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_4(
      P_CURVE_ID IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_BY(
      P_CURVE_ID IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_STATE(
      P_CURVE_ID IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION C0(
      P_CURVE_ID IN NUMBER)
      RETURN NUMBER;
   FUNCTION FORMULA_TYPE(
      P_CURVE_ID IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_5(
      P_CURVE_ID IN NUMBER)
      RETURN NUMBER;
   FUNCTION C3(
      P_CURVE_ID IN NUMBER)
      RETURN NUMBER;
   FUNCTION C4(
      P_CURVE_ID IN NUMBER)
      RETURN NUMBER;
   FUNCTION COMMENTS(
      P_CURVE_ID IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_6(
      P_CURVE_ID IN NUMBER)
      RETURN NUMBER;
   FUNCTION PERF_CURVE_ID(
      P_CURVE_ID IN NUMBER)
      RETURN NUMBER;
   FUNCTION RECORD_STATUS(
      P_CURVE_ID IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_1(
      P_CURVE_ID IN NUMBER)
      RETURN NUMBER;
   FUNCTION Z_VALUE(
      P_CURVE_ID IN NUMBER)
      RETURN NUMBER;
   FUNCTION APPROVAL_DATE(
      P_CURVE_ID IN NUMBER)
      RETURN DATE;
   FUNCTION C2(
      P_CURVE_ID IN NUMBER)
      RETURN NUMBER;
      TYPE REC_ROW_BY_PK IS RECORD (
         CURVE_ID NUMBER ,
         PERF_CURVE_ID NUMBER ,
         Z_VALUE NUMBER ,
         PHASE VARCHAR2 (16) ,
         FORMULA_TYPE VARCHAR2 (16) ,
         C0 NUMBER ,
         C1 NUMBER ,
         C2 NUMBER ,
         C3 NUMBER ,
         Y_VALID_FROM NUMBER ,
         Y_VALID_TO NUMBER ,
         COMMENTS VARCHAR2 (2000) ,
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
         REC_ID VARCHAR2 (32) ,
         C4 NUMBER  );
   FUNCTION ROW_BY_PK(
      P_CURVE_ID IN NUMBER)
      RETURN REC_ROW_BY_PK;
   FUNCTION VALUE_2(
      P_CURVE_ID IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_3(
      P_CURVE_ID IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_4(
      P_CURVE_ID IN NUMBER)
      RETURN NUMBER;
   FUNCTION C1(
      P_CURVE_ID IN NUMBER)
      RETURN NUMBER;
   FUNCTION PHASE(
      P_CURVE_ID IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION REC_ID(
      P_CURVE_ID IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_1(
      P_CURVE_ID IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_2(
      P_CURVE_ID IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_7(
      P_CURVE_ID IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_9(
      P_CURVE_ID IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_10(
      P_CURVE_ID IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_8(
      P_CURVE_ID IN NUMBER)
      RETURN NUMBER;
   FUNCTION Y_VALID_FROM(
      P_CURVE_ID IN NUMBER)
      RETURN NUMBER;
   FUNCTION Y_VALID_TO(
      P_CURVE_ID IN NUMBER)
      RETURN NUMBER;

END RP_CURVE;

/



CREATE or REPLACE PACKAGE BODY RP_CURVE
IS

   FUNCTION TEXT_3(
      P_CURVE_ID IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_CURVE.TEXT_3      (
         P_CURVE_ID );
         RETURN ret_value;
   END TEXT_3;
   FUNCTION TEXT_4(
      P_CURVE_ID IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_CURVE.TEXT_4      (
         P_CURVE_ID );
         RETURN ret_value;
   END TEXT_4;
   FUNCTION APPROVAL_BY(
      P_CURVE_ID IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (30) ;
   BEGIN
      ret_value := EC_CURVE.APPROVAL_BY      (
         P_CURVE_ID );
         RETURN ret_value;
   END APPROVAL_BY;
   FUNCTION APPROVAL_STATE(
      P_CURVE_ID IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_CURVE.APPROVAL_STATE      (
         P_CURVE_ID );
         RETURN ret_value;
   END APPROVAL_STATE;
   FUNCTION C0(
      P_CURVE_ID IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CURVE.C0      (
         P_CURVE_ID );
         RETURN ret_value;
   END C0;
   FUNCTION FORMULA_TYPE(
      P_CURVE_ID IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (16) ;
   BEGIN
      ret_value := EC_CURVE.FORMULA_TYPE      (
         P_CURVE_ID );
         RETURN ret_value;
   END FORMULA_TYPE;
   FUNCTION VALUE_5(
      P_CURVE_ID IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CURVE.VALUE_5      (
         P_CURVE_ID );
         RETURN ret_value;
   END VALUE_5;
   FUNCTION C3(
      P_CURVE_ID IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CURVE.C3      (
         P_CURVE_ID );
         RETURN ret_value;
   END C3;
   FUNCTION C4(
      P_CURVE_ID IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CURVE.C4      (
         P_CURVE_ID );
         RETURN ret_value;
   END C4;
   FUNCTION COMMENTS(
      P_CURVE_ID IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_CURVE.COMMENTS      (
         P_CURVE_ID );
         RETURN ret_value;
   END COMMENTS;
   FUNCTION VALUE_6(
      P_CURVE_ID IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CURVE.VALUE_6      (
         P_CURVE_ID );
         RETURN ret_value;
   END VALUE_6;
   FUNCTION PERF_CURVE_ID(
      P_CURVE_ID IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CURVE.PERF_CURVE_ID      (
         P_CURVE_ID );
         RETURN ret_value;
   END PERF_CURVE_ID;
   FUNCTION RECORD_STATUS(
      P_CURVE_ID IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_CURVE.RECORD_STATUS      (
         P_CURVE_ID );
         RETURN ret_value;
   END RECORD_STATUS;
   FUNCTION VALUE_1(
      P_CURVE_ID IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CURVE.VALUE_1      (
         P_CURVE_ID );
         RETURN ret_value;
   END VALUE_1;
   FUNCTION Z_VALUE(
      P_CURVE_ID IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CURVE.Z_VALUE      (
         P_CURVE_ID );
         RETURN ret_value;
   END Z_VALUE;
   FUNCTION APPROVAL_DATE(
      P_CURVE_ID IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CURVE.APPROVAL_DATE      (
         P_CURVE_ID );
         RETURN ret_value;
   END APPROVAL_DATE;
   FUNCTION C2(
      P_CURVE_ID IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CURVE.C2      (
         P_CURVE_ID );
         RETURN ret_value;
   END C2;
   FUNCTION ROW_BY_PK(
      P_CURVE_ID IN NUMBER)
      RETURN REC_ROW_BY_PK
   IS
      ret_value    REC_ROW_BY_PK ;
   BEGIN
      ret_value := EC_CURVE.ROW_BY_PK      (
         P_CURVE_ID );
         RETURN ret_value;
   END ROW_BY_PK;
   FUNCTION VALUE_2(
      P_CURVE_ID IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CURVE.VALUE_2      (
         P_CURVE_ID );
         RETURN ret_value;
   END VALUE_2;
   FUNCTION VALUE_3(
      P_CURVE_ID IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CURVE.VALUE_3      (
         P_CURVE_ID );
         RETURN ret_value;
   END VALUE_3;
   FUNCTION VALUE_4(
      P_CURVE_ID IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CURVE.VALUE_4      (
         P_CURVE_ID );
         RETURN ret_value;
   END VALUE_4;
   FUNCTION C1(
      P_CURVE_ID IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CURVE.C1      (
         P_CURVE_ID );
         RETURN ret_value;
   END C1;
   FUNCTION PHASE(
      P_CURVE_ID IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (16) ;
   BEGIN
      ret_value := EC_CURVE.PHASE      (
         P_CURVE_ID );
         RETURN ret_value;
   END PHASE;
   FUNCTION REC_ID(
      P_CURVE_ID IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_CURVE.REC_ID      (
         P_CURVE_ID );
         RETURN ret_value;
   END REC_ID;
   FUNCTION TEXT_1(
      P_CURVE_ID IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (16) ;
   BEGIN
      ret_value := EC_CURVE.TEXT_1      (
         P_CURVE_ID );
         RETURN ret_value;
   END TEXT_1;
   FUNCTION TEXT_2(
      P_CURVE_ID IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_CURVE.TEXT_2      (
         P_CURVE_ID );
         RETURN ret_value;
   END TEXT_2;
   FUNCTION VALUE_7(
      P_CURVE_ID IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CURVE.VALUE_7      (
         P_CURVE_ID );
         RETURN ret_value;
   END VALUE_7;
   FUNCTION VALUE_9(
      P_CURVE_ID IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CURVE.VALUE_9      (
         P_CURVE_ID );
         RETURN ret_value;
   END VALUE_9;
   FUNCTION VALUE_10(
      P_CURVE_ID IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CURVE.VALUE_10      (
         P_CURVE_ID );
         RETURN ret_value;
   END VALUE_10;
   FUNCTION VALUE_8(
      P_CURVE_ID IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CURVE.VALUE_8      (
         P_CURVE_ID );
         RETURN ret_value;
   END VALUE_8;
   FUNCTION Y_VALID_FROM(
      P_CURVE_ID IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CURVE.Y_VALID_FROM      (
         P_CURVE_ID );
         RETURN ret_value;
   END Y_VALID_FROM;
   FUNCTION Y_VALID_TO(
      P_CURVE_ID IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CURVE.Y_VALID_TO      (
         P_CURVE_ID );
         RETURN ret_value;
   END Y_VALID_TO;

END RP_CURVE;

/
--GRANT EXECUTE ON ECKERNEL_WST.RP_CURVE TO REPORT_ROLE_XXX;



 -- FINISH PKG_GEN_PKGS.sf_get_functions at:05/07/2019 10.28.09 AM


