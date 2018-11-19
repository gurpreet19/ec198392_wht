
 -- START PKG_GEN_PKGS.sf_get_functions at:11/15/2018 10.45.39 AM


CREATE or REPLACE PACKAGE RP_CHOKE_MODEL_LIP_YEAR
IS

   FUNCTION EST_PROD_GAIN(
      P_LIP_OPP_ID IN NUMBER,
      P_YEAR IN DATE)
      RETURN NUMBER;
   FUNCTION TEXT_3(
      P_LIP_OPP_ID IN NUMBER,
      P_YEAR IN DATE)
      RETURN VARCHAR2;
   FUNCTION TEXT_4(
      P_LIP_OPP_ID IN NUMBER,
      P_YEAR IN DATE)
      RETURN VARCHAR2;
   FUNCTION VALUE_16(
      P_LIP_OPP_ID IN NUMBER,
      P_YEAR IN DATE)
      RETURN NUMBER;
   FUNCTION VALUE_18(
      P_LIP_OPP_ID IN NUMBER,
      P_YEAR IN DATE)
      RETURN NUMBER;
   FUNCTION VALUE_21(
      P_LIP_OPP_ID IN NUMBER,
      P_YEAR IN DATE)
      RETURN NUMBER;
   FUNCTION VALUE_27(
      P_LIP_OPP_ID IN NUMBER,
      P_YEAR IN DATE)
      RETURN NUMBER;
   FUNCTION VALUE_30(
      P_LIP_OPP_ID IN NUMBER,
      P_YEAR IN DATE)
      RETURN NUMBER;
   FUNCTION VALUE_37(
      P_LIP_OPP_ID IN NUMBER,
      P_YEAR IN DATE)
      RETURN NUMBER;
   FUNCTION VALUE_47(
      P_LIP_OPP_ID IN NUMBER,
      P_YEAR IN DATE)
      RETURN NUMBER;
   FUNCTION VALUE_48(
      P_LIP_OPP_ID IN NUMBER,
      P_YEAR IN DATE)
      RETURN NUMBER;
   FUNCTION APPROVAL_BY(
      P_LIP_OPP_ID IN NUMBER,
      P_YEAR IN DATE)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_STATE(
      P_LIP_OPP_ID IN NUMBER,
      P_YEAR IN DATE)
      RETURN VARCHAR2;
   FUNCTION VALUE_23(
      P_LIP_OPP_ID IN NUMBER,
      P_YEAR IN DATE)
      RETURN NUMBER;
   FUNCTION VALUE_28(
      P_LIP_OPP_ID IN NUMBER,
      P_YEAR IN DATE)
      RETURN NUMBER;
   FUNCTION VALUE_42(
      P_LIP_OPP_ID IN NUMBER,
      P_YEAR IN DATE)
      RETURN NUMBER;
   FUNCTION VALUE_46(
      P_LIP_OPP_ID IN NUMBER,
      P_YEAR IN DATE)
      RETURN NUMBER;
   FUNCTION VALUE_5(
      P_LIP_OPP_ID IN NUMBER,
      P_YEAR IN DATE)
      RETURN NUMBER;
   FUNCTION NEXT_DAYTIME(
      P_LIP_OPP_ID IN NUMBER,
      P_YEAR IN DATE,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION OBJECT_ID(
      P_LIP_OPP_ID IN NUMBER,
      P_YEAR IN DATE)
      RETURN VARCHAR2;
   FUNCTION PREV_EQUAL_DAYTIME(
      P_LIP_OPP_ID IN NUMBER,
      P_YEAR IN DATE,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION TEXT_7(
      P_LIP_OPP_ID IN NUMBER,
      P_YEAR IN DATE)
      RETURN VARCHAR2;
   FUNCTION TEXT_8(
      P_LIP_OPP_ID IN NUMBER,
      P_YEAR IN DATE)
      RETURN VARCHAR2;
   FUNCTION VALUE_29(
      P_LIP_OPP_ID IN NUMBER,
      P_YEAR IN DATE)
      RETURN NUMBER;
   FUNCTION VALUE_31(
      P_LIP_OPP_ID IN NUMBER,
      P_YEAR IN DATE)
      RETURN NUMBER;
   FUNCTION VALUE_32(
      P_LIP_OPP_ID IN NUMBER,
      P_YEAR IN DATE)
      RETURN NUMBER;
   FUNCTION VALUE_36(
      P_LIP_OPP_ID IN NUMBER,
      P_YEAR IN DATE)
      RETURN NUMBER;
   FUNCTION COMMENTS(
      P_LIP_OPP_ID IN NUMBER,
      P_YEAR IN DATE)
      RETURN VARCHAR2;
   FUNCTION DATE_3(
      P_LIP_OPP_ID IN NUMBER,
      P_YEAR IN DATE)
      RETURN DATE;
   FUNCTION DATE_5(
      P_LIP_OPP_ID IN NUMBER,
      P_YEAR IN DATE)
      RETURN DATE;
   FUNCTION NEXT_EQUAL_DAYTIME(
      P_LIP_OPP_ID IN NUMBER,
      P_YEAR IN DATE,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION TEXT_6(
      P_LIP_OPP_ID IN NUMBER,
      P_YEAR IN DATE)
      RETURN VARCHAR2;
   FUNCTION TEXT_9(
      P_LIP_OPP_ID IN NUMBER,
      P_YEAR IN DATE)
      RETURN VARCHAR2;
   FUNCTION VALUE_12(
      P_LIP_OPP_ID IN NUMBER,
      P_YEAR IN DATE)
      RETURN NUMBER;
   FUNCTION VALUE_22(
      P_LIP_OPP_ID IN NUMBER,
      P_YEAR IN DATE)
      RETURN NUMBER;
   FUNCTION VALUE_26(
      P_LIP_OPP_ID IN NUMBER,
      P_YEAR IN DATE)
      RETURN NUMBER;
   FUNCTION VALUE_45(
      P_LIP_OPP_ID IN NUMBER,
      P_YEAR IN DATE)
      RETURN NUMBER;
   FUNCTION VALUE_49(
      P_LIP_OPP_ID IN NUMBER,
      P_YEAR IN DATE)
      RETURN NUMBER;
   FUNCTION VALUE_6(
      P_LIP_OPP_ID IN NUMBER,
      P_YEAR IN DATE)
      RETURN NUMBER;
   FUNCTION DATE_2(
      P_LIP_OPP_ID IN NUMBER,
      P_YEAR IN DATE)
      RETURN DATE;
   FUNCTION PREV_DAYTIME(
      P_LIP_OPP_ID IN NUMBER,
      P_YEAR IN DATE,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION RECORD_STATUS(
      P_LIP_OPP_ID IN NUMBER,
      P_YEAR IN DATE)
      RETURN VARCHAR2;
   FUNCTION VALUE_1(
      P_LIP_OPP_ID IN NUMBER,
      P_YEAR IN DATE)
      RETURN NUMBER;
   FUNCTION VALUE_15(
      P_LIP_OPP_ID IN NUMBER,
      P_YEAR IN DATE)
      RETURN NUMBER;
   FUNCTION VALUE_19(
      P_LIP_OPP_ID IN NUMBER,
      P_YEAR IN DATE)
      RETURN NUMBER;
   FUNCTION VALUE_33(
      P_LIP_OPP_ID IN NUMBER,
      P_YEAR IN DATE)
      RETURN NUMBER;
   FUNCTION VALUE_34(
      P_LIP_OPP_ID IN NUMBER,
      P_YEAR IN DATE)
      RETURN NUMBER;
   FUNCTION APPROVAL_DATE(
      P_LIP_OPP_ID IN NUMBER,
      P_YEAR IN DATE)
      RETURN DATE;
      TYPE REC_ROW_BY_PK IS RECORD (
         LIP_OPP_ID NUMBER ,
         YEAR  DATE ,
         OBJECT_ID VARCHAR2 (32) ,
         DAYTIME  DATE ,
         EST_PROD_GAIN NUMBER ,
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
         VALUE_31 NUMBER ,
         VALUE_32 NUMBER ,
         VALUE_33 NUMBER ,
         VALUE_34 NUMBER ,
         VALUE_35 NUMBER ,
         VALUE_36 NUMBER ,
         VALUE_37 NUMBER ,
         VALUE_38 NUMBER ,
         VALUE_39 NUMBER ,
         VALUE_40 NUMBER ,
         VALUE_41 NUMBER ,
         VALUE_42 NUMBER ,
         VALUE_43 NUMBER ,
         VALUE_44 NUMBER ,
         VALUE_45 NUMBER ,
         VALUE_46 NUMBER ,
         VALUE_47 NUMBER ,
         VALUE_48 NUMBER ,
         VALUE_49 NUMBER ,
         VALUE_50 NUMBER ,
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
      P_LIP_OPP_ID IN NUMBER,
      P_YEAR IN DATE)
      RETURN REC_ROW_BY_PK;
   FUNCTION TEXT_5(
      P_LIP_OPP_ID IN NUMBER,
      P_YEAR IN DATE)
      RETURN VARCHAR2;
   FUNCTION VALUE_13(
      P_LIP_OPP_ID IN NUMBER,
      P_YEAR IN DATE)
      RETURN NUMBER;
   FUNCTION VALUE_17(
      P_LIP_OPP_ID IN NUMBER,
      P_YEAR IN DATE)
      RETURN NUMBER;
   FUNCTION VALUE_2(
      P_LIP_OPP_ID IN NUMBER,
      P_YEAR IN DATE)
      RETURN NUMBER;
   FUNCTION VALUE_20(
      P_LIP_OPP_ID IN NUMBER,
      P_YEAR IN DATE)
      RETURN NUMBER;
   FUNCTION VALUE_25(
      P_LIP_OPP_ID IN NUMBER,
      P_YEAR IN DATE)
      RETURN NUMBER;
   FUNCTION VALUE_3(
      P_LIP_OPP_ID IN NUMBER,
      P_YEAR IN DATE)
      RETURN NUMBER;
   FUNCTION VALUE_4(
      P_LIP_OPP_ID IN NUMBER,
      P_YEAR IN DATE)
      RETURN NUMBER;
   FUNCTION DATE_4(
      P_LIP_OPP_ID IN NUMBER,
      P_YEAR IN DATE)
      RETURN DATE;
   FUNCTION REC_ID(
      P_LIP_OPP_ID IN NUMBER,
      P_YEAR IN DATE)
      RETURN VARCHAR2;
   FUNCTION TEXT_1(
      P_LIP_OPP_ID IN NUMBER,
      P_YEAR IN DATE)
      RETURN VARCHAR2;
   FUNCTION TEXT_2(
      P_LIP_OPP_ID IN NUMBER,
      P_YEAR IN DATE)
      RETURN VARCHAR2;
   FUNCTION VALUE_38(
      P_LIP_OPP_ID IN NUMBER,
      P_YEAR IN DATE)
      RETURN NUMBER;
   FUNCTION VALUE_39(
      P_LIP_OPP_ID IN NUMBER,
      P_YEAR IN DATE)
      RETURN NUMBER;
   FUNCTION VALUE_40(
      P_LIP_OPP_ID IN NUMBER,
      P_YEAR IN DATE)
      RETURN NUMBER;
   FUNCTION VALUE_43(
      P_LIP_OPP_ID IN NUMBER,
      P_YEAR IN DATE)
      RETURN NUMBER;
   FUNCTION VALUE_44(
      P_LIP_OPP_ID IN NUMBER,
      P_YEAR IN DATE)
      RETURN NUMBER;
   FUNCTION VALUE_7(
      P_LIP_OPP_ID IN NUMBER,
      P_YEAR IN DATE)
      RETURN NUMBER;
   FUNCTION VALUE_9(
      P_LIP_OPP_ID IN NUMBER,
      P_YEAR IN DATE)
      RETURN NUMBER;
   FUNCTION DATE_1(
      P_LIP_OPP_ID IN NUMBER,
      P_YEAR IN DATE)
      RETURN DATE;
   FUNCTION DAYTIME(
      P_LIP_OPP_ID IN NUMBER,
      P_YEAR IN DATE)
      RETURN DATE;
   FUNCTION TEXT_10(
      P_LIP_OPP_ID IN NUMBER,
      P_YEAR IN DATE)
      RETURN VARCHAR2;
   FUNCTION VALUE_10(
      P_LIP_OPP_ID IN NUMBER,
      P_YEAR IN DATE)
      RETURN NUMBER;
   FUNCTION VALUE_11(
      P_LIP_OPP_ID IN NUMBER,
      P_YEAR IN DATE)
      RETURN NUMBER;
   FUNCTION VALUE_14(
      P_LIP_OPP_ID IN NUMBER,
      P_YEAR IN DATE)
      RETURN NUMBER;
   FUNCTION VALUE_24(
      P_LIP_OPP_ID IN NUMBER,
      P_YEAR IN DATE)
      RETURN NUMBER;
   FUNCTION VALUE_35(
      P_LIP_OPP_ID IN NUMBER,
      P_YEAR IN DATE)
      RETURN NUMBER;
   FUNCTION VALUE_41(
      P_LIP_OPP_ID IN NUMBER,
      P_YEAR IN DATE)
      RETURN NUMBER;
   FUNCTION VALUE_50(
      P_LIP_OPP_ID IN NUMBER,
      P_YEAR IN DATE)
      RETURN NUMBER;
   FUNCTION VALUE_8(
      P_LIP_OPP_ID IN NUMBER,
      P_YEAR IN DATE)
      RETURN NUMBER;

END RP_CHOKE_MODEL_LIP_YEAR;

/



CREATE or REPLACE PACKAGE BODY RP_CHOKE_MODEL_LIP_YEAR
IS

   FUNCTION EST_PROD_GAIN(
      P_LIP_OPP_ID IN NUMBER,
      P_YEAR IN DATE)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CHOKE_MODEL_LIP_YEAR.EST_PROD_GAIN      (
         P_LIP_OPP_ID,
         P_YEAR );
         RETURN ret_value;
   END EST_PROD_GAIN;
   FUNCTION TEXT_3(
      P_LIP_OPP_ID IN NUMBER,
      P_YEAR IN DATE)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_CHOKE_MODEL_LIP_YEAR.TEXT_3      (
         P_LIP_OPP_ID,
         P_YEAR );
         RETURN ret_value;
   END TEXT_3;
   FUNCTION TEXT_4(
      P_LIP_OPP_ID IN NUMBER,
      P_YEAR IN DATE)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_CHOKE_MODEL_LIP_YEAR.TEXT_4      (
         P_LIP_OPP_ID,
         P_YEAR );
         RETURN ret_value;
   END TEXT_4;
   FUNCTION VALUE_16(
      P_LIP_OPP_ID IN NUMBER,
      P_YEAR IN DATE)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CHOKE_MODEL_LIP_YEAR.VALUE_16      (
         P_LIP_OPP_ID,
         P_YEAR );
         RETURN ret_value;
   END VALUE_16;
   FUNCTION VALUE_18(
      P_LIP_OPP_ID IN NUMBER,
      P_YEAR IN DATE)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CHOKE_MODEL_LIP_YEAR.VALUE_18      (
         P_LIP_OPP_ID,
         P_YEAR );
         RETURN ret_value;
   END VALUE_18;
   FUNCTION VALUE_21(
      P_LIP_OPP_ID IN NUMBER,
      P_YEAR IN DATE)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CHOKE_MODEL_LIP_YEAR.VALUE_21      (
         P_LIP_OPP_ID,
         P_YEAR );
         RETURN ret_value;
   END VALUE_21;
   FUNCTION VALUE_27(
      P_LIP_OPP_ID IN NUMBER,
      P_YEAR IN DATE)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CHOKE_MODEL_LIP_YEAR.VALUE_27      (
         P_LIP_OPP_ID,
         P_YEAR );
         RETURN ret_value;
   END VALUE_27;
   FUNCTION VALUE_30(
      P_LIP_OPP_ID IN NUMBER,
      P_YEAR IN DATE)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CHOKE_MODEL_LIP_YEAR.VALUE_30      (
         P_LIP_OPP_ID,
         P_YEAR );
         RETURN ret_value;
   END VALUE_30;
   FUNCTION VALUE_37(
      P_LIP_OPP_ID IN NUMBER,
      P_YEAR IN DATE)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CHOKE_MODEL_LIP_YEAR.VALUE_37      (
         P_LIP_OPP_ID,
         P_YEAR );
         RETURN ret_value;
   END VALUE_37;
   FUNCTION VALUE_47(
      P_LIP_OPP_ID IN NUMBER,
      P_YEAR IN DATE)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CHOKE_MODEL_LIP_YEAR.VALUE_47      (
         P_LIP_OPP_ID,
         P_YEAR );
         RETURN ret_value;
   END VALUE_47;
   FUNCTION VALUE_48(
      P_LIP_OPP_ID IN NUMBER,
      P_YEAR IN DATE)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CHOKE_MODEL_LIP_YEAR.VALUE_48      (
         P_LIP_OPP_ID,
         P_YEAR );
         RETURN ret_value;
   END VALUE_48;
   FUNCTION APPROVAL_BY(
      P_LIP_OPP_ID IN NUMBER,
      P_YEAR IN DATE)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (30) ;
   BEGIN
      ret_value := EC_CHOKE_MODEL_LIP_YEAR.APPROVAL_BY      (
         P_LIP_OPP_ID,
         P_YEAR );
         RETURN ret_value;
   END APPROVAL_BY;
   FUNCTION APPROVAL_STATE(
      P_LIP_OPP_ID IN NUMBER,
      P_YEAR IN DATE)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_CHOKE_MODEL_LIP_YEAR.APPROVAL_STATE      (
         P_LIP_OPP_ID,
         P_YEAR );
         RETURN ret_value;
   END APPROVAL_STATE;
   FUNCTION VALUE_23(
      P_LIP_OPP_ID IN NUMBER,
      P_YEAR IN DATE)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CHOKE_MODEL_LIP_YEAR.VALUE_23      (
         P_LIP_OPP_ID,
         P_YEAR );
         RETURN ret_value;
   END VALUE_23;
   FUNCTION VALUE_28(
      P_LIP_OPP_ID IN NUMBER,
      P_YEAR IN DATE)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CHOKE_MODEL_LIP_YEAR.VALUE_28      (
         P_LIP_OPP_ID,
         P_YEAR );
         RETURN ret_value;
   END VALUE_28;
   FUNCTION VALUE_42(
      P_LIP_OPP_ID IN NUMBER,
      P_YEAR IN DATE)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CHOKE_MODEL_LIP_YEAR.VALUE_42      (
         P_LIP_OPP_ID,
         P_YEAR );
         RETURN ret_value;
   END VALUE_42;
   FUNCTION VALUE_46(
      P_LIP_OPP_ID IN NUMBER,
      P_YEAR IN DATE)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CHOKE_MODEL_LIP_YEAR.VALUE_46      (
         P_LIP_OPP_ID,
         P_YEAR );
         RETURN ret_value;
   END VALUE_46;
   FUNCTION VALUE_5(
      P_LIP_OPP_ID IN NUMBER,
      P_YEAR IN DATE)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CHOKE_MODEL_LIP_YEAR.VALUE_5      (
         P_LIP_OPP_ID,
         P_YEAR );
         RETURN ret_value;
   END VALUE_5;
   FUNCTION NEXT_DAYTIME(
      P_LIP_OPP_ID IN NUMBER,
      P_YEAR IN DATE,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CHOKE_MODEL_LIP_YEAR.NEXT_DAYTIME      (
         P_LIP_OPP_ID,
         P_YEAR,
         P_NUM_ROWS );
         RETURN ret_value;
   END NEXT_DAYTIME;
   FUNCTION OBJECT_ID(
      P_LIP_OPP_ID IN NUMBER,
      P_YEAR IN DATE)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_CHOKE_MODEL_LIP_YEAR.OBJECT_ID      (
         P_LIP_OPP_ID,
         P_YEAR );
         RETURN ret_value;
   END OBJECT_ID;
   FUNCTION PREV_EQUAL_DAYTIME(
      P_LIP_OPP_ID IN NUMBER,
      P_YEAR IN DATE,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CHOKE_MODEL_LIP_YEAR.PREV_EQUAL_DAYTIME      (
         P_LIP_OPP_ID,
         P_YEAR,
         P_NUM_ROWS );
         RETURN ret_value;
   END PREV_EQUAL_DAYTIME;
   FUNCTION TEXT_7(
      P_LIP_OPP_ID IN NUMBER,
      P_YEAR IN DATE)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_CHOKE_MODEL_LIP_YEAR.TEXT_7      (
         P_LIP_OPP_ID,
         P_YEAR );
         RETURN ret_value;
   END TEXT_7;
   FUNCTION TEXT_8(
      P_LIP_OPP_ID IN NUMBER,
      P_YEAR IN DATE)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_CHOKE_MODEL_LIP_YEAR.TEXT_8      (
         P_LIP_OPP_ID,
         P_YEAR );
         RETURN ret_value;
   END TEXT_8;
   FUNCTION VALUE_29(
      P_LIP_OPP_ID IN NUMBER,
      P_YEAR IN DATE)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CHOKE_MODEL_LIP_YEAR.VALUE_29      (
         P_LIP_OPP_ID,
         P_YEAR );
         RETURN ret_value;
   END VALUE_29;
   FUNCTION VALUE_31(
      P_LIP_OPP_ID IN NUMBER,
      P_YEAR IN DATE)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CHOKE_MODEL_LIP_YEAR.VALUE_31      (
         P_LIP_OPP_ID,
         P_YEAR );
         RETURN ret_value;
   END VALUE_31;
   FUNCTION VALUE_32(
      P_LIP_OPP_ID IN NUMBER,
      P_YEAR IN DATE)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CHOKE_MODEL_LIP_YEAR.VALUE_32      (
         P_LIP_OPP_ID,
         P_YEAR );
         RETURN ret_value;
   END VALUE_32;
   FUNCTION VALUE_36(
      P_LIP_OPP_ID IN NUMBER,
      P_YEAR IN DATE)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CHOKE_MODEL_LIP_YEAR.VALUE_36      (
         P_LIP_OPP_ID,
         P_YEAR );
         RETURN ret_value;
   END VALUE_36;
   FUNCTION COMMENTS(
      P_LIP_OPP_ID IN NUMBER,
      P_YEAR IN DATE)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_CHOKE_MODEL_LIP_YEAR.COMMENTS      (
         P_LIP_OPP_ID,
         P_YEAR );
         RETURN ret_value;
   END COMMENTS;
   FUNCTION DATE_3(
      P_LIP_OPP_ID IN NUMBER,
      P_YEAR IN DATE)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CHOKE_MODEL_LIP_YEAR.DATE_3      (
         P_LIP_OPP_ID,
         P_YEAR );
         RETURN ret_value;
   END DATE_3;
   FUNCTION DATE_5(
      P_LIP_OPP_ID IN NUMBER,
      P_YEAR IN DATE)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CHOKE_MODEL_LIP_YEAR.DATE_5      (
         P_LIP_OPP_ID,
         P_YEAR );
         RETURN ret_value;
   END DATE_5;
   FUNCTION NEXT_EQUAL_DAYTIME(
      P_LIP_OPP_ID IN NUMBER,
      P_YEAR IN DATE,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CHOKE_MODEL_LIP_YEAR.NEXT_EQUAL_DAYTIME      (
         P_LIP_OPP_ID,
         P_YEAR,
         P_NUM_ROWS );
         RETURN ret_value;
   END NEXT_EQUAL_DAYTIME;
   FUNCTION TEXT_6(
      P_LIP_OPP_ID IN NUMBER,
      P_YEAR IN DATE)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_CHOKE_MODEL_LIP_YEAR.TEXT_6      (
         P_LIP_OPP_ID,
         P_YEAR );
         RETURN ret_value;
   END TEXT_6;
   FUNCTION TEXT_9(
      P_LIP_OPP_ID IN NUMBER,
      P_YEAR IN DATE)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_CHOKE_MODEL_LIP_YEAR.TEXT_9      (
         P_LIP_OPP_ID,
         P_YEAR );
         RETURN ret_value;
   END TEXT_9;
   FUNCTION VALUE_12(
      P_LIP_OPP_ID IN NUMBER,
      P_YEAR IN DATE)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CHOKE_MODEL_LIP_YEAR.VALUE_12      (
         P_LIP_OPP_ID,
         P_YEAR );
         RETURN ret_value;
   END VALUE_12;
   FUNCTION VALUE_22(
      P_LIP_OPP_ID IN NUMBER,
      P_YEAR IN DATE)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CHOKE_MODEL_LIP_YEAR.VALUE_22      (
         P_LIP_OPP_ID,
         P_YEAR );
         RETURN ret_value;
   END VALUE_22;
   FUNCTION VALUE_26(
      P_LIP_OPP_ID IN NUMBER,
      P_YEAR IN DATE)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CHOKE_MODEL_LIP_YEAR.VALUE_26      (
         P_LIP_OPP_ID,
         P_YEAR );
         RETURN ret_value;
   END VALUE_26;
   FUNCTION VALUE_45(
      P_LIP_OPP_ID IN NUMBER,
      P_YEAR IN DATE)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CHOKE_MODEL_LIP_YEAR.VALUE_45      (
         P_LIP_OPP_ID,
         P_YEAR );
         RETURN ret_value;
   END VALUE_45;
   FUNCTION VALUE_49(
      P_LIP_OPP_ID IN NUMBER,
      P_YEAR IN DATE)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CHOKE_MODEL_LIP_YEAR.VALUE_49      (
         P_LIP_OPP_ID,
         P_YEAR );
         RETURN ret_value;
   END VALUE_49;
   FUNCTION VALUE_6(
      P_LIP_OPP_ID IN NUMBER,
      P_YEAR IN DATE)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CHOKE_MODEL_LIP_YEAR.VALUE_6      (
         P_LIP_OPP_ID,
         P_YEAR );
         RETURN ret_value;
   END VALUE_6;
   FUNCTION DATE_2(
      P_LIP_OPP_ID IN NUMBER,
      P_YEAR IN DATE)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CHOKE_MODEL_LIP_YEAR.DATE_2      (
         P_LIP_OPP_ID,
         P_YEAR );
         RETURN ret_value;
   END DATE_2;
   FUNCTION PREV_DAYTIME(
      P_LIP_OPP_ID IN NUMBER,
      P_YEAR IN DATE,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CHOKE_MODEL_LIP_YEAR.PREV_DAYTIME      (
         P_LIP_OPP_ID,
         P_YEAR,
         P_NUM_ROWS );
         RETURN ret_value;
   END PREV_DAYTIME;
   FUNCTION RECORD_STATUS(
      P_LIP_OPP_ID IN NUMBER,
      P_YEAR IN DATE)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_CHOKE_MODEL_LIP_YEAR.RECORD_STATUS      (
         P_LIP_OPP_ID,
         P_YEAR );
         RETURN ret_value;
   END RECORD_STATUS;
   FUNCTION VALUE_1(
      P_LIP_OPP_ID IN NUMBER,
      P_YEAR IN DATE)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CHOKE_MODEL_LIP_YEAR.VALUE_1      (
         P_LIP_OPP_ID,
         P_YEAR );
         RETURN ret_value;
   END VALUE_1;
   FUNCTION VALUE_15(
      P_LIP_OPP_ID IN NUMBER,
      P_YEAR IN DATE)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CHOKE_MODEL_LIP_YEAR.VALUE_15      (
         P_LIP_OPP_ID,
         P_YEAR );
         RETURN ret_value;
   END VALUE_15;
   FUNCTION VALUE_19(
      P_LIP_OPP_ID IN NUMBER,
      P_YEAR IN DATE)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CHOKE_MODEL_LIP_YEAR.VALUE_19      (
         P_LIP_OPP_ID,
         P_YEAR );
         RETURN ret_value;
   END VALUE_19;
   FUNCTION VALUE_33(
      P_LIP_OPP_ID IN NUMBER,
      P_YEAR IN DATE)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CHOKE_MODEL_LIP_YEAR.VALUE_33      (
         P_LIP_OPP_ID,
         P_YEAR );
         RETURN ret_value;
   END VALUE_33;
   FUNCTION VALUE_34(
      P_LIP_OPP_ID IN NUMBER,
      P_YEAR IN DATE)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CHOKE_MODEL_LIP_YEAR.VALUE_34      (
         P_LIP_OPP_ID,
         P_YEAR );
         RETURN ret_value;
   END VALUE_34;
   FUNCTION APPROVAL_DATE(
      P_LIP_OPP_ID IN NUMBER,
      P_YEAR IN DATE)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CHOKE_MODEL_LIP_YEAR.APPROVAL_DATE      (
         P_LIP_OPP_ID,
         P_YEAR );
         RETURN ret_value;
   END APPROVAL_DATE;
   FUNCTION ROW_BY_PK(
      P_LIP_OPP_ID IN NUMBER,
      P_YEAR IN DATE)
      RETURN REC_ROW_BY_PK
   IS
      ret_value    REC_ROW_BY_PK ;
   BEGIN
      ret_value := EC_CHOKE_MODEL_LIP_YEAR.ROW_BY_PK      (
         P_LIP_OPP_ID,
         P_YEAR );
         RETURN ret_value;
   END ROW_BY_PK;
   FUNCTION TEXT_5(
      P_LIP_OPP_ID IN NUMBER,
      P_YEAR IN DATE)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_CHOKE_MODEL_LIP_YEAR.TEXT_5      (
         P_LIP_OPP_ID,
         P_YEAR );
         RETURN ret_value;
   END TEXT_5;
   FUNCTION VALUE_13(
      P_LIP_OPP_ID IN NUMBER,
      P_YEAR IN DATE)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CHOKE_MODEL_LIP_YEAR.VALUE_13      (
         P_LIP_OPP_ID,
         P_YEAR );
         RETURN ret_value;
   END VALUE_13;
   FUNCTION VALUE_17(
      P_LIP_OPP_ID IN NUMBER,
      P_YEAR IN DATE)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CHOKE_MODEL_LIP_YEAR.VALUE_17      (
         P_LIP_OPP_ID,
         P_YEAR );
         RETURN ret_value;
   END VALUE_17;
   FUNCTION VALUE_2(
      P_LIP_OPP_ID IN NUMBER,
      P_YEAR IN DATE)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CHOKE_MODEL_LIP_YEAR.VALUE_2      (
         P_LIP_OPP_ID,
         P_YEAR );
         RETURN ret_value;
   END VALUE_2;
   FUNCTION VALUE_20(
      P_LIP_OPP_ID IN NUMBER,
      P_YEAR IN DATE)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CHOKE_MODEL_LIP_YEAR.VALUE_20      (
         P_LIP_OPP_ID,
         P_YEAR );
         RETURN ret_value;
   END VALUE_20;
   FUNCTION VALUE_25(
      P_LIP_OPP_ID IN NUMBER,
      P_YEAR IN DATE)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CHOKE_MODEL_LIP_YEAR.VALUE_25      (
         P_LIP_OPP_ID,
         P_YEAR );
         RETURN ret_value;
   END VALUE_25;
   FUNCTION VALUE_3(
      P_LIP_OPP_ID IN NUMBER,
      P_YEAR IN DATE)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CHOKE_MODEL_LIP_YEAR.VALUE_3      (
         P_LIP_OPP_ID,
         P_YEAR );
         RETURN ret_value;
   END VALUE_3;
   FUNCTION VALUE_4(
      P_LIP_OPP_ID IN NUMBER,
      P_YEAR IN DATE)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CHOKE_MODEL_LIP_YEAR.VALUE_4      (
         P_LIP_OPP_ID,
         P_YEAR );
         RETURN ret_value;
   END VALUE_4;
   FUNCTION DATE_4(
      P_LIP_OPP_ID IN NUMBER,
      P_YEAR IN DATE)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CHOKE_MODEL_LIP_YEAR.DATE_4      (
         P_LIP_OPP_ID,
         P_YEAR );
         RETURN ret_value;
   END DATE_4;
   FUNCTION REC_ID(
      P_LIP_OPP_ID IN NUMBER,
      P_YEAR IN DATE)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_CHOKE_MODEL_LIP_YEAR.REC_ID      (
         P_LIP_OPP_ID,
         P_YEAR );
         RETURN ret_value;
   END REC_ID;
   FUNCTION TEXT_1(
      P_LIP_OPP_ID IN NUMBER,
      P_YEAR IN DATE)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (16) ;
   BEGIN
      ret_value := EC_CHOKE_MODEL_LIP_YEAR.TEXT_1      (
         P_LIP_OPP_ID,
         P_YEAR );
         RETURN ret_value;
   END TEXT_1;
   FUNCTION TEXT_2(
      P_LIP_OPP_ID IN NUMBER,
      P_YEAR IN DATE)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_CHOKE_MODEL_LIP_YEAR.TEXT_2      (
         P_LIP_OPP_ID,
         P_YEAR );
         RETURN ret_value;
   END TEXT_2;
   FUNCTION VALUE_38(
      P_LIP_OPP_ID IN NUMBER,
      P_YEAR IN DATE)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CHOKE_MODEL_LIP_YEAR.VALUE_38      (
         P_LIP_OPP_ID,
         P_YEAR );
         RETURN ret_value;
   END VALUE_38;
   FUNCTION VALUE_39(
      P_LIP_OPP_ID IN NUMBER,
      P_YEAR IN DATE)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CHOKE_MODEL_LIP_YEAR.VALUE_39      (
         P_LIP_OPP_ID,
         P_YEAR );
         RETURN ret_value;
   END VALUE_39;
   FUNCTION VALUE_40(
      P_LIP_OPP_ID IN NUMBER,
      P_YEAR IN DATE)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CHOKE_MODEL_LIP_YEAR.VALUE_40      (
         P_LIP_OPP_ID,
         P_YEAR );
         RETURN ret_value;
   END VALUE_40;
   FUNCTION VALUE_43(
      P_LIP_OPP_ID IN NUMBER,
      P_YEAR IN DATE)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CHOKE_MODEL_LIP_YEAR.VALUE_43      (
         P_LIP_OPP_ID,
         P_YEAR );
         RETURN ret_value;
   END VALUE_43;
   FUNCTION VALUE_44(
      P_LIP_OPP_ID IN NUMBER,
      P_YEAR IN DATE)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CHOKE_MODEL_LIP_YEAR.VALUE_44      (
         P_LIP_OPP_ID,
         P_YEAR );
         RETURN ret_value;
   END VALUE_44;
   FUNCTION VALUE_7(
      P_LIP_OPP_ID IN NUMBER,
      P_YEAR IN DATE)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CHOKE_MODEL_LIP_YEAR.VALUE_7      (
         P_LIP_OPP_ID,
         P_YEAR );
         RETURN ret_value;
   END VALUE_7;
   FUNCTION VALUE_9(
      P_LIP_OPP_ID IN NUMBER,
      P_YEAR IN DATE)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CHOKE_MODEL_LIP_YEAR.VALUE_9      (
         P_LIP_OPP_ID,
         P_YEAR );
         RETURN ret_value;
   END VALUE_9;
   FUNCTION DATE_1(
      P_LIP_OPP_ID IN NUMBER,
      P_YEAR IN DATE)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CHOKE_MODEL_LIP_YEAR.DATE_1      (
         P_LIP_OPP_ID,
         P_YEAR );
         RETURN ret_value;
   END DATE_1;
   FUNCTION DAYTIME(
      P_LIP_OPP_ID IN NUMBER,
      P_YEAR IN DATE)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CHOKE_MODEL_LIP_YEAR.DAYTIME      (
         P_LIP_OPP_ID,
         P_YEAR );
         RETURN ret_value;
   END DAYTIME;
   FUNCTION TEXT_10(
      P_LIP_OPP_ID IN NUMBER,
      P_YEAR IN DATE)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_CHOKE_MODEL_LIP_YEAR.TEXT_10      (
         P_LIP_OPP_ID,
         P_YEAR );
         RETURN ret_value;
   END TEXT_10;
   FUNCTION VALUE_10(
      P_LIP_OPP_ID IN NUMBER,
      P_YEAR IN DATE)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CHOKE_MODEL_LIP_YEAR.VALUE_10      (
         P_LIP_OPP_ID,
         P_YEAR );
         RETURN ret_value;
   END VALUE_10;
   FUNCTION VALUE_11(
      P_LIP_OPP_ID IN NUMBER,
      P_YEAR IN DATE)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CHOKE_MODEL_LIP_YEAR.VALUE_11      (
         P_LIP_OPP_ID,
         P_YEAR );
         RETURN ret_value;
   END VALUE_11;
   FUNCTION VALUE_14(
      P_LIP_OPP_ID IN NUMBER,
      P_YEAR IN DATE)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CHOKE_MODEL_LIP_YEAR.VALUE_14      (
         P_LIP_OPP_ID,
         P_YEAR );
         RETURN ret_value;
   END VALUE_14;
   FUNCTION VALUE_24(
      P_LIP_OPP_ID IN NUMBER,
      P_YEAR IN DATE)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CHOKE_MODEL_LIP_YEAR.VALUE_24      (
         P_LIP_OPP_ID,
         P_YEAR );
         RETURN ret_value;
   END VALUE_24;
   FUNCTION VALUE_35(
      P_LIP_OPP_ID IN NUMBER,
      P_YEAR IN DATE)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CHOKE_MODEL_LIP_YEAR.VALUE_35      (
         P_LIP_OPP_ID,
         P_YEAR );
         RETURN ret_value;
   END VALUE_35;
   FUNCTION VALUE_41(
      P_LIP_OPP_ID IN NUMBER,
      P_YEAR IN DATE)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CHOKE_MODEL_LIP_YEAR.VALUE_41      (
         P_LIP_OPP_ID,
         P_YEAR );
         RETURN ret_value;
   END VALUE_41;
   FUNCTION VALUE_50(
      P_LIP_OPP_ID IN NUMBER,
      P_YEAR IN DATE)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CHOKE_MODEL_LIP_YEAR.VALUE_50      (
         P_LIP_OPP_ID,
         P_YEAR );
         RETURN ret_value;
   END VALUE_50;
   FUNCTION VALUE_8(
      P_LIP_OPP_ID IN NUMBER,
      P_YEAR IN DATE)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CHOKE_MODEL_LIP_YEAR.VALUE_8      (
         P_LIP_OPP_ID,
         P_YEAR );
         RETURN ret_value;
   END VALUE_8;

END RP_CHOKE_MODEL_LIP_YEAR;

/
--GRANT EXECUTE ON ECKERNEL_WST.RP_CHOKE_MODEL_LIP_YEAR TO REPORT_ROLE_XXX;



 -- FINISH PKG_GEN_PKGS.sf_get_functions at:11/15/2018 10.45.56 AM


