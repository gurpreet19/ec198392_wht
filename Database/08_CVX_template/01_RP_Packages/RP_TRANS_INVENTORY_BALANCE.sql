
 -- START PKG_GEN_PKGS.sf_get_functions at:05/07/2019 05.33.41 AM


CREATE or REPLACE PACKAGE RP_TRANS_INVENTORY_BALANCE
IS

   FUNCTION COST_11(
      P_KEY IN NUMBER)
      RETURN NUMBER;
   FUNCTION COST_14(
      P_KEY IN NUMBER)
      RETURN NUMBER;
   FUNCTION COST_19(
      P_KEY IN NUMBER)
      RETURN NUMBER;
   FUNCTION DATE_10(
      P_KEY IN NUMBER)
      RETURN DATE;
   FUNCTION PP_PREV_KEY(
      P_KEY IN NUMBER)
      RETURN NUMBER;
   FUNCTION SORT_ORDER(
      P_KEY IN NUMBER)
      RETURN NUMBER;
   FUNCTION TEXT_3(
      P_KEY IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION UNIT_PRICE_1(
      P_KEY IN NUMBER)
      RETURN NUMBER;
   FUNCTION UNIT_PRICE_10(
      P_KEY IN NUMBER)
      RETURN NUMBER;
   FUNCTION UNIT_PRICE_17(
      P_KEY IN NUMBER)
      RETURN NUMBER;
   FUNCTION UNIT_PRICE_20(
      P_KEY IN NUMBER)
      RETURN NUMBER;
   FUNCTION UNIT_PRICE_26(
      P_KEY IN NUMBER)
      RETURN NUMBER;
   FUNCTION UNIT_PRICE_28(
      P_KEY IN NUMBER)
      RETURN NUMBER;
   FUNCTION UNIT_PRICE_6(
      P_KEY IN NUMBER)
      RETURN NUMBER;
   FUNCTION APPROVAL_BY(
      P_KEY IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_STATE(
      P_KEY IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION COST_27(
      P_KEY IN NUMBER)
      RETURN NUMBER;
   FUNCTION COST_29(
      P_KEY IN NUMBER)
      RETURN NUMBER;
   FUNCTION QTY_4(
      P_KEY IN NUMBER)
      RETURN NUMBER;
   FUNCTION REF_OBJECT_ID_4(
      P_KEY IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION UNIT_PRICE_18(
      P_KEY IN NUMBER)
      RETURN NUMBER;
   FUNCTION UNIT_PRICE_27(
      P_KEY IN NUMBER)
      RETURN NUMBER;
   FUNCTION UNIT_PRICE_9(
      P_KEY IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_5(
      P_KEY IN NUMBER)
      RETURN NUMBER;
   FUNCTION COST_10(
      P_KEY IN NUMBER)
      RETURN NUMBER;
   FUNCTION COST_17(
      P_KEY IN NUMBER)
      RETURN NUMBER;
   FUNCTION COST_20(
      P_KEY IN NUMBER)
      RETURN NUMBER;
   FUNCTION COST_25(
      P_KEY IN NUMBER)
      RETURN NUMBER;
   FUNCTION COST_30(
      P_KEY IN NUMBER)
      RETURN NUMBER;
   FUNCTION COST_5(
      P_KEY IN NUMBER)
      RETURN NUMBER;
   FUNCTION COST_7(
      P_KEY IN NUMBER)
      RETURN NUMBER;
   FUNCTION DATE_7(
      P_KEY IN NUMBER)
      RETURN DATE;
   FUNCTION DATE_9(
      P_KEY IN NUMBER)
      RETURN DATE;
   FUNCTION NEXT_DAYTIME(
      P_KEY IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION OBJECT_ID(
      P_KEY IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION PREV_EQUAL_DAYTIME(
      P_KEY IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION QTY_8(
      P_KEY IN NUMBER)
      RETURN NUMBER;
   FUNCTION TEXT_7(
      P_KEY IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_8(
      P_KEY IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION UNIT_PRICE_12(
      P_KEY IN NUMBER)
      RETURN NUMBER;
   FUNCTION UNIT_PRICE_13(
      P_KEY IN NUMBER)
      RETURN NUMBER;
   FUNCTION UNIT_PRICE_14(
      P_KEY IN NUMBER)
      RETURN NUMBER;
   FUNCTION UNIT_PRICE_15(
      P_KEY IN NUMBER)
      RETURN NUMBER;
   FUNCTION UNIT_PRICE_16(
      P_KEY IN NUMBER)
      RETURN NUMBER;
   FUNCTION UNIT_PRICE_19(
      P_KEY IN NUMBER)
      RETURN NUMBER;
   FUNCTION UNIT_PRICE_23(
      P_KEY IN NUMBER)
      RETURN NUMBER;
   FUNCTION UNIT_PRICE_24(
      P_KEY IN NUMBER)
      RETURN NUMBER;
   FUNCTION COST_1(
      P_KEY IN NUMBER)
      RETURN NUMBER;
   FUNCTION COST_12(
      P_KEY IN NUMBER)
      RETURN NUMBER;
   FUNCTION COST_13(
      P_KEY IN NUMBER)
      RETURN NUMBER;
   FUNCTION COST_21(
      P_KEY IN NUMBER)
      RETURN NUMBER;
   FUNCTION COST_22(
      P_KEY IN NUMBER)
      RETURN NUMBER;
   FUNCTION COST_23(
      P_KEY IN NUMBER)
      RETURN NUMBER;
   FUNCTION DATE_3(
      P_KEY IN NUMBER)
      RETURN DATE;
   FUNCTION DATE_5(
      P_KEY IN NUMBER)
      RETURN DATE;
   FUNCTION NEXT_EQUAL_DAYTIME(
      P_KEY IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION QTY_1(
      P_KEY IN NUMBER)
      RETURN NUMBER;
   FUNCTION QTY_7(
      P_KEY IN NUMBER)
      RETURN NUMBER;
   FUNCTION REF_OBJECT_ID_2(
      P_KEY IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION REF_OBJECT_ID_3(
      P_KEY IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_1(
      P_KEY IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_6(
      P_KEY IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_9(
      P_KEY IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION UNIT_PRICE_11(
      P_KEY IN NUMBER)
      RETURN NUMBER;
   FUNCTION UNIT_PRICE_22(
      P_KEY IN NUMBER)
      RETURN NUMBER;
   FUNCTION UNIT_PRICE_29(
      P_KEY IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_6(
      P_KEY IN NUMBER)
      RETURN NUMBER;
   FUNCTION COST_2(
      P_KEY IN NUMBER)
      RETURN NUMBER;
   FUNCTION COST_26(
      P_KEY IN NUMBER)
      RETURN NUMBER;
   FUNCTION COST_28(
      P_KEY IN NUMBER)
      RETURN NUMBER;
   FUNCTION COST_4(
      P_KEY IN NUMBER)
      RETURN NUMBER;
   FUNCTION DATE_2(
      P_KEY IN NUMBER)
      RETURN DATE;
   FUNCTION MAX_IND(
      P_KEY IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION PP_CALC_NO(
      P_KEY IN NUMBER)
      RETURN NUMBER;
   FUNCTION PREV_DAYTIME(
      P_KEY IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION QTY_2(
      P_KEY IN NUMBER)
      RETURN NUMBER;
   FUNCTION QTY_3(
      P_KEY IN NUMBER)
      RETURN NUMBER;
   FUNCTION QTY_6(
      P_KEY IN NUMBER)
      RETURN NUMBER;
   FUNCTION RECORD_STATUS(
      P_KEY IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION REF_OBJECT_ID_5(
      P_KEY IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION UNIT_PRICE_3(
      P_KEY IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_1(
      P_KEY IN NUMBER)
      RETURN NUMBER;
   FUNCTION APPROVAL_DATE(
      P_KEY IN NUMBER)
      RETURN DATE;
   FUNCTION CALC_RUN_NO(
      P_KEY IN NUMBER)
      RETURN NUMBER;
   FUNCTION COST_16(
      P_KEY IN NUMBER)
      RETURN NUMBER;
   FUNCTION COST_18(
      P_KEY IN NUMBER)
      RETURN NUMBER;
   FUNCTION COST_9(
      P_KEY IN NUMBER)
      RETURN NUMBER;
   FUNCTION DATE_6(
      P_KEY IN NUMBER)
      RETURN DATE;
   FUNCTION PROD_STREAM_ID(
      P_KEY IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION REF_OBJECT_ID_1(
      P_KEY IN NUMBER)
      RETURN VARCHAR2;
      TYPE REC_ROW_BY_PK IS RECORD (
         OBJECT_ID VARCHAR2 (32) ,
         DAYTIME  DATE ,
         LAYER_MONTH  DATE ,
         DIMENSION_TAG VARCHAR2 (100) ,
         PROD_STREAM_ID VARCHAR2 (32) ,
         QTY_1 NUMBER ,
         QTY_2 NUMBER ,
         QTY_3 NUMBER ,
         QTY_4 NUMBER ,
         QTY_5 NUMBER ,
         QTY_6 NUMBER ,
         QTY_7 NUMBER ,
         QTY_8 NUMBER ,
         QTY_9 NUMBER ,
         QTY_10 NUMBER ,
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
         COST_1 NUMBER ,
         COST_2 NUMBER ,
         COST_3 NUMBER ,
         COST_4 NUMBER ,
         COST_5 NUMBER ,
         COST_6 NUMBER ,
         COST_7 NUMBER ,
         COST_8 NUMBER ,
         COST_9 NUMBER ,
         COST_10 NUMBER ,
         COST_11 NUMBER ,
         COST_12 NUMBER ,
         COST_13 NUMBER ,
         COST_14 NUMBER ,
         COST_15 NUMBER ,
         COST_16 NUMBER ,
         COST_17 NUMBER ,
         COST_18 NUMBER ,
         COST_19 NUMBER ,
         COST_20 NUMBER ,
         COST_21 NUMBER ,
         COST_22 NUMBER ,
         COST_23 NUMBER ,
         COST_24 NUMBER ,
         COST_25 NUMBER ,
         COST_26 NUMBER ,
         COST_27 NUMBER ,
         COST_28 NUMBER ,
         COST_29 NUMBER ,
         COST_30 NUMBER ,
         UNIT_PRICE_1 NUMBER ,
         UNIT_PRICE_2 NUMBER ,
         UNIT_PRICE_3 NUMBER ,
         UNIT_PRICE_4 NUMBER ,
         UNIT_PRICE_5 NUMBER ,
         UNIT_PRICE_6 NUMBER ,
         UNIT_PRICE_7 NUMBER ,
         UNIT_PRICE_8 NUMBER ,
         UNIT_PRICE_9 NUMBER ,
         UNIT_PRICE_10 NUMBER ,
         UNIT_PRICE_11 NUMBER ,
         UNIT_PRICE_12 NUMBER ,
         UNIT_PRICE_13 NUMBER ,
         UNIT_PRICE_14 NUMBER ,
         UNIT_PRICE_15 NUMBER ,
         UNIT_PRICE_16 NUMBER ,
         UNIT_PRICE_17 NUMBER ,
         UNIT_PRICE_18 NUMBER ,
         UNIT_PRICE_19 NUMBER ,
         UNIT_PRICE_20 NUMBER ,
         UNIT_PRICE_21 NUMBER ,
         UNIT_PRICE_22 NUMBER ,
         UNIT_PRICE_23 NUMBER ,
         UNIT_PRICE_24 NUMBER ,
         UNIT_PRICE_25 NUMBER ,
         UNIT_PRICE_26 NUMBER ,
         UNIT_PRICE_27 NUMBER ,
         UNIT_PRICE_28 NUMBER ,
         UNIT_PRICE_29 NUMBER ,
         UNIT_PRICE_30 NUMBER ,
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
         DATE_6  DATE ,
         DATE_7  DATE ,
         DATE_8  DATE ,
         DATE_9  DATE ,
         DATE_10  DATE ,
         REF_OBJECT_ID_1 VARCHAR2 (32) ,
         REF_OBJECT_ID_2 VARCHAR2 (32) ,
         REF_OBJECT_ID_3 VARCHAR2 (32) ,
         REF_OBJECT_ID_4 VARCHAR2 (32) ,
         REF_OBJECT_ID_5 VARCHAR2 (32) ,
         KEY NUMBER ,
         PP_PREV_KEY NUMBER ,
         PP_CALC_NO NUMBER ,
         MAX_IND VARCHAR2 (1) ,
         CALC_RUN_NO NUMBER ,
         SORT_ORDER NUMBER ,
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
      P_KEY IN NUMBER)
      RETURN REC_ROW_BY_PK;
   FUNCTION TEXT_2(
      P_KEY IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_4(
      P_KEY IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_5(
      P_KEY IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION UNIT_PRICE_5(
      P_KEY IN NUMBER)
      RETURN NUMBER;
   FUNCTION UNIT_PRICE_8(
      P_KEY IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_2(
      P_KEY IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_3(
      P_KEY IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_4(
      P_KEY IN NUMBER)
      RETURN NUMBER;
   FUNCTION COST_15(
      P_KEY IN NUMBER)
      RETURN NUMBER;
   FUNCTION DATE_4(
      P_KEY IN NUMBER)
      RETURN DATE;
   FUNCTION DIMENSION_TAG(
      P_KEY IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION QTY_9(
      P_KEY IN NUMBER)
      RETURN NUMBER;
   FUNCTION REC_ID(
      P_KEY IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION UNIT_PRICE_2(
      P_KEY IN NUMBER)
      RETURN NUMBER;
   FUNCTION UNIT_PRICE_21(
      P_KEY IN NUMBER)
      RETURN NUMBER;
   FUNCTION UNIT_PRICE_4(
      P_KEY IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_7(
      P_KEY IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_9(
      P_KEY IN NUMBER)
      RETURN NUMBER;
   FUNCTION COST_24(
      P_KEY IN NUMBER)
      RETURN NUMBER;
   FUNCTION COST_3(
      P_KEY IN NUMBER)
      RETURN NUMBER;
   FUNCTION COST_6(
      P_KEY IN NUMBER)
      RETURN NUMBER;
   FUNCTION COST_8(
      P_KEY IN NUMBER)
      RETURN NUMBER;
   FUNCTION DATE_1(
      P_KEY IN NUMBER)
      RETURN DATE;
   FUNCTION DATE_8(
      P_KEY IN NUMBER)
      RETURN DATE;
   FUNCTION DAYTIME(
      P_KEY IN NUMBER)
      RETURN DATE;
   FUNCTION LAYER_MONTH(
      P_KEY IN NUMBER)
      RETURN DATE;
   FUNCTION QTY_10(
      P_KEY IN NUMBER)
      RETURN NUMBER;
   FUNCTION QTY_5(
      P_KEY IN NUMBER)
      RETURN NUMBER;
   FUNCTION TEXT_10(
      P_KEY IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION UNIT_PRICE_25(
      P_KEY IN NUMBER)
      RETURN NUMBER;
   FUNCTION UNIT_PRICE_30(
      P_KEY IN NUMBER)
      RETURN NUMBER;
   FUNCTION UNIT_PRICE_7(
      P_KEY IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_10(
      P_KEY IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_8(
      P_KEY IN NUMBER)
      RETURN NUMBER;

END RP_TRANS_INVENTORY_BALANCE;

/



CREATE or REPLACE PACKAGE BODY RP_TRANS_INVENTORY_BALANCE
IS

   FUNCTION COST_11(
      P_KEY IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_TRANS_INVENTORY_BALANCE.COST_11      (
         P_KEY );
         RETURN ret_value;
   END COST_11;
   FUNCTION COST_14(
      P_KEY IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_TRANS_INVENTORY_BALANCE.COST_14      (
         P_KEY );
         RETURN ret_value;
   END COST_14;
   FUNCTION COST_19(
      P_KEY IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_TRANS_INVENTORY_BALANCE.COST_19      (
         P_KEY );
         RETURN ret_value;
   END COST_19;
   FUNCTION DATE_10(
      P_KEY IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_TRANS_INVENTORY_BALANCE.DATE_10      (
         P_KEY );
         RETURN ret_value;
   END DATE_10;
   FUNCTION PP_PREV_KEY(
      P_KEY IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_TRANS_INVENTORY_BALANCE.PP_PREV_KEY      (
         P_KEY );
         RETURN ret_value;
   END PP_PREV_KEY;
   FUNCTION SORT_ORDER(
      P_KEY IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_TRANS_INVENTORY_BALANCE.SORT_ORDER      (
         P_KEY );
         RETURN ret_value;
   END SORT_ORDER;
   FUNCTION TEXT_3(
      P_KEY IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_TRANS_INVENTORY_BALANCE.TEXT_3      (
         P_KEY );
         RETURN ret_value;
   END TEXT_3;
   FUNCTION UNIT_PRICE_1(
      P_KEY IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_TRANS_INVENTORY_BALANCE.UNIT_PRICE_1      (
         P_KEY );
         RETURN ret_value;
   END UNIT_PRICE_1;
   FUNCTION UNIT_PRICE_10(
      P_KEY IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_TRANS_INVENTORY_BALANCE.UNIT_PRICE_10      (
         P_KEY );
         RETURN ret_value;
   END UNIT_PRICE_10;
   FUNCTION UNIT_PRICE_17(
      P_KEY IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_TRANS_INVENTORY_BALANCE.UNIT_PRICE_17      (
         P_KEY );
         RETURN ret_value;
   END UNIT_PRICE_17;
   FUNCTION UNIT_PRICE_20(
      P_KEY IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_TRANS_INVENTORY_BALANCE.UNIT_PRICE_20      (
         P_KEY );
         RETURN ret_value;
   END UNIT_PRICE_20;
   FUNCTION UNIT_PRICE_26(
      P_KEY IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_TRANS_INVENTORY_BALANCE.UNIT_PRICE_26      (
         P_KEY );
         RETURN ret_value;
   END UNIT_PRICE_26;
   FUNCTION UNIT_PRICE_28(
      P_KEY IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_TRANS_INVENTORY_BALANCE.UNIT_PRICE_28      (
         P_KEY );
         RETURN ret_value;
   END UNIT_PRICE_28;
   FUNCTION UNIT_PRICE_6(
      P_KEY IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_TRANS_INVENTORY_BALANCE.UNIT_PRICE_6      (
         P_KEY );
         RETURN ret_value;
   END UNIT_PRICE_6;
   FUNCTION APPROVAL_BY(
      P_KEY IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (30) ;
   BEGIN
      ret_value := EC_TRANS_INVENTORY_BALANCE.APPROVAL_BY      (
         P_KEY );
         RETURN ret_value;
   END APPROVAL_BY;
   FUNCTION APPROVAL_STATE(
      P_KEY IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_TRANS_INVENTORY_BALANCE.APPROVAL_STATE      (
         P_KEY );
         RETURN ret_value;
   END APPROVAL_STATE;
   FUNCTION COST_27(
      P_KEY IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_TRANS_INVENTORY_BALANCE.COST_27      (
         P_KEY );
         RETURN ret_value;
   END COST_27;
   FUNCTION COST_29(
      P_KEY IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_TRANS_INVENTORY_BALANCE.COST_29      (
         P_KEY );
         RETURN ret_value;
   END COST_29;
   FUNCTION QTY_4(
      P_KEY IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_TRANS_INVENTORY_BALANCE.QTY_4      (
         P_KEY );
         RETURN ret_value;
   END QTY_4;
   FUNCTION REF_OBJECT_ID_4(
      P_KEY IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_TRANS_INVENTORY_BALANCE.REF_OBJECT_ID_4      (
         P_KEY );
         RETURN ret_value;
   END REF_OBJECT_ID_4;
   FUNCTION UNIT_PRICE_18(
      P_KEY IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_TRANS_INVENTORY_BALANCE.UNIT_PRICE_18      (
         P_KEY );
         RETURN ret_value;
   END UNIT_PRICE_18;
   FUNCTION UNIT_PRICE_27(
      P_KEY IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_TRANS_INVENTORY_BALANCE.UNIT_PRICE_27      (
         P_KEY );
         RETURN ret_value;
   END UNIT_PRICE_27;
   FUNCTION UNIT_PRICE_9(
      P_KEY IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_TRANS_INVENTORY_BALANCE.UNIT_PRICE_9      (
         P_KEY );
         RETURN ret_value;
   END UNIT_PRICE_9;
   FUNCTION VALUE_5(
      P_KEY IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_TRANS_INVENTORY_BALANCE.VALUE_5      (
         P_KEY );
         RETURN ret_value;
   END VALUE_5;
   FUNCTION COST_10(
      P_KEY IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_TRANS_INVENTORY_BALANCE.COST_10      (
         P_KEY );
         RETURN ret_value;
   END COST_10;
   FUNCTION COST_17(
      P_KEY IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_TRANS_INVENTORY_BALANCE.COST_17      (
         P_KEY );
         RETURN ret_value;
   END COST_17;
   FUNCTION COST_20(
      P_KEY IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_TRANS_INVENTORY_BALANCE.COST_20      (
         P_KEY );
         RETURN ret_value;
   END COST_20;
   FUNCTION COST_25(
      P_KEY IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_TRANS_INVENTORY_BALANCE.COST_25      (
         P_KEY );
         RETURN ret_value;
   END COST_25;
   FUNCTION COST_30(
      P_KEY IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_TRANS_INVENTORY_BALANCE.COST_30      (
         P_KEY );
         RETURN ret_value;
   END COST_30;
   FUNCTION COST_5(
      P_KEY IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_TRANS_INVENTORY_BALANCE.COST_5      (
         P_KEY );
         RETURN ret_value;
   END COST_5;
   FUNCTION COST_7(
      P_KEY IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_TRANS_INVENTORY_BALANCE.COST_7      (
         P_KEY );
         RETURN ret_value;
   END COST_7;
   FUNCTION DATE_7(
      P_KEY IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_TRANS_INVENTORY_BALANCE.DATE_7      (
         P_KEY );
         RETURN ret_value;
   END DATE_7;
   FUNCTION DATE_9(
      P_KEY IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_TRANS_INVENTORY_BALANCE.DATE_9      (
         P_KEY );
         RETURN ret_value;
   END DATE_9;
   FUNCTION NEXT_DAYTIME(
      P_KEY IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_TRANS_INVENTORY_BALANCE.NEXT_DAYTIME      (
         P_KEY,
         P_NUM_ROWS );
         RETURN ret_value;
   END NEXT_DAYTIME;
   FUNCTION OBJECT_ID(
      P_KEY IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_TRANS_INVENTORY_BALANCE.OBJECT_ID      (
         P_KEY );
         RETURN ret_value;
   END OBJECT_ID;
   FUNCTION PREV_EQUAL_DAYTIME(
      P_KEY IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_TRANS_INVENTORY_BALANCE.PREV_EQUAL_DAYTIME      (
         P_KEY,
         P_NUM_ROWS );
         RETURN ret_value;
   END PREV_EQUAL_DAYTIME;
   FUNCTION QTY_8(
      P_KEY IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_TRANS_INVENTORY_BALANCE.QTY_8      (
         P_KEY );
         RETURN ret_value;
   END QTY_8;
   FUNCTION TEXT_7(
      P_KEY IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_TRANS_INVENTORY_BALANCE.TEXT_7      (
         P_KEY );
         RETURN ret_value;
   END TEXT_7;
   FUNCTION TEXT_8(
      P_KEY IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_TRANS_INVENTORY_BALANCE.TEXT_8      (
         P_KEY );
         RETURN ret_value;
   END TEXT_8;
   FUNCTION UNIT_PRICE_12(
      P_KEY IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_TRANS_INVENTORY_BALANCE.UNIT_PRICE_12      (
         P_KEY );
         RETURN ret_value;
   END UNIT_PRICE_12;
   FUNCTION UNIT_PRICE_13(
      P_KEY IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_TRANS_INVENTORY_BALANCE.UNIT_PRICE_13      (
         P_KEY );
         RETURN ret_value;
   END UNIT_PRICE_13;
   FUNCTION UNIT_PRICE_14(
      P_KEY IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_TRANS_INVENTORY_BALANCE.UNIT_PRICE_14      (
         P_KEY );
         RETURN ret_value;
   END UNIT_PRICE_14;
   FUNCTION UNIT_PRICE_15(
      P_KEY IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_TRANS_INVENTORY_BALANCE.UNIT_PRICE_15      (
         P_KEY );
         RETURN ret_value;
   END UNIT_PRICE_15;
   FUNCTION UNIT_PRICE_16(
      P_KEY IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_TRANS_INVENTORY_BALANCE.UNIT_PRICE_16      (
         P_KEY );
         RETURN ret_value;
   END UNIT_PRICE_16;
   FUNCTION UNIT_PRICE_19(
      P_KEY IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_TRANS_INVENTORY_BALANCE.UNIT_PRICE_19      (
         P_KEY );
         RETURN ret_value;
   END UNIT_PRICE_19;
   FUNCTION UNIT_PRICE_23(
      P_KEY IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_TRANS_INVENTORY_BALANCE.UNIT_PRICE_23      (
         P_KEY );
         RETURN ret_value;
   END UNIT_PRICE_23;
   FUNCTION UNIT_PRICE_24(
      P_KEY IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_TRANS_INVENTORY_BALANCE.UNIT_PRICE_24      (
         P_KEY );
         RETURN ret_value;
   END UNIT_PRICE_24;
   FUNCTION COST_1(
      P_KEY IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_TRANS_INVENTORY_BALANCE.COST_1      (
         P_KEY );
         RETURN ret_value;
   END COST_1;
   FUNCTION COST_12(
      P_KEY IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_TRANS_INVENTORY_BALANCE.COST_12      (
         P_KEY );
         RETURN ret_value;
   END COST_12;
   FUNCTION COST_13(
      P_KEY IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_TRANS_INVENTORY_BALANCE.COST_13      (
         P_KEY );
         RETURN ret_value;
   END COST_13;
   FUNCTION COST_21(
      P_KEY IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_TRANS_INVENTORY_BALANCE.COST_21      (
         P_KEY );
         RETURN ret_value;
   END COST_21;
   FUNCTION COST_22(
      P_KEY IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_TRANS_INVENTORY_BALANCE.COST_22      (
         P_KEY );
         RETURN ret_value;
   END COST_22;
   FUNCTION COST_23(
      P_KEY IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_TRANS_INVENTORY_BALANCE.COST_23      (
         P_KEY );
         RETURN ret_value;
   END COST_23;
   FUNCTION DATE_3(
      P_KEY IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_TRANS_INVENTORY_BALANCE.DATE_3      (
         P_KEY );
         RETURN ret_value;
   END DATE_3;
   FUNCTION DATE_5(
      P_KEY IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_TRANS_INVENTORY_BALANCE.DATE_5      (
         P_KEY );
         RETURN ret_value;
   END DATE_5;
   FUNCTION NEXT_EQUAL_DAYTIME(
      P_KEY IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_TRANS_INVENTORY_BALANCE.NEXT_EQUAL_DAYTIME      (
         P_KEY,
         P_NUM_ROWS );
         RETURN ret_value;
   END NEXT_EQUAL_DAYTIME;
   FUNCTION QTY_1(
      P_KEY IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_TRANS_INVENTORY_BALANCE.QTY_1      (
         P_KEY );
         RETURN ret_value;
   END QTY_1;
   FUNCTION QTY_7(
      P_KEY IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_TRANS_INVENTORY_BALANCE.QTY_7      (
         P_KEY );
         RETURN ret_value;
   END QTY_7;
   FUNCTION REF_OBJECT_ID_2(
      P_KEY IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_TRANS_INVENTORY_BALANCE.REF_OBJECT_ID_2      (
         P_KEY );
         RETURN ret_value;
   END REF_OBJECT_ID_2;
   FUNCTION REF_OBJECT_ID_3(
      P_KEY IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_TRANS_INVENTORY_BALANCE.REF_OBJECT_ID_3      (
         P_KEY );
         RETURN ret_value;
   END REF_OBJECT_ID_3;
   FUNCTION TEXT_1(
      P_KEY IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_TRANS_INVENTORY_BALANCE.TEXT_1      (
         P_KEY );
         RETURN ret_value;
   END TEXT_1;
   FUNCTION TEXT_6(
      P_KEY IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_TRANS_INVENTORY_BALANCE.TEXT_6      (
         P_KEY );
         RETURN ret_value;
   END TEXT_6;
   FUNCTION TEXT_9(
      P_KEY IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_TRANS_INVENTORY_BALANCE.TEXT_9      (
         P_KEY );
         RETURN ret_value;
   END TEXT_9;
   FUNCTION UNIT_PRICE_11(
      P_KEY IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_TRANS_INVENTORY_BALANCE.UNIT_PRICE_11      (
         P_KEY );
         RETURN ret_value;
   END UNIT_PRICE_11;
   FUNCTION UNIT_PRICE_22(
      P_KEY IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_TRANS_INVENTORY_BALANCE.UNIT_PRICE_22      (
         P_KEY );
         RETURN ret_value;
   END UNIT_PRICE_22;
   FUNCTION UNIT_PRICE_29(
      P_KEY IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_TRANS_INVENTORY_BALANCE.UNIT_PRICE_29      (
         P_KEY );
         RETURN ret_value;
   END UNIT_PRICE_29;
   FUNCTION VALUE_6(
      P_KEY IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_TRANS_INVENTORY_BALANCE.VALUE_6      (
         P_KEY );
         RETURN ret_value;
   END VALUE_6;
   FUNCTION COST_2(
      P_KEY IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_TRANS_INVENTORY_BALANCE.COST_2      (
         P_KEY );
         RETURN ret_value;
   END COST_2;
   FUNCTION COST_26(
      P_KEY IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_TRANS_INVENTORY_BALANCE.COST_26      (
         P_KEY );
         RETURN ret_value;
   END COST_26;
   FUNCTION COST_28(
      P_KEY IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_TRANS_INVENTORY_BALANCE.COST_28      (
         P_KEY );
         RETURN ret_value;
   END COST_28;
   FUNCTION COST_4(
      P_KEY IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_TRANS_INVENTORY_BALANCE.COST_4      (
         P_KEY );
         RETURN ret_value;
   END COST_4;
   FUNCTION DATE_2(
      P_KEY IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_TRANS_INVENTORY_BALANCE.DATE_2      (
         P_KEY );
         RETURN ret_value;
   END DATE_2;
   FUNCTION MAX_IND(
      P_KEY IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_TRANS_INVENTORY_BALANCE.MAX_IND      (
         P_KEY );
         RETURN ret_value;
   END MAX_IND;
   FUNCTION PP_CALC_NO(
      P_KEY IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_TRANS_INVENTORY_BALANCE.PP_CALC_NO      (
         P_KEY );
         RETURN ret_value;
   END PP_CALC_NO;
   FUNCTION PREV_DAYTIME(
      P_KEY IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_TRANS_INVENTORY_BALANCE.PREV_DAYTIME      (
         P_KEY,
         P_NUM_ROWS );
         RETURN ret_value;
   END PREV_DAYTIME;
   FUNCTION QTY_2(
      P_KEY IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_TRANS_INVENTORY_BALANCE.QTY_2      (
         P_KEY );
         RETURN ret_value;
   END QTY_2;
   FUNCTION QTY_3(
      P_KEY IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_TRANS_INVENTORY_BALANCE.QTY_3      (
         P_KEY );
         RETURN ret_value;
   END QTY_3;
   FUNCTION QTY_6(
      P_KEY IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_TRANS_INVENTORY_BALANCE.QTY_6      (
         P_KEY );
         RETURN ret_value;
   END QTY_6;
   FUNCTION RECORD_STATUS(
      P_KEY IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_TRANS_INVENTORY_BALANCE.RECORD_STATUS      (
         P_KEY );
         RETURN ret_value;
   END RECORD_STATUS;
   FUNCTION REF_OBJECT_ID_5(
      P_KEY IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_TRANS_INVENTORY_BALANCE.REF_OBJECT_ID_5      (
         P_KEY );
         RETURN ret_value;
   END REF_OBJECT_ID_5;
   FUNCTION UNIT_PRICE_3(
      P_KEY IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_TRANS_INVENTORY_BALANCE.UNIT_PRICE_3      (
         P_KEY );
         RETURN ret_value;
   END UNIT_PRICE_3;
   FUNCTION VALUE_1(
      P_KEY IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_TRANS_INVENTORY_BALANCE.VALUE_1      (
         P_KEY );
         RETURN ret_value;
   END VALUE_1;
   FUNCTION APPROVAL_DATE(
      P_KEY IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_TRANS_INVENTORY_BALANCE.APPROVAL_DATE      (
         P_KEY );
         RETURN ret_value;
   END APPROVAL_DATE;
   FUNCTION CALC_RUN_NO(
      P_KEY IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_TRANS_INVENTORY_BALANCE.CALC_RUN_NO      (
         P_KEY );
         RETURN ret_value;
   END CALC_RUN_NO;
   FUNCTION COST_16(
      P_KEY IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_TRANS_INVENTORY_BALANCE.COST_16      (
         P_KEY );
         RETURN ret_value;
   END COST_16;
   FUNCTION COST_18(
      P_KEY IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_TRANS_INVENTORY_BALANCE.COST_18      (
         P_KEY );
         RETURN ret_value;
   END COST_18;
   FUNCTION COST_9(
      P_KEY IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_TRANS_INVENTORY_BALANCE.COST_9      (
         P_KEY );
         RETURN ret_value;
   END COST_9;
   FUNCTION DATE_6(
      P_KEY IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_TRANS_INVENTORY_BALANCE.DATE_6      (
         P_KEY );
         RETURN ret_value;
   END DATE_6;
   FUNCTION PROD_STREAM_ID(
      P_KEY IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_TRANS_INVENTORY_BALANCE.PROD_STREAM_ID      (
         P_KEY );
         RETURN ret_value;
   END PROD_STREAM_ID;
   FUNCTION REF_OBJECT_ID_1(
      P_KEY IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_TRANS_INVENTORY_BALANCE.REF_OBJECT_ID_1      (
         P_KEY );
         RETURN ret_value;
   END REF_OBJECT_ID_1;
   FUNCTION ROW_BY_PK(
      P_KEY IN NUMBER)
      RETURN REC_ROW_BY_PK
   IS
      ret_value    REC_ROW_BY_PK ;
   BEGIN
      ret_value := EC_TRANS_INVENTORY_BALANCE.ROW_BY_PK      (
         P_KEY );
         RETURN ret_value;
   END ROW_BY_PK;
   FUNCTION TEXT_2(
      P_KEY IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_TRANS_INVENTORY_BALANCE.TEXT_2      (
         P_KEY );
         RETURN ret_value;
   END TEXT_2;
   FUNCTION TEXT_4(
      P_KEY IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_TRANS_INVENTORY_BALANCE.TEXT_4      (
         P_KEY );
         RETURN ret_value;
   END TEXT_4;
   FUNCTION TEXT_5(
      P_KEY IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_TRANS_INVENTORY_BALANCE.TEXT_5      (
         P_KEY );
         RETURN ret_value;
   END TEXT_5;
   FUNCTION UNIT_PRICE_5(
      P_KEY IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_TRANS_INVENTORY_BALANCE.UNIT_PRICE_5      (
         P_KEY );
         RETURN ret_value;
   END UNIT_PRICE_5;
   FUNCTION UNIT_PRICE_8(
      P_KEY IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_TRANS_INVENTORY_BALANCE.UNIT_PRICE_8      (
         P_KEY );
         RETURN ret_value;
   END UNIT_PRICE_8;
   FUNCTION VALUE_2(
      P_KEY IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_TRANS_INVENTORY_BALANCE.VALUE_2      (
         P_KEY );
         RETURN ret_value;
   END VALUE_2;
   FUNCTION VALUE_3(
      P_KEY IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_TRANS_INVENTORY_BALANCE.VALUE_3      (
         P_KEY );
         RETURN ret_value;
   END VALUE_3;
   FUNCTION VALUE_4(
      P_KEY IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_TRANS_INVENTORY_BALANCE.VALUE_4      (
         P_KEY );
         RETURN ret_value;
   END VALUE_4;
   FUNCTION COST_15(
      P_KEY IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_TRANS_INVENTORY_BALANCE.COST_15      (
         P_KEY );
         RETURN ret_value;
   END COST_15;
   FUNCTION DATE_4(
      P_KEY IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_TRANS_INVENTORY_BALANCE.DATE_4      (
         P_KEY );
         RETURN ret_value;
   END DATE_4;
   FUNCTION DIMENSION_TAG(
      P_KEY IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (100) ;
   BEGIN
      ret_value := EC_TRANS_INVENTORY_BALANCE.DIMENSION_TAG      (
         P_KEY );
         RETURN ret_value;
   END DIMENSION_TAG;
   FUNCTION QTY_9(
      P_KEY IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_TRANS_INVENTORY_BALANCE.QTY_9      (
         P_KEY );
         RETURN ret_value;
   END QTY_9;
   FUNCTION REC_ID(
      P_KEY IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_TRANS_INVENTORY_BALANCE.REC_ID      (
         P_KEY );
         RETURN ret_value;
   END REC_ID;
   FUNCTION UNIT_PRICE_2(
      P_KEY IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_TRANS_INVENTORY_BALANCE.UNIT_PRICE_2      (
         P_KEY );
         RETURN ret_value;
   END UNIT_PRICE_2;
   FUNCTION UNIT_PRICE_21(
      P_KEY IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_TRANS_INVENTORY_BALANCE.UNIT_PRICE_21      (
         P_KEY );
         RETURN ret_value;
   END UNIT_PRICE_21;
   FUNCTION UNIT_PRICE_4(
      P_KEY IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_TRANS_INVENTORY_BALANCE.UNIT_PRICE_4      (
         P_KEY );
         RETURN ret_value;
   END UNIT_PRICE_4;
   FUNCTION VALUE_7(
      P_KEY IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_TRANS_INVENTORY_BALANCE.VALUE_7      (
         P_KEY );
         RETURN ret_value;
   END VALUE_7;
   FUNCTION VALUE_9(
      P_KEY IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_TRANS_INVENTORY_BALANCE.VALUE_9      (
         P_KEY );
         RETURN ret_value;
   END VALUE_9;
   FUNCTION COST_24(
      P_KEY IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_TRANS_INVENTORY_BALANCE.COST_24      (
         P_KEY );
         RETURN ret_value;
   END COST_24;
   FUNCTION COST_3(
      P_KEY IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_TRANS_INVENTORY_BALANCE.COST_3      (
         P_KEY );
         RETURN ret_value;
   END COST_3;
   FUNCTION COST_6(
      P_KEY IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_TRANS_INVENTORY_BALANCE.COST_6      (
         P_KEY );
         RETURN ret_value;
   END COST_6;
   FUNCTION COST_8(
      P_KEY IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_TRANS_INVENTORY_BALANCE.COST_8      (
         P_KEY );
         RETURN ret_value;
   END COST_8;
   FUNCTION DATE_1(
      P_KEY IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_TRANS_INVENTORY_BALANCE.DATE_1      (
         P_KEY );
         RETURN ret_value;
   END DATE_1;
   FUNCTION DATE_8(
      P_KEY IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_TRANS_INVENTORY_BALANCE.DATE_8      (
         P_KEY );
         RETURN ret_value;
   END DATE_8;
   FUNCTION DAYTIME(
      P_KEY IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_TRANS_INVENTORY_BALANCE.DAYTIME      (
         P_KEY );
         RETURN ret_value;
   END DAYTIME;
   FUNCTION LAYER_MONTH(
      P_KEY IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_TRANS_INVENTORY_BALANCE.LAYER_MONTH      (
         P_KEY );
         RETURN ret_value;
   END LAYER_MONTH;
   FUNCTION QTY_10(
      P_KEY IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_TRANS_INVENTORY_BALANCE.QTY_10      (
         P_KEY );
         RETURN ret_value;
   END QTY_10;
   FUNCTION QTY_5(
      P_KEY IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_TRANS_INVENTORY_BALANCE.QTY_5      (
         P_KEY );
         RETURN ret_value;
   END QTY_5;
   FUNCTION TEXT_10(
      P_KEY IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_TRANS_INVENTORY_BALANCE.TEXT_10      (
         P_KEY );
         RETURN ret_value;
   END TEXT_10;
   FUNCTION UNIT_PRICE_25(
      P_KEY IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_TRANS_INVENTORY_BALANCE.UNIT_PRICE_25      (
         P_KEY );
         RETURN ret_value;
   END UNIT_PRICE_25;
   FUNCTION UNIT_PRICE_30(
      P_KEY IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_TRANS_INVENTORY_BALANCE.UNIT_PRICE_30      (
         P_KEY );
         RETURN ret_value;
   END UNIT_PRICE_30;
   FUNCTION UNIT_PRICE_7(
      P_KEY IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_TRANS_INVENTORY_BALANCE.UNIT_PRICE_7      (
         P_KEY );
         RETURN ret_value;
   END UNIT_PRICE_7;
   FUNCTION VALUE_10(
      P_KEY IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_TRANS_INVENTORY_BALANCE.VALUE_10      (
         P_KEY );
         RETURN ret_value;
   END VALUE_10;
   FUNCTION VALUE_8(
      P_KEY IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_TRANS_INVENTORY_BALANCE.VALUE_8      (
         P_KEY );
         RETURN ret_value;
   END VALUE_8;

END RP_TRANS_INVENTORY_BALANCE;

/
--GRANT EXECUTE ON ECKERNEL_WST.RP_TRANS_INVENTORY_BALANCE TO REPORT_ROLE_XXX;



 -- FINISH PKG_GEN_PKGS.sf_get_functions at:05/07/2019 05.34.52 AM


