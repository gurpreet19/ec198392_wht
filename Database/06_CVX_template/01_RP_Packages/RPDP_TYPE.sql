
 -- START PKG_GEN_PKGS.sf_get_functions at:11/16/2018 09.18.43 AM


CREATE or REPLACE PACKAGE RPDP_TYPE
IS

   FUNCTION IS_TRUE
      RETURN VARCHAR2;
   FUNCTION IS_FALSE
      RETURN VARCHAR2;

END RPDP_TYPE;

/



CREATE or REPLACE PACKAGE BODY RPDP_TYPE
IS

   FUNCTION IS_TRUE
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN

         ret_value := ECDP_TYPE.IS_TRUE ;
         RETURN ret_value;
   END IS_TRUE;
   FUNCTION IS_FALSE
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN

         ret_value := ECDP_TYPE.IS_FALSE ;
         RETURN ret_value;
   END IS_FALSE;

END RPDP_TYPE;

/
--GRANT EXECUTE ON ECKERNEL_WST.RPDP_TYPE TO REPORT_ROLE_XXX;



 -- FINISH PKG_GEN_PKGS.sf_get_functions at:11/16/2018 09.18.43 AM


