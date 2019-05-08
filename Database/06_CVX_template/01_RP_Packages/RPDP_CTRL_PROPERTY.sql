
 -- START PKG_GEN_PKGS.sf_get_functions at:05/07/2019 11.50.31 AM


CREATE or REPLACE PACKAGE RPDP_CTRL_PROPERTY
IS

   FUNCTION GETUSERPROPERTY(
      P_KEY IN VARCHAR2,
      P_USER_ID IN VARCHAR2 DEFAULT NULL)
      RETURN VARCHAR2;
   FUNCTION GETSYSTEMPROPERTY(
      P_KEY IN VARCHAR2,
      P_DAYTIME IN DATE DEFAULT NULL)
      RETURN VARCHAR2;

END RPDP_CTRL_PROPERTY;

/



CREATE or REPLACE PACKAGE BODY RPDP_CTRL_PROPERTY
IS

   FUNCTION GETUSERPROPERTY(
      P_KEY IN VARCHAR2,
      P_USER_ID IN VARCHAR2 DEFAULT NULL)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := ECDP_CTRL_PROPERTY.GETUSERPROPERTY      (
         P_KEY,
         P_USER_ID );
         RETURN ret_value;
   END GETUSERPROPERTY;
   FUNCTION GETSYSTEMPROPERTY(
      P_KEY IN VARCHAR2,
      P_DAYTIME IN DATE DEFAULT NULL)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := ECDP_CTRL_PROPERTY.GETSYSTEMPROPERTY      (
         P_KEY,
         P_DAYTIME );
         RETURN ret_value;
   END GETSYSTEMPROPERTY;

END RPDP_CTRL_PROPERTY;

/
--GRANT EXECUTE ON ECKERNEL_WST.RPDP_CTRL_PROPERTY TO REPORT_ROLE_XXX;



 -- FINISH PKG_GEN_PKGS.sf_get_functions at:05/07/2019 11.50.32 AM


