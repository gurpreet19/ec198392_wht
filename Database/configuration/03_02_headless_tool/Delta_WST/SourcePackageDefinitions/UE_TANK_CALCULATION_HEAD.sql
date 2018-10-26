CREATE OR REPLACE PACKAGE Ue_Tank_Calculation IS

/****************************************************************
** Package        :  Ue_Tank_Calculation, header part
***
** Date:       Whom:   Change description:
** --------    -----   --------------------------------------------
** 21.12.2007  oonnnng ECPD-6716:  Add getBSW() function.
** 07.01.2010  oonnnng ECPD-13585:  Add calcRoofDisplacementVol() function.
** 12.08.2013  kumarsur ECPD-22316:  Add findBlendShrinkageFactor() function.
** 27.05.2014  makkkkam ECPD-27440: Add findDiluentDens, findBitumenDens, findNetStdOilVol, findNetDiluentVol.
*****************************************************************/


FUNCTION getGrsVol(
   p_object_id tank.object_id%TYPE,
   p_meas_event_type  TANK_MEASUREMENT.MEASUREMENT_EVENT_TYPE%TYPE,
   p_daytime  DATE)
RETURN NUMBER;


FUNCTION getGrsMass(
   p_object_id tank.object_id%TYPE,
   p_meas_event_type  TANK_MEASUREMENT.MEASUREMENT_EVENT_TYPE%TYPE,
   p_daytime     DATE)
RETURN NUMBER;


FUNCTION getNetMass(
   p_object_id tank.object_id%TYPE,
   p_meas_event_type  TANK_MEASUREMENT.MEASUREMENT_EVENT_TYPE%TYPE,
   p_daytime     DATE)
RETURN NUMBER;


FUNCTION getVolumeCorrectionFactor(
   p_object_id tank.object_id%TYPE,
   p_meas_event_type  TANK_MEASUREMENT.MEASUREMENT_EVENT_TYPE%TYPE,
   p_daytime     DATE)
RETURN NUMBER;


FUNCTION getWaterVol(
   p_object_id tank.object_id%TYPE,
   p_meas_event_type  TANK_MEASUREMENT.MEASUREMENT_EVENT_TYPE%TYPE,
   p_daytime     DATE)
RETURN NUMBER;

FUNCTION getFreeWaterVol(
   p_object_id tank.object_id%TYPE,
   p_meas_event_type  TANK_MEASUREMENT.MEASUREMENT_EVENT_TYPE%TYPE,
   p_daytime     DATE)
RETURN NUMBER;


FUNCTION getObsDens(
  p_object_id tank.object_id%TYPE,
   p_meas_event_type  TANK_MEASUREMENT.MEASUREMENT_EVENT_TYPE%TYPE,
   p_daytime     DATE)
RETURN NUMBER;

FUNCTION getBSWVol(
   p_object_id tank.object_id%TYPE,
   p_meas_event_type  TANK_MEASUREMENT.MEASUREMENT_EVENT_TYPE%TYPE,
   p_daytime     DATE)
RETURN NUMBER;

FUNCTION getStdDens(
  p_object_id tank.object_id%TYPE,
  p_meas_event_type  TANK_MEASUREMENT.MEASUREMENT_EVENT_TYPE%TYPE,
  p_daytime     DATE)
RETURN NUMBER;

FUNCTION getBSWWT(
   p_object_id tank.object_id%TYPE,
   p_meas_event_type  TANK_MEASUREMENT.MEASUREMENT_EVENT_TYPE%TYPE,
   p_daytime     DATE)
RETURN NUMBER;

FUNCTION calcRoofDisplacementVol(
   p_object_id          TANK.OBJECT_ID%TYPE,
   p_meas_event_type    TANK_MEASUREMENT.MEASUREMENT_EVENT_TYPE%TYPE,
   p_dip_level          NUMBER,
   p_daytime            DATE)
RETURN NUMBER;

FUNCTION findBlendShrinkageFactor(
    p_object_id          TANK.OBJECT_ID%TYPE,
    p_meas_event_type    TANK_MEASUREMENT.MEASUREMENT_EVENT_TYPE%TYPE,
    p_daytime            DATE,
    p_diluent_dens       NUMBER,
	p_bitumen_dens       NUMBER,
	p_tank_dens          NUMBER)
RETURN NUMBER;

FUNCTION findDiluentDens(
   p_object_id TANK.object_id%TYPE,
   p_meas_event_type  TANK_MEASUREMENT.MEASUREMENT_EVENT_TYPE%TYPE,
   p_daytime     DATE)
RETURN NUMBER;

FUNCTION findBitumenDens(
   p_object_id TANK.object_id%TYPE,
   p_meas_event_type  TANK_MEASUREMENT.MEASUREMENT_EVENT_TYPE%TYPE,
   p_daytime     DATE)
RETURN NUMBER;

FUNCTION findNetStdOilVol(
   p_object_id TANK.object_id%TYPE,
   p_meas_event_type  TANK_MEASUREMENT.MEASUREMENT_EVENT_TYPE%TYPE,
   p_daytime     DATE)
RETURN NUMBER;

FUNCTION findNetDiluentVol(
   p_object_id TANK.object_id%TYPE,
   p_meas_event_type  TANK_MEASUREMENT.MEASUREMENT_EVENT_TYPE%TYPE,
   p_daytime     DATE)
RETURN NUMBER;

END Ue_Tank_Calculation;