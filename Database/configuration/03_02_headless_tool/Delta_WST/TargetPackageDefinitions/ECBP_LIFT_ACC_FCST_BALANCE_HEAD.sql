CREATE OR REPLACE PACKAGE EcBp_Lift_Acc_Fcst_Balance IS
/****************************************************************
** Package        :  EcBp_Lift_Acc_Fcst_Balance; head part
**
** $Revision: 1.3.24.3 $
**
** Purpose        :
**
** Documentation  :  www.energy-components.com
**
** Created        :  12.06.2008	Kari Sandvik
**
** Modification history:
**
** Date        Whom  Change description:
** ----------  ----- -------------------------------------------
** 29.05.2012  meisihil Added new function getInitBalance
*****************************************************************/

FUNCTION getAdjustments(p_object_id VARCHAR2, p_forecast_id VARCHAR2,p_from_date DATE,p_to_date DATE,p_xtra_qty  NUMBER DEFAULT 0) RETURN NUMBER;
FUNCTION getAdjustmentsSubDay(p_object_id VARCHAR2, p_forecast_id VARCHAR2,p_from_date DATE,p_to_date DATE,p_xtra_qty  NUMBER DEFAULT 0) RETURN NUMBER;
FUNCTION calcEstClosingBalanceDay(p_object_id	VARCHAR2, p_forecast_id VARCHAR2, p_daytime	DATE, p_xtra_qty NUMBER DEFAULT 0) RETURN NUMBER;
FUNCTION calcEstClosingBalanceSubDay(p_object_id VARCHAR2, p_forecast_id VARCHAR2, p_daytime	DATE, p_summer_time VARCHAR2, p_xtra_qty NUMBER DEFAULT 0) RETURN NUMBER;
FUNCTION getInitBalance(p_object_id VARCHAR2, p_forecast_id VARCHAR2, p_xtra_qty NUMBER DEFAULT 0) RETURN NUMBER;

END EcBp_Lift_Acc_Fcst_Balance;