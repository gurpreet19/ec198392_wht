
 -- START PKG_GEN_PKGS.sf_get_functions at:05/07/2019 05.52.36 AM


CREATE or REPLACE PACKAGE RP_TEST_DEVICE_INJ_RESULT
IS

   FUNCTION DHG_PRESS(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION TEXT_3(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_4(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_16(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_18(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_21(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_27(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_30(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION APPROVAL_BY(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_STATE(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION DH_TEMP_2(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION TDEV_PRESS(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION TDEV_TEMP(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_23(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_28(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_5(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION DH_PRESS_1(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION GAS_INJ_RATE(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION NEXT_DAYTIME(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION PREV_EQUAL_DAYTIME(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION VALUE_29(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION COMMENTS(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION DATA_CLASS_NAME(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION DHG_TEMP(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION NEXT_EQUAL_DAYTIME(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION OIL_IN_WATER(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_12(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_22(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_26(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_6(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION INJ_LN_PRESS(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION PREV_DAYTIME(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION RECORD_STATUS(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION STEAM_INJ_RATE(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_1(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_15(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_19(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION APPROVAL_DATE(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER)
      RETURN DATE;
      TYPE REC_ROW_BY_PK IS RECORD (
         OBJECT_ID VARCHAR2 (32) ,
         RESULT_NO NUMBER ,
         DATA_CLASS_NAME VARCHAR2 (24) ,
         DAYTIME  DATE ,
         TDEV_PRESS NUMBER ,
         TDEV_TEMP NUMBER ,
         GAS_INJ_RATE NUMBER ,
         STEAM_INJ_RATE NUMBER ,
         WATER_INJ_RATE NUMBER ,
         DH_PRESS_1 NUMBER ,
         DH_TEMP_1 NUMBER ,
         DH_PRESS_2 NUMBER ,
         DH_TEMP_2 NUMBER ,
         DHG_PRESS NUMBER ,
         DHG_TEMP NUMBER ,
         INJ_LN_PRESS NUMBER ,
         INJ_LN_TEMP NUMBER ,
         OIL_IN_WATER NUMBER ,
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
      P_RESULT_NO IN NUMBER)
      RETURN REC_ROW_BY_PK;
   FUNCTION VALUE_13(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_17(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_2(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_20(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_25(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_3(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_4(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION WATER_INJ_RATE(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION DH_PRESS_2(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION INJ_LN_TEMP(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION REC_ID(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_1(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_2(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_7(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_9(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION DAYTIME(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER)
      RETURN DATE;
   FUNCTION DH_TEMP_1(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_10(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_11(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_14(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_24(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_8(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER)
      RETURN NUMBER;

END RP_TEST_DEVICE_INJ_RESULT;

/



CREATE or REPLACE PACKAGE BODY RP_TEST_DEVICE_INJ_RESULT
IS

   FUNCTION DHG_PRESS(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_TEST_DEVICE_INJ_RESULT.DHG_PRESS      (
         P_OBJECT_ID,
         P_RESULT_NO );
         RETURN ret_value;
   END DHG_PRESS;
   FUNCTION TEXT_3(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_TEST_DEVICE_INJ_RESULT.TEXT_3      (
         P_OBJECT_ID,
         P_RESULT_NO );
         RETURN ret_value;
   END TEXT_3;
   FUNCTION TEXT_4(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_TEST_DEVICE_INJ_RESULT.TEXT_4      (
         P_OBJECT_ID,
         P_RESULT_NO );
         RETURN ret_value;
   END TEXT_4;
   FUNCTION VALUE_16(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_TEST_DEVICE_INJ_RESULT.VALUE_16      (
         P_OBJECT_ID,
         P_RESULT_NO );
         RETURN ret_value;
   END VALUE_16;
   FUNCTION VALUE_18(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_TEST_DEVICE_INJ_RESULT.VALUE_18      (
         P_OBJECT_ID,
         P_RESULT_NO );
         RETURN ret_value;
   END VALUE_18;
   FUNCTION VALUE_21(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_TEST_DEVICE_INJ_RESULT.VALUE_21      (
         P_OBJECT_ID,
         P_RESULT_NO );
         RETURN ret_value;
   END VALUE_21;
   FUNCTION VALUE_27(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_TEST_DEVICE_INJ_RESULT.VALUE_27      (
         P_OBJECT_ID,
         P_RESULT_NO );
         RETURN ret_value;
   END VALUE_27;
   FUNCTION VALUE_30(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_TEST_DEVICE_INJ_RESULT.VALUE_30      (
         P_OBJECT_ID,
         P_RESULT_NO );
         RETURN ret_value;
   END VALUE_30;
   FUNCTION APPROVAL_BY(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (30) ;
   BEGIN
      ret_value := EC_TEST_DEVICE_INJ_RESULT.APPROVAL_BY      (
         P_OBJECT_ID,
         P_RESULT_NO );
         RETURN ret_value;
   END APPROVAL_BY;
   FUNCTION APPROVAL_STATE(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_TEST_DEVICE_INJ_RESULT.APPROVAL_STATE      (
         P_OBJECT_ID,
         P_RESULT_NO );
         RETURN ret_value;
   END APPROVAL_STATE;
   FUNCTION DH_TEMP_2(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_TEST_DEVICE_INJ_RESULT.DH_TEMP_2      (
         P_OBJECT_ID,
         P_RESULT_NO );
         RETURN ret_value;
   END DH_TEMP_2;
   FUNCTION TDEV_PRESS(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_TEST_DEVICE_INJ_RESULT.TDEV_PRESS      (
         P_OBJECT_ID,
         P_RESULT_NO );
         RETURN ret_value;
   END TDEV_PRESS;
   FUNCTION TDEV_TEMP(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_TEST_DEVICE_INJ_RESULT.TDEV_TEMP      (
         P_OBJECT_ID,
         P_RESULT_NO );
         RETURN ret_value;
   END TDEV_TEMP;
   FUNCTION VALUE_23(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_TEST_DEVICE_INJ_RESULT.VALUE_23      (
         P_OBJECT_ID,
         P_RESULT_NO );
         RETURN ret_value;
   END VALUE_23;
   FUNCTION VALUE_28(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_TEST_DEVICE_INJ_RESULT.VALUE_28      (
         P_OBJECT_ID,
         P_RESULT_NO );
         RETURN ret_value;
   END VALUE_28;
   FUNCTION VALUE_5(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_TEST_DEVICE_INJ_RESULT.VALUE_5      (
         P_OBJECT_ID,
         P_RESULT_NO );
         RETURN ret_value;
   END VALUE_5;
   FUNCTION DH_PRESS_1(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_TEST_DEVICE_INJ_RESULT.DH_PRESS_1      (
         P_OBJECT_ID,
         P_RESULT_NO );
         RETURN ret_value;
   END DH_PRESS_1;
   FUNCTION GAS_INJ_RATE(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_TEST_DEVICE_INJ_RESULT.GAS_INJ_RATE      (
         P_OBJECT_ID,
         P_RESULT_NO );
         RETURN ret_value;
   END GAS_INJ_RATE;
   FUNCTION NEXT_DAYTIME(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_TEST_DEVICE_INJ_RESULT.NEXT_DAYTIME      (
         P_OBJECT_ID,
         P_RESULT_NO,
         P_NUM_ROWS );
         RETURN ret_value;
   END NEXT_DAYTIME;
   FUNCTION PREV_EQUAL_DAYTIME(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_TEST_DEVICE_INJ_RESULT.PREV_EQUAL_DAYTIME      (
         P_OBJECT_ID,
         P_RESULT_NO,
         P_NUM_ROWS );
         RETURN ret_value;
   END PREV_EQUAL_DAYTIME;
   FUNCTION VALUE_29(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_TEST_DEVICE_INJ_RESULT.VALUE_29      (
         P_OBJECT_ID,
         P_RESULT_NO );
         RETURN ret_value;
   END VALUE_29;
   FUNCTION COMMENTS(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_TEST_DEVICE_INJ_RESULT.COMMENTS      (
         P_OBJECT_ID,
         P_RESULT_NO );
         RETURN ret_value;
   END COMMENTS;
   FUNCTION DATA_CLASS_NAME(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (24) ;
   BEGIN
      ret_value := EC_TEST_DEVICE_INJ_RESULT.DATA_CLASS_NAME      (
         P_OBJECT_ID,
         P_RESULT_NO );
         RETURN ret_value;
   END DATA_CLASS_NAME;
   FUNCTION DHG_TEMP(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_TEST_DEVICE_INJ_RESULT.DHG_TEMP      (
         P_OBJECT_ID,
         P_RESULT_NO );
         RETURN ret_value;
   END DHG_TEMP;
   FUNCTION NEXT_EQUAL_DAYTIME(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_TEST_DEVICE_INJ_RESULT.NEXT_EQUAL_DAYTIME      (
         P_OBJECT_ID,
         P_RESULT_NO,
         P_NUM_ROWS );
         RETURN ret_value;
   END NEXT_EQUAL_DAYTIME;
   FUNCTION OIL_IN_WATER(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_TEST_DEVICE_INJ_RESULT.OIL_IN_WATER      (
         P_OBJECT_ID,
         P_RESULT_NO );
         RETURN ret_value;
   END OIL_IN_WATER;
   FUNCTION VALUE_12(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_TEST_DEVICE_INJ_RESULT.VALUE_12      (
         P_OBJECT_ID,
         P_RESULT_NO );
         RETURN ret_value;
   END VALUE_12;
   FUNCTION VALUE_22(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_TEST_DEVICE_INJ_RESULT.VALUE_22      (
         P_OBJECT_ID,
         P_RESULT_NO );
         RETURN ret_value;
   END VALUE_22;
   FUNCTION VALUE_26(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_TEST_DEVICE_INJ_RESULT.VALUE_26      (
         P_OBJECT_ID,
         P_RESULT_NO );
         RETURN ret_value;
   END VALUE_26;
   FUNCTION VALUE_6(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_TEST_DEVICE_INJ_RESULT.VALUE_6      (
         P_OBJECT_ID,
         P_RESULT_NO );
         RETURN ret_value;
   END VALUE_6;
   FUNCTION INJ_LN_PRESS(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_TEST_DEVICE_INJ_RESULT.INJ_LN_PRESS      (
         P_OBJECT_ID,
         P_RESULT_NO );
         RETURN ret_value;
   END INJ_LN_PRESS;
   FUNCTION PREV_DAYTIME(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_TEST_DEVICE_INJ_RESULT.PREV_DAYTIME      (
         P_OBJECT_ID,
         P_RESULT_NO,
         P_NUM_ROWS );
         RETURN ret_value;
   END PREV_DAYTIME;
   FUNCTION RECORD_STATUS(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_TEST_DEVICE_INJ_RESULT.RECORD_STATUS      (
         P_OBJECT_ID,
         P_RESULT_NO );
         RETURN ret_value;
   END RECORD_STATUS;
   FUNCTION STEAM_INJ_RATE(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_TEST_DEVICE_INJ_RESULT.STEAM_INJ_RATE      (
         P_OBJECT_ID,
         P_RESULT_NO );
         RETURN ret_value;
   END STEAM_INJ_RATE;
   FUNCTION VALUE_1(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_TEST_DEVICE_INJ_RESULT.VALUE_1      (
         P_OBJECT_ID,
         P_RESULT_NO );
         RETURN ret_value;
   END VALUE_1;
   FUNCTION VALUE_15(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_TEST_DEVICE_INJ_RESULT.VALUE_15      (
         P_OBJECT_ID,
         P_RESULT_NO );
         RETURN ret_value;
   END VALUE_15;
   FUNCTION VALUE_19(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_TEST_DEVICE_INJ_RESULT.VALUE_19      (
         P_OBJECT_ID,
         P_RESULT_NO );
         RETURN ret_value;
   END VALUE_19;
   FUNCTION APPROVAL_DATE(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_TEST_DEVICE_INJ_RESULT.APPROVAL_DATE      (
         P_OBJECT_ID,
         P_RESULT_NO );
         RETURN ret_value;
   END APPROVAL_DATE;
   FUNCTION ROW_BY_PK(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER)
      RETURN REC_ROW_BY_PK
   IS
      ret_value    REC_ROW_BY_PK ;
   BEGIN
      ret_value := EC_TEST_DEVICE_INJ_RESULT.ROW_BY_PK      (
         P_OBJECT_ID,
         P_RESULT_NO );
         RETURN ret_value;
   END ROW_BY_PK;
   FUNCTION VALUE_13(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_TEST_DEVICE_INJ_RESULT.VALUE_13      (
         P_OBJECT_ID,
         P_RESULT_NO );
         RETURN ret_value;
   END VALUE_13;
   FUNCTION VALUE_17(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_TEST_DEVICE_INJ_RESULT.VALUE_17      (
         P_OBJECT_ID,
         P_RESULT_NO );
         RETURN ret_value;
   END VALUE_17;
   FUNCTION VALUE_2(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_TEST_DEVICE_INJ_RESULT.VALUE_2      (
         P_OBJECT_ID,
         P_RESULT_NO );
         RETURN ret_value;
   END VALUE_2;
   FUNCTION VALUE_20(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_TEST_DEVICE_INJ_RESULT.VALUE_20      (
         P_OBJECT_ID,
         P_RESULT_NO );
         RETURN ret_value;
   END VALUE_20;
   FUNCTION VALUE_25(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_TEST_DEVICE_INJ_RESULT.VALUE_25      (
         P_OBJECT_ID,
         P_RESULT_NO );
         RETURN ret_value;
   END VALUE_25;
   FUNCTION VALUE_3(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_TEST_DEVICE_INJ_RESULT.VALUE_3      (
         P_OBJECT_ID,
         P_RESULT_NO );
         RETURN ret_value;
   END VALUE_3;
   FUNCTION VALUE_4(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_TEST_DEVICE_INJ_RESULT.VALUE_4      (
         P_OBJECT_ID,
         P_RESULT_NO );
         RETURN ret_value;
   END VALUE_4;
   FUNCTION WATER_INJ_RATE(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_TEST_DEVICE_INJ_RESULT.WATER_INJ_RATE      (
         P_OBJECT_ID,
         P_RESULT_NO );
         RETURN ret_value;
   END WATER_INJ_RATE;
   FUNCTION DH_PRESS_2(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_TEST_DEVICE_INJ_RESULT.DH_PRESS_2      (
         P_OBJECT_ID,
         P_RESULT_NO );
         RETURN ret_value;
   END DH_PRESS_2;
   FUNCTION INJ_LN_TEMP(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_TEST_DEVICE_INJ_RESULT.INJ_LN_TEMP      (
         P_OBJECT_ID,
         P_RESULT_NO );
         RETURN ret_value;
   END INJ_LN_TEMP;
   FUNCTION REC_ID(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_TEST_DEVICE_INJ_RESULT.REC_ID      (
         P_OBJECT_ID,
         P_RESULT_NO );
         RETURN ret_value;
   END REC_ID;
   FUNCTION TEXT_1(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (16) ;
   BEGIN
      ret_value := EC_TEST_DEVICE_INJ_RESULT.TEXT_1      (
         P_OBJECT_ID,
         P_RESULT_NO );
         RETURN ret_value;
   END TEXT_1;
   FUNCTION TEXT_2(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_TEST_DEVICE_INJ_RESULT.TEXT_2      (
         P_OBJECT_ID,
         P_RESULT_NO );
         RETURN ret_value;
   END TEXT_2;
   FUNCTION VALUE_7(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_TEST_DEVICE_INJ_RESULT.VALUE_7      (
         P_OBJECT_ID,
         P_RESULT_NO );
         RETURN ret_value;
   END VALUE_7;
   FUNCTION VALUE_9(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_TEST_DEVICE_INJ_RESULT.VALUE_9      (
         P_OBJECT_ID,
         P_RESULT_NO );
         RETURN ret_value;
   END VALUE_9;
   FUNCTION DAYTIME(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_TEST_DEVICE_INJ_RESULT.DAYTIME      (
         P_OBJECT_ID,
         P_RESULT_NO );
         RETURN ret_value;
   END DAYTIME;
   FUNCTION DH_TEMP_1(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_TEST_DEVICE_INJ_RESULT.DH_TEMP_1      (
         P_OBJECT_ID,
         P_RESULT_NO );
         RETURN ret_value;
   END DH_TEMP_1;
   FUNCTION VALUE_10(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_TEST_DEVICE_INJ_RESULT.VALUE_10      (
         P_OBJECT_ID,
         P_RESULT_NO );
         RETURN ret_value;
   END VALUE_10;
   FUNCTION VALUE_11(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_TEST_DEVICE_INJ_RESULT.VALUE_11      (
         P_OBJECT_ID,
         P_RESULT_NO );
         RETURN ret_value;
   END VALUE_11;
   FUNCTION VALUE_14(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_TEST_DEVICE_INJ_RESULT.VALUE_14      (
         P_OBJECT_ID,
         P_RESULT_NO );
         RETURN ret_value;
   END VALUE_14;
   FUNCTION VALUE_24(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_TEST_DEVICE_INJ_RESULT.VALUE_24      (
         P_OBJECT_ID,
         P_RESULT_NO );
         RETURN ret_value;
   END VALUE_24;
   FUNCTION VALUE_8(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_TEST_DEVICE_INJ_RESULT.VALUE_8      (
         P_OBJECT_ID,
         P_RESULT_NO );
         RETURN ret_value;
   END VALUE_8;

END RP_TEST_DEVICE_INJ_RESULT;

/
--GRANT EXECUTE ON ECKERNEL_WST.RP_TEST_DEVICE_INJ_RESULT TO REPORT_ROLE_XXX;



 -- FINISH PKG_GEN_PKGS.sf_get_functions at:05/07/2019 05.53.31 AM


