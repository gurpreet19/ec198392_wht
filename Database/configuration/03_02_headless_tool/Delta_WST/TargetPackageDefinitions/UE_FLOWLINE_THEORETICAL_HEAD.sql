CREATE OR REPLACE PACKAGE Ue_Flowline_Theoretical IS

/****************************************************************
** Package        :  Ue_Flowline_Theoretical, header part
*
** Version  Date        Whom      Change description:
** -------  ------      -----     -----------------------------------

*****************************************************************/


FUNCTION getOilStdRateDay(
   p_object_id flowline.object_id%TYPE,
   p_daytime  DATE)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (getOilStdRateDay, WNDS, WNPS, RNPS);

FUNCTION getSubseaWellStdRateDay(
   p_object_id flowline.object_id%TYPE,
   p_daytime  DATE)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (getSubseaWellStdRateDay, WNDS, WNPS, RNPS);

FUNCTION getSubseaWellStdRateSubDay(
   p_object_id flowline.object_id%TYPE,
   p_daytime  DATE)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (getSubseaWellStdRateSubDay, WNDS, WNPS, RNPS);


FUNCTION getGasStdRateDay(
   p_object_id flowline.object_id%TYPE,
   p_daytime     DATE)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (getGasStdRateDay, WNDS, WNPS, RNPS);


FUNCTION getWatStdRateDay(
   p_object_id flowline.object_id%TYPE,
   p_daytime     DATE)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (getWatStdRateDay, WNDS, WNPS, RNPS);


FUNCTION getCondStdRateDay(
   p_object_id flowline.object_id%TYPE,
   p_daytime     DATE)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (getCondStdRateDay, WNDS, WNPS, RNPS);

FUNCTION getGasLiftStdRateDay(
   p_object_id flowline.object_id%TYPE,
   p_daytime  DATE)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (getGasLiftStdRateDay, WNDS, WNPS, RNPS);

FUNCTION findWaterCutPct(
   p_object_id flowline.object_id%TYPE,
   p_daytime  DATE)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (findWaterCutPct, WNDS, WNPS, RNPS);

FUNCTION findCondGasRatio(
   p_object_id flowline.object_id%TYPE,
   p_daytime  DATE)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (findCondGasRatio, WNDS, WNPS, RNPS);

FUNCTION findGasOilRatio(
   p_object_id flowline.object_id%TYPE,
   p_daytime  DATE)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (findGasOilRatio, WNDS, WNPS, RNPS);

FUNCTION findWetDryFactor(
   p_object_id flowline.object_id%TYPE,
   p_daytime  DATE)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (findWetDryFactor, WNDS, WNPS, RNPS);


FUNCTION getOilStdVolSubDay(
   p_object_id   flowline.object_id%TYPE,
   p_daytime     DATE)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (getOilStdVolSubDay, WNDS, WNPS, RNPS);

FUNCTION getGasStdVolSubDay(
   p_object_id   flowline.object_id%TYPE,
   p_daytime     DATE)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (getGasStdVolSubDay, WNDS, WNPS, RNPS);

FUNCTION getWatStdVolSubDay(
   p_object_id   flowline.object_id%TYPE,
   p_daytime     DATE)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (getWatStdVolSubDay, WNDS, WNPS, RNPS);

FUNCTION findOilMassDay(
   p_object_id   flowline.object_id%TYPE,
   p_daytime     DATE)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (findOilMassDay, WNDS, WNPS, RNPS);

FUNCTION findGasMassDay(
   p_object_id flowline.object_id%TYPE,
   p_daytime     DATE)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (findGasMassDay, WNDS, WNPS, RNPS);

FUNCTION findWaterMassDay(
   p_object_id flowline.object_id%TYPE,
   p_daytime     DATE)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (findWaterMassDay, WNDS, WNPS, RNPS);

FUNCTION findCondMassDay(
   p_object_id flowline.object_id%TYPE,
   p_daytime     DATE)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (findCondMassDay, WNDS, WNPS, RNPS);

FUNCTION getCondStdVolSubDay(
   p_object_id   flowline.object_id%TYPE,
   p_daytime     DATE)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (getCondStdVolSubDay, WNDS, WNPS, RNPS);

END Ue_Flowline_Theoretical;