CREATE OR REPLACE FORCE VIEW "V_FCST_LIFT_ACC_DAY_ENT" ("OBJECT_ID", "DAYTIME", "FORECAST_ID", "LIFTING_ACCOUNT_ID", "LIFITNG_ACCOUNT_CODE", "CLOSING_BALANCE", "RECORD_STATUS", "CREATED_BY", "CREATED_DATE", "LAST_UPDATED_BY", "LAST_UPDATED_DATE", "REV_NO", "REV_TEXT") AS 
  (
----------------------------------------------------------------------------------------------------
-- File name: v_fcst_lift_acc_day_ent.sql
-- View name: v_fcst_lift_acc_day_ent
--
-- $Revision: 1.1 $
--
-- Purpose  :
--
-- Modification history:
--
-- Date       Whom  Change description:
-- ---------- ----  --------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
SELECT
  la.storage_id object_id,
  fc.DAYTIME,
  fc.forecast_id,
  la.object_id lifting_account_id,
  la.object_code lifitng_account_code,
  EcBp_Lift_Acc_Fcst_Balance.calcEstClosingBalanceDay(la.object_id,fc.forecast_id,fc.DAYTIME) CLOSING_BALANCE,
  'P' record_status,
  NULL created_by,
  TO_DATE(NULL) created_date,
  NULL last_updated_by,
  TO_DATE(NULL) last_updated_date,
  TO_NUMBER(NULL) rev_no,
  null rev_text
FROM
  lift_acc_day_fcst_fcast fc,
  LIFTING_ACCOUNT la
WHERE
  fc.OBJECT_ID = la.object_id
GROUP BY la.storage_id,  fc.forecast_id, fc.DAYTIME,  la.object_id, la.object_code
)