CREATE OR REPLACE PACKAGE BODY Ue_Truck_Ticket IS

/****************************************************************
** Package        :  Ue_Truck_Ticket; body part
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
--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      :  verifyTicket
-- Description    :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
PROCEDURE verifyTicket(
	p_event_no  NUMBER,
	p_user VARCHAR2 DEFAULT USER)


IS

BEGIN

	NULL;

END verifyTicket;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : prorateTruckedWellProd
-- Description    : Called after EcBp_TruckTicket.prorateTruckedWellProd
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
PROCEDURE prorateTruckedWellProd(
                p_startdate       DATE,
                p_end_date        DATE,
                p_facility_id     VARCHAR2)

IS
BEGIN
NULL;
END prorateTruckedWellProd;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : prorateTruckedWellLoadOil
-- Description    : Called after EcBp_TruckTicket.prorateTruckedWellLoadOil
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
PROCEDURE prorateTruckedWellLoadOil(
                p_facility_id     VARCHAR2,
                p_startday        DATE,
                p_endday         DATE)
IS
BEGIN
NULL;
END prorateTruckedWellLoadOil;

---------------------------------------------------------------------------------------------------
-- Function       : findGrsStdVol
-- Description    :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION findGrsStdVol(
  p_event_no     NUMBER,
  p_resolve_loop VARCHAR2 DEFAULT NULL)
RETURN NUMBER
--</EC-DOC>
IS
BEGIN
  RETURN NULL;

END findGrsStdVol;

---------------------------------------------------------------------------------------------------
-- Function       : findNetStdVol
-- Description    :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION findNetStdVol(
  p_event_no     NUMBER,
  p_resolve_loop VARCHAR2 DEFAULT NULL)
RETURN NUMBER
--</EC-DOC>
IS
BEGIN
  RETURN NULL;

END findNetStdVol;

---------------------------------------------------------------------------------------------------
-- Function       : findWatVol
-- Description    :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION findWatVol(
  p_event_no     NUMBER,
  p_resolve_loop VARCHAR2 DEFAULT NULL)
RETURN NUMBER
--</EC-DOC>
IS
BEGIN
  RETURN NULL;

END findWatVol;

---------------------------------------------------------------------------------------------------
-- Function       : findSandVol
-- Description    :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION findSandVol (
  p_event_no     NUMBER,
  p_resolve_loop VARCHAR2 DEFAULT NULL)
RETURN NUMBER
--</EC-DOC>
IS
BEGIN
  RETURN NULL;
END  findSandVol;

---------------------------------------------------------------------------------------------------
-- Function       : findWellStdVol
-- Description    :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION findWellStdVol (
  p_event_no     NUMBER,
  p_object_id VARCHAR2,
  p_resolve_loop VARCHAR2 DEFAULT NULL)
RETURN NUMBER
--</EC-DOC>
IS
BEGIN
  RETURN NULL;
END  findWellStdVol;

---------------------------------------------------------------------------------------------------
-- Function       : findWellGrsStdVol
-- Description    :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION findWellGrsStdVol(
  p_event_no     NUMBER,
  p_resolve_loop VARCHAR2 DEFAULT NULL)
RETURN NUMBER
--</EC-DOC>
IS
BEGIN
  RETURN NULL;

END findWellGrsStdVol;

---------------------------------------------------------------------------------------------------
-- Function       : findWellWaterVol
-- Description    :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION findWellWaterVol(
  p_event_no     NUMBER,
  p_object_id VARCHAR2,
  p_resolve_loop VARCHAR2 DEFAULT NULL)
RETURN NUMBER
--</EC-DOC>
IS
BEGIN
  RETURN NULL;
END  findWellWaterVol;


---------------------------------------------------------------------------------------------------
-- Function       : findGrsStdMass
-- Description    :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION findGrsStdMass(
  p_event_no     NUMBER,
  p_resolve_loop VARCHAR2 DEFAULT NULL)
RETURN NUMBER
--</EC-DOC>
IS
BEGIN
  RETURN NULL;

END findGrsStdMass;

---------------------------------------------------------------------------------------------------
-- Function       : findNetStdMass
-- Description    :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION findNetStdMass(
  p_event_no     NUMBER,
  p_resolve_loop VARCHAR2 DEFAULT NULL)
RETURN NUMBER
--</EC-DOC>
IS
BEGIN
  RETURN NULL;

END findNetStdMass;

---------------------------------------------------------------------------------------------------
-- Function       : findWatMass
-- Description    :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION findWatMass(
  p_event_no     NUMBER, p_resolve_loop VARCHAR2 DEFAULT NULL)
RETURN NUMBER
--</EC-DOC>
IS
BEGIN
  RETURN NULL;

END findWatMass;

---------------------------------------------------------------------------------------------------
-- Function       : findSandMass
-- Description    :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION findSandMass(
  p_event_no     NUMBER, p_resolve_loop VARCHAR2 DEFAULT NULL)
RETURN NUMBER
--</EC-DOC>
IS
BEGIN
  RETURN NULL;

END findSandMass;

---------------------------------------------------------------------------------------------------
-- Function       : findWellGrsStdMass
-- Description    :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION findWellGrsStdMass(
  p_event_no     NUMBER, p_object_id VARCHAR2 , p_resolve_loop VARCHAR2 DEFAULT NULL)
RETURN NUMBER
--</EC-DOC>
IS
BEGIN
  RETURN NULL;

END findWellGrsStdMass;

---------------------------------------------------------------------------------------------------
-- Function       : findWellNetStdMass
-- Description    :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION findWellNetStdMass(
  p_event_no     NUMBER, p_object_id VARCHAR2,  p_resolve_loop VARCHAR2 DEFAULT NULL)
RETURN NUMBER
--</EC-DOC>
IS
BEGIN
  RETURN NULL;

END findWellNetStdMass;

---------------------------------------------------------------------------------------------------
-- Function       : calcDensity
-- Description    :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION calcDensity (
  p_event_no     NUMBER,
  p_resolve_loop VARCHAR2 DEFAULT NULL)
RETURN NUMBER
--</EC-DOC>
IS
BEGIN
  RETURN NULL;

END  calcDensity;

---------------------------------------------------------------------------------------------------
-- Function       : findOilDensity
-- Description    :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION findOilDensity (
  p_event_no     NUMBER,
  p_resolve_loop VARCHAR2 DEFAULT NULL)
RETURN NUMBER
--</EC-DOC>
IS
BEGIN
  RETURN NULL;

END findOilDensity;

---------------------------------------------------------------------------------------------------
-- Function       : findWaterDensity
-- Description    :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION findWaterDensity(
  p_event_no     NUMBER,
  p_resolve_loop VARCHAR2 DEFAULT NULL)
RETURN NUMBER
--</EC-DOC>
IS
BEGIN
  RETURN NULL;

END findWaterDensity;

---------------------------------------------------------------------------------------------------
-- Function       : findSandDensity
-- Description    :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION findSandDensity(
  p_event_no     NUMBER,
  p_resolve_loop VARCHAR2 DEFAULT NULL)
RETURN NUMBER
--</EC-DOC>
IS
BEGIN
  RETURN NULL;

END findSandDensity;

---------------------------------------------------------------------------------------------------
-- Function       : findBswVolFrac
-- Description    :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION findBswVolFrac(
  p_event_no     NUMBER,
  p_resolve_loop VARCHAR2 DEFAULT NULL)
RETURN NUMBER
--</EC-DOC>
IS
BEGIN
  RETURN NULL;

END findBswVolFrac;

---------------------------------------------------------------------------------------------------
-- Function       : findBswVolFrac
-- Description    :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION findWellBswVolFrac(
  p_event_no     NUMBER,
  p_resolve_loop VARCHAR2 DEFAULT NULL)
RETURN NUMBER
--</EC-DOC>
IS
BEGIN
  RETURN NULL;

END findWellBswVolFrac;

---------------------------------------------------------------------------------------------------
-- Function       : findBswWtFrac
-- Description    :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION findBswWtFrac(
  p_event_no     NUMBER,
  p_resolve_loop VARCHAR2 DEFAULT NULL)
RETURN NUMBER
--</EC-DOC>
IS
BEGIN
  RETURN NULL;

END findBswWtFrac;

---------------------------------------------------------------------------------------------------
-- Function       : VolumeCorrFactor
-- Description    :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION volumeCorrFactor(
  p_event_no     NUMBER)
RETURN NUMBER
--</EC-DOC>
IS
BEGIN
  RETURN NULL;

END volumeCorrFactor;

END Ue_Truck_Ticket;