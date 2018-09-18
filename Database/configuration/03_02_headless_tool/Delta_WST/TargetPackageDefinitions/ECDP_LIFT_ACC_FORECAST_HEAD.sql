CREATE OR REPLACE PACKAGE EcDp_Lift_Acc_Forecast IS
/****************************************************************
** Package        :  EcDp_Lift_Acc_Forecast; head part
**
** $Revision: 1.5.4.1 $
**
** Purpose        :
**
** Documentation  :  www.energy-components.com
**
** Created        :  13.09.2006	Kari Sandvik
**
** Modification history:
**
** Date        Whom  Change description:
** ----------  ----- -------------------------------------------
** 01.07.2011  meisihil  Added new getTotalMonth function
** 08.03.2011  chooysie  ECPD-23418 added function to populate production_day and summer_time
*****************************************************************/

FUNCTION getForecastMonth(p_object_id VARCHAR2, p_daytime DATE, p_xtra_qty NUMBER DEFAULT 0) RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (getForecastMonth, WNDS, WNPS, RNPS);

FUNCTION getTotalMonth(p_object_id VARCHAR2, p_daytime DATE, p_xtra_qty NUMBER DEFAULT 0) RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (getTotalMonth, WNDS, WNPS, RNPS);

PROCEDURE aggregateSubDay(p_object_id VARCHAR2, p_daytime DATE, p_xtra_qty NUMBER DEFAULT 0);

PROCEDURE aggregateFcstSubDay(p_forecast_id VARCHAR2, p_object_id VARCHAR2, p_daytime DATE, p_xtra_qty NUMBER DEFAULT 0);

PROCEDURE populateSubDailyValueAdj(p_object_id VARCHAR2, p_daytime DATE, p_forecast_id VARCHAR2);

PROCEDURE populateSubDailyValueSinAdj(p_object_id VARCHAR2, p_daytime DATE, p_forecast_id VARCHAR2);

END EcDp_Lift_Acc_Forecast;