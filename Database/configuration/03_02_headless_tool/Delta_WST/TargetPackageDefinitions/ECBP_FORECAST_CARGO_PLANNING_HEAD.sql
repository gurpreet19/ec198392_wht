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
** 31/5/2010   lauuufus	ECPD-14514 Modify deleteForecastCascade
*************************************************************************/

PROCEDURE copyFromOriginal(p_new_forecast_code VARCHAR2, p_start_date DATE, p_end_date DATE, p_storage_id VARCHAR2 DEFAULT NULL);

PROCEDURE copyFromForecast(p_forecast_id VARCHAR2, p_new_forecast_code VARCHAR2, p_start_date DATE, p_end_date DATE, p_storage_id VARCHAR2 DEFAULT NULL);

PROCEDURE copyToOriginal(p_forecast_id VARCHAR2);

PROCEDURE deleteForecastCascade(p_forecast_id VARCHAR2, p_start_date DATE, p_end_date DATE);

END EcBp_Forecast_Cargo_Planning;