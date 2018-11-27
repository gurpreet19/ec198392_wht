CREATE OR REPLACE PACKAGE BODY EcDp_Curve_Constant IS

/****************************************************************
** Package        :  EcDp_Curve_Constant, body part
**
** $Revision: 1.4 $
**
** Purpose        :  Provides constant declarations for curvess
**
** Documentation  :  www.energy-components.com
**
** Created  : 22.09.2000 Carl-Fredrik S�sen
**
** Modification history:
**
** Version  Date     	Whom  	  Change description:
** -------  ----------  --------  --------------------------------------
**          13.02.2004  BIH  	  Removed unused entries, changed SQRT_POLYNOM_2 to INV_POLYNOM_2
**	        09.03.2010  musaamah  ECPD-13372: Added function POLYNOM_3 as an enhancement purpose for Well Performance Curves.
**          23.02.2017  choooshu  ECPD-32359: Added function POLYNOM_4 as an enhancement purpose for Well Performance Curves.
*****************************************************************/


-------------------------------------------------------------------------------------------------
-- CURVE_POINT
-- Constant function, returns 'CURVE_POINT'
-- Used in curve.formula_type
-------------------------------------------------------------------------------------------------
FUNCTION CURVE_POINT RETURN VARCHAR2 IS
BEGIN
	RETURN 'CURVE_POINT';
END CURVE_POINT;


-------------------------------------------------------------------------------------------------
-- LINEAR
-- Constant function, returns 'LINEAR'
-- Used in curve.formula_type
-------------------------------------------------------------------------------------------------
FUNCTION LINEAR RETURN VARCHAR2
IS
BEGIN
  RETURN 'LINEAR';
END LINEAR;

-------------------------------------------------------------------------------------------------
-- POLYNOM_2
-- Constant function, returns 'POLYNOM_2'
-- Used in curve.formula_type
-------------------------------------------------------------------------------------------------
FUNCTION POLYNOM_2 RETURN VARCHAR2
IS
BEGIN
  RETURN 'POLYNOM_2';
END POLYNOM_2;


-------------------------------------------------------------------------------------------------
-- INV_POLYNOM_2
-- Constant function, returns 'INV_POLYNOM_2'
-- Used in curve.formula_type
-------------------------------------------------------------------------------------------------
FUNCTION INV_POLYNOM_2 RETURN VARCHAR2
IS
BEGIN
  RETURN 'INV_POLYNOM_2';
END INV_POLYNOM_2;


-------------------------------------------------------------------------------------------------
-- POLYNOM_3
-- Constant function, returns 'POLYNOM_3'
-- Used in curve.formula_type
-------------------------------------------------------------------------------------------------
FUNCTION POLYNOM_3 RETURN VARCHAR2
IS
BEGIN
  RETURN 'POLYNOM_3';
END POLYNOM_3;

-------------------------------------------------------------------------------------------------
-- POLYNOM_4
-- Constant function, returns 'POLYNOM_4'
-- Used in curve.formula_type
-------------------------------------------------------------------------------------------------
FUNCTION POLYNOM_4 RETURN VARCHAR2
IS
BEGIN
  RETURN 'POLYNOM_4';
END POLYNOM_4;

END EcDp_Curve_Constant;