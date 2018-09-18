CREATE OR REPLACE PACKAGE ue_Contract_Delivery_Tracking IS
/****************************************************************
** Package        :  ue_Contract_Delivery_Tracking; head part
**
** $Revision: 1.1.2.4 $
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
** 15.01.2013	muhammah	ECPD-23097: Initial - created functions getPlannedQty, getPlannedPct, getACQToleranceLimit
** 25.01.2013   chooysie    ECPD-20101: Create functions for Contract Delivery Tracking screen: getYtd and getRemaining
** 18.12.2013   chooysie    ECPD-26349: Create functions for Forecast Contract Delivery Tracking screen: getFcstYtd and getFcstRemaining
** 23.12.2013	muhammah	ECPD-26389: Added new functions - getFcstPlannedQty, getFcstPlannedQty
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

END ue_Contract_Delivery_Tracking;