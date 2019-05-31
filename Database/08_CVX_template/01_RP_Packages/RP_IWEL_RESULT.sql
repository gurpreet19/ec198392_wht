
 -- START PKG_GEN_PKGS.sf_get_functions at:05/07/2019 09.14.34 AM


CREATE or REPLACE PACKAGE RP_IWEL_RESULT
IS

   FUNCTION BH_TEMP(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION IMMESIBLE_GAS_RATE(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION SEA_WATER_RATE(
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
   FUNCTION WH_TEMP(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION WOR(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION ANNULUS_TEMP(
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
   FUNCTION STATUS(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TDEV_PRESS(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION TDEV_TEMP(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION TEXT_15(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION UTC_END_DATE(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER)
      RETURN DATE;
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
   FUNCTION CHECK_UNIQUE(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION GAS_INJ_RATE(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION GAS_INJ_TYPE(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION GAS_SOURCE(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION INJECTIVITY_INDEX(
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
   FUNCTION RESERVOIR_PRESS(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION TEXT_7(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_8(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_29(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION WH_PRESS(
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
   FUNCTION DATE_3(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER)
      RETURN DATE;
   FUNCTION DATE_5(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER)
      RETURN DATE;
   FUNCTION HF(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION NEXT_EQUAL_DAYTIME(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION PRIMARY_IND(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION SAND_UOM(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_11(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_6(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_9(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION UTC_DAYTIME(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER)
      RETURN DATE;
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
   FUNCTION ANNULUS_PRESS(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION DATE_2(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER)
      RETURN DATE;
   FUNCTION END_DATE(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER)
      RETURN DATE;
   FUNCTION EROSION_UOM(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION FLOWING_IND(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION GOR(
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
   FUNCTION SAND_2_UOM(
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
   FUNCTION PRO_WATER_RATE(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION RESULT_NO_COMB(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER)
      RETURN NUMBER;
      TYPE REC_ROW_BY_PK IS RECORD (
         OBJECT_ID VARCHAR2 (32) ,
         DAYTIME  DATE ,
         UTC_DAYTIME  DATE ,
         PRODUCTION_DAY  DATE ,
         VALID_FROM_DATE  DATE ,
         VALID_FROM_UTC_DATE  DATE ,
         VALID_FROM_DAY  DATE ,
         END_DATE  DATE ,
         UTC_END_DATE  DATE ,
         END_DAY  DATE ,
         WATER_INJ_RATE NUMBER ,
         RESULT_NO NUMBER ,
         CHECK_UNIQUE VARCHAR2 (1000) ,
         DATA_CLASS_NAME VARCHAR2 (24) ,
         RESULT_NO_COMB NUMBER ,
         PRIMARY_IND VARCHAR2 (1) ,
         FLOWING_IND VARCHAR2 (1) ,
         CHOKE_SIZE NUMBER ,
         WH_PRESS NUMBER ,
         WH_TEMP NUMBER ,
         BH_PRESS NUMBER ,
         BH_TEMP NUMBER ,
         ANNULUS_PRESS NUMBER ,
         ANNULUS_TEMP NUMBER ,
         GOR NUMBER ,
         WOR NUMBER ,
         TDEV_PRESS NUMBER ,
         TDEV_TEMP NUMBER ,
         PUMP_STROKE NUMBER ,
         PUMP_RUNTIME NUMBER ,
         STATUS VARCHAR2 (32) ,
         TEST_DEVICE VARCHAR2 (32) ,
         CO2_RATE NUMBER ,
         IMMESIBLE_GAS_RATE NUMBER ,
         GAS_INJ_RATE NUMBER ,
         STEAM_INJ_RATE NUMBER ,
         RESERVOIR_PRESS NUMBER ,
         SAND_UOM VARCHAR2 (32) ,
         SAND_2_UOM VARCHAR2 (32) ,
         EROSION_RATE NUMBER ,
         EROSION_UOM VARCHAR2 (32) ,
         DILUENT_RATE NUMBER ,
         SEA_WATER_RATE NUMBER ,
         PRO_WATER_RATE NUMBER ,
         GAS_INJ_TYPE VARCHAR2 (32) ,
         GAS_SOURCE VARCHAR2 (32) ,
         TDD NUMBER ,
         INJECTIVITY_INDEX NUMBER ,
         FILTER_DIFF_PRESS NUMBER ,
         HCL NUMBER ,
         HF NUMBER ,
         SAND_RATE_2 NUMBER ,
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
         TEXT_5 VARCHAR2 (240) ,
         TEXT_6 VARCHAR2 (240) ,
         TEXT_7 VARCHAR2 (240) ,
         TEXT_8 VARCHAR2 (240) ,
         TEXT_9 VARCHAR2 (240) ,
         TEXT_10 VARCHAR2 (240) ,
         TEXT_11 VARCHAR2 (240) ,
         TEXT_12 VARCHAR2 (240) ,
         TEXT_13 VARCHAR2 (240) ,
         TEXT_14 VARCHAR2 (240) ,
         TEXT_15 VARCHAR2 (240) ,
         DATE_1  DATE ,
         DATE_2  DATE ,
         DATE_3  DATE ,
         DATE_4  DATE ,
         DATE_5  DATE ,
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
   FUNCTION TEXT_12(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_5(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER)
      RETURN VARCHAR2;
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
   FUNCTION CHOKE_SIZE(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION CO2_RATE(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION DATE_4(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER)
      RETURN DATE;
   FUNCTION EROSION_RATE(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION FILTER_DIFF_PRESS(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION HCL(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION PUMP_STROKE(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION REC_ID(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION SAND_RATE_2(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION TEXT_1(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_13(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_2(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALID_FROM_DATE(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER)
      RETURN DATE;
   FUNCTION VALID_FROM_DAY(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER)
      RETURN DATE;
   FUNCTION VALID_FROM_UTC_DATE(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER)
      RETURN DATE;
   FUNCTION VALUE_7(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_9(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION BH_PRESS(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION DATE_1(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER)
      RETURN DATE;
   FUNCTION DAYTIME(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER)
      RETURN DATE;
   FUNCTION DILUENT_RATE(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION END_DAY(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER)
      RETURN DATE;
   FUNCTION PRODUCTION_DAY(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER)
      RETURN DATE;
   FUNCTION PUMP_RUNTIME(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION TDD(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION TEST_DEVICE(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_10(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_14(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER)
      RETURN VARCHAR2;
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

END RP_IWEL_RESULT;

/



CREATE or REPLACE PACKAGE BODY RP_IWEL_RESULT
IS

   FUNCTION BH_TEMP(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_IWEL_RESULT.BH_TEMP      (
         P_OBJECT_ID,
         P_RESULT_NO );
         RETURN ret_value;
   END BH_TEMP;
   FUNCTION IMMESIBLE_GAS_RATE(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_IWEL_RESULT.IMMESIBLE_GAS_RATE      (
         P_OBJECT_ID,
         P_RESULT_NO );
         RETURN ret_value;
   END IMMESIBLE_GAS_RATE;
   FUNCTION SEA_WATER_RATE(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_IWEL_RESULT.SEA_WATER_RATE      (
         P_OBJECT_ID,
         P_RESULT_NO );
         RETURN ret_value;
   END SEA_WATER_RATE;
   FUNCTION TEXT_3(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_IWEL_RESULT.TEXT_3      (
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
      ret_value := EC_IWEL_RESULT.TEXT_4      (
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
      ret_value := EC_IWEL_RESULT.VALUE_16      (
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
      ret_value := EC_IWEL_RESULT.VALUE_18      (
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
      ret_value := EC_IWEL_RESULT.VALUE_21      (
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
      ret_value := EC_IWEL_RESULT.VALUE_27      (
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
      ret_value := EC_IWEL_RESULT.VALUE_30      (
         P_OBJECT_ID,
         P_RESULT_NO );
         RETURN ret_value;
   END VALUE_30;
   FUNCTION WH_TEMP(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_IWEL_RESULT.WH_TEMP      (
         P_OBJECT_ID,
         P_RESULT_NO );
         RETURN ret_value;
   END WH_TEMP;
   FUNCTION WOR(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_IWEL_RESULT.WOR      (
         P_OBJECT_ID,
         P_RESULT_NO );
         RETURN ret_value;
   END WOR;
   FUNCTION ANNULUS_TEMP(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_IWEL_RESULT.ANNULUS_TEMP      (
         P_OBJECT_ID,
         P_RESULT_NO );
         RETURN ret_value;
   END ANNULUS_TEMP;
   FUNCTION APPROVAL_BY(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (30) ;
   BEGIN
      ret_value := EC_IWEL_RESULT.APPROVAL_BY      (
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
      ret_value := EC_IWEL_RESULT.APPROVAL_STATE      (
         P_OBJECT_ID,
         P_RESULT_NO );
         RETURN ret_value;
   END APPROVAL_STATE;
   FUNCTION STATUS(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_IWEL_RESULT.STATUS      (
         P_OBJECT_ID,
         P_RESULT_NO );
         RETURN ret_value;
   END STATUS;
   FUNCTION TDEV_PRESS(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_IWEL_RESULT.TDEV_PRESS      (
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
      ret_value := EC_IWEL_RESULT.TDEV_TEMP      (
         P_OBJECT_ID,
         P_RESULT_NO );
         RETURN ret_value;
   END TDEV_TEMP;
   FUNCTION TEXT_15(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_IWEL_RESULT.TEXT_15      (
         P_OBJECT_ID,
         P_RESULT_NO );
         RETURN ret_value;
   END TEXT_15;
   FUNCTION UTC_END_DATE(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_IWEL_RESULT.UTC_END_DATE      (
         P_OBJECT_ID,
         P_RESULT_NO );
         RETURN ret_value;
   END UTC_END_DATE;
   FUNCTION VALUE_23(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_IWEL_RESULT.VALUE_23      (
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
      ret_value := EC_IWEL_RESULT.VALUE_28      (
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
      ret_value := EC_IWEL_RESULT.VALUE_5      (
         P_OBJECT_ID,
         P_RESULT_NO );
         RETURN ret_value;
   END VALUE_5;
   FUNCTION CHECK_UNIQUE(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1000) ;
   BEGIN
      ret_value := EC_IWEL_RESULT.CHECK_UNIQUE      (
         P_OBJECT_ID,
         P_RESULT_NO );
         RETURN ret_value;
   END CHECK_UNIQUE;
   FUNCTION GAS_INJ_RATE(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_IWEL_RESULT.GAS_INJ_RATE      (
         P_OBJECT_ID,
         P_RESULT_NO );
         RETURN ret_value;
   END GAS_INJ_RATE;
   FUNCTION GAS_INJ_TYPE(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_IWEL_RESULT.GAS_INJ_TYPE      (
         P_OBJECT_ID,
         P_RESULT_NO );
         RETURN ret_value;
   END GAS_INJ_TYPE;
   FUNCTION GAS_SOURCE(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_IWEL_RESULT.GAS_SOURCE      (
         P_OBJECT_ID,
         P_RESULT_NO );
         RETURN ret_value;
   END GAS_SOURCE;
   FUNCTION INJECTIVITY_INDEX(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_IWEL_RESULT.INJECTIVITY_INDEX      (
         P_OBJECT_ID,
         P_RESULT_NO );
         RETURN ret_value;
   END INJECTIVITY_INDEX;
   FUNCTION NEXT_DAYTIME(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_IWEL_RESULT.NEXT_DAYTIME      (
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
      ret_value := EC_IWEL_RESULT.PREV_EQUAL_DAYTIME      (
         P_OBJECT_ID,
         P_RESULT_NO,
         P_NUM_ROWS );
         RETURN ret_value;
   END PREV_EQUAL_DAYTIME;
   FUNCTION RESERVOIR_PRESS(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_IWEL_RESULT.RESERVOIR_PRESS      (
         P_OBJECT_ID,
         P_RESULT_NO );
         RETURN ret_value;
   END RESERVOIR_PRESS;
   FUNCTION TEXT_7(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_IWEL_RESULT.TEXT_7      (
         P_OBJECT_ID,
         P_RESULT_NO );
         RETURN ret_value;
   END TEXT_7;
   FUNCTION TEXT_8(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_IWEL_RESULT.TEXT_8      (
         P_OBJECT_ID,
         P_RESULT_NO );
         RETURN ret_value;
   END TEXT_8;
   FUNCTION VALUE_29(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_IWEL_RESULT.VALUE_29      (
         P_OBJECT_ID,
         P_RESULT_NO );
         RETURN ret_value;
   END VALUE_29;
   FUNCTION WH_PRESS(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_IWEL_RESULT.WH_PRESS      (
         P_OBJECT_ID,
         P_RESULT_NO );
         RETURN ret_value;
   END WH_PRESS;
   FUNCTION COMMENTS(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_IWEL_RESULT.COMMENTS      (
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
      ret_value := EC_IWEL_RESULT.DATA_CLASS_NAME      (
         P_OBJECT_ID,
         P_RESULT_NO );
         RETURN ret_value;
   END DATA_CLASS_NAME;
   FUNCTION DATE_3(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_IWEL_RESULT.DATE_3      (
         P_OBJECT_ID,
         P_RESULT_NO );
         RETURN ret_value;
   END DATE_3;
   FUNCTION DATE_5(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_IWEL_RESULT.DATE_5      (
         P_OBJECT_ID,
         P_RESULT_NO );
         RETURN ret_value;
   END DATE_5;
   FUNCTION HF(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_IWEL_RESULT.HF      (
         P_OBJECT_ID,
         P_RESULT_NO );
         RETURN ret_value;
   END HF;
   FUNCTION NEXT_EQUAL_DAYTIME(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_IWEL_RESULT.NEXT_EQUAL_DAYTIME      (
         P_OBJECT_ID,
         P_RESULT_NO,
         P_NUM_ROWS );
         RETURN ret_value;
   END NEXT_EQUAL_DAYTIME;
   FUNCTION PRIMARY_IND(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_IWEL_RESULT.PRIMARY_IND      (
         P_OBJECT_ID,
         P_RESULT_NO );
         RETURN ret_value;
   END PRIMARY_IND;
   FUNCTION SAND_UOM(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_IWEL_RESULT.SAND_UOM      (
         P_OBJECT_ID,
         P_RESULT_NO );
         RETURN ret_value;
   END SAND_UOM;
   FUNCTION TEXT_11(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_IWEL_RESULT.TEXT_11      (
         P_OBJECT_ID,
         P_RESULT_NO );
         RETURN ret_value;
   END TEXT_11;
   FUNCTION TEXT_6(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_IWEL_RESULT.TEXT_6      (
         P_OBJECT_ID,
         P_RESULT_NO );
         RETURN ret_value;
   END TEXT_6;
   FUNCTION TEXT_9(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_IWEL_RESULT.TEXT_9      (
         P_OBJECT_ID,
         P_RESULT_NO );
         RETURN ret_value;
   END TEXT_9;
   FUNCTION UTC_DAYTIME(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_IWEL_RESULT.UTC_DAYTIME      (
         P_OBJECT_ID,
         P_RESULT_NO );
         RETURN ret_value;
   END UTC_DAYTIME;
   FUNCTION VALUE_12(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_IWEL_RESULT.VALUE_12      (
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
      ret_value := EC_IWEL_RESULT.VALUE_22      (
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
      ret_value := EC_IWEL_RESULT.VALUE_26      (
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
      ret_value := EC_IWEL_RESULT.VALUE_6      (
         P_OBJECT_ID,
         P_RESULT_NO );
         RETURN ret_value;
   END VALUE_6;
   FUNCTION ANNULUS_PRESS(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_IWEL_RESULT.ANNULUS_PRESS      (
         P_OBJECT_ID,
         P_RESULT_NO );
         RETURN ret_value;
   END ANNULUS_PRESS;
   FUNCTION DATE_2(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_IWEL_RESULT.DATE_2      (
         P_OBJECT_ID,
         P_RESULT_NO );
         RETURN ret_value;
   END DATE_2;
   FUNCTION END_DATE(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_IWEL_RESULT.END_DATE      (
         P_OBJECT_ID,
         P_RESULT_NO );
         RETURN ret_value;
   END END_DATE;
   FUNCTION EROSION_UOM(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_IWEL_RESULT.EROSION_UOM      (
         P_OBJECT_ID,
         P_RESULT_NO );
         RETURN ret_value;
   END EROSION_UOM;
   FUNCTION FLOWING_IND(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_IWEL_RESULT.FLOWING_IND      (
         P_OBJECT_ID,
         P_RESULT_NO );
         RETURN ret_value;
   END FLOWING_IND;
   FUNCTION GOR(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_IWEL_RESULT.GOR      (
         P_OBJECT_ID,
         P_RESULT_NO );
         RETURN ret_value;
   END GOR;
   FUNCTION PREV_DAYTIME(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_IWEL_RESULT.PREV_DAYTIME      (
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
      ret_value := EC_IWEL_RESULT.RECORD_STATUS      (
         P_OBJECT_ID,
         P_RESULT_NO );
         RETURN ret_value;
   END RECORD_STATUS;
   FUNCTION SAND_2_UOM(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_IWEL_RESULT.SAND_2_UOM      (
         P_OBJECT_ID,
         P_RESULT_NO );
         RETURN ret_value;
   END SAND_2_UOM;
   FUNCTION STEAM_INJ_RATE(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_IWEL_RESULT.STEAM_INJ_RATE      (
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
      ret_value := EC_IWEL_RESULT.VALUE_1      (
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
      ret_value := EC_IWEL_RESULT.VALUE_15      (
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
      ret_value := EC_IWEL_RESULT.VALUE_19      (
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
      ret_value := EC_IWEL_RESULT.APPROVAL_DATE      (
         P_OBJECT_ID,
         P_RESULT_NO );
         RETURN ret_value;
   END APPROVAL_DATE;
   FUNCTION PRO_WATER_RATE(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_IWEL_RESULT.PRO_WATER_RATE      (
         P_OBJECT_ID,
         P_RESULT_NO );
         RETURN ret_value;
   END PRO_WATER_RATE;
   FUNCTION RESULT_NO_COMB(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_IWEL_RESULT.RESULT_NO_COMB      (
         P_OBJECT_ID,
         P_RESULT_NO );
         RETURN ret_value;
   END RESULT_NO_COMB;
   FUNCTION ROW_BY_PK(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER)
      RETURN REC_ROW_BY_PK
   IS
      ret_value    REC_ROW_BY_PK ;
   BEGIN
      ret_value := EC_IWEL_RESULT.ROW_BY_PK      (
         P_OBJECT_ID,
         P_RESULT_NO );
         RETURN ret_value;
   END ROW_BY_PK;
   FUNCTION TEXT_12(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_IWEL_RESULT.TEXT_12      (
         P_OBJECT_ID,
         P_RESULT_NO );
         RETURN ret_value;
   END TEXT_12;
   FUNCTION TEXT_5(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_IWEL_RESULT.TEXT_5      (
         P_OBJECT_ID,
         P_RESULT_NO );
         RETURN ret_value;
   END TEXT_5;
   FUNCTION VALUE_13(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_IWEL_RESULT.VALUE_13      (
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
      ret_value := EC_IWEL_RESULT.VALUE_17      (
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
      ret_value := EC_IWEL_RESULT.VALUE_2      (
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
      ret_value := EC_IWEL_RESULT.VALUE_20      (
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
      ret_value := EC_IWEL_RESULT.VALUE_25      (
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
      ret_value := EC_IWEL_RESULT.VALUE_3      (
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
      ret_value := EC_IWEL_RESULT.VALUE_4      (
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
      ret_value := EC_IWEL_RESULT.WATER_INJ_RATE      (
         P_OBJECT_ID,
         P_RESULT_NO );
         RETURN ret_value;
   END WATER_INJ_RATE;
   FUNCTION CHOKE_SIZE(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_IWEL_RESULT.CHOKE_SIZE      (
         P_OBJECT_ID,
         P_RESULT_NO );
         RETURN ret_value;
   END CHOKE_SIZE;
   FUNCTION CO2_RATE(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_IWEL_RESULT.CO2_RATE      (
         P_OBJECT_ID,
         P_RESULT_NO );
         RETURN ret_value;
   END CO2_RATE;
   FUNCTION DATE_4(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_IWEL_RESULT.DATE_4      (
         P_OBJECT_ID,
         P_RESULT_NO );
         RETURN ret_value;
   END DATE_4;
   FUNCTION EROSION_RATE(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_IWEL_RESULT.EROSION_RATE      (
         P_OBJECT_ID,
         P_RESULT_NO );
         RETURN ret_value;
   END EROSION_RATE;
   FUNCTION FILTER_DIFF_PRESS(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_IWEL_RESULT.FILTER_DIFF_PRESS      (
         P_OBJECT_ID,
         P_RESULT_NO );
         RETURN ret_value;
   END FILTER_DIFF_PRESS;
   FUNCTION HCL(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_IWEL_RESULT.HCL      (
         P_OBJECT_ID,
         P_RESULT_NO );
         RETURN ret_value;
   END HCL;
   FUNCTION PUMP_STROKE(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_IWEL_RESULT.PUMP_STROKE      (
         P_OBJECT_ID,
         P_RESULT_NO );
         RETURN ret_value;
   END PUMP_STROKE;
   FUNCTION REC_ID(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_IWEL_RESULT.REC_ID      (
         P_OBJECT_ID,
         P_RESULT_NO );
         RETURN ret_value;
   END REC_ID;
   FUNCTION SAND_RATE_2(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_IWEL_RESULT.SAND_RATE_2      (
         P_OBJECT_ID,
         P_RESULT_NO );
         RETURN ret_value;
   END SAND_RATE_2;
   FUNCTION TEXT_1(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (16) ;
   BEGIN
      ret_value := EC_IWEL_RESULT.TEXT_1      (
         P_OBJECT_ID,
         P_RESULT_NO );
         RETURN ret_value;
   END TEXT_1;
   FUNCTION TEXT_13(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_IWEL_RESULT.TEXT_13      (
         P_OBJECT_ID,
         P_RESULT_NO );
         RETURN ret_value;
   END TEXT_13;
   FUNCTION TEXT_2(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_IWEL_RESULT.TEXT_2      (
         P_OBJECT_ID,
         P_RESULT_NO );
         RETURN ret_value;
   END TEXT_2;
   FUNCTION VALID_FROM_DATE(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_IWEL_RESULT.VALID_FROM_DATE      (
         P_OBJECT_ID,
         P_RESULT_NO );
         RETURN ret_value;
   END VALID_FROM_DATE;
   FUNCTION VALID_FROM_DAY(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_IWEL_RESULT.VALID_FROM_DAY      (
         P_OBJECT_ID,
         P_RESULT_NO );
         RETURN ret_value;
   END VALID_FROM_DAY;
   FUNCTION VALID_FROM_UTC_DATE(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_IWEL_RESULT.VALID_FROM_UTC_DATE      (
         P_OBJECT_ID,
         P_RESULT_NO );
         RETURN ret_value;
   END VALID_FROM_UTC_DATE;
   FUNCTION VALUE_7(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_IWEL_RESULT.VALUE_7      (
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
      ret_value := EC_IWEL_RESULT.VALUE_9      (
         P_OBJECT_ID,
         P_RESULT_NO );
         RETURN ret_value;
   END VALUE_9;
   FUNCTION BH_PRESS(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_IWEL_RESULT.BH_PRESS      (
         P_OBJECT_ID,
         P_RESULT_NO );
         RETURN ret_value;
   END BH_PRESS;
   FUNCTION DATE_1(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_IWEL_RESULT.DATE_1      (
         P_OBJECT_ID,
         P_RESULT_NO );
         RETURN ret_value;
   END DATE_1;
   FUNCTION DAYTIME(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_IWEL_RESULT.DAYTIME      (
         P_OBJECT_ID,
         P_RESULT_NO );
         RETURN ret_value;
   END DAYTIME;
   FUNCTION DILUENT_RATE(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_IWEL_RESULT.DILUENT_RATE      (
         P_OBJECT_ID,
         P_RESULT_NO );
         RETURN ret_value;
   END DILUENT_RATE;
   FUNCTION END_DAY(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_IWEL_RESULT.END_DAY      (
         P_OBJECT_ID,
         P_RESULT_NO );
         RETURN ret_value;
   END END_DAY;
   FUNCTION PRODUCTION_DAY(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_IWEL_RESULT.PRODUCTION_DAY      (
         P_OBJECT_ID,
         P_RESULT_NO );
         RETURN ret_value;
   END PRODUCTION_DAY;
   FUNCTION PUMP_RUNTIME(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_IWEL_RESULT.PUMP_RUNTIME      (
         P_OBJECT_ID,
         P_RESULT_NO );
         RETURN ret_value;
   END PUMP_RUNTIME;
   FUNCTION TDD(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_IWEL_RESULT.TDD      (
         P_OBJECT_ID,
         P_RESULT_NO );
         RETURN ret_value;
   END TDD;
   FUNCTION TEST_DEVICE(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_IWEL_RESULT.TEST_DEVICE      (
         P_OBJECT_ID,
         P_RESULT_NO );
         RETURN ret_value;
   END TEST_DEVICE;
   FUNCTION TEXT_10(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_IWEL_RESULT.TEXT_10      (
         P_OBJECT_ID,
         P_RESULT_NO );
         RETURN ret_value;
   END TEXT_10;
   FUNCTION TEXT_14(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_IWEL_RESULT.TEXT_14      (
         P_OBJECT_ID,
         P_RESULT_NO );
         RETURN ret_value;
   END TEXT_14;
   FUNCTION VALUE_10(
      P_OBJECT_ID IN VARCHAR2,
      P_RESULT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_IWEL_RESULT.VALUE_10      (
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
      ret_value := EC_IWEL_RESULT.VALUE_11      (
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
      ret_value := EC_IWEL_RESULT.VALUE_14      (
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
      ret_value := EC_IWEL_RESULT.VALUE_24      (
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
      ret_value := EC_IWEL_RESULT.VALUE_8      (
         P_OBJECT_ID,
         P_RESULT_NO );
         RETURN ret_value;
   END VALUE_8;

END RP_IWEL_RESULT;

/
--GRANT EXECUTE ON ECKERNEL_WST.RP_IWEL_RESULT TO REPORT_ROLE_XXX;



 -- FINISH PKG_GEN_PKGS.sf_get_functions at:05/07/2019 09.14.56 AM


