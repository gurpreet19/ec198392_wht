
 -- START PKG_GEN_PKGS.sf_get_functions at:05/07/2019 11.49.08 AM


CREATE or REPLACE PACKAGE RPDP_FORECAST
IS

   FUNCTION VALIDATEPERIODTYPES(
      P_FROM_FORECAST_ID IN VARCHAR2,
      P_NEW_FORECAST_ID IN VARCHAR2)
      RETURN INTEGER;

END RPDP_FORECAST;

/



CREATE or REPLACE PACKAGE BODY RPDP_FORECAST
IS

   FUNCTION VALIDATEPERIODTYPES(
      P_FROM_FORECAST_ID IN VARCHAR2,
      P_NEW_FORECAST_ID IN VARCHAR2)
      RETURN INTEGER
   IS
      ret_value   INTEGER ;
   BEGIN
      ret_value := ECDP_FORECAST.VALIDATEPERIODTYPES      (
         P_FROM_FORECAST_ID,
         P_NEW_FORECAST_ID );
         RETURN ret_value;
   END VALIDATEPERIODTYPES;

END RPDP_FORECAST;

/
--GRANT EXECUTE ON ECKERNEL_WST.RPDP_FORECAST TO REPORT_ROLE_XXX;



 -- FINISH PKG_GEN_PKGS.sf_get_functions at:05/07/2019 11.49.08 AM

