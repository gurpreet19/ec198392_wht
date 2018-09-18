CREATE OR REPLACE PACKAGE ue_Contract_Delivery_Tracking IS
/****************************************************************
** Package        :  ue_Contract_Delivery_Tracking; head part
**
** $Revision: 1.4 $
**
** Purpose        :
**
** Documentation  :  www.energy-components.com
**
** Created        :
**
** Modification history:
**
** Date        	Whom  		Change description:
** ---------- 	-------- 	-------------------------------------------
** 14.01.2013	muhammah	ECPD-20117: Initial - created functions getPlannedQty, getPlannedPct, getACQToleranceLimit
** 25.01.2013   chooysie    ECPD-20101: Create functions for Contract Delivery Tracking screen: getYtd and getRemaining
** 17.12.2013   chooysie    ECPD-26108: Create functions for Forecast Contract Delivery Tracking screen: getFcstYtd and getFcstRemaining
** 18.12.2013	muhammah	ECPD-26100: Added new functions - getFcstPlannedQty, getFcstPlannedQty
** 25.05.2015	farhaann	ECPD-30572: Added new function, getPlannedLiftVol
** 11.01.2016	asareswi	ECPD-33109: Added new function getFcstPlannedCargos, getPlannedCargos : Count the planned no of cargoes for a contract in a forecast
** 11.01.2016	asareswi	ECPD-33109: Added new function getFcstPlannedProdQty, getPlannedProdQty : To calculate the planned production qty based on the selected storage.
**************************************************************************************************/

FUNCTION getPlannedQty (p_contract_id VARCHAR2, p_daytime DATE, p_xtra_qty NUMBER DEFAULT 0) RETURN NUMBER;

FUNCTION getPlannedPct (p_contract_id VARCHAR2,	p_daytime DATE, p_xtra_qty NUMBER DEFAULT 0) RETURN NUMBER;

FUNCTION getACQToleranceLimit(p_plannedPct NUMBER, p_tolPct NUMBER) RETURN VARCHAR2;

FUNCTION getYtd (p_contract_id VARCHAR2,	p_daytime DATE, p_xtra_qty NUMBER DEFAULT 0) RETURN NUMBER;

FUNCTION getRemaining (p_contract_id VARCHAR2,	p_daytime DATE, p_xtra_qty NUMBER DEFAULT 0) RETURN NUMBER;

FUNCTION getFcstYtd (p_contract_id VARCHAR2,	p_forecast_id VARCHAR2,	p_daytime DATE, p_xtra_qty NUMBER DEFAULT 0) RETURN NUMBER;

FUNCTION getFcstRemaining (p_contract_id VARCHAR2, p_forecast_id VARCHAR2, p_daytime DATE, p_xtra_qty NUMBER DEFAULT 0) RETURN NUMBER;

FUNCTION getFcstPlannedQty (p_forecast_id VARCHAR2, p_contract_id VARCHAR2, p_daytime DATE, p_xtra_qty NUMBER DEFAULT 0) RETURN NUMBER;

FUNCTION getFcstPlannedPct (p_forecast_id VARCHAR2, p_contract_id VARCHAR2,	p_daytime DATE, p_xtra_qty NUMBER DEFAULT 0) RETURN NUMBER;

FUNCTION getPlannedLiftVol (p_daytime DATE, p_lifting_account_id VARCHAR2, p_profit_centre_id VARCHAR2, p_storage_id VARCHAR2) RETURN NUMBER;

FUNCTION getFcstPlannedCargos (p_forecast_id VARCHAR2, p_contract_id VARCHAR2, p_daytime DATE ) RETURN NUMBER;

FUNCTION getPlannedCargos (p_contract_id VARCHAR2, p_daytime DATE, p_to_date DATE DEFAULT NULL) RETURN NUMBER;

FUNCTION getFcstPlannedProdQty (p_forecast_id VARCHAR2, p_storage_id VARCHAR2, p_daytime DATE ) RETURN NUMBER;

FUNCTION getPlannedProdQty (p_storage_id VARCHAR2, p_daytime DATE, p_to_date DATE DEFAULT NULL) RETURN NUMBER;

END ue_Contract_Delivery_Tracking;