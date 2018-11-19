
 -- START PKG_GEN_PKGS.sf_get_functions at:11/15/2018 09.42.02 AM


CREATE or REPLACE PACKAGE RP_FCST_PROD_CURVES
IS

   FUNCTION TEXT_3(
      P_FCST_CURVE_ID IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_4(
      P_FCST_CURVE_ID IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_BY(
      P_FCST_CURVE_ID IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_STATE(
      P_FCST_CURVE_ID IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_5(
      P_FCST_CURVE_ID IN NUMBER)
      RETURN NUMBER;
   FUNCTION NEXT_DAYTIME(
      P_FCST_CURVE_ID IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION PREV_EQUAL_DAYTIME(
      P_FCST_CURVE_ID IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION COMMENTS(
      P_FCST_CURVE_ID IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION DATE_3(
      P_FCST_CURVE_ID IN NUMBER)
      RETURN DATE;
   FUNCTION DATE_5(
      P_FCST_CURVE_ID IN NUMBER)
      RETURN DATE;
   FUNCTION NEXT_EQUAL_DAYTIME(
      P_FCST_CURVE_ID IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION VALUE_6(
      P_FCST_CURVE_ID IN NUMBER)
      RETURN NUMBER;
   FUNCTION DATE_2(
      P_FCST_CURVE_ID IN NUMBER)
      RETURN DATE;
   FUNCTION END_DATE(
      P_FCST_CURVE_ID IN NUMBER)
      RETURN DATE;
   FUNCTION PREV_DAYTIME(
      P_FCST_CURVE_ID IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION RECORD_STATUS(
      P_FCST_CURVE_ID IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_1(
      P_FCST_CURVE_ID IN NUMBER)
      RETURN NUMBER;
   FUNCTION APPROVAL_DATE(
      P_FCST_CURVE_ID IN NUMBER)
      RETURN DATE;
   FUNCTION CURVE_TYPE(
      P_FCST_CURVE_ID IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION FORECAST_ID(
      P_FCST_CURVE_ID IN NUMBER)
      RETURN VARCHAR2;
      TYPE REC_ROW_BY_PK IS RECORD (
         FCST_CURVE_ID NUMBER ,
         DAYTIME  DATE ,
         FORECAST_ID VARCHAR2 (32) ,
         SCENARIO_ID VARCHAR2 (32) ,
         FORECAST_TYPE VARCHAR2 (32) ,
         WELL_ID VARCHAR2 (32) ,
         CURVE_TYPE VARCHAR2 (32) ,
         CLASS_NAME VARCHAR2 (32) ,
         INCLUDE_FLAG VARCHAR2 (1) ,
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
      P_FCST_CURVE_ID IN NUMBER)
      RETURN REC_ROW_BY_PK;
   FUNCTION SCENARIO_ID(
      P_FCST_CURVE_ID IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_2(
      P_FCST_CURVE_ID IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_3(
      P_FCST_CURVE_ID IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_4(
      P_FCST_CURVE_ID IN NUMBER)
      RETURN NUMBER;
   FUNCTION CLASS_NAME(
      P_FCST_CURVE_ID IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION DATE_4(
      P_FCST_CURVE_ID IN NUMBER)
      RETURN DATE;
   FUNCTION FORECAST_TYPE(
      P_FCST_CURVE_ID IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION REC_ID(
      P_FCST_CURVE_ID IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_1(
      P_FCST_CURVE_ID IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_2(
      P_FCST_CURVE_ID IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_7(
      P_FCST_CURVE_ID IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_9(
      P_FCST_CURVE_ID IN NUMBER)
      RETURN NUMBER;
   FUNCTION DATE_1(
      P_FCST_CURVE_ID IN NUMBER)
      RETURN DATE;
   FUNCTION DAYTIME(
      P_FCST_CURVE_ID IN NUMBER)
      RETURN DATE;
   FUNCTION INCLUDE_FLAG(
      P_FCST_CURVE_ID IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_10(
      P_FCST_CURVE_ID IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_8(
      P_FCST_CURVE_ID IN NUMBER)
      RETURN NUMBER;
   FUNCTION WELL_ID(
      P_FCST_CURVE_ID IN NUMBER)
      RETURN VARCHAR2;

END RP_FCST_PROD_CURVES;

/



CREATE or REPLACE PACKAGE BODY RP_FCST_PROD_CURVES
IS

   FUNCTION TEXT_3(
      P_FCST_CURVE_ID IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_FCST_PROD_CURVES.TEXT_3      (
         P_FCST_CURVE_ID );
         RETURN ret_value;
   END TEXT_3;
   FUNCTION TEXT_4(
      P_FCST_CURVE_ID IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_FCST_PROD_CURVES.TEXT_4      (
         P_FCST_CURVE_ID );
         RETURN ret_value;
   END TEXT_4;
   FUNCTION APPROVAL_BY(
      P_FCST_CURVE_ID IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (30) ;
   BEGIN
      ret_value := EC_FCST_PROD_CURVES.APPROVAL_BY      (
         P_FCST_CURVE_ID );
         RETURN ret_value;
   END APPROVAL_BY;
   FUNCTION APPROVAL_STATE(
      P_FCST_CURVE_ID IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_FCST_PROD_CURVES.APPROVAL_STATE      (
         P_FCST_CURVE_ID );
         RETURN ret_value;
   END APPROVAL_STATE;
   FUNCTION VALUE_5(
      P_FCST_CURVE_ID IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FCST_PROD_CURVES.VALUE_5      (
         P_FCST_CURVE_ID );
         RETURN ret_value;
   END VALUE_5;
   FUNCTION NEXT_DAYTIME(
      P_FCST_CURVE_ID IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_FCST_PROD_CURVES.NEXT_DAYTIME      (
         P_FCST_CURVE_ID,
         P_NUM_ROWS );
         RETURN ret_value;
   END NEXT_DAYTIME;
   FUNCTION PREV_EQUAL_DAYTIME(
      P_FCST_CURVE_ID IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_FCST_PROD_CURVES.PREV_EQUAL_DAYTIME      (
         P_FCST_CURVE_ID,
         P_NUM_ROWS );
         RETURN ret_value;
   END PREV_EQUAL_DAYTIME;
   FUNCTION COMMENTS(
      P_FCST_CURVE_ID IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_FCST_PROD_CURVES.COMMENTS      (
         P_FCST_CURVE_ID );
         RETURN ret_value;
   END COMMENTS;
   FUNCTION DATE_3(
      P_FCST_CURVE_ID IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_FCST_PROD_CURVES.DATE_3      (
         P_FCST_CURVE_ID );
         RETURN ret_value;
   END DATE_3;
   FUNCTION DATE_5(
      P_FCST_CURVE_ID IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_FCST_PROD_CURVES.DATE_5      (
         P_FCST_CURVE_ID );
         RETURN ret_value;
   END DATE_5;
   FUNCTION NEXT_EQUAL_DAYTIME(
      P_FCST_CURVE_ID IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_FCST_PROD_CURVES.NEXT_EQUAL_DAYTIME      (
         P_FCST_CURVE_ID,
         P_NUM_ROWS );
         RETURN ret_value;
   END NEXT_EQUAL_DAYTIME;
   FUNCTION VALUE_6(
      P_FCST_CURVE_ID IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FCST_PROD_CURVES.VALUE_6      (
         P_FCST_CURVE_ID );
         RETURN ret_value;
   END VALUE_6;
   FUNCTION DATE_2(
      P_FCST_CURVE_ID IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_FCST_PROD_CURVES.DATE_2      (
         P_FCST_CURVE_ID );
         RETURN ret_value;
   END DATE_2;
   FUNCTION END_DATE(
      P_FCST_CURVE_ID IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_FCST_PROD_CURVES.END_DATE      (
         P_FCST_CURVE_ID );
         RETURN ret_value;
   END END_DATE;
   FUNCTION PREV_DAYTIME(
      P_FCST_CURVE_ID IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_FCST_PROD_CURVES.PREV_DAYTIME      (
         P_FCST_CURVE_ID,
         P_NUM_ROWS );
         RETURN ret_value;
   END PREV_DAYTIME;
   FUNCTION RECORD_STATUS(
      P_FCST_CURVE_ID IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_FCST_PROD_CURVES.RECORD_STATUS      (
         P_FCST_CURVE_ID );
         RETURN ret_value;
   END RECORD_STATUS;
   FUNCTION VALUE_1(
      P_FCST_CURVE_ID IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FCST_PROD_CURVES.VALUE_1      (
         P_FCST_CURVE_ID );
         RETURN ret_value;
   END VALUE_1;
   FUNCTION APPROVAL_DATE(
      P_FCST_CURVE_ID IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_FCST_PROD_CURVES.APPROVAL_DATE      (
         P_FCST_CURVE_ID );
         RETURN ret_value;
   END APPROVAL_DATE;
   FUNCTION CURVE_TYPE(
      P_FCST_CURVE_ID IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_FCST_PROD_CURVES.CURVE_TYPE      (
         P_FCST_CURVE_ID );
         RETURN ret_value;
   END CURVE_TYPE;
   FUNCTION FORECAST_ID(
      P_FCST_CURVE_ID IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_FCST_PROD_CURVES.FORECAST_ID      (
         P_FCST_CURVE_ID );
         RETURN ret_value;
   END FORECAST_ID;
   FUNCTION ROW_BY_PK(
      P_FCST_CURVE_ID IN NUMBER)
      RETURN REC_ROW_BY_PK
   IS
      ret_value    REC_ROW_BY_PK ;
   BEGIN
      ret_value := EC_FCST_PROD_CURVES.ROW_BY_PK      (
         P_FCST_CURVE_ID );
         RETURN ret_value;
   END ROW_BY_PK;
   FUNCTION SCENARIO_ID(
      P_FCST_CURVE_ID IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_FCST_PROD_CURVES.SCENARIO_ID      (
         P_FCST_CURVE_ID );
         RETURN ret_value;
   END SCENARIO_ID;
   FUNCTION VALUE_2(
      P_FCST_CURVE_ID IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FCST_PROD_CURVES.VALUE_2      (
         P_FCST_CURVE_ID );
         RETURN ret_value;
   END VALUE_2;
   FUNCTION VALUE_3(
      P_FCST_CURVE_ID IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FCST_PROD_CURVES.VALUE_3      (
         P_FCST_CURVE_ID );
         RETURN ret_value;
   END VALUE_3;
   FUNCTION VALUE_4(
      P_FCST_CURVE_ID IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FCST_PROD_CURVES.VALUE_4      (
         P_FCST_CURVE_ID );
         RETURN ret_value;
   END VALUE_4;
   FUNCTION CLASS_NAME(
      P_FCST_CURVE_ID IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_FCST_PROD_CURVES.CLASS_NAME      (
         P_FCST_CURVE_ID );
         RETURN ret_value;
   END CLASS_NAME;
   FUNCTION DATE_4(
      P_FCST_CURVE_ID IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_FCST_PROD_CURVES.DATE_4      (
         P_FCST_CURVE_ID );
         RETURN ret_value;
   END DATE_4;
   FUNCTION FORECAST_TYPE(
      P_FCST_CURVE_ID IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_FCST_PROD_CURVES.FORECAST_TYPE      (
         P_FCST_CURVE_ID );
         RETURN ret_value;
   END FORECAST_TYPE;
   FUNCTION REC_ID(
      P_FCST_CURVE_ID IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_FCST_PROD_CURVES.REC_ID      (
         P_FCST_CURVE_ID );
         RETURN ret_value;
   END REC_ID;
   FUNCTION TEXT_1(
      P_FCST_CURVE_ID IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (16) ;
   BEGIN
      ret_value := EC_FCST_PROD_CURVES.TEXT_1      (
         P_FCST_CURVE_ID );
         RETURN ret_value;
   END TEXT_1;
   FUNCTION TEXT_2(
      P_FCST_CURVE_ID IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_FCST_PROD_CURVES.TEXT_2      (
         P_FCST_CURVE_ID );
         RETURN ret_value;
   END TEXT_2;
   FUNCTION VALUE_7(
      P_FCST_CURVE_ID IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FCST_PROD_CURVES.VALUE_7      (
         P_FCST_CURVE_ID );
         RETURN ret_value;
   END VALUE_7;
   FUNCTION VALUE_9(
      P_FCST_CURVE_ID IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FCST_PROD_CURVES.VALUE_9      (
         P_FCST_CURVE_ID );
         RETURN ret_value;
   END VALUE_9;
   FUNCTION DATE_1(
      P_FCST_CURVE_ID IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_FCST_PROD_CURVES.DATE_1      (
         P_FCST_CURVE_ID );
         RETURN ret_value;
   END DATE_1;
   FUNCTION DAYTIME(
      P_FCST_CURVE_ID IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_FCST_PROD_CURVES.DAYTIME      (
         P_FCST_CURVE_ID );
         RETURN ret_value;
   END DAYTIME;
   FUNCTION INCLUDE_FLAG(
      P_FCST_CURVE_ID IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_FCST_PROD_CURVES.INCLUDE_FLAG      (
         P_FCST_CURVE_ID );
         RETURN ret_value;
   END INCLUDE_FLAG;
   FUNCTION VALUE_10(
      P_FCST_CURVE_ID IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FCST_PROD_CURVES.VALUE_10      (
         P_FCST_CURVE_ID );
         RETURN ret_value;
   END VALUE_10;
   FUNCTION VALUE_8(
      P_FCST_CURVE_ID IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FCST_PROD_CURVES.VALUE_8      (
         P_FCST_CURVE_ID );
         RETURN ret_value;
   END VALUE_8;
   FUNCTION WELL_ID(
      P_FCST_CURVE_ID IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_FCST_PROD_CURVES.WELL_ID      (
         P_FCST_CURVE_ID );
         RETURN ret_value;
   END WELL_ID;

END RP_FCST_PROD_CURVES;

/
--GRANT EXECUTE ON ECKERNEL_WST.RP_FCST_PROD_CURVES TO REPORT_ROLE_XXX;



 -- FINISH PKG_GEN_PKGS.sf_get_functions at:11/15/2018 09.42.10 AM


