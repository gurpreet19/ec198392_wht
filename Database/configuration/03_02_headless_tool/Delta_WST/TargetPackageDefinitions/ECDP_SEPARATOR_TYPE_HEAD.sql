CREATE OR REPLACE PACKAGE EcDp_Separator_Type IS

/****************************************************************
** Package        :  EcDp_Separator_Type, header part
**
** $Revision: 1.1.1.1 $
**
** Purpose        :  Defines separator types.
**
** Documentation  :  www.energy-components.com
**
** Created  : 09.05.2000  Carl-Fredrik Sørensen
**
** Modification history:
**
** Version  Date     Whom  Change description:
** -------  ------   ----- --------------------------------------
** 3.0	    11.09.00 CFS   Added INLET
*****************************************************************/

--

FUNCTION ARTIFICIAL
RETURN VARCHAR2;

PRAGMA RESTRICT_REFERENCES(ARTIFICIAL, WNDS, WNPS, RNPS);

--

FUNCTION INLET
RETURN VARCHAR2;

PRAGMA RESTRICT_REFERENCES(INLET, WNDS, WNPS, RNPS);

--

FUNCTION PRODUCTION
RETURN VARCHAR2;

PRAGMA RESTRICT_REFERENCES(PRODUCTION, WNDS, WNPS, RNPS);

--

FUNCTION TEST
RETURN VARCHAR2;

PRAGMA RESTRICT_REFERENCES(TEST, WNDS, WNPS, RNPS);

--

END EcDp_Separator_Type;