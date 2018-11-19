
 -- START PKG_GEN_PKGS.sf_get_functions at:11/15/2018 07.37.37 AM


CREATE or REPLACE PACKAGE RP_STRM_MTH_PC_CPY
IS

   FUNCTION MATH_LIQ_VOL_ADJ(
      P_OBJECT_ID IN VARCHAR2,
      P_PROFIT_CENTRE_ID IN VARCHAR2,
      P_COMPANY_ID IN VARCHAR2,
      P_FROM_DAY IN DATE,
      P_TO_DAY IN DATE,
      P_METHOD IN VARCHAR2 DEFAULT 'SUM')
      RETURN NUMBER;
   FUNCTION TEXT_3(
      P_OBJECT_ID IN VARCHAR2,
      P_PROFIT_CENTRE_ID IN VARCHAR2,
      P_COMPANY_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2;
   FUNCTION APPROVAL_BY(
      P_OBJECT_ID IN VARCHAR2,
      P_PROFIT_CENTRE_ID IN VARCHAR2,
      P_COMPANY_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2;
   FUNCTION APPROVAL_STATE(
      P_OBJECT_ID IN VARCHAR2,
      P_PROFIT_CENTRE_ID IN VARCHAR2,
      P_COMPANY_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2;
   FUNCTION LIQ_VOL_ADJ(
      P_OBJECT_ID IN VARCHAR2,
      P_PROFIT_CENTRE_ID IN VARCHAR2,
      P_COMPANY_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER;
   FUNCTION MATH_VALUE_3(
      P_OBJECT_ID IN VARCHAR2,
      P_PROFIT_CENTRE_ID IN VARCHAR2,
      P_COMPANY_ID IN VARCHAR2,
      P_FROM_DAY IN DATE,
      P_TO_DAY IN DATE,
      P_METHOD IN VARCHAR2 DEFAULT 'SUM')
      RETURN NUMBER;
   FUNCTION MATH_VALUE_4(
      P_OBJECT_ID IN VARCHAR2,
      P_PROFIT_CENTRE_ID IN VARCHAR2,
      P_COMPANY_ID IN VARCHAR2,
      P_FROM_DAY IN DATE,
      P_TO_DAY IN DATE,
      P_METHOD IN VARCHAR2 DEFAULT 'SUM')
      RETURN NUMBER;
   FUNCTION MATH_VALUE_8(
      P_OBJECT_ID IN VARCHAR2,
      P_PROFIT_CENTRE_ID IN VARCHAR2,
      P_COMPANY_ID IN VARCHAR2,
      P_FROM_DAY IN DATE,
      P_TO_DAY IN DATE,
      P_METHOD IN VARCHAR2 DEFAULT 'SUM')
      RETURN NUMBER;
   FUNCTION VALUE_5(
      P_OBJECT_ID IN VARCHAR2,
      P_PROFIT_CENTRE_ID IN VARCHAR2,
      P_COMPANY_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER;
   FUNCTION GAS_VOL_ADJ(
      P_OBJECT_ID IN VARCHAR2,
      P_PROFIT_CENTRE_ID IN VARCHAR2,
      P_COMPANY_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER;
   FUNCTION MASS_ADJ(
      P_OBJECT_ID IN VARCHAR2,
      P_PROFIT_CENTRE_ID IN VARCHAR2,
      P_COMPANY_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER;
   FUNCTION MATH_GAS_VOL_ADJ(
      P_OBJECT_ID IN VARCHAR2,
      P_PROFIT_CENTRE_ID IN VARCHAR2,
      P_COMPANY_ID IN VARCHAR2,
      P_FROM_DAY IN DATE,
      P_TO_DAY IN DATE,
      P_METHOD IN VARCHAR2 DEFAULT 'SUM')
      RETURN NUMBER;
   FUNCTION MATH_MASS_ADJ(
      P_OBJECT_ID IN VARCHAR2,
      P_PROFIT_CENTRE_ID IN VARCHAR2,
      P_COMPANY_ID IN VARCHAR2,
      P_FROM_DAY IN DATE,
      P_TO_DAY IN DATE,
      P_METHOD IN VARCHAR2 DEFAULT 'SUM')
      RETURN NUMBER;
   FUNCTION MATH_VALUE_6(
      P_OBJECT_ID IN VARCHAR2,
      P_PROFIT_CENTRE_ID IN VARCHAR2,
      P_COMPANY_ID IN VARCHAR2,
      P_FROM_DAY IN DATE,
      P_TO_DAY IN DATE,
      P_METHOD IN VARCHAR2 DEFAULT 'SUM')
      RETURN NUMBER;
   FUNCTION NEXT_DAYTIME(
      P_OBJECT_ID IN VARCHAR2,
      P_PROFIT_CENTRE_ID IN VARCHAR2,
      P_COMPANY_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION PREV_EQUAL_DAYTIME(
      P_OBJECT_ID IN VARCHAR2,
      P_PROFIT_CENTRE_ID IN VARCHAR2,
      P_COMPANY_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION COMMENTS(
      P_OBJECT_ID IN VARCHAR2,
      P_PROFIT_CENTRE_ID IN VARCHAR2,
      P_COMPANY_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2;
   FUNCTION COUNT_ROWS(
      P_OBJECT_ID IN VARCHAR2,
      P_PROFIT_CENTRE_ID IN VARCHAR2,
      P_COMPANY_ID IN VARCHAR2,
      P_FROM_DAY IN DATE,
      P_TO_DAY IN DATE)
      RETURN NUMBER;
   FUNCTION MATH_VALUE_1(
      P_OBJECT_ID IN VARCHAR2,
      P_PROFIT_CENTRE_ID IN VARCHAR2,
      P_COMPANY_ID IN VARCHAR2,
      P_FROM_DAY IN DATE,
      P_TO_DAY IN DATE,
      P_METHOD IN VARCHAR2 DEFAULT 'SUM')
      RETURN NUMBER;
   FUNCTION MATH_VALUE_5(
      P_OBJECT_ID IN VARCHAR2,
      P_PROFIT_CENTRE_ID IN VARCHAR2,
      P_COMPANY_ID IN VARCHAR2,
      P_FROM_DAY IN DATE,
      P_TO_DAY IN DATE,
      P_METHOD IN VARCHAR2 DEFAULT 'SUM')
      RETURN NUMBER;
   FUNCTION MATH_VALUE_7(
      P_OBJECT_ID IN VARCHAR2,
      P_PROFIT_CENTRE_ID IN VARCHAR2,
      P_COMPANY_ID IN VARCHAR2,
      P_FROM_DAY IN DATE,
      P_TO_DAY IN DATE,
      P_METHOD IN VARCHAR2 DEFAULT 'SUM')
      RETURN NUMBER;
   FUNCTION MATH_VALUE_9(
      P_OBJECT_ID IN VARCHAR2,
      P_PROFIT_CENTRE_ID IN VARCHAR2,
      P_COMPANY_ID IN VARCHAR2,
      P_FROM_DAY IN DATE,
      P_TO_DAY IN DATE,
      P_METHOD IN VARCHAR2 DEFAULT 'SUM')
      RETURN NUMBER;
   FUNCTION NEXT_EQUAL_DAYTIME(
      P_OBJECT_ID IN VARCHAR2,
      P_PROFIT_CENTRE_ID IN VARCHAR2,
      P_COMPANY_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION TEXT_4(
      P_OBJECT_ID IN VARCHAR2,
      P_PROFIT_CENTRE_ID IN VARCHAR2,
      P_COMPANY_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2;
   FUNCTION VALUE_6(
      P_OBJECT_ID IN VARCHAR2,
      P_PROFIT_CENTRE_ID IN VARCHAR2,
      P_COMPANY_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER;
   FUNCTION ENERGY_ADJ(
      P_OBJECT_ID IN VARCHAR2,
      P_PROFIT_CENTRE_ID IN VARCHAR2,
      P_COMPANY_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER;
   FUNCTION MATH_ENERGY_ADJ(
      P_OBJECT_ID IN VARCHAR2,
      P_PROFIT_CENTRE_ID IN VARCHAR2,
      P_COMPANY_ID IN VARCHAR2,
      P_FROM_DAY IN DATE,
      P_TO_DAY IN DATE,
      P_METHOD IN VARCHAR2 DEFAULT 'SUM')
      RETURN NUMBER;
   FUNCTION PREV_DAYTIME(
      P_OBJECT_ID IN VARCHAR2,
      P_PROFIT_CENTRE_ID IN VARCHAR2,
      P_COMPANY_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION RECORD_STATUS(
      P_OBJECT_ID IN VARCHAR2,
      P_PROFIT_CENTRE_ID IN VARCHAR2,
      P_COMPANY_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2;
   FUNCTION VALUE_1(
      P_OBJECT_ID IN VARCHAR2,
      P_PROFIT_CENTRE_ID IN VARCHAR2,
      P_COMPANY_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER;
   FUNCTION APPROVAL_DATE(
      P_OBJECT_ID IN VARCHAR2,
      P_PROFIT_CENTRE_ID IN VARCHAR2,
      P_COMPANY_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN DATE;
   FUNCTION MATH_VALUE_2(
      P_OBJECT_ID IN VARCHAR2,
      P_PROFIT_CENTRE_ID IN VARCHAR2,
      P_COMPANY_ID IN VARCHAR2,
      P_FROM_DAY IN DATE,
      P_TO_DAY IN DATE,
      P_METHOD IN VARCHAR2 DEFAULT 'SUM')
      RETURN NUMBER;
      TYPE REC_ROW_BY_PK IS RECORD (
         OBJECT_ID VARCHAR2 (32) ,
         PROFIT_CENTRE_ID VARCHAR2 (32) ,
         COMPANY_ID VARCHAR2 (32) ,
         DAYTIME  DATE ,
         GAS_VOL_ADJ NUMBER ,
         LIQ_VOL_ADJ NUMBER ,
         MASS_ADJ NUMBER ,
         ENERGY_ADJ NUMBER ,
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
         TEXT_1 VARCHAR2 (16) ,
         TEXT_2 VARCHAR2 (32) ,
         TEXT_3 VARCHAR2 (240) ,
         TEXT_4 VARCHAR2 (1000) ,
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
      P_OBJECT_ID IN VARCHAR2,
      P_PROFIT_CENTRE_ID IN VARCHAR2,
      P_COMPANY_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN REC_ROW_BY_PK;
      TYPE REC_ROW_BY_REL_OPERATOR IS RECORD (
         OBJECT_ID VARCHAR2 (32) ,
         PROFIT_CENTRE_ID VARCHAR2 (32) ,
         COMPANY_ID VARCHAR2 (32) ,
         DAYTIME  DATE ,
         GAS_VOL_ADJ NUMBER ,
         LIQ_VOL_ADJ NUMBER ,
         MASS_ADJ NUMBER ,
         ENERGY_ADJ NUMBER ,
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
         TEXT_1 VARCHAR2 (16) ,
         TEXT_2 VARCHAR2 (32) ,
         TEXT_3 VARCHAR2 (240) ,
         TEXT_4 VARCHAR2 (1000) ,
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
   FUNCTION ROW_BY_REL_OPERATOR(
      P_OBJECT_ID IN VARCHAR2,
      P_PROFIT_CENTRE_ID IN VARCHAR2,
      P_COMPANY_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN REC_ROW_BY_REL_OPERATOR;
   FUNCTION VALUE_2(
      P_OBJECT_ID IN VARCHAR2,
      P_PROFIT_CENTRE_ID IN VARCHAR2,
      P_COMPANY_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER;
   FUNCTION VALUE_3(
      P_OBJECT_ID IN VARCHAR2,
      P_PROFIT_CENTRE_ID IN VARCHAR2,
      P_COMPANY_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER;
   FUNCTION VALUE_4(
      P_OBJECT_ID IN VARCHAR2,
      P_PROFIT_CENTRE_ID IN VARCHAR2,
      P_COMPANY_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER;
   FUNCTION REC_ID(
      P_OBJECT_ID IN VARCHAR2,
      P_PROFIT_CENTRE_ID IN VARCHAR2,
      P_COMPANY_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2;
   FUNCTION TEXT_1(
      P_OBJECT_ID IN VARCHAR2,
      P_PROFIT_CENTRE_ID IN VARCHAR2,
      P_COMPANY_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2;
   FUNCTION TEXT_2(
      P_OBJECT_ID IN VARCHAR2,
      P_PROFIT_CENTRE_ID IN VARCHAR2,
      P_COMPANY_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2;
   FUNCTION VALUE_7(
      P_OBJECT_ID IN VARCHAR2,
      P_PROFIT_CENTRE_ID IN VARCHAR2,
      P_COMPANY_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER;
   FUNCTION VALUE_9(
      P_OBJECT_ID IN VARCHAR2,
      P_PROFIT_CENTRE_ID IN VARCHAR2,
      P_COMPANY_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER;
   FUNCTION MATH_VALUE_10(
      P_OBJECT_ID IN VARCHAR2,
      P_PROFIT_CENTRE_ID IN VARCHAR2,
      P_COMPANY_ID IN VARCHAR2,
      P_FROM_DAY IN DATE,
      P_TO_DAY IN DATE,
      P_METHOD IN VARCHAR2 DEFAULT 'SUM')
      RETURN NUMBER;
   FUNCTION VALUE_10(
      P_OBJECT_ID IN VARCHAR2,
      P_PROFIT_CENTRE_ID IN VARCHAR2,
      P_COMPANY_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER;
   FUNCTION VALUE_8(
      P_OBJECT_ID IN VARCHAR2,
      P_PROFIT_CENTRE_ID IN VARCHAR2,
      P_COMPANY_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER;

END RP_STRM_MTH_PC_CPY;

/



CREATE or REPLACE PACKAGE BODY RP_STRM_MTH_PC_CPY
IS

   FUNCTION MATH_LIQ_VOL_ADJ(
      P_OBJECT_ID IN VARCHAR2,
      P_PROFIT_CENTRE_ID IN VARCHAR2,
      P_COMPANY_ID IN VARCHAR2,
      P_FROM_DAY IN DATE,
      P_TO_DAY IN DATE,
      P_METHOD IN VARCHAR2 DEFAULT 'SUM')
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_STRM_MTH_PC_CPY.MATH_LIQ_VOL_ADJ      (
         P_OBJECT_ID,
         P_PROFIT_CENTRE_ID,
         P_COMPANY_ID,
         P_FROM_DAY,
         P_TO_DAY,
         P_METHOD );
         RETURN ret_value;
   END MATH_LIQ_VOL_ADJ;
   FUNCTION TEXT_3(
      P_OBJECT_ID IN VARCHAR2,
      P_PROFIT_CENTRE_ID IN VARCHAR2,
      P_COMPANY_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_STRM_MTH_PC_CPY.TEXT_3      (
         P_OBJECT_ID,
         P_PROFIT_CENTRE_ID,
         P_COMPANY_ID,
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END TEXT_3;
   FUNCTION APPROVAL_BY(
      P_OBJECT_ID IN VARCHAR2,
      P_PROFIT_CENTRE_ID IN VARCHAR2,
      P_COMPANY_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (30) ;
   BEGIN
      ret_value := EC_STRM_MTH_PC_CPY.APPROVAL_BY      (
         P_OBJECT_ID,
         P_PROFIT_CENTRE_ID,
         P_COMPANY_ID,
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END APPROVAL_BY;
   FUNCTION APPROVAL_STATE(
      P_OBJECT_ID IN VARCHAR2,
      P_PROFIT_CENTRE_ID IN VARCHAR2,
      P_COMPANY_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_STRM_MTH_PC_CPY.APPROVAL_STATE      (
         P_OBJECT_ID,
         P_PROFIT_CENTRE_ID,
         P_COMPANY_ID,
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END APPROVAL_STATE;
   FUNCTION LIQ_VOL_ADJ(
      P_OBJECT_ID IN VARCHAR2,
      P_PROFIT_CENTRE_ID IN VARCHAR2,
      P_COMPANY_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_STRM_MTH_PC_CPY.LIQ_VOL_ADJ      (
         P_OBJECT_ID,
         P_PROFIT_CENTRE_ID,
         P_COMPANY_ID,
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END LIQ_VOL_ADJ;
   FUNCTION MATH_VALUE_3(
      P_OBJECT_ID IN VARCHAR2,
      P_PROFIT_CENTRE_ID IN VARCHAR2,
      P_COMPANY_ID IN VARCHAR2,
      P_FROM_DAY IN DATE,
      P_TO_DAY IN DATE,
      P_METHOD IN VARCHAR2 DEFAULT 'SUM')
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_STRM_MTH_PC_CPY.MATH_VALUE_3      (
         P_OBJECT_ID,
         P_PROFIT_CENTRE_ID,
         P_COMPANY_ID,
         P_FROM_DAY,
         P_TO_DAY,
         P_METHOD );
         RETURN ret_value;
   END MATH_VALUE_3;
   FUNCTION MATH_VALUE_4(
      P_OBJECT_ID IN VARCHAR2,
      P_PROFIT_CENTRE_ID IN VARCHAR2,
      P_COMPANY_ID IN VARCHAR2,
      P_FROM_DAY IN DATE,
      P_TO_DAY IN DATE,
      P_METHOD IN VARCHAR2 DEFAULT 'SUM')
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_STRM_MTH_PC_CPY.MATH_VALUE_4      (
         P_OBJECT_ID,
         P_PROFIT_CENTRE_ID,
         P_COMPANY_ID,
         P_FROM_DAY,
         P_TO_DAY,
         P_METHOD );
         RETURN ret_value;
   END MATH_VALUE_4;
   FUNCTION MATH_VALUE_8(
      P_OBJECT_ID IN VARCHAR2,
      P_PROFIT_CENTRE_ID IN VARCHAR2,
      P_COMPANY_ID IN VARCHAR2,
      P_FROM_DAY IN DATE,
      P_TO_DAY IN DATE,
      P_METHOD IN VARCHAR2 DEFAULT 'SUM')
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_STRM_MTH_PC_CPY.MATH_VALUE_8      (
         P_OBJECT_ID,
         P_PROFIT_CENTRE_ID,
         P_COMPANY_ID,
         P_FROM_DAY,
         P_TO_DAY,
         P_METHOD );
         RETURN ret_value;
   END MATH_VALUE_8;
   FUNCTION VALUE_5(
      P_OBJECT_ID IN VARCHAR2,
      P_PROFIT_CENTRE_ID IN VARCHAR2,
      P_COMPANY_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_STRM_MTH_PC_CPY.VALUE_5      (
         P_OBJECT_ID,
         P_PROFIT_CENTRE_ID,
         P_COMPANY_ID,
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END VALUE_5;
   FUNCTION GAS_VOL_ADJ(
      P_OBJECT_ID IN VARCHAR2,
      P_PROFIT_CENTRE_ID IN VARCHAR2,
      P_COMPANY_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_STRM_MTH_PC_CPY.GAS_VOL_ADJ      (
         P_OBJECT_ID,
         P_PROFIT_CENTRE_ID,
         P_COMPANY_ID,
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END GAS_VOL_ADJ;
   FUNCTION MASS_ADJ(
      P_OBJECT_ID IN VARCHAR2,
      P_PROFIT_CENTRE_ID IN VARCHAR2,
      P_COMPANY_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_STRM_MTH_PC_CPY.MASS_ADJ      (
         P_OBJECT_ID,
         P_PROFIT_CENTRE_ID,
         P_COMPANY_ID,
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END MASS_ADJ;
   FUNCTION MATH_GAS_VOL_ADJ(
      P_OBJECT_ID IN VARCHAR2,
      P_PROFIT_CENTRE_ID IN VARCHAR2,
      P_COMPANY_ID IN VARCHAR2,
      P_FROM_DAY IN DATE,
      P_TO_DAY IN DATE,
      P_METHOD IN VARCHAR2 DEFAULT 'SUM')
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_STRM_MTH_PC_CPY.MATH_GAS_VOL_ADJ      (
         P_OBJECT_ID,
         P_PROFIT_CENTRE_ID,
         P_COMPANY_ID,
         P_FROM_DAY,
         P_TO_DAY,
         P_METHOD );
         RETURN ret_value;
   END MATH_GAS_VOL_ADJ;
   FUNCTION MATH_MASS_ADJ(
      P_OBJECT_ID IN VARCHAR2,
      P_PROFIT_CENTRE_ID IN VARCHAR2,
      P_COMPANY_ID IN VARCHAR2,
      P_FROM_DAY IN DATE,
      P_TO_DAY IN DATE,
      P_METHOD IN VARCHAR2 DEFAULT 'SUM')
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_STRM_MTH_PC_CPY.MATH_MASS_ADJ      (
         P_OBJECT_ID,
         P_PROFIT_CENTRE_ID,
         P_COMPANY_ID,
         P_FROM_DAY,
         P_TO_DAY,
         P_METHOD );
         RETURN ret_value;
   END MATH_MASS_ADJ;
   FUNCTION MATH_VALUE_6(
      P_OBJECT_ID IN VARCHAR2,
      P_PROFIT_CENTRE_ID IN VARCHAR2,
      P_COMPANY_ID IN VARCHAR2,
      P_FROM_DAY IN DATE,
      P_TO_DAY IN DATE,
      P_METHOD IN VARCHAR2 DEFAULT 'SUM')
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_STRM_MTH_PC_CPY.MATH_VALUE_6      (
         P_OBJECT_ID,
         P_PROFIT_CENTRE_ID,
         P_COMPANY_ID,
         P_FROM_DAY,
         P_TO_DAY,
         P_METHOD );
         RETURN ret_value;
   END MATH_VALUE_6;
   FUNCTION NEXT_DAYTIME(
      P_OBJECT_ID IN VARCHAR2,
      P_PROFIT_CENTRE_ID IN VARCHAR2,
      P_COMPANY_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_STRM_MTH_PC_CPY.NEXT_DAYTIME      (
         P_OBJECT_ID,
         P_PROFIT_CENTRE_ID,
         P_COMPANY_ID,
         P_DAYTIME,
         P_NUM_ROWS );
         RETURN ret_value;
   END NEXT_DAYTIME;
   FUNCTION PREV_EQUAL_DAYTIME(
      P_OBJECT_ID IN VARCHAR2,
      P_PROFIT_CENTRE_ID IN VARCHAR2,
      P_COMPANY_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_STRM_MTH_PC_CPY.PREV_EQUAL_DAYTIME      (
         P_OBJECT_ID,
         P_PROFIT_CENTRE_ID,
         P_COMPANY_ID,
         P_DAYTIME,
         P_NUM_ROWS );
         RETURN ret_value;
   END PREV_EQUAL_DAYTIME;
   FUNCTION COMMENTS(
      P_OBJECT_ID IN VARCHAR2,
      P_PROFIT_CENTRE_ID IN VARCHAR2,
      P_COMPANY_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_STRM_MTH_PC_CPY.COMMENTS      (
         P_OBJECT_ID,
         P_PROFIT_CENTRE_ID,
         P_COMPANY_ID,
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END COMMENTS;
   FUNCTION COUNT_ROWS(
      P_OBJECT_ID IN VARCHAR2,
      P_PROFIT_CENTRE_ID IN VARCHAR2,
      P_COMPANY_ID IN VARCHAR2,
      P_FROM_DAY IN DATE,
      P_TO_DAY IN DATE)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_STRM_MTH_PC_CPY.COUNT_ROWS      (
         P_OBJECT_ID,
         P_PROFIT_CENTRE_ID,
         P_COMPANY_ID,
         P_FROM_DAY,
         P_TO_DAY );
         RETURN ret_value;
   END COUNT_ROWS;
   FUNCTION MATH_VALUE_1(
      P_OBJECT_ID IN VARCHAR2,
      P_PROFIT_CENTRE_ID IN VARCHAR2,
      P_COMPANY_ID IN VARCHAR2,
      P_FROM_DAY IN DATE,
      P_TO_DAY IN DATE,
      P_METHOD IN VARCHAR2 DEFAULT 'SUM')
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_STRM_MTH_PC_CPY.MATH_VALUE_1      (
         P_OBJECT_ID,
         P_PROFIT_CENTRE_ID,
         P_COMPANY_ID,
         P_FROM_DAY,
         P_TO_DAY,
         P_METHOD );
         RETURN ret_value;
   END MATH_VALUE_1;
   FUNCTION MATH_VALUE_5(
      P_OBJECT_ID IN VARCHAR2,
      P_PROFIT_CENTRE_ID IN VARCHAR2,
      P_COMPANY_ID IN VARCHAR2,
      P_FROM_DAY IN DATE,
      P_TO_DAY IN DATE,
      P_METHOD IN VARCHAR2 DEFAULT 'SUM')
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_STRM_MTH_PC_CPY.MATH_VALUE_5      (
         P_OBJECT_ID,
         P_PROFIT_CENTRE_ID,
         P_COMPANY_ID,
         P_FROM_DAY,
         P_TO_DAY,
         P_METHOD );
         RETURN ret_value;
   END MATH_VALUE_5;
   FUNCTION MATH_VALUE_7(
      P_OBJECT_ID IN VARCHAR2,
      P_PROFIT_CENTRE_ID IN VARCHAR2,
      P_COMPANY_ID IN VARCHAR2,
      P_FROM_DAY IN DATE,
      P_TO_DAY IN DATE,
      P_METHOD IN VARCHAR2 DEFAULT 'SUM')
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_STRM_MTH_PC_CPY.MATH_VALUE_7      (
         P_OBJECT_ID,
         P_PROFIT_CENTRE_ID,
         P_COMPANY_ID,
         P_FROM_DAY,
         P_TO_DAY,
         P_METHOD );
         RETURN ret_value;
   END MATH_VALUE_7;
   FUNCTION MATH_VALUE_9(
      P_OBJECT_ID IN VARCHAR2,
      P_PROFIT_CENTRE_ID IN VARCHAR2,
      P_COMPANY_ID IN VARCHAR2,
      P_FROM_DAY IN DATE,
      P_TO_DAY IN DATE,
      P_METHOD IN VARCHAR2 DEFAULT 'SUM')
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_STRM_MTH_PC_CPY.MATH_VALUE_9      (
         P_OBJECT_ID,
         P_PROFIT_CENTRE_ID,
         P_COMPANY_ID,
         P_FROM_DAY,
         P_TO_DAY,
         P_METHOD );
         RETURN ret_value;
   END MATH_VALUE_9;
   FUNCTION NEXT_EQUAL_DAYTIME(
      P_OBJECT_ID IN VARCHAR2,
      P_PROFIT_CENTRE_ID IN VARCHAR2,
      P_COMPANY_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_STRM_MTH_PC_CPY.NEXT_EQUAL_DAYTIME      (
         P_OBJECT_ID,
         P_PROFIT_CENTRE_ID,
         P_COMPANY_ID,
         P_DAYTIME,
         P_NUM_ROWS );
         RETURN ret_value;
   END NEXT_EQUAL_DAYTIME;
   FUNCTION TEXT_4(
      P_OBJECT_ID IN VARCHAR2,
      P_PROFIT_CENTRE_ID IN VARCHAR2,
      P_COMPANY_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1000) ;
   BEGIN
      ret_value := EC_STRM_MTH_PC_CPY.TEXT_4      (
         P_OBJECT_ID,
         P_PROFIT_CENTRE_ID,
         P_COMPANY_ID,
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END TEXT_4;
   FUNCTION VALUE_6(
      P_OBJECT_ID IN VARCHAR2,
      P_PROFIT_CENTRE_ID IN VARCHAR2,
      P_COMPANY_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_STRM_MTH_PC_CPY.VALUE_6      (
         P_OBJECT_ID,
         P_PROFIT_CENTRE_ID,
         P_COMPANY_ID,
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END VALUE_6;
   FUNCTION ENERGY_ADJ(
      P_OBJECT_ID IN VARCHAR2,
      P_PROFIT_CENTRE_ID IN VARCHAR2,
      P_COMPANY_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_STRM_MTH_PC_CPY.ENERGY_ADJ      (
         P_OBJECT_ID,
         P_PROFIT_CENTRE_ID,
         P_COMPANY_ID,
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END ENERGY_ADJ;
   FUNCTION MATH_ENERGY_ADJ(
      P_OBJECT_ID IN VARCHAR2,
      P_PROFIT_CENTRE_ID IN VARCHAR2,
      P_COMPANY_ID IN VARCHAR2,
      P_FROM_DAY IN DATE,
      P_TO_DAY IN DATE,
      P_METHOD IN VARCHAR2 DEFAULT 'SUM')
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_STRM_MTH_PC_CPY.MATH_ENERGY_ADJ      (
         P_OBJECT_ID,
         P_PROFIT_CENTRE_ID,
         P_COMPANY_ID,
         P_FROM_DAY,
         P_TO_DAY,
         P_METHOD );
         RETURN ret_value;
   END MATH_ENERGY_ADJ;
   FUNCTION PREV_DAYTIME(
      P_OBJECT_ID IN VARCHAR2,
      P_PROFIT_CENTRE_ID IN VARCHAR2,
      P_COMPANY_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_STRM_MTH_PC_CPY.PREV_DAYTIME      (
         P_OBJECT_ID,
         P_PROFIT_CENTRE_ID,
         P_COMPANY_ID,
         P_DAYTIME,
         P_NUM_ROWS );
         RETURN ret_value;
   END PREV_DAYTIME;
   FUNCTION RECORD_STATUS(
      P_OBJECT_ID IN VARCHAR2,
      P_PROFIT_CENTRE_ID IN VARCHAR2,
      P_COMPANY_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_STRM_MTH_PC_CPY.RECORD_STATUS      (
         P_OBJECT_ID,
         P_PROFIT_CENTRE_ID,
         P_COMPANY_ID,
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END RECORD_STATUS;
   FUNCTION VALUE_1(
      P_OBJECT_ID IN VARCHAR2,
      P_PROFIT_CENTRE_ID IN VARCHAR2,
      P_COMPANY_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_STRM_MTH_PC_CPY.VALUE_1      (
         P_OBJECT_ID,
         P_PROFIT_CENTRE_ID,
         P_COMPANY_ID,
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END VALUE_1;
   FUNCTION APPROVAL_DATE(
      P_OBJECT_ID IN VARCHAR2,
      P_PROFIT_CENTRE_ID IN VARCHAR2,
      P_COMPANY_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_STRM_MTH_PC_CPY.APPROVAL_DATE      (
         P_OBJECT_ID,
         P_PROFIT_CENTRE_ID,
         P_COMPANY_ID,
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END APPROVAL_DATE;
   FUNCTION MATH_VALUE_2(
      P_OBJECT_ID IN VARCHAR2,
      P_PROFIT_CENTRE_ID IN VARCHAR2,
      P_COMPANY_ID IN VARCHAR2,
      P_FROM_DAY IN DATE,
      P_TO_DAY IN DATE,
      P_METHOD IN VARCHAR2 DEFAULT 'SUM')
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_STRM_MTH_PC_CPY.MATH_VALUE_2      (
         P_OBJECT_ID,
         P_PROFIT_CENTRE_ID,
         P_COMPANY_ID,
         P_FROM_DAY,
         P_TO_DAY,
         P_METHOD );
         RETURN ret_value;
   END MATH_VALUE_2;
   FUNCTION ROW_BY_PK(
      P_OBJECT_ID IN VARCHAR2,
      P_PROFIT_CENTRE_ID IN VARCHAR2,
      P_COMPANY_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN REC_ROW_BY_PK
   IS
      ret_value    REC_ROW_BY_PK ;
   BEGIN
      ret_value := EC_STRM_MTH_PC_CPY.ROW_BY_PK      (
         P_OBJECT_ID,
         P_PROFIT_CENTRE_ID,
         P_COMPANY_ID,
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END ROW_BY_PK;
   FUNCTION ROW_BY_REL_OPERATOR(
      P_OBJECT_ID IN VARCHAR2,
      P_PROFIT_CENTRE_ID IN VARCHAR2,
      P_COMPANY_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN REC_ROW_BY_REL_OPERATOR
   IS
      ret_value    REC_ROW_BY_REL_OPERATOR ;
   BEGIN
      ret_value := EC_STRM_MTH_PC_CPY.ROW_BY_REL_OPERATOR      (
         P_OBJECT_ID,
         P_PROFIT_CENTRE_ID,
         P_COMPANY_ID,
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END ROW_BY_REL_OPERATOR;
   FUNCTION VALUE_2(
      P_OBJECT_ID IN VARCHAR2,
      P_PROFIT_CENTRE_ID IN VARCHAR2,
      P_COMPANY_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_STRM_MTH_PC_CPY.VALUE_2      (
         P_OBJECT_ID,
         P_PROFIT_CENTRE_ID,
         P_COMPANY_ID,
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END VALUE_2;
   FUNCTION VALUE_3(
      P_OBJECT_ID IN VARCHAR2,
      P_PROFIT_CENTRE_ID IN VARCHAR2,
      P_COMPANY_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_STRM_MTH_PC_CPY.VALUE_3      (
         P_OBJECT_ID,
         P_PROFIT_CENTRE_ID,
         P_COMPANY_ID,
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END VALUE_3;
   FUNCTION VALUE_4(
      P_OBJECT_ID IN VARCHAR2,
      P_PROFIT_CENTRE_ID IN VARCHAR2,
      P_COMPANY_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_STRM_MTH_PC_CPY.VALUE_4      (
         P_OBJECT_ID,
         P_PROFIT_CENTRE_ID,
         P_COMPANY_ID,
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END VALUE_4;
   FUNCTION REC_ID(
      P_OBJECT_ID IN VARCHAR2,
      P_PROFIT_CENTRE_ID IN VARCHAR2,
      P_COMPANY_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_STRM_MTH_PC_CPY.REC_ID      (
         P_OBJECT_ID,
         P_PROFIT_CENTRE_ID,
         P_COMPANY_ID,
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END REC_ID;
   FUNCTION TEXT_1(
      P_OBJECT_ID IN VARCHAR2,
      P_PROFIT_CENTRE_ID IN VARCHAR2,
      P_COMPANY_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (16) ;
   BEGIN
      ret_value := EC_STRM_MTH_PC_CPY.TEXT_1      (
         P_OBJECT_ID,
         P_PROFIT_CENTRE_ID,
         P_COMPANY_ID,
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END TEXT_1;
   FUNCTION TEXT_2(
      P_OBJECT_ID IN VARCHAR2,
      P_PROFIT_CENTRE_ID IN VARCHAR2,
      P_COMPANY_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_STRM_MTH_PC_CPY.TEXT_2      (
         P_OBJECT_ID,
         P_PROFIT_CENTRE_ID,
         P_COMPANY_ID,
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END TEXT_2;
   FUNCTION VALUE_7(
      P_OBJECT_ID IN VARCHAR2,
      P_PROFIT_CENTRE_ID IN VARCHAR2,
      P_COMPANY_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_STRM_MTH_PC_CPY.VALUE_7      (
         P_OBJECT_ID,
         P_PROFIT_CENTRE_ID,
         P_COMPANY_ID,
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END VALUE_7;
   FUNCTION VALUE_9(
      P_OBJECT_ID IN VARCHAR2,
      P_PROFIT_CENTRE_ID IN VARCHAR2,
      P_COMPANY_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_STRM_MTH_PC_CPY.VALUE_9      (
         P_OBJECT_ID,
         P_PROFIT_CENTRE_ID,
         P_COMPANY_ID,
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END VALUE_9;
   FUNCTION MATH_VALUE_10(
      P_OBJECT_ID IN VARCHAR2,
      P_PROFIT_CENTRE_ID IN VARCHAR2,
      P_COMPANY_ID IN VARCHAR2,
      P_FROM_DAY IN DATE,
      P_TO_DAY IN DATE,
      P_METHOD IN VARCHAR2 DEFAULT 'SUM')
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_STRM_MTH_PC_CPY.MATH_VALUE_10      (
         P_OBJECT_ID,
         P_PROFIT_CENTRE_ID,
         P_COMPANY_ID,
         P_FROM_DAY,
         P_TO_DAY,
         P_METHOD );
         RETURN ret_value;
   END MATH_VALUE_10;
   FUNCTION VALUE_10(
      P_OBJECT_ID IN VARCHAR2,
      P_PROFIT_CENTRE_ID IN VARCHAR2,
      P_COMPANY_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_STRM_MTH_PC_CPY.VALUE_10      (
         P_OBJECT_ID,
         P_PROFIT_CENTRE_ID,
         P_COMPANY_ID,
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END VALUE_10;
   FUNCTION VALUE_8(
      P_OBJECT_ID IN VARCHAR2,
      P_PROFIT_CENTRE_ID IN VARCHAR2,
      P_COMPANY_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_STRM_MTH_PC_CPY.VALUE_8      (
         P_OBJECT_ID,
         P_PROFIT_CENTRE_ID,
         P_COMPANY_ID,
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END VALUE_8;

END RP_STRM_MTH_PC_CPY;

/
--GRANT EXECUTE ON ECKERNEL_WST.RP_STRM_MTH_PC_CPY TO REPORT_ROLE_XXX;



 -- FINISH PKG_GEN_PKGS.sf_get_functions at:11/15/2018 07.37.46 AM


