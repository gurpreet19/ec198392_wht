
 -- START PKG_GEN_PKGS.sf_get_functions at:05/07/2019 11.48.59 AM


CREATE or REPLACE PACKAGE RPDP_GENERATE
IS

   FUNCTION IUR_TRIGGERS
      RETURN INTEGER;
   FUNCTION ALL_TRIGGERS
      RETURN INTEGER;
   FUNCTION BASIC_TRIGGERS
      RETURN INTEGER;
   FUNCTION IU_TRIGGERS
      RETURN INTEGER;
   FUNCTION AP_TRIGGERS
      RETURN INTEGER;
   FUNCTION AUT_TRIGGERS
      RETURN INTEGER;
   FUNCTION JN_INDEX
      RETURN INTEGER;
   FUNCTION JN_TRIGGERS
      RETURN INTEGER;
   FUNCTION AIUDT_TRIGGERS
      RETURN INTEGER;
   FUNCTION PACKAGES
      RETURN INTEGER;

END RPDP_GENERATE;

/



CREATE or REPLACE PACKAGE BODY RPDP_GENERATE
IS

   FUNCTION IUR_TRIGGERS
      RETURN INTEGER
   IS
      ret_value   INTEGER ;
   BEGIN

         ret_value := ECDP_GENERATE.IUR_TRIGGERS ;
         RETURN ret_value;
   END IUR_TRIGGERS;
   FUNCTION ALL_TRIGGERS
      RETURN INTEGER
   IS
      ret_value   INTEGER ;
   BEGIN

         ret_value := ECDP_GENERATE.ALL_TRIGGERS ;
         RETURN ret_value;
   END ALL_TRIGGERS;
   FUNCTION BASIC_TRIGGERS
      RETURN INTEGER
   IS
      ret_value   INTEGER ;
   BEGIN

         ret_value := ECDP_GENERATE.BASIC_TRIGGERS ;
         RETURN ret_value;
   END BASIC_TRIGGERS;
   FUNCTION IU_TRIGGERS
      RETURN INTEGER
   IS
      ret_value   INTEGER ;
   BEGIN

         ret_value := ECDP_GENERATE.IU_TRIGGERS ;
         RETURN ret_value;
   END IU_TRIGGERS;
   FUNCTION AP_TRIGGERS
      RETURN INTEGER
   IS
      ret_value   INTEGER ;
   BEGIN

         ret_value := ECDP_GENERATE.AP_TRIGGERS ;
         RETURN ret_value;
   END AP_TRIGGERS;
   FUNCTION AUT_TRIGGERS
      RETURN INTEGER
   IS
      ret_value   INTEGER ;
   BEGIN

         ret_value := ECDP_GENERATE.AUT_TRIGGERS ;
         RETURN ret_value;
   END AUT_TRIGGERS;
   FUNCTION JN_INDEX
      RETURN INTEGER
   IS
      ret_value   INTEGER ;
   BEGIN

         ret_value := ECDP_GENERATE.JN_INDEX ;
         RETURN ret_value;
   END JN_INDEX;
   FUNCTION JN_TRIGGERS
      RETURN INTEGER
   IS
      ret_value   INTEGER ;
   BEGIN

         ret_value := ECDP_GENERATE.JN_TRIGGERS ;
         RETURN ret_value;
   END JN_TRIGGERS;
   FUNCTION AIUDT_TRIGGERS
      RETURN INTEGER
   IS
      ret_value   INTEGER ;
   BEGIN

         ret_value := ECDP_GENERATE.AIUDT_TRIGGERS ;
         RETURN ret_value;
   END AIUDT_TRIGGERS;
   FUNCTION PACKAGES
      RETURN INTEGER
   IS
      ret_value   INTEGER ;
   BEGIN

         ret_value := ECDP_GENERATE.PACKAGES ;
         RETURN ret_value;
   END PACKAGES;

END RPDP_GENERATE;

/
--GRANT EXECUTE ON ECKERNEL_WST.RPDP_GENERATE TO REPORT_ROLE_XXX;



 -- FINISH PKG_GEN_PKGS.sf_get_functions at:05/07/2019 11.49.01 AM


