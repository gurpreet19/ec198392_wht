
 -- START PKG_GEN_PKGS.sf_get_functions at:11/16/2018 09.24.53 AM


CREATE or REPLACE PACKAGE RPDP_CURVE
IS

   FUNCTION GETPREVIOUSPERFCURVE(
      P_PERF_CURVE_ID IN NUMBER,
      P_PHASE IN VARCHAR2 DEFAULT NULL)
      RETURN NUMBER;
   FUNCTION GETRATIOORWCFROMX(
      P_CURVE_ID IN NUMBER,
      P_X_VALUE IN NUMBER,
      P_CONSTANT_TYPE IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION GETYFROMX(
      P_CURVE_ID IN NUMBER,
      P_X_VALUE IN NUMBER)
      RETURN NUMBER;
   FUNCTION GETYFROMXGRAPH(
      P_CURVE_ID IN NUMBER,
      P_X_VALUE IN NUMBER)
      RETURN NUMBER;
   FUNCTION GETMEASUREMENTTYPE(
      P_CURVE_ID IN NUMBER,
      P_CURVE_AXIS IN VARCHAR2)
      RETURN VARCHAR2;

END RPDP_CURVE;

/



CREATE or REPLACE PACKAGE BODY RPDP_CURVE
IS

   FUNCTION GETPREVIOUSPERFCURVE(
      P_PERF_CURVE_ID IN NUMBER,
      P_PHASE IN VARCHAR2 DEFAULT NULL)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECDP_CURVE.GETPREVIOUSPERFCURVE      (
         P_PERF_CURVE_ID,
         P_PHASE );
         RETURN ret_value;
   END GETPREVIOUSPERFCURVE;
   FUNCTION GETRATIOORWCFROMX(
      P_CURVE_ID IN NUMBER,
      P_X_VALUE IN NUMBER,
      P_CONSTANT_TYPE IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECDP_CURVE.GETRATIOORWCFROMX      (
         P_CURVE_ID,
         P_X_VALUE,
         P_CONSTANT_TYPE );
         RETURN ret_value;
   END GETRATIOORWCFROMX;
   FUNCTION GETYFROMX(
      P_CURVE_ID IN NUMBER,
      P_X_VALUE IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECDP_CURVE.GETYFROMX      (
         P_CURVE_ID,
         P_X_VALUE );
         RETURN ret_value;
   END GETYFROMX;
   FUNCTION GETYFROMXGRAPH(
      P_CURVE_ID IN NUMBER,
      P_X_VALUE IN NUMBER)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECDP_CURVE.GETYFROMXGRAPH      (
         P_CURVE_ID,
         P_X_VALUE );
         RETURN ret_value;
   END GETYFROMXGRAPH;
   FUNCTION GETMEASUREMENTTYPE(
      P_CURVE_ID IN NUMBER,
      P_CURVE_AXIS IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := ECDP_CURVE.GETMEASUREMENTTYPE      (
         P_CURVE_ID,
         P_CURVE_AXIS );
         RETURN ret_value;
   END GETMEASUREMENTTYPE;

END RPDP_CURVE;

/
--GRANT EXECUTE ON ECKERNEL_WST.RPDP_CURVE TO REPORT_ROLE_XXX;



 -- FINISH PKG_GEN_PKGS.sf_get_functions at:11/16/2018 09.24.55 AM


