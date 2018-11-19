
 -- START PKG_GEN_PKGS.sf_get_functions at:11/15/2018 10.53.42 AM


CREATE or REPLACE PACKAGE RP_CAPACITY_BID_FORM
IS

   FUNCTION REF_OBJECT_ID_7(
      P_BID_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_3(
      P_BID_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_32(
      P_BID_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_36(
      P_BID_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_44(
      P_BID_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_47(
      P_BID_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_16(
      P_BID_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_18(
      P_BID_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_21(
      P_BID_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_27(
      P_BID_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_30(
      P_BID_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION APPROVAL_BY(
      P_BID_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_STATE(
      P_BID_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION PREARRANGED_IND(
      P_BID_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION REF_OBJECT_ID_4(
      P_BID_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION REF_OBJECT_ID_8(
      P_BID_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION STATUS_DESCRIPTION(
      P_BID_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_15(
      P_BID_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_21(
      P_BID_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_27(
      P_BID_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_33(
      P_BID_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_34(
      P_BID_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_48(
      P_BID_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_23(
      P_BID_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_28(
      P_BID_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_5(
      P_BID_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION SPECIAL_TERMS(
      P_BID_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_18(
      P_BID_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_19(
      P_BID_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_23(
      P_BID_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_40(
      P_BID_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_43(
      P_BID_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_45(
      P_BID_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_7(
      P_BID_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_8(
      P_BID_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_29(
      P_BID_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION DATE_3(
      P_BID_NO IN NUMBER)
      RETURN DATE;
   FUNCTION DATE_5(
      P_BID_NO IN NUMBER)
      RETURN DATE;
   FUNCTION REF_OBJECT_ID_2(
      P_BID_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION REF_OBJECT_ID_3(
      P_BID_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION REF_OBJECT_ID_9(
      P_BID_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_1(
      P_BID_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_11(
      P_BID_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_17(
      P_BID_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_20(
      P_BID_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_24(
      P_BID_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_28(
      P_BID_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_39(
      P_BID_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_49(
      P_BID_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_6(
      P_BID_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_9(
      P_BID_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_12(
      P_BID_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_22(
      P_BID_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_26(
      P_BID_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_6(
      P_BID_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION DATE_2(
      P_BID_NO IN NUMBER)
      RETURN DATE;
   FUNCTION RECORD_STATUS(
      P_BID_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION REF_OBJECT_ID_5(
      P_BID_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_16(
      P_BID_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_38(
      P_BID_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_42(
      P_BID_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_46(
      P_BID_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_1(
      P_BID_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_15(
      P_BID_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_19(
      P_BID_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION APPROVAL_DATE(
      P_BID_NO IN NUMBER)
      RETURN DATE;
   FUNCTION BID_RATE(
      P_BID_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION REF_OBJECT_ID_1(
      P_BID_NO IN NUMBER)
      RETURN VARCHAR2;
      TYPE REC_ROW_BY_PK IS RECORD (
         BID_NO NUMBER ,
         STATUS_DESCRIPTION VARCHAR2 (2000) ,
         BID_QTY NUMBER ,
         BID_RATE NUMBER ,
         SPECIAL_TERMS VARCHAR2 (4000) ,
         PREARRANGED_IND VARCHAR2 (1) ,
         MESSAGE_CONTACT_ID VARCHAR2 (32) ,
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
         TEXT_11 VARCHAR2 (240) ,
         TEXT_12 VARCHAR2 (240) ,
         TEXT_13 VARCHAR2 (240) ,
         TEXT_14 VARCHAR2 (240) ,
         TEXT_15 VARCHAR2 (240) ,
         TEXT_16 VARCHAR2 (2000) ,
         TEXT_17 VARCHAR2 (2000) ,
         TEXT_18 VARCHAR2 (2000) ,
         TEXT_19 VARCHAR2 (2000) ,
         TEXT_20 VARCHAR2 (2000) ,
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
         TEXT_45 VARCHAR2 (2000) ,
         TEXT_46 VARCHAR2 (2000) ,
         TEXT_47 VARCHAR2 (2000) ,
         TEXT_48 VARCHAR2 (2000) ,
         TEXT_49 VARCHAR2 (2000) ,
         TEXT_50 VARCHAR2 (2000) ,
         DATE_1  DATE ,
         DATE_2  DATE ,
         DATE_3  DATE ,
         DATE_4  DATE ,
         DATE_5  DATE ,
         REF_OBJECT_ID_1 VARCHAR2 (32) ,
         REF_OBJECT_ID_2 VARCHAR2 (32) ,
         REF_OBJECT_ID_3 VARCHAR2 (32) ,
         REF_OBJECT_ID_4 VARCHAR2 (32) ,
         REF_OBJECT_ID_5 VARCHAR2 (32) ,
         REF_OBJECT_ID_6 VARCHAR2 (32) ,
         REF_OBJECT_ID_7 VARCHAR2 (32) ,
         REF_OBJECT_ID_8 VARCHAR2 (32) ,
         REF_OBJECT_ID_9 VARCHAR2 (32) ,
         REF_OBJECT_ID_10 VARCHAR2 (32) ,
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
      P_BID_NO IN NUMBER)
      RETURN REC_ROW_BY_PK;
   FUNCTION TEXT_12(
      P_BID_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_2(
      P_BID_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_22(
      P_BID_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_25(
      P_BID_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_4(
      P_BID_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_5(
      P_BID_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_13(
      P_BID_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_17(
      P_BID_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_2(
      P_BID_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_20(
      P_BID_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_25(
      P_BID_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_3(
      P_BID_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_4(
      P_BID_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION DATE_4(
      P_BID_NO IN NUMBER)
      RETURN DATE;
   FUNCTION MESSAGE_CONTACT_ID(
      P_BID_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION REC_ID(
      P_BID_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION REF_OBJECT_ID_10(
      P_BID_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION REF_OBJECT_ID_6(
      P_BID_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_13(
      P_BID_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_29(
      P_BID_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_35(
      P_BID_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_37(
      P_BID_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_41(
      P_BID_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_50(
      P_BID_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_7(
      P_BID_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_9(
      P_BID_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION BID_QTY(
      P_BID_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION DATE_1(
      P_BID_NO IN NUMBER)
      RETURN DATE;
   FUNCTION TEXT_10(
      P_BID_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_14(
      P_BID_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_26(
      P_BID_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_30(
      P_BID_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_31(
      P_BID_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_10(
      P_BID_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_11(
      P_BID_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_14(
      P_BID_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_24(
      P_BID_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_8(
      P_BID_NO IN NUMBER)
      RETURN NUMBER;

END RP_CAPACITY_BID_FORM;

/



CREATE or REPLACE PACKAGE BODY RP_CAPACITY_BID_FORM
IS

   FUNCTION REF_OBJECT_ID_7(
      P_BID_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_CAPACITY_BID_FORM.REF_OBJECT_ID_7      (
         P_BID_NO );
         RETURN ret_value;
   END REF_OBJECT_ID_7;
   FUNCTION TEXT_3(
      P_BID_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_CAPACITY_BID_FORM.TEXT_3      (
         P_BID_NO );
         RETURN ret_value;
   END TEXT_3;
   FUNCTION TEXT_32(
      P_BID_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_CAPACITY_BID_FORM.TEXT_32      (
         P_BID_NO );
         RETURN ret_value;
   END TEXT_32;
   FUNCTION TEXT_36(
      P_BID_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_CAPACITY_BID_FORM.TEXT_36      (
         P_BID_NO );
         RETURN ret_value;
   END TEXT_36;
   FUNCTION TEXT_44(
      P_BID_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_CAPACITY_BID_FORM.TEXT_44      (
         P_BID_NO );
         RETURN ret_value;
   END TEXT_44;
   FUNCTION TEXT_47(
      P_BID_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_CAPACITY_BID_FORM.TEXT_47      (
         P_BID_NO );
         RETURN ret_value;
   END TEXT_47;
   FUNCTION VALUE_16(
      P_BID_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CAPACITY_BID_FORM.VALUE_16      (
         P_BID_NO );
         RETURN ret_value;
   END VALUE_16;
   FUNCTION VALUE_18(
      P_BID_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CAPACITY_BID_FORM.VALUE_18      (
         P_BID_NO );
         RETURN ret_value;
   END VALUE_18;
   FUNCTION VALUE_21(
      P_BID_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CAPACITY_BID_FORM.VALUE_21      (
         P_BID_NO );
         RETURN ret_value;
   END VALUE_21;
   FUNCTION VALUE_27(
      P_BID_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CAPACITY_BID_FORM.VALUE_27      (
         P_BID_NO );
         RETURN ret_value;
   END VALUE_27;
   FUNCTION VALUE_30(
      P_BID_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CAPACITY_BID_FORM.VALUE_30      (
         P_BID_NO );
         RETURN ret_value;
   END VALUE_30;
   FUNCTION APPROVAL_BY(
      P_BID_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (30) ;
   BEGIN
      ret_value := EC_CAPACITY_BID_FORM.APPROVAL_BY      (
         P_BID_NO );
         RETURN ret_value;
   END APPROVAL_BY;
   FUNCTION APPROVAL_STATE(
      P_BID_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_CAPACITY_BID_FORM.APPROVAL_STATE      (
         P_BID_NO );
         RETURN ret_value;
   END APPROVAL_STATE;
   FUNCTION PREARRANGED_IND(
      P_BID_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_CAPACITY_BID_FORM.PREARRANGED_IND      (
         P_BID_NO );
         RETURN ret_value;
   END PREARRANGED_IND;
   FUNCTION REF_OBJECT_ID_4(
      P_BID_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_CAPACITY_BID_FORM.REF_OBJECT_ID_4      (
         P_BID_NO );
         RETURN ret_value;
   END REF_OBJECT_ID_4;
   FUNCTION REF_OBJECT_ID_8(
      P_BID_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_CAPACITY_BID_FORM.REF_OBJECT_ID_8      (
         P_BID_NO );
         RETURN ret_value;
   END REF_OBJECT_ID_8;
   FUNCTION STATUS_DESCRIPTION(
      P_BID_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_CAPACITY_BID_FORM.STATUS_DESCRIPTION      (
         P_BID_NO );
         RETURN ret_value;
   END STATUS_DESCRIPTION;
   FUNCTION TEXT_15(
      P_BID_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_CAPACITY_BID_FORM.TEXT_15      (
         P_BID_NO );
         RETURN ret_value;
   END TEXT_15;
   FUNCTION TEXT_21(
      P_BID_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_CAPACITY_BID_FORM.TEXT_21      (
         P_BID_NO );
         RETURN ret_value;
   END TEXT_21;
   FUNCTION TEXT_27(
      P_BID_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_CAPACITY_BID_FORM.TEXT_27      (
         P_BID_NO );
         RETURN ret_value;
   END TEXT_27;
   FUNCTION TEXT_33(
      P_BID_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_CAPACITY_BID_FORM.TEXT_33      (
         P_BID_NO );
         RETURN ret_value;
   END TEXT_33;
   FUNCTION TEXT_34(
      P_BID_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_CAPACITY_BID_FORM.TEXT_34      (
         P_BID_NO );
         RETURN ret_value;
   END TEXT_34;
   FUNCTION TEXT_48(
      P_BID_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_CAPACITY_BID_FORM.TEXT_48      (
         P_BID_NO );
         RETURN ret_value;
   END TEXT_48;
   FUNCTION VALUE_23(
      P_BID_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CAPACITY_BID_FORM.VALUE_23      (
         P_BID_NO );
         RETURN ret_value;
   END VALUE_23;
   FUNCTION VALUE_28(
      P_BID_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CAPACITY_BID_FORM.VALUE_28      (
         P_BID_NO );
         RETURN ret_value;
   END VALUE_28;
   FUNCTION VALUE_5(
      P_BID_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CAPACITY_BID_FORM.VALUE_5      (
         P_BID_NO );
         RETURN ret_value;
   END VALUE_5;
   FUNCTION SPECIAL_TERMS(
      P_BID_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (4000) ;
   BEGIN
      ret_value := EC_CAPACITY_BID_FORM.SPECIAL_TERMS      (
         P_BID_NO );
         RETURN ret_value;
   END SPECIAL_TERMS;
   FUNCTION TEXT_18(
      P_BID_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_CAPACITY_BID_FORM.TEXT_18      (
         P_BID_NO );
         RETURN ret_value;
   END TEXT_18;
   FUNCTION TEXT_19(
      P_BID_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_CAPACITY_BID_FORM.TEXT_19      (
         P_BID_NO );
         RETURN ret_value;
   END TEXT_19;
   FUNCTION TEXT_23(
      P_BID_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_CAPACITY_BID_FORM.TEXT_23      (
         P_BID_NO );
         RETURN ret_value;
   END TEXT_23;
   FUNCTION TEXT_40(
      P_BID_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_CAPACITY_BID_FORM.TEXT_40      (
         P_BID_NO );
         RETURN ret_value;
   END TEXT_40;
   FUNCTION TEXT_43(
      P_BID_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_CAPACITY_BID_FORM.TEXT_43      (
         P_BID_NO );
         RETURN ret_value;
   END TEXT_43;
   FUNCTION TEXT_45(
      P_BID_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_CAPACITY_BID_FORM.TEXT_45      (
         P_BID_NO );
         RETURN ret_value;
   END TEXT_45;
   FUNCTION TEXT_7(
      P_BID_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_CAPACITY_BID_FORM.TEXT_7      (
         P_BID_NO );
         RETURN ret_value;
   END TEXT_7;
   FUNCTION TEXT_8(
      P_BID_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_CAPACITY_BID_FORM.TEXT_8      (
         P_BID_NO );
         RETURN ret_value;
   END TEXT_8;
   FUNCTION VALUE_29(
      P_BID_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CAPACITY_BID_FORM.VALUE_29      (
         P_BID_NO );
         RETURN ret_value;
   END VALUE_29;
   FUNCTION DATE_3(
      P_BID_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CAPACITY_BID_FORM.DATE_3      (
         P_BID_NO );
         RETURN ret_value;
   END DATE_3;
   FUNCTION DATE_5(
      P_BID_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CAPACITY_BID_FORM.DATE_5      (
         P_BID_NO );
         RETURN ret_value;
   END DATE_5;
   FUNCTION REF_OBJECT_ID_2(
      P_BID_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_CAPACITY_BID_FORM.REF_OBJECT_ID_2      (
         P_BID_NO );
         RETURN ret_value;
   END REF_OBJECT_ID_2;
   FUNCTION REF_OBJECT_ID_3(
      P_BID_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_CAPACITY_BID_FORM.REF_OBJECT_ID_3      (
         P_BID_NO );
         RETURN ret_value;
   END REF_OBJECT_ID_3;
   FUNCTION REF_OBJECT_ID_9(
      P_BID_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_CAPACITY_BID_FORM.REF_OBJECT_ID_9      (
         P_BID_NO );
         RETURN ret_value;
   END REF_OBJECT_ID_9;
   FUNCTION TEXT_1(
      P_BID_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_CAPACITY_BID_FORM.TEXT_1      (
         P_BID_NO );
         RETURN ret_value;
   END TEXT_1;
   FUNCTION TEXT_11(
      P_BID_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_CAPACITY_BID_FORM.TEXT_11      (
         P_BID_NO );
         RETURN ret_value;
   END TEXT_11;
   FUNCTION TEXT_17(
      P_BID_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_CAPACITY_BID_FORM.TEXT_17      (
         P_BID_NO );
         RETURN ret_value;
   END TEXT_17;
   FUNCTION TEXT_20(
      P_BID_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_CAPACITY_BID_FORM.TEXT_20      (
         P_BID_NO );
         RETURN ret_value;
   END TEXT_20;
   FUNCTION TEXT_24(
      P_BID_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_CAPACITY_BID_FORM.TEXT_24      (
         P_BID_NO );
         RETURN ret_value;
   END TEXT_24;
   FUNCTION TEXT_28(
      P_BID_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_CAPACITY_BID_FORM.TEXT_28      (
         P_BID_NO );
         RETURN ret_value;
   END TEXT_28;
   FUNCTION TEXT_39(
      P_BID_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_CAPACITY_BID_FORM.TEXT_39      (
         P_BID_NO );
         RETURN ret_value;
   END TEXT_39;
   FUNCTION TEXT_49(
      P_BID_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_CAPACITY_BID_FORM.TEXT_49      (
         P_BID_NO );
         RETURN ret_value;
   END TEXT_49;
   FUNCTION TEXT_6(
      P_BID_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_CAPACITY_BID_FORM.TEXT_6      (
         P_BID_NO );
         RETURN ret_value;
   END TEXT_6;
   FUNCTION TEXT_9(
      P_BID_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_CAPACITY_BID_FORM.TEXT_9      (
         P_BID_NO );
         RETURN ret_value;
   END TEXT_9;
   FUNCTION VALUE_12(
      P_BID_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CAPACITY_BID_FORM.VALUE_12      (
         P_BID_NO );
         RETURN ret_value;
   END VALUE_12;
   FUNCTION VALUE_22(
      P_BID_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CAPACITY_BID_FORM.VALUE_22      (
         P_BID_NO );
         RETURN ret_value;
   END VALUE_22;
   FUNCTION VALUE_26(
      P_BID_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CAPACITY_BID_FORM.VALUE_26      (
         P_BID_NO );
         RETURN ret_value;
   END VALUE_26;
   FUNCTION VALUE_6(
      P_BID_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CAPACITY_BID_FORM.VALUE_6      (
         P_BID_NO );
         RETURN ret_value;
   END VALUE_6;
   FUNCTION DATE_2(
      P_BID_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CAPACITY_BID_FORM.DATE_2      (
         P_BID_NO );
         RETURN ret_value;
   END DATE_2;
   FUNCTION RECORD_STATUS(
      P_BID_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_CAPACITY_BID_FORM.RECORD_STATUS      (
         P_BID_NO );
         RETURN ret_value;
   END RECORD_STATUS;
   FUNCTION REF_OBJECT_ID_5(
      P_BID_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_CAPACITY_BID_FORM.REF_OBJECT_ID_5      (
         P_BID_NO );
         RETURN ret_value;
   END REF_OBJECT_ID_5;
   FUNCTION TEXT_16(
      P_BID_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_CAPACITY_BID_FORM.TEXT_16      (
         P_BID_NO );
         RETURN ret_value;
   END TEXT_16;
   FUNCTION TEXT_38(
      P_BID_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_CAPACITY_BID_FORM.TEXT_38      (
         P_BID_NO );
         RETURN ret_value;
   END TEXT_38;
   FUNCTION TEXT_42(
      P_BID_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_CAPACITY_BID_FORM.TEXT_42      (
         P_BID_NO );
         RETURN ret_value;
   END TEXT_42;
   FUNCTION TEXT_46(
      P_BID_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_CAPACITY_BID_FORM.TEXT_46      (
         P_BID_NO );
         RETURN ret_value;
   END TEXT_46;
   FUNCTION VALUE_1(
      P_BID_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CAPACITY_BID_FORM.VALUE_1      (
         P_BID_NO );
         RETURN ret_value;
   END VALUE_1;
   FUNCTION VALUE_15(
      P_BID_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CAPACITY_BID_FORM.VALUE_15      (
         P_BID_NO );
         RETURN ret_value;
   END VALUE_15;
   FUNCTION VALUE_19(
      P_BID_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CAPACITY_BID_FORM.VALUE_19      (
         P_BID_NO );
         RETURN ret_value;
   END VALUE_19;
   FUNCTION APPROVAL_DATE(
      P_BID_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CAPACITY_BID_FORM.APPROVAL_DATE      (
         P_BID_NO );
         RETURN ret_value;
   END APPROVAL_DATE;
   FUNCTION BID_RATE(
      P_BID_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CAPACITY_BID_FORM.BID_RATE      (
         P_BID_NO );
         RETURN ret_value;
   END BID_RATE;
   FUNCTION REF_OBJECT_ID_1(
      P_BID_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_CAPACITY_BID_FORM.REF_OBJECT_ID_1      (
         P_BID_NO );
         RETURN ret_value;
   END REF_OBJECT_ID_1;
   FUNCTION ROW_BY_PK(
      P_BID_NO IN NUMBER)
      RETURN REC_ROW_BY_PK
   IS
      ret_value    REC_ROW_BY_PK ;
   BEGIN
      ret_value := EC_CAPACITY_BID_FORM.ROW_BY_PK      (
         P_BID_NO );
         RETURN ret_value;
   END ROW_BY_PK;
   FUNCTION TEXT_12(
      P_BID_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_CAPACITY_BID_FORM.TEXT_12      (
         P_BID_NO );
         RETURN ret_value;
   END TEXT_12;
   FUNCTION TEXT_2(
      P_BID_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_CAPACITY_BID_FORM.TEXT_2      (
         P_BID_NO );
         RETURN ret_value;
   END TEXT_2;
   FUNCTION TEXT_22(
      P_BID_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_CAPACITY_BID_FORM.TEXT_22      (
         P_BID_NO );
         RETURN ret_value;
   END TEXT_22;
   FUNCTION TEXT_25(
      P_BID_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_CAPACITY_BID_FORM.TEXT_25      (
         P_BID_NO );
         RETURN ret_value;
   END TEXT_25;
   FUNCTION TEXT_4(
      P_BID_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_CAPACITY_BID_FORM.TEXT_4      (
         P_BID_NO );
         RETURN ret_value;
   END TEXT_4;
   FUNCTION TEXT_5(
      P_BID_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_CAPACITY_BID_FORM.TEXT_5      (
         P_BID_NO );
         RETURN ret_value;
   END TEXT_5;
   FUNCTION VALUE_13(
      P_BID_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CAPACITY_BID_FORM.VALUE_13      (
         P_BID_NO );
         RETURN ret_value;
   END VALUE_13;
   FUNCTION VALUE_17(
      P_BID_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CAPACITY_BID_FORM.VALUE_17      (
         P_BID_NO );
         RETURN ret_value;
   END VALUE_17;
   FUNCTION VALUE_2(
      P_BID_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CAPACITY_BID_FORM.VALUE_2      (
         P_BID_NO );
         RETURN ret_value;
   END VALUE_2;
   FUNCTION VALUE_20(
      P_BID_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CAPACITY_BID_FORM.VALUE_20      (
         P_BID_NO );
         RETURN ret_value;
   END VALUE_20;
   FUNCTION VALUE_25(
      P_BID_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CAPACITY_BID_FORM.VALUE_25      (
         P_BID_NO );
         RETURN ret_value;
   END VALUE_25;
   FUNCTION VALUE_3(
      P_BID_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CAPACITY_BID_FORM.VALUE_3      (
         P_BID_NO );
         RETURN ret_value;
   END VALUE_3;
   FUNCTION VALUE_4(
      P_BID_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CAPACITY_BID_FORM.VALUE_4      (
         P_BID_NO );
         RETURN ret_value;
   END VALUE_4;
   FUNCTION DATE_4(
      P_BID_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CAPACITY_BID_FORM.DATE_4      (
         P_BID_NO );
         RETURN ret_value;
   END DATE_4;
   FUNCTION MESSAGE_CONTACT_ID(
      P_BID_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_CAPACITY_BID_FORM.MESSAGE_CONTACT_ID      (
         P_BID_NO );
         RETURN ret_value;
   END MESSAGE_CONTACT_ID;
   FUNCTION REC_ID(
      P_BID_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_CAPACITY_BID_FORM.REC_ID      (
         P_BID_NO );
         RETURN ret_value;
   END REC_ID;
   FUNCTION REF_OBJECT_ID_10(
      P_BID_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_CAPACITY_BID_FORM.REF_OBJECT_ID_10      (
         P_BID_NO );
         RETURN ret_value;
   END REF_OBJECT_ID_10;
   FUNCTION REF_OBJECT_ID_6(
      P_BID_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_CAPACITY_BID_FORM.REF_OBJECT_ID_6      (
         P_BID_NO );
         RETURN ret_value;
   END REF_OBJECT_ID_6;
   FUNCTION TEXT_13(
      P_BID_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_CAPACITY_BID_FORM.TEXT_13      (
         P_BID_NO );
         RETURN ret_value;
   END TEXT_13;
   FUNCTION TEXT_29(
      P_BID_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_CAPACITY_BID_FORM.TEXT_29      (
         P_BID_NO );
         RETURN ret_value;
   END TEXT_29;
   FUNCTION TEXT_35(
      P_BID_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_CAPACITY_BID_FORM.TEXT_35      (
         P_BID_NO );
         RETURN ret_value;
   END TEXT_35;
   FUNCTION TEXT_37(
      P_BID_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_CAPACITY_BID_FORM.TEXT_37      (
         P_BID_NO );
         RETURN ret_value;
   END TEXT_37;
   FUNCTION TEXT_41(
      P_BID_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_CAPACITY_BID_FORM.TEXT_41      (
         P_BID_NO );
         RETURN ret_value;
   END TEXT_41;
   FUNCTION TEXT_50(
      P_BID_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_CAPACITY_BID_FORM.TEXT_50      (
         P_BID_NO );
         RETURN ret_value;
   END TEXT_50;
   FUNCTION VALUE_7(
      P_BID_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CAPACITY_BID_FORM.VALUE_7      (
         P_BID_NO );
         RETURN ret_value;
   END VALUE_7;
   FUNCTION VALUE_9(
      P_BID_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CAPACITY_BID_FORM.VALUE_9      (
         P_BID_NO );
         RETURN ret_value;
   END VALUE_9;
   FUNCTION BID_QTY(
      P_BID_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CAPACITY_BID_FORM.BID_QTY      (
         P_BID_NO );
         RETURN ret_value;
   END BID_QTY;
   FUNCTION DATE_1(
      P_BID_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CAPACITY_BID_FORM.DATE_1      (
         P_BID_NO );
         RETURN ret_value;
   END DATE_1;
   FUNCTION TEXT_10(
      P_BID_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_CAPACITY_BID_FORM.TEXT_10      (
         P_BID_NO );
         RETURN ret_value;
   END TEXT_10;
   FUNCTION TEXT_14(
      P_BID_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_CAPACITY_BID_FORM.TEXT_14      (
         P_BID_NO );
         RETURN ret_value;
   END TEXT_14;
   FUNCTION TEXT_26(
      P_BID_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_CAPACITY_BID_FORM.TEXT_26      (
         P_BID_NO );
         RETURN ret_value;
   END TEXT_26;
   FUNCTION TEXT_30(
      P_BID_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_CAPACITY_BID_FORM.TEXT_30      (
         P_BID_NO );
         RETURN ret_value;
   END TEXT_30;
   FUNCTION TEXT_31(
      P_BID_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_CAPACITY_BID_FORM.TEXT_31      (
         P_BID_NO );
         RETURN ret_value;
   END TEXT_31;
   FUNCTION VALUE_10(
      P_BID_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CAPACITY_BID_FORM.VALUE_10      (
         P_BID_NO );
         RETURN ret_value;
   END VALUE_10;
   FUNCTION VALUE_11(
      P_BID_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CAPACITY_BID_FORM.VALUE_11      (
         P_BID_NO );
         RETURN ret_value;
   END VALUE_11;
   FUNCTION VALUE_14(
      P_BID_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CAPACITY_BID_FORM.VALUE_14      (
         P_BID_NO );
         RETURN ret_value;
   END VALUE_14;
   FUNCTION VALUE_24(
      P_BID_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CAPACITY_BID_FORM.VALUE_24      (
         P_BID_NO );
         RETURN ret_value;
   END VALUE_24;
   FUNCTION VALUE_8(
      P_BID_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CAPACITY_BID_FORM.VALUE_8      (
         P_BID_NO );
         RETURN ret_value;
   END VALUE_8;

END RP_CAPACITY_BID_FORM;

/
--GRANT EXECUTE ON ECKERNEL_WST.RP_CAPACITY_BID_FORM TO REPORT_ROLE_XXX;



 -- FINISH PKG_GEN_PKGS.sf_get_functions at:11/15/2018 10.54.03 AM


