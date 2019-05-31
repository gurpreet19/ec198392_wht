
 -- START PKG_GEN_PKGS.sf_get_functions at:05/07/2019 11.21.29 AM


CREATE or REPLACE PACKAGE RP_ACCOUNT_TEMPLATE
IS

   FUNCTION TEXT_3(
      P_CODE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION VALUE_16(
      P_CODE IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION VALUE_18(
      P_CODE IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION VALUE_21(
      P_CODE IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION VALUE_27(
      P_CODE IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION VALUE_30(
      P_CODE IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION APPROVAL_BY(
      P_CODE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_STATE(
      P_CODE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION VALUE_23(
      P_CODE IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION VALUE_28(
      P_CODE IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION VALUE_5(
      P_CODE IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION TEXT_7(
      P_CODE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION TEXT_8(
      P_CODE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION VALUE_29(
      P_CODE IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION DATE_3(
      P_CODE IN VARCHAR2)
      RETURN DATE;
   FUNCTION DATE_5(
      P_CODE IN VARCHAR2)
      RETURN DATE;
   FUNCTION TEXT_1(
      P_CODE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION TEXT_14(
      P_CODE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION TEXT_6(
      P_CODE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION TEXT_9(
      P_CODE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION VALUE_12(
      P_CODE IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION VALUE_22(
      P_CODE IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION VALUE_26(
      P_CODE IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION VALUE_6(
      P_CODE IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION DATE_2(
      P_CODE IN VARCHAR2)
      RETURN DATE;
   FUNCTION RECORD_STATUS(
      P_CODE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION VALUE_1(
      P_CODE IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION VALUE_15(
      P_CODE IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION VALUE_19(
      P_CODE IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION APPROVAL_DATE(
      P_CODE IN VARCHAR2)
      RETURN DATE;
   FUNCTION NAME(
      P_CODE IN VARCHAR2)
      RETURN VARCHAR2;
      TYPE REC_ROW_BY_PK IS RECORD (
         CODE VARCHAR2 (32) ,
         NAME VARCHAR2 (240) ,
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
         REV_TEXT VARCHAR2 (2000) ,
         APPROVAL_BY VARCHAR2 (30) ,
         APPROVAL_DATE  DATE ,
         APPROVAL_STATE VARCHAR2 (1) ,
         REC_ID VARCHAR2 (32)  );
   FUNCTION ROW_BY_PK(
      P_CODE IN VARCHAR2)
      RETURN REC_ROW_BY_PK;
   FUNCTION TEXT_13(
      P_CODE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION TEXT_2(
      P_CODE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION TEXT_4(
      P_CODE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION TEXT_5(
      P_CODE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION VALUE_13(
      P_CODE IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION VALUE_17(
      P_CODE IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION VALUE_2(
      P_CODE IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION VALUE_20(
      P_CODE IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION VALUE_25(
      P_CODE IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION VALUE_3(
      P_CODE IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION VALUE_4(
      P_CODE IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION DATE_4(
      P_CODE IN VARCHAR2)
      RETURN DATE;
   FUNCTION REC_ID(
      P_CODE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION VALUE_7(
      P_CODE IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION VALUE_9(
      P_CODE IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION DATE_1(
      P_CODE IN VARCHAR2)
      RETURN DATE;
   FUNCTION TEXT_10(
      P_CODE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION TEXT_11(
      P_CODE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION TEXT_12(
      P_CODE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION TEXT_15(
      P_CODE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION VALUE_10(
      P_CODE IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION VALUE_11(
      P_CODE IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION VALUE_14(
      P_CODE IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION VALUE_24(
      P_CODE IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION VALUE_8(
      P_CODE IN VARCHAR2)
      RETURN NUMBER;

END RP_ACCOUNT_TEMPLATE;

/



CREATE or REPLACE PACKAGE BODY RP_ACCOUNT_TEMPLATE
IS

   FUNCTION TEXT_3(
      P_CODE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_ACCOUNT_TEMPLATE.TEXT_3      (
         P_CODE );
         RETURN ret_value;
   END TEXT_3;
   FUNCTION VALUE_16(
      P_CODE IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_ACCOUNT_TEMPLATE.VALUE_16      (
         P_CODE );
         RETURN ret_value;
   END VALUE_16;
   FUNCTION VALUE_18(
      P_CODE IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_ACCOUNT_TEMPLATE.VALUE_18      (
         P_CODE );
         RETURN ret_value;
   END VALUE_18;
   FUNCTION VALUE_21(
      P_CODE IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_ACCOUNT_TEMPLATE.VALUE_21      (
         P_CODE );
         RETURN ret_value;
   END VALUE_21;
   FUNCTION VALUE_27(
      P_CODE IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_ACCOUNT_TEMPLATE.VALUE_27      (
         P_CODE );
         RETURN ret_value;
   END VALUE_27;
   FUNCTION VALUE_30(
      P_CODE IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_ACCOUNT_TEMPLATE.VALUE_30      (
         P_CODE );
         RETURN ret_value;
   END VALUE_30;
   FUNCTION APPROVAL_BY(
      P_CODE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (30) ;
   BEGIN
      ret_value := EC_ACCOUNT_TEMPLATE.APPROVAL_BY      (
         P_CODE );
         RETURN ret_value;
   END APPROVAL_BY;
   FUNCTION APPROVAL_STATE(
      P_CODE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_ACCOUNT_TEMPLATE.APPROVAL_STATE      (
         P_CODE );
         RETURN ret_value;
   END APPROVAL_STATE;
   FUNCTION VALUE_23(
      P_CODE IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_ACCOUNT_TEMPLATE.VALUE_23      (
         P_CODE );
         RETURN ret_value;
   END VALUE_23;
   FUNCTION VALUE_28(
      P_CODE IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_ACCOUNT_TEMPLATE.VALUE_28      (
         P_CODE );
         RETURN ret_value;
   END VALUE_28;
   FUNCTION VALUE_5(
      P_CODE IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_ACCOUNT_TEMPLATE.VALUE_5      (
         P_CODE );
         RETURN ret_value;
   END VALUE_5;
   FUNCTION TEXT_7(
      P_CODE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_ACCOUNT_TEMPLATE.TEXT_7      (
         P_CODE );
         RETURN ret_value;
   END TEXT_7;
   FUNCTION TEXT_8(
      P_CODE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_ACCOUNT_TEMPLATE.TEXT_8      (
         P_CODE );
         RETURN ret_value;
   END TEXT_8;
   FUNCTION VALUE_29(
      P_CODE IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_ACCOUNT_TEMPLATE.VALUE_29      (
         P_CODE );
         RETURN ret_value;
   END VALUE_29;
   FUNCTION DATE_3(
      P_CODE IN VARCHAR2)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_ACCOUNT_TEMPLATE.DATE_3      (
         P_CODE );
         RETURN ret_value;
   END DATE_3;
   FUNCTION DATE_5(
      P_CODE IN VARCHAR2)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_ACCOUNT_TEMPLATE.DATE_5      (
         P_CODE );
         RETURN ret_value;
   END DATE_5;
   FUNCTION TEXT_1(
      P_CODE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_ACCOUNT_TEMPLATE.TEXT_1      (
         P_CODE );
         RETURN ret_value;
   END TEXT_1;
   FUNCTION TEXT_14(
      P_CODE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_ACCOUNT_TEMPLATE.TEXT_14      (
         P_CODE );
         RETURN ret_value;
   END TEXT_14;
   FUNCTION TEXT_6(
      P_CODE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_ACCOUNT_TEMPLATE.TEXT_6      (
         P_CODE );
         RETURN ret_value;
   END TEXT_6;
   FUNCTION TEXT_9(
      P_CODE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_ACCOUNT_TEMPLATE.TEXT_9      (
         P_CODE );
         RETURN ret_value;
   END TEXT_9;
   FUNCTION VALUE_12(
      P_CODE IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_ACCOUNT_TEMPLATE.VALUE_12      (
         P_CODE );
         RETURN ret_value;
   END VALUE_12;
   FUNCTION VALUE_22(
      P_CODE IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_ACCOUNT_TEMPLATE.VALUE_22      (
         P_CODE );
         RETURN ret_value;
   END VALUE_22;
   FUNCTION VALUE_26(
      P_CODE IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_ACCOUNT_TEMPLATE.VALUE_26      (
         P_CODE );
         RETURN ret_value;
   END VALUE_26;
   FUNCTION VALUE_6(
      P_CODE IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_ACCOUNT_TEMPLATE.VALUE_6      (
         P_CODE );
         RETURN ret_value;
   END VALUE_6;
   FUNCTION DATE_2(
      P_CODE IN VARCHAR2)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_ACCOUNT_TEMPLATE.DATE_2      (
         P_CODE );
         RETURN ret_value;
   END DATE_2;
   FUNCTION RECORD_STATUS(
      P_CODE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_ACCOUNT_TEMPLATE.RECORD_STATUS      (
         P_CODE );
         RETURN ret_value;
   END RECORD_STATUS;
   FUNCTION VALUE_1(
      P_CODE IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_ACCOUNT_TEMPLATE.VALUE_1      (
         P_CODE );
         RETURN ret_value;
   END VALUE_1;
   FUNCTION VALUE_15(
      P_CODE IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_ACCOUNT_TEMPLATE.VALUE_15      (
         P_CODE );
         RETURN ret_value;
   END VALUE_15;
   FUNCTION VALUE_19(
      P_CODE IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_ACCOUNT_TEMPLATE.VALUE_19      (
         P_CODE );
         RETURN ret_value;
   END VALUE_19;
   FUNCTION APPROVAL_DATE(
      P_CODE IN VARCHAR2)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_ACCOUNT_TEMPLATE.APPROVAL_DATE      (
         P_CODE );
         RETURN ret_value;
   END APPROVAL_DATE;
   FUNCTION NAME(
      P_CODE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_ACCOUNT_TEMPLATE.NAME      (
         P_CODE );
         RETURN ret_value;
   END NAME;
   FUNCTION ROW_BY_PK(
      P_CODE IN VARCHAR2)
      RETURN REC_ROW_BY_PK
   IS
      ret_value    REC_ROW_BY_PK ;
   BEGIN
      ret_value := EC_ACCOUNT_TEMPLATE.ROW_BY_PK      (
         P_CODE );
         RETURN ret_value;
   END ROW_BY_PK;
   FUNCTION TEXT_13(
      P_CODE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_ACCOUNT_TEMPLATE.TEXT_13      (
         P_CODE );
         RETURN ret_value;
   END TEXT_13;
   FUNCTION TEXT_2(
      P_CODE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_ACCOUNT_TEMPLATE.TEXT_2      (
         P_CODE );
         RETURN ret_value;
   END TEXT_2;
   FUNCTION TEXT_4(
      P_CODE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_ACCOUNT_TEMPLATE.TEXT_4      (
         P_CODE );
         RETURN ret_value;
   END TEXT_4;
   FUNCTION TEXT_5(
      P_CODE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_ACCOUNT_TEMPLATE.TEXT_5      (
         P_CODE );
         RETURN ret_value;
   END TEXT_5;
   FUNCTION VALUE_13(
      P_CODE IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_ACCOUNT_TEMPLATE.VALUE_13      (
         P_CODE );
         RETURN ret_value;
   END VALUE_13;
   FUNCTION VALUE_17(
      P_CODE IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_ACCOUNT_TEMPLATE.VALUE_17      (
         P_CODE );
         RETURN ret_value;
   END VALUE_17;
   FUNCTION VALUE_2(
      P_CODE IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_ACCOUNT_TEMPLATE.VALUE_2      (
         P_CODE );
         RETURN ret_value;
   END VALUE_2;
   FUNCTION VALUE_20(
      P_CODE IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_ACCOUNT_TEMPLATE.VALUE_20      (
         P_CODE );
         RETURN ret_value;
   END VALUE_20;
   FUNCTION VALUE_25(
      P_CODE IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_ACCOUNT_TEMPLATE.VALUE_25      (
         P_CODE );
         RETURN ret_value;
   END VALUE_25;
   FUNCTION VALUE_3(
      P_CODE IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_ACCOUNT_TEMPLATE.VALUE_3      (
         P_CODE );
         RETURN ret_value;
   END VALUE_3;
   FUNCTION VALUE_4(
      P_CODE IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_ACCOUNT_TEMPLATE.VALUE_4      (
         P_CODE );
         RETURN ret_value;
   END VALUE_4;
   FUNCTION DATE_4(
      P_CODE IN VARCHAR2)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_ACCOUNT_TEMPLATE.DATE_4      (
         P_CODE );
         RETURN ret_value;
   END DATE_4;
   FUNCTION REC_ID(
      P_CODE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_ACCOUNT_TEMPLATE.REC_ID      (
         P_CODE );
         RETURN ret_value;
   END REC_ID;
   FUNCTION VALUE_7(
      P_CODE IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_ACCOUNT_TEMPLATE.VALUE_7      (
         P_CODE );
         RETURN ret_value;
   END VALUE_7;
   FUNCTION VALUE_9(
      P_CODE IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_ACCOUNT_TEMPLATE.VALUE_9      (
         P_CODE );
         RETURN ret_value;
   END VALUE_9;
   FUNCTION DATE_1(
      P_CODE IN VARCHAR2)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_ACCOUNT_TEMPLATE.DATE_1      (
         P_CODE );
         RETURN ret_value;
   END DATE_1;
   FUNCTION TEXT_10(
      P_CODE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_ACCOUNT_TEMPLATE.TEXT_10      (
         P_CODE );
         RETURN ret_value;
   END TEXT_10;
   FUNCTION TEXT_11(
      P_CODE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_ACCOUNT_TEMPLATE.TEXT_11      (
         P_CODE );
         RETURN ret_value;
   END TEXT_11;
   FUNCTION TEXT_12(
      P_CODE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_ACCOUNT_TEMPLATE.TEXT_12      (
         P_CODE );
         RETURN ret_value;
   END TEXT_12;
   FUNCTION TEXT_15(
      P_CODE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_ACCOUNT_TEMPLATE.TEXT_15      (
         P_CODE );
         RETURN ret_value;
   END TEXT_15;
   FUNCTION VALUE_10(
      P_CODE IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_ACCOUNT_TEMPLATE.VALUE_10      (
         P_CODE );
         RETURN ret_value;
   END VALUE_10;
   FUNCTION VALUE_11(
      P_CODE IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_ACCOUNT_TEMPLATE.VALUE_11      (
         P_CODE );
         RETURN ret_value;
   END VALUE_11;
   FUNCTION VALUE_14(
      P_CODE IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_ACCOUNT_TEMPLATE.VALUE_14      (
         P_CODE );
         RETURN ret_value;
   END VALUE_14;
   FUNCTION VALUE_24(
      P_CODE IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_ACCOUNT_TEMPLATE.VALUE_24      (
         P_CODE );
         RETURN ret_value;
   END VALUE_24;
   FUNCTION VALUE_8(
      P_CODE IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_ACCOUNT_TEMPLATE.VALUE_8      (
         P_CODE );
         RETURN ret_value;
   END VALUE_8;

END RP_ACCOUNT_TEMPLATE;

/
--GRANT EXECUTE ON ECKERNEL_WST.RP_ACCOUNT_TEMPLATE TO REPORT_ROLE_XXX;



 -- FINISH PKG_GEN_PKGS.sf_get_functions at:05/07/2019 11.21.41 AM


