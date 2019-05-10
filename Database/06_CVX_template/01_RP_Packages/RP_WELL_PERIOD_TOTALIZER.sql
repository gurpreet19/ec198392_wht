
 -- START PKG_GEN_PKGS.sf_get_functions at:05/07/2019 05.14.04 AM


CREATE or REPLACE PACKAGE RP_WELL_PERIOD_TOTALIZER
IS

   FUNCTION AVG_TEMP(
      P_OBJECT_ID IN VARCHAR2,
      P_CLASS_NAME IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER;
   FUNCTION TEXT_3(
      P_OBJECT_ID IN VARCHAR2,
      P_CLASS_NAME IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2;
   FUNCTION TEXT_4(
      P_OBJECT_ID IN VARCHAR2,
      P_CLASS_NAME IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2;
   FUNCTION APPROVAL_BY(
      P_OBJECT_ID IN VARCHAR2,
      P_CLASS_NAME IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2;
   FUNCTION APPROVAL_STATE(
      P_OBJECT_ID IN VARCHAR2,
      P_CLASS_NAME IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2;
   FUNCTION CLOSING_READING(
      P_OBJECT_ID IN VARCHAR2,
      P_CLASS_NAME IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER;
   FUNCTION MATH_VALUE_3(
      P_OBJECT_ID IN VARCHAR2,
      P_CLASS_NAME IN VARCHAR2,
      P_FROM_DAY IN DATE,
      P_TO_DAY IN DATE,
      P_METHOD IN VARCHAR2 DEFAULT 'SUM')
      RETURN NUMBER;
   FUNCTION MATH_VALUE_4(
      P_OBJECT_ID IN VARCHAR2,
      P_CLASS_NAME IN VARCHAR2,
      P_FROM_DAY IN DATE,
      P_TO_DAY IN DATE,
      P_METHOD IN VARCHAR2 DEFAULT 'SUM')
      RETURN NUMBER;
   FUNCTION MATH_VALUE_8(
      P_OBJECT_ID IN VARCHAR2,
      P_CLASS_NAME IN VARCHAR2,
      P_FROM_DAY IN DATE,
      P_TO_DAY IN DATE,
      P_METHOD IN VARCHAR2 DEFAULT 'SUM')
      RETURN NUMBER;
   FUNCTION UTC_END_DATE(
      P_OBJECT_ID IN VARCHAR2,
      P_CLASS_NAME IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN DATE;
   FUNCTION VALUE_5(
      P_OBJECT_ID IN VARCHAR2,
      P_CLASS_NAME IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER;
   FUNCTION MATH_VALUE_6(
      P_OBJECT_ID IN VARCHAR2,
      P_CLASS_NAME IN VARCHAR2,
      P_FROM_DAY IN DATE,
      P_TO_DAY IN DATE,
      P_METHOD IN VARCHAR2 DEFAULT 'SUM')
      RETURN NUMBER;
   FUNCTION NEXT_DAYTIME(
      P_OBJECT_ID IN VARCHAR2,
      P_CLASS_NAME IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION PREV_EQUAL_DAYTIME(
      P_OBJECT_ID IN VARCHAR2,
      P_CLASS_NAME IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION COMMENTS(
      P_OBJECT_ID IN VARCHAR2,
      P_CLASS_NAME IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2;
   FUNCTION COUNT_ROWS(
      P_OBJECT_ID IN VARCHAR2,
      P_CLASS_NAME IN VARCHAR2,
      P_FROM_DAY IN DATE,
      P_TO_DAY IN DATE)
      RETURN NUMBER;
   FUNCTION MATH_VALUE_1(
      P_OBJECT_ID IN VARCHAR2,
      P_CLASS_NAME IN VARCHAR2,
      P_FROM_DAY IN DATE,
      P_TO_DAY IN DATE,
      P_METHOD IN VARCHAR2 DEFAULT 'SUM')
      RETURN NUMBER;
   FUNCTION MATH_VALUE_5(
      P_OBJECT_ID IN VARCHAR2,
      P_CLASS_NAME IN VARCHAR2,
      P_FROM_DAY IN DATE,
      P_TO_DAY IN DATE,
      P_METHOD IN VARCHAR2 DEFAULT 'SUM')
      RETURN NUMBER;
   FUNCTION MATH_VALUE_7(
      P_OBJECT_ID IN VARCHAR2,
      P_CLASS_NAME IN VARCHAR2,
      P_FROM_DAY IN DATE,
      P_TO_DAY IN DATE,
      P_METHOD IN VARCHAR2 DEFAULT 'SUM')
      RETURN NUMBER;
   FUNCTION MATH_VALUE_9(
      P_OBJECT_ID IN VARCHAR2,
      P_CLASS_NAME IN VARCHAR2,
      P_FROM_DAY IN DATE,
      P_TO_DAY IN DATE,
      P_METHOD IN VARCHAR2 DEFAULT 'SUM')
      RETURN NUMBER;
   FUNCTION NEXT_EQUAL_DAYTIME(
      P_OBJECT_ID IN VARCHAR2,
      P_CLASS_NAME IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION OPENING_READING(
      P_OBJECT_ID IN VARCHAR2,
      P_CLASS_NAME IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER;
   FUNCTION UTC_DAYTIME(
      P_OBJECT_ID IN VARCHAR2,
      P_CLASS_NAME IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN DATE;
   FUNCTION VALUE_6(
      P_OBJECT_ID IN VARCHAR2,
      P_CLASS_NAME IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER;
   FUNCTION END_DATE(
      P_OBJECT_ID IN VARCHAR2,
      P_CLASS_NAME IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN DATE;
   FUNCTION MATH_AVG_PRESS(
      P_OBJECT_ID IN VARCHAR2,
      P_CLASS_NAME IN VARCHAR2,
      P_FROM_DAY IN DATE,
      P_TO_DAY IN DATE,
      P_METHOD IN VARCHAR2 DEFAULT 'SUM')
      RETURN NUMBER;
   FUNCTION PREV_DAYTIME(
      P_OBJECT_ID IN VARCHAR2,
      P_CLASS_NAME IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION RECORD_STATUS(
      P_OBJECT_ID IN VARCHAR2,
      P_CLASS_NAME IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2;
   FUNCTION VALUE_1(
      P_OBJECT_ID IN VARCHAR2,
      P_CLASS_NAME IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER;
   FUNCTION APPROVAL_DATE(
      P_OBJECT_ID IN VARCHAR2,
      P_CLASS_NAME IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN DATE;
   FUNCTION AVG_PRESS(
      P_OBJECT_ID IN VARCHAR2,
      P_CLASS_NAME IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER;
   FUNCTION MATH_OPENING_READING(
      P_OBJECT_ID IN VARCHAR2,
      P_CLASS_NAME IN VARCHAR2,
      P_FROM_DAY IN DATE,
      P_TO_DAY IN DATE,
      P_METHOD IN VARCHAR2 DEFAULT 'SUM')
      RETURN NUMBER;
   FUNCTION MATH_VALUE_2(
      P_OBJECT_ID IN VARCHAR2,
      P_CLASS_NAME IN VARCHAR2,
      P_FROM_DAY IN DATE,
      P_TO_DAY IN DATE,
      P_METHOD IN VARCHAR2 DEFAULT 'SUM')
      RETURN NUMBER;
      TYPE REC_ROW_BY_PK IS RECORD (
         OBJECT_ID VARCHAR2 (32) ,
         CLASS_NAME VARCHAR2 (24) ,
         DAYTIME  DATE ,
         END_DATE  DATE ,
         PRODUCTION_DAY  DATE ,
         OPENING_READING NUMBER ,
         CLOSING_READING NUMBER ,
         MANUAL_ADJUSTMENT NUMBER ,
         AVG_TEMP NUMBER ,
         AVG_PRESS NUMBER ,
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
         TEXT_4 VARCHAR2 (2000) ,
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
         END_DAY  DATE ,
         UTC_DAYTIME  DATE ,
         UTC_END_DATE  DATE  );
   FUNCTION ROW_BY_PK(
      P_OBJECT_ID IN VARCHAR2,
      P_CLASS_NAME IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN REC_ROW_BY_PK;
      TYPE REC_ROW_BY_REL_OPERATOR IS RECORD (
         OBJECT_ID VARCHAR2 (32) ,
         CLASS_NAME VARCHAR2 (24) ,
         DAYTIME  DATE ,
         END_DATE  DATE ,
         PRODUCTION_DAY  DATE ,
         OPENING_READING NUMBER ,
         CLOSING_READING NUMBER ,
         MANUAL_ADJUSTMENT NUMBER ,
         AVG_TEMP NUMBER ,
         AVG_PRESS NUMBER ,
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
         TEXT_4 VARCHAR2 (2000) ,
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
         END_DAY  DATE ,
         UTC_DAYTIME  DATE ,
         UTC_END_DATE  DATE  );
   FUNCTION ROW_BY_REL_OPERATOR(
      P_OBJECT_ID IN VARCHAR2,
      P_CLASS_NAME IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN REC_ROW_BY_REL_OPERATOR;
   FUNCTION VALUE_2(
      P_OBJECT_ID IN VARCHAR2,
      P_CLASS_NAME IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER;
   FUNCTION VALUE_3(
      P_OBJECT_ID IN VARCHAR2,
      P_CLASS_NAME IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER;
   FUNCTION VALUE_4(
      P_OBJECT_ID IN VARCHAR2,
      P_CLASS_NAME IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER;
   FUNCTION MANUAL_ADJUSTMENT(
      P_OBJECT_ID IN VARCHAR2,
      P_CLASS_NAME IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER;
   FUNCTION REC_ID(
      P_OBJECT_ID IN VARCHAR2,
      P_CLASS_NAME IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2;
   FUNCTION TEXT_1(
      P_OBJECT_ID IN VARCHAR2,
      P_CLASS_NAME IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2;
   FUNCTION TEXT_2(
      P_OBJECT_ID IN VARCHAR2,
      P_CLASS_NAME IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2;
   FUNCTION VALUE_7(
      P_OBJECT_ID IN VARCHAR2,
      P_CLASS_NAME IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER;
   FUNCTION VALUE_9(
      P_OBJECT_ID IN VARCHAR2,
      P_CLASS_NAME IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER;
   FUNCTION END_DAY(
      P_OBJECT_ID IN VARCHAR2,
      P_CLASS_NAME IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN DATE;
   FUNCTION MATH_AVG_TEMP(
      P_OBJECT_ID IN VARCHAR2,
      P_CLASS_NAME IN VARCHAR2,
      P_FROM_DAY IN DATE,
      P_TO_DAY IN DATE,
      P_METHOD IN VARCHAR2 DEFAULT 'SUM')
      RETURN NUMBER;
   FUNCTION MATH_CLOSING_READING(
      P_OBJECT_ID IN VARCHAR2,
      P_CLASS_NAME IN VARCHAR2,
      P_FROM_DAY IN DATE,
      P_TO_DAY IN DATE,
      P_METHOD IN VARCHAR2 DEFAULT 'SUM')
      RETURN NUMBER;
   FUNCTION MATH_MANUAL_ADJUSTMENT(
      P_OBJECT_ID IN VARCHAR2,
      P_CLASS_NAME IN VARCHAR2,
      P_FROM_DAY IN DATE,
      P_TO_DAY IN DATE,
      P_METHOD IN VARCHAR2 DEFAULT 'SUM')
      RETURN NUMBER;
   FUNCTION MATH_VALUE_10(
      P_OBJECT_ID IN VARCHAR2,
      P_CLASS_NAME IN VARCHAR2,
      P_FROM_DAY IN DATE,
      P_TO_DAY IN DATE,
      P_METHOD IN VARCHAR2 DEFAULT 'SUM')
      RETURN NUMBER;
   FUNCTION PRODUCTION_DAY(
      P_OBJECT_ID IN VARCHAR2,
      P_CLASS_NAME IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN DATE;
   FUNCTION VALUE_10(
      P_OBJECT_ID IN VARCHAR2,
      P_CLASS_NAME IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER;
   FUNCTION VALUE_8(
      P_OBJECT_ID IN VARCHAR2,
      P_CLASS_NAME IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER;

END RP_WELL_PERIOD_TOTALIZER;

/



CREATE or REPLACE PACKAGE BODY RP_WELL_PERIOD_TOTALIZER
IS

   FUNCTION AVG_TEMP(
      P_OBJECT_ID IN VARCHAR2,
      P_CLASS_NAME IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_WELL_PERIOD_TOTALIZER.AVG_TEMP      (
         P_OBJECT_ID,
         P_CLASS_NAME,
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END AVG_TEMP;
   FUNCTION TEXT_3(
      P_OBJECT_ID IN VARCHAR2,
      P_CLASS_NAME IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_WELL_PERIOD_TOTALIZER.TEXT_3      (
         P_OBJECT_ID,
         P_CLASS_NAME,
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END TEXT_3;
   FUNCTION TEXT_4(
      P_OBJECT_ID IN VARCHAR2,
      P_CLASS_NAME IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_WELL_PERIOD_TOTALIZER.TEXT_4      (
         P_OBJECT_ID,
         P_CLASS_NAME,
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END TEXT_4;
   FUNCTION APPROVAL_BY(
      P_OBJECT_ID IN VARCHAR2,
      P_CLASS_NAME IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (30) ;
   BEGIN
      ret_value := EC_WELL_PERIOD_TOTALIZER.APPROVAL_BY      (
         P_OBJECT_ID,
         P_CLASS_NAME,
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END APPROVAL_BY;
   FUNCTION APPROVAL_STATE(
      P_OBJECT_ID IN VARCHAR2,
      P_CLASS_NAME IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_WELL_PERIOD_TOTALIZER.APPROVAL_STATE      (
         P_OBJECT_ID,
         P_CLASS_NAME,
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END APPROVAL_STATE;
   FUNCTION CLOSING_READING(
      P_OBJECT_ID IN VARCHAR2,
      P_CLASS_NAME IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_WELL_PERIOD_TOTALIZER.CLOSING_READING      (
         P_OBJECT_ID,
         P_CLASS_NAME,
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END CLOSING_READING;
   FUNCTION MATH_VALUE_3(
      P_OBJECT_ID IN VARCHAR2,
      P_CLASS_NAME IN VARCHAR2,
      P_FROM_DAY IN DATE,
      P_TO_DAY IN DATE,
      P_METHOD IN VARCHAR2 DEFAULT 'SUM')
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_WELL_PERIOD_TOTALIZER.MATH_VALUE_3      (
         P_OBJECT_ID,
         P_CLASS_NAME,
         P_FROM_DAY,
         P_TO_DAY,
         P_METHOD );
         RETURN ret_value;
   END MATH_VALUE_3;
   FUNCTION MATH_VALUE_4(
      P_OBJECT_ID IN VARCHAR2,
      P_CLASS_NAME IN VARCHAR2,
      P_FROM_DAY IN DATE,
      P_TO_DAY IN DATE,
      P_METHOD IN VARCHAR2 DEFAULT 'SUM')
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_WELL_PERIOD_TOTALIZER.MATH_VALUE_4      (
         P_OBJECT_ID,
         P_CLASS_NAME,
         P_FROM_DAY,
         P_TO_DAY,
         P_METHOD );
         RETURN ret_value;
   END MATH_VALUE_4;
   FUNCTION MATH_VALUE_8(
      P_OBJECT_ID IN VARCHAR2,
      P_CLASS_NAME IN VARCHAR2,
      P_FROM_DAY IN DATE,
      P_TO_DAY IN DATE,
      P_METHOD IN VARCHAR2 DEFAULT 'SUM')
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_WELL_PERIOD_TOTALIZER.MATH_VALUE_8      (
         P_OBJECT_ID,
         P_CLASS_NAME,
         P_FROM_DAY,
         P_TO_DAY,
         P_METHOD );
         RETURN ret_value;
   END MATH_VALUE_8;
   FUNCTION UTC_END_DATE(
      P_OBJECT_ID IN VARCHAR2,
      P_CLASS_NAME IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_WELL_PERIOD_TOTALIZER.UTC_END_DATE      (
         P_OBJECT_ID,
         P_CLASS_NAME,
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END UTC_END_DATE;
   FUNCTION VALUE_5(
      P_OBJECT_ID IN VARCHAR2,
      P_CLASS_NAME IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_WELL_PERIOD_TOTALIZER.VALUE_5      (
         P_OBJECT_ID,
         P_CLASS_NAME,
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END VALUE_5;
   FUNCTION MATH_VALUE_6(
      P_OBJECT_ID IN VARCHAR2,
      P_CLASS_NAME IN VARCHAR2,
      P_FROM_DAY IN DATE,
      P_TO_DAY IN DATE,
      P_METHOD IN VARCHAR2 DEFAULT 'SUM')
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_WELL_PERIOD_TOTALIZER.MATH_VALUE_6      (
         P_OBJECT_ID,
         P_CLASS_NAME,
         P_FROM_DAY,
         P_TO_DAY,
         P_METHOD );
         RETURN ret_value;
   END MATH_VALUE_6;
   FUNCTION NEXT_DAYTIME(
      P_OBJECT_ID IN VARCHAR2,
      P_CLASS_NAME IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_WELL_PERIOD_TOTALIZER.NEXT_DAYTIME      (
         P_OBJECT_ID,
         P_CLASS_NAME,
         P_DAYTIME,
         P_NUM_ROWS );
         RETURN ret_value;
   END NEXT_DAYTIME;
   FUNCTION PREV_EQUAL_DAYTIME(
      P_OBJECT_ID IN VARCHAR2,
      P_CLASS_NAME IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_WELL_PERIOD_TOTALIZER.PREV_EQUAL_DAYTIME      (
         P_OBJECT_ID,
         P_CLASS_NAME,
         P_DAYTIME,
         P_NUM_ROWS );
         RETURN ret_value;
   END PREV_EQUAL_DAYTIME;
   FUNCTION COMMENTS(
      P_OBJECT_ID IN VARCHAR2,
      P_CLASS_NAME IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_WELL_PERIOD_TOTALIZER.COMMENTS      (
         P_OBJECT_ID,
         P_CLASS_NAME,
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END COMMENTS;
   FUNCTION COUNT_ROWS(
      P_OBJECT_ID IN VARCHAR2,
      P_CLASS_NAME IN VARCHAR2,
      P_FROM_DAY IN DATE,
      P_TO_DAY IN DATE)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_WELL_PERIOD_TOTALIZER.COUNT_ROWS      (
         P_OBJECT_ID,
         P_CLASS_NAME,
         P_FROM_DAY,
         P_TO_DAY );
         RETURN ret_value;
   END COUNT_ROWS;
   FUNCTION MATH_VALUE_1(
      P_OBJECT_ID IN VARCHAR2,
      P_CLASS_NAME IN VARCHAR2,
      P_FROM_DAY IN DATE,
      P_TO_DAY IN DATE,
      P_METHOD IN VARCHAR2 DEFAULT 'SUM')
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_WELL_PERIOD_TOTALIZER.MATH_VALUE_1      (
         P_OBJECT_ID,
         P_CLASS_NAME,
         P_FROM_DAY,
         P_TO_DAY,
         P_METHOD );
         RETURN ret_value;
   END MATH_VALUE_1;
   FUNCTION MATH_VALUE_5(
      P_OBJECT_ID IN VARCHAR2,
      P_CLASS_NAME IN VARCHAR2,
      P_FROM_DAY IN DATE,
      P_TO_DAY IN DATE,
      P_METHOD IN VARCHAR2 DEFAULT 'SUM')
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_WELL_PERIOD_TOTALIZER.MATH_VALUE_5      (
         P_OBJECT_ID,
         P_CLASS_NAME,
         P_FROM_DAY,
         P_TO_DAY,
         P_METHOD );
         RETURN ret_value;
   END MATH_VALUE_5;
   FUNCTION MATH_VALUE_7(
      P_OBJECT_ID IN VARCHAR2,
      P_CLASS_NAME IN VARCHAR2,
      P_FROM_DAY IN DATE,
      P_TO_DAY IN DATE,
      P_METHOD IN VARCHAR2 DEFAULT 'SUM')
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_WELL_PERIOD_TOTALIZER.MATH_VALUE_7      (
         P_OBJECT_ID,
         P_CLASS_NAME,
         P_FROM_DAY,
         P_TO_DAY,
         P_METHOD );
         RETURN ret_value;
   END MATH_VALUE_7;
   FUNCTION MATH_VALUE_9(
      P_OBJECT_ID IN VARCHAR2,
      P_CLASS_NAME IN VARCHAR2,
      P_FROM_DAY IN DATE,
      P_TO_DAY IN DATE,
      P_METHOD IN VARCHAR2 DEFAULT 'SUM')
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_WELL_PERIOD_TOTALIZER.MATH_VALUE_9      (
         P_OBJECT_ID,
         P_CLASS_NAME,
         P_FROM_DAY,
         P_TO_DAY,
         P_METHOD );
         RETURN ret_value;
   END MATH_VALUE_9;
   FUNCTION NEXT_EQUAL_DAYTIME(
      P_OBJECT_ID IN VARCHAR2,
      P_CLASS_NAME IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_WELL_PERIOD_TOTALIZER.NEXT_EQUAL_DAYTIME      (
         P_OBJECT_ID,
         P_CLASS_NAME,
         P_DAYTIME,
         P_NUM_ROWS );
         RETURN ret_value;
   END NEXT_EQUAL_DAYTIME;
   FUNCTION OPENING_READING(
      P_OBJECT_ID IN VARCHAR2,
      P_CLASS_NAME IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_WELL_PERIOD_TOTALIZER.OPENING_READING      (
         P_OBJECT_ID,
         P_CLASS_NAME,
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END OPENING_READING;
   FUNCTION UTC_DAYTIME(
      P_OBJECT_ID IN VARCHAR2,
      P_CLASS_NAME IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_WELL_PERIOD_TOTALIZER.UTC_DAYTIME      (
         P_OBJECT_ID,
         P_CLASS_NAME,
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END UTC_DAYTIME;
   FUNCTION VALUE_6(
      P_OBJECT_ID IN VARCHAR2,
      P_CLASS_NAME IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_WELL_PERIOD_TOTALIZER.VALUE_6      (
         P_OBJECT_ID,
         P_CLASS_NAME,
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END VALUE_6;
   FUNCTION END_DATE(
      P_OBJECT_ID IN VARCHAR2,
      P_CLASS_NAME IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_WELL_PERIOD_TOTALIZER.END_DATE      (
         P_OBJECT_ID,
         P_CLASS_NAME,
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END END_DATE;
   FUNCTION MATH_AVG_PRESS(
      P_OBJECT_ID IN VARCHAR2,
      P_CLASS_NAME IN VARCHAR2,
      P_FROM_DAY IN DATE,
      P_TO_DAY IN DATE,
      P_METHOD IN VARCHAR2 DEFAULT 'SUM')
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_WELL_PERIOD_TOTALIZER.MATH_AVG_PRESS      (
         P_OBJECT_ID,
         P_CLASS_NAME,
         P_FROM_DAY,
         P_TO_DAY,
         P_METHOD );
         RETURN ret_value;
   END MATH_AVG_PRESS;
   FUNCTION PREV_DAYTIME(
      P_OBJECT_ID IN VARCHAR2,
      P_CLASS_NAME IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_WELL_PERIOD_TOTALIZER.PREV_DAYTIME      (
         P_OBJECT_ID,
         P_CLASS_NAME,
         P_DAYTIME,
         P_NUM_ROWS );
         RETURN ret_value;
   END PREV_DAYTIME;
   FUNCTION RECORD_STATUS(
      P_OBJECT_ID IN VARCHAR2,
      P_CLASS_NAME IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_WELL_PERIOD_TOTALIZER.RECORD_STATUS      (
         P_OBJECT_ID,
         P_CLASS_NAME,
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END RECORD_STATUS;
   FUNCTION VALUE_1(
      P_OBJECT_ID IN VARCHAR2,
      P_CLASS_NAME IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_WELL_PERIOD_TOTALIZER.VALUE_1      (
         P_OBJECT_ID,
         P_CLASS_NAME,
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END VALUE_1;
   FUNCTION APPROVAL_DATE(
      P_OBJECT_ID IN VARCHAR2,
      P_CLASS_NAME IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_WELL_PERIOD_TOTALIZER.APPROVAL_DATE      (
         P_OBJECT_ID,
         P_CLASS_NAME,
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END APPROVAL_DATE;
   FUNCTION AVG_PRESS(
      P_OBJECT_ID IN VARCHAR2,
      P_CLASS_NAME IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_WELL_PERIOD_TOTALIZER.AVG_PRESS      (
         P_OBJECT_ID,
         P_CLASS_NAME,
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END AVG_PRESS;
   FUNCTION MATH_OPENING_READING(
      P_OBJECT_ID IN VARCHAR2,
      P_CLASS_NAME IN VARCHAR2,
      P_FROM_DAY IN DATE,
      P_TO_DAY IN DATE,
      P_METHOD IN VARCHAR2 DEFAULT 'SUM')
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_WELL_PERIOD_TOTALIZER.MATH_OPENING_READING      (
         P_OBJECT_ID,
         P_CLASS_NAME,
         P_FROM_DAY,
         P_TO_DAY,
         P_METHOD );
         RETURN ret_value;
   END MATH_OPENING_READING;
   FUNCTION MATH_VALUE_2(
      P_OBJECT_ID IN VARCHAR2,
      P_CLASS_NAME IN VARCHAR2,
      P_FROM_DAY IN DATE,
      P_TO_DAY IN DATE,
      P_METHOD IN VARCHAR2 DEFAULT 'SUM')
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_WELL_PERIOD_TOTALIZER.MATH_VALUE_2      (
         P_OBJECT_ID,
         P_CLASS_NAME,
         P_FROM_DAY,
         P_TO_DAY,
         P_METHOD );
         RETURN ret_value;
   END MATH_VALUE_2;
   FUNCTION ROW_BY_PK(
      P_OBJECT_ID IN VARCHAR2,
      P_CLASS_NAME IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN REC_ROW_BY_PK
   IS
      ret_value    REC_ROW_BY_PK ;
   BEGIN
      ret_value := EC_WELL_PERIOD_TOTALIZER.ROW_BY_PK      (
         P_OBJECT_ID,
         P_CLASS_NAME,
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END ROW_BY_PK;
   FUNCTION ROW_BY_REL_OPERATOR(
      P_OBJECT_ID IN VARCHAR2,
      P_CLASS_NAME IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN REC_ROW_BY_REL_OPERATOR
   IS
      ret_value    REC_ROW_BY_REL_OPERATOR ;
   BEGIN
      ret_value := EC_WELL_PERIOD_TOTALIZER.ROW_BY_REL_OPERATOR      (
         P_OBJECT_ID,
         P_CLASS_NAME,
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END ROW_BY_REL_OPERATOR;
   FUNCTION VALUE_2(
      P_OBJECT_ID IN VARCHAR2,
      P_CLASS_NAME IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_WELL_PERIOD_TOTALIZER.VALUE_2      (
         P_OBJECT_ID,
         P_CLASS_NAME,
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END VALUE_2;
   FUNCTION VALUE_3(
      P_OBJECT_ID IN VARCHAR2,
      P_CLASS_NAME IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_WELL_PERIOD_TOTALIZER.VALUE_3      (
         P_OBJECT_ID,
         P_CLASS_NAME,
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END VALUE_3;
   FUNCTION VALUE_4(
      P_OBJECT_ID IN VARCHAR2,
      P_CLASS_NAME IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_WELL_PERIOD_TOTALIZER.VALUE_4      (
         P_OBJECT_ID,
         P_CLASS_NAME,
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END VALUE_4;
   FUNCTION MANUAL_ADJUSTMENT(
      P_OBJECT_ID IN VARCHAR2,
      P_CLASS_NAME IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_WELL_PERIOD_TOTALIZER.MANUAL_ADJUSTMENT      (
         P_OBJECT_ID,
         P_CLASS_NAME,
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END MANUAL_ADJUSTMENT;
   FUNCTION REC_ID(
      P_OBJECT_ID IN VARCHAR2,
      P_CLASS_NAME IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_WELL_PERIOD_TOTALIZER.REC_ID      (
         P_OBJECT_ID,
         P_CLASS_NAME,
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END REC_ID;
   FUNCTION TEXT_1(
      P_OBJECT_ID IN VARCHAR2,
      P_CLASS_NAME IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (16) ;
   BEGIN
      ret_value := EC_WELL_PERIOD_TOTALIZER.TEXT_1      (
         P_OBJECT_ID,
         P_CLASS_NAME,
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END TEXT_1;
   FUNCTION TEXT_2(
      P_OBJECT_ID IN VARCHAR2,
      P_CLASS_NAME IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_WELL_PERIOD_TOTALIZER.TEXT_2      (
         P_OBJECT_ID,
         P_CLASS_NAME,
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END TEXT_2;
   FUNCTION VALUE_7(
      P_OBJECT_ID IN VARCHAR2,
      P_CLASS_NAME IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_WELL_PERIOD_TOTALIZER.VALUE_7      (
         P_OBJECT_ID,
         P_CLASS_NAME,
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END VALUE_7;
   FUNCTION VALUE_9(
      P_OBJECT_ID IN VARCHAR2,
      P_CLASS_NAME IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_WELL_PERIOD_TOTALIZER.VALUE_9      (
         P_OBJECT_ID,
         P_CLASS_NAME,
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END VALUE_9;
   FUNCTION END_DAY(
      P_OBJECT_ID IN VARCHAR2,
      P_CLASS_NAME IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_WELL_PERIOD_TOTALIZER.END_DAY      (
         P_OBJECT_ID,
         P_CLASS_NAME,
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END END_DAY;
   FUNCTION MATH_AVG_TEMP(
      P_OBJECT_ID IN VARCHAR2,
      P_CLASS_NAME IN VARCHAR2,
      P_FROM_DAY IN DATE,
      P_TO_DAY IN DATE,
      P_METHOD IN VARCHAR2 DEFAULT 'SUM')
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_WELL_PERIOD_TOTALIZER.MATH_AVG_TEMP      (
         P_OBJECT_ID,
         P_CLASS_NAME,
         P_FROM_DAY,
         P_TO_DAY,
         P_METHOD );
         RETURN ret_value;
   END MATH_AVG_TEMP;
   FUNCTION MATH_CLOSING_READING(
      P_OBJECT_ID IN VARCHAR2,
      P_CLASS_NAME IN VARCHAR2,
      P_FROM_DAY IN DATE,
      P_TO_DAY IN DATE,
      P_METHOD IN VARCHAR2 DEFAULT 'SUM')
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_WELL_PERIOD_TOTALIZER.MATH_CLOSING_READING      (
         P_OBJECT_ID,
         P_CLASS_NAME,
         P_FROM_DAY,
         P_TO_DAY,
         P_METHOD );
         RETURN ret_value;
   END MATH_CLOSING_READING;
   FUNCTION MATH_MANUAL_ADJUSTMENT(
      P_OBJECT_ID IN VARCHAR2,
      P_CLASS_NAME IN VARCHAR2,
      P_FROM_DAY IN DATE,
      P_TO_DAY IN DATE,
      P_METHOD IN VARCHAR2 DEFAULT 'SUM')
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_WELL_PERIOD_TOTALIZER.MATH_MANUAL_ADJUSTMENT      (
         P_OBJECT_ID,
         P_CLASS_NAME,
         P_FROM_DAY,
         P_TO_DAY,
         P_METHOD );
         RETURN ret_value;
   END MATH_MANUAL_ADJUSTMENT;
   FUNCTION MATH_VALUE_10(
      P_OBJECT_ID IN VARCHAR2,
      P_CLASS_NAME IN VARCHAR2,
      P_FROM_DAY IN DATE,
      P_TO_DAY IN DATE,
      P_METHOD IN VARCHAR2 DEFAULT 'SUM')
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_WELL_PERIOD_TOTALIZER.MATH_VALUE_10      (
         P_OBJECT_ID,
         P_CLASS_NAME,
         P_FROM_DAY,
         P_TO_DAY,
         P_METHOD );
         RETURN ret_value;
   END MATH_VALUE_10;
   FUNCTION PRODUCTION_DAY(
      P_OBJECT_ID IN VARCHAR2,
      P_CLASS_NAME IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_WELL_PERIOD_TOTALIZER.PRODUCTION_DAY      (
         P_OBJECT_ID,
         P_CLASS_NAME,
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END PRODUCTION_DAY;
   FUNCTION VALUE_10(
      P_OBJECT_ID IN VARCHAR2,
      P_CLASS_NAME IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_WELL_PERIOD_TOTALIZER.VALUE_10      (
         P_OBJECT_ID,
         P_CLASS_NAME,
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END VALUE_10;
   FUNCTION VALUE_8(
      P_OBJECT_ID IN VARCHAR2,
      P_CLASS_NAME IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_WELL_PERIOD_TOTALIZER.VALUE_8      (
         P_OBJECT_ID,
         P_CLASS_NAME,
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END VALUE_8;

END RP_WELL_PERIOD_TOTALIZER;

/
--GRANT EXECUTE ON ECKERNEL_WST.RP_WELL_PERIOD_TOTALIZER TO REPORT_ROLE_XXX;



 -- FINISH PKG_GEN_PKGS.sf_get_functions at:05/07/2019 05.14.25 AM

