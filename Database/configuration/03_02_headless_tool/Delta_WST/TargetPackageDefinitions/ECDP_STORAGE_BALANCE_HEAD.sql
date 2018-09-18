CREATE OR REPLACE PACKAGE EcDp_Storage_Balance IS
/****************************************************************
** Package        :  EcDp_Storage_Balance; head part
**
** $Revision: 1.11.4.2 $
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
*****************************************************************/

FUNCTION getAccLiftedQtyMth(p_lifting_account_id VARCHAR2, p_daytime DATE, p_xtra_qty NUMBER DEFAULT 0) RETURN NUMBER;
--PRAGMA RESTRICT_REFERENCES (getAccLiftedQtyMth, WNDS, WNPS, RNPS);

FUNCTION getAccEstLiftedQtyMth(p_lifting_account_id VARCHAR2, p_daytime DATE, p_xtra_qty NUMBER DEFAULT 0, p_incl_delta VARCHAR2 DEFAULT 'N') RETURN NUMBER;
--PRAGMA RESTRICT_REFERENCES (getAccEstLiftedQtyMth, WNDS, WNPS, RNPS);

FUNCTION getAccEstLiftedQtyDay(p_lifting_account_id VARCHAR2, p_daytime DATE, p_xtra_qty NUMBER DEFAULT 0, p_incl_delta VARCHAR2 DEFAULT 'N') RETURN NUMBER;
--PRAGMA RESTRICT_REFERENCES (getAccEstLiftedQtyDay, WNDS, WNPS, RNPS);

FUNCTION getAccEstLiftedQtySubDay(p_lifting_account_id VARCHAR2, p_startdate DATE, p_enddate DATE, p_xtra_qty NUMBER DEFAULT 0, p_incl_delta VARCHAR2 DEFAULT 'N', p_summer_time VARCHAR2 DEFAULT NULL) RETURN NUMBER;
--PRAGMA RESTRICT_REFERENCES (getAccEstLiftedQtySubDay, WNDS, WNPS, RNPS);

FUNCTION getLiftedQtyMth(p_object_id VARCHAR2, p_daytime DATE, p_xtra_qty NUMBER DEFAULT 0) RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (getLiftedQtyMth, WNDS, WNPS, RNPS);

FUNCTION getEstLiftedQtyMth(p_object_id VARCHAR2, p_daytime DATE, p_xtra_qty NUMBER DEFAULT 0) RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (getEstLiftedQtyMth, WNDS, WNPS, RNPS);

FUNCTION getEstLiftedQtyDay(p_object_id VARCHAR2, p_daytime DATE, p_xtra_qty NUMBER DEFAULT 0) RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (getEstLiftedQtyDay, WNDS, WNPS, RNPS);

FUNCTION calcStorageLevel(p_storage_id VARCHAR2, p_daytime DATE, p_plan VARCHAR2 DEFAULT 'PO', p_xtra_qty NUMBER DEFAULT 0) RETURN NUMBER;

FUNCTION calcStorageLevelSubDay(p_storage_id VARCHAR2, p_daytime DATE, p_summer_time VARCHAR2, p_xtra_qty NUMBER DEFAULT 0) RETURN NUMBER;

FUNCTION getStorageLoadStatus(p_qty NUMBER, p_nom_date DATE, p_loadType VARCHAR2,p_cargo_status VARCHAR2) RETURN VARCHAR2;
PRAGMA RESTRICT_REFERENCES (getStorageLoadStatus, WNDS, WNPS, RNPS);

END EcDp_Storage_Balance;