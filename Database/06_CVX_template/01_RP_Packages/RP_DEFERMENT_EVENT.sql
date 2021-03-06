
 -- START PKG_GEN_PKGS.sf_get_functions at:05/07/2019 10.26.36 AM


CREATE or REPLACE PACKAGE RP_DEFERMENT_EVENT
IS

   FUNCTION COND_LOSS_MASS_RATE(
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION END_SUMMER_TIME(
      P_EVENT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION OIL_LOSS_VOLUME(
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION PARENT_OBJECT_ID(
      P_EVENT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION REASON_CODE_TYPE_8(
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
   FUNCTION WATER_INJ_LOSS_RATE(
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION WATER_LOSS_MASS_RATE(
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
   FUNCTION GAS_LOSS_MASS_RATE(
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION GAS_LOSS_RATE(
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION REASON_CODE_3(
      P_EVENT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION REASON_CODE_7(
      P_EVENT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION REASON_CODE_TYPE_1(
      P_EVENT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION REASON_CODE_TYPE_5(
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
   FUNCTION GAS_LIFT_LOSS_MASS(
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION GAS_LIFT_LOSS_MASS_RATE(
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER;
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
   FUNCTION REASON_CODE_5(
      P_EVENT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION REASON_CODE_TYPE_10(
      P_EVENT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION REASON_CODE_TYPE_2(
      P_EVENT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION REASON_CODE_TYPE_4(
      P_EVENT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION REASON_CODE_TYPE_7(
      P_EVENT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION CLASS_NAME(
      P_EVENT_NO IN NUMBER)
      RETURN VARCHAR2;
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
   FUNCTION REASON_CODE_8(
      P_EVENT_NO IN NUMBER)
      RETURN VARCHAR2;
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
   FUNCTION WATER_INJ_LOSS_MASS(
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION DATE_2(
      P_EVENT_NO IN NUMBER)
      RETURN DATE;
   FUNCTION END_DATE(
      P_EVENT_NO IN NUMBER)
      RETURN DATE;
   FUNCTION GAS_INJ_LOSS_MASS(
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION GAS_INJ_LOSS_MASS_RATE(
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION PREV_DAYTIME(
      P_EVENT_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION REASON_CODE_4(
      P_EVENT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION REASON_CODE_9(
      P_EVENT_NO IN NUMBER)
      RETURN VARCHAR2;
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
   FUNCTION COND_LOSS_MASS(
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION COND_LOSS_VOLUME(
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION GAS_LIFT_LOSS_VOLUME(
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION GAS_LOSS_VOLUME(
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION OBJECT_TYPE(
      P_EVENT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION OIL_LOSS_MASS(
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION REASON_CODE_10(
      P_EVENT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION REASON_CODE_TYPE_9(
      P_EVENT_NO IN NUMBER)
      RETURN VARCHAR2;
      TYPE REC_ROW_BY_PK IS RECORD (
         OBJECT_ID VARCHAR2 (32) ,
         OBJECT_TYPE VARCHAR2 (32) ,
         CLASS_NAME VARCHAR2 (24) ,
         EVENT_NO NUMBER ,
         PARENT_EVENT_NO NUMBER ,
         EVENT_TYPE VARCHAR2 (32) ,
         DEFERMENT_TYPE VARCHAR2 (32) ,
         SCHEDULED VARCHAR2 (1) ,
         DAYTIME  DATE ,
         END_DATE  DATE ,
         END_SUMMER_TIME VARCHAR2 (1) ,
         UTC_END_DATE  DATE ,
         UTC_DAYTIME  DATE ,
         MASTER_EVENT_ID NUMBER ,
         PARENT_DAYTIME  DATE ,
         PARENT_MASTER_EVENT_ID NUMBER ,
         PARENT_OBJECT_ID VARCHAR2 (32) ,
         REASON_CODE_1 VARCHAR2 (32) ,
         REASON_CODE_2 VARCHAR2 (32) ,
         REASON_CODE_3 VARCHAR2 (32) ,
         REASON_CODE_4 VARCHAR2 (32) ,
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
         OIL_LOSS_MASS NUMBER ,
         GAS_LOSS_MASS NUMBER ,
         COND_LOSS_MASS NUMBER ,
         WATER_LOSS_MASS NUMBER ,
         WATER_INJ_LOSS_MASS NUMBER ,
         STEAM_INJ_LOSS_MASS NUMBER ,
         GAS_INJ_LOSS_MASS NUMBER ,
         GAS_LIFT_LOSS_MASS NUMBER ,
         OIL_LOSS_MASS_RATE NUMBER ,
         GAS_LOSS_MASS_RATE NUMBER ,
         COND_LOSS_MASS_RATE NUMBER ,
         WATER_LOSS_MASS_RATE NUMBER ,
         WATER_INJ_LOSS_MASS_RATE NUMBER ,
         STEAM_INJ_LOSS_MASS_RATE NUMBER ,
         GAS_INJ_LOSS_MASS_RATE NUMBER ,
         GAS_LIFT_LOSS_MASS_RATE NUMBER ,
         STATUS VARCHAR2 (32) ,
         EVENT_TAG VARCHAR2 (100) ,
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
         REASON_CODE_TYPE_1 VARCHAR2 (32) ,
         REASON_CODE_TYPE_2 VARCHAR2 (32) ,
         REASON_CODE_TYPE_3 VARCHAR2 (32) ,
         REASON_CODE_TYPE_4 VARCHAR2 (32) ,
         DAY  DATE ,
         END_DAY  DATE ,
         SUMMER_TIME VARCHAR2 (1) ,
         DILUENT_LOSS_RATE NUMBER ,
         DILUENT_LOSS_VOLUME NUMBER ,
         GAS_LIFT_LOSS_RATE NUMBER ,
         GAS_LIFT_LOSS_VOLUME NUMBER ,
         EQUIPMENT_ID VARCHAR2 (32) ,
         REASON_CODE_5 VARCHAR2 (32) ,
         REASON_CODE_6 VARCHAR2 (32) ,
         REASON_CODE_7 VARCHAR2 (32) ,
         REASON_CODE_8 VARCHAR2 (32) ,
         REASON_CODE_9 VARCHAR2 (32) ,
         REASON_CODE_10 VARCHAR2 (32) ,
         REASON_CODE_TYPE_5 VARCHAR2 (32) ,
         REASON_CODE_TYPE_6 VARCHAR2 (32) ,
         REASON_CODE_TYPE_7 VARCHAR2 (32) ,
         REASON_CODE_TYPE_8 VARCHAR2 (32) ,
         REASON_CODE_TYPE_9 VARCHAR2 (32) ,
         REASON_CODE_TYPE_10 VARCHAR2 (32) ,
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
   FUNCTION STEAM_INJ_LOSS_MASS(
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER;
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
   FUNCTION WATER_LOSS_MASS(
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
   FUNCTION EVENT_TAG(
      P_EVENT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION GAS_INJ_LOSS_VOLUME(
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION OIL_LOSS_MASS_RATE(
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION PARENT_EVENT_NO(
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION REASON_CODE_2(
      P_EVENT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION REASON_CODE_TYPE_3(
      P_EVENT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION REASON_CODE_TYPE_6(
      P_EVENT_NO IN NUMBER)
      RETURN VARCHAR2;
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
   FUNCTION WATER_INJ_LOSS_MASS_RATE(
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
   FUNCTION GAS_LOSS_MASS(
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION PARENT_DAYTIME(
      P_EVENT_NO IN NUMBER)
      RETURN DATE;
   FUNCTION REASON_CODE_1(
      P_EVENT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION REASON_CODE_6(
      P_EVENT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION STEAM_INJ_LOSS_MASS_RATE(
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_10(
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_8(
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER;

END RP_DEFERMENT_EVENT;

/



CREATE or REPLACE PACKAGE BODY RP_DEFERMENT_EVENT
IS

   FUNCTION COND_LOSS_MASS_RATE(
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_DEFERMENT_EVENT.COND_LOSS_MASS_RATE      (
         P_EVENT_NO );
         RETURN ret_value;
   END COND_LOSS_MASS_RATE;
   FUNCTION END_SUMMER_TIME(
      P_EVENT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_DEFERMENT_EVENT.END_SUMMER_TIME      (
         P_EVENT_NO );
         RETURN ret_value;
   END END_SUMMER_TIME;
   FUNCTION OIL_LOSS_VOLUME(
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_DEFERMENT_EVENT.OIL_LOSS_VOLUME      (
         P_EVENT_NO );
         RETURN ret_value;
   END OIL_LOSS_VOLUME;
   FUNCTION PARENT_OBJECT_ID(
      P_EVENT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_DEFERMENT_EVENT.PARENT_OBJECT_ID      (
         P_EVENT_NO );
         RETURN ret_value;
   END PARENT_OBJECT_ID;
   FUNCTION REASON_CODE_TYPE_8(
      P_EVENT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_DEFERMENT_EVENT.REASON_CODE_TYPE_8      (
         P_EVENT_NO );
         RETURN ret_value;
   END REASON_CODE_TYPE_8;
   FUNCTION STEAM_INJ_LOSS_RATE(
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_DEFERMENT_EVENT.STEAM_INJ_LOSS_RATE      (
         P_EVENT_NO );
         RETURN ret_value;
   END STEAM_INJ_LOSS_RATE;
   FUNCTION TEXT_3(
      P_EVENT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_DEFERMENT_EVENT.TEXT_3      (
         P_EVENT_NO );
         RETURN ret_value;
   END TEXT_3;
   FUNCTION TEXT_4(
      P_EVENT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_DEFERMENT_EVENT.TEXT_4      (
         P_EVENT_NO );
         RETURN ret_value;
   END TEXT_4;
   FUNCTION TEXT_5(
      P_EVENT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (64) ;
   BEGIN
      ret_value := EC_DEFERMENT_EVENT.TEXT_5      (
         P_EVENT_NO );
         RETURN ret_value;
   END TEXT_5;
   FUNCTION WATER_INJ_LOSS_RATE(
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_DEFERMENT_EVENT.WATER_INJ_LOSS_RATE      (
         P_EVENT_NO );
         RETURN ret_value;
   END WATER_INJ_LOSS_RATE;
   FUNCTION WATER_LOSS_MASS_RATE(
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_DEFERMENT_EVENT.WATER_LOSS_MASS_RATE      (
         P_EVENT_NO );
         RETURN ret_value;
   END WATER_LOSS_MASS_RATE;
   FUNCTION APPROVAL_BY(
      P_EVENT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (30) ;
   BEGIN
      ret_value := EC_DEFERMENT_EVENT.APPROVAL_BY      (
         P_EVENT_NO );
         RETURN ret_value;
   END APPROVAL_BY;
   FUNCTION APPROVAL_STATE(
      P_EVENT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_DEFERMENT_EVENT.APPROVAL_STATE      (
         P_EVENT_NO );
         RETURN ret_value;
   END APPROVAL_STATE;
   FUNCTION DILUENT_LOSS_RATE(
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_DEFERMENT_EVENT.DILUENT_LOSS_RATE      (
         P_EVENT_NO );
         RETURN ret_value;
   END DILUENT_LOSS_RATE;
   FUNCTION GAS_LOSS_MASS_RATE(
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_DEFERMENT_EVENT.GAS_LOSS_MASS_RATE      (
         P_EVENT_NO );
         RETURN ret_value;
   END GAS_LOSS_MASS_RATE;
   FUNCTION GAS_LOSS_RATE(
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_DEFERMENT_EVENT.GAS_LOSS_RATE      (
         P_EVENT_NO );
         RETURN ret_value;
   END GAS_LOSS_RATE;
   FUNCTION REASON_CODE_3(
      P_EVENT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_DEFERMENT_EVENT.REASON_CODE_3      (
         P_EVENT_NO );
         RETURN ret_value;
   END REASON_CODE_3;
   FUNCTION REASON_CODE_7(
      P_EVENT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_DEFERMENT_EVENT.REASON_CODE_7      (
         P_EVENT_NO );
         RETURN ret_value;
   END REASON_CODE_7;
   FUNCTION REASON_CODE_TYPE_1(
      P_EVENT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_DEFERMENT_EVENT.REASON_CODE_TYPE_1      (
         P_EVENT_NO );
         RETURN ret_value;
   END REASON_CODE_TYPE_1;
   FUNCTION REASON_CODE_TYPE_5(
      P_EVENT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_DEFERMENT_EVENT.REASON_CODE_TYPE_5      (
         P_EVENT_NO );
         RETURN ret_value;
   END REASON_CODE_TYPE_5;
   FUNCTION SCHEDULED(
      P_EVENT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_DEFERMENT_EVENT.SCHEDULED      (
         P_EVENT_NO );
         RETURN ret_value;
   END SCHEDULED;
   FUNCTION STATUS(
      P_EVENT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_DEFERMENT_EVENT.STATUS      (
         P_EVENT_NO );
         RETURN ret_value;
   END STATUS;
   FUNCTION SUMMER_TIME(
      P_EVENT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_DEFERMENT_EVENT.SUMMER_TIME      (
         P_EVENT_NO );
         RETURN ret_value;
   END SUMMER_TIME;
   FUNCTION UTC_END_DATE(
      P_EVENT_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_DEFERMENT_EVENT.UTC_END_DATE      (
         P_EVENT_NO );
         RETURN ret_value;
   END UTC_END_DATE;
   FUNCTION VALUE_5(
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_DEFERMENT_EVENT.VALUE_5      (
         P_EVENT_NO );
         RETURN ret_value;
   END VALUE_5;
   FUNCTION WATER_LOSS_RATE(
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_DEFERMENT_EVENT.WATER_LOSS_RATE      (
         P_EVENT_NO );
         RETURN ret_value;
   END WATER_LOSS_RATE;
   FUNCTION WATER_LOSS_VOLUME(
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_DEFERMENT_EVENT.WATER_LOSS_VOLUME      (
         P_EVENT_NO );
         RETURN ret_value;
   END WATER_LOSS_VOLUME;
   FUNCTION EVENT_TYPE(
      P_EVENT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_DEFERMENT_EVENT.EVENT_TYPE      (
         P_EVENT_NO );
         RETURN ret_value;
   END EVENT_TYPE;
   FUNCTION GAS_LIFT_LOSS_MASS(
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_DEFERMENT_EVENT.GAS_LIFT_LOSS_MASS      (
         P_EVENT_NO );
         RETURN ret_value;
   END GAS_LIFT_LOSS_MASS;
   FUNCTION GAS_LIFT_LOSS_MASS_RATE(
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_DEFERMENT_EVENT.GAS_LIFT_LOSS_MASS_RATE      (
         P_EVENT_NO );
         RETURN ret_value;
   END GAS_LIFT_LOSS_MASS_RATE;
   FUNCTION MASTER_EVENT_ID(
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_DEFERMENT_EVENT.MASTER_EVENT_ID      (
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
      ret_value := EC_DEFERMENT_EVENT.NEXT_DAYTIME      (
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
      ret_value := EC_DEFERMENT_EVENT.OBJECT_ID      (
         P_EVENT_NO );
         RETURN ret_value;
   END OBJECT_ID;
   FUNCTION PARENT_MASTER_EVENT_ID(
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_DEFERMENT_EVENT.PARENT_MASTER_EVENT_ID      (
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
      ret_value := EC_DEFERMENT_EVENT.PREV_EQUAL_DAYTIME      (
         P_EVENT_NO,
         P_NUM_ROWS );
         RETURN ret_value;
   END PREV_EQUAL_DAYTIME;
   FUNCTION REASON_CODE_5(
      P_EVENT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_DEFERMENT_EVENT.REASON_CODE_5      (
         P_EVENT_NO );
         RETURN ret_value;
   END REASON_CODE_5;
   FUNCTION REASON_CODE_TYPE_10(
      P_EVENT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_DEFERMENT_EVENT.REASON_CODE_TYPE_10      (
         P_EVENT_NO );
         RETURN ret_value;
   END REASON_CODE_TYPE_10;
   FUNCTION REASON_CODE_TYPE_2(
      P_EVENT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_DEFERMENT_EVENT.REASON_CODE_TYPE_2      (
         P_EVENT_NO );
         RETURN ret_value;
   END REASON_CODE_TYPE_2;
   FUNCTION REASON_CODE_TYPE_4(
      P_EVENT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_DEFERMENT_EVENT.REASON_CODE_TYPE_4      (
         P_EVENT_NO );
         RETURN ret_value;
   END REASON_CODE_TYPE_4;
   FUNCTION REASON_CODE_TYPE_7(
      P_EVENT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_DEFERMENT_EVENT.REASON_CODE_TYPE_7      (
         P_EVENT_NO );
         RETURN ret_value;
   END REASON_CODE_TYPE_7;
   FUNCTION CLASS_NAME(
      P_EVENT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (24) ;
   BEGIN
      ret_value := EC_DEFERMENT_EVENT.CLASS_NAME      (
         P_EVENT_NO );
         RETURN ret_value;
   END CLASS_NAME;
   FUNCTION COMMENTS(
      P_EVENT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_DEFERMENT_EVENT.COMMENTS      (
         P_EVENT_NO );
         RETURN ret_value;
   END COMMENTS;
   FUNCTION DATE_3(
      P_EVENT_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_DEFERMENT_EVENT.DATE_3      (
         P_EVENT_NO );
         RETURN ret_value;
   END DATE_3;
   FUNCTION DATE_5(
      P_EVENT_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_DEFERMENT_EVENT.DATE_5      (
         P_EVENT_NO );
         RETURN ret_value;
   END DATE_5;
   FUNCTION DEFERMENT_TYPE(
      P_EVENT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_DEFERMENT_EVENT.DEFERMENT_TYPE      (
         P_EVENT_NO );
         RETURN ret_value;
   END DEFERMENT_TYPE;
   FUNCTION EQUIPMENT_ID(
      P_EVENT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_DEFERMENT_EVENT.EQUIPMENT_ID      (
         P_EVENT_NO );
         RETURN ret_value;
   END EQUIPMENT_ID;
   FUNCTION GAS_INJ_LOSS_RATE(
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_DEFERMENT_EVENT.GAS_INJ_LOSS_RATE      (
         P_EVENT_NO );
         RETURN ret_value;
   END GAS_INJ_LOSS_RATE;
   FUNCTION GAS_LIFT_LOSS_RATE(
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_DEFERMENT_EVENT.GAS_LIFT_LOSS_RATE      (
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
      ret_value := EC_DEFERMENT_EVENT.NEXT_EQUAL_DAYTIME      (
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
      ret_value := EC_DEFERMENT_EVENT.OIL_LOSS_RATE      (
         P_EVENT_NO );
         RETURN ret_value;
   END OIL_LOSS_RATE;
   FUNCTION REASON_CODE_8(
      P_EVENT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_DEFERMENT_EVENT.REASON_CODE_8      (
         P_EVENT_NO );
         RETURN ret_value;
   END REASON_CODE_8;
   FUNCTION TEXT_6(
      P_EVENT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (64) ;
   BEGIN
      ret_value := EC_DEFERMENT_EVENT.TEXT_6      (
         P_EVENT_NO );
         RETURN ret_value;
   END TEXT_6;
   FUNCTION TEXT_9(
      P_EVENT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (64) ;
   BEGIN
      ret_value := EC_DEFERMENT_EVENT.TEXT_9      (
         P_EVENT_NO );
         RETURN ret_value;
   END TEXT_9;
   FUNCTION UTC_DAYTIME(
      P_EVENT_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_DEFERMENT_EVENT.UTC_DAYTIME      (
         P_EVENT_NO );
         RETURN ret_value;
   END UTC_DAYTIME;
   FUNCTION VALUE_6(
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_DEFERMENT_EVENT.VALUE_6      (
         P_EVENT_NO );
         RETURN ret_value;
   END VALUE_6;
   FUNCTION WATER_INJ_LOSS_MASS(
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_DEFERMENT_EVENT.WATER_INJ_LOSS_MASS      (
         P_EVENT_NO );
         RETURN ret_value;
   END WATER_INJ_LOSS_MASS;
   FUNCTION DATE_2(
      P_EVENT_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_DEFERMENT_EVENT.DATE_2      (
         P_EVENT_NO );
         RETURN ret_value;
   END DATE_2;
   FUNCTION END_DATE(
      P_EVENT_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_DEFERMENT_EVENT.END_DATE      (
         P_EVENT_NO );
         RETURN ret_value;
   END END_DATE;
   FUNCTION GAS_INJ_LOSS_MASS(
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_DEFERMENT_EVENT.GAS_INJ_LOSS_MASS      (
         P_EVENT_NO );
         RETURN ret_value;
   END GAS_INJ_LOSS_MASS;
   FUNCTION GAS_INJ_LOSS_MASS_RATE(
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_DEFERMENT_EVENT.GAS_INJ_LOSS_MASS_RATE      (
         P_EVENT_NO );
         RETURN ret_value;
   END GAS_INJ_LOSS_MASS_RATE;
   FUNCTION PREV_DAYTIME(
      P_EVENT_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_DEFERMENT_EVENT.PREV_DAYTIME      (
         P_EVENT_NO,
         P_NUM_ROWS );
         RETURN ret_value;
   END PREV_DAYTIME;
   FUNCTION REASON_CODE_4(
      P_EVENT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_DEFERMENT_EVENT.REASON_CODE_4      (
         P_EVENT_NO );
         RETURN ret_value;
   END REASON_CODE_4;
   FUNCTION REASON_CODE_9(
      P_EVENT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_DEFERMENT_EVENT.REASON_CODE_9      (
         P_EVENT_NO );
         RETURN ret_value;
   END REASON_CODE_9;
   FUNCTION RECORD_STATUS(
      P_EVENT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_DEFERMENT_EVENT.RECORD_STATUS      (
         P_EVENT_NO );
         RETURN ret_value;
   END RECORD_STATUS;
   FUNCTION TEXT_10(
      P_EVENT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (64) ;
   BEGIN
      ret_value := EC_DEFERMENT_EVENT.TEXT_10      (
         P_EVENT_NO );
         RETURN ret_value;
   END TEXT_10;
   FUNCTION TEXT_7(
      P_EVENT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (64) ;
   BEGIN
      ret_value := EC_DEFERMENT_EVENT.TEXT_7      (
         P_EVENT_NO );
         RETURN ret_value;
   END TEXT_7;
   FUNCTION VALUE_1(
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_DEFERMENT_EVENT.VALUE_1      (
         P_EVENT_NO );
         RETURN ret_value;
   END VALUE_1;
   FUNCTION WATER_INJ_LOSS_VOLUME(
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_DEFERMENT_EVENT.WATER_INJ_LOSS_VOLUME      (
         P_EVENT_NO );
         RETURN ret_value;
   END WATER_INJ_LOSS_VOLUME;
   FUNCTION APPROVAL_DATE(
      P_EVENT_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_DEFERMENT_EVENT.APPROVAL_DATE      (
         P_EVENT_NO );
         RETURN ret_value;
   END APPROVAL_DATE;
   FUNCTION COND_LOSS_MASS(
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_DEFERMENT_EVENT.COND_LOSS_MASS      (
         P_EVENT_NO );
         RETURN ret_value;
   END COND_LOSS_MASS;
   FUNCTION COND_LOSS_VOLUME(
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_DEFERMENT_EVENT.COND_LOSS_VOLUME      (
         P_EVENT_NO );
         RETURN ret_value;
   END COND_LOSS_VOLUME;
   FUNCTION GAS_LIFT_LOSS_VOLUME(
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_DEFERMENT_EVENT.GAS_LIFT_LOSS_VOLUME      (
         P_EVENT_NO );
         RETURN ret_value;
   END GAS_LIFT_LOSS_VOLUME;
   FUNCTION GAS_LOSS_VOLUME(
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_DEFERMENT_EVENT.GAS_LOSS_VOLUME      (
         P_EVENT_NO );
         RETURN ret_value;
   END GAS_LOSS_VOLUME;
   FUNCTION OBJECT_TYPE(
      P_EVENT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_DEFERMENT_EVENT.OBJECT_TYPE      (
         P_EVENT_NO );
         RETURN ret_value;
   END OBJECT_TYPE;
   FUNCTION OIL_LOSS_MASS(
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_DEFERMENT_EVENT.OIL_LOSS_MASS      (
         P_EVENT_NO );
         RETURN ret_value;
   END OIL_LOSS_MASS;
   FUNCTION REASON_CODE_10(
      P_EVENT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_DEFERMENT_EVENT.REASON_CODE_10      (
         P_EVENT_NO );
         RETURN ret_value;
   END REASON_CODE_10;
   FUNCTION REASON_CODE_TYPE_9(
      P_EVENT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_DEFERMENT_EVENT.REASON_CODE_TYPE_9      (
         P_EVENT_NO );
         RETURN ret_value;
   END REASON_CODE_TYPE_9;
   FUNCTION ROW_BY_PK(
      P_EVENT_NO IN NUMBER)
      RETURN REC_ROW_BY_PK
   IS
      ret_value    REC_ROW_BY_PK ;
   BEGIN
      ret_value := EC_DEFERMENT_EVENT.ROW_BY_PK      (
         P_EVENT_NO );
         RETURN ret_value;
   END ROW_BY_PK;
   FUNCTION STEAM_INJ_LOSS_MASS(
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_DEFERMENT_EVENT.STEAM_INJ_LOSS_MASS      (
         P_EVENT_NO );
         RETURN ret_value;
   END STEAM_INJ_LOSS_MASS;
   FUNCTION STEAM_INJ_LOSS_VOLUME(
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_DEFERMENT_EVENT.STEAM_INJ_LOSS_VOLUME      (
         P_EVENT_NO );
         RETURN ret_value;
   END STEAM_INJ_LOSS_VOLUME;
   FUNCTION VALUE_2(
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_DEFERMENT_EVENT.VALUE_2      (
         P_EVENT_NO );
         RETURN ret_value;
   END VALUE_2;
   FUNCTION VALUE_3(
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_DEFERMENT_EVENT.VALUE_3      (
         P_EVENT_NO );
         RETURN ret_value;
   END VALUE_3;
   FUNCTION VALUE_4(
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_DEFERMENT_EVENT.VALUE_4      (
         P_EVENT_NO );
         RETURN ret_value;
   END VALUE_4;
   FUNCTION WATER_LOSS_MASS(
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_DEFERMENT_EVENT.WATER_LOSS_MASS      (
         P_EVENT_NO );
         RETURN ret_value;
   END WATER_LOSS_MASS;
   FUNCTION DATE_4(
      P_EVENT_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_DEFERMENT_EVENT.DATE_4      (
         P_EVENT_NO );
         RETURN ret_value;
   END DATE_4;
   FUNCTION DAY(
      P_EVENT_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_DEFERMENT_EVENT.DAY      (
         P_EVENT_NO );
         RETURN ret_value;
   END DAY;
   FUNCTION DILUENT_LOSS_VOLUME(
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_DEFERMENT_EVENT.DILUENT_LOSS_VOLUME      (
         P_EVENT_NO );
         RETURN ret_value;
   END DILUENT_LOSS_VOLUME;
   FUNCTION EVENT_TAG(
      P_EVENT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (100) ;
   BEGIN
      ret_value := EC_DEFERMENT_EVENT.EVENT_TAG      (
         P_EVENT_NO );
         RETURN ret_value;
   END EVENT_TAG;
   FUNCTION GAS_INJ_LOSS_VOLUME(
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_DEFERMENT_EVENT.GAS_INJ_LOSS_VOLUME      (
         P_EVENT_NO );
         RETURN ret_value;
   END GAS_INJ_LOSS_VOLUME;
   FUNCTION OIL_LOSS_MASS_RATE(
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_DEFERMENT_EVENT.OIL_LOSS_MASS_RATE      (
         P_EVENT_NO );
         RETURN ret_value;
   END OIL_LOSS_MASS_RATE;
   FUNCTION PARENT_EVENT_NO(
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_DEFERMENT_EVENT.PARENT_EVENT_NO      (
         P_EVENT_NO );
         RETURN ret_value;
   END PARENT_EVENT_NO;
   FUNCTION REASON_CODE_2(
      P_EVENT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_DEFERMENT_EVENT.REASON_CODE_2      (
         P_EVENT_NO );
         RETURN ret_value;
   END REASON_CODE_2;
   FUNCTION REASON_CODE_TYPE_3(
      P_EVENT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_DEFERMENT_EVENT.REASON_CODE_TYPE_3      (
         P_EVENT_NO );
         RETURN ret_value;
   END REASON_CODE_TYPE_3;
   FUNCTION REASON_CODE_TYPE_6(
      P_EVENT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_DEFERMENT_EVENT.REASON_CODE_TYPE_6      (
         P_EVENT_NO );
         RETURN ret_value;
   END REASON_CODE_TYPE_6;
   FUNCTION REC_ID(
      P_EVENT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_DEFERMENT_EVENT.REC_ID      (
         P_EVENT_NO );
         RETURN ret_value;
   END REC_ID;
   FUNCTION TEXT_1(
      P_EVENT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (16) ;
   BEGIN
      ret_value := EC_DEFERMENT_EVENT.TEXT_1      (
         P_EVENT_NO );
         RETURN ret_value;
   END TEXT_1;
   FUNCTION TEXT_2(
      P_EVENT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_DEFERMENT_EVENT.TEXT_2      (
         P_EVENT_NO );
         RETURN ret_value;
   END TEXT_2;
   FUNCTION TEXT_8(
      P_EVENT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (64) ;
   BEGIN
      ret_value := EC_DEFERMENT_EVENT.TEXT_8      (
         P_EVENT_NO );
         RETURN ret_value;
   END TEXT_8;
   FUNCTION VALUE_7(
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_DEFERMENT_EVENT.VALUE_7      (
         P_EVENT_NO );
         RETURN ret_value;
   END VALUE_7;
   FUNCTION VALUE_9(
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_DEFERMENT_EVENT.VALUE_9      (
         P_EVENT_NO );
         RETURN ret_value;
   END VALUE_9;
   FUNCTION WATER_INJ_LOSS_MASS_RATE(
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_DEFERMENT_EVENT.WATER_INJ_LOSS_MASS_RATE      (
         P_EVENT_NO );
         RETURN ret_value;
   END WATER_INJ_LOSS_MASS_RATE;
   FUNCTION COND_LOSS_RATE(
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_DEFERMENT_EVENT.COND_LOSS_RATE      (
         P_EVENT_NO );
         RETURN ret_value;
   END COND_LOSS_RATE;
   FUNCTION DATE_1(
      P_EVENT_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_DEFERMENT_EVENT.DATE_1      (
         P_EVENT_NO );
         RETURN ret_value;
   END DATE_1;
   FUNCTION DAYTIME(
      P_EVENT_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_DEFERMENT_EVENT.DAYTIME      (
         P_EVENT_NO );
         RETURN ret_value;
   END DAYTIME;
   FUNCTION END_DAY(
      P_EVENT_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_DEFERMENT_EVENT.END_DAY      (
         P_EVENT_NO );
         RETURN ret_value;
   END END_DAY;
   FUNCTION GAS_LOSS_MASS(
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_DEFERMENT_EVENT.GAS_LOSS_MASS      (
         P_EVENT_NO );
         RETURN ret_value;
   END GAS_LOSS_MASS;
   FUNCTION PARENT_DAYTIME(
      P_EVENT_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_DEFERMENT_EVENT.PARENT_DAYTIME      (
         P_EVENT_NO );
         RETURN ret_value;
   END PARENT_DAYTIME;
   FUNCTION REASON_CODE_1(
      P_EVENT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_DEFERMENT_EVENT.REASON_CODE_1      (
         P_EVENT_NO );
         RETURN ret_value;
   END REASON_CODE_1;
   FUNCTION REASON_CODE_6(
      P_EVENT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_DEFERMENT_EVENT.REASON_CODE_6      (
         P_EVENT_NO );
         RETURN ret_value;
   END REASON_CODE_6;
   FUNCTION STEAM_INJ_LOSS_MASS_RATE(
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_DEFERMENT_EVENT.STEAM_INJ_LOSS_MASS_RATE      (
         P_EVENT_NO );
         RETURN ret_value;
   END STEAM_INJ_LOSS_MASS_RATE;
   FUNCTION VALUE_10(
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_DEFERMENT_EVENT.VALUE_10      (
         P_EVENT_NO );
         RETURN ret_value;
   END VALUE_10;
   FUNCTION VALUE_8(
      P_EVENT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_DEFERMENT_EVENT.VALUE_8      (
         P_EVENT_NO );
         RETURN ret_value;
   END VALUE_8;

END RP_DEFERMENT_EVENT;

/
--GRANT EXECUTE ON ECKERNEL_WST.RP_DEFERMENT_EVENT TO REPORT_ROLE_XXX;



 -- FINISH PKG_GEN_PKGS.sf_get_functions at:05/07/2019 10.26.59 AM


