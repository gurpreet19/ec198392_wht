
 -- START PKG_GEN_PKGS.sf_get_functions at:11/16/2018 09.23.24 AM


CREATE or REPLACE PACKAGE RPDP_IMPORT
IS

   FUNCTION GET_SOURCE_TYPE(
      P_INTERFACE_CODE IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION ISEDITABLECONF(
      P_INTERFACE_CODE IN VARCHAR2,
      P_SOURCE_MAPPING_NO IN NUMBER DEFAULT NULL)
      RETURN VARCHAR2;

END RPDP_IMPORT;

/



CREATE or REPLACE PACKAGE BODY RPDP_IMPORT
IS

   FUNCTION GET_SOURCE_TYPE(
      P_INTERFACE_CODE IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := ECDP_IMPORT.GET_SOURCE_TYPE      (
         P_INTERFACE_CODE );
         RETURN ret_value;
   END GET_SOURCE_TYPE;
   FUNCTION ISEDITABLECONF(
      P_INTERFACE_CODE IN VARCHAR2,
      P_SOURCE_MAPPING_NO IN NUMBER DEFAULT NULL)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := ECDP_IMPORT.ISEDITABLECONF      (
         P_INTERFACE_CODE,
         P_SOURCE_MAPPING_NO );
         RETURN ret_value;
   END ISEDITABLECONF;

END RPDP_IMPORT;

/
--GRANT EXECUTE ON ECKERNEL_WST.RPDP_IMPORT TO REPORT_ROLE_XXX;



 -- FINISH PKG_GEN_PKGS.sf_get_functions at:11/16/2018 09.23.25 AM


