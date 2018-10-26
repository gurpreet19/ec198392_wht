CREATE OR REPLACE PACKAGE BODY EcDp_Well_Theoretical IS
/****************************************************************
** Package        :  EcDp_Well_Theoretical, body part
**
** $Revision: 1.35.2.7 $
**
** Purpose        :  Calculates theoretical well values (rates etc)
**
** Documentation  :  www.energy-components.com
**
** Created  : 02.03.2000  Dagfinn Nj?
**
** Modification history:
**
** Version  Date     Whom  Change description:
** -------  ------   ----- --------------------------------------
** 1.1      09.05.00 AV    Added new function getPerformanceCurveId
** 1.2      29.05.00 AV    Moved 8 functions from EcBp_Well_Theoretical
**                         Changed function getGasOilRatio to handle
**                         gas_method INTERPOLATED_GOR.
** 3.1	    13.05.00 AV	   Changed functions getGasOilRatio and
**                         getLowPressureGasOilRatio to also return a value
**									if calc_method = MPM.
** 4.0      12.09.00 DN    Replaced pck_well reference with ecDp_well.
** 4.1      13.09.00 DN    Removed obsolete function findIndicatedCurveValue.
**                         Replaced old PERF_CURVE references.
** 4.2      17.10.00 TeJ   Added function findRepresentativeBhp
** 4.3      18.09.00 GNO   New function findRepresentativeDSCPress
** 4.5      25.09.00 ØJ    Fixed bug in findRepresentativeOilStdRate. Replaced parameter in call to
**			   EcBp_Performance_Curve.findReprYByParameterCode with
**				performance_curve.curve_parameter_code
** 4.5      26.09.00 ØJ	   Added : findRepresentativeChokeSizeNat
** 4.6      27.09.00 DN    getGasOilRatio: Removed CALC_METHOD-testing.
**                         Only mutually exclusive gas-methods should be used.
** 4.7      24.10.2001     Added return-statement in function getCurveWhpFromStdRate.
** 4.8      09.11.2001     Added watercut_method in function getWaterCutPct.
**                         Added PREVIOUS_WT-method in getGasOilratio.
** 4.9      26.11.01 DN    New function getNextWellPerformanceCurve.
******
*           05.03.04 BIH   Rewrote getPerformanceCurveId to use new EcDp_Performance_Curve
*                          Rewrote getNextWellPerformanceCurve and renamed it to getNextPerformanceCurveId
*                          Removed getLastPerformanceCurve since it was a duplicate of getPerformanceCurveId
*                          Renamed getWaterGasRatio to getGasWaterRatio to match new database model
*                          Added getCurveStdRate and getCurveParamValue
*                          Added type PerfCurveParamRec
*                          Removed code for features that are no longer supported by the performance curves
*                          (trying to use this code now throws an exception).
*                          Removed getCurveChokeFromStdRate and getCurveWhpFromStdRate
*           25.05.2004 FBa Removed references to EcDp_Calc_Methd.PREVIOUS_WT
*           11.08.2004 mazrina    removed sysnam and update as necessary
*           24.02.2005 Toha Removed deadcodes
*                           #1965 update calls to attributes
*	    04.03.2005 kaurrnar	Removed findRepresentativeGasStdRate, getGasOilRatio and getCurveStdRate function
*	    07.03.2005 kaurrnar	Added getGasOilRatio and getCurveStdRate function
*      07.03.2005 DN       Function getGasOilRatio: reduced implementation to only cope with GOR from performance curve.
*      22.03.2005 DN       Removed obsolete function getOilStdQtyDayValidTest
**     29.03.2005 SHN      Removed obsolete functions: findRepresentativeOilStdRate,findRepresentativeDSCPress,
**									findRepresentativeChokeSize,findRepresentativeOilStdRate,findRepresentativeValidDate
**									findRepresentativeWatStdRate,findRepresentativeWhp,findRepresentativeBhp
**     18.04.2005 Toha     TI 1940: added avg_gl_diff_press to record PerfCurveParamRec
**     28.04.2005 DN       Bug fix: local variable holding approach_method must be declared varchar2(32).
**     09.09.2005 Darren   TI 2379: Enhanced getCurveStdrate to support 3 new APPROACH_METHOD
**     30.09.2005 Darren   TD4414 and 4416 Fixed bug in  getCurveStdrate
**     30.09.2005 Darren   Rollback previous changes
**     05.04.2006 johanein T#3670.  PrefCurveParamRec expanded in order to cater for new curve input parameters
**     29.08.2006 ottermag Tracker #1597: GCR -> CGR, GWR -> WGR. Rewrited getCondensateGasRatio, getWaterCutPct, getWaterGasRatio due
**                         to amended ratios and WC. Removed interpolateGasOilRatio (not used).
**	   03.12.2007 oonnnng  ECPD-6541: Add avg_flow_mass attribute to getCurveParamValue, getCondensateGasRatio, getWaterCutPct, getGasOilRatio and getWaterGasRatio functions.
**     06.03.2008 oonnnng  ECPD-7593: Add checking for division by zero for getWaterGasRatio, getCondensateGasRatio, getGasOilRatio, getWaterCutPct functions.
**     31.12.2008 sharawan ECPD-10416:Replaced all references to EcDp_Type.pb_comp_number%TYPE with NUMBER in functions
**                         getCondensateGasRatio, getGasOilRatio, getWaterOilRatio, getWaterCutPct, getWaterGasRatio.
**     19.01.2010 madondin ECDP-13571: Modified getCurveStdRate to enhance performance when using performance curve and approach_method is not NULL and STEPPED.
**     23-12-2010 leongwen ECDP-11637: Well Performance Curve should accept more than one curve.
**     08.07.2011 rajarsar ECPD-17700: Updated getPerformanceCurveId,getNextPerformanceCurveId and getCurveStdRate to add p_calc_method as passing parameter and updated getGasOilRatio, getWaterOilRatio, getWaterCutPct.
**     18-08-2011 aliasnur ECDP-18266: Modified getGasOilRatio and getWaterCutPct to check for ZERO values.
**     17-11-2011 leongwen ECPD-18170: Updated getCondensateGasRatio, getCondensateGasRatio, getGasOilRatio, getWaterCutPct, getWaterGasRatio
**                                     with new parameters of p_phase and p_calc_method.
**     21-12-2011 madondin ECPD-19446: Modified getCurveStdRate to handle liquid phase
**     19-01-2012 rajarsar ECPD-19447: Updated getCondensateGasRatio,getWaterOilRatio,getGasOilRatio,getWaterOilRatio,getWaterCutPct,getWaterGasRatio
**	   29-08-2012 musaamah ECPD-20773: Modified getCurveParamValue by changing the ELSIF condition from EcDp_Curve_Parameter.BH_PRESS to EcDp_Curve_Parameter.DH_PRESS
**	   08-10-2012 kumarsur ECPD-22074: Added populateCurveParameterValues
**     28-06-2013 musthram ECPD-24533: Modified function populateCurveParameterValues, getWaterCutPct, getGasOilRatio
**     04-09-2013 abdulmaw ECPD-25307: Modified function populateCurveParameterValues by adding EcDp_ProductionDay.getProductionDay
** 	   22.11.2013 kumarsur ECPD-26104: Modified populateCurveParameterValues added phase_current,ac_frequency and intake_press.
** 	   02.12.2013 makkkkam ECPD-25991: Modified PerfCurveParamRec added mpm_oil_rate,mpm_gas_rate,mpm_water_rate and mpm_cond_rate.
**     24-01-2014 leongwen ECPD-26709: Modified the functions of getCondensateGasRatio, getGasOilRatio, getWaterOilRatio, getWaterCutPct and getWaterGasRatio to return value when the rate is NOT zero or NULL,
**                                     and return zero when the rate is zero, and return NULL when the rate is NULL.
*****************************************************************/

-----------------------------------------------------------------
-- Function:    getCondensateGasRatio  (Well)
-- Description: Returns condensate gas ratio for a given well on
--              a given day based on the last performance curve
--
-----------------------------------------------------------------
FUNCTION getCondensateGasRatio(
	p_object_id well.object_id%TYPE,
	p_daytime  DATE,
  p_phase VARCHAR2,
  p_calc_method VARCHAR2,
  p_class_name VARCHAR2  DEFAULT NULL)

RETURN NUMBER IS

  ln_ret_val NUMBER;
  ln_condrate NUMBER;
  ln_gasrate NUMBER;
  lr_pwel_day_status_rec pwel_day_status%ROWTYPE;
  lr_params EcDp_Well_Theoretical.PerfCurveParamRec;

BEGIN

	populateCurveParameterValues(p_object_id,p_daytime,p_class_name,lr_params);

  ln_gasrate := Ecdp_Well_Theoretical.getCurveStdRate(p_object_id,p_daytime,EcDp_Curve_Purpose.PRODUCTION,ecdp_phase.GAS,lr_params,p_calc_method);

  IF ln_gasrate > 0 THEN
	  ln_condrate := Ecdp_Well_Theoretical.getCurveStdRate(p_object_id,p_daytime,EcDp_Curve_Purpose.PRODUCTION,ecdp_phase.CONDENSATE,lr_params,p_calc_method);
    ln_ret_val := ln_condrate/ln_gasrate;
  ELSIF ln_gasrate = 0 THEN
    ln_ret_val := 0;
  ELSIF ln_gasrate IS NULL THEN
    ln_ret_val := NULL;
  END IF;

  RETURN ln_ret_val;

END getCondensateGasRatio;

-----------------------------------------------------------------
--  Function:    getGasOilRatio
--  Description: Find proper GOR to be used for an actual day
-----------------------------------------------------------------
FUNCTION getGasOilRatio(
	p_object_id well.object_id%TYPE,
  p_daytime  DATE,
  p_phase VARCHAR2,
  p_calc_method VARCHAR2,
  p_class_name VARCHAR2  DEFAULT NULL,
  p_result_no NUMBER DEFAULT NULL)

RETURN NUMBER IS

  ln_oilrate NUMBER;
  ln_gasrate NUMBER;
  ln_gor NUMBER;
  lr_pwel_day_status_rec pwel_day_status%ROWTYPE;
  lr_params EcDp_Well_Theoretical.PerfCurveParamRec;

BEGIN
   populateCurveParameterValues(p_object_id,p_daytime,p_class_name,lr_params,p_result_no);

   ln_oilrate := Ecdp_Well_Theoretical.getCurveStdRate(p_object_id,p_daytime,EcDp_Curve_Purpose.PRODUCTION, p_phase,lr_params,p_calc_method);

   IF ln_oilrate > 0 THEN
     ln_gasrate := Ecdp_Well_Theoretical.getCurveStdRate(p_object_id,p_daytime,EcDp_Curve_Purpose.PRODUCTION,ecdp_phase.GAS,lr_params,p_calc_method);
     ln_gor := ln_gasrate/ln_oilrate;
   ELSIF ln_oilrate = 0 THEN
     ln_gor := 0;
   ELSIF ln_oilrate IS NULL THEN
     ln_gor := NULL;
   END IF;

   RETURN ln_gor;
END getGasOilRatio;
-----------------------------------------------------------------
--  Function:    getWaterOilRatio
--  Description: Find proper WOR to be used for an actual day
-----------------------------------------------------------------
FUNCTION getWaterOilRatio(
	p_object_id well.object_id%TYPE,
  p_daytime  DATE,
  p_phase VARCHAR2,
  p_calc_method VARCHAR2,
  p_class_name VARCHAR2 DEFAULT NULL)

RETURN NUMBER IS

	ln_wor NUMBER;
  ln_oilrate NUMBER;
  ln_waterrate NUMBER;
  lr_pwel_day_status_rec pwel_day_status%ROWTYPE;
  lr_params EcDp_Well_Theoretical.PerfCurveParamRec;

BEGIN
  populateCurveParameterValues(p_object_id,p_daytime,p_class_name,lr_params);

  ln_oilrate := Ecdp_Well_Theoretical.getCurveStdRate(p_object_id,p_daytime,EcDp_Curve_Purpose.PRODUCTION,ecdp_phase.OIL,lr_params,p_calc_method);

  IF ln_oilrate > 0 THEN
    ln_waterrate := Ecdp_Well_Theoretical.getCurveStdRate(p_object_id,p_daytime,EcDp_Curve_Purpose.PRODUCTION,ecdp_phase.WATER,lr_params,p_calc_method);
    ln_wor := ln_waterrate/ln_oilrate;
  ELSIF ln_oilrate = 0 THEN
    ln_wor := 0;
  ELSIF ln_oilrate IS NULL THEN
    ln_wor := NULL;
  END IF;

  RETURN ln_wor;

END getWaterOilRatio;

-----------------------------------------------------------------
--  Function:    getLowPressureGasOilRatio
--  Description: Find proper Low pressure GOR to be used for an actual day
-----------------------------------------------------------------
FUNCTION getLowPressureGasOilRatio(
	p_object_id well.object_id%TYPE,
  p_daytime  DATE)

RETURN NUMBER IS

BEGIN
    RAISE_APPLICATION_ERROR(-20000,'Low pressure GOR from performance curve data is not supported.');

END getLowPressureGasOilRatio;



--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getWaterCutPct                                                               --
-- Description    : Returns water cut in percentage unit                                         --
--                                                                                               --
-- Preconditions  :                                                                              --
-- Postconditions :                                                                              --
--                                                                                               --
-- Using tables   :                                                                              --
--                                                                                               --
-- Using functions:                                                                              --
--                  ECDP_WELL.GETATTRIBUTETEXT                                                   --
--                  ECDP_WELL_ATTRIBUTE.WATERCUT_METHOD                                          --
--                  ECDP_CALC_METHOD.PREVIOUS_WT                                                 --
--                  ECDP_WELL_TEST.GETLASTWATSTDRATE                                             --
--                  ECDP_WELL_TEST.GETLASTOILSTDRATE                                             --
--                  ECDP_WELL_THEORETICAL.GETPERFORMANCECURVEID                                  --
--                  EC_PERFORMANCE_CURVE.WATERCUT_PCT                                            --
--                                                                                               --
-- Configuration                                                                                 --
-- required       :                                                                              --
--                                                                                               --
-- Behaviour      :                                                                              --
--                  WATERCUT_METHOD = 'PREVIOUS_WT' Calculate the value from the last valid      --
--                                                  well test rates                              --
--                  Otherwise get the watercut from the performance curve.                       --
---------------------------------------------------------------------------------------------------
FUNCTION getWaterCutPct(
	p_object_id well.object_id%TYPE,
  p_daytime	 DATE,
  p_phase VARCHAR2,
  p_calc_method VARCHAR2,
  p_class_name VARCHAR2 DEFAULT NULL,
  p_result_no NUMBER DEFAULT NULL)

RETURN NUMBER
--</EC-DOC>
IS
  ln_watercut NUMBER;
  ln_liqrate NUMBER;
  ln_waterrate NUMBER;
  lr_pwel_day_status_rec pwel_day_status%ROWTYPE;
  lr_params EcDp_Well_Theoretical.PerfCurveParamRec;

BEGIN
    populateCurveParameterValues(p_object_id,p_daytime,p_class_name,lr_params,p_result_no);

    ln_liqrate := Ecdp_Well_Theoretical.getCurveStdRate(p_object_id,p_daytime,EcDp_Curve_Purpose.PRODUCTION,p_phase,lr_params,p_calc_method);
    ln_waterrate := Ecdp_Well_Theoretical.getCurveStdRate(p_object_id,p_daytime,EcDp_Curve_Purpose.PRODUCTION,ecdp_phase.WATER,lr_params,p_calc_method);

    IF (ln_liqrate + ln_waterrate) > 0 THEN
      ln_watercut := ln_waterrate/(ln_liqrate + ln_waterrate) * 100;
    ELSIF (ln_liqrate = 0 AND ln_waterrate = 0) THEN
      ln_watercut := 0;
    ELSIF (ln_liqrate IS NULL OR ln_waterrate IS NULL) THEN
      ln_watercut := NULL;
    END IF;

    RETURN ln_watercut;

END getWaterCutPct;
-----------------------------------------------------------------
-- Function:    getWaterGasRatio
-- Description: Returns water gas ratio:
--              condensated water from gas/Dry gas  [m3/Sm3]
-----------------------------------------------------------------
FUNCTION getWaterGasRatio(
	p_object_id well.object_id%TYPE,
  p_daytime	 DATE,
  p_phase VARCHAR2,
  p_calc_method VARCHAR2,
  p_class_name VARCHAR2 DEFAULT NULL)

RETURN NUMBER IS

ln_gasrate NUMBER;
ln_waterrate NUMBER;
ln_ret_val  		NUMBER;
lr_pwel_day_status_rec pwel_day_status%ROWTYPE;
lr_params EcDp_Well_Theoretical.PerfCurveParamRec;


BEGIN
   populateCurveParameterValues(p_object_id,p_daytime,p_class_name,lr_params);

   ln_gasrate := Ecdp_Well_Theoretical.getCurveStdRate(p_object_id,p_daytime,EcDp_Curve_Purpose.PRODUCTION,p_phase,lr_params,p_calc_method);
   ln_waterrate := Ecdp_Well_Theoretical.getCurveStdRate(p_object_id,p_daytime,EcDp_Curve_Purpose.PRODUCTION,ecdp_phase.WATER,lr_params,p_calc_method);

   IF ln_gasrate > 0 THEN
     ln_ret_val := ln_waterrate/ln_gasrate;
   ELSIF ln_gasrate = 0 THEN
     ln_ret_val := 0;
   ELSIF ln_gasrate IS NULL THEN
     ln_ret_val := NULL;
   END IF;

   RETURN ln_ret_val;

END getWaterGasRatio;

-----------------------------------------------------------------
--  Function:    getWellCurveParameterCode
--  Description: Find the curve_parameter_code used by the performance
--               curve for the well at the given time. The curve_parameter_code
--               holds information about what parameter is used to define
--               the x-axis in the performance curve.
-----------------------------------------------------------------
FUNCTION getWellCurveParameterCode(
	p_object_id well.object_id%TYPE,
  p_daytime    DATE,
  p_phase VARCHAR2 DEFAULT 'OIL') RETURN VARCHAR2

IS

ln_perf_curve_id  NUMBER;
ln_ret_val performance_curve.curve_parameter_code%TYPE ;

BEGIN

/*
Commented by leongwen. ecpd-11637
We can't find where this function is being utilized. Defaulted the p_phase value to be as "OIL"
since that was only phase supported when this function was created.
*/

  ln_perf_curve_id := EcDp_Well_Theoretical.getPerformanceCurveId(
   					    p_object_id,
        				p_daytime,
        				EcDp_Curve_Purpose.PRODUCTION,
                p_phase);

  	ln_ret_val := ec_performance_curve.curve_parameter_code(ln_perf_curve_id);

    RETURN ln_ret_val;

END getWellCurveParameterCode;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getPerformanceCurveId                                                        --
-- Description    : Finds the newest valid performance curve for the given well, daytime and     --
--                  purpose.                                                                     --
--                                                                                               --
-- Preconditions  :                                                                              --
-- Postconditions :                                                                              --
--                                                                                               --
-- Using tables   : WELL                                                                         --
--                                                                                               --
-- Using functions: EcDp_Performance_Curve.getWellPerformanceCurveId                             --
--                                                                                               --
-- Configuration                                                                                 --
-- required       :                                                                              --
--                                                                                               --
-- Behaviour      : Returns the performance curve with the given well and purpose that has       --
--                  the highest daytime <= the given daytime, or NULL if no such curve can       --
--                  be found.                                                                    --
--                                                                                               --
---------------------------------------------------------------------------------------------------
FUNCTION getPerformanceCurveId(
   p_object_id well.object_id%TYPE,
   p_daytime         DATE,
   p_curve_purpose   VARCHAR2,
   p_phase           VARCHAR2,
   p_calc_method VARCHAR2 DEFAULT NULL
)
RETURN NUMBER
--</EC-DOC>
IS
BEGIN
   RETURN EcDp_Performance_Curve.getWellPerformanceCurveId(
      p_object_id,
      p_daytime,
      p_curve_purpose,
      p_phase,
      p_calc_method
   );
END getPerformanceCurveId;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getNextPerformanceCurveId                                                    --
-- Description    : Finds the first "future" performance curve for the given well, daytime and   --
--                  purpose. (That is the first curve that is not yet valid).                    --
--                                                                                               --
-- Preconditions  :                                                                              --
-- Postconditions :                                                                              --
--                                                                                               --
-- Using tables   : WELL                                                                         --
--                                                                                               --
-- Using functions: EcDp_Performance_Curve.getNextWellPerformanceCurveId                         --
--                                                                                               --
-- Configuration                                                                                 --
-- required       :                                                                              --
--                                                                                               --
-- Behaviour      : Returns the performance curve with the given well and purpose that has       --
--                  the lowest daytime >= the given daytime, or NULL if no such curve can        --
--                  be found.                                                                    --
--                  Note the use of >=, which means that both this function and                  --
--                  getWellPerformanceCurveId will return the same curve if there is a           --
--                  curve that excatly matches the given daytime. This is by design to           --
--                  aid business functions in interpolating curves in time.                      --
--                                                                                               --
---------------------------------------------------------------------------------------------------
FUNCTION getNextPerformanceCurveId(
   p_object_id well.object_id%TYPE,
   p_daytime         DATE,
   p_curve_purpose   VARCHAR2,
   p_phase           VARCHAR2,
   p_calc_method VARCHAR2 DEFAULT NULL
)
RETURN NUMBER
--</EC-DOC>
IS
BEGIN
   RETURN EcDp_Performance_Curve.getNextWellPerformanceCurveId(
      p_object_id,
      p_daytime,
      p_curve_purpose,
      p_phase,
      p_calc_method
   );
END getNextPerformanceCurveId;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getCurveParamValue                                                           --
-- Description    : Picks the correct parameter value based on the parameter code                --
--                  (Example: If the parameter code is WH_PRESS then the wh_press                --
--                  field in the parameter values structure is returned.)                        --
--                                                                                               --
-- Preconditions  :                                                                              --
-- Postconditions :                                                                              --
--                                                                                               --
-- Using tables   :                                                                              --
--                                                                                               --
-- Using functions: EcDp_Curve_Parameter.*                                                       --
--                                                                                               --
-- Configuration                                                                                 --
-- required       :                                                                              --
--                                                                                               --
-- Behaviour      : Note that the params that identifies the well is not currently used since    --
--                  we don't support any parameters (ie CHOKE in mm) that need these, however    --
--                  this might change in future versions.                                        --
--                                                                                               --
---------------------------------------------------------------------------------------------------
FUNCTION getCurveParamValue(
   p_object_id      well.object_id%TYPE,
   p_daytime        DATE,
   p_param_code     VARCHAR2,
   p_param_values   PerfCurveParamRec
)
RETURN NUMBER
--</EC-DOC>
IS
   ln_param_value NUMBER;
BEGIN
   IF p_param_code=EcDp_Curve_Parameter.NONE THEN
      ln_param_value:=0;
   ELSIF p_param_code=EcDp_Curve_Parameter.CHOKE_NATURAL THEN
      ln_param_value:=p_param_values.choke_size;
   ELSIF p_param_code=EcDp_Curve_Parameter.WH_PRESS THEN
      ln_param_value:=p_param_values.wh_press;
   ELSIF p_param_code=EcDp_Curve_Parameter.WH_TEMP THEN
      ln_param_value:=p_param_values.wh_temp;
   ELSIF p_param_code=EcDp_Curve_Parameter.DH_PRESS THEN
      ln_param_value:=p_param_values.bh_press;
   ELSIF p_param_code=EcDp_Curve_Parameter.ANNULUS_PRESS THEN
      ln_param_value:=p_param_values.annulus_press;
   ELSIF p_param_code=EcDp_Curve_Parameter.DP_CHOKE THEN
      ln_param_value:=(p_param_values.wh_usc_press - p_param_values.wh_dsc_press);
   ELSIF p_param_code=EcDp_Curve_Parameter.DP_TUBING THEN
      ln_param_value:=(p_param_values.bh_press - p_param_values.wh_press);
   ELSIF p_param_code=EcDp_Curve_Parameter.WATERCUT_PCT THEN
      ln_param_value:=p_param_values.bs_w*100;
   ELSIF p_param_code=EcDp_Curve_Parameter.RPM THEN
      ln_param_value:=p_param_values.dh_pump_rpm;
   ELSIF p_param_code=EcDp_Curve_Parameter.GL_CHOKE THEN
      ln_param_value:=p_param_values.gl_choke;
   ELSIF p_param_code=EcDp_Curve_Parameter.GL_PRESS THEN
      ln_param_value:=p_param_values.gl_press;
   ELSIF p_param_code=EcDp_Curve_Parameter.GL_RATE THEN
      ln_param_value:=p_param_values.gl_rate;
   ELSIF p_param_code=EcDp_Curve_Parameter.GL_DIFF_PRESS THEN
      ln_param_value:=p_param_values.gl_diff_press;
   ELSIF p_param_code=EcDp_Curve_Parameter.AVG_FLOW_MASS THEN
	  ln_param_value:=p_param_values.avg_flow_mass;
   ELSIF p_param_code=EcDp_Curve_Parameter.PHASE_CURRENT OR p_param_code=EcDp_Curve_Parameter.DRIVE_CURRENT THEN
	  ln_param_value:=p_param_values.phase_current;
   ELSIF p_param_code=EcDp_Curve_Parameter.AC_FREQUENCY OR p_param_code=EcDp_Curve_Parameter.DRIVE_FREQUENCY THEN
	  ln_param_value:=p_param_values.ac_frequency;
   ELSIF p_param_code=EcDp_Curve_Parameter.INTAKE_PRESS THEN
	  ln_param_value:=p_param_values.intake_press;
   ELSIF p_param_code=EcDp_Curve_Parameter.MPM_OIL_RATE THEN
	  ln_param_value:=p_param_values.mpm_oil_rate;
   ELSIF p_param_code=EcDp_Curve_Parameter.MPM_GAS_RATE THEN
	  ln_param_value:=p_param_values.mpm_gas_rate;
   ELSIF p_param_code=EcDp_Curve_Parameter.MPM_WATER_RATE THEN
	  ln_param_value:=p_param_values.mpm_water_rate;
   ELSIF p_param_code=EcDp_Curve_Parameter.MPM_COND_RATE THEN
	  ln_param_value:=p_param_values.mpm_cond_rate;

   ELSE
      ln_param_value:=NULL;
   END IF;
   RETURN ln_param_value;
END getCurveParamValue;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getCurveStdRate                                                              --
-- Description    : Gets the theoretical rate for a well using performance curves.               --
--                  If the well attribute APPROACH_METHOD is 'INTERMEDIATE' then the value will  --
--                  be interpolated in time using the latest valid and first "future" curves.    --
--                                                                                               --
-- Preconditions  :                                                                              --
-- Postconditions :                                                                              --
--                                                                                               --
-- Using tables   : PERFORMANCE_CURVE                                                            --
--                                                                                               --
-- Using functions: getPerformanceCurveId                                                        --
--                  getNextPerformanceCurveId                                                    --
--                  getCurveParamValue                                                           --
--                  EcDp_Well.getAttributeText                                                   --
--                  EcDp_Performance_Curve.getStdRateFromParamValue                              --
-- Configuration                                                                                 --
-- required       :                                                                              --
--                                                                                               --
-- Behaviour      : Calculates the rate with the following steps:                                --
--                    1. Locates the newest valid performance curve                              --
--                    2. Finds the parameter values to use based on the curve's setup            --
--                       and the input values                                                    --
--                    3. Calculates the rate from the curve                                      --
--                    4. If the well attribute APPROACH_METHOD is 'INTERMEDIATE' then            --
--                       a) Repeats step 1-3 but for the first "future" curve                    --
--                       b) Interpolates the two rates in time.                                  --
--                       If no second curve can be found, or if it is not possible to            --
--                       interpolate due to NULL values or results, then the rate from step 3    --
--                       is used directly.                                                       --
--                       If there is an exact match on daytime then that curve will be used      --
--                       without any interpolation.                                              --
--                                                                                               --
---------------------------------------------------------------------------------------------------
FUNCTION getCurveStdRate(
   p_object_id well.object_id%TYPE,
   p_daytime        DATE,
   p_curve_purpose  VARCHAR2,
   p_phase          VARCHAR2,
   p_param_values   PerfCurveParamRec,
   p_calc_method VARCHAR2 DEFAULT NULL
) RETURN NUMBER
--</EC-DOC>
IS
   ln_cur_perf_curve_id performance_curve.perf_curve_id%TYPE;
   ln_next_perf_curve_id performance_curve.perf_curve_id%TYPE;
   ln_reset_trend_flag_left NUMBER;
   ln_reset_trend_flag_right NUMBER;
   ln_x1 NUMBER;
   ln_z1 NUMBER;
   ln_y1 NUMBER;
   ln_time1 NUMBER;
   ld_daytime_1 DATE;
   ln_x2 NUMBER;
   ln_z2 NUMBER;
   ln_y2 NUMBER;
   ln_time2 NUMBER;
   ld_daytime_2 DATE;
   lv2_approach_method VARCHAR2(32);
   ln_c2 NUMBER;
   ln_temp NUMBER;

   -- cursor to check if there's any reset trend avalaible at any daytime > ln_daytime_1 and < p_daytime
   CURSOR c_check_reset_trend_left (cp_object_id VARCHAR2, cp_daytime DATE, cp_daytime_1 DATE) IS
   select pt.result_no from pwel_result pw, ptst_result pt where
          pw.result_no = pt.result_no and
          pw.object_id = cp_object_id and
          pt.valid_from_date > cp_daytime_1 and
          pt.valid_from_date < cp_daytime and
          pw.trend_reset_ind = 'Y';

   -- cursor to check if there's any reset trend avalaible at any daytime <= ln_daytime_2 and > p_datime
   CURSOR c_check_reset_trend_right (cp_object_id VARCHAR2, cp_daytime DATE, cp_daytime_2 DATE) IS
   select pt.result_no from pwel_result pw, ptst_result pt where
          pw.result_no = pt.result_no and
          pw.object_id = cp_object_id and
          pt.valid_from_date > p_daytime and
          pt.valid_from_date <= cp_daytime_2 and
          pw.trend_reset_ind = 'Y';

BEGIN
   -- Find the latest valid curve and the resulting rate (y1)
   ln_cur_perf_curve_id:=getPerformanceCurveId(p_object_id,
                                               p_daytime,
                                               p_curve_purpose,
                                               p_phase,
                                               p_calc_method);

   -- Not able to find a valid curve, function return null
   IF ln_cur_perf_curve_id IS NULL THEN
      RETURN NULL;
   END IF;

   -- Find the next valid curve and the resulting rate (y2)
   ln_next_perf_curve_id:=getNextPerformanceCurveId(p_object_id,
                                                    p_daytime,
                                                    p_curve_purpose,
                                                    p_phase,
                                                    p_calc_method);

   -- Find y1
   ln_x1:=getCurveParamValue(
   		  		    p_object_id,
                p_daytime,
                ec_performance_curve.curve_parameter_code(ln_cur_perf_curve_id),
                p_param_values);
   ln_z1:=getCurveParamValue(
   					    p_object_id,
                p_daytime,
                ec_performance_curve.plane_intersect_code(ln_cur_perf_curve_id),
                p_param_values);
   ln_y1:=EcDp_Performance_Curve.getStdRateFromParamValue(ln_cur_perf_curve_id,p_phase,ln_x1,ln_z1);

   -- Not able to find any rate from curve, function return null
   IF ln_y1 IS NULL THEN
      RETURN NULL;
   END IF;

   --
   -- Check which approach method we should use
   --
   lv2_approach_method := ec_well_version.approach_method(
                                                  p_object_id,
                                                  p_daytime,
                                                  '<=');
   --
   -- Just for lv2_approach_method <> null and lv2_approach_method <> STEPPED
   IF (lv2_approach_method IS NOT NULL) AND (lv2_approach_method <> Ecdp_Calc_Method.STEPPED) THEN
   -- Find y2
      ln_x2:=getCurveParamValue(
               p_object_id,
               p_daytime,
               ec_performance_curve.curve_parameter_code(ln_next_perf_curve_id),
               p_param_values);
      ln_z2:=getCurveParamValue(
               p_object_id,
               p_daytime,
               ec_performance_curve.plane_intersect_code(ln_next_perf_curve_id),
               p_param_values);
      ln_y2:=EcDp_Performance_Curve.getStdRateFromParamValue(ln_next_perf_curve_id,p_phase,ln_x2,ln_z2);



   --
   -- Convert performance curve daytime to julian date
   --
      ln_time1:=to_char(ec_performance_curve.daytime(ln_cur_perf_curve_id),'J');
      ln_time2:=to_char(ec_performance_curve.daytime(ln_next_perf_curve_id),'J');

   -- Check reset trend exist in either side of production day
      ld_daytime_1 := ec_performance_curve.daytime(ln_cur_perf_curve_id);
      ld_daytime_2 := ec_performance_curve.daytime(ln_next_perf_curve_id);

      FOR my_cur IN c_check_reset_trend_left (p_object_id, p_daytime, ld_daytime_1) LOOP
	     ln_reset_trend_flag_left := my_cur.result_no;
      END LOOP;

      FOR my_cur2 IN c_check_reset_trend_right (p_object_id, p_daytime, ld_daytime_2) LOOP
	     ln_reset_trend_flag_right := my_cur2.result_no;
      END LOOP;

   END IF;

   -- Extrapolate
   --
   IF lv2_approach_method = Ecdp_Calc_Method.EXTRAPOLATE THEN

      -- if theres no performance reference point 1 and there's no reset trend at
      -- any date > daytime_1 and <= production day, then return null
	    IF (ln_y1 IS NULL) OR (ln_reset_trend_flag_left IS NOT NULL) THEN

         RETURN NULL;

      ELSE
         -- if there is no performance reference point 2 and there is not reset trend flag set at
         -- any production day < date < daytime_2 then extrapolate
         IF (ln_y2 IS NULL) OR ((ln_y2 IS NOT NULL) AND (ln_reset_trend_flag_right IS NOT NULL)) THEN

            -- Find C2
            IF p_phase = 'OIL' THEN
               ln_c2 := EcDp_Performance_Test.findOilConstantC2(p_object_id, p_daytime);
            ELSIF p_phase = 'GAS' THEN
               ln_c2 := EcDp_Performance_Test.findGasConstantC2(p_object_id, p_daytime);
            ELSIF p_phase = 'WAT' THEN
               ln_c2 := EcDp_Performance_Test.findWatConstantC2(p_object_id, p_daytime);
            ELSIF p_phase = 'COND' THEN
               ln_c2 := EcDp_Performance_Test.findCondConstantC2(p_object_id, p_daytime);
            ELSIF p_phase = 'LIQ' THEN
               ln_c2 := EcDp_Performance_Test.findLiqConstantC2(p_object_id, p_daytime);
            ELSE
               RETURN NULL;
            END IF;

            --Extrapolation
            ln_temp := (to_char(p_daytime, 'J') - ln_time1)/30;
            RETURN ln_y1 * power((1 + ln_c2 / 100), ln_temp);
         -- Return stepped if there is future valid curve
         ELSIF (ln_y2 IS NOT NULL) OR (ln_reset_trend_flag_right IS NULL) THEN
            RETURN ln_y1;
         ELSE
            RETURN NULL;
         END IF;
      END IF;

   --
   -- Interpolate if not able then use extrapolate
   --
    ELSIF lv2_approach_method = EcDp_Calc_Method.INTERPOLATE_EXTRAPOLATE THEN

      IF (ln_y1 IS NULL) OR (ln_reset_trend_flag_left IS NOT NULL) THEN
         -- No valid curve found or there is a reset trend flag set for well
         -- at any date > daytime and < production_day!
         RETURN NULL;
      ELSE

         -- if there's no performance reference point 2 and there's a reset trend at a date where date > production day and <= daytime_2
         IF (ln_y2 IS NULL) OR (ln_reset_trend_flag_right IS NOT NULL) THEN

            -- Find C2
            -- Extrapolate curve
            IF p_phase = 'OIL' THEN
               ln_c2 := EcDp_Performance_Test.findOilConstantC2(p_object_id, p_daytime);
            ELSIF p_phase = 'GAS' THEN
               ln_c2 := EcDp_Performance_Test.findGasConstantC2(p_object_id, p_daytime);
            ELSIF p_phase = 'WAT' THEN
               ln_c2 := EcDp_Performance_Test.findWatConstantC2(p_object_id, p_daytime);
            ELSIF p_phase = 'COND' THEN
               ln_c2 := EcDp_Performance_Test.findCondConstantC2(p_object_id, p_daytime);
            ELSIF p_phase = 'LIQ' THEN
               ln_c2 := EcDp_Performance_Test.findLiqConstantC2(p_object_id, p_daytime);
            ELSE
               RETURN NULL;
            END IF;

            ln_temp := (to_char(p_daytime, 'J') - ln_time1)/30;
            RETURN ln_y1 * power((1 + ln_c2 / 100), ln_temp);
         -- All condition is fulfill and ready to be interpolated
         ELSE
            IF (ln_time1 IS NULL) OR (ln_time2 IS NULL) THEN
               -- Cannot interpolate, return NULL. Should never happen!
               RETURN NULL;
            ELSIF ln_time1=ln_time2 THEN

               -- Exact hit on a daytime, no need for interpolation!
               RETURN ln_y1;
            ELSE

               -- Linear interpolation
               RETURN ln_y1+(to_char(p_daytime,'J')-ln_time1)*(ln_y2-ln_y1)/(ln_time2-ln_time1);
            END IF;
         END IF;
      END IF;

   ELSE
       -- APPROACH_METHOD = STEPPED OR NULL
       RETURN ln_y1;
   END IF;
END getCurveStdRate;

PROCEDURE populateCurveParameterValues (
 p_object_id VARCHAR2,
 p_daytime DATE,
 p_class_name VARCHAR2,
 p_param_values  OUT PerfCurveParamRec,
 p_result_no NUMBER DEFAULT NULL
)
IS
   lr_params EcDp_Well_Theoretical.PerfCurveParamRec;
   lr_pwel_day_status_rec pwel_day_status%ROWTYPE;
   lr_pwel_sub_day_status_rec pwel_sub_day_status%ROWTYPE;
   lr_pwel_result_rec pwel_result%ROWTYPE;
   ld_prod_daytime      DATE;

BEGIN

   IF p_class_name = 'PWEL_DAY_STATUS' THEN
     ld_prod_daytime := EcDp_ProductionDay.getProductionDay('WELL', p_object_id, p_daytime);
	 lr_pwel_day_status_rec := ec_pwel_day_status.row_by_pk(p_object_id,ld_prod_daytime);

     lr_params.choke_size        := lr_pwel_day_status_rec.avg_choke_size;
     lr_params.wh_press          := lr_pwel_day_status_rec.avg_wh_press;
     lr_params.wh_temp           := lr_pwel_day_status_rec.avg_wh_temp;
     lr_params.bh_press          := lr_pwel_day_status_rec.avg_bh_press;
     lr_params.annulus_press     := lr_pwel_day_status_rec.avg_annulus_press;
     lr_params.wh_usc_press      := lr_pwel_day_status_rec.avg_wh_usc_press;
     lr_params.wh_dsc_press      := lr_pwel_day_status_rec.avg_wh_dsc_press;
     lr_params.bs_w              := NULL;
     lr_params.dh_pump_rpm       := lr_pwel_day_status_rec.avg_dh_pump_speed;
     lr_params.gl_choke          := lr_pwel_day_status_rec.avg_gl_choke;
     lr_params.gl_press          := lr_pwel_day_status_rec.avg_gl_press;
     lr_params.gl_rate           := lr_pwel_day_status_rec.avg_gl_rate;
     lr_params.gl_diff_press     := lr_pwel_day_status_rec.avg_gl_diff_press;
     lr_params.avg_flow_mass     := lr_pwel_day_status_rec.avg_flow_mass;
	 lr_params.phase_current     := lr_pwel_day_status_rec.phase_current;
	 lr_params.ac_frequency      := lr_pwel_day_status_rec.ac_frequency;
	 lr_params.intake_press      := lr_pwel_day_status_rec.intake_press;
   	 lr_params.mpm_oil_rate      := lr_pwel_day_status_rec.avg_mpm_oil_rate;
     lr_params.mpm_gas_rate      := lr_pwel_day_status_rec.avg_mpm_gas_rate;
     lr_params.mpm_water_rate    := lr_pwel_day_status_rec.avg_mpm_water_rate;
     lr_params.mpm_cond_rate     := lr_pwel_day_status_rec.avg_mpm_cond_rate;

   ELSIF p_class_name = 'PWEL_SUB_DAY_STATUS' THEN
     ld_prod_daytime := EcDp_ProductionDay.getProductionDay('WELL', p_object_id, p_daytime);
	 lr_pwel_sub_day_status_rec := ec_pwel_sub_day_status.row_by_pk(p_object_id,ld_prod_daytime);

     lr_params.choke_size        := lr_pwel_sub_day_status_rec.avg_choke_size;
     lr_params.wh_press          := lr_pwel_sub_day_status_rec.avg_wh_press;
     lr_params.wh_temp           := lr_pwel_sub_day_status_rec.avg_wh_temp;
     lr_params.bh_press          := lr_pwel_sub_day_status_rec.avg_bh_press;
     lr_params.annulus_press     := lr_pwel_sub_day_status_rec.avg_annulus_press;
     lr_params.wh_usc_press      := lr_pwel_sub_day_status_rec.avg_wh_usc_press;
     lr_params.wh_dsc_press      := lr_pwel_sub_day_status_rec.avg_wh_dsc_press;
     lr_params.bs_w              := NULL;
     lr_params.dh_pump_rpm       := lr_pwel_sub_day_status_rec.avg_dh_pump_speed;
     lr_params.gl_choke          := NULL;
     lr_params.gl_press          := lr_pwel_sub_day_status_rec.avg_gl_press;
     lr_params.gl_rate           := lr_pwel_sub_day_status_rec.avg_gl_rate;
     lr_params.gl_diff_press     := lr_pwel_sub_day_status_rec.avg_gl_diff_press;
     lr_params.avg_flow_mass     := NULL;
	 lr_params.phase_current     := lr_pwel_sub_day_status_rec.phase_current;
	 lr_params.ac_frequency      := lr_pwel_sub_day_status_rec.ac_frequency;
	 lr_params.intake_press      := lr_pwel_sub_day_status_rec.intake_press;
     lr_params.mpm_oil_rate      := lr_pwel_sub_day_status_rec.avg_mpm_oil_rate;
     lr_params.mpm_gas_rate      := lr_pwel_sub_day_status_rec.avg_mpm_gas_rate;
     lr_params.mpm_water_rate    := lr_pwel_sub_day_status_rec.avg_mpm_water_rate;
     lr_params.mpm_cond_rate     := lr_pwel_sub_day_status_rec.avg_mpm_cond_rate;

   ELSIF p_class_name = 'PWEL_RESULT' THEN
     lr_pwel_result_rec := ec_pwel_result.row_by_pk(p_object_id,p_result_no);

     lr_params.choke_size        := lr_pwel_result_rec.choke_size;
     lr_params.wh_press          := lr_pwel_result_rec.wh_press;
     lr_params.wh_temp           := lr_pwel_result_rec.wh_temp;
     lr_params.bh_press          := lr_pwel_result_rec.bh_press;
     lr_params.annulus_press     := lr_pwel_result_rec.annulus_press;
     lr_params.wh_usc_press      := lr_pwel_result_rec.wh_usc_press;
     lr_params.wh_dsc_press      := lr_pwel_result_rec.wh_dsc_press;
     lr_params.bs_w              := NULL;
     lr_params.dh_pump_rpm       := lr_pwel_result_rec.pump_speed;
     lr_params.gl_choke          := lr_pwel_result_rec.gl_choke_size;
     lr_params.gl_press          := lr_pwel_result_rec.gl_press;
     lr_params.gl_rate           := lr_pwel_result_rec.gl_rate;
     lr_params.gl_diff_press     := lr_pwel_result_rec.gl_diff_press;
     lr_params.avg_flow_mass     := lr_pwel_result_rec.avg_flow_mass;
	 lr_params.phase_current     := lr_pwel_result_rec.drive_current;
	 lr_params.ac_frequency      := lr_pwel_result_rec.drive_frequency;
	 lr_params.intake_press      := lr_pwel_result_rec.intake_press;
     lr_params.mpm_oil_rate      := lr_pwel_result_rec.mpm_oil_rate;
     lr_params.mpm_gas_rate      := lr_pwel_result_rec.mpm_gas_rate;
     lr_params.mpm_water_rate    := lr_pwel_result_rec.mpm_water_rate;
     lr_params.mpm_cond_rate     := lr_pwel_result_rec.mpm_cond_rate;

   ELSE
     ld_prod_daytime := EcDp_ProductionDay.getProductionDay('WELL', p_object_id, p_daytime);
	 lr_pwel_day_status_rec := ec_pwel_day_status.row_by_pk(p_object_id,ld_prod_daytime);

     lr_params.choke_size        := lr_pwel_day_status_rec.avg_choke_size;
     lr_params.wh_press          := lr_pwel_day_status_rec.avg_wh_press;
     lr_params.wh_temp           := lr_pwel_day_status_rec.avg_wh_temp;
     lr_params.bh_press          := lr_pwel_day_status_rec.avg_bh_press;
     lr_params.annulus_press     := lr_pwel_day_status_rec.avg_annulus_press;
     lr_params.wh_usc_press      := lr_pwel_day_status_rec.avg_wh_usc_press;
     lr_params.wh_dsc_press      := lr_pwel_day_status_rec.avg_wh_dsc_press;
     lr_params.bs_w              := NULL;
     lr_params.dh_pump_rpm       := lr_pwel_day_status_rec.avg_dh_pump_speed;
     lr_params.gl_choke          := lr_pwel_day_status_rec.avg_gl_choke;
     lr_params.gl_press          := lr_pwel_day_status_rec.avg_gl_press;
     lr_params.gl_rate           := lr_pwel_day_status_rec.avg_gl_rate;
     lr_params.gl_diff_press     := lr_pwel_day_status_rec.avg_gl_diff_press;
     lr_params.avg_flow_mass     := lr_pwel_day_status_rec.avg_flow_mass;
	 lr_params.phase_current     := lr_pwel_day_status_rec.phase_current;
	 lr_params.ac_frequency      := lr_pwel_day_status_rec.ac_frequency;
	 lr_params.intake_press      := lr_pwel_day_status_rec.intake_press;
	 lr_params.mpm_oil_rate      := lr_pwel_day_status_rec.avg_mpm_oil_rate;
     lr_params.mpm_gas_rate      := lr_pwel_day_status_rec.avg_mpm_gas_rate;
     lr_params.mpm_water_rate    := lr_pwel_day_status_rec.avg_mpm_water_rate;
     lr_params.mpm_cond_rate     := lr_pwel_day_status_rec.avg_mpm_cond_rate;

 END IF;
     p_param_values :=  lr_params;
END populateCurveParameterValues;

END EcDp_Well_Theoretical;