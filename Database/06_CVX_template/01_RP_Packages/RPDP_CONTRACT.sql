
 -- START PKG_GEN_PKGS.sf_get_functions at:11/16/2018 09.25.25 AM


CREATE or REPLACE PACKAGE RPDP_CONTRACT
IS

   FUNCTION GETCONTRACTYEAR(
      P_OBJECT_ID IN VARCHAR2,
      P_CONTRACT_DAY IN DATE)
      RETURN DATE;
   FUNCTION GETCONTRACTYEARSTARTDATE(
      P_OBJECT_ID IN VARCHAR2,
      P_CONTRACT_YEAR IN DATE)
      RETURN DATE;

END RPDP_CONTRACT;

/



CREATE or REPLACE PACKAGE BODY RPDP_CONTRACT
IS

   FUNCTION GETCONTRACTYEAR(
      P_OBJECT_ID IN VARCHAR2,
      P_CONTRACT_DAY IN DATE)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := ECDP_CONTRACT.GETCONTRACTYEAR      (
         P_OBJECT_ID,
         P_CONTRACT_DAY );
         RETURN ret_value;
   END GETCONTRACTYEAR;
   FUNCTION GETCONTRACTYEARSTARTDATE(
      P_OBJECT_ID IN VARCHAR2,
      P_CONTRACT_YEAR IN DATE)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := ECDP_CONTRACT.GETCONTRACTYEARSTARTDATE      (
         P_OBJECT_ID,
         P_CONTRACT_YEAR );
         RETURN ret_value;
   END GETCONTRACTYEARSTARTDATE;

END RPDP_CONTRACT;

/
--GRANT EXECUTE ON ECKERNEL_WST.RPDP_CONTRACT TO REPORT_ROLE_XXX;



 -- FINISH PKG_GEN_PKGS.sf_get_functions at:11/16/2018 09.25.26 AM


