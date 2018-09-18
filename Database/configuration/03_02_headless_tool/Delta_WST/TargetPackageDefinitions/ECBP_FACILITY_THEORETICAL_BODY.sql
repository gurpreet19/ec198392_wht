CREATE OR REPLACE PACKAGE BODY EcBp_Facility_Theoretical IS
/****************************************************************
** Package        :  EcBp_Facility_Theoretical, body part
**
** $Revision: 1.16.2.1 $
**
** Purpose        :  Provides theoretical fluid values (rates etc)
**	                  for a given facility.
**
** Documentation  :  www.energy-components.com
**
** Created  : 14.01.2000  Carl-Fredrik Sørensen
**
** Modification history:
**
** Version  Date     Whom  Change description:
** -------  ------   ----- --------------------------------------
** 1.0   	  14.01.00 CFS   Initial version
** 1.1		  03.03.00 GNO   Added calcFacilityOilDay and calcFacilityGasDay
** 3.1      14.06.00 AV    Changed parameters in call to EcBp_Well_Theoretical
** 4.0      07.07.00 DN    Added calcTotFlowlineStdRateDay.
** 4.1      15.05.01 DN    Added calcPlatformPhaseStdVolPeriod and calcSubseaPhaseStdVolPeriod
** 4.2      09.01.02 UMF   Added calcFacilityCondDay
**          25.05.04 FBa   Removed references to EcBp_Flowline_Theoretical
**          10.08.04 Toha  Removed sysnam and facility and made changes as necessary.
**         28.12.2005 bohhhron Add new function
**                             calcFacilityWatInjDay
**                             calcFacilityGasInjDay
**                             calcFacilitySteamInjDay
**                             calcFacilityGasLiftDay
**                             calcFacilityDiluentDay
**			       Update the old cursor for better performance.
**          09.01.06 Lau  3027 - theoretical includes well not in allocation
**                         remove dead codes
**          04.09.2008 rajarsar ECPD-9038:Added calcFacilityCO2Day.
**          23.09.2008 farhaann ECPD-7728:Replaced  with w.proc_node_<phase>_id
**          16.12.2008 oonnnng  ECPD-10317: Add new functions calcFacilityOilMassDay, calcFacilityGasMassDay, calcFacilityWatMassDay.
**          30.12.2008 sharawan ECPD-10416:Replaced all references to EcDp_Type.pb_comp_number%TYPE with NUMBER in functions
**                              calcPlatformPhaseStdVolPeriod, calcSubseaPhaseStdVolPeriod, calcFacilityWatDay, calcFacilityOilDay, calcFacilityGasDay,
**                              calcFacilityCondDay, calcFacilityWatInjDay, calcFacilityGasInjDay, calcFacilitySteamInjDay, calcFacilityGasLiftDay,
**                              calcFacilityDiluentDay, calcFacilityCO2Day, calcFacilityOilMassDay, calcFacilityGasMassDay, calcFacilityWatMassDay.
**          15.01.2009 aliassit ECPD-10563: Add new functions to calculate sum theoretical independent on proc_node_id_XXX
**          14.03.2009 rajarsar ECPD-9038: Updated calcFacilityCo2day to use  proc_node_co2_id and added calcfacilityCO2InjDay and calcSumOperFacilityCO2InjDay
**          14.02.2012 syazwnur ECPD-17880: Added checking on Well Active Status for functions CalcFacilityWatDay up to calcSumOperFacilityWatMassDay.
**          13.07.2012 musthram ECPD-21503: Added calcFacililtyCondMass and calcSumOperFacilityCondMassDay
*****************************************************************/

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : calcPlatformPhaseStdVolPeriod                                                --
-- Description    : Returns total theoretical standard phase volume for only platform wells      --
--                  on a given facility and periods of day.                                      --
--                                                                                               --
-- Preconditions  : Only days without time is allowed, 'To date' included.                       --
--                  All parameteres are required.                                                --
-- Postconditions :                                                                              --
--                                                                                               --
-- Using tables   :                                                                              --
--                                                                                               --
-- Using functions:                                                                              --
--                                                                                               --
-- Configuration                                                                                 --
-- required       :                                                                              --
--                                                                                               --
-- Behaviour      :                                                                              --
--                                                                                               --
---------------------------------------------------------------------------------------------------
FUNCTION calcPlatformPhaseStdVolPeriod(
    p_object_id       production_facility.object_id%TYPE,
    p_from_date    DATE,
    p_to_date      DATE,
    p_phase    VARCHAR2)

RETURN NUMBER
--</EC-DOC>
IS
ln_return_sum NUMBER;
ln_phase_val NUMBER;

-- Get all distinct active producing flowlines
CURSOR c_platform_wells IS
SELECT pds.*
FROM pwel_day_status pds, well_version wv, well w
WHERE pds.object_id = wv.object_id
AND wv.object_id = w.object_id
AND pds.daytime BETWEEN p_from_date AND p_to_date
AND wv.op_fcty_class_1_id = p_object_id
AND wv.alloc_flag = 'Y'
AND pds.daytime BETWEEN wv.daytime AND Nvl(wv.end_date, pds.daytime)
AND w.template_no IS NOT NULL;

BEGIN

   IF p_phase = EcDp_Phase.OIL THEN

      FOR thisrow IN c_platform_wells LOOP

         ln_phase_val := EcBp_Well_Theoretical.getOilStdRateDay(thisrow.object_id,
                                                                thisrow.daytime);
         IF ln_phase_val IS NOT NULL THEN -- Only deal with real values

            ln_return_sum := Nvl(ln_return_sum,0) + ln_phase_val;

         END IF;

      END LOOP;

   ELSIF p_phase = EcDp_Phase.GAS THEN

      FOR thisrow IN c_platform_wells LOOP

         ln_phase_val := EcBp_Well_Theoretical.getGasStdRateDay(thisrow.object_id,
                                                                thisrow.daytime);
         IF ln_phase_val IS NOT NULL THEN -- Only deal with real values

            ln_return_sum := Nvl(ln_return_sum,0) + ln_phase_val;

         END IF;

      END LOOP;

   ELSIF p_phase = EcDp_Phase.WATER THEN

      FOR thisrow IN c_platform_wells LOOP

         ln_phase_val := EcBp_Well_Theoretical.getWatStdRateDay(thisrow.object_id,
                                                                thisrow.daytime);
         IF ln_phase_val IS NOT NULL THEN -- Only deal with real values

            ln_return_sum := Nvl(ln_return_sum,0) + ln_phase_val;

         END IF;

      END LOOP;

   END IF;

   RETURN ln_return_sum;

END calcPlatformPhaseStdVolPeriod;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : calcSubseaPhaseStdVolPeriod                                                  --
-- Description    : Returns total theoretical standard phase volume for only platform wells      --
--                  on a given facility and periods of day.                                      --
--                                                                                               --
-- Preconditions  : Only days without time is allowed, 'To date' included.                       --
--                  All parameteres are required.                                                --
-- Postconditions :                                                                              --
--                                                                                               --
-- Using tables   :                                                                              --
--                                                                                               --
-- Using functions:                                                                              --
--                                                                                               --
-- Configuration                                                                                 --
-- required       :                                                                              --
--                                                                                               --
-- Behaviour      :                                                                              --
--                                                                                               --
---------------------------------------------------------------------------------------------------
FUNCTION calcSubseaPhaseStdVolPeriod(
    p_object_id       production_facility.object_id%TYPE,
    p_from_date    DATE,
    p_to_date      DATE,
    p_phase    VARCHAR2)

RETURN NUMBER
--</EC-DOC>
IS

ln_return_sum NUMBER;
ln_phase_val NUMBER;

-- Get all distinct active producing flowlines
CURSOR c_subsea_wells IS
SELECT pds.*
FROM pwel_day_status pds, well_version wv, well w
WHERE pds.object_id = wv.object_id
AND wv.object_id = w.object_id
AND pds.daytime BETWEEN p_from_date AND p_to_date
AND wv.op_fcty_class_1_id = p_object_id
AND wv.alloc_flag = 'Y'
AND pds.daytime BETWEEN wv.daytime AND Nvl(wv.end_date, pds.daytime)
AND w.template_no IS NOT NULL;

BEGIN

   IF p_phase = EcDp_Phase.OIL THEN

      FOR thisrow IN c_subsea_wells LOOP

         ln_phase_val := EcBp_Well_Theoretical.getOilStdRateDay(thisrow.object_id,
                                                                thisrow.daytime);
         IF ln_phase_val IS NOT NULL THEN -- Only deal with real values

            ln_return_sum := Nvl(ln_return_sum,0) + ln_phase_val;

         END IF;

      END LOOP;

   ELSIF p_phase = EcDp_Phase.GAS THEN

      FOR thisrow IN c_subsea_wells LOOP

         ln_phase_val := EcBp_Well_Theoretical.getGasStdRateDay(thisrow.object_id,
                                                                thisrow.daytime);
         IF ln_phase_val IS NOT NULL THEN -- Only deal with real values

            ln_return_sum := Nvl(ln_return_sum,0) + ln_phase_val;

         END IF;

      END LOOP;

   ELSIF p_phase = EcDp_Phase.WATER THEN

      FOR thisrow IN c_subsea_wells LOOP

         ln_phase_val := EcBp_Well_Theoretical.getWatStdRateDay(thisrow.object_id,
                                                                thisrow.daytime);
         IF ln_phase_val IS NOT NULL THEN -- Only deal with real values

            ln_return_sum := Nvl(ln_return_sum,0) + ln_phase_val;

         END IF;

      END LOOP;

   END IF;

   RETURN ln_return_sum;

END calcSubseaPhaseStdVolPeriod;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : calcFacilityWatDay                                                           --
-- Description    : Returns total theoretical water for a given facility and day.                --
--                                                                                               --
-- Preconditions  :                                                                              --
-- Postconditions :                                                                              --
--                                                                                               --
-- Using tables   : pwel_day_status                                                              --
--                                                                                               --
-- Using functions: EcBp_Well_Theoretical.getWatStdRateDay                                       --
--                                                                                               --
-- Configuration                                                                                 --
-- required       :                                                                              --
--                                                                                               --
-- Behaviour      :                                                                              --
--                                                                                               --
---------------------------------------------------------------------------------------------------
FUNCTION calcFacilityWatDay(
    p_object_id       production_facility.object_id%TYPE,
    p_daytime  DATE)

RETURN NUMBER
--</EC-DOC>
IS

CURSOR c_day_water IS
SELECT Sum(EcBp_Well_Theoretical.getWatStdRateDay(
          w.object_id,
					s.daytime)) sum_water
FROM   well_version w, system_days s
WHERE  w.proc_node_water_id = p_object_id
AND    w.alloc_flag = 'Y'
AND    s.daytime between w.daytime and nvl(w.end_date-1,p_daytime)
AND    nvl(ec_pwel_period_status.active_well_status(w.object_id,p_daytime,'EVENT','<='),'OPEN')<> 'CLOSED_LT'
AND    s.daytime = p_daytime;


ln_return_value NUMBER;

BEGIN

   FOR mycur IN c_day_water LOOP

   	ln_return_value := mycur.sum_water;

   END LOOP;

   RETURN ln_return_value;

END calcFacilityWatDay;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : calcFacilityOilDay                                                           --
-- Description    : Returns total theoretical oil for a given facility and day.                  --
--                                                                                               --
-- Preconditions  :                                                                              --
-- Postconditions :                                                                              --
--                                                                                               --
-- Using tables   : pwel_day_status                                                              --
--                                                                                               --
-- Using functions: EcBp_Well_Theoretical.getOilStdRateDay                                       --
--                                                                                               --
-- Configuration                                                                                 --
-- required       :                                                                              --
--                                                                                               --
-- Behaviour      :                                                                              --
--                                                                                               --
---------------------------------------------------------------------------------------------------
FUNCTION calcFacilityOilDay(
    p_object_id       production_facility.object_id%TYPE,
    p_daytime  DATE)

RETURN NUMBER
--</EC-DOC>
IS

CURSOR c_day_oil IS
SELECT Sum(EcBp_Well_Theoretical.getOilStdRateDay(
          w.object_id,
					s.daytime)) sum_oil
FROM   well_version w, system_days s
WHERE  w.proc_node_oil_id = p_object_id
AND    w.alloc_flag = 'Y'
AND    s.daytime between w.daytime and nvl(w.end_date-1,p_daytime)
AND    nvl(ec_pwel_period_status.active_well_status(w.object_id,p_daytime,'EVENT','<='),'OPEN')<> 'CLOSED_LT'
AND    s.daytime = p_daytime;


ln_return_value NUMBER;

BEGIN

   FOR mycur IN c_day_oil LOOP

   	ln_return_value := mycur.sum_oil;

   END LOOP;

   RETURN ln_return_value;

END calcFacilityOilDay;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : calcFacilityGasDay                                                           --
-- Description    : Returns total theoretical gas for a given facility and day.                  --
--                                                                                               --
-- Preconditions  :                                                                              --
-- Postconditions :                                                                              --
--                                                                                               --
-- Using tables   : pwel_day_status                                                              --
--                                                                                               --
-- Using functions: EcBp_Well_Theoretical.getGasStdRateDay                                       --
--                                                                                               --
-- Configuration                                                                                 --
-- required       :                                                                              --
--                                                                                               --
-- Behaviour      :                                                                              --
--                                                                                               --
---------------------------------------------------------------------------------------------------
FUNCTION calcFacilityGasDay(
    p_object_id       production_facility.object_id%TYPE,
    p_daytime  DATE)

RETURN NUMBER
--</EC-DOC>
IS

CURSOR c_day_gas IS
SELECT Sum(EcBp_Well_Theoretical.getGasStdRateDay(
          w.object_id,
					s.daytime)) sum_gas
FROM   well_version w, system_days s
WHERE  w.proc_node_gas_id = p_object_id
AND    w.alloc_flag = 'Y'
AND    s.daytime between w.daytime and nvl(w.end_date-1,p_daytime)
AND    nvl(ec_pwel_period_status.active_well_status(w.object_id,p_daytime,'EVENT','<='),'OPEN')<> 'CLOSED_LT'
AND    s.daytime = p_daytime;


ln_return_value NUMBER;

BEGIN

   FOR mycur IN c_day_gas LOOP

   	ln_return_value := mycur.sum_gas;

   END LOOP;

   RETURN ln_return_value;

END calcFacilityGasDay;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : calcFacilityCondDay                                                           --
-- Description    : Returns total theoretical gas for a given facility and day.                  --
--                                                                                               --
-- Preconditions  :                                                                              --
-- Postconditions :                                                                              --
--                                                                                               --
-- Using tables   : pwel_day_status                                                              --
--                                                                                               --
-- Using functions: EcBp_Well_Theoretical.getCondStdRateDay                                       --
--                                                                                               --
-- Configuration                                                                                 --
-- required       :                                                                              --
--                                                                                               --
-- Behaviour      :                                                                              --
--                                                                                               --
---------------------------------------------------------------------------------------------------
FUNCTION calcFacilityCondDay(
    p_object_id       production_facility.object_id%TYPE,
    p_daytime  DATE)

RETURN NUMBER
--</EC-DOC>
IS

CURSOR c_day_cond IS
SELECT Sum(EcBp_Well_Theoretical.getCondStdRateDay(
          w.object_id,
					s.daytime)) sum_cond
FROM   well_version w, system_days s
WHERE  w.proc_node_cond_id = p_object_id
AND    w.alloc_flag = 'Y'
AND    s.daytime between w.daytime and nvl(w.end_date-1,p_daytime)
AND    nvl(ec_pwel_period_status.active_well_status(w.object_id,p_daytime,'EVENT','<='),'OPEN')<> 'CLOSED_LT'
AND    s.daytime = p_daytime;


ln_return_value NUMBER;

BEGIN

   FOR mycur IN c_day_cond LOOP

   	ln_return_value := mycur.sum_cond;

   END LOOP;

   RETURN ln_return_value;

END calcFacilityCondDay;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : calcFacilityWatDay                                                           --
-- Description    : Returns total theoretical water for a given facility and day.                  --
--                                                                                               --
-- Preconditions  :                                                                              --
-- Postconditions :                                                                              --
--                                                                                               --
-- Using tables   : pwel_day_status                                                              --
--                                                                                               --
-- Using functions: EcBp_Well_Theoretical.getCondStdRateDay                                       --
--                                                                                               --
-- Configuration                                                                                 --
-- required       :                                                                              --
--                                                                                               --
-- Behaviour      :                                                                              --
--                                                                                               --
---------------------------------------------------------------------------------------------------
FUNCTION calcFacilityWatInjDay(
    p_object_id       production_facility.object_id%TYPE,
    p_daytime  DATE)

RETURN NUMBER
--</EC-DOC>
IS

CURSOR c_day_water_inj IS
SELECT Sum(EcBp_Well_Theoretical.getInjectedStdRateDay(
					w.object_id,
          'WI',
          s.daytime)) sum_water_inj
FROM   well_version w, system_days s
WHERE  w.proc_node_water_inj_id = p_object_id
AND    w.alloc_flag = 'Y'
AND    s.daytime between w.daytime and nvl(w.end_date-1,p_daytime)
AND    nvl(ec_iwel_period_status.active_well_status(w.object_id,p_daytime,'WI','EVENT','<='),'OPEN')<> 'CLOSED_LT'
AND    s.daytime = p_daytime;

ln_return_value NUMBER;

BEGIN

   FOR mycur IN c_day_water_inj LOOP

   	ln_return_value := mycur.sum_water_inj;

   END LOOP;

   RETURN ln_return_value;

END calcFacilityWatInjDay;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : calcFacilityGasInjDay                                                      --
-- Description    : Returns total theoretical gas injection for a given facility and day.     --
--                                                                                               --
-- Preconditions  :                                                                              --
-- Postconditions :                                                                              --
--                                                                                               --
-- Using tables   : iwel_day_status                                                              --
--                                                                                               --
-- Using functions: EcBp_Well_Theoretical.getInjectedStdRateDay                                       --
--                                                                                               --
-- Configuration                                                                                 --
-- required       :                                                                              --
--                                                                                               --
-- Behaviour      :                                                                              --
--                                                                                               --
---------------------------------------------------------------------------------------------------
FUNCTION calcFacilityGasInjDay(
    p_object_id       production_facility.object_id%TYPE,
    p_daytime  DATE)

RETURN NUMBER
--</EC-DOC>
IS

CURSOR c_day_gas_inj IS
SELECT Sum(EcBp_Well_Theoretical.getInjectedStdRateDay(
					w.object_id,
          'GI',
          s.daytime)) sum_gas_inj
FROM   well_version w, system_days s
WHERE  w.proc_node_gas_inj_id = p_object_id
AND    w.alloc_flag = 'Y'
AND    s.daytime between w.daytime and nvl(w.end_date-1,p_daytime)
AND    nvl(ec_iwel_period_status.active_well_status(w.object_id,p_daytime,'GI','EVENT','<='),'OPEN')<> 'CLOSED_LT'
AND    s.daytime = p_daytime;

ln_return_value NUMBER;

BEGIN

   FOR mycur IN c_day_gas_inj LOOP

   	ln_return_value := mycur.sum_gas_inj;

   END LOOP;

   RETURN ln_return_value;

END calcFacilityGasInjDay;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : calcFacilitySteamInjDay                                                    --
-- Description    : Returns total theoretical steam injection for a given facility and day.   --
--                                                                                               --
-- Preconditions  :                                                                              --
-- Postconditions :                                                                              --
--                                                                                               --
-- Using tables   : iwel_day_status                                                              --
--                                                                                               --
-- Using functions: EcBp_Well_Theoretical.getInjectedStdRateDay                                       --
--                                                                                               --
-- Configuration                                                                                 --
-- required       :                                                                              --
--                                                                                               --
-- Behaviour      :                                                                              --
--                                                                                               --
---------------------------------------------------------------------------------------------------
FUNCTION calcFacilitySteamInjDay(
    p_object_id       production_facility.object_id%TYPE,
    p_daytime  DATE)

RETURN NUMBER
--</EC-DOC>
IS

CURSOR c_day_steam_inj IS
SELECT Sum(EcBp_Well_Theoretical.getInjectedStdRateDay(
					w.object_id,
          'SI',
          s.daytime)) sum_steam_inj
FROM   well_version w, system_days s
WHERE  w.proc_node_steam_inj_id = p_object_id
AND    w.alloc_flag = 'Y'
AND    s.daytime between w.daytime and nvl(w.end_date-1,p_daytime)
AND    nvl(ec_iwel_period_status.active_well_status(w.object_id,p_daytime,'SI','EVENT','<='),'OPEN')<> 'CLOSED_LT'
AND    s.daytime = p_daytime;

ln_return_value NUMBER;

BEGIN

   FOR mycur IN c_day_steam_inj LOOP

   	ln_return_value := mycur.sum_steam_inj;

   END LOOP;

   RETURN ln_return_value;

END calcFacilitySteamInjDay;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : calcFacilityGasLiftDay                                                     --
-- Description    : Returns total theoretical gas lift for a given facility and day.          --
--                                                                                               --
-- Preconditions  :                                                                              --
-- Postconditions :                                                                              --
--                                                                                               --
-- Using tables   : pwel_day_status                                                              --
--                                                                                               --
-- Using functions: EcBp_Well_Theoretical.getGasLiftStdRateDay                                   --
--                                                                                               --
-- Configuration                                                                                 --
-- required       :                                                                              --
--                                                                                               --
-- Behaviour      :                                                                              --
--                                                                                               --
---------------------------------------------------------------------------------------------------
FUNCTION calcFacilityGasLiftDay(
    p_object_id       production_facility.object_id%TYPE,
    p_daytime  DATE)

RETURN NUMBER
--</EC-DOC>
IS

CURSOR c_day_gas_lift IS
SELECT Sum(EcBp_Well_Theoretical.getGasLiftStdRateDay(
          w.object_id,
					s.daytime)) sum_gas_lift
FROM   well_version w, system_days s
WHERE  w.proc_node_gas_lift_id = p_object_id
AND    w.alloc_flag = 'Y'
AND    s.daytime between w.daytime and nvl(w.end_date-1,p_daytime)
AND    nvl(ec_pwel_period_status.active_well_status(w.object_id,p_daytime,'EVENT','<='),'OPEN')<> 'CLOSED_LT'
AND    s.daytime = p_daytime;

ln_return_value NUMBER;

BEGIN

   FOR mycur IN c_day_gas_lift LOOP

   	ln_return_value := mycur.sum_gas_lift;

   END LOOP;

   RETURN ln_return_value;

END calcFacilityGasLiftDay;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : calcFacilityDiluentDay                                                     --
-- Description    : Returns total theoretical diluent for a given facility and day.           --
--                                                                                               --
-- Preconditions  :                                                                              --
-- Postconditions :                                                                              --
--                                                                                               --
-- Using tables   : pwel_day_status                                                              --
--                                                                                               --
-- Using functions: EcBp_Well_Theoretical.getDiluentStdRateDay                                   --
--                                                                                               --
-- Configuration                                                                                 --
-- required       :                                                                              --
--                                                                                               --
-- Behaviour      :                                                                              --
--                                                                                               --
---------------------------------------------------------------------------------------------------
FUNCTION calcFacilityDiluentDay(
    p_object_id       production_facility.object_id%TYPE,
    p_daytime  DATE)

RETURN NUMBER
--</EC-DOC>
IS

CURSOR c_day_diluent IS
SELECT Sum(EcBp_Well_Theoretical.getDiluentStdRateDay(
          w.object_id,
					s.daytime)) sum_diluent
FROM   well_version w, system_days s
WHERE  w.proc_node_diluent_id = p_object_id
AND    w.alloc_flag = 'Y'
AND    s.daytime between w.daytime and nvl(w.end_date-1,p_daytime)
AND    nvl(ec_pwel_period_status.active_well_status(w.object_id,p_daytime,'EVENT','<='),'OPEN')<> 'CLOSED_LT'
AND    s.daytime = p_daytime;

ln_return_value NUMBER;

BEGIN

   FOR mycur IN c_day_diluent LOOP

   	ln_return_value := mycur.sum_diluent;

   END LOOP;

   RETURN ln_return_value;

END calcFacilityDiluentDay;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : calcFacilityCO2Day                                                           --
-- Description    : Returns total theoretical CO2 for a given facility and day.                  --
--                                                                                               --
-- Preconditions  :                                                                              --
-- Postconditions :                                                                              --
--                                                                                               --
-- Using tables   : pwel_day_status                                                              --
--                                                                                               --
-- Using functions: EcBp_Well_Theoretical.getCO2StdRateDay                                       --
--                                                                                               --
-- Configuration                                                                                 --
-- required       :                                                                              --
--                                                                                               --
-- Behaviour      :                                                                              --
--                                                                                               --
---------------------------------------------------------------------------------------------------
FUNCTION calcFacilityCO2Day(
    p_object_id       production_facility.object_id%TYPE,
    p_daytime  DATE)

RETURN NUMBER
--</EC-DOC>
IS

CURSOR c_day_co2 IS
SELECT Sum(EcBp_Well_Theoretical.getCO2StdRateDay(
          w.object_id,
					s.daytime)) sum_co2
FROM   well_version w, system_days s
WHERE  w.proc_node_co2_id = p_object_id
AND    w.alloc_flag = 'Y'
AND    s.daytime between w.daytime and nvl(w.end_date-1,p_daytime)
AND    nvl(ec_pwel_period_status.active_well_status(w.object_id,p_daytime,'EVENT','<='),'OPEN')<> 'CLOSED_LT'
AND    s.daytime = p_daytime;


ln_return_value NUMBER;

BEGIN

   FOR mycur IN c_day_co2 LOOP

   	ln_return_value := mycur.sum_co2;

   END LOOP;

   RETURN ln_return_value;

END calcFacilityCO2Day;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : calcFacilityCO2InjDay                                                           --
-- Description    : Returns total theoretical CO2 Injection for a given facility and day.                  --
--                                                                                               --
-- Preconditions  :                                                                              --
-- Postconditions :                                                                              --
--                                                                                               --
-- Using tables   :                                                             --
--                                                                                               --
-- Using functions: EcBp_Well_Theoretical.getInjectedStdRateDay                                       --
--                                                                                               --
-- Configuration                                                                                 --
-- required       :                                                                              --
--                                                                                               --
-- Behaviour      :                                                                              --
--                                                                                               --
---------------------------------------------------------------------------------------------------
FUNCTION calcFacilityCO2InjDay(
    p_object_id       production_facility.object_id%TYPE,
    p_daytime  DATE)

RETURN NUMBER
--</EC-DOC>
IS

CURSOR c_day_co2 IS
SELECT Sum(EcBp_Well_Theoretical.getInjectedStdRateDay(
					w.object_id,
          'CI',
          s.daytime)) sum_co2_inj
FROM   well_version w, system_days s
WHERE  w.proc_node_co2_inj_id = p_object_id
AND    w.alloc_flag = 'Y'
AND    s.daytime between w.daytime and nvl(w.end_date-1,p_daytime)
AND    nvl(ec_iwel_period_status.active_well_status(w.object_id,p_daytime,'CI','EVENT','<='),'OPEN')<> 'CLOSED_LT'
AND    s.daytime = p_daytime;


ln_return_value NUMBER;

BEGIN

   FOR mycur IN c_day_co2 LOOP

   	ln_return_value := mycur.sum_co2_inj;

   END LOOP;

   RETURN ln_return_value;

END calcFacilityCO2InjDay;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : calcFacilityOilMassDay                                                       --
-- Description    : Returns total theoretical oil mass for a given facility and day.             --
--                                                                                               --
-- Preconditions  :                                                                              --
-- Postconditions :                                                                              --
--                                                                                               --
-- Using tables   : pwel_day_status                                                              --
--                                                                                               --
-- Using functions: EcBp_Well_Theoretical.findOilMassDay                                         --
--                                                                                               --
-- Configuration                                                                                 --
-- required       :                                                                              --
--                                                                                               --
-- Behaviour      :                                                                              --
--                                                                                               --
---------------------------------------------------------------------------------------------------
FUNCTION calcFacilityOilMassDay(
    p_object_id       production_facility.object_id%TYPE,
    p_daytime  DATE)

RETURN NUMBER
--</EC-DOC>
IS

CURSOR c_day_oil_mass IS
SELECT Sum(EcBp_Well_Theoretical.findOilMassDay(
          w.object_id,
					s.daytime)) sum_oil_mass
FROM   well_version w, system_days s
WHERE  w.proc_node_oil_id = p_object_id
AND    w.alloc_flag = 'Y'
AND    s.daytime between w.daytime and nvl(w.end_date-1,p_daytime)
AND    nvl(ec_pwel_period_status.active_well_status(w.object_id,p_daytime,'EVENT','<='),'OPEN')<> 'CLOSED_LT'
AND    s.daytime = p_daytime;


ln_return_value NUMBER;

BEGIN

   FOR mycur IN c_day_oil_mass LOOP

   	ln_return_value := mycur.sum_oil_mass;

   END LOOP;

   RETURN ln_return_value;

END calcFacilityOilMassDay;



--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : calcFacilityGasMassDay                                                       --
-- Description    : Returns total theoretical gas mass for a given facility and day.             --
--                                                                                               --
-- Preconditions  :                                                                              --
-- Postconditions :                                                                              --
--                                                                                               --
-- Using tables   : pwel_day_status                                                              --
--                                                                                               --
-- Using functions: EcBp_Well_Theoretical.findGasMassDay                                         --
--                                                                                               --
-- Configuration                                                                                 --
-- required       :                                                                              --
--                                                                                               --
-- Behaviour      :                                                                              --
--                                                                                               --
---------------------------------------------------------------------------------------------------
FUNCTION calcFacilityGasMassDay(
    p_object_id       production_facility.object_id%TYPE,
    p_daytime  DATE)

RETURN NUMBER
--</EC-DOC>
IS

CURSOR c_day_gas_mass IS
SELECT Sum(EcBp_Well_Theoretical.findGasMassDay(
          w.object_id,
					s.daytime)) sum_gas_mass
FROM   well_version w, system_days s
WHERE  w.proc_node_gas_id = p_object_id
AND    w.alloc_flag = 'Y'
AND    s.daytime between w.daytime and nvl(w.end_date-1,p_daytime)
AND    nvl(ec_pwel_period_status.active_well_status(w.object_id,p_daytime,'EVENT','<='),'OPEN')<> 'CLOSED_LT'
AND    s.daytime = p_daytime;


ln_return_value NUMBER;

BEGIN

   FOR mycur IN c_day_gas_mass LOOP

   	ln_return_value := mycur.sum_gas_mass;

   END LOOP;

   RETURN ln_return_value;

END calcFacilityGasMassDay;



--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : calcFacilityWatMassDay                                                       --
-- Description    : Returns total theoretical water mass for a given facility and day.           --
--                                                                                               --
-- Preconditions  :                                                                              --
-- Postconditions :                                                                              --
--                                                                                               --
-- Using tables   : pwel_day_status                                                              --
--                                                                                               --
-- Using functions: EcBp_Well_Theoretical.findWaterMassDay                                       --
--                                                                                               --
-- Configuration                                                                                 --
-- required       :                                                                              --
--                                                                                               --
-- Behaviour      :                                                                              --
--                                                                                               --
---------------------------------------------------------------------------------------------------
FUNCTION calcFacilityWatMassDay(
    p_object_id       production_facility.object_id%TYPE,
    p_daytime  DATE)

RETURN NUMBER
--</EC-DOC>
IS

CURSOR c_day_wat_mass IS
SELECT Sum(EcBp_Well_Theoretical.findWaterMassDay(
          w.object_id,
					s.daytime)) sum_wat_mass
FROM   well_version w, system_days s
WHERE  w.proc_node_water_id = p_object_id
AND    w.alloc_flag = 'Y'
AND    s.daytime between w.daytime and nvl(w.end_date-1,p_daytime)
AND    nvl(ec_pwel_period_status.active_well_status(w.object_id,p_daytime,'EVENT','<='),'OPEN')<> 'CLOSED_LT'
AND    s.daytime = p_daytime;


ln_return_value NUMBER;

BEGIN

   FOR mycur IN c_day_wat_mass LOOP

   	ln_return_value := mycur.sum_wat_mass;

   END LOOP;

   RETURN ln_return_value;

END calcFacilityWatMassDay;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : calcFacilityCondMassDay                                                       --
-- Description    : Returns total theoretical cond mass for a given facility and day.           --
--                                                                                               --
-- Preconditions  :                                                                              --
-- Postconditions :                                                                              --
--                                                                                               --
-- Using tables   : pwel_day_status                                                              --
--                                                                                               --
-- Using functions: EcBp_Well_Theoretical.findCondMassDay                                       --
--                                                                                               --
-- Configuration                                                                                 --
-- required       :                                                                              --
--                                                                                               --
-- Behaviour      :                                                                              --
--                                                                                               --
---------------------------------------------------------------------------------------------------
FUNCTION calcFacilityCondMassDay(
    p_object_id       production_facility.object_id%TYPE,
    p_daytime  DATE)

RETURN NUMBER
--</EC-DOC>
IS

CURSOR c_day_cond_mass IS
SELECT Sum(EcBp_Well_Theoretical.findCondMassDay(
          w.object_id,
					s.daytime)) sum_cond_mass
FROM   well_version w, system_days s
WHERE  w.proc_node_cond_id = p_object_id
AND    w.alloc_flag = 'Y'
AND    s.daytime between w.daytime and nvl(w.end_date-1,p_daytime)
AND    nvl(ec_pwel_period_status.active_well_status(w.object_id,p_daytime,'EVENT','<='),'OPEN')<> 'CLOSED_LT'
AND    s.daytime = p_daytime;


ln_return_value NUMBER;

BEGIN

   FOR mycur IN c_day_cond_mass LOOP

   	ln_return_value := mycur.sum_cond_mass;

   END LOOP;

   RETURN ln_return_value;

END calcFacilityCondMassDay;



--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : calcSumOperFacilityWatDay                                                    --
-- Description    : Returns total theoretical water for a given facility and day.                --
--                  independent on proc_node_water_id                                            --
-- Preconditions  :                                                                              --
-- Postconditions :                                                                              --
--                                                                                               --
-- Using tables   : pwel_day_status                                                              --
--                                                                                               --
-- Using functions: EcBp_Well_Theoretical.getWatStdRateDay                                       --
--                                                                                               --
-- Configuration                                                                                 --
-- required       :                                                                              --
--                                                                                               --
-- Behaviour      :                                                                              --
--                                                                                               --
---------------------------------------------------------------------------------------------------
FUNCTION calcSumOperFacilityWatDay(
    p_object_id       production_facility.object_id%TYPE,
    p_daytime  DATE)

RETURN NUMBER
--</EC-DOC>
IS

CURSOR c_day_water IS
SELECT Sum(EcBp_Well_Theoretical.getWatStdRateDay(
          w.object_id,
					s.daytime)) sum_water
FROM   well_version w, system_days s
WHERE  w.op_fcty_class_1_id = p_object_id
AND    w.alloc_flag = 'Y'
AND    s.daytime between w.daytime and nvl(w.end_date-1,p_daytime)
AND    nvl(ec_pwel_period_status.active_well_status(w.object_id,p_daytime,'EVENT','<='),'OPEN')<> 'CLOSED_LT'
AND    s.daytime = p_daytime;


ln_return_value NUMBER;

BEGIN

   FOR mycur IN c_day_water LOOP

   	ln_return_value := mycur.sum_water;

   END LOOP;

   RETURN ln_return_value;

END calcSumOperFacilityWatDay;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : calcSumOperFacilityOilDay                                                    --
-- Description    : Returns total theoretical oil for a given facility and day.                  --
--                  independent on proc_node_oil_id                                              --
-- Preconditions  :                                                                              --
-- Postconditions :                                                                              --
--                                                                                               --
-- Using tables   : pwel_day_status                                                              --
--                                                                                               --
-- Using functions: EcBp_Well_Theoretical.getOilStdRateDay                                       --
--                                                                                               --
-- Configuration                                                                                 --
-- required       :                                                                              --
--                                                                                               --
-- Behaviour      :                                                                              --
--                                                                                               --
---------------------------------------------------------------------------------------------------
FUNCTION calcSumOperFacilityOilDay(
    p_object_id       production_facility.object_id%TYPE,
    p_daytime  DATE)

RETURN NUMBER
--</EC-DOC>
IS

CURSOR c_day_oil IS
SELECT Sum(EcBp_Well_Theoretical.getOilStdRateDay(
          w.object_id,
					s.daytime)) sum_oil
FROM   well_version w, system_days s
WHERE  w.op_fcty_class_1_id = p_object_id
AND    w.alloc_flag = 'Y'
AND    s.daytime between w.daytime and nvl(w.end_date-1,p_daytime)
AND    nvl(ec_pwel_period_status.active_well_status(w.object_id,p_daytime,'EVENT','<='),'OPEN')<> 'CLOSED_LT'
AND    s.daytime = p_daytime;


ln_return_value NUMBER;

BEGIN

   FOR mycur IN c_day_oil LOOP

   	ln_return_value := mycur.sum_oil;

   END LOOP;

   RETURN ln_return_value;

END calcSumOperFacilityOilDay;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : calcSumOperFacilityGasDay                                                    --
-- Description    : Returns total theoretical gas for a given facility and day.                  --
--                  independent on proc_node_gas_id                                              --
-- Preconditions  :                                                                              --
-- Postconditions :                                                                              --
--                                                                                               --
-- Using tables   : pwel_day_status                                                              --
--                                                                                               --
-- Using functions: EcBp_Well_Theoretical.getGasStdRateDay                                       --
--                                                                                               --
-- Configuration                                                                                 --
-- required       :                                                                              --
--                                                                                               --
-- Behaviour      :                                                                              --
--                                                                                               --
---------------------------------------------------------------------------------------------------
FUNCTION calcSumOperFacilityGasDay(
    p_object_id       production_facility.object_id%TYPE,
    p_daytime  DATE)

RETURN NUMBER
--</EC-DOC>
IS

CURSOR c_day_gas IS
SELECT Sum(EcBp_Well_Theoretical.getGasStdRateDay(
          w.object_id,
					s.daytime)) sum_gas
FROM   well_version w, system_days s
WHERE  w.op_fcty_class_1_id = p_object_id
AND    w.alloc_flag = 'Y'
AND    s.daytime between w.daytime and nvl(w.end_date-1,p_daytime)
AND    nvl(ec_pwel_period_status.active_well_status(w.object_id,p_daytime,'EVENT','<='),'OPEN')<> 'CLOSED_LT'
AND    s.daytime = p_daytime;


ln_return_value NUMBER;

BEGIN

   FOR mycur IN c_day_gas LOOP

   	ln_return_value := mycur.sum_gas;

   END LOOP;

   RETURN ln_return_value;

END calcSumOperFacilityGasDay;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : calcSumOperFacilityCondDay                                                   --
-- Description    : Returns total theoretical gas for a given facility and day.                  --
--                  independent on proc_node_cond_id                                             --
-- Preconditions  :                                                                              --
-- Postconditions :                                                                              --
--                                                                                               --
-- Using tables   : pwel_day_status                                                              --
--                                                                                               --
-- Using functions: EcBp_Well_Theoretical.getCondStdRateDay                                      --
--                                                                                               --
-- Configuration                                                                                 --
-- required       :                                                                              --
--                                                                                               --
-- Behaviour      :                                                                              --
--                                                                                               --
---------------------------------------------------------------------------------------------------
FUNCTION calcSumOperFacilityCondDay(
    p_object_id       production_facility.object_id%TYPE,
    p_daytime  DATE)

RETURN NUMBER
--</EC-DOC>
IS

CURSOR c_day_cond IS
SELECT Sum(EcBp_Well_Theoretical.getCondStdRateDay(
          w.object_id,
					s.daytime)) sum_cond
FROM   well_version w, system_days s
WHERE  w.op_fcty_class_1_id = p_object_id
AND    w.alloc_flag = 'Y'
AND    s.daytime between w.daytime and nvl(w.end_date-1,p_daytime)
AND    nvl(ec_pwel_period_status.active_well_status(w.object_id,p_daytime,'EVENT','<='),'OPEN')<> 'CLOSED_LT'
AND    s.daytime = p_daytime;


ln_return_value NUMBER;

BEGIN

   FOR mycur IN c_day_cond LOOP

   	ln_return_value := mycur.sum_cond;

   END LOOP;

   RETURN ln_return_value;

END calcSumOperFacilityCondDay;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : calcSumOperFacilityWatDay                                                    --
-- Description    : Returns total theoretical water for a given facility and day.                --
--                  independent from proc_node_water_inj_id                                      --
-- Preconditions  :                                                                              --
-- Postconditions :                                                                              --
--                                                                                               --
-- Using tables   : pwel_day_status                                                              --
--                                                                                               --
-- Using functions: EcBp_Well_Theoretical.getCondStdRateDay                                      --
--                                                                                               --
-- Configuration                                                                                 --
-- required       :                                                                              --
--                                                                                               --
-- Behaviour      :                                                                              --
--                                                                                               --
---------------------------------------------------------------------------------------------------
FUNCTION calcSumOperFacilityWatInjDay(
    p_object_id       production_facility.object_id%TYPE,
    p_daytime  DATE)

RETURN NUMBER
--</EC-DOC>
IS

CURSOR c_day_water_inj IS
SELECT Sum(EcBp_Well_Theoretical.getInjectedStdRateDay(
					w.object_id,
          'WI',
          s.daytime)) sum_water_inj
FROM   well_version w, system_days s
WHERE  w.op_fcty_class_1_id = p_object_id
AND    w.alloc_flag = 'Y'
AND    s.daytime between w.daytime and nvl(w.end_date-1,p_daytime)
AND    nvl(ec_iwel_period_status.active_well_status(w.object_id,p_daytime,'WI','EVENT','<='),'OPEN')<> 'CLOSED_LT'
AND    s.daytime = p_daytime;

ln_return_value NUMBER;

BEGIN

   FOR mycur IN c_day_water_inj LOOP

   	ln_return_value := mycur.sum_water_inj;

   END LOOP;

   RETURN ln_return_value;

END calcSumOperFacilityWatInjDay;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : calcSumOperFacilityGasInjDay                                                 --
-- Description    : Returns total theoretical gas injection for a given facility and day.        --
--                  independent on proc_node_gas_inj_id                                          --
-- Preconditions  :                                                                              --
-- Postconditions :                                                                              --
--                                                                                               --
-- Using tables   : iwel_day_status                                                              --
--                                                                                               --
-- Using functions: EcBp_Well_Theoretical.getInjectedStdRateDay                                  --
--                                                                                               --
-- Configuration                                                                                 --
-- required       :                                                                              --
--                                                                                               --
-- Behaviour      :                                                                              --
--                                                                                               --
---------------------------------------------------------------------------------------------------
FUNCTION calcSumOperFacilityGasInjDay(
    p_object_id       production_facility.object_id%TYPE,
    p_daytime  DATE)

RETURN NUMBER
--</EC-DOC>
IS

CURSOR c_day_gas_inj IS
SELECT Sum(EcBp_Well_Theoretical.getInjectedStdRateDay(
					w.object_id,
          'GI',
          s.daytime)) sum_gas_inj
FROM   well_version w, system_days s
WHERE  w.op_fcty_class_1_id = p_object_id
AND    w.alloc_flag = 'Y'
AND    s.daytime between w.daytime and nvl(w.end_date-1,p_daytime)
AND    nvl(ec_iwel_period_status.active_well_status(w.object_id,p_daytime,'GI','EVENT','<='),'OPEN')<> 'CLOSED_LT'
AND    s.daytime = p_daytime;

ln_return_value NUMBER;

BEGIN

   FOR mycur IN c_day_gas_inj LOOP

   	ln_return_value := mycur.sum_gas_inj;

   END LOOP;

   RETURN ln_return_value;

END calcSumOperFacilityGasInjDay;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : calcSumOperFacilitySteamInjDay                                               --
-- Description    : Returns total theoretical steam injection for a given facility and day.      --
--                  independent on proc_node_steam_inj_id                                        --
-- Preconditions  :                                                                              --
-- Postconditions :                                                                              --
--                                                                                               --
-- Using tables   : iwel_day_status                                                              --
--                                                                                               --
-- Using functions: EcBp_Well_Theoretical.getInjectedStdRateDay                                  --
--                                                                                               --
-- Configuration                                                                                 --
-- required       :                                                                              --
--                                                                                               --
-- Behaviour      :                                                                              --
--                                                                                               --
---------------------------------------------------------------------------------------------------
FUNCTION calcSumOperFacilitySteamInjDay(
    p_object_id       production_facility.object_id%TYPE,
    p_daytime  DATE)

RETURN NUMBER
--</EC-DOC>
IS

CURSOR c_day_steam_inj IS
SELECT Sum(EcBp_Well_Theoretical.getInjectedStdRateDay(
					w.object_id,
          'SI',
          s.daytime)) sum_steam_inj
FROM   well_version w, system_days s
WHERE  w.op_fcty_class_1_id = p_object_id
AND    w.alloc_flag = 'Y'
AND    s.daytime between w.daytime and nvl(w.end_date-1,p_daytime)
AND    nvl(ec_iwel_period_status.active_well_status(w.object_id,p_daytime,'SI','EVENT','<='),'OPEN')<> 'CLOSED_LT'
AND    s.daytime = p_daytime;

ln_return_value NUMBER;

BEGIN

   FOR mycur IN c_day_steam_inj LOOP

   	ln_return_value := mycur.sum_steam_inj;

   END LOOP;

   RETURN ln_return_value;

END calcSumOperFacilitySteamInjDay;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : calcSumOperFacilityGasLiftDay                                                --
-- Description    : Returns total theoretical gas lift for a given facility and day.             --
--                  independent on proc_node_gas_lift_id                                         --
-- Preconditions  :                                                                              --
-- Postconditions :                                                                              --
--                                                                                               --
-- Using tables   : pwel_day_status                                                              --
--                                                                                               --
-- Using functions: EcBp_Well_Theoretical.getGasLiftStdRateDay                                   --
--                                                                                               --
-- Configuration                                                                                 --
-- required       :                                                                              --
--                                                                                               --
-- Behaviour      :                                                                              --
--                                                                                               --
---------------------------------------------------------------------------------------------------
FUNCTION calcSumOperFacilityGasLiftDay(
    p_object_id       production_facility.object_id%TYPE,
    p_daytime  DATE)

RETURN NUMBER
--</EC-DOC>
IS

CURSOR c_day_gas_lift IS
SELECT Sum(EcBp_Well_Theoretical.getGasLiftStdRateDay(
          w.object_id,
					s.daytime)) sum_gas_lift
FROM   well_version w, system_days s
WHERE  w.op_fcty_class_1_id = p_object_id
AND    w.alloc_flag = 'Y'
AND    s.daytime between w.daytime and nvl(w.end_date-1,p_daytime)
AND    nvl(ec_pwel_period_status.active_well_status(w.object_id,p_daytime,'EVENT','<='),'OPEN')<> 'CLOSED_LT'
AND    s.daytime = p_daytime;

ln_return_value NUMBER;

BEGIN

   FOR mycur IN c_day_gas_lift LOOP

   	ln_return_value := mycur.sum_gas_lift;

   END LOOP;

   RETURN ln_return_value;

END calcSumOperFacilityGasLiftDay;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : calcSumOperFacilityDiluentDay                                                --
-- Description    : Returns total theoretical diluent for a given facility and day.              --
--                  independent on proc_node_diluent_id                                          --
-- Preconditions  :                                                                              --
-- Postconditions :                                                                              --
--                                                                                               --
-- Using tables   : pwel_day_status                                                              --
--                                                                                               --
-- Using functions: EcBp_Well_Theoretical.getDiluentStdRateDay                                   --
--                                                                                               --
-- Configuration                                                                                 --
-- required       :                                                                              --
--                                                                                               --
-- Behaviour      :                                                                              --
--                                                                                               --
---------------------------------------------------------------------------------------------------
FUNCTION calcSumOperFacilityDiluentDay(
    p_object_id       production_facility.object_id%TYPE,
    p_daytime  DATE)

RETURN NUMBER
--</EC-DOC>
IS

CURSOR c_day_diluent IS
SELECT Sum(EcBp_Well_Theoretical.getDiluentStdRateDay(
          w.object_id,
					s.daytime)) sum_diluent
FROM   well_version w, system_days s
WHERE  w.op_fcty_class_1_id = p_object_id
AND    w.alloc_flag = 'Y'
AND    s.daytime between w.daytime and nvl(w.end_date-1,p_daytime)
AND    nvl(ec_pwel_period_status.active_well_status(w.object_id,p_daytime,'EVENT','<='),'OPEN')<> 'CLOSED_LT'
AND    s.daytime = p_daytime;

ln_return_value NUMBER;

BEGIN

   FOR mycur IN c_day_diluent LOOP

   	ln_return_value := mycur.sum_diluent;

   END LOOP;

   RETURN ln_return_value;

END calcSumOperFacilityDiluentDay;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : calcSumOperFacilityCO2Day                                                    --
-- Description    : Returns total theoretical CO2 for a given facility and day.                  --
--                  independent on proc_node_co2_id                                          --
-- Preconditions  :                                                                              --
-- Postconditions :                                                                              --
--                                                                                               --
-- Using tables   : pwel_day_status                                                              --
--                                                                                               --
-- Using functions: EcBp_Well_Theoretical.getCO2StdRateDay                                       --
--                                                                                               --
-- Configuration                                                                                 --
-- required       :                                                                              --
--                                                                                               --
-- Behaviour      :                                                                              --
--                                                                                               --
---------------------------------------------------------------------------------------------------
FUNCTION calcSumOperFacilityCO2Day(
    p_object_id       production_facility.object_id%TYPE,
    p_daytime  DATE)

RETURN NUMBER
--</EC-DOC>
IS

CURSOR c_day_co2 IS
SELECT Sum(EcBp_Well_Theoretical.getCO2StdRateDay(
          w.object_id,
					s.daytime)) sum_co2
FROM   well_version w, system_days s
WHERE  w.op_fcty_class_1_id = p_object_id
AND    w.alloc_flag = 'Y'
AND    s.daytime between w.daytime and nvl(w.end_date-1,p_daytime)
AND    nvl(ec_pwel_period_status.active_well_status(w.object_id,p_daytime,'EVENT','<='),'OPEN')<> 'CLOSED_LT'
AND    s.daytime = p_daytime;


ln_return_value NUMBER;

BEGIN

   FOR mycur IN c_day_co2 LOOP

   	ln_return_value := mycur.sum_co2;

   END LOOP;

   RETURN ln_return_value;

END calcSumOperFacilityCO2Day;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : calcSumOperFacilityCO2InjDay                                                 --
-- Description    : Returns total theoretical co2 injection for a given facility and day.        --
--                  independent on proc_node_co2_inj_id                                          --
-- Preconditions  :                                                                              --
-- Postconditions :                                                                              --
--                                                                                               --
-- Using tables   : iwel_day_status                                                              --
--                                                                                               --
-- Using functions: EcBp_Well_Theoretical.getInjectedStdRateDay                                  --
--                                                                                               --
-- Configuration                                                                                 --
-- required       :                                                                              --
--                                                                                               --
-- Behaviour      :                                                                              --
--                                                                                               --
---------------------------------------------------------------------------------------------------
FUNCTION calcSumOperFacilityCO2InjDay(
    p_object_id       production_facility.object_id%TYPE,
    p_daytime  DATE)

RETURN NUMBER
--</EC-DOC>
IS

CURSOR c_day_co2_inj IS
SELECT Sum(EcBp_Well_Theoretical.getInjectedStdRateDay(
					w.object_id,
          'CI',
          s.daytime)) sum_co2_inj
FROM   well_version w, system_days s
WHERE  w.op_fcty_class_1_id = p_object_id
AND    w.alloc_flag = 'Y'
AND    s.daytime between w.daytime and nvl(w.end_date-1,p_daytime)
AND    nvl(ec_iwel_period_status.active_well_status(w.object_id,p_daytime,'CI','EVENT','<='),'OPEN')<> 'CLOSED_LT'
AND    s.daytime = p_daytime;

ln_return_value NUMBER;

BEGIN

   FOR mycur IN c_day_co2_inj LOOP

   	ln_return_value := mycur.sum_co2_inj;

   END LOOP;

   RETURN ln_return_value;

END calcSumOperFacilityCO2InjDay;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : calcSumOperFacilityOilMassDay                                                --
-- Description    : Returns total theoretical oil mass for a given facility and day.             --
--                  independent on proc_node_oil_id                                              --
-- Preconditions  :                                                                              --
-- Postconditions :                                                                              --
--                                                                                               --
-- Using tables   : pwel_day_status                                                              --
--                                                                                               --
-- Using functions: EcBp_Well_Theoretical.findOilMassDay                                         --
--                                                                                               --
-- Configuration                                                                                 --
-- required       :                                                                              --
--                                                                                               --
-- Behaviour      :                                                                              --
--                                                                                               --
---------------------------------------------------------------------------------------------------
FUNCTION calcSumOperFacilityOilMassDay(
    p_object_id       production_facility.object_id%TYPE,
    p_daytime  DATE)

RETURN NUMBER
--</EC-DOC>
IS

CURSOR c_day_oil_mass IS
SELECT Sum(EcBp_Well_Theoretical.findOilMassDay(
          w.object_id,
					s.daytime)) sum_oil_mass
FROM   well_version w, system_days s
WHERE  w.op_fcty_class_1_id = p_object_id
AND    w.alloc_flag = 'Y'
AND    s.daytime between w.daytime and nvl(w.end_date-1,p_daytime)
AND    nvl(ec_pwel_period_status.active_well_status(w.object_id,p_daytime,'EVENT','<='),'OPEN')<> 'CLOSED_LT'
AND    s.daytime = p_daytime;


ln_return_value NUMBER;

BEGIN

   FOR mycur IN c_day_oil_mass LOOP

   	ln_return_value := mycur.sum_oil_mass;

   END LOOP;

   RETURN ln_return_value;

END calcSumOperFacilityOilMassDay;



--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : calcSumOperFacilityGasMassDay                                                --
-- Description    : Returns total theoretical gas mass for a given facility and day.             --
--                  independent on proc_node_gas_id                                              --
-- Preconditions  :                                                                              --
-- Postconditions :                                                                              --
--                                                                                               --
-- Using tables   : pwel_day_status                                                              --
--                                                                                               --
-- Using functions: EcBp_Well_Theoretical.findGasMassDay                                         --
--                                                                                               --
-- Configuration                                                                                 --
-- required       :                                                                              --
--                                                                                               --
-- Behaviour      :                                                                              --
--                                                                                               --
---------------------------------------------------------------------------------------------------
FUNCTION calcSumOperFacilityGasMassDay(
    p_object_id       production_facility.object_id%TYPE,
    p_daytime  DATE)

RETURN NUMBER
--</EC-DOC>
IS

CURSOR c_day_gas_mass IS
SELECT Sum(EcBp_Well_Theoretical.findGasMassDay(
          w.object_id,
					s.daytime)) sum_gas_mass
FROM   well_version w, system_days s
WHERE  w.op_fcty_class_1_id = p_object_id
AND    w.alloc_flag = 'Y'
AND    s.daytime between w.daytime and nvl(w.end_date-1,p_daytime)
AND    nvl(ec_pwel_period_status.active_well_status(w.object_id,p_daytime,'EVENT','<='),'OPEN')<> 'CLOSED_LT'
AND    s.daytime = p_daytime;


ln_return_value NUMBER;

BEGIN

   FOR mycur IN c_day_gas_mass LOOP

   	ln_return_value := mycur.sum_gas_mass;

   END LOOP;

   RETURN ln_return_value;

END calcSumOperFacilityGasMassDay;



--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : calcSumOperFacilityWatMassDay                                                --
-- Description    : Returns total theoretical water mass for a given facility and day.           --
--                  independent on proc_node_water_id                                            --
-- Preconditions  :                                                                              --
-- Postconditions :                                                                              --
--                                                                                               --
-- Using tables   : pwel_day_status                                                              --
--                                                                                               --
-- Using functions: EcBp_Well_Theoretical.findWaterMassDay                                       --
--                                                                                               --
-- Configuration                                                                                 --
-- required       :                                                                              --
--                                                                                               --
-- Behaviour      :                                                                              --
--                                                                                               --
---------------------------------------------------------------------------------------------------
FUNCTION calcSumOperFacilityWatMassDay(
    p_object_id       production_facility.object_id%TYPE,
    p_daytime  DATE)

RETURN NUMBER
--</EC-DOC>
IS

CURSOR c_day_wat_mass IS
SELECT Sum(EcBp_Well_Theoretical.findWaterMassDay(
          w.object_id,
					s.daytime)) sum_wat_mass
FROM   well_version w, system_days s
WHERE  w.op_fcty_class_1_id = p_object_id
AND    w.alloc_flag = 'Y'
AND    s.daytime between w.daytime and nvl(w.end_date-1,p_daytime)
AND    nvl(ec_pwel_period_status.active_well_status(w.object_id,p_daytime,'EVENT','<='),'OPEN')<> 'CLOSED_LT'
AND    s.daytime = p_daytime;


ln_return_value NUMBER;

BEGIN

   FOR mycur IN c_day_wat_mass LOOP

   	ln_return_value := mycur.sum_wat_mass;

   END LOOP;

   RETURN ln_return_value;

END calcSumOperFacilityWatMassDay;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : calcSumOperFacilityCondMassDay                                                --
-- Description    : Returns total theoretical cond mass for a given facility and day.           --
--                  independent on proc_node_water_id                                            --
-- Preconditions  :                                                                              --
-- Postconditions :                                                                              --
--                                                                                               --
-- Using tables   : pwel_day_status                                                              --
--                                                                                               --
-- Using functions: EcBp_Well_Theoretical.findCondMassDay                                       --
--                                                                                               --
-- Configuration                                                                                 --
-- required       :                                                                              --
--                                                                                               --
-- Behaviour      :                                                                              --
--                                                                                               --
---------------------------------------------------------------------------------------------------
FUNCTION calcSumOperFacilityCondMassDay(
    p_object_id       production_facility.object_id%TYPE,
    p_daytime  DATE)

RETURN NUMBER
--</EC-DOC>
IS

CURSOR c_day_cond_mass IS
SELECT Sum(EcBp_Well_Theoretical.findCondMassDay(
          w.object_id,
					s.daytime)) sum_cond_mass
FROM   well_version w, system_days s
WHERE  w.op_fcty_class_1_id = p_object_id
AND    w.alloc_flag = 'Y'
AND    s.daytime between w.daytime and nvl(w.end_date-1,p_daytime)
AND    nvl(ec_pwel_period_status.active_well_status(w.object_id,p_daytime,'EVENT','<='),'OPEN')<> 'CLOSED_LT'
AND    s.daytime = p_daytime;


ln_return_value NUMBER;

BEGIN

   FOR mycur IN c_day_cond_mass LOOP

   	ln_return_value := mycur.sum_cond_mass;

   END LOOP;

   RETURN ln_return_value;

END calcSumOperFacilityCondMassDay;

END;