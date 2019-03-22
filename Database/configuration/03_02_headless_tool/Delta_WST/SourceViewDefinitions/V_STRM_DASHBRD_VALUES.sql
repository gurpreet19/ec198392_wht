CREATE OR REPLACE FORCE EDITIONABLE VIEW "V_STRM_DASHBRD_VALUES" ("OBJECT_ID", "DAYTIME", "GRS_VOL", "NET_VOL", "ALLOC_NET_VOL", "ALLOC_VOL_FACTOR", "GRS_MASS", "NET_MASS", "ALLOC_NET_MASS", "ALLOC_MASS_FACTOR", "RECORD_STATUS", "CREATED_BY", "CREATED_DATE", "LAST_UPDATED_BY", "LAST_UPDATED_DATE", "REV_NO", "REV_TEXT") AS 
  (
----------------------------------------------------------------------------------------------------
-- File name: V_STRM_DASHBRD_VALUES.sql
-- View name: V_STRM_DASHBRD_VALUES
--
-- $Revision: 1.3 $
--
-- Purpose  : Filters stream values for Gross Vol, Net Vol, Grs Mass and Net Mass
--
-- Modification history:
--
-- Date       Whom      Change description:
-- ---------- ----      --------------------------------------------------------------------------------
-- 27.07.2018 abdulmaw  ECPD-49811:New Production Widgets: Stream Values
----------------------------------------------------------------------------------------------------
SELECT
       sv.object_id AS OBJECT_ID,
       sd.daytime AS DAYTIME,
       ecbp_stream_fluid.findGrsStdVol(sv.object_id,sd.daytime,sd.daytime) AS GRS_VOL,
       ecbp_stream_fluid.findNetStdVol(sv.object_id,sd.daytime,sd.daytime) AS NET_VOL,
       Ec_strm_day_alloc.net_vol(sv.object_id, sd.daytime) AS ALLOC_NET_VOL,
       Ec_strm_day_alloc.vol_factor(sv.object_id, sd.daytime) AS ALLOC_VOL_FACTOR,
       ecbp_stream_fluid.findGrsStdMass(sv.object_id,sd.daytime,sd.daytime) AS GRS_MASS,
       ecbp_stream_fluid.findNetStdMass(sv.object_id,sd.daytime,sd.daytime) AS NET_MASS,
       Ec_strm_day_alloc.net_mass(sv.object_id, sd.daytime) AS ALLOC_NET_MASS,
       Ec_strm_day_alloc.mass_factor(sv.object_id, sd.daytime) AS ALLOC_MASS_FACTOR,
       to_char(null) record_status,
       to_char(null) created_by,
       to_date(null) created_date,
       to_char(null) last_updated_by,
       to_date(null) last_updated_date,
       to_number(null) rev_no,
       to_char(null) rev_text
FROM   strm_version sv, system_days sd
WHERE  sv.daytime <= sd.daytime
AND NVL(sv.end_date,sd.daytime+1) > sd.daytime
)