
 -- START PKG_GEN_PKGS.sf_get_functions at:05/07/2019 11.45.50 AM


CREATE or REPLACE PACKAGE RPDP_STORAGE
IS

   FUNCTION ISTANKRELATED(
      P_STORAGE_ID IN VARCHAR2,
      P_TANK_OBJECT_ID IN VARCHAR2)
      RETURN VARCHAR2;

END RPDP_STORAGE;

/



CREATE or REPLACE PACKAGE BODY RPDP_STORAGE
IS

   FUNCTION ISTANKRELATED(
      P_STORAGE_ID IN VARCHAR2,
      P_TANK_OBJECT_ID IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := ECDP_STORAGE.ISTANKRELATED      (
         P_STORAGE_ID,
         P_TANK_OBJECT_ID );
         RETURN ret_value;
   END ISTANKRELATED;

END RPDP_STORAGE;

/
--GRANT EXECUTE ON ECKERNEL_WST.RPDP_STORAGE TO REPORT_ROLE_XXX;



 -- FINISH PKG_GEN_PKGS.sf_get_functions at:05/07/2019 11.45.51 AM


