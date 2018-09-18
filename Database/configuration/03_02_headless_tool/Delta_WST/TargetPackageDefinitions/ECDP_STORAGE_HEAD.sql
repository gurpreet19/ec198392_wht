CREATE OR REPLACE PACKAGE EcDp_Storage IS

/****************************************************************
** Package        :  EcDp_Storage, header part
**
** $Revision: 1.1 $
**
** Purpose        :  Support functions for Storage class
**
** Documentation  :  www.energy-components.com
**
** Created  : 05.04.2005  Arild Vervik
**
** Modification history:
**
** Version  Date        Whom  Change description:
** -------  ----------  ----- --------------------------------------
*****************************************************************/

FUNCTION isTankRelated(p_storage_id STORAGE.OBJECT_ID%TYPE,
                       p_tank_object_id TANK.OBJECT_ID%TYPE)
RETURN VARCHAR2;

PRAGMA RESTRICT_REFERENCES (isTankRelated,WNDS, WNPS, RNPS);



END EcDp_Storage;