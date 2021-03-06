
 -- START PKG_GEN_PKGS.sf_get_functions at:05/08/2019 03.38.33 AM


CREATE or REPLACE PACKAGE RPBP_FLOWLINE_THEORETICAL
IS

   FUNCTION FINDGASOILRATIO(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_CALC_METHOD IN VARCHAR2 DEFAULT NULL,
      P_CLASS_NAME IN VARCHAR2 DEFAULT NULL)
      RETURN NUMBER;
   FUNCTION FINDWATERCUTPCT(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_CALC_METHOD IN VARCHAR2 DEFAULT NULL,
      P_CLASS_NAME IN VARCHAR2 DEFAULT NULL,
      P_RESULT_NO IN NUMBER DEFAULT NULL)
      RETURN NUMBER;
   FUNCTION FINDHCMASSDAY(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_CALC_METHOD IN VARCHAR2 DEFAULT NULL)
      RETURN NUMBER;
   FUNCTION FINDOILMASSDAY(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_CALC_METHOD IN VARCHAR2 DEFAULT NULL)
      RETURN NUMBER;
   FUNCTION GETOILSTDVOLSUBDAY(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_CALC_METHOD IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION GETWATSTDVOLSUBDAY(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_CALC_METHOD IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION FINDWATERGASRATIO(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_CALC_METHOD IN VARCHAR2 DEFAULT NULL,
      P_CLASS_NAME IN VARCHAR2 DEFAULT NULL)
      RETURN NUMBER;
   FUNCTION GETALLOCCONDVOLDAY(
      P_FLOWLINE_ID IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN NUMBER;
   FUNCTION GETALLOCOILVOLDAY(
      P_FLOWLINE_ID IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN NUMBER;
   FUNCTION GETCONDSTDVOLSUBDAY(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_CALC_METHOD IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION GETSUBSEAWELLMASSRATEDAY(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_PHASE IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION FINDWATERMASSDAY(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_CALC_METHOD IN VARCHAR2 DEFAULT NULL)
      RETURN NUMBER;
   FUNCTION GETCONDSTDRATEDAY(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_CALC_METHOD IN VARCHAR2 DEFAULT NULL)
      RETURN NUMBER;
   FUNCTION GETGASSTDRATEDAY(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_CALC_METHOD IN VARCHAR2 DEFAULT NULL)
      RETURN NUMBER;
   FUNCTION GETINJECTEDSTDRATEDAY(
      P_OBJECT_ID IN VARCHAR2,
      P_INJ_TYPE IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_CALC_INJ_METHOD IN VARCHAR2 DEFAULT NULL)
      RETURN NUMBER;
   FUNCTION GETGASSTDVOLSUBDAY(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_CALC_METHOD IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION FINDCONDGASRATIO(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_CALC_METHOD IN VARCHAR2 DEFAULT NULL,
      P_CLASS_NAME IN VARCHAR2 DEFAULT NULL)
      RETURN NUMBER;
   FUNCTION FINDWETDRYFACTOR(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_CALC_METHOD IN VARCHAR2 DEFAULT NULL )
      RETURN NUMBER;
   FUNCTION GETGASLIFTSTDRATEDAY(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_GAS_LIFT_METHOD IN VARCHAR2 default NULL)
      RETURN NUMBER;
   FUNCTION GETOILSTDRATEDAY(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_CALC_METHOD IN VARCHAR2 DEFAULT NULL)
      RETURN NUMBER;
   FUNCTION GETWATSTDRATEDAY(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_CALC_METHOD IN VARCHAR2 DEFAULT NULL)
      RETURN NUMBER;
   FUNCTION FINDCONDMASSDAY(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_CALC_METHOD IN VARCHAR2 DEFAULT NULL)
      RETURN NUMBER;
   FUNCTION GETCURVERATE(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_PHASE IN VARCHAR2,
      P_CURVE_PURPOSE IN VARCHAR2,
      P_CHOKE_SIZE IN NUMBER,
      P_FLWL_PRESS IN NUMBER,
      P_FLWL_TEMP IN NUMBER,
      P_FLWL_USC_PRESS IN NUMBER,
      P_FLWL_USC_TEMP IN NUMBER,
      P_FLWL_DSC_PRESS IN NUMBER,
      P_FLWL_DSC_TEMP IN NUMBER,
      P_MPM_OIL_RATE IN NUMBER,
      P_MPM_GAS_RATE IN NUMBER,
      P_MPM_WATER_RATE IN NUMBER,
      P_MPM_COND_RATE IN NUMBER,
      P_PRESSURE_ZONE IN VARCHAR2 DEFAULT 'NORMAL',
      P_CALC_METHOD IN VARCHAR2 DEFAULT NULL)
      RETURN NUMBER;
   FUNCTION FINDGASMASSDAY(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_CALC_METHOD IN VARCHAR2 DEFAULT NULL)
      RETURN NUMBER;
   FUNCTION GETALLOCGASVOLDAY(
      P_FLOWLINE_ID IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN NUMBER;
   FUNCTION GETALLOCWATERVOLDAY(
      P_FLOWLINE_ID IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN NUMBER;

END RPBP_FLOWLINE_THEORETICAL;

/



CREATE or REPLACE PACKAGE BODY RPBP_FLOWLINE_THEORETICAL
IS

   FUNCTION FINDGASOILRATIO(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_CALC_METHOD IN VARCHAR2 DEFAULT NULL,
      P_CLASS_NAME IN VARCHAR2 DEFAULT NULL)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECBP_FLOWLINE_THEORETICAL.FINDGASOILRATIO      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_CALC_METHOD,
         P_CLASS_NAME );
         RETURN ret_value;
   END FINDGASOILRATIO;
   FUNCTION FINDWATERCUTPCT(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_CALC_METHOD IN VARCHAR2 DEFAULT NULL,
      P_CLASS_NAME IN VARCHAR2 DEFAULT NULL,
      P_RESULT_NO IN NUMBER DEFAULT NULL)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECBP_FLOWLINE_THEORETICAL.FINDWATERCUTPCT      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_CALC_METHOD,
         P_CLASS_NAME,
         P_RESULT_NO );
         RETURN ret_value;
   END FINDWATERCUTPCT;
   FUNCTION FINDHCMASSDAY(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_CALC_METHOD IN VARCHAR2 DEFAULT NULL)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECBP_FLOWLINE_THEORETICAL.FINDHCMASSDAY      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_CALC_METHOD );
         RETURN ret_value;
   END FINDHCMASSDAY;
   FUNCTION FINDOILMASSDAY(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_CALC_METHOD IN VARCHAR2 DEFAULT NULL)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECBP_FLOWLINE_THEORETICAL.FINDOILMASSDAY      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_CALC_METHOD );
         RETURN ret_value;
   END FINDOILMASSDAY;
   FUNCTION GETOILSTDVOLSUBDAY(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_CALC_METHOD IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECBP_FLOWLINE_THEORETICAL.GETOILSTDVOLSUBDAY      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_CALC_METHOD );
         RETURN ret_value;
   END GETOILSTDVOLSUBDAY;
   FUNCTION GETWATSTDVOLSUBDAY(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_CALC_METHOD IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECBP_FLOWLINE_THEORETICAL.GETWATSTDVOLSUBDAY      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_CALC_METHOD );
         RETURN ret_value;
   END GETWATSTDVOLSUBDAY;
   FUNCTION FINDWATERGASRATIO(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_CALC_METHOD IN VARCHAR2 DEFAULT NULL,
      P_CLASS_NAME IN VARCHAR2 DEFAULT NULL)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECBP_FLOWLINE_THEORETICAL.FINDWATERGASRATIO      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_CALC_METHOD,
         P_CLASS_NAME );
         RETURN ret_value;
   END FINDWATERGASRATIO;
   FUNCTION GETALLOCCONDVOLDAY(
      P_FLOWLINE_ID IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECBP_FLOWLINE_THEORETICAL.GETALLOCCONDVOLDAY      (
         P_FLOWLINE_ID,
         P_DAYTIME );
         RETURN ret_value;
   END GETALLOCCONDVOLDAY;
   FUNCTION GETALLOCOILVOLDAY(
      P_FLOWLINE_ID IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECBP_FLOWLINE_THEORETICAL.GETALLOCOILVOLDAY      (
         P_FLOWLINE_ID,
         P_DAYTIME );
         RETURN ret_value;
   END GETALLOCOILVOLDAY;
   FUNCTION GETCONDSTDVOLSUBDAY(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_CALC_METHOD IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECBP_FLOWLINE_THEORETICAL.GETCONDSTDVOLSUBDAY      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_CALC_METHOD );
         RETURN ret_value;
   END GETCONDSTDVOLSUBDAY;
   FUNCTION GETSUBSEAWELLMASSRATEDAY(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_PHASE IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECBP_FLOWLINE_THEORETICAL.GETSUBSEAWELLMASSRATEDAY      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_PHASE );
         RETURN ret_value;
   END GETSUBSEAWELLMASSRATEDAY;
   FUNCTION FINDWATERMASSDAY(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_CALC_METHOD IN VARCHAR2 DEFAULT NULL)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECBP_FLOWLINE_THEORETICAL.FINDWATERMASSDAY      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_CALC_METHOD );
         RETURN ret_value;
   END FINDWATERMASSDAY;
   FUNCTION GETCONDSTDRATEDAY(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_CALC_METHOD IN VARCHAR2 DEFAULT NULL)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECBP_FLOWLINE_THEORETICAL.GETCONDSTDRATEDAY      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_CALC_METHOD );
         RETURN ret_value;
   END GETCONDSTDRATEDAY;
   FUNCTION GETGASSTDRATEDAY(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_CALC_METHOD IN VARCHAR2 DEFAULT NULL)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECBP_FLOWLINE_THEORETICAL.GETGASSTDRATEDAY      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_CALC_METHOD );
         RETURN ret_value;
   END GETGASSTDRATEDAY;
   FUNCTION GETINJECTEDSTDRATEDAY(
      P_OBJECT_ID IN VARCHAR2,
      P_INJ_TYPE IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_CALC_INJ_METHOD IN VARCHAR2 DEFAULT NULL)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECBP_FLOWLINE_THEORETICAL.GETINJECTEDSTDRATEDAY      (
         P_OBJECT_ID,
         P_INJ_TYPE,
         P_DAYTIME,
         P_CALC_INJ_METHOD );
         RETURN ret_value;
   END GETINJECTEDSTDRATEDAY;
   FUNCTION GETGASSTDVOLSUBDAY(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_CALC_METHOD IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECBP_FLOWLINE_THEORETICAL.GETGASSTDVOLSUBDAY      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_CALC_METHOD );
         RETURN ret_value;
   END GETGASSTDVOLSUBDAY;
   FUNCTION FINDCONDGASRATIO(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_CALC_METHOD IN VARCHAR2 DEFAULT NULL,
      P_CLASS_NAME IN VARCHAR2 DEFAULT NULL)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECBP_FLOWLINE_THEORETICAL.FINDCONDGASRATIO      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_CALC_METHOD,
         P_CLASS_NAME );
         RETURN ret_value;
   END FINDCONDGASRATIO;
   FUNCTION FINDWETDRYFACTOR(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_CALC_METHOD IN VARCHAR2 DEFAULT NULL )
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECBP_FLOWLINE_THEORETICAL.FINDWETDRYFACTOR      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_CALC_METHOD );
         RETURN ret_value;
   END FINDWETDRYFACTOR;
   FUNCTION GETGASLIFTSTDRATEDAY(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_GAS_LIFT_METHOD IN VARCHAR2 default NULL)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECBP_FLOWLINE_THEORETICAL.GETGASLIFTSTDRATEDAY      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_GAS_LIFT_METHOD );
         RETURN ret_value;
   END GETGASLIFTSTDRATEDAY;
   FUNCTION GETOILSTDRATEDAY(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_CALC_METHOD IN VARCHAR2 DEFAULT NULL)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECBP_FLOWLINE_THEORETICAL.GETOILSTDRATEDAY      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_CALC_METHOD );
         RETURN ret_value;
   END GETOILSTDRATEDAY;
   FUNCTION GETWATSTDRATEDAY(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_CALC_METHOD IN VARCHAR2 DEFAULT NULL)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECBP_FLOWLINE_THEORETICAL.GETWATSTDRATEDAY      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_CALC_METHOD );
         RETURN ret_value;
   END GETWATSTDRATEDAY;
   FUNCTION FINDCONDMASSDAY(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_CALC_METHOD IN VARCHAR2 DEFAULT NULL)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECBP_FLOWLINE_THEORETICAL.FINDCONDMASSDAY      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_CALC_METHOD );
         RETURN ret_value;
   END FINDCONDMASSDAY;
   FUNCTION GETCURVERATE(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_PHASE IN VARCHAR2,
      P_CURVE_PURPOSE IN VARCHAR2,
      P_CHOKE_SIZE IN NUMBER,
      P_FLWL_PRESS IN NUMBER,
      P_FLWL_TEMP IN NUMBER,
      P_FLWL_USC_PRESS IN NUMBER,
      P_FLWL_USC_TEMP IN NUMBER,
      P_FLWL_DSC_PRESS IN NUMBER,
      P_FLWL_DSC_TEMP IN NUMBER,
      P_MPM_OIL_RATE IN NUMBER,
      P_MPM_GAS_RATE IN NUMBER,
      P_MPM_WATER_RATE IN NUMBER,
      P_MPM_COND_RATE IN NUMBER,
      P_PRESSURE_ZONE IN VARCHAR2 DEFAULT 'NORMAL',
      P_CALC_METHOD IN VARCHAR2 DEFAULT NULL)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECBP_FLOWLINE_THEORETICAL.GETCURVERATE      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_PHASE,
         P_CURVE_PURPOSE,
         P_CHOKE_SIZE,
         P_FLWL_PRESS,
         P_FLWL_TEMP,
         P_FLWL_USC_PRESS,
         P_FLWL_USC_TEMP,
         P_FLWL_DSC_PRESS,
         P_FLWL_DSC_TEMP,
         P_MPM_OIL_RATE,
         P_MPM_GAS_RATE,
         P_MPM_WATER_RATE,
         P_MPM_COND_RATE,
         P_PRESSURE_ZONE,
         P_CALC_METHOD );
         RETURN ret_value;
   END GETCURVERATE;
   FUNCTION FINDGASMASSDAY(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE,
      P_CALC_METHOD IN VARCHAR2 DEFAULT NULL)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECBP_FLOWLINE_THEORETICAL.FINDGASMASSDAY      (
         P_OBJECT_ID,
         P_DAYTIME,
         P_CALC_METHOD );
         RETURN ret_value;
   END FINDGASMASSDAY;
   FUNCTION GETALLOCGASVOLDAY(
      P_FLOWLINE_ID IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECBP_FLOWLINE_THEORETICAL.GETALLOCGASVOLDAY      (
         P_FLOWLINE_ID,
         P_DAYTIME );
         RETURN ret_value;
   END GETALLOCGASVOLDAY;
   FUNCTION GETALLOCWATERVOLDAY(
      P_FLOWLINE_ID IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECBP_FLOWLINE_THEORETICAL.GETALLOCWATERVOLDAY      (
         P_FLOWLINE_ID,
         P_DAYTIME );
         RETURN ret_value;
   END GETALLOCWATERVOLDAY;

END RPBP_FLOWLINE_THEORETICAL;

/
--GRANT EXECUTE ON ECKERNEL_WST.RPBP_FLOWLINE_THEORETICAL TO REPORT_ROLE_XXX;



 -- FINISH PKG_GEN_PKGS.sf_get_functions at:05/08/2019 03.38.39 AM


