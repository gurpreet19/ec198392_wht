CREATE OR REPLACE PACKAGE EcDp_Carrier_Fcst IS
/**************************************************************************************************
** Package  :  EcDp_Carrier_Fcst
**
** $Revision: 1.1.2.1 $
**
** Purpose  :  This package handles the carrier availability
**
** Created:     31.01.2013 hassakha
**
** Modification history:
**
** Date:        Whom:       Rev.  Change description:
** ----------  	-----       ----  ------------------------------------------------------------------------
**
**************************************************************************************************/
FUNCTION isUnavailable(p_carrier_id VARCHAR2, p_daytime DATE, p_forecast_id VARCHAR2) RETURN VARCHAR2;
FUNCTION getUnavailableReason(p_carrier_id VARCHAR2, p_daytime DATE, p_forecast_id VARCHAR2)RETURN VARCHAR2;
FUNCTION getNextAvailDate(p_carrier_id VARCHAR2, p_daytime DATE, p_forecast_id VARCHAR2)RETURN DATE;

END EcDp_Carrier_Fcst;