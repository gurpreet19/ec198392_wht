
 -- START PKG_GEN_PKGS.sf_get_functions at:05/07/2019 09.20.46 AM


CREATE or REPLACE PACKAGE RP_IFLW_PERIOD_STATUS
IS

   FUNCTION INJ_VOL(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_TIME_SPAN IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=',
      P_SUMMERTIME IN VARCHAR2 DEFAULT NULL)
      RETURN NUMBER;
   FUNCTION APPROVAL_BY(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_TIME_SPAN IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=',
      P_SUMMERTIME IN VARCHAR2 DEFAULT NULL)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_STATE(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_TIME_SPAN IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=',
      P_SUMMERTIME IN VARCHAR2 DEFAULT NULL)
      RETURN VARCHAR2;
   FUNCTION AVG_TS_DSC_PRESS(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_TIME_SPAN IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=',
      P_SUMMERTIME IN VARCHAR2 DEFAULT NULL)
      RETURN NUMBER;
   FUNCTION AVG_FLOWLINE_PRESS(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_TIME_SPAN IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=',
      P_SUMMERTIME IN VARCHAR2 DEFAULT NULL)
      RETURN NUMBER;
   FUNCTION INJ_TYPE(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_TIME_SPAN IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=',
      P_SUMMERTIME IN VARCHAR2 DEFAULT NULL)
      RETURN VARCHAR2;
   FUNCTION NEXT_DAYTIME(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_TIME_SPAN IN VARCHAR2,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION ON_STREAM_SECS(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_TIME_SPAN IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=',
      P_SUMMERTIME IN VARCHAR2 DEFAULT NULL)
      RETURN NUMBER;
   FUNCTION PREV_EQUAL_DAYTIME(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_TIME_SPAN IN VARCHAR2,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION COMMENTS(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_TIME_SPAN IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=',
      P_SUMMERTIME IN VARCHAR2 DEFAULT NULL)
      RETURN VARCHAR2;
   FUNCTION NEXT_EQUAL_DAYTIME(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_TIME_SPAN IN VARCHAR2,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION USER_IND(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_TIME_SPAN IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=',
      P_SUMMERTIME IN VARCHAR2 DEFAULT NULL)
      RETURN VARCHAR2;
   FUNCTION UTC_DAYTIME(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_TIME_SPAN IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=',
      P_SUMMERTIME IN VARCHAR2 DEFAULT NULL)
      RETURN DATE;
   FUNCTION AVG_CHOKE_SIZE(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_TIME_SPAN IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=',
      P_SUMMERTIME IN VARCHAR2 DEFAULT NULL)
      RETURN NUMBER;
   FUNCTION AVG_FLOWLINE_SS_TEMP(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_TIME_SPAN IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=',
      P_SUMMERTIME IN VARCHAR2 DEFAULT NULL)
      RETURN NUMBER;
   FUNCTION MEAS_INJ_VOL(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_TIME_SPAN IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=',
      P_SUMMERTIME IN VARCHAR2 DEFAULT NULL)
      RETURN NUMBER;
   FUNCTION PERIOD_SECS(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_TIME_SPAN IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=',
      P_SUMMERTIME IN VARCHAR2 DEFAULT NULL)
      RETURN NUMBER;
   FUNCTION PREV_DAYTIME(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_TIME_SPAN IN VARCHAR2,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION RECORD_STATUS(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_TIME_SPAN IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=',
      P_SUMMERTIME IN VARCHAR2 DEFAULT NULL)
      RETURN VARCHAR2;
   FUNCTION SAFETY_VALVE_STATUS(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_TIME_SPAN IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=',
      P_SUMMERTIME IN VARCHAR2 DEFAULT NULL)
      RETURN NUMBER;
   FUNCTION APPROVAL_DATE(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_TIME_SPAN IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=',
      P_SUMMERTIME IN VARCHAR2 DEFAULT NULL)
      RETURN DATE;
   FUNCTION AVG_FLOWLINE_SS_PRESS(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_TIME_SPAN IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=',
      P_SUMMERTIME IN VARCHAR2 DEFAULT NULL)
      RETURN NUMBER;
   FUNCTION AVG_TS_DSC_TEMP(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_TIME_SPAN IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=',
      P_SUMMERTIME IN VARCHAR2 DEFAULT NULL)
      RETURN NUMBER;
      TYPE REC_ROW_BY_PK IS RECORD (
         OBJECT_ID VARCHAR2 (32) ,
         DAYTIME  DATE ,
         TIME_SPAN VARCHAR2 (16) ,
         SUMMER_TIME VARCHAR2 (1) ,
         DAY  DATE ,
         ON_STREAM_SECS NUMBER ,
         PERIOD_SECS NUMBER ,
         INJ_TYPE VARCHAR2 (2) ,
         INJ_VOL NUMBER ,
         AVG_CHOKE_SIZE NUMBER ,
         AVG_FLOWLINE_PRESS NUMBER ,
         AVG_FLOWLINE_TEMP NUMBER ,
         AVG_FLOWLINE_SS_TEMP NUMBER ,
         AVG_FLOWLINE_SS_PRESS NUMBER ,
         AVG_TS_DSC_PRESS NUMBER ,
         AVG_TS_DSC_TEMP NUMBER ,
         MEAS_INJ_VOL NUMBER ,
         USER_IND VARCHAR2 (1) ,
         RISER_VALVE_STATUS NUMBER ,
         SAFETY_VALVE_STATUS NUMBER ,
         COMMENTS VARCHAR2 (2000) ,
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
         UTC_DAYTIME  DATE  );
   FUNCTION ROW_BY_PK(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_TIME_SPAN IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN REC_ROW_BY_PK;
      TYPE REC_ROW_BY_REL_OPERATOR IS RECORD (
         OBJECT_ID VARCHAR2 (32) ,
         DAYTIME  DATE ,
         TIME_SPAN VARCHAR2 (16) ,
         SUMMER_TIME VARCHAR2 (1) ,
         DAY  DATE ,
         ON_STREAM_SECS NUMBER ,
         PERIOD_SECS NUMBER ,
         INJ_TYPE VARCHAR2 (2) ,
         INJ_VOL NUMBER ,
         AVG_CHOKE_SIZE NUMBER ,
         AVG_FLOWLINE_PRESS NUMBER ,
         AVG_FLOWLINE_TEMP NUMBER ,
         AVG_FLOWLINE_SS_TEMP NUMBER ,
         AVG_FLOWLINE_SS_PRESS NUMBER ,
         AVG_TS_DSC_PRESS NUMBER ,
         AVG_TS_DSC_TEMP NUMBER ,
         MEAS_INJ_VOL NUMBER ,
         USER_IND VARCHAR2 (1) ,
         RISER_VALVE_STATUS NUMBER ,
         SAFETY_VALVE_STATUS NUMBER ,
         COMMENTS VARCHAR2 (2000) ,
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
         UTC_DAYTIME  DATE  );
   FUNCTION ROW_BY_REL_OPERATOR(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_TIME_SPAN IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=',
      P_SUMMERTIME IN VARCHAR2 DEFAULT NULL)
      RETURN REC_ROW_BY_REL_OPERATOR;
   FUNCTION DAY(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_TIME_SPAN IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=',
      P_SUMMERTIME IN VARCHAR2 DEFAULT NULL)
      RETURN DATE;
   FUNCTION REC_ID(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_TIME_SPAN IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=',
      P_SUMMERTIME IN VARCHAR2 DEFAULT NULL)
      RETURN VARCHAR2;
   FUNCTION AVG_FLOWLINE_TEMP(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_TIME_SPAN IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=',
      P_SUMMERTIME IN VARCHAR2 DEFAULT NULL)
      RETURN NUMBER;
   FUNCTION RISER_VALVE_STATUS(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_TIME_SPAN IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=',
      P_SUMMERTIME IN VARCHAR2 DEFAULT NULL)
      RETURN NUMBER;

END RP_IFLW_PERIOD_STATUS;

/



CREATE or REPLACE PACKAGE BODY RP_IFLW_PERIOD_STATUS
IS

   FUNCTION INJ_VOL(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_TIME_SPAN IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=',
      P_SUMMERTIME IN VARCHAR2 DEFAULT NULL)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_IFLW_PERIOD_STATUS.INJ_VOL      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_TIME_SPAN,
         P_COMPARE_OPER,
         P_SUMMERTIME );
         RETURN ret_value;
   END INJ_VOL;
   FUNCTION APPROVAL_BY(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_TIME_SPAN IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=',
      P_SUMMERTIME IN VARCHAR2 DEFAULT NULL)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (30) ;
   BEGIN
      ret_value := EC_IFLW_PERIOD_STATUS.APPROVAL_BY      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_TIME_SPAN,
         P_COMPARE_OPER,
         P_SUMMERTIME );
         RETURN ret_value;
   END APPROVAL_BY;
   FUNCTION APPROVAL_STATE(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_TIME_SPAN IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=',
      P_SUMMERTIME IN VARCHAR2 DEFAULT NULL)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_IFLW_PERIOD_STATUS.APPROVAL_STATE      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_TIME_SPAN,
         P_COMPARE_OPER,
         P_SUMMERTIME );
         RETURN ret_value;
   END APPROVAL_STATE;
   FUNCTION AVG_TS_DSC_PRESS(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_TIME_SPAN IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=',
      P_SUMMERTIME IN VARCHAR2 DEFAULT NULL)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_IFLW_PERIOD_STATUS.AVG_TS_DSC_PRESS      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_TIME_SPAN,
         P_COMPARE_OPER,
         P_SUMMERTIME );
         RETURN ret_value;
   END AVG_TS_DSC_PRESS;
   FUNCTION AVG_FLOWLINE_PRESS(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_TIME_SPAN IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=',
      P_SUMMERTIME IN VARCHAR2 DEFAULT NULL)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_IFLW_PERIOD_STATUS.AVG_FLOWLINE_PRESS      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_TIME_SPAN,
         P_COMPARE_OPER,
         P_SUMMERTIME );
         RETURN ret_value;
   END AVG_FLOWLINE_PRESS;
   FUNCTION INJ_TYPE(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_TIME_SPAN IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=',
      P_SUMMERTIME IN VARCHAR2 DEFAULT NULL)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2) ;
   BEGIN
      ret_value := EC_IFLW_PERIOD_STATUS.INJ_TYPE      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_TIME_SPAN,
         P_COMPARE_OPER,
         P_SUMMERTIME );
         RETURN ret_value;
   END INJ_TYPE;
   FUNCTION NEXT_DAYTIME(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_TIME_SPAN IN VARCHAR2,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_IFLW_PERIOD_STATUS.NEXT_DAYTIME      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_TIME_SPAN,
         P_NUM_ROWS );
         RETURN ret_value;
   END NEXT_DAYTIME;
   FUNCTION ON_STREAM_SECS(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_TIME_SPAN IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=',
      P_SUMMERTIME IN VARCHAR2 DEFAULT NULL)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_IFLW_PERIOD_STATUS.ON_STREAM_SECS      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_TIME_SPAN,
         P_COMPARE_OPER,
         P_SUMMERTIME );
         RETURN ret_value;
   END ON_STREAM_SECS;
   FUNCTION PREV_EQUAL_DAYTIME(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_TIME_SPAN IN VARCHAR2,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_IFLW_PERIOD_STATUS.PREV_EQUAL_DAYTIME      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_TIME_SPAN,
         P_NUM_ROWS );
         RETURN ret_value;
   END PREV_EQUAL_DAYTIME;
   FUNCTION COMMENTS(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_TIME_SPAN IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=',
      P_SUMMERTIME IN VARCHAR2 DEFAULT NULL)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_IFLW_PERIOD_STATUS.COMMENTS      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_TIME_SPAN,
         P_COMPARE_OPER,
         P_SUMMERTIME );
         RETURN ret_value;
   END COMMENTS;
   FUNCTION NEXT_EQUAL_DAYTIME(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_TIME_SPAN IN VARCHAR2,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_IFLW_PERIOD_STATUS.NEXT_EQUAL_DAYTIME      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_TIME_SPAN,
         P_NUM_ROWS );
         RETURN ret_value;
   END NEXT_EQUAL_DAYTIME;
   FUNCTION USER_IND(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_TIME_SPAN IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=',
      P_SUMMERTIME IN VARCHAR2 DEFAULT NULL)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_IFLW_PERIOD_STATUS.USER_IND      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_TIME_SPAN,
         P_COMPARE_OPER,
         P_SUMMERTIME );
         RETURN ret_value;
   END USER_IND;
   FUNCTION UTC_DAYTIME(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_TIME_SPAN IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=',
      P_SUMMERTIME IN VARCHAR2 DEFAULT NULL)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_IFLW_PERIOD_STATUS.UTC_DAYTIME      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_TIME_SPAN,
         P_COMPARE_OPER,
         P_SUMMERTIME );
         RETURN ret_value;
   END UTC_DAYTIME;
   FUNCTION AVG_CHOKE_SIZE(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_TIME_SPAN IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=',
      P_SUMMERTIME IN VARCHAR2 DEFAULT NULL)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_IFLW_PERIOD_STATUS.AVG_CHOKE_SIZE      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_TIME_SPAN,
         P_COMPARE_OPER,
         P_SUMMERTIME );
         RETURN ret_value;
   END AVG_CHOKE_SIZE;
   FUNCTION AVG_FLOWLINE_SS_TEMP(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_TIME_SPAN IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=',
      P_SUMMERTIME IN VARCHAR2 DEFAULT NULL)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_IFLW_PERIOD_STATUS.AVG_FLOWLINE_SS_TEMP      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_TIME_SPAN,
         P_COMPARE_OPER,
         P_SUMMERTIME );
         RETURN ret_value;
   END AVG_FLOWLINE_SS_TEMP;
   FUNCTION MEAS_INJ_VOL(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_TIME_SPAN IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=',
      P_SUMMERTIME IN VARCHAR2 DEFAULT NULL)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_IFLW_PERIOD_STATUS.MEAS_INJ_VOL      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_TIME_SPAN,
         P_COMPARE_OPER,
         P_SUMMERTIME );
         RETURN ret_value;
   END MEAS_INJ_VOL;
   FUNCTION PERIOD_SECS(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_TIME_SPAN IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=',
      P_SUMMERTIME IN VARCHAR2 DEFAULT NULL)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_IFLW_PERIOD_STATUS.PERIOD_SECS      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_TIME_SPAN,
         P_COMPARE_OPER,
         P_SUMMERTIME );
         RETURN ret_value;
   END PERIOD_SECS;
   FUNCTION PREV_DAYTIME(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_TIME_SPAN IN VARCHAR2,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_IFLW_PERIOD_STATUS.PREV_DAYTIME      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_TIME_SPAN,
         P_NUM_ROWS );
         RETURN ret_value;
   END PREV_DAYTIME;
   FUNCTION RECORD_STATUS(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_TIME_SPAN IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=',
      P_SUMMERTIME IN VARCHAR2 DEFAULT NULL)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_IFLW_PERIOD_STATUS.RECORD_STATUS      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_TIME_SPAN,
         P_COMPARE_OPER,
         P_SUMMERTIME );
         RETURN ret_value;
   END RECORD_STATUS;
   FUNCTION SAFETY_VALVE_STATUS(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_TIME_SPAN IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=',
      P_SUMMERTIME IN VARCHAR2 DEFAULT NULL)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_IFLW_PERIOD_STATUS.SAFETY_VALVE_STATUS      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_TIME_SPAN,
         P_COMPARE_OPER,
         P_SUMMERTIME );
         RETURN ret_value;
   END SAFETY_VALVE_STATUS;
   FUNCTION APPROVAL_DATE(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_TIME_SPAN IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=',
      P_SUMMERTIME IN VARCHAR2 DEFAULT NULL)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_IFLW_PERIOD_STATUS.APPROVAL_DATE      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_TIME_SPAN,
         P_COMPARE_OPER,
         P_SUMMERTIME );
         RETURN ret_value;
   END APPROVAL_DATE;
   FUNCTION AVG_FLOWLINE_SS_PRESS(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_TIME_SPAN IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=',
      P_SUMMERTIME IN VARCHAR2 DEFAULT NULL)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_IFLW_PERIOD_STATUS.AVG_FLOWLINE_SS_PRESS      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_TIME_SPAN,
         P_COMPARE_OPER,
         P_SUMMERTIME );
         RETURN ret_value;
   END AVG_FLOWLINE_SS_PRESS;
   FUNCTION AVG_TS_DSC_TEMP(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_TIME_SPAN IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=',
      P_SUMMERTIME IN VARCHAR2 DEFAULT NULL)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_IFLW_PERIOD_STATUS.AVG_TS_DSC_TEMP      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_TIME_SPAN,
         P_COMPARE_OPER,
         P_SUMMERTIME );
         RETURN ret_value;
   END AVG_TS_DSC_TEMP;
   FUNCTION ROW_BY_PK(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_TIME_SPAN IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN REC_ROW_BY_PK
   IS
      ret_value    REC_ROW_BY_PK ;
   BEGIN
      ret_value := EC_IFLW_PERIOD_STATUS.ROW_BY_PK      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_TIME_SPAN,
         P_COMPARE_OPER );
         RETURN ret_value;
   END ROW_BY_PK;
   FUNCTION ROW_BY_REL_OPERATOR(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_TIME_SPAN IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=',
      P_SUMMERTIME IN VARCHAR2 DEFAULT NULL)
      RETURN REC_ROW_BY_REL_OPERATOR
   IS
      ret_value    REC_ROW_BY_REL_OPERATOR ;
   BEGIN
      ret_value := EC_IFLW_PERIOD_STATUS.ROW_BY_REL_OPERATOR      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_TIME_SPAN,
         P_COMPARE_OPER,
         P_SUMMERTIME );
         RETURN ret_value;
   END ROW_BY_REL_OPERATOR;
   FUNCTION DAY(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_TIME_SPAN IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=',
      P_SUMMERTIME IN VARCHAR2 DEFAULT NULL)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_IFLW_PERIOD_STATUS.DAY      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_TIME_SPAN,
         P_COMPARE_OPER,
         P_SUMMERTIME );
         RETURN ret_value;
   END DAY;
   FUNCTION REC_ID(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_TIME_SPAN IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=',
      P_SUMMERTIME IN VARCHAR2 DEFAULT NULL)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_IFLW_PERIOD_STATUS.REC_ID      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_TIME_SPAN,
         P_COMPARE_OPER,
         P_SUMMERTIME );
         RETURN ret_value;
   END REC_ID;
   FUNCTION AVG_FLOWLINE_TEMP(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_TIME_SPAN IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=',
      P_SUMMERTIME IN VARCHAR2 DEFAULT NULL)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_IFLW_PERIOD_STATUS.AVG_FLOWLINE_TEMP      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_TIME_SPAN,
         P_COMPARE_OPER,
         P_SUMMERTIME );
         RETURN ret_value;
   END AVG_FLOWLINE_TEMP;
   FUNCTION RISER_VALVE_STATUS(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_TIME_SPAN IN VARCHAR2,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=',
      P_SUMMERTIME IN VARCHAR2 DEFAULT NULL)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_IFLW_PERIOD_STATUS.RISER_VALVE_STATUS      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_TIME_SPAN,
         P_COMPARE_OPER,
         P_SUMMERTIME );
         RETURN ret_value;
   END RISER_VALVE_STATUS;

END RP_IFLW_PERIOD_STATUS;

/
--GRANT EXECUTE ON ECKERNEL_WST.RP_IFLW_PERIOD_STATUS TO REPORT_ROLE_XXX;



 -- FINISH PKG_GEN_PKGS.sf_get_functions at:05/07/2019 09.20.53 AM


