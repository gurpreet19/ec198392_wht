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
** Created        :  06.12.1999  Carl-Fredrik S�sen
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

--

FUNCTION getMaxStreamConDens (
	p_object_id stream.object_id%TYPE,
	p_daytime       DATE,
	p_analysis_type VARCHAR2)
RETURN NUMBER;

--

FUNCTION getMaxStreamGasDens (
	p_object_id stream.object_id%TYPE,
	p_daytime       DATE,
	p_analysis_type VARCHAR2)
RETURN NUMBER;

--

FUNCTION getMaxStreamOilDens (
	p_object_id stream.object_id%TYPE,
	p_daytime       DATE,
	p_analysis_type VARCHAR2)
RETURN NUMBER;

--

FUNCTION getMaxStreamSpecGrav (
	p_object_id     VARCHAR2,
	p_phase         VARCHAR2,
	p_analysis_type VARCHAR2,
	p_daytime       DATE)

RETURN NUMBER;

--

FUNCTION getMaxStreamGasSpecGrav (
	p_object_id 	stream.object_id%TYPE,
	p_daytime       DATE,
	p_analysis_type VARCHAR2)
RETURN NUMBER;

--

FUNCTION getMaxStreamOilSpecGrav (
	p_object_id stream.object_id%TYPE,
	p_daytime       DATE,
	p_analysis_type VARCHAR2)
RETURN NUMBER;

END;