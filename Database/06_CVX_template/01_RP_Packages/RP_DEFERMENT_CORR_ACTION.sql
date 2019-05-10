
 -- START PKG_GEN_PKGS.sf_get_functions at:05/07/2019 10.27.17 AM


CREATE or REPLACE PACKAGE RP_DEFERMENT_CORR_ACTION
IS

   FUNCTION TEXT_3(
      P_EVENT_NO IN NUMBER,
      P_ACTION IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2;
   FUNCTION TEXT_4(
      P_EVENT_NO IN NUMBER,
      P_ACTION IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2;
   FUNCTION TEXT_7(
      P_EVENT_NO IN NUMBER,
      P_ACTION IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2;
   FUNCTION APPROVAL_BY(
      P_EVENT_NO IN NUMBER,
      P_ACTION IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2;
   FUNCTION APPROVAL_STATE(
      P_EVENT_NO IN NUMBER,
      P_ACTION IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2;
   FUNCTION UTC_END_DATE(
      P_EVENT_NO IN NUMBER,
      P_ACTION IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN DATE;
   FUNCTION VALUE_5(
      P_EVENT_NO IN NUMBER,
      P_ACTION IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER;
   FUNCTION NEXT_DAYTIME(
      P_EVENT_NO IN NUMBER,
      P_ACTION IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION PREV_EQUAL_DAYTIME(
      P_EVENT_NO IN NUMBER,
      P_ACTION IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION TEXT_10(
      P_EVENT_NO IN NUMBER,
      P_ACTION IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2;
   FUNCTION TEXT_5(
      P_EVENT_NO IN NUMBER,
      P_ACTION IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2;
   FUNCTION TEXT_6(
      P_EVENT_NO IN NUMBER,
      P_ACTION IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2;
   FUNCTION COMMENTS(
      P_EVENT_NO IN NUMBER,
      P_ACTION IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2;
   FUNCTION DATE_3(
      P_EVENT_NO IN NUMBER,
      P_ACTION IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN DATE;
   FUNCTION DATE_5(
      P_EVENT_NO IN NUMBER,
      P_ACTION IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN DATE;
   FUNCTION NEXT_EQUAL_DAYTIME(
      P_EVENT_NO IN NUMBER,
      P_ACTION IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION TEXT_14(
      P_EVENT_NO IN NUMBER,
      P_ACTION IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2;
   FUNCTION UTC_DAYTIME(
      P_EVENT_NO IN NUMBER,
      P_ACTION IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN DATE;
   FUNCTION VALUE_6(
      P_EVENT_NO IN NUMBER,
      P_ACTION IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER;
   FUNCTION DATE_2(
      P_EVENT_NO IN NUMBER,
      P_ACTION IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN DATE;
   FUNCTION END_DATE(
      P_EVENT_NO IN NUMBER,
      P_ACTION IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN DATE;
   FUNCTION PREV_DAYTIME(
      P_EVENT_NO IN NUMBER,
      P_ACTION IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION RECORD_STATUS(
      P_EVENT_NO IN NUMBER,
      P_ACTION IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2;
   FUNCTION VALUE_1(
      P_EVENT_NO IN NUMBER,
      P_ACTION IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER;
   FUNCTION APPROVAL_DATE(
      P_EVENT_NO IN NUMBER,
      P_ACTION IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN DATE;
      TYPE REC_ROW_BY_PK IS RECORD (
         EVENT_NO NUMBER ,
         ACTION VARCHAR2 (32) ,
         DAYTIME  DATE ,
         END_DATE  DATE ,
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
         TEXT_5 VARCHAR2 (2000) ,
         TEXT_6 VARCHAR2 (2000) ,
         TEXT_7 VARCHAR2 (2000) ,
         TEXT_9 VARCHAR2 (2000) ,
         TEXT_8 VARCHAR2 (2000) ,
         TEXT_10 VARCHAR2 (2000) ,
         TEXT_11 VARCHAR2 (2000) ,
         TEXT_12 VARCHAR2 (2000) ,
         TEXT_13 VARCHAR2 (2000) ,
         TEXT_14 VARCHAR2 (2000) ,
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
         END_DAY  DATE ,
         PRODUCTION_DAY  DATE ,
         UTC_DAYTIME  DATE ,
         UTC_END_DATE  DATE  );
   FUNCTION ROW_BY_PK(
      P_EVENT_NO IN NUMBER,
      P_ACTION IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN REC_ROW_BY_PK;
      TYPE REC_ROW_BY_REL_OPERATOR IS RECORD (
         EVENT_NO NUMBER ,
         ACTION VARCHAR2 (32) ,
         DAYTIME  DATE ,
         END_DATE  DATE ,
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
         TEXT_5 VARCHAR2 (2000) ,
         TEXT_6 VARCHAR2 (2000) ,
         TEXT_7 VARCHAR2 (2000) ,
         TEXT_9 VARCHAR2 (2000) ,
         TEXT_8 VARCHAR2 (2000) ,
         TEXT_10 VARCHAR2 (2000) ,
         TEXT_11 VARCHAR2 (2000) ,
         TEXT_12 VARCHAR2 (2000) ,
         TEXT_13 VARCHAR2 (2000) ,
         TEXT_14 VARCHAR2 (2000) ,
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
         END_DAY  DATE ,
         PRODUCTION_DAY  DATE ,
         UTC_DAYTIME  DATE ,
         UTC_END_DATE  DATE  );
   FUNCTION ROW_BY_REL_OPERATOR(
      P_EVENT_NO IN NUMBER,
      P_ACTION IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN REC_ROW_BY_REL_OPERATOR;
   FUNCTION TEXT_13(
      P_EVENT_NO IN NUMBER,
      P_ACTION IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2;
   FUNCTION TEXT_9(
      P_EVENT_NO IN NUMBER,
      P_ACTION IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2;
   FUNCTION VALUE_2(
      P_EVENT_NO IN NUMBER,
      P_ACTION IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER;
   FUNCTION VALUE_3(
      P_EVENT_NO IN NUMBER,
      P_ACTION IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER;
   FUNCTION VALUE_4(
      P_EVENT_NO IN NUMBER,
      P_ACTION IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER;
   FUNCTION DATE_4(
      P_EVENT_NO IN NUMBER,
      P_ACTION IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN DATE;
   FUNCTION REC_ID(
      P_EVENT_NO IN NUMBER,
      P_ACTION IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2;
   FUNCTION TEXT_1(
      P_EVENT_NO IN NUMBER,
      P_ACTION IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2;
   FUNCTION TEXT_2(
      P_EVENT_NO IN NUMBER,
      P_ACTION IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2;
   FUNCTION VALUE_7(
      P_EVENT_NO IN NUMBER,
      P_ACTION IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER;
   FUNCTION VALUE_9(
      P_EVENT_NO IN NUMBER,
      P_ACTION IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER;
   FUNCTION DATE_1(
      P_EVENT_NO IN NUMBER,
      P_ACTION IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN DATE;
   FUNCTION END_DAY(
      P_EVENT_NO IN NUMBER,
      P_ACTION IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN DATE;
   FUNCTION PRODUCTION_DAY(
      P_EVENT_NO IN NUMBER,
      P_ACTION IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN DATE;
   FUNCTION TEXT_11(
      P_EVENT_NO IN NUMBER,
      P_ACTION IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2;
   FUNCTION TEXT_12(
      P_EVENT_NO IN NUMBER,
      P_ACTION IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2;
   FUNCTION TEXT_8(
      P_EVENT_NO IN NUMBER,
      P_ACTION IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2;
   FUNCTION VALUE_10(
      P_EVENT_NO IN NUMBER,
      P_ACTION IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER;
   FUNCTION VALUE_8(
      P_EVENT_NO IN NUMBER,
      P_ACTION IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER;

END RP_DEFERMENT_CORR_ACTION;

/



CREATE or REPLACE PACKAGE BODY RP_DEFERMENT_CORR_ACTION
IS

   FUNCTION TEXT_3(
      P_EVENT_NO IN NUMBER,
      P_ACTION IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_DEFERMENT_CORR_ACTION.TEXT_3      (
         P_EVENT_NO,
         P_ACTION,
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END TEXT_3;
   FUNCTION TEXT_4(
      P_EVENT_NO IN NUMBER,
      P_ACTION IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_DEFERMENT_CORR_ACTION.TEXT_4      (
         P_EVENT_NO,
         P_ACTION,
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END TEXT_4;
   FUNCTION TEXT_7(
      P_EVENT_NO IN NUMBER,
      P_ACTION IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_DEFERMENT_CORR_ACTION.TEXT_7      (
         P_EVENT_NO,
         P_ACTION,
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END TEXT_7;
   FUNCTION APPROVAL_BY(
      P_EVENT_NO IN NUMBER,
      P_ACTION IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (30) ;
   BEGIN
      ret_value := EC_DEFERMENT_CORR_ACTION.APPROVAL_BY      (
         P_EVENT_NO,
         P_ACTION,
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END APPROVAL_BY;
   FUNCTION APPROVAL_STATE(
      P_EVENT_NO IN NUMBER,
      P_ACTION IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_DEFERMENT_CORR_ACTION.APPROVAL_STATE      (
         P_EVENT_NO,
         P_ACTION,
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END APPROVAL_STATE;
   FUNCTION UTC_END_DATE(
      P_EVENT_NO IN NUMBER,
      P_ACTION IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_DEFERMENT_CORR_ACTION.UTC_END_DATE      (
         P_EVENT_NO,
         P_ACTION,
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END UTC_END_DATE;
   FUNCTION VALUE_5(
      P_EVENT_NO IN NUMBER,
      P_ACTION IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_DEFERMENT_CORR_ACTION.VALUE_5      (
         P_EVENT_NO,
         P_ACTION,
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END VALUE_5;
   FUNCTION NEXT_DAYTIME(
      P_EVENT_NO IN NUMBER,
      P_ACTION IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_DEFERMENT_CORR_ACTION.NEXT_DAYTIME      (
         P_EVENT_NO,
         P_ACTION,
         P_DAYTIME,
         P_NUM_ROWS );
         RETURN ret_value;
   END NEXT_DAYTIME;
   FUNCTION PREV_EQUAL_DAYTIME(
      P_EVENT_NO IN NUMBER,
      P_ACTION IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_DEFERMENT_CORR_ACTION.PREV_EQUAL_DAYTIME      (
         P_EVENT_NO,
         P_ACTION,
         P_DAYTIME,
         P_NUM_ROWS );
         RETURN ret_value;
   END PREV_EQUAL_DAYTIME;
   FUNCTION TEXT_10(
      P_EVENT_NO IN NUMBER,
      P_ACTION IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_DEFERMENT_CORR_ACTION.TEXT_10      (
         P_EVENT_NO,
         P_ACTION,
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END TEXT_10;
   FUNCTION TEXT_5(
      P_EVENT_NO IN NUMBER,
      P_ACTION IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_DEFERMENT_CORR_ACTION.TEXT_5      (
         P_EVENT_NO,
         P_ACTION,
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END TEXT_5;
   FUNCTION TEXT_6(
      P_EVENT_NO IN NUMBER,
      P_ACTION IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_DEFERMENT_CORR_ACTION.TEXT_6      (
         P_EVENT_NO,
         P_ACTION,
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END TEXT_6;
   FUNCTION COMMENTS(
      P_EVENT_NO IN NUMBER,
      P_ACTION IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_DEFERMENT_CORR_ACTION.COMMENTS      (
         P_EVENT_NO,
         P_ACTION,
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END COMMENTS;
   FUNCTION DATE_3(
      P_EVENT_NO IN NUMBER,
      P_ACTION IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_DEFERMENT_CORR_ACTION.DATE_3      (
         P_EVENT_NO,
         P_ACTION,
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END DATE_3;
   FUNCTION DATE_5(
      P_EVENT_NO IN NUMBER,
      P_ACTION IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_DEFERMENT_CORR_ACTION.DATE_5      (
         P_EVENT_NO,
         P_ACTION,
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END DATE_5;
   FUNCTION NEXT_EQUAL_DAYTIME(
      P_EVENT_NO IN NUMBER,
      P_ACTION IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_DEFERMENT_CORR_ACTION.NEXT_EQUAL_DAYTIME      (
         P_EVENT_NO,
         P_ACTION,
         P_DAYTIME,
         P_NUM_ROWS );
         RETURN ret_value;
   END NEXT_EQUAL_DAYTIME;
   FUNCTION TEXT_14(
      P_EVENT_NO IN NUMBER,
      P_ACTION IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_DEFERMENT_CORR_ACTION.TEXT_14      (
         P_EVENT_NO,
         P_ACTION,
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END TEXT_14;
   FUNCTION UTC_DAYTIME(
      P_EVENT_NO IN NUMBER,
      P_ACTION IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_DEFERMENT_CORR_ACTION.UTC_DAYTIME      (
         P_EVENT_NO,
         P_ACTION,
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END UTC_DAYTIME;
   FUNCTION VALUE_6(
      P_EVENT_NO IN NUMBER,
      P_ACTION IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_DEFERMENT_CORR_ACTION.VALUE_6      (
         P_EVENT_NO,
         P_ACTION,
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END VALUE_6;
   FUNCTION DATE_2(
      P_EVENT_NO IN NUMBER,
      P_ACTION IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_DEFERMENT_CORR_ACTION.DATE_2      (
         P_EVENT_NO,
         P_ACTION,
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END DATE_2;
   FUNCTION END_DATE(
      P_EVENT_NO IN NUMBER,
      P_ACTION IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_DEFERMENT_CORR_ACTION.END_DATE      (
         P_EVENT_NO,
         P_ACTION,
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END END_DATE;
   FUNCTION PREV_DAYTIME(
      P_EVENT_NO IN NUMBER,
      P_ACTION IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_DEFERMENT_CORR_ACTION.PREV_DAYTIME      (
         P_EVENT_NO,
         P_ACTION,
         P_DAYTIME,
         P_NUM_ROWS );
         RETURN ret_value;
   END PREV_DAYTIME;
   FUNCTION RECORD_STATUS(
      P_EVENT_NO IN NUMBER,
      P_ACTION IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_DEFERMENT_CORR_ACTION.RECORD_STATUS      (
         P_EVENT_NO,
         P_ACTION,
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END RECORD_STATUS;
   FUNCTION VALUE_1(
      P_EVENT_NO IN NUMBER,
      P_ACTION IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_DEFERMENT_CORR_ACTION.VALUE_1      (
         P_EVENT_NO,
         P_ACTION,
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END VALUE_1;
   FUNCTION APPROVAL_DATE(
      P_EVENT_NO IN NUMBER,
      P_ACTION IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_DEFERMENT_CORR_ACTION.APPROVAL_DATE      (
         P_EVENT_NO,
         P_ACTION,
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END APPROVAL_DATE;
   FUNCTION ROW_BY_PK(
      P_EVENT_NO IN NUMBER,
      P_ACTION IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN REC_ROW_BY_PK
   IS
      ret_value    REC_ROW_BY_PK ;
   BEGIN
      ret_value := EC_DEFERMENT_CORR_ACTION.ROW_BY_PK      (
         P_EVENT_NO,
         P_ACTION,
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END ROW_BY_PK;
   FUNCTION ROW_BY_REL_OPERATOR(
      P_EVENT_NO IN NUMBER,
      P_ACTION IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN REC_ROW_BY_REL_OPERATOR
   IS
      ret_value    REC_ROW_BY_REL_OPERATOR ;
   BEGIN
      ret_value := EC_DEFERMENT_CORR_ACTION.ROW_BY_REL_OPERATOR      (
         P_EVENT_NO,
         P_ACTION,
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END ROW_BY_REL_OPERATOR;
   FUNCTION TEXT_13(
      P_EVENT_NO IN NUMBER,
      P_ACTION IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_DEFERMENT_CORR_ACTION.TEXT_13      (
         P_EVENT_NO,
         P_ACTION,
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END TEXT_13;
   FUNCTION TEXT_9(
      P_EVENT_NO IN NUMBER,
      P_ACTION IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_DEFERMENT_CORR_ACTION.TEXT_9      (
         P_EVENT_NO,
         P_ACTION,
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END TEXT_9;
   FUNCTION VALUE_2(
      P_EVENT_NO IN NUMBER,
      P_ACTION IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_DEFERMENT_CORR_ACTION.VALUE_2      (
         P_EVENT_NO,
         P_ACTION,
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END VALUE_2;
   FUNCTION VALUE_3(
      P_EVENT_NO IN NUMBER,
      P_ACTION IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_DEFERMENT_CORR_ACTION.VALUE_3      (
         P_EVENT_NO,
         P_ACTION,
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END VALUE_3;
   FUNCTION VALUE_4(
      P_EVENT_NO IN NUMBER,
      P_ACTION IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_DEFERMENT_CORR_ACTION.VALUE_4      (
         P_EVENT_NO,
         P_ACTION,
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END VALUE_4;
   FUNCTION DATE_4(
      P_EVENT_NO IN NUMBER,
      P_ACTION IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_DEFERMENT_CORR_ACTION.DATE_4      (
         P_EVENT_NO,
         P_ACTION,
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END DATE_4;
   FUNCTION REC_ID(
      P_EVENT_NO IN NUMBER,
      P_ACTION IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_DEFERMENT_CORR_ACTION.REC_ID      (
         P_EVENT_NO,
         P_ACTION,
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END REC_ID;
   FUNCTION TEXT_1(
      P_EVENT_NO IN NUMBER,
      P_ACTION IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (16) ;
   BEGIN
      ret_value := EC_DEFERMENT_CORR_ACTION.TEXT_1      (
         P_EVENT_NO,
         P_ACTION,
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END TEXT_1;
   FUNCTION TEXT_2(
      P_EVENT_NO IN NUMBER,
      P_ACTION IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_DEFERMENT_CORR_ACTION.TEXT_2      (
         P_EVENT_NO,
         P_ACTION,
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END TEXT_2;
   FUNCTION VALUE_7(
      P_EVENT_NO IN NUMBER,
      P_ACTION IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_DEFERMENT_CORR_ACTION.VALUE_7      (
         P_EVENT_NO,
         P_ACTION,
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END VALUE_7;
   FUNCTION VALUE_9(
      P_EVENT_NO IN NUMBER,
      P_ACTION IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_DEFERMENT_CORR_ACTION.VALUE_9      (
         P_EVENT_NO,
         P_ACTION,
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END VALUE_9;
   FUNCTION DATE_1(
      P_EVENT_NO IN NUMBER,
      P_ACTION IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_DEFERMENT_CORR_ACTION.DATE_1      (
         P_EVENT_NO,
         P_ACTION,
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END DATE_1;
   FUNCTION END_DAY(
      P_EVENT_NO IN NUMBER,
      P_ACTION IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_DEFERMENT_CORR_ACTION.END_DAY      (
         P_EVENT_NO,
         P_ACTION,
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END END_DAY;
   FUNCTION PRODUCTION_DAY(
      P_EVENT_NO IN NUMBER,
      P_ACTION IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_DEFERMENT_CORR_ACTION.PRODUCTION_DAY      (
         P_EVENT_NO,
         P_ACTION,
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END PRODUCTION_DAY;
   FUNCTION TEXT_11(
      P_EVENT_NO IN NUMBER,
      P_ACTION IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_DEFERMENT_CORR_ACTION.TEXT_11      (
         P_EVENT_NO,
         P_ACTION,
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END TEXT_11;
   FUNCTION TEXT_12(
      P_EVENT_NO IN NUMBER,
      P_ACTION IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_DEFERMENT_CORR_ACTION.TEXT_12      (
         P_EVENT_NO,
         P_ACTION,
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END TEXT_12;
   FUNCTION TEXT_8(
      P_EVENT_NO IN NUMBER,
      P_ACTION IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_DEFERMENT_CORR_ACTION.TEXT_8      (
         P_EVENT_NO,
         P_ACTION,
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END TEXT_8;
   FUNCTION VALUE_10(
      P_EVENT_NO IN NUMBER,
      P_ACTION IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_DEFERMENT_CORR_ACTION.VALUE_10      (
         P_EVENT_NO,
         P_ACTION,
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END VALUE_10;
   FUNCTION VALUE_8(
      P_EVENT_NO IN NUMBER,
      P_ACTION IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_DEFERMENT_CORR_ACTION.VALUE_8      (
         P_EVENT_NO,
         P_ACTION,
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END VALUE_8;

END RP_DEFERMENT_CORR_ACTION;

/
--GRANT EXECUTE ON ECKERNEL_WST.RP_DEFERMENT_CORR_ACTION TO REPORT_ROLE_XXX;



 -- FINISH PKG_GEN_PKGS.sf_get_functions at:05/07/2019 10.27.27 AM

