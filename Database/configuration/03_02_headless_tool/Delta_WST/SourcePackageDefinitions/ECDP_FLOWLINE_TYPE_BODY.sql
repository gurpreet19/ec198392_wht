CREATE OR REPLACE PACKAGE BODY EcDp_Flowline_Type IS

/****************************************************************
** Package        :  EcDp_Flowline_Type, body part
**
** $Revision: 1.2 $
**
** Purpose        :  Defines flowline types.
**
** Documentation  :  www.energy-components.com
**
** Created  : 16.09.2000  Carl-Fredrik S�sen
**
** Modification history:
**
** Version  Date     Whom  Change description:
** -------  ------   ----- --------------------------------------
** 1.0      16.09.00  TEJ   Initial version
**          03.12.2004 DN    TI 1823: Removed dummy package constructor.
*****************************************************************/


FUNCTION GAS_INJECTOR
RETURN VARCHAR2 IS

BEGIN

   RETURN 'GI';

END GAS_INJECTOR;

--
FUNCTION GAS_PRODUCER
RETURN VARCHAR2 IS

BEGIN

   RETURN 'GP';

END GAS_PRODUCER;

--

FUNCTION OIL_PRODUCER
RETURN VARCHAR2 IS

BEGIN

   RETURN 'OP';

END OIL_PRODUCER;

--

FUNCTION WATER_GAS_INJECTOR
RETURN VARCHAR2 IS

BEGIN

   RETURN 'WG';

END WATER_GAS_INJECTOR;

--

FUNCTION WATER_INJECTOR
RETURN VARCHAR2 IS

BEGIN

   RETURN 'WI';

END WATER_INJECTOR;

END EcDp_Flowline_Type;