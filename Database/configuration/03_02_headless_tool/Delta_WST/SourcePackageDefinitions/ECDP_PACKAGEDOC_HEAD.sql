CREATE OR REPLACE PACKAGE EcDp_PackageDoc IS
/****************************************************************
** Package        :  EcDp_PackageDoc, header part
**
** $Revision: 1.1 $
**
** Purpose        :  Used for extraxting documentation from packages
**
** Documentation  :  www.energy-components.com
**
** Created  : 17.04.2001  Arild vervik
**
** Modification history:
**
** Version  Date     Whom  Change description:
** -------  ------   ----- --------------------------------------
*****************************************************************/

PROCEDURE ExtractPacageDocumentation(
    p_packagename VARCHAR2 DEFAULT NULL
);


END EcDp_PackageDoc;