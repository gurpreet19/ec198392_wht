CREATE OR REPLACE PACKAGE BODY EcDp_Type IS

/****************************************************************
** Package        :  EcDp_Type, body part
**
** $Revision: 1.1.1.1 $
**
** Purpose        :  This package is for defining EC package types
**
** Documentation  :  www.energy-components.com
**
** Created  : 12.01.2000  Carl-Fredrik Sørensen
**
** Modification history:
**
** Version  Date     	Whom  Change description:
** -------  ------   	----- -----------------------------------
** 3.1      09.05.2000  CFS   Added constants IS_TRUE, IS_FALSE
*****************************************************************/

--

FUNCTION IS_TRUE
RETURN VARCHAR2 IS

BEGIN

	RETURN 'Y';

END IS_TRUE;

--

FUNCTION IS_FALSE
RETURN VARCHAR2 IS

BEGIN

	RETURN 'N';

END IS_FALSE;


END;