CREATE OR REPLACE PACKAGE BODY Ue_Flowline_Theoretical IS
/****************************************************************
** Package        :  Ue_Flowline_Theoretical, body part
**
** This package is used to program theoretical calculation when a predefined method supplied by EC does not cover the requirements.
** Upgrade processes will never replace this package.
** Version  Date        Whom      Change description:
** -------  ------      -----     -----------------------------------
**
*****************************************************************/

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getOilStdRateDay
-- Description    : Returns theoretical oil volume
---------------------------------------------------------------------------------------------------
FUNCTION getOilStdRateDay(
   p_object_id   flowline.object_id%TYPE,
   p_daytime     DATE )
RETURN NUMBER
--</EC-DOC>
IS

BEGIN
   RETURN NULL;
END getOilStdRateDay;

--<EC-DOC>

---------------------------------------------------------------------------------------------------
-- Function       : getSubseaWellStdRateDay
-- Description    : Returns theoretical flowline rate
---------------------------------------------------------------------------------------------------
FUNCTION getSubseaWellStdRateDay(
   p_object_id   flowline.object_id%TYPE,
   p_daytime     DATE)
RETURN NUMBER
--</EC-DOC>
IS

BEGIN
   RETURN NULL;
END getSubseaWellStdRateDay;

--<EC-DOC>

---------------------------------------------------------------------------------------------------
-- Function       : getSubseaWellStdRateSubDay
-- Description    : Returns theoretical flowline rate
---------------------------------------------------------------------------------------------------
FUNCTION getSubseaWellStdRateSubDay(
   p_object_id   flowline.object_id%TYPE,
   p_daytime     DATE)
RETURN NUMBER
--</EC-DOC>
IS

BEGIN
   RETURN NULL;
END getSubseaWellStdRateSubDay;


--<EC-DOC>

---------------------------------------------------------------------------------------------------
-- Function       : getGasStdRateDay
-- Description    : Returns theoretical gas volume
---------------------------------------------------------------------------------------------------
FUNCTION getGasStdRateDay(
   p_object_id   flowline.object_id%TYPE,
   p_daytime     DATE)
RETURN NUMBER
--</EC-DOC>
IS

BEGIN
   RETURN NULL;
END getGasStdRateDay;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getWatStdRateDay
-- Description    : Returns theoretical water volume
---------------------------------------------------------------------------------------------------
FUNCTION getWatStdRateDay(
   p_object_id   flowline.object_id%TYPE,
   p_daytime     DATE)
RETURN NUMBER
--</EC-DOC>
IS

BEGIN
   RETURN NULL;
END getWatStdRateDay;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getCondStdRateDay
-- Description    : Returns theoretical condensate volume
---------------------------------------------------------------------------------------------------
FUNCTION getCondStdRateDay(
   p_object_id   flowline.object_id%TYPE,
   p_daytime     DATE)
RETURN NUMBER
--</EC-DOC>
IS

BEGIN
   RETURN null;
END getCondStdRateDay;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getGasLiftStdRateDay
-- Description    : Returns theoretical gas lift volume
---------------------------------------------------------------------------------------------------
FUNCTION getGasLiftStdRateDay(
   p_object_id   flowline.object_id%TYPE,
   p_daytime     DATE )
RETURN NUMBER
--</EC-DOC>
IS

BEGIN
   RETURN NULL;
END getGasLiftStdRateDay;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : findWaterCutPct
-- Description    : Returns BSW volume for flowline on a given day at standard conditions, source method specifiedReturns theoretical gas lift volume
---------------------------------------------------------------------------------------------------
FUNCTION findWaterCutPct(
   p_object_id   flowline.object_id%TYPE,
   p_daytime     DATE )
RETURN NUMBER
--</EC-DOC>
IS

BEGIN
   RETURN NULL;
END findWaterCutPct;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : findCondGasRatio
-- Description    : Returns Condensate Gas Ratio for flowline on a given day at standard conditions, source method specified
---------------------------------------------------------------------------------------------------
FUNCTION findCondGasRatio(
   p_object_id   flowline.object_id%TYPE,
   p_daytime     DATE )
RETURN NUMBER
--</EC-DOC>
IS

BEGIN
   RETURN NULL;
END findCondGasRatio;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : findGasOilRatio
-- Description    : Returns Gas Oil Ratio for flowline on a given day at standard conditions, source method specified
---------------------------------------------------------------------------------------------------
FUNCTION findGasOilRatio(
   p_object_id   flowline.object_id%TYPE,
   p_daytime     DATE )
RETURN NUMBER
--</EC-DOC>
IS

BEGIN
   RETURN NULL;
END findGasOilRatio;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : findWetDryFactor
-- Description    : Returns Wet Dry Factor Ratio for flowline on a given day at standard conditions, source method specified
---------------------------------------------------------------------------------------------------
FUNCTION findWetDryFactor(
   p_object_id   flowline.object_id%TYPE,
   p_daytime     DATE )
RETURN NUMBER
--</EC-DOC>
IS

BEGIN
   RETURN NULL;
END findWetDryFactor;

--<EC-DOC>

---------------------------------------------------------------------------------------------------
-- Function       : getOilStdVolSubDay
-- Description    : Returns sub daily theoretical oil volume
---------------------------------------------------------------------------------------------------
FUNCTION getOilStdVolSubDay(
   p_object_id   flowline.object_id%TYPE,
   p_daytime     DATE )
RETURN NUMBER
--</EC-DOC>
IS

BEGIN
   RETURN NULL;
END getOilStdVolSubDay;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getGasStdVolSubDay
-- Description    : Returns sub daily theoretical gas volume
---------------------------------------------------------------------------------------------------
FUNCTION getGasStdVolSubDay(
   p_object_id   flowline.object_id%TYPE,
   p_daytime     DATE )
RETURN NUMBER
--</EC-DOC>
IS

BEGIN
   RETURN NULL;
END getGasStdVolSubDay;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getWatStdVolSubDay
-- Description    : Returns sub daily theoretical water volume
---------------------------------------------------------------------------------------------------
FUNCTION getWatStdVolSubDay(
   p_object_id   flowline.object_id%TYPE,
   p_daytime     DATE )
RETURN NUMBER
--</EC-DOC>
IS

BEGIN
   RETURN NULL;
END getWatStdVolSubDay;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : findOilMassDay
---------------------------------------------------------------------------------------------------
FUNCTION findOilMassDay(
    p_object_id   flowline.object_id%TYPE,
    p_daytime     DATE)
RETURN NUMBER
--</EC-DOC>
IS

BEGIN
   RETURN NULL;
END findOilMassDay;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : findGasMassDay
---------------------------------------------------------------------------------------------------
FUNCTION findGasMassDay(
    p_object_id   flowline.object_id%TYPE,
    p_daytime     DATE)
RETURN NUMBER
--</EC-DOC>
IS

BEGIN
   RETURN NULL;
END findGasMassDay;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : findWaterMassDay
---------------------------------------------------------------------------------------------------
FUNCTION findWaterMassDay(
    p_object_id   flowline.object_id%TYPE,
    p_daytime     DATE)
RETURN NUMBER
--</EC-DOC>
IS

BEGIN
   RETURN NULL;
END findWaterMassDay;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : findCondMassDay
---------------------------------------------------------------------------------------------------
FUNCTION findCondMassDay(
    p_object_id   flowline.object_id%TYPE,
    p_daytime     DATE)
RETURN NUMBER
--</EC-DOC>
IS

BEGIN
   RETURN NULL;
END findCondMassDay;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getCondStdVolSubDay
-- Description    : Returns sub daily theoretical condensate volume
---------------------------------------------------------------------------------------------------
FUNCTION getCondStdVolSubDay(
   p_object_id   flowline.object_id%TYPE,
   p_daytime     DATE )
RETURN NUMBER
--</EC-DOC>
IS

BEGIN
   RETURN NULL;
END getCondStdVolSubDay;

--<EC-DOC>

END Ue_Flowline_theoretical;