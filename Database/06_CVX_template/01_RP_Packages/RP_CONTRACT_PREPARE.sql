
 -- START PKG_GEN_PKGS.sf_get_functions at:11/15/2018 10.25.29 AM


CREATE or REPLACE PACKAGE RP_CONTRACT_PREPARE
IS

   FUNCTION DATE_10(
      P_PREPARE_NO IN NUMBER)
      RETURN DATE;
   FUNCTION DATE_11(
      P_PREPARE_NO IN NUMBER)
      RETURN DATE;
   FUNCTION DATE_20(
      P_PREPARE_NO IN NUMBER)
      RETURN DATE;
   FUNCTION TEXT_13(
      P_PREPARE_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_15(
      P_PREPARE_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_32(
      P_PREPARE_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_36(
      P_PREPARE_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_44(
      P_PREPARE_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_47(
      P_PREPARE_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_7(
      P_PREPARE_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_16(
      P_PREPARE_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_18(
      P_PREPARE_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_21(
      P_PREPARE_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_27(
      P_PREPARE_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_30(
      P_PREPARE_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_37(
      P_PREPARE_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_47(
      P_PREPARE_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_48(
      P_PREPARE_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION APPROVAL_BY(
      P_PREPARE_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_STATE(
      P_PREPARE_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION DATE_15(
      P_PREPARE_NO IN NUMBER)
      RETURN DATE;
   FUNCTION TEXT_17(
      P_PREPARE_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_21(
      P_PREPARE_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_27(
      P_PREPARE_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_33(
      P_PREPARE_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_34(
      P_PREPARE_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_6(
      P_PREPARE_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_23(
      P_PREPARE_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_28(
      P_PREPARE_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_42(
      P_PREPARE_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_46(
      P_PREPARE_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_5(
      P_PREPARE_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION DATE_19(
      P_PREPARE_NO IN NUMBER)
      RETURN DATE;
   FUNCTION DATE_7(
      P_PREPARE_NO IN NUMBER)
      RETURN DATE;
   FUNCTION DATE_9(
      P_PREPARE_NO IN NUMBER)
      RETURN DATE;
   FUNCTION NEXT_DAYTIME(
      P_PREPARE_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION PREV_EQUAL_DAYTIME(
      P_PREPARE_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION TEXT_11(
      P_PREPARE_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_18(
      P_PREPARE_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_23(
      P_PREPARE_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_3(
      P_PREPARE_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_40(
      P_PREPARE_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_43(
      P_PREPARE_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_46(
      P_PREPARE_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_5(
      P_PREPARE_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_50(
      P_PREPARE_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_9(
      P_PREPARE_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_29(
      P_PREPARE_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_31(
      P_PREPARE_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_32(
      P_PREPARE_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_36(
      P_PREPARE_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION DATE_12(
      P_PREPARE_NO IN NUMBER)
      RETURN DATE;
   FUNCTION DATE_18(
      P_PREPARE_NO IN NUMBER)
      RETURN DATE;
   FUNCTION DATE_3(
      P_PREPARE_NO IN NUMBER)
      RETURN DATE;
   FUNCTION DATE_5(
      P_PREPARE_NO IN NUMBER)
      RETURN DATE;
   FUNCTION NEXT_EQUAL_DAYTIME(
      P_PREPARE_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION REF_CONTRACT_ID(
      P_PREPARE_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_24(
      P_PREPARE_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_28(
      P_PREPARE_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_39(
      P_PREPARE_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_4(
      P_PREPARE_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_12(
      P_PREPARE_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_22(
      P_PREPARE_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_26(
      P_PREPARE_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_45(
      P_PREPARE_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_49(
      P_PREPARE_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_6(
      P_PREPARE_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION DATE_14(
      P_PREPARE_NO IN NUMBER)
      RETURN DATE;
   FUNCTION DATE_2(
      P_PREPARE_NO IN NUMBER)
      RETURN DATE;
   FUNCTION END_DATE(
      P_PREPARE_NO IN NUMBER)
      RETURN DATE;
   FUNCTION PREV_DAYTIME(
      P_PREPARE_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION RECORD_STATUS(
      P_PREPARE_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_19(
      P_PREPARE_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_2(
      P_PREPARE_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_38(
      P_PREPARE_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_42(
      P_PREPARE_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_48(
      P_PREPARE_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_1(
      P_PREPARE_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_15(
      P_PREPARE_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_19(
      P_PREPARE_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_33(
      P_PREPARE_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_34(
      P_PREPARE_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION APPROVAL_DATE(
      P_PREPARE_NO IN NUMBER)
      RETURN DATE;
   FUNCTION DATE_6(
      P_PREPARE_NO IN NUMBER)
      RETURN DATE;
   FUNCTION NAME(
      P_PREPARE_NO IN NUMBER)
      RETURN VARCHAR2;
      TYPE REC_ROW_BY_PK IS RECORD (
         PREPARE_NO NUMBER ,
         CODE VARCHAR2 (32) ,
         NAME VARCHAR2 (240) ,
         DAYTIME  DATE ,
         END_DATE  DATE ,
         REF_CONTRACT_ID VARCHAR2 (32) ,
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
         TEXT_1 VARCHAR2 (1000) ,
         TEXT_2 VARCHAR2 (1000) ,
         TEXT_3 VARCHAR2 (1000) ,
         TEXT_4 VARCHAR2 (1000) ,
         TEXT_5 VARCHAR2 (1000) ,
         TEXT_6 VARCHAR2 (1000) ,
         TEXT_7 VARCHAR2 (1000) ,
         TEXT_8 VARCHAR2 (1000) ,
         TEXT_9 VARCHAR2 (1000) ,
         TEXT_10 VARCHAR2 (1000) ,
         TEXT_11 VARCHAR2 (1000) ,
         TEXT_12 VARCHAR2 (1000) ,
         TEXT_13 VARCHAR2 (1000) ,
         TEXT_14 VARCHAR2 (1000) ,
         TEXT_15 VARCHAR2 (1000) ,
         TEXT_16 VARCHAR2 (1000) ,
         TEXT_17 VARCHAR2 (1000) ,
         TEXT_18 VARCHAR2 (1000) ,
         TEXT_19 VARCHAR2 (1000) ,
         TEXT_20 VARCHAR2 (1000) ,
         TEXT_21 VARCHAR2 (2000) ,
         TEXT_22 VARCHAR2 (2000) ,
         TEXT_23 VARCHAR2 (2000) ,
         TEXT_24 VARCHAR2 (2000) ,
         TEXT_25 VARCHAR2 (2000) ,
         TEXT_26 VARCHAR2 (2000) ,
         TEXT_27 VARCHAR2 (2000) ,
         TEXT_28 VARCHAR2 (2000) ,
         TEXT_29 VARCHAR2 (2000) ,
         TEXT_30 VARCHAR2 (2000) ,
         TEXT_31 VARCHAR2 (2000) ,
         TEXT_32 VARCHAR2 (2000) ,
         TEXT_33 VARCHAR2 (2000) ,
         TEXT_34 VARCHAR2 (2000) ,
         TEXT_35 VARCHAR2 (2000) ,
         TEXT_36 VARCHAR2 (2000) ,
         TEXT_37 VARCHAR2 (2000) ,
         TEXT_38 VARCHAR2 (2000) ,
         TEXT_39 VARCHAR2 (2000) ,
         TEXT_40 VARCHAR2 (2000) ,
         TEXT_41 VARCHAR2 (2000) ,
         TEXT_42 VARCHAR2 (2000) ,
         TEXT_43 VARCHAR2 (2000) ,
         TEXT_44 VARCHAR2 (2000) ,
         TEXT_45 VARCHAR2 (4000) ,
         TEXT_46 VARCHAR2 (4000) ,
         TEXT_47 VARCHAR2 (4000) ,
         TEXT_48 VARCHAR2 (4000) ,
         TEXT_49 VARCHAR2 (4000) ,
         TEXT_50 VARCHAR2 (4000) ,
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
         DATE_11  DATE ,
         DATE_12  DATE ,
         DATE_13  DATE ,
         DATE_14  DATE ,
         DATE_15  DATE ,
         DATE_16  DATE ,
         DATE_17  DATE ,
         DATE_18  DATE ,
         DATE_19  DATE ,
         DATE_20  DATE ,
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
         REC_ID VARCHAR2 (32)  );
   FUNCTION ROW_BY_PK(
      P_PREPARE_NO IN NUMBER)
      RETURN REC_ROW_BY_PK;
   FUNCTION TEXT_1(
      P_PREPARE_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_10(
      P_PREPARE_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_22(
      P_PREPARE_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_25(
      P_PREPARE_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_49(
      P_PREPARE_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_8(
      P_PREPARE_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_13(
      P_PREPARE_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_17(
      P_PREPARE_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_2(
      P_PREPARE_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_20(
      P_PREPARE_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_25(
      P_PREPARE_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_3(
      P_PREPARE_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_4(
      P_PREPARE_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION CODE(
      P_PREPARE_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION DATE_16(
      P_PREPARE_NO IN NUMBER)
      RETURN DATE;
   FUNCTION DATE_17(
      P_PREPARE_NO IN NUMBER)
      RETURN DATE;
   FUNCTION DATE_4(
      P_PREPARE_NO IN NUMBER)
      RETURN DATE;
   FUNCTION REC_ID(
      P_PREPARE_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_12(
      P_PREPARE_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_20(
      P_PREPARE_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_29(
      P_PREPARE_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_35(
      P_PREPARE_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_37(
      P_PREPARE_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_41(
      P_PREPARE_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_45(
      P_PREPARE_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_38(
      P_PREPARE_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_39(
      P_PREPARE_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_40(
      P_PREPARE_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_43(
      P_PREPARE_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_44(
      P_PREPARE_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_7(
      P_PREPARE_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_9(
      P_PREPARE_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION DATE_1(
      P_PREPARE_NO IN NUMBER)
      RETURN DATE;
   FUNCTION DATE_13(
      P_PREPARE_NO IN NUMBER)
      RETURN DATE;
   FUNCTION DATE_8(
      P_PREPARE_NO IN NUMBER)
      RETURN DATE;
   FUNCTION DAYTIME(
      P_PREPARE_NO IN NUMBER)
      RETURN DATE;
   FUNCTION TEXT_14(
      P_PREPARE_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_16(
      P_PREPARE_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_26(
      P_PREPARE_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_30(
      P_PREPARE_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_31(
      P_PREPARE_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_10(
      P_PREPARE_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_11(
      P_PREPARE_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_14(
      P_PREPARE_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_24(
      P_PREPARE_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_35(
      P_PREPARE_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_41(
      P_PREPARE_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_50(
      P_PREPARE_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_8(
      P_PREPARE_NO IN NUMBER)
      RETURN NUMBER;

END RP_CONTRACT_PREPARE;

/



CREATE or REPLACE PACKAGE BODY RP_CONTRACT_PREPARE
IS

   FUNCTION DATE_10(
      P_PREPARE_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CONTRACT_PREPARE.DATE_10      (
         P_PREPARE_NO );
         RETURN ret_value;
   END DATE_10;
   FUNCTION DATE_11(
      P_PREPARE_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CONTRACT_PREPARE.DATE_11      (
         P_PREPARE_NO );
         RETURN ret_value;
   END DATE_11;
   FUNCTION DATE_20(
      P_PREPARE_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CONTRACT_PREPARE.DATE_20      (
         P_PREPARE_NO );
         RETURN ret_value;
   END DATE_20;
   FUNCTION TEXT_13(
      P_PREPARE_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1000) ;
   BEGIN
      ret_value := EC_CONTRACT_PREPARE.TEXT_13      (
         P_PREPARE_NO );
         RETURN ret_value;
   END TEXT_13;
   FUNCTION TEXT_15(
      P_PREPARE_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1000) ;
   BEGIN
      ret_value := EC_CONTRACT_PREPARE.TEXT_15      (
         P_PREPARE_NO );
         RETURN ret_value;
   END TEXT_15;
   FUNCTION TEXT_32(
      P_PREPARE_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_CONTRACT_PREPARE.TEXT_32      (
         P_PREPARE_NO );
         RETURN ret_value;
   END TEXT_32;
   FUNCTION TEXT_36(
      P_PREPARE_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_CONTRACT_PREPARE.TEXT_36      (
         P_PREPARE_NO );
         RETURN ret_value;
   END TEXT_36;
   FUNCTION TEXT_44(
      P_PREPARE_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_CONTRACT_PREPARE.TEXT_44      (
         P_PREPARE_NO );
         RETURN ret_value;
   END TEXT_44;
   FUNCTION TEXT_47(
      P_PREPARE_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (4000) ;
   BEGIN
      ret_value := EC_CONTRACT_PREPARE.TEXT_47      (
         P_PREPARE_NO );
         RETURN ret_value;
   END TEXT_47;
   FUNCTION TEXT_7(
      P_PREPARE_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1000) ;
   BEGIN
      ret_value := EC_CONTRACT_PREPARE.TEXT_7      (
         P_PREPARE_NO );
         RETURN ret_value;
   END TEXT_7;
   FUNCTION VALUE_16(
      P_PREPARE_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CONTRACT_PREPARE.VALUE_16      (
         P_PREPARE_NO );
         RETURN ret_value;
   END VALUE_16;
   FUNCTION VALUE_18(
      P_PREPARE_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CONTRACT_PREPARE.VALUE_18      (
         P_PREPARE_NO );
         RETURN ret_value;
   END VALUE_18;
   FUNCTION VALUE_21(
      P_PREPARE_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CONTRACT_PREPARE.VALUE_21      (
         P_PREPARE_NO );
         RETURN ret_value;
   END VALUE_21;
   FUNCTION VALUE_27(
      P_PREPARE_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CONTRACT_PREPARE.VALUE_27      (
         P_PREPARE_NO );
         RETURN ret_value;
   END VALUE_27;
   FUNCTION VALUE_30(
      P_PREPARE_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CONTRACT_PREPARE.VALUE_30      (
         P_PREPARE_NO );
         RETURN ret_value;
   END VALUE_30;
   FUNCTION VALUE_37(
      P_PREPARE_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CONTRACT_PREPARE.VALUE_37      (
         P_PREPARE_NO );
         RETURN ret_value;
   END VALUE_37;
   FUNCTION VALUE_47(
      P_PREPARE_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CONTRACT_PREPARE.VALUE_47      (
         P_PREPARE_NO );
         RETURN ret_value;
   END VALUE_47;
   FUNCTION VALUE_48(
      P_PREPARE_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CONTRACT_PREPARE.VALUE_48      (
         P_PREPARE_NO );
         RETURN ret_value;
   END VALUE_48;
   FUNCTION APPROVAL_BY(
      P_PREPARE_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (30) ;
   BEGIN
      ret_value := EC_CONTRACT_PREPARE.APPROVAL_BY      (
         P_PREPARE_NO );
         RETURN ret_value;
   END APPROVAL_BY;
   FUNCTION APPROVAL_STATE(
      P_PREPARE_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_CONTRACT_PREPARE.APPROVAL_STATE      (
         P_PREPARE_NO );
         RETURN ret_value;
   END APPROVAL_STATE;
   FUNCTION DATE_15(
      P_PREPARE_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CONTRACT_PREPARE.DATE_15      (
         P_PREPARE_NO );
         RETURN ret_value;
   END DATE_15;
   FUNCTION TEXT_17(
      P_PREPARE_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1000) ;
   BEGIN
      ret_value := EC_CONTRACT_PREPARE.TEXT_17      (
         P_PREPARE_NO );
         RETURN ret_value;
   END TEXT_17;
   FUNCTION TEXT_21(
      P_PREPARE_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_CONTRACT_PREPARE.TEXT_21      (
         P_PREPARE_NO );
         RETURN ret_value;
   END TEXT_21;
   FUNCTION TEXT_27(
      P_PREPARE_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_CONTRACT_PREPARE.TEXT_27      (
         P_PREPARE_NO );
         RETURN ret_value;
   END TEXT_27;
   FUNCTION TEXT_33(
      P_PREPARE_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_CONTRACT_PREPARE.TEXT_33      (
         P_PREPARE_NO );
         RETURN ret_value;
   END TEXT_33;
   FUNCTION TEXT_34(
      P_PREPARE_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_CONTRACT_PREPARE.TEXT_34      (
         P_PREPARE_NO );
         RETURN ret_value;
   END TEXT_34;
   FUNCTION TEXT_6(
      P_PREPARE_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1000) ;
   BEGIN
      ret_value := EC_CONTRACT_PREPARE.TEXT_6      (
         P_PREPARE_NO );
         RETURN ret_value;
   END TEXT_6;
   FUNCTION VALUE_23(
      P_PREPARE_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CONTRACT_PREPARE.VALUE_23      (
         P_PREPARE_NO );
         RETURN ret_value;
   END VALUE_23;
   FUNCTION VALUE_28(
      P_PREPARE_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CONTRACT_PREPARE.VALUE_28      (
         P_PREPARE_NO );
         RETURN ret_value;
   END VALUE_28;
   FUNCTION VALUE_42(
      P_PREPARE_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CONTRACT_PREPARE.VALUE_42      (
         P_PREPARE_NO );
         RETURN ret_value;
   END VALUE_42;
   FUNCTION VALUE_46(
      P_PREPARE_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CONTRACT_PREPARE.VALUE_46      (
         P_PREPARE_NO );
         RETURN ret_value;
   END VALUE_46;
   FUNCTION VALUE_5(
      P_PREPARE_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CONTRACT_PREPARE.VALUE_5      (
         P_PREPARE_NO );
         RETURN ret_value;
   END VALUE_5;
   FUNCTION DATE_19(
      P_PREPARE_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CONTRACT_PREPARE.DATE_19      (
         P_PREPARE_NO );
         RETURN ret_value;
   END DATE_19;
   FUNCTION DATE_7(
      P_PREPARE_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CONTRACT_PREPARE.DATE_7      (
         P_PREPARE_NO );
         RETURN ret_value;
   END DATE_7;
   FUNCTION DATE_9(
      P_PREPARE_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CONTRACT_PREPARE.DATE_9      (
         P_PREPARE_NO );
         RETURN ret_value;
   END DATE_9;
   FUNCTION NEXT_DAYTIME(
      P_PREPARE_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CONTRACT_PREPARE.NEXT_DAYTIME      (
         P_PREPARE_NO,
         P_NUM_ROWS );
         RETURN ret_value;
   END NEXT_DAYTIME;
   FUNCTION PREV_EQUAL_DAYTIME(
      P_PREPARE_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CONTRACT_PREPARE.PREV_EQUAL_DAYTIME      (
         P_PREPARE_NO,
         P_NUM_ROWS );
         RETURN ret_value;
   END PREV_EQUAL_DAYTIME;
   FUNCTION TEXT_11(
      P_PREPARE_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1000) ;
   BEGIN
      ret_value := EC_CONTRACT_PREPARE.TEXT_11      (
         P_PREPARE_NO );
         RETURN ret_value;
   END TEXT_11;
   FUNCTION TEXT_18(
      P_PREPARE_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1000) ;
   BEGIN
      ret_value := EC_CONTRACT_PREPARE.TEXT_18      (
         P_PREPARE_NO );
         RETURN ret_value;
   END TEXT_18;
   FUNCTION TEXT_23(
      P_PREPARE_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_CONTRACT_PREPARE.TEXT_23      (
         P_PREPARE_NO );
         RETURN ret_value;
   END TEXT_23;
   FUNCTION TEXT_3(
      P_PREPARE_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1000) ;
   BEGIN
      ret_value := EC_CONTRACT_PREPARE.TEXT_3      (
         P_PREPARE_NO );
         RETURN ret_value;
   END TEXT_3;
   FUNCTION TEXT_40(
      P_PREPARE_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_CONTRACT_PREPARE.TEXT_40      (
         P_PREPARE_NO );
         RETURN ret_value;
   END TEXT_40;
   FUNCTION TEXT_43(
      P_PREPARE_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_CONTRACT_PREPARE.TEXT_43      (
         P_PREPARE_NO );
         RETURN ret_value;
   END TEXT_43;
   FUNCTION TEXT_46(
      P_PREPARE_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (4000) ;
   BEGIN
      ret_value := EC_CONTRACT_PREPARE.TEXT_46      (
         P_PREPARE_NO );
         RETURN ret_value;
   END TEXT_46;
   FUNCTION TEXT_5(
      P_PREPARE_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1000) ;
   BEGIN
      ret_value := EC_CONTRACT_PREPARE.TEXT_5      (
         P_PREPARE_NO );
         RETURN ret_value;
   END TEXT_5;
   FUNCTION TEXT_50(
      P_PREPARE_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (4000) ;
   BEGIN
      ret_value := EC_CONTRACT_PREPARE.TEXT_50      (
         P_PREPARE_NO );
         RETURN ret_value;
   END TEXT_50;
   FUNCTION TEXT_9(
      P_PREPARE_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1000) ;
   BEGIN
      ret_value := EC_CONTRACT_PREPARE.TEXT_9      (
         P_PREPARE_NO );
         RETURN ret_value;
   END TEXT_9;
   FUNCTION VALUE_29(
      P_PREPARE_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CONTRACT_PREPARE.VALUE_29      (
         P_PREPARE_NO );
         RETURN ret_value;
   END VALUE_29;
   FUNCTION VALUE_31(
      P_PREPARE_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CONTRACT_PREPARE.VALUE_31      (
         P_PREPARE_NO );
         RETURN ret_value;
   END VALUE_31;
   FUNCTION VALUE_32(
      P_PREPARE_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CONTRACT_PREPARE.VALUE_32      (
         P_PREPARE_NO );
         RETURN ret_value;
   END VALUE_32;
   FUNCTION VALUE_36(
      P_PREPARE_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CONTRACT_PREPARE.VALUE_36      (
         P_PREPARE_NO );
         RETURN ret_value;
   END VALUE_36;
   FUNCTION DATE_12(
      P_PREPARE_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CONTRACT_PREPARE.DATE_12      (
         P_PREPARE_NO );
         RETURN ret_value;
   END DATE_12;
   FUNCTION DATE_18(
      P_PREPARE_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CONTRACT_PREPARE.DATE_18      (
         P_PREPARE_NO );
         RETURN ret_value;
   END DATE_18;
   FUNCTION DATE_3(
      P_PREPARE_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CONTRACT_PREPARE.DATE_3      (
         P_PREPARE_NO );
         RETURN ret_value;
   END DATE_3;
   FUNCTION DATE_5(
      P_PREPARE_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CONTRACT_PREPARE.DATE_5      (
         P_PREPARE_NO );
         RETURN ret_value;
   END DATE_5;
   FUNCTION NEXT_EQUAL_DAYTIME(
      P_PREPARE_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CONTRACT_PREPARE.NEXT_EQUAL_DAYTIME      (
         P_PREPARE_NO,
         P_NUM_ROWS );
         RETURN ret_value;
   END NEXT_EQUAL_DAYTIME;
   FUNCTION REF_CONTRACT_ID(
      P_PREPARE_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_CONTRACT_PREPARE.REF_CONTRACT_ID      (
         P_PREPARE_NO );
         RETURN ret_value;
   END REF_CONTRACT_ID;
   FUNCTION TEXT_24(
      P_PREPARE_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_CONTRACT_PREPARE.TEXT_24      (
         P_PREPARE_NO );
         RETURN ret_value;
   END TEXT_24;
   FUNCTION TEXT_28(
      P_PREPARE_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_CONTRACT_PREPARE.TEXT_28      (
         P_PREPARE_NO );
         RETURN ret_value;
   END TEXT_28;
   FUNCTION TEXT_39(
      P_PREPARE_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_CONTRACT_PREPARE.TEXT_39      (
         P_PREPARE_NO );
         RETURN ret_value;
   END TEXT_39;
   FUNCTION TEXT_4(
      P_PREPARE_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1000) ;
   BEGIN
      ret_value := EC_CONTRACT_PREPARE.TEXT_4      (
         P_PREPARE_NO );
         RETURN ret_value;
   END TEXT_4;
   FUNCTION VALUE_12(
      P_PREPARE_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CONTRACT_PREPARE.VALUE_12      (
         P_PREPARE_NO );
         RETURN ret_value;
   END VALUE_12;
   FUNCTION VALUE_22(
      P_PREPARE_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CONTRACT_PREPARE.VALUE_22      (
         P_PREPARE_NO );
         RETURN ret_value;
   END VALUE_22;
   FUNCTION VALUE_26(
      P_PREPARE_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CONTRACT_PREPARE.VALUE_26      (
         P_PREPARE_NO );
         RETURN ret_value;
   END VALUE_26;
   FUNCTION VALUE_45(
      P_PREPARE_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CONTRACT_PREPARE.VALUE_45      (
         P_PREPARE_NO );
         RETURN ret_value;
   END VALUE_45;
   FUNCTION VALUE_49(
      P_PREPARE_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CONTRACT_PREPARE.VALUE_49      (
         P_PREPARE_NO );
         RETURN ret_value;
   END VALUE_49;
   FUNCTION VALUE_6(
      P_PREPARE_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CONTRACT_PREPARE.VALUE_6      (
         P_PREPARE_NO );
         RETURN ret_value;
   END VALUE_6;
   FUNCTION DATE_14(
      P_PREPARE_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CONTRACT_PREPARE.DATE_14      (
         P_PREPARE_NO );
         RETURN ret_value;
   END DATE_14;
   FUNCTION DATE_2(
      P_PREPARE_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CONTRACT_PREPARE.DATE_2      (
         P_PREPARE_NO );
         RETURN ret_value;
   END DATE_2;
   FUNCTION END_DATE(
      P_PREPARE_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CONTRACT_PREPARE.END_DATE      (
         P_PREPARE_NO );
         RETURN ret_value;
   END END_DATE;
   FUNCTION PREV_DAYTIME(
      P_PREPARE_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CONTRACT_PREPARE.PREV_DAYTIME      (
         P_PREPARE_NO,
         P_NUM_ROWS );
         RETURN ret_value;
   END PREV_DAYTIME;
   FUNCTION RECORD_STATUS(
      P_PREPARE_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_CONTRACT_PREPARE.RECORD_STATUS      (
         P_PREPARE_NO );
         RETURN ret_value;
   END RECORD_STATUS;
   FUNCTION TEXT_19(
      P_PREPARE_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1000) ;
   BEGIN
      ret_value := EC_CONTRACT_PREPARE.TEXT_19      (
         P_PREPARE_NO );
         RETURN ret_value;
   END TEXT_19;
   FUNCTION TEXT_2(
      P_PREPARE_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1000) ;
   BEGIN
      ret_value := EC_CONTRACT_PREPARE.TEXT_2      (
         P_PREPARE_NO );
         RETURN ret_value;
   END TEXT_2;
   FUNCTION TEXT_38(
      P_PREPARE_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_CONTRACT_PREPARE.TEXT_38      (
         P_PREPARE_NO );
         RETURN ret_value;
   END TEXT_38;
   FUNCTION TEXT_42(
      P_PREPARE_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_CONTRACT_PREPARE.TEXT_42      (
         P_PREPARE_NO );
         RETURN ret_value;
   END TEXT_42;
   FUNCTION TEXT_48(
      P_PREPARE_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (4000) ;
   BEGIN
      ret_value := EC_CONTRACT_PREPARE.TEXT_48      (
         P_PREPARE_NO );
         RETURN ret_value;
   END TEXT_48;
   FUNCTION VALUE_1(
      P_PREPARE_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CONTRACT_PREPARE.VALUE_1      (
         P_PREPARE_NO );
         RETURN ret_value;
   END VALUE_1;
   FUNCTION VALUE_15(
      P_PREPARE_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CONTRACT_PREPARE.VALUE_15      (
         P_PREPARE_NO );
         RETURN ret_value;
   END VALUE_15;
   FUNCTION VALUE_19(
      P_PREPARE_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CONTRACT_PREPARE.VALUE_19      (
         P_PREPARE_NO );
         RETURN ret_value;
   END VALUE_19;
   FUNCTION VALUE_33(
      P_PREPARE_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CONTRACT_PREPARE.VALUE_33      (
         P_PREPARE_NO );
         RETURN ret_value;
   END VALUE_33;
   FUNCTION VALUE_34(
      P_PREPARE_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CONTRACT_PREPARE.VALUE_34      (
         P_PREPARE_NO );
         RETURN ret_value;
   END VALUE_34;
   FUNCTION APPROVAL_DATE(
      P_PREPARE_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CONTRACT_PREPARE.APPROVAL_DATE      (
         P_PREPARE_NO );
         RETURN ret_value;
   END APPROVAL_DATE;
   FUNCTION DATE_6(
      P_PREPARE_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CONTRACT_PREPARE.DATE_6      (
         P_PREPARE_NO );
         RETURN ret_value;
   END DATE_6;
   FUNCTION NAME(
      P_PREPARE_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_CONTRACT_PREPARE.NAME      (
         P_PREPARE_NO );
         RETURN ret_value;
   END NAME;
   FUNCTION ROW_BY_PK(
      P_PREPARE_NO IN NUMBER)
      RETURN REC_ROW_BY_PK
   IS
      ret_value    REC_ROW_BY_PK ;
   BEGIN
      ret_value := EC_CONTRACT_PREPARE.ROW_BY_PK      (
         P_PREPARE_NO );
         RETURN ret_value;
   END ROW_BY_PK;
   FUNCTION TEXT_1(
      P_PREPARE_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1000) ;
   BEGIN
      ret_value := EC_CONTRACT_PREPARE.TEXT_1      (
         P_PREPARE_NO );
         RETURN ret_value;
   END TEXT_1;
   FUNCTION TEXT_10(
      P_PREPARE_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1000) ;
   BEGIN
      ret_value := EC_CONTRACT_PREPARE.TEXT_10      (
         P_PREPARE_NO );
         RETURN ret_value;
   END TEXT_10;
   FUNCTION TEXT_22(
      P_PREPARE_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_CONTRACT_PREPARE.TEXT_22      (
         P_PREPARE_NO );
         RETURN ret_value;
   END TEXT_22;
   FUNCTION TEXT_25(
      P_PREPARE_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_CONTRACT_PREPARE.TEXT_25      (
         P_PREPARE_NO );
         RETURN ret_value;
   END TEXT_25;
   FUNCTION TEXT_49(
      P_PREPARE_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (4000) ;
   BEGIN
      ret_value := EC_CONTRACT_PREPARE.TEXT_49      (
         P_PREPARE_NO );
         RETURN ret_value;
   END TEXT_49;
   FUNCTION TEXT_8(
      P_PREPARE_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1000) ;
   BEGIN
      ret_value := EC_CONTRACT_PREPARE.TEXT_8      (
         P_PREPARE_NO );
         RETURN ret_value;
   END TEXT_8;
   FUNCTION VALUE_13(
      P_PREPARE_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CONTRACT_PREPARE.VALUE_13      (
         P_PREPARE_NO );
         RETURN ret_value;
   END VALUE_13;
   FUNCTION VALUE_17(
      P_PREPARE_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CONTRACT_PREPARE.VALUE_17      (
         P_PREPARE_NO );
         RETURN ret_value;
   END VALUE_17;
   FUNCTION VALUE_2(
      P_PREPARE_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CONTRACT_PREPARE.VALUE_2      (
         P_PREPARE_NO );
         RETURN ret_value;
   END VALUE_2;
   FUNCTION VALUE_20(
      P_PREPARE_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CONTRACT_PREPARE.VALUE_20      (
         P_PREPARE_NO );
         RETURN ret_value;
   END VALUE_20;
   FUNCTION VALUE_25(
      P_PREPARE_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CONTRACT_PREPARE.VALUE_25      (
         P_PREPARE_NO );
         RETURN ret_value;
   END VALUE_25;
   FUNCTION VALUE_3(
      P_PREPARE_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CONTRACT_PREPARE.VALUE_3      (
         P_PREPARE_NO );
         RETURN ret_value;
   END VALUE_3;
   FUNCTION VALUE_4(
      P_PREPARE_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CONTRACT_PREPARE.VALUE_4      (
         P_PREPARE_NO );
         RETURN ret_value;
   END VALUE_4;
   FUNCTION CODE(
      P_PREPARE_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_CONTRACT_PREPARE.CODE      (
         P_PREPARE_NO );
         RETURN ret_value;
   END CODE;
   FUNCTION DATE_16(
      P_PREPARE_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CONTRACT_PREPARE.DATE_16      (
         P_PREPARE_NO );
         RETURN ret_value;
   END DATE_16;
   FUNCTION DATE_17(
      P_PREPARE_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CONTRACT_PREPARE.DATE_17      (
         P_PREPARE_NO );
         RETURN ret_value;
   END DATE_17;
   FUNCTION DATE_4(
      P_PREPARE_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CONTRACT_PREPARE.DATE_4      (
         P_PREPARE_NO );
         RETURN ret_value;
   END DATE_4;
   FUNCTION REC_ID(
      P_PREPARE_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_CONTRACT_PREPARE.REC_ID      (
         P_PREPARE_NO );
         RETURN ret_value;
   END REC_ID;
   FUNCTION TEXT_12(
      P_PREPARE_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1000) ;
   BEGIN
      ret_value := EC_CONTRACT_PREPARE.TEXT_12      (
         P_PREPARE_NO );
         RETURN ret_value;
   END TEXT_12;
   FUNCTION TEXT_20(
      P_PREPARE_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1000) ;
   BEGIN
      ret_value := EC_CONTRACT_PREPARE.TEXT_20      (
         P_PREPARE_NO );
         RETURN ret_value;
   END TEXT_20;
   FUNCTION TEXT_29(
      P_PREPARE_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_CONTRACT_PREPARE.TEXT_29      (
         P_PREPARE_NO );
         RETURN ret_value;
   END TEXT_29;
   FUNCTION TEXT_35(
      P_PREPARE_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_CONTRACT_PREPARE.TEXT_35      (
         P_PREPARE_NO );
         RETURN ret_value;
   END TEXT_35;
   FUNCTION TEXT_37(
      P_PREPARE_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_CONTRACT_PREPARE.TEXT_37      (
         P_PREPARE_NO );
         RETURN ret_value;
   END TEXT_37;
   FUNCTION TEXT_41(
      P_PREPARE_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_CONTRACT_PREPARE.TEXT_41      (
         P_PREPARE_NO );
         RETURN ret_value;
   END TEXT_41;
   FUNCTION TEXT_45(
      P_PREPARE_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (4000) ;
   BEGIN
      ret_value := EC_CONTRACT_PREPARE.TEXT_45      (
         P_PREPARE_NO );
         RETURN ret_value;
   END TEXT_45;
   FUNCTION VALUE_38(
      P_PREPARE_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CONTRACT_PREPARE.VALUE_38      (
         P_PREPARE_NO );
         RETURN ret_value;
   END VALUE_38;
   FUNCTION VALUE_39(
      P_PREPARE_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CONTRACT_PREPARE.VALUE_39      (
         P_PREPARE_NO );
         RETURN ret_value;
   END VALUE_39;
   FUNCTION VALUE_40(
      P_PREPARE_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CONTRACT_PREPARE.VALUE_40      (
         P_PREPARE_NO );
         RETURN ret_value;
   END VALUE_40;
   FUNCTION VALUE_43(
      P_PREPARE_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CONTRACT_PREPARE.VALUE_43      (
         P_PREPARE_NO );
         RETURN ret_value;
   END VALUE_43;
   FUNCTION VALUE_44(
      P_PREPARE_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CONTRACT_PREPARE.VALUE_44      (
         P_PREPARE_NO );
         RETURN ret_value;
   END VALUE_44;
   FUNCTION VALUE_7(
      P_PREPARE_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CONTRACT_PREPARE.VALUE_7      (
         P_PREPARE_NO );
         RETURN ret_value;
   END VALUE_7;
   FUNCTION VALUE_9(
      P_PREPARE_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CONTRACT_PREPARE.VALUE_9      (
         P_PREPARE_NO );
         RETURN ret_value;
   END VALUE_9;
   FUNCTION DATE_1(
      P_PREPARE_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CONTRACT_PREPARE.DATE_1      (
         P_PREPARE_NO );
         RETURN ret_value;
   END DATE_1;
   FUNCTION DATE_13(
      P_PREPARE_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CONTRACT_PREPARE.DATE_13      (
         P_PREPARE_NO );
         RETURN ret_value;
   END DATE_13;
   FUNCTION DATE_8(
      P_PREPARE_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CONTRACT_PREPARE.DATE_8      (
         P_PREPARE_NO );
         RETURN ret_value;
   END DATE_8;
   FUNCTION DAYTIME(
      P_PREPARE_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CONTRACT_PREPARE.DAYTIME      (
         P_PREPARE_NO );
         RETURN ret_value;
   END DAYTIME;
   FUNCTION TEXT_14(
      P_PREPARE_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1000) ;
   BEGIN
      ret_value := EC_CONTRACT_PREPARE.TEXT_14      (
         P_PREPARE_NO );
         RETURN ret_value;
   END TEXT_14;
   FUNCTION TEXT_16(
      P_PREPARE_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1000) ;
   BEGIN
      ret_value := EC_CONTRACT_PREPARE.TEXT_16      (
         P_PREPARE_NO );
         RETURN ret_value;
   END TEXT_16;
   FUNCTION TEXT_26(
      P_PREPARE_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_CONTRACT_PREPARE.TEXT_26      (
         P_PREPARE_NO );
         RETURN ret_value;
   END TEXT_26;
   FUNCTION TEXT_30(
      P_PREPARE_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_CONTRACT_PREPARE.TEXT_30      (
         P_PREPARE_NO );
         RETURN ret_value;
   END TEXT_30;
   FUNCTION TEXT_31(
      P_PREPARE_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_CONTRACT_PREPARE.TEXT_31      (
         P_PREPARE_NO );
         RETURN ret_value;
   END TEXT_31;
   FUNCTION VALUE_10(
      P_PREPARE_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CONTRACT_PREPARE.VALUE_10      (
         P_PREPARE_NO );
         RETURN ret_value;
   END VALUE_10;
   FUNCTION VALUE_11(
      P_PREPARE_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CONTRACT_PREPARE.VALUE_11      (
         P_PREPARE_NO );
         RETURN ret_value;
   END VALUE_11;
   FUNCTION VALUE_14(
      P_PREPARE_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CONTRACT_PREPARE.VALUE_14      (
         P_PREPARE_NO );
         RETURN ret_value;
   END VALUE_14;
   FUNCTION VALUE_24(
      P_PREPARE_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CONTRACT_PREPARE.VALUE_24      (
         P_PREPARE_NO );
         RETURN ret_value;
   END VALUE_24;
   FUNCTION VALUE_35(
      P_PREPARE_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CONTRACT_PREPARE.VALUE_35      (
         P_PREPARE_NO );
         RETURN ret_value;
   END VALUE_35;
   FUNCTION VALUE_41(
      P_PREPARE_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CONTRACT_PREPARE.VALUE_41      (
         P_PREPARE_NO );
         RETURN ret_value;
   END VALUE_41;
   FUNCTION VALUE_50(
      P_PREPARE_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CONTRACT_PREPARE.VALUE_50      (
         P_PREPARE_NO );
         RETURN ret_value;
   END VALUE_50;
   FUNCTION VALUE_8(
      P_PREPARE_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CONTRACT_PREPARE.VALUE_8      (
         P_PREPARE_NO );
         RETURN ret_value;
   END VALUE_8;

END RP_CONTRACT_PREPARE;

/
--GRANT EXECUTE ON ECKERNEL_WST.RP_CONTRACT_PREPARE TO REPORT_ROLE_XXX;



 -- FINISH PKG_GEN_PKGS.sf_get_functions at:11/15/2018 10.25.57 AM


