
 -- START PKG_GEN_PKGS.sf_get_functions at:05/07/2019 11.16.36 AM


CREATE or REPLACE PACKAGE RP_CALC_EQUATION
IS

   FUNCTION DESCRIPTION(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_SEQ_NO IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN CLOB;
   FUNCTION DISABLED_IND(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_SEQ_NO IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2;
   FUNCTION EQUATION(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_SEQ_NO IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN CLOB;
   FUNCTION TEXT_3(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_SEQ_NO IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2;
   FUNCTION APPROVAL_BY(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_SEQ_NO IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2;
   FUNCTION APPROVAL_STATE(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_SEQ_NO IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2;
   FUNCTION ITERATIONS(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_SEQ_NO IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN CLOB;
   FUNCTION REF_OBJECT_ID_4(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_SEQ_NO IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2;
   FUNCTION VALUE_5(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_SEQ_NO IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER;
   FUNCTION EXEC_ORDER(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_SEQ_NO IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER;
   FUNCTION NEXT_DAYTIME(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_SEQ_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION PREV_EQUAL_DAYTIME(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_SEQ_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION TEXT_7(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_SEQ_NO IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2;
   FUNCTION TEXT_8(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_SEQ_NO IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2;
   FUNCTION DATE_3(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_SEQ_NO IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN DATE;
   FUNCTION DATE_5(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_SEQ_NO IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN DATE;
   FUNCTION NEXT_EQUAL_DAYTIME(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_SEQ_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION REF_OBJECT_ID_2(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_SEQ_NO IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2;
   FUNCTION REF_OBJECT_ID_3(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_SEQ_NO IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2;
   FUNCTION TEXT_1(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_SEQ_NO IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2;
   FUNCTION TEXT_6(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_SEQ_NO IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2;
   FUNCTION TEXT_9(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_SEQ_NO IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2;
   FUNCTION DATE_2(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_SEQ_NO IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN DATE;
   FUNCTION PREV_DAYTIME(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_SEQ_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION RECORD_STATUS(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_SEQ_NO IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2;
   FUNCTION REF_OBJECT_ID_5(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_SEQ_NO IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2;
   FUNCTION VALUE_1(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_SEQ_NO IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER;
   FUNCTION APPROVAL_DATE(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_SEQ_NO IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN DATE;
   FUNCTION CONDITION(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_SEQ_NO IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN CLOB;
   FUNCTION REF_OBJECT_ID_1(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_SEQ_NO IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2;
      TYPE REC_ROW_BY_PK IS RECORD (
         OBJECT_ID VARCHAR2 (32) ,
         DAYTIME  DATE ,
         SEQ_NO NUMBER ,
         EXEC_ORDER NUMBER ,
         DESCRIPTION  CLOB ,
         DISABLED_IND VARCHAR2 (1) ,
         ITERATIONS  CLOB ,
         CONDITION  CLOB ,
         EQUATION  CLOB ,
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
         REF_OBJECT_ID_1 VARCHAR2 (32) ,
         REF_OBJECT_ID_2 VARCHAR2 (32) ,
         REF_OBJECT_ID_3 VARCHAR2 (32) ,
         REF_OBJECT_ID_4 VARCHAR2 (32) ,
         REF_OBJECT_ID_5 VARCHAR2 (32) ,
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
      P_SEQ_NO IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN REC_ROW_BY_PK;
      TYPE REC_ROW_BY_REL_OPERATOR IS RECORD (
         OBJECT_ID VARCHAR2 (32) ,
         DAYTIME  DATE ,
         SEQ_NO NUMBER ,
         EXEC_ORDER NUMBER ,
         DESCRIPTION  CLOB ,
         DISABLED_IND VARCHAR2 (1) ,
         ITERATIONS  CLOB ,
         CONDITION  CLOB ,
         EQUATION  CLOB ,
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
         REF_OBJECT_ID_1 VARCHAR2 (32) ,
         REF_OBJECT_ID_2 VARCHAR2 (32) ,
         REF_OBJECT_ID_3 VARCHAR2 (32) ,
         REF_OBJECT_ID_4 VARCHAR2 (32) ,
         REF_OBJECT_ID_5 VARCHAR2 (32) ,
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
      P_SEQ_NO IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN REC_ROW_BY_REL_OPERATOR;
   FUNCTION TEXT_2(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_SEQ_NO IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2;
   FUNCTION TEXT_4(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_SEQ_NO IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2;
   FUNCTION TEXT_5(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_SEQ_NO IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2;
   FUNCTION VALUE_2(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_SEQ_NO IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER;
   FUNCTION VALUE_3(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_SEQ_NO IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER;
   FUNCTION VALUE_4(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_SEQ_NO IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER;
   FUNCTION DATE_4(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_SEQ_NO IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN DATE;
   FUNCTION REC_ID(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_SEQ_NO IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2;
   FUNCTION DATE_1(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_SEQ_NO IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN DATE;
   FUNCTION TEXT_10(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_SEQ_NO IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2;

END RP_CALC_EQUATION;

/



CREATE or REPLACE PACKAGE BODY RP_CALC_EQUATION
IS

   FUNCTION DESCRIPTION(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_SEQ_NO IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN CLOB
   IS
      ret_value    CLOB ;
   BEGIN
      ret_value := EC_CALC_EQUATION.DESCRIPTION      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_SEQ_NO,
         P_COMPARE_OPER );
         RETURN ret_value;
   END DESCRIPTION;
   FUNCTION DISABLED_IND(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_SEQ_NO IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_CALC_EQUATION.DISABLED_IND      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_SEQ_NO,
         P_COMPARE_OPER );
         RETURN ret_value;
   END DISABLED_IND;
   FUNCTION EQUATION(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_SEQ_NO IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN CLOB
   IS
      ret_value    CLOB ;
   BEGIN
      ret_value := EC_CALC_EQUATION.EQUATION      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_SEQ_NO,
         P_COMPARE_OPER );
         RETURN ret_value;
   END EQUATION;
   FUNCTION TEXT_3(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_SEQ_NO IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_CALC_EQUATION.TEXT_3      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_SEQ_NO,
         P_COMPARE_OPER );
         RETURN ret_value;
   END TEXT_3;
   FUNCTION APPROVAL_BY(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_SEQ_NO IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (30) ;
   BEGIN
      ret_value := EC_CALC_EQUATION.APPROVAL_BY      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_SEQ_NO,
         P_COMPARE_OPER );
         RETURN ret_value;
   END APPROVAL_BY;
   FUNCTION APPROVAL_STATE(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_SEQ_NO IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_CALC_EQUATION.APPROVAL_STATE      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_SEQ_NO,
         P_COMPARE_OPER );
         RETURN ret_value;
   END APPROVAL_STATE;
   FUNCTION ITERATIONS(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_SEQ_NO IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN CLOB
   IS
      ret_value    CLOB ;
   BEGIN
      ret_value := EC_CALC_EQUATION.ITERATIONS      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_SEQ_NO,
         P_COMPARE_OPER );
         RETURN ret_value;
   END ITERATIONS;
   FUNCTION REF_OBJECT_ID_4(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_SEQ_NO IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_CALC_EQUATION.REF_OBJECT_ID_4      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_SEQ_NO,
         P_COMPARE_OPER );
         RETURN ret_value;
   END REF_OBJECT_ID_4;
   FUNCTION VALUE_5(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_SEQ_NO IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CALC_EQUATION.VALUE_5      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_SEQ_NO,
         P_COMPARE_OPER );
         RETURN ret_value;
   END VALUE_5;
   FUNCTION EXEC_ORDER(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_SEQ_NO IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CALC_EQUATION.EXEC_ORDER      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_SEQ_NO,
         P_COMPARE_OPER );
         RETURN ret_value;
   END EXEC_ORDER;
   FUNCTION NEXT_DAYTIME(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_SEQ_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CALC_EQUATION.NEXT_DAYTIME      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_SEQ_NO,
         P_NUM_ROWS );
         RETURN ret_value;
   END NEXT_DAYTIME;
   FUNCTION PREV_EQUAL_DAYTIME(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_SEQ_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CALC_EQUATION.PREV_EQUAL_DAYTIME      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_SEQ_NO,
         P_NUM_ROWS );
         RETURN ret_value;
   END PREV_EQUAL_DAYTIME;
   FUNCTION TEXT_7(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_SEQ_NO IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_CALC_EQUATION.TEXT_7      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_SEQ_NO,
         P_COMPARE_OPER );
         RETURN ret_value;
   END TEXT_7;
   FUNCTION TEXT_8(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_SEQ_NO IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_CALC_EQUATION.TEXT_8      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_SEQ_NO,
         P_COMPARE_OPER );
         RETURN ret_value;
   END TEXT_8;
   FUNCTION DATE_3(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_SEQ_NO IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CALC_EQUATION.DATE_3      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_SEQ_NO,
         P_COMPARE_OPER );
         RETURN ret_value;
   END DATE_3;
   FUNCTION DATE_5(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_SEQ_NO IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CALC_EQUATION.DATE_5      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_SEQ_NO,
         P_COMPARE_OPER );
         RETURN ret_value;
   END DATE_5;
   FUNCTION NEXT_EQUAL_DAYTIME(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_SEQ_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CALC_EQUATION.NEXT_EQUAL_DAYTIME      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_SEQ_NO,
         P_NUM_ROWS );
         RETURN ret_value;
   END NEXT_EQUAL_DAYTIME;
   FUNCTION REF_OBJECT_ID_2(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_SEQ_NO IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_CALC_EQUATION.REF_OBJECT_ID_2      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_SEQ_NO,
         P_COMPARE_OPER );
         RETURN ret_value;
   END REF_OBJECT_ID_2;
   FUNCTION REF_OBJECT_ID_3(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_SEQ_NO IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_CALC_EQUATION.REF_OBJECT_ID_3      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_SEQ_NO,
         P_COMPARE_OPER );
         RETURN ret_value;
   END REF_OBJECT_ID_3;
   FUNCTION TEXT_1(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_SEQ_NO IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_CALC_EQUATION.TEXT_1      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_SEQ_NO,
         P_COMPARE_OPER );
         RETURN ret_value;
   END TEXT_1;
   FUNCTION TEXT_6(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_SEQ_NO IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_CALC_EQUATION.TEXT_6      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_SEQ_NO,
         P_COMPARE_OPER );
         RETURN ret_value;
   END TEXT_6;
   FUNCTION TEXT_9(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_SEQ_NO IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_CALC_EQUATION.TEXT_9      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_SEQ_NO,
         P_COMPARE_OPER );
         RETURN ret_value;
   END TEXT_9;
   FUNCTION DATE_2(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_SEQ_NO IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CALC_EQUATION.DATE_2      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_SEQ_NO,
         P_COMPARE_OPER );
         RETURN ret_value;
   END DATE_2;
   FUNCTION PREV_DAYTIME(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_SEQ_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CALC_EQUATION.PREV_DAYTIME      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_SEQ_NO,
         P_NUM_ROWS );
         RETURN ret_value;
   END PREV_DAYTIME;
   FUNCTION RECORD_STATUS(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_SEQ_NO IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_CALC_EQUATION.RECORD_STATUS      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_SEQ_NO,
         P_COMPARE_OPER );
         RETURN ret_value;
   END RECORD_STATUS;
   FUNCTION REF_OBJECT_ID_5(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_SEQ_NO IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_CALC_EQUATION.REF_OBJECT_ID_5      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_SEQ_NO,
         P_COMPARE_OPER );
         RETURN ret_value;
   END REF_OBJECT_ID_5;
   FUNCTION VALUE_1(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_SEQ_NO IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CALC_EQUATION.VALUE_1      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_SEQ_NO,
         P_COMPARE_OPER );
         RETURN ret_value;
   END VALUE_1;
   FUNCTION APPROVAL_DATE(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_SEQ_NO IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CALC_EQUATION.APPROVAL_DATE      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_SEQ_NO,
         P_COMPARE_OPER );
         RETURN ret_value;
   END APPROVAL_DATE;
   FUNCTION CONDITION(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_SEQ_NO IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN CLOB
   IS
      ret_value    CLOB ;
   BEGIN
      ret_value := EC_CALC_EQUATION.CONDITION      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_SEQ_NO,
         P_COMPARE_OPER );
         RETURN ret_value;
   END CONDITION;
   FUNCTION REF_OBJECT_ID_1(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_SEQ_NO IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_CALC_EQUATION.REF_OBJECT_ID_1      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_SEQ_NO,
         P_COMPARE_OPER );
         RETURN ret_value;
   END REF_OBJECT_ID_1;
   FUNCTION ROW_BY_PK(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_SEQ_NO IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN REC_ROW_BY_PK
   IS
      ret_value    REC_ROW_BY_PK ;
   BEGIN
      ret_value := EC_CALC_EQUATION.ROW_BY_PK      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_SEQ_NO,
         P_COMPARE_OPER );
         RETURN ret_value;
   END ROW_BY_PK;
   FUNCTION ROW_BY_REL_OPERATOR(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_SEQ_NO IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN REC_ROW_BY_REL_OPERATOR
   IS
      ret_value    REC_ROW_BY_REL_OPERATOR ;
   BEGIN
      ret_value := EC_CALC_EQUATION.ROW_BY_REL_OPERATOR      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_SEQ_NO,
         P_COMPARE_OPER );
         RETURN ret_value;
   END ROW_BY_REL_OPERATOR;
   FUNCTION TEXT_2(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_SEQ_NO IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_CALC_EQUATION.TEXT_2      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_SEQ_NO,
         P_COMPARE_OPER );
         RETURN ret_value;
   END TEXT_2;
   FUNCTION TEXT_4(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_SEQ_NO IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_CALC_EQUATION.TEXT_4      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_SEQ_NO,
         P_COMPARE_OPER );
         RETURN ret_value;
   END TEXT_4;
   FUNCTION TEXT_5(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_SEQ_NO IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_CALC_EQUATION.TEXT_5      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_SEQ_NO,
         P_COMPARE_OPER );
         RETURN ret_value;
   END TEXT_5;
   FUNCTION VALUE_2(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_SEQ_NO IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CALC_EQUATION.VALUE_2      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_SEQ_NO,
         P_COMPARE_OPER );
         RETURN ret_value;
   END VALUE_2;
   FUNCTION VALUE_3(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_SEQ_NO IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CALC_EQUATION.VALUE_3      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_SEQ_NO,
         P_COMPARE_OPER );
         RETURN ret_value;
   END VALUE_3;
   FUNCTION VALUE_4(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_SEQ_NO IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CALC_EQUATION.VALUE_4      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_SEQ_NO,
         P_COMPARE_OPER );
         RETURN ret_value;
   END VALUE_4;
   FUNCTION DATE_4(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_SEQ_NO IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CALC_EQUATION.DATE_4      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_SEQ_NO,
         P_COMPARE_OPER );
         RETURN ret_value;
   END DATE_4;
   FUNCTION REC_ID(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_SEQ_NO IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_CALC_EQUATION.REC_ID      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_SEQ_NO,
         P_COMPARE_OPER );
         RETURN ret_value;
   END REC_ID;
   FUNCTION DATE_1(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_SEQ_NO IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CALC_EQUATION.DATE_1      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_SEQ_NO,
         P_COMPARE_OPER );
         RETURN ret_value;
   END DATE_1;
   FUNCTION TEXT_10(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_SEQ_NO IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_CALC_EQUATION.TEXT_10      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_SEQ_NO,
         P_COMPARE_OPER );
         RETURN ret_value;
   END TEXT_10;

END RP_CALC_EQUATION;

/
--GRANT EXECUTE ON ECKERNEL_WST.RP_CALC_EQUATION TO REPORT_ROLE_XXX;



 -- FINISH PKG_GEN_PKGS.sf_get_functions at:05/07/2019 11.16.45 AM


