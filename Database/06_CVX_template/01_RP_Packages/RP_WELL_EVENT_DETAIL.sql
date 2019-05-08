
 -- START PKG_GEN_PKGS.sf_get_functions at:05/07/2019 05.17.31 AM


CREATE or REPLACE PACKAGE RP_WELL_EVENT_DETAIL
IS

   FUNCTION TEXT_3(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_EVENT_TYPE IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2;
   FUNCTION TEXT_4(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_EVENT_TYPE IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2;
   FUNCTION APPROVAL_BY(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_EVENT_TYPE IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2;
   FUNCTION APPROVAL_STATE(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_EVENT_TYPE IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2;
   FUNCTION CLOSING_READING(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_EVENT_TYPE IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER;
   FUNCTION DURATION_HRS(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_EVENT_TYPE IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER;
   FUNCTION OPENING_DAYTIME(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_EVENT_TYPE IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN DATE;
   FUNCTION SUMMER_TIME(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_EVENT_TYPE IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2;
   FUNCTION UTC_END_DATE(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_EVENT_TYPE IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN DATE;
   FUNCTION VALUE_5(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_EVENT_TYPE IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER;
   FUNCTION NEXT_DAYTIME(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_EVENT_TYPE IN VARCHAR2,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION PREV_EQUAL_DAYTIME(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_EVENT_TYPE IN VARCHAR2,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION COMMENTS(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_EVENT_TYPE IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2;
   FUNCTION METER_OVERRIDE(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_EVENT_TYPE IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER;
   FUNCTION NEXT_EQUAL_DAYTIME(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_EVENT_TYPE IN VARCHAR2,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION OPENING_OVERRIDE(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_EVENT_TYPE IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER;
   FUNCTION UTC_DAYTIME(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_EVENT_TYPE IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN DATE;
   FUNCTION VALUE_6(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_EVENT_TYPE IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER;
   FUNCTION END_DATE(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_EVENT_TYPE IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN DATE;
   FUNCTION PREV_DAYTIME(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_EVENT_TYPE IN VARCHAR2,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION RECORD_STATUS(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_EVENT_TYPE IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2;
   FUNCTION VALUE_1(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_EVENT_TYPE IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER;
   FUNCTION ADJ_VOL(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_EVENT_TYPE IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER;
   FUNCTION APPROVAL_DATE(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_EVENT_TYPE IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN DATE;
      TYPE REC_ROW_BY_PK IS RECORD (
         OBJECT_ID VARCHAR2 (32) ,
         CLASS_NAME VARCHAR2 (32) ,
         DAYTIME  DATE ,
         SUMMER_TIME VARCHAR2 (1) ,
         OPENING_DAYTIME  DATE ,
         END_DATE  DATE ,
         EVENT_TYPE VARCHAR2 (32) ,
         OPENING_OVERRIDE NUMBER ,
         CLOSING_READING NUMBER ,
         ADJ_VOL NUMBER ,
         METER_OVERRIDE NUMBER ,
         VOLUME NUMBER ,
         DURATION_HRS NUMBER ,
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
         PRODUCTION_DAY  DATE ,
         UTC_DAYTIME  DATE ,
         UTC_END_DATE  DATE  );
   FUNCTION ROW_BY_PK(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_EVENT_TYPE IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN REC_ROW_BY_PK;
      TYPE REC_ROW_BY_REL_OPERATOR IS RECORD (
         OBJECT_ID VARCHAR2 (32) ,
         CLASS_NAME VARCHAR2 (32) ,
         DAYTIME  DATE ,
         SUMMER_TIME VARCHAR2 (1) ,
         OPENING_DAYTIME  DATE ,
         END_DATE  DATE ,
         EVENT_TYPE VARCHAR2 (32) ,
         OPENING_OVERRIDE NUMBER ,
         CLOSING_READING NUMBER ,
         ADJ_VOL NUMBER ,
         METER_OVERRIDE NUMBER ,
         VOLUME NUMBER ,
         DURATION_HRS NUMBER ,
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
         PRODUCTION_DAY  DATE ,
         UTC_DAYTIME  DATE ,
         UTC_END_DATE  DATE  );
   FUNCTION ROW_BY_REL_OPERATOR(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_EVENT_TYPE IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN REC_ROW_BY_REL_OPERATOR;
   FUNCTION VALUE_2(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_EVENT_TYPE IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER;
   FUNCTION VALUE_3(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_EVENT_TYPE IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER;
   FUNCTION VALUE_4(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_EVENT_TYPE IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER;
   FUNCTION CLASS_NAME(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_EVENT_TYPE IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2;
   FUNCTION REC_ID(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_EVENT_TYPE IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2;
   FUNCTION TEXT_1(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_EVENT_TYPE IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2;
   FUNCTION TEXT_2(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_EVENT_TYPE IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2;
   FUNCTION VALUE_7(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_EVENT_TYPE IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER;
   FUNCTION VALUE_9(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_EVENT_TYPE IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER;
   FUNCTION END_DAY(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_EVENT_TYPE IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN DATE;
   FUNCTION PRODUCTION_DAY(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_EVENT_TYPE IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN DATE;
   FUNCTION VALUE_10(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_EVENT_TYPE IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER;
   FUNCTION VALUE_8(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_EVENT_TYPE IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER;
   FUNCTION VOLUME(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_EVENT_TYPE IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER;

END RP_WELL_EVENT_DETAIL;

/



CREATE or REPLACE PACKAGE BODY RP_WELL_EVENT_DETAIL
IS

   FUNCTION TEXT_3(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_EVENT_TYPE IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_WELL_EVENT_DETAIL.TEXT_3      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_EVENT_TYPE,
         P_COMPARE_OPER );
         RETURN ret_value;
   END TEXT_3;
   FUNCTION TEXT_4(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_EVENT_TYPE IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_WELL_EVENT_DETAIL.TEXT_4      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_EVENT_TYPE,
         P_COMPARE_OPER );
         RETURN ret_value;
   END TEXT_4;
   FUNCTION APPROVAL_BY(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_EVENT_TYPE IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (30) ;
   BEGIN
      ret_value := EC_WELL_EVENT_DETAIL.APPROVAL_BY      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_EVENT_TYPE,
         P_COMPARE_OPER );
         RETURN ret_value;
   END APPROVAL_BY;
   FUNCTION APPROVAL_STATE(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_EVENT_TYPE IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_WELL_EVENT_DETAIL.APPROVAL_STATE      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_EVENT_TYPE,
         P_COMPARE_OPER );
         RETURN ret_value;
   END APPROVAL_STATE;
   FUNCTION CLOSING_READING(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_EVENT_TYPE IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_WELL_EVENT_DETAIL.CLOSING_READING      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_EVENT_TYPE,
         P_COMPARE_OPER );
         RETURN ret_value;
   END CLOSING_READING;
   FUNCTION DURATION_HRS(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_EVENT_TYPE IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_WELL_EVENT_DETAIL.DURATION_HRS      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_EVENT_TYPE,
         P_COMPARE_OPER );
         RETURN ret_value;
   END DURATION_HRS;
   FUNCTION OPENING_DAYTIME(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_EVENT_TYPE IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_WELL_EVENT_DETAIL.OPENING_DAYTIME      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_EVENT_TYPE,
         P_COMPARE_OPER );
         RETURN ret_value;
   END OPENING_DAYTIME;
   FUNCTION SUMMER_TIME(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_EVENT_TYPE IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_WELL_EVENT_DETAIL.SUMMER_TIME      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_EVENT_TYPE,
         P_COMPARE_OPER );
         RETURN ret_value;
   END SUMMER_TIME;
   FUNCTION UTC_END_DATE(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_EVENT_TYPE IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_WELL_EVENT_DETAIL.UTC_END_DATE      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_EVENT_TYPE,
         P_COMPARE_OPER );
         RETURN ret_value;
   END UTC_END_DATE;
   FUNCTION VALUE_5(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_EVENT_TYPE IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_WELL_EVENT_DETAIL.VALUE_5      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_EVENT_TYPE,
         P_COMPARE_OPER );
         RETURN ret_value;
   END VALUE_5;
   FUNCTION NEXT_DAYTIME(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_EVENT_TYPE IN VARCHAR2,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_WELL_EVENT_DETAIL.NEXT_DAYTIME      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_EVENT_TYPE,
         P_NUM_ROWS );
         RETURN ret_value;
   END NEXT_DAYTIME;
   FUNCTION PREV_EQUAL_DAYTIME(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_EVENT_TYPE IN VARCHAR2,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_WELL_EVENT_DETAIL.PREV_EQUAL_DAYTIME      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_EVENT_TYPE,
         P_NUM_ROWS );
         RETURN ret_value;
   END PREV_EQUAL_DAYTIME;
   FUNCTION COMMENTS(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_EVENT_TYPE IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_WELL_EVENT_DETAIL.COMMENTS      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_EVENT_TYPE,
         P_COMPARE_OPER );
         RETURN ret_value;
   END COMMENTS;
   FUNCTION METER_OVERRIDE(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_EVENT_TYPE IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_WELL_EVENT_DETAIL.METER_OVERRIDE      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_EVENT_TYPE,
         P_COMPARE_OPER );
         RETURN ret_value;
   END METER_OVERRIDE;
   FUNCTION NEXT_EQUAL_DAYTIME(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_EVENT_TYPE IN VARCHAR2,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_WELL_EVENT_DETAIL.NEXT_EQUAL_DAYTIME      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_EVENT_TYPE,
         P_NUM_ROWS );
         RETURN ret_value;
   END NEXT_EQUAL_DAYTIME;
   FUNCTION OPENING_OVERRIDE(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_EVENT_TYPE IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_WELL_EVENT_DETAIL.OPENING_OVERRIDE      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_EVENT_TYPE,
         P_COMPARE_OPER );
         RETURN ret_value;
   END OPENING_OVERRIDE;
   FUNCTION UTC_DAYTIME(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_EVENT_TYPE IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_WELL_EVENT_DETAIL.UTC_DAYTIME      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_EVENT_TYPE,
         P_COMPARE_OPER );
         RETURN ret_value;
   END UTC_DAYTIME;
   FUNCTION VALUE_6(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_EVENT_TYPE IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_WELL_EVENT_DETAIL.VALUE_6      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_EVENT_TYPE,
         P_COMPARE_OPER );
         RETURN ret_value;
   END VALUE_6;
   FUNCTION END_DATE(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_EVENT_TYPE IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_WELL_EVENT_DETAIL.END_DATE      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_EVENT_TYPE,
         P_COMPARE_OPER );
         RETURN ret_value;
   END END_DATE;
   FUNCTION PREV_DAYTIME(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_EVENT_TYPE IN VARCHAR2,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_WELL_EVENT_DETAIL.PREV_DAYTIME      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_EVENT_TYPE,
         P_NUM_ROWS );
         RETURN ret_value;
   END PREV_DAYTIME;
   FUNCTION RECORD_STATUS(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_EVENT_TYPE IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_WELL_EVENT_DETAIL.RECORD_STATUS      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_EVENT_TYPE,
         P_COMPARE_OPER );
         RETURN ret_value;
   END RECORD_STATUS;
   FUNCTION VALUE_1(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_EVENT_TYPE IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_WELL_EVENT_DETAIL.VALUE_1      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_EVENT_TYPE,
         P_COMPARE_OPER );
         RETURN ret_value;
   END VALUE_1;
   FUNCTION ADJ_VOL(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_EVENT_TYPE IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_WELL_EVENT_DETAIL.ADJ_VOL      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_EVENT_TYPE,
         P_COMPARE_OPER );
         RETURN ret_value;
   END ADJ_VOL;
   FUNCTION APPROVAL_DATE(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_EVENT_TYPE IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_WELL_EVENT_DETAIL.APPROVAL_DATE      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_EVENT_TYPE,
         P_COMPARE_OPER );
         RETURN ret_value;
   END APPROVAL_DATE;
   FUNCTION ROW_BY_PK(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_EVENT_TYPE IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN REC_ROW_BY_PK
   IS
      ret_value    REC_ROW_BY_PK ;
   BEGIN
      ret_value := EC_WELL_EVENT_DETAIL.ROW_BY_PK      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_EVENT_TYPE,
         P_COMPARE_OPER );
         RETURN ret_value;
   END ROW_BY_PK;
   FUNCTION ROW_BY_REL_OPERATOR(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_EVENT_TYPE IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN REC_ROW_BY_REL_OPERATOR
   IS
      ret_value    REC_ROW_BY_REL_OPERATOR ;
   BEGIN
      ret_value := EC_WELL_EVENT_DETAIL.ROW_BY_REL_OPERATOR      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_EVENT_TYPE,
         P_COMPARE_OPER );
         RETURN ret_value;
   END ROW_BY_REL_OPERATOR;
   FUNCTION VALUE_2(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_EVENT_TYPE IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_WELL_EVENT_DETAIL.VALUE_2      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_EVENT_TYPE,
         P_COMPARE_OPER );
         RETURN ret_value;
   END VALUE_2;
   FUNCTION VALUE_3(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_EVENT_TYPE IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_WELL_EVENT_DETAIL.VALUE_3      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_EVENT_TYPE,
         P_COMPARE_OPER );
         RETURN ret_value;
   END VALUE_3;
   FUNCTION VALUE_4(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_EVENT_TYPE IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_WELL_EVENT_DETAIL.VALUE_4      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_EVENT_TYPE,
         P_COMPARE_OPER );
         RETURN ret_value;
   END VALUE_4;
   FUNCTION CLASS_NAME(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_EVENT_TYPE IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_WELL_EVENT_DETAIL.CLASS_NAME      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_EVENT_TYPE,
         P_COMPARE_OPER );
         RETURN ret_value;
   END CLASS_NAME;
   FUNCTION REC_ID(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_EVENT_TYPE IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_WELL_EVENT_DETAIL.REC_ID      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_EVENT_TYPE,
         P_COMPARE_OPER );
         RETURN ret_value;
   END REC_ID;
   FUNCTION TEXT_1(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_EVENT_TYPE IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (16) ;
   BEGIN
      ret_value := EC_WELL_EVENT_DETAIL.TEXT_1      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_EVENT_TYPE,
         P_COMPARE_OPER );
         RETURN ret_value;
   END TEXT_1;
   FUNCTION TEXT_2(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_EVENT_TYPE IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_WELL_EVENT_DETAIL.TEXT_2      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_EVENT_TYPE,
         P_COMPARE_OPER );
         RETURN ret_value;
   END TEXT_2;
   FUNCTION VALUE_7(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_EVENT_TYPE IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_WELL_EVENT_DETAIL.VALUE_7      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_EVENT_TYPE,
         P_COMPARE_OPER );
         RETURN ret_value;
   END VALUE_7;
   FUNCTION VALUE_9(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_EVENT_TYPE IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_WELL_EVENT_DETAIL.VALUE_9      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_EVENT_TYPE,
         P_COMPARE_OPER );
         RETURN ret_value;
   END VALUE_9;
   FUNCTION END_DAY(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_EVENT_TYPE IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_WELL_EVENT_DETAIL.END_DAY      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_EVENT_TYPE,
         P_COMPARE_OPER );
         RETURN ret_value;
   END END_DAY;
   FUNCTION PRODUCTION_DAY(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_EVENT_TYPE IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_WELL_EVENT_DETAIL.PRODUCTION_DAY      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_EVENT_TYPE,
         P_COMPARE_OPER );
         RETURN ret_value;
   END PRODUCTION_DAY;
   FUNCTION VALUE_10(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_EVENT_TYPE IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_WELL_EVENT_DETAIL.VALUE_10      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_EVENT_TYPE,
         P_COMPARE_OPER );
         RETURN ret_value;
   END VALUE_10;
   FUNCTION VALUE_8(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_EVENT_TYPE IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_WELL_EVENT_DETAIL.VALUE_8      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_EVENT_TYPE,
         P_COMPARE_OPER );
         RETURN ret_value;
   END VALUE_8;
   FUNCTION VOLUME(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_EVENT_TYPE IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_WELL_EVENT_DETAIL.VOLUME      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_EVENT_TYPE,
         P_COMPARE_OPER );
         RETURN ret_value;
   END VOLUME;

END RP_WELL_EVENT_DETAIL;

/
--GRANT EXECUTE ON ECKERNEL_WST.RP_WELL_EVENT_DETAIL TO REPORT_ROLE_XXX;



 -- FINISH PKG_GEN_PKGS.sf_get_functions at:05/07/2019 05.17.57 AM


