
 -- START PKG_GEN_PKGS.sf_get_functions at:05/07/2019 08.34.26 AM


CREATE or REPLACE PACKAGE RP_OPPORTUNITY
IS

   FUNCTION TEXT_3(
      P_OPPORTUNITY_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_16(
      P_OPPORTUNITY_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_18(
      P_OPPORTUNITY_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_21(
      P_OPPORTUNITY_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_27(
      P_OPPORTUNITY_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_30(
      P_OPPORTUNITY_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION APPROVAL_BY(
      P_OPPORTUNITY_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_STATE(
      P_OPPORTUNITY_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TERM_CODE(
      P_OPPORTUNITY_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_23(
      P_OPPORTUNITY_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_28(
      P_OPPORTUNITY_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_5(
      P_OPPORTUNITY_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION NEXT_DAYTIME(
      P_OPPORTUNITY_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION PREV_EQUAL_DAYTIME(
      P_OPPORTUNITY_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION TEXT_7(
      P_OPPORTUNITY_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_8(
      P_OPPORTUNITY_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_29(
      P_OPPORTUNITY_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION DATE_3(
      P_OPPORTUNITY_NO IN NUMBER)
      RETURN DATE;
   FUNCTION DATE_5(
      P_OPPORTUNITY_NO IN NUMBER)
      RETURN DATE;
   FUNCTION NEXT_EQUAL_DAYTIME(
      P_OPPORTUNITY_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION TEXT_1(
      P_OPPORTUNITY_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_14(
      P_OPPORTUNITY_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_6(
      P_OPPORTUNITY_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_9(
      P_OPPORTUNITY_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_12(
      P_OPPORTUNITY_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_22(
      P_OPPORTUNITY_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_26(
      P_OPPORTUNITY_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_6(
      P_OPPORTUNITY_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION COMPANY_ID(
      P_OPPORTUNITY_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION CONTRACT_ID(
      P_OPPORTUNITY_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION DATE_2(
      P_OPPORTUNITY_NO IN NUMBER)
      RETURN DATE;
   FUNCTION END_DATE(
      P_OPPORTUNITY_NO IN NUMBER)
      RETURN DATE;
   FUNCTION OPPORTUNITY_NAME(
      P_OPPORTUNITY_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION PREV_DAYTIME(
      P_OPPORTUNITY_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION RECORD_STATUS(
      P_OPPORTUNITY_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_1(
      P_OPPORTUNITY_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_15(
      P_OPPORTUNITY_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_19(
      P_OPPORTUNITY_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION APPROVAL_DATE(
      P_OPPORTUNITY_NO IN NUMBER)
      RETURN DATE;
   FUNCTION FORECAST_ID(
      P_OPPORTUNITY_NO IN NUMBER)
      RETURN VARCHAR2;
      TYPE REC_ROW_BY_PK IS RECORD (
         OPPORTUNITY_NO NUMBER ,
         OPPORTUNITY_NAME VARCHAR2 (100) ,
         DAYTIME  DATE ,
         END_DATE  DATE ,
         COMPANY_ID VARCHAR2 (32) ,
         CONTRACT_ID VARCHAR2 (32) ,
         TERM_CODE VARCHAR2 (32) ,
         OPPORTUNITY_STATUS VARCHAR2 (32) ,
         PERIOD VARCHAR2 (1) ,
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
         FORECAST_ID VARCHAR2 (32) ,
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
      P_OPPORTUNITY_NO IN NUMBER)
      RETURN REC_ROW_BY_PK;
   FUNCTION TEXT_13(
      P_OPPORTUNITY_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_2(
      P_OPPORTUNITY_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_4(
      P_OPPORTUNITY_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_5(
      P_OPPORTUNITY_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_13(
      P_OPPORTUNITY_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_17(
      P_OPPORTUNITY_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_2(
      P_OPPORTUNITY_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_20(
      P_OPPORTUNITY_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_25(
      P_OPPORTUNITY_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_3(
      P_OPPORTUNITY_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_4(
      P_OPPORTUNITY_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION DATE_4(
      P_OPPORTUNITY_NO IN NUMBER)
      RETURN DATE;
   FUNCTION OPPORTUNITY_STATUS(
      P_OPPORTUNITY_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION REC_ID(
      P_OPPORTUNITY_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_7(
      P_OPPORTUNITY_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_9(
      P_OPPORTUNITY_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION DATE_1(
      P_OPPORTUNITY_NO IN NUMBER)
      RETURN DATE;
   FUNCTION DAYTIME(
      P_OPPORTUNITY_NO IN NUMBER)
      RETURN DATE;
   FUNCTION PERIOD(
      P_OPPORTUNITY_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_10(
      P_OPPORTUNITY_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_11(
      P_OPPORTUNITY_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_12(
      P_OPPORTUNITY_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_15(
      P_OPPORTUNITY_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_10(
      P_OPPORTUNITY_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_11(
      P_OPPORTUNITY_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_14(
      P_OPPORTUNITY_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_24(
      P_OPPORTUNITY_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_8(
      P_OPPORTUNITY_NO IN NUMBER)
      RETURN NUMBER;

END RP_OPPORTUNITY;

/



CREATE or REPLACE PACKAGE BODY RP_OPPORTUNITY
IS

   FUNCTION TEXT_3(
      P_OPPORTUNITY_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_OPPORTUNITY.TEXT_3      (
         P_OPPORTUNITY_NO );
         RETURN ret_value;
   END TEXT_3;
   FUNCTION VALUE_16(
      P_OPPORTUNITY_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_OPPORTUNITY.VALUE_16      (
         P_OPPORTUNITY_NO );
         RETURN ret_value;
   END VALUE_16;
   FUNCTION VALUE_18(
      P_OPPORTUNITY_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_OPPORTUNITY.VALUE_18      (
         P_OPPORTUNITY_NO );
         RETURN ret_value;
   END VALUE_18;
   FUNCTION VALUE_21(
      P_OPPORTUNITY_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_OPPORTUNITY.VALUE_21      (
         P_OPPORTUNITY_NO );
         RETURN ret_value;
   END VALUE_21;
   FUNCTION VALUE_27(
      P_OPPORTUNITY_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_OPPORTUNITY.VALUE_27      (
         P_OPPORTUNITY_NO );
         RETURN ret_value;
   END VALUE_27;
   FUNCTION VALUE_30(
      P_OPPORTUNITY_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_OPPORTUNITY.VALUE_30      (
         P_OPPORTUNITY_NO );
         RETURN ret_value;
   END VALUE_30;
   FUNCTION APPROVAL_BY(
      P_OPPORTUNITY_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (30) ;
   BEGIN
      ret_value := EC_OPPORTUNITY.APPROVAL_BY      (
         P_OPPORTUNITY_NO );
         RETURN ret_value;
   END APPROVAL_BY;
   FUNCTION APPROVAL_STATE(
      P_OPPORTUNITY_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_OPPORTUNITY.APPROVAL_STATE      (
         P_OPPORTUNITY_NO );
         RETURN ret_value;
   END APPROVAL_STATE;
   FUNCTION TERM_CODE(
      P_OPPORTUNITY_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_OPPORTUNITY.TERM_CODE      (
         P_OPPORTUNITY_NO );
         RETURN ret_value;
   END TERM_CODE;
   FUNCTION VALUE_23(
      P_OPPORTUNITY_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_OPPORTUNITY.VALUE_23      (
         P_OPPORTUNITY_NO );
         RETURN ret_value;
   END VALUE_23;
   FUNCTION VALUE_28(
      P_OPPORTUNITY_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_OPPORTUNITY.VALUE_28      (
         P_OPPORTUNITY_NO );
         RETURN ret_value;
   END VALUE_28;
   FUNCTION VALUE_5(
      P_OPPORTUNITY_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_OPPORTUNITY.VALUE_5      (
         P_OPPORTUNITY_NO );
         RETURN ret_value;
   END VALUE_5;
   FUNCTION NEXT_DAYTIME(
      P_OPPORTUNITY_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_OPPORTUNITY.NEXT_DAYTIME      (
         P_OPPORTUNITY_NO,
         P_NUM_ROWS );
         RETURN ret_value;
   END NEXT_DAYTIME;
   FUNCTION PREV_EQUAL_DAYTIME(
      P_OPPORTUNITY_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_OPPORTUNITY.PREV_EQUAL_DAYTIME      (
         P_OPPORTUNITY_NO,
         P_NUM_ROWS );
         RETURN ret_value;
   END PREV_EQUAL_DAYTIME;
   FUNCTION TEXT_7(
      P_OPPORTUNITY_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_OPPORTUNITY.TEXT_7      (
         P_OPPORTUNITY_NO );
         RETURN ret_value;
   END TEXT_7;
   FUNCTION TEXT_8(
      P_OPPORTUNITY_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_OPPORTUNITY.TEXT_8      (
         P_OPPORTUNITY_NO );
         RETURN ret_value;
   END TEXT_8;
   FUNCTION VALUE_29(
      P_OPPORTUNITY_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_OPPORTUNITY.VALUE_29      (
         P_OPPORTUNITY_NO );
         RETURN ret_value;
   END VALUE_29;
   FUNCTION DATE_3(
      P_OPPORTUNITY_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_OPPORTUNITY.DATE_3      (
         P_OPPORTUNITY_NO );
         RETURN ret_value;
   END DATE_3;
   FUNCTION DATE_5(
      P_OPPORTUNITY_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_OPPORTUNITY.DATE_5      (
         P_OPPORTUNITY_NO );
         RETURN ret_value;
   END DATE_5;
   FUNCTION NEXT_EQUAL_DAYTIME(
      P_OPPORTUNITY_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_OPPORTUNITY.NEXT_EQUAL_DAYTIME      (
         P_OPPORTUNITY_NO,
         P_NUM_ROWS );
         RETURN ret_value;
   END NEXT_EQUAL_DAYTIME;
   FUNCTION TEXT_1(
      P_OPPORTUNITY_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_OPPORTUNITY.TEXT_1      (
         P_OPPORTUNITY_NO );
         RETURN ret_value;
   END TEXT_1;
   FUNCTION TEXT_14(
      P_OPPORTUNITY_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_OPPORTUNITY.TEXT_14      (
         P_OPPORTUNITY_NO );
         RETURN ret_value;
   END TEXT_14;
   FUNCTION TEXT_6(
      P_OPPORTUNITY_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_OPPORTUNITY.TEXT_6      (
         P_OPPORTUNITY_NO );
         RETURN ret_value;
   END TEXT_6;
   FUNCTION TEXT_9(
      P_OPPORTUNITY_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_OPPORTUNITY.TEXT_9      (
         P_OPPORTUNITY_NO );
         RETURN ret_value;
   END TEXT_9;
   FUNCTION VALUE_12(
      P_OPPORTUNITY_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_OPPORTUNITY.VALUE_12      (
         P_OPPORTUNITY_NO );
         RETURN ret_value;
   END VALUE_12;
   FUNCTION VALUE_22(
      P_OPPORTUNITY_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_OPPORTUNITY.VALUE_22      (
         P_OPPORTUNITY_NO );
         RETURN ret_value;
   END VALUE_22;
   FUNCTION VALUE_26(
      P_OPPORTUNITY_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_OPPORTUNITY.VALUE_26      (
         P_OPPORTUNITY_NO );
         RETURN ret_value;
   END VALUE_26;
   FUNCTION VALUE_6(
      P_OPPORTUNITY_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_OPPORTUNITY.VALUE_6      (
         P_OPPORTUNITY_NO );
         RETURN ret_value;
   END VALUE_6;
   FUNCTION COMPANY_ID(
      P_OPPORTUNITY_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_OPPORTUNITY.COMPANY_ID      (
         P_OPPORTUNITY_NO );
         RETURN ret_value;
   END COMPANY_ID;
   FUNCTION CONTRACT_ID(
      P_OPPORTUNITY_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_OPPORTUNITY.CONTRACT_ID      (
         P_OPPORTUNITY_NO );
         RETURN ret_value;
   END CONTRACT_ID;
   FUNCTION DATE_2(
      P_OPPORTUNITY_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_OPPORTUNITY.DATE_2      (
         P_OPPORTUNITY_NO );
         RETURN ret_value;
   END DATE_2;
   FUNCTION END_DATE(
      P_OPPORTUNITY_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_OPPORTUNITY.END_DATE      (
         P_OPPORTUNITY_NO );
         RETURN ret_value;
   END END_DATE;
   FUNCTION OPPORTUNITY_NAME(
      P_OPPORTUNITY_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (100) ;
   BEGIN
      ret_value := EC_OPPORTUNITY.OPPORTUNITY_NAME      (
         P_OPPORTUNITY_NO );
         RETURN ret_value;
   END OPPORTUNITY_NAME;
   FUNCTION PREV_DAYTIME(
      P_OPPORTUNITY_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_OPPORTUNITY.PREV_DAYTIME      (
         P_OPPORTUNITY_NO,
         P_NUM_ROWS );
         RETURN ret_value;
   END PREV_DAYTIME;
   FUNCTION RECORD_STATUS(
      P_OPPORTUNITY_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_OPPORTUNITY.RECORD_STATUS      (
         P_OPPORTUNITY_NO );
         RETURN ret_value;
   END RECORD_STATUS;
   FUNCTION VALUE_1(
      P_OPPORTUNITY_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_OPPORTUNITY.VALUE_1      (
         P_OPPORTUNITY_NO );
         RETURN ret_value;
   END VALUE_1;
   FUNCTION VALUE_15(
      P_OPPORTUNITY_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_OPPORTUNITY.VALUE_15      (
         P_OPPORTUNITY_NO );
         RETURN ret_value;
   END VALUE_15;
   FUNCTION VALUE_19(
      P_OPPORTUNITY_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_OPPORTUNITY.VALUE_19      (
         P_OPPORTUNITY_NO );
         RETURN ret_value;
   END VALUE_19;
   FUNCTION APPROVAL_DATE(
      P_OPPORTUNITY_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_OPPORTUNITY.APPROVAL_DATE      (
         P_OPPORTUNITY_NO );
         RETURN ret_value;
   END APPROVAL_DATE;
   FUNCTION FORECAST_ID(
      P_OPPORTUNITY_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_OPPORTUNITY.FORECAST_ID      (
         P_OPPORTUNITY_NO );
         RETURN ret_value;
   END FORECAST_ID;
   FUNCTION ROW_BY_PK(
      P_OPPORTUNITY_NO IN NUMBER)
      RETURN REC_ROW_BY_PK
   IS
      ret_value    REC_ROW_BY_PK ;
   BEGIN
      ret_value := EC_OPPORTUNITY.ROW_BY_PK      (
         P_OPPORTUNITY_NO );
         RETURN ret_value;
   END ROW_BY_PK;
   FUNCTION TEXT_13(
      P_OPPORTUNITY_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_OPPORTUNITY.TEXT_13      (
         P_OPPORTUNITY_NO );
         RETURN ret_value;
   END TEXT_13;
   FUNCTION TEXT_2(
      P_OPPORTUNITY_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_OPPORTUNITY.TEXT_2      (
         P_OPPORTUNITY_NO );
         RETURN ret_value;
   END TEXT_2;
   FUNCTION TEXT_4(
      P_OPPORTUNITY_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_OPPORTUNITY.TEXT_4      (
         P_OPPORTUNITY_NO );
         RETURN ret_value;
   END TEXT_4;
   FUNCTION TEXT_5(
      P_OPPORTUNITY_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_OPPORTUNITY.TEXT_5      (
         P_OPPORTUNITY_NO );
         RETURN ret_value;
   END TEXT_5;
   FUNCTION VALUE_13(
      P_OPPORTUNITY_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_OPPORTUNITY.VALUE_13      (
         P_OPPORTUNITY_NO );
         RETURN ret_value;
   END VALUE_13;
   FUNCTION VALUE_17(
      P_OPPORTUNITY_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_OPPORTUNITY.VALUE_17      (
         P_OPPORTUNITY_NO );
         RETURN ret_value;
   END VALUE_17;
   FUNCTION VALUE_2(
      P_OPPORTUNITY_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_OPPORTUNITY.VALUE_2      (
         P_OPPORTUNITY_NO );
         RETURN ret_value;
   END VALUE_2;
   FUNCTION VALUE_20(
      P_OPPORTUNITY_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_OPPORTUNITY.VALUE_20      (
         P_OPPORTUNITY_NO );
         RETURN ret_value;
   END VALUE_20;
   FUNCTION VALUE_25(
      P_OPPORTUNITY_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_OPPORTUNITY.VALUE_25      (
         P_OPPORTUNITY_NO );
         RETURN ret_value;
   END VALUE_25;
   FUNCTION VALUE_3(
      P_OPPORTUNITY_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_OPPORTUNITY.VALUE_3      (
         P_OPPORTUNITY_NO );
         RETURN ret_value;
   END VALUE_3;
   FUNCTION VALUE_4(
      P_OPPORTUNITY_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_OPPORTUNITY.VALUE_4      (
         P_OPPORTUNITY_NO );
         RETURN ret_value;
   END VALUE_4;
   FUNCTION DATE_4(
      P_OPPORTUNITY_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_OPPORTUNITY.DATE_4      (
         P_OPPORTUNITY_NO );
         RETURN ret_value;
   END DATE_4;
   FUNCTION OPPORTUNITY_STATUS(
      P_OPPORTUNITY_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_OPPORTUNITY.OPPORTUNITY_STATUS      (
         P_OPPORTUNITY_NO );
         RETURN ret_value;
   END OPPORTUNITY_STATUS;
   FUNCTION REC_ID(
      P_OPPORTUNITY_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_OPPORTUNITY.REC_ID      (
         P_OPPORTUNITY_NO );
         RETURN ret_value;
   END REC_ID;
   FUNCTION VALUE_7(
      P_OPPORTUNITY_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_OPPORTUNITY.VALUE_7      (
         P_OPPORTUNITY_NO );
         RETURN ret_value;
   END VALUE_7;
   FUNCTION VALUE_9(
      P_OPPORTUNITY_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_OPPORTUNITY.VALUE_9      (
         P_OPPORTUNITY_NO );
         RETURN ret_value;
   END VALUE_9;
   FUNCTION DATE_1(
      P_OPPORTUNITY_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_OPPORTUNITY.DATE_1      (
         P_OPPORTUNITY_NO );
         RETURN ret_value;
   END DATE_1;
   FUNCTION DAYTIME(
      P_OPPORTUNITY_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_OPPORTUNITY.DAYTIME      (
         P_OPPORTUNITY_NO );
         RETURN ret_value;
   END DAYTIME;
   FUNCTION PERIOD(
      P_OPPORTUNITY_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_OPPORTUNITY.PERIOD      (
         P_OPPORTUNITY_NO );
         RETURN ret_value;
   END PERIOD;
   FUNCTION TEXT_10(
      P_OPPORTUNITY_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_OPPORTUNITY.TEXT_10      (
         P_OPPORTUNITY_NO );
         RETURN ret_value;
   END TEXT_10;
   FUNCTION TEXT_11(
      P_OPPORTUNITY_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_OPPORTUNITY.TEXT_11      (
         P_OPPORTUNITY_NO );
         RETURN ret_value;
   END TEXT_11;
   FUNCTION TEXT_12(
      P_OPPORTUNITY_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_OPPORTUNITY.TEXT_12      (
         P_OPPORTUNITY_NO );
         RETURN ret_value;
   END TEXT_12;
   FUNCTION TEXT_15(
      P_OPPORTUNITY_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_OPPORTUNITY.TEXT_15      (
         P_OPPORTUNITY_NO );
         RETURN ret_value;
   END TEXT_15;
   FUNCTION VALUE_10(
      P_OPPORTUNITY_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_OPPORTUNITY.VALUE_10      (
         P_OPPORTUNITY_NO );
         RETURN ret_value;
   END VALUE_10;
   FUNCTION VALUE_11(
      P_OPPORTUNITY_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_OPPORTUNITY.VALUE_11      (
         P_OPPORTUNITY_NO );
         RETURN ret_value;
   END VALUE_11;
   FUNCTION VALUE_14(
      P_OPPORTUNITY_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_OPPORTUNITY.VALUE_14      (
         P_OPPORTUNITY_NO );
         RETURN ret_value;
   END VALUE_14;
   FUNCTION VALUE_24(
      P_OPPORTUNITY_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_OPPORTUNITY.VALUE_24      (
         P_OPPORTUNITY_NO );
         RETURN ret_value;
   END VALUE_24;
   FUNCTION VALUE_8(
      P_OPPORTUNITY_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_OPPORTUNITY.VALUE_8      (
         P_OPPORTUNITY_NO );
         RETURN ret_value;
   END VALUE_8;

END RP_OPPORTUNITY;

/
--GRANT EXECUTE ON ECKERNEL_WST.RP_OPPORTUNITY TO REPORT_ROLE_XXX;



 -- FINISH PKG_GEN_PKGS.sf_get_functions at:05/07/2019 08.34.47 AM


