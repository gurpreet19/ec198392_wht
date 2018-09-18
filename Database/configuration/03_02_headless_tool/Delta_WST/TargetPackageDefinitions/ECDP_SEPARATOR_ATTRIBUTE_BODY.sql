CREATE OR REPLACE PACKAGE BODY EcDp_Separator_Attribute IS

/****************************************************************
** Package        :  EcDp_Separator_Attribute, body part
**
** $Revision: 1.1.1.1 $
**
** Purpose        :  Definition of separator attributes
**
** Documentation  :  www.energy-components.com
**
** Created  : 09.05.2000  Carl-Fredrik Sørensen
**
** Modification history:
**
** Version  Date        Whom  Change description:
** -------  ------      ----- -----------------------------------
*****************************************************************/

--

FUNCTION LP
RETURN VARCHAR2 IS

BEGIN

   RETURN 'LP';

END LP;

--

FUNCTION HP
RETURN VARCHAR2 IS

BEGIN

   RETURN 'HP';

END HP;

--

FUNCTION LLP
RETURN VARCHAR2 IS

BEGIN

   RETURN 'LLP';

END LLP;


END EcDp_Separator_Attribute;