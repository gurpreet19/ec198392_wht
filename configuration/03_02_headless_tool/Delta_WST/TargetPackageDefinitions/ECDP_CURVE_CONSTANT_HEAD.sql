CREATE OR REPLACE PACKAGE EcDp_Curve_Constant IS

/****************************************************************
** Package        :  EcDp_Curve_Constant, header part
**
** $Revision: 1.4 $
**
** Purpose        :  Provides constant declarations for curvess
**
** Documentation  :  www.energy-components.com
**
** Created  : 22.09.2000 Carl-Fredrik Sørensen
**
** Modification history:
**
** Version  Date      	Whom  	  Change description:
** -------  ----------  --------  --------------------------------------
**          13.02.2004  BIH  	  Removed unused entries, changed SQRT_POLYNOM_2 to INV_POLYNOM_2
**          09.03.2010  musaamah  ECPD-13372: Added function POLYNOM_3 as an enhancement purpose for Well Performance Curves.
*****************************************************************/



FUNCTION CURVE_POINT RETURN VARCHAR2;

PRAGMA RESTRICT_REFERENCES(CURVE_POINT, WNDS, WNPS, RNPS);

--


FUNCTION LINEAR RETURN VARCHAR2;

PRAGMA RESTRICT_REFERENCES(linear, WNDS, WNPS, RNPS);

--

FUNCTION POLYNOM_2 RETURN VARCHAR2;

PRAGMA RESTRICT_REFERENCES(POLYNOM_2, WNDS, WNPS, RNPS);

--

FUNCTION INV_POLYNOM_2 RETURN VARCHAR2;

PRAGMA RESTRICT_REFERENCES(INV_POLYNOM_2, WNDS, WNPS, RNPS);

--

FUNCTION POLYNOM_3 RETURN VARCHAR2;

PRAGMA RESTRICT_REFERENCES(POLYNOM_3, WNDS, WNPS, RNPS);

END EcDp_Curve_Constant;