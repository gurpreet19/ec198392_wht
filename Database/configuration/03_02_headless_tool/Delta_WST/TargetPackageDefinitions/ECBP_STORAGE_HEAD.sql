CREATE OR REPLACE PACKAGE EcBp_Storage IS
/******************************************************************************
** Package        :  EcBp_Storage, header part
**
** $Revision: 1.4 $
**
** Purpose        :  Business logic for storages
**
** Documentation  :  www.energy-components.com
**
** Created  : 24.09.2004 Kari Sandvik
**
** Modification history:
**
** Version  Date     Whom  Change description:
** -------  ------   ----- -------------------------------------------
** #.#   DD.MM.YYYY  <initials>
** 1.3   07.04.2005  SHK   Added SafeLimit functions
********************************************************************/


FUNCTION getMaxVolLevel(p_storage_id VARCHAR2, p_daytime DATE) RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES(getMaxVolLevel, WNDS, WNPS, RNPS);

FUNCTION getMinVolLevel(p_storage_id VARCHAR2, p_daytime DATE) RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES(getMinVolLevel, WNDS, WNPS, RNPS);

FUNCTION getMinSafeLimitVolLevel(p_storage_id VARCHAR2, p_daytime DATE) RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES(getMinSafeLimitVolLevel, WNDS, WNPS, RNPS);

FUNCTION getMaxSafeLimitVolLevel(p_storage_id VARCHAR2, p_daytime DATE) RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES(getMaxSafeLimitVolLevel, WNDS, WNPS, RNPS);


END EcBp_Storage;