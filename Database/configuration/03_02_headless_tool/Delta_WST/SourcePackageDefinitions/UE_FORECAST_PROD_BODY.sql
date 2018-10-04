CREATE OR REPLACE PACKAGE BODY Ue_Forecast_Prod IS
/****************************************************************
** Package        :  Ue_Forecast_Prod, body part
**
** This package is used to program potential calculation when a predefined method supplied by EC does not cover the requirements.
** Upgrade processes will never replace this package.
**
** Modification history:
**
** Date        Whom        Change description:
** ------      --------    -----------------------------------------------------------------------------------------------
** 07-04-16    abdulmaw    Initial Version
** 15-04-16    kumarsur    ECPD-33820 : Added copyActualsToScenario.
** 21-04-16    leongwen    ECPD-34357 : Added copyScenarioToScenario.
** 16-05-16    jainnraj    ECPD-35071: Added deleteForecast.
** 20-05-16    jainnraj    ECPD-35072: Added deleteScenario.
** 03-06-16    jainnraj    ECPD-34651: Added setOfficialScenario.
** 06-07-16    jainnraj    ECPD-36978: Added demoteToUnofficial.
** 15-07-2016  kashisag    ECPD-36200: Forecast PL-SQL Calculation Changes, Added runScenarioCalc
** 12-10-16    kashisag    ECPD-34301: Added placeholder procedure for calculating analysis i.e. calculateanalysis
** 14-10-16    kashisag    ECPD-34301: Added procedure deleteComparison to delete Forecast defined Scenario Comparison records
*****************************************************************/

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : copyNewScenario
-- Description    : To copy existing scenario to create new senario.
---------------------------------------------------------------------------------------------------
PROCEDURE copyScenarioToNewScenario(
   p_src_scenario_id     VARCHAR2,
   p_opt_start_date      DATE,
   p_opt_end_date        DATE,
   p_new_code            VARCHAR2,
   p_new_name            VARCHAR2)
--</EC-DOC>
IS

BEGIN

	NULL;

END copyScenarioToNewScenario;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : copyActualsToScenario
-- Description    : To copy actual data into a scenario.
---------------------------------------------------------------------------------------------------
PROCEDURE copyActualsToScenario(
   p_dest_scenario_id 		VARCHAR2,
   p_opt_start_date      DATE,
   p_opt_end_date        DATE)
--</EC-DOC>
IS

BEGIN

	NULL;

END copyActualsToScenario;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : copyScenarioToScenario
-- Description    : Copy scenario data.
---------------------------------------------------------------------------------------------------
PROCEDURE copyScenarioToScenario(
   p_src_scenario_id    VARCHAR2,
   p_dest_scenario_id   VARCHAR2,
   p_opt_start_date     DATE,
   p_opt_end_date       DATE)
--</EC-DOC>
IS

BEGIN

  NULL;

END copyScenarioToScenario;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : deleteForecast
-- Description    : Delete all forecast data
---------------------------------------------------------------------------------------------------
PROCEDURE deleteForecast(
   p_forecast_id    VARCHAR2,
   p_code_exist OUT VARCHAR2)
--</EC-DOC>
IS

BEGIN

  p_code_exist := 'N';

END deleteForecast;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : deleteScenario
-- Description    : Delete all scenario data
---------------------------------------------------------------------------------------------------
PROCEDURE deleteScenario(
   p_scenario_id    VARCHAR2,
   p_code_exist OUT VARCHAR2)
--</EC-DOC>
IS

BEGIN

  p_code_exist := 'N';

END deleteScenario;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : setOfficialScenario
-- Description    : To set a scenario official
---------------------------------------------------------------------------------------------------
PROCEDURE setOfficialScenario(p_group_type VARCHAR2,
             p_forecast_id VARCHAR2,
             p_scenario_id VARCHAR2,
             p_start_date DATE,
             p_end_date DATE,
             p_code_exist OUT VARCHAR2)
 --</EC-DOC>
IS

BEGIN
  p_code_exist := 'N';

END setOfficialScenario;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : demoteToUnofficial
-- Description    : To set a scenario to unofficial
---------------------------------------------------------------------------------------------------
PROCEDURE demoteToUnofficial(p_scenario_id VARCHAR2,
             p_code_exist OUT VARCHAR2)
 --</EC-DOC>
IS

BEGIN
  p_code_exist := 'N';

END demoteToUnofficial;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : runPlsqlCalculation
-- Description    : To execute plsql calculation
---------------------------------------------------------------------------------------------------
PROCEDURE  runScenarioCalc( p_forecast_id  VARCHAR2,
                            p_scenario_id VARCHAR2,
                            p_calculation_code VARCHAR2,
                            p_start_date DATE,
                            p_end_date DATE,
                            p_code_exist OUT VARCHAR2)
--</EC-DOC>
IS

BEGIN
  p_code_exist := 'N';

END runScenarioCalc;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : calculateAnalysis
-- Description    : To execute analysis calculation
---------------------------------------------------------------------------------------------------
PROCEDURE  calculateAnalysis( p_comparison_id     VARCHAR2,

							                p_code_exist      OUT VARCHAR2 )
--</EC-DOC>
IS

BEGIN

  p_code_exist := 'N';

END calculateAnalysis;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : deleteComparison
-- Description    : To delete comparison records
---------------------------------------------------------------------------------------------------
PROCEDURE  deleteComparison( p_object_id VARCHAR2,
                             p_code_exist OUT VARCHAR2  )
--</EC-DOC>
IS

BEGIN

  p_code_exist := 'N';

END deleteComparison;

END Ue_Forecast_Prod;