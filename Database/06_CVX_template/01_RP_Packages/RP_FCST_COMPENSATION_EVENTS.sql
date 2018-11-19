
 -- START PKG_GEN_PKGS.sf_get_functions at:11/15/2018 09.57.20 AM


CREATE or REPLACE PACKAGE RP_FCST_COMPENSATION_EVENTS
IS

   FUNCTION COMMENTS(
      P_EVENT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION END_SUMMER_TIME(
      P_EVENT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_3(
      P_EVENT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_4(
      P_EVENT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TIME_ZONE(
      P_EVENT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_16(
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_18(
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION APPROVAL_BY(
      P_EVENT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_STATE(
      P_EVENT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION COND_COMP_VOLUME(
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION SUMMER_TIME(
      P_EVENT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION UTC_END_DATE(
      P_EVENT_NO IN NUMBER)
      RETURN DATE;
   FUNCTION VALUE_5(
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION WATER_COMP_RATE(
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION WATER_COMP_VOLUME(
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION GAS_INJ_COMP_VOLUME(
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION NEXT_DAYTIME(
      P_EVENT_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION OBJECT_ID(
      P_EVENT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION OIL_COMP_RATE(
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION PREV_EQUAL_DAYTIME(
      P_EVENT_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION STEAM_INJ_COMP_RATE(
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION STEAM_INJ_COMP_VOLUME(
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION DATE_3(
      P_EVENT_NO IN NUMBER)
      RETURN DATE;
   FUNCTION DATE_5(
      P_EVENT_NO IN NUMBER)
      RETURN DATE;
   FUNCTION NEXT_EQUAL_DAYTIME(
      P_EVENT_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION UTC_DAYTIME(
      P_EVENT_NO IN NUMBER)
      RETURN DATE;
   FUNCTION VALUE_12(
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_6(
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION WATER_INJ_COMP_RATE(
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION WATER_INJ_COMP_VOLUME(
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION CO2_INJ_COMP_RATE(
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION DATE_2(
      P_EVENT_NO IN NUMBER)
      RETURN DATE;
   FUNCTION END_DATE(
      P_EVENT_NO IN NUMBER)
      RETURN DATE;
   FUNCTION GAS_COMP_RATE(
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION GAS_COMP_VOLUME(
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION OBJECT_COMP_ID(
      P_EVENT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION PREV_DAYTIME(
      P_EVENT_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION RECORD_STATUS(
      P_EVENT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_1(
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_15(
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_19(
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION APPROVAL_DATE(
      P_EVENT_NO IN NUMBER)
      RETURN DATE;
   FUNCTION CO2_INJ_COMP_VOLUME(
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION COND_COMP_RATE(
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION DILUENT_COMP_RATE(
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION FORECAST_ID(
      P_EVENT_NO IN NUMBER)
      RETURN VARCHAR2;
      TYPE REC_ROW_BY_PK IS RECORD (
         OBJECT_COMP_ID VARCHAR2 (32) ,
         EVENT_NO NUMBER ,
         OBJECT_ID VARCHAR2 (32) ,
         FORECAST_ID VARCHAR2 (32) ,
         DAYTIME  DATE ,
         END_DATE  DATE ,
         REASON_CODE_1 VARCHAR2 (32) ,
         OIL_COMP_RATE NUMBER ,
         OIL_COMP_VOLUME NUMBER ,
         GAS_COMP_RATE NUMBER ,
         GAS_COMP_VOLUME NUMBER ,
         COND_COMP_RATE NUMBER ,
         COND_COMP_VOLUME NUMBER ,
         WATER_COMP_RATE NUMBER ,
         WATER_COMP_VOLUME NUMBER ,
         WATER_INJ_COMP_RATE NUMBER ,
         WATER_INJ_COMP_VOLUME NUMBER ,
         STEAM_INJ_COMP_RATE NUMBER ,
         STEAM_INJ_COMP_VOLUME NUMBER ,
         GAS_INJ_COMP_RATE NUMBER ,
         GAS_INJ_COMP_VOLUME NUMBER ,
         DILUENT_COMP_RATE NUMBER ,
         DILUENT_COMP_VOLUME NUMBER ,
         GAS_LIFT_COMP_RATE NUMBER ,
         GAS_LIFT_COMP_VOLUME NUMBER ,
         CO2_INJ_COMP_RATE NUMBER ,
         CO2_INJ_COMP_VOLUME NUMBER ,
         DAY  DATE ,
         END_DAY  DATE ,
         END_SUMMER_TIME VARCHAR2 (1) ,
         END_TIME_ZONE VARCHAR2 (65) ,
         TIME_ZONE VARCHAR2 (65) ,
         UTC_END_DATE  DATE ,
         UTC_DAYTIME  DATE ,
         SUMMER_TIME VARCHAR2 (1) ,
         COMMENTS VARCHAR2 (4000) ,
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
         TEXT_1 VARCHAR2 (16) ,
         TEXT_2 VARCHAR2 (32) ,
         TEXT_3 VARCHAR2 (240) ,
         TEXT_4 VARCHAR2 (2000) ,
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
         REV_TEXT VARCHAR2 (240) ,
         APPROVAL_BY VARCHAR2 (30) ,
         APPROVAL_DATE  DATE ,
         APPROVAL_STATE VARCHAR2 (1) ,
         REC_ID VARCHAR2 (32)  );
   FUNCTION ROW_BY_PK(
      P_EVENT_NO IN NUMBER)
      RETURN REC_ROW_BY_PK;
   FUNCTION VALUE_13(
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_17(
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_2(
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_20(
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_3(
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_4(
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION DATE_4(
      P_EVENT_NO IN NUMBER)
      RETURN DATE;
   FUNCTION DAY(
      P_EVENT_NO IN NUMBER)
      RETURN DATE;
   FUNCTION DILUENT_COMP_VOLUME(
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION END_TIME_ZONE(
      P_EVENT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION GAS_LIFT_COMP_RATE(
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION GAS_LIFT_COMP_VOLUME(
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION REC_ID(
      P_EVENT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_1(
      P_EVENT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_2(
      P_EVENT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_7(
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_9(
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION DATE_1(
      P_EVENT_NO IN NUMBER)
      RETURN DATE;
   FUNCTION DAYTIME(
      P_EVENT_NO IN NUMBER)
      RETURN DATE;
   FUNCTION END_DAY(
      P_EVENT_NO IN NUMBER)
      RETURN DATE;
   FUNCTION GAS_INJ_COMP_RATE(
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION OIL_COMP_VOLUME(
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION REASON_CODE_1(
      P_EVENT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_10(
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_11(
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_14(
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_8(
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER;

END RP_FCST_COMPENSATION_EVENTS;

/



CREATE or REPLACE PACKAGE BODY RP_FCST_COMPENSATION_EVENTS
IS

   FUNCTION COMMENTS(
      P_EVENT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (4000) ;
   BEGIN
      ret_value := EC_FCST_COMPENSATION_EVENTS.COMMENTS      (
         P_EVENT_NO );
         RETURN ret_value;
   END COMMENTS;
   FUNCTION END_SUMMER_TIME(
      P_EVENT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_FCST_COMPENSATION_EVENTS.END_SUMMER_TIME      (
         P_EVENT_NO );
         RETURN ret_value;
   END END_SUMMER_TIME;
   FUNCTION TEXT_3(
      P_EVENT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_FCST_COMPENSATION_EVENTS.TEXT_3      (
         P_EVENT_NO );
         RETURN ret_value;
   END TEXT_3;
   FUNCTION TEXT_4(
      P_EVENT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_FCST_COMPENSATION_EVENTS.TEXT_4      (
         P_EVENT_NO );
         RETURN ret_value;
   END TEXT_4;
   FUNCTION TIME_ZONE(
      P_EVENT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (65) ;
   BEGIN
      ret_value := EC_FCST_COMPENSATION_EVENTS.TIME_ZONE      (
         P_EVENT_NO );
         RETURN ret_value;
   END TIME_ZONE;
   FUNCTION VALUE_16(
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FCST_COMPENSATION_EVENTS.VALUE_16      (
         P_EVENT_NO );
         RETURN ret_value;
   END VALUE_16;
   FUNCTION VALUE_18(
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FCST_COMPENSATION_EVENTS.VALUE_18      (
         P_EVENT_NO );
         RETURN ret_value;
   END VALUE_18;
   FUNCTION APPROVAL_BY(
      P_EVENT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (30) ;
   BEGIN
      ret_value := EC_FCST_COMPENSATION_EVENTS.APPROVAL_BY      (
         P_EVENT_NO );
         RETURN ret_value;
   END APPROVAL_BY;
   FUNCTION APPROVAL_STATE(
      P_EVENT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_FCST_COMPENSATION_EVENTS.APPROVAL_STATE      (
         P_EVENT_NO );
         RETURN ret_value;
   END APPROVAL_STATE;
   FUNCTION COND_COMP_VOLUME(
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FCST_COMPENSATION_EVENTS.COND_COMP_VOLUME      (
         P_EVENT_NO );
         RETURN ret_value;
   END COND_COMP_VOLUME;
   FUNCTION SUMMER_TIME(
      P_EVENT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_FCST_COMPENSATION_EVENTS.SUMMER_TIME      (
         P_EVENT_NO );
         RETURN ret_value;
   END SUMMER_TIME;
   FUNCTION UTC_END_DATE(
      P_EVENT_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_FCST_COMPENSATION_EVENTS.UTC_END_DATE      (
         P_EVENT_NO );
         RETURN ret_value;
   END UTC_END_DATE;
   FUNCTION VALUE_5(
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FCST_COMPENSATION_EVENTS.VALUE_5      (
         P_EVENT_NO );
         RETURN ret_value;
   END VALUE_5;
   FUNCTION WATER_COMP_RATE(
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FCST_COMPENSATION_EVENTS.WATER_COMP_RATE      (
         P_EVENT_NO );
         RETURN ret_value;
   END WATER_COMP_RATE;
   FUNCTION WATER_COMP_VOLUME(
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FCST_COMPENSATION_EVENTS.WATER_COMP_VOLUME      (
         P_EVENT_NO );
         RETURN ret_value;
   END WATER_COMP_VOLUME;
   FUNCTION GAS_INJ_COMP_VOLUME(
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FCST_COMPENSATION_EVENTS.GAS_INJ_COMP_VOLUME      (
         P_EVENT_NO );
         RETURN ret_value;
   END GAS_INJ_COMP_VOLUME;
   FUNCTION NEXT_DAYTIME(
      P_EVENT_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_FCST_COMPENSATION_EVENTS.NEXT_DAYTIME      (
         P_EVENT_NO,
         P_NUM_ROWS );
         RETURN ret_value;
   END NEXT_DAYTIME;
   FUNCTION OBJECT_ID(
      P_EVENT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_FCST_COMPENSATION_EVENTS.OBJECT_ID      (
         P_EVENT_NO );
         RETURN ret_value;
   END OBJECT_ID;
   FUNCTION OIL_COMP_RATE(
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FCST_COMPENSATION_EVENTS.OIL_COMP_RATE      (
         P_EVENT_NO );
         RETURN ret_value;
   END OIL_COMP_RATE;
   FUNCTION PREV_EQUAL_DAYTIME(
      P_EVENT_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_FCST_COMPENSATION_EVENTS.PREV_EQUAL_DAYTIME      (
         P_EVENT_NO,
         P_NUM_ROWS );
         RETURN ret_value;
   END PREV_EQUAL_DAYTIME;
   FUNCTION STEAM_INJ_COMP_RATE(
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FCST_COMPENSATION_EVENTS.STEAM_INJ_COMP_RATE      (
         P_EVENT_NO );
         RETURN ret_value;
   END STEAM_INJ_COMP_RATE;
   FUNCTION STEAM_INJ_COMP_VOLUME(
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FCST_COMPENSATION_EVENTS.STEAM_INJ_COMP_VOLUME      (
         P_EVENT_NO );
         RETURN ret_value;
   END STEAM_INJ_COMP_VOLUME;
   FUNCTION DATE_3(
      P_EVENT_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_FCST_COMPENSATION_EVENTS.DATE_3      (
         P_EVENT_NO );
         RETURN ret_value;
   END DATE_3;
   FUNCTION DATE_5(
      P_EVENT_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_FCST_COMPENSATION_EVENTS.DATE_5      (
         P_EVENT_NO );
         RETURN ret_value;
   END DATE_5;
   FUNCTION NEXT_EQUAL_DAYTIME(
      P_EVENT_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_FCST_COMPENSATION_EVENTS.NEXT_EQUAL_DAYTIME      (
         P_EVENT_NO,
         P_NUM_ROWS );
         RETURN ret_value;
   END NEXT_EQUAL_DAYTIME;
   FUNCTION UTC_DAYTIME(
      P_EVENT_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_FCST_COMPENSATION_EVENTS.UTC_DAYTIME      (
         P_EVENT_NO );
         RETURN ret_value;
   END UTC_DAYTIME;
   FUNCTION VALUE_12(
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FCST_COMPENSATION_EVENTS.VALUE_12      (
         P_EVENT_NO );
         RETURN ret_value;
   END VALUE_12;
   FUNCTION VALUE_6(
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FCST_COMPENSATION_EVENTS.VALUE_6      (
         P_EVENT_NO );
         RETURN ret_value;
   END VALUE_6;
   FUNCTION WATER_INJ_COMP_RATE(
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FCST_COMPENSATION_EVENTS.WATER_INJ_COMP_RATE      (
         P_EVENT_NO );
         RETURN ret_value;
   END WATER_INJ_COMP_RATE;
   FUNCTION WATER_INJ_COMP_VOLUME(
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FCST_COMPENSATION_EVENTS.WATER_INJ_COMP_VOLUME      (
         P_EVENT_NO );
         RETURN ret_value;
   END WATER_INJ_COMP_VOLUME;
   FUNCTION CO2_INJ_COMP_RATE(
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FCST_COMPENSATION_EVENTS.CO2_INJ_COMP_RATE      (
         P_EVENT_NO );
         RETURN ret_value;
   END CO2_INJ_COMP_RATE;
   FUNCTION DATE_2(
      P_EVENT_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_FCST_COMPENSATION_EVENTS.DATE_2      (
         P_EVENT_NO );
         RETURN ret_value;
   END DATE_2;
   FUNCTION END_DATE(
      P_EVENT_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_FCST_COMPENSATION_EVENTS.END_DATE      (
         P_EVENT_NO );
         RETURN ret_value;
   END END_DATE;
   FUNCTION GAS_COMP_RATE(
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FCST_COMPENSATION_EVENTS.GAS_COMP_RATE      (
         P_EVENT_NO );
         RETURN ret_value;
   END GAS_COMP_RATE;
   FUNCTION GAS_COMP_VOLUME(
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FCST_COMPENSATION_EVENTS.GAS_COMP_VOLUME      (
         P_EVENT_NO );
         RETURN ret_value;
   END GAS_COMP_VOLUME;
   FUNCTION OBJECT_COMP_ID(
      P_EVENT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_FCST_COMPENSATION_EVENTS.OBJECT_COMP_ID      (
         P_EVENT_NO );
         RETURN ret_value;
   END OBJECT_COMP_ID;
   FUNCTION PREV_DAYTIME(
      P_EVENT_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_FCST_COMPENSATION_EVENTS.PREV_DAYTIME      (
         P_EVENT_NO,
         P_NUM_ROWS );
         RETURN ret_value;
   END PREV_DAYTIME;
   FUNCTION RECORD_STATUS(
      P_EVENT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_FCST_COMPENSATION_EVENTS.RECORD_STATUS      (
         P_EVENT_NO );
         RETURN ret_value;
   END RECORD_STATUS;
   FUNCTION VALUE_1(
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FCST_COMPENSATION_EVENTS.VALUE_1      (
         P_EVENT_NO );
         RETURN ret_value;
   END VALUE_1;
   FUNCTION VALUE_15(
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FCST_COMPENSATION_EVENTS.VALUE_15      (
         P_EVENT_NO );
         RETURN ret_value;
   END VALUE_15;
   FUNCTION VALUE_19(
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FCST_COMPENSATION_EVENTS.VALUE_19      (
         P_EVENT_NO );
         RETURN ret_value;
   END VALUE_19;
   FUNCTION APPROVAL_DATE(
      P_EVENT_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_FCST_COMPENSATION_EVENTS.APPROVAL_DATE      (
         P_EVENT_NO );
         RETURN ret_value;
   END APPROVAL_DATE;
   FUNCTION CO2_INJ_COMP_VOLUME(
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FCST_COMPENSATION_EVENTS.CO2_INJ_COMP_VOLUME      (
         P_EVENT_NO );
         RETURN ret_value;
   END CO2_INJ_COMP_VOLUME;
   FUNCTION COND_COMP_RATE(
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FCST_COMPENSATION_EVENTS.COND_COMP_RATE      (
         P_EVENT_NO );
         RETURN ret_value;
   END COND_COMP_RATE;
   FUNCTION DILUENT_COMP_RATE(
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FCST_COMPENSATION_EVENTS.DILUENT_COMP_RATE      (
         P_EVENT_NO );
         RETURN ret_value;
   END DILUENT_COMP_RATE;
   FUNCTION FORECAST_ID(
      P_EVENT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_FCST_COMPENSATION_EVENTS.FORECAST_ID      (
         P_EVENT_NO );
         RETURN ret_value;
   END FORECAST_ID;
   FUNCTION ROW_BY_PK(
      P_EVENT_NO IN NUMBER)
      RETURN REC_ROW_BY_PK
   IS
      ret_value    REC_ROW_BY_PK ;
   BEGIN
      ret_value := EC_FCST_COMPENSATION_EVENTS.ROW_BY_PK      (
         P_EVENT_NO );
         RETURN ret_value;
   END ROW_BY_PK;
   FUNCTION VALUE_13(
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FCST_COMPENSATION_EVENTS.VALUE_13      (
         P_EVENT_NO );
         RETURN ret_value;
   END VALUE_13;
   FUNCTION VALUE_17(
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FCST_COMPENSATION_EVENTS.VALUE_17      (
         P_EVENT_NO );
         RETURN ret_value;
   END VALUE_17;
   FUNCTION VALUE_2(
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FCST_COMPENSATION_EVENTS.VALUE_2      (
         P_EVENT_NO );
         RETURN ret_value;
   END VALUE_2;
   FUNCTION VALUE_20(
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FCST_COMPENSATION_EVENTS.VALUE_20      (
         P_EVENT_NO );
         RETURN ret_value;
   END VALUE_20;
   FUNCTION VALUE_3(
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FCST_COMPENSATION_EVENTS.VALUE_3      (
         P_EVENT_NO );
         RETURN ret_value;
   END VALUE_3;
   FUNCTION VALUE_4(
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FCST_COMPENSATION_EVENTS.VALUE_4      (
         P_EVENT_NO );
         RETURN ret_value;
   END VALUE_4;
   FUNCTION DATE_4(
      P_EVENT_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_FCST_COMPENSATION_EVENTS.DATE_4      (
         P_EVENT_NO );
         RETURN ret_value;
   END DATE_4;
   FUNCTION DAY(
      P_EVENT_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_FCST_COMPENSATION_EVENTS.DAY      (
         P_EVENT_NO );
         RETURN ret_value;
   END DAY;
   FUNCTION DILUENT_COMP_VOLUME(
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FCST_COMPENSATION_EVENTS.DILUENT_COMP_VOLUME      (
         P_EVENT_NO );
         RETURN ret_value;
   END DILUENT_COMP_VOLUME;
   FUNCTION END_TIME_ZONE(
      P_EVENT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (65) ;
   BEGIN
      ret_value := EC_FCST_COMPENSATION_EVENTS.END_TIME_ZONE      (
         P_EVENT_NO );
         RETURN ret_value;
   END END_TIME_ZONE;
   FUNCTION GAS_LIFT_COMP_RATE(
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FCST_COMPENSATION_EVENTS.GAS_LIFT_COMP_RATE      (
         P_EVENT_NO );
         RETURN ret_value;
   END GAS_LIFT_COMP_RATE;
   FUNCTION GAS_LIFT_COMP_VOLUME(
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FCST_COMPENSATION_EVENTS.GAS_LIFT_COMP_VOLUME      (
         P_EVENT_NO );
         RETURN ret_value;
   END GAS_LIFT_COMP_VOLUME;
   FUNCTION REC_ID(
      P_EVENT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_FCST_COMPENSATION_EVENTS.REC_ID      (
         P_EVENT_NO );
         RETURN ret_value;
   END REC_ID;
   FUNCTION TEXT_1(
      P_EVENT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (16) ;
   BEGIN
      ret_value := EC_FCST_COMPENSATION_EVENTS.TEXT_1      (
         P_EVENT_NO );
         RETURN ret_value;
   END TEXT_1;
   FUNCTION TEXT_2(
      P_EVENT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_FCST_COMPENSATION_EVENTS.TEXT_2      (
         P_EVENT_NO );
         RETURN ret_value;
   END TEXT_2;
   FUNCTION VALUE_7(
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FCST_COMPENSATION_EVENTS.VALUE_7      (
         P_EVENT_NO );
         RETURN ret_value;
   END VALUE_7;
   FUNCTION VALUE_9(
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FCST_COMPENSATION_EVENTS.VALUE_9      (
         P_EVENT_NO );
         RETURN ret_value;
   END VALUE_9;
   FUNCTION DATE_1(
      P_EVENT_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_FCST_COMPENSATION_EVENTS.DATE_1      (
         P_EVENT_NO );
         RETURN ret_value;
   END DATE_1;
   FUNCTION DAYTIME(
      P_EVENT_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_FCST_COMPENSATION_EVENTS.DAYTIME      (
         P_EVENT_NO );
         RETURN ret_value;
   END DAYTIME;
   FUNCTION END_DAY(
      P_EVENT_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_FCST_COMPENSATION_EVENTS.END_DAY      (
         P_EVENT_NO );
         RETURN ret_value;
   END END_DAY;
   FUNCTION GAS_INJ_COMP_RATE(
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FCST_COMPENSATION_EVENTS.GAS_INJ_COMP_RATE      (
         P_EVENT_NO );
         RETURN ret_value;
   END GAS_INJ_COMP_RATE;
   FUNCTION OIL_COMP_VOLUME(
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FCST_COMPENSATION_EVENTS.OIL_COMP_VOLUME      (
         P_EVENT_NO );
         RETURN ret_value;
   END OIL_COMP_VOLUME;
   FUNCTION REASON_CODE_1(
      P_EVENT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_FCST_COMPENSATION_EVENTS.REASON_CODE_1      (
         P_EVENT_NO );
         RETURN ret_value;
   END REASON_CODE_1;
   FUNCTION VALUE_10(
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FCST_COMPENSATION_EVENTS.VALUE_10      (
         P_EVENT_NO );
         RETURN ret_value;
   END VALUE_10;
   FUNCTION VALUE_11(
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FCST_COMPENSATION_EVENTS.VALUE_11      (
         P_EVENT_NO );
         RETURN ret_value;
   END VALUE_11;
   FUNCTION VALUE_14(
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FCST_COMPENSATION_EVENTS.VALUE_14      (
         P_EVENT_NO );
         RETURN ret_value;
   END VALUE_14;
   FUNCTION VALUE_8(
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FCST_COMPENSATION_EVENTS.VALUE_8      (
         P_EVENT_NO );
         RETURN ret_value;
   END VALUE_8;

END RP_FCST_COMPENSATION_EVENTS;

/
--GRANT EXECUTE ON ECKERNEL_WST.RP_FCST_COMPENSATION_EVENTS TO REPORT_ROLE_XXX;



 -- FINISH PKG_GEN_PKGS.sf_get_functions at:11/15/2018 09.57.35 AM


