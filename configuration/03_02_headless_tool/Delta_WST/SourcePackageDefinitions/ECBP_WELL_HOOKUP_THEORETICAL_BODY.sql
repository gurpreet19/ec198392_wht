CREATE OR REPLACE PACKAGE BODY EcBp_Well_Hookup_Theoretical IS

/****************************************************************
** Package        :  EcBp_Well_Hookup_Theoretical, body part
**
** $Revision: 1.18 $
**
** Purpose        :  Provides theoretical fluid values (rates etc)
**	                  for a given well hookup.
**
** Documentation  :  www.energy-components.com
**
** Created  : 06.08.2005  Jerome Chong
**
** Modification history:
**
** Version Date       Whom     Change description:
** ------- ---------- -------- ----------------------------------
** 1.0      06.08.2005 chongjer Initial version
**         28.12.2005 bohhhron Add new function
**                             calcWellHookupWatInjDay
**                             calcWellHookupGasInjDay
**                             calcWellHookupSteamInjDay
**                             calcWellHookupGasLiftDay
**                             calcWellHookupDiluentDay
**                             Update the old cursor for better performance.
**         09.01.2006 Lau     TI#3027 - Theoretical includes well not in allocation and remove dead codes
**     26.08.2008 aliassit ECPD-9080: Modified calcWellHookupWatDay, calcWellHookupOilDay, calcWellHookupGasDay, calcWellHookupCondDay
**     24.09.2008 aliassit ECPD-7728: Modified almost all the functions <phases> to replace w.op_well_hookup_id  with w.proc_node_<phases>)_id
**     29.08.2008 amirrasn ECPD-10156: Function calcWellHookupGasLiftDay: Added p_stream_id as a new parameter.
**                                      Added EcDp_Well.getPwelFracToStrmToNode() in cursor c_day_gas_lift.
**                                      Function calcWellHookupDiluentDay: Added p_stream_id as a new parameter.
**                                      Added EcDp_Well.getPwelFracToStrmToNode() in cursor c_day_diluent.
**     16.12.2008 oonnnng ECPD-10317: Add new functions calcWellHookupOilMassDay, calcWellHookupGasMassDay, and calcWellHookupWatMassDay.
**     31.12.2008 sharawan ECPD-10416:Replaced all references to EcDp_Type.pb_comp_number%TYPE with NUMBER in functions
**                         calcWellHookupWatDay, calcWellHookupGasDay, calcWellHookupCondDay, calcWellHookupWatInjDay, calcWellHookupGasInjDay,
**                         calcWellHookupSteamInjDay, calcWellHookupGasLiftDay, calcWellHookupDiluentDay, calcWellHookupOilMassDay, calcWellHookupGasMassDay, calcWellHookupWatMassDay.
**     15.01.2009 aliassit ECPD-10563: Add new functions to calculate sum theoretical independent on proc_node_id_XXX
**     14.03.2009 rajarsar ECPD-9038: Added calcWellHookupCO2InjDay, calcWellHookupCO2Day, calcSumOperWellHookCO2InjDay and calcSumOperWellHookCO2Day
**     26.03.2010 aliassit ECPD-11535: Modify calcWellHookupWatDay,calcWellHookupGasDay and calcWellHookupCondDay to handle new swing well functionality
**     22.05.2010 aliassit ECPD-14305: Fix swing well functionality in calcWellHookupWatDay,calcWellHookupGasDay and calcWellHookupCondDay
**     02.03.2011 syazwnur ECPD-16737: Added new functions calcWellHookupCondMassDay and calcSumOperWellHookCondMassDay.
**     26.04.2013 leongwen ECPD-23715: modified the function calcWellHookupWatDay and calcWellHookupCondDay
**     08.06.2015 ECPD-30691 Well hookup theoretical methods for stream formulae pass inactive wells
**     15.02.2017 singishi ECPD-43210: Added new function getWellHookPhaseFactorDay and getWellHookPhaseMassFactorDay to return the calculated factor for each phase.
*****************************************************************/

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : calcWellHookupWatDay                                                         --
-- Description    : Returns total theoretical water for a given well hookup and day.             --
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
FUNCTION calcWellHookupWatDay(
    p_object_id       well_hookup.object_id%TYPE,
    p_daytime  DATE,
    p_stream_id  VARCHAR2 DEFAULT NULL)

RETURN NUMBER
--</EC-DOC>
IS

CURSOR c_day_water IS
SELECT w.object_id, EcBp_Well_Theoretical.getWatStdRateDay(
          w.object_id,
          s.daytime)AS sum_water, w.calc_water_method calc_method
FROM   well_version w, system_days s
WHERE  w.proc_node_water_id = p_object_id
AND    w.alloc_flag = 'Y'
AND    s.daytime between w.daytime and nvl(w.end_date-1,p_daytime)
AND    nvl(ec_pwel_period_status.active_well_status(w.object_id,p_daytime,'EVENT','<='),'OPEN')<> 'CLOSED_LT'
AND    s.daytime = p_daytime;

ln_return_value NUMBER;
lb_first BOOLEAN;
lv2_to_node_id VARCHAR2(32);

BEGIN
   lv2_to_node_id := ec_strm_version.to_node_id(p_stream_id, p_daytime, '<=');
   lb_first := TRUE;
   FOR mycur IN c_day_water LOOP
     IF lb_first THEN
       lb_first := FALSE;
       IF mycur.calc_method = Ecdp_Calc_Method.MEAS_SWING_WELL THEN
         ln_return_value := Ecdp_Well_Swing_Theoretical.calcStreamWellDay(mycur.object_id,lv2_to_node_id, p_daytime, p_stream_id);
       ELSE
         ln_return_value := mycur.sum_water * Ecdp_Well.getPwelFracToStrmToNode(mycur.object_id,p_stream_id,p_daytime);
       END IF;
     ELSE
       IF mycur.calc_method = Ecdp_Calc_Method.MEAS_SWING_WELL THEN
         ln_return_value := ln_return_value + nvl(Ecdp_Well_Swing_Theoretical.calcStreamWellDay(mycur.object_id,lv2_to_node_id,p_daytime, p_stream_id),0);
       ELSE
         ln_return_value := ln_return_value + nvl((mycur.sum_water * Ecdp_Well.getPwelFracToStrmToNode(mycur.object_id,p_stream_id,p_daytime)),0);
       END IF;
     END IF;


   END LOOP;

   RETURN ln_return_value;



END calcWellHookupWatDay;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : calcWellHookupOilDay                                                         --
-- Description    : Returns total theoretical oil for a given well hookup and day.               --
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
FUNCTION calcWellHookupOilDay(
    p_object_id       well_hookup.object_id%TYPE,
    p_daytime  DATE,
    p_stream_id  VARCHAR2 DEFAULT NULL)

RETURN NUMBER
--</EC-DOC>
IS

  CURSOR c_day_oil IS
    SELECT Sum(EcBp_Well_Theoretical.getOilStdRateDay(w.object_id,
                                                      s.daytime) * EcDp_Well.getPwelFracToStrmToNode(w.object_id, p_stream_id, p_daytime)
                                                      ) sum_oil
      FROM well_version w, system_days s
     WHERE w.proc_node_oil_id = p_object_id
       AND w.alloc_flag = 'Y'
       AND s.daytime between w.daytime and nvl(w.end_date - 1, p_daytime)
	   AND    nvl(ec_pwel_period_status.active_well_status(w.object_id,p_daytime,'EVENT','<='),'OPEN')<> 'CLOSED_LT'
       AND s.daytime = p_daytime;


  ln_return_value NUMBER;

BEGIN

  FOR mycur IN c_day_oil LOOP

    ln_return_value := mycur.sum_oil;

  END LOOP;

  RETURN ln_return_value;

END calcWellHookupOilDay;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : calcWellHookupGasDay                                                         --
-- Description    : Returns total theoretical gas for a given well hookup and day.               --
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
FUNCTION calcWellHookupGasDay(
    p_object_id       well_hookup.object_id%TYPE,
    p_daytime  DATE,
    p_stream_id  VARCHAR2 DEFAULT NULL)

RETURN NUMBER
--</EC-DOC>
IS

CURSOR c_day_gas IS
SELECT w.object_id, EcBp_Well_Theoretical.getGasStdRateDay(
          w.object_id,
          s.daytime)AS sum_gas, w.calc_gas_method calc_method
FROM   well_version w, system_days s
WHERE  w.proc_node_gas_id = p_object_id
AND    w.alloc_flag = 'Y'
AND    s.daytime between w.daytime and nvl(w.end_date-1,p_daytime)
AND    nvl(ec_pwel_period_status.active_well_status(w.object_id,p_daytime,'EVENT','<='),'OPEN')<> 'CLOSED_LT'
AND    s.daytime = p_daytime;

ln_return_value NUMBER;
lb_first BOOLEAN;
lv2_to_node_id VARCHAR2(32);
BEGIN
   lb_first := TRUE;
   lv2_to_node_id := ec_strm_version.to_node_id(p_stream_id, p_daytime, '<=');
   lb_first := TRUE;
   FOR mycur IN c_day_gas LOOP
     IF lb_first THEN
       lb_first := FALSE;
       IF mycur.calc_method = Ecdp_Calc_Method.MEAS_SWING_WELL THEN
         ln_return_value := Ecdp_Well_Swing_Theoretical.calcStreamWellDay(mycur.object_id,lv2_to_node_id, p_daytime, p_stream_id);
       ELSE
         ln_return_value := mycur.sum_gas * Ecdp_Well.getPwelFracToStrmToNode(mycur.object_id,p_stream_id,p_daytime);
       END IF;
     ELSE
       IF mycur.calc_method = Ecdp_Calc_Method.MEAS_SWING_WELL THEN
         ln_return_value := ln_return_value + nvl(Ecdp_Well_Swing_Theoretical.calcStreamWellDay(mycur.object_id,lv2_to_node_id,p_daytime, p_stream_id),0);
       ELSE
         ln_return_value := ln_return_value + nvl((mycur.sum_gas * Ecdp_Well.getPwelFracToStrmToNode(mycur.object_id,p_stream_id,p_daytime)),0);
       END IF;
     END IF;

   END LOOP;

   RETURN ln_return_value;

END calcWellHookupGasDay;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : calcWellHookupCO2Day                                                         --
-- Description    : Returns total theoretical CO2 for a given well hookup and day.               --
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
FUNCTION calcWellHookupCO2Day(
    p_object_id       well_hookup.object_id%TYPE,
    p_daytime  DATE,
    p_stream_id  VARCHAR2 DEFAULT NULL)

RETURN NUMBER
--</EC-DOC>
IS

CURSOR c_day_co2 IS
SELECT Sum(EcBp_Well_Theoretical.getCO2StdRateDay(
          w.object_id,
          s.daytime)* EcDp_Well.getPwelFracToStrmToNode(w.object_id, p_stream_id, p_daytime)) sum_co2
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

END calcWellHookupCO2Day;



--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : calcWellHookupCondDay                                                        --
-- Description    : Returns total theoretical gas for a given well hookup and day.               --
--                                                                                               --
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
FUNCTION calcWellHookupCondDay(
    p_object_id       well_hookup.object_id%TYPE,
    p_daytime  DATE,
    p_stream_id  VARCHAR2 DEFAULT NULL)

RETURN NUMBER
--</EC-DOC>
IS

CURSOR c_day_cond IS
SELECT w.object_id, EcBp_Well_Theoretical.getCondStdRateDay(
          w.object_id,
          s.daytime)AS sum_cond, w.calc_cond_method calc_method
FROM   well_version w, system_days s
WHERE  w.proc_node_cond_id = p_object_id
AND    w.alloc_flag = 'Y'
AND    s.daytime between w.daytime and nvl(w.end_date-1,p_daytime)
AND    nvl(ec_pwel_period_status.active_well_status(w.object_id,p_daytime,'EVENT','<='),'OPEN')<> 'CLOSED_LT'
AND    s.daytime = p_daytime;


ln_return_value NUMBER;
lb_first BOOLEAN;
lv2_to_node_id VARCHAR2(32);
BEGIN
   lv2_to_node_id := ec_strm_version.to_node_id(p_stream_id, p_daytime, '<=');
   lb_first := TRUE;
   FOR mycur IN c_day_cond LOOP
     IF lb_first THEN
       lb_first := FALSE;
       IF mycur.calc_method = Ecdp_Calc_Method.MEAS_SWING_WELL THEN
         ln_return_value := Ecdp_Well_Swing_Theoretical.calcStreamWellDay(mycur.object_id,lv2_to_node_id,p_daytime, p_stream_id);
       ELSE
         ln_return_value := mycur.sum_cond * Ecdp_Well.getPwelFracToStrmToNode(mycur.object_id,p_stream_id,p_daytime);
       END IF;
     ELSE
       IF mycur.calc_method = Ecdp_Calc_Method.MEAS_SWING_WELL THEN
         ln_return_value := ln_return_value + nvl(Ecdp_Well_Swing_Theoretical.calcStreamWellDay(mycur.object_id,lv2_to_node_id,p_daytime, p_stream_id),0);
       ELSE
         ln_return_value := ln_return_value + nvl((mycur.sum_cond * Ecdp_Well.getPwelFracToStrmToNode(mycur.object_id,p_stream_id,p_daytime)),0);
       END IF;
     END IF;


   END LOOP;

   RETURN ln_return_value;


END calcWellHookupCondDay;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : calcWellHookupWatInjDay                                                      --
-- Description    : Returns total theoretical water injection for a given well hookup and day.   --
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
FUNCTION calcWellHookupWatInjDay(
    p_object_id       well_hookup.object_id%TYPE,
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

END calcWellHookupWatInjDay;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : calcWellHookupGasInjDay                                                      --
-- Description    : Returns total theoretical gas injection for a given well hookup and day.     --
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
FUNCTION calcWellHookupGasInjDay(
    p_object_id       well_hookup.object_id%TYPE,
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

END calcWellHookupGasInjDay;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : calcWellHookupCO2InjDay                                                      --
-- Description    : Returns total theoretical co2 injection for a given well hookup and day.     --
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
FUNCTION calcWellHookupCO2InjDay(
    p_object_id       well_hookup.object_id%TYPE,
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
WHERE  w.proc_node_co2_inj_id = p_object_id
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

END calcWellHookupCO2InjDay;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : calcWellHookupSteamInjDay                                                    --
-- Description    : Returns total theoretical steam injection for a given well hookup and day.   --
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
FUNCTION calcWellHookupSteamInjDay(
    p_object_id       well_hookup.object_id%TYPE,
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

END calcWellHookupSteamInjDay;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : calcWellHookupGasLiftDay                                                     --
-- Description    : Returns total theoretical gas lift for a given well hookup and day.          --
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
FUNCTION calcWellHookupGasLiftDay(
    p_object_id       well_hookup.object_id%TYPE,
    p_daytime  DATE,
  p_stream_id  VARCHAR2 DEFAULT NULL)

RETURN NUMBER
--</EC-DOC>
IS

CURSOR c_day_gas_lift IS
SELECT Sum(EcBp_Well_Theoretical.getGasLiftStdRateDay(
      w.object_id,s.daytime) * EcDp_Well.getPwelFracToStrmToNode(w.object_id, p_stream_id, p_daytime)) sum_gas_lift
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

END calcWellHookupGasLiftDay;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : calcWellHookupDiluentDay                                                     --
-- Description    : Returns total theoretical diluent for a given well hookup and day.           --
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
FUNCTION calcWellHookupDiluentDay(
    p_object_id       well_hookup.object_id%TYPE,
    p_daytime  DATE,
  p_stream_id  VARCHAR2 DEFAULT NULL)

RETURN NUMBER
--</EC-DOC>
IS

CURSOR c_day_diluent IS
SELECT Sum(EcBp_Well_Theoretical.getDiluentStdRateDay(
          w.object_id,s.daytime)* EcDp_Well.getPwelFracToStrmToNode(w.object_id, p_stream_id, p_daytime)) sum_diluent
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

END calcWellHookupDiluentDay;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : calcWellHookupOilMassDay                                                     --
-- Description    : Returns total theoretical Oil Mass for a given well hookup and day.          --
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
FUNCTION calcWellHookupOilMassDay(
    p_object_id       well_hookup.object_id%TYPE,
    p_daytime  DATE,
	p_stream_id	VARCHAR2 DEFAULT NULL)

RETURN NUMBER
--</EC-DOC>
IS

CURSOR c_day_oil_mass IS
SELECT Sum(EcBp_Well_Theoretical.findOilMassDay(
          w.object_id,s.daytime)* EcDp_Well.getPwelFracToStrmToNode(w.object_id, p_stream_id, p_daytime)) sum_oil_mass
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

END calcWellHookupOilMassDay;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : calcWellHookupGasMassDay                                                     --
-- Description    : Returns total theoretical gas mass for a given well hookup and day.          --
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
FUNCTION calcWellHookupGasMassDay(
    p_object_id       well_hookup.object_id%TYPE,
    p_daytime  DATE,
	p_stream_id	VARCHAR2 DEFAULT NULL)

RETURN NUMBER
--</EC-DOC>
IS

CURSOR c_day_gas_mass IS
SELECT Sum(EcBp_Well_Theoretical.findGasMassDay(
          w.object_id,s.daytime)* EcDp_Well.getPwelFracToStrmToNode(w.object_id, p_stream_id, p_daytime)) sum_gas_mass
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

END calcWellHookupGasMassDay;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : calcWellHookupWatMassDay                                                     --
-- Description    : Returns total theoretical water mass for a given well hookup and day.        --
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
FUNCTION calcWellHookupWatMassDay(
    p_object_id       well_hookup.object_id%TYPE,
    p_daytime  DATE,
	p_stream_id	VARCHAR2 DEFAULT NULL)

RETURN NUMBER
--</EC-DOC>
IS

CURSOR c_day_wat_mass IS
SELECT Sum(EcBp_Well_Theoretical.findWaterMassDay(
          w.object_id,s.daytime)* EcDp_Well.getPwelFracToStrmToNode(w.object_id, p_stream_id, p_daytime)) sum_wat_mass
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

END calcWellHookupWatMassDay;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : calcWellHookupCondMassDay                                                     --
-- Description    : Returns total theoretical condensate mass for a given well hookup and day.        --
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
FUNCTION calcWellHookupCondMassDay(
    p_object_id       well_hookup.object_id%TYPE,
    p_daytime  DATE,
	p_stream_id	VARCHAR2 DEFAULT NULL)

RETURN NUMBER
--</EC-DOC>
IS

CURSOR c_day_cond_mass IS
SELECT Sum(EcBp_Well_Theoretical.findCondMassDay(
          w.object_id,s.daytime)* EcDp_Well.getPwelFracToStrmToNode(w.object_id, p_stream_id, p_daytime)) sum_cond_mass
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

END calcWellHookupCondMassDay;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : calcSumOperWellHookWatDay                                                  --
-- Description    : Returns total theoretical water for a given well hookup and day.             --
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
FUNCTION calcSumOperWellHookWatDay(
    p_object_id       well_hookup.object_id%TYPE,
    p_daytime  DATE)

RETURN NUMBER
--</EC-DOC>
IS

CURSOR c_day_water IS
SELECT Sum(EcBp_Well_Theoretical.getWatStdRateDay(
          w.object_id,
          s.daytime)) sum_water
FROM   well_version w, system_days s
WHERE  w.op_well_hookup_id = p_object_id
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

END calcSumOperWellHookWatDay;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : calcSumOperWellHookOilDay                                                  --
-- Description    : Returns total theoretical oil for a given well hookup and day.               --
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
FUNCTION calcSumOperWellHookOilDay(
    p_object_id       well_hookup.object_id%TYPE,
    p_daytime  DATE)

RETURN NUMBER
--</EC-DOC>
IS

  CURSOR c_day_oil IS
    SELECT Sum(EcBp_Well_Theoretical.getOilStdRateDay(w.object_id,
                                                      s.daytime)) sum_oil
      FROM well_version w, system_days s
     WHERE w.op_well_hookup_id = p_object_id
       AND w.alloc_flag = 'Y'
       AND s.daytime between w.daytime and nvl(w.end_date - 1, p_daytime)
	   AND    nvl(ec_pwel_period_status.active_well_status(w.object_id,p_daytime,'EVENT','<='),'OPEN')<> 'CLOSED_LT'
       AND s.daytime = p_daytime;


  ln_return_value NUMBER;

BEGIN

  FOR mycur IN c_day_oil LOOP

    ln_return_value := mycur.sum_oil;

  END LOOP;

  RETURN ln_return_value;

END calcSumOperWellHookOilDay;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : calcSumOperWellHookGasDay                                                  --
-- Description    : Returns total theoretical gas for a given well hookup and day.               --
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
FUNCTION calcSumOperWellHookGasDay(
    p_object_id       well_hookup.object_id%TYPE,
    p_daytime  DATE)

RETURN NUMBER
--</EC-DOC>
IS

CURSOR c_day_gas IS
SELECT Sum(EcBp_Well_Theoretical.getGasStdRateDay(
          w.object_id,
          s.daytime)) sum_gas
FROM   well_version w, system_days s
WHERE  w.op_well_hookup_id = p_object_id
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

END calcSumOperWellHookGasDay;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : calcSumOperWellHookCO2Day                                                  --
-- Description  : Returns total theoretical CO2 for a given well hookup and day.               --
--                        independent on proc_node_co2_id                                              --
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
FUNCTION calcSumOperWellHookCO2Day(
    p_object_id       well_hookup.object_id%TYPE,
    p_daytime  DATE)

RETURN NUMBER
--</EC-DOC>
IS

CURSOR c_day_co2 IS
SELECT Sum(EcBp_Well_Theoretical.getCO2StdRateDay(
          w.object_id,
          s.daytime)) sum_co2
FROM   well_version w, system_days s
WHERE  w.op_well_hookup_id = p_object_id
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

END calcSumOperWellHookCO2Day;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : calcSumOperWellHookCondDay                                                 --
-- Description    : Returns total theoretical gas for a given well hookup and day.               --
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
FUNCTION calcSumOperWellHookCondDay(
    p_object_id       well_hookup.object_id%TYPE,
    p_daytime  DATE)

RETURN NUMBER
--</EC-DOC>
IS

CURSOR c_day_cond IS
SELECT Sum(EcBp_Well_Theoretical.getCondStdRateDay(
          w.object_id,
          s.daytime)) sum_cond
FROM   well_version w, system_days s
WHERE  w.op_well_hookup_id = p_object_id
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

END calcSumOperWellHookCondDay;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : calcSumOperWellHookWatInjDay                                               --
-- Description    : Returns total theoretical water injection for a given well hookup and day.   --
--                  independent on proc_node_water_inj_id                                        --
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
FUNCTION calcSumOperWellHookWatInjDay(
    p_object_id       well_hookup.object_id%TYPE,
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
WHERE  w.op_well_hookup_id = p_object_id
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

END calcSumOperWellHookWatInjDay;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : calcSumOperWellHookGasInjDay                                               --
-- Description    : Returns total theoretical gas injection for a given well hookup and day.     --
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
FUNCTION calcSumOperWellHookGasInjDay(
    p_object_id       well_hookup.object_id%TYPE,
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
WHERE  w.op_well_hookup_id = p_object_id
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

END calcSumOperWellHookGasInjDay;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : calcSumOperWellHookCO2InjDay                                               --
-- Description    : Returns total theoretical co2 injection for a given well hookup and day.     --
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
FUNCTION calcSumOperWellHookCO2InjDay(
    p_object_id       well_hookup.object_id%TYPE,
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
WHERE  w.op_well_hookup_id = p_object_id
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

END calcSumOperWellHookCO2InjDay;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : calcSumOperWellHookSteamInjDay                                             --
-- Description    : Returns total theoretical steam injection for a given well hookup and day.   --
--                  independent on proc_node_steam_id                                            --
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
FUNCTION calcSumOperWellHookSteamInjDay(
    p_object_id       well_hookup.object_id%TYPE,
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
WHERE  w.op_well_hookup_id = p_object_id
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

END calcSumOperWellHookSteamInjDay;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : calcSumOperWellHookGasLiftDay                                              --
-- Description    : Returns total theoretical gas lift for a given well hookup and day.          --
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
FUNCTION calcSumOperWellHookGasLiftDay(
    p_object_id       well_hookup.object_id%TYPE,
    p_daytime  DATE)

RETURN NUMBER
--</EC-DOC>
IS

CURSOR c_day_gas_lift IS
SELECT Sum(EcBp_Well_Theoretical.getGasLiftStdRateDay(
      w.object_id,s.daytime)) sum_gas_lift
FROM   well_version w, system_days s
WHERE  w.op_well_hookup_id = p_object_id
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

END calcSumOperWellHookGasLiftDay;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : calcSumOperWellHookDiluentDay                                              --
-- Description    : Returns total theoretical diluent for a given well hookup and day.           --
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
FUNCTION calcSumOperWellHookDiluentDay(
    p_object_id       well_hookup.object_id%TYPE,
    p_daytime  DATE)

RETURN NUMBER
--</EC-DOC>
IS

CURSOR c_day_diluent IS
SELECT Sum(EcBp_Well_Theoretical.getDiluentStdRateDay(
          w.object_id,s.daytime)) sum_diluent
FROM   well_version w, system_days s
WHERE  w.op_well_hookup_id = p_object_id
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

END calcSumOperWellHookDiluentDay;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : calcSumOperWellHookOilMassDay                                              --
-- Description    : Returns total theoretical Oil Mass for a given well hookup and day.          --
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
FUNCTION calcSumOperWellHookOilMassDay(
    p_object_id       well_hookup.object_id%TYPE,
    p_daytime  DATE)

RETURN NUMBER
--</EC-DOC>
IS

CURSOR c_day_oil_mass IS
SELECT Sum(EcBp_Well_Theoretical.findOilMassDay(
          w.object_id,s.daytime)) sum_oil_mass
FROM   well_version w, system_days s
WHERE  w.op_well_hookup_id = p_object_id
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

END calcSumOperWellHookOilMassDay;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : calcSumOperWellHookGasMassDay                                              --
-- Description    : Returns total theoretical gas mass for a given well hookup and day.          --
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
FUNCTION calcSumOperWellHookGasMassDay(
    p_object_id       well_hookup.object_id%TYPE,
    p_daytime  DATE)

RETURN NUMBER
--</EC-DOC>
IS

CURSOR c_day_gas_mass IS
SELECT Sum(EcBp_Well_Theoretical.findGasMassDay(
          w.object_id,s.daytime)) sum_gas_mass
FROM   well_version w, system_days s
WHERE  w.op_well_hookup_id = p_object_id
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

END calcSumOperWellHookGasMassDay;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : calcSumOperWellHookWatMassDay                                              --
-- Description    : Returns total theoretical water mass for a given well hookup and day.        --
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
FUNCTION calcSumOperWellHookWatMassDay(
    p_object_id       well_hookup.object_id%TYPE,
    p_daytime  DATE)

RETURN NUMBER
--</EC-DOC>
IS

CURSOR c_day_wat_mass IS
SELECT Sum(EcBp_Well_Theoretical.findWaterMassDay(
          w.object_id,s.daytime)) sum_wat_mass
FROM   well_version w, system_days s
WHERE  w.op_well_hookup_id = p_object_id
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

END calcSumOperWellHookWatMassDay;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : calcSumOperWellHookCondMassDay                                              --
-- Description    : Returns total theoretical condensate mass for a given well hookup and day.        --
--                  independent on proc_node_cond_id                                            --
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
FUNCTION calcSumOperWellHookCondMassDay(
    p_object_id       well_hookup.object_id%TYPE,
    p_daytime  DATE)

RETURN NUMBER
--</EC-DOC>
IS

CURSOR c_day_cond_mass IS
SELECT Sum(EcBp_Well_Theoretical.findCondMassDay(
          w.object_id,s.daytime)) sum_cond_mass
FROM   well_version w, system_days s
WHERE  w.op_well_hookup_id = p_object_id
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

END calcSumOperWellHookCondMassDay;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getWellHookPhaseFactorDay                                                    --
-- Description    : Returns reconciliation factor per phase, per well hookup, for a day.         --
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
FUNCTION getWellHookPhaseFactorDay(p_object_id    well_hookup.object_id%TYPE,
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
   AND w.op_well_hookup_id = p_object_id
   AND w.alloc_flag = 'Y'
   AND pda.daytime between w.daytime and nvl(w.end_date-1,p_daytime)
   AND pda.daytime = p_daytime;

BEGIN
   ln_ret_val := ue_well_hookup_theoretical.getWellHookPhaseFactorDay(p_object_id,p_daytime,p_phase);
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

END getWellHookPhaseFactorDay;
--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getWellHookPhaseMassFactorDay                                                    --
-- Description    : Returns reconciliation factor per phase, per well hookup, for a day.         --
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
FUNCTION getWellHookPhaseMassFactorDay(p_object_id    well_hookup.object_id%TYPE,
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
   AND w.op_well_hookup_id = p_object_id
   AND w.alloc_flag = 'Y'
   AND pda.daytime between w.daytime and nvl(w.end_date-1,p_daytime)
   AND pda.daytime = p_daytime;

BEGIN
   ln_ret_val := ue_well_hookup_theoretical.getWellHookPhaseMassFactorDay(p_object_id,p_daytime,p_phase);
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

END getWellHookPhaseMassFactorDay;


END;