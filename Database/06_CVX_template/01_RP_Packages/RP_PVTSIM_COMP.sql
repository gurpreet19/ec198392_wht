
 -- START PKG_GEN_PKGS.sf_get_functions at:11/15/2018 08.16.50 AM


CREATE or REPLACE PACKAGE RP_PVTSIM_COMP
IS

   FUNCTION COMPNO_08(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_RESULT_NO IN VARCHAR2,
      P_CODE IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER;
   FUNCTION COMPNO_14(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_RESULT_NO IN VARCHAR2,
      P_CODE IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER;
   FUNCTION APPROVAL_BY(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_RESULT_NO IN VARCHAR2,
      P_CODE IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2;
   FUNCTION APPROVAL_STATE(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_RESULT_NO IN VARCHAR2,
      P_CODE IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2;
   FUNCTION COMPNO_09(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_RESULT_NO IN VARCHAR2,
      P_CODE IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER;
   FUNCTION COMPNO_17(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_RESULT_NO IN VARCHAR2,
      P_CODE IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER;
   FUNCTION COMPNO_20(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_RESULT_NO IN VARCHAR2,
      P_CODE IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER;
   FUNCTION COMPNO_03(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_RESULT_NO IN VARCHAR2,
      P_CODE IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER;
   FUNCTION COMPNO_10(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_RESULT_NO IN VARCHAR2,
      P_CODE IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER;
   FUNCTION COMPNO_13(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_RESULT_NO IN VARCHAR2,
      P_CODE IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER;
   FUNCTION COMPNO_16(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_RESULT_NO IN VARCHAR2,
      P_CODE IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER;
   FUNCTION NEXT_DAYTIME(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_RESULT_NO IN VARCHAR2,
      P_CODE IN VARCHAR2,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION PREV_EQUAL_DAYTIME(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_RESULT_NO IN VARCHAR2,
      P_CODE IN VARCHAR2,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION COMPNO_02(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_RESULT_NO IN VARCHAR2,
      P_CODE IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER;
   FUNCTION COMPNO_19(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_RESULT_NO IN VARCHAR2,
      P_CODE IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER;
   FUNCTION COMPNO_22(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_RESULT_NO IN VARCHAR2,
      P_CODE IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER;
   FUNCTION NEXT_EQUAL_DAYTIME(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_RESULT_NO IN VARCHAR2,
      P_CODE IN VARCHAR2,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION COMPNO_06(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_RESULT_NO IN VARCHAR2,
      P_CODE IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER;
   FUNCTION COMPNO_12(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_RESULT_NO IN VARCHAR2,
      P_CODE IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER;
   FUNCTION PREV_DAYTIME(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_RESULT_NO IN VARCHAR2,
      P_CODE IN VARCHAR2,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION RECORD_STATUS(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_RESULT_NO IN VARCHAR2,
      P_CODE IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2;
   FUNCTION APPROVAL_DATE(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_RESULT_NO IN VARCHAR2,
      P_CODE IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN DATE;
   FUNCTION COMPNO_01(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_RESULT_NO IN VARCHAR2,
      P_CODE IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER;
   FUNCTION COMPNO_18(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_RESULT_NO IN VARCHAR2,
      P_CODE IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER;
      TYPE REC_ROW_BY_PK IS RECORD (
         OBJECT_ID VARCHAR2 (32) ,
         DAYTIME  DATE ,
         RESULT_NO VARCHAR2 (32) ,
         CODE VARCHAR2 (250) ,
         COMPNO_01 NUMBER ,
         COMPNO_02 NUMBER ,
         COMPNO_03 NUMBER ,
         COMPNO_04 NUMBER ,
         COMPNO_05 NUMBER ,
         COMPNO_06 NUMBER ,
         COMPNO_07 NUMBER ,
         COMPNO_08 NUMBER ,
         COMPNO_09 NUMBER ,
         COMPNO_10 NUMBER ,
         COMPNO_11 NUMBER ,
         COMPNO_12 NUMBER ,
         COMPNO_13 NUMBER ,
         COMPNO_14 NUMBER ,
         COMPNO_15 NUMBER ,
         COMPNO_16 NUMBER ,
         COMPNO_17 NUMBER ,
         COMPNO_18 NUMBER ,
         COMPNO_19 NUMBER ,
         COMPNO_20 NUMBER ,
         COMPNO_21 NUMBER ,
         COMPNO_22 NUMBER ,
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
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_RESULT_NO IN VARCHAR2,
      P_CODE IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN REC_ROW_BY_PK;
      TYPE REC_ROW_BY_REL_OPERATOR IS RECORD (
         OBJECT_ID VARCHAR2 (32) ,
         DAYTIME  DATE ,
         RESULT_NO VARCHAR2 (32) ,
         CODE VARCHAR2 (250) ,
         COMPNO_01 NUMBER ,
         COMPNO_02 NUMBER ,
         COMPNO_03 NUMBER ,
         COMPNO_04 NUMBER ,
         COMPNO_05 NUMBER ,
         COMPNO_06 NUMBER ,
         COMPNO_07 NUMBER ,
         COMPNO_08 NUMBER ,
         COMPNO_09 NUMBER ,
         COMPNO_10 NUMBER ,
         COMPNO_11 NUMBER ,
         COMPNO_12 NUMBER ,
         COMPNO_13 NUMBER ,
         COMPNO_14 NUMBER ,
         COMPNO_15 NUMBER ,
         COMPNO_16 NUMBER ,
         COMPNO_17 NUMBER ,
         COMPNO_18 NUMBER ,
         COMPNO_19 NUMBER ,
         COMPNO_20 NUMBER ,
         COMPNO_21 NUMBER ,
         COMPNO_22 NUMBER ,
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
   FUNCTION ROW_BY_REL_OPERATOR(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_RESULT_NO IN VARCHAR2,
      P_CODE IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN REC_ROW_BY_REL_OPERATOR;
   FUNCTION COMPNO_05(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_RESULT_NO IN VARCHAR2,
      P_CODE IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER;
   FUNCTION COMPNO_07(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_RESULT_NO IN VARCHAR2,
      P_CODE IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER;
   FUNCTION COMPNO_21(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_RESULT_NO IN VARCHAR2,
      P_CODE IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER;
   FUNCTION REC_ID(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_RESULT_NO IN VARCHAR2,
      P_CODE IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2;
   FUNCTION COMPNO_04(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_RESULT_NO IN VARCHAR2,
      P_CODE IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER;
   FUNCTION COMPNO_11(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_RESULT_NO IN VARCHAR2,
      P_CODE IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER;
   FUNCTION COMPNO_15(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_RESULT_NO IN VARCHAR2,
      P_CODE IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER;

END RP_PVTSIM_COMP;

/



CREATE or REPLACE PACKAGE BODY RP_PVTSIM_COMP
IS

   FUNCTION COMPNO_08(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_RESULT_NO IN VARCHAR2,
      P_CODE IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_PVTSIM_COMP.COMPNO_08      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_RESULT_NO,
         P_CODE,
         P_COMPARE_OPER );
         RETURN ret_value;
   END COMPNO_08;
   FUNCTION COMPNO_14(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_RESULT_NO IN VARCHAR2,
      P_CODE IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_PVTSIM_COMP.COMPNO_14      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_RESULT_NO,
         P_CODE,
         P_COMPARE_OPER );
         RETURN ret_value;
   END COMPNO_14;
   FUNCTION APPROVAL_BY(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_RESULT_NO IN VARCHAR2,
      P_CODE IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (30) ;
   BEGIN
      ret_value := EC_PVTSIM_COMP.APPROVAL_BY      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_RESULT_NO,
         P_CODE,
         P_COMPARE_OPER );
         RETURN ret_value;
   END APPROVAL_BY;
   FUNCTION APPROVAL_STATE(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_RESULT_NO IN VARCHAR2,
      P_CODE IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_PVTSIM_COMP.APPROVAL_STATE      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_RESULT_NO,
         P_CODE,
         P_COMPARE_OPER );
         RETURN ret_value;
   END APPROVAL_STATE;
   FUNCTION COMPNO_09(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_RESULT_NO IN VARCHAR2,
      P_CODE IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_PVTSIM_COMP.COMPNO_09      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_RESULT_NO,
         P_CODE,
         P_COMPARE_OPER );
         RETURN ret_value;
   END COMPNO_09;
   FUNCTION COMPNO_17(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_RESULT_NO IN VARCHAR2,
      P_CODE IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_PVTSIM_COMP.COMPNO_17      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_RESULT_NO,
         P_CODE,
         P_COMPARE_OPER );
         RETURN ret_value;
   END COMPNO_17;
   FUNCTION COMPNO_20(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_RESULT_NO IN VARCHAR2,
      P_CODE IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_PVTSIM_COMP.COMPNO_20      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_RESULT_NO,
         P_CODE,
         P_COMPARE_OPER );
         RETURN ret_value;
   END COMPNO_20;
   FUNCTION COMPNO_03(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_RESULT_NO IN VARCHAR2,
      P_CODE IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_PVTSIM_COMP.COMPNO_03      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_RESULT_NO,
         P_CODE,
         P_COMPARE_OPER );
         RETURN ret_value;
   END COMPNO_03;
   FUNCTION COMPNO_10(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_RESULT_NO IN VARCHAR2,
      P_CODE IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_PVTSIM_COMP.COMPNO_10      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_RESULT_NO,
         P_CODE,
         P_COMPARE_OPER );
         RETURN ret_value;
   END COMPNO_10;
   FUNCTION COMPNO_13(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_RESULT_NO IN VARCHAR2,
      P_CODE IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_PVTSIM_COMP.COMPNO_13      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_RESULT_NO,
         P_CODE,
         P_COMPARE_OPER );
         RETURN ret_value;
   END COMPNO_13;
   FUNCTION COMPNO_16(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_RESULT_NO IN VARCHAR2,
      P_CODE IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_PVTSIM_COMP.COMPNO_16      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_RESULT_NO,
         P_CODE,
         P_COMPARE_OPER );
         RETURN ret_value;
   END COMPNO_16;
   FUNCTION NEXT_DAYTIME(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_RESULT_NO IN VARCHAR2,
      P_CODE IN VARCHAR2,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_PVTSIM_COMP.NEXT_DAYTIME      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_RESULT_NO,
         P_CODE,
         P_NUM_ROWS );
         RETURN ret_value;
   END NEXT_DAYTIME;
   FUNCTION PREV_EQUAL_DAYTIME(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_RESULT_NO IN VARCHAR2,
      P_CODE IN VARCHAR2,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_PVTSIM_COMP.PREV_EQUAL_DAYTIME      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_RESULT_NO,
         P_CODE,
         P_NUM_ROWS );
         RETURN ret_value;
   END PREV_EQUAL_DAYTIME;
   FUNCTION COMPNO_02(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_RESULT_NO IN VARCHAR2,
      P_CODE IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_PVTSIM_COMP.COMPNO_02      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_RESULT_NO,
         P_CODE,
         P_COMPARE_OPER );
         RETURN ret_value;
   END COMPNO_02;
   FUNCTION COMPNO_19(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_RESULT_NO IN VARCHAR2,
      P_CODE IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_PVTSIM_COMP.COMPNO_19      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_RESULT_NO,
         P_CODE,
         P_COMPARE_OPER );
         RETURN ret_value;
   END COMPNO_19;
   FUNCTION COMPNO_22(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_RESULT_NO IN VARCHAR2,
      P_CODE IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_PVTSIM_COMP.COMPNO_22      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_RESULT_NO,
         P_CODE,
         P_COMPARE_OPER );
         RETURN ret_value;
   END COMPNO_22;
   FUNCTION NEXT_EQUAL_DAYTIME(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_RESULT_NO IN VARCHAR2,
      P_CODE IN VARCHAR2,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_PVTSIM_COMP.NEXT_EQUAL_DAYTIME      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_RESULT_NO,
         P_CODE,
         P_NUM_ROWS );
         RETURN ret_value;
   END NEXT_EQUAL_DAYTIME;
   FUNCTION COMPNO_06(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_RESULT_NO IN VARCHAR2,
      P_CODE IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_PVTSIM_COMP.COMPNO_06      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_RESULT_NO,
         P_CODE,
         P_COMPARE_OPER );
         RETURN ret_value;
   END COMPNO_06;
   FUNCTION COMPNO_12(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_RESULT_NO IN VARCHAR2,
      P_CODE IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_PVTSIM_COMP.COMPNO_12      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_RESULT_NO,
         P_CODE,
         P_COMPARE_OPER );
         RETURN ret_value;
   END COMPNO_12;
   FUNCTION PREV_DAYTIME(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_RESULT_NO IN VARCHAR2,
      P_CODE IN VARCHAR2,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_PVTSIM_COMP.PREV_DAYTIME      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_RESULT_NO,
         P_CODE,
         P_NUM_ROWS );
         RETURN ret_value;
   END PREV_DAYTIME;
   FUNCTION RECORD_STATUS(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_RESULT_NO IN VARCHAR2,
      P_CODE IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_PVTSIM_COMP.RECORD_STATUS      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_RESULT_NO,
         P_CODE,
         P_COMPARE_OPER );
         RETURN ret_value;
   END RECORD_STATUS;
   FUNCTION APPROVAL_DATE(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_RESULT_NO IN VARCHAR2,
      P_CODE IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_PVTSIM_COMP.APPROVAL_DATE      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_RESULT_NO,
         P_CODE,
         P_COMPARE_OPER );
         RETURN ret_value;
   END APPROVAL_DATE;
   FUNCTION COMPNO_01(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_RESULT_NO IN VARCHAR2,
      P_CODE IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_PVTSIM_COMP.COMPNO_01      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_RESULT_NO,
         P_CODE,
         P_COMPARE_OPER );
         RETURN ret_value;
   END COMPNO_01;
   FUNCTION COMPNO_18(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_RESULT_NO IN VARCHAR2,
      P_CODE IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_PVTSIM_COMP.COMPNO_18      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_RESULT_NO,
         P_CODE,
         P_COMPARE_OPER );
         RETURN ret_value;
   END COMPNO_18;
   FUNCTION ROW_BY_PK(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_RESULT_NO IN VARCHAR2,
      P_CODE IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN REC_ROW_BY_PK
   IS
      ret_value    REC_ROW_BY_PK ;
   BEGIN
      ret_value := EC_PVTSIM_COMP.ROW_BY_PK      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_RESULT_NO,
         P_CODE,
         P_COMPARE_OPER );
         RETURN ret_value;
   END ROW_BY_PK;
   FUNCTION ROW_BY_REL_OPERATOR(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_RESULT_NO IN VARCHAR2,
      P_CODE IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN REC_ROW_BY_REL_OPERATOR
   IS
      ret_value    REC_ROW_BY_REL_OPERATOR ;
   BEGIN
      ret_value := EC_PVTSIM_COMP.ROW_BY_REL_OPERATOR      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_RESULT_NO,
         P_CODE,
         P_COMPARE_OPER );
         RETURN ret_value;
   END ROW_BY_REL_OPERATOR;
   FUNCTION COMPNO_05(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_RESULT_NO IN VARCHAR2,
      P_CODE IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_PVTSIM_COMP.COMPNO_05      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_RESULT_NO,
         P_CODE,
         P_COMPARE_OPER );
         RETURN ret_value;
   END COMPNO_05;
   FUNCTION COMPNO_07(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_RESULT_NO IN VARCHAR2,
      P_CODE IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_PVTSIM_COMP.COMPNO_07      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_RESULT_NO,
         P_CODE,
         P_COMPARE_OPER );
         RETURN ret_value;
   END COMPNO_07;
   FUNCTION COMPNO_21(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_RESULT_NO IN VARCHAR2,
      P_CODE IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_PVTSIM_COMP.COMPNO_21      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_RESULT_NO,
         P_CODE,
         P_COMPARE_OPER );
         RETURN ret_value;
   END COMPNO_21;
   FUNCTION REC_ID(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_RESULT_NO IN VARCHAR2,
      P_CODE IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_PVTSIM_COMP.REC_ID      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_RESULT_NO,
         P_CODE,
         P_COMPARE_OPER );
         RETURN ret_value;
   END REC_ID;
   FUNCTION COMPNO_04(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_RESULT_NO IN VARCHAR2,
      P_CODE IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_PVTSIM_COMP.COMPNO_04      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_RESULT_NO,
         P_CODE,
         P_COMPARE_OPER );
         RETURN ret_value;
   END COMPNO_04;
   FUNCTION COMPNO_11(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_RESULT_NO IN VARCHAR2,
      P_CODE IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_PVTSIM_COMP.COMPNO_11      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_RESULT_NO,
         P_CODE,
         P_COMPARE_OPER );
         RETURN ret_value;
   END COMPNO_11;
   FUNCTION COMPNO_15(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_RESULT_NO IN VARCHAR2,
      P_CODE IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_PVTSIM_COMP.COMPNO_15      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_RESULT_NO,
         P_CODE,
         P_COMPARE_OPER );
         RETURN ret_value;
   END COMPNO_15;

END RP_PVTSIM_COMP;

/
--GRANT EXECUTE ON ECKERNEL_WST.RP_PVTSIM_COMP TO REPORT_ROLE_XXX;



 -- FINISH PKG_GEN_PKGS.sf_get_functions at:11/15/2018 08.16.57 AM

