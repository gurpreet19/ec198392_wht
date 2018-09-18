CREATE OR REPLACE FORCE EDITIONABLE VIEW "V_STREAM_DAY_LIQUID_ALL" ("DAYTIME", "OBJECT_ID", "OBJECT_CODE", "GRS_VOL", "GRS_MASS", "NET_VOL", "NET_MASS", "STD_DENSITY", "ALLOC_NET_VOL", "ALLOC_NET_MASS", "RECORD_STATUS", "CREATED_BY", "CREATED_DATE", "LAST_UPDATED_BY", "LAST_UPDATED_DATE", "REV_NO", "REV_TEXT") AS 
  (
-------------------------------------------------------------------------------------
--  v_stream_day_liquid_all
--
-- $Revision: 1.2 $
--
--  Purpose:   Provides all liquid streams in one view only independant on which BF they are assigned to
-------------------------------------------------------------------------------------
SELECT
   d.daytime,
   s.object_id,
   s.object_code,
   EcBp_Stream_Fluid.FindGrsStdVol(s.object_id, d.daytime) grs_vol,
   EcBp_Stream_Fluid.findGrsStdMass(s.object_id, d.daytime) grs_mass,
   EcBp_Stream_Fluid.FindNetStdVol(s.object_id, d.daytime) net_vol,
   EcBp_Stream_Fluid.findNetStdMass(s.object_id, d.daytime) net_mass,
   EcBp_Stream_Fluid.findStdDens(s.object_id, d.daytime) std_density,
   Ec_Strm_Day_Alloc.net_vol(s.object_id, d.daytime) alloc_net_vol,
   Ec_Strm_Day_Alloc.net_mass(s.object_id, d.daytime) alloc_net_mass,
   'P' record_status,
   TO_CHAR(NULL) created_by,
   TO_DATE(NULL) created_date,
   TO_CHAR(NULL) last_updated_by,
   TO_DATE(NULL) last_updated_date,
   0 rev_no,
   TO_CHAR(NULL) rev_text
  FROM system_days d, stream s, strm_version sv
 WHERE s.object_id = sv.object_id
	AND d.daytime >= sv.daytime
	AND d.daytime < nvl(sv.end_date,d.daytime+1)
   AND sv.stream_phase <> 'GAS'
)