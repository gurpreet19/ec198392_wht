
 -- START PKG_GEN_PKGS.sf_get_functions at:11/15/2018 08.47.39 AM


CREATE or REPLACE PACKAGE RP_OBJECTS_DEFERMENT_EVENT
IS

   FUNCTION COND_PROD_LOSS(
      P_EVENT_ID IN NUMBER)
      RETURN NUMBER;
   FUNCTION EXPECTED_VOLUME(
      P_EVENT_ID IN NUMBER)
      RETURN NUMBER;
   FUNCTION GAS_PROD_LOSS_MASS(
      P_EVENT_ID IN NUMBER)
      RETURN NUMBER;
   FUNCTION TEXT_3(
      P_EVENT_ID IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_4(
      P_EVENT_ID IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION WATER_PROD_LOSS(
      P_EVENT_ID IN NUMBER)
      RETURN NUMBER;
   FUNCTION APPROVAL_BY(
      P_EVENT_ID IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_STATE(
      P_EVENT_ID IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION DILUENT_LOSS(
      P_EVENT_ID IN NUMBER)
      RETURN NUMBER;
   FUNCTION DURATION_SECS(
      P_EVENT_ID IN NUMBER)
      RETURN NUMBER;
   FUNCTION GRP_DILUENT_LOSS(
      P_EVENT_ID IN NUMBER)
      RETURN NUMBER;
   FUNCTION OIL_PROD_LOSS_MASS(
      P_EVENT_ID IN NUMBER)
      RETURN NUMBER;
   FUNCTION STATUS(
      P_EVENT_ID IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_5(
      P_EVENT_ID IN NUMBER)
      RETURN NUMBER;
   FUNCTION WATER_PROD_LOSS_MASS(
      P_EVENT_ID IN NUMBER)
      RETURN NUMBER;
   FUNCTION ACTIVITY_OWNER(
      P_EVENT_ID IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION NEXT_DAYTIME(
      P_EVENT_ID IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION OBJECT_ID(
      P_EVENT_ID IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION PREV_EQUAL_DAYTIME(
      P_EVENT_ID IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION COMMENTS(
      P_EVENT_ID IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION GAS_LIFT_LOSS(
      P_EVENT_ID IN NUMBER)
      RETURN NUMBER;
   FUNCTION GRP_GAS_INJ_LOSS(
      P_EVENT_ID IN NUMBER)
      RETURN NUMBER;
   FUNCTION GRP_GAS_LIFT_LOSS(
      P_EVENT_ID IN NUMBER)
      RETURN NUMBER;
   FUNCTION NEXT_EQUAL_DAYTIME(
      P_EVENT_ID IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION OIL_PROD_LOSS(
      P_EVENT_ID IN NUMBER)
      RETURN NUMBER;
   FUNCTION SEVERITY(
      P_EVENT_ID IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_6(
      P_EVENT_ID IN NUMBER)
      RETURN NUMBER;
   FUNCTION WORK_ORDER_ID(
      P_EVENT_ID IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION END_DATE(
      P_EVENT_ID IN NUMBER)
      RETURN DATE;
   FUNCTION EVENT_REASON(
      P_EVENT_ID IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION EVENT_SYSTEM(
      P_EVENT_ID IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION GAS_PROD_LOSS(
      P_EVENT_ID IN NUMBER)
      RETURN NUMBER;
   FUNCTION GRP_GAS_PROD_LOSS(
      P_EVENT_ID IN NUMBER)
      RETURN NUMBER;
   FUNCTION PREV_DAYTIME(
      P_EVENT_ID IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION RECORD_STATUS(
      P_EVENT_ID IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_1(
      P_EVENT_ID IN NUMBER)
      RETURN NUMBER;
   FUNCTION APPROVAL_DATE(
      P_EVENT_ID IN NUMBER)
      RETURN DATE;
   FUNCTION CHILD_AGGREGATE_IND(
      P_EVENT_ID IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION EVENT_CATEGORY(
      P_EVENT_ID IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION EXPECTED_RATE(
      P_EVENT_ID IN NUMBER)
      RETURN NUMBER;
   FUNCTION GRP_WATER_INJ_LOSS(
      P_EVENT_ID IN NUMBER)
      RETURN NUMBER;
   FUNCTION GRP_WATER_PROD_LOSS(
      P_EVENT_ID IN NUMBER)
      RETURN NUMBER;
   FUNCTION LINKED_EVENT_ID(
      P_EVENT_ID IN NUMBER)
      RETURN NUMBER;
   FUNCTION OBJECT_TYPE(
      P_EVENT_ID IN NUMBER)
      RETURN VARCHAR2;
      TYPE REC_ROW_BY_PK IS RECORD (
         EVENT_ID NUMBER ,
         EVENT_TYPE VARCHAR2 (16) ,
         OBJECT_ID VARCHAR2 (32) ,
         OBJECT_TYPE VARCHAR2 (24) ,
         PRODUCTION_DAY  DATE ,
         DAYTIME  DATE ,
         END_DATE  DATE ,
         PARENT_EVENT_ID NUMBER ,
         DURATION_SECS NUMBER ,
         EVENT_CATEGORY VARCHAR2 (16) ,
         EVENT_REASON VARCHAR2 (16) ,
         WORK_ORDER_ID VARCHAR2 (16) ,
         EVENT_SYSTEM VARCHAR2 (32) ,
         SCHEDULED VARCHAR2 (32) ,
         OIL_PROD_LOSS NUMBER ,
         GAS_PROD_LOSS NUMBER ,
         COND_PROD_LOSS NUMBER ,
         WATER_PROD_LOSS NUMBER ,
         GAS_INJ_LOSS NUMBER ,
         WATER_INJ_LOSS NUMBER ,
         GAS_LIFT_LOSS NUMBER ,
         DILUENT_LOSS NUMBER ,
         SEVERITY VARCHAR2 (16) ,
         CHILD_AGGREGATE_IND VARCHAR2 (1) ,
         ROOT_CAUSE VARCHAR2 (32) ,
         ACTIVITY_OWNER VARCHAR2 (32) ,
         EXPECTED_RATE NUMBER ,
         EXPECTED_VOLUME NUMBER ,
         EXPECTED_DATE  DATE ,
         GRP_OIL_PROD_LOSS NUMBER ,
         GRP_GAS_PROD_LOSS NUMBER ,
         GRP_COND_PROD_LOSS NUMBER ,
         GRP_WATER_PROD_LOSS NUMBER ,
         GRP_GAS_INJ_LOSS NUMBER ,
         GRP_WATER_INJ_LOSS NUMBER ,
         GRP_GAS_LIFT_LOSS NUMBER ,
         GRP_DILUENT_LOSS NUMBER ,
         COND_PROD_LOSS_MASS NUMBER ,
         GAS_PROD_LOSS_MASS NUMBER ,
         OIL_PROD_LOSS_MASS NUMBER ,
         WATER_PROD_LOSS_MASS NUMBER ,
         LINKED_EVENT_ID NUMBER ,
         STATUS VARCHAR2 (32) ,
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
      P_EVENT_ID IN NUMBER)
      RETURN REC_ROW_BY_PK;
   FUNCTION VALUE_2(
      P_EVENT_ID IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_3(
      P_EVENT_ID IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_4(
      P_EVENT_ID IN NUMBER)
      RETURN NUMBER;
   FUNCTION WATER_INJ_LOSS(
      P_EVENT_ID IN NUMBER)
      RETURN NUMBER;
   FUNCTION REC_ID(
      P_EVENT_ID IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION SCHEDULED(
      P_EVENT_ID IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_1(
      P_EVENT_ID IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_2(
      P_EVENT_ID IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_7(
      P_EVENT_ID IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_9(
      P_EVENT_ID IN NUMBER)
      RETURN NUMBER;
   FUNCTION COND_PROD_LOSS_MASS(
      P_EVENT_ID IN NUMBER)
      RETURN NUMBER;
   FUNCTION DAYTIME(
      P_EVENT_ID IN NUMBER)
      RETURN DATE;
   FUNCTION EVENT_TYPE(
      P_EVENT_ID IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION EXPECTED_DATE(
      P_EVENT_ID IN NUMBER)
      RETURN DATE;
   FUNCTION GAS_INJ_LOSS(
      P_EVENT_ID IN NUMBER)
      RETURN NUMBER;
   FUNCTION GRP_COND_PROD_LOSS(
      P_EVENT_ID IN NUMBER)
      RETURN NUMBER;
   FUNCTION GRP_OIL_PROD_LOSS(
      P_EVENT_ID IN NUMBER)
      RETURN NUMBER;
   FUNCTION PARENT_EVENT_ID(
      P_EVENT_ID IN NUMBER)
      RETURN NUMBER;
   FUNCTION PRODUCTION_DAY(
      P_EVENT_ID IN NUMBER)
      RETURN DATE;
   FUNCTION ROOT_CAUSE(
      P_EVENT_ID IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_10(
      P_EVENT_ID IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_8(
      P_EVENT_ID IN NUMBER)
      RETURN NUMBER;

END RP_OBJECTS_DEFERMENT_EVENT;

/



CREATE or REPLACE PACKAGE BODY RP_OBJECTS_DEFERMENT_EVENT
IS

   FUNCTION COND_PROD_LOSS(
      P_EVENT_ID IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_OBJECTS_DEFERMENT_EVENT.COND_PROD_LOSS      (
         P_EVENT_ID );
         RETURN ret_value;
   END COND_PROD_LOSS;
   FUNCTION EXPECTED_VOLUME(
      P_EVENT_ID IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_OBJECTS_DEFERMENT_EVENT.EXPECTED_VOLUME      (
         P_EVENT_ID );
         RETURN ret_value;
   END EXPECTED_VOLUME;
   FUNCTION GAS_PROD_LOSS_MASS(
      P_EVENT_ID IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_OBJECTS_DEFERMENT_EVENT.GAS_PROD_LOSS_MASS      (
         P_EVENT_ID );
         RETURN ret_value;
   END GAS_PROD_LOSS_MASS;
   FUNCTION TEXT_3(
      P_EVENT_ID IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_OBJECTS_DEFERMENT_EVENT.TEXT_3      (
         P_EVENT_ID );
         RETURN ret_value;
   END TEXT_3;
   FUNCTION TEXT_4(
      P_EVENT_ID IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_OBJECTS_DEFERMENT_EVENT.TEXT_4      (
         P_EVENT_ID );
         RETURN ret_value;
   END TEXT_4;
   FUNCTION WATER_PROD_LOSS(
      P_EVENT_ID IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_OBJECTS_DEFERMENT_EVENT.WATER_PROD_LOSS      (
         P_EVENT_ID );
         RETURN ret_value;
   END WATER_PROD_LOSS;
   FUNCTION APPROVAL_BY(
      P_EVENT_ID IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (30) ;
   BEGIN
      ret_value := EC_OBJECTS_DEFERMENT_EVENT.APPROVAL_BY      (
         P_EVENT_ID );
         RETURN ret_value;
   END APPROVAL_BY;
   FUNCTION APPROVAL_STATE(
      P_EVENT_ID IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_OBJECTS_DEFERMENT_EVENT.APPROVAL_STATE      (
         P_EVENT_ID );
         RETURN ret_value;
   END APPROVAL_STATE;
   FUNCTION DILUENT_LOSS(
      P_EVENT_ID IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_OBJECTS_DEFERMENT_EVENT.DILUENT_LOSS      (
         P_EVENT_ID );
         RETURN ret_value;
   END DILUENT_LOSS;
   FUNCTION DURATION_SECS(
      P_EVENT_ID IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_OBJECTS_DEFERMENT_EVENT.DURATION_SECS      (
         P_EVENT_ID );
         RETURN ret_value;
   END DURATION_SECS;
   FUNCTION GRP_DILUENT_LOSS(
      P_EVENT_ID IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_OBJECTS_DEFERMENT_EVENT.GRP_DILUENT_LOSS      (
         P_EVENT_ID );
         RETURN ret_value;
   END GRP_DILUENT_LOSS;
   FUNCTION OIL_PROD_LOSS_MASS(
      P_EVENT_ID IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_OBJECTS_DEFERMENT_EVENT.OIL_PROD_LOSS_MASS      (
         P_EVENT_ID );
         RETURN ret_value;
   END OIL_PROD_LOSS_MASS;
   FUNCTION STATUS(
      P_EVENT_ID IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_OBJECTS_DEFERMENT_EVENT.STATUS      (
         P_EVENT_ID );
         RETURN ret_value;
   END STATUS;
   FUNCTION VALUE_5(
      P_EVENT_ID IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_OBJECTS_DEFERMENT_EVENT.VALUE_5      (
         P_EVENT_ID );
         RETURN ret_value;
   END VALUE_5;
   FUNCTION WATER_PROD_LOSS_MASS(
      P_EVENT_ID IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_OBJECTS_DEFERMENT_EVENT.WATER_PROD_LOSS_MASS      (
         P_EVENT_ID );
         RETURN ret_value;
   END WATER_PROD_LOSS_MASS;
   FUNCTION ACTIVITY_OWNER(
      P_EVENT_ID IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_OBJECTS_DEFERMENT_EVENT.ACTIVITY_OWNER      (
         P_EVENT_ID );
         RETURN ret_value;
   END ACTIVITY_OWNER;
   FUNCTION NEXT_DAYTIME(
      P_EVENT_ID IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_OBJECTS_DEFERMENT_EVENT.NEXT_DAYTIME      (
         P_EVENT_ID,
         P_NUM_ROWS );
         RETURN ret_value;
   END NEXT_DAYTIME;
   FUNCTION OBJECT_ID(
      P_EVENT_ID IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_OBJECTS_DEFERMENT_EVENT.OBJECT_ID      (
         P_EVENT_ID );
         RETURN ret_value;
   END OBJECT_ID;
   FUNCTION PREV_EQUAL_DAYTIME(
      P_EVENT_ID IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_OBJECTS_DEFERMENT_EVENT.PREV_EQUAL_DAYTIME      (
         P_EVENT_ID,
         P_NUM_ROWS );
         RETURN ret_value;
   END PREV_EQUAL_DAYTIME;
   FUNCTION COMMENTS(
      P_EVENT_ID IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_OBJECTS_DEFERMENT_EVENT.COMMENTS      (
         P_EVENT_ID );
         RETURN ret_value;
   END COMMENTS;
   FUNCTION GAS_LIFT_LOSS(
      P_EVENT_ID IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_OBJECTS_DEFERMENT_EVENT.GAS_LIFT_LOSS      (
         P_EVENT_ID );
         RETURN ret_value;
   END GAS_LIFT_LOSS;
   FUNCTION GRP_GAS_INJ_LOSS(
      P_EVENT_ID IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_OBJECTS_DEFERMENT_EVENT.GRP_GAS_INJ_LOSS      (
         P_EVENT_ID );
         RETURN ret_value;
   END GRP_GAS_INJ_LOSS;
   FUNCTION GRP_GAS_LIFT_LOSS(
      P_EVENT_ID IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_OBJECTS_DEFERMENT_EVENT.GRP_GAS_LIFT_LOSS      (
         P_EVENT_ID );
         RETURN ret_value;
   END GRP_GAS_LIFT_LOSS;
   FUNCTION NEXT_EQUAL_DAYTIME(
      P_EVENT_ID IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_OBJECTS_DEFERMENT_EVENT.NEXT_EQUAL_DAYTIME      (
         P_EVENT_ID,
         P_NUM_ROWS );
         RETURN ret_value;
   END NEXT_EQUAL_DAYTIME;
   FUNCTION OIL_PROD_LOSS(
      P_EVENT_ID IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_OBJECTS_DEFERMENT_EVENT.OIL_PROD_LOSS      (
         P_EVENT_ID );
         RETURN ret_value;
   END OIL_PROD_LOSS;
   FUNCTION SEVERITY(
      P_EVENT_ID IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (16) ;
   BEGIN
      ret_value := EC_OBJECTS_DEFERMENT_EVENT.SEVERITY      (
         P_EVENT_ID );
         RETURN ret_value;
   END SEVERITY;
   FUNCTION VALUE_6(
      P_EVENT_ID IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_OBJECTS_DEFERMENT_EVENT.VALUE_6      (
         P_EVENT_ID );
         RETURN ret_value;
   END VALUE_6;
   FUNCTION WORK_ORDER_ID(
      P_EVENT_ID IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (16) ;
   BEGIN
      ret_value := EC_OBJECTS_DEFERMENT_EVENT.WORK_ORDER_ID      (
         P_EVENT_ID );
         RETURN ret_value;
   END WORK_ORDER_ID;
   FUNCTION END_DATE(
      P_EVENT_ID IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_OBJECTS_DEFERMENT_EVENT.END_DATE      (
         P_EVENT_ID );
         RETURN ret_value;
   END END_DATE;
   FUNCTION EVENT_REASON(
      P_EVENT_ID IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (16) ;
   BEGIN
      ret_value := EC_OBJECTS_DEFERMENT_EVENT.EVENT_REASON      (
         P_EVENT_ID );
         RETURN ret_value;
   END EVENT_REASON;
   FUNCTION EVENT_SYSTEM(
      P_EVENT_ID IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_OBJECTS_DEFERMENT_EVENT.EVENT_SYSTEM      (
         P_EVENT_ID );
         RETURN ret_value;
   END EVENT_SYSTEM;
   FUNCTION GAS_PROD_LOSS(
      P_EVENT_ID IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_OBJECTS_DEFERMENT_EVENT.GAS_PROD_LOSS      (
         P_EVENT_ID );
         RETURN ret_value;
   END GAS_PROD_LOSS;
   FUNCTION GRP_GAS_PROD_LOSS(
      P_EVENT_ID IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_OBJECTS_DEFERMENT_EVENT.GRP_GAS_PROD_LOSS      (
         P_EVENT_ID );
         RETURN ret_value;
   END GRP_GAS_PROD_LOSS;
   FUNCTION PREV_DAYTIME(
      P_EVENT_ID IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_OBJECTS_DEFERMENT_EVENT.PREV_DAYTIME      (
         P_EVENT_ID,
         P_NUM_ROWS );
         RETURN ret_value;
   END PREV_DAYTIME;
   FUNCTION RECORD_STATUS(
      P_EVENT_ID IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_OBJECTS_DEFERMENT_EVENT.RECORD_STATUS      (
         P_EVENT_ID );
         RETURN ret_value;
   END RECORD_STATUS;
   FUNCTION VALUE_1(
      P_EVENT_ID IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_OBJECTS_DEFERMENT_EVENT.VALUE_1      (
         P_EVENT_ID );
         RETURN ret_value;
   END VALUE_1;
   FUNCTION APPROVAL_DATE(
      P_EVENT_ID IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_OBJECTS_DEFERMENT_EVENT.APPROVAL_DATE      (
         P_EVENT_ID );
         RETURN ret_value;
   END APPROVAL_DATE;
   FUNCTION CHILD_AGGREGATE_IND(
      P_EVENT_ID IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_OBJECTS_DEFERMENT_EVENT.CHILD_AGGREGATE_IND      (
         P_EVENT_ID );
         RETURN ret_value;
   END CHILD_AGGREGATE_IND;
   FUNCTION EVENT_CATEGORY(
      P_EVENT_ID IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (16) ;
   BEGIN
      ret_value := EC_OBJECTS_DEFERMENT_EVENT.EVENT_CATEGORY      (
         P_EVENT_ID );
         RETURN ret_value;
   END EVENT_CATEGORY;
   FUNCTION EXPECTED_RATE(
      P_EVENT_ID IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_OBJECTS_DEFERMENT_EVENT.EXPECTED_RATE      (
         P_EVENT_ID );
         RETURN ret_value;
   END EXPECTED_RATE;
   FUNCTION GRP_WATER_INJ_LOSS(
      P_EVENT_ID IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_OBJECTS_DEFERMENT_EVENT.GRP_WATER_INJ_LOSS      (
         P_EVENT_ID );
         RETURN ret_value;
   END GRP_WATER_INJ_LOSS;
   FUNCTION GRP_WATER_PROD_LOSS(
      P_EVENT_ID IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_OBJECTS_DEFERMENT_EVENT.GRP_WATER_PROD_LOSS      (
         P_EVENT_ID );
         RETURN ret_value;
   END GRP_WATER_PROD_LOSS;
   FUNCTION LINKED_EVENT_ID(
      P_EVENT_ID IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_OBJECTS_DEFERMENT_EVENT.LINKED_EVENT_ID      (
         P_EVENT_ID );
         RETURN ret_value;
   END LINKED_EVENT_ID;
   FUNCTION OBJECT_TYPE(
      P_EVENT_ID IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (24) ;
   BEGIN
      ret_value := EC_OBJECTS_DEFERMENT_EVENT.OBJECT_TYPE      (
         P_EVENT_ID );
         RETURN ret_value;
   END OBJECT_TYPE;
   FUNCTION ROW_BY_PK(
      P_EVENT_ID IN NUMBER)
      RETURN REC_ROW_BY_PK
   IS
      ret_value    REC_ROW_BY_PK ;
   BEGIN
      ret_value := EC_OBJECTS_DEFERMENT_EVENT.ROW_BY_PK      (
         P_EVENT_ID );
         RETURN ret_value;
   END ROW_BY_PK;
   FUNCTION VALUE_2(
      P_EVENT_ID IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_OBJECTS_DEFERMENT_EVENT.VALUE_2      (
         P_EVENT_ID );
         RETURN ret_value;
   END VALUE_2;
   FUNCTION VALUE_3(
      P_EVENT_ID IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_OBJECTS_DEFERMENT_EVENT.VALUE_3      (
         P_EVENT_ID );
         RETURN ret_value;
   END VALUE_3;
   FUNCTION VALUE_4(
      P_EVENT_ID IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_OBJECTS_DEFERMENT_EVENT.VALUE_4      (
         P_EVENT_ID );
         RETURN ret_value;
   END VALUE_4;
   FUNCTION WATER_INJ_LOSS(
      P_EVENT_ID IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_OBJECTS_DEFERMENT_EVENT.WATER_INJ_LOSS      (
         P_EVENT_ID );
         RETURN ret_value;
   END WATER_INJ_LOSS;
   FUNCTION REC_ID(
      P_EVENT_ID IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_OBJECTS_DEFERMENT_EVENT.REC_ID      (
         P_EVENT_ID );
         RETURN ret_value;
   END REC_ID;
   FUNCTION SCHEDULED(
      P_EVENT_ID IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_OBJECTS_DEFERMENT_EVENT.SCHEDULED      (
         P_EVENT_ID );
         RETURN ret_value;
   END SCHEDULED;
   FUNCTION TEXT_1(
      P_EVENT_ID IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (16) ;
   BEGIN
      ret_value := EC_OBJECTS_DEFERMENT_EVENT.TEXT_1      (
         P_EVENT_ID );
         RETURN ret_value;
   END TEXT_1;
   FUNCTION TEXT_2(
      P_EVENT_ID IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_OBJECTS_DEFERMENT_EVENT.TEXT_2      (
         P_EVENT_ID );
         RETURN ret_value;
   END TEXT_2;
   FUNCTION VALUE_7(
      P_EVENT_ID IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_OBJECTS_DEFERMENT_EVENT.VALUE_7      (
         P_EVENT_ID );
         RETURN ret_value;
   END VALUE_7;
   FUNCTION VALUE_9(
      P_EVENT_ID IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_OBJECTS_DEFERMENT_EVENT.VALUE_9      (
         P_EVENT_ID );
         RETURN ret_value;
   END VALUE_9;
   FUNCTION COND_PROD_LOSS_MASS(
      P_EVENT_ID IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_OBJECTS_DEFERMENT_EVENT.COND_PROD_LOSS_MASS      (
         P_EVENT_ID );
         RETURN ret_value;
   END COND_PROD_LOSS_MASS;
   FUNCTION DAYTIME(
      P_EVENT_ID IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_OBJECTS_DEFERMENT_EVENT.DAYTIME      (
         P_EVENT_ID );
         RETURN ret_value;
   END DAYTIME;
   FUNCTION EVENT_TYPE(
      P_EVENT_ID IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (16) ;
   BEGIN
      ret_value := EC_OBJECTS_DEFERMENT_EVENT.EVENT_TYPE      (
         P_EVENT_ID );
         RETURN ret_value;
   END EVENT_TYPE;
   FUNCTION EXPECTED_DATE(
      P_EVENT_ID IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_OBJECTS_DEFERMENT_EVENT.EXPECTED_DATE      (
         P_EVENT_ID );
         RETURN ret_value;
   END EXPECTED_DATE;
   FUNCTION GAS_INJ_LOSS(
      P_EVENT_ID IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_OBJECTS_DEFERMENT_EVENT.GAS_INJ_LOSS      (
         P_EVENT_ID );
         RETURN ret_value;
   END GAS_INJ_LOSS;
   FUNCTION GRP_COND_PROD_LOSS(
      P_EVENT_ID IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_OBJECTS_DEFERMENT_EVENT.GRP_COND_PROD_LOSS      (
         P_EVENT_ID );
         RETURN ret_value;
   END GRP_COND_PROD_LOSS;
   FUNCTION GRP_OIL_PROD_LOSS(
      P_EVENT_ID IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_OBJECTS_DEFERMENT_EVENT.GRP_OIL_PROD_LOSS      (
         P_EVENT_ID );
         RETURN ret_value;
   END GRP_OIL_PROD_LOSS;
   FUNCTION PARENT_EVENT_ID(
      P_EVENT_ID IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_OBJECTS_DEFERMENT_EVENT.PARENT_EVENT_ID      (
         P_EVENT_ID );
         RETURN ret_value;
   END PARENT_EVENT_ID;
   FUNCTION PRODUCTION_DAY(
      P_EVENT_ID IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_OBJECTS_DEFERMENT_EVENT.PRODUCTION_DAY      (
         P_EVENT_ID );
         RETURN ret_value;
   END PRODUCTION_DAY;
   FUNCTION ROOT_CAUSE(
      P_EVENT_ID IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_OBJECTS_DEFERMENT_EVENT.ROOT_CAUSE      (
         P_EVENT_ID );
         RETURN ret_value;
   END ROOT_CAUSE;
   FUNCTION VALUE_10(
      P_EVENT_ID IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_OBJECTS_DEFERMENT_EVENT.VALUE_10      (
         P_EVENT_ID );
         RETURN ret_value;
   END VALUE_10;
   FUNCTION VALUE_8(
      P_EVENT_ID IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_OBJECTS_DEFERMENT_EVENT.VALUE_8      (
         P_EVENT_ID );
         RETURN ret_value;
   END VALUE_8;

END RP_OBJECTS_DEFERMENT_EVENT;

/
--GRANT EXECUTE ON ECKERNEL_WST.RP_OBJECTS_DEFERMENT_EVENT TO REPORT_ROLE_XXX;



 -- FINISH PKG_GEN_PKGS.sf_get_functions at:11/15/2018 08.47.53 AM


