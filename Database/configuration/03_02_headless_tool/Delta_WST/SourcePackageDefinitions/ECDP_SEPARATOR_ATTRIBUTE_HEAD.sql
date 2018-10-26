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
** Created  : 09.05.2000  Carl-Fredrik S�sen
**
** Modification history:
**
** Version  Date        Whom  Change description:
** -------  ------      ----- -----------------------------------
*****************************************************************/

--

FUNCTION LP
RETURN VARCHAR2;

--

FUNCTION HP
RETURN VARCHAR2;

--

FUNCTION LLP
RETURN VARCHAR2;

END EcDp_Separator_Attribute;