CREATE OR REPLACE FORCE EDITIONABLE VIEW "V_FCTY_DASHBRD_IWEL_STATUS" ("OBJECT_ID", "TOTAL", "DAYTIME", "WELL_TYPE", "ACTIVE_STATUS", "RECORD_STATUS", "CREATED_BY", "CREATED_DATE", "LAST_UPDATED_BY", "LAST_UPDATED_DATE", "REV_NO", "REV_TEXT") AS 
  (
----------------------------------------------------------------------------------------------------
-- File name: v_fcty_dashbrd_iwel_status.sql
-- View name:V_FCTY_DASHBRD_IWEL_STATUS
--
-- $Revision: 1.3 $
--
-- Purpose  : The status of the injection wells for the facility/day
--
-- Modification history:
--
-- Date       Whom      Change description:
-- ---------- ----      --------------------------------------------------------------------------------
-- 22.03.2018 abdulmaw  ECPD-52703:New Production Widgets: Daily Injection Well Status Report by facilities
----------------------------------------------------------------------------------------------------
SELECT
       pf.object_id,
       count(ec_prosty_codes.CODE_TEXT(WV.WELL_TYPE,'WELL_TYPE')) as Total,
       sd.daytime,
       wv.well_type,
       nvl(ec_iwel_period_status.active_well_status(wv.object_id, sd.daytime,wv.well_type,'EVENT','<='),'No Status defined') active_status,
       to_char(null) record_status,
       to_char(null) created_by,
       to_date(null) created_date,
       to_char(null) last_updated_by,
       to_date(null) last_updated_date,
       to_number(null) rev_no,
       to_char(null) rev_text
FROM   system_days sd, well_version wv, production_facility pf
WHERE  wv.op_fcty_class_1_id = pf.object_id
AND wv.isinjector = 'Y'
AND wv.daytime <= sd.daytime
AND NVL(wv.end_date,sd.daytime+1) > sd.daytime
group by  pf.object_id,sd.daytime, wv.well_type,  ec_iwel_period_status.active_well_status(wv.object_id, sd.daytime,wv.well_type,'EVENT','<=')
)