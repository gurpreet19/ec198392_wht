CREATE OR REPLACE PACKAGE EcDp_Curve_Purpose IS

/****************************************************************
** Package        :  EcDp_Curve_Purpose, header part
**
** $Revision: 1.1.1.1 $
**
** Purpose        :  Provides constant declarations for curve purpose
**
** Documentation  :  www.energy-components.com
**
** Created  : 22.09.2000 Carl-Fredrik S?sen
**
** Modification history:
**
** Version  Date     Whom  Change description:
** -------  ------   ----- --------------------------------------
**
*****************************************************************/

--

FUNCTION GAS_LIFT

RETURN VARCHAR2;

--

FUNCTION INJECTION

RETURN VARCHAR2;

--

FUNCTION PRODUCTION

RETURN VARCHAR2;

--


END EcDp_Curve_Purpose;