
 -- START PKG_GEN_PKGS.sf_get_functions at:11/16/2018 09.23.11 AM


CREATE or REPLACE PACKAGE RPDP_LIFT_ACC_FORECAST
IS

   FUNCTION GETFORECASTMONTH(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_XTRA_QTY IN NUMBER DEFAULT 0)
      RETURN NUMBER;
   FUNCTION GETTOTALMONTH(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_XTRA_QTY IN NUMBER DEFAULT 0)
      RETURN NUMBER;

END RPDP_LIFT_ACC_FORECAST;

/



CREATE or REPLACE PACKAGE BODY RPDP_LIFT_ACC_FORECAST
IS

   FUNCTION GETFORECASTMONTH(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_XTRA_QTY IN NUMBER DEFAULT 0)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECDP_LIFT_ACC_FORECAST.GETFORECASTMONTH      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_XTRA_QTY );
         RETURN ret_value;
   END GETFORECASTMONTH;
   FUNCTION GETTOTALMONTH(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_XTRA_QTY IN NUMBER DEFAULT 0)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECDP_LIFT_ACC_FORECAST.GETTOTALMONTH      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_XTRA_QTY );
         RETURN ret_value;
   END GETTOTALMONTH;

END RPDP_LIFT_ACC_FORECAST;

/
--GRANT EXECUTE ON ECKERNEL_WST.RPDP_LIFT_ACC_FORECAST TO REPORT_ROLE_XXX;



 -- FINISH PKG_GEN_PKGS.sf_get_functions at:11/16/2018 09.23.12 AM

