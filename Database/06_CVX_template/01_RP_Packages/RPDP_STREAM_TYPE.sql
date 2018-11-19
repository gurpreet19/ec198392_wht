
 -- START PKG_GEN_PKGS.sf_get_functions at:11/16/2018 09.19.32 AM


CREATE or REPLACE PACKAGE RPDP_STREAM_TYPE
IS

   FUNCTION DERIVED
      RETURN VARCHAR2;
   FUNCTION FLOWLINE
      RETURN VARCHAR2;
   FUNCTION QUALITY
      RETURN VARCHAR2;
   FUNCTION THEORETICAL
      RETURN VARCHAR2;
   FUNCTION CALCULATED
      RETURN VARCHAR2;
   FUNCTION GAS_EXPORT
      RETURN VARCHAR2;
   FUNCTION GAS_FUEL
      RETURN VARCHAR2;
   FUNCTION OIL_EXPORT
      RETURN VARCHAR2;
   FUNCTION MEASURED
      RETURN VARCHAR2;
   FUNCTION GAS_FLARE
      RETURN VARCHAR2;
   FUNCTION GAS_LOSS
      RETURN VARCHAR2;
   FUNCTION OIL_LOSS
      RETURN VARCHAR2;
   FUNCTION WELL
      RETURN VARCHAR2;

END RPDP_STREAM_TYPE;

/



CREATE or REPLACE PACKAGE BODY RPDP_STREAM_TYPE
IS

   FUNCTION DERIVED
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN

         ret_value := ECDP_STREAM_TYPE.DERIVED ;
         RETURN ret_value;
   END DERIVED;
   FUNCTION FLOWLINE
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN

         ret_value := ECDP_STREAM_TYPE.FLOWLINE ;
         RETURN ret_value;
   END FLOWLINE;
   FUNCTION QUALITY
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN

         ret_value := ECDP_STREAM_TYPE.QUALITY ;
         RETURN ret_value;
   END QUALITY;
   FUNCTION THEORETICAL
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN

         ret_value := ECDP_STREAM_TYPE.THEORETICAL ;
         RETURN ret_value;
   END THEORETICAL;
   FUNCTION CALCULATED
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN

         ret_value := ECDP_STREAM_TYPE.CALCULATED ;
         RETURN ret_value;
   END CALCULATED;
   FUNCTION GAS_EXPORT
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN

         ret_value := ECDP_STREAM_TYPE.GAS_EXPORT ;
         RETURN ret_value;
   END GAS_EXPORT;
   FUNCTION GAS_FUEL
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN

         ret_value := ECDP_STREAM_TYPE.GAS_FUEL ;
         RETURN ret_value;
   END GAS_FUEL;
   FUNCTION OIL_EXPORT
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN

         ret_value := ECDP_STREAM_TYPE.OIL_EXPORT ;
         RETURN ret_value;
   END OIL_EXPORT;
   FUNCTION MEASURED
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN

         ret_value := ECDP_STREAM_TYPE.MEASURED ;
         RETURN ret_value;
   END MEASURED;
   FUNCTION GAS_FLARE
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN

         ret_value := ECDP_STREAM_TYPE.GAS_FLARE ;
         RETURN ret_value;
   END GAS_FLARE;
   FUNCTION GAS_LOSS
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN

         ret_value := ECDP_STREAM_TYPE.GAS_LOSS ;
         RETURN ret_value;
   END GAS_LOSS;
   FUNCTION OIL_LOSS
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN

         ret_value := ECDP_STREAM_TYPE.OIL_LOSS ;
         RETURN ret_value;
   END OIL_LOSS;
   FUNCTION WELL
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN

         ret_value := ECDP_STREAM_TYPE.WELL ;
         RETURN ret_value;
   END WELL;

END RPDP_STREAM_TYPE;

/
--GRANT EXECUTE ON ECKERNEL_WST.RPDP_STREAM_TYPE TO REPORT_ROLE_XXX;



 -- FINISH PKG_GEN_PKGS.sf_get_functions at:11/16/2018 09.19.34 AM


