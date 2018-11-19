
 -- START PKG_GEN_PKGS.sf_get_functions at:11/15/2018 07.17.05 AM


CREATE or REPLACE PACKAGE RP_TREND_CURVE
IS

   FUNCTION TEXT_3(
      P_TREND_SEGMENT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_16(
      P_TREND_SEGMENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_18(
      P_TREND_SEGMENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_21(
      P_TREND_SEGMENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_27(
      P_TREND_SEGMENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_30(
      P_TREND_SEGMENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION APPROVAL_BY(
      P_TREND_SEGMENT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_STATE(
      P_TREND_SEGMENT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION C0(
      P_TREND_SEGMENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION MAX_RANGE(
      P_TREND_SEGMENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_23(
      P_TREND_SEGMENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_28(
      P_TREND_SEGMENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_5(
      P_TREND_SEGMENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION NEXT_DAYTIME(
      P_TREND_SEGMENT_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION OBJECT_ID(
      P_TREND_SEGMENT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION PREV_EQUAL_DAYTIME(
      P_TREND_SEGMENT_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION R_SQUARED(
      P_TREND_SEGMENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION TEXT_7(
      P_TREND_SEGMENT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_8(
      P_TREND_SEGMENT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_29(
      P_TREND_SEGMENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION NEXT_EQUAL_DAYTIME(
      P_TREND_SEGMENT_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION TEXT_1(
      P_TREND_SEGMENT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_14(
      P_TREND_SEGMENT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_6(
      P_TREND_SEGMENT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_9(
      P_TREND_SEGMENT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TREND_METHOD(
      P_TREND_SEGMENT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_12(
      P_TREND_SEGMENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_22(
      P_TREND_SEGMENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_26(
      P_TREND_SEGMENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_6(
      P_TREND_SEGMENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION C0_UNIT(
      P_TREND_SEGMENT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION C1_UNIT(
      P_TREND_SEGMENT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION INC_PLOT(
      P_TREND_SEGMENT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION PREV_DAYTIME(
      P_TREND_SEGMENT_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION RECORD_STATUS(
      P_TREND_SEGMENT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_1(
      P_TREND_SEGMENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_15(
      P_TREND_SEGMENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_19(
      P_TREND_SEGMENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION APPROVAL_DATE(
      P_TREND_SEGMENT_NO IN NUMBER)
      RETURN DATE;
   FUNCTION C2(
      P_TREND_SEGMENT_NO IN NUMBER)
      RETURN NUMBER;
      TYPE REC_ROW_BY_PK IS RECORD (
         TREND_SEGMENT_NO NUMBER ,
         OBJECT_ID VARCHAR2 (32) ,
         DAYTIME  DATE ,
         TREND_PARAMETER VARCHAR2 (32) ,
         TREND_METHOD VARCHAR2 (32) ,
         C0 NUMBER ,
         C1 NUMBER ,
         C2 NUMBER ,
         C0_UNIT VARCHAR2 (32) ,
         C1_UNIT VARCHAR2 (32) ,
         R_SQUARED NUMBER ,
         HIGHLOW_BAND NUMBER ,
         TREND_SOURCE VARCHAR2 (2000) ,
         TEXT_1 VARCHAR2 (240) ,
         TEXT_2 VARCHAR2 (240) ,
         TEXT_3 VARCHAR2 (240) ,
         TEXT_4 VARCHAR2 (240) ,
         TEXT_5 VARCHAR2 (240) ,
         TEXT_6 VARCHAR2 (240) ,
         TEXT_7 VARCHAR2 (240) ,
         TEXT_8 VARCHAR2 (240) ,
         TEXT_9 VARCHAR2 (240) ,
         TEXT_10 VARCHAR2 (240) ,
         TEXT_11 VARCHAR2 (2000) ,
         TEXT_12 VARCHAR2 (2000) ,
         TEXT_13 VARCHAR2 (2000) ,
         TEXT_14 VARCHAR2 (2000) ,
         TEXT_15 VARCHAR2 (2000) ,
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
         VALUE_11 NUMBER ,
         VALUE_12 NUMBER ,
         VALUE_13 NUMBER ,
         VALUE_14 NUMBER ,
         VALUE_15 NUMBER ,
         VALUE_16 NUMBER ,
         VALUE_17 NUMBER ,
         VALUE_18 NUMBER ,
         VALUE_19 NUMBER ,
         VALUE_20 NUMBER ,
         VALUE_21 NUMBER ,
         VALUE_22 NUMBER ,
         VALUE_23 NUMBER ,
         VALUE_24 NUMBER ,
         VALUE_25 NUMBER ,
         VALUE_26 NUMBER ,
         VALUE_27 NUMBER ,
         VALUE_28 NUMBER ,
         VALUE_29 NUMBER ,
         VALUE_30 NUMBER ,
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
         REC_ID VARCHAR2 (32) ,
         MAX_RANGE NUMBER ,
         INC_PLOT VARCHAR2 (1)  );
   FUNCTION ROW_BY_PK(
      P_TREND_SEGMENT_NO IN NUMBER)
      RETURN REC_ROW_BY_PK;
   FUNCTION TEXT_13(
      P_TREND_SEGMENT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_2(
      P_TREND_SEGMENT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_4(
      P_TREND_SEGMENT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_5(
      P_TREND_SEGMENT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TREND_PARAMETER(
      P_TREND_SEGMENT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_13(
      P_TREND_SEGMENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_17(
      P_TREND_SEGMENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_2(
      P_TREND_SEGMENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_20(
      P_TREND_SEGMENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_25(
      P_TREND_SEGMENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_3(
      P_TREND_SEGMENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_4(
      P_TREND_SEGMENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION C1(
      P_TREND_SEGMENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION REC_ID(
      P_TREND_SEGMENT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TREND_SOURCE(
      P_TREND_SEGMENT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_7(
      P_TREND_SEGMENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_9(
      P_TREND_SEGMENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION DAYTIME(
      P_TREND_SEGMENT_NO IN NUMBER)
      RETURN DATE;
   FUNCTION HIGHLOW_BAND(
      P_TREND_SEGMENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION TEXT_10(
      P_TREND_SEGMENT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_11(
      P_TREND_SEGMENT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_12(
      P_TREND_SEGMENT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_15(
      P_TREND_SEGMENT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_10(
      P_TREND_SEGMENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_11(
      P_TREND_SEGMENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_14(
      P_TREND_SEGMENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_24(
      P_TREND_SEGMENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_8(
      P_TREND_SEGMENT_NO IN NUMBER)
      RETURN NUMBER;

END RP_TREND_CURVE;

/



CREATE or REPLACE PACKAGE BODY RP_TREND_CURVE
IS

   FUNCTION TEXT_3(
      P_TREND_SEGMENT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_TREND_CURVE.TEXT_3      (
         P_TREND_SEGMENT_NO );
         RETURN ret_value;
   END TEXT_3;
   FUNCTION VALUE_16(
      P_TREND_SEGMENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_TREND_CURVE.VALUE_16      (
         P_TREND_SEGMENT_NO );
         RETURN ret_value;
   END VALUE_16;
   FUNCTION VALUE_18(
      P_TREND_SEGMENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_TREND_CURVE.VALUE_18      (
         P_TREND_SEGMENT_NO );
         RETURN ret_value;
   END VALUE_18;
   FUNCTION VALUE_21(
      P_TREND_SEGMENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_TREND_CURVE.VALUE_21      (
         P_TREND_SEGMENT_NO );
         RETURN ret_value;
   END VALUE_21;
   FUNCTION VALUE_27(
      P_TREND_SEGMENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_TREND_CURVE.VALUE_27      (
         P_TREND_SEGMENT_NO );
         RETURN ret_value;
   END VALUE_27;
   FUNCTION VALUE_30(
      P_TREND_SEGMENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_TREND_CURVE.VALUE_30      (
         P_TREND_SEGMENT_NO );
         RETURN ret_value;
   END VALUE_30;
   FUNCTION APPROVAL_BY(
      P_TREND_SEGMENT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (30) ;
   BEGIN
      ret_value := EC_TREND_CURVE.APPROVAL_BY      (
         P_TREND_SEGMENT_NO );
         RETURN ret_value;
   END APPROVAL_BY;
   FUNCTION APPROVAL_STATE(
      P_TREND_SEGMENT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_TREND_CURVE.APPROVAL_STATE      (
         P_TREND_SEGMENT_NO );
         RETURN ret_value;
   END APPROVAL_STATE;
   FUNCTION C0(
      P_TREND_SEGMENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_TREND_CURVE.C0      (
         P_TREND_SEGMENT_NO );
         RETURN ret_value;
   END C0;
   FUNCTION MAX_RANGE(
      P_TREND_SEGMENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_TREND_CURVE.MAX_RANGE      (
         P_TREND_SEGMENT_NO );
         RETURN ret_value;
   END MAX_RANGE;
   FUNCTION VALUE_23(
      P_TREND_SEGMENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_TREND_CURVE.VALUE_23      (
         P_TREND_SEGMENT_NO );
         RETURN ret_value;
   END VALUE_23;
   FUNCTION VALUE_28(
      P_TREND_SEGMENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_TREND_CURVE.VALUE_28      (
         P_TREND_SEGMENT_NO );
         RETURN ret_value;
   END VALUE_28;
   FUNCTION VALUE_5(
      P_TREND_SEGMENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_TREND_CURVE.VALUE_5      (
         P_TREND_SEGMENT_NO );
         RETURN ret_value;
   END VALUE_5;
   FUNCTION NEXT_DAYTIME(
      P_TREND_SEGMENT_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_TREND_CURVE.NEXT_DAYTIME      (
         P_TREND_SEGMENT_NO,
         P_NUM_ROWS );
         RETURN ret_value;
   END NEXT_DAYTIME;
   FUNCTION OBJECT_ID(
      P_TREND_SEGMENT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_TREND_CURVE.OBJECT_ID      (
         P_TREND_SEGMENT_NO );
         RETURN ret_value;
   END OBJECT_ID;
   FUNCTION PREV_EQUAL_DAYTIME(
      P_TREND_SEGMENT_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_TREND_CURVE.PREV_EQUAL_DAYTIME      (
         P_TREND_SEGMENT_NO,
         P_NUM_ROWS );
         RETURN ret_value;
   END PREV_EQUAL_DAYTIME;
   FUNCTION R_SQUARED(
      P_TREND_SEGMENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_TREND_CURVE.R_SQUARED      (
         P_TREND_SEGMENT_NO );
         RETURN ret_value;
   END R_SQUARED;
   FUNCTION TEXT_7(
      P_TREND_SEGMENT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_TREND_CURVE.TEXT_7      (
         P_TREND_SEGMENT_NO );
         RETURN ret_value;
   END TEXT_7;
   FUNCTION TEXT_8(
      P_TREND_SEGMENT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_TREND_CURVE.TEXT_8      (
         P_TREND_SEGMENT_NO );
         RETURN ret_value;
   END TEXT_8;
   FUNCTION VALUE_29(
      P_TREND_SEGMENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_TREND_CURVE.VALUE_29      (
         P_TREND_SEGMENT_NO );
         RETURN ret_value;
   END VALUE_29;
   FUNCTION NEXT_EQUAL_DAYTIME(
      P_TREND_SEGMENT_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_TREND_CURVE.NEXT_EQUAL_DAYTIME      (
         P_TREND_SEGMENT_NO,
         P_NUM_ROWS );
         RETURN ret_value;
   END NEXT_EQUAL_DAYTIME;
   FUNCTION TEXT_1(
      P_TREND_SEGMENT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_TREND_CURVE.TEXT_1      (
         P_TREND_SEGMENT_NO );
         RETURN ret_value;
   END TEXT_1;
   FUNCTION TEXT_14(
      P_TREND_SEGMENT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_TREND_CURVE.TEXT_14      (
         P_TREND_SEGMENT_NO );
         RETURN ret_value;
   END TEXT_14;
   FUNCTION TEXT_6(
      P_TREND_SEGMENT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_TREND_CURVE.TEXT_6      (
         P_TREND_SEGMENT_NO );
         RETURN ret_value;
   END TEXT_6;
   FUNCTION TEXT_9(
      P_TREND_SEGMENT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_TREND_CURVE.TEXT_9      (
         P_TREND_SEGMENT_NO );
         RETURN ret_value;
   END TEXT_9;
   FUNCTION TREND_METHOD(
      P_TREND_SEGMENT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_TREND_CURVE.TREND_METHOD      (
         P_TREND_SEGMENT_NO );
         RETURN ret_value;
   END TREND_METHOD;
   FUNCTION VALUE_12(
      P_TREND_SEGMENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_TREND_CURVE.VALUE_12      (
         P_TREND_SEGMENT_NO );
         RETURN ret_value;
   END VALUE_12;
   FUNCTION VALUE_22(
      P_TREND_SEGMENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_TREND_CURVE.VALUE_22      (
         P_TREND_SEGMENT_NO );
         RETURN ret_value;
   END VALUE_22;
   FUNCTION VALUE_26(
      P_TREND_SEGMENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_TREND_CURVE.VALUE_26      (
         P_TREND_SEGMENT_NO );
         RETURN ret_value;
   END VALUE_26;
   FUNCTION VALUE_6(
      P_TREND_SEGMENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_TREND_CURVE.VALUE_6      (
         P_TREND_SEGMENT_NO );
         RETURN ret_value;
   END VALUE_6;
   FUNCTION C0_UNIT(
      P_TREND_SEGMENT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_TREND_CURVE.C0_UNIT      (
         P_TREND_SEGMENT_NO );
         RETURN ret_value;
   END C0_UNIT;
   FUNCTION C1_UNIT(
      P_TREND_SEGMENT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_TREND_CURVE.C1_UNIT      (
         P_TREND_SEGMENT_NO );
         RETURN ret_value;
   END C1_UNIT;
   FUNCTION INC_PLOT(
      P_TREND_SEGMENT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_TREND_CURVE.INC_PLOT      (
         P_TREND_SEGMENT_NO );
         RETURN ret_value;
   END INC_PLOT;
   FUNCTION PREV_DAYTIME(
      P_TREND_SEGMENT_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_TREND_CURVE.PREV_DAYTIME      (
         P_TREND_SEGMENT_NO,
         P_NUM_ROWS );
         RETURN ret_value;
   END PREV_DAYTIME;
   FUNCTION RECORD_STATUS(
      P_TREND_SEGMENT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_TREND_CURVE.RECORD_STATUS      (
         P_TREND_SEGMENT_NO );
         RETURN ret_value;
   END RECORD_STATUS;
   FUNCTION VALUE_1(
      P_TREND_SEGMENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_TREND_CURVE.VALUE_1      (
         P_TREND_SEGMENT_NO );
         RETURN ret_value;
   END VALUE_1;
   FUNCTION VALUE_15(
      P_TREND_SEGMENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_TREND_CURVE.VALUE_15      (
         P_TREND_SEGMENT_NO );
         RETURN ret_value;
   END VALUE_15;
   FUNCTION VALUE_19(
      P_TREND_SEGMENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_TREND_CURVE.VALUE_19      (
         P_TREND_SEGMENT_NO );
         RETURN ret_value;
   END VALUE_19;
   FUNCTION APPROVAL_DATE(
      P_TREND_SEGMENT_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_TREND_CURVE.APPROVAL_DATE      (
         P_TREND_SEGMENT_NO );
         RETURN ret_value;
   END APPROVAL_DATE;
   FUNCTION C2(
      P_TREND_SEGMENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_TREND_CURVE.C2      (
         P_TREND_SEGMENT_NO );
         RETURN ret_value;
   END C2;
   FUNCTION ROW_BY_PK(
      P_TREND_SEGMENT_NO IN NUMBER)
      RETURN REC_ROW_BY_PK
   IS
      ret_value    REC_ROW_BY_PK ;
   BEGIN
      ret_value := EC_TREND_CURVE.ROW_BY_PK      (
         P_TREND_SEGMENT_NO );
         RETURN ret_value;
   END ROW_BY_PK;
   FUNCTION TEXT_13(
      P_TREND_SEGMENT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_TREND_CURVE.TEXT_13      (
         P_TREND_SEGMENT_NO );
         RETURN ret_value;
   END TEXT_13;
   FUNCTION TEXT_2(
      P_TREND_SEGMENT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_TREND_CURVE.TEXT_2      (
         P_TREND_SEGMENT_NO );
         RETURN ret_value;
   END TEXT_2;
   FUNCTION TEXT_4(
      P_TREND_SEGMENT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_TREND_CURVE.TEXT_4      (
         P_TREND_SEGMENT_NO );
         RETURN ret_value;
   END TEXT_4;
   FUNCTION TEXT_5(
      P_TREND_SEGMENT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_TREND_CURVE.TEXT_5      (
         P_TREND_SEGMENT_NO );
         RETURN ret_value;
   END TEXT_5;
   FUNCTION TREND_PARAMETER(
      P_TREND_SEGMENT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_TREND_CURVE.TREND_PARAMETER      (
         P_TREND_SEGMENT_NO );
         RETURN ret_value;
   END TREND_PARAMETER;
   FUNCTION VALUE_13(
      P_TREND_SEGMENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_TREND_CURVE.VALUE_13      (
         P_TREND_SEGMENT_NO );
         RETURN ret_value;
   END VALUE_13;
   FUNCTION VALUE_17(
      P_TREND_SEGMENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_TREND_CURVE.VALUE_17      (
         P_TREND_SEGMENT_NO );
         RETURN ret_value;
   END VALUE_17;
   FUNCTION VALUE_2(
      P_TREND_SEGMENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_TREND_CURVE.VALUE_2      (
         P_TREND_SEGMENT_NO );
         RETURN ret_value;
   END VALUE_2;
   FUNCTION VALUE_20(
      P_TREND_SEGMENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_TREND_CURVE.VALUE_20      (
         P_TREND_SEGMENT_NO );
         RETURN ret_value;
   END VALUE_20;
   FUNCTION VALUE_25(
      P_TREND_SEGMENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_TREND_CURVE.VALUE_25      (
         P_TREND_SEGMENT_NO );
         RETURN ret_value;
   END VALUE_25;
   FUNCTION VALUE_3(
      P_TREND_SEGMENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_TREND_CURVE.VALUE_3      (
         P_TREND_SEGMENT_NO );
         RETURN ret_value;
   END VALUE_3;
   FUNCTION VALUE_4(
      P_TREND_SEGMENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_TREND_CURVE.VALUE_4      (
         P_TREND_SEGMENT_NO );
         RETURN ret_value;
   END VALUE_4;
   FUNCTION C1(
      P_TREND_SEGMENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_TREND_CURVE.C1      (
         P_TREND_SEGMENT_NO );
         RETURN ret_value;
   END C1;
   FUNCTION REC_ID(
      P_TREND_SEGMENT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_TREND_CURVE.REC_ID      (
         P_TREND_SEGMENT_NO );
         RETURN ret_value;
   END REC_ID;
   FUNCTION TREND_SOURCE(
      P_TREND_SEGMENT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_TREND_CURVE.TREND_SOURCE      (
         P_TREND_SEGMENT_NO );
         RETURN ret_value;
   END TREND_SOURCE;
   FUNCTION VALUE_7(
      P_TREND_SEGMENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_TREND_CURVE.VALUE_7      (
         P_TREND_SEGMENT_NO );
         RETURN ret_value;
   END VALUE_7;
   FUNCTION VALUE_9(
      P_TREND_SEGMENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_TREND_CURVE.VALUE_9      (
         P_TREND_SEGMENT_NO );
         RETURN ret_value;
   END VALUE_9;
   FUNCTION DAYTIME(
      P_TREND_SEGMENT_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_TREND_CURVE.DAYTIME      (
         P_TREND_SEGMENT_NO );
         RETURN ret_value;
   END DAYTIME;
   FUNCTION HIGHLOW_BAND(
      P_TREND_SEGMENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_TREND_CURVE.HIGHLOW_BAND      (
         P_TREND_SEGMENT_NO );
         RETURN ret_value;
   END HIGHLOW_BAND;
   FUNCTION TEXT_10(
      P_TREND_SEGMENT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_TREND_CURVE.TEXT_10      (
         P_TREND_SEGMENT_NO );
         RETURN ret_value;
   END TEXT_10;
   FUNCTION TEXT_11(
      P_TREND_SEGMENT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_TREND_CURVE.TEXT_11      (
         P_TREND_SEGMENT_NO );
         RETURN ret_value;
   END TEXT_11;
   FUNCTION TEXT_12(
      P_TREND_SEGMENT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_TREND_CURVE.TEXT_12      (
         P_TREND_SEGMENT_NO );
         RETURN ret_value;
   END TEXT_12;
   FUNCTION TEXT_15(
      P_TREND_SEGMENT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_TREND_CURVE.TEXT_15      (
         P_TREND_SEGMENT_NO );
         RETURN ret_value;
   END TEXT_15;
   FUNCTION VALUE_10(
      P_TREND_SEGMENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_TREND_CURVE.VALUE_10      (
         P_TREND_SEGMENT_NO );
         RETURN ret_value;
   END VALUE_10;
   FUNCTION VALUE_11(
      P_TREND_SEGMENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_TREND_CURVE.VALUE_11      (
         P_TREND_SEGMENT_NO );
         RETURN ret_value;
   END VALUE_11;
   FUNCTION VALUE_14(
      P_TREND_SEGMENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_TREND_CURVE.VALUE_14      (
         P_TREND_SEGMENT_NO );
         RETURN ret_value;
   END VALUE_14;
   FUNCTION VALUE_24(
      P_TREND_SEGMENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_TREND_CURVE.VALUE_24      (
         P_TREND_SEGMENT_NO );
         RETURN ret_value;
   END VALUE_24;
   FUNCTION VALUE_8(
      P_TREND_SEGMENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_TREND_CURVE.VALUE_8      (
         P_TREND_SEGMENT_NO );
         RETURN ret_value;
   END VALUE_8;

END RP_TREND_CURVE;

/
--GRANT EXECUTE ON ECKERNEL_WST.RP_TREND_CURVE TO REPORT_ROLE_XXX;



 -- FINISH PKG_GEN_PKGS.sf_get_functions at:11/15/2018 07.17.19 AM


