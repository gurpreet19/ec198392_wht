
 -- START PKG_GEN_PKGS.sf_get_functions at:11/15/2018 08.49.12 AM


CREATE or REPLACE PACKAGE RP_NOMPNT_SUB_DAY_DELIVERY
IS

   FUNCTION FUEL_QTY(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN NUMBER;
   FUNCTION SCHEDULED_QTY(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN NUMBER;
   FUNCTION TEXT_3(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TIME_ZONE(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_16(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_18(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN NUMBER;
   FUNCTION APPROVAL_BY(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_STATE(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION CALC_VOL_QTY(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN NUMBER;
   FUNCTION LAUF_QTY(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN NUMBER;
   FUNCTION SHIPPER_CODE(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION SUMMER_TIME(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TRANSACTION_TYPE(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_5(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN NUMBER;
   FUNCTION CALC_QTY(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN NUMBER;
   FUNCTION NEXT_DAYTIME(
      P_NOMINATION_SEQ IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION OBJECT_ID(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION PREV_EQUAL_DAYTIME(
      P_NOMINATION_SEQ IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION TEXT_7(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_8(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION CALC_ENERGY_QTY(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN NUMBER;
   FUNCTION CALC_MASS_QTY(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN NUMBER;
   FUNCTION DATE_3(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN DATE;
   FUNCTION DATE_5(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN DATE;
   FUNCTION NEXT_EQUAL_DAYTIME(
      P_NOMINATION_SEQ IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION NOMINATION_TYPE(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_1(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_6(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_9(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION UTC_DAYTIME(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN DATE;
   FUNCTION VALUE_12(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_6(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN NUMBER;
   FUNCTION DATE_2(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN DATE;
   FUNCTION FLARE_QTY(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN NUMBER;
   FUNCTION PREV_DAYTIME(
      P_NOMINATION_SEQ IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION RECORD_STATUS(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_1(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_15(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_19(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN NUMBER;
   FUNCTION VENTING_QTY(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN NUMBER;
   FUNCTION APPROVAL_DATE(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN DATE;
   FUNCTION DAY_NOM_SEQ(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN NUMBER;
      TYPE REC_ROW_BY_PK IS RECORD (
         NOMINATION_SEQ NUMBER ,
         OBJECT_ID VARCHAR2 (32) ,
         DAYTIME  DATE ,
         SUMMER_TIME VARCHAR2 (1) ,
         PRODUCTION_DAY  DATE ,
         NOMINATION_TYPE VARCHAR2 (32) ,
         NOM_CYCLE_CODE VARCHAR2 (32) ,
         SHIPPER_CODE VARCHAR2 (240) ,
         TRANSACTION_TYPE VARCHAR2 (32) ,
         DAY_NOM_SEQ NUMBER ,
         CALC_VOL_QTY NUMBER ,
         CALC_MASS_QTY NUMBER ,
         CALC_ENERGY_QTY NUMBER ,
         ADJ_QTY NUMBER ,
         CALC_QTY NUMBER ,
         FLARE_QTY NUMBER ,
         FUEL_QTY NUMBER ,
         LAUF_QTY NUMBER ,
         SCHEDULED_QTY NUMBER ,
         VENTING_QTY NUMBER ,
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
         APPROVAL_STATE VARCHAR2 (1) ,
         APPROVAL_BY VARCHAR2 (30) ,
         APPROVAL_DATE  DATE ,
         REC_ID VARCHAR2 (32) ,
         TIME_ZONE VARCHAR2 (65) ,
         UTC_DAYTIME  DATE  );
   FUNCTION ROW_BY_PK(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN REC_ROW_BY_PK;
   FUNCTION TEXT_2(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_4(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_5(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_13(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_17(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_2(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_20(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_3(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_4(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN NUMBER;
   FUNCTION ADJ_QTY(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN NUMBER;
   FUNCTION DATE_4(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN DATE;
   FUNCTION REC_ID(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_7(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_9(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN NUMBER;
   FUNCTION DATE_1(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN DATE;
   FUNCTION DAYTIME(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN DATE;
   FUNCTION NOM_CYCLE_CODE(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION PRODUCTION_DAY(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN DATE;
   FUNCTION TEXT_10(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_10(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_11(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_14(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_8(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN NUMBER;

END RP_NOMPNT_SUB_DAY_DELIVERY;

/



CREATE or REPLACE PACKAGE BODY RP_NOMPNT_SUB_DAY_DELIVERY
IS

   FUNCTION FUEL_QTY(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_NOMPNT_SUB_DAY_DELIVERY.FUEL_QTY      (
         P_NOMINATION_SEQ );
         RETURN ret_value;
   END FUEL_QTY;
   FUNCTION SCHEDULED_QTY(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_NOMPNT_SUB_DAY_DELIVERY.SCHEDULED_QTY      (
         P_NOMINATION_SEQ );
         RETURN ret_value;
   END SCHEDULED_QTY;
   FUNCTION TEXT_3(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_NOMPNT_SUB_DAY_DELIVERY.TEXT_3      (
         P_NOMINATION_SEQ );
         RETURN ret_value;
   END TEXT_3;
   FUNCTION TIME_ZONE(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (65) ;
   BEGIN
      ret_value := EC_NOMPNT_SUB_DAY_DELIVERY.TIME_ZONE      (
         P_NOMINATION_SEQ );
         RETURN ret_value;
   END TIME_ZONE;
   FUNCTION VALUE_16(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_NOMPNT_SUB_DAY_DELIVERY.VALUE_16      (
         P_NOMINATION_SEQ );
         RETURN ret_value;
   END VALUE_16;
   FUNCTION VALUE_18(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_NOMPNT_SUB_DAY_DELIVERY.VALUE_18      (
         P_NOMINATION_SEQ );
         RETURN ret_value;
   END VALUE_18;
   FUNCTION APPROVAL_BY(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (30) ;
   BEGIN
      ret_value := EC_NOMPNT_SUB_DAY_DELIVERY.APPROVAL_BY      (
         P_NOMINATION_SEQ );
         RETURN ret_value;
   END APPROVAL_BY;
   FUNCTION APPROVAL_STATE(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_NOMPNT_SUB_DAY_DELIVERY.APPROVAL_STATE      (
         P_NOMINATION_SEQ );
         RETURN ret_value;
   END APPROVAL_STATE;
   FUNCTION CALC_VOL_QTY(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_NOMPNT_SUB_DAY_DELIVERY.CALC_VOL_QTY      (
         P_NOMINATION_SEQ );
         RETURN ret_value;
   END CALC_VOL_QTY;
   FUNCTION LAUF_QTY(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_NOMPNT_SUB_DAY_DELIVERY.LAUF_QTY      (
         P_NOMINATION_SEQ );
         RETURN ret_value;
   END LAUF_QTY;
   FUNCTION SHIPPER_CODE(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_NOMPNT_SUB_DAY_DELIVERY.SHIPPER_CODE      (
         P_NOMINATION_SEQ );
         RETURN ret_value;
   END SHIPPER_CODE;
   FUNCTION SUMMER_TIME(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_NOMPNT_SUB_DAY_DELIVERY.SUMMER_TIME      (
         P_NOMINATION_SEQ );
         RETURN ret_value;
   END SUMMER_TIME;
   FUNCTION TRANSACTION_TYPE(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_NOMPNT_SUB_DAY_DELIVERY.TRANSACTION_TYPE      (
         P_NOMINATION_SEQ );
         RETURN ret_value;
   END TRANSACTION_TYPE;
   FUNCTION VALUE_5(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_NOMPNT_SUB_DAY_DELIVERY.VALUE_5      (
         P_NOMINATION_SEQ );
         RETURN ret_value;
   END VALUE_5;
   FUNCTION CALC_QTY(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_NOMPNT_SUB_DAY_DELIVERY.CALC_QTY      (
         P_NOMINATION_SEQ );
         RETURN ret_value;
   END CALC_QTY;
   FUNCTION NEXT_DAYTIME(
      P_NOMINATION_SEQ IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_NOMPNT_SUB_DAY_DELIVERY.NEXT_DAYTIME      (
         P_NOMINATION_SEQ,
         P_NUM_ROWS );
         RETURN ret_value;
   END NEXT_DAYTIME;
   FUNCTION OBJECT_ID(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_NOMPNT_SUB_DAY_DELIVERY.OBJECT_ID      (
         P_NOMINATION_SEQ );
         RETURN ret_value;
   END OBJECT_ID;
   FUNCTION PREV_EQUAL_DAYTIME(
      P_NOMINATION_SEQ IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_NOMPNT_SUB_DAY_DELIVERY.PREV_EQUAL_DAYTIME      (
         P_NOMINATION_SEQ,
         P_NUM_ROWS );
         RETURN ret_value;
   END PREV_EQUAL_DAYTIME;
   FUNCTION TEXT_7(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_NOMPNT_SUB_DAY_DELIVERY.TEXT_7      (
         P_NOMINATION_SEQ );
         RETURN ret_value;
   END TEXT_7;
   FUNCTION TEXT_8(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_NOMPNT_SUB_DAY_DELIVERY.TEXT_8      (
         P_NOMINATION_SEQ );
         RETURN ret_value;
   END TEXT_8;
   FUNCTION CALC_ENERGY_QTY(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_NOMPNT_SUB_DAY_DELIVERY.CALC_ENERGY_QTY      (
         P_NOMINATION_SEQ );
         RETURN ret_value;
   END CALC_ENERGY_QTY;
   FUNCTION CALC_MASS_QTY(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_NOMPNT_SUB_DAY_DELIVERY.CALC_MASS_QTY      (
         P_NOMINATION_SEQ );
         RETURN ret_value;
   END CALC_MASS_QTY;
   FUNCTION DATE_3(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_NOMPNT_SUB_DAY_DELIVERY.DATE_3      (
         P_NOMINATION_SEQ );
         RETURN ret_value;
   END DATE_3;
   FUNCTION DATE_5(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_NOMPNT_SUB_DAY_DELIVERY.DATE_5      (
         P_NOMINATION_SEQ );
         RETURN ret_value;
   END DATE_5;
   FUNCTION NEXT_EQUAL_DAYTIME(
      P_NOMINATION_SEQ IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_NOMPNT_SUB_DAY_DELIVERY.NEXT_EQUAL_DAYTIME      (
         P_NOMINATION_SEQ,
         P_NUM_ROWS );
         RETURN ret_value;
   END NEXT_EQUAL_DAYTIME;
   FUNCTION NOMINATION_TYPE(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_NOMPNT_SUB_DAY_DELIVERY.NOMINATION_TYPE      (
         P_NOMINATION_SEQ );
         RETURN ret_value;
   END NOMINATION_TYPE;
   FUNCTION TEXT_1(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_NOMPNT_SUB_DAY_DELIVERY.TEXT_1      (
         P_NOMINATION_SEQ );
         RETURN ret_value;
   END TEXT_1;
   FUNCTION TEXT_6(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_NOMPNT_SUB_DAY_DELIVERY.TEXT_6      (
         P_NOMINATION_SEQ );
         RETURN ret_value;
   END TEXT_6;
   FUNCTION TEXT_9(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_NOMPNT_SUB_DAY_DELIVERY.TEXT_9      (
         P_NOMINATION_SEQ );
         RETURN ret_value;
   END TEXT_9;
   FUNCTION UTC_DAYTIME(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_NOMPNT_SUB_DAY_DELIVERY.UTC_DAYTIME      (
         P_NOMINATION_SEQ );
         RETURN ret_value;
   END UTC_DAYTIME;
   FUNCTION VALUE_12(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_NOMPNT_SUB_DAY_DELIVERY.VALUE_12      (
         P_NOMINATION_SEQ );
         RETURN ret_value;
   END VALUE_12;
   FUNCTION VALUE_6(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_NOMPNT_SUB_DAY_DELIVERY.VALUE_6      (
         P_NOMINATION_SEQ );
         RETURN ret_value;
   END VALUE_6;
   FUNCTION DATE_2(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_NOMPNT_SUB_DAY_DELIVERY.DATE_2      (
         P_NOMINATION_SEQ );
         RETURN ret_value;
   END DATE_2;
   FUNCTION FLARE_QTY(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_NOMPNT_SUB_DAY_DELIVERY.FLARE_QTY      (
         P_NOMINATION_SEQ );
         RETURN ret_value;
   END FLARE_QTY;
   FUNCTION PREV_DAYTIME(
      P_NOMINATION_SEQ IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_NOMPNT_SUB_DAY_DELIVERY.PREV_DAYTIME      (
         P_NOMINATION_SEQ,
         P_NUM_ROWS );
         RETURN ret_value;
   END PREV_DAYTIME;
   FUNCTION RECORD_STATUS(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_NOMPNT_SUB_DAY_DELIVERY.RECORD_STATUS      (
         P_NOMINATION_SEQ );
         RETURN ret_value;
   END RECORD_STATUS;
   FUNCTION VALUE_1(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_NOMPNT_SUB_DAY_DELIVERY.VALUE_1      (
         P_NOMINATION_SEQ );
         RETURN ret_value;
   END VALUE_1;
   FUNCTION VALUE_15(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_NOMPNT_SUB_DAY_DELIVERY.VALUE_15      (
         P_NOMINATION_SEQ );
         RETURN ret_value;
   END VALUE_15;
   FUNCTION VALUE_19(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_NOMPNT_SUB_DAY_DELIVERY.VALUE_19      (
         P_NOMINATION_SEQ );
         RETURN ret_value;
   END VALUE_19;
   FUNCTION VENTING_QTY(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_NOMPNT_SUB_DAY_DELIVERY.VENTING_QTY      (
         P_NOMINATION_SEQ );
         RETURN ret_value;
   END VENTING_QTY;
   FUNCTION APPROVAL_DATE(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_NOMPNT_SUB_DAY_DELIVERY.APPROVAL_DATE      (
         P_NOMINATION_SEQ );
         RETURN ret_value;
   END APPROVAL_DATE;
   FUNCTION DAY_NOM_SEQ(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_NOMPNT_SUB_DAY_DELIVERY.DAY_NOM_SEQ      (
         P_NOMINATION_SEQ );
         RETURN ret_value;
   END DAY_NOM_SEQ;
   FUNCTION ROW_BY_PK(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN REC_ROW_BY_PK
   IS
      ret_value    REC_ROW_BY_PK ;
   BEGIN
      ret_value := EC_NOMPNT_SUB_DAY_DELIVERY.ROW_BY_PK      (
         P_NOMINATION_SEQ );
         RETURN ret_value;
   END ROW_BY_PK;
   FUNCTION TEXT_2(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_NOMPNT_SUB_DAY_DELIVERY.TEXT_2      (
         P_NOMINATION_SEQ );
         RETURN ret_value;
   END TEXT_2;
   FUNCTION TEXT_4(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_NOMPNT_SUB_DAY_DELIVERY.TEXT_4      (
         P_NOMINATION_SEQ );
         RETURN ret_value;
   END TEXT_4;
   FUNCTION TEXT_5(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_NOMPNT_SUB_DAY_DELIVERY.TEXT_5      (
         P_NOMINATION_SEQ );
         RETURN ret_value;
   END TEXT_5;
   FUNCTION VALUE_13(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_NOMPNT_SUB_DAY_DELIVERY.VALUE_13      (
         P_NOMINATION_SEQ );
         RETURN ret_value;
   END VALUE_13;
   FUNCTION VALUE_17(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_NOMPNT_SUB_DAY_DELIVERY.VALUE_17      (
         P_NOMINATION_SEQ );
         RETURN ret_value;
   END VALUE_17;
   FUNCTION VALUE_2(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_NOMPNT_SUB_DAY_DELIVERY.VALUE_2      (
         P_NOMINATION_SEQ );
         RETURN ret_value;
   END VALUE_2;
   FUNCTION VALUE_20(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_NOMPNT_SUB_DAY_DELIVERY.VALUE_20      (
         P_NOMINATION_SEQ );
         RETURN ret_value;
   END VALUE_20;
   FUNCTION VALUE_3(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_NOMPNT_SUB_DAY_DELIVERY.VALUE_3      (
         P_NOMINATION_SEQ );
         RETURN ret_value;
   END VALUE_3;
   FUNCTION VALUE_4(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_NOMPNT_SUB_DAY_DELIVERY.VALUE_4      (
         P_NOMINATION_SEQ );
         RETURN ret_value;
   END VALUE_4;
   FUNCTION ADJ_QTY(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_NOMPNT_SUB_DAY_DELIVERY.ADJ_QTY      (
         P_NOMINATION_SEQ );
         RETURN ret_value;
   END ADJ_QTY;
   FUNCTION DATE_4(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_NOMPNT_SUB_DAY_DELIVERY.DATE_4      (
         P_NOMINATION_SEQ );
         RETURN ret_value;
   END DATE_4;
   FUNCTION REC_ID(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_NOMPNT_SUB_DAY_DELIVERY.REC_ID      (
         P_NOMINATION_SEQ );
         RETURN ret_value;
   END REC_ID;
   FUNCTION VALUE_7(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_NOMPNT_SUB_DAY_DELIVERY.VALUE_7      (
         P_NOMINATION_SEQ );
         RETURN ret_value;
   END VALUE_7;
   FUNCTION VALUE_9(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_NOMPNT_SUB_DAY_DELIVERY.VALUE_9      (
         P_NOMINATION_SEQ );
         RETURN ret_value;
   END VALUE_9;
   FUNCTION DATE_1(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_NOMPNT_SUB_DAY_DELIVERY.DATE_1      (
         P_NOMINATION_SEQ );
         RETURN ret_value;
   END DATE_1;
   FUNCTION DAYTIME(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_NOMPNT_SUB_DAY_DELIVERY.DAYTIME      (
         P_NOMINATION_SEQ );
         RETURN ret_value;
   END DAYTIME;
   FUNCTION NOM_CYCLE_CODE(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_NOMPNT_SUB_DAY_DELIVERY.NOM_CYCLE_CODE      (
         P_NOMINATION_SEQ );
         RETURN ret_value;
   END NOM_CYCLE_CODE;
   FUNCTION PRODUCTION_DAY(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_NOMPNT_SUB_DAY_DELIVERY.PRODUCTION_DAY      (
         P_NOMINATION_SEQ );
         RETURN ret_value;
   END PRODUCTION_DAY;
   FUNCTION TEXT_10(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_NOMPNT_SUB_DAY_DELIVERY.TEXT_10      (
         P_NOMINATION_SEQ );
         RETURN ret_value;
   END TEXT_10;
   FUNCTION VALUE_10(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_NOMPNT_SUB_DAY_DELIVERY.VALUE_10      (
         P_NOMINATION_SEQ );
         RETURN ret_value;
   END VALUE_10;
   FUNCTION VALUE_11(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_NOMPNT_SUB_DAY_DELIVERY.VALUE_11      (
         P_NOMINATION_SEQ );
         RETURN ret_value;
   END VALUE_11;
   FUNCTION VALUE_14(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_NOMPNT_SUB_DAY_DELIVERY.VALUE_14      (
         P_NOMINATION_SEQ );
         RETURN ret_value;
   END VALUE_14;
   FUNCTION VALUE_8(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_NOMPNT_SUB_DAY_DELIVERY.VALUE_8      (
         P_NOMINATION_SEQ );
         RETURN ret_value;
   END VALUE_8;

END RP_NOMPNT_SUB_DAY_DELIVERY;

/
--GRANT EXECUTE ON ECKERNEL_WST.RP_NOMPNT_SUB_DAY_DELIVERY TO REPORT_ROLE_XXX;



 -- FINISH PKG_GEN_PKGS.sf_get_functions at:11/15/2018 08.49.25 AM

