CREATE OR REPLACE PACKAGE EcDp_Separator_Attribute IS

/****************************************************************
** Package        :  EcDp_Separator_Attribute, header part
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
RETURN VARCHAR2;

PRAGMA RESTRICT_REFERENCES(LP, WNDS, WNPS, RNPS);

--

FUNCTION HP
RETURN VARCHAR2;

PRAGMA RESTRICT_REFERENCES(HP, WNDS, WNPS, RNPS);

--

FUNCTION LLP
RETURN VARCHAR2;

PRAGMA RESTRICT_REFERENCES(LLP, WNDS, WNPS, RNPS);

END EcDp_Separator_Attribute;