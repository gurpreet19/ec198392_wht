CREATE OR REPLACE PACKAGE EcDp_VPD IS
/****************************************************************
** Package        :  EcDp_VPD, header part
**
** $Revision: 1.4 $
**
** Purpose        :
**
** Documentation  :  www.energy-components.com
**
** Created  : 13-Mar-2007, Hanne Austad
**
** Modification history:
**
**  Date           Whom  Change description:
**  ------         ----- --------------------------------------
**  13-Mar-2007    HUS   Initial version
*****************************************************************/

PROCEDURE DropPolicies(p_class_name VARCHAR2);
PROCEDURE RefreshPolicies(p_class_name VARCHAR2);
PROCEDURE GenPackage(p_class_name VARCHAR2);
FUNCTION hasUserAccess(p_object_id VARCHAR2) RETURN VARCHAR2; -- Returns 'Y' if user has access and 'N' if not

END EcDp_VPD;