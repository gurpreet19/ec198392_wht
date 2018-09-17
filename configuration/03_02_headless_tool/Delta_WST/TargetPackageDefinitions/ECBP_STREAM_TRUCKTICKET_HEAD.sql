CREATE OR REPLACE PACKAGE EcBp_Stream_TruckTicket IS
/******************************************************************************
** Package        :  EcBp_Stream_TruckTicket, header part
**
** $Revision: 1.14 $
**
** Purpose        :  This package contains functions and procedures for Truck Ticket
**					 business functions
**
** Documentation  :  www.energy-components.com
**
** Created  : 16.10.2006 OTTERMAG
**
** Modification history:
**
** Version  Date         Whom           Change description:
** -------  ------       -----          -------------------------------------------
**          16.10.2006   OTTERMAG       First version
**          06.11.2006	 SEONGKOK       Added functions find_*_by_pc()
**          10.11.2006	 SEONGKOK       Moved functions find_*_by_pc() to package EcBp_Stream_Fluid
**          22.05.2007   kaurrjes       ECPD-5487: Added parameter p_user in calcGrsMass Procedure
**          23.07.2007	 ismaiime       ECPD-6148 Added parameter p_user in verufyTicket Procedure
**          26.07.2007	 siah           Added getCalcGrsMass
**          30.08.2007	 rahmanaz       ECPD-5724: Added getNetMass
**          04.02.2010   leongsei       ECPD-13197: Added function findNetStdVol, getBswVolFrac, findGrsStdVol, findWatVol,
**                                                                 findNetStdMass, getBswWeightFrac, findGrsStdMass, findWatMass
**                                                  for truck ticket calculation
********************************************************************/

 -- Public type declarations

FUNCTION getNetVol(
         p_unique strm_transport_event.event_no%TYPE
         )
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES(getNetVol, WNDS, WNPS, RNPS);

FUNCTION getWaterVol(
         p_unique strm_transport_event.event_no%TYPE
         )
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES(getWaterVol, WNDS, WNPS, RNPS);

PROCEDURE calcGrsMass(
         p_unique strm_transport_event.event_no%TYPE,
         p_start_meter_reading strm_transport_event.start_meter_reading%TYPE,
         p_end_meter_reading strm_transport_event.end_meter_reading%TYPE,
         p_user varchar2 default user);

FUNCTION getFacility(
         p_object_id strm_transport_event.object_id%TYPE,
         p_daytime strm_transport_event.daytime%TYPE
         )
RETURN VARCHAR2;
PRAGMA RESTRICT_REFERENCES(getFacility, WNDS, WNPS, RNPS);

PROCEDURE verifyTicket(
   p_event_no STRM_TRANSPORT_EVENT.EVENT_NO%TYPE,
   p_user VARCHAR2 DEFAULT USER);

FUNCTION getCalcGrsMass(
         p_stream_id strm_transport_event.stream_id%TYPE,
         p_start_meter_reading strm_transport_event.start_meter_reading%TYPE,
         p_end_meter_reading strm_transport_event.end_meter_reading%TYPE,
         p_daytime strm_transport_event.daytime%TYPE
         )
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES(getCalcGrsMass, WNDS, WNPS, RNPS);

FUNCTION getNetMass(
         p_unique strm_transport_event.event_no%TYPE
         )
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES(getNetMass, WNDS, WNPS, RNPS);

FUNCTION findNetStdVol (
     p_event_no     NUMBER)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (findNetStdVol, WNDS, WNPS, RNPS);

FUNCTION getBswVolFrac(
   p_event_no     NUMBER)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (getBswVolFrac, WNDS, WNPS, RNPS);

FUNCTION findGrsStdVol (
   p_event_no     NUMBER)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (findGrsStdVol, WNDS, WNPS, RNPS);

FUNCTION findWatVol (
   p_event_no     NUMBER)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (findWatVol, WNDS, WNPS, RNPS);

FUNCTION findNetStdMass (
   p_event_no     NUMBER)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (findNetStdMass, WNDS, WNPS, RNPS);

FUNCTION getBswWeightFrac(
   p_event_no     NUMBER)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (getBswWeightFrac, WNDS, WNPS, RNPS);

FUNCTION findGrsStdMass (
   p_event_no     NUMBER)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (findGrsStdMass, WNDS, WNPS, RNPS);

FUNCTION findWatMass (
   p_event_no     NUMBER)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (findWatMass, WNDS, WNPS, RNPS);

END EcBp_Stream_TruckTicket;