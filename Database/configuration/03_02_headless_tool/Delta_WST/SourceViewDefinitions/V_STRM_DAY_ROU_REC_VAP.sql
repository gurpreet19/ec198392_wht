CREATE OR REPLACE FORCE EDITIONABLE VIEW "V_STRM_DAY_ROU_REC_VAP" ("ASSET_ID", "OBJECT_ID", "ASSET_CLASS", "DAYTIME", "PARENT_GROUP_TYPE", "START_DATE", "RUN_HOURS", "RECOVERY_CAPACITY", "SEQUENCE", "SHARES", "PROCESS_UNIT_RUN", "ROUTINE", "PARENT_OBJECT_ID", "RECORD_STATUS", "CREATED_BY", "CREATED_DATE", "LAST_UPDATED_BY", "LAST_UPDATED_DATE", "REV_NO", "REV_TEXT") AS 
  (
-------------------------------------------------------------------------------------
--   v_strm_day_rou_rec_vap.sql
--
-- $Revision: 1.4 $
--
--  Purpose: Get values in Recovered Vapors tab in Daily Gas Stream - Vent and Flare
--
--  Created:   03.12.2009  Sarojini Rajaretnam
--
-- Modification history:
--
-- Date       	Whom  		Change description:
-- ---------- 	----  		--------------------------------------------------------------------------------
-- 17.03.2010	rajarsar	ECPD-4828:Initial Version
-- 13.08.2010	rajarsar	ECPD-15495:Additional parameter added for EcBp_Stream_VentFlare.calcRoutineRunHours
-- 13.07.2017    kashisag  ECPD-45817: Replaced sysdate with Ecdp_Timestamp.getCurrentSysdate
----------------------------------------------------------------------------------------------------
SELECT
ogc.child_obj_id ASSET_ID,
sds.object_id OBJECT_ID,
ecdp_objects.GetObjClassName(ogc.child_obj_id) ASSET_CLASS,
sds.DAYTIME,
ogc.parent_group_type PARENT_GROUP_TYPE,
ogc.start_date START_DATE,
EcBp_Stream_VentFlare.calcRunHours(ogc.child_obj_id, sds.DAYTIME) RUN_HOURS,
ec_eqpm_reference_value.normal_rec_cap_rate(ogc.child_obj_id, sds.DAYTIME, '<=') RECOVERY_CAPACITY,
ec_object_group_conn.sequence(ogc.object_id,ogc.child_obj_id,ogc.start_date,ogc.parent_group_type) SEQUENCE,
ec_object_group_conn.shares(ogc.object_id,ogc.child_obj_id,ogc.start_date,ogc.parent_group_type) SHARES,
EcBp_Stream_VentFlare.calcRunHours(ogc.object_id, sds.DAYTIME) PROCESS_UNIT_RUN,
EcBp_Stream_VentFlare.calcRoutineRunHours(ogc.object_id, ogc.child_obj_id, sds.DAYTIME) ROUTINE,
ogc.object_id PARENT_OBJECT_ID,
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
  AND NVL(sst.end_date,sds.DAYTIME + 1) > sds.DAYTIME
  AND ogc.parent_group_type = 'VF_VRS'
  AND ogc.object_id IN
      (
       SELECT ogc.object_id
          FROM object_group_conn ogc
         WHERE ogc.parent_group_type = 'VF_REL'
           AND ogc.child_obj_id = sds.object_id
           AND ogc.start_date <= sds.daytime
           AND NVL (ogc.end_date, sds.daytime + 1) > sds.daytime
       )
)
ORDER BY ogc.sequence