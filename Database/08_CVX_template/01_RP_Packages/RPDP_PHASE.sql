
 -- START PKG_GEN_PKGS.sf_get_functions at:05/07/2019 11.47.18 AM


CREATE or REPLACE PACKAGE RPDP_PHASE
IS

   FUNCTION GAS_LIFT
      RETURN VARCHAR2;
   FUNCTION WATER
      RETURN VARCHAR2;
   FUNCTION GAS_INJ
      RETURN VARCHAR2;
   FUNCTION GAS_MASS
      RETURN VARCHAR2;
   FUNCTION HC
      RETURN VARCHAR2;
   FUNCTION OIL_MASS
      RETURN VARCHAR2;
   FUNCTION DIESEL
      RETURN VARCHAR2;
   FUNCTION WATER_MASS
      RETURN VARCHAR2;
   FUNCTION CONDENSATE
      RETURN VARCHAR2;
   FUNCTION CONDENSATE_MASS
      RETURN VARCHAR2;
   FUNCTION CRUDE
      RETURN VARCHAR2;
   FUNCTION LIQUID
      RETURN VARCHAR2;
   FUNCTION NGL
      RETURN VARCHAR2;
   FUNCTION OIL
      RETURN VARCHAR2;
   FUNCTION STEAM
      RETURN VARCHAR2;
   FUNCTION WAT_INJ
      RETURN VARCHAR2;
   FUNCTION GAS
      RETURN VARCHAR2;

END RPDP_PHASE;

/



CREATE or REPLACE PACKAGE BODY RPDP_PHASE
IS

   FUNCTION GAS_LIFT
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN

         ret_value := ECDP_PHASE.GAS_LIFT ;
         RETURN ret_value;
   END GAS_LIFT;
   FUNCTION WATER
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN

         ret_value := ECDP_PHASE.WATER ;
         RETURN ret_value;
   END WATER;
   FUNCTION GAS_INJ
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN

         ret_value := ECDP_PHASE.GAS_INJ ;
         RETURN ret_value;
   END GAS_INJ;
   FUNCTION GAS_MASS
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN

         ret_value := ECDP_PHASE.GAS_MASS ;
         RETURN ret_value;
   END GAS_MASS;
   FUNCTION HC
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN

         ret_value := ECDP_PHASE.HC ;
         RETURN ret_value;
   END HC;
   FUNCTION OIL_MASS
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN

         ret_value := ECDP_PHASE.OIL_MASS ;
         RETURN ret_value;
   END OIL_MASS;
   FUNCTION DIESEL
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN

         ret_value := ECDP_PHASE.DIESEL ;
         RETURN ret_value;
   END DIESEL;
   FUNCTION WATER_MASS
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN

         ret_value := ECDP_PHASE.WATER_MASS ;
         RETURN ret_value;
   END WATER_MASS;
   FUNCTION CONDENSATE
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN

         ret_value := ECDP_PHASE.CONDENSATE ;
         RETURN ret_value;
   END CONDENSATE;
   FUNCTION CONDENSATE_MASS
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN

         ret_value := ECDP_PHASE.CONDENSATE_MASS ;
         RETURN ret_value;
   END CONDENSATE_MASS;
   FUNCTION CRUDE
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN

         ret_value := ECDP_PHASE.CRUDE ;
         RETURN ret_value;
   END CRUDE;
   FUNCTION LIQUID
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN

         ret_value := ECDP_PHASE.LIQUID ;
         RETURN ret_value;
   END LIQUID;
   FUNCTION NGL
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN

         ret_value := ECDP_PHASE.NGL ;
         RETURN ret_value;
   END NGL;
   FUNCTION OIL
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN

         ret_value := ECDP_PHASE.OIL ;
         RETURN ret_value;
   END OIL;
   FUNCTION STEAM
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN

         ret_value := ECDP_PHASE.STEAM ;
         RETURN ret_value;
   END STEAM;
   FUNCTION WAT_INJ
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN

         ret_value := ECDP_PHASE.WAT_INJ ;
         RETURN ret_value;
   END WAT_INJ;
   FUNCTION GAS
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN

         ret_value := ECDP_PHASE.GAS ;
         RETURN ret_value;
   END GAS;

END RPDP_PHASE;

/
--GRANT EXECUTE ON ECKERNEL_WST.RPDP_PHASE TO REPORT_ROLE_XXX;



 -- FINISH PKG_GEN_PKGS.sf_get_functions at:05/07/2019 11.47.22 AM


