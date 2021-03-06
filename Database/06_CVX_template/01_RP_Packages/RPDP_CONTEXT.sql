
 -- START PKG_GEN_PKGS.sf_get_functions at:05/07/2019 11.51.01 AM


CREATE or REPLACE PACKAGE RPDP_CONTEXT
IS

   FUNCTION GETAPPUSER
      RETURN VARCHAR2;
   FUNCTION ISAPPUSERROLE(
      P_ROLE_ID IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION GETCACHEDUSERROLES(
      P_USER_ID IN VARCHAR2)
      RETURN ECDP_CONTEXT.VARCHAR32L_T;
   FUNCTION GETUSERROLES
      RETURN ECDP_CONTEXT.VARCHAR32L_T;

END RPDP_CONTEXT;

/



CREATE or REPLACE PACKAGE BODY RPDP_CONTEXT
IS

   FUNCTION GETAPPUSER
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN

         ret_value := ECDP_CONTEXT.GETAPPUSER ;
         RETURN ret_value;
   END GETAPPUSER;
   FUNCTION ISAPPUSERROLE(
      P_ROLE_ID IN VARCHAR2)
      RETURN NUMBER
   IS
      ret_value   NUMBER ;
   BEGIN
      ret_value := ECDP_CONTEXT.ISAPPUSERROLE      (
         P_ROLE_ID );
         RETURN ret_value;
   END ISAPPUSERROLE;
   FUNCTION GETCACHEDUSERROLES(
      P_USER_ID IN VARCHAR2)
      RETURN ECDP_CONTEXT.VARCHAR32L_T
   IS
      ret_value    ECDP_CONTEXT.VARCHAR32L_T ;
   BEGIN
      ret_value := ECDP_CONTEXT.GETCACHEDUSERROLES      (
         P_USER_ID );
         RETURN ret_value;
   END GETCACHEDUSERROLES;
   FUNCTION GETUSERROLES
      RETURN ECDP_CONTEXT.VARCHAR32L_T
   IS
      ret_value    ECDP_CONTEXT.VARCHAR32L_T ;
   BEGIN

         ret_value := ECDP_CONTEXT.GETUSERROLES ;
         RETURN ret_value;
   END GETUSERROLES;

END RPDP_CONTEXT;

/
--GRANT EXECUTE ON ECKERNEL_WST.RPDP_CONTEXT TO REPORT_ROLE_XXX;



 -- FINISH PKG_GEN_PKGS.sf_get_functions at:05/07/2019 11.51.02 AM


