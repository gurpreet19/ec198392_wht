CREATE OR REPLACE VIEW CV_IWEL_DAY_STATUS_RBF 
AS 
SELECT    iwel_day_status.object_id AS object_id,
          iwel_day_status.inj_type AS inj_type,
          iwel_day_status.daytime AS daytime,
          iwel_day_status.inj_vol AS inj_vol,
          iwel_day_status.inj_mass AS inj_mass,
          iwel_day_status.inj_rate AS inj_rate,
          iwel_day_status.on_stream_hrs AS on_stream_hrs,
          iwel_day_status.avg_annulus_press AS avg_annulus_press,
          iwel_day_status.avg_annulus_press_2 AS avg_annulus_press_2,
          iwel_day_status.avg_annulus_press_3 AS avg_annulus_press_3,
          iwel_day_status.avg_tubing_press AS avg_tubing_press,
          iwel_day_status.avg_gas_density AS avg_gas_density,
          iwel_day_status.avg_choke_size AS avg_choke_size,
          iwel_day_status.avg_2nd_choke_size AS avg_2nd_choke_size,
          iwel_day_status.avg_choke_line_temp AS avg_choke_line_temp,
          iwel_day_status.avg_wh_press AS avg_wh_press,
          iwel_day_status.avg_wh_temp AS avg_wh_temp,
          iwel_day_status.avg_wh_usc_press AS avg_wh_usc_press,
          iwel_day_status.avg_wh_usc_temp AS avg_wh_usc_temp,
          iwel_day_status.avg_wh_dsc_press AS avg_wh_dsc_press,
          iwel_day_status.avg_wh_dsc_temp AS avg_wh_dsc_temp,
          iwel_day_status.avg_temp AS avg_temp,
          iwel_day_status.avg_press AS avg_press,
          iwel_day_status.inj_press AS inj_press,
          iwel_day_status.avg_bh_temp AS avg_bh_temp,
          iwel_day_status.avg_bh_press AS avg_bh_press,
          iwel_day_status.avg_brhead_press AS avg_brhead_press,
          iwel_day_status.totalizer AS totalizer,
          iwel_day_status.totalizer_reset_ind AS totalizer_reset_ind,
          iwel_day_status.theor_inj_rate AS theor_inj_rate,
          iwel_day_status.well_status AS well_status,
          iwel_day_status.orifice_diff_press AS orifice_diff_press,
          iwel_day_status.orifice_diff_press_2 AS orifice_diff_press_2,
          iwel_day_status.orifice_static_press AS orifice_static_press,
          iwel_day_status.orifice_static_press_2 AS orifice_static_press_2,
          iwel_day_status.inj_mass_rate_1 AS inj_mass_rate_1,
          iwel_day_status.inj_mass_rate_2 AS inj_mass_rate_2,
          iwel_day_status.steam_quality AS steam_quality,
          iwel_day_status.inj_energy AS inj_energy,
          iwel_day_status.on_stream_secs AS on_stream_secs,
          iwel_day_status.annulus_press AS annulus_press,
          iwel_day_status.comments AS comments,
          iwel_day_status.value_1 AS value_1,
          iwel_day_status.value_2 AS value_2,
          iwel_day_status.value_3 AS value_3,
          iwel_day_status.value_4 AS value_4,
          iwel_day_status.value_5 AS value_5,
          iwel_day_status.value_6 AS value_6,
          iwel_day_status.value_7 AS value_7,
          iwel_day_status.value_8 AS value_8,
          iwel_day_status.value_9 AS value_9,
          iwel_day_status.value_10 AS value_10,
          iwel_day_status.text_1 AS text_1, iwel_day_status.text_2 AS text_2,
          iwel_day_status.text_3 AS text_3, iwel_day_status.text_4 AS text_4,
          iwel_day_status.record_status, iwel_day_status.created_by,
          iwel_day_status.created_date, iwel_day_status.last_updated_by,
          iwel_day_status.last_updated_date, iwel_day_status.rev_no,
          iwel_day_status.rev_text,
          iwel_day_status.approval_state AS approval_state,
          iwel_day_status.approval_by AS approval_by,
          iwel_day_status.approval_date AS approval_date,
          iwel_day_status.rec_id AS rec_id,
          wb.well_id AS well_id, wb.object_id AS well_bore_id,
          wb.object_code AS well_bore_code,
          wbi.object_id AS well_bore_interval_id,
          wbi.object_code AS well_bore_interval_code,
          pi.object_id AS perf_interval_id,
          pi.object_code AS perf_interval_code,
          piv.resv_block_formation_id AS resv_block_formation_id-- Added this join cause 111 moved the resv_block_formation_id from perf_interval to perf_interval_version
     FROM system_days s,
          well_version oa,
          well o,
          webo_version wbv,
          webo_bore wb,
          webo_interval_version wbiv,
          webo_interval wbi,
          perf_interval_version piv,
          iwel_day_status,
          perf_interval pi
    WHERE 
-- WELL
    s.DAYTIME=iwel_day_status.DAYTIME AND
    iwel_day_status.OBJECT_ID = o.OBJECT_ID AND
    oa.OBJECT_ID = iwel_day_status.OBJECT_ID AND
    o.OBJECT_ID = oa.OBJECT_ID AND
      iwel_day_status.DAYTIME >= oa.DAYTIME AND
    (iwel_day_status.DAYTIME < oa.END_DATE OR oa.END_DATE IS NULL) AND
-- WELL_BORE
    oa.OBJECT_ID = WB.WELL_ID AND
    WB.OBJECT_ID = WBV.OBJECT_ID AND
      iwel_day_status.DAYTIME >= WBV.DAYTIME AND
    (iwel_day_status.DAYTIME < WBV.END_DATE OR WBV.END_DATE IS NULL) AND
-- WELL_BORE_INTERVAL
      WB.OBJECT_ID = WBI.WELL_BORE_ID AND 
    WBI.OBJECT_ID = WBIV.OBJECT_ID AND 
      iwel_day_status.DAYTIME >= WBIV.DAYTIME AND
    (iwel_day_status.DAYTIME < WBIV.END_DATE OR WBIV.END_DATE IS NULL) AND
-- PERF_INTERVAL
      WBI.OBJECT_ID = PI.WEBO_INTERVAL_ID AND 
    PI.OBJECT_ID = PIV.OBJECT_ID AND 
      IWEL_day_status.DAYTIME >= PIV.DAYTIME AND
    (IWEL_day_status.DAYTIME < PIV.END_DATE OR PIV.END_DATE IS NULL);