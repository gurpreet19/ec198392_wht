
 -- START PKG_GEN_PKGS.sf_get_functions at:11/15/2018 10.28.32 AM


CREATE or REPLACE PACKAGE RP_CONST_STD_K_INTERPOL
IS

   FUNCTION TEXT_3(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_MOL_WT IN NUMBER,
      P_GAS_TEMP IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2;
   FUNCTION APPROVAL_BY(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_MOL_WT IN NUMBER,
      P_GAS_TEMP IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2;
   FUNCTION APPROVAL_STATE(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_MOL_WT IN NUMBER,
      P_GAS_TEMP IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2;
   FUNCTION MATH_VALUE_3(
      P_OBJECT_ID IN VARCHAR2,
      P_MOL_WT IN NUMBER,
      P_GAS_TEMP IN NUMBER,
      P_FROM_DAY IN DATE,
      P_TO_DAY IN DATE,
      P_METHOD IN VARCHAR2 DEFAULT 'SUM')
      RETURN NUMBER;
   FUNCTION MATH_VALUE_4(
      P_OBJECT_ID IN VARCHAR2,
      P_MOL_WT IN NUMBER,
      P_GAS_TEMP IN NUMBER,
      P_FROM_DAY IN DATE,
      P_TO_DAY IN DATE,
      P_METHOD IN VARCHAR2 DEFAULT 'SUM')
      RETURN NUMBER;
   FUNCTION VALUE_5(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_MOL_WT IN NUMBER,
      P_GAS_TEMP IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER;
   FUNCTION K1_FACTOR(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_MOL_WT IN NUMBER,
      P_GAS_TEMP IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER;
   FUNCTION NEXT_DAYTIME(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_MOL_WT IN NUMBER,
      P_GAS_TEMP IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION PREV_EQUAL_DAYTIME(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_MOL_WT IN NUMBER,
      P_GAS_TEMP IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION TEXT_7(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_MOL_WT IN NUMBER,
      P_GAS_TEMP IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2;
   FUNCTION TEXT_8(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_MOL_WT IN NUMBER,
      P_GAS_TEMP IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2;
   FUNCTION COMMENTS(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_MOL_WT IN NUMBER,
      P_GAS_TEMP IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2;
   FUNCTION COUNT_ROWS(
      P_OBJECT_ID IN VARCHAR2,
      P_MOL_WT IN NUMBER,
      P_GAS_TEMP IN NUMBER,
      P_FROM_DAY IN DATE,
      P_TO_DAY IN DATE)
      RETURN NUMBER;
   FUNCTION DATE_3(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_MOL_WT IN NUMBER,
      P_GAS_TEMP IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN DATE;
   FUNCTION DATE_5(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_MOL_WT IN NUMBER,
      P_GAS_TEMP IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN DATE;
   FUNCTION MATH_K1_FACTOR(
      P_OBJECT_ID IN VARCHAR2,
      P_MOL_WT IN NUMBER,
      P_GAS_TEMP IN NUMBER,
      P_FROM_DAY IN DATE,
      P_TO_DAY IN DATE,
      P_METHOD IN VARCHAR2 DEFAULT 'SUM')
      RETURN NUMBER;
   FUNCTION MATH_K2_FACTOR(
      P_OBJECT_ID IN VARCHAR2,
      P_MOL_WT IN NUMBER,
      P_GAS_TEMP IN NUMBER,
      P_FROM_DAY IN DATE,
      P_TO_DAY IN DATE,
      P_METHOD IN VARCHAR2 DEFAULT 'SUM')
      RETURN NUMBER;
   FUNCTION MATH_VALUE_1(
      P_OBJECT_ID IN VARCHAR2,
      P_MOL_WT IN NUMBER,
      P_GAS_TEMP IN NUMBER,
      P_FROM_DAY IN DATE,
      P_TO_DAY IN DATE,
      P_METHOD IN VARCHAR2 DEFAULT 'SUM')
      RETURN NUMBER;
   FUNCTION MATH_VALUE_5(
      P_OBJECT_ID IN VARCHAR2,
      P_MOL_WT IN NUMBER,
      P_GAS_TEMP IN NUMBER,
      P_FROM_DAY IN DATE,
      P_TO_DAY IN DATE,
      P_METHOD IN VARCHAR2 DEFAULT 'SUM')
      RETURN NUMBER;
   FUNCTION NEXT_EQUAL_DAYTIME(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_MOL_WT IN NUMBER,
      P_GAS_TEMP IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION TEXT_1(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_MOL_WT IN NUMBER,
      P_GAS_TEMP IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2;
   FUNCTION TEXT_6(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_MOL_WT IN NUMBER,
      P_GAS_TEMP IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2;
   FUNCTION TEXT_9(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_MOL_WT IN NUMBER,
      P_GAS_TEMP IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2;
   FUNCTION DATE_2(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_MOL_WT IN NUMBER,
      P_GAS_TEMP IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN DATE;
   FUNCTION PREV_DAYTIME(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_MOL_WT IN NUMBER,
      P_GAS_TEMP IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION RECORD_STATUS(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_MOL_WT IN NUMBER,
      P_GAS_TEMP IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2;
   FUNCTION VALUE_1(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_MOL_WT IN NUMBER,
      P_GAS_TEMP IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER;
   FUNCTION APPROVAL_DATE(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_MOL_WT IN NUMBER,
      P_GAS_TEMP IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN DATE;
   FUNCTION MATH_VALUE_2(
      P_OBJECT_ID IN VARCHAR2,
      P_MOL_WT IN NUMBER,
      P_GAS_TEMP IN NUMBER,
      P_FROM_DAY IN DATE,
      P_TO_DAY IN DATE,
      P_METHOD IN VARCHAR2 DEFAULT 'SUM')
      RETURN NUMBER;
      TYPE REC_ROW_BY_PK IS RECORD (
         OBJECT_ID VARCHAR2 (32) ,
         DAYTIME  DATE ,
         MOL_WT NUMBER ,
         GAS_TEMP NUMBER ,
         K1_FACTOR NUMBER ,
         K2_FACTOR NUMBER ,
         COMMENTS VARCHAR2 (2000) ,
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
         VALUE_1 NUMBER ,
         VALUE_2 NUMBER ,
         VALUE_3 NUMBER ,
         VALUE_4 NUMBER ,
         VALUE_5 NUMBER ,
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
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_MOL_WT IN NUMBER,
      P_GAS_TEMP IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN REC_ROW_BY_PK;
      TYPE REC_ROW_BY_REL_OPERATOR IS RECORD (
         OBJECT_ID VARCHAR2 (32) ,
         DAYTIME  DATE ,
         MOL_WT NUMBER ,
         GAS_TEMP NUMBER ,
         K1_FACTOR NUMBER ,
         K2_FACTOR NUMBER ,
         COMMENTS VARCHAR2 (2000) ,
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
         VALUE_1 NUMBER ,
         VALUE_2 NUMBER ,
         VALUE_3 NUMBER ,
         VALUE_4 NUMBER ,
         VALUE_5 NUMBER ,
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
   FUNCTION ROW_BY_REL_OPERATOR(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_MOL_WT IN NUMBER,
      P_GAS_TEMP IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN REC_ROW_BY_REL_OPERATOR;
   FUNCTION TEXT_2(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_MOL_WT IN NUMBER,
      P_GAS_TEMP IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2;
   FUNCTION TEXT_4(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_MOL_WT IN NUMBER,
      P_GAS_TEMP IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2;
   FUNCTION TEXT_5(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_MOL_WT IN NUMBER,
      P_GAS_TEMP IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2;
   FUNCTION VALUE_2(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_MOL_WT IN NUMBER,
      P_GAS_TEMP IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER;
   FUNCTION VALUE_3(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_MOL_WT IN NUMBER,
      P_GAS_TEMP IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER;
   FUNCTION VALUE_4(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_MOL_WT IN NUMBER,
      P_GAS_TEMP IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER;
   FUNCTION DATE_4(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_MOL_WT IN NUMBER,
      P_GAS_TEMP IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN DATE;
   FUNCTION K2_FACTOR(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_MOL_WT IN NUMBER,
      P_GAS_TEMP IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER;
   FUNCTION MATH_MOL_WT(
      P_OBJECT_ID IN VARCHAR2,
      P_MOL_WT IN NUMBER,
      P_GAS_TEMP IN NUMBER,
      P_FROM_DAY IN DATE,
      P_TO_DAY IN DATE,
      P_METHOD IN VARCHAR2 DEFAULT 'SUM')
      RETURN NUMBER;
   FUNCTION REC_ID(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_MOL_WT IN NUMBER,
      P_GAS_TEMP IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2;
   FUNCTION DATE_1(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_MOL_WT IN NUMBER,
      P_GAS_TEMP IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN DATE;
   FUNCTION MATH_GAS_TEMP(
      P_OBJECT_ID IN VARCHAR2,
      P_MOL_WT IN NUMBER,
      P_GAS_TEMP IN NUMBER,
      P_FROM_DAY IN DATE,
      P_TO_DAY IN DATE,
      P_METHOD IN VARCHAR2 DEFAULT 'SUM')
      RETURN NUMBER;
   FUNCTION TEXT_10(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_MOL_WT IN NUMBER,
      P_GAS_TEMP IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2;

END RP_CONST_STD_K_INTERPOL;

/



CREATE or REPLACE PACKAGE BODY RP_CONST_STD_K_INTERPOL
IS

   FUNCTION TEXT_3(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_MOL_WT IN NUMBER,
      P_GAS_TEMP IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_CONST_STD_K_INTERPOL.TEXT_3      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_MOL_WT,
         P_GAS_TEMP,
         P_COMPARE_OPER );
         RETURN ret_value;
   END TEXT_3;
   FUNCTION APPROVAL_BY(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_MOL_WT IN NUMBER,
      P_GAS_TEMP IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (30) ;
   BEGIN
      ret_value := EC_CONST_STD_K_INTERPOL.APPROVAL_BY      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_MOL_WT,
         P_GAS_TEMP,
         P_COMPARE_OPER );
         RETURN ret_value;
   END APPROVAL_BY;
   FUNCTION APPROVAL_STATE(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_MOL_WT IN NUMBER,
      P_GAS_TEMP IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_CONST_STD_K_INTERPOL.APPROVAL_STATE      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_MOL_WT,
         P_GAS_TEMP,
         P_COMPARE_OPER );
         RETURN ret_value;
   END APPROVAL_STATE;
   FUNCTION MATH_VALUE_3(
      P_OBJECT_ID IN VARCHAR2,
      P_MOL_WT IN NUMBER,
      P_GAS_TEMP IN NUMBER,
      P_FROM_DAY IN DATE,
      P_TO_DAY IN DATE,
      P_METHOD IN VARCHAR2 DEFAULT 'SUM')
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CONST_STD_K_INTERPOL.MATH_VALUE_3      (
         P_OBJECT_ID,
         P_MOL_WT,
         P_GAS_TEMP,
         P_FROM_DAY,
         P_TO_DAY,
         P_METHOD );
         RETURN ret_value;
   END MATH_VALUE_3;
   FUNCTION MATH_VALUE_4(
      P_OBJECT_ID IN VARCHAR2,
      P_MOL_WT IN NUMBER,
      P_GAS_TEMP IN NUMBER,
      P_FROM_DAY IN DATE,
      P_TO_DAY IN DATE,
      P_METHOD IN VARCHAR2 DEFAULT 'SUM')
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CONST_STD_K_INTERPOL.MATH_VALUE_4      (
         P_OBJECT_ID,
         P_MOL_WT,
         P_GAS_TEMP,
         P_FROM_DAY,
         P_TO_DAY,
         P_METHOD );
         RETURN ret_value;
   END MATH_VALUE_4;
   FUNCTION VALUE_5(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_MOL_WT IN NUMBER,
      P_GAS_TEMP IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CONST_STD_K_INTERPOL.VALUE_5      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_MOL_WT,
         P_GAS_TEMP,
         P_COMPARE_OPER );
         RETURN ret_value;
   END VALUE_5;
   FUNCTION K1_FACTOR(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_MOL_WT IN NUMBER,
      P_GAS_TEMP IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CONST_STD_K_INTERPOL.K1_FACTOR      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_MOL_WT,
         P_GAS_TEMP,
         P_COMPARE_OPER );
         RETURN ret_value;
   END K1_FACTOR;
   FUNCTION NEXT_DAYTIME(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_MOL_WT IN NUMBER,
      P_GAS_TEMP IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CONST_STD_K_INTERPOL.NEXT_DAYTIME      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_MOL_WT,
         P_GAS_TEMP,
         P_NUM_ROWS );
         RETURN ret_value;
   END NEXT_DAYTIME;
   FUNCTION PREV_EQUAL_DAYTIME(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_MOL_WT IN NUMBER,
      P_GAS_TEMP IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CONST_STD_K_INTERPOL.PREV_EQUAL_DAYTIME      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_MOL_WT,
         P_GAS_TEMP,
         P_NUM_ROWS );
         RETURN ret_value;
   END PREV_EQUAL_DAYTIME;
   FUNCTION TEXT_7(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_MOL_WT IN NUMBER,
      P_GAS_TEMP IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_CONST_STD_K_INTERPOL.TEXT_7      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_MOL_WT,
         P_GAS_TEMP,
         P_COMPARE_OPER );
         RETURN ret_value;
   END TEXT_7;
   FUNCTION TEXT_8(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_MOL_WT IN NUMBER,
      P_GAS_TEMP IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_CONST_STD_K_INTERPOL.TEXT_8      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_MOL_WT,
         P_GAS_TEMP,
         P_COMPARE_OPER );
         RETURN ret_value;
   END TEXT_8;
   FUNCTION COMMENTS(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_MOL_WT IN NUMBER,
      P_GAS_TEMP IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_CONST_STD_K_INTERPOL.COMMENTS      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_MOL_WT,
         P_GAS_TEMP,
         P_COMPARE_OPER );
         RETURN ret_value;
   END COMMENTS;
   FUNCTION COUNT_ROWS(
      P_OBJECT_ID IN VARCHAR2,
      P_MOL_WT IN NUMBER,
      P_GAS_TEMP IN NUMBER,
      P_FROM_DAY IN DATE,
      P_TO_DAY IN DATE)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CONST_STD_K_INTERPOL.COUNT_ROWS      (
         P_OBJECT_ID,
         P_MOL_WT,
         P_GAS_TEMP,
         P_FROM_DAY,
         P_TO_DAY );
         RETURN ret_value;
   END COUNT_ROWS;
   FUNCTION DATE_3(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_MOL_WT IN NUMBER,
      P_GAS_TEMP IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CONST_STD_K_INTERPOL.DATE_3      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_MOL_WT,
         P_GAS_TEMP,
         P_COMPARE_OPER );
         RETURN ret_value;
   END DATE_3;
   FUNCTION DATE_5(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_MOL_WT IN NUMBER,
      P_GAS_TEMP IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CONST_STD_K_INTERPOL.DATE_5      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_MOL_WT,
         P_GAS_TEMP,
         P_COMPARE_OPER );
         RETURN ret_value;
   END DATE_5;
   FUNCTION MATH_K1_FACTOR(
      P_OBJECT_ID IN VARCHAR2,
      P_MOL_WT IN NUMBER,
      P_GAS_TEMP IN NUMBER,
      P_FROM_DAY IN DATE,
      P_TO_DAY IN DATE,
      P_METHOD IN VARCHAR2 DEFAULT 'SUM')
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CONST_STD_K_INTERPOL.MATH_K1_FACTOR      (
         P_OBJECT_ID,
         P_MOL_WT,
         P_GAS_TEMP,
         P_FROM_DAY,
         P_TO_DAY,
         P_METHOD );
         RETURN ret_value;
   END MATH_K1_FACTOR;
   FUNCTION MATH_K2_FACTOR(
      P_OBJECT_ID IN VARCHAR2,
      P_MOL_WT IN NUMBER,
      P_GAS_TEMP IN NUMBER,
      P_FROM_DAY IN DATE,
      P_TO_DAY IN DATE,
      P_METHOD IN VARCHAR2 DEFAULT 'SUM')
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CONST_STD_K_INTERPOL.MATH_K2_FACTOR      (
         P_OBJECT_ID,
         P_MOL_WT,
         P_GAS_TEMP,
         P_FROM_DAY,
         P_TO_DAY,
         P_METHOD );
         RETURN ret_value;
   END MATH_K2_FACTOR;
   FUNCTION MATH_VALUE_1(
      P_OBJECT_ID IN VARCHAR2,
      P_MOL_WT IN NUMBER,
      P_GAS_TEMP IN NUMBER,
      P_FROM_DAY IN DATE,
      P_TO_DAY IN DATE,
      P_METHOD IN VARCHAR2 DEFAULT 'SUM')
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CONST_STD_K_INTERPOL.MATH_VALUE_1      (
         P_OBJECT_ID,
         P_MOL_WT,
         P_GAS_TEMP,
         P_FROM_DAY,
         P_TO_DAY,
         P_METHOD );
         RETURN ret_value;
   END MATH_VALUE_1;
   FUNCTION MATH_VALUE_5(
      P_OBJECT_ID IN VARCHAR2,
      P_MOL_WT IN NUMBER,
      P_GAS_TEMP IN NUMBER,
      P_FROM_DAY IN DATE,
      P_TO_DAY IN DATE,
      P_METHOD IN VARCHAR2 DEFAULT 'SUM')
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CONST_STD_K_INTERPOL.MATH_VALUE_5      (
         P_OBJECT_ID,
         P_MOL_WT,
         P_GAS_TEMP,
         P_FROM_DAY,
         P_TO_DAY,
         P_METHOD );
         RETURN ret_value;
   END MATH_VALUE_5;
   FUNCTION NEXT_EQUAL_DAYTIME(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_MOL_WT IN NUMBER,
      P_GAS_TEMP IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CONST_STD_K_INTERPOL.NEXT_EQUAL_DAYTIME      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_MOL_WT,
         P_GAS_TEMP,
         P_NUM_ROWS );
         RETURN ret_value;
   END NEXT_EQUAL_DAYTIME;
   FUNCTION TEXT_1(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_MOL_WT IN NUMBER,
      P_GAS_TEMP IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_CONST_STD_K_INTERPOL.TEXT_1      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_MOL_WT,
         P_GAS_TEMP,
         P_COMPARE_OPER );
         RETURN ret_value;
   END TEXT_1;
   FUNCTION TEXT_6(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_MOL_WT IN NUMBER,
      P_GAS_TEMP IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_CONST_STD_K_INTERPOL.TEXT_6      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_MOL_WT,
         P_GAS_TEMP,
         P_COMPARE_OPER );
         RETURN ret_value;
   END TEXT_6;
   FUNCTION TEXT_9(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_MOL_WT IN NUMBER,
      P_GAS_TEMP IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_CONST_STD_K_INTERPOL.TEXT_9      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_MOL_WT,
         P_GAS_TEMP,
         P_COMPARE_OPER );
         RETURN ret_value;
   END TEXT_9;
   FUNCTION DATE_2(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_MOL_WT IN NUMBER,
      P_GAS_TEMP IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CONST_STD_K_INTERPOL.DATE_2      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_MOL_WT,
         P_GAS_TEMP,
         P_COMPARE_OPER );
         RETURN ret_value;
   END DATE_2;
   FUNCTION PREV_DAYTIME(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_MOL_WT IN NUMBER,
      P_GAS_TEMP IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CONST_STD_K_INTERPOL.PREV_DAYTIME      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_MOL_WT,
         P_GAS_TEMP,
         P_NUM_ROWS );
         RETURN ret_value;
   END PREV_DAYTIME;
   FUNCTION RECORD_STATUS(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_MOL_WT IN NUMBER,
      P_GAS_TEMP IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_CONST_STD_K_INTERPOL.RECORD_STATUS      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_MOL_WT,
         P_GAS_TEMP,
         P_COMPARE_OPER );
         RETURN ret_value;
   END RECORD_STATUS;
   FUNCTION VALUE_1(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_MOL_WT IN NUMBER,
      P_GAS_TEMP IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CONST_STD_K_INTERPOL.VALUE_1      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_MOL_WT,
         P_GAS_TEMP,
         P_COMPARE_OPER );
         RETURN ret_value;
   END VALUE_1;
   FUNCTION APPROVAL_DATE(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_MOL_WT IN NUMBER,
      P_GAS_TEMP IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CONST_STD_K_INTERPOL.APPROVAL_DATE      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_MOL_WT,
         P_GAS_TEMP,
         P_COMPARE_OPER );
         RETURN ret_value;
   END APPROVAL_DATE;
   FUNCTION MATH_VALUE_2(
      P_OBJECT_ID IN VARCHAR2,
      P_MOL_WT IN NUMBER,
      P_GAS_TEMP IN NUMBER,
      P_FROM_DAY IN DATE,
      P_TO_DAY IN DATE,
      P_METHOD IN VARCHAR2 DEFAULT 'SUM')
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CONST_STD_K_INTERPOL.MATH_VALUE_2      (
         P_OBJECT_ID,
         P_MOL_WT,
         P_GAS_TEMP,
         P_FROM_DAY,
         P_TO_DAY,
         P_METHOD );
         RETURN ret_value;
   END MATH_VALUE_2;
   FUNCTION ROW_BY_PK(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_MOL_WT IN NUMBER,
      P_GAS_TEMP IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN REC_ROW_BY_PK
   IS
      ret_value    REC_ROW_BY_PK ;
   BEGIN
      ret_value := EC_CONST_STD_K_INTERPOL.ROW_BY_PK      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_MOL_WT,
         P_GAS_TEMP,
         P_COMPARE_OPER );
         RETURN ret_value;
   END ROW_BY_PK;
   FUNCTION ROW_BY_REL_OPERATOR(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_MOL_WT IN NUMBER,
      P_GAS_TEMP IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN REC_ROW_BY_REL_OPERATOR
   IS
      ret_value    REC_ROW_BY_REL_OPERATOR ;
   BEGIN
      ret_value := EC_CONST_STD_K_INTERPOL.ROW_BY_REL_OPERATOR      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_MOL_WT,
         P_GAS_TEMP,
         P_COMPARE_OPER );
         RETURN ret_value;
   END ROW_BY_REL_OPERATOR;
   FUNCTION TEXT_2(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_MOL_WT IN NUMBER,
      P_GAS_TEMP IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_CONST_STD_K_INTERPOL.TEXT_2      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_MOL_WT,
         P_GAS_TEMP,
         P_COMPARE_OPER );
         RETURN ret_value;
   END TEXT_2;
   FUNCTION TEXT_4(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_MOL_WT IN NUMBER,
      P_GAS_TEMP IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_CONST_STD_K_INTERPOL.TEXT_4      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_MOL_WT,
         P_GAS_TEMP,
         P_COMPARE_OPER );
         RETURN ret_value;
   END TEXT_4;
   FUNCTION TEXT_5(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_MOL_WT IN NUMBER,
      P_GAS_TEMP IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_CONST_STD_K_INTERPOL.TEXT_5      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_MOL_WT,
         P_GAS_TEMP,
         P_COMPARE_OPER );
         RETURN ret_value;
   END TEXT_5;
   FUNCTION VALUE_2(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_MOL_WT IN NUMBER,
      P_GAS_TEMP IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CONST_STD_K_INTERPOL.VALUE_2      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_MOL_WT,
         P_GAS_TEMP,
         P_COMPARE_OPER );
         RETURN ret_value;
   END VALUE_2;
   FUNCTION VALUE_3(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_MOL_WT IN NUMBER,
      P_GAS_TEMP IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CONST_STD_K_INTERPOL.VALUE_3      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_MOL_WT,
         P_GAS_TEMP,
         P_COMPARE_OPER );
         RETURN ret_value;
   END VALUE_3;
   FUNCTION VALUE_4(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_MOL_WT IN NUMBER,
      P_GAS_TEMP IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CONST_STD_K_INTERPOL.VALUE_4      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_MOL_WT,
         P_GAS_TEMP,
         P_COMPARE_OPER );
         RETURN ret_value;
   END VALUE_4;
   FUNCTION DATE_4(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_MOL_WT IN NUMBER,
      P_GAS_TEMP IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CONST_STD_K_INTERPOL.DATE_4      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_MOL_WT,
         P_GAS_TEMP,
         P_COMPARE_OPER );
         RETURN ret_value;
   END DATE_4;
   FUNCTION K2_FACTOR(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_MOL_WT IN NUMBER,
      P_GAS_TEMP IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CONST_STD_K_INTERPOL.K2_FACTOR      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_MOL_WT,
         P_GAS_TEMP,
         P_COMPARE_OPER );
         RETURN ret_value;
   END K2_FACTOR;
   FUNCTION MATH_MOL_WT(
      P_OBJECT_ID IN VARCHAR2,
      P_MOL_WT IN NUMBER,
      P_GAS_TEMP IN NUMBER,
      P_FROM_DAY IN DATE,
      P_TO_DAY IN DATE,
      P_METHOD IN VARCHAR2 DEFAULT 'SUM')
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CONST_STD_K_INTERPOL.MATH_MOL_WT      (
         P_OBJECT_ID,
         P_MOL_WT,
         P_GAS_TEMP,
         P_FROM_DAY,
         P_TO_DAY,
         P_METHOD );
         RETURN ret_value;
   END MATH_MOL_WT;
   FUNCTION REC_ID(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_MOL_WT IN NUMBER,
      P_GAS_TEMP IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_CONST_STD_K_INTERPOL.REC_ID      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_MOL_WT,
         P_GAS_TEMP,
         P_COMPARE_OPER );
         RETURN ret_value;
   END REC_ID;
   FUNCTION DATE_1(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_MOL_WT IN NUMBER,
      P_GAS_TEMP IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CONST_STD_K_INTERPOL.DATE_1      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_MOL_WT,
         P_GAS_TEMP,
         P_COMPARE_OPER );
         RETURN ret_value;
   END DATE_1;
   FUNCTION MATH_GAS_TEMP(
      P_OBJECT_ID IN VARCHAR2,
      P_MOL_WT IN NUMBER,
      P_GAS_TEMP IN NUMBER,
      P_FROM_DAY IN DATE,
      P_TO_DAY IN DATE,
      P_METHOD IN VARCHAR2 DEFAULT 'SUM')
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CONST_STD_K_INTERPOL.MATH_GAS_TEMP      (
         P_OBJECT_ID,
         P_MOL_WT,
         P_GAS_TEMP,
         P_FROM_DAY,
         P_TO_DAY,
         P_METHOD );
         RETURN ret_value;
   END MATH_GAS_TEMP;
   FUNCTION TEXT_10(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_MOL_WT IN NUMBER,
      P_GAS_TEMP IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_CONST_STD_K_INTERPOL.TEXT_10      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_MOL_WT,
         P_GAS_TEMP,
         P_COMPARE_OPER );
         RETURN ret_value;
   END TEXT_10;

END RP_CONST_STD_K_INTERPOL;

/
--GRANT EXECUTE ON ECKERNEL_WST.RP_CONST_STD_K_INTERPOL TO REPORT_ROLE_XXX;



 -- FINISH PKG_GEN_PKGS.sf_get_functions at:11/15/2018 10.28.42 AM


