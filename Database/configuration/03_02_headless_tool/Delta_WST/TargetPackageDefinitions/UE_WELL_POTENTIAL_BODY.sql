CREATE OR REPLACE PACKAGE BODY Ue_Well_Potential IS
/****************************************************************
** Package        :  Ue_Well_Potential, body part
**
** This package is used to program potential calculation when a predefined method supplied by EC does not cover the requirements.
** Upgrade processes will never replace this package.
*****************************************************************/

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getOilMassPotential
-- Description    : Returns potential oil mass
---------------------------------------------------------------------------------------------------
FUNCTION getOilMassPotential(
   p_object_id   well.object_id%TYPE,
   p_daytime     DATE )
RETURN NUMBER
--</EC-DOC>
IS

BEGIN
   RETURN NULL;
END getOilMassPotential;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getGasMassPotential
-- Description    : Returns potential gas mass
---------------------------------------------------------------------------------------------------
FUNCTION getGasMassPotential(
   p_object_id   well.object_id%TYPE,
   p_daytime     DATE )
RETURN NUMBER
--</EC-DOC>
IS

BEGIN
   RETURN NULL;
END getGasMassPotential;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getCondMassPotential
-- Description    : Returns potential cond mass
---------------------------------------------------------------------------------------------------
FUNCTION getCondMassPotential(
   p_object_id   well.object_id%TYPE,
   p_daytime     DATE )
RETURN NUMBER
--</EC-DOC>
IS

BEGIN
   RETURN NULL;
END getCondMassPotential;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getWaterMassPotential
-- Description    : Returns potential water mass
---------------------------------------------------------------------------------------------------
FUNCTION getWaterMassPotential(
   p_object_id   well.object_id%TYPE,
   p_daytime     DATE )
RETURN NUMBER
--</EC-DOC>
IS

BEGIN
   RETURN NULL;
END getWaterMassPotential;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getOilProductionPotential
-- Description    : Returns potential oil production volume
---------------------------------------------------------------------------------------------------
FUNCTION getOilProductionPotential(
   p_object_id   well.object_id%TYPE,
   p_daytime     DATE )
RETURN NUMBER
--</EC-DOC>
IS

BEGIN
   RETURN NULL;
END getOilProductionPotential;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getGasProductionPotential
-- Description    : Returns potential gas production volume
---------------------------------------------------------------------------------------------------
FUNCTION getGasProductionPotential(
   p_object_id   well.object_id%TYPE,
   p_daytime     DATE )
RETURN NUMBER
--</EC-DOC>
IS

BEGIN
   RETURN NULL;
END getGasProductionPotential;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getConProductionPotential
-- Description    : Returns potential condensate production volume
---------------------------------------------------------------------------------------------------
FUNCTION getConProductionPotential(
   p_object_id   well.object_id%TYPE,
   p_daytime     DATE )
RETURN NUMBER
--</EC-DOC>
IS

BEGIN
   RETURN NULL;
END getConProductionPotential;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getWatProductionPotential
-- Description    : Returns potential water production volume
---------------------------------------------------------------------------------------------------
FUNCTION getWatProductionPotential(
   p_object_id   well.object_id%TYPE,
   p_daytime     DATE )
RETURN NUMBER
--</EC-DOC>
IS

BEGIN
   RETURN NULL;
END getWatProductionPotential;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getGasInjectionPotential
-- Description    : Returns potential gas injection volume
---------------------------------------------------------------------------------------------------
FUNCTION getGasInjectionPotential(
   p_object_id   well.object_id%TYPE,
   p_daytime     DATE )
RETURN NUMBER
--</EC-DOC>
IS

BEGIN
   RETURN NULL;
END getGasInjectionPotential;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getWatInjectionPotential
-- Description    : Returns potential water injection volume
---------------------------------------------------------------------------------------------------
FUNCTION getWatInjectionPotential(
   p_object_id   well.object_id%TYPE,
   p_daytime     DATE )
RETURN NUMBER
--</EC-DOC>
IS

BEGIN
   RETURN NULL;
END getWatInjectionPotential;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getSteamInjectionPotential
-- Description    : Returns potential steam injection volume
---------------------------------------------------------------------------------------------------
FUNCTION getSteamInjectionPotential(
   p_object_id   well.object_id%TYPE,
   p_daytime     DATE )
RETURN NUMBER
--</EC-DOC>
IS

BEGIN
   RETURN NULL;
END getSteamInjectionPotential;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getCo2InjectionPotential
-- Description    : Returns potential co2 injection volume
---------------------------------------------------------------------------------------------------
FUNCTION getCo2InjectionPotential(
   p_object_id   well.object_id%TYPE,
   p_daytime     DATE )
RETURN NUMBER
--</EC-DOC>
IS

BEGIN
   RETURN NULL;
END getCo2InjectionPotential;



--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getGasLiftPotential
-- Description    : Returns potential gas lift production volume
---------------------------------------------------------------------------------------------------
FUNCTION getGasLiftPotential(
   p_object_id   well.object_id%TYPE,
   p_daytime     DATE )
RETURN NUMBER
--</EC-DOC>
IS

BEGIN
   RETURN NULL;
END getGasLiftPotential;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getDiluentPotential
-- Description    : Returns potential diluent production volume
---------------------------------------------------------------------------------------------------
FUNCTION getDiluentPotential(
   p_object_id   well.object_id%TYPE,
   p_daytime     DATE )
RETURN NUMBER
--</EC-DOC>
IS

BEGIN
   RETURN NULL;
END getDiluentPotential;


END Ue_Well_Potential;