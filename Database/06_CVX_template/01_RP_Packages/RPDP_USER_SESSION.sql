
 -- START PKG_GEN_PKGS.sf_get_functions at:11/16/2018 09.18.38 AM


CREATE or REPLACE PACKAGE RPDP_USER_SESSION
IS

   FUNCTION GETUSERSESSIONPARAMETER(
      P_PARAMETER_NAME IN VARCHAR2)
      RETURN VARCHAR2;

END RPDP_USER_SESSION;

/



CREATE or REPLACE PACKAGE BODY RPDP_USER_SESSION
IS

   FUNCTION GETUSERSESSIONPARAMETER(
      P_PARAMETER_NAME IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := ECDP_USER_SESSION.GETUSERSESSIONPARAMETER      (
         P_PARAMETER_NAME );
         RETURN ret_value;
   END GETUSERSESSIONPARAMETER;

END RPDP_USER_SESSION;

/
--GRANT EXECUTE ON ECKERNEL_WST.RPDP_USER_SESSION TO REPORT_ROLE_XXX;



 -- FINISH PKG_GEN_PKGS.sf_get_functions at:11/16/2018 09.18.39 AM


