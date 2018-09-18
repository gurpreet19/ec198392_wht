CREATE OR REPLACE FORCE VIEW "V_FCST_STOR_MTH_BALANCE" ("OBJECT_ID", "DAYTIME", "FORECAST_ID", "BALANCE_QTY", "RECORD_STATUS", "CREATED_BY", "CREATED_DATE", "LAST_UPDATED_BY", "LAST_UPDATED_DATE", "REV_NO", "REV_TEXT") AS 
  (
----------------------------------------------------------------------------------------------------
-- File name: v_fcst_stor_mth_balance.sql
-- View name: v_fcst_stor_mth_balance
--
-- $Revision: 1.1 $
--
-- Purpose  : The closing balance for the month for the storage and forecast
--
-- Modification history:
--
-- Date       Whom  Change description:
-- ---------- ----  --------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
SELECT  OBJECT_ID,
		DAYTIME,
		forecast_id,
		ecdp_stor_fcst_balance.calcStorageLevel(object_id, forecast_id, LAST_DAY(daytime)) balance_qty,
		to_char(null) record_status,
		to_char(null) created_by,
		to_date(null) created_date,
		to_char(null) last_updated_by,
		to_date(null) last_updated_date,
		to_number(null) rev_no,
		to_char(null) rev_text
FROM 	STOR_DAY_FCST_FCAST
WHERE 	daytime = trunc(daytime, 'MM')
)