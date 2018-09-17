CREATE OR REPLACE PACKAGE EcDp_Storage_Forecast IS
/****************************************************************
** Package        :  EcDp_Storage_Forecast; head part
**
** $Revision: 1.4.24.1 $
**
** Purpose        :
**
** Documentation  :  www.energy-components.com
**
** Created        :  05.09.2006	Kari Sandvik
**
** Modification history:
**
** Date        Whom  Change description:
** ----------  ----- -------------------------------------------
** 06.11.2006  RAJARSAR  Added getStorPlannedDayAverage and getStorPlannedMonth
** 26.12.2013  leeeewei	ECPD-26371: Added additional planned values in getStorPlannedDayAverage and getStorPlannedMonth
*****************************************************************/

FUNCTION getPlannedMonthAverage(p_storage_id VARCHAR2, p_pc_id VARCHAR2, p_first_of_year DATE) RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (getPlannedMonthAverage, WNDS, WNPS, RNPS);

FUNCTION getPlannedDayAverage(p_storage_id VARCHAR2, p_pc_id VARCHAR2, p_first_of_month DATE) RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (getPlannedDayAverage, WNDS, WNPS, RNPS);

FUNCTION getPlannedYear(p_storage_id VARCHAR2, p_pc_id VARCHAR2, p_first_of_year DATE) RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (getPlannedYear, WNDS, WNPS, RNPS);

FUNCTION getPlannedMonth(p_storage_id VARCHAR2, p_pc_id VARCHAR2, p_first_of_month DATE) RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (getPlannedMonth, WNDS, WNPS, RNPS);

PROCEDURE apportionStorDay (p_date DATE, p_forecast_month NUMBER, p_storage_id VARCHAR2, p_plan VARCHAR2 DEFAULT 'PLAN', p_user VARCHAR2 DEFAULT NULL);

PROCEDURE apportionStorPcMonth (p_date DATE, p_forecast_year NUMBER, p_storage_id VARCHAR2, p_pc_id VARCHAR2, p_user VARCHAR2 DEFAULT NULL);

PROCEDURE apportionStorPcDay (p_date DATE, p_forecast_month NUMBER, p_storage_id VARCHAR2, p_pc_id VARCHAR2, p_plan VARCHAR2 DEFAULT 'PLAN', p_user VARCHAR2 DEFAULT NULL);

PROCEDURE aiuStorPcForecast(p_storage_id VARCHAR2, p_pc_id VARCHAR2, p_daytime DATE, p_old_qty NUMBER, p_new_qty NUMBER, p_user VARCHAR2 DEFAULT NULL);

PROCEDURE aggrForecast(p_object_id VARCHAR2, p_daytime DATE, p_user VARCHAR2 DEFAULT NULL);

FUNCTION getStorPlannedDayAverage(p_storage_id VARCHAR2,p_first_of_month DATE, p_plan VARCHAR2 DEFAULT 'PLAN') RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (getStorPlannedDayAverage, WNDS, WNPS, RNPS);

FUNCTION getStorPlannedMonth(p_storage_id VARCHAR2, p_first_of_month DATE, p_plan VARCHAR2 DEFAULT 'PLAN') RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (getStorPlannedMonth, WNDS, WNPS, RNPS);

PROCEDURE aggregateSubDay(p_object_id VARCHAR2, p_daytime DATE, p_xtra_qty NUMBER DEFAULT 0);

END EcDp_Storage_Forecast;