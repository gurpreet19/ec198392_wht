CREATE OR REPLACE FORCE VIEW "V_IWEL_DAY_COMBINATION" ("OBJECT_ID", "DAYTIME", "INJ_TYPE", "RECORD_STATUS", "CREATED_BY", "CREATED_DATE", "LAST_UPDATED_BY", "LAST_UPDATED_DATE", "REV_NO", "REV_TEXT") AS 
  (
-------------------------------------------------------------------------------------
--  v_iwel_day_combination
--
-- $Revision: 1.5.24.1 $
--
--  Purpose: Get all combinations of injection wells and system days.
--
--  Note:
-- Date       Whom  	  description:
-- ---------- ----  --------------------------------------------------------------------------------
-- 30-04-2014  dhavaalo	  ECPD-27486:Mass injection allocation data read fails
-------------------------------------------------------------------------------------
SELECT w.object_id,
       d.daytime,
       'GI' inj_type,
       w.record_status,
       w.created_by,
       w.created_date,
       w.last_updated_by,
       w.last_updated_date,
       w.rev_no,
       w.rev_text
  FROM well w,
       well_version wv,
       system_days d
 WHERE w.object_id = wv.object_id
   AND wv.isgasinjector = 'Y'
   AND d.daytime >= w.start_date
   AND (w.end_date IS NULL OR d.daytime < w.end_date)
   AND d.daytime >= wv.daytime AND (wv.end_date IS NULL OR d.daytime < wv.end_date)
   AND (wv.calc_inj_method IS NOT NULL or wv.calc_inj_method_mass IS NOT NULL)
   AND nvl(ec_iwel_period_status.active_well_status(w.object_id,d.daytime,'GI','EVENT','<='),'OPEN')<> 'CLOSED_LT'
UNION ALL
SELECT w.object_id,
       d.daytime,
       'WI' inj_type,
       w.record_status,
       w.created_by,
       w.created_date,
       w.last_updated_by,
       w.last_updated_date,
       w.rev_no,
       w.rev_text
  FROM well w,
       well_version wv,
       system_days d
 WHERE w.object_id = wv.object_id
   AND wv.iswaterinjector = 'Y'
   AND d.daytime >= w.start_date
   AND (w.end_date IS NULL OR d.daytime < w.end_date)
   AND d.daytime >= wv.daytime AND (wv.end_date IS NULL OR d.daytime < wv.end_date)
   AND (wv.calc_water_inj_method IS NOT NULL or wv.calc_inj_method_mass IS NOT NULL)
   AND nvl(ec_iwel_period_status.active_well_status(w.object_id,d.daytime,'WI','EVENT','<='),'OPEN')<> 'CLOSED_LT'
UNION ALL
SELECT w.object_id,
       d.daytime,
       'SI' inj_type,
       w.record_status,
       w.created_by,
       w.created_date,
       w.last_updated_by,
       w.last_updated_date,
       w.rev_no,
       w.rev_text
  FROM well w,
       well_version wv,
       system_days d
 WHERE w.object_id = wv.object_id
   AND wv.issteaminjector = 'Y'
   AND d.daytime >= w.start_date
   AND (w.end_date IS NULL OR d.daytime < w.end_date)
   AND d.daytime >= wv.daytime AND (wv.end_date IS NULL OR d.daytime < wv.end_date)
   AND (wv.calc_steam_inj_method IS NOT NULL or wv.calc_inj_method_mass IS NOT NULL)
   AND nvl(ec_iwel_period_status.active_well_status(w.object_id,d.daytime,'SI','EVENT','<='),'OPEN')<> 'CLOSED_LT'
UNION ALL
SELECT w.object_id,
       d.daytime,
       'CI' inj_type,
       w.record_status,
       w.created_by,
       w.created_date,
       w.last_updated_by,
       w.last_updated_date,
       w.rev_no,
       w.rev_text
  FROM well w,
       well_version wv,
       system_days d
 WHERE w.object_id = wv.object_id
   AND wv.isco2injector = 'Y'
   AND d.daytime >= w.start_date
   AND (w.end_date IS NULL OR d.daytime < w.end_date)
   AND d.daytime >= wv.daytime AND (wv.end_date IS NULL OR d.daytime < wv.end_date)
   AND (wv.calc_co2_inj_method IS NOT NULL or wv.calc_inj_method_mass IS NOT NULL)
   AND nvl(ec_iwel_period_status.active_well_status(w.object_id,d.daytime,'CI','EVENT','<='),'OPEN')<> 'CLOSED_LT'
)