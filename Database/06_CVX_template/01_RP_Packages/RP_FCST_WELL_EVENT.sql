
 -- START PKG_GEN_PKGS.sf_get_functions at:11/15/2018 09.22.42 AM


CREATE or REPLACE PACKAGE RP_FCST_WELL_EVENT
IS

   FUNCTION END_SUMMER_TIME(
      P_EVENT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION OIL_LOSS_VOLUME(
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION PARENT_OBJECT_ID(
      P_EVENT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION STEAM_INJ_LOSS_RATE(
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION TEXT_3(
      P_EVENT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_4(
      P_EVENT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_5(
      P_EVENT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TIME_ZONE(
      P_EVENT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION WATER_INJ_LOSS_RATE(
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION APPROVAL_BY(
      P_EVENT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_STATE(
      P_EVENT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION DILUENT_LOSS_RATE(
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION GAS_LOSS_RATE(
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION REASON_CODE_TYPE_1(
      P_EVENT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION SCHEDULED(
      P_EVENT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION STATUS(
      P_EVENT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION SUMMER_TIME(
      P_EVENT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION UTC_END_DATE(
      P_EVENT_NO IN NUMBER)
      RETURN DATE;
   FUNCTION VALUE_5(
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION WATER_LOSS_RATE(
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION WATER_LOSS_VOLUME(
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION EVENT_TYPE(
      P_EVENT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION MASTER_EVENT_ID(
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION NEXT_DAYTIME(
      P_EVENT_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION OBJECT_ID(
      P_EVENT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION PARENT_MASTER_EVENT_ID(
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION PREV_EQUAL_DAYTIME(
      P_EVENT_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION CO2_INJ_LOSS_RATE(
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION COMMENTS(
      P_EVENT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION DATE_3(
      P_EVENT_NO IN NUMBER)
      RETURN DATE;
   FUNCTION DATE_5(
      P_EVENT_NO IN NUMBER)
      RETURN DATE;
   FUNCTION DEFERMENT_TYPE(
      P_EVENT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION EQUIPMENT_ID(
      P_EVENT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION GAS_INJ_LOSS_RATE(
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION GAS_LIFT_LOSS_RATE(
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION NEXT_EQUAL_DAYTIME(
      P_EVENT_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION OIL_LOSS_RATE(
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION TEXT_6(
      P_EVENT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_9(
      P_EVENT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION UTC_DAYTIME(
      P_EVENT_NO IN NUMBER)
      RETURN DATE;
   FUNCTION VALUE_6(
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION DATE_2(
      P_EVENT_NO IN NUMBER)
      RETURN DATE;
   FUNCTION END_DATE(
      P_EVENT_NO IN NUMBER)
      RETURN DATE;
   FUNCTION PREV_DAYTIME(
      P_EVENT_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION RECORD_STATUS(
      P_EVENT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_10(
      P_EVENT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_7(
      P_EVENT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_1(
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION WATER_INJ_LOSS_VOLUME(
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION APPROVAL_DATE(
      P_EVENT_NO IN NUMBER)
      RETURN DATE;
   FUNCTION COND_LOSS_VOLUME(
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION FORECAST_ID(
      P_EVENT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION GAS_LIFT_LOSS_VOLUME(
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION GAS_LOSS_VOLUME(
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION OBJECT_TYPE(
      P_EVENT_NO IN NUMBER)
      RETURN VARCHAR2;
      TYPE REC_ROW_BY_PK IS RECORD (
         EVENT_ID VARCHAR2 (32) ,
         OBJECT_TYPE VARCHAR2 (32) ,
         FORECAST_ID VARCHAR2 (32) ,
         OBJECT_ID VARCHAR2 (32) ,
         EVENT_NO NUMBER ,
         PARENT_EVENT_NO NUMBER ,
         EVENT_TYPE VARCHAR2 (32) ,
         DEFERMENT_TYPE VARCHAR2 (32) ,
         SCHEDULED VARCHAR2 (1) ,
         DAYTIME  DATE ,
         END_DATE  DATE ,
         END_SUMMER_TIME VARCHAR2 (1) ,
         END_TIME_ZONE VARCHAR2 (65) ,
         TIME_ZONE VARCHAR2 (65) ,
         UTC_END_DATE  DATE ,
         UTC_DAYTIME  DATE ,
         MASTER_EVENT_ID NUMBER ,
         PARENT_DAYTIME  DATE ,
         PARENT_MASTER_EVENT_ID NUMBER ,
         PARENT_OBJECT_ID VARCHAR2 (32) ,
         REASON_CODE_1 VARCHAR2 (32) ,
         REASON_CODE_TYPE_1 VARCHAR2 (32) ,
         COND_LOSS_RATE NUMBER ,
         COND_LOSS_VOLUME NUMBER ,
         GAS_LOSS_RATE NUMBER ,
         GAS_LOSS_VOLUME NUMBER ,
         GAS_INJ_LOSS_RATE NUMBER ,
         GAS_INJ_LOSS_VOLUME NUMBER ,
         OIL_LOSS_RATE NUMBER ,
         OIL_LOSS_VOLUME NUMBER ,
         STEAM_INJ_LOSS_RATE NUMBER ,
         STEAM_INJ_LOSS_VOLUME NUMBER ,
         WATER_INJ_LOSS_RATE NUMBER ,
         WATER_INJ_LOSS_VOLUME NUMBER ,
         WATER_LOSS_RATE NUMBER ,
         WATER_LOSS_VOLUME NUMBER ,
         DILUENT_LOSS_RATE NUMBER ,
         DILUENT_LOSS_VOLUME NUMBER ,
         GAS_LIFT_LOSS_RATE NUMBER ,
         GAS_LIFT_LOSS_VOLUME NUMBER ,
         STATUS VARCHAR2 (32) ,
         DAY  DATE ,
         END_DAY  DATE ,
         SUMMER_TIME VARCHAR2 (1) ,
         EQUIPMENT_ID VARCHAR2 (32) ,
         EVENT_TAG VARCHAR2 (100) ,
         CO2_INJ_LOSS_RATE NUMBER ,
         CO2_INJ_LOSS_VOLUME NUMBER ,
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
         TEXT_5 VARCHAR2 (64) ,
         TEXT_6 VARCHAR2 (64) ,
         TEXT_7 VARCHAR2 (64) ,
         TEXT_8 VARCHAR2 (64) ,
         TEXT_9 VARCHAR2 (64) ,
         TEXT_10 VARCHAR2 (64) ,
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
      P_EVENT_NO IN NUMBER)
      RETURN REC_ROW_BY_PK;
   FUNCTION STEAM_INJ_LOSS_VOLUME(
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_2(
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_3(
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_4(
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION CO2_INJ_LOSS_VOLUME(
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION DATE_4(
      P_EVENT_NO IN NUMBER)
      RETURN DATE;
   FUNCTION DAY(
      P_EVENT_NO IN NUMBER)
      RETURN DATE;
   FUNCTION DILUENT_LOSS_VOLUME(
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION END_TIME_ZONE(
      P_EVENT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION EVENT_ID(
      P_EVENT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION EVENT_TAG(
      P_EVENT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION GAS_INJ_LOSS_VOLUME(
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION PARENT_EVENT_NO(
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
   FUNCTION TEXT_8(
      P_EVENT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_7(
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_9(
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION COND_LOSS_RATE(
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
   FUNCTION PARENT_DAYTIME(
      P_EVENT_NO IN NUMBER)
      RETURN DATE;
   FUNCTION REASON_CODE_1(
      P_EVENT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_10(
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_8(
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER;

END RP_FCST_WELL_EVENT;

/



CREATE or REPLACE PACKAGE BODY RP_FCST_WELL_EVENT
IS

   FUNCTION END_SUMMER_TIME(
      P_EVENT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_FCST_WELL_EVENT.END_SUMMER_TIME      (
         P_EVENT_NO );
         RETURN ret_value;
   END END_SUMMER_TIME;
   FUNCTION OIL_LOSS_VOLUME(
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FCST_WELL_EVENT.OIL_LOSS_VOLUME      (
         P_EVENT_NO );
         RETURN ret_value;
   END OIL_LOSS_VOLUME;
   FUNCTION PARENT_OBJECT_ID(
      P_EVENT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_FCST_WELL_EVENT.PARENT_OBJECT_ID      (
         P_EVENT_NO );
         RETURN ret_value;
   END PARENT_OBJECT_ID;
   FUNCTION STEAM_INJ_LOSS_RATE(
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FCST_WELL_EVENT.STEAM_INJ_LOSS_RATE      (
         P_EVENT_NO );
         RETURN ret_value;
   END STEAM_INJ_LOSS_RATE;
   FUNCTION TEXT_3(
      P_EVENT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_FCST_WELL_EVENT.TEXT_3      (
         P_EVENT_NO );
         RETURN ret_value;
   END TEXT_3;
   FUNCTION TEXT_4(
      P_EVENT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_FCST_WELL_EVENT.TEXT_4      (
         P_EVENT_NO );
         RETURN ret_value;
   END TEXT_4;
   FUNCTION TEXT_5(
      P_EVENT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (64) ;
   BEGIN
      ret_value := EC_FCST_WELL_EVENT.TEXT_5      (
         P_EVENT_NO );
         RETURN ret_value;
   END TEXT_5;
   FUNCTION TIME_ZONE(
      P_EVENT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (65) ;
   BEGIN
      ret_value := EC_FCST_WELL_EVENT.TIME_ZONE      (
         P_EVENT_NO );
         RETURN ret_value;
   END TIME_ZONE;
   FUNCTION WATER_INJ_LOSS_RATE(
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FCST_WELL_EVENT.WATER_INJ_LOSS_RATE      (
         P_EVENT_NO );
         RETURN ret_value;
   END WATER_INJ_LOSS_RATE;
   FUNCTION APPROVAL_BY(
      P_EVENT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (30) ;
   BEGIN
      ret_value := EC_FCST_WELL_EVENT.APPROVAL_BY      (
         P_EVENT_NO );
         RETURN ret_value;
   END APPROVAL_BY;
   FUNCTION APPROVAL_STATE(
      P_EVENT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_FCST_WELL_EVENT.APPROVAL_STATE      (
         P_EVENT_NO );
         RETURN ret_value;
   END APPROVAL_STATE;
   FUNCTION DILUENT_LOSS_RATE(
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FCST_WELL_EVENT.DILUENT_LOSS_RATE      (
         P_EVENT_NO );
         RETURN ret_value;
   END DILUENT_LOSS_RATE;
   FUNCTION GAS_LOSS_RATE(
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FCST_WELL_EVENT.GAS_LOSS_RATE      (
         P_EVENT_NO );
         RETURN ret_value;
   END GAS_LOSS_RATE;
   FUNCTION REASON_CODE_TYPE_1(
      P_EVENT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_FCST_WELL_EVENT.REASON_CODE_TYPE_1      (
         P_EVENT_NO );
         RETURN ret_value;
   END REASON_CODE_TYPE_1;
   FUNCTION SCHEDULED(
      P_EVENT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_FCST_WELL_EVENT.SCHEDULED      (
         P_EVENT_NO );
         RETURN ret_value;
   END SCHEDULED;
   FUNCTION STATUS(
      P_EVENT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_FCST_WELL_EVENT.STATUS      (
         P_EVENT_NO );
         RETURN ret_value;
   END STATUS;
   FUNCTION SUMMER_TIME(
      P_EVENT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_FCST_WELL_EVENT.SUMMER_TIME      (
         P_EVENT_NO );
         RETURN ret_value;
   END SUMMER_TIME;
   FUNCTION UTC_END_DATE(
      P_EVENT_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_FCST_WELL_EVENT.UTC_END_DATE      (
         P_EVENT_NO );
         RETURN ret_value;
   END UTC_END_DATE;
   FUNCTION VALUE_5(
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FCST_WELL_EVENT.VALUE_5      (
         P_EVENT_NO );
         RETURN ret_value;
   END VALUE_5;
   FUNCTION WATER_LOSS_RATE(
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FCST_WELL_EVENT.WATER_LOSS_RATE      (
         P_EVENT_NO );
         RETURN ret_value;
   END WATER_LOSS_RATE;
   FUNCTION WATER_LOSS_VOLUME(
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FCST_WELL_EVENT.WATER_LOSS_VOLUME      (
         P_EVENT_NO );
         RETURN ret_value;
   END WATER_LOSS_VOLUME;
   FUNCTION EVENT_TYPE(
      P_EVENT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_FCST_WELL_EVENT.EVENT_TYPE      (
         P_EVENT_NO );
         RETURN ret_value;
   END EVENT_TYPE;
   FUNCTION MASTER_EVENT_ID(
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FCST_WELL_EVENT.MASTER_EVENT_ID      (
         P_EVENT_NO );
         RETURN ret_value;
   END MASTER_EVENT_ID;
   FUNCTION NEXT_DAYTIME(
      P_EVENT_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_FCST_WELL_EVENT.NEXT_DAYTIME      (
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
      ret_value := EC_FCST_WELL_EVENT.OBJECT_ID      (
         P_EVENT_NO );
         RETURN ret_value;
   END OBJECT_ID;
   FUNCTION PARENT_MASTER_EVENT_ID(
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FCST_WELL_EVENT.PARENT_MASTER_EVENT_ID      (
         P_EVENT_NO );
         RETURN ret_value;
   END PARENT_MASTER_EVENT_ID;
   FUNCTION PREV_EQUAL_DAYTIME(
      P_EVENT_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_FCST_WELL_EVENT.PREV_EQUAL_DAYTIME      (
         P_EVENT_NO,
         P_NUM_ROWS );
         RETURN ret_value;
   END PREV_EQUAL_DAYTIME;
   FUNCTION CO2_INJ_LOSS_RATE(
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FCST_WELL_EVENT.CO2_INJ_LOSS_RATE      (
         P_EVENT_NO );
         RETURN ret_value;
   END CO2_INJ_LOSS_RATE;
   FUNCTION COMMENTS(
      P_EVENT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_FCST_WELL_EVENT.COMMENTS      (
         P_EVENT_NO );
         RETURN ret_value;
   END COMMENTS;
   FUNCTION DATE_3(
      P_EVENT_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_FCST_WELL_EVENT.DATE_3      (
         P_EVENT_NO );
         RETURN ret_value;
   END DATE_3;
   FUNCTION DATE_5(
      P_EVENT_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_FCST_WELL_EVENT.DATE_5      (
         P_EVENT_NO );
         RETURN ret_value;
   END DATE_5;
   FUNCTION DEFERMENT_TYPE(
      P_EVENT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_FCST_WELL_EVENT.DEFERMENT_TYPE      (
         P_EVENT_NO );
         RETURN ret_value;
   END DEFERMENT_TYPE;
   FUNCTION EQUIPMENT_ID(
      P_EVENT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_FCST_WELL_EVENT.EQUIPMENT_ID      (
         P_EVENT_NO );
         RETURN ret_value;
   END EQUIPMENT_ID;
   FUNCTION GAS_INJ_LOSS_RATE(
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FCST_WELL_EVENT.GAS_INJ_LOSS_RATE      (
         P_EVENT_NO );
         RETURN ret_value;
   END GAS_INJ_LOSS_RATE;
   FUNCTION GAS_LIFT_LOSS_RATE(
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FCST_WELL_EVENT.GAS_LIFT_LOSS_RATE      (
         P_EVENT_NO );
         RETURN ret_value;
   END GAS_LIFT_LOSS_RATE;
   FUNCTION NEXT_EQUAL_DAYTIME(
      P_EVENT_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_FCST_WELL_EVENT.NEXT_EQUAL_DAYTIME      (
         P_EVENT_NO,
         P_NUM_ROWS );
         RETURN ret_value;
   END NEXT_EQUAL_DAYTIME;
   FUNCTION OIL_LOSS_RATE(
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FCST_WELL_EVENT.OIL_LOSS_RATE      (
         P_EVENT_NO );
         RETURN ret_value;
   END OIL_LOSS_RATE;
   FUNCTION TEXT_6(
      P_EVENT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (64) ;
   BEGIN
      ret_value := EC_FCST_WELL_EVENT.TEXT_6      (
         P_EVENT_NO );
         RETURN ret_value;
   END TEXT_6;
   FUNCTION TEXT_9(
      P_EVENT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (64) ;
   BEGIN
      ret_value := EC_FCST_WELL_EVENT.TEXT_9      (
         P_EVENT_NO );
         RETURN ret_value;
   END TEXT_9;
   FUNCTION UTC_DAYTIME(
      P_EVENT_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_FCST_WELL_EVENT.UTC_DAYTIME      (
         P_EVENT_NO );
         RETURN ret_value;
   END UTC_DAYTIME;
   FUNCTION VALUE_6(
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FCST_WELL_EVENT.VALUE_6      (
         P_EVENT_NO );
         RETURN ret_value;
   END VALUE_6;
   FUNCTION DATE_2(
      P_EVENT_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_FCST_WELL_EVENT.DATE_2      (
         P_EVENT_NO );
         RETURN ret_value;
   END DATE_2;
   FUNCTION END_DATE(
      P_EVENT_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_FCST_WELL_EVENT.END_DATE      (
         P_EVENT_NO );
         RETURN ret_value;
   END END_DATE;
   FUNCTION PREV_DAYTIME(
      P_EVENT_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_FCST_WELL_EVENT.PREV_DAYTIME      (
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
      ret_value := EC_FCST_WELL_EVENT.RECORD_STATUS      (
         P_EVENT_NO );
         RETURN ret_value;
   END RECORD_STATUS;
   FUNCTION TEXT_10(
      P_EVENT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (64) ;
   BEGIN
      ret_value := EC_FCST_WELL_EVENT.TEXT_10      (
         P_EVENT_NO );
         RETURN ret_value;
   END TEXT_10;
   FUNCTION TEXT_7(
      P_EVENT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (64) ;
   BEGIN
      ret_value := EC_FCST_WELL_EVENT.TEXT_7      (
         P_EVENT_NO );
         RETURN ret_value;
   END TEXT_7;
   FUNCTION VALUE_1(
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FCST_WELL_EVENT.VALUE_1      (
         P_EVENT_NO );
         RETURN ret_value;
   END VALUE_1;
   FUNCTION WATER_INJ_LOSS_VOLUME(
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FCST_WELL_EVENT.WATER_INJ_LOSS_VOLUME      (
         P_EVENT_NO );
         RETURN ret_value;
   END WATER_INJ_LOSS_VOLUME;
   FUNCTION APPROVAL_DATE(
      P_EVENT_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_FCST_WELL_EVENT.APPROVAL_DATE      (
         P_EVENT_NO );
         RETURN ret_value;
   END APPROVAL_DATE;
   FUNCTION COND_LOSS_VOLUME(
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FCST_WELL_EVENT.COND_LOSS_VOLUME      (
         P_EVENT_NO );
         RETURN ret_value;
   END COND_LOSS_VOLUME;
   FUNCTION FORECAST_ID(
      P_EVENT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_FCST_WELL_EVENT.FORECAST_ID      (
         P_EVENT_NO );
         RETURN ret_value;
   END FORECAST_ID;
   FUNCTION GAS_LIFT_LOSS_VOLUME(
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FCST_WELL_EVENT.GAS_LIFT_LOSS_VOLUME      (
         P_EVENT_NO );
         RETURN ret_value;
   END GAS_LIFT_LOSS_VOLUME;
   FUNCTION GAS_LOSS_VOLUME(
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FCST_WELL_EVENT.GAS_LOSS_VOLUME      (
         P_EVENT_NO );
         RETURN ret_value;
   END GAS_LOSS_VOLUME;
   FUNCTION OBJECT_TYPE(
      P_EVENT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_FCST_WELL_EVENT.OBJECT_TYPE      (
         P_EVENT_NO );
         RETURN ret_value;
   END OBJECT_TYPE;
   FUNCTION ROW_BY_PK(
      P_EVENT_NO IN NUMBER)
      RETURN REC_ROW_BY_PK
   IS
      ret_value    REC_ROW_BY_PK ;
   BEGIN
      ret_value := EC_FCST_WELL_EVENT.ROW_BY_PK      (
         P_EVENT_NO );
         RETURN ret_value;
   END ROW_BY_PK;
   FUNCTION STEAM_INJ_LOSS_VOLUME(
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FCST_WELL_EVENT.STEAM_INJ_LOSS_VOLUME      (
         P_EVENT_NO );
         RETURN ret_value;
   END STEAM_INJ_LOSS_VOLUME;
   FUNCTION VALUE_2(
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FCST_WELL_EVENT.VALUE_2      (
         P_EVENT_NO );
         RETURN ret_value;
   END VALUE_2;
   FUNCTION VALUE_3(
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FCST_WELL_EVENT.VALUE_3      (
         P_EVENT_NO );
         RETURN ret_value;
   END VALUE_3;
   FUNCTION VALUE_4(
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FCST_WELL_EVENT.VALUE_4      (
         P_EVENT_NO );
         RETURN ret_value;
   END VALUE_4;
   FUNCTION CO2_INJ_LOSS_VOLUME(
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FCST_WELL_EVENT.CO2_INJ_LOSS_VOLUME      (
         P_EVENT_NO );
         RETURN ret_value;
   END CO2_INJ_LOSS_VOLUME;
   FUNCTION DATE_4(
      P_EVENT_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_FCST_WELL_EVENT.DATE_4      (
         P_EVENT_NO );
         RETURN ret_value;
   END DATE_4;
   FUNCTION DAY(
      P_EVENT_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_FCST_WELL_EVENT.DAY      (
         P_EVENT_NO );
         RETURN ret_value;
   END DAY;
   FUNCTION DILUENT_LOSS_VOLUME(
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FCST_WELL_EVENT.DILUENT_LOSS_VOLUME      (
         P_EVENT_NO );
         RETURN ret_value;
   END DILUENT_LOSS_VOLUME;
   FUNCTION END_TIME_ZONE(
      P_EVENT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (65) ;
   BEGIN
      ret_value := EC_FCST_WELL_EVENT.END_TIME_ZONE      (
         P_EVENT_NO );
         RETURN ret_value;
   END END_TIME_ZONE;
   FUNCTION EVENT_ID(
      P_EVENT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_FCST_WELL_EVENT.EVENT_ID      (
         P_EVENT_NO );
         RETURN ret_value;
   END EVENT_ID;
   FUNCTION EVENT_TAG(
      P_EVENT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (100) ;
   BEGIN
      ret_value := EC_FCST_WELL_EVENT.EVENT_TAG      (
         P_EVENT_NO );
         RETURN ret_value;
   END EVENT_TAG;
   FUNCTION GAS_INJ_LOSS_VOLUME(
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FCST_WELL_EVENT.GAS_INJ_LOSS_VOLUME      (
         P_EVENT_NO );
         RETURN ret_value;
   END GAS_INJ_LOSS_VOLUME;
   FUNCTION PARENT_EVENT_NO(
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FCST_WELL_EVENT.PARENT_EVENT_NO      (
         P_EVENT_NO );
         RETURN ret_value;
   END PARENT_EVENT_NO;
   FUNCTION REC_ID(
      P_EVENT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_FCST_WELL_EVENT.REC_ID      (
         P_EVENT_NO );
         RETURN ret_value;
   END REC_ID;
   FUNCTION TEXT_1(
      P_EVENT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (16) ;
   BEGIN
      ret_value := EC_FCST_WELL_EVENT.TEXT_1      (
         P_EVENT_NO );
         RETURN ret_value;
   END TEXT_1;
   FUNCTION TEXT_2(
      P_EVENT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_FCST_WELL_EVENT.TEXT_2      (
         P_EVENT_NO );
         RETURN ret_value;
   END TEXT_2;
   FUNCTION TEXT_8(
      P_EVENT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (64) ;
   BEGIN
      ret_value := EC_FCST_WELL_EVENT.TEXT_8      (
         P_EVENT_NO );
         RETURN ret_value;
   END TEXT_8;
   FUNCTION VALUE_7(
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FCST_WELL_EVENT.VALUE_7      (
         P_EVENT_NO );
         RETURN ret_value;
   END VALUE_7;
   FUNCTION VALUE_9(
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FCST_WELL_EVENT.VALUE_9      (
         P_EVENT_NO );
         RETURN ret_value;
   END VALUE_9;
   FUNCTION COND_LOSS_RATE(
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FCST_WELL_EVENT.COND_LOSS_RATE      (
         P_EVENT_NO );
         RETURN ret_value;
   END COND_LOSS_RATE;
   FUNCTION DATE_1(
      P_EVENT_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_FCST_WELL_EVENT.DATE_1      (
         P_EVENT_NO );
         RETURN ret_value;
   END DATE_1;
   FUNCTION DAYTIME(
      P_EVENT_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_FCST_WELL_EVENT.DAYTIME      (
         P_EVENT_NO );
         RETURN ret_value;
   END DAYTIME;
   FUNCTION END_DAY(
      P_EVENT_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_FCST_WELL_EVENT.END_DAY      (
         P_EVENT_NO );
         RETURN ret_value;
   END END_DAY;
   FUNCTION PARENT_DAYTIME(
      P_EVENT_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_FCST_WELL_EVENT.PARENT_DAYTIME      (
         P_EVENT_NO );
         RETURN ret_value;
   END PARENT_DAYTIME;
   FUNCTION REASON_CODE_1(
      P_EVENT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_FCST_WELL_EVENT.REASON_CODE_1      (
         P_EVENT_NO );
         RETURN ret_value;
   END REASON_CODE_1;
   FUNCTION VALUE_10(
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FCST_WELL_EVENT.VALUE_10      (
         P_EVENT_NO );
         RETURN ret_value;
   END VALUE_10;
   FUNCTION VALUE_8(
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FCST_WELL_EVENT.VALUE_8      (
         P_EVENT_NO );
         RETURN ret_value;
   END VALUE_8;

END RP_FCST_WELL_EVENT;

/
--GRANT EXECUTE ON ECKERNEL_WST.RP_FCST_WELL_EVENT TO REPORT_ROLE_XXX;



 -- FINISH PKG_GEN_PKGS.sf_get_functions at:11/15/2018 09.22.58 AM


