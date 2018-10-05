CREATE OR REPLACE FORCE VIEW "V_LIFT_ACC_DAY_ENTITLEMENT" ("OBJECT_ID", "DAYTIME", "LIFTING_ACCOUNT_ID", "LIFITNG_ACCOUNT_CODE", "CLOSING_BALANCE", "RECORD_STATUS", "CREATED_BY", "CREATED_DATE", "LAST_UPDATED_BY", "LAST_UPDATED_DATE", "REV_NO", "REV_TEXT") AS 
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
----------------------------------------------------------------------------------------------------
SELECT
  la.storage_id object_id,
  fc.DAYTIME,
  la.object_id lifting_account_id,
  la.object_code lifitng_account_code,
  EcBp_Lift_Acc_Balance.calcEstClosingBalanceDay(la.object_id,fc.DAYTIME) CLOSING_BALANCE,
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
AND
  NVL(la.lift_agreement_ind, 'N') = 'N'
GROUP BY la.storage_id,  fc.DAYTIME,  la.object_id, la.object_code
)