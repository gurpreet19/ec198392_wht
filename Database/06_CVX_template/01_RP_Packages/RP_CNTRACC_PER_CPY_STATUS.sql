
 -- START PKG_GEN_PKGS.sf_get_functions at:05/07/2019 11.00.03 AM


CREATE or REPLACE PACKAGE RP_CNTRACC_PER_CPY_STATUS
IS

   FUNCTION TEXT_3(
      P_OBJECT_ID IN VARCHAR2,
      P_COMPANY_ID IN VARCHAR2,
      P_ACCOUNT_CODE IN VARCHAR2,
      P_TIME_SPAN IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2;
   FUNCTION TEXT_4(
      P_OBJECT_ID IN VARCHAR2,
      P_COMPANY_ID IN VARCHAR2,
      P_ACCOUNT_CODE IN VARCHAR2,
      P_TIME_SPAN IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2;
   FUNCTION VOL_QTY(
      P_OBJECT_ID IN VARCHAR2,
      P_COMPANY_ID IN VARCHAR2,
      P_ACCOUNT_CODE IN VARCHAR2,
      P_TIME_SPAN IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER;
   FUNCTION X3_QTY(
      P_OBJECT_ID IN VARCHAR2,
      P_COMPANY_ID IN VARCHAR2,
      P_ACCOUNT_CODE IN VARCHAR2,
      P_TIME_SPAN IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER;
   FUNCTION AMOUNT(
      P_OBJECT_ID IN VARCHAR2,
      P_COMPANY_ID IN VARCHAR2,
      P_ACCOUNT_CODE IN VARCHAR2,
      P_TIME_SPAN IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER;
   FUNCTION APPROVAL_BY(
      P_OBJECT_ID IN VARCHAR2,
      P_COMPANY_ID IN VARCHAR2,
      P_ACCOUNT_CODE IN VARCHAR2,
      P_TIME_SPAN IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2;
   FUNCTION APPROVAL_STATE(
      P_OBJECT_ID IN VARCHAR2,
      P_COMPANY_ID IN VARCHAR2,
      P_ACCOUNT_CODE IN VARCHAR2,
      P_TIME_SPAN IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2;
   FUNCTION VALUE_5(
      P_OBJECT_ID IN VARCHAR2,
      P_COMPANY_ID IN VARCHAR2,
      P_ACCOUNT_CODE IN VARCHAR2,
      P_TIME_SPAN IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER;
   FUNCTION NEXT_DAYTIME(
      P_OBJECT_ID IN VARCHAR2,
      P_COMPANY_ID IN VARCHAR2,
      P_ACCOUNT_CODE IN VARCHAR2,
      P_TIME_SPAN IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION PREV_EQUAL_DAYTIME(
      P_OBJECT_ID IN VARCHAR2,
      P_COMPANY_ID IN VARCHAR2,
      P_ACCOUNT_CODE IN VARCHAR2,
      P_TIME_SPAN IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION X1_QTY(
      P_OBJECT_ID IN VARCHAR2,
      P_COMPANY_ID IN VARCHAR2,
      P_ACCOUNT_CODE IN VARCHAR2,
      P_TIME_SPAN IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER;
   FUNCTION DATE_3(
      P_OBJECT_ID IN VARCHAR2,
      P_COMPANY_ID IN VARCHAR2,
      P_ACCOUNT_CODE IN VARCHAR2,
      P_TIME_SPAN IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN DATE;
   FUNCTION DATE_5(
      P_OBJECT_ID IN VARCHAR2,
      P_COMPANY_ID IN VARCHAR2,
      P_ACCOUNT_CODE IN VARCHAR2,
      P_TIME_SPAN IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN DATE;
   FUNCTION ENERGY_QTY(
      P_OBJECT_ID IN VARCHAR2,
      P_COMPANY_ID IN VARCHAR2,
      P_ACCOUNT_CODE IN VARCHAR2,
      P_TIME_SPAN IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER;
   FUNCTION NEXT_EQUAL_DAYTIME(
      P_OBJECT_ID IN VARCHAR2,
      P_COMPANY_ID IN VARCHAR2,
      P_ACCOUNT_CODE IN VARCHAR2,
      P_TIME_SPAN IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION VALUE_6(
      P_OBJECT_ID IN VARCHAR2,
      P_COMPANY_ID IN VARCHAR2,
      P_ACCOUNT_CODE IN VARCHAR2,
      P_TIME_SPAN IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER;
   FUNCTION DATE_2(
      P_OBJECT_ID IN VARCHAR2,
      P_COMPANY_ID IN VARCHAR2,
      P_ACCOUNT_CODE IN VARCHAR2,
      P_TIME_SPAN IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN DATE;
   FUNCTION PREV_DAYTIME(
      P_OBJECT_ID IN VARCHAR2,
      P_COMPANY_ID IN VARCHAR2,
      P_ACCOUNT_CODE IN VARCHAR2,
      P_TIME_SPAN IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION RECORD_STATUS(
      P_OBJECT_ID IN VARCHAR2,
      P_COMPANY_ID IN VARCHAR2,
      P_ACCOUNT_CODE IN VARCHAR2,
      P_TIME_SPAN IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2;
   FUNCTION VALUE_1(
      P_OBJECT_ID IN VARCHAR2,
      P_COMPANY_ID IN VARCHAR2,
      P_ACCOUNT_CODE IN VARCHAR2,
      P_TIME_SPAN IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER;
   FUNCTION APPROVAL_DATE(
      P_OBJECT_ID IN VARCHAR2,
      P_COMPANY_ID IN VARCHAR2,
      P_ACCOUNT_CODE IN VARCHAR2,
      P_TIME_SPAN IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN DATE;
   FUNCTION CALC_RUN_NO(
      P_OBJECT_ID IN VARCHAR2,
      P_COMPANY_ID IN VARCHAR2,
      P_ACCOUNT_CODE IN VARCHAR2,
      P_TIME_SPAN IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER;
   FUNCTION MASS_QTY(
      P_OBJECT_ID IN VARCHAR2,
      P_COMPANY_ID IN VARCHAR2,
      P_ACCOUNT_CODE IN VARCHAR2,
      P_TIME_SPAN IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER;
      TYPE REC_ROW_BY_PK IS RECORD (
         OBJECT_ID VARCHAR2 (32) ,
         COMPANY_ID VARCHAR2 (32) ,
         ACCOUNT_CODE VARCHAR2 (32) ,
         TIME_SPAN VARCHAR2 (16) ,
         DAYTIME  DATE ,
         VOL_QTY NUMBER ,
         MASS_QTY NUMBER ,
         ENERGY_QTY NUMBER ,
         X1_QTY NUMBER ,
         X2_QTY NUMBER ,
         X3_QTY NUMBER ,
         TEXT_1 VARCHAR2 (16) ,
         TEXT_2 VARCHAR2 (32) ,
         TEXT_3 VARCHAR2 (240) ,
         TEXT_4 VARCHAR2 (2000) ,
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
         REC_ID VARCHAR2 (32) ,
         AMOUNT NUMBER ,
         CALC_RUN_NO NUMBER  );
   FUNCTION ROW_BY_PK(
      P_OBJECT_ID IN VARCHAR2,
      P_COMPANY_ID IN VARCHAR2,
      P_ACCOUNT_CODE IN VARCHAR2,
      P_TIME_SPAN IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN REC_ROW_BY_PK;
      TYPE REC_ROW_BY_REL_OPERATOR IS RECORD (
         OBJECT_ID VARCHAR2 (32) ,
         COMPANY_ID VARCHAR2 (32) ,
         ACCOUNT_CODE VARCHAR2 (32) ,
         TIME_SPAN VARCHAR2 (16) ,
         DAYTIME  DATE ,
         VOL_QTY NUMBER ,
         MASS_QTY NUMBER ,
         ENERGY_QTY NUMBER ,
         X1_QTY NUMBER ,
         X2_QTY NUMBER ,
         X3_QTY NUMBER ,
         TEXT_1 VARCHAR2 (16) ,
         TEXT_2 VARCHAR2 (32) ,
         TEXT_3 VARCHAR2 (240) ,
         TEXT_4 VARCHAR2 (2000) ,
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
         REC_ID VARCHAR2 (32) ,
         AMOUNT NUMBER ,
         CALC_RUN_NO NUMBER  );
   FUNCTION ROW_BY_REL_OPERATOR(
      P_OBJECT_ID IN VARCHAR2,
      P_COMPANY_ID IN VARCHAR2,
      P_ACCOUNT_CODE IN VARCHAR2,
      P_TIME_SPAN IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN REC_ROW_BY_REL_OPERATOR;
   FUNCTION VALUE_2(
      P_OBJECT_ID IN VARCHAR2,
      P_COMPANY_ID IN VARCHAR2,
      P_ACCOUNT_CODE IN VARCHAR2,
      P_TIME_SPAN IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER;
   FUNCTION VALUE_3(
      P_OBJECT_ID IN VARCHAR2,
      P_COMPANY_ID IN VARCHAR2,
      P_ACCOUNT_CODE IN VARCHAR2,
      P_TIME_SPAN IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER;
   FUNCTION VALUE_4(
      P_OBJECT_ID IN VARCHAR2,
      P_COMPANY_ID IN VARCHAR2,
      P_ACCOUNT_CODE IN VARCHAR2,
      P_TIME_SPAN IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER;
   FUNCTION DATE_4(
      P_OBJECT_ID IN VARCHAR2,
      P_COMPANY_ID IN VARCHAR2,
      P_ACCOUNT_CODE IN VARCHAR2,
      P_TIME_SPAN IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN DATE;
   FUNCTION REC_ID(
      P_OBJECT_ID IN VARCHAR2,
      P_COMPANY_ID IN VARCHAR2,
      P_ACCOUNT_CODE IN VARCHAR2,
      P_TIME_SPAN IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2;
   FUNCTION TEXT_1(
      P_OBJECT_ID IN VARCHAR2,
      P_COMPANY_ID IN VARCHAR2,
      P_ACCOUNT_CODE IN VARCHAR2,
      P_TIME_SPAN IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2;
   FUNCTION TEXT_2(
      P_OBJECT_ID IN VARCHAR2,
      P_COMPANY_ID IN VARCHAR2,
      P_ACCOUNT_CODE IN VARCHAR2,
      P_TIME_SPAN IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2;
   FUNCTION VALUE_7(
      P_OBJECT_ID IN VARCHAR2,
      P_COMPANY_ID IN VARCHAR2,
      P_ACCOUNT_CODE IN VARCHAR2,
      P_TIME_SPAN IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER;
   FUNCTION VALUE_9(
      P_OBJECT_ID IN VARCHAR2,
      P_COMPANY_ID IN VARCHAR2,
      P_ACCOUNT_CODE IN VARCHAR2,
      P_TIME_SPAN IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER;
   FUNCTION DATE_1(
      P_OBJECT_ID IN VARCHAR2,
      P_COMPANY_ID IN VARCHAR2,
      P_ACCOUNT_CODE IN VARCHAR2,
      P_TIME_SPAN IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN DATE;
   FUNCTION VALUE_10(
      P_OBJECT_ID IN VARCHAR2,
      P_COMPANY_ID IN VARCHAR2,
      P_ACCOUNT_CODE IN VARCHAR2,
      P_TIME_SPAN IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER;
   FUNCTION VALUE_8(
      P_OBJECT_ID IN VARCHAR2,
      P_COMPANY_ID IN VARCHAR2,
      P_ACCOUNT_CODE IN VARCHAR2,
      P_TIME_SPAN IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER;
   FUNCTION X2_QTY(
      P_OBJECT_ID IN VARCHAR2,
      P_COMPANY_ID IN VARCHAR2,
      P_ACCOUNT_CODE IN VARCHAR2,
      P_TIME_SPAN IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER;

END RP_CNTRACC_PER_CPY_STATUS;

/



CREATE or REPLACE PACKAGE BODY RP_CNTRACC_PER_CPY_STATUS
IS

   FUNCTION TEXT_3(
      P_OBJECT_ID IN VARCHAR2,
      P_COMPANY_ID IN VARCHAR2,
      P_ACCOUNT_CODE IN VARCHAR2,
      P_TIME_SPAN IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_CNTRACC_PER_CPY_STATUS.TEXT_3      (
         P_OBJECT_ID,
         P_COMPANY_ID,
         P_ACCOUNT_CODE,
         P_TIME_SPAN,
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END TEXT_3;
   FUNCTION TEXT_4(
      P_OBJECT_ID IN VARCHAR2,
      P_COMPANY_ID IN VARCHAR2,
      P_ACCOUNT_CODE IN VARCHAR2,
      P_TIME_SPAN IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_CNTRACC_PER_CPY_STATUS.TEXT_4      (
         P_OBJECT_ID,
         P_COMPANY_ID,
         P_ACCOUNT_CODE,
         P_TIME_SPAN,
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END TEXT_4;
   FUNCTION VOL_QTY(
      P_OBJECT_ID IN VARCHAR2,
      P_COMPANY_ID IN VARCHAR2,
      P_ACCOUNT_CODE IN VARCHAR2,
      P_TIME_SPAN IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CNTRACC_PER_CPY_STATUS.VOL_QTY      (
         P_OBJECT_ID,
         P_COMPANY_ID,
         P_ACCOUNT_CODE,
         P_TIME_SPAN,
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END VOL_QTY;
   FUNCTION X3_QTY(
      P_OBJECT_ID IN VARCHAR2,
      P_COMPANY_ID IN VARCHAR2,
      P_ACCOUNT_CODE IN VARCHAR2,
      P_TIME_SPAN IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CNTRACC_PER_CPY_STATUS.X3_QTY      (
         P_OBJECT_ID,
         P_COMPANY_ID,
         P_ACCOUNT_CODE,
         P_TIME_SPAN,
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END X3_QTY;
   FUNCTION AMOUNT(
      P_OBJECT_ID IN VARCHAR2,
      P_COMPANY_ID IN VARCHAR2,
      P_ACCOUNT_CODE IN VARCHAR2,
      P_TIME_SPAN IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CNTRACC_PER_CPY_STATUS.AMOUNT      (
         P_OBJECT_ID,
         P_COMPANY_ID,
         P_ACCOUNT_CODE,
         P_TIME_SPAN,
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END AMOUNT;
   FUNCTION APPROVAL_BY(
      P_OBJECT_ID IN VARCHAR2,
      P_COMPANY_ID IN VARCHAR2,
      P_ACCOUNT_CODE IN VARCHAR2,
      P_TIME_SPAN IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (30) ;
   BEGIN
      ret_value := EC_CNTRACC_PER_CPY_STATUS.APPROVAL_BY      (
         P_OBJECT_ID,
         P_COMPANY_ID,
         P_ACCOUNT_CODE,
         P_TIME_SPAN,
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END APPROVAL_BY;
   FUNCTION APPROVAL_STATE(
      P_OBJECT_ID IN VARCHAR2,
      P_COMPANY_ID IN VARCHAR2,
      P_ACCOUNT_CODE IN VARCHAR2,
      P_TIME_SPAN IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_CNTRACC_PER_CPY_STATUS.APPROVAL_STATE      (
         P_OBJECT_ID,
         P_COMPANY_ID,
         P_ACCOUNT_CODE,
         P_TIME_SPAN,
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END APPROVAL_STATE;
   FUNCTION VALUE_5(
      P_OBJECT_ID IN VARCHAR2,
      P_COMPANY_ID IN VARCHAR2,
      P_ACCOUNT_CODE IN VARCHAR2,
      P_TIME_SPAN IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CNTRACC_PER_CPY_STATUS.VALUE_5      (
         P_OBJECT_ID,
         P_COMPANY_ID,
         P_ACCOUNT_CODE,
         P_TIME_SPAN,
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END VALUE_5;
   FUNCTION NEXT_DAYTIME(
      P_OBJECT_ID IN VARCHAR2,
      P_COMPANY_ID IN VARCHAR2,
      P_ACCOUNT_CODE IN VARCHAR2,
      P_TIME_SPAN IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CNTRACC_PER_CPY_STATUS.NEXT_DAYTIME      (
         P_OBJECT_ID,
         P_COMPANY_ID,
         P_ACCOUNT_CODE,
         P_TIME_SPAN,
         P_DAYTIME,
         P_NUM_ROWS );
         RETURN ret_value;
   END NEXT_DAYTIME;
   FUNCTION PREV_EQUAL_DAYTIME(
      P_OBJECT_ID IN VARCHAR2,
      P_COMPANY_ID IN VARCHAR2,
      P_ACCOUNT_CODE IN VARCHAR2,
      P_TIME_SPAN IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CNTRACC_PER_CPY_STATUS.PREV_EQUAL_DAYTIME      (
         P_OBJECT_ID,
         P_COMPANY_ID,
         P_ACCOUNT_CODE,
         P_TIME_SPAN,
         P_DAYTIME,
         P_NUM_ROWS );
         RETURN ret_value;
   END PREV_EQUAL_DAYTIME;
   FUNCTION X1_QTY(
      P_OBJECT_ID IN VARCHAR2,
      P_COMPANY_ID IN VARCHAR2,
      P_ACCOUNT_CODE IN VARCHAR2,
      P_TIME_SPAN IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CNTRACC_PER_CPY_STATUS.X1_QTY      (
         P_OBJECT_ID,
         P_COMPANY_ID,
         P_ACCOUNT_CODE,
         P_TIME_SPAN,
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END X1_QTY;
   FUNCTION DATE_3(
      P_OBJECT_ID IN VARCHAR2,
      P_COMPANY_ID IN VARCHAR2,
      P_ACCOUNT_CODE IN VARCHAR2,
      P_TIME_SPAN IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CNTRACC_PER_CPY_STATUS.DATE_3      (
         P_OBJECT_ID,
         P_COMPANY_ID,
         P_ACCOUNT_CODE,
         P_TIME_SPAN,
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END DATE_3;
   FUNCTION DATE_5(
      P_OBJECT_ID IN VARCHAR2,
      P_COMPANY_ID IN VARCHAR2,
      P_ACCOUNT_CODE IN VARCHAR2,
      P_TIME_SPAN IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CNTRACC_PER_CPY_STATUS.DATE_5      (
         P_OBJECT_ID,
         P_COMPANY_ID,
         P_ACCOUNT_CODE,
         P_TIME_SPAN,
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END DATE_5;
   FUNCTION ENERGY_QTY(
      P_OBJECT_ID IN VARCHAR2,
      P_COMPANY_ID IN VARCHAR2,
      P_ACCOUNT_CODE IN VARCHAR2,
      P_TIME_SPAN IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CNTRACC_PER_CPY_STATUS.ENERGY_QTY      (
         P_OBJECT_ID,
         P_COMPANY_ID,
         P_ACCOUNT_CODE,
         P_TIME_SPAN,
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END ENERGY_QTY;
   FUNCTION NEXT_EQUAL_DAYTIME(
      P_OBJECT_ID IN VARCHAR2,
      P_COMPANY_ID IN VARCHAR2,
      P_ACCOUNT_CODE IN VARCHAR2,
      P_TIME_SPAN IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CNTRACC_PER_CPY_STATUS.NEXT_EQUAL_DAYTIME      (
         P_OBJECT_ID,
         P_COMPANY_ID,
         P_ACCOUNT_CODE,
         P_TIME_SPAN,
         P_DAYTIME,
         P_NUM_ROWS );
         RETURN ret_value;
   END NEXT_EQUAL_DAYTIME;
   FUNCTION VALUE_6(
      P_OBJECT_ID IN VARCHAR2,
      P_COMPANY_ID IN VARCHAR2,
      P_ACCOUNT_CODE IN VARCHAR2,
      P_TIME_SPAN IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CNTRACC_PER_CPY_STATUS.VALUE_6      (
         P_OBJECT_ID,
         P_COMPANY_ID,
         P_ACCOUNT_CODE,
         P_TIME_SPAN,
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END VALUE_6;
   FUNCTION DATE_2(
      P_OBJECT_ID IN VARCHAR2,
      P_COMPANY_ID IN VARCHAR2,
      P_ACCOUNT_CODE IN VARCHAR2,
      P_TIME_SPAN IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CNTRACC_PER_CPY_STATUS.DATE_2      (
         P_OBJECT_ID,
         P_COMPANY_ID,
         P_ACCOUNT_CODE,
         P_TIME_SPAN,
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END DATE_2;
   FUNCTION PREV_DAYTIME(
      P_OBJECT_ID IN VARCHAR2,
      P_COMPANY_ID IN VARCHAR2,
      P_ACCOUNT_CODE IN VARCHAR2,
      P_TIME_SPAN IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CNTRACC_PER_CPY_STATUS.PREV_DAYTIME      (
         P_OBJECT_ID,
         P_COMPANY_ID,
         P_ACCOUNT_CODE,
         P_TIME_SPAN,
         P_DAYTIME,
         P_NUM_ROWS );
         RETURN ret_value;
   END PREV_DAYTIME;
   FUNCTION RECORD_STATUS(
      P_OBJECT_ID IN VARCHAR2,
      P_COMPANY_ID IN VARCHAR2,
      P_ACCOUNT_CODE IN VARCHAR2,
      P_TIME_SPAN IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_CNTRACC_PER_CPY_STATUS.RECORD_STATUS      (
         P_OBJECT_ID,
         P_COMPANY_ID,
         P_ACCOUNT_CODE,
         P_TIME_SPAN,
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END RECORD_STATUS;
   FUNCTION VALUE_1(
      P_OBJECT_ID IN VARCHAR2,
      P_COMPANY_ID IN VARCHAR2,
      P_ACCOUNT_CODE IN VARCHAR2,
      P_TIME_SPAN IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CNTRACC_PER_CPY_STATUS.VALUE_1      (
         P_OBJECT_ID,
         P_COMPANY_ID,
         P_ACCOUNT_CODE,
         P_TIME_SPAN,
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END VALUE_1;
   FUNCTION APPROVAL_DATE(
      P_OBJECT_ID IN VARCHAR2,
      P_COMPANY_ID IN VARCHAR2,
      P_ACCOUNT_CODE IN VARCHAR2,
      P_TIME_SPAN IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CNTRACC_PER_CPY_STATUS.APPROVAL_DATE      (
         P_OBJECT_ID,
         P_COMPANY_ID,
         P_ACCOUNT_CODE,
         P_TIME_SPAN,
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END APPROVAL_DATE;
   FUNCTION CALC_RUN_NO(
      P_OBJECT_ID IN VARCHAR2,
      P_COMPANY_ID IN VARCHAR2,
      P_ACCOUNT_CODE IN VARCHAR2,
      P_TIME_SPAN IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CNTRACC_PER_CPY_STATUS.CALC_RUN_NO      (
         P_OBJECT_ID,
         P_COMPANY_ID,
         P_ACCOUNT_CODE,
         P_TIME_SPAN,
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END CALC_RUN_NO;
   FUNCTION MASS_QTY(
      P_OBJECT_ID IN VARCHAR2,
      P_COMPANY_ID IN VARCHAR2,
      P_ACCOUNT_CODE IN VARCHAR2,
      P_TIME_SPAN IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CNTRACC_PER_CPY_STATUS.MASS_QTY      (
         P_OBJECT_ID,
         P_COMPANY_ID,
         P_ACCOUNT_CODE,
         P_TIME_SPAN,
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END MASS_QTY;
   FUNCTION ROW_BY_PK(
      P_OBJECT_ID IN VARCHAR2,
      P_COMPANY_ID IN VARCHAR2,
      P_ACCOUNT_CODE IN VARCHAR2,
      P_TIME_SPAN IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN REC_ROW_BY_PK
   IS
      ret_value    REC_ROW_BY_PK ;
   BEGIN
      ret_value := EC_CNTRACC_PER_CPY_STATUS.ROW_BY_PK      (
         P_OBJECT_ID,
         P_COMPANY_ID,
         P_ACCOUNT_CODE,
         P_TIME_SPAN,
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END ROW_BY_PK;
   FUNCTION ROW_BY_REL_OPERATOR(
      P_OBJECT_ID IN VARCHAR2,
      P_COMPANY_ID IN VARCHAR2,
      P_ACCOUNT_CODE IN VARCHAR2,
      P_TIME_SPAN IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN REC_ROW_BY_REL_OPERATOR
   IS
      ret_value    REC_ROW_BY_REL_OPERATOR ;
   BEGIN
      ret_value := EC_CNTRACC_PER_CPY_STATUS.ROW_BY_REL_OPERATOR      (
         P_OBJECT_ID,
         P_COMPANY_ID,
         P_ACCOUNT_CODE,
         P_TIME_SPAN,
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END ROW_BY_REL_OPERATOR;
   FUNCTION VALUE_2(
      P_OBJECT_ID IN VARCHAR2,
      P_COMPANY_ID IN VARCHAR2,
      P_ACCOUNT_CODE IN VARCHAR2,
      P_TIME_SPAN IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CNTRACC_PER_CPY_STATUS.VALUE_2      (
         P_OBJECT_ID,
         P_COMPANY_ID,
         P_ACCOUNT_CODE,
         P_TIME_SPAN,
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END VALUE_2;
   FUNCTION VALUE_3(
      P_OBJECT_ID IN VARCHAR2,
      P_COMPANY_ID IN VARCHAR2,
      P_ACCOUNT_CODE IN VARCHAR2,
      P_TIME_SPAN IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CNTRACC_PER_CPY_STATUS.VALUE_3      (
         P_OBJECT_ID,
         P_COMPANY_ID,
         P_ACCOUNT_CODE,
         P_TIME_SPAN,
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END VALUE_3;
   FUNCTION VALUE_4(
      P_OBJECT_ID IN VARCHAR2,
      P_COMPANY_ID IN VARCHAR2,
      P_ACCOUNT_CODE IN VARCHAR2,
      P_TIME_SPAN IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CNTRACC_PER_CPY_STATUS.VALUE_4      (
         P_OBJECT_ID,
         P_COMPANY_ID,
         P_ACCOUNT_CODE,
         P_TIME_SPAN,
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END VALUE_4;
   FUNCTION DATE_4(
      P_OBJECT_ID IN VARCHAR2,
      P_COMPANY_ID IN VARCHAR2,
      P_ACCOUNT_CODE IN VARCHAR2,
      P_TIME_SPAN IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CNTRACC_PER_CPY_STATUS.DATE_4      (
         P_OBJECT_ID,
         P_COMPANY_ID,
         P_ACCOUNT_CODE,
         P_TIME_SPAN,
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END DATE_4;
   FUNCTION REC_ID(
      P_OBJECT_ID IN VARCHAR2,
      P_COMPANY_ID IN VARCHAR2,
      P_ACCOUNT_CODE IN VARCHAR2,
      P_TIME_SPAN IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_CNTRACC_PER_CPY_STATUS.REC_ID      (
         P_OBJECT_ID,
         P_COMPANY_ID,
         P_ACCOUNT_CODE,
         P_TIME_SPAN,
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END REC_ID;
   FUNCTION TEXT_1(
      P_OBJECT_ID IN VARCHAR2,
      P_COMPANY_ID IN VARCHAR2,
      P_ACCOUNT_CODE IN VARCHAR2,
      P_TIME_SPAN IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (16) ;
   BEGIN
      ret_value := EC_CNTRACC_PER_CPY_STATUS.TEXT_1      (
         P_OBJECT_ID,
         P_COMPANY_ID,
         P_ACCOUNT_CODE,
         P_TIME_SPAN,
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END TEXT_1;
   FUNCTION TEXT_2(
      P_OBJECT_ID IN VARCHAR2,
      P_COMPANY_ID IN VARCHAR2,
      P_ACCOUNT_CODE IN VARCHAR2,
      P_TIME_SPAN IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_CNTRACC_PER_CPY_STATUS.TEXT_2      (
         P_OBJECT_ID,
         P_COMPANY_ID,
         P_ACCOUNT_CODE,
         P_TIME_SPAN,
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END TEXT_2;
   FUNCTION VALUE_7(
      P_OBJECT_ID IN VARCHAR2,
      P_COMPANY_ID IN VARCHAR2,
      P_ACCOUNT_CODE IN VARCHAR2,
      P_TIME_SPAN IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CNTRACC_PER_CPY_STATUS.VALUE_7      (
         P_OBJECT_ID,
         P_COMPANY_ID,
         P_ACCOUNT_CODE,
         P_TIME_SPAN,
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END VALUE_7;
   FUNCTION VALUE_9(
      P_OBJECT_ID IN VARCHAR2,
      P_COMPANY_ID IN VARCHAR2,
      P_ACCOUNT_CODE IN VARCHAR2,
      P_TIME_SPAN IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CNTRACC_PER_CPY_STATUS.VALUE_9      (
         P_OBJECT_ID,
         P_COMPANY_ID,
         P_ACCOUNT_CODE,
         P_TIME_SPAN,
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END VALUE_9;
   FUNCTION DATE_1(
      P_OBJECT_ID IN VARCHAR2,
      P_COMPANY_ID IN VARCHAR2,
      P_ACCOUNT_CODE IN VARCHAR2,
      P_TIME_SPAN IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CNTRACC_PER_CPY_STATUS.DATE_1      (
         P_OBJECT_ID,
         P_COMPANY_ID,
         P_ACCOUNT_CODE,
         P_TIME_SPAN,
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END DATE_1;
   FUNCTION VALUE_10(
      P_OBJECT_ID IN VARCHAR2,
      P_COMPANY_ID IN VARCHAR2,
      P_ACCOUNT_CODE IN VARCHAR2,
      P_TIME_SPAN IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CNTRACC_PER_CPY_STATUS.VALUE_10      (
         P_OBJECT_ID,
         P_COMPANY_ID,
         P_ACCOUNT_CODE,
         P_TIME_SPAN,
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END VALUE_10;
   FUNCTION VALUE_8(
      P_OBJECT_ID IN VARCHAR2,
      P_COMPANY_ID IN VARCHAR2,
      P_ACCOUNT_CODE IN VARCHAR2,
      P_TIME_SPAN IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CNTRACC_PER_CPY_STATUS.VALUE_8      (
         P_OBJECT_ID,
         P_COMPANY_ID,
         P_ACCOUNT_CODE,
         P_TIME_SPAN,
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END VALUE_8;
   FUNCTION X2_QTY(
      P_OBJECT_ID IN VARCHAR2,
      P_COMPANY_ID IN VARCHAR2,
      P_ACCOUNT_CODE IN VARCHAR2,
      P_TIME_SPAN IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CNTRACC_PER_CPY_STATUS.X2_QTY      (
         P_OBJECT_ID,
         P_COMPANY_ID,
         P_ACCOUNT_CODE,
         P_TIME_SPAN,
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END X2_QTY;

END RP_CNTRACC_PER_CPY_STATUS;

/
--GRANT EXECUTE ON ECKERNEL_WST.RP_CNTRACC_PER_CPY_STATUS TO REPORT_ROLE_XXX;



 -- FINISH PKG_GEN_PKGS.sf_get_functions at:05/07/2019 11.00.11 AM


