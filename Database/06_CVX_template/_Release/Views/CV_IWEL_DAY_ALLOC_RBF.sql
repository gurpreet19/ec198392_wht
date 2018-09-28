---------------------------------------------------------------------------------------------------
--  CV_IWEL_DAY_ALLOC_RBF
--
--  Purpose:           	Provides Reservoir Block Formation detail with IWEL_DAY_ALLOC data; 
--
--
--  Notes:
--
--   	MVAS 05/2008 	9.3
-- 
--
----------------------------------------------------------------------------------------------------- 

CREATE OR REPLACE VIEW cv_iwel_day_alloc_rbf (object_id,
                                                                  daytime,
                                                                  inj_type,
                                                                  alloc_gas_inj_vol,
                                                                  alloc_water_inj_vol,
                                                                  alloc_gas_inj_mass,
                                                                  alloc_water_inj_mass,
                                                                  theor_gas_inj_mass,
                                                                  theor_water_inj_mass,
                                                                  theor_gas_inj_vol,
                                                                  theor_water_inj_vol,
                                                                  prec_theor_gas_inj_mass,
                                                                  prec_theor_water_inj_mass,
                                                                  prec_theor_gas_inj_vol,
                                                                  prec_theor_water_inj_vol,
                                                                  on_stream_hrs,
                                                                  value_1,
                                                                  value_2,
                                                                  value_3,
                                                                  value_4,
                                                                  value_5,
                                                                  value_6,
                                                                  value_7,
                                                                  value_8,
                                                                  value_9,
                                                                  value_10,
                                                                  text_1,
                                                                  text_2,
                                                                  text_3,
                                                                  text_4,
                                                                  well_bore_id,
                                                                  well_bore_code,
                                                                  well_bore_interval_id,
                                                                  well_bore_interval_code,
                                                                  perf_interval_id,
                                                                  perf_interval_code,
                                                                  resv_block_formation_id,
                                                                  record_status,
                                                                  created_by,
                                                                  created_date,
                                                                  last_updated_by,
                                                                  last_updated_date,
                                                                  rev_no,
                                                                  rev_text
                                                                 )
AS
   SELECT a.object_id, 
   a.daytime, -- Added this join cause 111 moved the resv_block_formation_id from perf_interval to perf_interval_version
   inj_type,
          DECODE (inj_type, 'GI', alloc_inj_vol, NULL) AS alloc_gas_inj_vol,
          DECODE (inj_type,
                  'WI', alloc_inj_vol,
                  NULL
                 ) AS alloc_water_inj_vol,
          DECODE (inj_type,
                  'GI', alloc_inj_mass,
                  NULL
                 ) AS alloc_gas_inj_mass,
          DECODE (inj_type,
                  'WI', alloc_inj_mass,
                  NULL
                 ) AS alloc_water_inj_mass,
          DECODE (inj_type,
                  'GI', theor_inj_mass,
                  NULL
                 ) AS theor_gas_inj_mass,
          DECODE (inj_type,
                  'WI', theor_inj_mass,
                  NULL
                 ) AS theor_water_inj_mass,
          DECODE (inj_type, 'GI', theor_inj_vol, NULL) AS theor_gas_inj_vol,
          DECODE (inj_type,
                  'WI', theor_inj_vol,
                  NULL
                 ) AS theor_water_inj_vol,
          DECODE (inj_type,
                  'GI', prec_theor_inj_mass,
                  NULL
                 ) AS prec_theor_gas_inj_mass,
          DECODE (inj_type,
                  'WI', prec_theor_inj_mass,
                  NULL
                 ) AS prec_theor_water_inj_mass,
          DECODE (inj_type,
                  'GI', prec_theor_inj_vol,
                  NULL
                 ) AS prec_theor_gas_inj_vol,
          DECODE (inj_type,
                  'WI', prec_theor_inj_vol,
                  NULL
                 ) AS prec_theor_water_inj_vol,
          on_stream_hrs, a.value_1, a.value_2, a.value_3, a.value_4, a.value_5, a.value_6,-- Added this join cause 111 moved the resv_block_formation_id from perf_interval to perf_interval_version
          a.value_7, a.value_8, a.value_9, a.value_10, a.text_1, a.text_2, a.text_3, a.text_4,-- Added this join cause 111 moved the resv_block_formation_id from perf_interval to perf_interval_version
          wb.object_id AS well_bore_id, wb.object_code AS well_bore_code,
          wbi.object_id AS well_bore_interval_id,
          wbi.object_code AS well_bore_interval_code,
          pi.object_id AS perf_interval_id,
          pi.object_code AS perf_interval_code,
          pv1.resv_block_formation_id AS resv_block_formation_id, -- Added this join cause 111 moved the resv_block_formation_id from perf_interval to perf_interval_version
          a.record_status, a.created_by, a.created_date, a.last_updated_by,
          a.last_updated_date, a.rev_no, a.rev_text
     FROM iwel_day_alloc a, webo_bore wb, webo_interval wbi, perf_interval pi,perf_interval_version pv1 -- Added this join cause 111 moved the resv_block_formation_id from perf_interval to perf_interval_version
    WHERE a.object_id = wb.well_id
	  AND pi.object_id = pv1.object_id -- Added this join cause 111 moved the resv_block_formation_id from perf_interval to perf_interval_version
	  AND pv1.end_date IS NULL ---- Added this join cause 111 moved the resv_block_formation_id from perf_interval to perf_interval_version
      AND wb.start_date >= ec_well.start_date (a.object_id)
      AND (   wb.end_date IS NULL
           OR wb.end_date <
                         NVL (ec_well.end_date (a.object_id), wb.end_date + 1)
          )
      AND
--
          wb.object_id = wbi.well_bore_id
      AND wbi.start_date >= wb.start_date
      AND (   wbi.end_date IS NULL
           OR wbi.end_date < NVL (wb.end_date, wbi.end_date + 1)
          )
      AND
--
          wbi.object_id = pi.webo_interval_id
      AND pi.start_date >= wbi.start_date
      AND (   pi.end_date IS NULL
           OR pi.end_date < NVL (wbi.end_date, pi.end_date + 1)
          );