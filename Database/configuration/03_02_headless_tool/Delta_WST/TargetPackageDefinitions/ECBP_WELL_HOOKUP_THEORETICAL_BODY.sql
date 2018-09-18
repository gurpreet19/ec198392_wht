CREATE OR REPLACE PACKAGE BODY EcBp_Well_Hookup_Theoretical IS

/****************************************************************
** Package        :  EcBp_Well_Hookup_Theoretical, body part
**
** $Revision: 1.17.12.1 $
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
**     24.04.2013 leongwen ECPD-24051: modified the function calcWellHookupWatDay and calcWellHookupCondDay
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
AND    s.daytime = p_daytime;

ln_return_value NUMBER;

BEGIN

   FOR mycur IN c_day_cond_mass LOOP

   	ln_return_value := mycur.sum_cond_mass;

   END LOOP;

   RETURN ln_return_value;

END calcSumOperWellHookCondMassDay;

END;