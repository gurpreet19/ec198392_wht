CREATE OR REPLACE PACKAGE EcDp_Carrier_Fcst IS
/**************************************************************************************************
** Package  :  EcDp_Carrier_Fcst
**
** $Revision: 1.1 $
**
** Purpose  :  This package handles the carrier availability
**
** Created:     31.01.2013 hassakha
**
** Modification history:
**
** Date:        Whom:       Rev.  Change description:
** ----------  	-----       ----  ------------------------------------------------------------------------
** 17.10.2017   sharawan          ECPD-49488: Added function getRouteDays for the Carrier Utilization Chart in Forecast Manager.
**************************************************************************************************/
  FUNCTION isUnavailable(p_carrier_id VARCHAR2, p_daytime DATE, p_forecast_id VARCHAR2) RETURN VARCHAR2;
  FUNCTION getUnavailableReason(p_carrier_id VARCHAR2, p_daytime DATE, p_forecast_id VARCHAR2) RETURN VARCHAR2;
  FUNCTION getNextAvailDate(p_carrier_id VARCHAR2, p_daytime DATE, p_forecast_id VARCHAR2) RETURN DATE;
  FUNCTION getRouteDays(p_carrier_id VARCHAR2, p_daytime DATE, p_storage_id VARCHAR2, p_port_id VARCHAR2) RETURN NUMBER;
  FUNCTION get_carrier_id(p_carrier_name varchar2) RETURN VARCHAR2;
END EcDp_Carrier_Fcst;