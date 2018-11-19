
 -- START PKG_GEN_PKGS.sf_get_functions at:11/16/2018 09.24.52 AM


CREATE or REPLACE PACKAGE RPDP_CURVE_CONSTANT
IS

   FUNCTION CURVE_POINT
      RETURN VARCHAR2;
   FUNCTION POLYNOM_2
      RETURN VARCHAR2;
   FUNCTION INV_POLYNOM_2
      RETURN VARCHAR2;
   FUNCTION POLYNOM_4
      RETURN VARCHAR2;
   FUNCTION LINEAR
      RETURN VARCHAR2;
   FUNCTION POLYNOM_3
      RETURN VARCHAR2;

END RPDP_CURVE_CONSTANT;

/



CREATE or REPLACE PACKAGE BODY RPDP_CURVE_CONSTANT
IS

   FUNCTION CURVE_POINT
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN

         ret_value := ECDP_CURVE_CONSTANT.CURVE_POINT ;
         RETURN ret_value;
   END CURVE_POINT;
   FUNCTION POLYNOM_2
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN

         ret_value := ECDP_CURVE_CONSTANT.POLYNOM_2 ;
         RETURN ret_value;
   END POLYNOM_2;
   FUNCTION INV_POLYNOM_2
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN

         ret_value := ECDP_CURVE_CONSTANT.INV_POLYNOM_2 ;
         RETURN ret_value;
   END INV_POLYNOM_2;
   FUNCTION POLYNOM_4
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN

         ret_value := ECDP_CURVE_CONSTANT.POLYNOM_4 ;
         RETURN ret_value;
   END POLYNOM_4;
   FUNCTION LINEAR
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN

         ret_value := ECDP_CURVE_CONSTANT.LINEAR ;
         RETURN ret_value;
   END LINEAR;
   FUNCTION POLYNOM_3
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN

         ret_value := ECDP_CURVE_CONSTANT.POLYNOM_3 ;
         RETURN ret_value;
   END POLYNOM_3;

END RPDP_CURVE_CONSTANT;

/
--GRANT EXECUTE ON ECKERNEL_WST.RPDP_CURVE_CONSTANT TO REPORT_ROLE_XXX;



 -- FINISH PKG_GEN_PKGS.sf_get_functions at:11/16/2018 09.24.53 AM


