CREATE OR REPLACE PACKAGE EcDp_Forecast IS
/******************************************************************************
** Package        :  EcDp_Forecast, header part
**
** $Revision: 1.8 $
**
** Purpose        :  Data package for Forecasting
**
** Documentation  :  www.energy-components.com
**
** Created  : 20.04.2006 Atle Weibell
**
** Modification history:
**
** Date     Whom  Change description:
** ------   ----- -------------------------------------------
** 09.05.2006  awe   1.1   Added function validatePeriodTypes
**									Added procedures generateComp, deleteComp
**									Added procedures copyForecast, copyForecastInput, copyForecastAnalysis
** 10.05.2006  awe   1.2   Added procedure copyForecastResult
**
********************************************************************/

PROCEDURE createForecast(p_from_forecast_id VARCHAR2,
                         p_copy_type VARCHAR2,
						 p_period_type VARCHAR2,
						 p_forecast_type VARCHAR2,
						 p_comment VARCHAR2 DEFAULT NULL,
						 p_user VARCHAR2,
                         p_new_forecast_code VARCHAR2,
						 p_start_date DATE,
						 p_end_date DATE);

PROCEDURE generateComp(p_object_id 			VARCHAR2,
								p_daytime				DATE,
								p_forecast_id				VARCHAR2,
								p_series					VARCHAR2);

PROCEDURE deleteComp(p_analysis_no NUMBER);

FUNCTION validatePeriodTypes(p_from_forecast_id VARCHAR2,
                             p_new_forecast_id VARCHAR2) RETURN INTEGER;

PROCEDURE copyForecastAnalysis(p_from_forecast_id VARCHAR2,
                               p_new_forecast_id   VARCHAR2,
                               p_copy_type      VARCHAR2,
										 p_comment		VARCHAR2 DEFAULT NULL,
										 p_user				VARCHAR2);

PROCEDURE copyForecastInput(p_from_forecast_id VARCHAR2,
                            p_new_forecast_id   VARCHAR2,
                            p_copy_type      VARCHAR2,
									 p_comment			VARCHAR2 DEFAULT NULL,
									 p_user				VARCHAR2);

PROCEDURE copyForecastResult(p_from_forecast_id VARCHAR2,
									p_new_forecast_id VARCHAR2,
									p_copy_type VARCHAR2,
									p_comment			VARCHAR2 DEFAULT NULL,
									p_user				VARCHAR2);

PROCEDURE copyForecast(p_from_forecast_id VARCHAR2,
                       p_new_forecast_id VARCHAR2,
					   p_copy_type VARCHAR2,
					   p_comment VARCHAR2 DEFAULT NULL,
					   p_user VARCHAR2);


END EcDp_Forecast;
