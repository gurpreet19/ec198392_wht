
 -- START PKG_GEN_PKGS.sf_get_functions at:05/07/2019 10.13.33 AM


CREATE or REPLACE PACKAGE RP_FCST_CNTR_MTH_EXPEND
IS

   FUNCTION TEXT_3(
      P_OBJECT_ID IN VARCHAR2,
      P_FORECAST_ID IN VARCHAR2,
      P_CATEGORY_CODE IN VARCHAR2,
      P_EXP_CODE IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2;
   FUNCTION TEXT_4(
      P_OBJECT_ID IN VARCHAR2,
      P_FORECAST_ID IN VARCHAR2,
      P_CATEGORY_CODE IN VARCHAR2,
      P_EXP_CODE IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2;
   FUNCTION APPROVAL_BY(
      P_OBJECT_ID IN VARCHAR2,
      P_FORECAST_ID IN VARCHAR2,
      P_CATEGORY_CODE IN VARCHAR2,
      P_EXP_CODE IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2;
   FUNCTION APPROVAL_STATE(
      P_OBJECT_ID IN VARCHAR2,
      P_FORECAST_ID IN VARCHAR2,
      P_CATEGORY_CODE IN VARCHAR2,
      P_EXP_CODE IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2;
   FUNCTION EXP_VALUE(
      P_OBJECT_ID IN VARCHAR2,
      P_FORECAST_ID IN VARCHAR2,
      P_CATEGORY_CODE IN VARCHAR2,
      P_EXP_CODE IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER;
   FUNCTION MATH_EXP_VALUE(
      P_OBJECT_ID IN VARCHAR2,
      P_FORECAST_ID IN VARCHAR2,
      P_CATEGORY_CODE IN VARCHAR2,
      P_EXP_CODE IN VARCHAR2,
      P_FROM_DAY IN DATE,
      P_TO_DAY IN DATE,
      P_METHOD IN VARCHAR2 DEFAULT 'SUM')
      RETURN NUMBER;
   FUNCTION MATH_VALUE_3(
      P_OBJECT_ID IN VARCHAR2,
      P_FORECAST_ID IN VARCHAR2,
      P_CATEGORY_CODE IN VARCHAR2,
      P_EXP_CODE IN VARCHAR2,
      P_FROM_DAY IN DATE,
      P_TO_DAY IN DATE,
      P_METHOD IN VARCHAR2 DEFAULT 'SUM')
      RETURN NUMBER;
   FUNCTION MATH_VALUE_4(
      P_OBJECT_ID IN VARCHAR2,
      P_FORECAST_ID IN VARCHAR2,
      P_CATEGORY_CODE IN VARCHAR2,
      P_EXP_CODE IN VARCHAR2,
      P_FROM_DAY IN DATE,
      P_TO_DAY IN DATE,
      P_METHOD IN VARCHAR2 DEFAULT 'SUM')
      RETURN NUMBER;
   FUNCTION MATH_VALUE_8(
      P_OBJECT_ID IN VARCHAR2,
      P_FORECAST_ID IN VARCHAR2,
      P_CATEGORY_CODE IN VARCHAR2,
      P_EXP_CODE IN VARCHAR2,
      P_FROM_DAY IN DATE,
      P_TO_DAY IN DATE,
      P_METHOD IN VARCHAR2 DEFAULT 'SUM')
      RETURN NUMBER;
   FUNCTION VALUE_5(
      P_OBJECT_ID IN VARCHAR2,
      P_FORECAST_ID IN VARCHAR2,
      P_CATEGORY_CODE IN VARCHAR2,
      P_EXP_CODE IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER;
   FUNCTION MATH_VALUE_6(
      P_OBJECT_ID IN VARCHAR2,
      P_FORECAST_ID IN VARCHAR2,
      P_CATEGORY_CODE IN VARCHAR2,
      P_EXP_CODE IN VARCHAR2,
      P_FROM_DAY IN DATE,
      P_TO_DAY IN DATE,
      P_METHOD IN VARCHAR2 DEFAULT 'SUM')
      RETURN NUMBER;
   FUNCTION NEXT_DAYTIME(
      P_OBJECT_ID IN VARCHAR2,
      P_FORECAST_ID IN VARCHAR2,
      P_CATEGORY_CODE IN VARCHAR2,
      P_EXP_CODE IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION PREV_EQUAL_DAYTIME(
      P_OBJECT_ID IN VARCHAR2,
      P_FORECAST_ID IN VARCHAR2,
      P_CATEGORY_CODE IN VARCHAR2,
      P_EXP_CODE IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION COUNT_ROWS(
      P_OBJECT_ID IN VARCHAR2,
      P_FORECAST_ID IN VARCHAR2,
      P_CATEGORY_CODE IN VARCHAR2,
      P_EXP_CODE IN VARCHAR2,
      P_FROM_DAY IN DATE,
      P_TO_DAY IN DATE)
      RETURN NUMBER;
   FUNCTION MATH_VALUE_1(
      P_OBJECT_ID IN VARCHAR2,
      P_FORECAST_ID IN VARCHAR2,
      P_CATEGORY_CODE IN VARCHAR2,
      P_EXP_CODE IN VARCHAR2,
      P_FROM_DAY IN DATE,
      P_TO_DAY IN DATE,
      P_METHOD IN VARCHAR2 DEFAULT 'SUM')
      RETURN NUMBER;
   FUNCTION MATH_VALUE_5(
      P_OBJECT_ID IN VARCHAR2,
      P_FORECAST_ID IN VARCHAR2,
      P_CATEGORY_CODE IN VARCHAR2,
      P_EXP_CODE IN VARCHAR2,
      P_FROM_DAY IN DATE,
      P_TO_DAY IN DATE,
      P_METHOD IN VARCHAR2 DEFAULT 'SUM')
      RETURN NUMBER;
   FUNCTION MATH_VALUE_7(
      P_OBJECT_ID IN VARCHAR2,
      P_FORECAST_ID IN VARCHAR2,
      P_CATEGORY_CODE IN VARCHAR2,
      P_EXP_CODE IN VARCHAR2,
      P_FROM_DAY IN DATE,
      P_TO_DAY IN DATE,
      P_METHOD IN VARCHAR2 DEFAULT 'SUM')
      RETURN NUMBER;
   FUNCTION MATH_VALUE_9(
      P_OBJECT_ID IN VARCHAR2,
      P_FORECAST_ID IN VARCHAR2,
      P_CATEGORY_CODE IN VARCHAR2,
      P_EXP_CODE IN VARCHAR2,
      P_FROM_DAY IN DATE,
      P_TO_DAY IN DATE,
      P_METHOD IN VARCHAR2 DEFAULT 'SUM')
      RETURN NUMBER;
   FUNCTION NEXT_EQUAL_DAYTIME(
      P_OBJECT_ID IN VARCHAR2,
      P_FORECAST_ID IN VARCHAR2,
      P_CATEGORY_CODE IN VARCHAR2,
      P_EXP_CODE IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION VALUE_6(
      P_OBJECT_ID IN VARCHAR2,
      P_FORECAST_ID IN VARCHAR2,
      P_CATEGORY_CODE IN VARCHAR2,
      P_EXP_CODE IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER;
   FUNCTION COMPANY_ID(
      P_OBJECT_ID IN VARCHAR2,
      P_FORECAST_ID IN VARCHAR2,
      P_CATEGORY_CODE IN VARCHAR2,
      P_EXP_CODE IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2;
   FUNCTION DATE_2(
      P_OBJECT_ID IN VARCHAR2,
      P_FORECAST_ID IN VARCHAR2,
      P_CATEGORY_CODE IN VARCHAR2,
      P_EXP_CODE IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN DATE;
   FUNCTION PREV_DAYTIME(
      P_OBJECT_ID IN VARCHAR2,
      P_FORECAST_ID IN VARCHAR2,
      P_CATEGORY_CODE IN VARCHAR2,
      P_EXP_CODE IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION RECORD_STATUS(
      P_OBJECT_ID IN VARCHAR2,
      P_FORECAST_ID IN VARCHAR2,
      P_CATEGORY_CODE IN VARCHAR2,
      P_EXP_CODE IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2;
   FUNCTION VALUE_1(
      P_OBJECT_ID IN VARCHAR2,
      P_FORECAST_ID IN VARCHAR2,
      P_CATEGORY_CODE IN VARCHAR2,
      P_EXP_CODE IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER;
   FUNCTION APPROVAL_DATE(
      P_OBJECT_ID IN VARCHAR2,
      P_FORECAST_ID IN VARCHAR2,
      P_CATEGORY_CODE IN VARCHAR2,
      P_EXP_CODE IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN DATE;
   FUNCTION MATH_VALUE_2(
      P_OBJECT_ID IN VARCHAR2,
      P_FORECAST_ID IN VARCHAR2,
      P_CATEGORY_CODE IN VARCHAR2,
      P_EXP_CODE IN VARCHAR2,
      P_FROM_DAY IN DATE,
      P_TO_DAY IN DATE,
      P_METHOD IN VARCHAR2 DEFAULT 'SUM')
      RETURN NUMBER;
      TYPE REC_ROW_BY_PK IS RECORD (
         FORECAST_ID VARCHAR2 (32) ,
         OBJECT_ID VARCHAR2 (32) ,
         CATEGORY_CODE VARCHAR2 (32) ,
         EXP_CODE VARCHAR2 (32) ,
         DAYTIME  DATE ,
         COMPANY_ID VARCHAR2 (32) ,
         EXP_VALUE NUMBER ,
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
         DATE_1  DATE ,
         DATE_2  DATE ,
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
      P_FORECAST_ID IN VARCHAR2,
      P_CATEGORY_CODE IN VARCHAR2,
      P_EXP_CODE IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN REC_ROW_BY_PK;
      TYPE REC_ROW_BY_REL_OPERATOR IS RECORD (
         FORECAST_ID VARCHAR2 (32) ,
         OBJECT_ID VARCHAR2 (32) ,
         CATEGORY_CODE VARCHAR2 (32) ,
         EXP_CODE VARCHAR2 (32) ,
         DAYTIME  DATE ,
         COMPANY_ID VARCHAR2 (32) ,
         EXP_VALUE NUMBER ,
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
         DATE_1  DATE ,
         DATE_2  DATE ,
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
      P_FORECAST_ID IN VARCHAR2,
      P_CATEGORY_CODE IN VARCHAR2,
      P_EXP_CODE IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN REC_ROW_BY_REL_OPERATOR;
   FUNCTION VALUE_2(
      P_OBJECT_ID IN VARCHAR2,
      P_FORECAST_ID IN VARCHAR2,
      P_CATEGORY_CODE IN VARCHAR2,
      P_EXP_CODE IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER;
   FUNCTION VALUE_3(
      P_OBJECT_ID IN VARCHAR2,
      P_FORECAST_ID IN VARCHAR2,
      P_CATEGORY_CODE IN VARCHAR2,
      P_EXP_CODE IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER;
   FUNCTION VALUE_4(
      P_OBJECT_ID IN VARCHAR2,
      P_FORECAST_ID IN VARCHAR2,
      P_CATEGORY_CODE IN VARCHAR2,
      P_EXP_CODE IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER;
   FUNCTION REC_ID(
      P_OBJECT_ID IN VARCHAR2,
      P_FORECAST_ID IN VARCHAR2,
      P_CATEGORY_CODE IN VARCHAR2,
      P_EXP_CODE IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2;
   FUNCTION TEXT_1(
      P_OBJECT_ID IN VARCHAR2,
      P_FORECAST_ID IN VARCHAR2,
      P_CATEGORY_CODE IN VARCHAR2,
      P_EXP_CODE IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2;
   FUNCTION TEXT_2(
      P_OBJECT_ID IN VARCHAR2,
      P_FORECAST_ID IN VARCHAR2,
      P_CATEGORY_CODE IN VARCHAR2,
      P_EXP_CODE IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2;
   FUNCTION VALUE_7(
      P_OBJECT_ID IN VARCHAR2,
      P_FORECAST_ID IN VARCHAR2,
      P_CATEGORY_CODE IN VARCHAR2,
      P_EXP_CODE IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER;
   FUNCTION VALUE_9(
      P_OBJECT_ID IN VARCHAR2,
      P_FORECAST_ID IN VARCHAR2,
      P_CATEGORY_CODE IN VARCHAR2,
      P_EXP_CODE IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER;
   FUNCTION DATE_1(
      P_OBJECT_ID IN VARCHAR2,
      P_FORECAST_ID IN VARCHAR2,
      P_CATEGORY_CODE IN VARCHAR2,
      P_EXP_CODE IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN DATE;
   FUNCTION MATH_VALUE_10(
      P_OBJECT_ID IN VARCHAR2,
      P_FORECAST_ID IN VARCHAR2,
      P_CATEGORY_CODE IN VARCHAR2,
      P_EXP_CODE IN VARCHAR2,
      P_FROM_DAY IN DATE,
      P_TO_DAY IN DATE,
      P_METHOD IN VARCHAR2 DEFAULT 'SUM')
      RETURN NUMBER;
   FUNCTION VALUE_10(
      P_OBJECT_ID IN VARCHAR2,
      P_FORECAST_ID IN VARCHAR2,
      P_CATEGORY_CODE IN VARCHAR2,
      P_EXP_CODE IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER;
   FUNCTION VALUE_8(
      P_OBJECT_ID IN VARCHAR2,
      P_FORECAST_ID IN VARCHAR2,
      P_CATEGORY_CODE IN VARCHAR2,
      P_EXP_CODE IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER;

END RP_FCST_CNTR_MTH_EXPEND;

/



CREATE or REPLACE PACKAGE BODY RP_FCST_CNTR_MTH_EXPEND
IS

   FUNCTION TEXT_3(
      P_OBJECT_ID IN VARCHAR2,
      P_FORECAST_ID IN VARCHAR2,
      P_CATEGORY_CODE IN VARCHAR2,
      P_EXP_CODE IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_FCST_CNTR_MTH_EXPEND.TEXT_3      (
         P_OBJECT_ID,
         P_FORECAST_ID,
         P_CATEGORY_CODE,
         P_EXP_CODE,
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END TEXT_3;
   FUNCTION TEXT_4(
      P_OBJECT_ID IN VARCHAR2,
      P_FORECAST_ID IN VARCHAR2,
      P_CATEGORY_CODE IN VARCHAR2,
      P_EXP_CODE IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_FCST_CNTR_MTH_EXPEND.TEXT_4      (
         P_OBJECT_ID,
         P_FORECAST_ID,
         P_CATEGORY_CODE,
         P_EXP_CODE,
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END TEXT_4;
   FUNCTION APPROVAL_BY(
      P_OBJECT_ID IN VARCHAR2,
      P_FORECAST_ID IN VARCHAR2,
      P_CATEGORY_CODE IN VARCHAR2,
      P_EXP_CODE IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (30) ;
   BEGIN
      ret_value := EC_FCST_CNTR_MTH_EXPEND.APPROVAL_BY      (
         P_OBJECT_ID,
         P_FORECAST_ID,
         P_CATEGORY_CODE,
         P_EXP_CODE,
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END APPROVAL_BY;
   FUNCTION APPROVAL_STATE(
      P_OBJECT_ID IN VARCHAR2,
      P_FORECAST_ID IN VARCHAR2,
      P_CATEGORY_CODE IN VARCHAR2,
      P_EXP_CODE IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_FCST_CNTR_MTH_EXPEND.APPROVAL_STATE      (
         P_OBJECT_ID,
         P_FORECAST_ID,
         P_CATEGORY_CODE,
         P_EXP_CODE,
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END APPROVAL_STATE;
   FUNCTION EXP_VALUE(
      P_OBJECT_ID IN VARCHAR2,
      P_FORECAST_ID IN VARCHAR2,
      P_CATEGORY_CODE IN VARCHAR2,
      P_EXP_CODE IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FCST_CNTR_MTH_EXPEND.EXP_VALUE      (
         P_OBJECT_ID,
         P_FORECAST_ID,
         P_CATEGORY_CODE,
         P_EXP_CODE,
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END EXP_VALUE;
   FUNCTION MATH_EXP_VALUE(
      P_OBJECT_ID IN VARCHAR2,
      P_FORECAST_ID IN VARCHAR2,
      P_CATEGORY_CODE IN VARCHAR2,
      P_EXP_CODE IN VARCHAR2,
      P_FROM_DAY IN DATE,
      P_TO_DAY IN DATE,
      P_METHOD IN VARCHAR2 DEFAULT 'SUM')
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FCST_CNTR_MTH_EXPEND.MATH_EXP_VALUE      (
         P_OBJECT_ID,
         P_FORECAST_ID,
         P_CATEGORY_CODE,
         P_EXP_CODE,
         P_FROM_DAY,
         P_TO_DAY,
         P_METHOD );
         RETURN ret_value;
   END MATH_EXP_VALUE;
   FUNCTION MATH_VALUE_3(
      P_OBJECT_ID IN VARCHAR2,
      P_FORECAST_ID IN VARCHAR2,
      P_CATEGORY_CODE IN VARCHAR2,
      P_EXP_CODE IN VARCHAR2,
      P_FROM_DAY IN DATE,
      P_TO_DAY IN DATE,
      P_METHOD IN VARCHAR2 DEFAULT 'SUM')
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FCST_CNTR_MTH_EXPEND.MATH_VALUE_3      (
         P_OBJECT_ID,
         P_FORECAST_ID,
         P_CATEGORY_CODE,
         P_EXP_CODE,
         P_FROM_DAY,
         P_TO_DAY,
         P_METHOD );
         RETURN ret_value;
   END MATH_VALUE_3;
   FUNCTION MATH_VALUE_4(
      P_OBJECT_ID IN VARCHAR2,
      P_FORECAST_ID IN VARCHAR2,
      P_CATEGORY_CODE IN VARCHAR2,
      P_EXP_CODE IN VARCHAR2,
      P_FROM_DAY IN DATE,
      P_TO_DAY IN DATE,
      P_METHOD IN VARCHAR2 DEFAULT 'SUM')
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FCST_CNTR_MTH_EXPEND.MATH_VALUE_4      (
         P_OBJECT_ID,
         P_FORECAST_ID,
         P_CATEGORY_CODE,
         P_EXP_CODE,
         P_FROM_DAY,
         P_TO_DAY,
         P_METHOD );
         RETURN ret_value;
   END MATH_VALUE_4;
   FUNCTION MATH_VALUE_8(
      P_OBJECT_ID IN VARCHAR2,
      P_FORECAST_ID IN VARCHAR2,
      P_CATEGORY_CODE IN VARCHAR2,
      P_EXP_CODE IN VARCHAR2,
      P_FROM_DAY IN DATE,
      P_TO_DAY IN DATE,
      P_METHOD IN VARCHAR2 DEFAULT 'SUM')
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FCST_CNTR_MTH_EXPEND.MATH_VALUE_8      (
         P_OBJECT_ID,
         P_FORECAST_ID,
         P_CATEGORY_CODE,
         P_EXP_CODE,
         P_FROM_DAY,
         P_TO_DAY,
         P_METHOD );
         RETURN ret_value;
   END MATH_VALUE_8;
   FUNCTION VALUE_5(
      P_OBJECT_ID IN VARCHAR2,
      P_FORECAST_ID IN VARCHAR2,
      P_CATEGORY_CODE IN VARCHAR2,
      P_EXP_CODE IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FCST_CNTR_MTH_EXPEND.VALUE_5      (
         P_OBJECT_ID,
         P_FORECAST_ID,
         P_CATEGORY_CODE,
         P_EXP_CODE,
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END VALUE_5;
   FUNCTION MATH_VALUE_6(
      P_OBJECT_ID IN VARCHAR2,
      P_FORECAST_ID IN VARCHAR2,
      P_CATEGORY_CODE IN VARCHAR2,
      P_EXP_CODE IN VARCHAR2,
      P_FROM_DAY IN DATE,
      P_TO_DAY IN DATE,
      P_METHOD IN VARCHAR2 DEFAULT 'SUM')
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FCST_CNTR_MTH_EXPEND.MATH_VALUE_6      (
         P_OBJECT_ID,
         P_FORECAST_ID,
         P_CATEGORY_CODE,
         P_EXP_CODE,
         P_FROM_DAY,
         P_TO_DAY,
         P_METHOD );
         RETURN ret_value;
   END MATH_VALUE_6;
   FUNCTION NEXT_DAYTIME(
      P_OBJECT_ID IN VARCHAR2,
      P_FORECAST_ID IN VARCHAR2,
      P_CATEGORY_CODE IN VARCHAR2,
      P_EXP_CODE IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_FCST_CNTR_MTH_EXPEND.NEXT_DAYTIME      (
         P_OBJECT_ID,
         P_FORECAST_ID,
         P_CATEGORY_CODE,
         P_EXP_CODE,
         P_DAYTIME,
         P_NUM_ROWS );
         RETURN ret_value;
   END NEXT_DAYTIME;
   FUNCTION PREV_EQUAL_DAYTIME(
      P_OBJECT_ID IN VARCHAR2,
      P_FORECAST_ID IN VARCHAR2,
      P_CATEGORY_CODE IN VARCHAR2,
      P_EXP_CODE IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_FCST_CNTR_MTH_EXPEND.PREV_EQUAL_DAYTIME      (
         P_OBJECT_ID,
         P_FORECAST_ID,
         P_CATEGORY_CODE,
         P_EXP_CODE,
         P_DAYTIME,
         P_NUM_ROWS );
         RETURN ret_value;
   END PREV_EQUAL_DAYTIME;
   FUNCTION COUNT_ROWS(
      P_OBJECT_ID IN VARCHAR2,
      P_FORECAST_ID IN VARCHAR2,
      P_CATEGORY_CODE IN VARCHAR2,
      P_EXP_CODE IN VARCHAR2,
      P_FROM_DAY IN DATE,
      P_TO_DAY IN DATE)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FCST_CNTR_MTH_EXPEND.COUNT_ROWS      (
         P_OBJECT_ID,
         P_FORECAST_ID,
         P_CATEGORY_CODE,
         P_EXP_CODE,
         P_FROM_DAY,
         P_TO_DAY );
         RETURN ret_value;
   END COUNT_ROWS;
   FUNCTION MATH_VALUE_1(
      P_OBJECT_ID IN VARCHAR2,
      P_FORECAST_ID IN VARCHAR2,
      P_CATEGORY_CODE IN VARCHAR2,
      P_EXP_CODE IN VARCHAR2,
      P_FROM_DAY IN DATE,
      P_TO_DAY IN DATE,
      P_METHOD IN VARCHAR2 DEFAULT 'SUM')
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FCST_CNTR_MTH_EXPEND.MATH_VALUE_1      (
         P_OBJECT_ID,
         P_FORECAST_ID,
         P_CATEGORY_CODE,
         P_EXP_CODE,
         P_FROM_DAY,
         P_TO_DAY,
         P_METHOD );
         RETURN ret_value;
   END MATH_VALUE_1;
   FUNCTION MATH_VALUE_5(
      P_OBJECT_ID IN VARCHAR2,
      P_FORECAST_ID IN VARCHAR2,
      P_CATEGORY_CODE IN VARCHAR2,
      P_EXP_CODE IN VARCHAR2,
      P_FROM_DAY IN DATE,
      P_TO_DAY IN DATE,
      P_METHOD IN VARCHAR2 DEFAULT 'SUM')
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FCST_CNTR_MTH_EXPEND.MATH_VALUE_5      (
         P_OBJECT_ID,
         P_FORECAST_ID,
         P_CATEGORY_CODE,
         P_EXP_CODE,
         P_FROM_DAY,
         P_TO_DAY,
         P_METHOD );
         RETURN ret_value;
   END MATH_VALUE_5;
   FUNCTION MATH_VALUE_7(
      P_OBJECT_ID IN VARCHAR2,
      P_FORECAST_ID IN VARCHAR2,
      P_CATEGORY_CODE IN VARCHAR2,
      P_EXP_CODE IN VARCHAR2,
      P_FROM_DAY IN DATE,
      P_TO_DAY IN DATE,
      P_METHOD IN VARCHAR2 DEFAULT 'SUM')
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FCST_CNTR_MTH_EXPEND.MATH_VALUE_7      (
         P_OBJECT_ID,
         P_FORECAST_ID,
         P_CATEGORY_CODE,
         P_EXP_CODE,
         P_FROM_DAY,
         P_TO_DAY,
         P_METHOD );
         RETURN ret_value;
   END MATH_VALUE_7;
   FUNCTION MATH_VALUE_9(
      P_OBJECT_ID IN VARCHAR2,
      P_FORECAST_ID IN VARCHAR2,
      P_CATEGORY_CODE IN VARCHAR2,
      P_EXP_CODE IN VARCHAR2,
      P_FROM_DAY IN DATE,
      P_TO_DAY IN DATE,
      P_METHOD IN VARCHAR2 DEFAULT 'SUM')
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FCST_CNTR_MTH_EXPEND.MATH_VALUE_9      (
         P_OBJECT_ID,
         P_FORECAST_ID,
         P_CATEGORY_CODE,
         P_EXP_CODE,
         P_FROM_DAY,
         P_TO_DAY,
         P_METHOD );
         RETURN ret_value;
   END MATH_VALUE_9;
   FUNCTION NEXT_EQUAL_DAYTIME(
      P_OBJECT_ID IN VARCHAR2,
      P_FORECAST_ID IN VARCHAR2,
      P_CATEGORY_CODE IN VARCHAR2,
      P_EXP_CODE IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_FCST_CNTR_MTH_EXPEND.NEXT_EQUAL_DAYTIME      (
         P_OBJECT_ID,
         P_FORECAST_ID,
         P_CATEGORY_CODE,
         P_EXP_CODE,
         P_DAYTIME,
         P_NUM_ROWS );
         RETURN ret_value;
   END NEXT_EQUAL_DAYTIME;
   FUNCTION VALUE_6(
      P_OBJECT_ID IN VARCHAR2,
      P_FORECAST_ID IN VARCHAR2,
      P_CATEGORY_CODE IN VARCHAR2,
      P_EXP_CODE IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FCST_CNTR_MTH_EXPEND.VALUE_6      (
         P_OBJECT_ID,
         P_FORECAST_ID,
         P_CATEGORY_CODE,
         P_EXP_CODE,
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END VALUE_6;
   FUNCTION COMPANY_ID(
      P_OBJECT_ID IN VARCHAR2,
      P_FORECAST_ID IN VARCHAR2,
      P_CATEGORY_CODE IN VARCHAR2,
      P_EXP_CODE IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_FCST_CNTR_MTH_EXPEND.COMPANY_ID      (
         P_OBJECT_ID,
         P_FORECAST_ID,
         P_CATEGORY_CODE,
         P_EXP_CODE,
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END COMPANY_ID;
   FUNCTION DATE_2(
      P_OBJECT_ID IN VARCHAR2,
      P_FORECAST_ID IN VARCHAR2,
      P_CATEGORY_CODE IN VARCHAR2,
      P_EXP_CODE IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_FCST_CNTR_MTH_EXPEND.DATE_2      (
         P_OBJECT_ID,
         P_FORECAST_ID,
         P_CATEGORY_CODE,
         P_EXP_CODE,
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END DATE_2;
   FUNCTION PREV_DAYTIME(
      P_OBJECT_ID IN VARCHAR2,
      P_FORECAST_ID IN VARCHAR2,
      P_CATEGORY_CODE IN VARCHAR2,
      P_EXP_CODE IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_FCST_CNTR_MTH_EXPEND.PREV_DAYTIME      (
         P_OBJECT_ID,
         P_FORECAST_ID,
         P_CATEGORY_CODE,
         P_EXP_CODE,
         P_DAYTIME,
         P_NUM_ROWS );
         RETURN ret_value;
   END PREV_DAYTIME;
   FUNCTION RECORD_STATUS(
      P_OBJECT_ID IN VARCHAR2,
      P_FORECAST_ID IN VARCHAR2,
      P_CATEGORY_CODE IN VARCHAR2,
      P_EXP_CODE IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_FCST_CNTR_MTH_EXPEND.RECORD_STATUS      (
         P_OBJECT_ID,
         P_FORECAST_ID,
         P_CATEGORY_CODE,
         P_EXP_CODE,
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END RECORD_STATUS;
   FUNCTION VALUE_1(
      P_OBJECT_ID IN VARCHAR2,
      P_FORECAST_ID IN VARCHAR2,
      P_CATEGORY_CODE IN VARCHAR2,
      P_EXP_CODE IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FCST_CNTR_MTH_EXPEND.VALUE_1      (
         P_OBJECT_ID,
         P_FORECAST_ID,
         P_CATEGORY_CODE,
         P_EXP_CODE,
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END VALUE_1;
   FUNCTION APPROVAL_DATE(
      P_OBJECT_ID IN VARCHAR2,
      P_FORECAST_ID IN VARCHAR2,
      P_CATEGORY_CODE IN VARCHAR2,
      P_EXP_CODE IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_FCST_CNTR_MTH_EXPEND.APPROVAL_DATE      (
         P_OBJECT_ID,
         P_FORECAST_ID,
         P_CATEGORY_CODE,
         P_EXP_CODE,
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END APPROVAL_DATE;
   FUNCTION MATH_VALUE_2(
      P_OBJECT_ID IN VARCHAR2,
      P_FORECAST_ID IN VARCHAR2,
      P_CATEGORY_CODE IN VARCHAR2,
      P_EXP_CODE IN VARCHAR2,
      P_FROM_DAY IN DATE,
      P_TO_DAY IN DATE,
      P_METHOD IN VARCHAR2 DEFAULT 'SUM')
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FCST_CNTR_MTH_EXPEND.MATH_VALUE_2      (
         P_OBJECT_ID,
         P_FORECAST_ID,
         P_CATEGORY_CODE,
         P_EXP_CODE,
         P_FROM_DAY,
         P_TO_DAY,
         P_METHOD );
         RETURN ret_value;
   END MATH_VALUE_2;
   FUNCTION ROW_BY_PK(
      P_OBJECT_ID IN VARCHAR2,
      P_FORECAST_ID IN VARCHAR2,
      P_CATEGORY_CODE IN VARCHAR2,
      P_EXP_CODE IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN REC_ROW_BY_PK
   IS
      ret_value    REC_ROW_BY_PK ;
   BEGIN
      ret_value := EC_FCST_CNTR_MTH_EXPEND.ROW_BY_PK      (
         P_OBJECT_ID,
         P_FORECAST_ID,
         P_CATEGORY_CODE,
         P_EXP_CODE,
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END ROW_BY_PK;
   FUNCTION ROW_BY_REL_OPERATOR(
      P_OBJECT_ID IN VARCHAR2,
      P_FORECAST_ID IN VARCHAR2,
      P_CATEGORY_CODE IN VARCHAR2,
      P_EXP_CODE IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN REC_ROW_BY_REL_OPERATOR
   IS
      ret_value    REC_ROW_BY_REL_OPERATOR ;
   BEGIN
      ret_value := EC_FCST_CNTR_MTH_EXPEND.ROW_BY_REL_OPERATOR      (
         P_OBJECT_ID,
         P_FORECAST_ID,
         P_CATEGORY_CODE,
         P_EXP_CODE,
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END ROW_BY_REL_OPERATOR;
   FUNCTION VALUE_2(
      P_OBJECT_ID IN VARCHAR2,
      P_FORECAST_ID IN VARCHAR2,
      P_CATEGORY_CODE IN VARCHAR2,
      P_EXP_CODE IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FCST_CNTR_MTH_EXPEND.VALUE_2      (
         P_OBJECT_ID,
         P_FORECAST_ID,
         P_CATEGORY_CODE,
         P_EXP_CODE,
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END VALUE_2;
   FUNCTION VALUE_3(
      P_OBJECT_ID IN VARCHAR2,
      P_FORECAST_ID IN VARCHAR2,
      P_CATEGORY_CODE IN VARCHAR2,
      P_EXP_CODE IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FCST_CNTR_MTH_EXPEND.VALUE_3      (
         P_OBJECT_ID,
         P_FORECAST_ID,
         P_CATEGORY_CODE,
         P_EXP_CODE,
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END VALUE_3;
   FUNCTION VALUE_4(
      P_OBJECT_ID IN VARCHAR2,
      P_FORECAST_ID IN VARCHAR2,
      P_CATEGORY_CODE IN VARCHAR2,
      P_EXP_CODE IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FCST_CNTR_MTH_EXPEND.VALUE_4      (
         P_OBJECT_ID,
         P_FORECAST_ID,
         P_CATEGORY_CODE,
         P_EXP_CODE,
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END VALUE_4;
   FUNCTION REC_ID(
      P_OBJECT_ID IN VARCHAR2,
      P_FORECAST_ID IN VARCHAR2,
      P_CATEGORY_CODE IN VARCHAR2,
      P_EXP_CODE IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_FCST_CNTR_MTH_EXPEND.REC_ID      (
         P_OBJECT_ID,
         P_FORECAST_ID,
         P_CATEGORY_CODE,
         P_EXP_CODE,
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END REC_ID;
   FUNCTION TEXT_1(
      P_OBJECT_ID IN VARCHAR2,
      P_FORECAST_ID IN VARCHAR2,
      P_CATEGORY_CODE IN VARCHAR2,
      P_EXP_CODE IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (16) ;
   BEGIN
      ret_value := EC_FCST_CNTR_MTH_EXPEND.TEXT_1      (
         P_OBJECT_ID,
         P_FORECAST_ID,
         P_CATEGORY_CODE,
         P_EXP_CODE,
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END TEXT_1;
   FUNCTION TEXT_2(
      P_OBJECT_ID IN VARCHAR2,
      P_FORECAST_ID IN VARCHAR2,
      P_CATEGORY_CODE IN VARCHAR2,
      P_EXP_CODE IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_FCST_CNTR_MTH_EXPEND.TEXT_2      (
         P_OBJECT_ID,
         P_FORECAST_ID,
         P_CATEGORY_CODE,
         P_EXP_CODE,
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END TEXT_2;
   FUNCTION VALUE_7(
      P_OBJECT_ID IN VARCHAR2,
      P_FORECAST_ID IN VARCHAR2,
      P_CATEGORY_CODE IN VARCHAR2,
      P_EXP_CODE IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FCST_CNTR_MTH_EXPEND.VALUE_7      (
         P_OBJECT_ID,
         P_FORECAST_ID,
         P_CATEGORY_CODE,
         P_EXP_CODE,
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END VALUE_7;
   FUNCTION VALUE_9(
      P_OBJECT_ID IN VARCHAR2,
      P_FORECAST_ID IN VARCHAR2,
      P_CATEGORY_CODE IN VARCHAR2,
      P_EXP_CODE IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FCST_CNTR_MTH_EXPEND.VALUE_9      (
         P_OBJECT_ID,
         P_FORECAST_ID,
         P_CATEGORY_CODE,
         P_EXP_CODE,
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END VALUE_9;
   FUNCTION DATE_1(
      P_OBJECT_ID IN VARCHAR2,
      P_FORECAST_ID IN VARCHAR2,
      P_CATEGORY_CODE IN VARCHAR2,
      P_EXP_CODE IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_FCST_CNTR_MTH_EXPEND.DATE_1      (
         P_OBJECT_ID,
         P_FORECAST_ID,
         P_CATEGORY_CODE,
         P_EXP_CODE,
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END DATE_1;
   FUNCTION MATH_VALUE_10(
      P_OBJECT_ID IN VARCHAR2,
      P_FORECAST_ID IN VARCHAR2,
      P_CATEGORY_CODE IN VARCHAR2,
      P_EXP_CODE IN VARCHAR2,
      P_FROM_DAY IN DATE,
      P_TO_DAY IN DATE,
      P_METHOD IN VARCHAR2 DEFAULT 'SUM')
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FCST_CNTR_MTH_EXPEND.MATH_VALUE_10      (
         P_OBJECT_ID,
         P_FORECAST_ID,
         P_CATEGORY_CODE,
         P_EXP_CODE,
         P_FROM_DAY,
         P_TO_DAY,
         P_METHOD );
         RETURN ret_value;
   END MATH_VALUE_10;
   FUNCTION VALUE_10(
      P_OBJECT_ID IN VARCHAR2,
      P_FORECAST_ID IN VARCHAR2,
      P_CATEGORY_CODE IN VARCHAR2,
      P_EXP_CODE IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FCST_CNTR_MTH_EXPEND.VALUE_10      (
         P_OBJECT_ID,
         P_FORECAST_ID,
         P_CATEGORY_CODE,
         P_EXP_CODE,
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END VALUE_10;
   FUNCTION VALUE_8(
      P_OBJECT_ID IN VARCHAR2,
      P_FORECAST_ID IN VARCHAR2,
      P_CATEGORY_CODE IN VARCHAR2,
      P_EXP_CODE IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FCST_CNTR_MTH_EXPEND.VALUE_8      (
         P_OBJECT_ID,
         P_FORECAST_ID,
         P_CATEGORY_CODE,
         P_EXP_CODE,
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END VALUE_8;

END RP_FCST_CNTR_MTH_EXPEND;

/
--GRANT EXECUTE ON ECKERNEL_WST.RP_FCST_CNTR_MTH_EXPEND TO REPORT_ROLE_XXX;



 -- FINISH PKG_GEN_PKGS.sf_get_functions at:05/07/2019 10.13.42 AM


