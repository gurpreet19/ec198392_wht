CREATE OR REPLACE PACKAGE BODY EcBp_Flowline_Theoretical IS
/****************************************************************
** Package        :  EcBp_Flowline_Theoretical, body part
**
** $Revision: 1.17 $
**
** Purpose        :  Calculates theoretical flowline values (rates etc)
**
** Documentation  :  www.energy-components.com
**
** Created  :
**
** Modification history:
**
** Version  Date        Whom      Change description:
** -------  ----------  --------  --------------------------------------
**          30.12.2008  sharawan  ECPD-10416:Replaced all references to EcDp_Type.pb_comp_number%TYPE with NUMBER in functions
**                                getSubseaWellStdRateDay, getInjectedStdRateDay, getSubseaWellStdRateSubDay, getOilStdVolSubDay, getGasStdVolSubDay,
**                                getWatStdVolSubDay, getCondStdVolSubDay, findWaterCutPct, findCondGasRatio, findGasOilRatio, findWetDryFactor.
**          11.05.2011  bergejar  ECPD-16617 Fixed bug in if statements, referencing wrong method variable
**          20.04.2012  genasdev  ECPD-19938 Complete the attribute support for ORF-based calculations.
**          09.05.2012  limmmchu  ECPD-19937: Fixed bug in referencing wrong method variables.
**          09.05.2012  limmmchu  ECPD-19937: Modified getInjectedStdRateDay, flwl_oil_calc_inj_mtd to flwl_gas_calc_inj_mtd
**          13.03.2013  limmmchu  ECPD-23347: Updated getSubseaWellStdRateDay to use the correct calc method.
**          29.04.2013  wonggkai  ECPD-23348: getSubseaWellStdRateDay, getGasLiftStdRateDay to support gaslift.
**          03.05.2014  deshpadi  ECPD-26350: Modified getWatStdRateDay,getCondStdRateDay to support GAS_WGR and GAS_CGR respectively.Also added method findWaterGasRatio.
**          14.04.2014  leongwen  ECPD-22866: Applied the calculation methods for multiple phases Flowline Performance Curve based on the similar logic from Well Performance Curve.
**          24.03.2015  dhavaalo  ECPD-30292: Modified EcDp_Flowline_Theoretical.populateCurveParameterValues,getOilStdVolSubDay,getGasStdVolSubDay,getWatStdVolSubDay,getCondStdVolSubDay,
**                                    		  findWaterCutPct,findCondGasRatio and findGasOilRatio function to calculate Theoretical Water and Gas values correctly for day offset for Daily and sub-daily screen.
**											  Code Formatting done
**          31.08.2016  keskaash  ECPD-37224: Added new functions getAllocGasVolDay,getAllocOilVolDay,getAllocWaterVolDay,getAllocCondVolDay to get the well allocation data.
**          27.09.16 keskaash ECPD-35756: Added function getSubseaWellMassRateDay and findHCMassDay
*****************************************************************/


CURSOR c_conn_well_cursor (cp_flowline_object_id IN VARCHAR2, cp_daytime DATE) IS
 SELECT a.well_id well_object_id
 FROM flowline_sub_well_conn a
 WHERE a.object_id = cp_flowline_object_id
 AND a.daytime = ( SELECT Max(f.daytime)
		    FROM flowline_sub_well_conn f
		   WHERE  f.object_id = a.object_id
		   AND f.well_id = a.well_id
		   AND cp_daytime >= f.daytime AND cp_daytime < Nvl(f.end_Date, cp_daytime + 1));

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getCurveRate
-- Description    : Returns theoretical rate from performance curve
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
-- Using functions: EcDp_Flowline_Theoretical.GETPERFORMANCECURVEID
--                  EC_PERFORMANCE_CURVE.CURVE_PARAMETER_CODE
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getCurveRate(p_object_id       flowline.object_id%TYPE,
                      p_daytime         DATE,
                      p_phase           VARCHAR2,
                      p_curve_purpose   VARCHAR2,
                      p_choke_size      NUMBER,
                      p_flwl_press      NUMBER,
                      p_flwl_temp       NUMBER,
                      p_flwl_usc_press  NUMBER,
                      p_flwl_usc_temp   NUMBER,
                      p_flwl_dsc_press  NUMBER,
                      p_flwl_dsc_temp   NUMBER,
                      p_mpm_oil_rate    NUMBER,
                      p_mpm_gas_rate    NUMBER,
                      p_mpm_water_rate  NUMBER,
                      p_mpm_cond_rate   NUMBER,
                      p_pressure_zone   VARCHAR2 DEFAULT 'NORMAL',
                      p_calc_method     VARCHAR2 DEFAULT NULL)
RETURN NUMBER
--</EC-DOC>
IS
  lr_params EcDp_Flowline_Theoretical.PerfCurveParamRec;
BEGIN

  IF NVL(p_pressure_zone,'NORMAL')!='NORMAL' THEN
     RAISE_APPLICATION_ERROR(-20000,'Only NORMAL pressure zone is supported in performance curve calculations');
     RETURN NULL;
  END IF;
  lr_params.choke_size     := p_choke_size;
  lr_params.flwl_press     := p_flwl_press;
  lr_params.flwl_temp      := p_flwl_temp;
  lr_params.flwl_usc_press := p_flwl_usc_press;
  lr_params.flwl_usc_temp  := p_flwl_usc_temp;
  lr_params.flwl_dsc_press := p_flwl_dsc_press;
  lr_params.flwl_dsc_temp  := p_flwl_dsc_temp;
  lr_params.mpm_oil_rate   := p_mpm_oil_rate;
  lr_params.mpm_gas_rate   := p_mpm_gas_rate;
  lr_params.mpm_water_rate := p_mpm_water_rate;
  lr_params.mpm_cond_rate  := p_mpm_cond_rate;

  RETURN EcDp_Flowline_Theoretical.getCurveStdRate(p_object_id,
                                                   p_daytime,
                                                   p_curve_purpose,
                                                   p_phase,
                                                   lr_params,
                                                   p_calc_method);
END getCurveRate;


--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Function       : getSubseaWellStdRateDay                                                        --
-- Description    : Calculates theoretical rate for a flowline by summarizing the theoretical      --
--                  values for each subsea well connected.                                         --
--                                                                                                 --
-- Preconditions  :                                                                                --
-- Postconditions :                                                                                --
--                                                                                                 --
-- Using tables   : flowline_sub_well_conn                                                         --
--                                                                                                 --
-- Using functions: EcBp_Well_Theoretical.getOilStdRateDay                                         --
--                              EcBp_Well_Theoretical.getGasStdRateDay                             --
--                              EcBp_Well_Theoretical.getWatStdRateDay                             --
--                              EcBp_Well_Theoretical.getCondStdRateDay                            --
--                                                                                                 --
-- Configuration                                                                                   --
-- required       :                                                                                --
--                                                                                                 --
-- Behaviour      :                                                                                --
--                                                                                                 --
-----------------------------------------------------------------------------------------------------

FUNCTION getSubseaWellStdRateDay(p_object_id   VARCHAR2,
                                 p_daytime     DATE,
                                 p_phase       VARCHAR2)
RETURN NUMBER
--<EC-DOC>
 IS
  /* Select all open producing wells which have been connected to a flowline during the production day period.  */
  CURSOR c_subwells IS
  SELECT DISTINCT object_id, well_id
  FROM flowline_sub_well_conn
  WHERE object_id = p_object_id AND
        daytime < p_daytime + 1 AND
        Nvl(end_date, p_daytime + 1) > p_daytime;

  ln_ret_val    NUMBER;
  ln_phase_rate NUMBER := 0;
  lb_value_flag BOOLEAN;
  lv2_calc_method VARCHAR2(32);

BEGIN
 -- Process all sub wells which have been connected during the day
  FOR subwell IN c_subwells LOOP
    IF (c_subwells%ROWCOUNT = 1) THEN
      ln_ret_val := 0;
    END IF;
    If p_phase = ecdp_phase.OIL THEN
      lv2_calc_method :=ec_well_version.calc_method(subwell.well_id, p_daytime, '<=');
      ln_phase_rate := EcBp_Well_Theoretical.getOilStdRateDay(subwell.well_id, p_daytime, lv2_calc_method);
    elsif p_phase = ecdp_phase.GAS then
      lv2_calc_method :=ec_well_version.calc_gas_method(subwell.well_id, p_daytime, '<=');
      ln_phase_rate := EcBp_Well_Theoretical.getGasStdRateDay(subwell.well_id, p_daytime, lv2_calc_method);
    elsif p_phase = ecdp_phase.WATER then
      lv2_calc_method :=ec_well_version.calc_water_method(subwell.well_id, p_daytime, '<=');
      ln_phase_rate := EcBp_Well_Theoretical.getWatStdRateDay(subwell.well_id, p_daytime, lv2_calc_method);
    elsif p_phase = ecdp_phase.CONDENSATE then
      lv2_calc_method :=ec_well_version.calc_cond_method(subwell.well_id, p_daytime, '<=');
      ln_phase_rate := EcBp_Well_Theoretical.getCondStdRateDay(subwell.well_id, p_daytime, lv2_calc_method);
    elsif p_phase = ecdp_phase.GAS_LIFT then
      lv2_calc_method :=ec_well_version.gas_lift_method(subwell.well_id, p_daytime, '<=');
      ln_phase_rate := EcBp_Well_Theoretical.getGasLiftStdRateDay(subwell.well_id, p_daytime, lv2_calc_method);
    end if;
    IF NOT lb_value_flag THEN
      lb_value_flag := (ln_phase_rate >= 0);
    END IF;
    ln_ret_val := ln_ret_val + Nvl(ln_phase_rate, 0);
  END LOOP;
  RETURN ln_ret_val;

END getSubseaWellStdRateDay;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getOilStdRateDay
-- Description    : Returns theoretical oil volume for flowline on a given day, source method specified
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getOilStdRateDay(p_object_id   flowline.object_id%TYPE,
                          p_daytime     DATE,
                          p_calc_method VARCHAR2 DEFAULT NULL)
RETURN NUMBER
--</EC-DOC>
IS
  lv2_calc_method            VARCHAR2(32);
  lr_day_rec                 PFLW_DAY_STATUS%ROWTYPE;
  lr_flwl_version            FLWL_VERSION%ROWTYPE;

  ln_curve_value             NUMBER;
  ln_on_flwl_ratio           NUMBER;
  ln_ret_val                 NUMBER;

BEGIN
-- oil_calc_method
  lr_flwl_version :=ec_flwl_version.row_by_pk(p_object_id, p_daytime, '<=');
  lv2_calc_method := Nvl(p_calc_method, lr_flwl_version.FLW_CALC_OIL_MTD);
  IF (lv2_calc_method = EcDp_Calc_Method.CURVE) THEN
    ln_on_flwl_ratio := EcDp_Flowline.calcPflwUptime(p_object_id, p_daytime)/24;
    IF ln_on_flwl_ratio > 0 THEN -- Only worth doing calculation when the flowline is up
       lr_day_rec := ec_pflw_day_status.row_by_pk(p_object_id, p_daytime);
       ln_curve_value := getCurveRate(p_object_id,
                                      p_daytime,
                                      EcDp_Phase.OIL,
                                      EcDp_Curve_Purpose.PRODUCTION,
                                      lr_day_rec.avg_choke_size,
                                      lr_day_rec.avg_flwl_press,
                                      lr_day_rec.avg_flwl_temp,
                                      lr_day_rec.avg_flwl_usc_press,
                                      lr_day_rec.avg_flwl_usc_temp,
                                      lr_day_rec.avg_flwl_dsc_press,
                                      lr_day_rec.avg_flwl_dsc_temp,
                                      lr_day_rec.avg_mpm_oil_rate,
                                      lr_day_rec.avg_mpm_gas_rate,
                                      lr_day_rec.avg_mpm_water_rate,
                                      lr_day_rec.avg_mpm_cond_rate,
                                      NULL,
                                      lv2_calc_method
                                      );
       ln_ret_val := ln_curve_value * ln_on_flwl_ratio;
    ELSIF ln_on_flwl_ratio = 0 THEN
      ln_ret_val := 0;
    ELSE
       ln_ret_val := NULL;
    END IF;
  ELSIF (lv2_calc_method = EcDp_Calc_Method.CURVE_LIQUID) THEN
    ln_on_flwl_ratio := EcDp_Flowline.calcPflwUptime(p_object_id, p_daytime)/24;
    IF ln_on_flwl_ratio > 0 THEN -- Only worth doing calculation when the well is up
      lr_day_rec := ec_pflw_day_status.row_by_pk(p_object_id, p_daytime);
      ln_ret_val := getCurveRate(p_object_id,
                                 p_daytime,
                                 EcDp_Phase.LIQUID,
                                 EcDp_Curve_Purpose.PRODUCTION,
                                 lr_day_rec.avg_choke_size,
                                 lr_day_rec.avg_flwl_press,
                                 lr_day_rec.avg_flwl_temp,
                                 lr_day_rec.avg_flwl_usc_press,
                                 lr_day_rec.avg_flwl_usc_temp,
                                 lr_day_rec.avg_flwl_dsc_press,
                                 lr_day_rec.avg_flwl_dsc_temp,
                                 lr_day_rec.avg_mpm_oil_rate,
                                 lr_day_rec.avg_mpm_gas_rate,
                                 lr_day_rec.avg_mpm_water_rate,
                                 lr_day_rec.avg_mpm_cond_rate,
                                 NULL,
                                 lv2_calc_method
                                 );
      ln_ret_val :=  ln_ret_val *  ln_on_flwl_ratio;
    ELSIF ln_on_flwl_ratio = 0 THEN
      ln_ret_val := 0;
    ELSE
      ln_ret_val := NULL;
    END IF;
  ELSIF (lv2_calc_method = EcDp_Calc_method.MPM) THEN
     lr_day_rec := ec_pflw_day_status.row_by_pk(p_object_id, p_daytime);
     ln_ret_val := lr_day_rec.avg_mpm_oil_rate;
  ELSIF lv2_calc_method = EcDp_Calc_Method.SUBSEA_WELLS THEN
     ln_ret_val := getSubseaWellStdRateDay(p_object_id, p_daytime, EcDp_Phase.OIL);
  ELSIF (substr(lv2_calc_method,1,9) = EcDp_Calc_Method.USER_EXIT) THEN
     ln_ret_val := Ue_Flowline_Theoretical.getOilStdRateDay(p_object_id, p_daytime);
  ELSE -- undefined
     ln_ret_val := NULL;
  END IF;
 RETURN ln_ret_val;
END getOilStdRateDay;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getGasLiftStdRateDay
-- Description    : Returns theoretical gaslift volume for flowline on a given day, source method specified
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      : FOR FUTURE USE --(CURRENTLY NOT URGENT REQUIRED)
--
---------------------------------------------------------------------------------------------------
FUNCTION getGasLiftStdRateDay(p_object_id     flowline.object_id%TYPE,
                              p_daytime       DATE,
                              p_gas_lift_method   VARCHAR2 DEFAULT NULL )
RETURN NUMBER
--</EC-DOC>
IS
  lv2_gas_lift_method   VARCHAR2(32);
  lr_day_rec            PFLW_DAY_STATUS%ROWTYPE;
  lr_result_rec         pflw_result%ROWTYPE;

  ln_curve_value        NUMBER;
  ln_on_flwl_ratio      NUMBER;
  ln_ret_val            NUMBER;
BEGIN
  lv2_gas_lift_method := NVL(p_gas_lift_method, ec_flwl_version.FLWL_CALC_GAS_LIFT_MTD(p_object_id, p_daytime, '<='));

  IF (lv2_gas_lift_method = EcDp_Calc_Method.CURVE_GAS_LIFT) THEN
    ln_on_flwl_ratio := EcDp_Flowline.calcPflwUptime(p_object_id, p_daytime)/24;
    IF ln_on_flwl_ratio > 0 THEN -- Only worth doing calculation when the flowline is up
      lr_day_rec := ec_pflw_day_status.row_by_pk(p_object_id, p_daytime);
      ln_curve_value := getCurveRate(p_object_id,
                                     p_daytime,
                                     'GAS',
                                     'GAS_LIFT',
                                     lr_day_rec.avg_choke_size,
                                     lr_day_rec.avg_flwl_press,
                                     lr_day_rec.avg_flwl_temp,
                                     lr_day_rec.avg_flwl_usc_press,
                                     lr_day_rec.avg_flwl_usc_temp,
                                     lr_day_rec.avg_flwl_dsc_press,
                                     lr_day_rec.avg_flwl_dsc_temp,
                                     lr_day_rec.avg_mpm_oil_rate,
                                     lr_day_rec.avg_mpm_gas_rate,
                                     lr_day_rec.avg_mpm_water_rate,
                                     lr_day_rec.avg_mpm_cond_rate,
                                     NULL,
                                     lv2_gas_lift_method
                                     );
      ln_ret_val := ln_curve_value * ln_on_flwl_ratio;
    ELSIF ln_on_flwl_ratio = 0 THEN
      ln_ret_val := 0;
    ELSE
      ln_ret_val := NULL;
    END IF;
  ELSIF (lv2_gas_lift_method = EcDp_Calc_Method.MEASURED) THEN
    lr_day_rec := ec_pflw_day_status.row_by_pk(p_object_id, p_daytime);
    ln_ret_val := lr_day_rec.avg_gl_rate;
  ELSIF (lv2_gas_lift_method = EcDp_Calc_Method.SUBSEA_WELLS) THEN
    ln_ret_val := getSubseaWellStdRateDay(p_object_id, p_daytime, EcDp_Phase.GAS_LIFT);
  ELSIF (substr(lv2_gas_lift_method,1,9) = EcDp_Calc_Method.USER_EXIT) THEN
    ln_ret_val := Ue_Flowline_Theoretical.getGasLiftStdRateDay(p_object_id, p_daytime);
  ELSE -- undefined method
    ln_ret_val := null;
  END IF;
  RETURN ln_ret_val;
END getGasLiftStdRateDay;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getGasStdRateDay
-- Description    : Returns theoretical gas volume for flowline on a given day, source method specified
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getGasStdRateDay(p_object_id   flowline.object_id%TYPE,
                          p_daytime     DATE,
                          p_calc_method VARCHAR2 DEFAULT NULL)
RETURN NUMBER
--</EC-DOC>
IS
  lv2_calc_method       VARCHAR2(32);
  lr_day_rec            pflw_day_status%ROWTYPE;
  lr_flwl_version       flwl_version%ROWTYPE;
  ln_curve_value        NUMBER;
  ln_on_flwl_ratio      NUMBER;
  ln_ret_val            NUMBER;
  ln_oil_rate           NUMBER;
BEGIN
  lr_flwl_version := ec_flwl_version.row_by_pk(p_object_id, p_daytime, '<=');
  lv2_calc_method := Nvl(p_calc_method, lr_flwl_version.FLW_CALC_GAS_MTD);
  IF (lv2_calc_method = EcDp_Calc_Method.CURVE_GAS) THEN
    ln_on_flwl_ratio := EcDp_Flowline.calcPflwUptime(p_object_id, p_daytime)/24;
    IF ln_on_flwl_ratio > 0 THEN -- Only worth doing calculation when the flowline is up
      lr_day_rec := ec_pflw_day_status.row_by_pk(p_object_id, p_daytime);
      ln_curve_value := getCurveRate( p_object_id,
                                      p_daytime,
                                      EcDp_Phase.GAS,
                                      EcDp_Curve_Purpose.PRODUCTION,
                                      lr_day_rec.avg_choke_size,
                                      lr_day_rec.avg_flwl_press,
                                      lr_day_rec.avg_flwl_temp,
                                      lr_day_rec.avg_flwl_usc_press,
                                      lr_day_rec.avg_flwl_usc_temp,
                                      lr_day_rec.avg_flwl_dsc_press,
                                      lr_day_rec.avg_flwl_dsc_temp,
                                      lr_day_rec.avg_mpm_oil_rate,
                                      lr_day_rec.avg_mpm_gas_rate,
                                      lr_day_rec.avg_mpm_water_rate,
                                      lr_day_rec.avg_mpm_cond_rate,
                                      NULL,
                                      lv2_calc_method
                                      );
      ln_ret_val := ln_curve_value * ln_on_flwl_ratio;
    ELSIF ln_on_flwl_ratio = 0 THEN
      ln_ret_val := 0;
    ELSE
      ln_ret_val := NULL;
    END IF;
  ELSIF (lv2_calc_method = EcDp_Calc_method.MPM) THEN
    lr_day_rec := ec_pflw_day_status.row_by_pk(p_object_id, p_daytime);
    ln_ret_val := lr_day_rec.avg_mpm_gas_rate;
  ELSIF lv2_calc_method = EcDp_Calc_Method.SUBSEA_WELLS THEN
    ln_ret_val := getSubseaWellStdRateDay(p_object_id, p_daytime, EcDp_Phase.GAS);
  ELSIF (lv2_calc_method = EcDp_Calc_Method.OIL_GOR) THEN
    ln_oil_rate := getOilStdRateDay(p_object_id, p_daytime, NULL);
    IF ln_oil_rate > 0 THEN     -- Only worth getting GOR if Oil is > 0
       ln_ret_val := ln_oil_rate * findGasOilRatio(p_object_id, p_daytime, null, 'PFLW_DAY_STATUS');
    ELSIF ln_oil_rate = 0 THEN     -- if oil rate = 0, then gas is also zero
       ln_ret_val := 0;
    ELSE
       ln_ret_val := null;
    END IF;
  ELSIF (substr(lv2_calc_method,1,9) = EcDp_Calc_Method.USER_EXIT) THEN
    ln_ret_val := Ue_Flowline_Theoretical.getGasStdRateDay(p_object_id, p_daytime);
  ELSE  -- unknown method
    ln_ret_val := NULL;
  END IF;
  RETURN ln_ret_val;
END getGasStdRateDay;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getWatStdRateDay
-- Description    : Returns theoretical water volume for flowline on a given day, source method specified
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getWatStdRateDay(p_object_id   flowline.object_id%TYPE,
                          p_daytime     DATE,
                          p_calc_method VARCHAR2 DEFAULT NULL)

RETURN NUMBER
--</EC-DOC>
IS
  lv2_calc_method       VARCHAR2(32);
  lr_day_rec            pflw_day_status%ROWTYPE;
  lr_flwl_version       flwl_version%ROWTYPE;
  ln_curve_value        NUMBER;
  ln_on_flwl_ratio      NUMBER;
  ln_gas_rate           NUMBER;
  ln_ret_val            NUMBER;
  ln_water_cut          NUMBER;
  ln_oil_rate           NUMBER;
BEGIN
  lr_flwl_version := ec_flwl_version.row_by_pk(p_object_id, p_daytime, '<=');
  lv2_calc_method := Nvl(p_calc_method, lr_flwl_version.FLW_CALC_WATER_MTD);

  IF (lv2_calc_method = EcDp_Calc_Method.CURVE_WATER) THEN
    ln_on_flwl_ratio := EcDp_Flowline.calcPflwUptime(p_object_id, p_daytime)/24;
    IF ln_on_flwl_ratio > 0 THEN -- Only worth doing calculation when the flowline is up
      lr_day_rec := ec_pflw_day_status.row_by_pk(p_object_id, p_daytime);
      ln_curve_value := getCurveRate( p_object_id,
                                      p_daytime,
                                      EcDp_Phase.WATER,
                                      EcDp_Curve_Purpose.PRODUCTION,
                                      lr_day_rec.avg_choke_size,
                                      lr_day_rec.avg_flwl_press,
                                      lr_day_rec.avg_flwl_temp,
                                      lr_day_rec.avg_flwl_usc_press,
                                      lr_day_rec.avg_flwl_usc_temp,
                                      lr_day_rec.avg_flwl_dsc_press,
                                      lr_day_rec.avg_flwl_dsc_temp,
                                      lr_day_rec.avg_mpm_oil_rate,
                                      lr_day_rec.avg_mpm_gas_rate,
                                      lr_day_rec.avg_mpm_water_rate,
                                      lr_day_rec.avg_mpm_cond_rate,
                                      NULL,
                                      lv2_calc_method
                                      );
      ln_ret_val := ln_curve_value * ln_on_flwl_ratio;
    ELSIF ln_on_flwl_ratio = 0 THEN
      ln_ret_val := 0;
    ELSE
      ln_ret_val := NULL;
    END IF;
  ELSIF (lv2_calc_method = EcDp_Calc_method.MPM) THEN
    lr_day_rec := ec_pflw_day_status.row_by_pk(p_object_id, p_daytime);
    ln_ret_val := lr_day_rec.avg_mpm_water_rate;
  ELSIF lv2_calc_method = EcDp_Calc_Method.SUBSEA_WELLS THEN
    ln_ret_val := getSubseaWellStdRateDay(p_object_id, p_daytime, EcDp_Phase.WATER);
  ELSIF (lv2_calc_method = EcDp_Calc_Method.GAS_WGR) THEN
    ln_gas_rate := getGasStdRateDay(p_object_id, p_daytime, lr_flwl_version.FLW_CALC_GAS_MTD);
    IF ln_gas_rate > 0 THEN   -- Only worth getting WGR if Gas is > 0
        ln_ret_val := ln_gas_rate * findWaterGasRatio(p_object_id, p_daytime, lr_flwl_version.FLWL_WGR_MTD, 'PFLW_DAY_STATUS');
    ELSIF ln_gas_rate = 0 THEN   -- if oil rate = 0, then water is also zero
        ln_ret_val := 0;
    ELSE
        ln_ret_val := NULL;
    END IF;
  ELSIF (lv2_calc_method = EcDp_Calc_Method.OIL_WATER_CUT) THEN
    ln_water_cut := findWaterCutPct(p_object_id, p_daytime, lr_flwl_version.FLWL_BSW_VOL_MTD, 'PFLW_DAY_STATUS')/100;
    ln_oil_rate := getOilStdRateDay(p_object_id, p_daytime, lr_flwl_version.FLW_CALC_OIL_MTD);
    IF ln_oil_rate > 0 THEN
      IF (1 - ln_water_cut) <> 0 THEN
        ln_ret_val := (ln_oil_rate/(1 - ln_water_cut)) * ln_water_cut;
      ELSE   -- div by zero
        ln_ret_val := null;
      END IF;
    ELSIF ln_oil_rate = 0 THEN   -- if oil is zero, then also water is zero
      ln_ret_val := 0;
    ELSE
      ln_ret_val := null;
    END IF;
  ELSIF (lv2_calc_method = EcDp_Calc_Method.GAS_WATER_CUT) THEN
    ln_water_cut := findWaterCutPct(p_object_id, p_daytime, lr_flwl_version.FLWL_BSW_VOL_MTD, 'PFLW_DAY_STATUS')/100;
    ln_gas_rate := getGasStdRateDay(p_object_id, p_daytime, lr_flwl_version.FLW_CALC_GAS_MTD);
    IF ln_gas_rate > 0 THEN
      IF (1 - ln_water_cut) <> 0 THEN
        ln_ret_val := (ln_gas_rate/(1 - ln_water_cut)) * ln_water_cut;
      ELSE   -- div by zero
        ln_ret_val := null;
      END IF;
    ELSIF ln_gas_rate = 0 THEN   -- if oil is zero, then also water is zero
      ln_ret_val := 0;
    ELSE
      ln_ret_val := null;
    END IF;
  ELSIF (lv2_calc_method = EcDp_Calc_Method.LIQ_WATER_CUT) THEN
    ln_water_cut := findWaterCutPct(p_object_id, p_daytime, lr_flwl_version.FLWL_BSW_VOL_MTD, 'PFLW_DAY_STATUS')/100;
    ln_oil_rate := getOilStdRateDay(p_object_id, p_daytime, lr_flwl_version.FLW_CALC_OIL_MTD);
    IF ln_oil_rate > 0 THEN
      IF (1 - ln_water_cut) <> 0 THEN
        ln_ret_val := (ln_oil_rate / (1 - ln_water_cut)) * ln_water_cut;
      ELSE   -- div by zero
        ln_ret_val := null;
      END IF;
    ELSIF ln_oil_rate = 0 THEN   -- if oil is zero, then also water is zero
      ln_ret_val := 0;
    ELSE
      ln_ret_val := null;
    END IF;
  ELSIF (substr(lv2_calc_method,1,9) = EcDp_Calc_Method.USER_EXIT) THEN
    ln_ret_val := Ue_Flowline_Theoretical.getWatStdRateDay(p_object_id, p_daytime);
  ELSE -- undefined
    ln_ret_val :=  NULL;
  END IF;
  RETURN ln_ret_val;
END getWatStdRateDay;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getCondStdRateDay
-- Description    : Returns theoretical condensate volume for flowline on a given day, source method specified
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getCondStdRateDay(p_object_id   flowline.object_id%TYPE,
                           p_daytime     DATE,
                           p_calc_method VARCHAR2 DEFAULT NULL)
RETURN NUMBER
--</EC-DOC>
IS
  lv2_calc_method       VARCHAR2(32);
  lr_day_rec            pflw_day_status%ROWTYPE;
  lr_flwl_version       flwl_version%ROWTYPE;
  ln_curve_value        NUMBER;
  ln_on_flwl_ratio      NUMBER;
  ln_gas_rate           NUMBER;
  ln_ret_val            NUMBER;
BEGIN
  lr_flwl_version := ec_flwl_version.row_by_pk(p_object_id, p_daytime, '<=');
  lv2_calc_method := Nvl(p_calc_method, lr_flwl_version.FLW_CALC_COND_MTD);
  IF (lv2_calc_method = EcDp_Calc_Method.CURVE) THEN
    ln_on_flwl_ratio := EcDp_Flowline.calcPflwUptime(p_object_id, p_daytime)/24;
    IF ln_on_flwl_ratio > 0 THEN -- Only worth doing calculation when the flowline is up
      lr_day_rec := ec_pflw_day_status.row_by_pk(p_object_id, p_daytime);
      ln_curve_value := getCurveRate( p_object_id,
                                      p_daytime,
                                      EcDp_Phase.CONDENSATE,
                                      EcDp_Curve_Purpose.PRODUCTION,
                                      lr_day_rec.avg_choke_size,
                                      lr_day_rec.avg_flwl_press,
                                      lr_day_rec.avg_flwl_temp,
                                      lr_day_rec.avg_flwl_usc_press,
                                      lr_day_rec.avg_flwl_usc_temp,
                                      lr_day_rec.avg_flwl_dsc_press,
                                      lr_day_rec.avg_flwl_dsc_temp,
                                      lr_day_rec.avg_mpm_oil_rate,
                                      lr_day_rec.avg_mpm_gas_rate,
                                      lr_day_rec.avg_mpm_water_rate,
                                      lr_day_rec.avg_mpm_cond_rate,
                                      NULL,
                                      lv2_calc_method
                                      );
      ln_ret_val := ln_curve_value * ln_on_flwl_ratio;
    ELSIF ln_on_flwl_ratio = 0 THEN
      ln_ret_val := 0;
    ELSE
      ln_ret_val := NULL;
    END IF;
  ELSIF (lv2_calc_method = EcDp_Calc_Method.CURVE_LIQUID) THEN
    ln_on_flwl_ratio := EcDp_Flowline.calcPflwUptime(p_object_id, p_daytime)/24;
    IF ln_on_flwl_ratio > 0 THEN -- Only worth doing calculation when the flowline is up
      lr_day_rec := ec_pflw_day_status.row_by_pk(p_object_id, p_daytime);
      ln_curve_value := getCurveRate( p_object_id,
                                      p_daytime,
                                      EcDp_Phase.CONDENSATE,
                                      EcDp_Curve_Purpose.PRODUCTION,
                                      lr_day_rec.avg_choke_size,
                                      lr_day_rec.avg_flwl_press,
                                      lr_day_rec.avg_flwl_temp,
                                      lr_day_rec.avg_flwl_usc_press,
                                      lr_day_rec.avg_flwl_usc_temp,
                                      lr_day_rec.avg_flwl_dsc_press,
                                      lr_day_rec.avg_flwl_dsc_temp,
                                      lr_day_rec.avg_mpm_oil_rate,
                                      lr_day_rec.avg_mpm_gas_rate,
                                      lr_day_rec.avg_mpm_water_rate,
                                      lr_day_rec.avg_mpm_cond_rate,
                                      NULL,
                                      lv2_calc_method
                                      );
      ln_ret_val := ln_curve_value * ln_on_flwl_ratio;
    ELSIF ln_on_flwl_ratio = 0 THEN
      ln_ret_val := 0;
    ELSE
      ln_ret_val := NULL;
    END IF;
  ELSIF lv2_calc_method = EcDp_Calc_Method.SUBSEA_WELLS THEN
    ln_ret_val := getSubseaWellStdRateDay(p_object_id, p_daytime, EcDp_Phase.CONDENSATE);
  ELSIF (lv2_calc_method = EcDp_Calc_method.MPM) THEN
    lr_day_rec := ec_pflw_day_status.row_by_pk(p_object_id, p_daytime);
    ln_ret_val := lr_day_rec.avg_mpm_cond_rate;
  ELSIF (lv2_calc_method = EcDp_Calc_Method.GAS_CGR) THEN
    ln_gas_rate := getGasStdRateDay(p_object_id, p_daytime, lr_flwl_version.FLW_CALC_GAS_MTD);
    IF ln_gas_rate > 0 THEN
      ln_ret_val := ln_gas_rate * findCondGasRatio(p_object_id, p_daytime, lr_flwl_version.FLWL_CGR_MTD, 'PFLW_DAY_STATUS');
    ELSE
      ln_ret_val := 0;
    END IF;
  ELSIF (substr(lv2_calc_method,1,9) = EcDp_Calc_Method.USER_EXIT) THEN
    ln_ret_val := Ue_Flowline_Theoretical.getCondStdRateDay(p_object_id, p_daytime);
  ELSE
    ln_ret_val := NULL;
  END IF;
  RETURN ln_ret_val;
END getCondStdRateDay;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getInjectedStdRateDay
-- Description    : Returns theoretical injection volume for well on a given day, source method specified
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getInjectedStdRateDay(p_object_id   flowline.object_id%TYPE,
                               p_inj_type    VARCHAR2,
                               p_daytime     DATE,
                               p_calc_inj_method VARCHAR2 DEFAULT NULL)
RETURN NUMBER
--</EC-DOC>
IS
  lv2_calc_inj_method         VARCHAR2(32);
  lr_day_rec                  iflw_day_status%ROWTYPE;
  ln_ret_val                  NUMBER;
  ln_on_flwl_ratio            NUMBER;
  lv2_phase                   VARCHAR2(32);
  ln_curve_value              NUMBER;
  lr_flwl_version             FLWL_VERSION%ROWTYPE;
BEGIN
  lr_flwl_version := ec_flwl_version.row_by_pk(p_object_id, p_daytime, '<=');

  IF (p_inj_type = Ecdp_Flowline_Type.GAS_INJECTOR) THEN
    lv2_calc_inj_method := Nvl(p_calc_inj_method, lr_flwl_version.FLWL_GAS_CALC_INJ_MTD);
  ELSIF (p_inj_type = Ecdp_Flowline_Type.WATER_INJECTOR) THEN
    lv2_calc_inj_method := Nvl(p_calc_inj_method, lr_flwl_version.FLWL_WAT_CALC_INJ_MTD);
  END IF;

  IF (substr(lv2_calc_inj_method,1,9) = 'CURVE_INJ') THEN
    ln_on_flwl_ratio := EcDp_Flowline.calcIflwUptime(p_object_id,p_daytime) / 24;
    IF ln_on_flwl_ratio > 0 THEN -- Only worth doing calculation when the well is up
      IF (p_inj_type = ecdp_flowline_type.WATER_INJECTOR) THEN
          lv2_phase := EcDp_Phase.WATER;
      ELSIF (p_inj_type = ecdp_flowline_type.GAS_INJECTOR) THEN
          lv2_phase := EcDp_Phase.GAS;
      END IF;
      lr_day_rec := ec_iflw_day_status.row_by_pk(p_object_id,p_inj_type, p_daytime);
      ln_curve_value := getCurveRate( p_object_id,
                                      p_daytime,
                                      lv2_phase,
                                      EcDp_Curve_Purpose.INJECTION,
                                      lr_day_rec.avg_choke_size,
                                      lr_day_rec.avg_flwl_press,
                                      lr_day_rec.avg_flwl_temp,
                                      lr_day_rec.avg_flwl_usc_press,
                                      lr_day_rec.avg_flwl_usc_temp,
                                      lr_day_rec.avg_flwl_dsc_press,
                                      lr_day_rec.avg_flwl_dsc_temp,
                                      lr_day_rec.avg_mpm_oil_rate,
                                      lr_day_rec.avg_mpm_gas_rate,
                                      lr_day_rec.avg_mpm_water_rate,
                                      lr_day_rec.avg_mpm_cond_rate,
                                      NULL,
                                      lv2_calc_inj_method
                                      );
      ln_ret_val := ln_curve_value * ln_on_flwl_ratio;
    ELSIF ln_on_flwl_ratio = 0 THEN
      ln_ret_val := 0;
    ELSE
      ln_ret_val := NULL;
    END IF;
  ELSIF (lv2_calc_inj_method = Ecdp_Calc_Method.MEASURED) THEN
     lr_day_rec := ec_iflw_day_status.row_by_pk(p_object_id, p_inj_type, p_daytime);
    IF NOT(lr_day_rec.inj_vol IS NULL AND lr_day_rec.inj_vol_2 IS NULL) THEN
      ln_ret_val := nvl(lr_day_rec.inj_vol,0) + nvl(lr_day_rec.inj_vol_2,0);
    END IF;
  ELSIF (substr(lv2_calc_inj_method,1,9) = EcDp_Calc_Method.USER_EXIT) THEN
    ln_ret_val := Ue_Flowline_Theoretical.getInjectedStdRateDay(p_object_id, p_inj_type, p_daytime);
  ELSE -- undefined
     ln_ret_val := NULL;
  END IF;
  RETURN ln_ret_val;
END getInjectedStdRateDay;

-------------------------------------------------------------------------
-- Function       : findOilMassDay
-------------------------------------------------------------------------
FUNCTION findOilMassDay(p_object_id   flowline.object_id%TYPE,
                        p_daytime     DATE,
                        p_calc_method VARCHAR2 DEFAULT NULL)
RETURN NUMBER
--</EC-DOC>
IS
  lv2_calc_method    VARCHAR2(32);
  ln_ret_val         NUMBER;
  lr_day_rec         PFLW_DAY_STATUS%ROWTYPE;
BEGIN
  lv2_calc_method := Nvl(p_calc_method, ec_flwl_version.FLWL_CALC_MASS_MTD(p_object_id,p_daytime,'<='));
  IF (lv2_calc_method = EcDp_Calc_Method.MEASURED) THEN
    lr_day_rec := ec_pflw_day_status.row_by_pk(p_object_id, p_daytime);
    ln_ret_val := lr_day_rec.avg_oil_mass;
  ELSIF (substr(lv2_calc_method,1,9) = EcDp_Calc_Method.USER_EXIT) THEN
    ln_ret_val := Ue_Flowline_Theoretical.findOilMassDay(p_object_id, p_daytime);
  ELSE  -- undefined
        ln_ret_val := NULL;
  END IF;
  RETURN ln_ret_val;
END findOilMassDay;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : findGasMassDay
---------------------------------------------------------------------------------------------------
FUNCTION findGasMassDay (p_object_id   flowline.object_id%TYPE,
                         p_daytime     DATE,
                         p_calc_method VARCHAR2 DEFAULT NULL)
RETURN NUMBER
--</EC-DOC>
IS
  lv2_calc_method    VARCHAR2(32);
  ln_ret_val         NUMBER;
  lr_day_rec         PFLW_DAY_STATUS%ROWTYPE;
BEGIN
  lv2_calc_method := Nvl(p_calc_method, ec_flwl_version.FLWL_CALC_MASS_MTD(p_object_id,p_daytime,'<='));
  IF (lv2_calc_method = EcDp_Calc_Method.MEASURED) THEN
    lr_day_rec := ec_pflw_day_status.row_by_pk(p_object_id, p_daytime);
    ln_ret_val := lr_day_rec.avg_gas_mass;
  ELSIF (substr(lv2_calc_method,1,9) = EcDp_Calc_Method.USER_EXIT) THEN
    ln_ret_val := Ue_Flowline_Theoretical.findGasMassDay(p_object_id, p_daytime);
  ELSE  -- undefined
        ln_ret_val := NULL;
  END IF;
  RETURN ln_ret_val;
END findGasMassDay;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : findWaterMassDay
---------------------------------------------------------------------------------------------------
FUNCTION findWaterMassDay (p_object_id   flowline.object_id%TYPE,
                           p_daytime     DATE,
                           p_calc_method VARCHAR2 DEFAULT NULL)
RETURN NUMBER
--</EC-DOC>
IS
  lv2_calc_method    VARCHAR2(32);
  ln_ret_val         NUMBER;
  lr_day_rec         PFLW_DAY_STATUS%ROWTYPE;
BEGIN
  lv2_calc_method := Nvl(p_calc_method, ec_flwl_version.FLWL_CALC_MASS_MTD(p_object_id,p_daytime,'<='));
  IF (lv2_calc_method = EcDp_Calc_Method.MEASURED) THEN
    lr_day_rec := ec_pflw_day_status.row_by_pk(p_object_id, p_daytime);
    ln_ret_val := lr_day_rec.avg_water_mass;
  ELSIF (substr(lv2_calc_method,1,9) = EcDp_Calc_Method.USER_EXIT) THEN
    ln_ret_val := Ue_Flowline_Theoretical.findWaterMassDay(p_object_id, p_daytime);
  ELSE  -- undefined
        ln_ret_val := NULL;
  END IF;
  RETURN ln_ret_val;
END findWaterMassDay;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : findCondMassDay
---------------------------------------------------------------------------------------------------
FUNCTION findCondMassDay (p_object_id   flowline.object_id%TYPE,
                          p_daytime     DATE,
                          p_calc_method VARCHAR2 DEFAULT NULL)
RETURN NUMBER
--</EC-DOC>
IS
  lv2_calc_method    VARCHAR2(32);
  ln_ret_val         NUMBER;
  lr_day_rec         PFLW_DAY_STATUS%ROWTYPE;
BEGIN
  lv2_calc_method := Nvl(p_calc_method, ec_flwl_version.FLWL_CALC_MASS_MTD(p_object_id,p_daytime,'<='));
  IF (lv2_calc_method = EcDp_Calc_Method.MEASURED) THEN
    lr_day_rec := ec_pflw_day_status.row_by_pk(p_object_id, p_daytime);
    ln_ret_val := lr_day_rec.avg_cond_mass;
  ELSIF (substr(lv2_calc_method,1,9) = EcDp_Calc_Method.USER_EXIT) THEN
    ln_ret_val := Ue_Flowline_Theoretical.findCondMassDay(p_object_id, p_daytime);
  ELSE  -- undefined
        ln_ret_val := NULL;
  END IF;
  RETURN ln_ret_val;
END findCondMassDay;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : findHCMassDay
---------------------------------------------------------------------------------------------------
FUNCTION findHCMassDay(
   p_object_id   flowline.object_id%TYPE,
   p_daytime     DATE,
   p_calc_method VARCHAR2 DEFAULT NULL)

RETURN NUMBER
--</EC-DOC>
IS
   lr_day_rec      PFLW_DAY_STATUS%ROWTYPE;
   lv2_calc_method VARCHAR2(32);
   lv2_gl_Qstream  VARCHAR2(32);
   ln_gl_dens      NUMBER;
   ln_gl_mass      NUMBER;
   ln_ret_val      NUMBER;

BEGIN
    lv2_calc_method := ec_flwl_version.flwl_calc_mass_mtd(p_object_id, p_daytime, '<=');
    lr_day_rec := ec_pflw_day_status.row_by_pk(p_object_id, p_daytime);

    IF (lv2_calc_method = EcDp_Calc_Method.MPM_NET) THEN
      ln_ret_val := nvl(lr_day_rec.MPM_HC_MASS_RATE, (lr_day_rec.AVG_MPM_GAS_MASS_RATE + (nvl(lr_day_rec.AVG_MPM_OIL_MASS_RATE,lr_day_rec.AVG_MPM_COND_MASS_RATE))));

    ELSIF (lv2_calc_method = EcDp_Calc_Method.MPM) THEN
      ln_ret_val := nvl(lr_day_rec.MPM_HC_MASS_RATE, (lr_day_rec.AVG_MPM_GAS_MASS_RATE + (nvl(lr_day_rec.AVG_MPM_OIL_MASS_RATE,lr_day_rec.AVG_MPM_COND_MASS_RATE))));

      lv2_gl_Qstream := ec_fcty_version.GL_QUALITY_STREAM_ID(ec_flwl_version.op_fcty_class_1_id(p_object_id, p_daytime, '<='),p_daytime,'<=');
      ln_gl_dens     := ecbp_stream_fluid.findStdDens(lv2_gl_Qstream,p_daytime);
      ln_gl_mass     := nvl(ecbp_flowline_theoretical.getGasLiftStdRateDay(p_object_id, p_daytime) * ln_gl_dens,0);
      ln_ret_val     := ln_ret_val - ln_gl_mass;

    ELSIF (lv2_calc_method = EcDp_Calc_Method.SUBWELL) THEN
      ln_ret_val := getSubseaWellMassRateDay(p_object_id,p_daytime, 'HC');

    ELSE  --undefined method
      ln_ret_val := NULL;
    END IF;

   RETURN ln_ret_val;
END findHCMassDay;


--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Function       : getSubseaWellStdRateSubDay
-- Description    : Returns sum of all rated for selected half hour for all conected well          -
--                           --
-- Preconditions  :                                                                                --
-- Postconditions :                                                                                --
--                                                                                                 --
-- Using tables   :                                                                                --
--                                                                                                 --
-- Using functions: EcBp_Well_Theoretical.getOilStdRateSubDay                             --
--                              EcBp_Well_Theoretical.getGasStdRateSubDay                             --
--                              EcBp_Well_Theoretical.getWatStdRateSubDay                             --
--                              EcBp_Well_Theoretical.getCondStdRateSubDay                             --
--                                                                                                 --
-- Configuration                                                                                   --
-- required       :                                                                                --
--                                                                                                 --
-- Behaviour      :                                                                                --
--                                                                                                 --
-----------------------------------------------------------------------------------------------------
FUNCTION getSubseaWellStdRateSubDay(p_object_id      VARCHAR2,
                                    p_daytime        DATE,
                                    p_phase          VARCHAR2) RETURN NUMBER IS

  CURSOR c_subwells IS
  SELECT DISTINCT object_id, well_id
  FROM flowline_sub_well_conn
  WHERE object_id = p_object_id AND
        daytime <= p_daytime AND
        Nvl(end_date, p_daytime + 1 / 48) > p_daytime;

  ln_ret_val      NUMBER;
  ln_phase_rate   NUMBER := 0;
  lv2_calc_method VARCHAR2(32);

BEGIN
  -- Process all sub wells which have been connected during the day
  FOR subwell IN c_subwells LOOP
    IF (c_subwells%ROWCOUNT = 1) THEN
      ln_ret_val := 0;
    END IF;
    If p_Phase = ecdp_phase.OIL THEN
      lv2_calc_method :=ec_well_version.calc_sub_day_method(subwell.well_id, p_daytime, '<=');
      ln_phase_rate := EcBp_Well_Theoretical.getOilStdVolSubDay(subwell.well_id, p_daytime, lv2_calc_method);
    elsif p_phase = ecdp_phase.GAS then
      lv2_calc_method :=ec_well_version.calc_sub_day_gas_method(subwell.well_id, p_daytime, '<=');
      ln_phase_rate := EcBp_Well_Theoretical.getGasStdVolSubDay(subwell.well_id, p_daytime, lv2_calc_method);
    elsif p_phase = ecdp_phase.WATER then
      lv2_calc_method :=ec_well_version.calc_sub_day_water_method(subwell.well_id, p_daytime, '<=');
      ln_phase_rate := EcBp_Well_Theoretical.getWatStdVolSubDay(subwell.well_id, p_daytime, lv2_calc_method);
    elsif p_phase = ecdp_phase.CONDENSATE then
      lv2_calc_method :=ec_well_version.calc_sub_day_cond_method(subwell.well_id, p_daytime, '<=');
      ln_phase_rate := EcBp_Well_Theoretical.getCondStdVolSubDay(subwell.well_id, p_daytime, lv2_calc_method);
    end if;
    ln_ret_val := ln_ret_val + Nvl(ln_phase_rate, 0);
  END LOOP;
  RETURN ln_ret_val;
End getSubseaWellStdRateSubDay;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getOilStdVolSubDay
-- Description    : Returns theoretical oil rate for a prod. flowline during a sub daily time period.
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
-- Using functions: EC_pflw_sub_day_status.ROW_BY_PK
--                  ECBP_FLOWLINE_THEORETICAL.GETCURVERATE
--                  ECBP_FLOWLINE_THEORETICAL.getSubseaWellStdRateSubDay
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
--                  p_calc_method = 'CURVE'
--                  Calculate the volume by using performance curve lookup.
---------------------------------------------------------------------------------------------------
FUNCTION getOilStdVolSubDay(p_object_id   VARCHAR2,
                            p_daytime     DATE,
                            p_calc_method VARCHAR2)

RETURN NUMBER
--</EC-DOC>
IS
  lv2_calc_method   VARCHAR2(32);
  ln_ret_val        NUMBER;
  lr_sub_day_rec    pflw_sub_day_status%ROWTYPE;
  ln_curve_value    NUMBER;
  ln_on_flwl_ratio  NUMBER;
BEGIN
  lv2_calc_method := Nvl(p_calc_method,ec_flwl_version.FLW_CALC_SUB_DAY_OIL_MTD(p_object_id, p_daytime, '<='));
  lr_sub_day_rec := ec_pflw_sub_day_status.row_by_pk(p_object_id, p_daytime);
  IF (lv2_calc_method = EcDp_Calc_Method.CURVE) THEN
    ln_on_flwl_ratio := lr_sub_day_rec.on_stream_hrs / 24;
    IF ln_on_flwl_ratio > 0 THEN -- Only worth doing calculation when the flowline is up
      ln_curve_value := getCurveRate( p_object_id,
                                      EcDp_ProductionDay.getProductionDay('FLOWLINE', p_object_id, p_daytime),
                                      EcDp_Phase.OIL,
                                      EcDp_Curve_Purpose.PRODUCTION,
                                      lr_sub_day_rec.avg_choke_size,
                                      lr_sub_day_rec.avg_flwl_press,
                                      lr_sub_day_rec.avg_flwl_temp,
                                      lr_sub_day_rec.avg_flwl_usc_press,
                                      lr_sub_day_rec.avg_flwl_usc_temp,
                                      lr_sub_day_rec.avg_flwl_dsc_press,
                                      lr_sub_day_rec.avg_flwl_dsc_temp,
                                      lr_sub_day_rec.avg_mpm_oil_rate,
                                      lr_sub_day_rec.avg_mpm_gas_rate,
                                      lr_sub_day_rec.avg_mpm_water_rate,
                                      lr_sub_day_rec.avg_mpm_cond_rate,
                                      NULL,
                                      lv2_calc_method
                                      );
      ln_ret_val := ln_curve_value * ln_on_flwl_ratio;
    ELSIF ln_on_flwl_ratio = 0 THEN
      ln_ret_val := 0;
    ELSE
       ln_ret_val := NULL;
    END IF;
  ELSIF (lv2_calc_method = EcDp_Calc_Method.CURVE_LIQUID) THEN
    ln_on_flwl_ratio := lr_sub_day_rec.on_stream_hrs / 24;
    IF ln_on_flwl_ratio > 0 THEN -- Only worth doing calculation when the flowline is up
      ln_curve_value := getCurveRate( p_object_id,
                                      EcDp_ProductionDay.getProductionDay('FLOWLINE', p_object_id, p_daytime),
                                      EcDp_Phase.LIQUID,
                                      EcDp_Curve_Purpose.PRODUCTION,
                                      lr_sub_day_rec.avg_choke_size,
                                      lr_sub_day_rec.avg_flwl_press,
                                      lr_sub_day_rec.avg_flwl_temp,
                                      lr_sub_day_rec.avg_flwl_usc_press,
                                      lr_sub_day_rec.avg_flwl_usc_temp,
                                      lr_sub_day_rec.avg_flwl_dsc_press,
                                      lr_sub_day_rec.avg_flwl_dsc_temp,
                                      lr_sub_day_rec.avg_mpm_oil_rate,
                                      lr_sub_day_rec.avg_mpm_gas_rate,
                                      lr_sub_day_rec.avg_mpm_water_rate,
                                      lr_sub_day_rec.avg_mpm_cond_rate,
                                      NULL,
                                      lv2_calc_method
                                      );
      ln_ret_val := ln_curve_value * ln_on_flwl_ratio;
    ELSIF ln_on_flwl_ratio = 0 THEN
      ln_ret_val := 0;
    ELSE
       ln_ret_val := NULL;
    END IF;
  ELSIF (lv2_calc_method = EcDp_Calc_method.MPM) THEN
    lr_sub_day_rec := ec_pflw_sub_day_status.row_by_pk(p_object_id, p_daytime);
    ln_ret_val := lr_sub_day_rec.avg_mpm_oil_rate;
  ELSIF lv2_calc_method = EcDp_Calc_Method.SUBSEA_WELLS THEN
    ln_ret_val := getSubseaWellStdRateSubDay(p_object_id, p_daytime, EcDp_Phase.OIL);
  ELSIF (substr(lv2_calc_method,1,9) = EcDp_Calc_Method.USER_EXIT) THEN
    ln_ret_val := Ue_Flowline_Theoretical.getOilStdVolSubDay(p_object_id, p_daytime);
  ELSE
    ln_ret_val := NULL;
  END IF;
  RETURN ln_ret_val;
END getOilStdVolSubDay;


---------------------------------------------------------------------------------------------------
-- Function       : getGasStdVolSubDay
-- Description    : Returns theoretical gas rate for a prod. flowline during a sub daily time period.
--
-- Preconditions  :
-- Postcondition  :
-- Using Tables   :
--
-- Using functions: EC_pflw_sub_day_status.ROW_BY_PK
--                  ECBP_FLOWLINE_THEORETICAL.GETCURVERATE
--                  ECBP_FLOWLINE_THEORETICAL.getSubseaWellStdRateSubDay
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getGasStdVolSubDay(p_object_id    VARCHAR2,
                            p_daytime      DATE,
                            p_calc_method  VARCHAR2)
RETURN NUMBER
--</EC-DOC>
IS
  lv2_calc_method    VARCHAR2(32);
  ln_ret_val         NUMBER;
  lr_sub_day_rec     PFLW_SUB_DAY_STATUS%ROWTYPE;
  ln_curve_value     NUMBER;
  ln_on_flwl_ratio   NUMBER;
  ln_oil_rate        NUMBER;
BEGIN
   lv2_calc_method := Nvl(p_calc_method,ec_flwl_version.FLW_CALC_SUB_DAY_GAS_MTD(p_object_id, p_daytime, '<='));
   lr_sub_day_rec := ec_pflw_sub_day_status.row_by_pk(p_object_id, p_daytime);
   IF (lv2_calc_method = EcDp_Calc_Method.CURVE_GAS) THEN
    ln_on_flwl_ratio := lr_sub_day_rec.on_stream_hrs / 24;
    IF ln_on_flwl_ratio > 0 THEN -- Only worth doing calculation when the flowline is up
      ln_curve_value := getCurveRate(p_object_id,
                                     EcDp_ProductionDay.getProductionDay('FLOWLINE', p_object_id, p_daytime),
                                     EcDp_Phase.GAS,
                                     EcDp_Curve_Purpose.PRODUCTION,
                                     lr_sub_day_rec.avg_choke_size,
                                     lr_sub_day_rec.avg_flwl_press,
                                     lr_sub_day_rec.avg_flwl_temp,
                                     lr_sub_day_rec.avg_flwl_usc_press,
                                     lr_sub_day_rec.avg_flwl_usc_temp,
                                     lr_sub_day_rec.avg_flwl_dsc_press,
                                     lr_sub_day_rec.avg_flwl_dsc_temp,
                                     lr_sub_day_rec.avg_mpm_oil_rate,
                                     lr_sub_day_rec.avg_mpm_gas_rate,
                                     lr_sub_day_rec.avg_mpm_water_rate,
                                     lr_sub_day_rec.avg_mpm_cond_rate,
                                     NULL,
                                     lv2_calc_method
                                    );
      ln_ret_val := ln_curve_value * ln_on_flwl_ratio;
    ELSIF ln_on_flwl_ratio = 0 THEN
      ln_ret_val := 0;
    ELSE
       ln_ret_val := NULL;
    END IF;
  ELSIF (lv2_calc_method = EcDp_Calc_method.MPM) THEN
    lr_sub_day_rec := ec_pflw_sub_day_status.row_by_pk(p_object_id, p_daytime);
    ln_ret_val := lr_sub_day_rec.avg_mpm_gas_rate;
  ELSIF lv2_calc_method = EcDp_Calc_Method.SUBSEA_WELLS THEN
    ln_ret_val := getSubseaWellStdRateSubDay(p_object_id, p_daytime, EcDp_Phase.GAS);
  ELSIF (lv2_calc_method = EcDp_Calc_Method.OIL_GOR) THEN
    ln_oil_rate := getOilStdVolSubDay(p_object_id, p_daytime, NULL);
    IF ln_oil_rate > 0 THEN     -- Only worth getting GOR if Oil is > 0
       ln_ret_val := ln_oil_rate * findGasOilRatio(p_object_id, p_daytime, null, 'PFLW_SUB_DAY_STATUS');
    ELSIF ln_oil_rate = 0 THEN     -- if oil rate = 0, then gas is also zero
       ln_ret_val := 0;
    ELSE
       ln_ret_val := null;
    END IF;
  ELSIF (substr(lv2_calc_method,1,9) = EcDp_Calc_Method.USER_EXIT) THEN
    ln_ret_val := Ue_Flowline_Theoretical.getGasStdVolSubDay(p_object_id, p_daytime);
  ELSE  -- Undefined
    ln_ret_val := NULL;
  END IF;
  RETURN ln_ret_val;
END getGasStdVolSubDay;


---------------------------------------------------------------------------------------------------
-- Function       : getWatStdVolSubDay
-- Description    : Returns theoretical water rate for a prod. flowline during a sub daily time period.
--
-- Preconditions  :
-- Postcondition  :
-- Using Tables   :
--
-- Using functions: EC_pflw_sub_day_status.ROW_BY_PK
--                  ECBP_FLOWLINE_THEORETICAL.GETCURVERATE
--                  ECBP_FLOWLINE_THEORETICAL.getSubseaWellStdRateSubDay
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getWatStdVolSubDay(p_object_id   VARCHAR2,
                            p_daytime     DATE,
                            p_calc_method VARCHAR2)
RETURN NUMBER IS
  lv2_calc_method   VARCHAR2(32);
  ln_ret_val        NUMBER;
  lr_sub_day_rec    PFLW_SUB_DAY_STATUS%ROWTYPE;
  ln_curve_value    NUMBER;
  ln_on_flwl_ratio  NUMBER;
  ln_water_cut      NUMBER;
  ln_oil_rate       NUMBER;
  ln_gas_rate       NUMBER;
BEGIN

  lv2_calc_method := Nvl(p_calc_method, ec_flwl_version.FLW_CALC_SUB_DAY_WATER_MTD(p_object_id, p_daytime, '<='));
  lr_sub_day_rec := ec_pflw_sub_day_status.row_by_pk(p_object_id, p_daytime);
  IF (lv2_calc_method = EcDp_Calc_Method.CURVE_WATER) THEN
    ln_on_flwl_ratio := lr_sub_day_rec.on_stream_hrs / 24;
    IF ln_on_flwl_ratio > 0 THEN -- Only worth doing calculation when the flowline is up
        ln_curve_value := getCurveRate( p_object_id,
                                        EcDp_ProductionDay.getProductionDay('FLOWLINE', p_object_id, p_daytime),
                                        EcDp_Phase.WATER,
                                        EcDp_Curve_Purpose.PRODUCTION,
                                        lr_sub_day_rec.avg_choke_size,
                                        lr_sub_day_rec.avg_flwl_press,
                                        lr_sub_day_rec.avg_flwl_temp,
                                        lr_sub_day_rec.avg_flwl_usc_press,
                                        lr_sub_day_rec.avg_flwl_usc_temp,
                                        lr_sub_day_rec.avg_flwl_dsc_press,
                                        lr_sub_day_rec.avg_flwl_dsc_temp,
                                        lr_sub_day_rec.avg_mpm_oil_rate,
                                        lr_sub_day_rec.avg_mpm_gas_rate,
                                        lr_sub_day_rec.avg_mpm_water_rate,
                                        lr_sub_day_rec.avg_mpm_cond_rate,
                                        NULL,
                                        lv2_calc_method
                                       );
        ln_ret_val := ln_curve_value * ln_on_flwl_ratio;
    ELSIF ln_on_flwl_ratio = 0 THEN
      ln_ret_val := 0;
    ELSE
       ln_ret_val := NULL;
    END IF;
  ELSIF (lv2_calc_method = EcDp_Calc_method.MPM) THEN
    lr_sub_day_rec := ec_pflw_sub_day_status.row_by_pk(p_object_id, p_daytime);
    ln_ret_val := lr_sub_day_rec.avg_mpm_water_rate;
  ELSIF lv2_calc_method = EcDp_Calc_Method.SUBSEA_WELLS THEN
    ln_ret_val := getSubseaWellStdRateSubDay(p_object_id, p_daytime, EcDp_Phase.WATER);
  ELSIF (lv2_calc_method = EcDp_Calc_Method.OIL_WATER_CUT) THEN
    ln_water_cut := findWaterCutPct(p_object_id, p_daytime, ec_flwl_version.FLWL_BSW_VOL_MTD(p_object_id, p_daytime, '<='), 'PFLW_SUB_DAY_STATUS')/100;
    ln_oil_rate := getOilStdVolSubDay(p_object_id, p_daytime, ec_flwl_version.FLW_CALC_SUB_DAY_OIL_MTD(p_object_id, p_daytime, '<='));
    IF ln_oil_rate > 0 THEN
      IF (1 - ln_water_cut) <> 0 THEN
        ln_ret_val := (ln_oil_rate/(1 - ln_water_cut)) * ln_water_cut;
      ELSE   -- div by zero
        ln_ret_val := null;
      END IF;
    ELSIF ln_oil_rate = 0 THEN   -- if oil is zero, then also water is zero
      ln_ret_val := 0;
    ELSE
      ln_ret_val := null;
    END IF;
  ELSIF (lv2_calc_method = EcDp_Calc_Method.LIQ_WATER_CUT) THEN
    ln_water_cut := findWaterCutPct(p_object_id, p_daytime, ec_flwl_version.FLWL_BSW_VOL_MTD(p_object_id, p_daytime, '<='), 'PFLW_SUB_DAY_STATUS')/100;
    ln_oil_rate := getOilStdVolSubDay(p_object_id, p_daytime, ec_flwl_version.FLW_CALC_SUB_DAY_OIL_MTD(p_object_id, p_daytime, '<='));
    IF ln_oil_rate > 0 THEN
      IF (1 - ln_water_cut) <> 0 THEN
        ln_ret_val := (ln_oil_rate / (1 - ln_water_cut)) * ln_water_cut;
      ELSE   -- div by zero
        ln_ret_val := null;
      END IF;
    ELSIF ln_oil_rate = 0 THEN   -- if oil is zero, then also water is zero
      ln_ret_val := 0;
    ELSE
      ln_ret_val := null;
    END IF;
  ELSIF (lv2_calc_method = EcDp_Calc_Method.GAS_WGR) THEN
    ln_gas_rate := getGasStdVolSubDay(p_object_id, p_daytime, ec_flwl_version.FLW_CALC_SUB_DAY_GAS_MTD(p_object_id, p_daytime, '<='));
    IF ln_gas_rate > 0 THEN   -- Only worth getting WGR if Gas is > 0
      ln_ret_val := ln_gas_rate * findWaterGasRatio(p_object_id, p_daytime, ec_flwl_version.FLWL_WGR_MTD(p_object_id, p_daytime, '<='), 'PFLW_SUB_DAY_STATUS');
    ELSIF ln_gas_rate = 0 THEN   -- if oil rate = 0, then water is also zero
      ln_ret_val := 0;
    ELSE
      ln_ret_val := NULL;
    END IF;
  ELSIF (substr(lv2_calc_method,1,9) = EcDp_Calc_Method.USER_EXIT) THEN
    ln_ret_val := Ue_Flowline_Theoretical.getWatStdVolSubDay(p_object_id, p_daytime);
  ELSE  -- undefined
    ln_ret_val := NULL;
  END IF;
  RETURN  ln_ret_val;
END getWatStdVolSubDay;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getCondStdVolSubDay
-- Description    : Returns theoretical condensate rate for a flowline gas producer during a given
--                  sub daily period.
--
-- Preconditions  :
-- Postcondition  :
-- Using Tables   :
--
-- Using functions: EC_pflw_sub_day_status.ROW_BY_PK
--                  ECBP_FLOWLINE_THEORETICAL.GETCURVERATE
--                  ECBP_FLOWLINE_THEORETICAL.getSubseaWellStdRateSubDay
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getCondStdVolSubDay(p_object_id    VARCHAR2,
                             p_daytime      DATE,
                             p_calc_method  VARCHAR2)

RETURN NUMBER
--</EC-DOC>
IS
  lv2_calc_method   VARCHAR2(32);
  ln_ret_val        NUMBER;
  lr_sub_day_rec    pflw_sub_day_status%ROWTYPE;
  ln_curve_value    NUMBER;
  ln_on_flwl_ratio  NUMBER;
BEGIN
  lv2_calc_method := Nvl(p_calc_method,ec_flwl_version.flw_calc_sub_day_cond_mtd(p_object_id, p_daytime, '<='));
  lr_sub_day_rec := ec_pflw_sub_day_status.row_by_pk(p_object_id, p_daytime);
  IF (lv2_calc_method = EcDp_Calc_Method.CURVE) THEN
    ln_on_flwl_ratio := lr_sub_day_rec.on_stream_hrs / 24;
    IF ln_on_flwl_ratio > 0 THEN -- Only worth doing calculation when the flowline is up
      ln_curve_value := getCurveRate( p_object_id,
                                      EcDp_ProductionDay.getProductionDay('FLOWLINE', p_object_id, p_daytime),
                                      EcDp_Phase.CONDENSATE,
                                      EcDp_Curve_Purpose.PRODUCTION,
                                      lr_sub_day_rec.avg_choke_size,
                                      lr_sub_day_rec.avg_flwl_press,
                                      lr_sub_day_rec.avg_flwl_temp,
                                      lr_sub_day_rec.avg_flwl_usc_press,
                                      lr_sub_day_rec.avg_flwl_usc_temp,
                                      lr_sub_day_rec.avg_flwl_dsc_press,
                                      lr_sub_day_rec.avg_flwl_dsc_temp,
                                      lr_sub_day_rec.avg_mpm_oil_rate,
                                      lr_sub_day_rec.avg_mpm_gas_rate,
                                      lr_sub_day_rec.avg_mpm_water_rate,
                                      lr_sub_day_rec.avg_mpm_cond_rate,
                                      NULL,
                                      lv2_calc_method
                                     );
        ln_ret_val := ln_curve_value * ln_on_flwl_ratio;
    ELSIF ln_on_flwl_ratio = 0 THEN
      ln_ret_val := 0;
    ELSE
       ln_ret_val := NULL;
    END IF;
  ELSIF (lv2_calc_method = EcDp_Calc_Method.CURVE_LIQUID) THEN
    ln_on_flwl_ratio := lr_sub_day_rec.on_stream_hrs / 24;
    IF ln_on_flwl_ratio > 0 THEN -- Only worth doing calculation when the flowline is up
      ln_curve_value := getCurveRate( p_object_id,
                                      EcDp_ProductionDay.getProductionDay('FLOWLINE', p_object_id, p_daytime),
                                      EcDp_Phase.CONDENSATE,
                                      EcDp_Curve_Purpose.PRODUCTION,
                                      lr_sub_day_rec.avg_choke_size,
                                      lr_sub_day_rec.avg_flwl_press,
                                      lr_sub_day_rec.avg_flwl_temp,
                                      lr_sub_day_rec.avg_flwl_usc_press,
                                      lr_sub_day_rec.avg_flwl_usc_temp,
                                      lr_sub_day_rec.avg_flwl_dsc_press,
                                      lr_sub_day_rec.avg_flwl_dsc_temp,
                                      lr_sub_day_rec.avg_mpm_oil_rate,
                                      lr_sub_day_rec.avg_mpm_gas_rate,
                                      lr_sub_day_rec.avg_mpm_water_rate,
                                      lr_sub_day_rec.avg_mpm_cond_rate,
                                      NULL,
                                      lv2_calc_method
                                     );
        ln_ret_val := ln_curve_value * ln_on_flwl_ratio;
    ELSIF ln_on_flwl_ratio = 0 THEN
      ln_ret_val := 0;
    ELSE
       ln_ret_val := NULL;
    END IF;
  ELSIF (lv2_calc_method = EcDp_Calc_method.MPM) THEN
    lr_sub_day_rec := ec_pflw_sub_day_status.row_by_pk(p_object_id, p_daytime);
    ln_ret_val := lr_sub_day_rec.avg_mpm_cond_rate;
  ELSIF lv2_calc_method = EcDp_Calc_Method.SUBSEA_WELLS THEN
    ln_ret_val := getSubseaWellStdRateSubDay(p_object_id, p_daytime, EcDp_Phase.CONDENSATE);
  ELSIF (lv2_calc_method = EcDp_Calc_Method.GAS_CGR) THEN
    ln_ret_val := getGasStdVolSubDay(p_object_id, p_daytime, NULL) * findCondGasRatio(p_object_id, p_daytime, NULL,'PFLW_SUB_DAY_STATUS');
  ELSIF (substr(lv2_calc_method,1,9) = EcDp_Calc_Method.USER_EXIT) THEN
    ln_ret_val := Ue_Flowline_Theoretical.getCondStdVolSubDay(p_object_id, p_daytime);
  ELSE  -- undefined
    ln_ret_val := NULL;
  END IF;
  RETURN ln_ret_val;
END getCondStdVolSubDay;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : findWaterCutPct
-- Description    : Returns BSW volume for flowline on a given day at standard conditions, source method specified
---------------------------------------------------------------------------------------------------
FUNCTION findWaterCutPct( p_object_id     VARCHAR2,
                          p_daytime       DATE,
                          p_calc_method   VARCHAR2 DEFAULT NULL,
                          p_class_name    VARCHAR2 DEFAULT NULL,
                          p_result_no     NUMBER DEFAULT NULL)

RETURN NUMBER
--</EC-DOC>
IS
  lv2_calc_method         VARCHAR2(32);
  lr_flwl_version         flwl_version%ROWTYPE;
  ln_ret_val              NUMBER;
  ld_start_daytime      DATE;
  ln_prod_day_offset    NUMBER;

BEGIN
  lr_flwl_version := ec_flwl_version.row_by_pk(p_object_id, p_daytime, '<=');
  lv2_calc_method := Nvl(p_calc_method, lr_flwl_version.FLWL_BSW_VOL_MTD);
  IF (lv2_calc_method = EcDp_Calc_Method.CURVE) THEN
     IF p_class_name = 'PFLW_DAY_STATUS' THEN
          ln_prod_day_offset := EcDp_ProductionDay.getProductionDayOffset('FLOWLINE',p_object_id,p_daytime)/24;
          ld_start_daytime := p_daytime + ln_prod_day_offset;
        ELSIF p_class_name = 'PFLW_SUB_DAY_STATUS' THEN
          ld_start_daytime := p_daytime;
        ELSE
          ln_prod_day_offset := EcDp_ProductionDay.getProductionDayOffset('FLOWLINE',p_object_id,p_daytime)/24;
          ld_start_daytime := p_daytime + ln_prod_day_offset;
        END IF ;
     ln_ret_val := EcDp_Flowline_Theoretical.getWaterCutPct(p_object_id, ld_start_daytime, EcDp_Phase.OIL, EcDp_Calc_Method.CURVE,p_class_name,p_result_no);

  ELSIF (lv2_calc_method = EcDp_Calc_Method.CURVE_LIQUID) THEN
       IF p_class_name = 'PFLW_DAY_STATUS' THEN
          ln_prod_day_offset := EcDp_ProductionDay.getProductionDayOffset('FLOWLINE',p_object_id,p_daytime)/24;
          ld_start_daytime := p_daytime + ln_prod_day_offset;
        ELSIF p_class_name = 'PFLW_SUB_DAY_STATUS' THEN
          ld_start_daytime := p_daytime;
        ELSE
          ln_prod_day_offset := EcDp_ProductionDay.getProductionDayOffset('FLOWLINE',p_object_id,p_daytime)/24;
          ld_start_daytime := p_daytime + ln_prod_day_offset;
        END IF ;
     ln_ret_val := EcDp_Flowline_Theoretical.getWaterCutPct(p_object_id, ld_start_daytime, EcDp_Phase.LIQUID, EcDp_Calc_Method.CURVE_LIQUID, p_class_name, p_result_no);

  ELSIF (substr(lv2_calc_method,1,9) = EcDp_Calc_Method.USER_EXIT) THEN
    ln_ret_val := Ue_Flowline_Theoretical.findWaterCutPct(p_object_id,p_daytime);
  END IF;
  RETURN ln_ret_val;
END findWaterCutPct;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : findCondGasRatio
-- Description    : Returns Condensate Gas Ratio for flowline on a given day at standard conditions, source method specified
---------------------------------------------------------------------------------------------------
FUNCTION findCondGasRatio(p_object_id    VARCHAR2,
                          p_daytime      DATE,
                          p_calc_method  VARCHAR2 DEFAULT NULL,
                          p_class_name VARCHAR2 DEFAULT NULL)
RETURN NUMBER
--</EC-DOC>
IS
  lv2_calc_method       VARCHAR2(32);
  lr_flwl_version       flwl_version%ROWTYPE;
  ln_ret_val            NUMBER;
  ln_prod_day_offset    NUMBER;
  ld_start_daytime      DATE;
BEGIN
  lr_flwl_version := ec_flwl_version.row_by_pk(p_object_id, p_daytime, '<=');
  lv2_calc_method := Nvl(p_calc_method, lr_flwl_version.FLWL_CGR_MTD);
  IF (lv2_calc_method = EcDp_Calc_Method.CURVE_GAS) THEN
           IF p_class_name = 'PFLW_DAY_STATUS' THEN
          ln_prod_day_offset := EcDp_ProductionDay.getProductionDayOffset('FLOWLINE',p_object_id,p_daytime)/24;
          ld_start_daytime := p_daytime + ln_prod_day_offset;
        ELSIF p_class_name = 'PFLW_SUB_DAY_STATUS' THEN
          ld_start_daytime := p_daytime;
        ELSE
          ln_prod_day_offset := EcDp_ProductionDay.getProductionDayOffset('FLOWLINE',p_object_id,p_daytime)/24;
          ld_start_daytime := p_daytime + ln_prod_day_offset;
        END IF ;
    ln_ret_val := EcDp_Flowline_Theoretical.getCondensateGasRatio(p_object_id, ld_start_daytime, EcDp_Phase.GAS, EcDp_Calc_Method.CURVE_GAS,p_class_name);
  ELSIF (substr(lv2_calc_method,1,9) = EcDp_Calc_Method.USER_EXIT) THEN
    ln_ret_val := Ue_Flowline_Theoretical.findCondGasRatio(p_object_id,p_daytime);
  ELSE  -- undefined
    ln_ret_val := NULL;
  END IF;
  RETURN ln_ret_val;
END findCondGasRatio;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : findGasOilRatio
-- Description    : Returns Gas Oil Ratio for flowline on a given day at standard conditions, source method specified
---------------------------------------------------------------------------------------------------
FUNCTION findGasOilRatio(p_object_id    VARCHAR2,
                         p_daytime      DATE,
                         p_calc_method  VARCHAR2 DEFAULT NULL,
                         p_class_name   VARCHAR2 DEFAULT NULL)

RETURN NUMBER
--</EC-DOC>
IS
  lv2_calc_method    VARCHAR2(32);
  lr_flwl_version       flwl_version%ROWTYPE;
  ln_ret_val            NUMBER;
  ln_prod_day_offset    NUMBER;
  ld_start_daytime      DATE;
BEGIN
  lr_flwl_version := ec_flwl_version.row_by_pk(p_object_id, p_daytime, '<=');
  lv2_calc_method := Nvl(p_calc_method, lr_flwl_version.FLWL_GOR_MTD);
  IF (lv2_calc_method = EcDp_Calc_Method.CURVE) THEN
        IF p_class_name = 'PFLW_DAY_STATUS' THEN
            ln_prod_day_offset := EcDp_ProductionDay.getProductionDayOffset('FLOWLINE',p_object_id,p_daytime)/24;
            ld_start_daytime := p_daytime + ln_prod_day_offset;
        ELSIF p_class_name = 'PFLW_SUB_DAY_STATUS' THEN
            ld_start_daytime := p_daytime;
        ELSE
            ln_prod_day_offset := EcDp_ProductionDay.getProductionDayOffset('FLOWLINE',p_object_id,p_daytime)/24;
            ld_start_daytime := p_daytime + ln_prod_day_offset;
        END IF ;
      ln_ret_val := EcDp_Flowline_Theoretical.getGasOilRatio(p_object_id, ld_start_daytime, EcDp_Phase.OIL, EcDp_Calc_Method.CURVE,p_class_name);
  ELSIF (lv2_calc_method = EcDp_Calc_Method.CURVE_LIQUID) THEN
        IF p_class_name = 'PFLW_DAY_STATUS' THEN
          ln_prod_day_offset := EcDp_ProductionDay.getProductionDayOffset('FLOWLINE',p_object_id,p_daytime)/24;
          ld_start_daytime := p_daytime + ln_prod_day_offset;
        ELSIF p_class_name = 'PFLW_SUB_DAY_STATUS' THEN
          ld_start_daytime := p_daytime;
        ELSE
          ln_prod_day_offset := EcDp_ProductionDay.getProductionDayOffset('FLOWLINE',p_object_id,p_daytime)/24;
          ld_start_daytime := p_daytime + ln_prod_day_offset;
        END IF ;
      ln_ret_val := EcDp_Flowline_Theoretical.getGasOilRatio(p_object_id, ld_start_daytime, EcDp_Phase.LIQUID, EcDp_Calc_Method.CURVE_LIQUID,p_class_name);

  ELSIF (substr(lv2_calc_method,1,9) = EcDp_Calc_Method.USER_EXIT) THEN
    ln_ret_val := Ue_Flowline_Theoretical.findGasOilRatio(p_object_id,p_daytime);
  ELSE  -- undefined
    ln_ret_val := NULL;
  END IF;
  RETURN ln_ret_val;
END findGasOilRatio;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : findGasWaterRatio
-- Description    : Returns Gas Water Ratio for flowline on a given day at standard conditions, source method specified
---------------------------------------------------------------------------------------------------
FUNCTION findWaterGasRatio( p_object_id    VARCHAR2,
                            p_daytime      DATE,
                            p_calc_method  VARCHAR2 DEFAULT NULL,
                            p_class_name   VARCHAR2 DEFAULT NULL)
RETURN NUMBER
--</EC-DOC>
IS
  lv2_calc_method       VARCHAR2(32);
  lr_flwl_version       FLWL_VERSION%ROWTYPE;
  ln_ret_val            NUMBER;
  ln_prod_day_offset    NUMBER;
  ld_start_daytime      DATE;
BEGIN
  lr_flwl_version := ec_flwl_version.row_by_pk(p_object_id, p_daytime, '<=');
  lv2_calc_method := Nvl(p_calc_method, lr_flwl_version.flwl_wgr_mtd);
  IF (lv2_calc_method = EcDp_Calc_Method.CURVE_GAS) THEN
          IF p_class_name = 'PFLW_DAY_STATUS' THEN
          ln_prod_day_offset := EcDp_ProductionDay.getProductionDayOffset('FLOWLINE',p_object_id,p_daytime)/24;
          ld_start_daytime := p_daytime + ln_prod_day_offset;
        ELSIF p_class_name = 'PFLW_SUB_DAY_STATUS' THEN
          ld_start_daytime := p_daytime;
        ELSE
          ln_prod_day_offset := EcDp_ProductionDay.getProductionDayOffset('FLOWLINE',p_object_id,p_daytime)/24;
          ld_start_daytime := p_daytime + ln_prod_day_offset;
        END IF ;
      ln_ret_val := EcDp_Flowline_Theoretical.getWaterGasRatio(p_object_id, ld_start_daytime, EcDp_Phase.GAS, EcDp_Calc_Method.CURVE_GAS,p_class_name);

  ELSIF (substr(lv2_calc_method,1,9) = EcDp_Calc_Method.USER_EXIT) THEN
    ln_ret_val := Ue_Flowline_Theoretical.findWaterGasRatio(p_object_id,p_daytime);
  ELSE  -- undefined
    ln_ret_val := NULL;
  END IF;
  RETURN ln_ret_val;
END findWaterGasRatio;



--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : findWetDryFactor
-- Description    : Returns Wet Dry Factor Ratio for flowline on a given day at standard conditions, source method specified
---------------------------------------------------------------------------------------------------
FUNCTION findWetDryFactor(p_object_id    VARCHAR2,
                          p_daytime      DATE,
                          p_calc_method  VARCHAR2 DEFAULT NULL)
RETURN NUMBER
--</EC-DOC>
IS
  lv2_calc_method       VARCHAR2(32);
  ln_ret_val            NUMBER;
BEGIN
  lv2_calc_method := Nvl(p_calc_method, ec_flwl_version.FLWL_WDF_MTD(p_object_id,p_daytime,'<='));
  IF (substr(lv2_calc_method,1,9) = EcDp_Calc_Method.USER_EXIT) THEN
    ln_ret_val := Ue_Flowline_Theoretical.findWetDryFactor(p_object_id,p_daytime);
  ELSE  -- undefined
    ln_ret_val := NULL;
  END IF;
  RETURN ln_ret_val;
END findWetDryFactor;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getAllocCondVolDay
-- Description    : Get the allocated condensate data from well.
--
-- Preconditions  :
--
-- Postconditions :
-- Using tables   :
--
-- Using functions: ec_pwel_day_alloc.alloc_cond_vol
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getAllocCondVolDay(
 	p_flowline_id  FLOWLINE.OBJECT_ID%TYPE,
 	p_daytime DATE)
 	return NUMBER
--</EC-DOC>
 IS
 ln_returnval NUMBER;
  BEGIN
  	FOR v_conn_well_cursor IN c_conn_well_cursor(p_flowline_id, p_daytime) LOOP
  		ln_returnval := Nvl(ln_returnval,0) + Nvl(ec_pwel_day_alloc.alloc_cond_vol( v_conn_well_cursor.well_object_id,p_daytime), 0);
  	END LOOP;

   RETURN ln_returnval;

END getAllocCondVolDay;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getAllocGasVolDay
-- Description    : Get the allocated gas data from well.
--
-- Preconditions  :
--
-- Postconditions :
-- Using tables   :
--
-- Using functions: ec_pwel_day_alloc.alloc_gas_vol
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
 FUNCTION getAllocGasVolDay(
 	p_flowline_id  FLOWLINE.OBJECT_ID%TYPE,
 	p_daytime DATE)
 	return NUMBER
--</EC-DOC>
 IS
 ln_returnval NUMBER;
  BEGIN
  	FOR v_conn_well_cursor IN c_conn_well_cursor(p_flowline_id, p_daytime) LOOP
  		ln_returnval := Nvl(ln_returnval,0) + Nvl(ec_pwel_day_alloc.alloc_gas_vol( v_conn_well_cursor.well_object_id,p_daytime), 0);
  	END LOOP;

   RETURN ln_returnval;

  end getAllocGasVolDay;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getAllocOilVolDay
-- Description    : Get the allocated oil data from well.
--
-- Preconditions  :
--
-- Postconditions :
-- Using tables   :
--
-- Using functions: ec_pwel_day_alloc.alloc_net_oil_vol
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getAllocOilVolDay(
 	p_flowline_id  FLOWLINE.OBJECT_ID%TYPE,
 	p_daytime DATE)
 	return NUMBER
--</EC-DOC>
 IS
 ln_returnval NUMBER;
  BEGIN
  	FOR v_conn_well_cursor IN c_conn_well_cursor(p_flowline_id, p_daytime) LOOP
  		ln_returnval := Nvl(ln_returnval,0) + Nvl(ec_pwel_day_alloc.alloc_net_oil_vol( v_conn_well_cursor.well_object_id,p_daytime), 0);
  	END LOOP;

   RETURN ln_returnval;

END getAllocOilVolDay;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getAllocWaterVolDay
-- Description    : Get the allocated water data from well.
--
-- Preconditions  :
--
-- Postconditions :
-- Using tables   :
--
-- Using functions: ec_pwel_day_alloc.alloc_water_vol
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------

FUNCTION getAllocWaterVolDay(
 	p_flowline_id  FLOWLINE.OBJECT_ID%TYPE,
 	p_daytime DATE)
 	return NUMBER
--</EC-DOC>
 IS
 ln_returnval NUMBER;
  BEGIN
  	FOR v_conn_well_cursor IN c_conn_well_cursor(p_flowline_id, p_daytime) LOOP
  		ln_returnval := Nvl(ln_returnval,0) + Nvl(ec_pwel_day_alloc.alloc_water_vol( v_conn_well_cursor.well_object_id,p_daytime), 0);
  	END LOOP;

  RETURN ln_returnval;
  END getAllocWaterVolDay;


---------------------------------------------------------------------------------------------------
-- Function       : getSubseaWellStdRateDay
-- Description    : Returns theoretical flowline rate
---------------------------------------------------------------------------------------------------
FUNCTION getSubseaWellMassRateDay(
   p_object_id   flowline.object_id%TYPE,
   p_daytime     DATE,
   p_phase       VARCHAR2)
RETURN NUMBER
--</EC-DOC>
IS
  /* Select all open producing wells which have been connected to a flowline during the production day period.  */
  CURSOR c_subwells IS
    SELECT DISTINCT object_id, well_id
    FROM flowline_sub_well_conn
    WHERE object_id = p_object_id
    AND daytime < p_daytime + 1
    AND Nvl(end_date, p_daytime + 1) > p_daytime;

  ln_ret_val    NUMBER;
  ln_phase_rate NUMBER := 0;
  lv2_calc_method VARCHAR2(32);

BEGIN

   FOR subwell IN c_subwells LOOP
      IF (c_subwells%ROWCOUNT = 1) THEN
        ln_ret_val := 0;
      END IF;

      lv2_calc_method := ec_well_version.calc_method_mass(p_object_id, p_daytime, '<=');

      IF p_phase = ecdp_phase.HC THEN
        ln_phase_rate := EcBp_Well_Theoretical.findHCMassDay(subwell.well_id,
                                                           p_daytime);
      ELSIF p_phase = ecdp_phase.OIL THEN
        ln_phase_rate := EcBp_Well_Theoretical.findOilMassDay(subwell.well_id,
                                                                   p_daytime,
                                                                   lv2_calc_method);
      ELSIF p_phase = ecdp_phase.GAS then
        ln_phase_rate := EcBp_Well_Theoretical.findGasMassDay(subwell.well_id,
                                                                   p_daytime,
                                                                   lv2_calc_method);
      ELSIF p_phase = ecdp_phase.WATER then
        ln_phase_rate := EcBp_Well_Theoretical.findWaterMassDay(subwell.well_id,
                                                                   p_daytime,
                                                                   lv2_calc_method);

      ELSIF p_phase = ecdp_phase.CONDENSATE then
        ln_phase_rate := EcBp_Well_Theoretical.findCondMassDay(subwell.well_id,
                                                                   p_daytime,
                                                                   lv2_calc_method);
      END IF;

	  ln_ret_val := ln_ret_val + Nvl(ln_phase_rate, 0);

   END LOOP;

   RETURN ln_ret_val;

END getSubseaWellMassRateDay;

END EcBp_Flowline_Theoretical;