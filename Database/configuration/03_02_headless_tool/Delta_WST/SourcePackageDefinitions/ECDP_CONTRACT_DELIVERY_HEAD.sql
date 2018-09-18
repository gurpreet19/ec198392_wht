CREATE OR REPLACE PACKAGE EcDp_Contract_Delivery IS
/******************************************************************************
** Package        :  EcDp_Contract_Delivery, header part
**
** $Revision: 1.1 $
**
** Purpose        :  Find and work with delivery data
**
** Documentation  :  www.energy-components.com
**
** Created        :  13.12.2004 Tor Erik Hauge
**
** Modification history:
**
** Date        Whom  Change description:
** ------      ----- -----------------------------------------------------------------------------------------------
** 22.12.2004  BIH   Initial version (first build / handover to test)
** 11.01.2005  BIH   Added / cleaned up documentation
**
********************************************************************/

FUNCTION getNumberOfSubDailyRecords(
  p_contract_id   VARCHAR2,
  p_delivery_point_id   VARCHAR2,
  p_date                DATE
)
RETURN INTEGER;

--

FUNCTION getDailyDeliveredQty(
  p_contract_id   VARCHAR2,
  p_delivery_point_id   VARCHAR2,
  p_date                DATE
)
RETURN NUMBER;

--

FUNCTION differenceNominatedDelivered(
  p_object_id  VARCHAR2,
  p_delivery_point_id VARCHAR2,
  p_daytime            DATE,
  p_time_span 		VARCHAR2,
  p_user		VARCHAR2 DEFAULT NULL)

RETURN NUMBER;

--

FUNCTION getDailyContractDeliveredQty(
  p_contract_id   VARCHAR2,
  p_date                DATE
)
RETURN NUMBER;

--
FUNCTION aggregateVolQty(
  p_object_id  VARCHAR2,
  p_delivery_point_id VARCHAR2,
  p_daytime            DATE,
  p_user		VARCHAR2 DEFAULT NULL)
  RETURN NUMBER;

--

--
FUNCTION aggregateMassQty(
  p_object_id  VARCHAR2,
  p_delivery_point_id VARCHAR2,
  p_daytime            DATE,
  p_user		VARCHAR2 DEFAULT NULL)
  RETURN NUMBER;
--

--
FUNCTION aggregateEnergyQty(
  p_object_id  VARCHAR2,
  p_delivery_point_id VARCHAR2,
  p_daytime            DATE,
  p_user		VARCHAR2 DEFAULT NULL)
  RETURN NUMBER;
--

--
FUNCTION aggregateProfitCentreVolQty(
  p_object_id  VARCHAR2,
  p_delivery_point_id VARCHAR2,
  p_profit_centre_id VARCHAR2,
  p_daytime            DATE,
  p_user		VARCHAR2 DEFAULT NULL)
  RETURN NUMBER;

--

--
FUNCTION aggregateProfitCentreMassQty(
  p_object_id  VARCHAR2,
  p_delivery_point_id VARCHAR2,
  p_profit_centre_id VARCHAR2,
  p_daytime            DATE,
  p_user		VARCHAR2 DEFAULT NULL)
  RETURN NUMBER;
--

--
FUNCTION aggregateProfitCentreEnergyQty(
  p_object_id  VARCHAR2,
  p_delivery_point_id VARCHAR2,
  p_profit_centre_id VARCHAR2,
  p_daytime            DATE,
  p_user		VARCHAR2 DEFAULT NULL)
  RETURN NUMBER;
--

FUNCTION getMonthlyContractDeliveredQty(
  p_contract_id   VARCHAR2,
  p_date                DATE
)
RETURN NUMBER;

--

FUNCTION getYearlyContractDeliveredQty(
  p_contract_id   VARCHAR2,
  p_contract_year       DATE
)
RETURN NUMBER;

--

FUNCTION getSubDailyDeliveredQty(
  p_contract_id   VARCHAR2,
  p_delivery_point_id   VARCHAR2,
  p_daytime             DATE
)
RETURN NUMBER;

--

PROCEDURE aggregateSubDailyToDaily(
  	p_contract_id   	VARCHAR2,
  	p_delivery_point_id   	VARCHAR2,
  	p_daytime             	DATE,
	p_user					VARCHAR2
);

--

PROCEDURE createContractDayHours(
	p_contract_id	VARCHAR2,
	p_delpt_id     	VARCHAR2,
	p_daytime       DATE,
	p_curr_user		VARCHAR2,
  	p_accessLevel	INTEGER
);

--

FUNCTION getNumberOfApprovedDeliveries(
  p_contract_id  VARCHAR2,
  p_daytime            DATE
)
RETURN INTEGER;

FUNCTION getNominationPointId(p_contract_id VARCHAR2, p_delivery_point_id VARCHAR2, p_daytime DATE) RETURN VARCHAR2;

FUNCTION getDelviertPointByType(p_contract_id VARCHAR2, p_dp_type VARCHAR2, p_daytime DATE) RETURN VARCHAR2;

END EcDp_Contract_Delivery;