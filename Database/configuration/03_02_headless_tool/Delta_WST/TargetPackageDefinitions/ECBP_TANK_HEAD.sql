CREATE OR REPLACE PACKAGE EcBp_Tank IS
/****************************************************************
** Package        :  EcBp_Tank, header part
**
** $Revision: 1.20.2.2 $
**
** Purpose        :  Finds tank volumes
**
** Documentation  :  www.energy-components.com
**
** Created  : 06.05.2002  Harald Vetrhus
**
** Modification history:
**
** Date        Whom     Change description:
** ---------   -------- --------------------------------------
** 25.10.02    HNE      Added findTankBswFrac
** 05.05.2004  FBa      Totally rewritten package for EC release 7.3
** 09.06.2004  HNE      Added p_meas_event_type to parameter list. Added two roof functions to header.
** 19.11.2005  chongjer Tracker 2458: Added findClosingGrsVol, findClosingGrsMass, findOpeningNetVol, findClosingNetVol,
**                                          findOpeningNetMass, findClosingNetMass, findOpeningWatVol, findClosingWatVol
** 02.01.2006  DN       Tracker 2288: Added lock procedures.
** 26.09.2007  rajarsar ECPD-6378: Updated findBSWVol, findObsDens and findStdDens to support User Exit.
** 08.05.2009  leongsei ECPD-11702: Added overload procedure for checkTankMeasurementLock
** 21.01.2010  rajarsar ECPD-13196: Removed calcTankWellBSW function
** 08.09.2010  saadsiti  ECPD-15639: Added new function findClosingGrsStdOilVol
** 01.11.2012  limmmchu	ECPD-22065: Enhance findNetStdOilVol, findStdDens, findBSWVol. Added findNetDiluentVol, findClosingDiluentVol, findOpeningDiluentVol, findDiluentDens, findBitumenDens, calcWeightedDensFromTaps, calcWeightedBSWFromTaps
** 21.03.2013  kumarsur	ECPD-23650: Modified calcWeightedDensFromTaps(), calcWeightedBSWFromTaps(), findNetStdOilVol(), findNetDiluentVol() and added findShrunkVol().
*****************************************************************/
FUNCTION calcRoofDisplacementVol(
  p_tank_object_id     TANK.OBJECT_ID%TYPE,
  p_meas_event_type    TANK_MEASUREMENT.MEASUREMENT_EVENT_TYPE%TYPE,
  p_dip_level          NUMBER,
  p_daytime            DATE,
  p_method             VARCHAR2 DEFAULT NULL,
  p_resolve_loop       VARCHAR2 DEFAULT NULL)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES(calcRoofDisplacementVol, WNDS, WNPS, RNPS);

FUNCTION calcRoofDisplacementMass(
  p_tank_object_id     TANK.OBJECT_ID%TYPE,
  p_meas_event_type    TANK_MEASUREMENT.MEASUREMENT_EVENT_TYPE%TYPE,
  p_daytime            DATE)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES(calcRoofDisplacementMass, WNDS, WNPS, RNPS);

FUNCTION findGrsVol(
  p_tank_object_id     TANK.OBJECT_ID%TYPE,
  p_meas_event_type    TANK_MEASUREMENT.MEASUREMENT_EVENT_TYPE%TYPE,
  p_daytime            DATE,
  p_method             VARCHAR2 DEFAULT NULL,
  p_resolve_loop       VARCHAR2 DEFAULT NULL)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES(findGrsVol, WNDS, WNPS, RNPS);

FUNCTION findGrsStdVol(
  p_tank_object_id     TANK.OBJECT_ID%TYPE,
  p_meas_event_type    TANK_MEASUREMENT.MEASUREMENT_EVENT_TYPE%TYPE,
  p_daytime            DATE,
  p_method             VARCHAR2 DEFAULT NULL,
  p_resolve_loop       VARCHAR2 DEFAULT NULL)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES(findGrsStdVol, WNDS, WNPS, RNPS);

FUNCTION findNetMass(
  p_tank_object_id     TANK.OBJECT_ID%TYPE,
  p_meas_event_type    TANK_MEASUREMENT.MEASUREMENT_EVENT_TYPE%TYPE,
  p_daytime            DATE,
  p_method             VARCHAR2 DEFAULT NULL,
  p_resolve_loop       VARCHAR2 DEFAULT NULL)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES(findNetMass, WNDS, WNPS, RNPS);

FUNCTION findGrsMass(
  p_tank_object_id     TANK.OBJECT_ID%TYPE,
  p_meas_event_type    TANK_MEASUREMENT.MEASUREMENT_EVENT_TYPE%TYPE,
  p_daytime            DATE,
  p_method             VARCHAR2 DEFAULT NULL,
  p_resolve_loop       VARCHAR2 DEFAULT NULL)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES(findGrsMass, WNDS, WNPS, RNPS);

--

FUNCTION findBSWVol(
  p_tank_object_id     TANK.OBJECT_ID%TYPE,
  p_meas_event_type    TANK_MEASUREMENT.MEASUREMENT_EVENT_TYPE%TYPE,
  p_daytime            DATE,
  p_method             VARCHAR2 DEFAULT NULL,
  p_resolve_loop       VARCHAR2 DEFAULT NULL)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES(findBSWVol, WNDS, WNPS, RNPS);

FUNCTION findBSWWt(
  p_tank_object_id     TANK.OBJECT_ID%TYPE,
  p_meas_event_type    TANK_MEASUREMENT.MEASUREMENT_EVENT_TYPE%TYPE,
  p_daytime            DATE,
  p_method             VARCHAR2 DEFAULT NULL,
  p_resolve_loop       VARCHAR2 DEFAULT NULL)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES(findBSWWt, WNDS, WNPS, RNPS);

FUNCTION getAnalysisNo(
  p_tank_object_id     TANK.OBJECT_ID%TYPE,
  p_daytime            DATE)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES(getAnalysisNo, WNDS, WNPS, RNPS);

FUNCTION findDiluentDens(
  p_tank_object_id     TANK.OBJECT_ID%TYPE,
  p_meas_event_type    TANK_MEASUREMENT.MEASUREMENT_EVENT_TYPE%TYPE,
  p_daytime            DATE,
  p_method             VARCHAR2 DEFAULT NULL,
  p_resolve_loop       VARCHAR2 DEFAULT NULL)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES(findDiluentDens, WNDS, WNPS, RNPS);

FUNCTION findBitumenDens(
  p_tank_object_id     TANK.OBJECT_ID%TYPE,
  p_meas_event_type    TANK_MEASUREMENT.MEASUREMENT_EVENT_TYPE%TYPE,
  p_daytime            DATE,
  p_method             VARCHAR2 DEFAULT NULL,
  p_resolve_loop       VARCHAR2 DEFAULT NULL)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES(findBitumenDens, WNDS, WNPS, RNPS);

FUNCTION findStdDens(
  p_tank_object_id     TANK.OBJECT_ID%TYPE,
  p_meas_event_type    TANK_MEASUREMENT.MEASUREMENT_EVENT_TYPE%TYPE,
  p_daytime            DATE,
  p_method             VARCHAR2 DEFAULT NULL,
  p_resolve_loop       VARCHAR2 DEFAULT NULL)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES(findStdDens, WNDS, WNPS, RNPS);

FUNCTION findObsDens(
  p_tank_object_id     TANK.OBJECT_ID%TYPE,
  p_meas_event_type    TANK_MEASUREMENT.MEASUREMENT_EVENT_TYPE%TYPE,
  p_daytime            DATE,
  p_method             VARCHAR2 DEFAULT NULL,
  p_resolve_loop       VARCHAR2 DEFAULT NULL)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES(findObsDens, WNDS, WNPS, RNPS);

FUNCTION calcWeightedDensFromTaps(
  p_tank_object_id     TANK.OBJECT_ID%TYPE,
  p_daytime            DATE)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES(calcWeightedDensFromTaps, WNDS, WNPS, RNPS);

FUNCTION calcWeightedBSWFromTaps(
  p_tank_object_id     TANK.OBJECT_ID%TYPE,
  p_daytime            DATE)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES(calcWeightedBSWFromTaps, WNDS, WNPS, RNPS);

FUNCTION findVolumeCorrectionFactor(
  p_tank_object_id     TANK.OBJECT_ID%TYPE,
  p_meas_event_type    TANK_MEASUREMENT.MEASUREMENT_EVENT_TYPE%TYPE,
  p_daytime            DATE,
  p_method             VARCHAR2 DEFAULT NULL,
  p_resolve_loop       VARCHAR2 DEFAULT NULL)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES(findVolumeCorrectionFactor, WNDS, WNPS, RNPS);

FUNCTION findGrsOilVol(
  p_tank_object_id     TANK.OBJECT_ID%TYPE,
  p_meas_event_type    TANK_MEASUREMENT.MEASUREMENT_EVENT_TYPE%TYPE,
  p_daytime            DATE,
  p_method             VARCHAR2 DEFAULT NULL,
  p_resolve_loop       VARCHAR2 DEFAULT NULL)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES(findGrsOilVol, WNDS, WNPS, RNPS);

FUNCTION findGrsStdOilVol(
  p_tank_object_id     TANK.OBJECT_ID%TYPE,
  p_meas_event_type    TANK_MEASUREMENT.MEASUREMENT_EVENT_TYPE%TYPE,
  p_daytime            DATE,
  p_method             VARCHAR2 DEFAULT NULL,
  p_resolve_loop       VARCHAR2 DEFAULT NULL)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES(findGrsStdOilVol, WNDS, WNPS, RNPS);

FUNCTION findNetStdOilVol(
  p_tank_object_id     TANK.OBJECT_ID%TYPE,
  p_meas_event_type    TANK_MEASUREMENT.MEASUREMENT_EVENT_TYPE%TYPE,
  p_daytime            DATE,
  p_method             VARCHAR2 DEFAULT NULL,
  p_resolve_loop       VARCHAR2 DEFAULT NULL)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES(findNetStdOilVol, WNDS, WNPS, RNPS);

FUNCTION findNetDiluentVol(
  p_tank_object_id     TANK.OBJECT_ID%TYPE,
  p_meas_event_type    TANK_MEASUREMENT.MEASUREMENT_EVENT_TYPE%TYPE,
  p_daytime            DATE,
  p_method             VARCHAR2 DEFAULT NULL,
  p_resolve_loop       VARCHAR2 DEFAULT NULL)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES(findNetDiluentVol, WNDS, WNPS, RNPS);

FUNCTION findFreeWaterVol(
  p_tank_object_id     TANK.OBJECT_ID%TYPE,
  p_meas_event_type    TANK_MEASUREMENT.MEASUREMENT_EVENT_TYPE%TYPE,
  p_daytime            DATE,
  p_method             VARCHAR2 DEFAULT NULL,
  p_resolve_loop       VARCHAR2 DEFAULT NULL)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES(findFreeWaterVol, WNDS, WNPS, RNPS);

FUNCTION findWaterVol(
  p_tank_object_id     TANK.OBJECT_ID%TYPE,
  p_meas_event_type    TANK_MEASUREMENT.MEASUREMENT_EVENT_TYPE%TYPE,
  p_daytime            DATE,
  p_method             VARCHAR2 DEFAULT NULL,
  p_resolve_loop       VARCHAR2 DEFAULT NULL)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES(findWaterVol, WNDS, WNPS, RNPS);

FUNCTION findAvailableVol(
  p_tank_object_id     TANK.OBJECT_ID%TYPE,
  p_meas_event_type    TANK_MEASUREMENT.MEASUREMENT_EVENT_TYPE%TYPE,
  p_daytime            DATE,
  p_method             VARCHAR2 DEFAULT NULL,
  p_resolve_loop       VARCHAR2 DEFAULT NULL)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES(findAvailableVol, WNDS, WNPS, RNPS);


FUNCTION findOpeningGrsVol(
  p_tank_object_id     TANK.OBJECT_ID%TYPE,
  p_meas_event_type    TANK_MEASUREMENT.MEASUREMENT_EVENT_TYPE%TYPE,
  p_daytime            DATE,
  p_method             VARCHAR2 DEFAULT NULL,
  p_resolve_loop       VARCHAR2 DEFAULT NULL)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES(findOpeningGrsVol, WNDS, WNPS, RNPS);

FUNCTION findOpeningGrsMass(
  p_tank_object_id     TANK.OBJECT_ID%TYPE,
  p_meas_event_type    TANK_MEASUREMENT.MEASUREMENT_EVENT_TYPE%TYPE,
  p_daytime            DATE,
  p_method             VARCHAR2 DEFAULT NULL,
  p_resolve_loop       VARCHAR2 DEFAULT NULL)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES(findOpeningGrsMass, WNDS, WNPS, RNPS);

FUNCTION findClosingGrsVol(
  p_tank_object_id     TANK.OBJECT_ID%TYPE,
  p_meas_event_type    TANK_MEASUREMENT.MEASUREMENT_EVENT_TYPE%TYPE,
  p_daytime            DATE,
  p_method             VARCHAR2 DEFAULT NULL,
  p_resolve_loop       VARCHAR2 DEFAULT NULL)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES(findClosingGrsVol, WNDS, WNPS, RNPS);

FUNCTION findClosingGrsStdOilVol(
  p_tank_object_id     TANK.OBJECT_ID%TYPE,
  p_meas_event_type    TANK_MEASUREMENT.MEASUREMENT_EVENT_TYPE%TYPE,
  p_daytime            DATE,
  p_method             VARCHAR2 DEFAULT NULL,
  p_resolve_loop       VARCHAR2 DEFAULT NULL)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES(findClosingGrsStdOilVol, WNDS, WNPS, RNPS);

FUNCTION findClosingGrsMass(
  p_tank_object_id     TANK.OBJECT_ID%TYPE,
  p_meas_event_type    TANK_MEASUREMENT.MEASUREMENT_EVENT_TYPE%TYPE,
  p_daytime            DATE,
  p_method             VARCHAR2 DEFAULT NULL,
  p_resolve_loop       VARCHAR2 DEFAULT NULL)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES(findClosingGrsMass, WNDS, WNPS, RNPS);

FUNCTION findOpeningDiluentVol(
  p_tank_object_id     TANK.OBJECT_ID%TYPE,
  p_meas_event_type    TANK_MEASUREMENT.MEASUREMENT_EVENT_TYPE%TYPE,
  p_daytime            DATE,
  p_method             VARCHAR2 DEFAULT NULL,
  p_resolve_loop       VARCHAR2 DEFAULT NULL)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES(findOpeningDiluentVol, WNDS, WNPS, RNPS);

FUNCTION findClosingDiluentVol(
  p_tank_object_id     TANK.OBJECT_ID%TYPE,
  p_meas_event_type    TANK_MEASUREMENT.MEASUREMENT_EVENT_TYPE%TYPE,
  p_daytime            DATE,
  p_method             VARCHAR2 DEFAULT NULL,
  p_resolve_loop       VARCHAR2 DEFAULT NULL)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES(findClosingDiluentVol, WNDS, WNPS, RNPS);

FUNCTION findOpeningNetVol(
  p_tank_object_id     TANK.OBJECT_ID%TYPE,
  p_meas_event_type    TANK_MEASUREMENT.MEASUREMENT_EVENT_TYPE%TYPE,
  p_daytime            DATE,
  p_method             VARCHAR2 DEFAULT NULL,
  p_resolve_loop       VARCHAR2 DEFAULT NULL)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES(findOpeningNetVol, WNDS, WNPS, RNPS);

FUNCTION findClosingNetVol(
  p_tank_object_id     TANK.OBJECT_ID%TYPE,
  p_meas_event_type    TANK_MEASUREMENT.MEASUREMENT_EVENT_TYPE%TYPE,
  p_daytime            DATE,
  p_method             VARCHAR2 DEFAULT NULL,
  p_resolve_loop       VARCHAR2 DEFAULT NULL)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES(findClosingNetVol, WNDS, WNPS, RNPS);

FUNCTION findOpeningNetMass(
  p_tank_object_id     TANK.OBJECT_ID%TYPE,
  p_meas_event_type    TANK_MEASUREMENT.MEASUREMENT_EVENT_TYPE%TYPE,
  p_daytime            DATE,
  p_method             VARCHAR2 DEFAULT NULL,
  p_resolve_loop       VARCHAR2 DEFAULT NULL)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES(findOpeningNetMass, WNDS, WNPS, RNPS);

FUNCTION findClosingNetMass(
  p_tank_object_id     TANK.OBJECT_ID%TYPE,
  p_meas_event_type    TANK_MEASUREMENT.MEASUREMENT_EVENT_TYPE%TYPE,
  p_daytime            DATE,
  p_method             VARCHAR2 DEFAULT NULL,
  p_resolve_loop       VARCHAR2 DEFAULT NULL)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES(findClosingNetMass, WNDS, WNPS, RNPS);

FUNCTION findOpeningWatVol(
  p_tank_object_id     TANK.OBJECT_ID%TYPE,
  p_meas_event_type    TANK_MEASUREMENT.MEASUREMENT_EVENT_TYPE%TYPE,
  p_daytime            DATE,
  p_method             VARCHAR2 DEFAULT NULL,
  p_resolve_loop       VARCHAR2 DEFAULT NULL)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES(findOpeningWatVol, WNDS, WNPS, RNPS);

FUNCTION findClosingWatVol(
  p_tank_object_id     TANK.OBJECT_ID%TYPE,
  p_meas_event_type    TANK_MEASUREMENT.MEASUREMENT_EVENT_TYPE%TYPE,
  p_daytime            DATE,
  p_method             VARCHAR2 DEFAULT NULL,
  p_resolve_loop       VARCHAR2 DEFAULT NULL)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES(findClosingWatVol, WNDS, WNPS, RNPS);

FUNCTION findOpeningEnergy(
  p_tank_object_id     TANK.OBJECT_ID%TYPE,
  p_meas_event_type    TANK_MEASUREMENT.MEASUREMENT_EVENT_TYPE%TYPE,
  p_daytime            DATE,
  p_method             VARCHAR2 DEFAULT NULL,
  p_resolve_loop       VARCHAR2 DEFAULT NULL)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES(findOpeningEnergy, WNDS, WNPS, RNPS);

FUNCTION findClosingEnergy(
  p_tank_object_id     TANK.OBJECT_ID%TYPE,
  p_meas_event_type    TANK_MEASUREMENT.MEASUREMENT_EVENT_TYPE%TYPE,
  p_daytime            DATE,
  p_method             VARCHAR2 DEFAULT NULL,
  p_resolve_loop       VARCHAR2 DEFAULT NULL)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES(findClosingEnergy, WNDS, WNPS, RNPS);

PROCEDURE checkTankMeasurementLock(p_operation VARCHAR2, p_new_lock_columns IN OUT EcDp_Month_Lock.column_list, p_old_lock_columns IN OUT EcDp_Month_Lock.column_list);

PROCEDURE checkTankMeasurementLock(p_object_id VARCHAR2, p_measurement_event_type VARCHAR2, p_daytime DATE, p_class_name VARCHAR2);

PROCEDURE checkTankStrappingLock(p_operation VARCHAR2, p_new_lock_columns IN OUT EcDp_Month_Lock.column_list, p_old_lock_columns IN OUT EcDp_Month_Lock.column_list);

FUNCTION findShrunkVol(
  p_tank_object_id     TANK.OBJECT_ID%TYPE,
  p_meas_event_type    TANK_MEASUREMENT.MEASUREMENT_EVENT_TYPE%TYPE,
  p_daytime            DATE)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES(findShrunkVol, WNDS, WNPS, RNPS);

END EcBp_Tank;