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
** Created  : 22.09.2000 Carl-Fredrik S?sen
**
** Modification history:
**
** Version  Date      	Whom  	  Change description:
** -------  ----------  --------  --------------------------------------
**          13.02.2004  BIH  	  Removed unused entries, changed SQRT_POLYNOM_2 to INV_POLYNOM_2
**          09.03.2010  musaamah  ECPD-13372: Added function POLYNOM_3 as an enhancement purpose for Well Performance Curves.
**          23.02.2017  choooshu  ECPD-32359: Added function POLYNOM_4 as an enhancement purpose for Well Performance Curves.
*****************************************************************/



FUNCTION CURVE_POINT RETURN VARCHAR2;

--


FUNCTION LINEAR RETURN VARCHAR2;

--

FUNCTION POLYNOM_2 RETURN VARCHAR2;

--

FUNCTION INV_POLYNOM_2 RETURN VARCHAR2;

--

FUNCTION POLYNOM_3 RETURN VARCHAR2;

--

FUNCTION POLYNOM_4 RETURN VARCHAR2;

END EcDp_Curve_Constant;