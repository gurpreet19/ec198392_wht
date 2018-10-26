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
** Created  : 22.09.2000 Carl-Fredrik Sørensen
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

PRAGMA RESTRICT_REFERENCES(GAS_LIFT, WNDS, WNPS, RNPS);

--

FUNCTION INJECTION

RETURN VARCHAR2;

PRAGMA RESTRICT_REFERENCES(INJECTION, WNDS, WNPS, RNPS);

--

FUNCTION PRODUCTION

RETURN VARCHAR2;

PRAGMA RESTRICT_REFERENCES(PRODUCTION, WNDS, WNPS, RNPS);

--


END EcDp_Curve_Purpose;