CREATE OR REPLACE PACKAGE Ue_Tank_Calculation IS

/****************************************************************
** Package        :  Ue_Tank_Calculation, header part
***
** Date:       Whom:   Change description:
** --------    -----   --------------------------------------------
** 21.12.2007  oonnnng ECPD-6716:  Add getBSW() function.
** 07.01.2010  oonnnng ECPD-13585:  Add calcRoofDisplacementVol() function.
*****************************************************************/


FUNCTION getGrsVol(
   p_object_id tank.object_id%TYPE,
   p_meas_event_type  TANK_MEASUREMENT.MEASUREMENT_EVENT_TYPE%TYPE,
   p_daytime  DATE)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (getGrsVol, WNDS, WNPS, RNPS);


FUNCTION getGrsMass(
   p_object_id tank.object_id%TYPE,
   p_meas_event_type  TANK_MEASUREMENT.MEASUREMENT_EVENT_TYPE%TYPE,
   p_daytime     DATE)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (getGrsMass, WNDS, WNPS, RNPS);


FUNCTION getNetMass(
   p_object_id tank.object_id%TYPE,
   p_meas_event_type  TANK_MEASUREMENT.MEASUREMENT_EVENT_TYPE%TYPE,
   p_daytime     DATE)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (getNetMass, WNDS, WNPS, RNPS);


FUNCTION getVolumeCorrectionFactor(
   p_object_id tank.object_id%TYPE,
   p_meas_event_type  TANK_MEASUREMENT.MEASUREMENT_EVENT_TYPE%TYPE,
   p_daytime     DATE)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (getVolumeCorrectionFactor, WNDS, WNPS, RNPS);


FUNCTION getWaterVol(
   p_object_id tank.object_id%TYPE,
   p_meas_event_type  TANK_MEASUREMENT.MEASUREMENT_EVENT_TYPE%TYPE,
   p_daytime     DATE)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (getWaterVol, WNDS, WNPS, RNPS);

FUNCTION getFreeWaterVol(
   p_object_id tank.object_id%TYPE,
   p_meas_event_type  TANK_MEASUREMENT.MEASUREMENT_EVENT_TYPE%TYPE,
   p_daytime     DATE)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (getFreeWaterVol, WNDS, WNPS, RNPS);


FUNCTION getObsDens(
  p_object_id tank.object_id%TYPE,
   p_meas_event_type  TANK_MEASUREMENT.MEASUREMENT_EVENT_TYPE%TYPE,
   p_daytime     DATE)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES(getObsDens, WNDS, WNPS, RNPS);

FUNCTION getBSWVol(
   p_object_id tank.object_id%TYPE,
   p_meas_event_type  TANK_MEASUREMENT.MEASUREMENT_EVENT_TYPE%TYPE,
   p_daytime     DATE)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES(getBSWVol, WNDS, WNPS, RNPS);

FUNCTION getStdDens(
  p_object_id tank.object_id%TYPE,
  p_meas_event_type  TANK_MEASUREMENT.MEASUREMENT_EVENT_TYPE%TYPE,
  p_daytime     DATE)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES(getStdDens, WNDS, WNPS, RNPS);

FUNCTION getBSWWT(
   p_object_id tank.object_id%TYPE,
   p_meas_event_type  TANK_MEASUREMENT.MEASUREMENT_EVENT_TYPE%TYPE,
   p_daytime     DATE)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES(getBSWWT, WNDS, WNPS, RNPS);

FUNCTION calcRoofDisplacementVol(
   p_object_id          TANK.OBJECT_ID%TYPE,
   p_meas_event_type    TANK_MEASUREMENT.MEASUREMENT_EVENT_TYPE%TYPE,
   p_dip_level          NUMBER,
   p_daytime            DATE)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES(calcRoofDisplacementVol, WNDS, WNPS, RNPS);

END Ue_Tank_Calculation;