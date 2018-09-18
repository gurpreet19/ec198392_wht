CREATE OR REPLACE PACKAGE Ue_Flowline_Theoretical IS

/****************************************************************
** Package        :  Ue_Flowline_Theoretical, header part
*
** Version  Date        Whom      Change description:
** -------  ------      -----     -----------------------------------
**          06.05.2014  leongwen  ECPD-22866: Added new function getInjectedStdRateDay
*****************************************************************/


FUNCTION getOilStdRateDay(
   p_object_id flowline.object_id%TYPE,
   p_daytime  DATE)
RETURN NUMBER;

FUNCTION getSubseaWellStdRateDay(
   p_object_id flowline.object_id%TYPE,
   p_daytime  DATE)
RETURN NUMBER;

FUNCTION getSubseaWellStdRateSubDay(
   p_object_id flowline.object_id%TYPE,
   p_daytime  DATE)
RETURN NUMBER;


FUNCTION getGasStdRateDay(
   p_object_id flowline.object_id%TYPE,
   p_daytime     DATE)
RETURN NUMBER;


FUNCTION getWatStdRateDay(
   p_object_id flowline.object_id%TYPE,
   p_daytime     DATE)
RETURN NUMBER;


FUNCTION getCondStdRateDay(
   p_object_id flowline.object_id%TYPE,
   p_daytime     DATE)
RETURN NUMBER;

FUNCTION getGasLiftStdRateDay(
   p_object_id flowline.object_id%TYPE,
   p_daytime  DATE)
RETURN NUMBER;

FUNCTION findWaterCutPct(
   p_object_id flowline.object_id%TYPE,
   p_daytime  DATE)
RETURN NUMBER;

FUNCTION findCondGasRatio(
   p_object_id flowline.object_id%TYPE,
   p_daytime  DATE)
RETURN NUMBER;

FUNCTION findWaterGasRatio(
   p_object_id flowline.object_id%TYPE,
   p_daytime  DATE)
RETURN NUMBER;

FUNCTION findGasOilRatio(
   p_object_id flowline.object_id%TYPE,
   p_daytime  DATE)
RETURN NUMBER;

FUNCTION findWetDryFactor(
   p_object_id flowline.object_id%TYPE,
   p_daytime  DATE)
RETURN NUMBER;


FUNCTION getOilStdVolSubDay(
   p_object_id   flowline.object_id%TYPE,
   p_daytime     DATE)
RETURN NUMBER;

FUNCTION getGasStdVolSubDay(
   p_object_id   flowline.object_id%TYPE,
   p_daytime     DATE)
RETURN NUMBER;

FUNCTION getWatStdVolSubDay(
   p_object_id   flowline.object_id%TYPE,
   p_daytime     DATE)
RETURN NUMBER;

FUNCTION findOilMassDay(
   p_object_id   flowline.object_id%TYPE,
   p_daytime     DATE)
RETURN NUMBER;

FUNCTION findGasMassDay(
   p_object_id flowline.object_id%TYPE,
   p_daytime     DATE)
RETURN NUMBER;

FUNCTION findWaterMassDay(
   p_object_id flowline.object_id%TYPE,
   p_daytime     DATE)
RETURN NUMBER;

FUNCTION findCondMassDay(
   p_object_id flowline.object_id%TYPE,
   p_daytime     DATE)
RETURN NUMBER;

FUNCTION getCondStdVolSubDay(
   p_object_id   flowline.object_id%TYPE,
   p_daytime     DATE)
RETURN NUMBER;

FUNCTION getInjectedStdRateDay(
   p_object_id   flowline.object_id%TYPE,
   p_inj_type    VARCHAR2,
   p_daytime     DATE)
RETURN NUMBER;

END Ue_Flowline_Theoretical;