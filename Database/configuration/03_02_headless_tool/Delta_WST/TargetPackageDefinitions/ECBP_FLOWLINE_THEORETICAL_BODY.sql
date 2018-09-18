CREATE OR REPLACE PACKAGE BODY EcBp_Flowline_Theoretical IS
/****************************************************************
** Package        :  EcBp_Flowline_Theoretical, body part
**
** $Revision: 1.8.2.6 $
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
**          09.05.2012  limmmchu  ECPD-20889: Fixed bug in referencing wrong method variables.
**          09.05.2012  limmmchu  ECPD-20889: Modified getInjectedStdRateDay, flwl_oil_calc_inj_mtd to flwl_gas_calc_inj_mtd
**          13.03.2013  limmmchu  ECPD-23570: Updated getSubseaWellStdRateDay to use the correct calc method.
**          29.04.2013  wonggkai  ECPD-24185: getSubseaWellStdRateDay, getGasLiftStdRateDay to support gaslift.
*****************************************************************/


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
                      p_flwl_usc_temp   NUMBER,
                      p_flwl_usc_press  NUMBER,
                      p_flwl_dsc_press  NUMBER,
                      p_flwl_dsc_temp   NUMBER,
                      p_mpm_oil_rate    NUMBER,
                      p_mpm_gas_rate    NUMBER,
                      p_mpm_water_rate  NUMBER,
                      p_mpm_cond_rate   NUMBER,
--                      p_gl_rate         NUMBER,
                      p_pressure_zone   VARCHAR2 DEFAULT 'NORMAL')
RETURN NUMBER
--</EC-DOC>
IS
   lr_params EcDp_Flowline_Theoretical.PerfCurveParamRec;
BEGIN
   -- We should ideally just get rid of this function altogether and have every function that currently
   -- uses this to use the new getCurveStdRate instead

   IF NVL(p_pressure_zone,'NORMAL')!='NORMAL' THEN
      RAISE_APPLICATION_ERROR(-20000,'Only NORMAL pressure zone is supported in performance curve calculations');
      RETURN NULL;
   END IF;
   lr_params.avg_choke_size     := p_choke_size;
   lr_params.avg_flwl_press     := p_flwl_press;
   lr_params.avg_flwl_temp      := p_flwl_temp;
   lr_params.avg_flwl_usc_press := p_flwl_usc_press;
   lr_params.avg_flwl_usc_temp  := p_flwl_usc_temp;
   lr_params.avg_flwl_dsc_press := p_flwl_dsc_press;
   lr_params.avg_flwl_dsc_temp  := p_flwl_dsc_temp;
   lr_params.avg_mpm_oil_rate   := p_mpm_oil_rate;
   lr_params.avg_mpm_gas_rate   := p_mpm_gas_rate;
   lr_params.avg_mpm_water_rate := p_mpm_water_rate;
   lr_params.avg_mpm_cond_rate  := p_mpm_cond_rate;
---   lr_params.gl_rate            := p_gl_rate;
   RETURN EcDp_Flowline_Theoretical.getCurveStdRate(p_object_id,
                                                    p_daytime,
                                                    p_curve_purpose,
                                                    p_phase,
                                                    lr_params);
END getCurveRate;


  --<EC-DOC>
  -----------------------------------------------------------------------------------------------------
  -- Function       : getSubseaWellStdRateDay                                                  --
  -- Description    : Calculates theoretical rate for a flowline by summarizing the theoretical      --
  --                  values for each subsea well connected.                                         --
  --                           --
  -- Preconditions  :                                                                                --
  -- Postconditions :                                                                                --
  --                                                                                                 --
  -- Using tables   : flowline_sub_well_conn                                                         --
  --                                                                                                 --
  -- Using functions: EcBp_Well_Theoretical.getOilStdRateDay                             --
  --                              EcBp_Well_Theoretical.getGasStdRateDay                             --
  --                              EcBp_Well_Theoretical.getWatStdRateDay                             --
  --                              EcBp_Well_Theoretical.getCondStdRateDay                             --
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
        ln_phase_rate := EcBp_Well_Theoretical.getOilStdRateDay(subwell.well_id,
                                                                   p_daytime,
                                                                   lv2_calc_method);
      elsif p_phase = ecdp_phase.GAS then
        lv2_calc_method :=ec_well_version.calc_gas_method(subwell.well_id, p_daytime, '<=');
        ln_phase_rate := EcBp_Well_Theoretical.getGasStdRateDay(subwell.well_id,
                                                                   p_daytime,
                                                                   lv2_calc_method);

      elsif p_phase = ecdp_phase.WATER then
        lv2_calc_method :=ec_well_version.calc_water_method(subwell.well_id, p_daytime, '<=');
        ln_phase_rate := EcBp_Well_Theoretical.getWatStdRateDay(subwell.well_id,
                                                                   p_daytime,
                                                                   lv2_calc_method);

      elsif p_phase = ecdp_phase.CONDENSATE then
        lv2_calc_method :=ec_well_version.calc_cond_method(subwell.well_id, p_daytime, '<=');
        ln_phase_rate := EcBp_Well_Theoretical.getCondStdRateDay(subwell.well_id,
                                                                   p_daytime,
                                                                   lv2_calc_method);
      elsif p_phase = ecdp_phase.GAS_LIFT then
        lv2_calc_method :=ec_well_version.gas_lift_method(subwell.well_id, p_daytime, '<=');
        ln_phase_rate := EcBp_Well_Theoretical.getGasLiftStdRateDay(subwell.well_id,
                                                                   p_daytime,
                                                                   lv2_calc_method);
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
                          p_calc_method VARCHAR2 DEFAULT NULL)/* ,
						      p_decline_flag VARCHAR2 DEFAULT NULL)*/
RETURN NUMBER
--</EC-DOC>
IS
   lv2_calc_method            VARCHAR2(32);
   lr_day_rec                 PFLW_DAY_STATUS%ROWTYPE;
   lr_flwl_version            FLWL_VERSION%ROWTYPE;

   ln_curve_value             NUMBER;
   ln_on_flwl_ratio           NUMBER;
   ln_ret_val                 NUMBER;

/*    lv2_def_version            VARCHAR2(32);
   lv2_decline_flag           VARCHAR2(1);
   lr_well_event_row          WELL_EVENT%ROWTYPE;
   lr_well_ref_value          WELL_REFERENCE_VALUE%ROWTYPE;
   lr_pflw_result             PFLW_RESULT%ROWTYPE;
   ln_diluent_rate            NUMBER;
   ln_pump_speed_ratio        NUMBER;
   ln_test_pump_speed         NUMBER;
   ln_on_flwl_ratio           NUMBER;
   ln_prev_test_no            NUMBER;
   ln_vol_rate                NUMBER;
   ln_prod_day_offset         NUMBER;
   lb_first                   BOOLEAN;
   ld_end_daytime             DATE;
   ld_start_daytime           DATE;
   ld_eff_daytime             DATE;
   ld_next_eff_daytime        DATE;
   ld_prev_estimate           DATE;
   ld_next_estimate           DATE;
   ld_prev_test               DATE;
   ld_next_test               DATE;
   ld_from_date               DATE;
   ld_prod_day                DATE; */


BEGIN
-- oil_calc_method
   lr_flwl_version :=ec_flwl_version.row_by_pk(p_object_id, p_daytime, '<=');
   lv2_calc_method := Nvl(p_calc_method, lr_flwl_version.flw_calc_oil_mtd);


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
                                        lr_day_rec.avg_mpm_cond_rate
                                        );

         ln_ret_val := ln_curve_value * ln_on_flwl_ratio;

      ELSE
         ln_ret_val := ln_on_flwl_ratio;
      END IF;


   ELSIF (lv2_calc_method = EcDp_Calc_method.MPM) THEN
      lr_day_rec := ec_pflw_day_status.row_by_pk(p_object_id, p_daytime);
      ln_ret_val := lr_day_rec.avg_mpm_oil_rate;


   ELSIF lv2_calc_method = EcDp_Calc_Method.SUBSEA_WELLS THEN

      ln_ret_val := getSubseaWellStdRateDay(p_object_id,
                                            p_daytime,
                                            EcDp_Phase.OIL);


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

   lv2_gas_lift_method := NVL(p_gas_lift_method,
                              ec_flwl_version.flwl_calc_gas_lift_mtd(p_object_id,
                              p_daytime,
                              '<='));

   IF (lv2_gas_lift_method = EcDp_Calc_Method.CURVE) THEN

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
                                        lr_day_rec.avg_mpm_cond_rate
                                        );

         ln_ret_val := ln_curve_value * ln_on_flwl_ratio;

      ELSE
         ln_ret_val := ln_on_flwl_ratio;
      END IF;

   ELSIF (lv2_gas_lift_method = EcDp_Calc_Method.MEASURED) THEN
      lr_day_rec := ec_pflw_day_status.row_by_pk(p_object_id, p_daytime);

      ln_ret_val := lr_day_rec.avg_gl_rate;

   ELSIF (lv2_gas_lift_method = EcDp_Calc_Method.SUBSEA_WELLS) THEN
      ln_ret_val := getSubseaWellStdRateDay(p_object_id,
                                            p_daytime,
                                            EcDp_Phase.GAS_LIFT);

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


BEGIN
-- gas_calc_method
   lr_flwl_version := ec_flwl_version.row_by_pk(p_object_id, p_daytime, '<=');
   lv2_calc_method := Nvl(p_calc_method, lr_flwl_version.flw_calc_gas_mtd);


   IF (lv2_calc_method = EcDp_Calc_Method.CURVE) THEN

      ln_on_flwl_ratio := EcDp_Flowline.calcPflwUptime(p_object_id, p_daytime)/24;

      IF ln_on_flwl_ratio > 0 THEN -- Only worth doing calculation when the flowline is up

            lr_day_rec := ec_pflw_day_status.row_by_pk(p_object_id, p_daytime);
            ln_curve_value := getCurveRate(p_object_id,
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
                                           lr_day_rec.avg_mpm_cond_rate
                                           );

            ln_ret_val := ln_curve_value * ln_on_flwl_ratio;

      ELSE
            ln_ret_val := ln_on_flwl_ratio;
      END IF;


   ELSIF (lv2_calc_method = EcDp_Calc_method.MPM) THEN
      lr_day_rec := ec_pflw_day_status.row_by_pk(p_object_id, p_daytime);
      ln_ret_val := lr_day_rec.avg_mpm_gas_rate;



   ELSIF lv2_calc_method = EcDp_Calc_Method.SUBSEA_WELLS THEN

      ln_ret_val := getSubseaWellStdRateDay(p_object_id,
                                            p_daytime,
                                            EcDp_Phase.GAS);


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
   ln_ret_val            NUMBER;


BEGIN
	-- water_calc_method
   lr_flwl_version := ec_flwl_version.row_by_pk(p_object_id, p_daytime, '<=');
   lv2_calc_method := Nvl(p_calc_method, lr_flwl_version.flw_calc_water_mtd);


   IF (lv2_calc_method = EcDp_Calc_Method.CURVE) THEN

      ln_on_flwl_ratio := EcDp_Flowline.calcPflwUptime(p_object_id, p_daytime)/24;

      IF ln_on_flwl_ratio > 0 THEN -- Only worth doing calculation when the flowline is up

         lr_day_rec := ec_pflw_day_status.row_by_pk(p_object_id, p_daytime);
         ln_curve_value := getCurveRate(p_object_id,
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
                                        lr_day_rec.avg_mpm_cond_rate
                                        );

         ln_ret_val := ln_curve_value * ln_on_flwl_ratio;
      ELSE
         ln_ret_val := ln_on_flwl_ratio;
      END IF;


   ELSIF (lv2_calc_method = EcDp_Calc_method.MPM) THEN
      lr_day_rec := ec_pflw_day_status.row_by_pk(p_object_id, p_daytime);
      ln_ret_val := lr_day_rec.avg_mpm_water_rate;


   ELSIF lv2_calc_method = EcDp_Calc_Method.SUBSEA_WELLS THEN

      ln_ret_val := getSubseaWellStdRateDay(p_object_id,
                                            p_daytime,
                                            EcDp_Phase.WATER);


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
   ln_ret_val            NUMBER;



BEGIN
   -- cond_calc_method
   lr_flwl_version := ec_flwl_version.row_by_pk(p_object_id, p_daytime, '<=');
   lv2_calc_method := Nvl(p_calc_method, lr_flwl_version.flw_calc_cond_mtd);


   IF (lv2_calc_method = EcDp_Calc_Method.CURVE) THEN

     ln_on_flwl_ratio := EcDp_Flowline.calcPflwUptime(p_object_id, p_daytime)/24;

      IF ln_on_flwl_ratio > 0 THEN -- Only worth doing calculation when the flowline is up

         lr_day_rec := ec_pflw_day_status.row_by_pk(p_object_id, p_daytime);
         ln_curve_value := getCurveRate(p_object_id,
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
                                        lr_day_rec.avg_mpm_cond_rate
                                        );

         ln_ret_val := ln_curve_value * ln_on_flwl_ratio;

      ELSE
         ln_ret_val := ln_on_flwl_ratio;
      END IF;


   ELSIF lv2_calc_method = EcDp_Calc_Method.SUBSEA_WELLS THEN

      ln_ret_val := getSubseaWellStdRateDay(p_object_id,
                                            p_daytime,
                                            EcDp_Phase.CONDENSATE);


   ELSIF (lv2_calc_method = EcDp_Calc_method.MPM) THEN
      lr_day_rec := ec_pflw_day_status.row_by_pk(p_object_id, p_daytime);
      ln_ret_val := lr_day_rec.avg_mpm_cond_rate;


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
   lv2_calc_inj_method    VARCHAR2(32);
   lr_day_rec         iflw_day_status%ROWTYPE;
   ln_ret_val         NUMBER;
   ln_on_strm_ratio   NUMBER;
   ld_start_daytime     DATE;
   ld_end_daytime       DATE;
   lv2_phase          VARCHAR2(32);
   ln_curve_value     NUMBER;
   ln_inj_rate_value  NUMBER;
   lv2_def_version    VARCHAR2(32);

   ld_prod_day                DATE;
   ld_daytime                 DATE;
   ld_maxdaytime              DATE;
   ln_mth_inj_vol             NUMBER;
   ln_prevmth_inj_vol         NUMBER;
   ln_on_strm_mth             NUMBER;
   ln_on_strm_prevmth         NUMBER;
   ln_prod_day_offset         NUMBER;
   ln_totalizer_frac          NUMBER;
   ln_fraction_vol            NUMBER;
   lv2_class_name             VARCHAR2(32);
   ld_cur_date                DATE;
   ln_total_vol               NUMBER;
   ln_inj_rate                NUMBER;
   ln_duration_fraction       NUMBER;
   ln_total_inj_rate          NUMBER;
   ln_fraction_rate           NUMBER;


BEGIN

  IF (p_inj_type = Ecdp_Flowline_Type.GAS_INJECTOR) THEN

    lv2_calc_inj_method := Nvl(p_calc_inj_method,
                          ec_flwl_version.flwl_gas_calc_inj_mtd(p_object_id,
                                                      p_daytime,
                                                      '<='));

  ELSIF (p_inj_type = Ecdp_Flowline_Type.WATER_INJECTOR) THEN

    lv2_calc_inj_method := Nvl(p_calc_inj_method,
                          ec_flwl_version.flwl_wat_calc_inj_mtd(p_object_id,
                                                      p_daytime,
                                                       '<='));

  /* ELSIF (p_inj_type = Ecdp_Flowline_Type.STEAM_INJECTOR) THEN

    lv2_calc_inj_method := Nvl(p_calc_inj_method,
                          ec_flwl_version.flwl_stm_calc_inj_mtd(p_object_id,
                                                      p_daytime,
                                                      '<=')); */
  END IF;


   IF (lv2_calc_inj_method = EcDp_Calc_Method.CURVE) THEN

      ln_on_strm_ratio := EcDp_Flowline.calcIflwUptime(p_object_id,p_daytime) / 24;

      IF ln_on_strm_ratio > 0 THEN -- Only worth doing calculation when the well is up

         IF (p_inj_type = EcDp_Well_Type.WATER_INJECTOR) THEN
            lv2_phase := EcDp_Phase.WATER;
         ELSIF (p_inj_type = EcDp_Well_Type.GAS_INJECTOR) THEN
            lv2_phase := EcDp_Phase.GAS;
         END IF;

         lr_day_rec := ec_iflw_day_status.row_by_pk(p_object_id,p_inj_type, p_daytime);
         ln_curve_value := getCurveRate(p_object_id,
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
                                        lr_day_rec.avg_mpm_cond_rate
                                        );

         ln_ret_val := ln_curve_value * ln_on_strm_ratio;

      ELSE
         ln_ret_val := ln_on_strm_ratio;
      END IF;

   ELSIF (lv2_calc_inj_method = Ecdp_Calc_Method.MEASURED) THEN
      lr_day_rec := ec_iflw_day_status.row_by_pk(p_object_id, p_inj_type, p_daytime);
      ln_ret_val := lr_day_rec.inj_vol;

   ELSIF (substr(lv2_calc_inj_method,1,9) = EcDp_Calc_Method.USER_EXIT) THEN
       ln_ret_val := 0;
	   /*Ue_Well_Theoretical.getInjectedStdRateDay(
         			p_object_id,
         			p_inj_type,
         			p_daytime);*/


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

   lv2_calc_method := Nvl(p_calc_method, ec_flwl_version.flwl_calc_mass_mtd(p_object_id,p_daytime,'<='));

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

   lv2_calc_method := Nvl(p_calc_method, ec_flwl_version.flwl_calc_mass_mtd(p_object_id,p_daytime,'<='));

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

   lv2_calc_method := Nvl(p_calc_method, ec_flwl_version.flwl_calc_mass_mtd(p_object_id,p_daytime,'<='));

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

   lv2_calc_method := Nvl(p_calc_method, ec_flwl_version.flwl_calc_mass_mtd(p_object_id,p_daytime,'<='));

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
        ln_phase_rate := EcBp_Well_Theoretical.getOilStdVolSubDay(subwell.well_id,
                                                                   p_daytime,
                                                                   lv2_calc_method);
      elsif p_phase = ecdp_phase.GAS then
        lv2_calc_method :=ec_well_version.calc_sub_day_gas_method(subwell.well_id, p_daytime, '<=');
        ln_phase_rate := EcBp_Well_Theoretical.getGasStdVolSubDay(subwell.well_id,
                                                                   p_daytime,
                                                                   lv2_calc_method);

      elsif p_phase = ecdp_phase.WATER then
        lv2_calc_method :=ec_well_version.calc_sub_day_water_method(subwell.well_id, p_daytime, '<=');
        ln_phase_rate := EcBp_Well_Theoretical.getWatStdVolSubDay(subwell.well_id,
                                                                   p_daytime,
                                                                   lv2_calc_method);

      elsif p_phase = ecdp_phase.CONDENSATE then
        lv2_calc_method :=ec_well_version.calc_sub_day_cond_method(subwell.well_id, p_daytime, '<=');
        ln_phase_rate := EcBp_Well_Theoretical.getCondStdVolSubDay(subwell.well_id,
                                                                   p_daytime,
                                                                   lv2_calc_method);
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
   -- oil sub day calc method
   lv2_calc_method := Nvl(p_calc_method,ec_flwl_version.flw_calc_sub_day_oil_mtd(p_object_id,
                                                                                 p_daytime,
                                                                                 '<='));

   lr_sub_day_rec := ec_pflw_sub_day_status.row_by_pk(p_object_id,
                                                      p_daytime);


   IF (lv2_calc_method = EcDp_Calc_Method.CURVE) THEN

      ln_on_flwl_ratio := lr_sub_day_rec.on_stream_hrs / 24;

      IF ln_on_flwl_ratio > 0 THEN -- Only worth doing calculation when the flowline is up

         ln_curve_value := getCurveRate(p_object_id,
                                        p_daytime,
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
                                        lr_sub_day_rec.avg_mpm_cond_rate
                                        );

         ln_ret_val := ln_curve_value * ln_on_flwl_ratio;

      ELSE
         ln_ret_val := ln_on_flwl_ratio;
      END IF;


   ELSIF (lv2_calc_method = EcDp_Calc_method.MPM) THEN
      lr_sub_day_rec := ec_pflw_sub_day_status.row_by_pk(p_object_id, p_daytime);
      ln_ret_val := lr_sub_day_rec.avg_mpm_oil_rate;


   ELSIF lv2_calc_method = EcDp_Calc_Method.SUBSEA_WELLS THEN

      ln_ret_val := getSubseaWellStdRateSubDay(p_object_id,
                                               p_daytime,
                                               EcDp_Phase.OIL);


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
   lr_sub_day_rec     pflw_sub_day_status%ROWTYPE;
   ln_curve_value     NUMBER;
   ln_on_flwl_ratio   NUMBER;
   ln_gor             NUMBER;
   ln_oil_rate        NUMBER;

BEGIN

   -- gas sub day calc method
   lv2_calc_method := Nvl(p_calc_method,ec_flwl_version.flw_calc_sub_day_gas_mtd(p_object_id,
                                                                                 p_daytime,
                                                                                 '<='));
   lr_sub_day_rec := ec_pflw_sub_day_status.row_by_pk(p_object_id,
                                                      p_daytime);


   IF (lv2_calc_method = EcDp_Calc_Method.CURVE) THEN

   -- something missing here
   -- including as comment for now
   /*   IF EcDp_Flowline_Type.isGasProducer(EcDp_Flowline.getFlowlineType(p_object_id, p_daytime)) = ECDP_TYPE.IS_TRUE THEN*/

	 ln_on_flwl_ratio := lr_sub_day_rec.on_stream_hrs / 24;

	 IF ln_on_flwl_ratio > 0 THEN -- Only worth doing calculation when the flowline is up

         ln_curve_value := getCurveRate(p_object_id,
                                        p_daytime,
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
                                        lr_sub_day_rec.avg_mpm_cond_rate
                                        );

		ln_ret_val := ln_curve_value * ln_on_flwl_ratio;

	 ELSE
		ln_ret_val := ln_on_flwl_ratio;
    END IF;

	/*
	      ELSE
         ln_gor := EcDp_Well_Theoretical.getGasOilRatio(p_object_id,
                                                        p_daytime);

         ln_oil_rate := getOilStdVolSubDay(p_object_id,
                                           p_daytime,
                                           NULL);

         ln_ret_val := ln_oil_rate * ln_gor;
      END IF;
*/

   ELSIF (lv2_calc_method = EcDp_Calc_method.MPM) THEN
      lr_sub_day_rec := ec_pflw_sub_day_status.row_by_pk(p_object_id, p_daytime);
      ln_ret_val := lr_sub_day_rec.avg_mpm_gas_rate;


   ELSIF lv2_calc_method = EcDp_Calc_Method.SUBSEA_WELLS THEN

      ln_ret_val := getSubseaWellStdRateSubDay(p_object_id,
                                               p_daytime,
                                               EcDp_Phase.GAS);


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
   lr_sub_day_rec    pflw_sub_day_status%ROWTYPE;
   ln_curve_value    NUMBER;
   ln_on_flwl_ratio  NUMBER;


BEGIN
    -- water sub day calc method
   lv2_calc_method := Nvl(p_calc_method,ec_flwl_version.flw_calc_sub_day_water_mtd(p_object_id,
                                                                                   p_daytime,
                                                                                   '<='));

   lr_sub_day_rec := ec_pflw_sub_day_status.row_by_pk(p_object_id, p_daytime);


   IF (lv2_calc_method = EcDp_Calc_Method.CURVE) THEN

      ln_on_flwl_ratio := lr_sub_day_rec.on_stream_hrs / 24;

      IF ln_on_flwl_ratio > 0 THEN -- Only worth doing calculation when the flowline is up

         ln_curve_value := getCurveRate(p_object_id,
                                        p_daytime,
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
                                        lr_sub_day_rec.avg_mpm_cond_rate
                                        );

         ln_ret_val := ln_curve_value * ln_on_flwl_ratio;
      ELSE
         ln_ret_val := ln_on_flwl_ratio;
      END IF;


   ELSIF (lv2_calc_method = EcDp_Calc_method.MPM) THEN
      lr_sub_day_rec := ec_pflw_sub_day_status.row_by_pk(p_object_id, p_daytime);
      ln_ret_val := lr_sub_day_rec.avg_mpm_water_rate;


   ELSIF lv2_calc_method = EcDp_Calc_Method.SUBSEA_WELLS THEN

      ln_ret_val := getSubseaWellStdRateSubDay(p_object_id,
                                               p_daytime,
                                               EcDp_Phase.WATER);


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
   ln_cgr            NUMBER;
   lr_sub_day_rec    pflw_sub_day_status%ROWTYPE;
   ln_curve_value    NUMBER;
   ln_on_flwl_ratio  NUMBER;

BEGIN
   -- cond sub day calc method
   lv2_calc_method := Nvl(p_calc_method,ec_flwl_version.flw_calc_sub_day_cond_mtd(p_object_id,
                                                                                  p_daytime,
                                                                                  '<='));


   lr_sub_day_rec := ec_pflw_sub_day_status.row_by_pk(p_object_id, p_daytime);

   IF (lv2_calc_method = EcDp_Calc_Method.CURVE) THEN

      ln_on_flwl_ratio := lr_sub_day_rec.on_stream_hrs / 24;

      IF ln_on_flwl_ratio > 0 THEN -- Only worth doing calculation when the flowline is up

         ln_curve_value := getCurveRate(p_object_id,
                                        p_daytime,
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
                                        lr_sub_day_rec.avg_mpm_cond_rate
                                        );

         ln_ret_val := ln_curve_value * ln_on_flwl_ratio;
      ELSE
         ln_ret_val := ln_on_flwl_ratio;
      END IF;


   ELSIF (lv2_calc_method = EcDp_Calc_method.MPM) THEN
      lr_sub_day_rec := ec_pflw_sub_day_status.row_by_pk(p_object_id, p_daytime);
      ln_ret_val := lr_sub_day_rec.avg_mpm_cond_rate;


   ELSIF lv2_calc_method = EcDp_Calc_Method.SUBSEA_WELLS THEN

      ln_ret_val := getSubseaWellStdRateSubDay(p_object_id,
                                               p_daytime,
                                               EcDp_Phase.CONDENSATE);


   ELSIF (substr(lv2_calc_method,1,9) = EcDp_Calc_Method.USER_EXIT) THEN
      ln_ret_val := Ue_Flowline_Theoretical.getOilStdVolSubDay(p_object_id, p_daytime);


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
FUNCTION findWaterCutPct(p_object_id    VARCHAR2,
                    p_daytime      DATE,
                    p_calc_method  VARCHAR2 DEFAULT NULL)

RETURN NUMBER
--</EC-DOC>
IS
   lv2_calc_method         VARCHAR2(32);
   --lr_well_est_detail      pflw_result%ROWTYPE;
   lr_day_rec              pflw_day_status%ROWTYPE;
   lr_flwl_version         flwl_version%ROWTYPE;
   ln_ret_val              NUMBER;
   ln_prod_day_offset      NUMBER;
   ld_start_daytime        DATE;

BEGIN

   lr_flwl_version := ec_flwl_version.row_by_pk(p_object_id, p_daytime, '<=');
   lv2_calc_method := Nvl(p_calc_method, lr_flwl_version.FLWL_BSW_VOL_MTD);


   IF (lv2_calc_method = EcDp_Calc_Method.CURVE) THEN
      ln_prod_day_offset := EcDp_ProductionDay.getProductionDayOffset('FLOWLINE',p_object_id,p_daytime)/24;
      ld_start_daytime := p_daytime + ln_prod_day_offset;
      ln_ret_val := EcDp_Flowline_Theoretical.getWaterCutPct(p_object_id, ld_start_daytime);


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
                          p_calc_method  VARCHAR2 DEFAULT NULL)

RETURN NUMBER
--</EC-DOC>
IS
   lv2_calc_method    VARCHAR2(32);
   lr_flwl_version    flwl_version%ROWTYPE;
   ln_ret_val       NUMBER;
   ln_prod_day_offset    NUMBER;
   ld_start_daytime      DATE;

BEGIN

   lr_flwl_version := ec_flwl_version.row_by_pk(p_object_id, p_daytime, '<=');

   lv2_calc_method := Nvl(p_calc_method, lr_flwl_version.FLWL_CGR_MTD);


   IF (lv2_calc_method = EcDp_Calc_Method.CURVE) THEN
      ln_prod_day_offset := EcDp_ProductionDay.getProductionDayOffset('FLOWLINE',p_object_id,p_daytime)/24;
      ld_start_daytime := p_daytime + ln_prod_day_offset;
      ln_ret_val := EcDp_Flowline_Theoretical.getCondensateGasRatio(p_object_id, ld_start_daytime);


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
                         p_calc_method  VARCHAR2 DEFAULT NULL)

RETURN NUMBER
--</EC-DOC>
IS
   lv2_calc_method    VARCHAR2(32);
   lr_flwl_est_detail    pflw_result%ROWTYPE;
   lr_flwl_version       flwl_version%ROWTYPE;
   ln_ret_val            NUMBER;
   ln_prod_day_offset    NUMBER;
   ld_start_daytime      DATE;

BEGIN

   lr_flwl_version := ec_flwl_version.row_by_pk(p_object_id, p_daytime, '<=');

   lv2_calc_method := Nvl(p_calc_method, lr_flwl_version.FLWL_GOR_MTD);

   IF (lv2_calc_method = EcDp_Calc_Method.CURVE) THEN
      ln_prod_day_offset := EcDp_ProductionDay.getProductionDayOffset('FLOWLINE',p_object_id,p_daytime)/24;
      ld_start_daytime := p_daytime + ln_prod_day_offset;
      ln_ret_val := EcDp_Flowline_Theoretical.getGasOilRatio(p_object_id, ld_start_daytime);


   ELSIF (substr(lv2_calc_method,1,9) = EcDp_Calc_Method.USER_EXIT) THEN
      ln_ret_val := Ue_Flowline_Theoretical.findGasOilRatio(p_object_id,p_daytime);


   ELSE  -- undefined
      ln_ret_val := NULL;

   END IF;

   RETURN ln_ret_val;
END findGasOilRatio;


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
   lv2_calc_method    VARCHAR2(32);
   lr_flwl_est_detail pflw_result%ROWTYPE;
   ln_ret_val       NUMBER;
   ln_prod_day_offset    NUMBER;
   ld_start_daytime      DATE;

BEGIN

   lv2_calc_method := Nvl(p_calc_method, ec_flwl_version.FLWL_WDF_MTD(p_object_id,p_daytime,'<='));
 ---- need to add new flowline calc methods here ---------------

   IF (substr(lv2_calc_method,1,9) = EcDp_Calc_Method.USER_EXIT) THEN
      ln_ret_val := Ue_Flowline_Theoretical.findWetDryFactor(p_object_id,p_daytime);


   ELSE  -- undefined
      ln_ret_val := NULL;


   END IF;

   RETURN ln_ret_val;
END findWetDryFactor;


END EcBp_Flowline_Theoretical;