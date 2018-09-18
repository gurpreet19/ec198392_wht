CREATE OR REPLACE PACKAGE EcBp_Truck_Ticket IS

/****************************************************************
** Package        :  EcBp_Truck_Ticket; head part
**
** $Revision: 1.6 $
**
** Purpose        :  This package is responsible for calculations directly related
**                   to truck ticket operations, consisting of single transfer and
**                   stream-to/from-well transfer events.
**
** Documentation  :  www.energy-components.com
**
** Created        :  28.03.2006  Nik Eizwan Nik Sufian
**
** Modification history:
**
** Version  Date        Whom         Change description:
** -------  ----------  --------     --------------------------------------
** 1.0      28.03.2006  eizwanik     First version
**          07.10.2010  sharawan     ECPD-14895: Add deleteChildEvent procedure and countChildEvent function.
**          11.02.2011  farhaann	 ECPD-13292: Added verifyTicket, findNetStdVol, getBswVolFrac, findGrsStdVol and findWatVol
**          30.07.2012  kumarsur	 ECPD-21449: Added findLiqGrsMass, findSandMass, findSandVol and calcDensity.
**          28.05.2013  rajarsar	 ECPD-21876: Updated all existing functions and added findOilDensity,findWaterDensity, findSandDensity, findBSWVolFrac, findBswWtFrac and volumeCorrFactor.
**          20.06.2013	rajarsar 	 ECPD-21876: Added findWellStdVol, findWellWaterVol,findWellNetStdMass and findWellGrsStdMass.
**          31.03.2016	shindani	 ECPD-31221: Added findWellGrsStdVol,findWellBSWVolFrac. Modified findWellStdVol,findWellWaterVol.
*****************************************************************/

PROCEDURE prorateTruckedWellProd(
     p_startdate    DATE,
     p_end_date     DATE,
     p_facility_id  VARCHAR2);

PROCEDURE prorateTruckedWellLoadOil(
     p_facility_id  VARCHAR2,
     p_startday     DATE,
     p_endday      DATE);

PROCEDURE deleteChildEvent(p_event_no NUMBER, p_daytime DATE);

FUNCTION countChildEvent(p_event_no NUMBER, p_daytime DATE)
RETURN NUMBER;

PROCEDURE verifyTicket(
   p_event_no NUMBER,
   p_user VARCHAR2 DEFAULT USER);


FUNCTION findGrsStdVol (p_event_no NUMBER, p_resolve_loop VARCHAR2 DEFAULT NULL)
RETURN NUMBER;

FUNCTION findNetStdVol (
     p_event_no     NUMBER,  p_resolve_loop VARCHAR2 DEFAULT NULL)
RETURN NUMBER;

FUNCTION findWatVol (
   p_event_no     NUMBER,  p_resolve_loop VARCHAR2 DEFAULT NULL)
RETURN NUMBER;

FUNCTION findSandVol (
   p_event_no     NUMBER, p_resolve_loop VARCHAR2 DEFAULT NULL)
RETURN NUMBER;

FUNCTION findWellStdVol(
     p_event_no     NUMBER, p_object_id VARCHAR2,  p_resolve_loop VARCHAR2 DEFAULT NULL)
RETURN NUMBER;

FUNCTION findWellGrsStdVol(
     p_event_no     NUMBER, p_resolve_loop VARCHAR2 DEFAULT NULL)
RETURN NUMBER;

FUNCTION findWellWaterVol (
   p_event_no     NUMBER,  p_object_id VARCHAR2, p_resolve_loop VARCHAR2 DEFAULT NULL)
RETURN NUMBER;

FUNCTION findGrsStdMass (p_event_no NUMBER, p_resolve_loop VARCHAR2 DEFAULT NULL)
RETURN NUMBER;

FUNCTION findNetStdMass (p_event_no NUMBER, p_resolve_loop VARCHAR2 DEFAULT NULL)
RETURN NUMBER;

FUNCTION findWatMass (
   p_event_no     NUMBER,  p_resolve_loop VARCHAR2 DEFAULT NULL)
RETURN NUMBER;

FUNCTION findSandMass (
   p_event_no     NUMBER,  p_resolve_loop VARCHAR2 DEFAULT NULL)
RETURN NUMBER;

FUNCTION findWellGrsStdMass(
   p_event_no     NUMBER, p_object_id varchar2, p_resolve_loop VARCHAR2 DEFAULT NULL)
RETURN NUMBER;

FUNCTION findWellNetStdMass(
   p_event_no     NUMBER, p_object_id varchar2,  p_resolve_loop VARCHAR2 DEFAULT NULL)
RETURN NUMBER;

FUNCTION calcDensity (
   p_event_no     NUMBER, p_resolve_loop VARCHAR2 DEFAULT NULL)
RETURN NUMBER;

FUNCTION findOilDensity (
   p_event_no     NUMBER, p_resolve_loop VARCHAR2 DEFAULT NULL)
RETURN NUMBER;

FUNCTION findWaterDensity (
   p_event_no     NUMBER, p_resolve_loop VARCHAR2 DEFAULT NULL)
RETURN NUMBER;

FUNCTION findSandDensity (
   p_event_no     NUMBER, p_resolve_loop VARCHAR2 DEFAULT NULL)
RETURN NUMBER;

FUNCTION findBSWVolFrac (
   p_event_no     NUMBER, p_resolve_loop VARCHAR2 DEFAULT NULL)
RETURN NUMBER;

FUNCTION findWellBSWVolFrac (
   p_event_no     NUMBER, p_resolve_loop VARCHAR2 DEFAULT NULL)
RETURN NUMBER;

FUNCTION findBswWtFrac (
   p_event_no     NUMBER,
   p_resolve_loop VARCHAR2 DEFAULT NULL)
RETURN NUMBER;

FUNCTION volumeCorrFactor (p_event_no NUMBER)
RETURN NUMBER;

FUNCTION getFacility(
         p_object_id strm_transport_event.object_id%TYPE,
         p_daytime strm_transport_event.daytime%TYPE
         )
RETURN VARCHAR2;

FUNCTION getCalcGrsMass(
         p_stream_id strm_transport_event.stream_id%TYPE,
         p_start_meter_reading strm_transport_event.start_meter_reading%TYPE,
         p_end_meter_reading strm_transport_event.end_meter_reading%TYPE,
         p_daytime strm_transport_event.daytime%TYPE
         )
RETURN NUMBER;

PROCEDURE calcGrsMass(
         p_unique strm_transport_event.event_no%TYPE,
         p_start_meter_reading strm_transport_event.start_meter_reading%TYPE,
         p_end_meter_reading strm_transport_event.end_meter_reading%TYPE,
         p_user varchar2 default user);
END;