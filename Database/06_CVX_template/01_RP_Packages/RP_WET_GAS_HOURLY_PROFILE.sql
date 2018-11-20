
 -- START PKG_GEN_PKGS.sf_get_functions at:11/15/2018 07.05.32 AM


CREATE or REPLACE PACKAGE RP_WET_GAS_HOURLY_PROFILE
IS

   FUNCTION TEXT_3(
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=',
      P_SUMMERTIME IN VARCHAR2 DEFAULT NULL)
      RETURN VARCHAR2;
   FUNCTION TEXT_4(
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=',
      P_SUMMERTIME IN VARCHAR2 DEFAULT NULL)
      RETURN VARCHAR2;
   FUNCTION TIME_ZONE(
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=',
      P_SUMMERTIME IN VARCHAR2 DEFAULT NULL)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_BY(
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=',
      P_SUMMERTIME IN VARCHAR2 DEFAULT NULL)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_STATE(
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=',
      P_SUMMERTIME IN VARCHAR2 DEFAULT NULL)
      RETURN VARCHAR2;
   FUNCTION VALUE_5(
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=',
      P_SUMMERTIME IN VARCHAR2 DEFAULT NULL)
      RETURN NUMBER;
   FUNCTION NEXT_DAYTIME(
      P_DAYTIME IN DATE,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION PREV_EQUAL_DAYTIME(
      P_DAYTIME IN DATE,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION NEXT_EQUAL_DAYTIME(
      P_DAYTIME IN DATE,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION UTC_DAYTIME(
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=',
      P_SUMMERTIME IN VARCHAR2 DEFAULT NULL)
      RETURN DATE;
   FUNCTION VALUE_6(
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=',
      P_SUMMERTIME IN VARCHAR2 DEFAULT NULL)
      RETURN NUMBER;
   FUNCTION PREV_DAYTIME(
      P_DAYTIME IN DATE,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION RECORD_STATUS(
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=',
      P_SUMMERTIME IN VARCHAR2 DEFAULT NULL)
      RETURN VARCHAR2;
   FUNCTION VALUE_1(
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=',
      P_SUMMERTIME IN VARCHAR2 DEFAULT NULL)
      RETURN NUMBER;
   FUNCTION APPROVAL_DATE(
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=',
      P_SUMMERTIME IN VARCHAR2 DEFAULT NULL)
      RETURN DATE;
      TYPE REC_ROW_BY_PK IS RECORD (
         DAYTIME  DATE ,
         SUMMER_TIME VARCHAR2 (1) ,
         PRODUCTION_DAY  DATE ,
         FLOW_RATE NUMBER ,
         RECORD_STATUS VARCHAR2 (1) ,
         CREATED_BY VARCHAR2 (30) ,
         CREATED_DATE  DATE ,
         LAST_UPDATED_BY VARCHAR2 (30) ,
         LAST_UPDATED_DATE  DATE ,
         REV_NO NUMBER ,
         REV_TEXT VARCHAR2 (2000) ,
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
         APPROVAL_BY VARCHAR2 (30) ,
         APPROVAL_DATE  DATE ,
         APPROVAL_STATE VARCHAR2 (1) ,
         REC_ID VARCHAR2 (32) ,
         TIME_ZONE VARCHAR2 (65) ,
         UTC_DAYTIME  DATE  );
   FUNCTION ROW_BY_PK(
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN REC_ROW_BY_PK;
      TYPE REC_ROW_BY_REL_OPERATOR IS RECORD (
         DAYTIME  DATE ,
         SUMMER_TIME VARCHAR2 (1) ,
         PRODUCTION_DAY  DATE ,
         FLOW_RATE NUMBER ,
         RECORD_STATUS VARCHAR2 (1) ,
         CREATED_BY VARCHAR2 (30) ,
         CREATED_DATE  DATE ,
         LAST_UPDATED_BY VARCHAR2 (30) ,
         LAST_UPDATED_DATE  DATE ,
         REV_NO NUMBER ,
         REV_TEXT VARCHAR2 (2000) ,
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
         APPROVAL_BY VARCHAR2 (30) ,
         APPROVAL_DATE  DATE ,
         APPROVAL_STATE VARCHAR2 (1) ,
         REC_ID VARCHAR2 (32) ,
         TIME_ZONE VARCHAR2 (65) ,
         UTC_DAYTIME  DATE  );
   FUNCTION ROW_BY_REL_OPERATOR(
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=',
      P_SUMMERTIME IN VARCHAR2 DEFAULT NULL)
      RETURN REC_ROW_BY_REL_OPERATOR;
   FUNCTION VALUE_2(
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=',
      P_SUMMERTIME IN VARCHAR2 DEFAULT NULL)
      RETURN NUMBER;
   FUNCTION VALUE_3(
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=',
      P_SUMMERTIME IN VARCHAR2 DEFAULT NULL)
      RETURN NUMBER;
   FUNCTION VALUE_4(
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=',
      P_SUMMERTIME IN VARCHAR2 DEFAULT NULL)
      RETURN NUMBER;
   FUNCTION REC_ID(
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=',
      P_SUMMERTIME IN VARCHAR2 DEFAULT NULL)
      RETURN VARCHAR2;
   FUNCTION TEXT_1(
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=',
      P_SUMMERTIME IN VARCHAR2 DEFAULT NULL)
      RETURN VARCHAR2;
   FUNCTION TEXT_2(
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=',
      P_SUMMERTIME IN VARCHAR2 DEFAULT NULL)
      RETURN VARCHAR2;
   FUNCTION VALUE_7(
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=',
      P_SUMMERTIME IN VARCHAR2 DEFAULT NULL)
      RETURN NUMBER;
   FUNCTION VALUE_9(
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=',
      P_SUMMERTIME IN VARCHAR2 DEFAULT NULL)
      RETURN NUMBER;
   FUNCTION FLOW_RATE(
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=',
      P_SUMMERTIME IN VARCHAR2 DEFAULT NULL)
      RETURN NUMBER;
   FUNCTION PRODUCTION_DAY(
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=',
      P_SUMMERTIME IN VARCHAR2 DEFAULT NULL)
      RETURN DATE;
   FUNCTION VALUE_10(
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=',
      P_SUMMERTIME IN VARCHAR2 DEFAULT NULL)
      RETURN NUMBER;
   FUNCTION VALUE_8(
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=',
      P_SUMMERTIME IN VARCHAR2 DEFAULT NULL)
      RETURN NUMBER;

END RP_WET_GAS_HOURLY_PROFILE;

/



CREATE or REPLACE PACKAGE BODY RP_WET_GAS_HOURLY_PROFILE
IS

   FUNCTION TEXT_3(
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=',
      P_SUMMERTIME IN VARCHAR2 DEFAULT NULL)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_WET_GAS_HOURLY_PROFILE.TEXT_3      (
         P_DAYTIME,
         P_COMPARE_OPER,
         P_SUMMERTIME );
         RETURN ret_value;
   END TEXT_3;
   FUNCTION TEXT_4(
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=',
      P_SUMMERTIME IN VARCHAR2 DEFAULT NULL)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_WET_GAS_HOURLY_PROFILE.TEXT_4      (
         P_DAYTIME,
         P_COMPARE_OPER,
         P_SUMMERTIME );
         RETURN ret_value;
   END TEXT_4;
   FUNCTION TIME_ZONE(
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=',
      P_SUMMERTIME IN VARCHAR2 DEFAULT NULL)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (65) ;
   BEGIN
      ret_value := EC_WET_GAS_HOURLY_PROFILE.TIME_ZONE      (
         P_DAYTIME,
         P_COMPARE_OPER,
         P_SUMMERTIME );
         RETURN ret_value;
   END TIME_ZONE;
   FUNCTION APPROVAL_BY(
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=',
      P_SUMMERTIME IN VARCHAR2 DEFAULT NULL)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (30) ;
   BEGIN
      ret_value := EC_WET_GAS_HOURLY_PROFILE.APPROVAL_BY      (
         P_DAYTIME,
         P_COMPARE_OPER,
         P_SUMMERTIME );
         RETURN ret_value;
   END APPROVAL_BY;
   FUNCTION APPROVAL_STATE(
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=',
      P_SUMMERTIME IN VARCHAR2 DEFAULT NULL)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_WET_GAS_HOURLY_PROFILE.APPROVAL_STATE      (
         P_DAYTIME,
         P_COMPARE_OPER,
         P_SUMMERTIME );
         RETURN ret_value;
   END APPROVAL_STATE;
   FUNCTION VALUE_5(
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=',
      P_SUMMERTIME IN VARCHAR2 DEFAULT NULL)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_WET_GAS_HOURLY_PROFILE.VALUE_5      (
         P_DAYTIME,
         P_COMPARE_OPER,
         P_SUMMERTIME );
         RETURN ret_value;
   END VALUE_5;
   FUNCTION NEXT_DAYTIME(
      P_DAYTIME IN DATE,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_WET_GAS_HOURLY_PROFILE.NEXT_DAYTIME      (
         P_DAYTIME,
         P_NUM_ROWS );
         RETURN ret_value;
   END NEXT_DAYTIME;
   FUNCTION PREV_EQUAL_DAYTIME(
      P_DAYTIME IN DATE,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_WET_GAS_HOURLY_PROFILE.PREV_EQUAL_DAYTIME      (
         P_DAYTIME,
         P_NUM_ROWS );
         RETURN ret_value;
   END PREV_EQUAL_DAYTIME;
   FUNCTION NEXT_EQUAL_DAYTIME(
      P_DAYTIME IN DATE,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_WET_GAS_HOURLY_PROFILE.NEXT_EQUAL_DAYTIME      (
         P_DAYTIME,
         P_NUM_ROWS );
         RETURN ret_value;
   END NEXT_EQUAL_DAYTIME;
   FUNCTION UTC_DAYTIME(
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=',
      P_SUMMERTIME IN VARCHAR2 DEFAULT NULL)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_WET_GAS_HOURLY_PROFILE.UTC_DAYTIME      (
         P_DAYTIME,
         P_COMPARE_OPER,
         P_SUMMERTIME );
         RETURN ret_value;
   END UTC_DAYTIME;
   FUNCTION VALUE_6(
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=',
      P_SUMMERTIME IN VARCHAR2 DEFAULT NULL)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_WET_GAS_HOURLY_PROFILE.VALUE_6      (
         P_DAYTIME,
         P_COMPARE_OPER,
         P_SUMMERTIME );
         RETURN ret_value;
   END VALUE_6;
   FUNCTION PREV_DAYTIME(
      P_DAYTIME IN DATE,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_WET_GAS_HOURLY_PROFILE.PREV_DAYTIME      (
         P_DAYTIME,
         P_NUM_ROWS );
         RETURN ret_value;
   END PREV_DAYTIME;
   FUNCTION RECORD_STATUS(
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=',
      P_SUMMERTIME IN VARCHAR2 DEFAULT NULL)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_WET_GAS_HOURLY_PROFILE.RECORD_STATUS      (
         P_DAYTIME,
         P_COMPARE_OPER,
         P_SUMMERTIME );
         RETURN ret_value;
   END RECORD_STATUS;
   FUNCTION VALUE_1(
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=',
      P_SUMMERTIME IN VARCHAR2 DEFAULT NULL)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_WET_GAS_HOURLY_PROFILE.VALUE_1      (
         P_DAYTIME,
         P_COMPARE_OPER,
         P_SUMMERTIME );
         RETURN ret_value;
   END VALUE_1;
   FUNCTION APPROVAL_DATE(
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=',
      P_SUMMERTIME IN VARCHAR2 DEFAULT NULL)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_WET_GAS_HOURLY_PROFILE.APPROVAL_DATE      (
         P_DAYTIME,
         P_COMPARE_OPER,
         P_SUMMERTIME );
         RETURN ret_value;
   END APPROVAL_DATE;
   FUNCTION ROW_BY_PK(
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=')
      RETURN REC_ROW_BY_PK
   IS
      ret_value    REC_ROW_BY_PK ;
   BEGIN
      ret_value := EC_WET_GAS_HOURLY_PROFILE.ROW_BY_PK      (
         P_DAYTIME,
         P_COMPARE_OPER );
         RETURN ret_value;
   END ROW_BY_PK;
   FUNCTION ROW_BY_REL_OPERATOR(
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=',
      P_SUMMERTIME IN VARCHAR2 DEFAULT NULL)
      RETURN REC_ROW_BY_REL_OPERATOR
   IS
      ret_value    REC_ROW_BY_REL_OPERATOR ;
   BEGIN
      ret_value := EC_WET_GAS_HOURLY_PROFILE.ROW_BY_REL_OPERATOR      (
         P_DAYTIME,
         P_COMPARE_OPER,
         P_SUMMERTIME );
         RETURN ret_value;
   END ROW_BY_REL_OPERATOR;
   FUNCTION VALUE_2(
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=',
      P_SUMMERTIME IN VARCHAR2 DEFAULT NULL)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_WET_GAS_HOURLY_PROFILE.VALUE_2      (
         P_DAYTIME,
         P_COMPARE_OPER,
         P_SUMMERTIME );
         RETURN ret_value;
   END VALUE_2;
   FUNCTION VALUE_3(
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=',
      P_SUMMERTIME IN VARCHAR2 DEFAULT NULL)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_WET_GAS_HOURLY_PROFILE.VALUE_3      (
         P_DAYTIME,
         P_COMPARE_OPER,
         P_SUMMERTIME );
         RETURN ret_value;
   END VALUE_3;
   FUNCTION VALUE_4(
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=',
      P_SUMMERTIME IN VARCHAR2 DEFAULT NULL)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_WET_GAS_HOURLY_PROFILE.VALUE_4      (
         P_DAYTIME,
         P_COMPARE_OPER,
         P_SUMMERTIME );
         RETURN ret_value;
   END VALUE_4;
   FUNCTION REC_ID(
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=',
      P_SUMMERTIME IN VARCHAR2 DEFAULT NULL)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_WET_GAS_HOURLY_PROFILE.REC_ID      (
         P_DAYTIME,
         P_COMPARE_OPER,
         P_SUMMERTIME );
         RETURN ret_value;
   END REC_ID;
   FUNCTION TEXT_1(
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=',
      P_SUMMERTIME IN VARCHAR2 DEFAULT NULL)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (16) ;
   BEGIN
      ret_value := EC_WET_GAS_HOURLY_PROFILE.TEXT_1      (
         P_DAYTIME,
         P_COMPARE_OPER,
         P_SUMMERTIME );
         RETURN ret_value;
   END TEXT_1;
   FUNCTION TEXT_2(
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=',
      P_SUMMERTIME IN VARCHAR2 DEFAULT NULL)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_WET_GAS_HOURLY_PROFILE.TEXT_2      (
         P_DAYTIME,
         P_COMPARE_OPER,
         P_SUMMERTIME );
         RETURN ret_value;
   END TEXT_2;
   FUNCTION VALUE_7(
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=',
      P_SUMMERTIME IN VARCHAR2 DEFAULT NULL)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_WET_GAS_HOURLY_PROFILE.VALUE_7      (
         P_DAYTIME,
         P_COMPARE_OPER,
         P_SUMMERTIME );
         RETURN ret_value;
   END VALUE_7;
   FUNCTION VALUE_9(
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=',
      P_SUMMERTIME IN VARCHAR2 DEFAULT NULL)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_WET_GAS_HOURLY_PROFILE.VALUE_9      (
         P_DAYTIME,
         P_COMPARE_OPER,
         P_SUMMERTIME );
         RETURN ret_value;
   END VALUE_9;
   FUNCTION FLOW_RATE(
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=',
      P_SUMMERTIME IN VARCHAR2 DEFAULT NULL)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_WET_GAS_HOURLY_PROFILE.FLOW_RATE      (
         P_DAYTIME,
         P_COMPARE_OPER,
         P_SUMMERTIME );
         RETURN ret_value;
   END FLOW_RATE;
   FUNCTION PRODUCTION_DAY(
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=',
      P_SUMMERTIME IN VARCHAR2 DEFAULT NULL)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_WET_GAS_HOURLY_PROFILE.PRODUCTION_DAY      (
         P_DAYTIME,
         P_COMPARE_OPER,
         P_SUMMERTIME );
         RETURN ret_value;
   END PRODUCTION_DAY;
   FUNCTION VALUE_10(
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=',
      P_SUMMERTIME IN VARCHAR2 DEFAULT NULL)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_WET_GAS_HOURLY_PROFILE.VALUE_10      (
         P_DAYTIME,
         P_COMPARE_OPER,
         P_SUMMERTIME );
         RETURN ret_value;
   END VALUE_10;
   FUNCTION VALUE_8(
      P_DAYTIME IN DATE,
      P_COMPARE_OPER IN VARCHAR2 DEFAULT '=',
      P_SUMMERTIME IN VARCHAR2 DEFAULT NULL)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_WET_GAS_HOURLY_PROFILE.VALUE_8      (
         P_DAYTIME,
         P_COMPARE_OPER,
         P_SUMMERTIME );
         RETURN ret_value;
   END VALUE_8;

END RP_WET_GAS_HOURLY_PROFILE;

/
--GRANT EXECUTE ON ECKERNEL_WST.RP_WET_GAS_HOURLY_PROFILE TO REPORT_ROLE_XXX;



 -- FINISH PKG_GEN_PKGS.sf_get_functions at:11/15/2018 07.05.42 AM

