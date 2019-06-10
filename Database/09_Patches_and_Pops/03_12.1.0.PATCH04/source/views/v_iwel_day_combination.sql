CREATE OR REPLACE VIEW V_IWEL_DAY_COMBINATION AS
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
-- 28.03.2019    rainanid          ECPD-64824 - Corrected logic in view V_IWEL_DAY_COMBINATION to exclude wells that are Longtime Closed.
-- 15.04.2019    abdulmaw          ECPD-64824 - To improve performance issue when running the allocation
-------------------------------------------------------------------------------------
WITH w_min_daytime AS -- to get min date from system_days
  (SELECT min(daytime) daytime
     FROM system_days),
w_days AS -- to find all days
  (SELECT daytime + ROWNUM -1 daytime
     FROM w_min_daytime
     CONNECT BY ROWNUM <= sysdate - daytime),
w_well_open AS -- main query
  (SELECT w.object_id,
          d.daytime,
          s.inj_type,
          wv.isgasinjector,
          wv.iswaterinjector,
          wv.issteaminjector,
          wv.isco2injector,
          wv.calc_inj_method,
          wv.calc_inj_method_mass,
          wv.calc_water_inj_method,
          wv.calc_steam_inj_method,
          wv.calc_co2_inj_method,
          w.record_status,
          w.created_by,
          w.created_date,
          w.last_updated_by,
          w.last_updated_date,
          w.rev_no,
          w.rev_text
    FROM well w,
         well_version wv,
         w_days d,
         iwel_period_status s
   WHERE w.object_id = wv.object_id
     AND w.object_id = s.object_id
     AND s.active_well_status NOT IN ('CLOSED_LT','PLANNED')
     AND d.daytime >= w.start_date
     AND (w.end_date IS NULL OR d.daytime < w.end_date)
     AND d.daytime >= wv.daytime
     AND (wv.end_date IS NULL OR d.daytime < wv.end_date)
     AND s.day = (SELECT max(ms.day)
                  FROM IWEL_PERIOD_STATUS ms
                  WHERE ms.object_id = s.object_id
                    AND ms.inj_type = s.inj_type
                    AND ms.time_span = 'EVENT'
                    AND ms.day <= d.daytime)
  )
(SELECT wwo.object_id,
        wwo.daytime,
        wwo.inj_type,
        wwo.record_status,
        wwo.created_by,
        wwo.created_date,
        wwo.last_updated_by,
        wwo.last_updated_date,
        wwo.rev_no,
        wwo.rev_text
  FROM w_well_open wwo
  WHERE (wwo.inj_type = 'GI' AND wwo.isgasinjector = 'Y' AND ( wwo.calc_inj_method IS NOT NULL or wwo.calc_inj_method_mass IS NOT NULL ))
     OR (wwo.inj_type = 'WI' AND wwo.iswaterinjector = 'Y' AND ( wwo.calc_water_inj_method IS NOT NULL or wwo.calc_inj_method_mass IS NOT NULL ))
     OR (wwo.inj_type = 'SI' AND wwo.issteaminjector = 'Y' AND ( wwo.calc_steam_inj_method IS NOT NULL or wwo.calc_inj_method_mass IS NOT NULL ))
     OR (wwo.inj_type = 'CI' AND wwo.isco2injector = 'Y' AND ( wwo.calc_co2_inj_method IS NOT NULL or wwo.calc_inj_method_mass IS NOT NULL ))
)
UNION   -- Queries to include daily wells whose entries not present in iwel_period_status
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
   AND Nvl(ec_iwel_period_status.active_well_status(s.object_id,s.daytime,s.inj_type,'EVENT','<='),'OPEN') NOT IN ('CLOSED_LT','PLANNED')
)
/