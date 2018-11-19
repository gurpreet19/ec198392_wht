
 -- START PKG_GEN_PKGS.sf_get_functions at:11/16/2018 09.24.44 AM


CREATE or REPLACE PACKAGE RPDP_CURVE_PARAMETER
IS

   FUNCTION AC_FREQUENCY
      RETURN VARCHAR2;
   FUNCTION AVG_DP_VENTURI
      RETURN VARCHAR2;
   FUNCTION DP_FLOWLINE
      RETURN VARCHAR2;
   FUNCTION GAS_RATE
      RETURN VARCHAR2;
   FUNCTION GL_PRESS
      RETURN VARCHAR2;
   FUNCTION MPM_OIL_RATE
      RETURN VARCHAR2;
   FUNCTION SS_PRESS
      RETURN VARCHAR2;
   FUNCTION WH_TEMP
      RETURN VARCHAR2;
   FUNCTION INTAKE_PRESS
      RETURN VARCHAR2;
   FUNCTION PHASE_CURRENT
      RETURN VARCHAR2;
   FUNCTION AVG_FLOW_MASS
      RETURN VARCHAR2;
   FUNCTION HXT_WH_PRESS
      RETURN VARCHAR2;
   FUNCTION MPM_WATER_RATE
      RETURN VARCHAR2;
   FUNCTION DH_PRESS
      RETURN VARCHAR2;
   FUNCTION DP_TUBING
      RETURN VARCHAR2;
   FUNCTION GL_DIFF_PRESS
      RETURN VARCHAR2;
   FUNCTION INJ_VOL_RATE
      RETURN VARCHAR2;
   FUNCTION MPM_COND_RATE
      RETURN VARCHAR2;
   FUNCTION CHOKE_NATURAL
      RETURN VARCHAR2;
   FUNCTION DT_FLOWLINE
      RETURN VARCHAR2;
   FUNCTION GL_CHOKE
      RETURN VARCHAR2;
   FUNCTION LIQUID_RATE
      RETURN VARCHAR2;
   FUNCTION CHOKE
      RETURN VARCHAR2;
   FUNCTION MPM_GAS_RATE
      RETURN VARCHAR2;
   FUNCTION TS_DSC_PRESS
      RETURN VARCHAR2;
   FUNCTION TS_PRESS
      RETURN VARCHAR2;
   FUNCTION WATERCUT_PCT
      RETURN VARCHAR2;
   FUNCTION ANNULUS_PRESS
      RETURN VARCHAR2;
   FUNCTION AVG_DH_PUMP_POWER
      RETURN VARCHAR2;
   FUNCTION DP_CHOKE
      RETURN VARCHAR2;
   FUNCTION DRIVE_FREQUENCY
      RETURN VARCHAR2;
   FUNCTION DRY_OIL_RATE
      RETURN VARCHAR2;
   FUNCTION GL_RATE
      RETURN VARCHAR2;
   FUNCTION RPM
      RETURN VARCHAR2;
   FUNCTION WH_DSC_PRESS
      RETURN VARCHAR2;
   FUNCTION WH_PRESS
      RETURN VARCHAR2;
   FUNCTION DRIVE_CURRENT
      RETURN VARCHAR2;
   FUNCTION MPM_WH_PRESS
      RETURN VARCHAR2;
   FUNCTION NONE
      RETURN VARCHAR2;

END RPDP_CURVE_PARAMETER;

/



CREATE or REPLACE PACKAGE BODY RPDP_CURVE_PARAMETER
IS

   FUNCTION AC_FREQUENCY
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN

         ret_value := ECDP_CURVE_PARAMETER.AC_FREQUENCY ;
         RETURN ret_value;
   END AC_FREQUENCY;
   FUNCTION AVG_DP_VENTURI
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN

         ret_value := ECDP_CURVE_PARAMETER.AVG_DP_VENTURI ;
         RETURN ret_value;
   END AVG_DP_VENTURI;
   FUNCTION DP_FLOWLINE
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN

         ret_value := ECDP_CURVE_PARAMETER.DP_FLOWLINE ;
         RETURN ret_value;
   END DP_FLOWLINE;
   FUNCTION GAS_RATE
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN

         ret_value := ECDP_CURVE_PARAMETER.GAS_RATE ;
         RETURN ret_value;
   END GAS_RATE;
   FUNCTION GL_PRESS
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN

         ret_value := ECDP_CURVE_PARAMETER.GL_PRESS ;
         RETURN ret_value;
   END GL_PRESS;
   FUNCTION MPM_OIL_RATE
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN

         ret_value := ECDP_CURVE_PARAMETER.MPM_OIL_RATE ;
         RETURN ret_value;
   END MPM_OIL_RATE;
   FUNCTION SS_PRESS
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN

         ret_value := ECDP_CURVE_PARAMETER.SS_PRESS ;
         RETURN ret_value;
   END SS_PRESS;
   FUNCTION WH_TEMP
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN

         ret_value := ECDP_CURVE_PARAMETER.WH_TEMP ;
         RETURN ret_value;
   END WH_TEMP;
   FUNCTION INTAKE_PRESS
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN

         ret_value := ECDP_CURVE_PARAMETER.INTAKE_PRESS ;
         RETURN ret_value;
   END INTAKE_PRESS;
   FUNCTION PHASE_CURRENT
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN

         ret_value := ECDP_CURVE_PARAMETER.PHASE_CURRENT ;
         RETURN ret_value;
   END PHASE_CURRENT;
   FUNCTION AVG_FLOW_MASS
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN

         ret_value := ECDP_CURVE_PARAMETER.AVG_FLOW_MASS ;
         RETURN ret_value;
   END AVG_FLOW_MASS;
   FUNCTION HXT_WH_PRESS
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN

         ret_value := ECDP_CURVE_PARAMETER.HXT_WH_PRESS ;
         RETURN ret_value;
   END HXT_WH_PRESS;
   FUNCTION MPM_WATER_RATE
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN

         ret_value := ECDP_CURVE_PARAMETER.MPM_WATER_RATE ;
         RETURN ret_value;
   END MPM_WATER_RATE;
   FUNCTION DH_PRESS
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN

         ret_value := ECDP_CURVE_PARAMETER.DH_PRESS ;
         RETURN ret_value;
   END DH_PRESS;
   FUNCTION DP_TUBING
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN

         ret_value := ECDP_CURVE_PARAMETER.DP_TUBING ;
         RETURN ret_value;
   END DP_TUBING;
   FUNCTION GL_DIFF_PRESS
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN

         ret_value := ECDP_CURVE_PARAMETER.GL_DIFF_PRESS ;
         RETURN ret_value;
   END GL_DIFF_PRESS;
   FUNCTION INJ_VOL_RATE
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN

         ret_value := ECDP_CURVE_PARAMETER.INJ_VOL_RATE ;
         RETURN ret_value;
   END INJ_VOL_RATE;
   FUNCTION MPM_COND_RATE
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN

         ret_value := ECDP_CURVE_PARAMETER.MPM_COND_RATE ;
         RETURN ret_value;
   END MPM_COND_RATE;
   FUNCTION CHOKE_NATURAL
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN

         ret_value := ECDP_CURVE_PARAMETER.CHOKE_NATURAL ;
         RETURN ret_value;
   END CHOKE_NATURAL;
   FUNCTION DT_FLOWLINE
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN

         ret_value := ECDP_CURVE_PARAMETER.DT_FLOWLINE ;
         RETURN ret_value;
   END DT_FLOWLINE;
   FUNCTION GL_CHOKE
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN

         ret_value := ECDP_CURVE_PARAMETER.GL_CHOKE ;
         RETURN ret_value;
   END GL_CHOKE;
   FUNCTION LIQUID_RATE
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN

         ret_value := ECDP_CURVE_PARAMETER.LIQUID_RATE ;
         RETURN ret_value;
   END LIQUID_RATE;
   FUNCTION CHOKE
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN

         ret_value := ECDP_CURVE_PARAMETER.CHOKE ;
         RETURN ret_value;
   END CHOKE;
   FUNCTION MPM_GAS_RATE
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN

         ret_value := ECDP_CURVE_PARAMETER.MPM_GAS_RATE ;
         RETURN ret_value;
   END MPM_GAS_RATE;
   FUNCTION TS_DSC_PRESS
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN

         ret_value := ECDP_CURVE_PARAMETER.TS_DSC_PRESS ;
         RETURN ret_value;
   END TS_DSC_PRESS;
   FUNCTION TS_PRESS
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN

         ret_value := ECDP_CURVE_PARAMETER.TS_PRESS ;
         RETURN ret_value;
   END TS_PRESS;
   FUNCTION WATERCUT_PCT
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN

         ret_value := ECDP_CURVE_PARAMETER.WATERCUT_PCT ;
         RETURN ret_value;
   END WATERCUT_PCT;
   FUNCTION ANNULUS_PRESS
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN

         ret_value := ECDP_CURVE_PARAMETER.ANNULUS_PRESS ;
         RETURN ret_value;
   END ANNULUS_PRESS;
   FUNCTION AVG_DH_PUMP_POWER
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN

         ret_value := ECDP_CURVE_PARAMETER.AVG_DH_PUMP_POWER ;
         RETURN ret_value;
   END AVG_DH_PUMP_POWER;
   FUNCTION DP_CHOKE
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN

         ret_value := ECDP_CURVE_PARAMETER.DP_CHOKE ;
         RETURN ret_value;
   END DP_CHOKE;
   FUNCTION DRIVE_FREQUENCY
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN

         ret_value := ECDP_CURVE_PARAMETER.DRIVE_FREQUENCY ;
         RETURN ret_value;
   END DRIVE_FREQUENCY;
   FUNCTION DRY_OIL_RATE
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN

         ret_value := ECDP_CURVE_PARAMETER.DRY_OIL_RATE ;
         RETURN ret_value;
   END DRY_OIL_RATE;
   FUNCTION GL_RATE
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN

         ret_value := ECDP_CURVE_PARAMETER.GL_RATE ;
         RETURN ret_value;
   END GL_RATE;
   FUNCTION RPM
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN

         ret_value := ECDP_CURVE_PARAMETER.RPM ;
         RETURN ret_value;
   END RPM;
   FUNCTION WH_DSC_PRESS
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN

         ret_value := ECDP_CURVE_PARAMETER.WH_DSC_PRESS ;
         RETURN ret_value;
   END WH_DSC_PRESS;
   FUNCTION WH_PRESS
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN

         ret_value := ECDP_CURVE_PARAMETER.WH_PRESS ;
         RETURN ret_value;
   END WH_PRESS;
   FUNCTION DRIVE_CURRENT
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN

         ret_value := ECDP_CURVE_PARAMETER.DRIVE_CURRENT ;
         RETURN ret_value;
   END DRIVE_CURRENT;
   FUNCTION MPM_WH_PRESS
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN

         ret_value := ECDP_CURVE_PARAMETER.MPM_WH_PRESS ;
         RETURN ret_value;
   END MPM_WH_PRESS;
   FUNCTION NONE
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN

         ret_value := ECDP_CURVE_PARAMETER.NONE ;
         RETURN ret_value;
   END NONE;

END RPDP_CURVE_PARAMETER;

/
--GRANT EXECUTE ON ECKERNEL_WST.RPDP_CURVE_PARAMETER TO REPORT_ROLE_XXX;



 -- FINISH PKG_GEN_PKGS.sf_get_functions at:11/16/2018 09.24.52 AM


