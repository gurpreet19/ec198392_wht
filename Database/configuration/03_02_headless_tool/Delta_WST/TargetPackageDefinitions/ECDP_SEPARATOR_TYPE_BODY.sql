CREATE OR REPLACE PACKAGE BODY EcDp_Separator_Type IS

/****************************************************************
** Package        :  EcDp_Separator_Type, body part
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


FUNCTION ARTIFICIAL
RETURN VARCHAR2 IS

BEGIN

   RETURN 'ARTIFICIAL';

END ARTIFICIAL;

--

FUNCTION INLET
RETURN VARCHAR2 IS

BEGIN

   RETURN 'INLET';

END INLET;

--

FUNCTION PRODUCTION
RETURN VARCHAR2 IS

BEGIN

   RETURN 'PROD';

END PRODUCTION;

--

FUNCTION TEST
RETURN VARCHAR2 IS

BEGIN

   RETURN 'TEST';

END TEST;

--

END EcDp_Separator_Type;