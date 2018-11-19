
 -- START PKG_GEN_PKGS.sf_get_functions at:11/15/2018 08.58.06 AM


CREATE or REPLACE PACKAGE RP_LIFT_ACC_SUB_DAY_FCST_FC
IS

   FUNCTION FORECAST_QTY(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_FORECAST_ID IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=',
      P_SUMMERTIME IN VARCHAR2 DEFAULT NULL)
      RETURN NUMBER;
   FUNCTION TEXT_3(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_FORECAST_ID IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=',
      P_SUMMERTIME IN VARCHAR2 DEFAULT NULL)
      RETURN VARCHAR2;
   FUNCTION TEXT_4(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_FORECAST_ID IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=',
      P_SUMMERTIME IN VARCHAR2 DEFAULT NULL)
      RETURN VARCHAR2;
   FUNCTION TIME_ZONE(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_FORECAST_ID IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=',
      P_SUMMERTIME IN VARCHAR2 DEFAULT NULL)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_BY(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_FORECAST_ID IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=',
      P_SUMMERTIME IN VARCHAR2 DEFAULT NULL)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_STATE(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_FORECAST_ID IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=',
      P_SUMMERTIME IN VARCHAR2 DEFAULT NULL)
      RETURN VARCHAR2;
   FUNCTION OFFICIAL_IND(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_FORECAST_ID IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=',
      P_SUMMERTIME IN VARCHAR2 DEFAULT NULL)
      RETURN VARCHAR2;
   FUNCTION VALUE_5(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_FORECAST_ID IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=',
      P_SUMMERTIME IN VARCHAR2 DEFAULT NULL)
      RETURN NUMBER;
   FUNCTION FORECAST_QTY3(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_FORECAST_ID IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=',
      P_SUMMERTIME IN VARCHAR2 DEFAULT NULL)
      RETURN NUMBER;
   FUNCTION NEXT_DAYTIME(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_FORECAST_ID IN VARCHAR2,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION PREV_EQUAL_DAYTIME(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_FORECAST_ID IN VARCHAR2,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION NEXT_EQUAL_DAYTIME(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_FORECAST_ID IN VARCHAR2,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION UTC_DAYTIME(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_FORECAST_ID IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=',
      P_SUMMERTIME IN VARCHAR2 DEFAULT NULL)
      RETURN DATE;
   FUNCTION VALUE_6(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_FORECAST_ID IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=',
      P_SUMMERTIME IN VARCHAR2 DEFAULT NULL)
      RETURN NUMBER;
   FUNCTION PREV_DAYTIME(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_FORECAST_ID IN VARCHAR2,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION RECORD_STATUS(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_FORECAST_ID IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=',
      P_SUMMERTIME IN VARCHAR2 DEFAULT NULL)
      RETURN VARCHAR2;
   FUNCTION VALUE_1(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_FORECAST_ID IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=',
      P_SUMMERTIME IN VARCHAR2 DEFAULT NULL)
      RETURN NUMBER;
   FUNCTION APPROVAL_DATE(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_FORECAST_ID IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=',
      P_SUMMERTIME IN VARCHAR2 DEFAULT NULL)
      RETURN DATE;
   FUNCTION FORECAST_QTY2(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_FORECAST_ID IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=',
      P_SUMMERTIME IN VARCHAR2 DEFAULT NULL)
      RETURN NUMBER;
      TYPE REC_ROW_BY_PK IS RECORD (
         OBJECT_ID VARCHAR2 (32) ,
         DAYTIME  DATE ,
         SUMMER_TIME VARCHAR2 (1) ,
         PRODUCTION_DAY  DATE ,
         FORECAST_ID VARCHAR2 (32) ,
         FORECAST_QTY NUMBER ,
         FORECAST_QTY2 NUMBER ,
         FORECAST_QTY3 NUMBER ,
         OFFICIAL_IND VARCHAR2 (1) ,
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
         APPROVAL_STATE VARCHAR2 (1) ,
         APPROVAL_BY VARCHAR2 (30) ,
         APPROVAL_DATE  DATE ,
         REC_ID VARCHAR2 (32) ,
         TIME_ZONE VARCHAR2 (65) ,
         UTC_DAYTIME  DATE  );
   FUNCTION ROW_BY_PK(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_FORECAST_ID IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN REC_ROW_BY_PK;
      TYPE REC_ROW_BY_REL_OPERATOR IS RECORD (
         OBJECT_ID VARCHAR2 (32) ,
         DAYTIME  DATE ,
         SUMMER_TIME VARCHAR2 (1) ,
         PRODUCTION_DAY  DATE ,
         FORECAST_ID VARCHAR2 (32) ,
         FORECAST_QTY NUMBER ,
         FORECAST_QTY2 NUMBER ,
         FORECAST_QTY3 NUMBER ,
         OFFICIAL_IND VARCHAR2 (1) ,
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
         APPROVAL_STATE VARCHAR2 (1) ,
         APPROVAL_BY VARCHAR2 (30) ,
         APPROVAL_DATE  DATE ,
         REC_ID VARCHAR2 (32) ,
         TIME_ZONE VARCHAR2 (65) ,
         UTC_DAYTIME  DATE  );
   FUNCTION ROW_BY_REL_OPERATOR(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_FORECAST_ID IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=',
      P_SUMMERTIME IN VARCHAR2 DEFAULT NULL)
      RETURN REC_ROW_BY_REL_OPERATOR;
   FUNCTION VALUE_2(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_FORECAST_ID IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=',
      P_SUMMERTIME IN VARCHAR2 DEFAULT NULL)
      RETURN NUMBER;
   FUNCTION VALUE_3(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_FORECAST_ID IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=',
      P_SUMMERTIME IN VARCHAR2 DEFAULT NULL)
      RETURN NUMBER;
   FUNCTION VALUE_4(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_FORECAST_ID IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=',
      P_SUMMERTIME IN VARCHAR2 DEFAULT NULL)
      RETURN NUMBER;
   FUNCTION REC_ID(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_FORECAST_ID IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=',
      P_SUMMERTIME IN VARCHAR2 DEFAULT NULL)
      RETURN VARCHAR2;
   FUNCTION TEXT_1(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_FORECAST_ID IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=',
      P_SUMMERTIME IN VARCHAR2 DEFAULT NULL)
      RETURN VARCHAR2;
   FUNCTION TEXT_2(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_FORECAST_ID IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=',
      P_SUMMERTIME IN VARCHAR2 DEFAULT NULL)
      RETURN VARCHAR2;
   FUNCTION VALUE_7(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_FORECAST_ID IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=',
      P_SUMMERTIME IN VARCHAR2 DEFAULT NULL)
      RETURN NUMBER;
   FUNCTION VALUE_9(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_FORECAST_ID IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=',
      P_SUMMERTIME IN VARCHAR2 DEFAULT NULL)
      RETURN NUMBER;
   FUNCTION PRODUCTION_DAY(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_FORECAST_ID IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=',
      P_SUMMERTIME IN VARCHAR2 DEFAULT NULL)
      RETURN DATE;
   FUNCTION VALUE_10(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_FORECAST_ID IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=',
      P_SUMMERTIME IN VARCHAR2 DEFAULT NULL)
      RETURN NUMBER;
   FUNCTION VALUE_8(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_FORECAST_ID IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=',
      P_SUMMERTIME IN VARCHAR2 DEFAULT NULL)
      RETURN NUMBER;

END RP_LIFT_ACC_SUB_DAY_FCST_FC;

/



CREATE or REPLACE PACKAGE BODY RP_LIFT_ACC_SUB_DAY_FCST_FC
IS

   FUNCTION FORECAST_QTY(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_FORECAST_ID IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=',
      P_SUMMERTIME IN VARCHAR2 DEFAULT NULL)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_LIFT_ACC_SUB_DAY_FCST_FC.FORECAST_QTY      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_FORECAST_ID,
         P_COMPARE_OPER,
         P_SUMMERTIME );
         RETURN ret_value;
   END FORECAST_QTY;
   FUNCTION TEXT_3(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_FORECAST_ID IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=',
      P_SUMMERTIME IN VARCHAR2 DEFAULT NULL)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_LIFT_ACC_SUB_DAY_FCST_FC.TEXT_3      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_FORECAST_ID,
         P_COMPARE_OPER,
         P_SUMMERTIME );
         RETURN ret_value;
   END TEXT_3;
   FUNCTION TEXT_4(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_FORECAST_ID IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=',
      P_SUMMERTIME IN VARCHAR2 DEFAULT NULL)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_LIFT_ACC_SUB_DAY_FCST_FC.TEXT_4      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_FORECAST_ID,
         P_COMPARE_OPER,
         P_SUMMERTIME );
         RETURN ret_value;
   END TEXT_4;
   FUNCTION TIME_ZONE(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_FORECAST_ID IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=',
      P_SUMMERTIME IN VARCHAR2 DEFAULT NULL)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (65) ;
   BEGIN
      ret_value := EC_LIFT_ACC_SUB_DAY_FCST_FC.TIME_ZONE      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_FORECAST_ID,
         P_COMPARE_OPER,
         P_SUMMERTIME );
         RETURN ret_value;
   END TIME_ZONE;
   FUNCTION APPROVAL_BY(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_FORECAST_ID IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=',
      P_SUMMERTIME IN VARCHAR2 DEFAULT NULL)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (30) ;
   BEGIN
      ret_value := EC_LIFT_ACC_SUB_DAY_FCST_FC.APPROVAL_BY      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_FORECAST_ID,
         P_COMPARE_OPER,
         P_SUMMERTIME );
         RETURN ret_value;
   END APPROVAL_BY;
   FUNCTION APPROVAL_STATE(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_FORECAST_ID IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=',
      P_SUMMERTIME IN VARCHAR2 DEFAULT NULL)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_LIFT_ACC_SUB_DAY_FCST_FC.APPROVAL_STATE      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_FORECAST_ID,
         P_COMPARE_OPER,
         P_SUMMERTIME );
         RETURN ret_value;
   END APPROVAL_STATE;
   FUNCTION OFFICIAL_IND(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_FORECAST_ID IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=',
      P_SUMMERTIME IN VARCHAR2 DEFAULT NULL)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_LIFT_ACC_SUB_DAY_FCST_FC.OFFICIAL_IND      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_FORECAST_ID,
         P_COMPARE_OPER,
         P_SUMMERTIME );
         RETURN ret_value;
   END OFFICIAL_IND;
   FUNCTION VALUE_5(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_FORECAST_ID IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=',
      P_SUMMERTIME IN VARCHAR2 DEFAULT NULL)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_LIFT_ACC_SUB_DAY_FCST_FC.VALUE_5      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_FORECAST_ID,
         P_COMPARE_OPER,
         P_SUMMERTIME );
         RETURN ret_value;
   END VALUE_5;
   FUNCTION FORECAST_QTY3(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_FORECAST_ID IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=',
      P_SUMMERTIME IN VARCHAR2 DEFAULT NULL)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_LIFT_ACC_SUB_DAY_FCST_FC.FORECAST_QTY3      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_FORECAST_ID,
         P_COMPARE_OPER,
         P_SUMMERTIME );
         RETURN ret_value;
   END FORECAST_QTY3;
   FUNCTION NEXT_DAYTIME(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_FORECAST_ID IN VARCHAR2,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_LIFT_ACC_SUB_DAY_FCST_FC.NEXT_DAYTIME      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_FORECAST_ID,
         P_NUM_ROWS );
         RETURN ret_value;
   END NEXT_DAYTIME;
   FUNCTION PREV_EQUAL_DAYTIME(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_FORECAST_ID IN VARCHAR2,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_LIFT_ACC_SUB_DAY_FCST_FC.PREV_EQUAL_DAYTIME      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_FORECAST_ID,
         P_NUM_ROWS );
         RETURN ret_value;
   END PREV_EQUAL_DAYTIME;
   FUNCTION NEXT_EQUAL_DAYTIME(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_FORECAST_ID IN VARCHAR2,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_LIFT_ACC_SUB_DAY_FCST_FC.NEXT_EQUAL_DAYTIME      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_FORECAST_ID,
         P_NUM_ROWS );
         RETURN ret_value;
   END NEXT_EQUAL_DAYTIME;
   FUNCTION UTC_DAYTIME(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_FORECAST_ID IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=',
      P_SUMMERTIME IN VARCHAR2 DEFAULT NULL)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_LIFT_ACC_SUB_DAY_FCST_FC.UTC_DAYTIME      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_FORECAST_ID,
         P_COMPARE_OPER,
         P_SUMMERTIME );
         RETURN ret_value;
   END UTC_DAYTIME;
   FUNCTION VALUE_6(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_FORECAST_ID IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=',
      P_SUMMERTIME IN VARCHAR2 DEFAULT NULL)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_LIFT_ACC_SUB_DAY_FCST_FC.VALUE_6      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_FORECAST_ID,
         P_COMPARE_OPER,
         P_SUMMERTIME );
         RETURN ret_value;
   END VALUE_6;
   FUNCTION PREV_DAYTIME(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_FORECAST_ID IN VARCHAR2,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_LIFT_ACC_SUB_DAY_FCST_FC.PREV_DAYTIME      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_FORECAST_ID,
         P_NUM_ROWS );
         RETURN ret_value;
   END PREV_DAYTIME;
   FUNCTION RECORD_STATUS(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_FORECAST_ID IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=',
      P_SUMMERTIME IN VARCHAR2 DEFAULT NULL)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_LIFT_ACC_SUB_DAY_FCST_FC.RECORD_STATUS      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_FORECAST_ID,
         P_COMPARE_OPER,
         P_SUMMERTIME );
         RETURN ret_value;
   END RECORD_STATUS;
   FUNCTION VALUE_1(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_FORECAST_ID IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=',
      P_SUMMERTIME IN VARCHAR2 DEFAULT NULL)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_LIFT_ACC_SUB_DAY_FCST_FC.VALUE_1      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_FORECAST_ID,
         P_COMPARE_OPER,
         P_SUMMERTIME );
         RETURN ret_value;
   END VALUE_1;
   FUNCTION APPROVAL_DATE(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_FORECAST_ID IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=',
      P_SUMMERTIME IN VARCHAR2 DEFAULT NULL)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_LIFT_ACC_SUB_DAY_FCST_FC.APPROVAL_DATE      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_FORECAST_ID,
         P_COMPARE_OPER,
         P_SUMMERTIME );
         RETURN ret_value;
   END APPROVAL_DATE;
   FUNCTION FORECAST_QTY2(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_FORECAST_ID IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=',
      P_SUMMERTIME IN VARCHAR2 DEFAULT NULL)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_LIFT_ACC_SUB_DAY_FCST_FC.FORECAST_QTY2      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_FORECAST_ID,
         P_COMPARE_OPER,
         P_SUMMERTIME );
         RETURN ret_value;
   END FORECAST_QTY2;
   FUNCTION ROW_BY_PK(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_FORECAST_ID IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN REC_ROW_BY_PK
   IS
      ret_value    REC_ROW_BY_PK ;
   BEGIN
      ret_value := EC_LIFT_ACC_SUB_DAY_FCST_FC.ROW_BY_PK      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_FORECAST_ID,
         P_COMPARE_OPER );
         RETURN ret_value;
   END ROW_BY_PK;
   FUNCTION ROW_BY_REL_OPERATOR(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_FORECAST_ID IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=',
      P_SUMMERTIME IN VARCHAR2 DEFAULT NULL)
      RETURN REC_ROW_BY_REL_OPERATOR
   IS
      ret_value    REC_ROW_BY_REL_OPERATOR ;
   BEGIN
      ret_value := EC_LIFT_ACC_SUB_DAY_FCST_FC.ROW_BY_REL_OPERATOR      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_FORECAST_ID,
         P_COMPARE_OPER,
         P_SUMMERTIME );
         RETURN ret_value;
   END ROW_BY_REL_OPERATOR;
   FUNCTION VALUE_2(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_FORECAST_ID IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=',
      P_SUMMERTIME IN VARCHAR2 DEFAULT NULL)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_LIFT_ACC_SUB_DAY_FCST_FC.VALUE_2      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_FORECAST_ID,
         P_COMPARE_OPER,
         P_SUMMERTIME );
         RETURN ret_value;
   END VALUE_2;
   FUNCTION VALUE_3(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_FORECAST_ID IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=',
      P_SUMMERTIME IN VARCHAR2 DEFAULT NULL)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_LIFT_ACC_SUB_DAY_FCST_FC.VALUE_3      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_FORECAST_ID,
         P_COMPARE_OPER,
         P_SUMMERTIME );
         RETURN ret_value;
   END VALUE_3;
   FUNCTION VALUE_4(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_FORECAST_ID IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=',
      P_SUMMERTIME IN VARCHAR2 DEFAULT NULL)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_LIFT_ACC_SUB_DAY_FCST_FC.VALUE_4      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_FORECAST_ID,
         P_COMPARE_OPER,
         P_SUMMERTIME );
         RETURN ret_value;
   END VALUE_4;
   FUNCTION REC_ID(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_FORECAST_ID IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=',
      P_SUMMERTIME IN VARCHAR2 DEFAULT NULL)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_LIFT_ACC_SUB_DAY_FCST_FC.REC_ID      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_FORECAST_ID,
         P_COMPARE_OPER,
         P_SUMMERTIME );
         RETURN ret_value;
   END REC_ID;
   FUNCTION TEXT_1(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_FORECAST_ID IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=',
      P_SUMMERTIME IN VARCHAR2 DEFAULT NULL)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (16) ;
   BEGIN
      ret_value := EC_LIFT_ACC_SUB_DAY_FCST_FC.TEXT_1      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_FORECAST_ID,
         P_COMPARE_OPER,
         P_SUMMERTIME );
         RETURN ret_value;
   END TEXT_1;
   FUNCTION TEXT_2(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_FORECAST_ID IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=',
      P_SUMMERTIME IN VARCHAR2 DEFAULT NULL)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_LIFT_ACC_SUB_DAY_FCST_FC.TEXT_2      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_FORECAST_ID,
         P_COMPARE_OPER,
         P_SUMMERTIME );
         RETURN ret_value;
   END TEXT_2;
   FUNCTION VALUE_7(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_FORECAST_ID IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=',
      P_SUMMERTIME IN VARCHAR2 DEFAULT NULL)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_LIFT_ACC_SUB_DAY_FCST_FC.VALUE_7      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_FORECAST_ID,
         P_COMPARE_OPER,
         P_SUMMERTIME );
         RETURN ret_value;
   END VALUE_7;
   FUNCTION VALUE_9(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_FORECAST_ID IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=',
      P_SUMMERTIME IN VARCHAR2 DEFAULT NULL)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_LIFT_ACC_SUB_DAY_FCST_FC.VALUE_9      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_FORECAST_ID,
         P_COMPARE_OPER,
         P_SUMMERTIME );
         RETURN ret_value;
   END VALUE_9;
   FUNCTION PRODUCTION_DAY(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_FORECAST_ID IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=',
      P_SUMMERTIME IN VARCHAR2 DEFAULT NULL)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_LIFT_ACC_SUB_DAY_FCST_FC.PRODUCTION_DAY      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_FORECAST_ID,
         P_COMPARE_OPER,
         P_SUMMERTIME );
         RETURN ret_value;
   END PRODUCTION_DAY;
   FUNCTION VALUE_10(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_FORECAST_ID IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=',
      P_SUMMERTIME IN VARCHAR2 DEFAULT NULL)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_LIFT_ACC_SUB_DAY_FCST_FC.VALUE_10      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_FORECAST_ID,
         P_COMPARE_OPER,
         P_SUMMERTIME );
         RETURN ret_value;
   END VALUE_10;
   FUNCTION VALUE_8(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_FORECAST_ID IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=',
      P_SUMMERTIME IN VARCHAR2 DEFAULT NULL)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_LIFT_ACC_SUB_DAY_FCST_FC.VALUE_8      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_FORECAST_ID,
         P_COMPARE_OPER,
         P_SUMMERTIME );
         RETURN ret_value;
   END VALUE_8;

END RP_LIFT_ACC_SUB_DAY_FCST_FC;

/
--GRANT EXECUTE ON ECKERNEL_WST.RP_LIFT_ACC_SUB_DAY_FCST_FC TO REPORT_ROLE_XXX;



 -- FINISH PKG_GEN_PKGS.sf_get_functions at:11/15/2018 08.58.13 AM


