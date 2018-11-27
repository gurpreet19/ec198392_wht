CREATE OR REPLACE PACKAGE BODY EcBp_Defer_Summary IS
/****************************************************************
** Package        :  EcBp_Defer_Summary
**
** $Revision: 1.7 $
**
** Purpose        :  This package is responsible for supporting business functions
**                   related to Daily Deferment Master and Daily Deferment Summary.
**
** Documentation  :  www.energy-components.com
**
** Created  : 04.01.2006  Sarojini Rajaretnam
**
** Modification history:
**
** Date       Whom     Change description:
** ------     -------- --------------------------------------
** 29.05.2007 zakiiari ECPD-3905: Modified getPlannedVolumes to use prod_fcty_forecast instead of plan_value
** 15.02.2007 kaurrjes ECPD-6544: Modified getPlannedVolumes, getAssignedDeferVolumes and getActualVolumes functions.
** 18.08.2008 aliassit ECPD-9294: Added two new functions getActualMass and getActualEnergy and modified getActualVolumes function.
** 18.10.2010 rajarsar ECPD-15760: Updated getPlannedVolumes to support new potential methods
** 14.07.2011 musaamah ECPD-17211: Modified the class names in function getPlannedVolumes.
** 25-09-2015 kumarsur ECPD-31862: Modified getPlannedVolumes.
** 27-02-2017 leongwen ECPD-32871: Modified getPlannedVolumes to work with renamed columns but subject to further change on ECPD-43662 later
** 12-05-2017 jainnraj ECPD-42563: Renamed function call getProdForecastId to getProdScenarioId.
** 28-12-2017 jainnraj ECPD-31884: Removing all the calls where potential_method is Ecdp_Calc_Method.FORECAST and modified getPlannedVolumes to remove call of Ecbp_Productionforecast.getRecentProdForecastNo
*****************************************************************/

--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Function       : getPlannedVolumes                                                   --
-- Description    : Returns Planned Volumes.
-- Preconditions  :
-- Postconditions :                                                                                --
--                                                                                                 --
-- Using tables   :
--                                                                                                 --
-- Using functions:
--
--                                                                                                 --
-- Configuration                                                                           --
-- required       :                                                                                --
--                                                                                                 --
-- Behaviour      :                                                                                --
--                                                                                                 --
-----------------------------------------------------------------------------------------------------
FUNCTION getPlannedVolumes(p_object_id VARCHAR2, p_phase VARCHAR2, p_daytime DATE)

RETURN NUMBER
--</EC-DOC>
IS

ln_planned_day_volume NUMBER;
lv2_class_name VARCHAR2(32);
lv2_scenario_id       VARCHAR2(32);
lv2_potential_method   VARCHAR2(32);
lr_fcty_version       FCTY_VERSION%ROWTYPE;

CURSOR c_fcst_fcty_vol(cp_forecast_id VARCHAR2) IS
SELECT DECODE(p_phase,
  'OIL', ec_fcst_fcty_day.net_oil_rate(p_object_id,p_daytime,cp_forecast_id,'<='),
  'GAS', ec_fcst_fcty_day.gas_rate(p_object_id,p_daytime,cp_forecast_id,'<='),
  'COND', ec_fcst_fcty_day.cond_rate(p_object_id,p_daytime,cp_forecast_id,'<='),
  'WAT_INJ', ec_fcst_fcty_day.water_inj_rate(p_object_id,p_daytime,cp_forecast_id,'<='),
  'GAS_INJ', ec_fcst_fcty_day.gas_inj_rate(p_object_id,p_daytime,cp_forecast_id,'<='),
  'STEAM_INJ', ec_fcst_fcty_day.steam_inj_rate(p_object_id,p_daytime,cp_forecast_id,'<='),
  'OIL_MASS', ec_fcst_fcty_day.net_oil_mass_rate(p_object_id,p_daytime,cp_forecast_id,'<='),
  'GAS_MASS', ec_fcst_fcty_day.gas_mass_rate(p_object_id,p_daytime,cp_forecast_id,'<='),
  'WATER_INJ_MASS', ec_fcst_fcty_day.water_inj_mass_rate(p_object_id,p_daytime,cp_forecast_id,'<='),
  'GAS_INJ_MASS', ec_fcst_fcty_day.gas_inj_mass_rate(p_object_id,p_daytime,cp_forecast_id,'<='),
  'WATER_MASS', ec_fcst_fcty_day.water_mass_rate(p_object_id,p_daytime,cp_forecast_id,'<='),
  'COND_MASS', ec_fcst_fcty_day.cond_mass_rate(p_object_id,p_daytime,cp_forecast_id,'<='),
  'STEAM_INJ_MASS', ec_fcst_fcty_day.steam_inj_mass_rate(p_object_id,p_daytime,cp_forecast_id,'<='),
  'GAS_ENERGY', ec_fcst_fcty_day.gas_energy(p_object_id,p_daytime,cp_forecast_id,'<='),
  'WATER', ec_fcst_fcty_day.water_rate(p_object_id,p_daytime,cp_forecast_id,'<=')) planned_vol
FROM dual;

CURSOR c_plan_fcty_vol(cp_class_name VARCHAR2) IS
SELECT DECODE(p_phase,
  'OIL', ec_object_plan.oil_rate(p_object_id,p_daytime,cp_class_name,'<='),
  'GAS', ec_object_plan.gas_rate(p_object_id,p_daytime,cp_class_name,'<='),
  'WATER', ec_object_plan.water_rate(p_object_id,p_daytime,cp_class_name,'<='),
  'COND', ec_object_plan.cond_rate(p_object_id,p_daytime,cp_class_name,'<='),
  'WAT_INJ', ec_object_plan.wat_inj_rate(p_object_id,p_daytime,cp_class_name,'<='),
  'GAS_INJ', ec_object_plan.gas_inj_rate(p_object_id,p_daytime,cp_class_name,'<='),
  'STEAM_INJ', ec_object_plan.steam_inj_rate(p_object_id,p_daytime,cp_class_name,'<=')) planned_vol
FROM dual;

CURSOR c_planned_sub_area_vol IS
SELECT Ue_Defer_Summary.getPlannedVolumes(p_object_id, p_phase, p_daytime) planned_vol
FROM dual;

BEGIN

  lv2_class_name := EcDp_Objects.getObjClassName(p_object_id);
  lv2_scenario_id := ecbp_forecast_prod.getProdScenarioId(p_object_id,p_daytime);

  IF lv2_class_name IN ('FCTY_CLASS_1','FCTY_CLASS_2') THEN
   lr_fcty_version      := ec_fcty_version.row_by_pk(p_object_id, p_daytime, '<=');
   lv2_potential_method := lr_fcty_version.prod_plan_method;

    IF (lv2_potential_method = Ecdp_Calc_Method.FORECAST_PROD) THEN
        FOR mycur IN c_fcst_fcty_vol(lv2_scenario_id) LOOP
            ln_planned_day_volume := mycur.planned_vol;
        END LOOP;
    ELSIF (lv2_potential_method = Ecdp_Calc_Method.BUDGET_PLAN) THEN
      FOR mycur IN c_plan_fcty_vol('FCTY_PLAN_BUDGET') LOOP
        ln_planned_day_volume := mycur.planned_vol;
      END LOOP;
    ELSIF (lv2_potential_method = Ecdp_Calc_Method.POTENTIAL_PLAN) THEN
      FOR mycur IN c_plan_fcty_vol('FCTY_PLAN_POTENTIAL') LOOP
        ln_planned_day_volume := mycur.planned_vol;
      END LOOP;
    ELSIF (lv2_potential_method = Ecdp_Calc_Method.TARGET_PLAN) THEN
      FOR mycur IN c_plan_fcty_vol('FCTY_PLAN_TARGET') LOOP
        ln_planned_day_volume := mycur.planned_vol;
      END LOOP;
    ELSIF (lv2_potential_method = Ecdp_Calc_Method.OTHER_PLAN) THEN
      FOR mycur IN c_plan_fcty_vol('FCTY_PLAN_OTHER') LOOP
        ln_planned_day_volume := mycur.planned_vol;
      END LOOP;
    END IF;
  ELSIF lv2_class_name = 'SUB_AREA' THEN
    FOR mycur IN c_planned_sub_area_vol LOOP
      ln_planned_day_volume := mycur.planned_vol;
    END LOOP;
  ELSE
    NULL;
  END IF;

  RETURN ln_planned_day_volume;

END getPlannedVolumes;

--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Function       : getAssignedDeferVolumes                                                   --
-- Description    : Returns Assigned Defer Volumes which was assigned.
-- Preconditions  :
-- Postconditions :                                                                                --
--                                                                                                 --
-- Using tables   : def_day_summary_events
--                                                                                                 --
-- Using functions:
--
--                                                                                                 --
-- Configuration                                                                           --
-- required       :                                                                                --
--                                                                                                 --
-- Behaviour      :                                                                                --
--                                                                                                 --
-----------------------------------------------------------------------------------------------------
FUNCTION getAssignedDeferVolumes(p_object_id VARCHAR2, p_phase VARCHAR2, p_daytime DATE)

RETURN NUMBER
--</EC-DOC>
IS

ln_assigned_defer_volume NUMBER;

CURSOR c_def_day_summary_event IS
SELECT DECODE(p_phase,
  'OIL',sum(def_oil_vol),
  'GAS',sum(def_gas_vol),
  'COND',sum(def_cond_vol),
  'WAT_INJ',sum(def_water_inj_vol),
  'GAS_INJ',sum(def_gas_inj_vol),
  'STEAM_INJ',sum(def_steam_inj_vol),
  'OIL_MASS', sum(def_oil_mass),
  'GAS_MASS', sum(def_gas_mass),
  'WATER_INJ_MASS',sum(def_water_inj_mass),
  'GAS_INJ_MASS',sum(def_gas_inj_mass),
  'WATER_MASS',sum(def_water_mass),
  'COND_MASS',sum(def_cond_mass),
  'STEAM_INJ_MASS',sum(def_steam_inj_mass),
  'GAS_ENERGY',sum(def_gas_energy),
  'WATER',sum(def_water_vol)) sum_vol
FROM def_day_summary_event
WHERE daytime = p_daytime AND defer_level_object_id = p_object_id;

BEGIN
  FOR mycur IN c_def_day_summary_event LOOP
    ln_assigned_defer_volume := mycur.sum_vol;
  END LOOP;

  RETURN nvl(ln_assigned_defer_volume,0);

END getAssignedDeferVolumes;

--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Function       : getActualVolumes                                                   --
-- Description    : Returns Actual Volumes based on phase.
-- Preconditions  :
-- Postconditions :                                                                                --
--                                                                                                 --
-- Using tables   :
--                                                                                                 --
-- Using functions: getActualProducedVolumes
--
--                                                                                                 --
-- Configuration                                                                           --
-- required       :                                                                                --
--                                                                                                 --
-- Behaviour      :                                                                                --
--                                                                                                 --
-----------------------------------------------------------------------------------------------------
FUNCTION getActualVolumes(p_object_id VARCHAR2, p_phase VARCHAR2, p_daytime DATE)

RETURN NUMBER
--</EC-DOC>
IS

  ln_actual_volume NUMBER;
  lv2_strm_set VARCHAR(32);

BEGIN

  IF p_phase = 'OIL' THEN
     lv2_strm_set := 'PD.0005_04';
     ln_actual_volume := getActualProducedVolumes(p_object_id, lv2_strm_set, p_daytime);

  ELSIF p_phase = 'GAS' THEN
     lv2_strm_set := 'PD.0005_02';
     ln_actual_volume := getActualProducedVolumes(p_object_id, lv2_strm_set, p_daytime);

  ELSIF p_phase = 'COND' THEN
     lv2_strm_set := 'PD.0005';
     ln_actual_volume := getActualProducedVolumes(p_object_id, lv2_strm_set, p_daytime);

  ELSIF p_phase = 'WAT_INJ' THEN
     lv2_strm_set := 'PD.0005_06';
     ln_actual_volume := getActualProducedVolumes(p_object_id, lv2_strm_set, p_daytime);

  ELSIF p_phase = 'GAS_INJ' THEN
     lv2_strm_set := 'PD.0005_03';
     ln_actual_volume := getActualProducedVolumes(p_object_id, lv2_strm_set, p_daytime);

  ELSIF p_phase = 'STEAM_INJ' THEN
     lv2_strm_set := 'PD.0005_05';
     ln_actual_volume := getActualProducedVolumes(p_object_id, lv2_strm_set, p_daytime);

  ELSIF p_phase = 'WATER' THEN
     lv2_strm_set := 'PD.0005_07';
     ln_actual_volume := getActualProducedVolumes(p_object_id, lv2_strm_set, p_daytime);

  ELSIF p_phase = 'OIL_MASS' THEN
     lv2_strm_set := 'PD.0005_08';
     ln_actual_volume := getActualMass(p_object_id, lv2_strm_set, p_daytime);

  ELSIF p_phase = 'GAS_MASS' THEN
     lv2_strm_set := 'PD.0005_09';
     ln_actual_volume := getActualMass(p_object_id, lv2_strm_set, p_daytime);

  ELSIF p_phase = 'WATER_INJ_MASS' THEN
     lv2_strm_set := 'PD.0005_10';
     ln_actual_volume := getActualMass(p_object_id, lv2_strm_set, p_daytime);

  ELSIF p_phase = 'GAS_INJ_MASS' THEN
     lv2_strm_set := 'PD.0005_11';
     ln_actual_volume := getActualMass(p_object_id, lv2_strm_set, p_daytime);

  ELSIF p_phase = 'WATER_MASS' THEN
     lv2_strm_set := 'PD.0005_12';
     ln_actual_volume := getActualMass(p_object_id, lv2_strm_set, p_daytime);

  ELSIF p_phase = 'COND_MASS' THEN
     lv2_strm_set := 'PD.0005_13';
     ln_actual_volume := getActualMass(p_object_id, lv2_strm_set, p_daytime);

  ELSIF p_phase = 'STEAM_INJ_MASS' THEN
     lv2_strm_set := 'PD.0005_14';
     ln_actual_volume := getActualMass(p_object_id, lv2_strm_set, p_daytime);

  ELSIF p_phase = 'GAS_ENERGY' THEN
     lv2_strm_set := 'PD.0005_15';
     ln_actual_volume := getActualEnergy(p_object_id, lv2_strm_set, p_daytime);
  END IF;

  RETURN ln_actual_volume;

END getActualVolumes;


--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Function       : getActualProducedVolumes                                                --
-- Description    : Returns Actual Produced Volumes based on stream set.
-- Preconditions  :
-- Postconditions :                                                                                --
--                                                                                                 --
-- Using tables   :
--                                                                                                 --
-- Using functions:
--
--                                                                                                 --
-- Configuration                                                                           --
-- required       :                                                                                --
--                                                                                                 --
-- Behaviour      :                                                                                --
--                                                                                                 --
-----------------------------------------------------------------------------------------------------
FUNCTION getActualProducedVolumes(p_object_id VARCHAR2, p_strm_set VARCHAR2, p_daytime DATE)

RETURN NUMBER
--</EC-DOC>
IS

ln_actual_prod_volume NUMBER;
lv2_class_name VARCHAR2(32);

CURSOR c_actual_prod_fcty_1 IS
SELECT SUM(EcBp_Stream_Fluid.findNetStdVol(sv.object_id,p_daytime)) prod_vol
FROM strm_set_list ssl, strm_version sv
WHERE sv.op_fcty_class_1_id = p_object_id
AND p_daytime >= ssl.from_date AND (p_daytime < ssl.end_date OR ssl.end_date IS NULL)
AND p_daytime >= sv.daytime AND (p_daytime < sv.end_date OR sv.end_date IS NULL)
AND ssl.stream_set = p_strm_set
AND sv.object_id = ssl.object_id;

CURSOR c_actual_prod_fcty_2 IS
SELECT SUM(EcBp_Stream_Fluid.findNetStdVol(sv.object_id,p_daytime)) prod_vol
FROM strm_set_list ssl, strm_version sv
WHERE sv.op_fcty_class_2_id = p_object_id
AND p_daytime >= ssl.from_date AND (p_daytime < ssl.end_date OR ssl.end_date IS NULL)
AND p_daytime >= sv.daytime AND (p_daytime < sv.end_date OR sv.end_date IS NULL)
AND ssl.stream_set = p_strm_set
AND sv.object_id = ssl.object_id;

CURSOR c_actual_prod_sub_area IS
SELECT Ue_Defer_Summary.getActualProducedVolumes(p_object_id, p_strm_set, p_daytime) prod_vol
FROM dual;

BEGIN
  lv2_class_name := EcDp_Objects.getObjClassName(p_object_id);

  IF lv2_class_name = 'FCTY_CLASS_1' THEN
    FOR mycur IN c_actual_prod_fcty_1 LOOP
      ln_actual_prod_volume := mycur.prod_vol;
    END LOOP;
  ELSIF lv2_class_name = 'FCTY_CLASS_2' THEN
    FOR mycur IN c_actual_prod_fcty_2 LOOP
      ln_actual_prod_volume := mycur.prod_vol;
    END LOOP;
  ELSIF lv2_class_name = 'SUB_AREA' THEN
    FOR mycur IN c_actual_prod_sub_area LOOP
      ln_actual_prod_volume := mycur.prod_vol;
    END LOOP;
  ELSE
    NULL;
  END IF;

  RETURN ln_actual_prod_volume;

END getActualProducedVolumes;

--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Function       : getActualMass                                               --
-- Description    : Returns Actual Mass based on stream set.
-- Preconditions  :
-- Postconditions :                                                                                --
--                                                                                                 --
-- Using tables   :
--                                                                                                 --
-- Using functions:
--
--                                                                                                 --
-- Configuration                                                                           --
-- required       :                                                                                --
--                                                                                                 --
-- Behaviour      :                                                                                --
--                                                                                                 --
-----------------------------------------------------------------------------------------------------
FUNCTION getActualMass(p_object_id VARCHAR2, p_strm_set VARCHAR2, p_daytime DATE)

RETURN NUMBER
--</EC-DOC>
IS

ln_actual_prod_mass NUMBER;
lv2_class_name VARCHAR2(32);

CURSOR c_actual_prod_fcty_1 IS
SELECT SUM(EcBp_Stream_Fluid.findNetStdMass(sv.object_id,p_daytime)) prod_mass
FROM strm_set_list ssl, strm_version sv
WHERE sv.op_fcty_class_1_id = p_object_id
AND p_daytime >= ssl.from_date AND (p_daytime < ssl.end_date OR ssl.end_date IS NULL)
AND p_daytime >= sv.daytime AND (p_daytime < sv.end_date OR sv.end_date IS NULL)
AND ssl.stream_set = p_strm_set
AND sv.object_id = ssl.object_id;

CURSOR c_actual_prod_fcty_2 IS
SELECT SUM(EcBp_Stream_Fluid.findNetStdMass(sv.object_id,p_daytime)) prod_mass
FROM strm_set_list ssl, strm_version sv
WHERE sv.op_fcty_class_2_id = p_object_id
AND p_daytime >= ssl.from_date AND (p_daytime < ssl.end_date OR ssl.end_date IS NULL)
AND p_daytime >= sv.daytime AND (p_daytime < sv.end_date OR sv.end_date IS NULL)
AND ssl.stream_set = p_strm_set
AND sv.object_id = ssl.object_id;

CURSOR c_actual_prod_sub_area IS
SELECT Ue_Defer_Summary.getActualMass(p_object_id, p_strm_set, p_daytime) prod_mass
FROM dual;

BEGIN
  lv2_class_name := EcDp_Objects.getObjClassName(p_object_id);

  IF lv2_class_name = 'FCTY_CLASS_1' THEN
    FOR mycur IN c_actual_prod_fcty_1 LOOP
      ln_actual_prod_mass := mycur.prod_mass;
    END LOOP;
  ELSIF lv2_class_name = 'FCTY_CLASS_2' THEN
    FOR mycur IN c_actual_prod_fcty_2 LOOP
      ln_actual_prod_mass := mycur.prod_mass;
    END LOOP;
  ELSIF lv2_class_name = 'SUB_AREA' THEN
    FOR mycur IN c_actual_prod_sub_area LOOP
      ln_actual_prod_mass := mycur.prod_mass;
    END LOOP;
  ELSE
    NULL;
  END IF;

  RETURN ln_actual_prod_mass;

END getActualMass;

--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Function       : getActualProducedVolumes                                                --
-- Description    : Returns Actual Produced Volumes based on stream set.
-- Preconditions  :
-- Postconditions :                                                                                --
--                                                                                                 --
-- Using tables   :
--                                                                                                 --
-- Using functions:
--
--                                                                                                 --
-- Configuration                                                                           --
-- required       :                                                                                --
--                                                                                                 --
-- Behaviour      :                                                                                --
--                                                                                                 --
-----------------------------------------------------------------------------------------------------
FUNCTION getActualEnergy(p_object_id VARCHAR2, p_strm_set VARCHAR2, p_daytime DATE)

RETURN NUMBER
--</EC-DOC>
IS

ln_actual_energy NUMBER;
lv2_class_name VARCHAR2(32);

CURSOR c_actual_prod_fcty_1 IS
SELECT SUM(EcBp_Stream_Fluid.findEnergy(sv.object_id,p_daytime)) energy
FROM strm_set_list ssl, strm_version sv
WHERE sv.op_fcty_class_1_id = p_object_id
AND p_daytime >= ssl.from_date AND (p_daytime < ssl.end_date OR ssl.end_date IS NULL)
AND p_daytime >= sv.daytime AND (p_daytime < sv.end_date OR sv.end_date IS NULL)
AND ssl.stream_set = p_strm_set
AND sv.object_id = ssl.object_id;

CURSOR c_actual_prod_fcty_2 IS
SELECT SUM(EcBp_Stream_Fluid.findEnergy(sv.object_id,p_daytime)) energy
FROM strm_set_list ssl, strm_version sv
WHERE sv.op_fcty_class_2_id = p_object_id
AND p_daytime >= ssl.from_date AND (p_daytime < ssl.end_date OR ssl.end_date IS NULL)
AND p_daytime >= sv.daytime AND (p_daytime < sv.end_date OR sv.end_date IS NULL)
AND ssl.stream_set = p_strm_set
AND sv.object_id = ssl.object_id;

CURSOR c_actual_prod_sub_area IS
SELECT Ue_Defer_Summary.getActualEnergy(p_object_id, p_strm_set, p_daytime) energy
FROM dual;

BEGIN
  lv2_class_name := EcDp_Objects.getObjClassName(p_object_id);

  IF lv2_class_name = 'FCTY_CLASS_1' THEN
    FOR mycur IN c_actual_prod_fcty_1 LOOP
      ln_actual_energy := mycur.energy;
    END LOOP;
  ELSIF lv2_class_name = 'FCTY_CLASS_2' THEN
    FOR mycur IN c_actual_prod_fcty_2 LOOP
      ln_actual_energy := mycur.energy;
    END LOOP;
  ELSIF lv2_class_name = 'SUB_AREA' THEN
    FOR mycur IN c_actual_prod_sub_area LOOP
      ln_actual_energy := mycur.energy;
    END LOOP;
  ELSE
    NULL;
  END IF;

  RETURN ln_actual_energy;

END getActualEnergy;

END EcBp_Defer_Summary;