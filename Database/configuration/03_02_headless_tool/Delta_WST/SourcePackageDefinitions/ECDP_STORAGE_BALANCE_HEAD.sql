CREATE OR REPLACE PACKAGE EcDp_Storage_Balance IS
/****************************************************************
** Package        :  EcDp_Storage_Balance; head part
**
** $Revision: 1.13 $
**
** Purpose        :
**
** Documentation  :  www.energy-components.com
**
** Created        :  05.09.2006	Kari Sandvik
**
** Modification history:
**
** Date        Whom  Change description:
** ----------  ----- -------------------------------------------
** 26.05.2015  sharawan     ECPD-19047: Added parameter p_ignore_cache to calcStorageLevel and calcStorageLevelSubDay.
** 22.10.2018  prashwag     ECPD-59463: Added new function getStorageDip.
*****************************************************************/

FUNCTION getStorageDip(p_storage_id VARCHAR2, p_daytime DATE, p_condition VARCHAR2, p_group VARCHAR2, p_type VARCHAR) RETURN NUMBER;

FUNCTION getAccLiftedQtyMth(p_lifting_account_id VARCHAR2, p_daytime DATE, p_xtra_qty NUMBER DEFAULT 0) RETURN NUMBER;

FUNCTION getAccEstLiftedQtyMth(p_lifting_account_id VARCHAR2, p_daytime DATE, p_xtra_qty NUMBER DEFAULT 0, p_incl_delta VARCHAR2 DEFAULT 'N') RETURN NUMBER;

FUNCTION getAccEstLiftedQtyDay(p_lifting_account_id VARCHAR2, p_daytime DATE, p_xtra_qty NUMBER DEFAULT 0, p_incl_delta VARCHAR2 DEFAULT 'N') RETURN NUMBER;

FUNCTION getAccEstLiftedQtySubDay(p_lifting_account_id VARCHAR2, p_startdate DATE, p_enddate DATE, p_xtra_qty NUMBER DEFAULT 0, p_incl_delta VARCHAR2 DEFAULT 'N', p_summer_time VARCHAR2 DEFAULT NULL) RETURN NUMBER;

FUNCTION getLiftedQtyMth(p_object_id VARCHAR2, p_daytime DATE, p_xtra_qty NUMBER DEFAULT 0) RETURN NUMBER;

FUNCTION getEstLiftedQtyMth(p_object_id VARCHAR2, p_daytime DATE, p_xtra_qty NUMBER DEFAULT 0) RETURN NUMBER;

FUNCTION getEstLiftedQtyDay(p_object_id VARCHAR2, p_daytime DATE, p_xtra_qty NUMBER DEFAULT 0) RETURN NUMBER;

FUNCTION calcStorageLevel(p_storage_id VARCHAR2, p_daytime DATE, p_plan VARCHAR2 DEFAULT 'PO', p_xtra_qty NUMBER DEFAULT 0, p_ignore_cache VARCHAR2 DEFAULT 'N') RETURN NUMBER;

FUNCTION calcStorageLevelSubDay(p_storage_id VARCHAR2, p_daytime DATE, p_summer_time VARCHAR2, p_xtra_qty NUMBER DEFAULT 0, p_ignore_cache VARCHAR2 DEFAULT 'N') RETURN NUMBER;

FUNCTION getStorageLoadStatus(p_qty NUMBER, p_nom_date DATE, p_loadType VARCHAR2,p_cargo_status VARCHAR2) RETURN VARCHAR2;

FUNCTION getStorageLoadVerifStatusValue(p_qty NUMBER, p_nom_date DATE, p_loadType VARCHAR2, p_cargo_status VARCHAR2) RETURN VARCHAR2;

FUNCTION getStorageLoadVerifTextValue(p_qty NUMBER, p_nom_date DATE, p_loadType VARCHAR2, p_cargo_status VARCHAR2) RETURN VARCHAR2;

END EcDp_Storage_Balance;