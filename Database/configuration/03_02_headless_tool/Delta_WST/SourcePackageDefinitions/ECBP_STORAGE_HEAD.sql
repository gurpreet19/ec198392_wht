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

FUNCTION getMinVolLevel(p_storage_id VARCHAR2, p_daytime DATE) RETURN NUMBER;

FUNCTION getMinSafeLimitVolLevel(p_storage_id VARCHAR2, p_daytime DATE) RETURN NUMBER;

FUNCTION getMaxSafeLimitVolLevel(p_storage_id VARCHAR2, p_daytime DATE) RETURN NUMBER;


END EcBp_Storage;