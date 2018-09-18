CREATE OR REPLACE PACKAGE EcBp_Truck_Ticket IS

/****************************************************************
** Package        :  EcBp_Truck_Ticket; head part
**
** $Revision: 1.3.12.1 $
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
**          30.07.2012  limmmchu	 ECPD-21588: Added findLiqGrsMass, findSandMass, findSandVol and calcDensity.
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
PRAGMA RESTRICT_REFERENCES (countChildEvent, WNDS, WNPS, RNPS);

PROCEDURE verifyTicket(
   p_event_no OBJECT_TRANSPORT_EVENT.EVENT_NO%TYPE,
   p_user VARCHAR2 DEFAULT USER);

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

FUNCTION findLiqGrsMass (
   p_event_no     NUMBER)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (findLiqGrsMass, WNDS, WNPS, RNPS);

FUNCTION findSandMass (
   p_event_no     NUMBER)
RETURN NUMBER;

FUNCTION findSandVol (
   p_event_no     NUMBER)
RETURN NUMBER;

FUNCTION calcDensity (
   p_event_no     NUMBER)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (calcDensity, WNDS, WNPS, RNPS);

END;