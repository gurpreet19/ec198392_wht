CREATE OR REPLACE PACKAGE BODY EcDp_Curve_Purpose IS

/****************************************************************
** Package        :  EcDp_Curve_Purpose, body part
**
** $Revision: 1.1.1.1 $
**
** Purpose        :  Provides constant declarations for curve purpose
**
** Documentation  :  www.energy-components.com
**
** Created  : 22.09.2000 Carl-Fredrik Sørensen
**
** Modification history:
**
** Version  Date     Whom  Change description:
** -------  ------   ----- --------------------------------------
**
*****************************************************************/

-------------------------------------------------------------------------------------------------
-- GAS_LIFT
-- Constant function, returns 'GAS_LIFT'
-- Used in formula_type
-------------------------------------------------------------------------------------------------
FUNCTION GAS_LIFT

RETURN VARCHAR2 IS
BEGIN

  RETURN 'GAS_LIFT';

END GAS_LIFT;

-------------------------------------------------------------------------------------------------
-- INJECTION
-- Constant function, returns 'INJECTION'
-- Used in formula_type
-------------------------------------------------------------------------------------------------
FUNCTION INJECTION

RETURN VARCHAR2 IS
BEGIN

  RETURN 'INJECTION';

END INJECTION;

-------------------------------------------------------------------------------------------------
-- PRODUCTION
-- Constant function, returns 'PRODUCTION'
-- Used in formula_type
-------------------------------------------------------------------------------------------------
FUNCTION PRODUCTION

RETURN VARCHAR2 IS
BEGIN

  RETURN 'PRODUCTION';

END PRODUCTION;

END EcDp_Curve_Purpose;