CREATE OR REPLACE PACKAGE BODY EcDp_Flowline_Theoretical IS
/****************************************************************
** Package        :  EcDp_Flowline_Theoretical, body part
**
** $Revision: 1.8 $
**
** Purpose        :  Calculates theoretical flowline values (rates etc)
**
** Documentation  :  www.energy-components.com
**
** Created  :
**
** Modification history:
**
** Version  Date     Whom  Change description:
** -------  ------   ----- --------------------------------------
**          31.12.2008 sharawan ECPD-10416:Replaced all references to EcDp_Type.pb_comp_number%TYPE with NUMBER in functions
**                              getCondensateGasRatio, getGasOilRatio, getWaterCutPct, getWaterGasRatio.
**          28-01-2011 leongwen ECDP-16574: To correct and enhance the screens which are affected by the changes made in ECPD-16525.
**          14-04-2014 leongwen ECPD-22866: Applied the calculation methods for multiple phases Flowline Performance Curve based on the similar logic from Well Performance Curve.
**          24-03-2015 dhavaalo ECPD-30292: Modified EcDp_Well_Theoretical.populateCurveParameterValues function to calculate Theoretical Water and Gas values correctly for day offset for Daily and sub-daily screen.
**											Code Formatting done
*****************************************************************/

-----------------------------------------------------------------
-- Function:    getCondensateGasRatio  (Flowline)
-- Description: Returns condensate gas ratio for a given flowline on
--              a given day based on the last performance curve
--
-----------------------------------------------------------------
FUNCTION getCondensateGasRatio(
  p_object_id               flowline.object_id%TYPE,
  p_daytime                 DATE,
  p_phase                   VARCHAR2,
  p_calc_method             VARCHAR2,
  p_class_name              VARCHAR2  DEFAULT NULL)
RETURN NUMBER IS
    ln_ret_val NUMBER;
  ln_condrate NUMBER;
  ln_gasrate NUMBER;
    lr_pflw_day_status_rec pflw_day_status%ROWTYPE;
    lr_params EcDp_Flowline_Theoretical.PerfCurveParamRec;

BEGIN
  populateCurveParameterValues(p_object_id,p_daytime,p_class_name,lr_params);

  ln_gasrate := Ecdp_Flowline_Theoretical.getCurveStdRate(p_object_id,EcDp_ProductionDay.getProductionDay('FLOWLINE', p_object_id, p_daytime),EcDp_Curve_Purpose.PRODUCTION,ecdp_phase.GAS,lr_params,p_calc_method);

  IF ln_gasrate > 0 THEN
    ln_condrate := Ecdp_Flowline_Theoretical.getCurveStdRate(p_object_id,EcDp_ProductionDay.getProductionDay('FLOWLINE', p_object_id, p_daytime),EcDp_Curve_Purpose.PRODUCTION,ecdp_phase.CONDENSATE,lr_params,p_calc_method);
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
  p_object_id flowline.object_id%TYPE,
  p_daytime  DATE,
  p_phase VARCHAR2,
  p_calc_method VARCHAR2,
  p_class_name VARCHAR2 DEFAULT NULL,
  p_result_no NUMBER DEFAULT NULL)

RETURN NUMBER IS

  ln_oilrate NUMBER;
  ln_gasrate NUMBER;
  ln_gor NUMBER;
  lr_pflw_day_status_rec pflw_day_status%ROWTYPE;
  lr_params EcDp_Flowline_Theoretical.PerfCurveParamRec;

BEGIN
  populateCurveParameterValues(p_object_id,p_daytime,p_class_name,lr_params,p_result_no);

  ln_oilrate := Ecdp_Flowline_Theoretical.getCurveStdRate(p_object_id,EcDp_ProductionDay.getProductionDay('FLOWLINE', p_object_id, p_daytime),EcDp_Curve_Purpose.PRODUCTION, p_phase,lr_params,p_calc_method);

  IF ln_oilrate > 0 THEN
    ln_gasrate := Ecdp_Flowline_Theoretical.getCurveStdRate(p_object_id,EcDp_ProductionDay.getProductionDay('FLOWLINE', p_object_id, p_daytime),EcDp_Curve_Purpose.PRODUCTION,ecdp_phase.GAS,lr_params,p_calc_method);
    ln_gor := ln_gasrate/ln_oilrate;
  ELSIF ln_oilrate = 0 THEN
    ln_gor := 0;
  ELSIF ln_oilrate IS NULL THEN
    ln_gor := NULL;
  END IF;

  RETURN ln_gor;

END getGasOilRatio;

-----------------------------------------------------------------
--  Function:    getLowPressureGasOilRatio
--  Description: Find proper Low pressure GOR to be used for an actual day
-----------------------------------------------------------------
FUNCTION getLowPressureGasOilRatio(
  p_object_id  flowline.object_id%TYPE,
  p_daytime    DATE)

RETURN NUMBER IS

BEGIN
    RAISE_APPLICATION_ERROR(-20000,'Low pressure GOR from performance curve data is not supported.');

END getLowPressureGasOilRatio;



--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getWaterCutPct                                                               --
-- Description    : Returns water cut in percentage unit                                         --
--                                                                                               --
-- Configuration                                                                                 --
-- required       :                                                                              --
--                                                                                               --
-- Behaviour      :         needs updating                                                                     --
---------------------------------------------------------------------------------------------------
FUNCTION getWaterCutPct(
  p_object_id  flowline.object_id%TYPE,
  p_daytime    DATE,
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

  lr_pflw_day_status_rec pflw_day_status%ROWTYPE;
  lr_params EcDp_Flowline_Theoretical.PerfCurveParamRec;

BEGIN
  populateCurveParameterValues(p_object_id,p_daytime,p_class_name,lr_params,p_result_no);

  ln_liqrate := Ecdp_Flowline_Theoretical.getCurveStdRate(p_object_id,EcDp_ProductionDay.getProductionDay('FLOWLINE', p_object_id, p_daytime),EcDp_Curve_Purpose.PRODUCTION,p_phase,lr_params,p_calc_method);
  ln_waterrate := Ecdp_Flowline_Theoretical.getCurveStdRate(p_object_id,EcDp_ProductionDay.getProductionDay('FLOWLINE', p_object_id, p_daytime),EcDp_Curve_Purpose.PRODUCTION,ecdp_phase.WATER,lr_params,p_calc_method);

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
  p_object_id flowline.object_id%TYPE,
  p_daytime     DATE,
  p_phase VARCHAR2,
  p_calc_method VARCHAR2,
  p_class_name VARCHAR2 DEFAULT NULL)

RETURN NUMBER IS

ln_gasrate                NUMBER;
ln_waterrate              NUMBER;
ln_ret_val                NUMBER;
lr_pflw_day_status_rec    pflw_day_status%ROWTYPE;
lr_params                 EcDp_Flowline_Theoretical.PerfCurveParamRec;

BEGIN
  populateCurveParameterValues(p_object_id,p_daytime,p_class_name,lr_params);

   ln_gasrate := Ecdp_Flowline_Theoretical.getCurveStdRate(p_object_id,EcDp_ProductionDay.getProductionDay('FLOWLINE', p_object_id, p_daytime),EcDp_Curve_Purpose.PRODUCTION,p_phase,lr_params,p_calc_method);
   ln_waterrate := Ecdp_Flowline_Theoretical.getCurveStdRate(p_object_id,EcDp_ProductionDay.getProductionDay('FLOWLINE', p_object_id, p_daytime),EcDp_Curve_Purpose.PRODUCTION,ecdp_phase.WATER,lr_params,p_calc_method);

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
--  Function:    getFlowlineCurveParameterCode
--  Description: Find the curve_parameter_code used by the performance
--               curve for the flowline at the given time. The curve_parameter_code
--               holds information about what parameter is used to define
--               the x-axis in the performance curve.
-----------------------------------------------------------------
FUNCTION getFlowlineCurveParameterCode(
    p_object_id flowline.object_id%TYPE,
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

  ln_perf_curve_id := EcDp_Flowline_Theoretical.getPerformanceCurveId(
                                                         p_object_id,
                                                         p_daytime,
                                                         EcDp_Curve_Purpose.PRODUCTION,
                                                         p_phase);

  ln_ret_val := ec_performance_curve.curve_parameter_code(ln_perf_curve_id);

  RETURN ln_ret_val;

END getFlowlineCurveParameterCode;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getPerformanceCurveId                                                        --
-- Description    : Finds the newest valid performance curve for the given flowline, daytime and     --
--                  purpose.                                                                     --
--                                                                                               --
-- Preconditions  :                                                                              --
-- Postconditions :                                                                              --
--                                                                                               --
-- Using tables   : FLOWLINE                                                                         --
--                                                                                               --
-- Using functions: EcDp_Performance_Curve.getWellPerformanceCurveId                             --
--                                                                                               --
-- Configuration                                                                                 --
-- required       :                                                                              --
--                                                                                               --
-- Behaviour      : Returns the performance curve with the given flowline and purpose that has       --
--                  the highest daytime <= the given daytime, or NULL if no such curve can       --
--                  be found.                                                                    --
--                                                                                               --
---------------------------------------------------------------------------------------------------
FUNCTION getPerformanceCurveId(
   p_object_id flowline.object_id%TYPE,
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
-- Description    : Finds the first "future" performance curve for the given flowline, daytime and   --
--                  purpose. (That is the first curve that is not yet valid).                    --
--                                                                                               --
-- Preconditions  :                                                                              --
-- Postconditions :                                                                              --
--                                                                                               --
-- Using tables   : FLOWLINE                                                                         --
--                                                                                               --
-- Using functions: EcDp_Performance_Curve.getNextWellPerformanceCurveId                         --
--                                                                                               --
-- Configuration                                                                                 --
-- required       :                                                                              --
--                                                                                               --
-- Behaviour      :  to be determined
--                                                                                               --
---------------------------------------------------------------------------------------------------
FUNCTION getNextPerformanceCurveId(
   p_object_id flowline.object_id%TYPE,
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
-- Behaviour      : Note that the params that identifies the flowline is not currently used since    --
--                  we don't support any parameters (ie CHOKE in mm) that need these, however    --
--                  this might change in future versions.                                        --
--                                                                                               --
---------------------------------------------------------------------------------------------------
FUNCTION getCurveParamValue(
   p_object_id      flowline.object_id%TYPE,
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
   ELSIF p_param_code=EcDp_Curve_Parameter.DP_FLOWLINE THEN
      ln_param_value:=p_param_values.flwl_press;
   ELSIF p_param_code=EcDp_Curve_Parameter.DT_FLOWLINE THEN
      ln_param_value:=p_param_values.flwl_temp;
   ELSIF p_param_code=EcDp_Curve_Parameter.DP_CHOKE THEN
      ln_param_value:=(p_param_values.flwl_usc_press - p_param_values.flwl_dsc_press);
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
-- Description    :  To be determined    --
--                                                                                               --
-- Preconditions  :                                                                              --
-- Postconditions :                                                                              --
--                                                                                               --
-- Using tables   : PERFORMANCE_CURVE                                                            --
--                                                                                               --
-- Using functions: getPerformanceCurveId                                                        --
--                  getCurveParamValue                                                           --
--                  EcDp_Performance_Curve.getStdRateFromParamValue                              --
-- Configuration                                                                                 --
-- required       :                                                                              --
--                                                                                               --
-- Behaviour      : To be determined                             --
--                                                                                               --
---------------------------------------------------------------------------------------------------
FUNCTION getCurveStdRate(
   p_object_id      flowline.object_id%TYPE,
   p_daytime        DATE,
   p_curve_purpose  VARCHAR2,
   p_phase          VARCHAR2,
   p_param_values   PerfCurveParamRec,
   p_calc_method    VARCHAR2 DEFAULT NULL
) RETURN NUMBER
--</EC-DOC>
IS
   ln_cur_perf_curve_id performance_curve.perf_curve_id%TYPE;
   ln_next_perf_curve_id performance_curve.perf_curve_id%TYPE;
   ln_x1 NUMBER;
   ln_z1 NUMBER;
   ln_y1 NUMBER;
   lv2_approach_method VARCHAR2(32);

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
   lv2_approach_method := ec_flwl_version.flw_approach_mtd(p_object_id, p_daytime, '<=');

   IF lv2_approach_method = Ecdp_Calc_Method.STEPPED OR
      lv2_approach_method IS NULL THEN
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
   lr_params                    EcDp_Flowline_Theoretical.PerfCurveParamRec;
   lr_pflw_day_status_rec       pflw_day_status%ROWTYPE;
   lr_pflw_sub_day_status_rec   pflw_sub_day_status%ROWTYPE;
   lr_pflw_result_rec           pflw_result%ROWTYPE;
   ld_prod_daytime              DATE;

BEGIN

  IF p_class_name = 'PFLW_DAY_STATUS' THEN
    ld_prod_daytime := EcDp_ProductionDay.getProductionDay('FLOWLINE', p_object_id, p_daytime);
    lr_pflw_day_status_rec := ec_pflw_day_status.row_by_pk(p_object_id,ld_prod_daytime);

    lr_params.choke_size        := lr_pflw_day_status_rec.avg_choke_size;
    lr_params.flwl_press        := lr_pflw_day_status_rec.avg_flwl_press;
    lr_params.flwl_temp         := lr_pflw_day_status_rec.avg_flwl_temp;
    lr_params.flwl_usc_press    := lr_pflw_day_status_rec.avg_flwl_usc_press;
    lr_params.flwl_usc_temp     := lr_pflw_day_status_rec.avg_flwl_usc_temp;
    lr_params.flwl_dsc_press    := lr_pflw_day_status_rec.avg_flwl_dsc_press;
    lr_params.flwl_dsc_temp     := lr_pflw_day_status_rec.avg_flwl_dsc_temp;
    lr_params.mpm_oil_rate      := lr_pflw_day_status_rec.avg_mpm_oil_rate;
    lr_params.mpm_gas_rate      := lr_pflw_day_status_rec.avg_mpm_gas_rate;
    lr_params.mpm_water_rate    := lr_pflw_day_status_rec.avg_mpm_water_rate;
    lr_params.mpm_cond_rate     := lr_pflw_day_status_rec.avg_mpm_cond_rate;

  ELSIF p_class_name = 'PFLW_SUB_DAY_STATUS' THEN
    lr_pflw_sub_day_status_rec := ec_pflw_sub_day_status.row_by_pk(p_object_id,p_daytime);

    lr_params.choke_size        := lr_pflw_sub_day_status_rec.avg_choke_size;
    lr_params.flwl_press        := lr_pflw_sub_day_status_rec.avg_flwl_press;
    lr_params.flwl_temp         := lr_pflw_sub_day_status_rec.avg_flwl_temp;
    lr_params.flwl_usc_press    := lr_pflw_sub_day_status_rec.avg_flwl_usc_press;
    lr_params.flwl_usc_temp     := lr_pflw_sub_day_status_rec.avg_flwl_usc_temp;
    lr_params.flwl_dsc_press    := lr_pflw_sub_day_status_rec.avg_flwl_dsc_press;
    lr_params.flwl_dsc_temp     := lr_pflw_sub_day_status_rec.avg_flwl_dsc_temp;
    lr_params.mpm_oil_rate      := lr_pflw_sub_day_status_rec.avg_mpm_oil_rate;
    lr_params.mpm_gas_rate      := lr_pflw_sub_day_status_rec.avg_mpm_gas_rate;
    lr_params.mpm_water_rate    := lr_pflw_sub_day_status_rec.avg_mpm_water_rate;
    lr_params.mpm_cond_rate     := lr_pflw_sub_day_status_rec.avg_mpm_cond_rate;

  ELSIF SUBSTR(p_class_name,1, 11) = 'PFLW_RESULT' THEN
    ld_prod_daytime := EcDp_ProductionDay.getProductionDay('FLOWLINE', p_object_id, p_daytime);
    lr_pflw_result_rec := ec_pflw_result.row_by_pk(p_object_id,p_result_no);

    lr_params.choke_size        := lr_pflw_result_rec.choke_size;
    lr_params.flwl_press        := lr_pflw_result_rec.flwl_press;
    lr_params.flwl_temp         := lr_pflw_result_rec.flwl_temp;
    lr_params.flwl_usc_press    := lr_pflw_result_rec.flwl_usc_press;
    lr_params.flwl_usc_temp     := lr_pflw_result_rec.flwl_usc_temp;
    lr_params.flwl_dsc_press    := lr_pflw_result_rec.flwl_dsc_press;
    lr_params.flwl_dsc_temp     := lr_pflw_result_rec.flwl_dsc_temp;
    lr_params.mpm_oil_rate      := lr_pflw_result_rec.mpm_oil_rate;
    lr_params.mpm_gas_rate      := lr_pflw_result_rec.mpm_gas_rate;
    lr_params.mpm_water_rate    := lr_pflw_result_rec.mpm_water_rate;
    lr_params.mpm_cond_rate     := lr_pflw_result_rec.mpm_cond_rate;

  END IF;
    p_param_values :=  lr_params;
END populateCurveParameterValues;

END EcDp_Flowline_Theoretical;