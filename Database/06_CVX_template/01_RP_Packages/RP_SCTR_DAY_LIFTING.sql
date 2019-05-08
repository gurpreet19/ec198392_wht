
 -- START PKG_GEN_PKGS.sf_get_functions at:05/07/2019 07.39.14 AM


CREATE or REPLACE PACKAGE RP_SCTR_DAY_LIFTING
IS

   FUNCTION TEXT_3(
      P_SEQ_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_16(
      P_SEQ_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_18(
      P_SEQ_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_21(
      P_SEQ_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_27(
      P_SEQ_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_30(
      P_SEQ_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION APPROVAL_BY(
      P_SEQ_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_STATE(
      P_SEQ_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION CARRIER_ID(
      P_SEQ_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_23(
      P_SEQ_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_28(
      P_SEQ_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_5(
      P_SEQ_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION NEXT_DAYTIME(
      P_SEQ_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION OBJECT_ID(
      P_SEQ_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION PREV_EQUAL_DAYTIME(
      P_SEQ_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION PRODUCT_ID(
      P_SEQ_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_7(
      P_SEQ_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_8(
      P_SEQ_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_29(
      P_SEQ_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION DATE_3(
      P_SEQ_NO IN NUMBER)
      RETURN DATE;
   FUNCTION DATE_5(
      P_SEQ_NO IN NUMBER)
      RETURN DATE;
   FUNCTION NEXT_EQUAL_DAYTIME(
      P_SEQ_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION TEXT_1(
      P_SEQ_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_14(
      P_SEQ_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_6(
      P_SEQ_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_9(
      P_SEQ_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_12(
      P_SEQ_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_22(
      P_SEQ_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_26(
      P_SEQ_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_6(
      P_SEQ_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION CARGO_NO(
      P_SEQ_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION COMPANY_ID(
      P_SEQ_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION DATE_2(
      P_SEQ_NO IN NUMBER)
      RETURN DATE;
   FUNCTION PREV_DAYTIME(
      P_SEQ_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION RECORD_STATUS(
      P_SEQ_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_1(
      P_SEQ_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_15(
      P_SEQ_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_19(
      P_SEQ_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION APPROVAL_DATE(
      P_SEQ_NO IN NUMBER)
      RETURN DATE;
   FUNCTION CARGO_STATUS(
      P_SEQ_NO IN NUMBER)
      RETURN VARCHAR2;
      TYPE REC_ROW_BY_PK IS RECORD (
         SEQ_NO NUMBER ,
         OBJECT_ID VARCHAR2 (32) ,
         DAYTIME  DATE ,
         PRODUCT_ID VARCHAR2 (32) ,
         COMPANY_ID VARCHAR2 (32) ,
         CARGO_NO NUMBER ,
         CARGO_STATUS VARCHAR2 (32) ,
         CARRIER_ID VARCHAR2 (32) ,
         LIFTING_QTY NUMBER ,
         LIFTING_PRICE NUMBER ,
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
         APPROVAL_STATE VARCHAR2 (1) ,
         APPROVAL_BY VARCHAR2 (30) ,
         APPROVAL_DATE  DATE ,
         REC_ID VARCHAR2 (32)  );
   FUNCTION ROW_BY_PK(
      P_SEQ_NO IN NUMBER)
      RETURN REC_ROW_BY_PK;
   FUNCTION TEXT_13(
      P_SEQ_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_2(
      P_SEQ_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_4(
      P_SEQ_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_5(
      P_SEQ_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_13(
      P_SEQ_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_17(
      P_SEQ_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_2(
      P_SEQ_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_20(
      P_SEQ_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_25(
      P_SEQ_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_3(
      P_SEQ_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_4(
      P_SEQ_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION DATE_4(
      P_SEQ_NO IN NUMBER)
      RETURN DATE;
   FUNCTION REC_ID(
      P_SEQ_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_7(
      P_SEQ_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_9(
      P_SEQ_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION DATE_1(
      P_SEQ_NO IN NUMBER)
      RETURN DATE;
   FUNCTION DAYTIME(
      P_SEQ_NO IN NUMBER)
      RETURN DATE;
   FUNCTION LIFTING_PRICE(
      P_SEQ_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION LIFTING_QTY(
      P_SEQ_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION TEXT_10(
      P_SEQ_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_11(
      P_SEQ_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_12(
      P_SEQ_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_15(
      P_SEQ_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_10(
      P_SEQ_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_11(
      P_SEQ_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_14(
      P_SEQ_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_24(
      P_SEQ_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_8(
      P_SEQ_NO IN NUMBER)
      RETURN NUMBER;

END RP_SCTR_DAY_LIFTING;

/



CREATE or REPLACE PACKAGE BODY RP_SCTR_DAY_LIFTING
IS

   FUNCTION TEXT_3(
      P_SEQ_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_SCTR_DAY_LIFTING.TEXT_3      (
         P_SEQ_NO );
         RETURN ret_value;
   END TEXT_3;
   FUNCTION VALUE_16(
      P_SEQ_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_SCTR_DAY_LIFTING.VALUE_16      (
         P_SEQ_NO );
         RETURN ret_value;
   END VALUE_16;
   FUNCTION VALUE_18(
      P_SEQ_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_SCTR_DAY_LIFTING.VALUE_18      (
         P_SEQ_NO );
         RETURN ret_value;
   END VALUE_18;
   FUNCTION VALUE_21(
      P_SEQ_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_SCTR_DAY_LIFTING.VALUE_21      (
         P_SEQ_NO );
         RETURN ret_value;
   END VALUE_21;
   FUNCTION VALUE_27(
      P_SEQ_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_SCTR_DAY_LIFTING.VALUE_27      (
         P_SEQ_NO );
         RETURN ret_value;
   END VALUE_27;
   FUNCTION VALUE_30(
      P_SEQ_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_SCTR_DAY_LIFTING.VALUE_30      (
         P_SEQ_NO );
         RETURN ret_value;
   END VALUE_30;
   FUNCTION APPROVAL_BY(
      P_SEQ_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (30) ;
   BEGIN
      ret_value := EC_SCTR_DAY_LIFTING.APPROVAL_BY      (
         P_SEQ_NO );
         RETURN ret_value;
   END APPROVAL_BY;
   FUNCTION APPROVAL_STATE(
      P_SEQ_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_SCTR_DAY_LIFTING.APPROVAL_STATE      (
         P_SEQ_NO );
         RETURN ret_value;
   END APPROVAL_STATE;
   FUNCTION CARRIER_ID(
      P_SEQ_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_SCTR_DAY_LIFTING.CARRIER_ID      (
         P_SEQ_NO );
         RETURN ret_value;
   END CARRIER_ID;
   FUNCTION VALUE_23(
      P_SEQ_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_SCTR_DAY_LIFTING.VALUE_23      (
         P_SEQ_NO );
         RETURN ret_value;
   END VALUE_23;
   FUNCTION VALUE_28(
      P_SEQ_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_SCTR_DAY_LIFTING.VALUE_28      (
         P_SEQ_NO );
         RETURN ret_value;
   END VALUE_28;
   FUNCTION VALUE_5(
      P_SEQ_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_SCTR_DAY_LIFTING.VALUE_5      (
         P_SEQ_NO );
         RETURN ret_value;
   END VALUE_5;
   FUNCTION NEXT_DAYTIME(
      P_SEQ_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_SCTR_DAY_LIFTING.NEXT_DAYTIME      (
         P_SEQ_NO,
         P_NUM_ROWS );
         RETURN ret_value;
   END NEXT_DAYTIME;
   FUNCTION OBJECT_ID(
      P_SEQ_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_SCTR_DAY_LIFTING.OBJECT_ID      (
         P_SEQ_NO );
         RETURN ret_value;
   END OBJECT_ID;
   FUNCTION PREV_EQUAL_DAYTIME(
      P_SEQ_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_SCTR_DAY_LIFTING.PREV_EQUAL_DAYTIME      (
         P_SEQ_NO,
         P_NUM_ROWS );
         RETURN ret_value;
   END PREV_EQUAL_DAYTIME;
   FUNCTION PRODUCT_ID(
      P_SEQ_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_SCTR_DAY_LIFTING.PRODUCT_ID      (
         P_SEQ_NO );
         RETURN ret_value;
   END PRODUCT_ID;
   FUNCTION TEXT_7(
      P_SEQ_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_SCTR_DAY_LIFTING.TEXT_7      (
         P_SEQ_NO );
         RETURN ret_value;
   END TEXT_7;
   FUNCTION TEXT_8(
      P_SEQ_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_SCTR_DAY_LIFTING.TEXT_8      (
         P_SEQ_NO );
         RETURN ret_value;
   END TEXT_8;
   FUNCTION VALUE_29(
      P_SEQ_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_SCTR_DAY_LIFTING.VALUE_29      (
         P_SEQ_NO );
         RETURN ret_value;
   END VALUE_29;
   FUNCTION DATE_3(
      P_SEQ_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_SCTR_DAY_LIFTING.DATE_3      (
         P_SEQ_NO );
         RETURN ret_value;
   END DATE_3;
   FUNCTION DATE_5(
      P_SEQ_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_SCTR_DAY_LIFTING.DATE_5      (
         P_SEQ_NO );
         RETURN ret_value;
   END DATE_5;
   FUNCTION NEXT_EQUAL_DAYTIME(
      P_SEQ_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_SCTR_DAY_LIFTING.NEXT_EQUAL_DAYTIME      (
         P_SEQ_NO,
         P_NUM_ROWS );
         RETURN ret_value;
   END NEXT_EQUAL_DAYTIME;
   FUNCTION TEXT_1(
      P_SEQ_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_SCTR_DAY_LIFTING.TEXT_1      (
         P_SEQ_NO );
         RETURN ret_value;
   END TEXT_1;
   FUNCTION TEXT_14(
      P_SEQ_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_SCTR_DAY_LIFTING.TEXT_14      (
         P_SEQ_NO );
         RETURN ret_value;
   END TEXT_14;
   FUNCTION TEXT_6(
      P_SEQ_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_SCTR_DAY_LIFTING.TEXT_6      (
         P_SEQ_NO );
         RETURN ret_value;
   END TEXT_6;
   FUNCTION TEXT_9(
      P_SEQ_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_SCTR_DAY_LIFTING.TEXT_9      (
         P_SEQ_NO );
         RETURN ret_value;
   END TEXT_9;
   FUNCTION VALUE_12(
      P_SEQ_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_SCTR_DAY_LIFTING.VALUE_12      (
         P_SEQ_NO );
         RETURN ret_value;
   END VALUE_12;
   FUNCTION VALUE_22(
      P_SEQ_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_SCTR_DAY_LIFTING.VALUE_22      (
         P_SEQ_NO );
         RETURN ret_value;
   END VALUE_22;
   FUNCTION VALUE_26(
      P_SEQ_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_SCTR_DAY_LIFTING.VALUE_26      (
         P_SEQ_NO );
         RETURN ret_value;
   END VALUE_26;
   FUNCTION VALUE_6(
      P_SEQ_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_SCTR_DAY_LIFTING.VALUE_6      (
         P_SEQ_NO );
         RETURN ret_value;
   END VALUE_6;
   FUNCTION CARGO_NO(
      P_SEQ_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_SCTR_DAY_LIFTING.CARGO_NO      (
         P_SEQ_NO );
         RETURN ret_value;
   END CARGO_NO;
   FUNCTION COMPANY_ID(
      P_SEQ_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_SCTR_DAY_LIFTING.COMPANY_ID      (
         P_SEQ_NO );
         RETURN ret_value;
   END COMPANY_ID;
   FUNCTION DATE_2(
      P_SEQ_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_SCTR_DAY_LIFTING.DATE_2      (
         P_SEQ_NO );
         RETURN ret_value;
   END DATE_2;
   FUNCTION PREV_DAYTIME(
      P_SEQ_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_SCTR_DAY_LIFTING.PREV_DAYTIME      (
         P_SEQ_NO,
         P_NUM_ROWS );
         RETURN ret_value;
   END PREV_DAYTIME;
   FUNCTION RECORD_STATUS(
      P_SEQ_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_SCTR_DAY_LIFTING.RECORD_STATUS      (
         P_SEQ_NO );
         RETURN ret_value;
   END RECORD_STATUS;
   FUNCTION VALUE_1(
      P_SEQ_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_SCTR_DAY_LIFTING.VALUE_1      (
         P_SEQ_NO );
         RETURN ret_value;
   END VALUE_1;
   FUNCTION VALUE_15(
      P_SEQ_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_SCTR_DAY_LIFTING.VALUE_15      (
         P_SEQ_NO );
         RETURN ret_value;
   END VALUE_15;
   FUNCTION VALUE_19(
      P_SEQ_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_SCTR_DAY_LIFTING.VALUE_19      (
         P_SEQ_NO );
         RETURN ret_value;
   END VALUE_19;
   FUNCTION APPROVAL_DATE(
      P_SEQ_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_SCTR_DAY_LIFTING.APPROVAL_DATE      (
         P_SEQ_NO );
         RETURN ret_value;
   END APPROVAL_DATE;
   FUNCTION CARGO_STATUS(
      P_SEQ_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_SCTR_DAY_LIFTING.CARGO_STATUS      (
         P_SEQ_NO );
         RETURN ret_value;
   END CARGO_STATUS;
   FUNCTION ROW_BY_PK(
      P_SEQ_NO IN NUMBER)
      RETURN REC_ROW_BY_PK
   IS
      ret_value    REC_ROW_BY_PK ;
   BEGIN
      ret_value := EC_SCTR_DAY_LIFTING.ROW_BY_PK      (
         P_SEQ_NO );
         RETURN ret_value;
   END ROW_BY_PK;
   FUNCTION TEXT_13(
      P_SEQ_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_SCTR_DAY_LIFTING.TEXT_13      (
         P_SEQ_NO );
         RETURN ret_value;
   END TEXT_13;
   FUNCTION TEXT_2(
      P_SEQ_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_SCTR_DAY_LIFTING.TEXT_2      (
         P_SEQ_NO );
         RETURN ret_value;
   END TEXT_2;
   FUNCTION TEXT_4(
      P_SEQ_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_SCTR_DAY_LIFTING.TEXT_4      (
         P_SEQ_NO );
         RETURN ret_value;
   END TEXT_4;
   FUNCTION TEXT_5(
      P_SEQ_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_SCTR_DAY_LIFTING.TEXT_5      (
         P_SEQ_NO );
         RETURN ret_value;
   END TEXT_5;
   FUNCTION VALUE_13(
      P_SEQ_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_SCTR_DAY_LIFTING.VALUE_13      (
         P_SEQ_NO );
         RETURN ret_value;
   END VALUE_13;
   FUNCTION VALUE_17(
      P_SEQ_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_SCTR_DAY_LIFTING.VALUE_17      (
         P_SEQ_NO );
         RETURN ret_value;
   END VALUE_17;
   FUNCTION VALUE_2(
      P_SEQ_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_SCTR_DAY_LIFTING.VALUE_2      (
         P_SEQ_NO );
         RETURN ret_value;
   END VALUE_2;
   FUNCTION VALUE_20(
      P_SEQ_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_SCTR_DAY_LIFTING.VALUE_20      (
         P_SEQ_NO );
         RETURN ret_value;
   END VALUE_20;
   FUNCTION VALUE_25(
      P_SEQ_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_SCTR_DAY_LIFTING.VALUE_25      (
         P_SEQ_NO );
         RETURN ret_value;
   END VALUE_25;
   FUNCTION VALUE_3(
      P_SEQ_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_SCTR_DAY_LIFTING.VALUE_3      (
         P_SEQ_NO );
         RETURN ret_value;
   END VALUE_3;
   FUNCTION VALUE_4(
      P_SEQ_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_SCTR_DAY_LIFTING.VALUE_4      (
         P_SEQ_NO );
         RETURN ret_value;
   END VALUE_4;
   FUNCTION DATE_4(
      P_SEQ_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_SCTR_DAY_LIFTING.DATE_4      (
         P_SEQ_NO );
         RETURN ret_value;
   END DATE_4;
   FUNCTION REC_ID(
      P_SEQ_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_SCTR_DAY_LIFTING.REC_ID      (
         P_SEQ_NO );
         RETURN ret_value;
   END REC_ID;
   FUNCTION VALUE_7(
      P_SEQ_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_SCTR_DAY_LIFTING.VALUE_7      (
         P_SEQ_NO );
         RETURN ret_value;
   END VALUE_7;
   FUNCTION VALUE_9(
      P_SEQ_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_SCTR_DAY_LIFTING.VALUE_9      (
         P_SEQ_NO );
         RETURN ret_value;
   END VALUE_9;
   FUNCTION DATE_1(
      P_SEQ_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_SCTR_DAY_LIFTING.DATE_1      (
         P_SEQ_NO );
         RETURN ret_value;
   END DATE_1;
   FUNCTION DAYTIME(
      P_SEQ_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_SCTR_DAY_LIFTING.DAYTIME      (
         P_SEQ_NO );
         RETURN ret_value;
   END DAYTIME;
   FUNCTION LIFTING_PRICE(
      P_SEQ_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_SCTR_DAY_LIFTING.LIFTING_PRICE      (
         P_SEQ_NO );
         RETURN ret_value;
   END LIFTING_PRICE;
   FUNCTION LIFTING_QTY(
      P_SEQ_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_SCTR_DAY_LIFTING.LIFTING_QTY      (
         P_SEQ_NO );
         RETURN ret_value;
   END LIFTING_QTY;
   FUNCTION TEXT_10(
      P_SEQ_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_SCTR_DAY_LIFTING.TEXT_10      (
         P_SEQ_NO );
         RETURN ret_value;
   END TEXT_10;
   FUNCTION TEXT_11(
      P_SEQ_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_SCTR_DAY_LIFTING.TEXT_11      (
         P_SEQ_NO );
         RETURN ret_value;
   END TEXT_11;
   FUNCTION TEXT_12(
      P_SEQ_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_SCTR_DAY_LIFTING.TEXT_12      (
         P_SEQ_NO );
         RETURN ret_value;
   END TEXT_12;
   FUNCTION TEXT_15(
      P_SEQ_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_SCTR_DAY_LIFTING.TEXT_15      (
         P_SEQ_NO );
         RETURN ret_value;
   END TEXT_15;
   FUNCTION VALUE_10(
      P_SEQ_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_SCTR_DAY_LIFTING.VALUE_10      (
         P_SEQ_NO );
         RETURN ret_value;
   END VALUE_10;
   FUNCTION VALUE_11(
      P_SEQ_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_SCTR_DAY_LIFTING.VALUE_11      (
         P_SEQ_NO );
         RETURN ret_value;
   END VALUE_11;
   FUNCTION VALUE_14(
      P_SEQ_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_SCTR_DAY_LIFTING.VALUE_14      (
         P_SEQ_NO );
         RETURN ret_value;
   END VALUE_14;
   FUNCTION VALUE_24(
      P_SEQ_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_SCTR_DAY_LIFTING.VALUE_24      (
         P_SEQ_NO );
         RETURN ret_value;
   END VALUE_24;
   FUNCTION VALUE_8(
      P_SEQ_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_SCTR_DAY_LIFTING.VALUE_8      (
         P_SEQ_NO );
         RETURN ret_value;
   END VALUE_8;

END RP_SCTR_DAY_LIFTING;

/
--GRANT EXECUTE ON ECKERNEL_WST.RP_SCTR_DAY_LIFTING TO REPORT_ROLE_XXX;



 -- FINISH PKG_GEN_PKGS.sf_get_functions at:05/07/2019 07.39.37 AM


