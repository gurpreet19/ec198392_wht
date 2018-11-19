
 -- START PKG_GEN_PKGS.sf_get_functions at:11/16/2018 09.18.10 AM


CREATE or REPLACE PACKAGE RPDP_WELL_DECLINE
IS

   FUNCTION GETCURVEEXP(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_TREND_PARAMETER IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION GETPRODUCTIONRATE(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_TREND_PARAMETER IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION GETYFROMX(
      P_X_VALUE IN NUMBER,
      P_C0 IN NUMBER,
      P_C1 IN NUMBER,
      P_TREND_METHOD IN VARCHAR2,
      P_C2 IN NUMBER DEFAULT NULL)
      RETURN NUMBER;

END RPDP_WELL_DECLINE;

/



CREATE or REPLACE PACKAGE BODY RPDP_WELL_DECLINE
IS

   FUNCTION GETCURVEEXP(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_TREND_PARAMETER IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECDP_WELL_DECLINE.GETCURVEEXP      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_TREND_PARAMETER );
         RETURN ret_value;
   END GETCURVEEXP;
   FUNCTION GETPRODUCTIONRATE(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_TREND_PARAMETER IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECDP_WELL_DECLINE.GETPRODUCTIONRATE      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_TREND_PARAMETER );
         RETURN ret_value;
   END GETPRODUCTIONRATE;
   FUNCTION GETYFROMX(
      P_X_VALUE IN NUMBER,
      P_C0 IN NUMBER,
      P_C1 IN NUMBER,
      P_TREND_METHOD IN VARCHAR2,
      P_C2 IN NUMBER DEFAULT NULL)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECDP_WELL_DECLINE.GETYFROMX      (
         P_X_VALUE,
         P_C0,
         P_C1,
         P_TREND_METHOD,
         P_C2 );
         RETURN ret_value;
   END GETYFROMX;

END RPDP_WELL_DECLINE;

/
--GRANT EXECUTE ON ECKERNEL_WST.RPDP_WELL_DECLINE TO REPORT_ROLE_XXX;



 -- FINISH PKG_GEN_PKGS.sf_get_functions at:11/16/2018 09.18.12 AM


