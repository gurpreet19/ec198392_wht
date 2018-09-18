CREATE OR REPLACE PACKAGE EcDp_Flowline_Attribute IS

/****************************************************************
** Package        :  EcDp_Flowline_Attribute, header part
**
** $Revision: 1.1.1.1 $
**
** Purpose        :  Definition of flowline attributes
**
** Documentation  :  www.energy-components.com
**
** Created  : 17.01.2000  Carl-Fredrik Sørensen
**
** Modification history:
**
** Version  Date        Whom  Change description:
** -------  ------      ----- -----------------------------------
** 1.0      17.01.2000  CFS   Initial version
*****************************************************************/

--

FUNCTION CALC_METHOD
RETURN VARCHAR2;

PRAGMA RESTRICT_REFERENCES(CALC_METHOD, WNDS, WNPS, RNPS);

--

FUNCTION FLOWLINE_GOR
RETURN VARCHAR2;

PRAGMA RESTRICT_REFERENCES(FLOWLINE_GOR, WNDS, WNPS, RNPS);

--

FUNCTION FLOWLINE_TYPE
RETURN VARCHAR2;

PRAGMA RESTRICT_REFERENCES(FLOWLINE_TYPE, WNDS, WNPS, RNPS);

--

FUNCTION GAS_METHOD
RETURN VARCHAR2;

PRAGMA RESTRICT_REFERENCES(GAS_METHOD, WNDS, WNPS, RNPS);

--

END EcDp_Flowline_Attribute;