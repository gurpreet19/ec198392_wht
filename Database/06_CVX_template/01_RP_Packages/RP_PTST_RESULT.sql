
 -- START PKG_GEN_PKGS.sf_get_functions at:11/15/2018 08.16.57 AM


CREATE or REPLACE PACKAGE RP_PTST_RESULT
IS

   FUNCTION ESTIMATE_TYPE(
      P_RESULT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION FACILITY_ID(
      P_RESULT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_3(
      P_RESULT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_4(
      P_RESULT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION USE_CALC(
      P_RESULT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_BY(
      P_RESULT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_STATE(
      P_RESULT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION DURATION(
      P_RESULT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION STATUS(
      P_RESULT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_5(
      P_RESULT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION MEAS_SPECIFIC_GRAVITY(
      P_RESULT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION NEXT_DAYTIME(
      P_RESULT_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION PREV_EQUAL_DAYTIME(
      P_RESULT_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION CLASS_NAME(
      P_RESULT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION COMMENTS(
      P_RESULT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION NEXT_EQUAL_DAYTIME(
      P_RESULT_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION VALUE_6(
      P_RESULT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION END_DATE(
      P_RESULT_NO IN NUMBER)
      RETURN DATE;
   FUNCTION PREPROCESS_LOG(
      P_RESULT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION PREV_DAYTIME(
      P_RESULT_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION RECORD_STATUS(
      P_RESULT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TREND_ANALYSIS_IND(
      P_RESULT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_1(
      P_RESULT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION APPROVAL_DATE(
      P_RESULT_NO IN NUMBER)
      RETURN DATE;
   FUNCTION PURGE_DURATION(
      P_RESULT_NO IN NUMBER)
      RETURN VARCHAR2;
      TYPE REC_ROW_BY_PK IS RECORD (
         RESULT_NO NUMBER ,
         DAYTIME  DATE ,
         END_DATE  DATE ,
         DURATION NUMBER ,
         PRODUCTION_DAY  DATE ,
         TEST_TYPE VARCHAR2 (32) ,
         ESTIMATE_TYPE VARCHAR2 (32) ,
         TEST_NO NUMBER ,
         SUMMARISED_IND VARCHAR2 (1) ,
         TREND_ANALYSIS_IND VARCHAR2 (1) ,
         VALID_FROM_DATE  DATE ,
         STATUS VARCHAR2 (32) ,
         PREPROCESS_LOG VARCHAR2 (3000) ,
         USE_CALC VARCHAR2 (1) ,
         CLASS_NAME VARCHAR2 (24) ,
         FACILITY_ID VARCHAR2 (32) ,
         COLLECTION_POINT_ID VARCHAR2 (32) ,
         PURGE_DURATION VARCHAR2 (32) ,
         WELL_TEST_REASON VARCHAR2 (32) ,
         MEAS_SPECIFIC_GRAVITY NUMBER ,
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
         ACCEPTED_DATE  DATE  );
   FUNCTION ROW_BY_PK(
      P_RESULT_NO IN NUMBER)
      RETURN REC_ROW_BY_PK;
   FUNCTION SUMMARISED_IND(
      P_RESULT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_2(
      P_RESULT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_3(
      P_RESULT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_4(
      P_RESULT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION REC_ID(
      P_RESULT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_1(
      P_RESULT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_2(
      P_RESULT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALID_FROM_DATE(
      P_RESULT_NO IN NUMBER)
      RETURN DATE;
   FUNCTION VALUE_7(
      P_RESULT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_9(
      P_RESULT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION ACCEPTED_DATE(
      P_RESULT_NO IN NUMBER)
      RETURN DATE;
   FUNCTION COLLECTION_POINT_ID(
      P_RESULT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION DAYTIME(
      P_RESULT_NO IN NUMBER)
      RETURN DATE;
   FUNCTION PRODUCTION_DAY(
      P_RESULT_NO IN NUMBER)
      RETURN DATE;
   FUNCTION TEST_NO(
      P_RESULT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION TEST_TYPE(
      P_RESULT_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_10(
      P_RESULT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_8(
      P_RESULT_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION WELL_TEST_REASON(
      P_RESULT_NO IN NUMBER)
      RETURN VARCHAR2;

END RP_PTST_RESULT;

/



CREATE or REPLACE PACKAGE BODY RP_PTST_RESULT
IS

   FUNCTION ESTIMATE_TYPE(
      P_RESULT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_PTST_RESULT.ESTIMATE_TYPE      (
         P_RESULT_NO );
         RETURN ret_value;
   END ESTIMATE_TYPE;
   FUNCTION FACILITY_ID(
      P_RESULT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_PTST_RESULT.FACILITY_ID      (
         P_RESULT_NO );
         RETURN ret_value;
   END FACILITY_ID;
   FUNCTION TEXT_3(
      P_RESULT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_PTST_RESULT.TEXT_3      (
         P_RESULT_NO );
         RETURN ret_value;
   END TEXT_3;
   FUNCTION TEXT_4(
      P_RESULT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_PTST_RESULT.TEXT_4      (
         P_RESULT_NO );
         RETURN ret_value;
   END TEXT_4;
   FUNCTION USE_CALC(
      P_RESULT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_PTST_RESULT.USE_CALC      (
         P_RESULT_NO );
         RETURN ret_value;
   END USE_CALC;
   FUNCTION APPROVAL_BY(
      P_RESULT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (30) ;
   BEGIN
      ret_value := EC_PTST_RESULT.APPROVAL_BY      (
         P_RESULT_NO );
         RETURN ret_value;
   END APPROVAL_BY;
   FUNCTION APPROVAL_STATE(
      P_RESULT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_PTST_RESULT.APPROVAL_STATE      (
         P_RESULT_NO );
         RETURN ret_value;
   END APPROVAL_STATE;
   FUNCTION DURATION(
      P_RESULT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_PTST_RESULT.DURATION      (
         P_RESULT_NO );
         RETURN ret_value;
   END DURATION;
   FUNCTION STATUS(
      P_RESULT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_PTST_RESULT.STATUS      (
         P_RESULT_NO );
         RETURN ret_value;
   END STATUS;
   FUNCTION VALUE_5(
      P_RESULT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_PTST_RESULT.VALUE_5      (
         P_RESULT_NO );
         RETURN ret_value;
   END VALUE_5;
   FUNCTION MEAS_SPECIFIC_GRAVITY(
      P_RESULT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_PTST_RESULT.MEAS_SPECIFIC_GRAVITY      (
         P_RESULT_NO );
         RETURN ret_value;
   END MEAS_SPECIFIC_GRAVITY;
   FUNCTION NEXT_DAYTIME(
      P_RESULT_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_PTST_RESULT.NEXT_DAYTIME      (
         P_RESULT_NO,
         P_NUM_ROWS );
         RETURN ret_value;
   END NEXT_DAYTIME;
   FUNCTION PREV_EQUAL_DAYTIME(
      P_RESULT_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_PTST_RESULT.PREV_EQUAL_DAYTIME      (
         P_RESULT_NO,
         P_NUM_ROWS );
         RETURN ret_value;
   END PREV_EQUAL_DAYTIME;
   FUNCTION CLASS_NAME(
      P_RESULT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (24) ;
   BEGIN
      ret_value := EC_PTST_RESULT.CLASS_NAME      (
         P_RESULT_NO );
         RETURN ret_value;
   END CLASS_NAME;
   FUNCTION COMMENTS(
      P_RESULT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_PTST_RESULT.COMMENTS      (
         P_RESULT_NO );
         RETURN ret_value;
   END COMMENTS;
   FUNCTION NEXT_EQUAL_DAYTIME(
      P_RESULT_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_PTST_RESULT.NEXT_EQUAL_DAYTIME      (
         P_RESULT_NO,
         P_NUM_ROWS );
         RETURN ret_value;
   END NEXT_EQUAL_DAYTIME;
   FUNCTION VALUE_6(
      P_RESULT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_PTST_RESULT.VALUE_6      (
         P_RESULT_NO );
         RETURN ret_value;
   END VALUE_6;
   FUNCTION END_DATE(
      P_RESULT_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_PTST_RESULT.END_DATE      (
         P_RESULT_NO );
         RETURN ret_value;
   END END_DATE;
   FUNCTION PREPROCESS_LOG(
      P_RESULT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (3000) ;
   BEGIN
      ret_value := EC_PTST_RESULT.PREPROCESS_LOG      (
         P_RESULT_NO );
         RETURN ret_value;
   END PREPROCESS_LOG;
   FUNCTION PREV_DAYTIME(
      P_RESULT_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_PTST_RESULT.PREV_DAYTIME      (
         P_RESULT_NO,
         P_NUM_ROWS );
         RETURN ret_value;
   END PREV_DAYTIME;
   FUNCTION RECORD_STATUS(
      P_RESULT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_PTST_RESULT.RECORD_STATUS      (
         P_RESULT_NO );
         RETURN ret_value;
   END RECORD_STATUS;
   FUNCTION TREND_ANALYSIS_IND(
      P_RESULT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_PTST_RESULT.TREND_ANALYSIS_IND      (
         P_RESULT_NO );
         RETURN ret_value;
   END TREND_ANALYSIS_IND;
   FUNCTION VALUE_1(
      P_RESULT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_PTST_RESULT.VALUE_1      (
         P_RESULT_NO );
         RETURN ret_value;
   END VALUE_1;
   FUNCTION APPROVAL_DATE(
      P_RESULT_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_PTST_RESULT.APPROVAL_DATE      (
         P_RESULT_NO );
         RETURN ret_value;
   END APPROVAL_DATE;
   FUNCTION PURGE_DURATION(
      P_RESULT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_PTST_RESULT.PURGE_DURATION      (
         P_RESULT_NO );
         RETURN ret_value;
   END PURGE_DURATION;
   FUNCTION ROW_BY_PK(
      P_RESULT_NO IN NUMBER)
      RETURN REC_ROW_BY_PK
   IS
      ret_value    REC_ROW_BY_PK ;
   BEGIN
      ret_value := EC_PTST_RESULT.ROW_BY_PK      (
         P_RESULT_NO );
         RETURN ret_value;
   END ROW_BY_PK;
   FUNCTION SUMMARISED_IND(
      P_RESULT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_PTST_RESULT.SUMMARISED_IND      (
         P_RESULT_NO );
         RETURN ret_value;
   END SUMMARISED_IND;
   FUNCTION VALUE_2(
      P_RESULT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_PTST_RESULT.VALUE_2      (
         P_RESULT_NO );
         RETURN ret_value;
   END VALUE_2;
   FUNCTION VALUE_3(
      P_RESULT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_PTST_RESULT.VALUE_3      (
         P_RESULT_NO );
         RETURN ret_value;
   END VALUE_3;
   FUNCTION VALUE_4(
      P_RESULT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_PTST_RESULT.VALUE_4      (
         P_RESULT_NO );
         RETURN ret_value;
   END VALUE_4;
   FUNCTION REC_ID(
      P_RESULT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_PTST_RESULT.REC_ID      (
         P_RESULT_NO );
         RETURN ret_value;
   END REC_ID;
   FUNCTION TEXT_1(
      P_RESULT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (16) ;
   BEGIN
      ret_value := EC_PTST_RESULT.TEXT_1      (
         P_RESULT_NO );
         RETURN ret_value;
   END TEXT_1;
   FUNCTION TEXT_2(
      P_RESULT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_PTST_RESULT.TEXT_2      (
         P_RESULT_NO );
         RETURN ret_value;
   END TEXT_2;
   FUNCTION VALID_FROM_DATE(
      P_RESULT_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_PTST_RESULT.VALID_FROM_DATE      (
         P_RESULT_NO );
         RETURN ret_value;
   END VALID_FROM_DATE;
   FUNCTION VALUE_7(
      P_RESULT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_PTST_RESULT.VALUE_7      (
         P_RESULT_NO );
         RETURN ret_value;
   END VALUE_7;
   FUNCTION VALUE_9(
      P_RESULT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_PTST_RESULT.VALUE_9      (
         P_RESULT_NO );
         RETURN ret_value;
   END VALUE_9;
   FUNCTION ACCEPTED_DATE(
      P_RESULT_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_PTST_RESULT.ACCEPTED_DATE      (
         P_RESULT_NO );
         RETURN ret_value;
   END ACCEPTED_DATE;
   FUNCTION COLLECTION_POINT_ID(
      P_RESULT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_PTST_RESULT.COLLECTION_POINT_ID      (
         P_RESULT_NO );
         RETURN ret_value;
   END COLLECTION_POINT_ID;
   FUNCTION DAYTIME(
      P_RESULT_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_PTST_RESULT.DAYTIME      (
         P_RESULT_NO );
         RETURN ret_value;
   END DAYTIME;
   FUNCTION PRODUCTION_DAY(
      P_RESULT_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_PTST_RESULT.PRODUCTION_DAY      (
         P_RESULT_NO );
         RETURN ret_value;
   END PRODUCTION_DAY;
   FUNCTION TEST_NO(
      P_RESULT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_PTST_RESULT.TEST_NO      (
         P_RESULT_NO );
         RETURN ret_value;
   END TEST_NO;
   FUNCTION TEST_TYPE(
      P_RESULT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_PTST_RESULT.TEST_TYPE      (
         P_RESULT_NO );
         RETURN ret_value;
   END TEST_TYPE;
   FUNCTION VALUE_10(
      P_RESULT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_PTST_RESULT.VALUE_10      (
         P_RESULT_NO );
         RETURN ret_value;
   END VALUE_10;
   FUNCTION VALUE_8(
      P_RESULT_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_PTST_RESULT.VALUE_8      (
         P_RESULT_NO );
         RETURN ret_value;
   END VALUE_8;
   FUNCTION WELL_TEST_REASON(
      P_RESULT_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_PTST_RESULT.WELL_TEST_REASON      (
         P_RESULT_NO );
         RETURN ret_value;
   END WELL_TEST_REASON;

END RP_PTST_RESULT;

/
--GRANT EXECUTE ON ECKERNEL_WST.RP_PTST_RESULT TO REPORT_ROLE_XXX;



 -- FINISH PKG_GEN_PKGS.sf_get_functions at:11/15/2018 08.17.06 AM


