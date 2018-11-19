
 -- START PKG_GEN_PKGS.sf_get_functions at:11/15/2018 09.49.16 AM


CREATE or REPLACE PACKAGE RP_FCST_JOB_LOG
IS

   FUNCTION CALC_NAME(
      P_RUN_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION CALC_REF_OBJECT_ID_10(
      P_RUN_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION CALC_REF_OBJECT_ID_9(
      P_RUN_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION CALC_TEXT_2(
      P_RUN_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION COMMENTS(
      P_RUN_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_3(
      P_RUN_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_BY(
      P_RUN_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_STATE(
      P_RUN_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION CALC_REF_OBJECT_ID_3(
      P_RUN_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION CALC_REF_OBJECT_ID_4(
      P_RUN_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION CALC_TEXT_5(
      P_RUN_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION CALC_VALUE_1(
      P_RUN_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION CALC_VALUE_4(
      P_RUN_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION CALC_VALUE_5(
      P_RUN_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION EXIT_STATUS(
      P_RUN_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_5(
      P_RUN_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION CALC_DATE_4(
      P_RUN_NO IN NUMBER)
      RETURN DATE;
   FUNCTION CALC_REF_OBJECT_ID_1(
      P_RUN_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION CALC_TEXT_3(
      P_RUN_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION NEXT_DAYTIME(
      P_RUN_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION PREV_EQUAL_DAYTIME(
      P_RUN_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION CALC_DATE_1(
      P_RUN_NO IN NUMBER)
      RETURN DATE;
   FUNCTION CALC_REF_OBJECT_ID_2(
      P_RUN_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION CALC_REF_OBJECT_ID_6(
      P_RUN_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION CALC_REF_OBJECT_ID_8(
      P_RUN_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION DATE_3(
      P_RUN_NO IN NUMBER)
      RETURN DATE;
   FUNCTION DATE_5(
      P_RUN_NO IN NUMBER)
      RETURN DATE;
   FUNCTION LOG_LEVEL(
      P_RUN_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION NEXT_EQUAL_DAYTIME(
      P_RUN_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION TEXT_1(
      P_RUN_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION CALC_REF_OBJECT_ID_5(
      P_RUN_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION CALC_REF_OBJECT_ID_7(
      P_RUN_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION DATE_2(
      P_RUN_NO IN NUMBER)
      RETURN DATE;
   FUNCTION END_DATE(
      P_RUN_NO IN NUMBER)
      RETURN DATE;
   FUNCTION PREV_DAYTIME(
      P_RUN_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION RECORD_STATUS(
      P_RUN_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TO_PERIOD(
      P_RUN_NO IN NUMBER)
      RETURN DATE;
   FUNCTION VALUE_1(
      P_RUN_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION APPROVAL_DATE(
      P_RUN_NO IN NUMBER)
      RETURN DATE;
   FUNCTION CALC_DATE_3(
      P_RUN_NO IN NUMBER)
      RETURN DATE;
   FUNCTION CALC_DATE_5(
      P_RUN_NO IN NUMBER)
      RETURN DATE;
   FUNCTION CALC_TEXT_1(
      P_RUN_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION CALC_TEXT_4(
      P_RUN_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION CALC_VALUE_2(
      P_RUN_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION FORECAST_ID(
      P_RUN_NO IN NUMBER)
      RETURN VARCHAR2;
      TYPE REC_ROW_BY_PK IS RECORD (
         RUN_NO NUMBER ,
         FORECAST_ID VARCHAR2 (32) ,
         SCENARIO_ID VARCHAR2 (32) ,
         CALC_NAME VARCHAR2 (32) ,
         FROM_PERIOD  DATE ,
         TO_PERIOD  DATE ,
         DAYTIME  DATE ,
         END_DATE  DATE ,
         EXIT_STATUS VARCHAR2 (32) ,
         LOG_LEVEL VARCHAR2 (65) ,
         LOG_SUMMARY  BLOB ,
         COMMENTS VARCHAR2 (4000) ,
         CALC_TEXT_1 VARCHAR2 (240) ,
         CALC_TEXT_2 VARCHAR2 (240) ,
         CALC_TEXT_3 VARCHAR2 (240) ,
         CALC_TEXT_4 VARCHAR2 (240) ,
         CALC_TEXT_5 VARCHAR2 (240) ,
         CALC_VALUE_1 NUMBER ,
         CALC_VALUE_2 NUMBER ,
         CALC_VALUE_3 NUMBER ,
         CALC_VALUE_4 NUMBER ,
         CALC_VALUE_5 NUMBER ,
         CALC_DATE_1  DATE ,
         CALC_DATE_2  DATE ,
         CALC_DATE_3  DATE ,
         CALC_DATE_4  DATE ,
         CALC_DATE_5  DATE ,
         CALC_REF_OBJECT_ID_1 VARCHAR2 (32) ,
         CALC_REF_OBJECT_ID_2 VARCHAR2 (32) ,
         CALC_REF_OBJECT_ID_3 VARCHAR2 (32) ,
         CALC_REF_OBJECT_ID_4 VARCHAR2 (32) ,
         CALC_REF_OBJECT_ID_5 VARCHAR2 (32) ,
         CALC_REF_OBJECT_ID_6 VARCHAR2 (32) ,
         CALC_REF_OBJECT_ID_7 VARCHAR2 (32) ,
         CALC_REF_OBJECT_ID_8 VARCHAR2 (32) ,
         CALC_REF_OBJECT_ID_9 VARCHAR2 (32) ,
         CALC_REF_OBJECT_ID_10 VARCHAR2 (32) ,
         TEXT_1 VARCHAR2 (240) ,
         TEXT_2 VARCHAR2 (240) ,
         TEXT_3 VARCHAR2 (240) ,
         TEXT_4 VARCHAR2 (240) ,
         TEXT_5 VARCHAR2 (240) ,
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
      P_RUN_NO IN NUMBER)
      RETURN REC_ROW_BY_PK;
   FUNCTION SCENARIO_ID(
      P_RUN_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_2(
      P_RUN_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_4(
      P_RUN_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_5(
      P_RUN_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_2(
      P_RUN_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_3(
      P_RUN_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_4(
      P_RUN_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION DATE_4(
      P_RUN_NO IN NUMBER)
      RETURN DATE;
   FUNCTION FROM_PERIOD(
      P_RUN_NO IN NUMBER)
      RETURN DATE;
   FUNCTION LOG_SUMMARY(
      P_RUN_NO IN NUMBER)
      RETURN BLOB;
   FUNCTION REC_ID(
      P_RUN_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION CALC_DATE_2(
      P_RUN_NO IN NUMBER)
      RETURN DATE;
   FUNCTION CALC_VALUE_3(
      P_RUN_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION DATE_1(
      P_RUN_NO IN NUMBER)
      RETURN DATE;
   FUNCTION DAYTIME(
      P_RUN_NO IN NUMBER)
      RETURN DATE;

END RP_FCST_JOB_LOG;

/



CREATE or REPLACE PACKAGE BODY RP_FCST_JOB_LOG
IS

   FUNCTION CALC_NAME(
      P_RUN_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_FCST_JOB_LOG.CALC_NAME      (
         P_RUN_NO );
         RETURN ret_value;
   END CALC_NAME;
   FUNCTION CALC_REF_OBJECT_ID_10(
      P_RUN_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_FCST_JOB_LOG.CALC_REF_OBJECT_ID_10      (
         P_RUN_NO );
         RETURN ret_value;
   END CALC_REF_OBJECT_ID_10;
   FUNCTION CALC_REF_OBJECT_ID_9(
      P_RUN_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_FCST_JOB_LOG.CALC_REF_OBJECT_ID_9      (
         P_RUN_NO );
         RETURN ret_value;
   END CALC_REF_OBJECT_ID_9;
   FUNCTION CALC_TEXT_2(
      P_RUN_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_FCST_JOB_LOG.CALC_TEXT_2      (
         P_RUN_NO );
         RETURN ret_value;
   END CALC_TEXT_2;
   FUNCTION COMMENTS(
      P_RUN_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (4000) ;
   BEGIN
      ret_value := EC_FCST_JOB_LOG.COMMENTS      (
         P_RUN_NO );
         RETURN ret_value;
   END COMMENTS;
   FUNCTION TEXT_3(
      P_RUN_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_FCST_JOB_LOG.TEXT_3      (
         P_RUN_NO );
         RETURN ret_value;
   END TEXT_3;
   FUNCTION APPROVAL_BY(
      P_RUN_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (30) ;
   BEGIN
      ret_value := EC_FCST_JOB_LOG.APPROVAL_BY      (
         P_RUN_NO );
         RETURN ret_value;
   END APPROVAL_BY;
   FUNCTION APPROVAL_STATE(
      P_RUN_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_FCST_JOB_LOG.APPROVAL_STATE      (
         P_RUN_NO );
         RETURN ret_value;
   END APPROVAL_STATE;
   FUNCTION CALC_REF_OBJECT_ID_3(
      P_RUN_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_FCST_JOB_LOG.CALC_REF_OBJECT_ID_3      (
         P_RUN_NO );
         RETURN ret_value;
   END CALC_REF_OBJECT_ID_3;
   FUNCTION CALC_REF_OBJECT_ID_4(
      P_RUN_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_FCST_JOB_LOG.CALC_REF_OBJECT_ID_4      (
         P_RUN_NO );
         RETURN ret_value;
   END CALC_REF_OBJECT_ID_4;
   FUNCTION CALC_TEXT_5(
      P_RUN_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_FCST_JOB_LOG.CALC_TEXT_5      (
         P_RUN_NO );
         RETURN ret_value;
   END CALC_TEXT_5;
   FUNCTION CALC_VALUE_1(
      P_RUN_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FCST_JOB_LOG.CALC_VALUE_1      (
         P_RUN_NO );
         RETURN ret_value;
   END CALC_VALUE_1;
   FUNCTION CALC_VALUE_4(
      P_RUN_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FCST_JOB_LOG.CALC_VALUE_4      (
         P_RUN_NO );
         RETURN ret_value;
   END CALC_VALUE_4;
   FUNCTION CALC_VALUE_5(
      P_RUN_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FCST_JOB_LOG.CALC_VALUE_5      (
         P_RUN_NO );
         RETURN ret_value;
   END CALC_VALUE_5;
   FUNCTION EXIT_STATUS(
      P_RUN_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_FCST_JOB_LOG.EXIT_STATUS      (
         P_RUN_NO );
         RETURN ret_value;
   END EXIT_STATUS;
   FUNCTION VALUE_5(
      P_RUN_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FCST_JOB_LOG.VALUE_5      (
         P_RUN_NO );
         RETURN ret_value;
   END VALUE_5;
   FUNCTION CALC_DATE_4(
      P_RUN_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_FCST_JOB_LOG.CALC_DATE_4      (
         P_RUN_NO );
         RETURN ret_value;
   END CALC_DATE_4;
   FUNCTION CALC_REF_OBJECT_ID_1(
      P_RUN_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_FCST_JOB_LOG.CALC_REF_OBJECT_ID_1      (
         P_RUN_NO );
         RETURN ret_value;
   END CALC_REF_OBJECT_ID_1;
   FUNCTION CALC_TEXT_3(
      P_RUN_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_FCST_JOB_LOG.CALC_TEXT_3      (
         P_RUN_NO );
         RETURN ret_value;
   END CALC_TEXT_3;
   FUNCTION NEXT_DAYTIME(
      P_RUN_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_FCST_JOB_LOG.NEXT_DAYTIME      (
         P_RUN_NO,
         P_NUM_ROWS );
         RETURN ret_value;
   END NEXT_DAYTIME;
   FUNCTION PREV_EQUAL_DAYTIME(
      P_RUN_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_FCST_JOB_LOG.PREV_EQUAL_DAYTIME      (
         P_RUN_NO,
         P_NUM_ROWS );
         RETURN ret_value;
   END PREV_EQUAL_DAYTIME;
   FUNCTION CALC_DATE_1(
      P_RUN_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_FCST_JOB_LOG.CALC_DATE_1      (
         P_RUN_NO );
         RETURN ret_value;
   END CALC_DATE_1;
   FUNCTION CALC_REF_OBJECT_ID_2(
      P_RUN_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_FCST_JOB_LOG.CALC_REF_OBJECT_ID_2      (
         P_RUN_NO );
         RETURN ret_value;
   END CALC_REF_OBJECT_ID_2;
   FUNCTION CALC_REF_OBJECT_ID_6(
      P_RUN_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_FCST_JOB_LOG.CALC_REF_OBJECT_ID_6      (
         P_RUN_NO );
         RETURN ret_value;
   END CALC_REF_OBJECT_ID_6;
   FUNCTION CALC_REF_OBJECT_ID_8(
      P_RUN_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_FCST_JOB_LOG.CALC_REF_OBJECT_ID_8      (
         P_RUN_NO );
         RETURN ret_value;
   END CALC_REF_OBJECT_ID_8;
   FUNCTION DATE_3(
      P_RUN_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_FCST_JOB_LOG.DATE_3      (
         P_RUN_NO );
         RETURN ret_value;
   END DATE_3;
   FUNCTION DATE_5(
      P_RUN_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_FCST_JOB_LOG.DATE_5      (
         P_RUN_NO );
         RETURN ret_value;
   END DATE_5;
   FUNCTION LOG_LEVEL(
      P_RUN_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (65) ;
   BEGIN
      ret_value := EC_FCST_JOB_LOG.LOG_LEVEL      (
         P_RUN_NO );
         RETURN ret_value;
   END LOG_LEVEL;
   FUNCTION NEXT_EQUAL_DAYTIME(
      P_RUN_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_FCST_JOB_LOG.NEXT_EQUAL_DAYTIME      (
         P_RUN_NO,
         P_NUM_ROWS );
         RETURN ret_value;
   END NEXT_EQUAL_DAYTIME;
   FUNCTION TEXT_1(
      P_RUN_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_FCST_JOB_LOG.TEXT_1      (
         P_RUN_NO );
         RETURN ret_value;
   END TEXT_1;
   FUNCTION CALC_REF_OBJECT_ID_5(
      P_RUN_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_FCST_JOB_LOG.CALC_REF_OBJECT_ID_5      (
         P_RUN_NO );
         RETURN ret_value;
   END CALC_REF_OBJECT_ID_5;
   FUNCTION CALC_REF_OBJECT_ID_7(
      P_RUN_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_FCST_JOB_LOG.CALC_REF_OBJECT_ID_7      (
         P_RUN_NO );
         RETURN ret_value;
   END CALC_REF_OBJECT_ID_7;
   FUNCTION DATE_2(
      P_RUN_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_FCST_JOB_LOG.DATE_2      (
         P_RUN_NO );
         RETURN ret_value;
   END DATE_2;
   FUNCTION END_DATE(
      P_RUN_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_FCST_JOB_LOG.END_DATE      (
         P_RUN_NO );
         RETURN ret_value;
   END END_DATE;
   FUNCTION PREV_DAYTIME(
      P_RUN_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_FCST_JOB_LOG.PREV_DAYTIME      (
         P_RUN_NO,
         P_NUM_ROWS );
         RETURN ret_value;
   END PREV_DAYTIME;
   FUNCTION RECORD_STATUS(
      P_RUN_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_FCST_JOB_LOG.RECORD_STATUS      (
         P_RUN_NO );
         RETURN ret_value;
   END RECORD_STATUS;
   FUNCTION TO_PERIOD(
      P_RUN_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_FCST_JOB_LOG.TO_PERIOD      (
         P_RUN_NO );
         RETURN ret_value;
   END TO_PERIOD;
   FUNCTION VALUE_1(
      P_RUN_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FCST_JOB_LOG.VALUE_1      (
         P_RUN_NO );
         RETURN ret_value;
   END VALUE_1;
   FUNCTION APPROVAL_DATE(
      P_RUN_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_FCST_JOB_LOG.APPROVAL_DATE      (
         P_RUN_NO );
         RETURN ret_value;
   END APPROVAL_DATE;
   FUNCTION CALC_DATE_3(
      P_RUN_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_FCST_JOB_LOG.CALC_DATE_3      (
         P_RUN_NO );
         RETURN ret_value;
   END CALC_DATE_3;
   FUNCTION CALC_DATE_5(
      P_RUN_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_FCST_JOB_LOG.CALC_DATE_5      (
         P_RUN_NO );
         RETURN ret_value;
   END CALC_DATE_5;
   FUNCTION CALC_TEXT_1(
      P_RUN_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_FCST_JOB_LOG.CALC_TEXT_1      (
         P_RUN_NO );
         RETURN ret_value;
   END CALC_TEXT_1;
   FUNCTION CALC_TEXT_4(
      P_RUN_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_FCST_JOB_LOG.CALC_TEXT_4      (
         P_RUN_NO );
         RETURN ret_value;
   END CALC_TEXT_4;
   FUNCTION CALC_VALUE_2(
      P_RUN_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FCST_JOB_LOG.CALC_VALUE_2      (
         P_RUN_NO );
         RETURN ret_value;
   END CALC_VALUE_2;
   FUNCTION FORECAST_ID(
      P_RUN_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_FCST_JOB_LOG.FORECAST_ID      (
         P_RUN_NO );
         RETURN ret_value;
   END FORECAST_ID;
   FUNCTION ROW_BY_PK(
      P_RUN_NO IN NUMBER)
      RETURN REC_ROW_BY_PK
   IS
      ret_value    REC_ROW_BY_PK ;
   BEGIN
      ret_value := EC_FCST_JOB_LOG.ROW_BY_PK      (
         P_RUN_NO );
         RETURN ret_value;
   END ROW_BY_PK;
   FUNCTION SCENARIO_ID(
      P_RUN_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_FCST_JOB_LOG.SCENARIO_ID      (
         P_RUN_NO );
         RETURN ret_value;
   END SCENARIO_ID;
   FUNCTION TEXT_2(
      P_RUN_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_FCST_JOB_LOG.TEXT_2      (
         P_RUN_NO );
         RETURN ret_value;
   END TEXT_2;
   FUNCTION TEXT_4(
      P_RUN_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_FCST_JOB_LOG.TEXT_4      (
         P_RUN_NO );
         RETURN ret_value;
   END TEXT_4;
   FUNCTION TEXT_5(
      P_RUN_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_FCST_JOB_LOG.TEXT_5      (
         P_RUN_NO );
         RETURN ret_value;
   END TEXT_5;
   FUNCTION VALUE_2(
      P_RUN_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FCST_JOB_LOG.VALUE_2      (
         P_RUN_NO );
         RETURN ret_value;
   END VALUE_2;
   FUNCTION VALUE_3(
      P_RUN_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FCST_JOB_LOG.VALUE_3      (
         P_RUN_NO );
         RETURN ret_value;
   END VALUE_3;
   FUNCTION VALUE_4(
      P_RUN_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FCST_JOB_LOG.VALUE_4      (
         P_RUN_NO );
         RETURN ret_value;
   END VALUE_4;
   FUNCTION DATE_4(
      P_RUN_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_FCST_JOB_LOG.DATE_4      (
         P_RUN_NO );
         RETURN ret_value;
   END DATE_4;
   FUNCTION FROM_PERIOD(
      P_RUN_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_FCST_JOB_LOG.FROM_PERIOD      (
         P_RUN_NO );
         RETURN ret_value;
   END FROM_PERIOD;
   FUNCTION LOG_SUMMARY(
      P_RUN_NO IN NUMBER)
      RETURN BLOB
   IS
      ret_value    BLOB ;
   BEGIN
      ret_value := EC_FCST_JOB_LOG.LOG_SUMMARY      (
         P_RUN_NO );
         RETURN ret_value;
   END LOG_SUMMARY;
   FUNCTION REC_ID(
      P_RUN_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_FCST_JOB_LOG.REC_ID      (
         P_RUN_NO );
         RETURN ret_value;
   END REC_ID;
   FUNCTION CALC_DATE_2(
      P_RUN_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_FCST_JOB_LOG.CALC_DATE_2      (
         P_RUN_NO );
         RETURN ret_value;
   END CALC_DATE_2;
   FUNCTION CALC_VALUE_3(
      P_RUN_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FCST_JOB_LOG.CALC_VALUE_3      (
         P_RUN_NO );
         RETURN ret_value;
   END CALC_VALUE_3;
   FUNCTION DATE_1(
      P_RUN_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_FCST_JOB_LOG.DATE_1      (
         P_RUN_NO );
         RETURN ret_value;
   END DATE_1;
   FUNCTION DAYTIME(
      P_RUN_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_FCST_JOB_LOG.DAYTIME      (
         P_RUN_NO );
         RETURN ret_value;
   END DAYTIME;

END RP_FCST_JOB_LOG;

/
--GRANT EXECUTE ON ECKERNEL_WST.RP_FCST_JOB_LOG TO REPORT_ROLE_XXX;



 -- FINISH PKG_GEN_PKGS.sf_get_functions at:11/15/2018 09.49.28 AM


