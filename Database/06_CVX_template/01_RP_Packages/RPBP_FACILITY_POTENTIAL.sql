
 -- START PKG_GEN_PKGS.sf_get_functions at:05/08/2019 03.38.48 AM


CREATE or REPLACE PACKAGE RPBP_FACILITY_POTENTIAL
IS

   FUNCTION GETGASWELLPOTENTIAL(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN NUMBER;
   FUNCTION GETOILWELLPOTENTIAL(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN NUMBER;

END RPBP_FACILITY_POTENTIAL;

/



CREATE or REPLACE PACKAGE BODY RPBP_FACILITY_POTENTIAL
IS

   FUNCTION GETGASWELLPOTENTIAL(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECBP_FACILITY_POTENTIAL.GETGASWELLPOTENTIAL      (
         P_OBJECT_ID,
         P_DAYTIME );
         RETURN ret_value;
   END GETGASWELLPOTENTIAL;
   FUNCTION GETOILWELLPOTENTIAL(
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECBP_FACILITY_POTENTIAL.GETOILWELLPOTENTIAL      (
         P_OBJECT_ID,
         P_DAYTIME );
         RETURN ret_value;
   END GETOILWELLPOTENTIAL;

END RPBP_FACILITY_POTENTIAL;

/
--GRANT EXECUTE ON ECKERNEL_WST.RPBP_FACILITY_POTENTIAL TO REPORT_ROLE_XXX;



 -- FINISH PKG_GEN_PKGS.sf_get_functions at:05/08/2019 03.38.49 AM


