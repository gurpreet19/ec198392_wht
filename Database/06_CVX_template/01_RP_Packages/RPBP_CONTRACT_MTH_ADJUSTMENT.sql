
 -- START PKG_GEN_PKGS.sf_get_functions at:05/08/2019 03.39.16 AM


CREATE or REPLACE PACKAGE RPBP_CONTRACT_MTH_ADJUSTMENT
IS

   FUNCTION GETALLOCATEDCOMPANYADJUSTEDVOL(
      P_COMPANY_ID IN VARCHAR2,
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN NUMBER;

END RPBP_CONTRACT_MTH_ADJUSTMENT;

/



CREATE or REPLACE PACKAGE BODY RPBP_CONTRACT_MTH_ADJUSTMENT
IS

   FUNCTION GETALLOCATEDCOMPANYADJUSTEDVOL(
      P_COMPANY_ID IN VARCHAR2,
      P_OBJECT_ID IN VARCHAR2,
      P_DAYTIME IN DATE)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECBP_CONTRACT_MTH_ADJUSTMENT.GETALLOCATEDCOMPANYADJUSTEDVOL      (
         P_COMPANY_ID,
         P_OBJECT_ID,
         P_DAYTIME );
         RETURN ret_value;
   END GETALLOCATEDCOMPANYADJUSTEDVOL;

END RPBP_CONTRACT_MTH_ADJUSTMENT;

/
--GRANT EXECUTE ON ECKERNEL_WST.RPBP_CONTRACT_MTH_ADJUSTMENT TO REPORT_ROLE_XXX;



 -- FINISH PKG_GEN_PKGS.sf_get_functions at:05/08/2019 03.39.17 AM


