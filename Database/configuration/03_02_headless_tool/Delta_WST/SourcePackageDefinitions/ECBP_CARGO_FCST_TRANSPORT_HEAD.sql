CREATE OR REPLACE PACKAGE EcBp_Cargo_Fcst_Transport IS
/******************************************************************************
** Package        :  EcBp_Cargo_Fcst_Transport, header part
**
** $Revision: 1.8 $
**
** Purpose        :  Business logic for cargo transport
**
** Documentation  :  www.energy-components.com
**
** Created  : 04.06.2008 Kari Sandvik
**
** Modification history:
**
** Version  Date         Whom       Change description:
** -------  ------       	-----      -------------------------------------------
** 10.0     27-01-10     lauuufus Add p_forecast_id in getCarrierName
** 10.2     05-10-10     Leongwen ECPD-15638 Forecast - Generate Cargo does not copy Carrier
** 10.4     29-06-12     meisihil  ECPD-20651: Add getCarrierLaytime function.
**          11.02.2016   sharawan  ECPD-33109: Add new function getCargoNameByBerth for Berth Overview Chart
********************************************************************/

FUNCTION getLiftingAccount(p_cargo_no NUMBER, p_forecast_id VARCHAR2) RETURN VARCHAR2;

FUNCTION getStorages(p_cargo_no NUMBER, p_forecast_id VARCHAR2) RETURN VARCHAR2;

FUNCTION getCargoNo(p_cargo_name VARCHAR2, p_forecast_id VARCHAR2) RETURN NUMBER;

FUNCTION getFirstNomDate(p_cargo_no NUMBER, p_forecast_id VARCHAR2) RETURN DATE;

FUNCTION getLastNomDate(p_cargo_no NUMBER, p_forecast_id VARCHAR2) RETURN DATE;

PROCEDURE cleanLonesomeCargoes(p_forecast_id VARCHAR2);

PROCEDURE auCargoTransport(p_cargo_no NUMBER, p_old_cargo_status VARCHAR2, p_new_cargo_status VARCHAR2);

PROCEDURE connectNomToCargo(p_cargo_no NUMBER, p_parcels VARCHAR2, p_forecast_id VARCHAR2);

PROCEDURE copyBwdNominatedCarrier(p_cargo_no    NUMBER,
                                  p_carrier_id  VARCHAR2,
                                  p_forecast_id VARCHAR2,
                                  p_user        VARCHAR2 DEFAULT NULL);

FUNCTION getCarrierName(p_carrier_id VARCHAR2, p_cargo_no NUMBER, p_forecast_id VARCHAR2) RETURN VARCHAR2;

FUNCTION getCarrierLaytime(p_carrier_id VARCHAR2, p_cargo_no NUMBER, p_forecast_id VARCHAR2) RETURN VARCHAR2;

FUNCTION getCargoNameByBerth(p_forecast_id VARCHAR2, p_berth_id VARCHAR2, p_daytime DATE, p_product_group VARCHAR2) RETURN VARCHAR2;

END EcBp_Cargo_Fcst_Transport;