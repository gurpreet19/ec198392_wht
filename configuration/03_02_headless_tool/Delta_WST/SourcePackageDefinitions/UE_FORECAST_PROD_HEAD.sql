CREATE OR REPLACE PACKAGE Ue_Forecast_Prod IS

/****************************************************************
** Package        :  Ue_Forecast_Prod, header part
**
** Modification history:
**
** Date        Whom        Change description:
** ------      --------    -----------------------------------------------------------------------------------------------
** 07-04-16    abdulmaw    Initial Version
** 15-04-16    kumarsur    ECPD-33820 : Added copyActualsToScenario.
** 21-04-16    leongwen    ECPD-34357 : Added copyScenarioToScenario.
** 16-05-16    jainnraj    ECPD-35071: Added deleteForecast to delete forecast.
** 20-05-16    jainnraj    ECPD-35072: Added deleteScenario to delete scenario.
** 03-06-16    jainnraj    ECPD-34651: Added setOfficialScenario.
** 06-07-16    jainnraj    ECPD-36978: Added demoteToUnofficial.
** 15-07-2016  kashisag    ECPD-36200: Forecast PL-SQL Calculation Changes, Added runPlsqlCalculation
** 12-10-16    kashisag    ECPD-34301: Added placeholder procedure for calculating analysis i.e. calculateanalysis
** 14-10-16    kashisag    ECPD-34301: Added procedure deleteComparison to delete Forecast defined Scenario Comparison records
*****************************************************************/


PROCEDURE copyScenarioToNewScenario(
   p_src_scenario_id     VARCHAR2,
   p_opt_start_date      DATE,
   p_opt_end_date        DATE,
   p_new_code            VARCHAR2,
   p_new_name            VARCHAR2);

PROCEDURE copyActualsToScenario(
   p_dest_scenario_id         VARCHAR2,
   p_opt_start_date      DATE,
   p_opt_end_date        DATE);

PROCEDURE copyScenarioToScenario(
   p_src_scenario_id    VARCHAR2,
   p_dest_scenario_id   VARCHAR2,
   p_opt_start_date     DATE,
   p_opt_end_date       DATE);

PROCEDURE deleteForecast(
   p_forecast_id    VARCHAR2,
   p_code_exist OUT VARCHAR2);

PROCEDURE deleteScenario(
   p_scenario_id    VARCHAR2,
   p_code_exist OUT VARCHAR2);

PROCEDURE setOfficialScenario(p_group_type VARCHAR2,
             p_forecast_id VARCHAR2,
             p_scenario_id VARCHAR2,
             p_start_date DATE,
             p_end_date DATE,
             p_code_exist OUT VARCHAR2);

PROCEDURE demoteToUnofficial(p_scenario_id VARCHAR2,
             p_code_exist OUT VARCHAR2);

PROCEDURE  runScenarioCalc( p_forecast_id  VARCHAR2,
                            p_scenario_id VARCHAR2,
                            p_calculation_code VARCHAR2,
                            p_start_date DATE,
                            p_end_date DATE ,
                            p_code_exist OUT VARCHAR2)   ;

PROCEDURE  calculateAnalysis( p_comparison_id     VARCHAR2,

							                p_code_exist      OUT VARCHAR2 );

PROCEDURE  deleteComparison( p_object_id VARCHAR2,
                             p_code_exist OUT VARCHAR2 );

END Ue_Forecast_Prod;