CREATE OR REPLACE PACKAGE EcBp_Tank IS
/****************************************************************
** Package        :  EcBp_Tank, header part
**
** $Revision: 1.22 $
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
** 01.11.2012  abdulmaw	ECPD-22037: Enhance findNetStdOilVol, findStdDens, findBSWVol. Added findNetDiluentVol, findClosingDiluentVol, findOpeningDiluentVol, findDiluentDens, findBitumenDens, calcWeightedDensFromTaps, calcWeightedBSWFromTaps
** 21.03.2013  kumarsur	ECPD-22598: Modified calcWeightedDensFromTaps(), calcWeightedBSWFromTaps(), findNetStdOilVol(), findNetDiluentVol() and added findShrunkVol().
*****************************************************************/
FUNCTION calcRoofDisplacementVol(
  p_tank_object_id     TANK.OBJECT_ID%TYPE,
  p_meas_event_type    TANK_MEASUREMENT.MEASUREMENT_EVENT_TYPE%TYPE,
  p_dip_level          NUMBER,
  p_daytime            DATE,
  p_method             VARCHAR2 DEFAULT NULL,
  p_resolve_loop       VARCHAR2 DEFAULT NULL)
RETURN NUMBER;

FUNCTION calcRoofDisplacementMass(
  p_tank_object_id     TANK.OBJECT_ID%TYPE,
  p_meas_event_type    TANK_MEASUREMENT.MEASUREMENT_EVENT_TYPE%TYPE,
  p_daytime            DATE)
RETURN NUMBER;

FUNCTION findGrsVol(
  p_tank_object_id     TANK.OBJECT_ID%TYPE,
  p_meas_event_type    TANK_MEASUREMENT.MEASUREMENT_EVENT_TYPE%TYPE,
  p_daytime            DATE,
  p_method             VARCHAR2 DEFAULT NULL,
  p_resolve_loop       VARCHAR2 DEFAULT NULL)
RETURN NUMBER;

FUNCTION findGrsStdVol(
  p_tank_object_id     TANK.OBJECT_ID%TYPE,
  p_meas_event_type    TANK_MEASUREMENT.MEASUREMENT_EVENT_TYPE%TYPE,
  p_daytime            DATE,
  p_method             VARCHAR2 DEFAULT NULL,
  p_resolve_loop       VARCHAR2 DEFAULT NULL)
RETURN NUMBER;

FUNCTION findNetMass(
  p_tank_object_id     TANK.OBJECT_ID%TYPE,
  p_meas_event_type    TANK_MEASUREMENT.MEASUREMENT_EVENT_TYPE%TYPE,
  p_daytime            DATE,
  p_method             VARCHAR2 DEFAULT NULL,
  p_resolve_loop       VARCHAR2 DEFAULT NULL)
RETURN NUMBER;

FUNCTION findGrsMass(
  p_tank_object_id     TANK.OBJECT_ID%TYPE,
  p_meas_event_type    TANK_MEASUREMENT.MEASUREMENT_EVENT_TYPE%TYPE,
  p_daytime            DATE,
  p_method             VARCHAR2 DEFAULT NULL,
  p_resolve_loop       VARCHAR2 DEFAULT NULL)
RETURN NUMBER;

--

FUNCTION findBSWVol(
  p_tank_object_id     TANK.OBJECT_ID%TYPE,
  p_meas_event_type    TANK_MEASUREMENT.MEASUREMENT_EVENT_TYPE%TYPE,
  p_daytime            DATE,
  p_method             VARCHAR2 DEFAULT NULL,
  p_resolve_loop       VARCHAR2 DEFAULT NULL)
RETURN NUMBER;

FUNCTION findBSWWt(
  p_tank_object_id     TANK.OBJECT_ID%TYPE,
  p_meas_event_type    TANK_MEASUREMENT.MEASUREMENT_EVENT_TYPE%TYPE,
  p_daytime            DATE,
  p_method             VARCHAR2 DEFAULT NULL,
  p_resolve_loop       VARCHAR2 DEFAULT NULL)
RETURN NUMBER;

FUNCTION getAnalysisNo(
  p_tank_object_id     TANK.OBJECT_ID%TYPE,
  p_daytime            DATE)
RETURN NUMBER;

FUNCTION findDiluentDens(
  p_tank_object_id     TANK.OBJECT_ID%TYPE,
  p_meas_event_type    TANK_MEASUREMENT.MEASUREMENT_EVENT_TYPE%TYPE,
  p_daytime            DATE,
  p_method             VARCHAR2 DEFAULT NULL,
  p_resolve_loop       VARCHAR2 DEFAULT NULL)
RETURN NUMBER;

FUNCTION findBitumenDens(
  p_tank_object_id     TANK.OBJECT_ID%TYPE,
  p_meas_event_type    TANK_MEASUREMENT.MEASUREMENT_EVENT_TYPE%TYPE,
  p_daytime            DATE,
  p_method             VARCHAR2 DEFAULT NULL,
  p_resolve_loop       VARCHAR2 DEFAULT NULL)
RETURN NUMBER;

FUNCTION findStdDens(
  p_tank_object_id     TANK.OBJECT_ID%TYPE,
  p_meas_event_type    TANK_MEASUREMENT.MEASUREMENT_EVENT_TYPE%TYPE,
  p_daytime            DATE,
  p_method             VARCHAR2 DEFAULT NULL,
  p_resolve_loop       VARCHAR2 DEFAULT NULL)
RETURN NUMBER;

FUNCTION findObsDens(
  p_tank_object_id     TANK.OBJECT_ID%TYPE,
  p_meas_event_type    TANK_MEASUREMENT.MEASUREMENT_EVENT_TYPE%TYPE,
  p_daytime            DATE,
  p_method             VARCHAR2 DEFAULT NULL,
  p_resolve_loop       VARCHAR2 DEFAULT NULL)
RETURN NUMBER;

FUNCTION calcWeightedDensFromTaps(
  p_tank_object_id     TANK.OBJECT_ID%TYPE,
  p_daytime            DATE)
RETURN NUMBER;

FUNCTION calcWeightedBSWFromTaps(
  p_tank_object_id     TANK.OBJECT_ID%TYPE,
  p_daytime            DATE)
RETURN NUMBER;

FUNCTION findVolumeCorrectionFactor(
  p_tank_object_id     TANK.OBJECT_ID%TYPE,
  p_meas_event_type    TANK_MEASUREMENT.MEASUREMENT_EVENT_TYPE%TYPE,
  p_daytime            DATE,
  p_method             VARCHAR2 DEFAULT NULL,
  p_resolve_loop       VARCHAR2 DEFAULT NULL)
RETURN NUMBER;

FUNCTION findGrsOilVol(
  p_tank_object_id     TANK.OBJECT_ID%TYPE,
  p_meas_event_type    TANK_MEASUREMENT.MEASUREMENT_EVENT_TYPE%TYPE,
  p_daytime            DATE,
  p_method             VARCHAR2 DEFAULT NULL,
  p_resolve_loop       VARCHAR2 DEFAULT NULL)
RETURN NUMBER;

FUNCTION findGrsStdOilVol(
  p_tank_object_id     TANK.OBJECT_ID%TYPE,
  p_meas_event_type    TANK_MEASUREMENT.MEASUREMENT_EVENT_TYPE%TYPE,
  p_daytime            DATE,
  p_method             VARCHAR2 DEFAULT NULL,
  p_resolve_loop       VARCHAR2 DEFAULT NULL)
RETURN NUMBER;

FUNCTION findNetStdOilVol(
  p_tank_object_id     TANK.OBJECT_ID%TYPE,
  p_meas_event_type    TANK_MEASUREMENT.MEASUREMENT_EVENT_TYPE%TYPE,
  p_daytime            DATE,
  p_method             VARCHAR2 DEFAULT NULL,
  p_resolve_loop       VARCHAR2 DEFAULT NULL)
RETURN NUMBER;

FUNCTION findNetDiluentVol(
  p_tank_object_id     TANK.OBJECT_ID%TYPE,
  p_meas_event_type    TANK_MEASUREMENT.MEASUREMENT_EVENT_TYPE%TYPE,
  p_daytime            DATE,
  p_method             VARCHAR2 DEFAULT NULL,
  p_resolve_loop       VARCHAR2 DEFAULT NULL)
RETURN NUMBER;

FUNCTION findFreeWaterVol(
  p_tank_object_id     TANK.OBJECT_ID%TYPE,
  p_meas_event_type    TANK_MEASUREMENT.MEASUREMENT_EVENT_TYPE%TYPE,
  p_daytime            DATE,
  p_method             VARCHAR2 DEFAULT NULL,
  p_resolve_loop       VARCHAR2 DEFAULT NULL)
RETURN NUMBER;

FUNCTION findWaterVol(
  p_tank_object_id     TANK.OBJECT_ID%TYPE,
  p_meas_event_type    TANK_MEASUREMENT.MEASUREMENT_EVENT_TYPE%TYPE,
  p_daytime            DATE,
  p_method             VARCHAR2 DEFAULT NULL,
  p_resolve_loop       VARCHAR2 DEFAULT NULL)
RETURN NUMBER;

FUNCTION findAvailableVol(
  p_tank_object_id     TANK.OBJECT_ID%TYPE,
  p_meas_event_type    TANK_MEASUREMENT.MEASUREMENT_EVENT_TYPE%TYPE,
  p_daytime            DATE,
  p_method             VARCHAR2 DEFAULT NULL,
  p_resolve_loop       VARCHAR2 DEFAULT NULL)
RETURN NUMBER;


FUNCTION findOpeningGrsVol(
  p_tank_object_id     TANK.OBJECT_ID%TYPE,
  p_meas_event_type    TANK_MEASUREMENT.MEASUREMENT_EVENT_TYPE%TYPE,
  p_daytime            DATE,
  p_method             VARCHAR2 DEFAULT NULL,
  p_resolve_loop       VARCHAR2 DEFAULT NULL)
RETURN NUMBER;

FUNCTION findOpeningGrsMass(
  p_tank_object_id     TANK.OBJECT_ID%TYPE,
  p_meas_event_type    TANK_MEASUREMENT.MEASUREMENT_EVENT_TYPE%TYPE,
  p_daytime            DATE,
  p_method             VARCHAR2 DEFAULT NULL,
  p_resolve_loop       VARCHAR2 DEFAULT NULL)
RETURN NUMBER;

FUNCTION findClosingGrsVol(
  p_tank_object_id     TANK.OBJECT_ID%TYPE,
  p_meas_event_type    TANK_MEASUREMENT.MEASUREMENT_EVENT_TYPE%TYPE,
  p_daytime            DATE,
  p_method             VARCHAR2 DEFAULT NULL,
  p_resolve_loop       VARCHAR2 DEFAULT NULL)
RETURN NUMBER;

FUNCTION findClosingGrsStdOilVol(
  p_tank_object_id     TANK.OBJECT_ID%TYPE,
  p_meas_event_type    TANK_MEASUREMENT.MEASUREMENT_EVENT_TYPE%TYPE,
  p_daytime            DATE,
  p_method             VARCHAR2 DEFAULT NULL,
  p_resolve_loop       VARCHAR2 DEFAULT NULL)
RETURN NUMBER;

FUNCTION findClosingGrsMass(
  p_tank_object_id     TANK.OBJECT_ID%TYPE,
  p_meas_event_type    TANK_MEASUREMENT.MEASUREMENT_EVENT_TYPE%TYPE,
  p_daytime            DATE,
  p_method             VARCHAR2 DEFAULT NULL,
  p_resolve_loop       VARCHAR2 DEFAULT NULL)
RETURN NUMBER;

FUNCTION findOpeningDiluentVol(
  p_tank_object_id     TANK.OBJECT_ID%TYPE,
  p_meas_event_type    TANK_MEASUREMENT.MEASUREMENT_EVENT_TYPE%TYPE,
  p_daytime            DATE,
  p_method             VARCHAR2 DEFAULT NULL,
  p_resolve_loop       VARCHAR2 DEFAULT NULL)
RETURN NUMBER;

FUNCTION findClosingDiluentVol(
  p_tank_object_id     TANK.OBJECT_ID%TYPE,
  p_meas_event_type    TANK_MEASUREMENT.MEASUREMENT_EVENT_TYPE%TYPE,
  p_daytime            DATE,
  p_method             VARCHAR2 DEFAULT NULL,
  p_resolve_loop       VARCHAR2 DEFAULT NULL)
RETURN NUMBER;

FUNCTION findOpeningNetVol(
  p_tank_object_id     TANK.OBJECT_ID%TYPE,
  p_meas_event_type    TANK_MEASUREMENT.MEASUREMENT_EVENT_TYPE%TYPE,
  p_daytime            DATE,
  p_method             VARCHAR2 DEFAULT NULL,
  p_resolve_loop       VARCHAR2 DEFAULT NULL)
RETURN NUMBER;

FUNCTION findClosingNetVol(
  p_tank_object_id     TANK.OBJECT_ID%TYPE,
  p_meas_event_type    TANK_MEASUREMENT.MEASUREMENT_EVENT_TYPE%TYPE,
  p_daytime            DATE,
  p_method             VARCHAR2 DEFAULT NULL,
  p_resolve_loop       VARCHAR2 DEFAULT NULL)
RETURN NUMBER;

FUNCTION findOpeningNetMass(
  p_tank_object_id     TANK.OBJECT_ID%TYPE,
  p_meas_event_type    TANK_MEASUREMENT.MEASUREMENT_EVENT_TYPE%TYPE,
  p_daytime            DATE,
  p_method             VARCHAR2 DEFAULT NULL,
  p_resolve_loop       VARCHAR2 DEFAULT NULL)
RETURN NUMBER;

FUNCTION findClosingNetMass(
  p_tank_object_id     TANK.OBJECT_ID%TYPE,
  p_meas_event_type    TANK_MEASUREMENT.MEASUREMENT_EVENT_TYPE%TYPE,
  p_daytime            DATE,
  p_method             VARCHAR2 DEFAULT NULL,
  p_resolve_loop       VARCHAR2 DEFAULT NULL)
RETURN NUMBER;

FUNCTION findOpeningWatVol(
  p_tank_object_id     TANK.OBJECT_ID%TYPE,
  p_meas_event_type    TANK_MEASUREMENT.MEASUREMENT_EVENT_TYPE%TYPE,
  p_daytime            DATE,
  p_method             VARCHAR2 DEFAULT NULL,
  p_resolve_loop       VARCHAR2 DEFAULT NULL)
RETURN NUMBER;

FUNCTION findClosingWatVol(
  p_tank_object_id     TANK.OBJECT_ID%TYPE,
  p_meas_event_type    TANK_MEASUREMENT.MEASUREMENT_EVENT_TYPE%TYPE,
  p_daytime            DATE,
  p_method             VARCHAR2 DEFAULT NULL,
  p_resolve_loop       VARCHAR2 DEFAULT NULL)
RETURN NUMBER;

FUNCTION findOpeningEnergy(
  p_tank_object_id     TANK.OBJECT_ID%TYPE,
  p_meas_event_type    TANK_MEASUREMENT.MEASUREMENT_EVENT_TYPE%TYPE,
  p_daytime            DATE,
  p_method             VARCHAR2 DEFAULT NULL,
  p_resolve_loop       VARCHAR2 DEFAULT NULL)
RETURN NUMBER;

FUNCTION findClosingEnergy(
  p_tank_object_id     TANK.OBJECT_ID%TYPE,
  p_meas_event_type    TANK_MEASUREMENT.MEASUREMENT_EVENT_TYPE%TYPE,
  p_daytime            DATE,
  p_method             VARCHAR2 DEFAULT NULL,
  p_resolve_loop       VARCHAR2 DEFAULT NULL)
RETURN NUMBER;

PROCEDURE checkTankMeasurementLock(p_operation VARCHAR2, p_new_lock_columns IN OUT EcDp_Month_Lock.column_list, p_old_lock_columns IN OUT EcDp_Month_Lock.column_list);

PROCEDURE checkTankMeasurementLock(p_object_id VARCHAR2, p_measurement_event_type VARCHAR2, p_daytime DATE, p_class_name VARCHAR2);

PROCEDURE checkTankStrappingLock(p_operation VARCHAR2, p_new_lock_columns IN OUT EcDp_Month_Lock.column_list, p_old_lock_columns IN OUT EcDp_Month_Lock.column_list);

FUNCTION findShrunkVol(
  p_tank_object_id     TANK.OBJECT_ID%TYPE,
  p_meas_event_type    TANK_MEASUREMENT.MEASUREMENT_EVENT_TYPE%TYPE,
  p_daytime            DATE)
RETURN NUMBER;

END EcBp_Tank;