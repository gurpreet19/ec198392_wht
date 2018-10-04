CREATE OR REPLACE PACKAGE EcDp_Stor_Fcst_Balance IS
/****************************************************************
** Package        :  EcDp_Stor_Fcst_Balance; head part
**
** $Revision: 1.7 $
**
** Purpose        :
**
** Documentation  :  www.energy-components.com
**
** Created        :  10.06.2008	Kari Sandvik
**
** Modification history:
**
** Date        Whom  Change description:
** ----------  ----- -------------------------------------------
** 26.05.2015  sharawan     ECPD-19047: Added parameter p_ignore_cache to calcStorageLevel and calcStorageLevelSubDay
*****************************************************************/

FUNCTION calcStorageLevel(p_storage_id VARCHAR2, p_forecast_id VARCHAR2, p_daytime DATE, p_xtra_qty NUMBER DEFAULT 0, p_ignore_cache VARCHAR2 DEFAULT 'N') RETURN NUMBER;

FUNCTION getAccEstLiftedQtySubDay(p_lifting_account_id VARCHAR2, p_forecast_id VARCHAR2, p_startdate DATE, p_enddate DATE, p_xtra_qty NUMBER DEFAULT 0, p_incl_delta VARCHAR2 DEFAULT 'N', p_summer_time VARCHAR2 DEFAULT NULL) RETURN NUMBER;

FUNCTION calcStorageLevelSubDay(p_storage_id VARCHAR2, p_forecast_id VARCHAR2, p_daytime DATE, p_summer_time VARCHAR2, p_xtra_qty NUMBER DEFAULT 0, p_ignore_cache VARCHAR2 DEFAULT 'N') RETURN NUMBER;

FUNCTION getInitBalance(p_storage_id VARCHAR2, p_forecast_id VARCHAR2, p_xtra_qty NUMBER DEFAULT 0) RETURN NUMBER;

END EcDp_Stor_Fcst_Balance;