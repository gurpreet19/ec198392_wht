
 -- START PKG_GEN_PKGS.sf_get_functions at:05/07/2019 10.27.52 AM


CREATE or REPLACE PACKAGE RP_CURVE_POINT
IS

   FUNCTION TEXT_3(
      P_CURVE_ID IN NUMBER,
      P_SEQ IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_4(
      P_CURVE_ID IN NUMBER,
      P_SEQ IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION Y_VALUE(
      P_CURVE_ID IN NUMBER,
      P_SEQ IN NUMBER)
      RETURN NUMBER;
   FUNCTION APPROVAL_BY(
      P_CURVE_ID IN NUMBER,
      P_SEQ IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_STATE(
      P_CURVE_ID IN NUMBER,
      P_SEQ IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_5(
      P_CURVE_ID IN NUMBER,
      P_SEQ IN NUMBER)
      RETURN NUMBER;
   FUNCTION X_VALUE(
      P_CURVE_ID IN NUMBER,
      P_SEQ IN NUMBER)
      RETURN NUMBER;
   FUNCTION REPR_POINT(
      P_CURVE_ID IN NUMBER,
      P_SEQ IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION COMMENTS(
      P_CURVE_ID IN NUMBER,
      P_SEQ IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_6(
      P_CURVE_ID IN NUMBER,
      P_SEQ IN NUMBER)
      RETURN NUMBER;
   FUNCTION GOR(
      P_CURVE_ID IN NUMBER,
      P_SEQ IN NUMBER)
      RETURN NUMBER;
   FUNCTION RECORD_STATUS(
      P_CURVE_ID IN NUMBER,
      P_SEQ IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_1(
      P_CURVE_ID IN NUMBER,
      P_SEQ IN NUMBER)
      RETURN NUMBER;
   FUNCTION APPROVAL_DATE(
      P_CURVE_ID IN NUMBER,
      P_SEQ IN NUMBER)
      RETURN DATE;
   FUNCTION CGR(
      P_CURVE_ID IN NUMBER,
      P_SEQ IN NUMBER)
      RETURN NUMBER;
      TYPE REC_ROW_BY_PK IS RECORD (
         CURVE_ID NUMBER ,
         SEQ NUMBER ,
         GOR NUMBER ,
         CGR NUMBER ,
         WGR NUMBER ,
         WATERCUT_PCT NUMBER ,
         X_VALUE NUMBER ,
         Y_VALUE NUMBER ,
         REPR_POINT VARCHAR2 (1) ,
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
         REC_ID VARCHAR2 (32)  );
   FUNCTION ROW_BY_PK(
      P_CURVE_ID IN NUMBER,
      P_SEQ IN NUMBER)
      RETURN REC_ROW_BY_PK;
   FUNCTION VALUE_2(
      P_CURVE_ID IN NUMBER,
      P_SEQ IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_3(
      P_CURVE_ID IN NUMBER,
      P_SEQ IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_4(
      P_CURVE_ID IN NUMBER,
      P_SEQ IN NUMBER)
      RETURN NUMBER;
   FUNCTION WGR(
      P_CURVE_ID IN NUMBER,
      P_SEQ IN NUMBER)
      RETURN NUMBER;
   FUNCTION REC_ID(
      P_CURVE_ID IN NUMBER,
      P_SEQ IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_1(
      P_CURVE_ID IN NUMBER,
      P_SEQ IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_2(
      P_CURVE_ID IN NUMBER,
      P_SEQ IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_7(
      P_CURVE_ID IN NUMBER,
      P_SEQ IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_9(
      P_CURVE_ID IN NUMBER,
      P_SEQ IN NUMBER)
      RETURN NUMBER;
   FUNCTION WATERCUT_PCT(
      P_CURVE_ID IN NUMBER,
      P_SEQ IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_10(
      P_CURVE_ID IN NUMBER,
      P_SEQ IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_8(
      P_CURVE_ID IN NUMBER,
      P_SEQ IN NUMBER)
      RETURN NUMBER;

END RP_CURVE_POINT;

/



CREATE or REPLACE PACKAGE BODY RP_CURVE_POINT
IS

   FUNCTION TEXT_3(
      P_CURVE_ID IN NUMBER,
      P_SEQ IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_CURVE_POINT.TEXT_3      (
         P_CURVE_ID,
         P_SEQ );
         RETURN ret_value;
   END TEXT_3;
   FUNCTION TEXT_4(
      P_CURVE_ID IN NUMBER,
      P_SEQ IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_CURVE_POINT.TEXT_4      (
         P_CURVE_ID,
         P_SEQ );
         RETURN ret_value;
   END TEXT_4;
   FUNCTION Y_VALUE(
      P_CURVE_ID IN NUMBER,
      P_SEQ IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CURVE_POINT.Y_VALUE      (
         P_CURVE_ID,
         P_SEQ );
         RETURN ret_value;
   END Y_VALUE;
   FUNCTION APPROVAL_BY(
      P_CURVE_ID IN NUMBER,
      P_SEQ IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (30) ;
   BEGIN
      ret_value := EC_CURVE_POINT.APPROVAL_BY      (
         P_CURVE_ID,
         P_SEQ );
         RETURN ret_value;
   END APPROVAL_BY;
   FUNCTION APPROVAL_STATE(
      P_CURVE_ID IN NUMBER,
      P_SEQ IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_CURVE_POINT.APPROVAL_STATE      (
         P_CURVE_ID,
         P_SEQ );
         RETURN ret_value;
   END APPROVAL_STATE;
   FUNCTION VALUE_5(
      P_CURVE_ID IN NUMBER,
      P_SEQ IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CURVE_POINT.VALUE_5      (
         P_CURVE_ID,
         P_SEQ );
         RETURN ret_value;
   END VALUE_5;
   FUNCTION X_VALUE(
      P_CURVE_ID IN NUMBER,
      P_SEQ IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CURVE_POINT.X_VALUE      (
         P_CURVE_ID,
         P_SEQ );
         RETURN ret_value;
   END X_VALUE;
   FUNCTION REPR_POINT(
      P_CURVE_ID IN NUMBER,
      P_SEQ IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_CURVE_POINT.REPR_POINT      (
         P_CURVE_ID,
         P_SEQ );
         RETURN ret_value;
   END REPR_POINT;
   FUNCTION COMMENTS(
      P_CURVE_ID IN NUMBER,
      P_SEQ IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_CURVE_POINT.COMMENTS      (
         P_CURVE_ID,
         P_SEQ );
         RETURN ret_value;
   END COMMENTS;
   FUNCTION VALUE_6(
      P_CURVE_ID IN NUMBER,
      P_SEQ IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CURVE_POINT.VALUE_6      (
         P_CURVE_ID,
         P_SEQ );
         RETURN ret_value;
   END VALUE_6;
   FUNCTION GOR(
      P_CURVE_ID IN NUMBER,
      P_SEQ IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CURVE_POINT.GOR      (
         P_CURVE_ID,
         P_SEQ );
         RETURN ret_value;
   END GOR;
   FUNCTION RECORD_STATUS(
      P_CURVE_ID IN NUMBER,
      P_SEQ IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_CURVE_POINT.RECORD_STATUS      (
         P_CURVE_ID,
         P_SEQ );
         RETURN ret_value;
   END RECORD_STATUS;
   FUNCTION VALUE_1(
      P_CURVE_ID IN NUMBER,
      P_SEQ IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CURVE_POINT.VALUE_1      (
         P_CURVE_ID,
         P_SEQ );
         RETURN ret_value;
   END VALUE_1;
   FUNCTION APPROVAL_DATE(
      P_CURVE_ID IN NUMBER,
      P_SEQ IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CURVE_POINT.APPROVAL_DATE      (
         P_CURVE_ID,
         P_SEQ );
         RETURN ret_value;
   END APPROVAL_DATE;
   FUNCTION CGR(
      P_CURVE_ID IN NUMBER,
      P_SEQ IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CURVE_POINT.CGR      (
         P_CURVE_ID,
         P_SEQ );
         RETURN ret_value;
   END CGR;
   FUNCTION ROW_BY_PK(
      P_CURVE_ID IN NUMBER,
      P_SEQ IN NUMBER)
      RETURN REC_ROW_BY_PK
   IS
      ret_value    REC_ROW_BY_PK ;
   BEGIN
      ret_value := EC_CURVE_POINT.ROW_BY_PK      (
         P_CURVE_ID,
         P_SEQ );
         RETURN ret_value;
   END ROW_BY_PK;
   FUNCTION VALUE_2(
      P_CURVE_ID IN NUMBER,
      P_SEQ IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CURVE_POINT.VALUE_2      (
         P_CURVE_ID,
         P_SEQ );
         RETURN ret_value;
   END VALUE_2;
   FUNCTION VALUE_3(
      P_CURVE_ID IN NUMBER,
      P_SEQ IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CURVE_POINT.VALUE_3      (
         P_CURVE_ID,
         P_SEQ );
         RETURN ret_value;
   END VALUE_3;
   FUNCTION VALUE_4(
      P_CURVE_ID IN NUMBER,
      P_SEQ IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CURVE_POINT.VALUE_4      (
         P_CURVE_ID,
         P_SEQ );
         RETURN ret_value;
   END VALUE_4;
   FUNCTION WGR(
      P_CURVE_ID IN NUMBER,
      P_SEQ IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CURVE_POINT.WGR      (
         P_CURVE_ID,
         P_SEQ );
         RETURN ret_value;
   END WGR;
   FUNCTION REC_ID(
      P_CURVE_ID IN NUMBER,
      P_SEQ IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_CURVE_POINT.REC_ID      (
         P_CURVE_ID,
         P_SEQ );
         RETURN ret_value;
   END REC_ID;
   FUNCTION TEXT_1(
      P_CURVE_ID IN NUMBER,
      P_SEQ IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (16) ;
   BEGIN
      ret_value := EC_CURVE_POINT.TEXT_1      (
         P_CURVE_ID,
         P_SEQ );
         RETURN ret_value;
   END TEXT_1;
   FUNCTION TEXT_2(
      P_CURVE_ID IN NUMBER,
      P_SEQ IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_CURVE_POINT.TEXT_2      (
         P_CURVE_ID,
         P_SEQ );
         RETURN ret_value;
   END TEXT_2;
   FUNCTION VALUE_7(
      P_CURVE_ID IN NUMBER,
      P_SEQ IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CURVE_POINT.VALUE_7      (
         P_CURVE_ID,
         P_SEQ );
         RETURN ret_value;
   END VALUE_7;
   FUNCTION VALUE_9(
      P_CURVE_ID IN NUMBER,
      P_SEQ IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CURVE_POINT.VALUE_9      (
         P_CURVE_ID,
         P_SEQ );
         RETURN ret_value;
   END VALUE_9;
   FUNCTION WATERCUT_PCT(
      P_CURVE_ID IN NUMBER,
      P_SEQ IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CURVE_POINT.WATERCUT_PCT      (
         P_CURVE_ID,
         P_SEQ );
         RETURN ret_value;
   END WATERCUT_PCT;
   FUNCTION VALUE_10(
      P_CURVE_ID IN NUMBER,
      P_SEQ IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CURVE_POINT.VALUE_10      (
         P_CURVE_ID,
         P_SEQ );
         RETURN ret_value;
   END VALUE_10;
   FUNCTION VALUE_8(
      P_CURVE_ID IN NUMBER,
      P_SEQ IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CURVE_POINT.VALUE_8      (
         P_CURVE_ID,
         P_SEQ );
         RETURN ret_value;
   END VALUE_8;

END RP_CURVE_POINT;

/
--GRANT EXECUTE ON ECKERNEL_WST.RP_CURVE_POINT TO REPORT_ROLE_XXX;



 -- FINISH PKG_GEN_PKGS.sf_get_functions at:05/07/2019 10.27.58 AM


