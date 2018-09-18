CREATE OR REPLACE FORCE EDITIONABLE VIEW "V_WELL_COMP_ANALYSIS" ("OBJECT_ID", "DAYTIME", "PHASE", "ANALYSIS_TYPE", "OFA_DENSITY", "COMPONENT_NO", "WT_PCT", "MOL_PCT", "DENSITY", "MEAS_MOL_WT", "MEAS_SPECIFIC_GRAVITY", "RECORD_STATUS", "CREATED_BY", "CREATED_DATE", "LAST_UPDATED_BY", "LAST_UPDATED_DATE", "REV_NO", "REV_TEXT") AS 
  (
-------------------------------------------------------------------------------------
--  V_WELL_COMP_ANALYSIS
--
-- $Revision: 1.4 $
--
--  Purpose: For each well get weight and mol pct pr component and day from last
--           analysis before or at daytime
--
--  Note:    V_WELL_COMP_ANALYSIS and V_STRM_COMP_ANALYSIS replaces V_LAST_WT_PCT in 8.1
--
-------------------------------------------------------------------------------------
SELECT w.object_id,
       sd.daytime,
       ofa.phase,
       ofa.analysis_type,
       ofa.density  ofa_density,
       fac.component_no,
       fac.wt_pct,
       fac.mol_pct,
       fac.density,
       fac.meas_mol_wt,
       fac.meas_specific_gravity,
       ofa.record_status,
       ofa.created_by,
       ofa.created_date,
       ofa.last_updated_by,
       ofa.last_updated_date,
       ofa.rev_no,
       ofa.rev_text
  from system_days sd,
       well w,
       fluid_analysis_component fac,
       object_fluid_analysis ofa
 where ofa.valid_from_date = (
      select max(valid_from_date)
        from object_fluid_analysis ofa2
       where ofa2.object_id = ofa.object_id
         and ofa2.phase = ofa.phase
  AND ofa2.analysis_status = 'APPROVED'
         and ofa2.valid_from_date <= sd.daytime
         and ofa2.analysis_type = ofa.analysis_type
   )
   and ofa.object_id = w.object_id
   and ofa.analysis_no = fac.analysis_no
   AND ofa.analysis_status = 'APPROVED'
)