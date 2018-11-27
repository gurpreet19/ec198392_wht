CREATE OR REPLACE PACKAGE BODY EcBp_Alloc_Values IS
/****************************************************************
** Package        :  EcBp_Alloc_Values, body part
**
** $Revision: 1.0 $
**
** Purpose        :  Provides allocated values for a given facility, Well-Hookup.
**
** Documentation  :  www.energy-components.com
**
** Created  : 10.02.2017  singishi
**
** Modification history:
**
** Version  Date        Whom         Change description:
** -------  ------      -----        --------------------------------------
** 1.0      10.02.2017  Singishi     ECPD-43210 New data Classes for Live data for Facility and Well Hookup
*****************************************************************/
--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : calcSumOperFacilityOilAlloc                                                  --
-- Description    : Returns total allocated oil volume for only platform wells                   --
--                  on a given facility and daytime.                                             --
--                                                                                               --
-- Preconditions  :                                                                              --
-- Postconditions :                                                                              --
--                                                                                               --
-- Using tables   :  PWEL_DAY_ALLOC                                                              --
--                                                                                               --
-- Using functions:                                                                              --
--                                                                                               --
-- Configuration                                                                                 --
-- required       :                                                                              --
--                                                                                               --
-- Behaviour      :                                                                              --
--                                                                                               --
---------------------------------------------------------------------------------------------------
FUNCTION calcSumOperFacilityOilAlloc(
    p_object_id  production_facility.object_id%TYPE,
    p_daytime  DATE)

RETURN NUMBER
--</EC-DOC>
IS

CURSOR c_day_oil_alloc IS
SELECT sum(p.Alloc_net_oil_vol) sum_oil_alloc
FROM PWEL_DAY_ALLOC p , Well_version w
WHERE p.object_id=w.object_id
AND w.op_fcty_class_1_ID=p_object_id
AND p.daytime = p_daytime;

ln_return_value NUMBER;

BEGIN

 FOR mycur IN c_day_oil_alloc
   LOOP

     ln_return_value := mycur.sum_oil_alloc;

   END LOOP;

   RETURN ln_return_value;

END calcSumOperFacilityOilAlloc;
--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : calcSumOperFacilityGasAlloc                                                  --
-- Description    : Returns total allocated Gas volume for only platform wells                   --
--                  on a given facility and daytime.                                             --
--                                                                                               --
-- Preconditions  :                                                                              --
-- Postconditions :                                                                              --
--                                                                                               --
-- Using tables   :  PWEL_DAY_ALLOC                                                              --
--                                                                                               --
-- Using functions:                                                                              --
--                                                                                               --
-- Configuration                                                                                 --
-- required       :                                                                              --
--                                                                                               --
-- Behaviour      :                                                                              --
--                                                                                               --
---------------------------------------------------------------------------------------------------
FUNCTION calcSumOperFacilityGasAlloc(
    p_object_id  production_facility.object_id%TYPE,
    p_daytime  DATE)

RETURN NUMBER
--</EC-DOC>
IS

CURSOR c_day_gas_alloc IS
SELECT sum(p.Alloc_gas_vol) sum_gas_alloc
FROM PWEL_DAY_ALLOC p , Well_version w
WHERE p.object_id=w.object_id
AND w.op_fcty_class_1_ID=p_object_id
AND p.daytime = p_daytime;

ln_return_value NUMBER;

BEGIN

 FOR mycur IN c_day_gas_alloc
   LOOP

     ln_return_value := mycur.sum_gas_alloc;

   END LOOP;

   RETURN ln_return_value;

END calcSumOperFacilityGasAlloc;
--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : calcSumOperFacilityWatAlloc                                                  --
-- Description    : Returns total allocated Water volume for only platform wells                 --
--                  on a given facility and daytime.                                             --
--                                                                                               --
-- Preconditions  :                                                                              --
-- Postconditions :                                                                              --
--                                                                                               --
-- Using tables   :  PWEL_DAY_ALLOC                                                              --
--                                                                                               --
-- Using functions:                                                                              --
--                                                                                               --
-- Configuration                                                                                 --
-- required       :                                                                              --
--                                                                                               --
-- Behaviour      :                                                                              --
--                                                                                               --
---------------------------------------------------------------------------------------------------
FUNCTION calcSumOperFacilityWatAlloc(
    p_object_id  production_facility.object_id%TYPE,
    p_daytime  DATE)

RETURN NUMBER
--</EC-DOC>
IS

CURSOR c_day_wat_alloc IS
SELECT sum(p.Alloc_water_vol) sum_wat_alloc
FROM PWEL_DAY_ALLOC p , Well_version w
WHERE p.object_id=w.object_id
AND w.op_fcty_class_1_ID=p_object_id
AND p.daytime = p_daytime;

ln_return_value NUMBER;

BEGIN

 FOR mycur IN c_day_wat_alloc
   LOOP

     ln_return_value := mycur.sum_wat_alloc;

   END LOOP;

   RETURN ln_return_value;

END calcSumOperFacilityWatAlloc;
--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : calcSumOperFacilityCondAlloc                                                 --
-- Description    : Returns total allocated condensate volume for only platform wells            --
--                  on a given facility and daytime.                                             --
--                                                                                               --
-- Preconditions  :                                                                              --
-- Postconditions :                                                                              --
--                                                                                               --
-- Using tables   :  PWEL_DAY_ALLOC                                                              --
--                                                                                               --
-- Using functions:                                                                              --
--                                                                                               --
-- Configuration                                                                                 --
-- required       :                                                                              --
--                                                                                               --
-- Behaviour      :                                                                              --
--                                                                                               --
---------------------------------------------------------------------------------------------------
FUNCTION calcSumOperFacilityCondAlloc(
    p_object_id  production_facility.object_id%TYPE,
    p_daytime  DATE)

RETURN NUMBER
--</EC-DOC>
IS

CURSOR c_day_cond_alloc IS
SELECT sum(p.Alloc_cond_vol) sum_cond_alloc
FROM PWEL_DAY_ALLOC p , Well_version w
WHERE p.object_id=w.object_id
AND w.op_fcty_class_1_ID=p_object_id
AND p.daytime = p_daytime;

ln_return_value NUMBER;

BEGIN

 FOR mycur IN c_day_cond_alloc
   LOOP

     ln_return_value := mycur.sum_cond_alloc;

   END LOOP;

   RETURN ln_return_value;

END calcSumOperFacilityCondAlloc;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : calcSumOperWellHookOilAlloc                                                  --
-- Description    : Returns total allocated oil volume for  wells                                --
--                  in a given well hookup and daytime.                                          --
--                                                                                               --
-- Preconditions  :                                                                              --
-- Postconditions :                                                                              --
--                                                                                               --
-- Using tables   :  PWEL_DAY_ALLOC                                                              --
--                                                                                               --
-- Using functions:                                                                              --
--                                                                                               --
-- Configuration                                                                                 --
-- required       :                                                                              --
--                                                                                               --
-- Behaviour      :                                                                              --
--                                                                                               --
---------------------------------------------------------------------------------------------------
FUNCTION calcSumOperWellHookOilAlloc(
    p_object_id  well_hookup.object_id%TYPE,
    p_daytime  DATE)

RETURN NUMBER
--</EC-DOC>
IS

CURSOR c_day_oil_alloc IS
SELECT sum(p.Alloc_net_oil_vol) sum_oil_alloc
FROM PWEL_DAY_ALLOC p , Well_version w
WHERE p.object_id=w.object_id
AND w.op_well_hookup_id=p_object_id
AND p.daytime = p_daytime;

ln_return_value NUMBER;

BEGIN

 FOR mycur IN c_day_oil_alloc
   LOOP

     ln_return_value := mycur.sum_oil_alloc;

   END LOOP;

   RETURN ln_return_value;

END calcSumOperWellHookOilAlloc;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : calcSumOperWellHookGasAlloc                                                  --
-- Description    : Returns total allocated Gas volume for  wells                                --
--                  in a given well hookup and daytime.                                          --
--                                                                                               --
-- Preconditions  :                                                                              --
-- Postconditions :                                                                              --
--                                                                                               --
-- Using tables   :  PWEL_DAY_ALLOC                                                              --
--                                                                                               --
-- Using functions:                                                                              --
--                                                                                               --
-- Configuration                                                                                 --
-- required       :                                                                              --
--                                                                                               --
-- Behaviour      :                                                                              --
--                                                                                               --
---------------------------------------------------------------------------------------------------
FUNCTION calcSumOperWellHookGasAlloc(
    p_object_id  well_hookup.object_id%TYPE,
    p_daytime  DATE)

RETURN NUMBER
--</EC-DOC>
IS

CURSOR c_day_gas_alloc IS
SELECT sum(p.Alloc_gas_vol) sum_gas_alloc
FROM PWEL_DAY_ALLOC p , Well_version w
WHERE p.object_id=w.object_id
AND w.op_well_hookup_id=p_object_id
AND p.daytime = p_daytime;

ln_return_value NUMBER;

BEGIN

 FOR mycur IN c_day_gas_alloc
   LOOP

     ln_return_value := mycur.sum_gas_alloc;

   END LOOP;

   RETURN ln_return_value;

END calcSumOperWellHookGasAlloc;
--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : calcSumOperWellHookCondAlloc                                                 --
-- Description    : Returns total allocated Condensate volume for  wells                         --
--                  in a given well hookup and daytime.                                          --
--                                                                                               --
-- Preconditions  :                                                                              --
-- Postconditions :                                                                              --
--                                                                                               --
-- Using tables   :  PWEL_DAY_ALLOC                                                              --
--                                                                                               --
-- Using functions:                                                                              --
--                                                                                               --
-- Configuration                                                                                 --
-- required       :                                                                              --
--                                                                                               --
-- Behaviour      :                                                                              --
--                                                                                               --
---------------------------------------------------------------------------------------------------
FUNCTION calcSumOperWellHookCondAlloc(
    p_object_id  well_hookup.object_id%TYPE,
    p_daytime  DATE)

RETURN NUMBER
--</EC-DOC>
IS

CURSOR c_day_cond_alloc IS
SELECT sum(p.Alloc_Cond_vol) sum_cond_alloc
FROM PWEL_DAY_ALLOC p , Well_version w
WHERE p.object_id=w.object_id
AND w.op_well_hookup_id=p_object_id
AND p.daytime = p_daytime;

ln_return_value NUMBER;

BEGIN

 FOR mycur IN c_day_cond_alloc
   LOOP

     ln_return_value := mycur.sum_cond_alloc;

   END LOOP;

   RETURN ln_return_value;

END calcSumOperWellHookCondAlloc;
--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : calcSumOperWellHookWatAlloc                                                  --
-- Description    : Returns total allocated Water volume for  wells                              --
--                  in a given well hookup and daytime.                                          --
--                                                                                               --
-- Preconditions  :                                                                              --
-- Postconditions :                                                                              --
--                                                                                               --
-- Using tables   :  PWEL_DAY_ALLOC                                                              --
--                                                                                               --
-- Using functions:                                                                              --
--                                                                                               --
-- Configuration                                                                                 --
-- required       :                                                                              --
--                                                                                               --
-- Behaviour      :                                                                              --
--                                                                                               --
---------------------------------------------------------------------------------------------------
FUNCTION calcSumOperWellHookWatAlloc(
    p_object_id  well_hookup.object_id%TYPE,
    p_daytime  DATE)

RETURN NUMBER
--</EC-DOC>
IS

CURSOR c_day_wat_alloc IS
SELECT sum(p.Alloc_water_vol) sum_wat_alloc
FROM PWEL_DAY_ALLOC p , Well_version w
WHERE p.object_id=w.object_id
AND w.op_well_hookup_id=p_object_id
AND p.daytime = p_daytime;

ln_return_value NUMBER;

BEGIN

 FOR mycur IN c_day_wat_alloc
   LOOP

     ln_return_value := mycur.sum_wat_alloc;

   END LOOP;

   RETURN ln_return_value;

END calcSumOperWellHookWatAlloc;
--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : calcSumOperFctyOilMassAlloc                                                  --
-- Description    : Returns total allocated oil mass for only platform wells                   --
--                  on a given facility and daytime.                                             --
--                                                                                               --
-- Preconditions  :                                                                              --
-- Postconditions :                                                                              --
--                                                                                               --
-- Using tables   :  PWEL_DAY_ALLOC                                                              --
--                                                                                               --
-- Using functions:                                                                              --
--                                                                                               --
-- Configuration                                                                                 --
-- required       :                                                                              --
--                                                                                               --
-- Behaviour      :                                                                              --
--                                                                                               --
---------------------------------------------------------------------------------------------------
FUNCTION calcSumOperFctyOilMassAlloc(
    p_object_id  production_facility.object_id%TYPE,
    p_daytime  DATE)

RETURN NUMBER
--</EC-DOC>
IS

CURSOR c_day_oil_alloc_mass IS
SELECT sum(p.Alloc_net_oil_mass) sum_oil_alloc_mass
FROM PWEL_DAY_ALLOC p , Well_version w
WHERE p.object_id=w.object_id
AND w.op_fcty_class_1_ID=p_object_id
AND p.daytime = p_daytime;

ln_return_value NUMBER;

BEGIN

 FOR mycur IN c_day_oil_alloc_mass
   LOOP

     ln_return_value := mycur.sum_oil_alloc_mass;

   END LOOP;

   RETURN ln_return_value;

END calcSumOperFctyOilMassAlloc;
--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : calcSumOperFctyGasMassAlloc                                                  --
-- Description    : Returns total allocated gas mass for only platform wells                   --
--                  on a given facility and daytime.                                             --
--                                                                                               --
-- Preconditions  :                                                                              --
-- Postconditions :                                                                              --
--                                                                                               --
-- Using tables   :  PWEL_DAY_ALLOC                                                              --
--                                                                                               --
-- Using functions:                                                                              --
--                                                                                               --
-- Configuration                                                                                 --
-- required       :                                                                              --
--                                                                                               --
-- Behaviour      :                                                                              --
--                                                                                               --
---------------------------------------------------------------------------------------------------
FUNCTION calcSumOperFctyGasMassAlloc(
    p_object_id  production_facility.object_id%TYPE,
    p_daytime  DATE)

RETURN NUMBER
--</EC-DOC>
IS

CURSOR c_day_gas_alloc_mass IS
SELECT sum(p.Alloc_gas_mass) sum_gas_alloc_mass
FROM PWEL_DAY_ALLOC p , Well_version w
WHERE p.object_id=w.object_id
AND w.op_fcty_class_1_ID=p_object_id
AND p.daytime = p_daytime;

ln_return_value NUMBER;

BEGIN

 FOR mycur IN c_day_gas_alloc_mass
   LOOP

     ln_return_value := mycur.sum_gas_alloc_mass;

   END LOOP;

   RETURN ln_return_value;

END calcSumOperFctyGasMassAlloc;
--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : calcSumOperFctyCondMassAlloc                                                  --
-- Description    : Returns total allocated cond mass for only platform wells                   --
--                  on a given facility and daytime.                                             --
--                                                                                               --
-- Preconditions  :                                                                              --
-- Postconditions :                                                                              --
--                                                                                               --
-- Using tables   :  PWEL_DAY_ALLOC                                                              --
--                                                                                               --
-- Using functions:                                                                              --
--                                                                                               --
-- Configuration                                                                                 --
-- required       :                                                                              --
--                                                                                               --
-- Behaviour      :                                                                              --
--                                                                                               --
---------------------------------------------------------------------------------------------------
FUNCTION calcSumOperFctyCondMassAlloc(
    p_object_id  production_facility.object_id%TYPE,
    p_daytime  DATE)

RETURN NUMBER
--</EC-DOC>
IS

CURSOR c_day_cond_alloc_mass IS
SELECT sum(p.Alloc_cond_mass) sum_cond_alloc_mass
FROM PWEL_DAY_ALLOC p , Well_version w
WHERE p.object_id=w.object_id
AND w.op_fcty_class_1_ID=p_object_id
AND p.daytime = p_daytime;

ln_return_value NUMBER;

BEGIN

 FOR mycur IN c_day_cond_alloc_mass
   LOOP

     ln_return_value := mycur.sum_cond_alloc_mass;

   END LOOP;

   RETURN ln_return_value;

END calcSumOperFctyCondMassAlloc;
--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : calcSumOperFctyWatMassAlloc                                                  --
-- Description    : Returns total allocated Water Mass for only platform wells                   --
--                  on a given facility and daytime.                                             --
--                                                                                               --
-- Preconditions  :                                                                              --
-- Postconditions :                                                                              --
--                                                                                               --
-- Using tables   :  PWEL_DAY_ALLOC                                                              --
--                                                                                               --
-- Using functions:                                                                              --
--                                                                                               --
-- Configuration                                                                                 --
-- required       :                                                                              --
--                                                                                               --
-- Behaviour      :                                                                              --
--                                                                                               --
---------------------------------------------------------------------------------------------------
FUNCTION calcSumOperFctyWatMassAlloc(
    p_object_id  production_facility.object_id%TYPE,
    p_daytime  DATE)

RETURN NUMBER
--</EC-DOC>
IS

CURSOR c_day_wat_alloc_mass IS
SELECT sum(p.Alloc_water_mass) sum_wat_alloc_mass
FROM PWEL_DAY_ALLOC p , Well_version w
WHERE p.object_id=w.object_id
AND w.op_fcty_class_1_ID=p_object_id
AND p.daytime = p_daytime;

ln_return_value NUMBER;

BEGIN

 FOR mycur IN c_day_wat_alloc_mass
   LOOP

     ln_return_value := mycur.sum_wat_alloc_mass;

   END LOOP;

   RETURN ln_return_value;

END calcSumOperFctyWatMassAlloc;


END EcBp_Alloc_Values;