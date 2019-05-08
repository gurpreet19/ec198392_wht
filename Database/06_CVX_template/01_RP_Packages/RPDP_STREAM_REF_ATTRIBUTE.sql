
 -- START PKG_GEN_PKGS.sf_get_functions at:05/07/2019 11.44.58 AM


CREATE or REPLACE PACKAGE RPDP_STREAM_REF_ATTRIBUTE
IS

   FUNCTION HIGH_GOR_MAX
      RETURN VARCHAR2;
   FUNCTION SR_FACTOR_STATFJORD_OST
      RETURN VARCHAR2;
   FUNCTION VA_REMOVE_GAS
      RETURN VARCHAR2;
   FUNCTION FUEL_HP_SCAV
      RETURN VARCHAR2;
   FUNCTION SEP_DENSITY
      RETURN VARCHAR2;
   FUNCTION SR_ADD_CONSTANT
      RETURN VARCHAR2;
   FUNCTION SR_FACTOR_STATFJORD_NORTH
      RETURN VARCHAR2;
   FUNCTION SR_PRESS_FACTOR
      RETURN VARCHAR2;
   FUNCTION FUEL_LP_SCAV
      RETURN VARCHAR2;
   FUNCTION N2_RATE
      RETURN VARCHAR2;
   FUNCTION NET_VOL
      RETURN VARCHAR2;
   FUNCTION NET_WATER_CONTENT
      RETURN VARCHAR2;
   FUNCTION VA_TRESHOLD_PCT
      RETURN VARCHAR2;
   FUNCTION FLARE_WATER_CONTENT
      RETURN VARCHAR2;
   FUNCTION GAS_OIL_RATIO
      RETURN VARCHAR2;
   FUNCTION HIGH_GOR_MIN
      RETURN VARCHAR2;
   FUNCTION SR_PRESS_CONSTANT
      RETURN VARCHAR2;
   FUNCTION SR_TEMP_CONSTANT
      RETURN VARCHAR2;
   FUNCTION VENTILE_WATER_CONTENT
      RETURN VARCHAR2;
   FUNCTION PILOT_GAS_RATE
      RETURN VARCHAR2;
   FUNCTION NET_FLARE_FACTOR
      RETURN VARCHAR2;
   FUNCTION BORG_PRT_TOR_PCT
      RETURN VARCHAR2;
   FUNCTION STD_DENSITY
      RETURN VARCHAR2;
   FUNCTION WATER_DENSITY
      RETURN VARCHAR2;

END RPDP_STREAM_REF_ATTRIBUTE;

/



CREATE or REPLACE PACKAGE BODY RPDP_STREAM_REF_ATTRIBUTE
IS

   FUNCTION HIGH_GOR_MAX
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN

         ret_value := ECDP_STREAM_REF_ATTRIBUTE.HIGH_GOR_MAX ;
         RETURN ret_value;
   END HIGH_GOR_MAX;
   FUNCTION SR_FACTOR_STATFJORD_OST
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN

         ret_value := ECDP_STREAM_REF_ATTRIBUTE.SR_FACTOR_STATFJORD_OST ;
         RETURN ret_value;
   END SR_FACTOR_STATFJORD_OST;
   FUNCTION VA_REMOVE_GAS
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN

         ret_value := ECDP_STREAM_REF_ATTRIBUTE.VA_REMOVE_GAS ;
         RETURN ret_value;
   END VA_REMOVE_GAS;
   FUNCTION FUEL_HP_SCAV
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN

         ret_value := ECDP_STREAM_REF_ATTRIBUTE.FUEL_HP_SCAV ;
         RETURN ret_value;
   END FUEL_HP_SCAV;
   FUNCTION SEP_DENSITY
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN

         ret_value := ECDP_STREAM_REF_ATTRIBUTE.SEP_DENSITY ;
         RETURN ret_value;
   END SEP_DENSITY;
   FUNCTION SR_ADD_CONSTANT
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN

         ret_value := ECDP_STREAM_REF_ATTRIBUTE.SR_ADD_CONSTANT ;
         RETURN ret_value;
   END SR_ADD_CONSTANT;
   FUNCTION SR_FACTOR_STATFJORD_NORTH
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN

         ret_value := ECDP_STREAM_REF_ATTRIBUTE.SR_FACTOR_STATFJORD_NORTH ;
         RETURN ret_value;
   END SR_FACTOR_STATFJORD_NORTH;
   FUNCTION SR_PRESS_FACTOR
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN

         ret_value := ECDP_STREAM_REF_ATTRIBUTE.SR_PRESS_FACTOR ;
         RETURN ret_value;
   END SR_PRESS_FACTOR;
   FUNCTION FUEL_LP_SCAV
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN

         ret_value := ECDP_STREAM_REF_ATTRIBUTE.FUEL_LP_SCAV ;
         RETURN ret_value;
   END FUEL_LP_SCAV;
   FUNCTION N2_RATE
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN

         ret_value := ECDP_STREAM_REF_ATTRIBUTE.N2_RATE ;
         RETURN ret_value;
   END N2_RATE;
   FUNCTION NET_VOL
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN

         ret_value := ECDP_STREAM_REF_ATTRIBUTE.NET_VOL ;
         RETURN ret_value;
   END NET_VOL;
   FUNCTION NET_WATER_CONTENT
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN

         ret_value := ECDP_STREAM_REF_ATTRIBUTE.NET_WATER_CONTENT ;
         RETURN ret_value;
   END NET_WATER_CONTENT;
   FUNCTION VA_TRESHOLD_PCT
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN

         ret_value := ECDP_STREAM_REF_ATTRIBUTE.VA_TRESHOLD_PCT ;
         RETURN ret_value;
   END VA_TRESHOLD_PCT;
   FUNCTION FLARE_WATER_CONTENT
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN

         ret_value := ECDP_STREAM_REF_ATTRIBUTE.FLARE_WATER_CONTENT ;
         RETURN ret_value;
   END FLARE_WATER_CONTENT;
   FUNCTION GAS_OIL_RATIO
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN

         ret_value := ECDP_STREAM_REF_ATTRIBUTE.GAS_OIL_RATIO ;
         RETURN ret_value;
   END GAS_OIL_RATIO;
   FUNCTION HIGH_GOR_MIN
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN

         ret_value := ECDP_STREAM_REF_ATTRIBUTE.HIGH_GOR_MIN ;
         RETURN ret_value;
   END HIGH_GOR_MIN;
   FUNCTION SR_PRESS_CONSTANT
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN

         ret_value := ECDP_STREAM_REF_ATTRIBUTE.SR_PRESS_CONSTANT ;
         RETURN ret_value;
   END SR_PRESS_CONSTANT;
   FUNCTION SR_TEMP_CONSTANT
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN

         ret_value := ECDP_STREAM_REF_ATTRIBUTE.SR_TEMP_CONSTANT ;
         RETURN ret_value;
   END SR_TEMP_CONSTANT;
   FUNCTION VENTILE_WATER_CONTENT
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN

         ret_value := ECDP_STREAM_REF_ATTRIBUTE.VENTILE_WATER_CONTENT ;
         RETURN ret_value;
   END VENTILE_WATER_CONTENT;
   FUNCTION PILOT_GAS_RATE
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN

         ret_value := ECDP_STREAM_REF_ATTRIBUTE.PILOT_GAS_RATE ;
         RETURN ret_value;
   END PILOT_GAS_RATE;
   FUNCTION NET_FLARE_FACTOR
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN

         ret_value := ECDP_STREAM_REF_ATTRIBUTE.NET_FLARE_FACTOR ;
         RETURN ret_value;
   END NET_FLARE_FACTOR;
   FUNCTION BORG_PRT_TOR_PCT
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN

         ret_value := ECDP_STREAM_REF_ATTRIBUTE.BORG_PRT_TOR_PCT ;
         RETURN ret_value;
   END BORG_PRT_TOR_PCT;
   FUNCTION STD_DENSITY
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN

         ret_value := ECDP_STREAM_REF_ATTRIBUTE.STD_DENSITY ;
         RETURN ret_value;
   END STD_DENSITY;
   FUNCTION WATER_DENSITY
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN

         ret_value := ECDP_STREAM_REF_ATTRIBUTE.WATER_DENSITY ;
         RETURN ret_value;
   END WATER_DENSITY;

END RPDP_STREAM_REF_ATTRIBUTE;

/
--GRANT EXECUTE ON ECKERNEL_WST.RPDP_STREAM_REF_ATTRIBUTE TO REPORT_ROLE_XXX;



 -- FINISH PKG_GEN_PKGS.sf_get_functions at:05/07/2019 11.45.03 AM


