CREATE OR REPLACE PACKAGE Ue_Truck_Ticket IS

/****************************************************************
** Package        :  Ue_Truck_Ticket; head part
**
** $Revision: 1.8 $
**
** Purpose        :  This package is responsible for project specific extensions directly related
**                   to truck ticket operations, consisting of single transfer and
**                   stream-to/from-well transfer events.
**
** Documentation  :  www.energy-components.com
**
** Created        :  09.12.2009  Irlene Fincaryk
**
** Modification history:
**
** Version  Date        Whom         Change description:
** -------  ----------  --------     --------------------------------------
** 1.0      09.12.2009  fincairl     First version
**          28.05.2013  rajarsar     ECPD-21876: Added user exit support for findGrsStdVol, findNetStdVol,findWatVol,findSandVol
**                                   findGrsStdMass,findNetStdMass, findSandMass,calcDensity,findOilDensity,findWaterDensity, findSandDensity,
**                                   findBswVolFrac,findBswWtFrac and volumeCorrFactor.
**          28.05.2013  musthram     ECPD-21876: Added user exit support for verifyTicket
**          29.05.2013  musthram     ECPD-21876: Added user exit support for findWatMass
**          20.06.2013  rajarsar     ECPD-21876: Added user exit support for findWellStdVol,findWellWaterVol,findWellGrsStdMass, findWellNetStdMass
**          31.03.2016  shindani     ECPD-31221: Added user exit support for findWellGrsStdVol,findWellBswVolFrac.
*****************************************************************/

PROCEDURE verifyTicket(
     p_event_no NUMBER,
    p_user VARCHAR2 DEFAULT USER);

PROCEDURE prorateTruckedWellProd(
     p_startdate    DATE,
     p_end_date     DATE,
     p_facility_id  VARCHAR2);

PROCEDURE prorateTruckedWellLoadOil(
     p_facility_id  VARCHAR2,
     p_startday     DATE,
     p_endday      DATE);

FUNCTION findGrsStdVol(
     p_event_no     NUMBER,
     p_resolve_loop VARCHAR2 DEFAULT NULL)
RETURN NUMBER;

FUNCTION findNetStdVol(
     p_event_no     NUMBER,
     p_resolve_loop VARCHAR2 DEFAULT NULL)
RETURN NUMBER;

FUNCTION findWatVol(
     p_event_no     NUMBER,
     p_resolve_loop VARCHAR2 DEFAULT NULL)
RETURN NUMBER;

FUNCTION findSandVol(
   p_event_no     NUMBER,
   p_resolve_loop VARCHAR2 DEFAULT NULL)
RETURN NUMBER;

FUNCTION findWellStdVol(
   p_event_no     NUMBER,
   p_object_id VARCHAR2,
   p_resolve_loop VARCHAR2 DEFAULT NULL)
RETURN NUMBER;

FUNCTION findWellGrsStdVol(
     p_event_no     NUMBER,
     p_resolve_loop VARCHAR2 DEFAULT NULL)
RETURN NUMBER;

FUNCTION findWellWaterVol(
   p_event_no     NUMBER,
   p_object_id VARCHAR2,
   p_resolve_loop VARCHAR2 DEFAULT NULL)
RETURN NUMBER;

FUNCTION findGrsStdMass(
   p_event_no     NUMBER,
   p_resolve_loop VARCHAR2 DEFAULT NULL)
RETURN NUMBER;

FUNCTION findNetStdMass(
   p_event_no     NUMBER,
   p_resolve_loop VARCHAR2 DEFAULT NULL)
RETURN NUMBER;

FUNCTION findWatMass(
   p_event_no     NUMBER,
   p_resolve_loop VARCHAR2 DEFAULT NULL)
RETURN NUMBER;

FUNCTION findSandMass(
   p_event_no     NUMBER,
   p_resolve_loop VARCHAR2 DEFAULT NULL)
RETURN NUMBER;

FUNCTION findWellGrsStdMass(
   p_event_no     NUMBER,
   p_object_id VARCHAR2,
   p_resolve_loop VARCHAR2 DEFAULT NULL)
RETURN NUMBER;

FUNCTION findWellNetStdMass(
   p_event_no     NUMBER,
   p_object_id    VARCHAR2,
   p_resolve_loop VARCHAR2 DEFAULT NULL)
RETURN NUMBER;


FUNCTION calcDensity(
   p_event_no     NUMBER,
   p_resolve_loop VARCHAR2 DEFAULT NULL)
RETURN NUMBER;

FUNCTION findOilDensity(
   p_event_no     NUMBER,
   p_resolve_loop VARCHAR2 DEFAULT NULL)
RETURN NUMBER;

FUNCTION findWaterDensity(
   p_event_no     NUMBER,
   p_resolve_loop VARCHAR2 DEFAULT NULL)
RETURN NUMBER;

FUNCTION findSandDensity(
   p_event_no     NUMBER,
   p_resolve_loop VARCHAR2 DEFAULT NULL)
RETURN NUMBER;

FUNCTION findBswVolFrac(
   p_event_no     NUMBER,
   p_resolve_loop VARCHAR2 DEFAULT NULL)
RETURN NUMBER;

FUNCTION findWellBswVolFrac(
   p_event_no     NUMBER,
   p_resolve_loop VARCHAR2 DEFAULT NULL)
RETURN NUMBER;

FUNCTION findBswWtFrac(
   p_event_no     NUMBER,
   p_resolve_loop VARCHAR2 DEFAULT NULL)
RETURN NUMBER;

FUNCTION volumeCorrFactor(
   p_event_no NUMBER)
RETURN NUMBER;


END;