CREATE OR REPLACE PACKAGE EcBp_Forecast_Cargo_Planning IS
/****************************************************************
** Package        :  EcBp_Forecast_Cargo_Planning; head part
**
** $Revision: 1.2 $
**
** Purpose        :  Cargo Planning Forecast business logic
**
** Documentation  :  www.energy-components.com
**
** Created        :  06.06.2008 Kari Sandvik
**
** Modification history:
**
** Date        Whom  Change description:
** ----------  ----- -------------------------------------------
** 31/5/2010   lauuufus	 ECPD-14514 Modify deleteForecastCascade
** 15/01/2016  sharawan  ECPD-33109: added parameter for copyFromOriginal and copyFromForecast used in Forecast Manager screen
** 05/12/2016  asareswi  ECPD-34770: Added ValidateStorage procedure to validate the storage assign to forecasts in forecast manager.
** 14/06/2017  sharawan  ECPD-45674: Modified ValidateStorage to return info message if the storage are mismatch for comparison in Forecast Manager - Compare tab.
*************************************************************************/

PROCEDURE copyFromOriginal(p_new_forecast_code VARCHAR2
                           , p_start_date DATE
                           , p_end_date DATE
                           , p_storage_id VARCHAR2 DEFAULT NULL);

PROCEDURE copyFromForecast(p_forecast_id VARCHAR2
                           , p_new_forecast_code VARCHAR2
                           , p_start_date DATE
                           , p_end_date DATE
                           , p_storage_id VARCHAR2 DEFAULT NULL);

PROCEDURE copyToOriginal(p_forecast_id VARCHAR2);

PROCEDURE deleteForecastCascade(p_forecast_id VARCHAR2, p_start_date DATE, p_end_date DATE);

PROCEDURE ValidateStorage(p_forecast_storage VARCHAR2, p_compare_storage VARCHAR2);

END EcBp_Forecast_Cargo_Planning;