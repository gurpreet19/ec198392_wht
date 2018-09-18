CREATE OR REPLACE PACKAGE EcDp_Stor_Fcst_Forecast IS
/****************************************************************
** Package        :  EcDp_Stor_Fcst_Forecast; head part
**
** $Revision: 1.3 $
**
** Purpose        :
**
** Documentation  :  www.energy-components.com
**
** Created        :  04.06.2008	Kari Sandvik
**
** Modification history:
**
** Date        	Whom  		Change description:
** ----------  	----- 		-------------------------------------------
** 23.05.2013	muhammah	ECPD-23062:added PROCEDURE aiuStorPcForecast
** 28.12.2016 sharawan  ECPD-42222: Modified aiuStorPcForecast procedure to fix error when doing apportion and improve performance.
**                                  Copied from ecdp_storage_forecast.
*****************************************************************/

FUNCTION getPlannedMonthAverage(p_storage_id VARCHAR2, p_pc_id VARCHAR2, p_forecast_id VARCHAR2, p_first_of_year DATE) RETURN NUMBER;

FUNCTION getPlannedDayAverage(p_storage_id VARCHAR2, p_pc_id VARCHAR2, p_forecast_id VARCHAR2, p_first_of_month DATE) RETURN NUMBER;

FUNCTION getPlannedYear(p_storage_id VARCHAR2, p_pc_id VARCHAR2, p_forecast_id VARCHAR2, p_first_of_year DATE) RETURN NUMBER;

FUNCTION getPlannedMonth(p_storage_id VARCHAR2, p_pc_id VARCHAR2, p_forecast_id VARCHAR2, p_first_of_month DATE) RETURN NUMBER;

PROCEDURE apportionStorDay (p_date DATE, p_forecast_month NUMBER, p_storage_id VARCHAR2, p_forecast_id VARCHAR2);

PROCEDURE apportionStorPcMonth (p_date DATE, p_forecast_year NUMBER, p_storage_id VARCHAR2, p_pc_id VARCHAR2, p_forecast_id VARCHAR2);

PROCEDURE apportionStorPcDay (p_date DATE, p_forecast_month NUMBER, p_storage_id VARCHAR2, p_pc_id VARCHAR2, p_forecast_id VARCHAR2);

PROCEDURE aggrForecast(p_object_id VARCHAR2, p_forecast_id VARCHAR2, p_daytime DATE);

FUNCTION getStorPlannedDayAverage(p_storage_id VARCHAR2, p_forecast_id VARCHAR2, p_first_of_month DATE) RETURN NUMBER;

FUNCTION getStorPlannedMonth(p_storage_id VARCHAR2, p_forecast_id VARCHAR2, p_first_of_month DATE) RETURN NUMBER;

PROCEDURE aggregateSubDay(p_object_id VARCHAR2, p_forecast_id VARCHAR2, p_daytime DATE, p_xtra_qty NUMBER DEFAULT 0);

PROCEDURE aiuStorPcForecast (p_storage_id VARCHAR2, p_forecast_id VARCHAR2, p_pc_id VARCHAR2, p_daytime DATE, p_old_qty NUMBER,
                            p_new_qty NUMBER, p_user VARCHAR2 DEFAULT NULL, p_tablename VARCHAR2 DEFAULT NULL, p_versiontable VARCHAR2 DEFAULT NULL);

END EcDp_Stor_Fcst_Forecast;