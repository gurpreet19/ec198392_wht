
 -- START PKG_GEN_PKGS.sf_get_functions at:05/07/2019 08.39.38 AM


CREATE or REPLACE PACKAGE RP_OBJLOC_DAY_NP_NOM
IS

   FUNCTION NOM_STATUS(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION REF_NOMINATION_SEQ(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN NUMBER;
   FUNCTION TEXT_3(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_16(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_18(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_21(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_27(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_30(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN NUMBER;
   FUNCTION APPROVAL_BY(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_STATE(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION CONFIRMED_OUT_QTY(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_23(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_28(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_5(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN NUMBER;
   FUNCTION ACCEPTED_IN_QTY(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN NUMBER;
   FUNCTION NEXT_DAYTIME(
      P_NOMINATION_SEQ IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION NOMPNT_ID(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN VARCHAR2;
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
   FUNCTION VALUE_29(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN NUMBER;
   FUNCTION ACCEPTED_OUT_QTY(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN NUMBER;
   FUNCTION CONFIRMED_IN_QTY(
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
   FUNCTION SCHEDULED_IN_QTY(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN NUMBER;
   FUNCTION TEXT_1(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_14(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_6(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_9(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_12(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_22(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_26(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_6(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN NUMBER;
   FUNCTION DATE_2(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN DATE;
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
   FUNCTION APPROVAL_DATE(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN DATE;
   FUNCTION REQUESTED_IN_QTY(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN NUMBER;
   FUNCTION ROUTE_ORDER(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN NUMBER;
      TYPE REC_ROW_BY_PK IS RECORD (
         OBJECT_ID VARCHAR2 (32) ,
         DAYTIME  DATE ,
         CLASS_NAME VARCHAR2 (32) ,
         REQUESTED_IN_QTY NUMBER ,
         REQUESTED_OUT_QTY NUMBER ,
         ACCEPTED_IN_QTY NUMBER ,
         ACCEPTED_OUT_QTY NUMBER ,
         ADJUSTED_IN_QTY NUMBER ,
         ADJUSTED_OUT_QTY NUMBER ,
         CONFIRMED_IN_QTY NUMBER ,
         CONFIRMED_OUT_QTY NUMBER ,
         SCHEDULED_IN_QTY NUMBER ,
         SCHEDULED_OUT_QTY NUMBER ,
         ROUTE_ORDER NUMBER ,
         NOMINATION_SEQ NUMBER ,
         REF_NOMINATION_SEQ NUMBER ,
         NOMPNT_ID VARCHAR2 (32) ,
         TO_NOMPNT_ID VARCHAR2 (32) ,
         NOMINATION_TYPE VARCHAR2 (32) ,
         NOM_CYCLE_CODE VARCHAR2 (32) ,
         NOM_STATUS VARCHAR2 (32) ,
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
      P_NOMINATION_SEQ IN NUMBER)
      RETURN REC_ROW_BY_PK;
   FUNCTION SCHEDULED_OUT_QTY(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN NUMBER;
   FUNCTION TEXT_13(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN VARCHAR2;
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
   FUNCTION VALUE_25(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_3(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_4(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN NUMBER;
   FUNCTION ADJUSTED_IN_QTY(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN NUMBER;
   FUNCTION CLASS_NAME(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN VARCHAR2;
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
   FUNCTION ADJUSTED_OUT_QTY(
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
   FUNCTION REQUESTED_OUT_QTY(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN NUMBER;
   FUNCTION TEXT_10(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_11(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_12(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_15(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TO_NOMPNT_ID(
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
   FUNCTION VALUE_24(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_8(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN NUMBER;

END RP_OBJLOC_DAY_NP_NOM;

/



CREATE or REPLACE PACKAGE BODY RP_OBJLOC_DAY_NP_NOM
IS

   FUNCTION NOM_STATUS(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_OBJLOC_DAY_NP_NOM.NOM_STATUS      (
         P_NOMINATION_SEQ );
         RETURN ret_value;
   END NOM_STATUS;
   FUNCTION REF_NOMINATION_SEQ(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_OBJLOC_DAY_NP_NOM.REF_NOMINATION_SEQ      (
         P_NOMINATION_SEQ );
         RETURN ret_value;
   END REF_NOMINATION_SEQ;
   FUNCTION TEXT_3(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_OBJLOC_DAY_NP_NOM.TEXT_3      (
         P_NOMINATION_SEQ );
         RETURN ret_value;
   END TEXT_3;
   FUNCTION VALUE_16(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_OBJLOC_DAY_NP_NOM.VALUE_16      (
         P_NOMINATION_SEQ );
         RETURN ret_value;
   END VALUE_16;
   FUNCTION VALUE_18(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_OBJLOC_DAY_NP_NOM.VALUE_18      (
         P_NOMINATION_SEQ );
         RETURN ret_value;
   END VALUE_18;
   FUNCTION VALUE_21(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_OBJLOC_DAY_NP_NOM.VALUE_21      (
         P_NOMINATION_SEQ );
         RETURN ret_value;
   END VALUE_21;
   FUNCTION VALUE_27(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_OBJLOC_DAY_NP_NOM.VALUE_27      (
         P_NOMINATION_SEQ );
         RETURN ret_value;
   END VALUE_27;
   FUNCTION VALUE_30(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_OBJLOC_DAY_NP_NOM.VALUE_30      (
         P_NOMINATION_SEQ );
         RETURN ret_value;
   END VALUE_30;
   FUNCTION APPROVAL_BY(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (30) ;
   BEGIN
      ret_value := EC_OBJLOC_DAY_NP_NOM.APPROVAL_BY      (
         P_NOMINATION_SEQ );
         RETURN ret_value;
   END APPROVAL_BY;
   FUNCTION APPROVAL_STATE(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_OBJLOC_DAY_NP_NOM.APPROVAL_STATE      (
         P_NOMINATION_SEQ );
         RETURN ret_value;
   END APPROVAL_STATE;
   FUNCTION CONFIRMED_OUT_QTY(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_OBJLOC_DAY_NP_NOM.CONFIRMED_OUT_QTY      (
         P_NOMINATION_SEQ );
         RETURN ret_value;
   END CONFIRMED_OUT_QTY;
   FUNCTION VALUE_23(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_OBJLOC_DAY_NP_NOM.VALUE_23      (
         P_NOMINATION_SEQ );
         RETURN ret_value;
   END VALUE_23;
   FUNCTION VALUE_28(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_OBJLOC_DAY_NP_NOM.VALUE_28      (
         P_NOMINATION_SEQ );
         RETURN ret_value;
   END VALUE_28;
   FUNCTION VALUE_5(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_OBJLOC_DAY_NP_NOM.VALUE_5      (
         P_NOMINATION_SEQ );
         RETURN ret_value;
   END VALUE_5;
   FUNCTION ACCEPTED_IN_QTY(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_OBJLOC_DAY_NP_NOM.ACCEPTED_IN_QTY      (
         P_NOMINATION_SEQ );
         RETURN ret_value;
   END ACCEPTED_IN_QTY;
   FUNCTION NEXT_DAYTIME(
      P_NOMINATION_SEQ IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_OBJLOC_DAY_NP_NOM.NEXT_DAYTIME      (
         P_NOMINATION_SEQ,
         P_NUM_ROWS );
         RETURN ret_value;
   END NEXT_DAYTIME;
   FUNCTION NOMPNT_ID(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_OBJLOC_DAY_NP_NOM.NOMPNT_ID      (
         P_NOMINATION_SEQ );
         RETURN ret_value;
   END NOMPNT_ID;
   FUNCTION OBJECT_ID(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_OBJLOC_DAY_NP_NOM.OBJECT_ID      (
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
      ret_value := EC_OBJLOC_DAY_NP_NOM.PREV_EQUAL_DAYTIME      (
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
      ret_value := EC_OBJLOC_DAY_NP_NOM.TEXT_7      (
         P_NOMINATION_SEQ );
         RETURN ret_value;
   END TEXT_7;
   FUNCTION TEXT_8(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_OBJLOC_DAY_NP_NOM.TEXT_8      (
         P_NOMINATION_SEQ );
         RETURN ret_value;
   END TEXT_8;
   FUNCTION VALUE_29(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_OBJLOC_DAY_NP_NOM.VALUE_29      (
         P_NOMINATION_SEQ );
         RETURN ret_value;
   END VALUE_29;
   FUNCTION ACCEPTED_OUT_QTY(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_OBJLOC_DAY_NP_NOM.ACCEPTED_OUT_QTY      (
         P_NOMINATION_SEQ );
         RETURN ret_value;
   END ACCEPTED_OUT_QTY;
   FUNCTION CONFIRMED_IN_QTY(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_OBJLOC_DAY_NP_NOM.CONFIRMED_IN_QTY      (
         P_NOMINATION_SEQ );
         RETURN ret_value;
   END CONFIRMED_IN_QTY;
   FUNCTION DATE_3(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_OBJLOC_DAY_NP_NOM.DATE_3      (
         P_NOMINATION_SEQ );
         RETURN ret_value;
   END DATE_3;
   FUNCTION DATE_5(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_OBJLOC_DAY_NP_NOM.DATE_5      (
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
      ret_value := EC_OBJLOC_DAY_NP_NOM.NEXT_EQUAL_DAYTIME      (
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
      ret_value := EC_OBJLOC_DAY_NP_NOM.NOMINATION_TYPE      (
         P_NOMINATION_SEQ );
         RETURN ret_value;
   END NOMINATION_TYPE;
   FUNCTION SCHEDULED_IN_QTY(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_OBJLOC_DAY_NP_NOM.SCHEDULED_IN_QTY      (
         P_NOMINATION_SEQ );
         RETURN ret_value;
   END SCHEDULED_IN_QTY;
   FUNCTION TEXT_1(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_OBJLOC_DAY_NP_NOM.TEXT_1      (
         P_NOMINATION_SEQ );
         RETURN ret_value;
   END TEXT_1;
   FUNCTION TEXT_14(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_OBJLOC_DAY_NP_NOM.TEXT_14      (
         P_NOMINATION_SEQ );
         RETURN ret_value;
   END TEXT_14;
   FUNCTION TEXT_6(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_OBJLOC_DAY_NP_NOM.TEXT_6      (
         P_NOMINATION_SEQ );
         RETURN ret_value;
   END TEXT_6;
   FUNCTION TEXT_9(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_OBJLOC_DAY_NP_NOM.TEXT_9      (
         P_NOMINATION_SEQ );
         RETURN ret_value;
   END TEXT_9;
   FUNCTION VALUE_12(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_OBJLOC_DAY_NP_NOM.VALUE_12      (
         P_NOMINATION_SEQ );
         RETURN ret_value;
   END VALUE_12;
   FUNCTION VALUE_22(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_OBJLOC_DAY_NP_NOM.VALUE_22      (
         P_NOMINATION_SEQ );
         RETURN ret_value;
   END VALUE_22;
   FUNCTION VALUE_26(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_OBJLOC_DAY_NP_NOM.VALUE_26      (
         P_NOMINATION_SEQ );
         RETURN ret_value;
   END VALUE_26;
   FUNCTION VALUE_6(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_OBJLOC_DAY_NP_NOM.VALUE_6      (
         P_NOMINATION_SEQ );
         RETURN ret_value;
   END VALUE_6;
   FUNCTION DATE_2(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_OBJLOC_DAY_NP_NOM.DATE_2      (
         P_NOMINATION_SEQ );
         RETURN ret_value;
   END DATE_2;
   FUNCTION PREV_DAYTIME(
      P_NOMINATION_SEQ IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_OBJLOC_DAY_NP_NOM.PREV_DAYTIME      (
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
      ret_value := EC_OBJLOC_DAY_NP_NOM.RECORD_STATUS      (
         P_NOMINATION_SEQ );
         RETURN ret_value;
   END RECORD_STATUS;
   FUNCTION VALUE_1(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_OBJLOC_DAY_NP_NOM.VALUE_1      (
         P_NOMINATION_SEQ );
         RETURN ret_value;
   END VALUE_1;
   FUNCTION VALUE_15(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_OBJLOC_DAY_NP_NOM.VALUE_15      (
         P_NOMINATION_SEQ );
         RETURN ret_value;
   END VALUE_15;
   FUNCTION VALUE_19(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_OBJLOC_DAY_NP_NOM.VALUE_19      (
         P_NOMINATION_SEQ );
         RETURN ret_value;
   END VALUE_19;
   FUNCTION APPROVAL_DATE(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_OBJLOC_DAY_NP_NOM.APPROVAL_DATE      (
         P_NOMINATION_SEQ );
         RETURN ret_value;
   END APPROVAL_DATE;
   FUNCTION REQUESTED_IN_QTY(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_OBJLOC_DAY_NP_NOM.REQUESTED_IN_QTY      (
         P_NOMINATION_SEQ );
         RETURN ret_value;
   END REQUESTED_IN_QTY;
   FUNCTION ROUTE_ORDER(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_OBJLOC_DAY_NP_NOM.ROUTE_ORDER      (
         P_NOMINATION_SEQ );
         RETURN ret_value;
   END ROUTE_ORDER;
   FUNCTION ROW_BY_PK(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN REC_ROW_BY_PK
   IS
      ret_value    REC_ROW_BY_PK ;
   BEGIN
      ret_value := EC_OBJLOC_DAY_NP_NOM.ROW_BY_PK      (
         P_NOMINATION_SEQ );
         RETURN ret_value;
   END ROW_BY_PK;
   FUNCTION SCHEDULED_OUT_QTY(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_OBJLOC_DAY_NP_NOM.SCHEDULED_OUT_QTY      (
         P_NOMINATION_SEQ );
         RETURN ret_value;
   END SCHEDULED_OUT_QTY;
   FUNCTION TEXT_13(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_OBJLOC_DAY_NP_NOM.TEXT_13      (
         P_NOMINATION_SEQ );
         RETURN ret_value;
   END TEXT_13;
   FUNCTION TEXT_2(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_OBJLOC_DAY_NP_NOM.TEXT_2      (
         P_NOMINATION_SEQ );
         RETURN ret_value;
   END TEXT_2;
   FUNCTION TEXT_4(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_OBJLOC_DAY_NP_NOM.TEXT_4      (
         P_NOMINATION_SEQ );
         RETURN ret_value;
   END TEXT_4;
   FUNCTION TEXT_5(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_OBJLOC_DAY_NP_NOM.TEXT_5      (
         P_NOMINATION_SEQ );
         RETURN ret_value;
   END TEXT_5;
   FUNCTION VALUE_13(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_OBJLOC_DAY_NP_NOM.VALUE_13      (
         P_NOMINATION_SEQ );
         RETURN ret_value;
   END VALUE_13;
   FUNCTION VALUE_17(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_OBJLOC_DAY_NP_NOM.VALUE_17      (
         P_NOMINATION_SEQ );
         RETURN ret_value;
   END VALUE_17;
   FUNCTION VALUE_2(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_OBJLOC_DAY_NP_NOM.VALUE_2      (
         P_NOMINATION_SEQ );
         RETURN ret_value;
   END VALUE_2;
   FUNCTION VALUE_20(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_OBJLOC_DAY_NP_NOM.VALUE_20      (
         P_NOMINATION_SEQ );
         RETURN ret_value;
   END VALUE_20;
   FUNCTION VALUE_25(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_OBJLOC_DAY_NP_NOM.VALUE_25      (
         P_NOMINATION_SEQ );
         RETURN ret_value;
   END VALUE_25;
   FUNCTION VALUE_3(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_OBJLOC_DAY_NP_NOM.VALUE_3      (
         P_NOMINATION_SEQ );
         RETURN ret_value;
   END VALUE_3;
   FUNCTION VALUE_4(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_OBJLOC_DAY_NP_NOM.VALUE_4      (
         P_NOMINATION_SEQ );
         RETURN ret_value;
   END VALUE_4;
   FUNCTION ADJUSTED_IN_QTY(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_OBJLOC_DAY_NP_NOM.ADJUSTED_IN_QTY      (
         P_NOMINATION_SEQ );
         RETURN ret_value;
   END ADJUSTED_IN_QTY;
   FUNCTION CLASS_NAME(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_OBJLOC_DAY_NP_NOM.CLASS_NAME      (
         P_NOMINATION_SEQ );
         RETURN ret_value;
   END CLASS_NAME;
   FUNCTION DATE_4(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_OBJLOC_DAY_NP_NOM.DATE_4      (
         P_NOMINATION_SEQ );
         RETURN ret_value;
   END DATE_4;
   FUNCTION REC_ID(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_OBJLOC_DAY_NP_NOM.REC_ID      (
         P_NOMINATION_SEQ );
         RETURN ret_value;
   END REC_ID;
   FUNCTION VALUE_7(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_OBJLOC_DAY_NP_NOM.VALUE_7      (
         P_NOMINATION_SEQ );
         RETURN ret_value;
   END VALUE_7;
   FUNCTION VALUE_9(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_OBJLOC_DAY_NP_NOM.VALUE_9      (
         P_NOMINATION_SEQ );
         RETURN ret_value;
   END VALUE_9;
   FUNCTION ADJUSTED_OUT_QTY(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_OBJLOC_DAY_NP_NOM.ADJUSTED_OUT_QTY      (
         P_NOMINATION_SEQ );
         RETURN ret_value;
   END ADJUSTED_OUT_QTY;
   FUNCTION DATE_1(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_OBJLOC_DAY_NP_NOM.DATE_1      (
         P_NOMINATION_SEQ );
         RETURN ret_value;
   END DATE_1;
   FUNCTION DAYTIME(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_OBJLOC_DAY_NP_NOM.DAYTIME      (
         P_NOMINATION_SEQ );
         RETURN ret_value;
   END DAYTIME;
   FUNCTION NOM_CYCLE_CODE(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_OBJLOC_DAY_NP_NOM.NOM_CYCLE_CODE      (
         P_NOMINATION_SEQ );
         RETURN ret_value;
   END NOM_CYCLE_CODE;
   FUNCTION REQUESTED_OUT_QTY(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_OBJLOC_DAY_NP_NOM.REQUESTED_OUT_QTY      (
         P_NOMINATION_SEQ );
         RETURN ret_value;
   END REQUESTED_OUT_QTY;
   FUNCTION TEXT_10(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_OBJLOC_DAY_NP_NOM.TEXT_10      (
         P_NOMINATION_SEQ );
         RETURN ret_value;
   END TEXT_10;
   FUNCTION TEXT_11(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_OBJLOC_DAY_NP_NOM.TEXT_11      (
         P_NOMINATION_SEQ );
         RETURN ret_value;
   END TEXT_11;
   FUNCTION TEXT_12(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_OBJLOC_DAY_NP_NOM.TEXT_12      (
         P_NOMINATION_SEQ );
         RETURN ret_value;
   END TEXT_12;
   FUNCTION TEXT_15(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_OBJLOC_DAY_NP_NOM.TEXT_15      (
         P_NOMINATION_SEQ );
         RETURN ret_value;
   END TEXT_15;
   FUNCTION TO_NOMPNT_ID(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_OBJLOC_DAY_NP_NOM.TO_NOMPNT_ID      (
         P_NOMINATION_SEQ );
         RETURN ret_value;
   END TO_NOMPNT_ID;
   FUNCTION VALUE_10(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_OBJLOC_DAY_NP_NOM.VALUE_10      (
         P_NOMINATION_SEQ );
         RETURN ret_value;
   END VALUE_10;
   FUNCTION VALUE_11(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_OBJLOC_DAY_NP_NOM.VALUE_11      (
         P_NOMINATION_SEQ );
         RETURN ret_value;
   END VALUE_11;
   FUNCTION VALUE_14(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_OBJLOC_DAY_NP_NOM.VALUE_14      (
         P_NOMINATION_SEQ );
         RETURN ret_value;
   END VALUE_14;
   FUNCTION VALUE_24(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_OBJLOC_DAY_NP_NOM.VALUE_24      (
         P_NOMINATION_SEQ );
         RETURN ret_value;
   END VALUE_24;
   FUNCTION VALUE_8(
      P_NOMINATION_SEQ IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_OBJLOC_DAY_NP_NOM.VALUE_8      (
         P_NOMINATION_SEQ );
         RETURN ret_value;
   END VALUE_8;

END RP_OBJLOC_DAY_NP_NOM;

/
--GRANT EXECUTE ON ECKERNEL_WST.RP_OBJLOC_DAY_NP_NOM TO REPORT_ROLE_XXX;



 -- FINISH PKG_GEN_PKGS.sf_get_functions at:05/07/2019 08.40.02 AM


