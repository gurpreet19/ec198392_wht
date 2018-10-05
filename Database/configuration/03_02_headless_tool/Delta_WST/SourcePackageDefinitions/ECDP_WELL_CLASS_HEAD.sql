CREATE OR REPLACE PACKAGE EcDp_Well_Class IS

/****************************************************************
** Package        :  EcDp_Well_Class, header part
**
** $Revision: 1.1.1.1 $
**
** Purpose        :  Defines well classes.
**
** Documentation  :  www.energy-components.com
**
** Created  : 18.01.2000  Carl-Fredrik S?sen
**
** Modification history:
**
** Version  Date     Whom  Change description:
** -------  ------   ----- --------------------------------------
** 1.0      18.01.00  CFS   Initial version
*****************************************************************/

--

FUNCTION PRODUCER
RETURN VARCHAR2;

--

FUNCTION INJECTOR
RETURN VARCHAR2;

--

FUNCTION PRODUCER_INJECTOR
RETURN VARCHAR2;


END EcDp_Well_Class;