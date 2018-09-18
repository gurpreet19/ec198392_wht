CREATE OR REPLACE PACKAGE EcDp_Tank_Measurement IS

/****************************************************************
** Package        :  EcDp_Tank_Measurement, header part
**
** $Revision: 1.5 $
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
*****************************************************************/

FUNCTION getGrsVol (
   p_tank_object_id TANK.OBJECT_ID%TYPE,
   p_meas_event_type    TANK_MEASUREMENT.MEASUREMENT_EVENT_TYPE%TYPE,
   p_daytime        DATE)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (getGrsVol,WNDS, WNPS, RNPS);

--

FUNCTION getNetVol (
   p_tank_object_id TANK.OBJECT_ID%TYPE,
   p_meas_event_type    TANK_MEASUREMENT.MEASUREMENT_EVENT_TYPE%TYPE,
   p_daytime        DATE)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (getNetVol,WNDS, WNPS, RNPS);

--

FUNCTION getBSWVol (
   p_tank_object_id TANK.OBJECT_ID%TYPE,
   p_meas_event_type    TANK_MEASUREMENT.MEASUREMENT_EVENT_TYPE%TYPE,
   p_daytime        DATE)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (getBSWVol,WNDS, WNPS, RNPS);

--

FUNCTION getBSWWt (
   p_tank_object_id TANK.OBJECT_ID%TYPE,
   p_meas_event_type    TANK_MEASUREMENT.MEASUREMENT_EVENT_TYPE%TYPE,
   p_daytime        DATE)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (getBSWWt,WNDS, WNPS, RNPS);

--

FUNCTION getWaterVol (
   p_tank_object_id TANK.OBJECT_ID%TYPE,
   p_meas_event_type    TANK_MEASUREMENT.MEASUREMENT_EVENT_TYPE%TYPE,
   p_daytime        DATE)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (getWaterVol,WNDS, WNPS, RNPS);

--

FUNCTION getStdDens (
   p_tank_object_id TANK.OBJECT_ID%TYPE,
   p_meas_event_type    TANK_MEASUREMENT.MEASUREMENT_EVENT_TYPE%TYPE,
   p_daytime        DATE)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (getStdDens,WNDS, WNPS, RNPS);

--

FUNCTION getObsDens (
   p_tank_object_id TANK.OBJECT_ID%TYPE,
   p_meas_event_type    TANK_MEASUREMENT.MEASUREMENT_EVENT_TYPE%TYPE,
   p_daytime        DATE)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (getObsDens,WNDS, WNPS, RNPS);

--

FUNCTION getGrsMass (
   p_tank_object_id TANK.OBJECT_ID%TYPE,
   p_meas_event_type    TANK_MEASUREMENT.MEASUREMENT_EVENT_TYPE%TYPE,
   p_daytime        DATE)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (getGrsMass,WNDS, WNPS, RNPS);

--

FUNCTION getNetMass (
   p_tank_object_id TANK.OBJECT_ID%TYPE,
   p_meas_event_type    TANK_MEASUREMENT.MEASUREMENT_EVENT_TYPE%TYPE,
   p_daytime        DATE)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (getNetMass,WNDS, WNPS, RNPS);

--

FUNCTION getGrsDipLevel (
   p_tank_object_id TANK.OBJECT_ID%TYPE,
   p_meas_event_type    TANK_MEASUREMENT.MEASUREMENT_EVENT_TYPE%TYPE,
   p_daytime        DATE)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (getGrsDipLevel,WNDS, WNPS, RNPS);

--

FUNCTION getWaterDipLevel (
   p_tank_object_id TANK.OBJECT_ID%TYPE,
   p_meas_event_type    TANK_MEASUREMENT.MEASUREMENT_EVENT_TYPE%TYPE,
   p_daytime        DATE)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (getWaterDipLevel,WNDS, WNPS, RNPS);

--

FUNCTION getVolumeCorrectionFactor (
   p_tank_object_id TANK.OBJECT_ID%TYPE,
   p_meas_event_type    TANK_MEASUREMENT.MEASUREMENT_EVENT_TYPE%TYPE,
   p_daytime        DATE)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (getVolumeCorrectionFactor,WNDS, WNPS, RNPS);

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

END EcDp_Tank_Measurement;