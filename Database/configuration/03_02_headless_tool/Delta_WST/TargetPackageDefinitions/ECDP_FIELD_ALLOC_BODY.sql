CREATE OR REPLACE PACKAGE BODY EcDp_Field_Alloc IS

/****************************************************************
** Package        :  EcDp_Field_Alloc, body part
**
** $Revision: 1.1 $
**
** Purpose        :  Provides geo field alloc data services
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
-- Function       : sumFieldAllocProdVolume                                               --
-- Description    : Returns sum of well alloc prod vol for a given geo field and day.           --
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
FUNCTION sumFieldAllocProdVolume(
    p_object_id       field.object_id%TYPE,
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
      WHERE wv.geo_field_id = p_object_id
      AND pw.object_id = wv.object_id
      AND pw.daytime between wv.daytime and nvl(wv.end_date-1,p_daytime)
      AND pw.daytime = p_daytime;


   RETURN ln_sum;

END sumFieldAllocProdVolume;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : sumFieldAllocProdMass                                             --
-- Description    : Returns sum of well alloc prod mass for a given geo field and day.           --
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
FUNCTION sumFieldAllocProdMass(
    p_object_id       field.object_id%TYPE,
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
      WHERE wv.geo_field_id = p_object_id
      AND pw.object_id = wv.object_id
      AND pw.daytime between wv.daytime and nvl(wv.end_date-1,p_daytime)
      AND pw.daytime = p_daytime;


   RETURN ln_sum;

END sumFieldAllocProdMass;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : sumFieldAllocInjVolume                                               --
-- Description    : Returns sum of well alloc injection vol for a given geo field and day.           --
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
FUNCTION sumFieldAllocInjVolume(
    p_object_id       field.object_id%TYPE,
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
      WHERE wv.geo_field_id = p_object_id
      AND iw.object_id = wv.object_id
      AND iw.inj_type = p_phase
      AND iw.daytime between wv.daytime and nvl(wv.end_date-1,p_daytime)
      AND iw.daytime = p_daytime;


   RETURN ln_sum;

END sumFieldAllocInjVolume;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : sumFieldAllocInjMass                                               --
-- Description    : Returns sum of well alloc injection mass for a given geo field and day.           --
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
FUNCTION sumFieldAllocInjMass(
    p_object_id       field.object_id%TYPE,
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
      WHERE wv.geo_field_id = p_object_id
      AND iw.object_id = wv.object_id
      AND iw.inj_type = p_phase
      AND iw.daytime between wv.daytime and nvl(wv.end_date-1,p_daytime)
      AND iw.daytime = p_daytime;



   RETURN ln_sum;

END sumFieldAllocInjMass;


END EcDp_Field_Alloc;