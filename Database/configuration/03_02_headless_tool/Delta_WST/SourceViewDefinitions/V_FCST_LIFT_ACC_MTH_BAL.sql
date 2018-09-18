CREATE OR REPLACE FORCE EDITIONABLE VIEW "V_FCST_LIFT_ACC_MTH_BAL" ("OBJECT_ID", "DAYTIME", "FORECAST_ID", "BALANCE_QTY", "RECORD_STATUS", "CREATED_BY", "CREATED_DATE", "LAST_UPDATED_BY", "LAST_UPDATED_DATE", "REV_NO", "REV_TEXT") AS 
  (
----------------------------------------------------------------------------------------------------
-- File name: v_fcst_lift_acc_mth_bal.sql
-- View name: v_fcst_lift_acc_mth_bal
--
-- $Revision: 1.1 $
--
-- Purpose  : The forecasted closing balance for the month for the lifting account
--
-- Modification history:
--
-- Date       Whom  Change description:
-- ---------- ----  --------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
SELECT  OBJECT_ID,
		DAYTIME,
		FORECAST_ID,
		EcBp_Lift_Acc_Fcst_Balance.calcEstClosingBalanceDay(object_id, forecast_id, LAST_DAY(daytime)) balance_qty,
		to_char(null) record_status,
		to_char(null) created_by,
		to_date(null) created_date,
		to_char(null) last_updated_by,
		to_date(null) last_updated_date,
		to_number(null) rev_no,
		to_char(null) rev_text
FROM 	lift_acc_day_fcst_fcast
WHERE	daytime = trunc(daytime, 'MM')
UNION
SELECT 	OBJECT_ID,
		trunc(daytime, 'MM') DAYTIME,
		forecast_id,
		EcBp_Lift_Acc_Fcst_Balance.calcEstClosingBalanceDay(object_id, forecast_id, LAST_DAY(daytime)) balance_qty,
		to_char(null) record_status,
		to_char(null) created_by,
		to_date(null) created_date,
		to_char(null) last_updated_by,
		to_date(null) last_updated_date,
		to_number(null) rev_no,
		to_char(null) rev_text
FROM 	lift_acc_day_fcst_fcast
WHERE 	daytime = ec_forecast.start_date(forecast_id)
AND 	ec_forecast.start_date(forecast_id) != trunc(ec_forecast.start_date(forecast_id), 'MM')
)