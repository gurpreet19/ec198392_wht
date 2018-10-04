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

PRAGMA RESTRICT_REFERENCES(getNumberOfSubDailyRecords, WNDS, WNPS, RNPS);

--

FUNCTION getDailyDeliveredQty(
  p_contract_id   VARCHAR2,
  p_delivery_point_id   VARCHAR2,
  p_date                DATE
)
RETURN NUMBER;

PRAGMA RESTRICT_REFERENCES(getDailyDeliveredQty, WNDS, WNPS, RNPS);

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

PRAGMA RESTRICT_REFERENCES(getDailyContractDeliveredQty, WNDS, WNPS, RNPS);

--
FUNCTION aggregateVolQty(
  p_object_id  VARCHAR2,
  p_delivery_point_id VARCHAR2,
  p_daytime            DATE,
  p_user		VARCHAR2 DEFAULT NULL)
  RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES(aggregateVolQty, WNDS, WNPS, RNPS);

--

--
FUNCTION aggregateMassQty(
  p_object_id  VARCHAR2,
  p_delivery_point_id VARCHAR2,
  p_daytime            DATE,
  p_user		VARCHAR2 DEFAULT NULL)
  RETURN NUMBER;

PRAGMA RESTRICT_REFERENCES(aggregateMassQty, WNDS, WNPS, RNPS);
--

--
FUNCTION aggregateEnergyQty(
  p_object_id  VARCHAR2,
  p_delivery_point_id VARCHAR2,
  p_daytime            DATE,
  p_user		VARCHAR2 DEFAULT NULL)
  RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES(aggregateEnergyQty, WNDS, WNPS, RNPS);
--

--
FUNCTION aggregateProfitCentreVolQty(
  p_object_id  VARCHAR2,
  p_delivery_point_id VARCHAR2,
  p_profit_centre_id VARCHAR2,
  p_daytime            DATE,
  p_user		VARCHAR2 DEFAULT NULL)
  RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES(aggregateProfitCentreVolQty, WNDS, WNPS, RNPS);

--

--
FUNCTION aggregateProfitCentreMassQty(
  p_object_id  VARCHAR2,
  p_delivery_point_id VARCHAR2,
  p_profit_centre_id VARCHAR2,
  p_daytime            DATE,
  p_user		VARCHAR2 DEFAULT NULL)
  RETURN NUMBER;

PRAGMA RESTRICT_REFERENCES(aggregateProfitCentreMassQty, WNDS, WNPS, RNPS);
--

--
FUNCTION aggregateProfitCentreEnergyQty(
  p_object_id  VARCHAR2,
  p_delivery_point_id VARCHAR2,
  p_profit_centre_id VARCHAR2,
  p_daytime            DATE,
  p_user		VARCHAR2 DEFAULT NULL)
  RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES(aggregateProfitCentreEnergyQty, WNDS, WNPS, RNPS);
--

FUNCTION getMonthlyContractDeliveredQty(
  p_contract_id   VARCHAR2,
  p_date                DATE
)
RETURN NUMBER;

PRAGMA RESTRICT_REFERENCES(getMonthlyContractDeliveredQty, WNDS, WNPS, RNPS);

--

FUNCTION getYearlyContractDeliveredQty(
  p_contract_id   VARCHAR2,
  p_contract_year       DATE
)
RETURN NUMBER;

PRAGMA RESTRICT_REFERENCES(getYearlyContractDeliveredQty, WNDS, WNPS, RNPS);

--

FUNCTION getSubDailyDeliveredQty(
  p_contract_id   VARCHAR2,
  p_delivery_point_id   VARCHAR2,
  p_daytime             DATE
)
RETURN NUMBER;

PRAGMA RESTRICT_REFERENCES(getSubDailyDeliveredQty, WNDS, WNPS, RNPS);

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

PRAGMA RESTRICT_REFERENCES(getNumberOfApprovedDeliveries, WNDS, WNPS, RNPS);

FUNCTION getNominationPointId(p_contract_id VARCHAR2, p_delivery_point_id VARCHAR2, p_daytime DATE) RETURN VARCHAR2;
PRAGMA RESTRICT_REFERENCES(getNominationPointId, WNDS, WNPS, RNPS);

FUNCTION getDelviertPointByType(p_contract_id VARCHAR2, p_dp_type VARCHAR2, p_daytime DATE) RETURN VARCHAR2;
PRAGMA RESTRICT_REFERENCES(getDelviertPointByType, WNDS, WNPS, RNPS);

END EcDp_Contract_Delivery;