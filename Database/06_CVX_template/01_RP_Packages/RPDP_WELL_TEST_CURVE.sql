
 -- START PKG_GEN_PKGS.sf_get_functions at:05/07/2019 11.43.01 AM


CREATE or REPLACE PACKAGE RPDP_WELL_TEST_CURVE
IS

   FUNCTION CONVERTLNTOEXP(
      P_POINT_LIST IN ECBP_MATHLIB.EC_DISCRETE_FUNC_TYPE)
      RETURN ECBP_MATHLIB.EC_DISCRETE_FUNC_TYPE;
   FUNCTION GETTRENDSEGMENTSTARTDAYTIME(
      P_OBJECT_ID IN VARCHAR2,
      P_FOCUS_DATE IN DATE,
      P_FROM_DAYTIME IN DATE,
      P_TO_DAYTIME IN DATE)
      RETURN DATE;
   FUNCTION TRENDCURVEROWCOUNT(
      P_OBJECT_ID IN VARCHAR2,
      P_FOCUS_DATE IN DATE,
      P_FROM_DAYTIME IN DATE,
      P_TO_DAYTIME IN DATE)
      RETURN NUMBER;
   FUNCTION GETYFROMX(
      P_X_VALUE IN NUMBER,
      P_C0 IN NUMBER,
      P_C1 IN NUMBER,
      P_TREND_METHOD IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION TRENDSEGMENTROWCOUNT(
      P_OBJECT_ID IN VARCHAR2,
      P_FROM_DAYTIME IN DATE,
      P_TO_DAYTIME IN DATE,
      P_MIN_DAYTIME IN DATE,
      P_MAX_DAYTIME IN DATE)
      RETURN NUMBER;

END RPDP_WELL_TEST_CURVE;

/



CREATE or REPLACE PACKAGE BODY RPDP_WELL_TEST_CURVE
IS

   FUNCTION CONVERTLNTOEXP(
      P_POINT_LIST IN ECBP_MATHLIB.EC_DISCRETE_FUNC_TYPE)
      RETURN ECBP_MATHLIB.EC_DISCRETE_FUNC_TYPE
   IS
      ret_value    ECBP_MATHLIB.EC_DISCRETE_FUNC_TYPE ;
   BEGIN
      ret_value := ECDP_WELL_TEST_CURVE.CONVERTLNTOEXP      (
         P_POINT_LIST );
         RETURN ret_value;
   END CONVERTLNTOEXP;
   FUNCTION GETTRENDSEGMENTSTARTDAYTIME(
      P_OBJECT_ID IN VARCHAR2,
      P_FOCUS_DATE IN DATE,
      P_FROM_DAYTIME IN DATE,
      P_TO_DAYTIME IN DATE)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := ECDP_WELL_TEST_CURVE.GETTRENDSEGMENTSTARTDAYTIME      (
         P_OBJECT_ID,
         P_FOCUS_DATE,
         P_FROM_DAYTIME,
         P_TO_DAYTIME );
         RETURN ret_value;
   END GETTRENDSEGMENTSTARTDAYTIME;
   FUNCTION TRENDCURVEROWCOUNT(
      P_OBJECT_ID IN VARCHAR2,
      P_FOCUS_DATE IN DATE,
      P_FROM_DAYTIME IN DATE,
      P_TO_DAYTIME IN DATE)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECDP_WELL_TEST_CURVE.TRENDCURVEROWCOUNT      (
         P_OBJECT_ID,
         P_FOCUS_DATE,
         P_FROM_DAYTIME,
         P_TO_DAYTIME );
         RETURN ret_value;
   END TRENDCURVEROWCOUNT;
   FUNCTION GETYFROMX(
      P_X_VALUE IN NUMBER,
      P_C0 IN NUMBER,
      P_C1 IN NUMBER,
      P_TREND_METHOD IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECDP_WELL_TEST_CURVE.GETYFROMX      (
         P_X_VALUE,
         P_C0,
         P_C1,
         P_TREND_METHOD );
         RETURN ret_value;
   END GETYFROMX;
   FUNCTION TRENDSEGMENTROWCOUNT(
      P_OBJECT_ID IN VARCHAR2,
      P_FROM_DAYTIME IN DATE,
      P_TO_DAYTIME IN DATE,
      P_MIN_DAYTIME IN DATE,
      P_MAX_DAYTIME IN DATE)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECDP_WELL_TEST_CURVE.TRENDSEGMENTROWCOUNT      (
         P_OBJECT_ID,
         P_FROM_DAYTIME,
         P_TO_DAYTIME,
         P_MIN_DAYTIME,
         P_MAX_DAYTIME );
         RETURN ret_value;
   END TRENDSEGMENTROWCOUNT;

END RPDP_WELL_TEST_CURVE;

/
--GRANT EXECUTE ON ECKERNEL_WST.RPDP_WELL_TEST_CURVE TO REPORT_ROLE_XXX;



 -- FINISH PKG_GEN_PKGS.sf_get_functions at:05/07/2019 11.43.03 AM


