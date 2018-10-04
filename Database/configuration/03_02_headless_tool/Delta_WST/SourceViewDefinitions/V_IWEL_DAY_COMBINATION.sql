CREATE OR REPLACE FORCE EDITIONABLE VIEW "V_IWEL_DAY_COMBINATION" ("OBJECT_ID", "DAYTIME", "INJ_TYPE", "RECORD_STATUS", "CREATED_BY", "CREATED_DATE", "LAST_UPDATED_BY", "LAST_UPDATED_DATE", "REV_NO", "REV_TEXT") AS 
  (
-------------------------------------------------------------------------------------
--  v_iwel_day_combination
--
-- $Revision: 1.6 $
--
--  Purpose: Get all combinations of injection wells and system days.
--
--  Note:
-- DATE       VERSION  BY          COMMENTS
-- 30.04.2014 1.0      dhavaalo    ECPD-25980-Mass injection allocation data read fails
-- 16.03.2015          wonggkai    ECPD-30074-excluded long term closed well from IWEL_DAY_DATA
-- 27.10.2015    kashisag          ECPD-31694 - V_IWEL_DAY_COMBINATION does not include daily wells, only period wells , reformed query
-- 08.08.2016    kashisag          ECPD-37910 - Corrected logic for V_IWEL_DAY_COMBINATION, not working correctly with longterm closed wells and daily wells
-------------------------------------------------------------------------------------
(SELECT w.object_id,
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
       system_days d,
       iwel_period_status s
 WHERE w.object_id = wv.object_id
   AND w.object_id = s.object_id
   AND s.active_well_status <> 'CLOSED_LT'
   AND wv.isgasinjector = 'Y'
   AND d.daytime >= w.start_date
   AND (w.end_date IS NULL OR d.daytime < w.end_date)
   AND d.daytime >= wv.daytime
   AND (wv.end_date IS NULL OR d.daytime < wv.end_date)
   AND ( wv.calc_inj_method IS NOT NULL or wv.calc_inj_method_mass IS NOT NULL )
   AND s.day = (SELECT max(ms.day)
                FROM IWEL_PERIOD_STATUS ms
                 where ms.object_id = s.object_id
                 AND ms.inj_type = 'GI'
                 AND ms.time_span = 'EVENT'
                 AND ms.day <= d.daytime)
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
       system_days d,
       iwel_period_status s
 WHERE w.object_id = wv.object_id
   AND w.object_id = s.object_id
   AND s.active_well_status <> 'CLOSED_LT'
   AND wv.iswaterinjector = 'Y'
   AND d.daytime >= w.start_date
   AND (w.end_date IS NULL OR d.daytime < w.end_date)
   AND d.daytime >= wv.daytime
   AND (wv.end_date IS NULL OR d.daytime < wv.end_date)
   AND ( wv.calc_water_inj_method IS NOT NULL or wv.calc_inj_method_mass IS NOT NULL )
   AND s.day = (SELECT max(ms.day)
                FROM IWEL_PERIOD_STATUS ms
                 where ms.object_id = s.object_id
                 AND ms.inj_type = 'WI'
                 AND ms.time_span = 'EVENT'
                 AND ms.day <= d.daytime)
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
       system_days d,
       iwel_period_status s
WHERE w.object_id = wv.object_id
    AND w.object_id = s.object_id
   AND s.active_well_status <> 'CLOSED_LT'
   AND wv.issteaminjector = 'Y'
   AND d.daytime >= w.start_date
   AND (w.end_date IS NULL OR d.daytime < w.end_date)
   AND d.daytime >= wv.daytime
   AND (wv.end_date IS NULL OR d.daytime < wv.end_date)
   AND ( wv.calc_steam_inj_method IS NOT NULL or wv.calc_inj_method_mass IS NOT NULL )
  AND s.day = (SELECT max(ms.day)
                FROM IWEL_PERIOD_STATUS ms
                 where ms.object_id = s.object_id
                 AND ms.inj_type = 'SI'
                 AND ms.time_span = 'EVENT'
                 AND ms.day <= d.daytime)
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
       system_days d,
       iwel_period_status s
 WHERE w.object_id = wv.object_id
   AND w.object_id = s.object_id
   AND s.active_well_status <> 'CLOSED_LT'
   AND wv.isco2injector = 'Y'
   AND d.daytime >= w.start_date
   AND (w.end_date IS NULL OR d.daytime < w.end_date)
   AND d.daytime >= wv.daytime
   AND (wv.end_date IS NULL OR d.daytime < wv.end_date)
   AND ( wv.calc_co2_inj_method IS NOT NULL or wv.calc_inj_method_mass IS NOT NULL )
  AND s.day = (SELECT max(ms.day)
                FROM IWEL_PERIOD_STATUS ms
                 where ms.object_id = s.object_id
                 AND ms.inj_type = 'CI'
                 AND ms.time_span = 'EVENT'
                 AND ms.day <= d.daytime)
)
UNION    -- Queries to include daily wells whose entries not present in iwel_period_status
( SELECT s.object_id,
       s.daytime,
       s.inj_type,
       w.record_status,
       w.created_by,
       w.created_date,
       w.last_updated_by,
       w.last_updated_date,
       w.rev_no,
       w.rev_text
  FROM iwel_day_status s, well w
 WHERE s.object_id= w.object_id
   AND s.inj_type ='GI'
UNION ALL
SELECT s.object_id,
       s.daytime,
       s.inj_type,
       w.record_status,
       w.created_by,
       w.created_date,
       w.last_updated_by,
       w.last_updated_date,
       w.rev_no,
       w.rev_text
  FROM iwel_day_status s, well w
 WHERE s.object_id= w.object_id
   AND s.inj_type ='WI'
UNION ALL
SELECT s.object_id,
       s.daytime,
       s.inj_type,
       w.record_status,
       w.created_by,
       w.created_date,
       w.last_updated_by,
       w.last_updated_date,
       w.rev_no,
       w.rev_text
  FROM iwel_day_status s, well w
 WHERE s.object_id= w.object_id
   AND s.inj_type ='SI'
UNION ALL
SELECT s.object_id,
       s.daytime,
       s.inj_type,
       w.record_status,
       w.created_by,
       w.created_date,
       w.last_updated_by,
       w.last_updated_date,
       w.rev_no,
       w.rev_text
  FROM iwel_day_status s, well w
 WHERE s.object_id= w.object_id
   AND s.inj_type ='CI'
)
)