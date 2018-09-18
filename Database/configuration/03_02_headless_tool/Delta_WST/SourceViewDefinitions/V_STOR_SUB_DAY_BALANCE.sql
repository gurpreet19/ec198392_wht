CREATE OR REPLACE FORCE EDITIONABLE VIEW "V_STOR_SUB_DAY_BALANCE" ("OBJECT_ID", "DAYTIME", "SUMMER_TIME", "PRODUCTION_DAY", "STOR_SCHED_PLAN", "STORAGE_LEVEL", "STORAGE_LEVEL2", "STORAGE_LEVEL3", "RECORD_STATUS", "CREATED_BY", "CREATED_DATE", "LAST_UPDATED_BY", "LAST_UPDATED_DATE", "REV_NO", "REV_TEXT") AS 
  (
----------------------------------------------------------------------------------------------------
-- File name: v_stor_sub_day_balance.sql
-- View name: v_stor_sub_day_balance
--
-- $Revision: 1.3 $
--
-- Purpose  : The closing balance for each sub daily for the storage
--
-- Modification history:
--
-- Date       Whom  Change description:
-- ---------- ----  --------------------------------------------------------------------------------
-- 10.03.2017 sharawan     ECPD-43320: New BF - CP.0072: Schedule Lifting Overview
----------------------------------------------------------------------------------------------------
SELECT OBJECT_ID,
       DAYTIME,
       SUMMER_TIME,
       PRODUCTION_DAY,
       p.CODE STOR_SCHED_PLAN,
       EcDp_Storage_Balance.calcStorageLevelSubDay(object_id, daytime, SUMMER_TIME) AS STORAGE_LEVEL,
       EcDp_Storage_Balance.calcStorageLevelSubDay(object_id, daytime, SUMMER_TIME, 1) AS STORAGE_LEVEL2,
       EcDp_Storage_Balance.calcStorageLevelSubDay(object_id, daytime, SUMMER_TIME, 2) AS STORAGE_LEVEL3,
       to_char(null) record_status,
       to_char(null) created_by,
       to_date(null) created_date,
       to_char(null) last_updated_by,
       to_date(null) last_updated_date,
       to_number(null) rev_no,
       to_char(null) rev_text
  FROM STOR_SUB_DAY_FORECAST, prosty_codes p
 where p.code_type = 'STOR_SCHED_PLAN'
 and nvl(p.is_active, 'N') = 'Y'
)