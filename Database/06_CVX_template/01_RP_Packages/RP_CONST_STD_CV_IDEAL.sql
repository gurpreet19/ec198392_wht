
 -- START PKG_GEN_PKGS.sf_get_functions at:05/07/2019 10.44.41 AM


CREATE or REPLACE PACKAGE RP_CONST_STD_CV_IDEAL
IS

   FUNCTION TEXT_3(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPONENT_NO IN VARCHAR2,
      P_METHOD IN VARCHAR2,
      P_COMB_TEMP IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2;
   FUNCTION APPROVAL_BY(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPONENT_NO IN VARCHAR2,
      P_METHOD IN VARCHAR2,
      P_COMB_TEMP IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2;
   FUNCTION APPROVAL_STATE(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPONENT_NO IN VARCHAR2,
      P_METHOD IN VARCHAR2,
      P_COMB_TEMP IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2;
   FUNCTION VALUE_5(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPONENT_NO IN VARCHAR2,
      P_METHOD IN VARCHAR2,
      P_COMB_TEMP IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER;
   FUNCTION NEXT_DAYTIME(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPONENT_NO IN VARCHAR2,
      P_METHOD IN VARCHAR2,
      P_COMB_TEMP IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION PREV_EQUAL_DAYTIME(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPONENT_NO IN VARCHAR2,
      P_METHOD IN VARCHAR2,
      P_COMB_TEMP IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION SUPERIOR(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPONENT_NO IN VARCHAR2,
      P_METHOD IN VARCHAR2,
      P_COMB_TEMP IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER;
   FUNCTION TEXT_7(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPONENT_NO IN VARCHAR2,
      P_METHOD IN VARCHAR2,
      P_COMB_TEMP IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2;
   FUNCTION TEXT_8(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPONENT_NO IN VARCHAR2,
      P_METHOD IN VARCHAR2,
      P_COMB_TEMP IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2;
   FUNCTION COMMENTS(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPONENT_NO IN VARCHAR2,
      P_METHOD IN VARCHAR2,
      P_COMB_TEMP IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2;
   FUNCTION DATE_3(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPONENT_NO IN VARCHAR2,
      P_METHOD IN VARCHAR2,
      P_COMB_TEMP IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN DATE;
   FUNCTION DATE_5(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPONENT_NO IN VARCHAR2,
      P_METHOD IN VARCHAR2,
      P_COMB_TEMP IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN DATE;
   FUNCTION NEXT_EQUAL_DAYTIME(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPONENT_NO IN VARCHAR2,
      P_METHOD IN VARCHAR2,
      P_COMB_TEMP IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION TEXT_1(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPONENT_NO IN VARCHAR2,
      P_METHOD IN VARCHAR2,
      P_COMB_TEMP IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2;
   FUNCTION TEXT_6(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPONENT_NO IN VARCHAR2,
      P_METHOD IN VARCHAR2,
      P_COMB_TEMP IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2;
   FUNCTION TEXT_9(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPONENT_NO IN VARCHAR2,
      P_METHOD IN VARCHAR2,
      P_COMB_TEMP IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2;
   FUNCTION DATE_2(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPONENT_NO IN VARCHAR2,
      P_METHOD IN VARCHAR2,
      P_COMB_TEMP IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN DATE;
   FUNCTION PREV_DAYTIME(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPONENT_NO IN VARCHAR2,
      P_METHOD IN VARCHAR2,
      P_COMB_TEMP IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION RECORD_STATUS(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPONENT_NO IN VARCHAR2,
      P_METHOD IN VARCHAR2,
      P_COMB_TEMP IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2;
   FUNCTION VALUE_1(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPONENT_NO IN VARCHAR2,
      P_METHOD IN VARCHAR2,
      P_COMB_TEMP IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER;
   FUNCTION APPROVAL_DATE(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPONENT_NO IN VARCHAR2,
      P_METHOD IN VARCHAR2,
      P_COMB_TEMP IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN DATE;
   FUNCTION INFERIOR(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPONENT_NO IN VARCHAR2,
      P_METHOD IN VARCHAR2,
      P_COMB_TEMP IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER;
      TYPE REC_ROW_BY_PK IS RECORD (
         OBJECT_ID VARCHAR2 (32) ,
         DAYTIME  DATE ,
         COMPONENT_NO VARCHAR2 (240) ,
         METHOD VARCHAR2 (240) ,
         COMB_TEMP NUMBER ,
         SUPERIOR NUMBER ,
         INFERIOR NUMBER ,
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
      P_COMPONENT_NO IN VARCHAR2,
      P_METHOD IN VARCHAR2,
      P_COMB_TEMP IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN REC_ROW_BY_PK;
      TYPE REC_ROW_BY_REL_OPERATOR IS RECORD (
         OBJECT_ID VARCHAR2 (32) ,
         DAYTIME  DATE ,
         COMPONENT_NO VARCHAR2 (240) ,
         METHOD VARCHAR2 (240) ,
         COMB_TEMP NUMBER ,
         SUPERIOR NUMBER ,
         INFERIOR NUMBER ,
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
      P_COMPONENT_NO IN VARCHAR2,
      P_METHOD IN VARCHAR2,
      P_COMB_TEMP IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN REC_ROW_BY_REL_OPERATOR;
   FUNCTION TEXT_2(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPONENT_NO IN VARCHAR2,
      P_METHOD IN VARCHAR2,
      P_COMB_TEMP IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2;
   FUNCTION TEXT_4(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPONENT_NO IN VARCHAR2,
      P_METHOD IN VARCHAR2,
      P_COMB_TEMP IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2;
   FUNCTION TEXT_5(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPONENT_NO IN VARCHAR2,
      P_METHOD IN VARCHAR2,
      P_COMB_TEMP IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2;
   FUNCTION VALUE_2(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPONENT_NO IN VARCHAR2,
      P_METHOD IN VARCHAR2,
      P_COMB_TEMP IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER;
   FUNCTION VALUE_3(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPONENT_NO IN VARCHAR2,
      P_METHOD IN VARCHAR2,
      P_COMB_TEMP IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER;
   FUNCTION VALUE_4(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPONENT_NO IN VARCHAR2,
      P_METHOD IN VARCHAR2,
      P_COMB_TEMP IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER;
   FUNCTION DATE_4(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPONENT_NO IN VARCHAR2,
      P_METHOD IN VARCHAR2,
      P_COMB_TEMP IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN DATE;
   FUNCTION REC_ID(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPONENT_NO IN VARCHAR2,
      P_METHOD IN VARCHAR2,
      P_COMB_TEMP IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2;
   FUNCTION DATE_1(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPONENT_NO IN VARCHAR2,
      P_METHOD IN VARCHAR2,
      P_COMB_TEMP IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN DATE;
   FUNCTION TEXT_10(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPONENT_NO IN VARCHAR2,
      P_METHOD IN VARCHAR2,
      P_COMB_TEMP IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2;

END RP_CONST_STD_CV_IDEAL;

/



CREATE or REPLACE PACKAGE BODY RP_CONST_STD_CV_IDEAL
IS

   FUNCTION TEXT_3(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPONENT_NO IN VARCHAR2,
      P_METHOD IN VARCHAR2,
      P_COMB_TEMP IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_CONST_STD_CV_IDEAL.TEXT_3      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_COMPONENT_NO,
         P_METHOD,
         P_COMB_TEMP,
         P_COMPARE_OPER );
         RETURN ret_value;
   END TEXT_3;
   FUNCTION APPROVAL_BY(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPONENT_NO IN VARCHAR2,
      P_METHOD IN VARCHAR2,
      P_COMB_TEMP IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (30) ;
   BEGIN
      ret_value := EC_CONST_STD_CV_IDEAL.APPROVAL_BY      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_COMPONENT_NO,
         P_METHOD,
         P_COMB_TEMP,
         P_COMPARE_OPER );
         RETURN ret_value;
   END APPROVAL_BY;
   FUNCTION APPROVAL_STATE(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPONENT_NO IN VARCHAR2,
      P_METHOD IN VARCHAR2,
      P_COMB_TEMP IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_CONST_STD_CV_IDEAL.APPROVAL_STATE      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_COMPONENT_NO,
         P_METHOD,
         P_COMB_TEMP,
         P_COMPARE_OPER );
         RETURN ret_value;
   END APPROVAL_STATE;
   FUNCTION VALUE_5(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPONENT_NO IN VARCHAR2,
      P_METHOD IN VARCHAR2,
      P_COMB_TEMP IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CONST_STD_CV_IDEAL.VALUE_5      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_COMPONENT_NO,
         P_METHOD,
         P_COMB_TEMP,
         P_COMPARE_OPER );
         RETURN ret_value;
   END VALUE_5;
   FUNCTION NEXT_DAYTIME(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPONENT_NO IN VARCHAR2,
      P_METHOD IN VARCHAR2,
      P_COMB_TEMP IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CONST_STD_CV_IDEAL.NEXT_DAYTIME      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_COMPONENT_NO,
         P_METHOD,
         P_COMB_TEMP,
         P_NUM_ROWS );
         RETURN ret_value;
   END NEXT_DAYTIME;
   FUNCTION PREV_EQUAL_DAYTIME(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPONENT_NO IN VARCHAR2,
      P_METHOD IN VARCHAR2,
      P_COMB_TEMP IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CONST_STD_CV_IDEAL.PREV_EQUAL_DAYTIME      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_COMPONENT_NO,
         P_METHOD,
         P_COMB_TEMP,
         P_NUM_ROWS );
         RETURN ret_value;
   END PREV_EQUAL_DAYTIME;
   FUNCTION SUPERIOR(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPONENT_NO IN VARCHAR2,
      P_METHOD IN VARCHAR2,
      P_COMB_TEMP IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CONST_STD_CV_IDEAL.SUPERIOR      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_COMPONENT_NO,
         P_METHOD,
         P_COMB_TEMP,
         P_COMPARE_OPER );
         RETURN ret_value;
   END SUPERIOR;
   FUNCTION TEXT_7(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPONENT_NO IN VARCHAR2,
      P_METHOD IN VARCHAR2,
      P_COMB_TEMP IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_CONST_STD_CV_IDEAL.TEXT_7      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_COMPONENT_NO,
         P_METHOD,
         P_COMB_TEMP,
         P_COMPARE_OPER );
         RETURN ret_value;
   END TEXT_7;
   FUNCTION TEXT_8(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPONENT_NO IN VARCHAR2,
      P_METHOD IN VARCHAR2,
      P_COMB_TEMP IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_CONST_STD_CV_IDEAL.TEXT_8      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_COMPONENT_NO,
         P_METHOD,
         P_COMB_TEMP,
         P_COMPARE_OPER );
         RETURN ret_value;
   END TEXT_8;
   FUNCTION COMMENTS(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPONENT_NO IN VARCHAR2,
      P_METHOD IN VARCHAR2,
      P_COMB_TEMP IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_CONST_STD_CV_IDEAL.COMMENTS      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_COMPONENT_NO,
         P_METHOD,
         P_COMB_TEMP,
         P_COMPARE_OPER );
         RETURN ret_value;
   END COMMENTS;
   FUNCTION DATE_3(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPONENT_NO IN VARCHAR2,
      P_METHOD IN VARCHAR2,
      P_COMB_TEMP IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CONST_STD_CV_IDEAL.DATE_3      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_COMPONENT_NO,
         P_METHOD,
         P_COMB_TEMP,
         P_COMPARE_OPER );
         RETURN ret_value;
   END DATE_3;
   FUNCTION DATE_5(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPONENT_NO IN VARCHAR2,
      P_METHOD IN VARCHAR2,
      P_COMB_TEMP IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CONST_STD_CV_IDEAL.DATE_5      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_COMPONENT_NO,
         P_METHOD,
         P_COMB_TEMP,
         P_COMPARE_OPER );
         RETURN ret_value;
   END DATE_5;
   FUNCTION NEXT_EQUAL_DAYTIME(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPONENT_NO IN VARCHAR2,
      P_METHOD IN VARCHAR2,
      P_COMB_TEMP IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CONST_STD_CV_IDEAL.NEXT_EQUAL_DAYTIME      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_COMPONENT_NO,
         P_METHOD,
         P_COMB_TEMP,
         P_NUM_ROWS );
         RETURN ret_value;
   END NEXT_EQUAL_DAYTIME;
   FUNCTION TEXT_1(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPONENT_NO IN VARCHAR2,
      P_METHOD IN VARCHAR2,
      P_COMB_TEMP IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_CONST_STD_CV_IDEAL.TEXT_1      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_COMPONENT_NO,
         P_METHOD,
         P_COMB_TEMP,
         P_COMPARE_OPER );
         RETURN ret_value;
   END TEXT_1;
   FUNCTION TEXT_6(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPONENT_NO IN VARCHAR2,
      P_METHOD IN VARCHAR2,
      P_COMB_TEMP IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_CONST_STD_CV_IDEAL.TEXT_6      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_COMPONENT_NO,
         P_METHOD,
         P_COMB_TEMP,
         P_COMPARE_OPER );
         RETURN ret_value;
   END TEXT_6;
   FUNCTION TEXT_9(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPONENT_NO IN VARCHAR2,
      P_METHOD IN VARCHAR2,
      P_COMB_TEMP IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_CONST_STD_CV_IDEAL.TEXT_9      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_COMPONENT_NO,
         P_METHOD,
         P_COMB_TEMP,
         P_COMPARE_OPER );
         RETURN ret_value;
   END TEXT_9;
   FUNCTION DATE_2(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPONENT_NO IN VARCHAR2,
      P_METHOD IN VARCHAR2,
      P_COMB_TEMP IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CONST_STD_CV_IDEAL.DATE_2      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_COMPONENT_NO,
         P_METHOD,
         P_COMB_TEMP,
         P_COMPARE_OPER );
         RETURN ret_value;
   END DATE_2;
   FUNCTION PREV_DAYTIME(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPONENT_NO IN VARCHAR2,
      P_METHOD IN VARCHAR2,
      P_COMB_TEMP IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CONST_STD_CV_IDEAL.PREV_DAYTIME      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_COMPONENT_NO,
         P_METHOD,
         P_COMB_TEMP,
         P_NUM_ROWS );
         RETURN ret_value;
   END PREV_DAYTIME;
   FUNCTION RECORD_STATUS(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPONENT_NO IN VARCHAR2,
      P_METHOD IN VARCHAR2,
      P_COMB_TEMP IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_CONST_STD_CV_IDEAL.RECORD_STATUS      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_COMPONENT_NO,
         P_METHOD,
         P_COMB_TEMP,
         P_COMPARE_OPER );
         RETURN ret_value;
   END RECORD_STATUS;
   FUNCTION VALUE_1(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPONENT_NO IN VARCHAR2,
      P_METHOD IN VARCHAR2,
      P_COMB_TEMP IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CONST_STD_CV_IDEAL.VALUE_1      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_COMPONENT_NO,
         P_METHOD,
         P_COMB_TEMP,
         P_COMPARE_OPER );
         RETURN ret_value;
   END VALUE_1;
   FUNCTION APPROVAL_DATE(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPONENT_NO IN VARCHAR2,
      P_METHOD IN VARCHAR2,
      P_COMB_TEMP IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CONST_STD_CV_IDEAL.APPROVAL_DATE      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_COMPONENT_NO,
         P_METHOD,
         P_COMB_TEMP,
         P_COMPARE_OPER );
         RETURN ret_value;
   END APPROVAL_DATE;
   FUNCTION INFERIOR(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPONENT_NO IN VARCHAR2,
      P_METHOD IN VARCHAR2,
      P_COMB_TEMP IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CONST_STD_CV_IDEAL.INFERIOR      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_COMPONENT_NO,
         P_METHOD,
         P_COMB_TEMP,
         P_COMPARE_OPER );
         RETURN ret_value;
   END INFERIOR;
   FUNCTION ROW_BY_PK(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPONENT_NO IN VARCHAR2,
      P_METHOD IN VARCHAR2,
      P_COMB_TEMP IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN REC_ROW_BY_PK
   IS
      ret_value    REC_ROW_BY_PK ;
   BEGIN
      ret_value := EC_CONST_STD_CV_IDEAL.ROW_BY_PK      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_COMPONENT_NO,
         P_METHOD,
         P_COMB_TEMP,
         P_COMPARE_OPER );
         RETURN ret_value;
   END ROW_BY_PK;
   FUNCTION ROW_BY_REL_OPERATOR(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPONENT_NO IN VARCHAR2,
      P_METHOD IN VARCHAR2,
      P_COMB_TEMP IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN REC_ROW_BY_REL_OPERATOR
   IS
      ret_value    REC_ROW_BY_REL_OPERATOR ;
   BEGIN
      ret_value := EC_CONST_STD_CV_IDEAL.ROW_BY_REL_OPERATOR      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_COMPONENT_NO,
         P_METHOD,
         P_COMB_TEMP,
         P_COMPARE_OPER );
         RETURN ret_value;
   END ROW_BY_REL_OPERATOR;
   FUNCTION TEXT_2(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPONENT_NO IN VARCHAR2,
      P_METHOD IN VARCHAR2,
      P_COMB_TEMP IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_CONST_STD_CV_IDEAL.TEXT_2      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_COMPONENT_NO,
         P_METHOD,
         P_COMB_TEMP,
         P_COMPARE_OPER );
         RETURN ret_value;
   END TEXT_2;
   FUNCTION TEXT_4(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPONENT_NO IN VARCHAR2,
      P_METHOD IN VARCHAR2,
      P_COMB_TEMP IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_CONST_STD_CV_IDEAL.TEXT_4      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_COMPONENT_NO,
         P_METHOD,
         P_COMB_TEMP,
         P_COMPARE_OPER );
         RETURN ret_value;
   END TEXT_4;
   FUNCTION TEXT_5(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPONENT_NO IN VARCHAR2,
      P_METHOD IN VARCHAR2,
      P_COMB_TEMP IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_CONST_STD_CV_IDEAL.TEXT_5      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_COMPONENT_NO,
         P_METHOD,
         P_COMB_TEMP,
         P_COMPARE_OPER );
         RETURN ret_value;
   END TEXT_5;
   FUNCTION VALUE_2(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPONENT_NO IN VARCHAR2,
      P_METHOD IN VARCHAR2,
      P_COMB_TEMP IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CONST_STD_CV_IDEAL.VALUE_2      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_COMPONENT_NO,
         P_METHOD,
         P_COMB_TEMP,
         P_COMPARE_OPER );
         RETURN ret_value;
   END VALUE_2;
   FUNCTION VALUE_3(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPONENT_NO IN VARCHAR2,
      P_METHOD IN VARCHAR2,
      P_COMB_TEMP IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CONST_STD_CV_IDEAL.VALUE_3      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_COMPONENT_NO,
         P_METHOD,
         P_COMB_TEMP,
         P_COMPARE_OPER );
         RETURN ret_value;
   END VALUE_3;
   FUNCTION VALUE_4(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPONENT_NO IN VARCHAR2,
      P_METHOD IN VARCHAR2,
      P_COMB_TEMP IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_CONST_STD_CV_IDEAL.VALUE_4      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_COMPONENT_NO,
         P_METHOD,
         P_COMB_TEMP,
         P_COMPARE_OPER );
         RETURN ret_value;
   END VALUE_4;
   FUNCTION DATE_4(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPONENT_NO IN VARCHAR2,
      P_METHOD IN VARCHAR2,
      P_COMB_TEMP IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CONST_STD_CV_IDEAL.DATE_4      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_COMPONENT_NO,
         P_METHOD,
         P_COMB_TEMP,
         P_COMPARE_OPER );
         RETURN ret_value;
   END DATE_4;
   FUNCTION REC_ID(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPONENT_NO IN VARCHAR2,
      P_METHOD IN VARCHAR2,
      P_COMB_TEMP IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_CONST_STD_CV_IDEAL.REC_ID      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_COMPONENT_NO,
         P_METHOD,
         P_COMB_TEMP,
         P_COMPARE_OPER );
         RETURN ret_value;
   END REC_ID;
   FUNCTION DATE_1(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPONENT_NO IN VARCHAR2,
      P_METHOD IN VARCHAR2,
      P_COMB_TEMP IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_CONST_STD_CV_IDEAL.DATE_1      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_COMPONENT_NO,
         P_METHOD,
         P_COMB_TEMP,
         P_COMPARE_OPER );
         RETURN ret_value;
   END DATE_1;
   FUNCTION TEXT_10(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPONENT_NO IN VARCHAR2,
      P_METHOD IN VARCHAR2,
      P_COMB_TEMP IN NUMBER,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_CONST_STD_CV_IDEAL.TEXT_10      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_COMPONENT_NO,
         P_METHOD,
         P_COMB_TEMP,
         P_COMPARE_OPER );
         RETURN ret_value;
   END TEXT_10;

END RP_CONST_STD_CV_IDEAL;

/
--GRANT EXECUTE ON ECKERNEL_WST.RP_CONST_STD_CV_IDEAL TO REPORT_ROLE_XXX;



 -- FINISH PKG_GEN_PKGS.sf_get_functions at:05/07/2019 10.44.49 AM


