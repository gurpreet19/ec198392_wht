CREATE OR REPLACE FORCE EDITIONABLE VIEW "V_STRM_DAY_ROU_GEN_VAP" ("OBJECT_ID", "EQPM_ID", "DAYTIME", "SEQUENCE", "GRS_VOL", "FLASH_FACTOR", "AVAIL_VAPOURS", "PRIM_REC_SYS", "RECORD_STATUS", "CREATED_BY", "CREATED_DATE", "LAST_UPDATED_BY", "LAST_UPDATED_DATE", "REV_NO", "REV_TEXT") AS 
  (
--------------------------------------------------------------------------------------------------
-- Script:  v_strm_day_rou_gen_vap.sql
--
-- $Revision: 1.6 $
--
-- Purpose: Get values in Generated Vapours tab in Daily Gas Stream - Vent and Flare
--
-- General Logic:
--
-- Created:   20.10.2009  Lau Fusan
--
-- Modification history:
--
-- Date       	Whom  		Change description:
-- ---------- 	----  		--------------------------------------------------------------------------------
-- 17.03.2010	rajarsar	ECPD-4828:Initial Version
-- 13.07.2017   kashisag    ECPD-45817: Replaced sysdate with EcDp_Date_Time.getCurrentSysdate
-- 21.03.2018   shindani    ECPD-44451: Added support for water phase.
----------------------------------------------------------------------------------------------------
SELECT
sds.object_id,
ogc.child_obj_id EQPM_ID,
sds.DAYTIME,
(select t.sequence from object_group_conn t where t.parent_group_type = 'VF_VRS' and t.child_obj_id = ogc.object_id) sequence,
decode(ec_strm_version.stream_phase(ogc.child_obj_id,sds.DAYTIME, '<='),'OIL',ecbp_stream_fluid.findGrsStdVol(ogc.child_obj_id,sds.DAYTIME,sds.DAYTIME),'WAT',ecbp_stream_fluid.findGrsStdVol(ogc.child_obj_id,sds.DAYTIME,sds.DAYTIME),NULL) GRS_VOL,
decode(ec_strm_version.stream_phase(ogc.child_obj_id,sds.DAYTIME, '<='),'OIL',ec_strm_reference_value.flash_factor(ogc.child_obj_id,sds.DAYTIME, '<='),'WAT',ec_strm_reference_value.flash_factor(ogc.child_obj_id,sds.DAYTIME,'<='),NULL) FLASH_FACTOR,
EcBp_Stream_VentFlare.calcVapourGenerated(ogc.child_obj_id,sds.DAYTIME) AVAIL_VAPOURS,
DECODE(ogc.parent_group_type, 'VF_NON', NULL, ogc.object_id) PRIM_REC_SYS,
'P' AS RECORD_STATUS,
USER AS CREATED_BY,
Ecdp_Timestamp.getCurrentSysdate AS CREATED_DATE,
USER AS LAST_UPDATED_BY,
Ecdp_Timestamp.getCurrentSysdate AS LAST_UPDATED_DATE,
NULL AS REV_NO,
NULL AS REV_TEXT
  FROM object_group_conn ogc, strm_day_stream sds, strm_set_list sst
 WHERE sds.object_id = sst.object_id
   AND sst.stream_set = 'PO.0086_VF_R'
   AND sst.from_date <= sds.daytime
   AND NVL(sst.end_date, sds.daytime + 1) > sds.daytime
   AND ogc.parent_group_type IN ('VF_REC', 'VF_NON')
   AND ogc.child_obj_id IN
       (SELECT ogc.child_obj_id
          FROM object_group_conn ogc
         WHERE ogc.parent_group_type = 'VF_NON'
           AND ogc.start_date <= sds.daytime
           AND NVL (ogc.end_date, sds.daytime + 1) > sds.daytime
           AND ogc.object_id IN
               (SELECT object_id
                  FROM object_group_conn ogc
                 WHERE ogc.child_obj_id = sds.object_id
                   AND ogc.parent_group_type = 'VF_REL'
                   AND ogc.start_date <= sds.daytime
                   AND NVL (ogc.end_date, sds.daytime + 1) > sds.daytime)
        UNION
        SELECT ogc.child_obj_id
          FROM object_group_conn ogc
         WHERE ogc.parent_group_type = 'VF_REC'
           AND ogc.start_date <= sds.daytime
           AND NVL (ogc.end_date, sds.daytime + 1) > sds.daytime
           AND ogc.object_id IN
               (SELECT ogc.child_obj_id
                  FROM object_group_conn ogc
                 WHERE ogc.parent_group_type = 'VF_VRS'
                   AND ogc.start_date <= sds.daytime
                   AND NVL (ogc.end_date, sds.daytime + 1) > sds.daytime
                   AND ogc.object_id IN
                       (SELECT object_id
                          FROM object_group_conn ogc
                         WHERE ogc.child_obj_id = sds.object_id
                           AND ogc.parent_group_type = 'VF_REL'
                           AND ogc.start_date <= sds.daytime
                           AND NVL (ogc.end_date, sds.daytime + 1) > sds.daytime))))
ORDER BY sequence, ogc.child_obj_id