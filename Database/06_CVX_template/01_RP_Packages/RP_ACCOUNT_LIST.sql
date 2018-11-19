
 -- START PKG_GEN_PKGS.sf_get_functions at:11/15/2018 11.04.53 AM


CREATE or REPLACE PACKAGE RP_ACCOUNT_LIST
IS

   FUNCTION ACCOUNT_NAME(
      P_ACCOUNT_CODE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION SORT_ORDER(
      P_ACCOUNT_CODE IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION TEXT_3(
      P_ACCOUNT_CODE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION VALUE_16(
      P_ACCOUNT_CODE IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION VALUE_18(
      P_ACCOUNT_CODE IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION VALUE_21(
      P_ACCOUNT_CODE IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION VALUE_27(
      P_ACCOUNT_CODE IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION VALUE_30(
      P_ACCOUNT_CODE IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION APPROVAL_BY(
      P_ACCOUNT_CODE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_STATE(
      P_ACCOUNT_CODE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION LINE_ITEM_BASED_TYPE(
      P_ACCOUNT_CODE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION VALUE_23(
      P_ACCOUNT_CODE IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION VALUE_28(
      P_ACCOUNT_CODE IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION VALUE_5(
      P_ACCOUNT_CODE IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION PRODUCT_ID(
      P_ACCOUNT_CODE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION TEXT_7(
      P_ACCOUNT_CODE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION TEXT_8(
      P_ACCOUNT_CODE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION VALUE_29(
      P_ACCOUNT_CODE IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION DATE_3(
      P_ACCOUNT_CODE IN VARCHAR2)
      RETURN DATE;
   FUNCTION DATE_5(
      P_ACCOUNT_CODE IN VARCHAR2)
      RETURN DATE;
   FUNCTION QTY3_REVN_MAPPING(
      P_ACCOUNT_CODE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION TEXT_1(
      P_ACCOUNT_CODE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION TEXT_14(
      P_ACCOUNT_CODE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION TEXT_6(
      P_ACCOUNT_CODE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION TEXT_9(
      P_ACCOUNT_CODE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION VALUE_12(
      P_ACCOUNT_CODE IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION VALUE_22(
      P_ACCOUNT_CODE IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION VALUE_26(
      P_ACCOUNT_CODE IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION VALUE_6(
      P_ACCOUNT_CODE IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION DATE_2(
      P_ACCOUNT_CODE IN VARCHAR2)
      RETURN DATE;
   FUNCTION QTY1_REVN_MAPPING(
      P_ACCOUNT_CODE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION QTY4_REVN_MAPPING(
      P_ACCOUNT_CODE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION RECORD_STATUS(
      P_ACCOUNT_CODE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION VALUE_1(
      P_ACCOUNT_CODE IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION VALUE_15(
      P_ACCOUNT_CODE IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION VALUE_19(
      P_ACCOUNT_CODE IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION APPROVAL_DATE(
      P_ACCOUNT_CODE IN VARCHAR2)
      RETURN DATE;
   FUNCTION DESCRIPTION(
      P_ACCOUNT_CODE IN VARCHAR2)
      RETURN VARCHAR2;
      TYPE REC_ROW_BY_PK IS RECORD (
         ACCOUNT_CODE VARCHAR2 (32) ,
         ACCOUNT_NAME VARCHAR2 (240) ,
         PRODUCT_ID VARCHAR2 (32) ,
         PRICE_CONCEPT_CODE VARCHAR2 (32) ,
         SORT_ORDER NUMBER ,
         DESCRIPTION VARCHAR2 (240) ,
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
         QTY1_REVN_MAPPING VARCHAR2 (32) ,
         QTY2_REVN_MAPPING VARCHAR2 (32) ,
         QTY3_REVN_MAPPING VARCHAR2 (32) ,
         QTY4_REVN_MAPPING VARCHAR2 (32) ,
         LINE_ITEM_BASED_TYPE VARCHAR2 (32) ,
         LINE_ITEM_TYPE VARCHAR2 (32) ,
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
      P_ACCOUNT_CODE IN VARCHAR2)
      RETURN REC_ROW_BY_PK;
   FUNCTION TEXT_13(
      P_ACCOUNT_CODE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION TEXT_2(
      P_ACCOUNT_CODE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION TEXT_4(
      P_ACCOUNT_CODE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION TEXT_5(
      P_ACCOUNT_CODE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION VALUE_13(
      P_ACCOUNT_CODE IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION VALUE_17(
      P_ACCOUNT_CODE IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION VALUE_2(
      P_ACCOUNT_CODE IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION VALUE_20(
      P_ACCOUNT_CODE IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION VALUE_25(
      P_ACCOUNT_CODE IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION VALUE_3(
      P_ACCOUNT_CODE IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION VALUE_4(
      P_ACCOUNT_CODE IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION DATE_4(
      P_ACCOUNT_CODE IN VARCHAR2)
      RETURN DATE;
   FUNCTION LINE_ITEM_TYPE(
      P_ACCOUNT_CODE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION REC_ID(
      P_ACCOUNT_CODE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION VALUE_7(
      P_ACCOUNT_CODE IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION VALUE_9(
      P_ACCOUNT_CODE IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION DATE_1(
      P_ACCOUNT_CODE IN VARCHAR2)
      RETURN DATE;
   FUNCTION PRICE_CONCEPT_CODE(
      P_ACCOUNT_CODE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION QTY2_REVN_MAPPING(
      P_ACCOUNT_CODE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION TEXT_10(
      P_ACCOUNT_CODE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION TEXT_11(
      P_ACCOUNT_CODE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION TEXT_12(
      P_ACCOUNT_CODE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION TEXT_15(
      P_ACCOUNT_CODE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION VALUE_10(
      P_ACCOUNT_CODE IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION VALUE_11(
      P_ACCOUNT_CODE IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION VALUE_14(
      P_ACCOUNT_CODE IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION VALUE_24(
      P_ACCOUNT_CODE IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION VALUE_8(
      P_ACCOUNT_CODE IN VARCHAR2)
      RETURN NUMBER;

END RP_ACCOUNT_LIST;

/



CREATE or REPLACE PACKAGE BODY RP_ACCOUNT_LIST
IS

   FUNCTION ACCOUNT_NAME(
      P_ACCOUNT_CODE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_ACCOUNT_LIST.ACCOUNT_NAME      (
         P_ACCOUNT_CODE );
         RETURN ret_value;
   END ACCOUNT_NAME;
   FUNCTION SORT_ORDER(
      P_ACCOUNT_CODE IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_ACCOUNT_LIST.SORT_ORDER      (
         P_ACCOUNT_CODE );
         RETURN ret_value;
   END SORT_ORDER;
   FUNCTION TEXT_3(
      P_ACCOUNT_CODE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_ACCOUNT_LIST.TEXT_3      (
         P_ACCOUNT_CODE );
         RETURN ret_value;
   END TEXT_3;
   FUNCTION VALUE_16(
      P_ACCOUNT_CODE IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_ACCOUNT_LIST.VALUE_16      (
         P_ACCOUNT_CODE );
         RETURN ret_value;
   END VALUE_16;
   FUNCTION VALUE_18(
      P_ACCOUNT_CODE IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_ACCOUNT_LIST.VALUE_18      (
         P_ACCOUNT_CODE );
         RETURN ret_value;
   END VALUE_18;
   FUNCTION VALUE_21(
      P_ACCOUNT_CODE IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_ACCOUNT_LIST.VALUE_21      (
         P_ACCOUNT_CODE );
         RETURN ret_value;
   END VALUE_21;
   FUNCTION VALUE_27(
      P_ACCOUNT_CODE IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_ACCOUNT_LIST.VALUE_27      (
         P_ACCOUNT_CODE );
         RETURN ret_value;
   END VALUE_27;
   FUNCTION VALUE_30(
      P_ACCOUNT_CODE IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_ACCOUNT_LIST.VALUE_30      (
         P_ACCOUNT_CODE );
         RETURN ret_value;
   END VALUE_30;
   FUNCTION APPROVAL_BY(
      P_ACCOUNT_CODE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (30) ;
   BEGIN
      ret_value := EC_ACCOUNT_LIST.APPROVAL_BY      (
         P_ACCOUNT_CODE );
         RETURN ret_value;
   END APPROVAL_BY;
   FUNCTION APPROVAL_STATE(
      P_ACCOUNT_CODE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_ACCOUNT_LIST.APPROVAL_STATE      (
         P_ACCOUNT_CODE );
         RETURN ret_value;
   END APPROVAL_STATE;
   FUNCTION LINE_ITEM_BASED_TYPE(
      P_ACCOUNT_CODE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_ACCOUNT_LIST.LINE_ITEM_BASED_TYPE      (
         P_ACCOUNT_CODE );
         RETURN ret_value;
   END LINE_ITEM_BASED_TYPE;
   FUNCTION VALUE_23(
      P_ACCOUNT_CODE IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_ACCOUNT_LIST.VALUE_23      (
         P_ACCOUNT_CODE );
         RETURN ret_value;
   END VALUE_23;
   FUNCTION VALUE_28(
      P_ACCOUNT_CODE IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_ACCOUNT_LIST.VALUE_28      (
         P_ACCOUNT_CODE );
         RETURN ret_value;
   END VALUE_28;
   FUNCTION VALUE_5(
      P_ACCOUNT_CODE IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_ACCOUNT_LIST.VALUE_5      (
         P_ACCOUNT_CODE );
         RETURN ret_value;
   END VALUE_5;
   FUNCTION PRODUCT_ID(
      P_ACCOUNT_CODE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_ACCOUNT_LIST.PRODUCT_ID      (
         P_ACCOUNT_CODE );
         RETURN ret_value;
   END PRODUCT_ID;
   FUNCTION TEXT_7(
      P_ACCOUNT_CODE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_ACCOUNT_LIST.TEXT_7      (
         P_ACCOUNT_CODE );
         RETURN ret_value;
   END TEXT_7;
   FUNCTION TEXT_8(
      P_ACCOUNT_CODE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_ACCOUNT_LIST.TEXT_8      (
         P_ACCOUNT_CODE );
         RETURN ret_value;
   END TEXT_8;
   FUNCTION VALUE_29(
      P_ACCOUNT_CODE IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_ACCOUNT_LIST.VALUE_29      (
         P_ACCOUNT_CODE );
         RETURN ret_value;
   END VALUE_29;
   FUNCTION DATE_3(
      P_ACCOUNT_CODE IN VARCHAR2)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_ACCOUNT_LIST.DATE_3      (
         P_ACCOUNT_CODE );
         RETURN ret_value;
   END DATE_3;
   FUNCTION DATE_5(
      P_ACCOUNT_CODE IN VARCHAR2)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_ACCOUNT_LIST.DATE_5      (
         P_ACCOUNT_CODE );
         RETURN ret_value;
   END DATE_5;
   FUNCTION QTY3_REVN_MAPPING(
      P_ACCOUNT_CODE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_ACCOUNT_LIST.QTY3_REVN_MAPPING      (
         P_ACCOUNT_CODE );
         RETURN ret_value;
   END QTY3_REVN_MAPPING;
   FUNCTION TEXT_1(
      P_ACCOUNT_CODE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_ACCOUNT_LIST.TEXT_1      (
         P_ACCOUNT_CODE );
         RETURN ret_value;
   END TEXT_1;
   FUNCTION TEXT_14(
      P_ACCOUNT_CODE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_ACCOUNT_LIST.TEXT_14      (
         P_ACCOUNT_CODE );
         RETURN ret_value;
   END TEXT_14;
   FUNCTION TEXT_6(
      P_ACCOUNT_CODE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_ACCOUNT_LIST.TEXT_6      (
         P_ACCOUNT_CODE );
         RETURN ret_value;
   END TEXT_6;
   FUNCTION TEXT_9(
      P_ACCOUNT_CODE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_ACCOUNT_LIST.TEXT_9      (
         P_ACCOUNT_CODE );
         RETURN ret_value;
   END TEXT_9;
   FUNCTION VALUE_12(
      P_ACCOUNT_CODE IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_ACCOUNT_LIST.VALUE_12      (
         P_ACCOUNT_CODE );
         RETURN ret_value;
   END VALUE_12;
   FUNCTION VALUE_22(
      P_ACCOUNT_CODE IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_ACCOUNT_LIST.VALUE_22      (
         P_ACCOUNT_CODE );
         RETURN ret_value;
   END VALUE_22;
   FUNCTION VALUE_26(
      P_ACCOUNT_CODE IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_ACCOUNT_LIST.VALUE_26      (
         P_ACCOUNT_CODE );
         RETURN ret_value;
   END VALUE_26;
   FUNCTION VALUE_6(
      P_ACCOUNT_CODE IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_ACCOUNT_LIST.VALUE_6      (
         P_ACCOUNT_CODE );
         RETURN ret_value;
   END VALUE_6;
   FUNCTION DATE_2(
      P_ACCOUNT_CODE IN VARCHAR2)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_ACCOUNT_LIST.DATE_2      (
         P_ACCOUNT_CODE );
         RETURN ret_value;
   END DATE_2;
   FUNCTION QTY1_REVN_MAPPING(
      P_ACCOUNT_CODE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_ACCOUNT_LIST.QTY1_REVN_MAPPING      (
         P_ACCOUNT_CODE );
         RETURN ret_value;
   END QTY1_REVN_MAPPING;
   FUNCTION QTY4_REVN_MAPPING(
      P_ACCOUNT_CODE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_ACCOUNT_LIST.QTY4_REVN_MAPPING      (
         P_ACCOUNT_CODE );
         RETURN ret_value;
   END QTY4_REVN_MAPPING;
   FUNCTION RECORD_STATUS(
      P_ACCOUNT_CODE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_ACCOUNT_LIST.RECORD_STATUS      (
         P_ACCOUNT_CODE );
         RETURN ret_value;
   END RECORD_STATUS;
   FUNCTION VALUE_1(
      P_ACCOUNT_CODE IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_ACCOUNT_LIST.VALUE_1      (
         P_ACCOUNT_CODE );
         RETURN ret_value;
   END VALUE_1;
   FUNCTION VALUE_15(
      P_ACCOUNT_CODE IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_ACCOUNT_LIST.VALUE_15      (
         P_ACCOUNT_CODE );
         RETURN ret_value;
   END VALUE_15;
   FUNCTION VALUE_19(
      P_ACCOUNT_CODE IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_ACCOUNT_LIST.VALUE_19      (
         P_ACCOUNT_CODE );
         RETURN ret_value;
   END VALUE_19;
   FUNCTION APPROVAL_DATE(
      P_ACCOUNT_CODE IN VARCHAR2)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_ACCOUNT_LIST.APPROVAL_DATE      (
         P_ACCOUNT_CODE );
         RETURN ret_value;
   END APPROVAL_DATE;
   FUNCTION DESCRIPTION(
      P_ACCOUNT_CODE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_ACCOUNT_LIST.DESCRIPTION      (
         P_ACCOUNT_CODE );
         RETURN ret_value;
   END DESCRIPTION;
   FUNCTION ROW_BY_PK(
      P_ACCOUNT_CODE IN VARCHAR2)
      RETURN REC_ROW_BY_PK
   IS
      ret_value    REC_ROW_BY_PK ;
   BEGIN
      ret_value := EC_ACCOUNT_LIST.ROW_BY_PK      (
         P_ACCOUNT_CODE );
         RETURN ret_value;
   END ROW_BY_PK;
   FUNCTION TEXT_13(
      P_ACCOUNT_CODE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_ACCOUNT_LIST.TEXT_13      (
         P_ACCOUNT_CODE );
         RETURN ret_value;
   END TEXT_13;
   FUNCTION TEXT_2(
      P_ACCOUNT_CODE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_ACCOUNT_LIST.TEXT_2      (
         P_ACCOUNT_CODE );
         RETURN ret_value;
   END TEXT_2;
   FUNCTION TEXT_4(
      P_ACCOUNT_CODE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_ACCOUNT_LIST.TEXT_4      (
         P_ACCOUNT_CODE );
         RETURN ret_value;
   END TEXT_4;
   FUNCTION TEXT_5(
      P_ACCOUNT_CODE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_ACCOUNT_LIST.TEXT_5      (
         P_ACCOUNT_CODE );
         RETURN ret_value;
   END TEXT_5;
   FUNCTION VALUE_13(
      P_ACCOUNT_CODE IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_ACCOUNT_LIST.VALUE_13      (
         P_ACCOUNT_CODE );
         RETURN ret_value;
   END VALUE_13;
   FUNCTION VALUE_17(
      P_ACCOUNT_CODE IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_ACCOUNT_LIST.VALUE_17      (
         P_ACCOUNT_CODE );
         RETURN ret_value;
   END VALUE_17;
   FUNCTION VALUE_2(
      P_ACCOUNT_CODE IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_ACCOUNT_LIST.VALUE_2      (
         P_ACCOUNT_CODE );
         RETURN ret_value;
   END VALUE_2;
   FUNCTION VALUE_20(
      P_ACCOUNT_CODE IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_ACCOUNT_LIST.VALUE_20      (
         P_ACCOUNT_CODE );
         RETURN ret_value;
   END VALUE_20;
   FUNCTION VALUE_25(
      P_ACCOUNT_CODE IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_ACCOUNT_LIST.VALUE_25      (
         P_ACCOUNT_CODE );
         RETURN ret_value;
   END VALUE_25;
   FUNCTION VALUE_3(
      P_ACCOUNT_CODE IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_ACCOUNT_LIST.VALUE_3      (
         P_ACCOUNT_CODE );
         RETURN ret_value;
   END VALUE_3;
   FUNCTION VALUE_4(
      P_ACCOUNT_CODE IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_ACCOUNT_LIST.VALUE_4      (
         P_ACCOUNT_CODE );
         RETURN ret_value;
   END VALUE_4;
   FUNCTION DATE_4(
      P_ACCOUNT_CODE IN VARCHAR2)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_ACCOUNT_LIST.DATE_4      (
         P_ACCOUNT_CODE );
         RETURN ret_value;
   END DATE_4;
   FUNCTION LINE_ITEM_TYPE(
      P_ACCOUNT_CODE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_ACCOUNT_LIST.LINE_ITEM_TYPE      (
         P_ACCOUNT_CODE );
         RETURN ret_value;
   END LINE_ITEM_TYPE;
   FUNCTION REC_ID(
      P_ACCOUNT_CODE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_ACCOUNT_LIST.REC_ID      (
         P_ACCOUNT_CODE );
         RETURN ret_value;
   END REC_ID;
   FUNCTION VALUE_7(
      P_ACCOUNT_CODE IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_ACCOUNT_LIST.VALUE_7      (
         P_ACCOUNT_CODE );
         RETURN ret_value;
   END VALUE_7;
   FUNCTION VALUE_9(
      P_ACCOUNT_CODE IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_ACCOUNT_LIST.VALUE_9      (
         P_ACCOUNT_CODE );
         RETURN ret_value;
   END VALUE_9;
   FUNCTION DATE_1(
      P_ACCOUNT_CODE IN VARCHAR2)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_ACCOUNT_LIST.DATE_1      (
         P_ACCOUNT_CODE );
         RETURN ret_value;
   END DATE_1;
   FUNCTION PRICE_CONCEPT_CODE(
      P_ACCOUNT_CODE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_ACCOUNT_LIST.PRICE_CONCEPT_CODE      (
         P_ACCOUNT_CODE );
         RETURN ret_value;
   END PRICE_CONCEPT_CODE;
   FUNCTION QTY2_REVN_MAPPING(
      P_ACCOUNT_CODE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_ACCOUNT_LIST.QTY2_REVN_MAPPING      (
         P_ACCOUNT_CODE );
         RETURN ret_value;
   END QTY2_REVN_MAPPING;
   FUNCTION TEXT_10(
      P_ACCOUNT_CODE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_ACCOUNT_LIST.TEXT_10      (
         P_ACCOUNT_CODE );
         RETURN ret_value;
   END TEXT_10;
   FUNCTION TEXT_11(
      P_ACCOUNT_CODE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_ACCOUNT_LIST.TEXT_11      (
         P_ACCOUNT_CODE );
         RETURN ret_value;
   END TEXT_11;
   FUNCTION TEXT_12(
      P_ACCOUNT_CODE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_ACCOUNT_LIST.TEXT_12      (
         P_ACCOUNT_CODE );
         RETURN ret_value;
   END TEXT_12;
   FUNCTION TEXT_15(
      P_ACCOUNT_CODE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_ACCOUNT_LIST.TEXT_15      (
         P_ACCOUNT_CODE );
         RETURN ret_value;
   END TEXT_15;
   FUNCTION VALUE_10(
      P_ACCOUNT_CODE IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_ACCOUNT_LIST.VALUE_10      (
         P_ACCOUNT_CODE );
         RETURN ret_value;
   END VALUE_10;
   FUNCTION VALUE_11(
      P_ACCOUNT_CODE IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_ACCOUNT_LIST.VALUE_11      (
         P_ACCOUNT_CODE );
         RETURN ret_value;
   END VALUE_11;
   FUNCTION VALUE_14(
      P_ACCOUNT_CODE IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_ACCOUNT_LIST.VALUE_14      (
         P_ACCOUNT_CODE );
         RETURN ret_value;
   END VALUE_14;
   FUNCTION VALUE_24(
      P_ACCOUNT_CODE IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_ACCOUNT_LIST.VALUE_24      (
         P_ACCOUNT_CODE );
         RETURN ret_value;
   END VALUE_24;
   FUNCTION VALUE_8(
      P_ACCOUNT_CODE IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_ACCOUNT_LIST.VALUE_8      (
         P_ACCOUNT_CODE );
         RETURN ret_value;
   END VALUE_8;

END RP_ACCOUNT_LIST;

/
--GRANT EXECUTE ON ECKERNEL_WST.RP_ACCOUNT_LIST TO REPORT_ROLE_XXX;



 -- FINISH PKG_GEN_PKGS.sf_get_functions at:11/15/2018 11.05.07 AM


