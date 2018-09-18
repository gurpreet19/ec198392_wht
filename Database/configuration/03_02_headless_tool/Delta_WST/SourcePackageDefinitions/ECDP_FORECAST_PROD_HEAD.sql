CREATE OR REPLACE PACKAGE EcDp_Forecast_Prod IS
/******************************************************************************
** Package        :  EcDp_Forecast_Prod, header part
**
** $Revision: 1.8 $
**
** Purpose        :  Data package for Forecasting
**
** Documentation  :  www.energy-components.com
**
** Created        :  13-07-2015 Suresh Kumar
**
** Modification history:
**
** Date        Whom  Change description:
** 29-07-15   kumarsur  ECPD-31234: Forecast
** 02-09-15   kumarsur  ECPD-31234: Added copyFcstFctyDay, copyFcstFctyMth and copyFcstObjectFluid.
** 28-03-16   kashisag  ECPD-33739 : Added procedure to update end date for child objects
** 11-04-16   abdulmaw  ECPD-34357: Added procedure copyScenarioToNewScenario to copy new scenario from an existing scenario
** 15-04-16   kumarsur  ECPD-33820: Added procedure copyActualsToScenario.
** 21-04-16   leongwen  ECPD-34357: Added procedure copyScenarioToScenario.
** 06-05-16   kumarsur  ECPD-33834: Added navForecastGroupFilter.
** 16-05-16   jainnraj  ECPD-35071: Added deleteForecast to delete forecast and all its dependent data.
** 20-05-16   jainnraj  ECPD-35072: Added deleteScenario to delete scenario and all its dependent data.
** 03-06-16   jainnraj  ECPD-34651: Added getForecastParentObjectId and setOfficialScenario and removed setOfficialForecast
** 06-07-16   jainnraj  ECPD-34651: Modified setDefaultOfficial to add a new column
** 15-07-16   kashisag  ECPD-36200: Added placeholder procedure runPlsqlCalculation for Forecast PLSQL calculation
** 12-10-16   kashisag  ECPD-34301: Added placeholder procedure for calculating analysis i.e. calculateanalysis
** 14-10-16   kashisag  ECPD-34301: Added procedure deleteComparison to delete Forecast defined Scenario Comparison records
** 26-10-16   kashisag  ECPD-34301: Added procedure to update end_date for comparison code
** 26-10-16   kashisag  ECPD-34301: Added procedure to update daytime for comparison code
********************************************************************/
TYPE t_forecast_id IS TABLE OF VARCHAR2(32);

PROCEDURE createForecast(p_from_forecast_id VARCHAR2,
						 p_period_type VARCHAR2,
						 p_forecast_type VARCHAR2,
						 p_comment VARCHAR2 DEFAULT NULL,
						 p_user VARCHAR2,
                         p_new_forecast_code VARCHAR2,
						 p_start_date DATE,
						 p_end_date DATE);

FUNCTION validatePeriodTypes(p_from_forecast_id VARCHAR2,
                             p_new_forecast_id VARCHAR2) RETURN INTEGER;

FUNCTION  getForecastParentObjectId(p_forecast_id VARCHAR2,
                                    p_group_type VARCHAR2,
                                    p_class_name VARCHAR2) RETURN VARCHAR2;

PROCEDURE demoteToUnofficial(p_scenario_id VARCHAR2);

PROCEDURE setOfficialScenario(p_group_type VARCHAR2,
                              p_forecast_id VARCHAR2,
                              p_scenario_id VARCHAR2,
                              p_start_date DATE,
                              p_end_date DATE);

PROCEDURE copyFcstStreamDay(p_from_forecast_id VARCHAR2,
                            p_new_forecast_id  VARCHAR2,
                            p_start_date       DATE,
                            p_end_date         DATE,
                            p_comment          VARCHAR2 DEFAULT NULL,
                            p_user             VARCHAR2);

PROCEDURE copyFcstStreamMth(p_from_forecast_id VARCHAR2,
                            p_new_forecast_id  VARCHAR2,
                            p_start_date       DATE,
                            p_end_date         DATE,
                            p_comment          VARCHAR2 DEFAULT NULL,
                            p_user             VARCHAR2);

PROCEDURE copyFcstPwelDay(p_from_forecast_id VARCHAR2,
                          p_new_forecast_id  VARCHAR2,
                          p_start_date       DATE,
                          p_end_date         DATE,
                          p_comment          VARCHAR2 DEFAULT NULL,
                          p_user             VARCHAR2);

PROCEDURE copyFcstPwelMth(p_from_forecast_id VARCHAR2,
                          p_new_forecast_id  VARCHAR2,
                          p_start_date       DATE,
                          p_end_date         DATE,
                          p_comment          VARCHAR2 DEFAULT NULL,
                          p_user             VARCHAR2);

PROCEDURE copyFcstIwelDay(p_from_forecast_id VARCHAR2,
                          p_new_forecast_id  VARCHAR2,
                          p_start_date       DATE,
                          p_end_date         DATE,
                          p_comment          VARCHAR2 DEFAULT NULL,
                          p_user             VARCHAR2);

PROCEDURE copyFcstIwelMth(p_from_forecast_id VARCHAR2,
                          p_new_forecast_id  VARCHAR2,
                          p_start_date       DATE,
                          p_end_date         DATE,
                          p_comment          VARCHAR2 DEFAULT NULL,
                          p_user             VARCHAR2);

PROCEDURE copyFcstStorageMth(p_from_forecast_id VARCHAR2,
                             p_new_forecast_id  VARCHAR2,
                             p_start_date       DATE,
                             p_end_date         DATE,
                             p_comment          VARCHAR2 DEFAULT NULL,
                             p_user             VARCHAR2);

PROCEDURE copyFcstStorageDay(p_from_forecast_id VARCHAR2,
                             p_new_forecast_id  VARCHAR2,
                             p_start_date       DATE,
                             p_end_date         DATE,
                             p_comment          VARCHAR2 DEFAULT NULL,
                             p_user             VARCHAR2);

PROCEDURE copyFcstFctyDay(p_from_forecast_id VARCHAR2,
                             p_new_forecast_id  VARCHAR2,
                             p_start_date       DATE,
                             p_end_date         DATE,
                             p_comment          VARCHAR2 DEFAULT NULL,
                             p_user             VARCHAR2);

PROCEDURE copyFcstFctyMth(p_from_forecast_id VARCHAR2,
                             p_new_forecast_id  VARCHAR2,
                             p_start_date       DATE,
                             p_end_date         DATE,
                             p_comment          VARCHAR2 DEFAULT NULL,
                             p_user             VARCHAR2);

PROCEDURE copyFcstObjectFluid(p_from_forecast_id VARCHAR2,
                             p_new_forecast_id  VARCHAR2,
                             p_start_date       DATE,
                             p_end_date         DATE,
                             p_comment          VARCHAR2 DEFAULT NULL,
                             p_user             VARCHAR2);

PROCEDURE  updateEndDateOnChildObjects(p_object_end_date DATE,
                                       p_object_id VARCHAR2);

PROCEDURE  copyScenarioToNewScenario(p_class_name      VARCHAR2,
                           p_src_scenario_id VARCHAR2,
                           p_daytime         DATE,
                           p_opt_start_date  DATE,
                           p_opt_end_date    DATE,
                           p_new_code        VARCHAR2,
                           p_new_name        VARCHAR2);

PROCEDURE copyActualsToScenario(
   p_dest_scenario_id 		VARCHAR2,
   p_opt_start_date      DATE,
   p_opt_end_date        DATE);

PROCEDURE copyScenarioToScenario(
   p_src_scenario_id    VARCHAR2,
   p_dest_scenario_id   VARCHAR2,
   p_opt_start_date     DATE,
   p_opt_end_date       DATE);

FUNCTION navForecastGroupFilter(
                p_group_type VARCHAR2,
                object_id_1 VARCHAR2,
				object_id_2 VARCHAR2 DEFAULT NULL,
				object_id_3 VARCHAR2 DEFAULT NULL,
				object_id_4 VARCHAR2 DEFAULT NULL,
				object_id_5 VARCHAR2 DEFAULT NULL,
				object_id_6 VARCHAR2 DEFAULT NULL)
RETURN t_forecast_id PIPELINED;

PROCEDURE  deleteForecast(p_forecast_id VARCHAR2
                          );

PROCEDURE  deleteScenario(p_scenario_id VARCHAR2
                          );

PROCEDURE  runScenarioCalc( p_forecast_id  VARCHAR2,
                            p_scenario_id VARCHAR2,
                            p_calculation_code VARCHAR2,
                            p_start_date DATE,
                            p_end_date DATE ,
                            p_user_id VARCHAR2    );

PROCEDURE  calculateAnalysis( p_comparison_id VARCHAR2 );


PROCEDURE  deleteComparison( p_object_id VARCHAR2);

PROCEDURE  updateEndDateComparison( p_object_end_date DATE,
                                    p_object_id VARCHAR2);

PROCEDURE  updateDaytimeComparison( p_object_start_date DATE,
                                       p_object_id VARCHAR2);

END EcDp_Forecast_Prod;
