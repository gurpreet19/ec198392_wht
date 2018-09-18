CREATE OR REPLACE PACKAGE EcDp_Contract_Nomination IS
/******************************************************************************
** Package        :  EcDp_Contract_Nomination, body part
**
** $Revision: 1.7 $
**
** Purpose        :  Find and work with nomination data
**
** Documentation  :  www.energy-components.com
**
** Created        :  13.12.2004 Tor-Erik Hauge
**
** Modification history:
**
** Date        Whom  Change description:
** ------      ----- -----------------------------------------------------------------------------------------------
** 22.12.2004  BIH   Initial version (first build / handover to test)
** 11.01.2005  BIH   Added / cleaned up documentation
** 25.04.2006  eikebeir    Added aggrSentSubDailyToDaily and aggrAdjSubDailyToDaily
** 15.05.2009  masamken    create new Procedures createDaysForPeriod / deleteHourlyData
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

FUNCTION getDailyNomination(
  p_contract_id   VARCHAR2,
  p_delivery_point_id   VARCHAR2,
  p_date                DATE
)
RETURN NUMBER;

PRAGMA RESTRICT_REFERENCES(getDailyNomination, WNDS, WNPS, RNPS);

--

FUNCTION getDailyContractNominatedQty(
  p_contract_id   VARCHAR2,
  p_date                DATE
)
RETURN NUMBER;

PRAGMA RESTRICT_REFERENCES(getDailyContractNominatedQty, WNDS, WNPS, RNPS);

--

FUNCTION getMonthlyContractNominatedQty(
  p_contract_id   VARCHAR2,
  p_date                DATE
)
RETURN NUMBER;

PRAGMA RESTRICT_REFERENCES(getMonthlyContractNominatedQty, WNDS, WNPS, RNPS);

--

FUNCTION getSubDailyNomination(
  	p_contract_id   	VARCHAR2,
  	p_delivery_point_id   	VARCHAR2,
  	p_daytime             	DATE
)
RETURN NUMBER;

PRAGMA RESTRICT_REFERENCES(getSubDailyNomination, WNDS, WNPS, RNPS);


--


PROCEDURE aggregateSubDailyToDaily(
	p_contract_id	VARCHAR2,
	p_delpt_id		VARCHAR2,
	p_daytime    	DATE,
	p_user			VARCHAR2
);


--

PROCEDURE aggrNomSubDailyToDaily(
	p_contract_id	VARCHAR2,
	p_delpt_id		VARCHAR2,
	p_daytime    	DATE,
	p_user         VARCHAR2 DEFAULT NULL

);

--

PROCEDURE aggrReqSubDailyToDaily(
	p_contract_id	VARCHAR2,
	p_delpt_id		VARCHAR2,
	p_daytime    	DATE,
	p_user         VARCHAR2 DEFAULT NULL

);

--

PROCEDURE aggrSentSubDailyToDaily(
	p_contract_id	VARCHAR2,
	p_delpt_id		VARCHAR2,
	p_daytime    	DATE,
	p_user         VARCHAR2 DEFAULT NULL

);


--

PROCEDURE aggrAdjSubDailyToDaily(
	p_contract_id	VARCHAR2,
	p_delpt_id		VARCHAR2,
	p_daytime    	DATE,
	p_user         VARCHAR2 DEFAULT NULL

);

--


PROCEDURE validateDailyNominationQty(
	p_contract_id	VARCHAR2,
	p_daytime    	DATE,
	p_qty          NUMBER
);

--

PROCEDURE createDaysForWeek(
	p_contract_id	VARCHAR2,
	p_delpt_id		VARCHAR2,
	p_daytime		DATE,
	p_curr_user 	VARCHAR2
);

--
PROCEDURE createDaysForPeriod(
   p_nav_model         VARCHAR2,
   p_nav_class_name    VARCHAR2,
   p_nav_object_id     VARCHAR2,
   p_delivery_point_id VARCHAR2 DEFAULT NULL,
   p_bfprofile         VARCHAR2,
   p_from_date         DATE,
   p_to_date           DATE,
   p_curr_user 	       VARCHAR2
);

--
PROCEDURE deleteHourlyData(
   p_object_id         VARCHAR2,
   p_delpt_id          VARCHAR2,
   p_production_day    DATE);
--

PROCEDURE createContractDayHours(
	p_contract_id	VARCHAR2,
	p_delpt_id     	VARCHAR2,
	p_daytime       DATE,
	p_curr_user		VARCHAR2
);


END EcDp_Contract_Nomination;