
 -- START PKG_GEN_PKGS.sf_get_functions at:05/07/2019 08.31.40 AM


CREATE or REPLACE PACKAGE RP_PERFORMANCE_CURVE
IS

   FUNCTION MIN_ALLOW_WH_PRESS(
      P_PERF_CURVE_ID IN NUMBER)
      RETURN NUMBER;
   FUNCTION APPROVAL_BY(
      P_PERF_CURVE_ID IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_STATE(
      P_PERF_CURVE_ID IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION CURVE_PARAMETER_CODE(
      P_PERF_CURVE_ID IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION FORMULA_TYPE(
      P_PERF_CURVE_ID IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION CURVE_OBJECT_ID(
      P_PERF_CURVE_ID IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION NEXT_DAYTIME(
      P_PERF_CURVE_ID IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION POTEN_3RD_VALUE(
      P_PERF_CURVE_ID IN NUMBER)
      RETURN NUMBER;
   FUNCTION PREV_EQUAL_DAYTIME(
      P_PERF_CURVE_ID IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION CLASS_NAME(
      P_PERF_CURVE_ID IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION COMMENTS(
      P_PERF_CURVE_ID IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION MAX_ALLOW_WH_PRESS(
      P_PERF_CURVE_ID IN NUMBER)
      RETURN NUMBER;
   FUNCTION NEXT_EQUAL_DAYTIME(
      P_PERF_CURVE_ID IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION PERF_CURVE_STATUS(
      P_PERF_CURVE_ID IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION POTEN_2ND_VALUE(
      P_PERF_CURVE_ID IN NUMBER)
      RETURN NUMBER;
   FUNCTION GOR(
      P_PERF_CURVE_ID IN NUMBER)
      RETURN NUMBER;
   FUNCTION PREV_DAYTIME(
      P_PERF_CURVE_ID IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE;
   FUNCTION RECORD_STATUS(
      P_PERF_CURVE_ID IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION APPROVAL_DATE(
      P_PERF_CURVE_ID IN NUMBER)
      RETURN DATE;
   FUNCTION CGR(
      P_PERF_CURVE_ID IN NUMBER)
      RETURN NUMBER;
   FUNCTION CURVE_PURPOSE(
      P_PERF_CURVE_ID IN NUMBER)
      RETURN VARCHAR2;
      TYPE REC_ROW_BY_PK IS RECORD (
         PERF_CURVE_ID NUMBER ,
         CURVE_OBJECT_ID VARCHAR2 (32) ,
         DAYTIME  DATE ,
         CURVE_PURPOSE VARCHAR2 (16) ,
         CURVE_PARAMETER_CODE VARCHAR2 (24) ,
         PERF_CURVE_STATUS VARCHAR2 (32) ,
         PLANE_INTERSECT_CODE VARCHAR2 (16) ,
         POTEN_2ND_VALUE NUMBER ,
         POTEN_3RD_VALUE NUMBER ,
         CGR NUMBER ,
         GOR NUMBER ,
         MAX_ALLOW_WH_PRESS NUMBER ,
         MIN_ALLOW_WH_PRESS NUMBER ,
         WGR NUMBER ,
         WATERCUT_PCT NUMBER ,
         FORMULA_TYPE VARCHAR2 (16) ,
         PHASE VARCHAR2 (16) ,
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
         CLASS_NAME VARCHAR2 (24)  );
   FUNCTION ROW_BY_PK(
      P_PERF_CURVE_ID IN NUMBER)
      RETURN REC_ROW_BY_PK;
   FUNCTION WGR(
      P_PERF_CURVE_ID IN NUMBER)
      RETURN NUMBER;
   FUNCTION PHASE(
      P_PERF_CURVE_ID IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION REC_ID(
      P_PERF_CURVE_ID IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION WATERCUT_PCT(
      P_PERF_CURVE_ID IN NUMBER)
      RETURN NUMBER;
   FUNCTION DAYTIME(
      P_PERF_CURVE_ID IN NUMBER)
      RETURN DATE;
   FUNCTION PLANE_INTERSECT_CODE(
      P_PERF_CURVE_ID IN NUMBER)
      RETURN VARCHAR2;

END RP_PERFORMANCE_CURVE;

/



CREATE or REPLACE PACKAGE BODY RP_PERFORMANCE_CURVE
IS

   FUNCTION MIN_ALLOW_WH_PRESS(
      P_PERF_CURVE_ID IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_PERFORMANCE_CURVE.MIN_ALLOW_WH_PRESS      (
         P_PERF_CURVE_ID );
         RETURN ret_value;
   END MIN_ALLOW_WH_PRESS;
   FUNCTION APPROVAL_BY(
      P_PERF_CURVE_ID IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (30) ;
   BEGIN
      ret_value := EC_PERFORMANCE_CURVE.APPROVAL_BY      (
         P_PERF_CURVE_ID );
         RETURN ret_value;
   END APPROVAL_BY;
   FUNCTION APPROVAL_STATE(
      P_PERF_CURVE_ID IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_PERFORMANCE_CURVE.APPROVAL_STATE      (
         P_PERF_CURVE_ID );
         RETURN ret_value;
   END APPROVAL_STATE;
   FUNCTION CURVE_PARAMETER_CODE(
      P_PERF_CURVE_ID IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (24) ;
   BEGIN
      ret_value := EC_PERFORMANCE_CURVE.CURVE_PARAMETER_CODE      (
         P_PERF_CURVE_ID );
         RETURN ret_value;
   END CURVE_PARAMETER_CODE;
   FUNCTION FORMULA_TYPE(
      P_PERF_CURVE_ID IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (16) ;
   BEGIN
      ret_value := EC_PERFORMANCE_CURVE.FORMULA_TYPE      (
         P_PERF_CURVE_ID );
         RETURN ret_value;
   END FORMULA_TYPE;
   FUNCTION CURVE_OBJECT_ID(
      P_PERF_CURVE_ID IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_PERFORMANCE_CURVE.CURVE_OBJECT_ID      (
         P_PERF_CURVE_ID );
         RETURN ret_value;
   END CURVE_OBJECT_ID;
   FUNCTION NEXT_DAYTIME(
      P_PERF_CURVE_ID IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_PERFORMANCE_CURVE.NEXT_DAYTIME      (
         P_PERF_CURVE_ID,
         P_NUM_ROWS );
         RETURN ret_value;
   END NEXT_DAYTIME;
   FUNCTION POTEN_3RD_VALUE(
      P_PERF_CURVE_ID IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_PERFORMANCE_CURVE.POTEN_3RD_VALUE      (
         P_PERF_CURVE_ID );
         RETURN ret_value;
   END POTEN_3RD_VALUE;
   FUNCTION PREV_EQUAL_DAYTIME(
      P_PERF_CURVE_ID IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_PERFORMANCE_CURVE.PREV_EQUAL_DAYTIME      (
         P_PERF_CURVE_ID,
         P_NUM_ROWS );
         RETURN ret_value;
   END PREV_EQUAL_DAYTIME;
   FUNCTION CLASS_NAME(
      P_PERF_CURVE_ID IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (24) ;
   BEGIN
      ret_value := EC_PERFORMANCE_CURVE.CLASS_NAME      (
         P_PERF_CURVE_ID );
         RETURN ret_value;
   END CLASS_NAME;
   FUNCTION COMMENTS(
      P_PERF_CURVE_ID IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (2000) ;
   BEGIN
      ret_value := EC_PERFORMANCE_CURVE.COMMENTS      (
         P_PERF_CURVE_ID );
         RETURN ret_value;
   END COMMENTS;
   FUNCTION MAX_ALLOW_WH_PRESS(
      P_PERF_CURVE_ID IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_PERFORMANCE_CURVE.MAX_ALLOW_WH_PRESS      (
         P_PERF_CURVE_ID );
         RETURN ret_value;
   END MAX_ALLOW_WH_PRESS;
   FUNCTION NEXT_EQUAL_DAYTIME(
      P_PERF_CURVE_ID IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_PERFORMANCE_CURVE.NEXT_EQUAL_DAYTIME      (
         P_PERF_CURVE_ID,
         P_NUM_ROWS );
         RETURN ret_value;
   END NEXT_EQUAL_DAYTIME;
   FUNCTION PERF_CURVE_STATUS(
      P_PERF_CURVE_ID IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_PERFORMANCE_CURVE.PERF_CURVE_STATUS      (
         P_PERF_CURVE_ID );
         RETURN ret_value;
   END PERF_CURVE_STATUS;
   FUNCTION POTEN_2ND_VALUE(
      P_PERF_CURVE_ID IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_PERFORMANCE_CURVE.POTEN_2ND_VALUE      (
         P_PERF_CURVE_ID );
         RETURN ret_value;
   END POTEN_2ND_VALUE;
   FUNCTION GOR(
      P_PERF_CURVE_ID IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_PERFORMANCE_CURVE.GOR      (
         P_PERF_CURVE_ID );
         RETURN ret_value;
   END GOR;
   FUNCTION PREV_DAYTIME(
      P_PERF_CURVE_ID IN NUMBER,
      P_NUM_ROWS IN NUMBER DEFAULT 1)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_PERFORMANCE_CURVE.PREV_DAYTIME      (
         P_PERF_CURVE_ID,
         P_NUM_ROWS );
         RETURN ret_value;
   END PREV_DAYTIME;
   FUNCTION RECORD_STATUS(
      P_PERF_CURVE_ID IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (1) ;
   BEGIN
      ret_value := EC_PERFORMANCE_CURVE.RECORD_STATUS      (
         P_PERF_CURVE_ID );
         RETURN ret_value;
   END RECORD_STATUS;
   FUNCTION APPROVAL_DATE(
      P_PERF_CURVE_ID IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_PERFORMANCE_CURVE.APPROVAL_DATE      (
         P_PERF_CURVE_ID );
         RETURN ret_value;
   END APPROVAL_DATE;
   FUNCTION CGR(
      P_PERF_CURVE_ID IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_PERFORMANCE_CURVE.CGR      (
         P_PERF_CURVE_ID );
         RETURN ret_value;
   END CGR;
   FUNCTION CURVE_PURPOSE(
      P_PERF_CURVE_ID IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (16) ;
   BEGIN
      ret_value := EC_PERFORMANCE_CURVE.CURVE_PURPOSE      (
         P_PERF_CURVE_ID );
         RETURN ret_value;
   END CURVE_PURPOSE;
   FUNCTION ROW_BY_PK(
      P_PERF_CURVE_ID IN NUMBER)
      RETURN REC_ROW_BY_PK
   IS
      ret_value    REC_ROW_BY_PK ;
   BEGIN
      ret_value := EC_PERFORMANCE_CURVE.ROW_BY_PK      (
         P_PERF_CURVE_ID );
         RETURN ret_value;
   END ROW_BY_PK;
   FUNCTION WGR(
      P_PERF_CURVE_ID IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_PERFORMANCE_CURVE.WGR      (
         P_PERF_CURVE_ID );
         RETURN ret_value;
   END WGR;
   FUNCTION PHASE(
      P_PERF_CURVE_ID IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (16) ;
   BEGIN
      ret_value := EC_PERFORMANCE_CURVE.PHASE      (
         P_PERF_CURVE_ID );
         RETURN ret_value;
   END PHASE;
   FUNCTION REC_ID(
      P_PERF_CURVE_ID IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (32) ;
   BEGIN
      ret_value := EC_PERFORMANCE_CURVE.REC_ID      (
         P_PERF_CURVE_ID );
         RETURN ret_value;
   END REC_ID;
   FUNCTION WATERCUT_PCT(
      P_PERF_CURVE_ID IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := EC_PERFORMANCE_CURVE.WATERCUT_PCT      (
         P_PERF_CURVE_ID );
         RETURN ret_value;
   END WATERCUT_PCT;
   FUNCTION DAYTIME(
      P_PERF_CURVE_ID IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := EC_PERFORMANCE_CURVE.DAYTIME      (
         P_PERF_CURVE_ID );
         RETURN ret_value;
   END DAYTIME;
   FUNCTION PLANE_INTERSECT_CODE(
      P_PERF_CURVE_ID IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2 (16) ;
   BEGIN
      ret_value := EC_PERFORMANCE_CURVE.PLANE_INTERSECT_CODE      (
         P_PERF_CURVE_ID );
         RETURN ret_value;
   END PLANE_INTERSECT_CODE;

END RP_PERFORMANCE_CURVE;

/
--GRANT EXECUTE ON ECKERNEL_WST.RP_PERFORMANCE_CURVE TO REPORT_ROLE_XXX;



 -- FINISH PKG_GEN_PKGS.sf_get_functions at:05/07/2019 08.31.49 AM


