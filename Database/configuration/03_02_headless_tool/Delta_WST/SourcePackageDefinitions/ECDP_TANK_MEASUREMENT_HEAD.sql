CREATE OR REPLACE PACKAGE EcDp_Tank_Measurement IS

/****************************************************************
** Package        :  EcDp_Tank_Measurement, header part
**
** $Revision: 1.8 $
**
** Purpose        :  This package is responsible for returning measured tank data.
**
** Documentation  :  www.energy-components.com
**
** Created  : 29.04.2004  Frode Barstad
**
** Modification history:
**
** Version  Date        Whom  Change description:
** -------  ----------  ----- --------------------------------------
** 1.0      29.04.2004  FBa   Initial version
**          27.08.2012  kumarsur ECPD-20144:New Screen Tank Dip and Batch Export.
**          01.03.2013  kumarsur ECPD-23389:Added delMeasurementSet.
*****************************************************************/

FUNCTION getGrsVol (
   p_tank_object_id TANK.OBJECT_ID%TYPE,
   p_meas_event_type    TANK_MEASUREMENT.MEASUREMENT_EVENT_TYPE%TYPE,
   p_daytime        DATE)
RETURN NUMBER;

--

FUNCTION getNetVol (
   p_tank_object_id TANK.OBJECT_ID%TYPE,
   p_meas_event_type    TANK_MEASUREMENT.MEASUREMENT_EVENT_TYPE%TYPE,
   p_daytime        DATE)
RETURN NUMBER;

--

FUNCTION getBSWVol (
   p_tank_object_id TANK.OBJECT_ID%TYPE,
   p_meas_event_type    TANK_MEASUREMENT.MEASUREMENT_EVENT_TYPE%TYPE,
   p_daytime        DATE)
RETURN NUMBER;

--

FUNCTION getBSWWt (
   p_tank_object_id TANK.OBJECT_ID%TYPE,
   p_meas_event_type    TANK_MEASUREMENT.MEASUREMENT_EVENT_TYPE%TYPE,
   p_daytime        DATE)
RETURN NUMBER;

--

FUNCTION getWaterVol (
   p_tank_object_id TANK.OBJECT_ID%TYPE,
   p_meas_event_type    TANK_MEASUREMENT.MEASUREMENT_EVENT_TYPE%TYPE,
   p_daytime        DATE)
RETURN NUMBER;

--

FUNCTION getStdDens (
   p_tank_object_id TANK.OBJECT_ID%TYPE,
   p_meas_event_type    TANK_MEASUREMENT.MEASUREMENT_EVENT_TYPE%TYPE,
   p_daytime        DATE)
RETURN NUMBER;

--

FUNCTION getObsDens (
   p_tank_object_id TANK.OBJECT_ID%TYPE,
   p_meas_event_type    TANK_MEASUREMENT.MEASUREMENT_EVENT_TYPE%TYPE,
   p_daytime        DATE)
RETURN NUMBER;

--

FUNCTION getGrsMass (
   p_tank_object_id TANK.OBJECT_ID%TYPE,
   p_meas_event_type    TANK_MEASUREMENT.MEASUREMENT_EVENT_TYPE%TYPE,
   p_daytime        DATE)
RETURN NUMBER;

--

FUNCTION getNetMass (
   p_tank_object_id TANK.OBJECT_ID%TYPE,
   p_meas_event_type    TANK_MEASUREMENT.MEASUREMENT_EVENT_TYPE%TYPE,
   p_daytime        DATE)
RETURN NUMBER;

--

FUNCTION getGrsDipLevel (
   p_tank_object_id TANK.OBJECT_ID%TYPE,
   p_meas_event_type    TANK_MEASUREMENT.MEASUREMENT_EVENT_TYPE%TYPE,
   p_daytime        DATE)
RETURN NUMBER;

--

FUNCTION getWaterDipLevel (
   p_tank_object_id TANK.OBJECT_ID%TYPE,
   p_meas_event_type    TANK_MEASUREMENT.MEASUREMENT_EVENT_TYPE%TYPE,
   p_daytime        DATE)
RETURN NUMBER;

--

FUNCTION getVolumeCorrectionFactor (
   p_tank_object_id TANK.OBJECT_ID%TYPE,
   p_meas_event_type    TANK_MEASUREMENT.MEASUREMENT_EVENT_TYPE%TYPE,
   p_daytime        DATE)
RETURN NUMBER;

--

PROCEDURE createMeasurementSet(
   p_strm_object_id  STRM_EVENT.OBJECT_ID%TYPE,
   p_event_type      STRM_EVENT.EVENT_TYPE%TYPE,
   p_daytime         DATE,
   p_method          VARCHAR2,
   p_tank_object_id  TANK.OBJECT_ID%TYPE DEFAULT NULL);

--

PROCEDURE setDefaultTicketVol(
   p_strm_object_id TANK.OBJECT_ID%TYPE,
   p_daytime DATE,
   p_ticket_net_vol STRM_EVENT.GRS_VOL%TYPE);

--

PROCEDURE setDefaultExportTank(
   p_strm_object_id TANK.OBJECT_ID%TYPE,
   p_daytime DATE);

--

PROCEDURE createSealLocation(
	p_object_id VARCHAR2,
	p_daytime DATE,
	p_user VARCHAR2);

--

PROCEDURE delSealLocation(
	p_object_id VARCHAR2,
	p_daytime DATE);

--

PROCEDURE delMeasurementSet(
   p_daytime         DATE,
   p_tank_object_id  VARCHAR2);

END EcDp_Tank_Measurement;