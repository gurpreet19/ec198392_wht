
 -- START PKG_GEN_PKGS.sf_get_functions at:11/15/2018 10.56.55 AM


CREATE or REPLACE PACKAGE RP_CALC_SET_CONDITION
IS

   FUNCTION TEXT_3(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_CALC_SET_NAME IN VARCHAR2,
      P_SEQ_NO IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2;
   FUNCTION APPROVAL_BY(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_CALC_SET_NAME IN VARCHAR2,
      P_SEQ_NO IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2;
   FUNCTION APPROVAL_STATE(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_CALC_SET_NAME IN VARCHAR2,
      P_SEQ_NO IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2;
   FUNCTION REF_OBJECT_ID_4(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_CALC_SET_NAME IN VARCHAR2,
      P_SEQ_NO IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2;
   FUNCTION VALUE_5(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_CALC_SET_NAME IN VARCHAR2,
      P_SEQ_NO IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER;
   FUNCTION NEXT_DAYTIME(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_CALC_SET_NAME IN VARCHAR2,
      P_SEQ_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION PREV_EQUAL_DAYTIME(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_CALC_SET_NAME IN VARCHAR2,
      P_SEQ_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION TEXT_7(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_CALC_SET_NAME IN VARCHAR2,
      P_SEQ_NO IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2;
   FUNCTION TEXT_8(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_CALC_SET_NAME IN VARCHAR2,
      P_SEQ_NO IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2;
   FUNCTION DATE_3(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_CALC_SET_NAME IN VARCHAR2,
      P_SEQ_NO IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN DATE;
   FUNCTION DATE_5(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_CALC_SET_NAME IN VARCHAR2,
      P_SEQ_NO IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN DATE;
   FUNCTION NEXT_EQUAL_DAYTIME(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_CALC_SET_NAME IN VARCHAR2,
      P_SEQ_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION REF_OBJECT_ID_2(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_CALC_SET_NAME IN VARCHAR2,
      P_SEQ_NO IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2;
   FUNCTION REF_OBJECT_ID_3(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_CALC_SET_NAME IN VARCHAR2,
      P_SEQ_NO IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2;
   FUNCTION TEXT_1(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_CALC_SET_NAME IN VARCHAR2,
      P_SEQ_NO IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2;
   FUNCTION TEXT_6(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_CALC_SET_NAME IN VARCHAR2,
      P_SEQ_NO IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2;
   FUNCTION TEXT_9(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_CALC_SET_NAME IN VARCHAR2,
      P_SEQ_NO IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2;
   FUNCTION DATE_2(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_CALC_SET_NAME IN VARCHAR2,
      P_SEQ_NO IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN DATE;
   FUNCTION PREV_DAYTIME(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_CALC_SET_NAME IN VARCHAR2,
      P_SEQ_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION RECORD_STATUS(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_CALC_SET_NAME IN VARCHAR2,
      P_SEQ_NO IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2;
   FUNCTION REF_OBJECT_ID_5(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_CALC_SET_NAME IN VARCHAR2,
      P_SEQ_NO IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2;
   FUNCTION VALUE_1(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_CALC_SET_NAME IN VARCHAR2,
      P_SEQ_NO IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER;
   FUNCTION APPROVAL_DATE(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_CALC_SET_NAME IN VARCHAR2,
      P_SEQ_NO IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN DATE;
   FUNCTION REF_OBJECT_ID_1(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_CALC_SET_NAME IN VARCHAR2,
      P_SEQ_NO IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2;
      TYPE REC_ROW_BY_PK IS RECORD (
         OBJECT_ID VARCHAR2 (32) ,
         DAYTIME  DATE ,
         CALC_SET_NAME VARCHAR2 (240) ,
         SEQ_NO NUMBER ,
         OPERATOR VARCHAR2 (32) ,
         OP1_SQL_SYNTAX VARCHAR2 (32) ,
         OP2_SET_COND_TYPE VARCHAR2 (32) ,
         OP2_SET_COND_VALUE VARCHAR2 (240) ,
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
      P_CALC_SET_NAME IN VARCHAR2,
      P_SEQ_NO IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN REC_ROW_BY_PK;
      TYPE REC_ROW_BY_REL_OPERATOR IS RECORD (
         OBJECT_ID VARCHAR2 (32) ,
         DAYTIME  DATE ,
         CALC_SET_NAME VARCHAR2 (240) ,
         SEQ_NO NUMBER ,
         OPERATOR VARCHAR2 (32) ,
         OP1_SQL_SYNTAX VARCHAR2 (32) ,
         OP2_SET_COND_TYPE VARCHAR2 (32) ,
         OP2_SET_COND_VALUE VARCHAR2 (240) ,
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
      P_CALC_SET_NAME IN VARCHAR2,
      P_SEQ_NO IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN REC_ROW_BY_REL_OPERATOR;
   FUNCTION TEXT_2(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_CALC_SET_NAME IN VARCHAR2,
      P_SEQ_NO IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2;
   FUNCTION TEXT_4(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_CALC_SET_NAME IN VARCHAR2,
      P_SEQ_NO IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2;
   FUNCTION TEXT_5(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_CALC_SET_NAME IN VARCHAR2,
      P_SEQ_NO IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2;
   FUNCTION VALUE_2(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_CALC_SET_NAME IN VARCHAR2,
      P_SEQ_NO IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER;
   FUNCTION VALUE_3(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_CALC_SET_NAME IN VARCHAR2,
      P_SEQ_NO IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER;
   FUNCTION VALUE_4(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_CALC_SET_NAME IN VARCHAR2,
      P_SEQ_NO IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER;
   FUNCTION DATE_4(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_CALC_SET_NAME IN VARCHAR2,
      P_SEQ_NO IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN DATE;
   FUNCTION OP1_SQL_SYNTAX(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_CALC_SET_NAME IN VARCHAR2,
      P_SEQ_NO IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2;
   FUNCTION OP2_SET_COND_VALUE(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_CALC_SET_NAME IN VARCHAR2,
      P_SEQ_NO IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2;
   FUNCTION REC_ID(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_CALC_SET_NAME IN VARCHAR2,
      P_SEQ_NO IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2;
   FUNCTION DATE_1(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_CALC_SET_NAME IN VARCHAR2,
      P_SEQ_NO IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN DATE;
   FUNCTION OP2_SET_COND_TYPE(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_CALC_SET_NAME IN VARCHAR2,
      P_SEQ_NO IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2;
   FUNCTION OPERATOR(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_CALC_SET_NAME IN VARCHAR2,
      P_SEQ_NO IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2;
   FUNCTION TEXT_10(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_CALC_SET_NAME IN VARCHAR2,
      P_SEQ_NO IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2;

END RP_CALC_SET_CONDITION;

/



CREATE or REPLACE PACKAGE BODY RP_CALC_SET_CONDITION
IS

   FUNCTION TEXT_3(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_CALC_SET_NAME IN VARCHAR2,
      P_SEQ_NO IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_CALC_SET_CONDITION.TEXT_3      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_CALC_SET_NAME,
         P_SEQ_NO,
         P_COMPARE_OPER );
         RETURN ret_value;
   END TEXT_3;
   FUNCTION APPROVAL_BY(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_CALC_SET_NAME IN VARCHAR2,
      P_SEQ_NO IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (30) ;
   BEGIN
      ret_value := EC_CALC_SET_CONDITION.APPROVAL_BY      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_CALC_SET_NAME,
         P_SEQ_NO,
         P_COMPARE_OPER );
         RETURN ret_value;
   END APPROVAL_BY;
   FUNCTION APPROVAL_STATE(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_CALC_SET_NAME IN VARCHAR2,
      P_SEQ_NO IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_CALC_SET_CONDITION.APPROVAL_STATE      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_CALC_SET_NAME,
         P_SEQ_NO,
         P_COMPARE_OPER );
         RETURN ret_value;
   END APPROVAL_STATE;
   FUNCTION REF_OBJECT_ID_4(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_CALC_SET_NAME IN VARCHAR2,
      P_SEQ_NO IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_CALC_SET_CONDITION.REF_OBJECT_ID_4      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_CALC_SET_NAME,
         P_SEQ_NO,
         P_COMPARE_OPER );
         RETURN ret_value;
   END REF_OBJECT_ID_4;
   FUNCTION VALUE_5(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_CALC_SET_NAME IN VARCHAR2,
      P_SEQ_NO IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CALC_SET_CONDITION.VALUE_5      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_CALC_SET_NAME,
         P_SEQ_NO,
         P_COMPARE_OPER );
         RETURN ret_value;
   END VALUE_5;
   FUNCTION NEXT_DAYTIME(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_CALC_SET_NAME IN VARCHAR2,
      P_SEQ_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CALC_SET_CONDITION.NEXT_DAYTIME      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_CALC_SET_NAME,
         P_SEQ_NO,
         P_NUM_ROWS );
         RETURN ret_value;
   END NEXT_DAYTIME;
   FUNCTION PREV_EQUAL_DAYTIME(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_CALC_SET_NAME IN VARCHAR2,
      P_SEQ_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CALC_SET_CONDITION.PREV_EQUAL_DAYTIME      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_CALC_SET_NAME,
         P_SEQ_NO,
         P_NUM_ROWS );
         RETURN ret_value;
   END PREV_EQUAL_DAYTIME;
   FUNCTION TEXT_7(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_CALC_SET_NAME IN VARCHAR2,
      P_SEQ_NO IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_CALC_SET_CONDITION.TEXT_7      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_CALC_SET_NAME,
         P_SEQ_NO,
         P_COMPARE_OPER );
         RETURN ret_value;
   END TEXT_7;
   FUNCTION TEXT_8(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_CALC_SET_NAME IN VARCHAR2,
      P_SEQ_NO IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_CALC_SET_CONDITION.TEXT_8      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_CALC_SET_NAME,
         P_SEQ_NO,
         P_COMPARE_OPER );
         RETURN ret_value;
   END TEXT_8;
   FUNCTION DATE_3(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_CALC_SET_NAME IN VARCHAR2,
      P_SEQ_NO IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CALC_SET_CONDITION.DATE_3      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_CALC_SET_NAME,
         P_SEQ_NO,
         P_COMPARE_OPER );
         RETURN ret_value;
   END DATE_3;
   FUNCTION DATE_5(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_CALC_SET_NAME IN VARCHAR2,
      P_SEQ_NO IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CALC_SET_CONDITION.DATE_5      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_CALC_SET_NAME,
         P_SEQ_NO,
         P_COMPARE_OPER );
         RETURN ret_value;
   END DATE_5;
   FUNCTION NEXT_EQUAL_DAYTIME(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_CALC_SET_NAME IN VARCHAR2,
      P_SEQ_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CALC_SET_CONDITION.NEXT_EQUAL_DAYTIME      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_CALC_SET_NAME,
         P_SEQ_NO,
         P_NUM_ROWS );
         RETURN ret_value;
   END NEXT_EQUAL_DAYTIME;
   FUNCTION REF_OBJECT_ID_2(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_CALC_SET_NAME IN VARCHAR2,
      P_SEQ_NO IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_CALC_SET_CONDITION.REF_OBJECT_ID_2      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_CALC_SET_NAME,
         P_SEQ_NO,
         P_COMPARE_OPER );
         RETURN ret_value;
   END REF_OBJECT_ID_2;
   FUNCTION REF_OBJECT_ID_3(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_CALC_SET_NAME IN VARCHAR2,
      P_SEQ_NO IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_CALC_SET_CONDITION.REF_OBJECT_ID_3      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_CALC_SET_NAME,
         P_SEQ_NO,
         P_COMPARE_OPER );
         RETURN ret_value;
   END REF_OBJECT_ID_3;
   FUNCTION TEXT_1(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_CALC_SET_NAME IN VARCHAR2,
      P_SEQ_NO IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_CALC_SET_CONDITION.TEXT_1      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_CALC_SET_NAME,
         P_SEQ_NO,
         P_COMPARE_OPER );
         RETURN ret_value;
   END TEXT_1;
   FUNCTION TEXT_6(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_CALC_SET_NAME IN VARCHAR2,
      P_SEQ_NO IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_CALC_SET_CONDITION.TEXT_6      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_CALC_SET_NAME,
         P_SEQ_NO,
         P_COMPARE_OPER );
         RETURN ret_value;
   END TEXT_6;
   FUNCTION TEXT_9(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_CALC_SET_NAME IN VARCHAR2,
      P_SEQ_NO IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_CALC_SET_CONDITION.TEXT_9      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_CALC_SET_NAME,
         P_SEQ_NO,
         P_COMPARE_OPER );
         RETURN ret_value;
   END TEXT_9;
   FUNCTION DATE_2(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_CALC_SET_NAME IN VARCHAR2,
      P_SEQ_NO IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CALC_SET_CONDITION.DATE_2      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_CALC_SET_NAME,
         P_SEQ_NO,
         P_COMPARE_OPER );
         RETURN ret_value;
   END DATE_2;
   FUNCTION PREV_DAYTIME(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_CALC_SET_NAME IN VARCHAR2,
      P_SEQ_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CALC_SET_CONDITION.PREV_DAYTIME      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_CALC_SET_NAME,
         P_SEQ_NO,
         P_NUM_ROWS );
         RETURN ret_value;
   END PREV_DAYTIME;
   FUNCTION RECORD_STATUS(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_CALC_SET_NAME IN VARCHAR2,
      P_SEQ_NO IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_CALC_SET_CONDITION.RECORD_STATUS      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_CALC_SET_NAME,
         P_SEQ_NO,
         P_COMPARE_OPER );
         RETURN ret_value;
   END RECORD_STATUS;
   FUNCTION REF_OBJECT_ID_5(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_CALC_SET_NAME IN VARCHAR2,
      P_SEQ_NO IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_CALC_SET_CONDITION.REF_OBJECT_ID_5      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_CALC_SET_NAME,
         P_SEQ_NO,
         P_COMPARE_OPER );
         RETURN ret_value;
   END REF_OBJECT_ID_5;
   FUNCTION VALUE_1(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_CALC_SET_NAME IN VARCHAR2,
      P_SEQ_NO IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CALC_SET_CONDITION.VALUE_1      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_CALC_SET_NAME,
         P_SEQ_NO,
         P_COMPARE_OPER );
         RETURN ret_value;
   END VALUE_1;
   FUNCTION APPROVAL_DATE(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_CALC_SET_NAME IN VARCHAR2,
      P_SEQ_NO IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CALC_SET_CONDITION.APPROVAL_DATE      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_CALC_SET_NAME,
         P_SEQ_NO,
         P_COMPARE_OPER );
         RETURN ret_value;
   END APPROVAL_DATE;
   FUNCTION REF_OBJECT_ID_1(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_CALC_SET_NAME IN VARCHAR2,
      P_SEQ_NO IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_CALC_SET_CONDITION.REF_OBJECT_ID_1      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_CALC_SET_NAME,
         P_SEQ_NO,
         P_COMPARE_OPER );
         RETURN ret_value;
   END REF_OBJECT_ID_1;
   FUNCTION ROW_BY_PK(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_CALC_SET_NAME IN VARCHAR2,
      P_SEQ_NO IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN REC_ROW_BY_PK
   IS
      ret_value    REC_ROW_BY_PK ;
   BEGIN
      ret_value := EC_CALC_SET_CONDITION.ROW_BY_PK      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_CALC_SET_NAME,
         P_SEQ_NO,
         P_COMPARE_OPER );
         RETURN ret_value;
   END ROW_BY_PK;
   FUNCTION ROW_BY_REL_OPERATOR(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_CALC_SET_NAME IN VARCHAR2,
      P_SEQ_NO IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN REC_ROW_BY_REL_OPERATOR
   IS
      ret_value    REC_ROW_BY_REL_OPERATOR ;
   BEGIN
      ret_value := EC_CALC_SET_CONDITION.ROW_BY_REL_OPERATOR      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_CALC_SET_NAME,
         P_SEQ_NO,
         P_COMPARE_OPER );
         RETURN ret_value;
   END ROW_BY_REL_OPERATOR;
   FUNCTION TEXT_2(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_CALC_SET_NAME IN VARCHAR2,
      P_SEQ_NO IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_CALC_SET_CONDITION.TEXT_2      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_CALC_SET_NAME,
         P_SEQ_NO,
         P_COMPARE_OPER );
         RETURN ret_value;
   END TEXT_2;
   FUNCTION TEXT_4(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_CALC_SET_NAME IN VARCHAR2,
      P_SEQ_NO IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_CALC_SET_CONDITION.TEXT_4      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_CALC_SET_NAME,
         P_SEQ_NO,
         P_COMPARE_OPER );
         RETURN ret_value;
   END TEXT_4;
   FUNCTION TEXT_5(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_CALC_SET_NAME IN VARCHAR2,
      P_SEQ_NO IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_CALC_SET_CONDITION.TEXT_5      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_CALC_SET_NAME,
         P_SEQ_NO,
         P_COMPARE_OPER );
         RETURN ret_value;
   END TEXT_5;
   FUNCTION VALUE_2(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_CALC_SET_NAME IN VARCHAR2,
      P_SEQ_NO IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CALC_SET_CONDITION.VALUE_2      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_CALC_SET_NAME,
         P_SEQ_NO,
         P_COMPARE_OPER );
         RETURN ret_value;
   END VALUE_2;
   FUNCTION VALUE_3(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_CALC_SET_NAME IN VARCHAR2,
      P_SEQ_NO IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CALC_SET_CONDITION.VALUE_3      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_CALC_SET_NAME,
         P_SEQ_NO,
         P_COMPARE_OPER );
         RETURN ret_value;
   END VALUE_3;
   FUNCTION VALUE_4(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_CALC_SET_NAME IN VARCHAR2,
      P_SEQ_NO IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CALC_SET_CONDITION.VALUE_4      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_CALC_SET_NAME,
         P_SEQ_NO,
         P_COMPARE_OPER );
         RETURN ret_value;
   END VALUE_4;
   FUNCTION DATE_4(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_CALC_SET_NAME IN VARCHAR2,
      P_SEQ_NO IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CALC_SET_CONDITION.DATE_4      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_CALC_SET_NAME,
         P_SEQ_NO,
         P_COMPARE_OPER );
         RETURN ret_value;
   END DATE_4;
   FUNCTION OP1_SQL_SYNTAX(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_CALC_SET_NAME IN VARCHAR2,
      P_SEQ_NO IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_CALC_SET_CONDITION.OP1_SQL_SYNTAX      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_CALC_SET_NAME,
         P_SEQ_NO,
         P_COMPARE_OPER );
         RETURN ret_value;
   END OP1_SQL_SYNTAX;
   FUNCTION OP2_SET_COND_VALUE(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_CALC_SET_NAME IN VARCHAR2,
      P_SEQ_NO IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_CALC_SET_CONDITION.OP2_SET_COND_VALUE      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_CALC_SET_NAME,
         P_SEQ_NO,
         P_COMPARE_OPER );
         RETURN ret_value;
   END OP2_SET_COND_VALUE;
   FUNCTION REC_ID(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_CALC_SET_NAME IN VARCHAR2,
      P_SEQ_NO IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_CALC_SET_CONDITION.REC_ID      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_CALC_SET_NAME,
         P_SEQ_NO,
         P_COMPARE_OPER );
         RETURN ret_value;
   END REC_ID;
   FUNCTION DATE_1(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_CALC_SET_NAME IN VARCHAR2,
      P_SEQ_NO IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CALC_SET_CONDITION.DATE_1      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_CALC_SET_NAME,
         P_SEQ_NO,
         P_COMPARE_OPER );
         RETURN ret_value;
   END DATE_1;
   FUNCTION OP2_SET_COND_TYPE(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_CALC_SET_NAME IN VARCHAR2,
      P_SEQ_NO IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_CALC_SET_CONDITION.OP2_SET_COND_TYPE      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_CALC_SET_NAME,
         P_SEQ_NO,
         P_COMPARE_OPER );
         RETURN ret_value;
   END OP2_SET_COND_TYPE;
   FUNCTION OPERATOR(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_CALC_SET_NAME IN VARCHAR2,
      P_SEQ_NO IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_CALC_SET_CONDITION.OPERATOR      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_CALC_SET_NAME,
         P_SEQ_NO,
         P_COMPARE_OPER );
         RETURN ret_value;
   END OPERATOR;
   FUNCTION TEXT_10(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_CALC_SET_NAME IN VARCHAR2,
      P_SEQ_NO IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_CALC_SET_CONDITION.TEXT_10      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_CALC_SET_NAME,
         P_SEQ_NO,
         P_COMPARE_OPER );
         RETURN ret_value;
   END TEXT_10;

END RP_CALC_SET_CONDITION;

/
--GRANT EXECUTE ON ECKERNEL_WST.RP_CALC_SET_CONDITION TO REPORT_ROLE_XXX;



 -- FINISH PKG_GEN_PKGS.sf_get_functions at:11/15/2018 10.57.03 AM


