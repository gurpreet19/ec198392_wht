
 -- START PKG_GEN_PKGS.sf_get_functions at:05/08/2019 03.36.35 AM


CREATE or REPLACE PACKAGE RPBP_WELL_PLT
IS

   FUNCTION CALCPERCENT(
      P_OBJECT_ID IN VARCHAR2,
      P_PERF_INTERVAL_ID IN VARCHAR2,
      P_PHASE IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN NUMBER;
   FUNCTION CALCTOTAL(
      P_OBJECT_ID IN VARCHAR2,
      P_PHASE IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN NUMBER;

END RPBP_WELL_PLT;

/



CREATE or REPLACE PACKAGE BODY RPBP_WELL_PLT
IS

   FUNCTION CALCPERCENT(
      P_OBJECT_ID IN VARCHAR2,
      P_PERF_INTERVAL_ID IN VARCHAR2,
      P_PHASE IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECBP_WELL_PLT.CALCPERCENT      (
         P_OBJECT_ID,
         P_PERF_INTERVAL_ID,
         P_PHASE,
         P_DAYTIME );
         RETURN ret_value;
   END CALCPERCENT;
   FUNCTION CALCTOTAL(
      P_OBJECT_ID IN VARCHAR2,
      P_PHASE IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECBP_WELL_PLT.CALCTOTAL      (
         P_OBJECT_ID,
         P_PHASE,
         P_DAYTIME );
         RETURN ret_value;
   END CALCTOTAL;

END RPBP_WELL_PLT;

/
--GRANT EXECUTE ON ECKERNEL_WST.RPBP_WELL_PLT TO REPORT_ROLE_XXX;



 -- FINISH PKG_GEN_PKGS.sf_get_functions at:05/08/2019 03.36.36 AM


