
 -- START PKG_GEN_PKGS.sf_get_functions at:11/15/2018 10.57.35 AM


CREATE or REPLACE PACKAGE RP_CALC_REFERENCE
IS

   FUNCTION COMMENTS(
      P_RUN_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_3(
      P_RUN_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION AMOUNT(
      P_RUN_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION APPROVAL_BY(
      P_RUN_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_STATE(
      P_RUN_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION DATASET(
      P_RUN_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION REPORTING_PERIOD(
      P_RUN_NO IN NUMBER)
      RETURN DATE;
   FUNCTION TEXT_15(
      P_RUN_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_5(
      P_RUN_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION ACCRUAL_IND(
      P_RUN_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION CALC_SCOPE(
      P_RUN_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION NEXT_DAYTIME(
      P_RUN_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION OBJECT_ID(
      P_RUN_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION PREV_EQUAL_DAYTIME(
      P_RUN_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION SEQ_NO(
      P_RUN_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION TEXT_18(
      P_RUN_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_19(
      P_RUN_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_7(
      P_RUN_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_8(
      P_RUN_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION CALC_COLLECTION_ID(
      P_RUN_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION DATE_3(
      P_RUN_NO IN NUMBER)
      RETURN DATE;
   FUNCTION DATE_5(
      P_RUN_NO IN NUMBER)
      RETURN DATE;
   FUNCTION NEXT_EQUAL_DAYTIME(
      P_RUN_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION REF_OBJECT_ID_5(
      P_RUN_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_1(
      P_RUN_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_11(
      P_RUN_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_17(
      P_RUN_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_20(
      P_RUN_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_6(
      P_RUN_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_9(
      P_RUN_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_6(
      P_RUN_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION CALCULATION_ID(
      P_RUN_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION DATE_2(
      P_RUN_NO IN NUMBER)
      RETURN DATE;
   FUNCTION OPEN_RUN_NO(
      P_RUN_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION PREV_DAYTIME(
      P_RUN_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION RECORD_STATUS(
      P_RUN_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION REF_OBJECT_ID_2(
      P_RUN_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION SUCCESSFULL(
      P_RUN_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_16(
      P_RUN_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_1(
      P_RUN_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION APPROVAL_DATE(
      P_RUN_NO IN NUMBER)
      RETURN DATE;
      TYPE REC_ROW_BY_PK IS RECORD (
         CALCULATION_ID VARCHAR2 (32) ,
         OBJECT_ID VARCHAR2 (32) ,
         CALC_COLLECTION_ID VARCHAR2 (32) ,
         DAYTIME  DATE ,
         RUN_DATE  DATE ,
         REFERENCE_ID VARCHAR2 (100) ,
         RUN_NO NUMBER ,
         PREV_RUN_NO NUMBER ,
         REPORTING_PERIOD  DATE ,
         OPEN_RUN_NO NUMBER ,
         SEQ_NO NUMBER ,
         ACCRUAL_IND VARCHAR2 (1) ,
         SUCCESSFULL VARCHAR2 (1) ,
         ACCEPT_STATUS VARCHAR2 (15) ,
         DATASET VARCHAR2 (32) ,
         COMMENTS VARCHAR2 (4000) ,
         AMOUNT NUMBER ,
         CALC_SCOPE VARCHAR2 (240) ,
         DATE_1  DATE ,
         DATE_2  DATE ,
         DATE_3  DATE ,
         DATE_4  DATE ,
         DATE_5  DATE ,
         REF_OBJECT_ID_1 VARCHAR2 (240) ,
         REF_OBJECT_ID_2 VARCHAR2 (240) ,
         REF_OBJECT_ID_3 VARCHAR2 (240) ,
         REF_OBJECT_ID_4 VARCHAR2 (240) ,
         REF_OBJECT_ID_5 VARCHAR2 (240) ,
         TEXT_1 VARCHAR2 (240) ,
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
         TEXT_2 VARCHAR2 (240) ,
         TEXT_20 VARCHAR2 (2000) ,
         TEXT_3 VARCHAR2 (240) ,
         TEXT_4 VARCHAR2 (240) ,
         TEXT_5 VARCHAR2 (240) ,
         TEXT_6 VARCHAR2 (240) ,
         TEXT_7 VARCHAR2 (240) ,
         TEXT_8 VARCHAR2 (240) ,
         TEXT_9 VARCHAR2 (240) ,
         VALUE_1 NUMBER ,
         VALUE_10 NUMBER ,
         VALUE_2 NUMBER ,
         VALUE_3 NUMBER ,
         VALUE_4 NUMBER ,
         VALUE_5 NUMBER ,
         VALUE_6 NUMBER ,
         VALUE_7 NUMBER ,
         VALUE_8 NUMBER ,
         VALUE_9 NUMBER ,
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
      P_RUN_NO IN NUMBER)
      RETURN REC_ROW_BY_PK;
   FUNCTION TEXT_12(
      P_RUN_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_2(
      P_RUN_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_4(
      P_RUN_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_5(
      P_RUN_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_2(
      P_RUN_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_3(
      P_RUN_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_4(
      P_RUN_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION DATE_4(
      P_RUN_NO IN NUMBER)
      RETURN DATE;
   FUNCTION REC_ID(
      P_RUN_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION REF_OBJECT_ID_1(
      P_RUN_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_13(
      P_RUN_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_7(
      P_RUN_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_9(
      P_RUN_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION ACCEPT_STATUS(
      P_RUN_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION DATE_1(
      P_RUN_NO IN NUMBER)
      RETURN DATE;
   FUNCTION DAYTIME(
      P_RUN_NO IN NUMBER)
      RETURN DATE;
   FUNCTION PREV_RUN_NO(
      P_RUN_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION REFERENCE_ID(
      P_RUN_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION REF_OBJECT_ID_3(
      P_RUN_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION REF_OBJECT_ID_4(
      P_RUN_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION RUN_DATE(
      P_RUN_NO IN NUMBER)
      RETURN DATE;
   FUNCTION TEXT_10(
      P_RUN_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_14(
      P_RUN_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_10(
      P_RUN_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_8(
      P_RUN_NO IN NUMBER)
      RETURN NUMBER;

END RP_CALC_REFERENCE;

/



CREATE or REPLACE PACKAGE BODY RP_CALC_REFERENCE
IS

   FUNCTION COMMENTS(
      P_RUN_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (4000) ;
   BEGIN
      ret_value := EC_CALC_REFERENCE.COMMENTS      (
         P_RUN_NO );
         RETURN ret_value;
   END COMMENTS;
   FUNCTION TEXT_3(
      P_RUN_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_CALC_REFERENCE.TEXT_3      (
         P_RUN_NO );
         RETURN ret_value;
   END TEXT_3;
   FUNCTION AMOUNT(
      P_RUN_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CALC_REFERENCE.AMOUNT      (
         P_RUN_NO );
         RETURN ret_value;
   END AMOUNT;
   FUNCTION APPROVAL_BY(
      P_RUN_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (30) ;
   BEGIN
      ret_value := EC_CALC_REFERENCE.APPROVAL_BY      (
         P_RUN_NO );
         RETURN ret_value;
   END APPROVAL_BY;
   FUNCTION APPROVAL_STATE(
      P_RUN_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_CALC_REFERENCE.APPROVAL_STATE      (
         P_RUN_NO );
         RETURN ret_value;
   END APPROVAL_STATE;
   FUNCTION DATASET(
      P_RUN_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_CALC_REFERENCE.DATASET      (
         P_RUN_NO );
         RETURN ret_value;
   END DATASET;
   FUNCTION REPORTING_PERIOD(
      P_RUN_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CALC_REFERENCE.REPORTING_PERIOD      (
         P_RUN_NO );
         RETURN ret_value;
   END REPORTING_PERIOD;
   FUNCTION TEXT_15(
      P_RUN_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_CALC_REFERENCE.TEXT_15      (
         P_RUN_NO );
         RETURN ret_value;
   END TEXT_15;
   FUNCTION VALUE_5(
      P_RUN_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CALC_REFERENCE.VALUE_5      (
         P_RUN_NO );
         RETURN ret_value;
   END VALUE_5;
   FUNCTION ACCRUAL_IND(
      P_RUN_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_CALC_REFERENCE.ACCRUAL_IND      (
         P_RUN_NO );
         RETURN ret_value;
   END ACCRUAL_IND;
   FUNCTION CALC_SCOPE(
      P_RUN_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_CALC_REFERENCE.CALC_SCOPE      (
         P_RUN_NO );
         RETURN ret_value;
   END CALC_SCOPE;
   FUNCTION NEXT_DAYTIME(
      P_RUN_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CALC_REFERENCE.NEXT_DAYTIME      (
         P_RUN_NO,
         P_NUM_ROWS );
         RETURN ret_value;
   END NEXT_DAYTIME;
   FUNCTION OBJECT_ID(
      P_RUN_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_CALC_REFERENCE.OBJECT_ID      (
         P_RUN_NO );
         RETURN ret_value;
   END OBJECT_ID;
   FUNCTION PREV_EQUAL_DAYTIME(
      P_RUN_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CALC_REFERENCE.PREV_EQUAL_DAYTIME      (
         P_RUN_NO,
         P_NUM_ROWS );
         RETURN ret_value;
   END PREV_EQUAL_DAYTIME;
   FUNCTION SEQ_NO(
      P_RUN_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CALC_REFERENCE.SEQ_NO      (
         P_RUN_NO );
         RETURN ret_value;
   END SEQ_NO;
   FUNCTION TEXT_18(
      P_RUN_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_CALC_REFERENCE.TEXT_18      (
         P_RUN_NO );
         RETURN ret_value;
   END TEXT_18;
   FUNCTION TEXT_19(
      P_RUN_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_CALC_REFERENCE.TEXT_19      (
         P_RUN_NO );
         RETURN ret_value;
   END TEXT_19;
   FUNCTION TEXT_7(
      P_RUN_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_CALC_REFERENCE.TEXT_7      (
         P_RUN_NO );
         RETURN ret_value;
   END TEXT_7;
   FUNCTION TEXT_8(
      P_RUN_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_CALC_REFERENCE.TEXT_8      (
         P_RUN_NO );
         RETURN ret_value;
   END TEXT_8;
   FUNCTION CALC_COLLECTION_ID(
      P_RUN_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_CALC_REFERENCE.CALC_COLLECTION_ID      (
         P_RUN_NO );
         RETURN ret_value;
   END CALC_COLLECTION_ID;
   FUNCTION DATE_3(
      P_RUN_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CALC_REFERENCE.DATE_3      (
         P_RUN_NO );
         RETURN ret_value;
   END DATE_3;
   FUNCTION DATE_5(
      P_RUN_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CALC_REFERENCE.DATE_5      (
         P_RUN_NO );
         RETURN ret_value;
   END DATE_5;
   FUNCTION NEXT_EQUAL_DAYTIME(
      P_RUN_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CALC_REFERENCE.NEXT_EQUAL_DAYTIME      (
         P_RUN_NO,
         P_NUM_ROWS );
         RETURN ret_value;
   END NEXT_EQUAL_DAYTIME;
   FUNCTION REF_OBJECT_ID_5(
      P_RUN_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_CALC_REFERENCE.REF_OBJECT_ID_5      (
         P_RUN_NO );
         RETURN ret_value;
   END REF_OBJECT_ID_5;
   FUNCTION TEXT_1(
      P_RUN_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_CALC_REFERENCE.TEXT_1      (
         P_RUN_NO );
         RETURN ret_value;
   END TEXT_1;
   FUNCTION TEXT_11(
      P_RUN_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_CALC_REFERENCE.TEXT_11      (
         P_RUN_NO );
         RETURN ret_value;
   END TEXT_11;
   FUNCTION TEXT_17(
      P_RUN_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_CALC_REFERENCE.TEXT_17      (
         P_RUN_NO );
         RETURN ret_value;
   END TEXT_17;
   FUNCTION TEXT_20(
      P_RUN_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_CALC_REFERENCE.TEXT_20      (
         P_RUN_NO );
         RETURN ret_value;
   END TEXT_20;
   FUNCTION TEXT_6(
      P_RUN_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_CALC_REFERENCE.TEXT_6      (
         P_RUN_NO );
         RETURN ret_value;
   END TEXT_6;
   FUNCTION TEXT_9(
      P_RUN_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_CALC_REFERENCE.TEXT_9      (
         P_RUN_NO );
         RETURN ret_value;
   END TEXT_9;
   FUNCTION VALUE_6(
      P_RUN_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CALC_REFERENCE.VALUE_6      (
         P_RUN_NO );
         RETURN ret_value;
   END VALUE_6;
   FUNCTION CALCULATION_ID(
      P_RUN_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_CALC_REFERENCE.CALCULATION_ID      (
         P_RUN_NO );
         RETURN ret_value;
   END CALCULATION_ID;
   FUNCTION DATE_2(
      P_RUN_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CALC_REFERENCE.DATE_2      (
         P_RUN_NO );
         RETURN ret_value;
   END DATE_2;
   FUNCTION OPEN_RUN_NO(
      P_RUN_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CALC_REFERENCE.OPEN_RUN_NO      (
         P_RUN_NO );
         RETURN ret_value;
   END OPEN_RUN_NO;
   FUNCTION PREV_DAYTIME(
      P_RUN_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CALC_REFERENCE.PREV_DAYTIME      (
         P_RUN_NO,
         P_NUM_ROWS );
         RETURN ret_value;
   END PREV_DAYTIME;
   FUNCTION RECORD_STATUS(
      P_RUN_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_CALC_REFERENCE.RECORD_STATUS      (
         P_RUN_NO );
         RETURN ret_value;
   END RECORD_STATUS;
   FUNCTION REF_OBJECT_ID_2(
      P_RUN_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_CALC_REFERENCE.REF_OBJECT_ID_2      (
         P_RUN_NO );
         RETURN ret_value;
   END REF_OBJECT_ID_2;
   FUNCTION SUCCESSFULL(
      P_RUN_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_CALC_REFERENCE.SUCCESSFULL      (
         P_RUN_NO );
         RETURN ret_value;
   END SUCCESSFULL;
   FUNCTION TEXT_16(
      P_RUN_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_CALC_REFERENCE.TEXT_16      (
         P_RUN_NO );
         RETURN ret_value;
   END TEXT_16;
   FUNCTION VALUE_1(
      P_RUN_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CALC_REFERENCE.VALUE_1      (
         P_RUN_NO );
         RETURN ret_value;
   END VALUE_1;
   FUNCTION APPROVAL_DATE(
      P_RUN_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CALC_REFERENCE.APPROVAL_DATE      (
         P_RUN_NO );
         RETURN ret_value;
   END APPROVAL_DATE;
   FUNCTION ROW_BY_PK(
      P_RUN_NO IN NUMBER)
      RETURN REC_ROW_BY_PK
   IS
      ret_value    REC_ROW_BY_PK ;
   BEGIN
      ret_value := EC_CALC_REFERENCE.ROW_BY_PK      (
         P_RUN_NO );
         RETURN ret_value;
   END ROW_BY_PK;
   FUNCTION TEXT_12(
      P_RUN_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_CALC_REFERENCE.TEXT_12      (
         P_RUN_NO );
         RETURN ret_value;
   END TEXT_12;
   FUNCTION TEXT_2(
      P_RUN_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_CALC_REFERENCE.TEXT_2      (
         P_RUN_NO );
         RETURN ret_value;
   END TEXT_2;
   FUNCTION TEXT_4(
      P_RUN_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_CALC_REFERENCE.TEXT_4      (
         P_RUN_NO );
         RETURN ret_value;
   END TEXT_4;
   FUNCTION TEXT_5(
      P_RUN_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_CALC_REFERENCE.TEXT_5      (
         P_RUN_NO );
         RETURN ret_value;
   END TEXT_5;
   FUNCTION VALUE_2(
      P_RUN_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CALC_REFERENCE.VALUE_2      (
         P_RUN_NO );
         RETURN ret_value;
   END VALUE_2;
   FUNCTION VALUE_3(
      P_RUN_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CALC_REFERENCE.VALUE_3      (
         P_RUN_NO );
         RETURN ret_value;
   END VALUE_3;
   FUNCTION VALUE_4(
      P_RUN_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CALC_REFERENCE.VALUE_4      (
         P_RUN_NO );
         RETURN ret_value;
   END VALUE_4;
   FUNCTION DATE_4(
      P_RUN_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CALC_REFERENCE.DATE_4      (
         P_RUN_NO );
         RETURN ret_value;
   END DATE_4;
   FUNCTION REC_ID(
      P_RUN_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_CALC_REFERENCE.REC_ID      (
         P_RUN_NO );
         RETURN ret_value;
   END REC_ID;
   FUNCTION REF_OBJECT_ID_1(
      P_RUN_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_CALC_REFERENCE.REF_OBJECT_ID_1      (
         P_RUN_NO );
         RETURN ret_value;
   END REF_OBJECT_ID_1;
   FUNCTION TEXT_13(
      P_RUN_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_CALC_REFERENCE.TEXT_13      (
         P_RUN_NO );
         RETURN ret_value;
   END TEXT_13;
   FUNCTION VALUE_7(
      P_RUN_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CALC_REFERENCE.VALUE_7      (
         P_RUN_NO );
         RETURN ret_value;
   END VALUE_7;
   FUNCTION VALUE_9(
      P_RUN_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CALC_REFERENCE.VALUE_9      (
         P_RUN_NO );
         RETURN ret_value;
   END VALUE_9;
   FUNCTION ACCEPT_STATUS(
      P_RUN_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (15) ;
   BEGIN
      ret_value := EC_CALC_REFERENCE.ACCEPT_STATUS      (
         P_RUN_NO );
         RETURN ret_value;
   END ACCEPT_STATUS;
   FUNCTION DATE_1(
      P_RUN_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CALC_REFERENCE.DATE_1      (
         P_RUN_NO );
         RETURN ret_value;
   END DATE_1;
   FUNCTION DAYTIME(
      P_RUN_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CALC_REFERENCE.DAYTIME      (
         P_RUN_NO );
         RETURN ret_value;
   END DAYTIME;
   FUNCTION PREV_RUN_NO(
      P_RUN_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CALC_REFERENCE.PREV_RUN_NO      (
         P_RUN_NO );
         RETURN ret_value;
   END PREV_RUN_NO;
   FUNCTION REFERENCE_ID(
      P_RUN_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (100) ;
   BEGIN
      ret_value := EC_CALC_REFERENCE.REFERENCE_ID      (
         P_RUN_NO );
         RETURN ret_value;
   END REFERENCE_ID;
   FUNCTION REF_OBJECT_ID_3(
      P_RUN_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_CALC_REFERENCE.REF_OBJECT_ID_3      (
         P_RUN_NO );
         RETURN ret_value;
   END REF_OBJECT_ID_3;
   FUNCTION REF_OBJECT_ID_4(
      P_RUN_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_CALC_REFERENCE.REF_OBJECT_ID_4      (
         P_RUN_NO );
         RETURN ret_value;
   END REF_OBJECT_ID_4;
   FUNCTION RUN_DATE(
      P_RUN_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CALC_REFERENCE.RUN_DATE      (
         P_RUN_NO );
         RETURN ret_value;
   END RUN_DATE;
   FUNCTION TEXT_10(
      P_RUN_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_CALC_REFERENCE.TEXT_10      (
         P_RUN_NO );
         RETURN ret_value;
   END TEXT_10;
   FUNCTION TEXT_14(
      P_RUN_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_CALC_REFERENCE.TEXT_14      (
         P_RUN_NO );
         RETURN ret_value;
   END TEXT_14;
   FUNCTION VALUE_10(
      P_RUN_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CALC_REFERENCE.VALUE_10      (
         P_RUN_NO );
         RETURN ret_value;
   END VALUE_10;
   FUNCTION VALUE_8(
      P_RUN_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CALC_REFERENCE.VALUE_8      (
         P_RUN_NO );
         RETURN ret_value;
   END VALUE_8;

END RP_CALC_REFERENCE;

/
--GRANT EXECUTE ON ECKERNEL_WST.RP_CALC_REFERENCE TO REPORT_ROLE_XXX;



 -- FINISH PKG_GEN_PKGS.sf_get_functions at:11/15/2018 10.57.48 AM


