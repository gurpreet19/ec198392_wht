
 -- START PKG_GEN_PKGS.sf_get_functions at:11/15/2018 09.06.16 AM


CREATE or REPLACE PACKAGE RP_INSTALL_CONSTANTS
IS

   FUNCTION ISBLOCKEDAPPSPACECNTX(
      P_APP_SPACE_CNTXS IN VARCHAR2)
      RETURN INTEGER;
   FUNCTION GETBLOCKEDAPPSPACECNTXS
      RETURN VARCHAR2;

END RP_INSTALL_CONSTANTS;

/



CREATE or REPLACE PACKAGE BODY RP_INSTALL_CONSTANTS
IS

   FUNCTION ISBLOCKEDAPPSPACECNTX(
      P_APP_SPACE_CNTXS IN VARCHAR2)
      RETURN INTEGER
   IS
      ret_value   INTEGER ;
   BEGIN
      ret_value := EC_INSTALL_CONSTANTS.ISBLOCKEDAPPSPACECNTX      (
         P_APP_SPACE_CNTXS );
         RETURN ret_value;
   END ISBLOCKEDAPPSPACECNTX;
   FUNCTION GETBLOCKEDAPPSPACECNTXS
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN

         ret_value := EC_INSTALL_CONSTANTS.GETBLOCKEDAPPSPACECNTXS ;
         RETURN ret_value;
   END GETBLOCKEDAPPSPACECNTXS;

END RP_INSTALL_CONSTANTS;

/
--GRANT EXECUTE ON ECKERNEL_WST.RP_INSTALL_CONSTANTS TO REPORT_ROLE_XXX;



 -- FINISH PKG_GEN_PKGS.sf_get_functions at:11/15/2018 09.06.17 AM


