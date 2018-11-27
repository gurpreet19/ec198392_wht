CREATE OR REPLACE PACKAGE BODY EcBp_Facility_Theoretical IS
/****************************************************************
** Package        :  EcBp_Facility_Theoretical, body part
**
** $Revision: 1.22 $
**
** Purpose        :  Provides theoretical fluid values (rates etc)
**	                  for a given facility.
**
** Documentation  :  www.energy-components.com
**
** Created  : 14.01.2000  Carl-Fredrik S�sen
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
**          17.07.2012 musthram ECPD-21375: Added calcFacililtyCondMass and calcSumOperFacilityCondMassDay
**        	29.04.2013 rajarsar ECPD-23618: Added getFacilityPhaseStdVolDay
**          09.05.2013 rajarsar ECPD-23618: Added getFacilityPhaseFactorDay
**          16.10.2014 shindani ECPD-23618: Modified getFacilityPhaseStdVolDay function.
**          19.10.2015 dhavaalo ECPD-26566: Added getFacilityPhaseVolMonth
**          28.10.2015 dhavaalo ECPD-32519: Modified getFacilityPhaseVolMonth for performance improvement
**          29.10.2015 kashisag ECPD-32498: Added getFacilityPhaseVolDay
**          24.11.2015 dhavaalo ECPD-32891: Modified getFacilityPhaseVolDay,getFacilityPhaseVolMonth to consider official flag
**          06.07.2016 jainnraj ECPD-36978: Modified getFacilityPhaseVolMonth,getFacilityPhaseVolDay to change official column to official_ind
**          15.03.2017 kashisag ECPD-42996: Modified getFacilityPhaseVolMonth,getFacilityPhaseVolDay to add logic for planned methods
**          09.06.2017 khatrnit ECPD-45823: Modified getFacilityPhaseVolMonth,getFacilityPhaseVolDay to modify logic for FORECAST_PROD planned method and to rectify the stream sets used for calculating daily actual volume
**          01.03.2018 singishi ECPD-51137: Removed all the references for low and off deferment screen
**          16.04.2018 kashisag ECPD-53238: Updated daily and monthly functions for actual and planned widgets e.g. getFacilityPhaseVolMonth
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

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getFacilityPhaseStdVolDay                                                    --
-- Description    : Returns total volume for planned, actual, deferred and unassigned deferred   --
--                                                             --
-- Preconditions  :                                                                              --
-- Postconditions :                                                                              --
--                                                                                               --
-- Using tables   :                                                               --
--                                                                                               --
-- Using functions:                                      --
--                                                                                               --
-- Configuration                                                                                 --
-- required       :                                                                              --
--                                                                                               --
-- Behaviour      :                                                                              --
--                                                                                               --
---------------------------------------------------------------------------------------------------
FUNCTION getFacilityPhaseStdVolDay(p_object_id    VARCHAR2,
                          p_daytime      DATE,
                          p_type  VARCHAR2,
                          p_phase VARCHAR2)
RETURN NUMBER
--</EC-DOC>
IS
   lv2_defer_version    VARCHAR2(32);
   ln_ret_val NUMBER;

BEGIN

  lv2_defer_version := ec_ctrl_system_attribute.attribute_text(p_daytime,'DEFERMENT_VERSION','<=');
  If p_type = 'DEFERRED' THEN
    IF lv2_defer_version = 'PD.0004' THEN
      ln_ret_val := EcBp_Defer_Summary.GetAssignedDeferVolumes(p_object_id,p_phase,p_daytime);
	ELSIF lv2_defer_version = 'PD.0020' THEN
      ln_ret_val := EcBp_Deferment.GetAssignedDeferVolumes(p_object_id,p_phase,p_daytime);
    END IF;
  ELSIF p_type = 'PLANNED' THEN
    IF lv2_defer_version = 'PD.0004' THEN
      ln_ret_val:= EcBp_Defer_Summary.GetPlannedVolumes(p_object_id,p_phase,p_daytime);
	ELSIF lv2_defer_version = 'PD.0020' THEN
      ln_ret_val:=EcBp_Deferment.GetPlannedVolumes(p_object_id,p_phase,p_daytime);
    END IF;
  ELSIF p_type = 'ACTUAL' THEN
    IF lv2_defer_version = 'PD.0004' THEN
      ln_ret_val:= EcBp_Defer_Summary.GetActualVolumes(p_object_id,p_phase,p_daytime);
    ELSIF lv2_defer_version = 'PD.0020' THEN
      ln_ret_val:=EcBp_Deferment.GetActualVolumes(p_object_id,p_phase,p_daytime);
    END IF;
  ELSIF p_type = 'UNACCT_DEFERRED' THEN
    IF lv2_defer_version = 'PD.0004' THEN
      ln_ret_val := EcBp_Defer_Summary.GetPlannedVolumes(p_object_id,p_phase,p_daytime)- EcBp_Defer_Summary.GetActualVolumes(p_object_id,p_phase,p_daytime) -  EcBp_Defer_Summary.GetAssignedDeferVolumes(p_object_id,p_phase,p_daytime);
    ELSIF lv2_defer_version = 'PD.0020' THEN
      ln_ret_val :=EcBp_Deferment.GetPlannedVolumes(p_object_id,p_phase,p_daytime) - EcBp_Deferment.GetActualVolumes(p_object_id,p_phase,
	  p_daytime) -  EcBp_Deferment.GetAssignedDeferVolumes(p_object_id,p_phase,p_daytime);
    END IF;
  END IF;

  RETURN ln_ret_val;

END getFacilityPhaseStdVolDay;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getFacilityPhaseFactorDay                                                    --
-- Description    : Returns reconciliation factor per phase, per facility, for a day.                                           --
--                                                                                               --
-- Preconditions  :                                                                              --
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
FUNCTION getFacilityPhaseFactorDay(p_object_id    VARCHAR2,
                          p_daytime      DATE,
                          p_phase VARCHAR2)
RETURN NUMBER
--</EC-DOC>
IS
   ln_total_theor_vol  NUMBER;
   ln_total_alloc_vol NUMBER;
   ln_ret_val NUMBER;

CURSOR c_day_vol IS
   SELECT sum(decode(p_phase,
   'OIL',(nvl(pda.alloc_net_oil_vol,0) + nvl(pda.alloc_cond_vol,0)),
   'WATER',pda.alloc_water_vol,
   'GAS',pda.alloc_gas_vol,
   'COND',pda.alloc_cond_vol)) sum_alloc_vol,
   sum(decode(p_phase,
   'OIL',(nvl(pda.theor_net_oil_rate,0) + nvl(pda.theor_cond_rate,0)),
   'WATER',pda.theor_water_rate,
   'GAS',pda.theor_gas_rate,
   'COND',pda.theor_cond_rate)) sum_theor_vol
   FROM well_version w, pwel_day_alloc pda
   WHERE  w.object_id = pda.object_id
   AND w.op_fcty_class_1_id = p_object_id
   AND w.alloc_flag = 'Y'
   AND pda.daytime between w.daytime and nvl(w.end_date-1,p_daytime)
   AND pda.daytime = p_daytime;

BEGIN
   ln_ret_val := ue_facility_theoretical.getFacilityPhaseFactorDay(p_object_id,p_daytime,p_phase);
   IF ln_ret_val IS NULL THEN
     FOR cur_day_vol IN c_day_vol LOOP
       ln_total_alloc_vol := cur_day_vol.sum_alloc_vol;
       ln_total_theor_vol  := cur_day_vol.sum_theor_vol;
     END LOOP;
     IF ln_total_alloc_vol > 0 AND ln_total_theor_vol> 0 THEN
       ln_ret_val := ln_total_alloc_vol/ln_total_theor_vol;
     END IF;
   END IF;
   RETURN ln_ret_val;

END getFacilityPhaseFactorDay;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getFacilityPhaseVolMonth                                                    --
-- Description    : Returns Actual,Planned volume per phase, per facility, for a month.                                           --
--                                                                                               --
-- Preconditions  :                                                                              --
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
FUNCTION getFacilityPhaseVolMonth(p_object_id VARCHAR2,
                                  p_daytime        DATE,
                                  p_type           VARCHAR2,
                                  p_phase          VARCHAR2) RETURN NUMBER
--</EC-DOC>
 IS

   ln_ret_vol   NUMBER;

BEGIN

	-- GET PLANNED METHOD FOR FACILITY

	IF p_type = 'PLANNED' THEN --Planned volume

	 ln_ret_vol := EcBp_Deferment.getMthPlannedVolumes(p_object_id,p_phase,p_daytime);
     RETURN ln_ret_vol;

	ELSIF p_type = 'ACTUAL' THEN -- Actual Volume

     ln_ret_vol := EcBp_Deferment.getMthActualVolumes(p_object_id,p_phase,p_daytime);
     RETURN ln_ret_vol;

	END IF;

END getFacilityPhaseVolMonth;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getFacilityPhaseVolDay                                                    --
-- Description    : Returns total volume for planned, actual                                     --
--                                                             --
-- Preconditions  :                                                                              --
-- Postconditions :                                                                              --
--                                                                                               --
-- Using tables   :                                                               --
--                                                                                               --
-- Using functions:                                      --
--                                                                                               --
-- Configuration                                                                                 --
-- required       :                                                                              --
--                                                                                               --
-- Behaviour      :                                                                              --
--                                                                                               --
---------------------------------------------------------------------------------------------------
FUNCTION getFacilityPhaseVolDay(p_object_id    VARCHAR2,
                          p_daytime      DATE,
                          p_type  VARCHAR2,
                          p_phase VARCHAR2)
RETURN NUMBER
--</EC-DOC>
IS
    ln_ret_actual_vol NUMBER;
    ln_ret_plan_vol   NUMBER;
	lv2_plan_method   VARCHAR2(32);

BEGIN
  IF p_type = 'PLANNED' THEN---Planned volume
    BEGIN

	    -- GET PLANNED METHOD FOR FACILITY
	    lv2_plan_method:= ec_fcty_version.prod_plan_method(p_object_id,p_daytime,'<=');


		IF lv2_plan_method = Ecdp_Calc_Method.BUDGET_PLAN THEN

          SELECT DECODE(p_phase,'OIL',ec_object_plan.oil_rate(p_object_id,p_daytime,'FCTY_PLAN_BUDGET', '<='),
		                        'GAS',ec_object_plan.gas_rate(p_object_id,p_daytime,'FCTY_PLAN_BUDGET', '<='),
								'WAT',ec_object_plan.water_rate(p_object_id,p_daytime,'FCTY_PLAN_BUDGET', '<='),
								'COND',ec_object_plan.cond_rate(p_object_id,p_daytime,'FCTY_PLAN_BUDGET', '<='))
          INTO   ln_ret_plan_vol
		  FROM   CTRL_DB_VERSION
		  WHERE  DB_VERSION = 1;

		ELSIF lv2_plan_method = Ecdp_Calc_Method.POTENTIAL_PLAN THEN

          SELECT DECODE(p_phase,'OIL',ec_object_plan.oil_rate(p_object_id,p_daytime,'FCTY_PLAN_POTENTIAL', '<='),
		                        'GAS',ec_object_plan.gas_rate(p_object_id,p_daytime,'FCTY_PLAN_POTENTIAL', '<='),
								'WAT',ec_object_plan.water_rate(p_object_id,p_daytime,'FCTY_PLAN_POTENTIAL', '<='),
								'COND',ec_object_plan.cond_rate(p_object_id,p_daytime,'FCTY_PLAN_POTENTIAL', '<='))
          INTO   ln_ret_plan_vol
		  FROM   CTRL_DB_VERSION
		  WHERE  DB_VERSION = 1;


		ELSIF lv2_plan_method = Ecdp_Calc_Method.TARGET_PLAN THEN

          SELECT DECODE(p_phase,'OIL',ec_object_plan.oil_rate(p_object_id,p_daytime,'FCTY_PLAN_TARGET', '<='),
		                        'GAS',ec_object_plan.gas_rate(p_object_id,p_daytime,'FCTY_PLAN_TARGET', '<='),
								'WAT',ec_object_plan.water_rate(p_object_id,p_daytime,'FCTY_PLAN_TARGET', '<='),
								'COND',ec_object_plan.cond_rate(p_object_id,p_daytime,'FCTY_PLAN_TARGET', '<='))
          INTO   ln_ret_plan_vol
		  FROM   CTRL_DB_VERSION
		  WHERE  DB_VERSION = 1;

		ELSIF lv2_plan_method = Ecdp_Calc_Method.OTHER_PLAN THEN

          SELECT DECODE(p_phase,'OIL',ec_object_plan.oil_rate(p_object_id,p_daytime,'FCTY_PLAN_OTHER', '<='),
		                        'GAS',ec_object_plan.gas_rate(p_object_id,p_daytime,'FCTY_PLAN_OTHER', '<='),
								'WAT',ec_object_plan.water_rate(p_object_id,p_daytime,'FCTY_PLAN_OTHER', '<='),
								'COND',ec_object_plan.cond_rate(p_object_id,p_daytime,'FCTY_PLAN_OTHER', '<='))
          INTO   ln_ret_plan_vol
		  FROM   CTRL_DB_VERSION
		  WHERE  DB_VERSION = 1;

		ELSIF lv2_plan_method = Ecdp_Calc_Method.FORECAST_PROD THEN

          SELECT DECODE(p_phase,'OIL',a.net_oil_rate,
                                'GAS',a.gas_rate,
                                'WAT',a.water_rate,
                                'COND',a.cond_rate)
           INTO ln_ret_plan_vol
           FROM FCST_FCTY_DAY a, FORECAST_VERSION b
          WHERE A.OBJECT_ID = p_object_id
            AND A.SCENARIO_ID = B.OBJECT_ID
            AND A.DAYTIME = (SELECT MAX(DAYTIME) FROM FCST_FCTY_DAY WHERE OBJECT_ID = p_object_id AND DAYTIME <= p_daytime)
            AND B.OFFICIAL_IND = 'Y';

        END IF;

    EXCEPTION
          WHEN NO_DATA_FOUND
             THEN ln_ret_plan_vol:= NULL;
    END ;

    RETURN ln_ret_plan_vol;

  ELSIF p_type = 'ACTUAL' THEN---Actual Volume
   BEGIN

        SELECT SUM(EcBp_Stream_Fluid.findNetStdVol(s.object_id, s.daytime))
        INTO ln_ret_actual_vol
        FROM STRM_DAY_STREAM s, STRM_VERSION sv
        WHERE s.object_id = sv.object_id
           and sv.op_fcty_class_1_id = p_object_id
           and s.daytime = p_daytime
           AND exists ( select 1
                        from strm_set_list
                        where s.object_id = strm_set_list.object_id
                        and stream_set = DECODE(p_phase,'OIL','PD.0005_04',
                                                        'GAS','PD.0005_02',
                                                        'WAT','PD.0005_07',
                                                        'COND','PD.0005')
                        and from_date <= s.DAYTIME
                        and nvl(end_date, s.DAYTIME + 1) > s.DAYTIME)
        AND sv.stream_phase = p_phase;

    EXCEPTION
          WHEN NO_DATA_FOUND
             THEN ln_ret_actual_vol:= NULL;
    END ;

    RETURN ln_ret_actual_vol;

  END IF;

END getFacilityPhaseVolDay;
--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getFacilityMassFactorDay                                                    --
-- Description    : Returns reconciliation factor per phase, per facility, for a day.                                           --
--                                                                                               --
-- Preconditions  :                                                                              --
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
FUNCTION getFacilityMassFactorDay(p_object_id    VARCHAR2,
                          p_daytime      DATE,
                          p_phase VARCHAR2)
RETURN NUMBER
--</EC-DOC>
IS
   ln_total_theor_mass  NUMBER;
   ln_total_alloc_mass NUMBER;
   ln_ret_val NUMBER;

CURSOR c_day_mass IS
   SELECT sum(decode(p_phase,
   'OIL',(nvl(pda.alloc_net_oil_mass,0) + nvl(pda.alloc_cond_mass,0)),
   'WATER',pda.alloc_water_mass,
   'GAS',pda.alloc_gas_mass,
   'COND',pda.alloc_cond_mass)) sum_alloc_mass,
   sum(decode(p_phase,
   'OIL',(nvl(pda.theor_net_oil_mass,0) + nvl(pda.theor_cond_mass,0)),
   'WATER',pda.theor_water_mass,
   'GAS',pda.theor_gas_mass,
   'COND',pda.theor_cond_mass)) sum_theor_mass
   FROM well_version w, pwel_day_alloc pda
   WHERE  w.object_id = pda.object_id
   AND w.op_fcty_class_1_id = p_object_id
   AND w.alloc_flag = 'Y'
   AND pda.daytime between w.daytime and nvl(w.end_date-1,p_daytime)
   AND pda.daytime = p_daytime;

BEGIN
   ln_ret_val := ue_facility_theoretical.getFacilityMassFactorDay(p_object_id,p_daytime,p_phase);
   IF ln_ret_val IS NULL THEN
     FOR cur_day_mass IN c_day_mass LOOP
       ln_total_alloc_mass := cur_day_mass.sum_alloc_mass;
       ln_total_theor_mass  := cur_day_mass.sum_theor_mass;
     END LOOP;
     IF ln_total_alloc_mass > 0 AND ln_total_theor_mass> 0 THEN
       ln_ret_val := ln_total_alloc_mass/ln_total_theor_mass;
     END IF;
   END IF;
   RETURN ln_ret_val;

END getFacilityMassFactorDay;
END;