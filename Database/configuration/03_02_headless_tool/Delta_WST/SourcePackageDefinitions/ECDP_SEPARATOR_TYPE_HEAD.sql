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
** Created  : 09.05.2000  Carl-Fredrik S�sen
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

--

FUNCTION INLET
RETURN VARCHAR2;

--

FUNCTION PRODUCTION
RETURN VARCHAR2;

--

FUNCTION TEST
RETURN VARCHAR2;

--

END EcDp_Separator_Type;