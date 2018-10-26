CREATE OR REPLACE PACKAGE EcDp_Stream_Measured IS

/****************************************************************
** Package        :  EcDp_Stream_Measured
**
** $Revision: 1.3 $
**
** Purpose        :  This package is responsible for stream fluid information of measured stream
**                   values
**
** Documentation  :  www.energy-components.com
**
** Created  : 22.11.1999  Carl-Fredrik Sørensen
**
** Modification history:
**
** Version  Date     Whom  Change description:
** -------  ------   ----- --------------------------------------
** 1.0      22.11.1999  CFS    First version
** 1.1      23.07.2004  kaurrnar     Removed p_sysnam, p_stream_code and update as necessary
**          23.02.2005  kaurrnar     Removed deadcode. Changed stor_attribute to stor_version
*****************************************************************/

--

FUNCTION getStdDens (
     p_object_id   stream.object_id%TYPE,
     p_daytime     stor_version.daytime%TYPE)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (getStdDens, WNDS, WNPS, RNPS);

--

FUNCTION getGrsStdMass (
     p_object_id   stream.object_id%TYPE,
     p_fromday     DATE,
     p_today       DATE)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (getGrsStdMass, WNDS, WNPS, RNPS);

--

FUNCTION getGrsStdVol (
     p_object_id   stream.object_id%TYPE,
     p_fromday     DATE,
     p_today       DATE)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (getGrsStdVol, WNDS, WNPS, RNPS);

--

FUNCTION getNetStdMass (
     p_object_id   stream.object_id%TYPE,
     p_fromday     DATE,
     p_today       DATE)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (getNetStdMass, WNDS, WNPS, RNPS);

--

FUNCTION getNetStdVol (
     p_object_id   stream.object_id%TYPE,
     p_fromday     DATE,
     p_today       DATE)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (getNetStdVol, WNDS, WNPS, RNPS);

--

FUNCTION getWatMass (
     p_object_id   stream.object_id%TYPE,
     p_fromday     DATE,
     p_today       DATE)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (getWatMass, WNDS, WNPS, RNPS);

--

FUNCTION getWatVol (
     p_object_id   stream.object_id%TYPE,
     p_fromday     DATE,
     p_today       DATE)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (getWatVol, WNDS, WNPS, RNPS);

END;