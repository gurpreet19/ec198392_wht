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
** Created  : 16.09.2000  Carl-Fredrik Sørensen
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

PRAGMA RESTRICT_REFERENCES(GAS_INJECTOR, WNDS, WNPS, RNPS, RNDS);

--

FUNCTION GAS_PRODUCER
RETURN VARCHAR2;

PRAGMA RESTRICT_REFERENCES(GAS_PRODUCER, WNDS, WNPS, RNPS, RNDS);

--

FUNCTION OIL_PRODUCER
RETURN VARCHAR2;

PRAGMA RESTRICT_REFERENCES(OIL_PRODUCER, WNDS, WNPS, RNPS, RNDS);

--

FUNCTION WATER_GAS_INJECTOR
RETURN VARCHAR2;

PRAGMA RESTRICT_REFERENCES(WATER_GAS_INJECTOR, WNDS, WNPS, RNPS, RNDS);

--

FUNCTION WATER_INJECTOR
RETURN VARCHAR2;

PRAGMA RESTRICT_REFERENCES(WATER_INJECTOR, WNDS, WNPS, RNPS, RNDS);

--

END EcDp_Flowline_Type;