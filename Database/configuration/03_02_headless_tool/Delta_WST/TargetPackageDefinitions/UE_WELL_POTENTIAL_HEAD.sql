CREATE OR REPLACE PACKAGE Ue_Well_Potential IS

/****************************************************************
** Package        :  Ue_Well_Potential, header part
*
*****************************************************************/


FUNCTION getOilMassPotential(
   p_object_id well.object_id%TYPE,
   p_daytime  DATE)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (getOilMassPotential, WNDS, WNPS, RNPS);


FUNCTION getGasMassPotential(
   p_object_id well.object_id%TYPE,
   p_daytime  DATE)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (getGasMassPotential, WNDS, WNPS, RNPS);


FUNCTION getCondMassPotential(
   p_object_id well.object_id%TYPE,
   p_daytime  DATE)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (getCondMassPotential, WNDS, WNPS, RNPS);


FUNCTION getWaterMassPotential(
   p_object_id well.object_id%TYPE,
   p_daytime  DATE)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (getWaterMassPotential, WNDS, WNPS, RNPS);


FUNCTION getOilProductionPotential(
   p_object_id well.object_id%TYPE,
   p_daytime  DATE)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (getOilProductionPotential, WNDS, WNPS, RNPS);


FUNCTION getGasProductionPotential(
   p_object_id well.object_id%TYPE,
   p_daytime  DATE)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (getGasProductionPotential, WNDS, WNPS, RNPS);


FUNCTION getConProductionPotential(
   p_object_id well.object_id%TYPE,
   p_daytime  DATE)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (getConProductionPotential, WNDS, WNPS, RNPS);


FUNCTION getWatProductionPotential(
   p_object_id well.object_id%TYPE,
   p_daytime  DATE)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (getWatProductionPotential, WNDS, WNPS, RNPS);


FUNCTION getGasInjectionPotential(
   p_object_id well.object_id%TYPE,
   p_daytime  DATE)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (getGasInjectionPotential, WNDS, WNPS, RNPS);


FUNCTION getWatInjectionPotential(
   p_object_id well.object_id%TYPE,
   p_daytime  DATE)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (getWatInjectionPotential, WNDS, WNPS, RNPS);


FUNCTION getSteamInjectionPotential(
   p_object_id well.object_id%TYPE,
   p_daytime  DATE)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (getSteamInjectionPotential, WNDS, WNPS, RNPS);


FUNCTION getCo2InjectionPotential(
   p_object_id well.object_id%TYPE,
   p_daytime  DATE)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (getCo2InjectionPotential, WNDS, WNPS, RNPS);


FUNCTION getGasLiftPotential(
   p_object_id well.object_id%TYPE,
   p_daytime  DATE)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (getGasLiftPotential, WNDS, WNPS, RNPS);


FUNCTION getDiluentPotential(
   p_object_id well.object_id%TYPE,
   p_daytime  DATE)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (getDiluentPotential, WNDS, WNPS, RNPS);


END Ue_Well_Potential;