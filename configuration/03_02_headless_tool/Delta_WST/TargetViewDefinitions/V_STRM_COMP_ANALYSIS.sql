CREATE OR REPLACE FORCE VIEW "V_STRM_COMP_ANALYSIS" ("OBJECT_ID", "DAYTIME", "VALID_FROM_DATE", "SAMPLING_METHOD", "COMPONENT_NO", "WT_PCT", "MOL_PCT", "MEAS_MOL_WT", "MEAS_SPECIFIC_GRAVITY", "VOL_PCT", "VALUE_1", "VALUE_2", "VALUE_3", "VALUE_4", "VALUE_5", "VALUE_6", "VALUE_7", "VALUE_8", "VALUE_9", "VALUE_10", "TEXT_1", "TEXT_2", "TEXT_3", "TEXT_4", "RECORD_STATUS", "CREATED_BY", "CREATED_DATE", "LAST_UPDATED_BY", "LAST_UPDATED_DATE", "REV_NO", "REV_TEXT") AS 
  (
-------------------------------------------------------------------------------------
--  V_STRM_COMP_ANALYSIS
--
-- $Revision: 1.14.2.1 $
--
--  Purpose: For each stream get weight and mol pct pr component and day from last
--           analysis before or at daytime
--
--  Note:    V_WELL_COMP_ANALYSIS and V_STRM_COMP_ANALYSIS replaced V_LAST_WT_PCT in 8.1
--  Note:    V_STRM_COMP_ANALYSIS should only include STRM_OIL_COMP,STRM_GAS_COMP and STRM_LNG_COMP analysis
-------------------------------------------------------------------------------------
SELECT s.object_id,
       sd.daytime,
       ofa.valid_from_date,
       ofa.sampling_method,
       fac.component_no,
       fac.wt_pct,
       fac.mol_pct,
       fac.meas_mol_wt,
       fac.meas_specific_gravity,
       fac.vol_pct,
       fac.value_1,
       fac.value_2,
       fac.value_3,
       fac.value_4,
       fac.value_5,
       fac.value_6,
       fac.value_7,
       fac.value_8,
       fac.value_9,
       fac.value_10,
       fac.text_1,
       fac.text_2,
       fac.text_3,
       fac.text_4,
       ofa.record_status,
       ofa.created_by,
       ofa.created_date,
       ofa.last_updated_by,
       ofa.last_updated_date,
       ofa.rev_no,
       ofa.rev_text
  from system_days sd,
       stream s,
       strm_version sv,
       fluid_analysis_component fac,
       object_fluid_analysis ofa
  where ofa.valid_from_date =
       (select max(valid_from_date)
        from object_fluid_analysis ofa2
        where ofa2.object_id = ofa.object_id
        and ofa2.phase = ofa.phase
        and ofa2.analysis_status = 'APPROVED'
        and ofa2.valid_from_date <= sd.daytime
        and ofa2.analysis_type in ('STRM_OIL_COMP','STRM_GAS_COMP','STRM_LNG_COMP')
       )
   AND s.object_id = sv.object_id
   AND ofa.object_id = nvl(sv.ref_analysis_stream_id,sv.object_id)
   and ofa.phase = sv.stream_phase
   AND sd.daytime >= sv.daytime
   AND (s.end_date IS NULL OR sd.daytime < s.end_date)
   AND (sv.end_date IS NULL OR sd.daytime < sv.end_date)
   AND ofa.analysis_status = 'APPROVED'
   AND ofa.analysis_type in ('STRM_OIL_COMP','STRM_GAS_COMP','STRM_LNG_COMP')
   AND ofa.analysis_no = fac.analysis_no
)