CREATE OR REPLACE PACKAGE BODY EcDp_Facility_Allocated IS
/****************************************************************
** Package        :  EcDp_Facility_Allocated, body part
**
** $Revision: 1.6 $
**
** Purpose        :  Provides allocated fluid values (rates etc)
**	                  for a given facility.
**
** Documentation  :  www.energy-components.com
**
** Created  : 16.10.2000  Dagfinn Nj?
**
** Modification history:
**
** Version  Date     Whom  Change description:
** -------  ------   ----- --------------------------------------
**  4.0     30.03.01 RRA   Added rev info in package
**  4.0     15.05.01 DN    Added getSubseaPhaseStdVolPeriod and getPlatformPhaseStdVolPeriod.
**          10.07.01 KB	   Changed getSubseaPhaseStdVolPeriod and getPlatformPhaseStdVolPeriod for well A-47T2 (ecrs G?_00035)
**  4.2     09.01.02 UMF   Extended function getFacilityPhaseStdVol to handle condensate
**  4.3     10.08.04 Toha  Removed sysnam and facility and made changes as necessary.
**  4.4		  17.02.06 Darren TI#3461 Fixed error in cursor c_period_phase.
**          31.12.2008 sharawan ECPD-10416:Replaced all references to EcDp_Type.pb_comp_number%TYPE with NUMBER in functions
**                              getFacilityPhaseStdVolPeriod, getSubseaPhaseStdVolPeriod, getPlatformPhaseStdVolPeriod.
**          24.09.09 aliassit ECPD-12558: Added sumFctyAllocProdVolume, sumFctyAllocProdMass, sumFctyAllocInjVolume, sumFctyAllocInjMass
*****************************************************************/


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getFacilityPhaseStdVolPeriod                                                 --
-- Description    : Returns total allocated standard phase volume for a given facility and       --
--                  periods of day.                                                              --
--                                                                                               --
-- Preconditions  : Only days without time is allowed, 'To date' included.                       --
--                  All parameteres are required.                                                --
-- Postconditions :                                                                              --
--                                                                                               --
-- Using tables   :  pwel_day_alloc                                                              --
--                                                                                               --
-- Using functions:                                                                              --
--                                                                                               --
-- Configuration                                                                                 --
-- required       :                                                                              --
--                                                                                               --
-- Behaviour      :                                                                              --
--                                                                                               --
---------------------------------------------------------------------------------------------------
FUNCTION getFacilityPhaseStdVolPeriod(
--	p_sysnam   VARCHAR2,
--	p_facility VARCHAR2,
    p_object_id         production_facility.object_id%TYPE,
    p_from_date  DATE,
    p_to_date    DATE,
    p_phase    VARCHAR2)

RETURN NUMBER
--</EC-DOC>
IS

CURSOR c_period_phase IS
SELECT Sum(alloc_net_oil_vol) sum_oil,
       Sum(alloc_gas_vol) sum_gas,
       Sum(alloc_water_vol) sum_water,
       Sum(alloc_cond_vol) sum_cond
FROM pwel_day_alloc pda, well_version wv
WHERE  pda.object_id = wv.object_id
AND    wv.op_fcty_class_1_id = p_object_id
AND    pda.daytime BETWEEN p_from_date AND p_to_date
AND    pda.daytime BETWEEN wv.daytime AND nvl(wv.end_date-1, p_to_date);

ln_return_value NUMBER;

BEGIN

   IF p_phase = EcDp_Phase.OIL THEN

      FOR mycur IN c_period_phase LOOP

   	   ln_return_value := mycur.sum_oil;

      END LOOP;

   ELSIF p_phase = EcDp_Phase.GAS THEN

      FOR mycur IN c_period_phase LOOP

   	   ln_return_value := mycur.sum_gas;

      END LOOP;

   ELSIF p_phase = EcDp_Phase.WATER THEN

      FOR mycur IN c_period_phase LOOP

   	   ln_return_value := mycur.sum_water;

      END LOOP;

   ELSIF p_phase = EcDp_Phase.CONDENSATE THEN

      FOR mycur IN c_period_phase LOOP

   	   ln_return_value := mycur.sum_cond;

      END LOOP;

   END IF;

   RETURN ln_return_value;

END getFacilityPhaseStdVolPeriod;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getSubseaPhaseStdVolPeriod                                                   --
-- Description    : Returns total allocated standard phase volume for subsea wells connected to a--
--                  given facility and periods of day.                                           --
--                                                                                               --
-- Preconditions  : Only days without time is allowed, 'To date' included.                       --
--                  All parameteres are required.                                                --
-- Postconditions :                                                                              --
--                                                                                               --
-- Using tables   :  pwel_day_alloc, well                                                        --
--                                                                                               --
-- Using functions:                                                                              --
--                                                                                               --
-- Configuration                                                                                 --
-- required       :                                                                              --
--                                                                                               --
-- Behaviour      :                                                                              --
--                                                                                               --
---------------------------------------------------------------------------------------------------
FUNCTION getSubseaPhaseStdVolPeriod(
--	p_sysnam   VARCHAR2,
--	p_facility VARCHAR2,
    p_object_id         production_facility.object_id%TYPE,
    p_from_date  DATE,
    p_to_date    DATE,
    p_phase    VARCHAR2)

RETURN NUMBER
--</EC-DOC>
IS

--CURSOR c_period_phase_subsea IS
--SELECT Sum(alloc_net_oil_vol) sum_oil,
--       Sum(alloc_gas_vol) sum_gas,
--       Sum(alloc_water_vol) sum_water
--FROM pwel_day_alloc pda
--WHERE pda.sysnam = p_sysnam
--AND pda.facility = p_facility
--AND pda.daytime BETWEEN p_from_date
--AND p_to_date
--AND EXISTS (
--SELECT * FROM well w
--where w.sysnam = pda.sysnam
--and w.facility = pda.facility
--and w.well_no = pda.well_no
--and w.template_no is not null
--);

CURSOR c_period_phase_subsea IS
SELECT SUM(alloc_net_oil_vol) sum_oil,
       Sum(alloc_gas_vol) sum_gas,
       Sum(alloc_water_vol) sum_water
FROM pwel_day_alloc pda, well
WHERE --pda.sysnam = p_sysnam AND pda.facility = p_facility
      well.object_id = pda.object_id
AND ecdp_well.getFacility(pda.object_id, Ecdp_Timestamp.getCurrentSysdate) = p_object_id
AND pda.daytime BETWEEN p_from_date
AND p_to_date
-- following lines always evaluate to true. gullfaks is no longer there
--AND EXISTS (
--SELECT * FROM well w
--where --w.sysnam = pda.sysnam and w.facility = pda.facility and w.well_no = pda.well_no
--      w.object_id = pda.object_id
--AND ((w.template_no IS NOT NULL
--AND Nvl(ec_well_attribute.attribute_text('GULLFAKS',pda.object_id,pda.daytime,'SATELITTE_OWNER','<='),'Y') = 'Y')
--OR 	(w.template_no IS NULL
--AND	ec_well_attribute.attribute_text('GULLFAKS',pda.object_id,pda.daytime,'SATELITTE_OWNER','<=') = 'Y'))
--);
;
ln_return_value NUMBER;

BEGIN

   IF p_phase = EcDp_Phase.OIL THEN

      FOR mycur IN c_period_phase_subsea LOOP

   	   ln_return_value := mycur.sum_oil;

      END LOOP;

   ELSIF p_phase = EcDp_Phase.GAS THEN

      FOR mycur IN c_period_phase_subsea LOOP

   	   ln_return_value := mycur.sum_gas;

      END LOOP;

   ELSIF p_phase = EcDp_Phase.WATER THEN

      FOR mycur IN c_period_phase_subsea LOOP

   	   ln_return_value := mycur.sum_water;

      END LOOP;

   END IF;

   RETURN ln_return_value;

END getSubseaPhaseStdVolPeriod;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getPlatformPhaseStdVolPeriod                                                 --
-- Description    : Returns total allocated standard phase volume for only platform wells        --
--                  on a given facility and periods of day.                                      --
--                                                                                               --
-- Preconditions  : Only days without time is allowed, 'To date' included.                       --
--                  All parameteres are required.                                                --
-- Postconditions :                                                                              --
--                                                                                               --
-- Using tables   :  pwel_day_alloc, well                                                        --
--                                                                                               --
-- Using functions:                                                                              --
--                                                                                               --
-- Configuration                                                                                 --
-- required       :                                                                              --
--                                                                                               --
-- Behaviour      :                                                                              --
--                                                                                               --
---------------------------------------------------------------------------------------------------
FUNCTION getPlatformPhaseStdVolPeriod(
--	p_sysnam   VARCHAR2,
--	p_facility VARCHAR2,
    p_object_id         production_facility.object_id%TYPE,
    p_from_date  DATE,
    p_to_date    DATE,
    p_phase    VARCHAR2)

RETURN NUMBER
--</EC-DOC>
IS

--CURSOR c_period_phase_plat IS
--SELECT Sum(alloc_net_oil_vol) sum_oil,
--       Sum(alloc_gas_vol) sum_gas,
--       Sum(alloc_water_vol) sum_water
--FROM pwel_day_alloc pda
--WHERE pda.sysnam = p_sysnam
--AND pda.facility = p_facility
--AND pda.daytime BETWEEN p_from_date
--AND p_to_date
--AND EXISTS (
--SELECT * FROM well w
--where w.sysnam = pda.sysnam
--and w.facility = pda.facility
--and w.well_no = pda.well_no
--and w.template_no is null
--);

CURSOR c_period_phase_plat IS
SELECT Sum(alloc_net_oil_vol) sum_oil,
       Sum(alloc_gas_vol) sum_gas,
       Sum(alloc_water_vol) sum_water
FROM pwel_day_alloc pda
WHERE --pda.sysnam = p_sysnam AND pda.facility = p_facility
      pda.object_id = p_object_id
AND pda.daytime BETWEEN p_from_date
AND p_to_date
--AND EXISTS (
--SELECT * FROM well w
--where --w.sysnam = pda.sysnam and w.facility = pda.facility and w.well_no = pda.well_no
--      w.object_id = pda.object_id
--AND ((w.template_no IS NULL
--AND Nvl(ec_well_attribute.attribute_text('GULLFAKS',pda.object_id,pda.daytime,'SATELITTE_OWNER','<='),'N') = 'N')
--OR 	(w.template_no IS NOT NULL
--AND	ec_well_attribute.attribute_text('GULLFAKS',pda.object_id,pda.daytime,'SATELITTE_OWNER','<=') = 'N'))
--);
;
ln_return_value NUMBER;

BEGIN

   IF p_phase = EcDp_Phase.OIL THEN

      FOR mycur IN c_period_phase_plat LOOP

   	   ln_return_value := mycur.sum_oil;

      END LOOP;

   ELSIF p_phase = EcDp_Phase.GAS THEN

      FOR mycur IN c_period_phase_plat LOOP

   	   ln_return_value := mycur.sum_gas;

      END LOOP;

   ELSIF p_phase = EcDp_Phase.WATER THEN

      FOR mycur IN c_period_phase_plat LOOP

   	   ln_return_value := mycur.sum_water;

      END LOOP;

   END IF;

   RETURN ln_return_value;

END getPlatformPhaseStdVolPeriod;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : sumFctyAllocProdVolume                                               --
-- Description    : Returns sum of well alloc prod vol for a given facility and day.           --
--                                                              --
-- Preconditions  :                                                                              --
-- Postconditions :                                                                              --
--                                                                                               --
-- Using tables   : pwel_day_alloc                                                              --
--                                                                                               --
-- Using functions:                                       --
--                                                                                               --
-- Configuration                                                                                 --
-- required       :                                                                              --
--                                                                                               --
-- Behaviour      :                                                                              --
--                                                                                               --
---------------------------------------------------------------------------------------------------
FUNCTION sumFctyAllocProdVolume(
    p_object_id       production_facility.object_id%TYPE,
    p_phase    VARCHAR2,
    p_daytime  DATE)

RETURN NUMBER
--</EC-DOC>
IS

ln_sum NUMBER;

BEGIN

   SELECT decode(p_phase,
   'NET_OIL_VOL',SUM(pw.alloc_net_oil_vol),
   'WAT_VOL',SUM(pw.alloc_water_vol),
   'GAS_VOL',SUM(pw.alloc_gas_vol),
   'COND_VOL',SUM(pw.alloc_cond_vol),
   'GL_VOL',SUM(pw.alloc_gl_vol),
   'DILUENT_VOL',SUM(pw.alloc_diluent_vol),
   'CO2_VOL',SUM(pw.alloc_co2_vol))
   INTO ln_sum
   FROM pwel_day_alloc pw, well_version wv
      WHERE wv.op_fcty_class_1_id = p_object_id
      AND pw.object_id = wv.object_id
      AND pw.daytime between wv.daytime and nvl(wv.end_date-1,p_daytime)
      AND pw.daytime = p_daytime;


   RETURN ln_sum;

END sumFctyAllocProdVolume;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : sumFctyAllocProdMass                                             --
-- Description    : Returns sum of well alloc prod mass for a given facility and day.           --
--                                                              --
-- Preconditions  :                                                                              --
-- Postconditions :                                                                              --
--                                                                                               --
-- Using tables   : pwel_day_alloc                                                              --
--                                                                                               --
-- Using functions:                                       --
--                                                                                               --
-- Configuration                                                                                 --
-- required       :                                                                              --
--                                                                                               --
-- Behaviour      :                                                                              --
--                                                                                               --
---------------------------------------------------------------------------------------------------
FUNCTION sumFctyAllocProdMass(
    p_object_id       production_facility.object_id%TYPE,
    p_phase    VARCHAR2,
    p_daytime  DATE)

RETURN NUMBER
--</EC-DOC>
IS

ln_sum NUMBER;

BEGIN

   SELECT decode(p_phase,
   'NET_OIL_MASS',SUM(pw.alloc_net_oil_mass),
   'WAT_MASS',SUM(pw.alloc_water_mass),
   'GAS_MASS',SUM(pw.alloc_gas_mass),
   'COND_MASS',SUM(pw.alloc_cond_mass))
   INTO ln_sum
   FROM pwel_day_alloc pw, well_version wv
      WHERE wv.op_fcty_class_1_id = p_object_id
      AND pw.object_id = wv.object_id
      AND pw.daytime between wv.daytime and nvl(wv.end_date-1,p_daytime)
      AND pw.daytime = p_daytime;


   RETURN ln_sum;

END sumFctyAllocProdMass;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : sumFctyAllocInjVolume                                               --
-- Description    : Returns sum of well alloc injection vol for a given facility and day.           --
--                                                              --
-- Preconditions  :                                                                              --
-- Postconditions :                                                                              --
--                                                                                               --
-- Using tables   : iwel_day_alloc                                                              --
--                                                                                               --
-- Using functions:                                       --
--                                                                                               --
-- Configuration                                                                                 --
-- required       :                                                                              --
--                                                                                               --
-- Behaviour      :                                                                              --
--                                                                                               --
---------------------------------------------------------------------------------------------------
FUNCTION sumFctyAllocInjVolume(
    p_object_id       production_facility.object_id%TYPE,
    p_phase    VARCHAR2,
    p_daytime  DATE)

RETURN NUMBER
--</EC-DOC>
IS

ln_sum NUMBER;

BEGIN

   SELECT sum(iw.alloc_inj_vol)
   INTO ln_sum
   FROM iwel_day_alloc iw, well_version wv
      WHERE wv.op_fcty_class_1_id = p_object_id
      AND iw.object_id = wv.object_id
      AND iw.inj_type = p_phase
      AND iw.daytime between wv.daytime and nvl(wv.end_date-1,p_daytime)
      AND iw.daytime = p_daytime;


   RETURN ln_sum;

END sumFctyAllocInjVolume;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : sumFctyAllocInjMass                                               --
-- Description    : Returns sum of well alloc injection mass for a given facility and day.           --
--                                                              --
-- Preconditions  :                                                                              --
-- Postconditions :                                                                              --
--                                                                                               --
-- Using tables   : iwel_day_alloc                                                              --
--                                                                                               --
-- Using functions:                                       --
--                                                                                               --
-- Configuration                                                                                 --
-- required       :                                                                              --
--                                                                                               --
-- Behaviour      :                                                                              --
--                                                                                               --
---------------------------------------------------------------------------------------------------
FUNCTION sumFctyAllocInjMass(
    p_object_id       production_facility.object_id%TYPE,
    p_phase    VARCHAR2,
    p_daytime  DATE)

RETURN NUMBER
--</EC-DOC>
IS

ln_sum NUMBER;

BEGIN

   SELECT sum(iw.alloc_inj_mass)
   INTO ln_sum
   FROM iwel_day_alloc iw, well_version wv
      WHERE wv.op_fcty_class_1_id = p_object_id
      AND iw.object_id = wv.object_id
      AND iw.inj_type = p_phase
      AND iw.daytime between wv.daytime and nvl(wv.end_date-1,p_daytime)
      AND iw.daytime = p_daytime;


   RETURN ln_sum;

END sumFctyAllocInjMass;



END;