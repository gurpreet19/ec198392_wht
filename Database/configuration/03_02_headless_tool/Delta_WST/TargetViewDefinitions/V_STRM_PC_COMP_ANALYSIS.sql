CREATE OR REPLACE FORCE VIEW "V_STRM_PC_COMP_ANALYSIS" ("OBJECT_ID", "DAYTIME", "PROFIT_CENTRE_ID", "VALID_FROM_DATE", "COMPONENT_NO", "WT_PCT", "MOL_PCT", "MOL_WT", "DENSITY", "VALUE_1", "VALUE_2", "VALUE_3", "VALUE_4", "VALUE_5", "VALUE_6", "VALUE_7", "VALUE_8", "VALUE_9", "VALUE_10", "TEXT_1", "TEXT_2", "TEXT_3", "TEXT_4", "RECORD_STATUS", "CREATED_BY", "CREATED_DATE", "LAST_UPDATED_BY", "LAST_UPDATED_DATE", "REV_NO", "REV_TEXT") AS 
  (
-------------------------------------------------------------------------------------
--  V_STRM_PC_COMP_ANALYSIS
--
-- $Revision: 1.2 $
--
--  Purpose: For each stream and profit centre get component values from last
--           approved analysis before or at daytime.
--
-------------------------------------------------------------------------------------
SELECT ofa.object_id,
       sd.daytime,
       ofa.profit_centre_id,
       ofa.valid_from_date,
       fac.component_no,
       fac.wt_pct,
       fac.mol_pct,
       fac.mol_wt,
       fac.density,
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
       strm_pc_comp_analysis fac,
       strm_pc_analysis ofa
  where ofa.valid_from_date =
       (select max(valid_from_date)
        from strm_pc_analysis ofa2
        where ofa2.object_id = ofa.object_id
        and ofa2.profit_centre_id = ofa.profit_centre_id
        and ofa2.analysis_status = 'APPROVED'
        and ofa2.valid_from_date <= sd.daytime
       )
   AND ofa.analysis_status = 'APPROVED'
   AND ofa.object_id = fac.object_id
   and ofa.profit_centre_id = fac.profit_centre_id
   and ofa.daytime = fac.daytime
)