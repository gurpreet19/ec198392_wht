CREATE OR REPLACE PACKAGE BODY EcDp_Well_Class IS

/****************************************************************
** Package        :  EcDp_Well_Class, body part
**
** $Revision: 1.1.1.1 $
**
** Purpose        :  Defines well classes.
**
** Documentation  :  www.energy-components.com
**
** Created  : 17.01.2000  Carl-Fredrik S�sen
**
** Modification history:
**
** Version  Date     Whom  Change description:
** -------  ------   ----- --------------------------------------
** 1.0   	17.01.00  CFS   Initial version
*****************************************************************/


FUNCTION PRODUCER
RETURN VARCHAR2 IS

BEGIN

   RETURN 'P';

END PRODUCER;

--

FUNCTION INJECTOR
RETURN VARCHAR2 IS

BEGIN

   RETURN 'I';

END INJECTOR;

--

FUNCTION PRODUCER_INJECTOR
RETURN VARCHAR2 IS

BEGIN

   RETURN 'PI';

END PRODUCER_INJECTOR;


END EcDp_Well_Class;