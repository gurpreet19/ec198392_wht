CREATE OR REPLACE PACKAGE EcDp_Stream_Fluid IS
/****************************************************************
** Package        :  EcDp_Stream_Fluid; body part
**
** $Revision: 1.5 $
**
** Purpose        :  This package is responsible for stream fluid data services
**
** Documentation  :  www.energy-components.com
**
** Created        :  06.12.1999  Carl-Fredrik Sørensen
**
** Modification history:
**
** Date     Whom  Change description:
** ------   ----- --------------------------------------
** 6/12/1999 CFS  First version
**	07.06.2001 KB	Changes made for Phillips (implemented for ATL)
** 27.05.2004 DN  Removed default option COMP on p_analysis_type parameter. Added getMaxStreamDens.
** 04.08.2004     removed stream_code and sysnam and update as necessary
** 11.03.2005 kaurrnar	Removed deadcodes
**			Added 3 new function: getMaxStreamSpecGrav,
**			getMaxStreamGasSpecGrav, getMaxStreamOilSpecGrav
*****************************************************************/

FUNCTION getMaxStreamDens (
	p_object_id     VARCHAR2,
	p_phase         VARCHAR2,
	p_analysis_type VARCHAR2,
	p_daytime       DATE)

RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (getMaxStreamDens, WNDS, WNPS, RNPS);

--

FUNCTION getMaxStreamConDens (
	p_object_id stream.object_id%TYPE,
	p_daytime       DATE,
	p_analysis_type VARCHAR2)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (getMaxStreamConDens, WNDS, WNPS, RNPS);

--

FUNCTION getMaxStreamGasDens (
	p_object_id stream.object_id%TYPE,
	p_daytime       DATE,
	p_analysis_type VARCHAR2)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (getMaxStreamGasDens, WNDS, WNPS, RNPS);

--

FUNCTION getMaxStreamOilDens (
	p_object_id stream.object_id%TYPE,
	p_daytime       DATE,
	p_analysis_type VARCHAR2)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (getMaxStreamOilDens, WNDS, WNPS, RNPS);

--

FUNCTION getMaxStreamSpecGrav (
	p_object_id     VARCHAR2,
	p_phase         VARCHAR2,
	p_analysis_type VARCHAR2,
	p_daytime       DATE)

RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (getMaxStreamSpecGrav, WNDS, WNPS, RNPS);

--

FUNCTION getMaxStreamGasSpecGrav (
	p_object_id 	stream.object_id%TYPE,
	p_daytime       DATE,
	p_analysis_type VARCHAR2)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (getMaxStreamGasSpecGrav, WNDS, WNPS, RNPS);

--

FUNCTION getMaxStreamOilSpecGrav (
	p_object_id stream.object_id%TYPE,
	p_daytime       DATE,
	p_analysis_type VARCHAR2)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (getMaxStreamOilSpecGrav, WNDS, WNPS, RNPS);

END;