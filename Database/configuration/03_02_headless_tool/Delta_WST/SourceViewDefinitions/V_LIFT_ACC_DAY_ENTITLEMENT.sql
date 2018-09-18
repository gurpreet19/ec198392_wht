CREATE OR REPLACE FORCE EDITIONABLE VIEW "V_LIFT_ACC_DAY_ENTITLEMENT" ("OBJECT_ID", "DAYTIME", "LIFTING_ACCOUNT_ID", "LIFITNG_ACCOUNT_CODE", "CLOSING_BALANCE", "CLOSING_BALANCE2", "CLOSING_BALANCE3", "RECORD_STATUS", "CREATED_BY", "CREATED_DATE", "LAST_UPDATED_BY", "LAST_UPDATED_DATE", "REV_NO", "REV_TEXT") AS 
  (
----------------------------------------------------------------------------------------------------
-- File name: v_lift_acc_day_entitlement.sql
-- View name: v_lift_acc_day_entitlement
--
-- $Revision: 1.6 $
--
-- Purpose  :
--
-- Modification history:
--
-- Date       Whom  Change description:
-- ---------- ----  --------------------------------------------------------------------------------
-- 30.06.2006 zakiiari  Intial version
-- 07.07.2005 sandvkar	Fixed
-- 26.01.2011 leeeewei  Update where clause to not include lifting account which is a lifting agreement
-- 29.03.2017 sharawan  ECPD-39633: Update where clause to filter for lifting account that is end dated
-- 09.10.2017 sharawan  ECPD-49591: Add second and third Quantity for Closing Balance
----------------------------------------------------------------------------------------------------
SELECT
  la.storage_id object_id,
  fc.DAYTIME,
  la.object_id lifting_account_id,
  la.object_code lifitng_account_code,
  EcBp_Lift_Acc_Balance.calcEstClosingBalanceDay(la.object_id,fc.DAYTIME) CLOSING_BALANCE,
  EcBp_Lift_Acc_Balance.calcEstClosingBalanceDay(la.object_id,fc.DAYTIME,1) CLOSING_BALANCE2,
  EcBp_Lift_Acc_Balance.calcEstClosingBalanceDay(la.object_id,fc.DAYTIME,2) CLOSING_BALANCE3,
  'P' record_status,
  NULL created_by,
  TO_DATE(NULL) created_date,
  NULL last_updated_by,
  TO_DATE(NULL) last_updated_date,
  TO_NUMBER(NULL) rev_no,
  null rev_text
FROM
  LIFT_ACC_DAY_FORECAST fc,
  LIFTING_ACCOUNT la
WHERE
  fc.OBJECT_ID = la.object_id
  AND fc.daytime >= la.start_date and fc.daytime < nvl(la.end_date, fc.daytime + 1)
  AND NVL(la.lift_agreement_ind, 'N') = 'N'
GROUP BY la.storage_id,  fc.DAYTIME,  la.object_id, la.object_code
)