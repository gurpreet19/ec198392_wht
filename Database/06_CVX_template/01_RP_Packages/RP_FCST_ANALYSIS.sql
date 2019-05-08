
 -- START PKG_GEN_PKGS.sf_get_functions at:05/07/2019 10.16.35 AM


CREATE or REPLACE PACKAGE RP_FCST_ANALYSIS
IS

   FUNCTION TEXT_3(
      P_ANALYSIS_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_4(
      P_ANALYSIS_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_BY(
      P_ANALYSIS_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_STATE(
      P_ANALYSIS_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION SERIES(
      P_ANALYSIS_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_5(
      P_ANALYSIS_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION NEXT_DAYTIME(
      P_ANALYSIS_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION OBJECT_ID(
      P_ANALYSIS_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION PREV_EQUAL_DAYTIME(
      P_ANALYSIS_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION GCV(
      P_ANALYSIS_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION NEXT_EQUAL_DAYTIME(
      P_ANALYSIS_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION VALUE_6(
      P_ANALYSIS_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION CONTRACT_ID(
      P_ANALYSIS_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION DELIVERY_POINT_ID(
      P_ANALYSIS_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION PREV_DAYTIME(
      P_ANALYSIS_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION RECORD_STATUS(
      P_ANALYSIS_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_1(
      P_ANALYSIS_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION APPROVAL_DATE(
      P_ANALYSIS_NO IN NUMBER)
      RETURN DATE;
   FUNCTION DENSITY(
      P_ANALYSIS_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION FORECAST_ID(
      P_ANALYSIS_NO IN NUMBER)
      RETURN VARCHAR2;
      TYPE REC_ROW_BY_PK IS RECORD (
         OBJECT_ID VARCHAR2 (32) ,
         CLASS_NAME VARCHAR2 (32) ,
         FORECAST_ID VARCHAR2 (32) ,
         ANALYSIS_NO NUMBER ,
         CONTRACT_ID VARCHAR2 (32) ,
         DELIVERY_POINT_ID VARCHAR2 (32) ,
         SERIES VARCHAR2 (32) ,
         DAYTIME  DATE ,
         GCV NUMBER ,
         DENSITY NUMBER ,
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
         REC_ID VARCHAR2 (32)  );
   FUNCTION ROW_BY_PK(
      P_ANALYSIS_NO IN NUMBER)
      RETURN REC_ROW_BY_PK;
   FUNCTION VALUE_2(
      P_ANALYSIS_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_3(
      P_ANALYSIS_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_4(
      P_ANALYSIS_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION CLASS_NAME(
      P_ANALYSIS_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION REC_ID(
      P_ANALYSIS_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_1(
      P_ANALYSIS_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION TEXT_2(
      P_ANALYSIS_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION VALUE_7(
      P_ANALYSIS_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_9(
      P_ANALYSIS_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION DAYTIME(
      P_ANALYSIS_NO IN NUMBER)
      RETURN DATE;
   FUNCTION VALUE_10(
      P_ANALYSIS_NO IN NUMBER)
      RETURN NUMBER;
   FUNCTION VALUE_8(
      P_ANALYSIS_NO IN NUMBER)
      RETURN NUMBER;

END RP_FCST_ANALYSIS;

/



CREATE or REPLACE PACKAGE BODY RP_FCST_ANALYSIS
IS

   FUNCTION TEXT_3(
      P_ANALYSIS_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (240) ;
   BEGIN
      ret_value := EC_FCST_ANALYSIS.TEXT_3      (
         P_ANALYSIS_NO );
         RETURN ret_value;
   END TEXT_3;
   FUNCTION TEXT_4(
      P_ANALYSIS_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_FCST_ANALYSIS.TEXT_4      (
         P_ANALYSIS_NO );
         RETURN ret_value;
   END TEXT_4;
   FUNCTION APPROVAL_BY(
      P_ANALYSIS_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (30) ;
   BEGIN
      ret_value := EC_FCST_ANALYSIS.APPROVAL_BY      (
         P_ANALYSIS_NO );
         RETURN ret_value;
   END APPROVAL_BY;
   FUNCTION APPROVAL_STATE(
      P_ANALYSIS_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_FCST_ANALYSIS.APPROVAL_STATE      (
         P_ANALYSIS_NO );
         RETURN ret_value;
   END APPROVAL_STATE;
   FUNCTION SERIES(
      P_ANALYSIS_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_FCST_ANALYSIS.SERIES      (
         P_ANALYSIS_NO );
         RETURN ret_value;
   END SERIES;
   FUNCTION VALUE_5(
      P_ANALYSIS_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FCST_ANALYSIS.VALUE_5      (
         P_ANALYSIS_NO );
         RETURN ret_value;
   END VALUE_5;
   FUNCTION NEXT_DAYTIME(
      P_ANALYSIS_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_FCST_ANALYSIS.NEXT_DAYTIME      (
         P_ANALYSIS_NO,
         P_NUM_ROWS );
         RETURN ret_value;
   END NEXT_DAYTIME;
   FUNCTION OBJECT_ID(
      P_ANALYSIS_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_FCST_ANALYSIS.OBJECT_ID      (
         P_ANALYSIS_NO );
         RETURN ret_value;
   END OBJECT_ID;
   FUNCTION PREV_EQUAL_DAYTIME(
      P_ANALYSIS_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_FCST_ANALYSIS.PREV_EQUAL_DAYTIME      (
         P_ANALYSIS_NO,
         P_NUM_ROWS );
         RETURN ret_value;
   END PREV_EQUAL_DAYTIME;
   FUNCTION GCV(
      P_ANALYSIS_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FCST_ANALYSIS.GCV      (
         P_ANALYSIS_NO );
         RETURN ret_value;
   END GCV;
   FUNCTION NEXT_EQUAL_DAYTIME(
      P_ANALYSIS_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_FCST_ANALYSIS.NEXT_EQUAL_DAYTIME      (
         P_ANALYSIS_NO,
         P_NUM_ROWS );
         RETURN ret_value;
   END NEXT_EQUAL_DAYTIME;
   FUNCTION VALUE_6(
      P_ANALYSIS_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FCST_ANALYSIS.VALUE_6      (
         P_ANALYSIS_NO );
         RETURN ret_value;
   END VALUE_6;
   FUNCTION CONTRACT_ID(
      P_ANALYSIS_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_FCST_ANALYSIS.CONTRACT_ID      (
         P_ANALYSIS_NO );
         RETURN ret_value;
   END CONTRACT_ID;
   FUNCTION DELIVERY_POINT_ID(
      P_ANALYSIS_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_FCST_ANALYSIS.DELIVERY_POINT_ID      (
         P_ANALYSIS_NO );
         RETURN ret_value;
   END DELIVERY_POINT_ID;
   FUNCTION PREV_DAYTIME(
      P_ANALYSIS_NO IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_FCST_ANALYSIS.PREV_DAYTIME      (
         P_ANALYSIS_NO,
         P_NUM_ROWS );
         RETURN ret_value;
   END PREV_DAYTIME;
   FUNCTION RECORD_STATUS(
      P_ANALYSIS_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_FCST_ANALYSIS.RECORD_STATUS      (
         P_ANALYSIS_NO );
         RETURN ret_value;
   END RECORD_STATUS;
   FUNCTION VALUE_1(
      P_ANALYSIS_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FCST_ANALYSIS.VALUE_1      (
         P_ANALYSIS_NO );
         RETURN ret_value;
   END VALUE_1;
   FUNCTION APPROVAL_DATE(
      P_ANALYSIS_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_FCST_ANALYSIS.APPROVAL_DATE      (
         P_ANALYSIS_NO );
         RETURN ret_value;
   END APPROVAL_DATE;
   FUNCTION DENSITY(
      P_ANALYSIS_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FCST_ANALYSIS.DENSITY      (
         P_ANALYSIS_NO );
         RETURN ret_value;
   END DENSITY;
   FUNCTION FORECAST_ID(
      P_ANALYSIS_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_FCST_ANALYSIS.FORECAST_ID      (
         P_ANALYSIS_NO );
         RETURN ret_value;
   END FORECAST_ID;
   FUNCTION ROW_BY_PK(
      P_ANALYSIS_NO IN NUMBER)
      RETURN REC_ROW_BY_PK
   IS
      ret_value    REC_ROW_BY_PK ;
   BEGIN
      ret_value := EC_FCST_ANALYSIS.ROW_BY_PK      (
         P_ANALYSIS_NO );
         RETURN ret_value;
   END ROW_BY_PK;
   FUNCTION VALUE_2(
      P_ANALYSIS_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FCST_ANALYSIS.VALUE_2      (
         P_ANALYSIS_NO );
         RETURN ret_value;
   END VALUE_2;
   FUNCTION VALUE_3(
      P_ANALYSIS_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FCST_ANALYSIS.VALUE_3      (
         P_ANALYSIS_NO );
         RETURN ret_value;
   END VALUE_3;
   FUNCTION VALUE_4(
      P_ANALYSIS_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FCST_ANALYSIS.VALUE_4      (
         P_ANALYSIS_NO );
         RETURN ret_value;
   END VALUE_4;
   FUNCTION CLASS_NAME(
      P_ANALYSIS_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_FCST_ANALYSIS.CLASS_NAME      (
         P_ANALYSIS_NO );
         RETURN ret_value;
   END CLASS_NAME;
   FUNCTION REC_ID(
      P_ANALYSIS_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_FCST_ANALYSIS.REC_ID      (
         P_ANALYSIS_NO );
         RETURN ret_value;
   END REC_ID;
   FUNCTION TEXT_1(
      P_ANALYSIS_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (16) ;
   BEGIN
      ret_value := EC_FCST_ANALYSIS.TEXT_1      (
         P_ANALYSIS_NO );
         RETURN ret_value;
   END TEXT_1;
   FUNCTION TEXT_2(
      P_ANALYSIS_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_FCST_ANALYSIS.TEXT_2      (
         P_ANALYSIS_NO );
         RETURN ret_value;
   END TEXT_2;
   FUNCTION VALUE_7(
      P_ANALYSIS_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FCST_ANALYSIS.VALUE_7      (
         P_ANALYSIS_NO );
         RETURN ret_value;
   END VALUE_7;
   FUNCTION VALUE_9(
      P_ANALYSIS_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FCST_ANALYSIS.VALUE_9      (
         P_ANALYSIS_NO );
         RETURN ret_value;
   END VALUE_9;
   FUNCTION DAYTIME(
      P_ANALYSIS_NO IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_FCST_ANALYSIS.DAYTIME      (
         P_ANALYSIS_NO );
         RETURN ret_value;
   END DAYTIME;
   FUNCTION VALUE_10(
      P_ANALYSIS_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FCST_ANALYSIS.VALUE_10      (
         P_ANALYSIS_NO );
         RETURN ret_value;
   END VALUE_10;
   FUNCTION VALUE_8(
      P_ANALYSIS_NO IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_FCST_ANALYSIS.VALUE_8      (
         P_ANALYSIS_NO );
         RETURN ret_value;
   END VALUE_8;

END RP_FCST_ANALYSIS;

/
--GRANT EXECUTE ON ECKERNEL_WST.RP_FCST_ANALYSIS TO REPORT_ROLE_XXX;



 -- FINISH PKG_GEN_PKGS.sf_get_functions at:05/07/2019 10.16.42 AM


