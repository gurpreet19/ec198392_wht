CREATE OR REPLACE PACKAGE EcDp_Contract_Forecast IS
/****************************************************************
** Package        :  EcDp_Contract_Forecast
**
** $Revision: 1.3 $
**
** Purpose        :  Find, generate and aggregate sale forecast data.
**
** Documentation  :  www.energy-components.com
**
** Created        :  16.12.2004  Tor-Erik Hauge
**
** Modification history:
**
** Date        Whom  Change description:
** ------      ----- -----------------------------------------------------------------------------------------------
** 22.12.2004  BIH   Initial version (first build / handover to test)
** 11.01.2005  BIH   Added / cleaned up documentation
** 07.11.2006  RAJARSAR Added aggregateDailyToMonthly Procedure and aggregateForecastVolQty Function
** 13.05.2009  MASAMKEN ECPD:11561 - Create two new functions createDaysForPeriod and deleteHourlyData.
******************************************************************/

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

--

FUNCTION getNumberOfSubDailyRecords(
	p_contract_id  	VARCHAR2,
	p_delpt_id  	VARCHAR2,
	p_daytime		DATE
)
RETURN NUMBER;

PRAGMA RESTRICT_REFERENCES(getNumberOfSubDailyRecords, WNDS, WNPS, RNPS);

--

FUNCTION getDailyForecast(
	p_contract_id  	VARCHAR2,
	p_delpt_id		VARCHAR2,
	p_daytime  		DATE
)
RETURN NUMBER;

PRAGMA RESTRICT_REFERENCES(getDailyForecast, WNDS, WNPS, RNPS);

--

FUNCTION getSubDailyForecast(
	p_contract_id	VARCHAR2,
	p_delpt_id	  	VARCHAR2,
	p_daytime  		DATE,
	p_summer_time	VARCHAR2
)
RETURN NUMBER;

PRAGMA RESTRICT_REFERENCES(getSubDailyForecast, WNDS, WNPS, RNPS);

--

PROCEDURE aggregateSubDailyToDaily(
  p_contract_id	VARCHAR2,
  p_delpt_id	VARCHAR2,
  p_daytime    	DATE,
  p_user		VARCHAR2
);

PROCEDURE aggregateDailyToMonthly(
  p_contract_id	VARCHAR2,
  p_delpt_id	VARCHAR2,
  p_daytime    	DATE,
  p_user		VARCHAR2
);

FUNCTION aggregateForecastVolQty(
  p_object_id  VARCHAR2,
  p_delivery_point_id VARCHAR2,
  p_daytime            DATE,
  p_user		VARCHAR2 DEFAULT NULL
)
RETURN NUMBER;




END EcDp_Contract_Forecast;