CREATE OR REPLACE PACKAGE Ue_Well_Potential IS

/****************************************************************
** Package        :  Ue_Well_Potential, header part
*
*****************************************************************/


FUNCTION getOilMassPotential(
   p_object_id well.object_id%TYPE,
   p_daytime  DATE)
RETURN NUMBER;


FUNCTION getGasMassPotential(
   p_object_id well.object_id%TYPE,
   p_daytime  DATE)
RETURN NUMBER;


FUNCTION getCondMassPotential(
   p_object_id well.object_id%TYPE,
   p_daytime  DATE)
RETURN NUMBER;


FUNCTION getWaterMassPotential(
   p_object_id well.object_id%TYPE,
   p_daytime  DATE)
RETURN NUMBER;


FUNCTION getOilProductionPotential(
   p_object_id well.object_id%TYPE,
   p_daytime  DATE)
RETURN NUMBER;


FUNCTION getGasProductionPotential(
   p_object_id well.object_id%TYPE,
   p_daytime  DATE)
RETURN NUMBER;


FUNCTION getConProductionPotential(
   p_object_id well.object_id%TYPE,
   p_daytime  DATE)
RETURN NUMBER;


FUNCTION getWatProductionPotential(
   p_object_id well.object_id%TYPE,
   p_daytime  DATE)
RETURN NUMBER;


FUNCTION getGasInjectionPotential(
   p_object_id well.object_id%TYPE,
   p_daytime  DATE)
RETURN NUMBER;


FUNCTION getWatInjectionPotential(
   p_object_id well.object_id%TYPE,
   p_daytime  DATE)
RETURN NUMBER;


FUNCTION getSteamInjectionPotential(
   p_object_id well.object_id%TYPE,
   p_daytime  DATE)
RETURN NUMBER;


FUNCTION getCo2InjectionPotential(
   p_object_id well.object_id%TYPE,
   p_daytime  DATE)
RETURN NUMBER;


FUNCTION getGasLiftPotential(
   p_object_id well.object_id%TYPE,
   p_daytime  DATE)
RETURN NUMBER;


FUNCTION getDiluentPotential(
   p_object_id well.object_id%TYPE,
   p_daytime  DATE)
RETURN NUMBER;


END Ue_Well_Potential;