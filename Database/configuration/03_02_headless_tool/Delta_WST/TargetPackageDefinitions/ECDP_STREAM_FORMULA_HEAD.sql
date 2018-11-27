CREATE OR REPLACE PACKAGE EcDp_Stream_Formula IS

/****************************************************************
** Package        :  EcDp_Stream_Formula, header part
**
** $Revision: 1.10 $
**
** Purpose        :  This package is responsible for stream fluid
**                   information for formula streams
**
** Documentation  :  www.energy-components.com
**
** Created  : 03.12.2002  Peter Gilling
**
** Modification history:
**
** Date        Whom    Change description:
** ------      -----   --------------------------------------
** 03.12.2002  PGI      First version
** 06.01.2002  PGI      Implemented changes in strm_formula and strm_formula_item
** 03.08.2004  kaurrnar           removed sysnam and stream_code and update as necessary
** 28.02.2005  kaurrnar	Removed deadcodes
** 20.12.2005  DN       Added getNextFormula amd getPreviousFormula.
** 02.10.2006  MOT      #4460: Added Zero function
** 23.08.2007  rajarsar ECPD-6246: Added getEnergy.
** 03.03.2008  rajarsar ECPD-7127: Added getPowerConsumption.
** 26.08.2008  aliassit	ECPD-9080: Added p_stream_id in function evaluateMethod and replaceItem
** 11.04.2011  musthram ECPD-16877: Added function getGCV
*****************************************************************/

FUNCTION getNetStdVol (
     p_object_id     stream.object_id%TYPE,
     p_fromday       DATE,
     p_today         DATE)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (getNetStdVol, WNDS, WNPS, RNPS);

--
FUNCTION getGrsStdVol (
     p_object_id     stream.object_id%TYPE,
     p_fromday       DATE,
     p_today         DATE)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (getGrsStdVol, WNDS, WNPS, RNPS);

--
FUNCTION getNetStdMass (
     p_object_id     stream.object_id%TYPE,
     p_fromday       DATE,
     p_today         DATE)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (getNetStdMass, WNDS, WNPS, RNPS);

--
FUNCTION getGrsStdMass (
     p_object_id     stream.object_id%TYPE,
     p_fromday       DATE,
     p_today         DATE)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (getGrsStdMass, WNDS, WNPS, RNPS);

--
FUNCTION getEnergy (
     p_object_id     stream.object_id%TYPE,
     p_fromday       DATE,
     p_today         DATE)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (getEnergy, WNDS, WNPS, RNPS);


--
FUNCTION getPowerConsumption (
     p_object_id     stream.object_id%TYPE,
     p_fromday       DATE,
     p_today         DATE)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (getPowerConsumption, WNDS, WNPS, RNPS);

--
FUNCTION getValueFromFormula (
     p_object_id     stream.object_id%TYPE,
     p_fromday       DATE,
     p_today         DATE,
     p_method			   VARCHAR2)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (getValueFromFormula, WNDS, WNPS, RNPS);

--
FUNCTION evaluateFormula (
     p_formula_id     VARCHAR2,
     p_formula 		    VARCHAR2,
     p_fromday		    DATE,
     p_today          DATE,
     p_stream_id VARCHAR2 DEFAULT NULL)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (evaluateFormula, WNDS, WNPS, RNPS);

--
FUNCTION replaceItem(
     p_formula_no     VARCHAR2,
     p_variable_name  VARCHAR2,
     p_fromday        DATE,
     p_today          DATE,
     p_stream_id VARCHAR2 DEFAULT NULL)
RETURN VARCHAR2;
PRAGMA RESTRICT_REFERENCES (replaceItem, WNDS, WNPS, RNPS);

FUNCTION checkCircularReference    (
					p_daytime           DATE,
					p_member_object_id  VARCHAR2,
					p_member_method		  VARCHAR2,
					p_orig_object_id		VARCHAR2,
					p_orig_method			  VARCHAR2) RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (checkCircularReference, WNDS, WNPS, RNPS);

FUNCTION translateStrmMethods (p_method VARCHAR2) RETURN VARCHAR2;
PRAGMA RESTRICT_REFERENCES (translateStrmMethods, WNDS, WNPS, RNPS);


FUNCTION getNextFormula (
     p_object_id stream.object_id%TYPE,
     p_formula_method         VARCHAR2,
     p_daytime                    DATE)
RETURN strm_formula%ROWTYPE;

PRAGMA RESTRICT_REFERENCES (getNextFormula, WNDS, WNPS, RNPS);


FUNCTION getPreviousFormula (
     p_object_id stream.object_id%TYPE,
     p_formula_method         VARCHAR2,
     p_daytime                    DATE)
RETURN strm_formula%ROWTYPE;

PRAGMA RESTRICT_REFERENCES (getPreviousFormula, WNDS, WNPS, RNPS);

FUNCTION getGCV (
     p_object_id     stream.object_id%TYPE,
     p_fromday       DATE,
     p_today         DATE)
RETURN NUMBER;

PRAGMA RESTRICT_REFERENCES (getGCV, WNDS, WNPS, RNPS);

FUNCTION zero(
     p_a NUMBER,
     p_b  NUMBER)
RETURN NUMBER;

PRAGMA RESTRICT_REFERENCES (zero, WNDS, WNPS, RNPS);

END;