CREATE OR REPLACE PACKAGE EcDp_Stream_Derived IS

/****************************************************************
** Package        :  EcDp_Stream_Derived, header part
**
** $Revision: 1.4 $
**
** Purpose        :  This package is responsible for stream fluid
**                   information for derived streams
**
** Documentation  :  www.energy-components.com
**
** Created  : 22.11.1999  Carl-Fredrik Sørensen
**
** Modification history:
**
** Version  Date        Whom      Change description:
** -------  ----------  --------  --------------------------------------
** 1.0      14.12.1999  CFS       First version
**          29.03.2000  RRA       Added function getGrsStdVol
** 3.3      19.07.2000  HNE       Added functions getGrsStdMass and getNetStdMass
** 3.4      04.08.2004  kaurrnar  removed sysnam ans stream_code and update as necessary
** 3.5      25.09.2006  kaurrjes  TI#4547: Added new function getEnergy and removed p_sysnam and p_stream_code
**          03.03.2008  rajarsar  ECPD-7127: added new function getPowerConsumption
*****************************************************************/

FUNCTION getNetStdVol (
   p_object_id stream.object_id%TYPE,
   p_fromday       DATE,
   p_today         DATE)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (getNetStdVol, WNDS, WNPS, RNPS);

--
FUNCTION getGrsStdVol (
   p_object_id stream.object_id%TYPE,
   p_fromday       DATE,
   p_today         DATE)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (getGrsStdVol, WNDS, WNPS, RNPS);

--
FUNCTION getNetStdMass (
   p_object_id stream.object_id%TYPE,
   p_fromday       DATE,
   p_today         DATE)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (getNetStdMass, WNDS, WNPS, RNPS);

--
FUNCTION getGrsStdMass (
   p_object_id stream.object_id%TYPE,
   p_fromday       DATE,
   p_today         DATE)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (getGrsStdMass, WNDS, WNPS, RNPS);

--
FUNCTION getEnergy (
   p_object_id stream.object_id%TYPE,
   p_fromday       DATE,
   p_today         DATE)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (getEnergy, WNDS, WNPS, RNPS);


--
FUNCTION getPowerConsumption (
   p_object_id stream.object_id%TYPE,
   p_fromday       DATE,
   p_today         DATE)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (getPowerConsumption, WNDS, WNPS, RNPS);

END;