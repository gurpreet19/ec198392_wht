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
** Created  : 18.01.2000  Carl-Fredrik Sørensen
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

PRAGMA RESTRICT_REFERENCES(PRODUCER, WNDS, WNPS, RNPS);

--

FUNCTION INJECTOR
RETURN VARCHAR2;

PRAGMA RESTRICT_REFERENCES(INJECTOR, WNDS, WNPS, RNPS);

--

FUNCTION PRODUCER_INJECTOR
RETURN VARCHAR2;

PRAGMA RESTRICT_REFERENCES(PRODUCER_INJECTOR, WNDS, WNPS, RNPS);


END EcDp_Well_Class;