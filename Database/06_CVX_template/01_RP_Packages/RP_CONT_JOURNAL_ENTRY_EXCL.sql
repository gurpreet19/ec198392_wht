
 -- START PKG_GEN_PKGS.sf_get_functions at:05/07/2019 10.37.54 AM


CREATE or REPLACE PACKAGE RP_CONT_JOURNAL_ENTRY_EXCL
IS

   FUNCTION COST_MAPPING_ID(
      P_JOURNAL_ENTRY_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION DATE_10(
      P_JOURNAL_ENTRY_NO IN NUMBER)
      RETURN DATE;
   FUNCTION DOCUMENT_KEY(
      P_JOURNAL_ENTRY_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION OVERRIDE(
      P_JOURNAL_ENTRY_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION REF_OBJECT_ID_7(
      P_JOURNAL_ENTRY_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_20(
      P_JOURNAL_ENTRY_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_3(
      P_JOURNAL_ENTRY_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION AMOUNT(
      P_JOURNAL_ENTRY_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION APPROVAL_BY(
      P_JOURNAL_ENTRY_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_STATE(
      P_JOURNAL_ENTRY_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION DATASET(
      P_JOURNAL_ENTRY_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION REF_OBJECT_ID_4(
      P_JOURNAL_ENTRY_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION REF_OBJECT_ID_8(
      P_JOURNAL_ENTRY_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_15(
      P_JOURNAL_ENTRY_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_16(
      P_JOURNAL_ENTRY_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_5(
      P_JOURNAL_ENTRY_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION DATE_7(
      P_JOURNAL_ENTRY_NO IN NUMBER)
      RETURN DATE;
   FUNCTION DATE_9(
      P_JOURNAL_ENTRY_NO IN NUMBER)
      RETURN DATE;
   FUNCTION NEXT_DAYTIME(
      P_JOURNAL_ENTRY_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION PREV_EQUAL_DAYTIME(
      P_JOURNAL_ENTRY_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION TEXT_7(
      P_JOURNAL_ENTRY_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_8(
      P_JOURNAL_ENTRY_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION COMMENTS(
      P_JOURNAL_ENTRY_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION DATE_3(
      P_JOURNAL_ENTRY_NO IN NUMBER)
      RETURN DATE;
   FUNCTION DATE_5(
      P_JOURNAL_ENTRY_NO IN NUMBER)
      RETURN DATE;
   FUNCTION NEXT_EQUAL_DAYTIME(
      P_JOURNAL_ENTRY_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION QTY_1(
      P_JOURNAL_ENTRY_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION REF_OBJECT_ID_2(
      P_JOURNAL_ENTRY_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION REF_OBJECT_ID_3(
      P_JOURNAL_ENTRY_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION REF_OBJECT_ID_9(
      P_JOURNAL_ENTRY_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_1(
      P_JOURNAL_ENTRY_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_11(
      P_JOURNAL_ENTRY_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_17(
      P_JOURNAL_ENTRY_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_18(
      P_JOURNAL_ENTRY_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_6(
      P_JOURNAL_ENTRY_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_9(
      P_JOURNAL_ENTRY_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_6(
      P_JOURNAL_ENTRY_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION CONTRACT_ID(
      P_JOURNAL_ENTRY_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION DATE_2(
      P_JOURNAL_ENTRY_NO IN NUMBER)
      RETURN DATE;
   FUNCTION PREV_DAYTIME(
      P_JOURNAL_ENTRY_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION RECORD_STATUS(
      P_JOURNAL_ENTRY_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION REF_OBJECT_ID_5(
      P_JOURNAL_ENTRY_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_19(
      P_JOURNAL_ENTRY_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_1(
      P_JOURNAL_ENTRY_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION APPROVAL_DATE(
      P_JOURNAL_ENTRY_NO IN NUMBER)
      RETURN DATE;
   FUNCTION DATE_6(
      P_JOURNAL_ENTRY_NO IN NUMBER)
      RETURN DATE;
   FUNCTION REF_OBJECT_ID_1(
      P_JOURNAL_ENTRY_NO IN NUMBER)
      RETURN VARCHAR2;
      TYPE REC_ROW_BY_PK IS RECORD (
         JOURNAL_ENTRY_NO NUMBER ,
         DOCUMENT_KEY VARCHAR2 (240) ,
         COST_MAPPING_ID VARCHAR2 (32) ,
         REF_JOURNAL_ENTRY_SRC VARCHAR2 (32) ,
         REF_JOURNAL_ENTRY_NO NUMBER ,
         DAYTIME  DATE ,
         PERIOD  DATE ,
         DATASET VARCHAR2 (32) ,
         COMMENTS VARCHAR2 (2000) ,
         AMOUNT NUMBER ,
         QTY_1 NUMBER ,
         OVERRIDE VARCHAR2 (32) ,
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
         TEXT_16 VARCHAR2 (240) ,
         TEXT_17 VARCHAR2 (240) ,
         TEXT_18 VARCHAR2 (240) ,
         TEXT_19 VARCHAR2 (240) ,
         TEXT_20 VARCHAR2 (240) ,
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
         REF_OBJECT_ID_6 VARCHAR2 (32) ,
         REF_OBJECT_ID_7 VARCHAR2 (32) ,
         REF_OBJECT_ID_8 VARCHAR2 (32) ,
         REF_OBJECT_ID_9 VARCHAR2 (32) ,
         REF_OBJECT_ID_10 VARCHAR2 (32) ,
         CONTRACT_ID VARCHAR2 (32) ,
         CONTRACT_CODE VARCHAR2 (32) ,
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
      P_JOURNAL_ENTRY_NO IN NUMBER)
      RETURN REC_ROW_BY_PK;
   FUNCTION TEXT_12(
      P_JOURNAL_ENTRY_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_2(
      P_JOURNAL_ENTRY_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_4(
      P_JOURNAL_ENTRY_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_5(
      P_JOURNAL_ENTRY_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_2(
      P_JOURNAL_ENTRY_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_3(
      P_JOURNAL_ENTRY_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_4(
      P_JOURNAL_ENTRY_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION CONTRACT_CODE(
      P_JOURNAL_ENTRY_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION DATE_4(
      P_JOURNAL_ENTRY_NO IN NUMBER)
      RETURN DATE;
   FUNCTION PERIOD(
      P_JOURNAL_ENTRY_NO IN NUMBER)
      RETURN DATE;
   FUNCTION REC_ID(
      P_JOURNAL_ENTRY_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION REF_JOURNAL_ENTRY_NO(
      P_JOURNAL_ENTRY_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION REF_JOURNAL_ENTRY_SRC(
      P_JOURNAL_ENTRY_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION REF_OBJECT_ID_10(
      P_JOURNAL_ENTRY_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION REF_OBJECT_ID_6(
      P_JOURNAL_ENTRY_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_13(
      P_JOURNAL_ENTRY_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_7(
      P_JOURNAL_ENTRY_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_9(
      P_JOURNAL_ENTRY_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION DATE_1(
      P_JOURNAL_ENTRY_NO IN NUMBER)
      RETURN DATE;
   FUNCTION DATE_8(
      P_JOURNAL_ENTRY_NO IN NUMBER)
      RETURN DATE;
   FUNCTION DAYTIME(
      P_JOURNAL_ENTRY_NO IN NUMBER)
      RETURN DATE;
   FUNCTION TEXT_10(
      P_JOURNAL_ENTRY_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_14(
      P_JOURNAL_ENTRY_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_10(
      P_JOURNAL_ENTRY_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_8(
      P_JOURNAL_ENTRY_NO IN NUMBER)
      RETURN NUMBER;

END RP_CONT_JOURNAL_ENTRY_EXCL;

/



CREATE or REPLACE PACKAGE BODY RP_CONT_JOURNAL_ENTRY_EXCL
IS

   FUNCTION COST_MAPPING_ID(
      P_JOURNAL_ENTRY_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_CONT_JOURNAL_ENTRY_EXCL.COST_MAPPING_ID      (
         P_JOURNAL_ENTRY_NO );
         RETURN ret_value;
   END COST_MAPPING_ID;
   FUNCTION DATE_10(
      P_JOURNAL_ENTRY_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CONT_JOURNAL_ENTRY_EXCL.DATE_10      (
         P_JOURNAL_ENTRY_NO );
         RETURN ret_value;
   END DATE_10;
   FUNCTION DOCUMENT_KEY(
      P_JOURNAL_ENTRY_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_CONT_JOURNAL_ENTRY_EXCL.DOCUMENT_KEY      (
         P_JOURNAL_ENTRY_NO );
         RETURN ret_value;
   END DOCUMENT_KEY;
   FUNCTION OVERRIDE(
      P_JOURNAL_ENTRY_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_CONT_JOURNAL_ENTRY_EXCL.OVERRIDE      (
         P_JOURNAL_ENTRY_NO );
         RETURN ret_value;
   END OVERRIDE;
   FUNCTION REF_OBJECT_ID_7(
      P_JOURNAL_ENTRY_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_CONT_JOURNAL_ENTRY_EXCL.REF_OBJECT_ID_7      (
         P_JOURNAL_ENTRY_NO );
         RETURN ret_value;
   END REF_OBJECT_ID_7;
   FUNCTION TEXT_20(
      P_JOURNAL_ENTRY_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_CONT_JOURNAL_ENTRY_EXCL.TEXT_20      (
         P_JOURNAL_ENTRY_NO );
         RETURN ret_value;
   END TEXT_20;
   FUNCTION TEXT_3(
      P_JOURNAL_ENTRY_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_CONT_JOURNAL_ENTRY_EXCL.TEXT_3      (
         P_JOURNAL_ENTRY_NO );
         RETURN ret_value;
   END TEXT_3;
   FUNCTION AMOUNT(
      P_JOURNAL_ENTRY_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CONT_JOURNAL_ENTRY_EXCL.AMOUNT      (
         P_JOURNAL_ENTRY_NO );
         RETURN ret_value;
   END AMOUNT;
   FUNCTION APPROVAL_BY(
      P_JOURNAL_ENTRY_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (30) ;
   BEGIN
      ret_value := EC_CONT_JOURNAL_ENTRY_EXCL.APPROVAL_BY      (
         P_JOURNAL_ENTRY_NO );
         RETURN ret_value;
   END APPROVAL_BY;
   FUNCTION APPROVAL_STATE(
      P_JOURNAL_ENTRY_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_CONT_JOURNAL_ENTRY_EXCL.APPROVAL_STATE      (
         P_JOURNAL_ENTRY_NO );
         RETURN ret_value;
   END APPROVAL_STATE;
   FUNCTION DATASET(
      P_JOURNAL_ENTRY_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_CONT_JOURNAL_ENTRY_EXCL.DATASET      (
         P_JOURNAL_ENTRY_NO );
         RETURN ret_value;
   END DATASET;
   FUNCTION REF_OBJECT_ID_4(
      P_JOURNAL_ENTRY_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_CONT_JOURNAL_ENTRY_EXCL.REF_OBJECT_ID_4      (
         P_JOURNAL_ENTRY_NO );
         RETURN ret_value;
   END REF_OBJECT_ID_4;
   FUNCTION REF_OBJECT_ID_8(
      P_JOURNAL_ENTRY_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_CONT_JOURNAL_ENTRY_EXCL.REF_OBJECT_ID_8      (
         P_JOURNAL_ENTRY_NO );
         RETURN ret_value;
   END REF_OBJECT_ID_8;
   FUNCTION TEXT_15(
      P_JOURNAL_ENTRY_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_CONT_JOURNAL_ENTRY_EXCL.TEXT_15      (
         P_JOURNAL_ENTRY_NO );
         RETURN ret_value;
   END TEXT_15;
   FUNCTION TEXT_16(
      P_JOURNAL_ENTRY_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_CONT_JOURNAL_ENTRY_EXCL.TEXT_16      (
         P_JOURNAL_ENTRY_NO );
         RETURN ret_value;
   END TEXT_16;
   FUNCTION VALUE_5(
      P_JOURNAL_ENTRY_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CONT_JOURNAL_ENTRY_EXCL.VALUE_5      (
         P_JOURNAL_ENTRY_NO );
         RETURN ret_value;
   END VALUE_5;
   FUNCTION DATE_7(
      P_JOURNAL_ENTRY_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CONT_JOURNAL_ENTRY_EXCL.DATE_7      (
         P_JOURNAL_ENTRY_NO );
         RETURN ret_value;
   END DATE_7;
   FUNCTION DATE_9(
      P_JOURNAL_ENTRY_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CONT_JOURNAL_ENTRY_EXCL.DATE_9      (
         P_JOURNAL_ENTRY_NO );
         RETURN ret_value;
   END DATE_9;
   FUNCTION NEXT_DAYTIME(
      P_JOURNAL_ENTRY_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CONT_JOURNAL_ENTRY_EXCL.NEXT_DAYTIME      (
         P_JOURNAL_ENTRY_NO,
         P_NUM_ROWS );
         RETURN ret_value;
   END NEXT_DAYTIME;
   FUNCTION PREV_EQUAL_DAYTIME(
      P_JOURNAL_ENTRY_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CONT_JOURNAL_ENTRY_EXCL.PREV_EQUAL_DAYTIME      (
         P_JOURNAL_ENTRY_NO,
         P_NUM_ROWS );
         RETURN ret_value;
   END PREV_EQUAL_DAYTIME;
   FUNCTION TEXT_7(
      P_JOURNAL_ENTRY_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_CONT_JOURNAL_ENTRY_EXCL.TEXT_7      (
         P_JOURNAL_ENTRY_NO );
         RETURN ret_value;
   END TEXT_7;
   FUNCTION TEXT_8(
      P_JOURNAL_ENTRY_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_CONT_JOURNAL_ENTRY_EXCL.TEXT_8      (
         P_JOURNAL_ENTRY_NO );
         RETURN ret_value;
   END TEXT_8;
   FUNCTION COMMENTS(
      P_JOURNAL_ENTRY_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_CONT_JOURNAL_ENTRY_EXCL.COMMENTS      (
         P_JOURNAL_ENTRY_NO );
         RETURN ret_value;
   END COMMENTS;
   FUNCTION DATE_3(
      P_JOURNAL_ENTRY_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CONT_JOURNAL_ENTRY_EXCL.DATE_3      (
         P_JOURNAL_ENTRY_NO );
         RETURN ret_value;
   END DATE_3;
   FUNCTION DATE_5(
      P_JOURNAL_ENTRY_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CONT_JOURNAL_ENTRY_EXCL.DATE_5      (
         P_JOURNAL_ENTRY_NO );
         RETURN ret_value;
   END DATE_5;
   FUNCTION NEXT_EQUAL_DAYTIME(
      P_JOURNAL_ENTRY_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CONT_JOURNAL_ENTRY_EXCL.NEXT_EQUAL_DAYTIME      (
         P_JOURNAL_ENTRY_NO,
         P_NUM_ROWS );
         RETURN ret_value;
   END NEXT_EQUAL_DAYTIME;
   FUNCTION QTY_1(
      P_JOURNAL_ENTRY_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CONT_JOURNAL_ENTRY_EXCL.QTY_1      (
         P_JOURNAL_ENTRY_NO );
         RETURN ret_value;
   END QTY_1;
   FUNCTION REF_OBJECT_ID_2(
      P_JOURNAL_ENTRY_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_CONT_JOURNAL_ENTRY_EXCL.REF_OBJECT_ID_2      (
         P_JOURNAL_ENTRY_NO );
         RETURN ret_value;
   END REF_OBJECT_ID_2;
   FUNCTION REF_OBJECT_ID_3(
      P_JOURNAL_ENTRY_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_CONT_JOURNAL_ENTRY_EXCL.REF_OBJECT_ID_3      (
         P_JOURNAL_ENTRY_NO );
         RETURN ret_value;
   END REF_OBJECT_ID_3;
   FUNCTION REF_OBJECT_ID_9(
      P_JOURNAL_ENTRY_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_CONT_JOURNAL_ENTRY_EXCL.REF_OBJECT_ID_9      (
         P_JOURNAL_ENTRY_NO );
         RETURN ret_value;
   END REF_OBJECT_ID_9;
   FUNCTION TEXT_1(
      P_JOURNAL_ENTRY_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_CONT_JOURNAL_ENTRY_EXCL.TEXT_1      (
         P_JOURNAL_ENTRY_NO );
         RETURN ret_value;
   END TEXT_1;
   FUNCTION TEXT_11(
      P_JOURNAL_ENTRY_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_CONT_JOURNAL_ENTRY_EXCL.TEXT_11      (
         P_JOURNAL_ENTRY_NO );
         RETURN ret_value;
   END TEXT_11;
   FUNCTION TEXT_17(
      P_JOURNAL_ENTRY_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_CONT_JOURNAL_ENTRY_EXCL.TEXT_17      (
         P_JOURNAL_ENTRY_NO );
         RETURN ret_value;
   END TEXT_17;
   FUNCTION TEXT_18(
      P_JOURNAL_ENTRY_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_CONT_JOURNAL_ENTRY_EXCL.TEXT_18      (
         P_JOURNAL_ENTRY_NO );
         RETURN ret_value;
   END TEXT_18;
   FUNCTION TEXT_6(
      P_JOURNAL_ENTRY_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_CONT_JOURNAL_ENTRY_EXCL.TEXT_6      (
         P_JOURNAL_ENTRY_NO );
         RETURN ret_value;
   END TEXT_6;
   FUNCTION TEXT_9(
      P_JOURNAL_ENTRY_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_CONT_JOURNAL_ENTRY_EXCL.TEXT_9      (
         P_JOURNAL_ENTRY_NO );
         RETURN ret_value;
   END TEXT_9;
   FUNCTION VALUE_6(
      P_JOURNAL_ENTRY_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CONT_JOURNAL_ENTRY_EXCL.VALUE_6      (
         P_JOURNAL_ENTRY_NO );
         RETURN ret_value;
   END VALUE_6;
   FUNCTION CONTRACT_ID(
      P_JOURNAL_ENTRY_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_CONT_JOURNAL_ENTRY_EXCL.CONTRACT_ID      (
         P_JOURNAL_ENTRY_NO );
         RETURN ret_value;
   END CONTRACT_ID;
   FUNCTION DATE_2(
      P_JOURNAL_ENTRY_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CONT_JOURNAL_ENTRY_EXCL.DATE_2      (
         P_JOURNAL_ENTRY_NO );
         RETURN ret_value;
   END DATE_2;
   FUNCTION PREV_DAYTIME(
      P_JOURNAL_ENTRY_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CONT_JOURNAL_ENTRY_EXCL.PREV_DAYTIME      (
         P_JOURNAL_ENTRY_NO,
         P_NUM_ROWS );
         RETURN ret_value;
   END PREV_DAYTIME;
   FUNCTION RECORD_STATUS(
      P_JOURNAL_ENTRY_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_CONT_JOURNAL_ENTRY_EXCL.RECORD_STATUS      (
         P_JOURNAL_ENTRY_NO );
         RETURN ret_value;
   END RECORD_STATUS;
   FUNCTION REF_OBJECT_ID_5(
      P_JOURNAL_ENTRY_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_CONT_JOURNAL_ENTRY_EXCL.REF_OBJECT_ID_5      (
         P_JOURNAL_ENTRY_NO );
         RETURN ret_value;
   END REF_OBJECT_ID_5;
   FUNCTION TEXT_19(
      P_JOURNAL_ENTRY_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_CONT_JOURNAL_ENTRY_EXCL.TEXT_19      (
         P_JOURNAL_ENTRY_NO );
         RETURN ret_value;
   END TEXT_19;
   FUNCTION VALUE_1(
      P_JOURNAL_ENTRY_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CONT_JOURNAL_ENTRY_EXCL.VALUE_1      (
         P_JOURNAL_ENTRY_NO );
         RETURN ret_value;
   END VALUE_1;
   FUNCTION APPROVAL_DATE(
      P_JOURNAL_ENTRY_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CONT_JOURNAL_ENTRY_EXCL.APPROVAL_DATE      (
         P_JOURNAL_ENTRY_NO );
         RETURN ret_value;
   END APPROVAL_DATE;
   FUNCTION DATE_6(
      P_JOURNAL_ENTRY_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CONT_JOURNAL_ENTRY_EXCL.DATE_6      (
         P_JOURNAL_ENTRY_NO );
         RETURN ret_value;
   END DATE_6;
   FUNCTION REF_OBJECT_ID_1(
      P_JOURNAL_ENTRY_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_CONT_JOURNAL_ENTRY_EXCL.REF_OBJECT_ID_1      (
         P_JOURNAL_ENTRY_NO );
         RETURN ret_value;
   END REF_OBJECT_ID_1;
   FUNCTION ROW_BY_PK(
      P_JOURNAL_ENTRY_NO IN NUMBER)
      RETURN REC_ROW_BY_PK
   IS
      ret_value    REC_ROW_BY_PK ;
   BEGIN
      ret_value := EC_CONT_JOURNAL_ENTRY_EXCL.ROW_BY_PK      (
         P_JOURNAL_ENTRY_NO );
         RETURN ret_value;
   END ROW_BY_PK;
   FUNCTION TEXT_12(
      P_JOURNAL_ENTRY_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_CONT_JOURNAL_ENTRY_EXCL.TEXT_12      (
         P_JOURNAL_ENTRY_NO );
         RETURN ret_value;
   END TEXT_12;
   FUNCTION TEXT_2(
      P_JOURNAL_ENTRY_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_CONT_JOURNAL_ENTRY_EXCL.TEXT_2      (
         P_JOURNAL_ENTRY_NO );
         RETURN ret_value;
   END TEXT_2;
   FUNCTION TEXT_4(
      P_JOURNAL_ENTRY_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_CONT_JOURNAL_ENTRY_EXCL.TEXT_4      (
         P_JOURNAL_ENTRY_NO );
         RETURN ret_value;
   END TEXT_4;
   FUNCTION TEXT_5(
      P_JOURNAL_ENTRY_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_CONT_JOURNAL_ENTRY_EXCL.TEXT_5      (
         P_JOURNAL_ENTRY_NO );
         RETURN ret_value;
   END TEXT_5;
   FUNCTION VALUE_2(
      P_JOURNAL_ENTRY_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CONT_JOURNAL_ENTRY_EXCL.VALUE_2      (
         P_JOURNAL_ENTRY_NO );
         RETURN ret_value;
   END VALUE_2;
   FUNCTION VALUE_3(
      P_JOURNAL_ENTRY_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CONT_JOURNAL_ENTRY_EXCL.VALUE_3      (
         P_JOURNAL_ENTRY_NO );
         RETURN ret_value;
   END VALUE_3;
   FUNCTION VALUE_4(
      P_JOURNAL_ENTRY_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CONT_JOURNAL_ENTRY_EXCL.VALUE_4      (
         P_JOURNAL_ENTRY_NO );
         RETURN ret_value;
   END VALUE_4;
   FUNCTION CONTRACT_CODE(
      P_JOURNAL_ENTRY_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_CONT_JOURNAL_ENTRY_EXCL.CONTRACT_CODE      (
         P_JOURNAL_ENTRY_NO );
         RETURN ret_value;
   END CONTRACT_CODE;
   FUNCTION DATE_4(
      P_JOURNAL_ENTRY_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CONT_JOURNAL_ENTRY_EXCL.DATE_4      (
         P_JOURNAL_ENTRY_NO );
         RETURN ret_value;
   END DATE_4;
   FUNCTION PERIOD(
      P_JOURNAL_ENTRY_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CONT_JOURNAL_ENTRY_EXCL.PERIOD      (
         P_JOURNAL_ENTRY_NO );
         RETURN ret_value;
   END PERIOD;
   FUNCTION REC_ID(
      P_JOURNAL_ENTRY_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_CONT_JOURNAL_ENTRY_EXCL.REC_ID      (
         P_JOURNAL_ENTRY_NO );
         RETURN ret_value;
   END REC_ID;
   FUNCTION REF_JOURNAL_ENTRY_NO(
      P_JOURNAL_ENTRY_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CONT_JOURNAL_ENTRY_EXCL.REF_JOURNAL_ENTRY_NO      (
         P_JOURNAL_ENTRY_NO );
         RETURN ret_value;
   END REF_JOURNAL_ENTRY_NO;
   FUNCTION REF_JOURNAL_ENTRY_SRC(
      P_JOURNAL_ENTRY_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_CONT_JOURNAL_ENTRY_EXCL.REF_JOURNAL_ENTRY_SRC      (
         P_JOURNAL_ENTRY_NO );
         RETURN ret_value;
   END REF_JOURNAL_ENTRY_SRC;
   FUNCTION REF_OBJECT_ID_10(
      P_JOURNAL_ENTRY_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_CONT_JOURNAL_ENTRY_EXCL.REF_OBJECT_ID_10      (
         P_JOURNAL_ENTRY_NO );
         RETURN ret_value;
   END REF_OBJECT_ID_10;
   FUNCTION REF_OBJECT_ID_6(
      P_JOURNAL_ENTRY_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_CONT_JOURNAL_ENTRY_EXCL.REF_OBJECT_ID_6      (
         P_JOURNAL_ENTRY_NO );
         RETURN ret_value;
   END REF_OBJECT_ID_6;
   FUNCTION TEXT_13(
      P_JOURNAL_ENTRY_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_CONT_JOURNAL_ENTRY_EXCL.TEXT_13      (
         P_JOURNAL_ENTRY_NO );
         RETURN ret_value;
   END TEXT_13;
   FUNCTION VALUE_7(
      P_JOURNAL_ENTRY_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CONT_JOURNAL_ENTRY_EXCL.VALUE_7      (
         P_JOURNAL_ENTRY_NO );
         RETURN ret_value;
   END VALUE_7;
   FUNCTION VALUE_9(
      P_JOURNAL_ENTRY_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CONT_JOURNAL_ENTRY_EXCL.VALUE_9      (
         P_JOURNAL_ENTRY_NO );
         RETURN ret_value;
   END VALUE_9;
   FUNCTION DATE_1(
      P_JOURNAL_ENTRY_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CONT_JOURNAL_ENTRY_EXCL.DATE_1      (
         P_JOURNAL_ENTRY_NO );
         RETURN ret_value;
   END DATE_1;
   FUNCTION DATE_8(
      P_JOURNAL_ENTRY_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CONT_JOURNAL_ENTRY_EXCL.DATE_8      (
         P_JOURNAL_ENTRY_NO );
         RETURN ret_value;
   END DATE_8;
   FUNCTION DAYTIME(
      P_JOURNAL_ENTRY_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CONT_JOURNAL_ENTRY_EXCL.DAYTIME      (
         P_JOURNAL_ENTRY_NO );
         RETURN ret_value;
   END DAYTIME;
   FUNCTION TEXT_10(
      P_JOURNAL_ENTRY_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_CONT_JOURNAL_ENTRY_EXCL.TEXT_10      (
         P_JOURNAL_ENTRY_NO );
         RETURN ret_value;
   END TEXT_10;
   FUNCTION TEXT_14(
      P_JOURNAL_ENTRY_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_CONT_JOURNAL_ENTRY_EXCL.TEXT_14      (
         P_JOURNAL_ENTRY_NO );
         RETURN ret_value;
   END TEXT_14;
   FUNCTION VALUE_10(
      P_JOURNAL_ENTRY_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CONT_JOURNAL_ENTRY_EXCL.VALUE_10      (
         P_JOURNAL_ENTRY_NO );
         RETURN ret_value;
   END VALUE_10;
   FUNCTION VALUE_8(
      P_JOURNAL_ENTRY_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CONT_JOURNAL_ENTRY_EXCL.VALUE_8      (
         P_JOURNAL_ENTRY_NO );
         RETURN ret_value;
   END VALUE_8;

END RP_CONT_JOURNAL_ENTRY_EXCL;

/
--GRANT EXECUTE ON ECKERNEL_WST.RP_CONT_JOURNAL_ENTRY_EXCL TO REPORT_ROLE_XXX;



 -- FINISH PKG_GEN_PKGS.sf_get_functions at:05/07/2019 10.38.10 AM


