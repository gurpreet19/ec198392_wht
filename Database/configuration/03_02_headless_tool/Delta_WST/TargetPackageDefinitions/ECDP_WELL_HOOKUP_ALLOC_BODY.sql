CREATE OR REPLACE PACKAGE BODY EcDp_Well_Hookup_Alloc IS

/****************************************************************
** Package        :  EcDp_Well_Hookup_Alloc, body part
**
** $Revision: 1.1 $
**
** Purpose        :  Provides well hookup alloc data services
**
** Documentation  :  www.energy-components.com
**
** Created  : 24.09.09 Siti Azura Alias
**
** Modification history:
**
** Date     Whom    Change description:
** -------- ------  -------------------------------------------

*****************************************************************/

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : sumWellHookAllocProdVolume                                               --
-- Description    : Returns sum of well alloc prod vol for a given well hookup and day.           --
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
FUNCTION sumWellHookAllocProdVolume(
    p_object_id       well_hookup.object_id%TYPE,
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
      WHERE wv.op_well_hookup_id = p_object_id
      AND pw.object_id = wv.object_id
      AND pw.daytime between wv.daytime and nvl(wv.end_date-1,p_daytime)
      AND pw.daytime = p_daytime;


   RETURN ln_sum;

END sumWellHookAllocProdVolume;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : sumWellHookAllocProdMass                                             --
-- Description    : Returns sum of well alloc prod mass for a given well hookup and day.           --
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
FUNCTION sumWellHookAllocProdMass(
    p_object_id       well_hookup.object_id%TYPE,
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
      WHERE wv.op_well_hookup_id = p_object_id
      AND pw.object_id = wv.object_id
      AND pw.daytime between wv.daytime and nvl(wv.end_date-1,p_daytime)
      AND pw.daytime = p_daytime;


   RETURN ln_sum;

END sumWellHookAllocProdMass;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : sumWellHookAllocInjVolume                                               --
-- Description    : Returns sum of well alloc injection vol for a given Well Hookup and day.           --
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
FUNCTION sumWellHookAllocInjVolume(
    p_object_id       well_hookup.object_id%TYPE,
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
      WHERE wv.op_well_hookup_id = p_object_id
      AND iw.object_id = wv.object_id
      AND iw.inj_type = p_phase
      AND iw.daytime between wv.daytime and nvl(wv.end_date-1,p_daytime)
      AND iw.daytime = p_daytime;


   RETURN ln_sum;

END sumWellHookAllocInjVolume;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : sumWellHookAllocInjMass                                               --
-- Description    : Returns sum of well alloc injection mass for a given well hookup and day.           --
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
FUNCTION sumWellHookAllocInjMass(
    p_object_id       well_hookup.object_id%TYPE,
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
      WHERE wv.op_well_hookup_id = p_object_id
      AND iw.object_id = wv.object_id
      AND iw.inj_type = p_phase
      AND iw.daytime between wv.daytime and nvl(wv.end_date-1,p_daytime)
      AND iw.daytime = p_daytime;


   RETURN ln_sum;

END sumWellHookAllocInjMass;


END EcDp_Well_Hookup_Alloc;