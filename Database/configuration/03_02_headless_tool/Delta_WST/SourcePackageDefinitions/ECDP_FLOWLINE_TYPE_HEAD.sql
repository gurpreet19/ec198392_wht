CREATE OR REPLACE PACKAGE EcDp_Flowline_Type IS

/****************************************************************
** Package        :  EcDp_Flowline_Type, header part
**
** $Revision: 1.1.1.1 $
**
** Purpose        :  Defines flowline types.
**
** Documentation  :  www.energy-components.com
**
** Created  : 16.09.2000  Carl-Fredrik S?sen
**
** Modification history:
**
** Version  Date     Whom  Change description:
** -------  ------   ----- --------------------------------------
** 1.0      16.09.00  TEJ   Initial version
*****************************************************************/

--

FUNCTION GAS_INJECTOR
RETURN VARCHAR2;

--

FUNCTION GAS_PRODUCER
RETURN VARCHAR2;

--

FUNCTION OIL_PRODUCER
RETURN VARCHAR2;

--

FUNCTION WATER_GAS_INJECTOR
RETURN VARCHAR2;

--

FUNCTION WATER_INJECTOR
RETURN VARCHAR2;

--

END EcDp_Flowline_Type;