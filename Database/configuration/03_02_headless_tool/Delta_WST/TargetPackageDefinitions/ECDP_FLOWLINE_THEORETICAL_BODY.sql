CREATE OR REPLACE PACKAGE BODY EcDp_Flowline_Theoretical IS
/****************************************************************
** Package        :  EcDp_Flowline_Theoretical, body part
**
** $Revision: 1.7 $
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
*****************************************************************/

-----------------------------------------------------------------
-- Function:    getCondensateGasRatio  (Flowline)
-- Description: Returns condensate gas ratio for a given flowline on
--              a given day based on the last performance curve
--
-----------------------------------------------------------------
FUNCTION getCondensateGasRatio(
	p_object_id flowline.object_id%TYPE,
	p_day DATE)
RETURN NUMBER IS
	ln_ret_val NUMBER;
	ln_condrate NUMBER;
	ln_gasrate NUMBER;
	lr_pflw_day_status_rec pflw_day_status%ROWTYPE;
	lr_params EcDp_Flowline_Theoretical.PerfCurveParamRec;

BEGIN

   lr_pflw_day_status_rec := ec_pflw_day_status.row_by_pk(p_object_id,p_day);

   lr_params.avg_choke_size        := lr_pflw_day_status_rec.avg_choke_size;
   lr_params.avg_flwl_press        := lr_pflw_day_status_rec.avg_flwl_press;
   lr_params.avg_flwl_temp         := lr_pflw_day_status_rec.avg_flwl_temp;
   lr_params.avg_flwl_usc_press    := lr_pflw_day_status_rec.avg_flwl_usc_press;
   lr_params.avg_flwl_usc_temp     := lr_pflw_day_status_rec.avg_flwl_usc_temp;
   lr_params.avg_flwl_dsc_press    := lr_pflw_day_status_rec.avg_flwl_dsc_press;
   lr_params.avg_flwl_dsc_temp     := lr_pflw_day_status_rec.avg_flwl_dsc_temp;
   lr_params.avg_mpm_oil_rate      := lr_pflw_day_status_rec.avg_mpm_oil_rate;
   lr_params.avg_mpm_gas_rate      := lr_pflw_day_status_rec.avg_mpm_gas_rate;
   lr_params.avg_mpm_water_rate    := lr_pflw_day_status_rec.avg_mpm_water_rate;
   lr_params.avg_mpm_cond_rate     := lr_pflw_day_status_rec.avg_mpm_cond_rate;


   ln_condrate := Ecdp_Flowline_Theoretical.getCurveStdRate(p_object_id,p_day,EcDp_Curve_Purpose.PRODUCTION,ecdp_phase.CONDENSATE,lr_params);
   ln_gasrate := Ecdp_Flowline_Theoretical.getCurveStdRate(p_object_id,p_day,EcDp_Curve_Purpose.PRODUCTION,ecdp_phase.GAS,lr_params);

   IF ln_gasrate > 0 THEN
	ln_ret_val := ln_condrate/ln_gasrate;
   END IF;

   RETURN ln_ret_val;
END getCondensateGasRatio;

-----------------------------------------------------------------
--  Function:    getGasOilRatio
--  Description: Find proper GOR to be used for an actual day
-----------------------------------------------------------------
FUNCTION getGasOilRatio(
  p_object_id flowline.object_id%TYPE,
  p_daytime  DATE)
RETURN NUMBER IS
  ln_gor NUMBER;
  ln_oilrate NUMBER;
  ln_gasrate NUMBER;
  lr_pflw_day_status_rec pflw_day_status%ROWTYPE;
  lr_params EcDp_Flowline_Theoretical.PerfCurveParamRec;

BEGIN
   lr_pflw_day_status_rec := ec_pflw_day_status.row_by_pk(p_object_id,p_daytime);

   lr_params.avg_choke_size        := lr_pflw_day_status_rec.avg_choke_size;
   lr_params.avg_flwl_press        := lr_pflw_day_status_rec.avg_flwl_press;
   lr_params.avg_flwl_temp         := lr_pflw_day_status_rec.avg_flwl_temp;
   lr_params.avg_flwl_usc_press    := lr_pflw_day_status_rec.avg_flwl_usc_press;
   lr_params.avg_flwl_usc_temp     := lr_pflw_day_status_rec.avg_flwl_usc_temp;
   lr_params.avg_flwl_dsc_press    := lr_pflw_day_status_rec.avg_flwl_dsc_press;
   lr_params.avg_flwl_dsc_temp     := lr_pflw_day_status_rec.avg_flwl_dsc_temp;
   lr_params.avg_mpm_oil_rate      := lr_pflw_day_status_rec.avg_mpm_oil_rate;
   lr_params.avg_mpm_gas_rate      := lr_pflw_day_status_rec.avg_mpm_gas_rate;
   lr_params.avg_mpm_water_rate    := lr_pflw_day_status_rec.avg_mpm_water_rate;
   lr_params.avg_mpm_cond_rate     := lr_pflw_day_status_rec.avg_mpm_cond_rate;


   ln_oilrate := Ecdp_Flowline_Theoretical.getCurveStdRate(p_object_id,p_daytime,EcDp_Curve_Purpose.PRODUCTION,ecdp_phase.OIL,lr_params);
   ln_gasrate := Ecdp_Flowline_Theoretical.getCurveStdRate(p_object_id,p_daytime,EcDp_Curve_Purpose.PRODUCTION,ecdp_phase.GAS,lr_params);

   IF ln_oilrate > 0 THEN
	ln_gor := ln_gasrate/ln_oilrate;
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
  p_daytime    DATE)

RETURN NUMBER
--</EC-DOC>
IS
  ln_watercut NUMBER;
  ln_oilrate NUMBER;
  ln_waterrate NUMBER;
  lr_pflw_day_status_rec pflw_day_status%ROWTYPE;
  lr_params EcDp_Flowline_Theoretical.PerfCurveParamRec;

BEGIN
   lr_pflw_day_status_rec := ec_pflw_day_status.row_by_pk(p_object_id,p_daytime);

   lr_params.avg_choke_size        := lr_pflw_day_status_rec.avg_choke_size;
   lr_params.avg_flwl_press        := lr_pflw_day_status_rec.avg_flwl_press;
   lr_params.avg_flwl_temp         := lr_pflw_day_status_rec.avg_flwl_temp;
   lr_params.avg_flwl_usc_press    := lr_pflw_day_status_rec.avg_flwl_usc_press;
   lr_params.avg_flwl_usc_temp     := lr_pflw_day_status_rec.avg_flwl_usc_temp;
   lr_params.avg_flwl_dsc_press    := lr_pflw_day_status_rec.avg_flwl_dsc_press;
   lr_params.avg_flwl_dsc_temp     := lr_pflw_day_status_rec.avg_flwl_dsc_temp;
   lr_params.avg_mpm_oil_rate      := lr_pflw_day_status_rec.avg_mpm_oil_rate;
   lr_params.avg_mpm_gas_rate      := lr_pflw_day_status_rec.avg_mpm_gas_rate;
   lr_params.avg_mpm_water_rate    := lr_pflw_day_status_rec.avg_mpm_water_rate;
   lr_params.avg_mpm_cond_rate     := lr_pflw_day_status_rec.avg_mpm_cond_rate;


   ln_oilrate := Ecdp_Flowline_Theoretical.getCurveStdRate(p_object_id,p_daytime,EcDp_Curve_Purpose.PRODUCTION,ecdp_phase.OIL,lr_params);
   ln_waterrate := Ecdp_Flowline_Theoretical.getCurveStdRate(p_object_id,p_daytime,EcDp_Curve_Purpose.PRODUCTION,ecdp_phase.WATER,lr_params);

   IF (ln_oilrate + ln_waterrate) > 0 THEN
      ln_watercut := ln_waterrate/(ln_oilrate + ln_waterrate) * 100;
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
  p_daytime	 DATE)

RETURN NUMBER IS

ln_ret_val                 NUMBER;
ln_gasrate                 NUMBER;
ln_waterrate               NUMBER;
lr_pflw_day_status_rec     pflw_day_status%ROWTYPE;
lr_params                  EcDp_Flowline_Theoretical.PerfCurveParamRec;


BEGIN
   lr_pflw_day_status_rec := ec_pflw_day_status.row_by_pk(p_object_id,p_daytime);

   lr_params.avg_choke_size        := lr_pflw_day_status_rec.avg_choke_size;
   lr_params.avg_flwl_press        := lr_pflw_day_status_rec.avg_flwl_press;
   lr_params.avg_flwl_temp         := lr_pflw_day_status_rec.avg_flwl_temp;
   lr_params.avg_flwl_usc_press    := lr_pflw_day_status_rec.avg_flwl_usc_press;
   lr_params.avg_flwl_usc_temp     := lr_pflw_day_status_rec.avg_flwl_usc_temp;
   lr_params.avg_flwl_dsc_press    := lr_pflw_day_status_rec.avg_flwl_dsc_press;
   lr_params.avg_flwl_dsc_temp     := lr_pflw_day_status_rec.avg_flwl_dsc_temp;
   lr_params.avg_mpm_oil_rate      := lr_pflw_day_status_rec.avg_mpm_oil_rate;
   lr_params.avg_mpm_gas_rate      := lr_pflw_day_status_rec.avg_mpm_gas_rate;
   lr_params.avg_mpm_water_rate    := lr_pflw_day_status_rec.avg_mpm_water_rate;
   lr_params.avg_mpm_cond_rate     := lr_pflw_day_status_rec.avg_mpm_cond_rate;


   ln_gasrate := EcDp_Flowline_Theoretical.getCurveStdRate(p_object_id,p_daytime,EcDp_Curve_Purpose.PRODUCTION,ecdp_phase.GAS,lr_params);
   ln_waterrate := EcDp_Flowline_Theoretical.getCurveStdRate(p_object_id,p_daytime,EcDp_Curve_Purpose.PRODUCTION,ecdp_phase.WATER,lr_params);

   IF ln_gasrate > 0 THEN
	ln_ret_val := ln_waterrate/ln_gasrate;
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
   p_phase           VARCHAR2
)
RETURN NUMBER
--</EC-DOC>
IS
BEGIN
   RETURN EcDp_Performance_Curve.getWellPerformanceCurveId(
											      p_object_id,
											      p_daytime,
											      p_curve_purpose,
                            p_phase
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
   p_phase           VARCHAR2
)
RETURN NUMBER
--</EC-DOC>
IS
BEGIN
   RETURN EcDp_Performance_Curve.getNextWellPerformanceCurveId(
														  p_object_id,
														  p_daytime,
														  p_curve_purpose,
                              p_phase
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
      ln_param_value:=p_param_values.avg_choke_size;
   ELSIF p_param_code=EcDp_Curve_Parameter.DP_FLOWLINE THEN
      ln_param_value:=p_param_values.avg_flwl_press;
   ELSIF p_param_code=EcDp_Curve_Parameter.DT_FLOWLINE THEN
      ln_param_value:=p_param_values.avg_flwl_temp;
   ELSIF p_param_code=EcDp_Curve_Parameter.DP_CHOKE THEN
      ln_param_value:=(p_param_values.avg_flwl_usc_press - p_param_values.avg_flwl_dsc_press);
    ELSIF p_param_code=EcDp_Curve_Parameter.MPM_OIL_RATE THEN
      ln_param_value:=p_param_values.avg_mpm_oil_rate;
   ELSIF p_param_code=EcDp_Curve_Parameter.MPM_GAS_RATE THEN
      ln_param_value:=p_param_values.avg_mpm_gas_rate;
   ELSIF p_param_code=EcDp_Curve_Parameter.MPM_WATER_RATE THEN
      ln_param_value:=p_param_values.avg_mpm_water_rate;

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
-- Behaviour      : To be determined		                     --
--                                                                                               --
---------------------------------------------------------------------------------------------------
FUNCTION getCurveStdRate(
   p_object_id flowline.object_id%TYPE,
   p_daytime        DATE,
   p_curve_purpose  VARCHAR2,
   p_phase          VARCHAR2,
   p_param_values   PerfCurveParamRec
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
   select pt.result_no from pflw_result pf, ptst_result pt where
          pf.result_no = pt.result_no and
          pf.object_id = cp_object_id and
          pt.valid_from_date > cp_daytime_1 and
          pt.valid_from_date < cp_daytime;
--		  and  pf.trend_reset_ind = 'Y';

   -- cursor to check if there's any reset trend avalaible at any daytime <= ln_daytime_2 and > p_datime
   CURSOR c_check_reset_trend_right (cp_object_id VARCHAR2, cp_daytime DATE, cp_daytime_2 DATE) IS
   select pt.result_no from pflw_result pf, ptst_result pt where
          pf.result_no = pt.result_no and
          pf.object_id = cp_object_id and
          pt.valid_from_date > p_daytime and
          pt.valid_from_date <= cp_daytime_2;
		  --and pf.trend_reset_ind = 'Y';

BEGIN
   -- Find the latest valid curve and the resulting rate (y1)
   ln_cur_perf_curve_id:=getPerformanceCurveId(p_object_id,
                                               p_daytime,
                                               p_curve_purpose,
                                               p_phase);

   -- Not able to find a valid curve, function return null
   IF ln_cur_perf_curve_id IS NULL THEN
      RETURN NULL;
   END IF;

   -- Find the next valid curve and the resulting rate (y2)
   ln_next_perf_curve_id:=getNextPerformanceCurveId(p_object_id,
                                                    p_daytime,
                                                    p_curve_purpose,
                                                    p_phase);

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

   --
   -- Check which approach method we should use
   --
   lv2_approach_method := ec_flwl_version.flw_approach_mtd(
                                                  p_object_id,
                                                  p_daytime,
                                                  '<=');
   --
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

END EcDp_Flowline_Theoretical;