
 -- START PKG_GEN_PKGS.sf_get_functions at:05/07/2019 11.49.06 AM


CREATE or REPLACE PACKAGE RPDP_FORECAST_CURVE
IS

   FUNCTION CHECKMANDATORYTF(
      P_FCST_CURVE_ID IN NUMBER,
      P_PHASE IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION GETSEGMENTNO(
      P_FCST_CURVE_ID IN NUMBER,
      P_PHASE IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION ISEDITABLEQI(
      P_FCST_CURVE_ID IN NUMBER,
      P_PHASE IN VARCHAR2,
      P_SEGMENT IN NUMBER,
      P_CURVE_SHAPE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION GETWELLPRODUCT(
      P_FCST_CURVE_ID IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION GETSORTORDER(
      P_FCST_CURVE_ID IN NUMBER,
      P_FCST_SEGMENT_ID IN NUMBER)
      RETURN NUMBER;
   FUNCTION SEGMENTDAYTIME(
      P_FCST_CURVE_ID IN NUMBER,
      P_PHASE IN VARCHAR2,
      P_SEGMENT IN NUMBER)
      RETURN DATE;
   FUNCTION SEGMENTENDDATE(
      P_FCST_CURVE_ID IN NUMBER,
      P_PHASE IN VARCHAR2,
      P_SEGMENT IN NUMBER)
      RETURN DATE;

END RPDP_FORECAST_CURVE;

/



CREATE or REPLACE PACKAGE BODY RPDP_FORECAST_CURVE
IS

   FUNCTION CHECKMANDATORYTF(
      P_FCST_CURVE_ID IN NUMBER,
      P_PHASE IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECDP_FORECAST_CURVE.CHECKMANDATORYTF      (
         P_FCST_CURVE_ID,
         P_PHASE );
         RETURN ret_value;
   END CHECKMANDATORYTF;
   FUNCTION GETSEGMENTNO(
      P_FCST_CURVE_ID IN NUMBER,
      P_PHASE IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECDP_FORECAST_CURVE.GETSEGMENTNO      (
         P_FCST_CURVE_ID,
         P_PHASE );
         RETURN ret_value;
   END GETSEGMENTNO;
   FUNCTION ISEDITABLEQI(
      P_FCST_CURVE_ID IN NUMBER,
      P_PHASE IN VARCHAR2,
      P_SEGMENT IN NUMBER,
      P_CURVE_SHAPE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := ECDP_FORECAST_CURVE.ISEDITABLEQI      (
         P_FCST_CURVE_ID,
         P_PHASE,
         P_SEGMENT,
         P_CURVE_SHAPE );
         RETURN ret_value;
   END ISEDITABLEQI;
   FUNCTION GETWELLPRODUCT(
      P_FCST_CURVE_ID IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := ECDP_FORECAST_CURVE.GETWELLPRODUCT      (
         P_FCST_CURVE_ID );
         RETURN ret_value;
   END GETWELLPRODUCT;
   FUNCTION GETSORTORDER(
      P_FCST_CURVE_ID IN NUMBER,
      P_FCST_SEGMENT_ID IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECDP_FORECAST_CURVE.GETSORTORDER      (
         P_FCST_CURVE_ID,
         P_FCST_SEGMENT_ID );
         RETURN ret_value;
   END GETSORTORDER;
   FUNCTION SEGMENTDAYTIME(
      P_FCST_CURVE_ID IN NUMBER,
      P_PHASE IN VARCHAR2,
      P_SEGMENT IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := ECDP_FORECAST_CURVE.SEGMENTDAYTIME      (
         P_FCST_CURVE_ID,
         P_PHASE,
         P_SEGMENT );
         RETURN ret_value;
   END SEGMENTDAYTIME;
   FUNCTION SEGMENTENDDATE(
      P_FCST_CURVE_ID IN NUMBER,
      P_PHASE IN VARCHAR2,
      P_SEGMENT IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := ECDP_FORECAST_CURVE.SEGMENTENDDATE      (
         P_FCST_CURVE_ID,
         P_PHASE,
         P_SEGMENT );
         RETURN ret_value;
   END SEGMENTENDDATE;

END RPDP_FORECAST_CURVE;

/
--GRANT EXECUTE ON ECKERNEL_WST.RPDP_FORECAST_CURVE TO REPORT_ROLE_XXX;



 -- FINISH PKG_GEN_PKGS.sf_get_functions at:05/07/2019 11.49.08 AM


