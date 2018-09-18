CREATE OR REPLACE FORCE EDITIONABLE VIEW "V_DEF_WELL_DEF_SUM_VIEW" ("DAYTIME", "CLASS_NAME", "OBJECT_ID", "SUMMARY_TYPE", "SORT_ORDER", "RECORD_STATUS", "CREATED_BY", "CREATED_DATE", "LAST_UPDATED_BY", "LAST_UPDATED_DATE", "REV_NO", "REV_TEXT", "OIL", "GAS", "COND", "WATER", "WATER_INJ", "GAS_INJ", "STEAM_INJ") AS 
  (
----------------------------------------------------------------------------------------------------
-- File name: V_DEF_WELL_DEF_SUM_VIEW.sql
-- View name: V_DEF_WELL_DEF_SUM_VIEW
--
-- $Revision: 1.0 $
--
-- Purpose  : This view is used to find planned,actual,assigned deferment and unassigned deferment.
--
-- Modification history:
--
-- Date       Whom  Change description:
-- ---------- ----  --------------------------------------------------------------------------------
-- 19-Jan-2015   dhavaalo  ECPD-29754:View for Deferment Summary screen for Deferment version PD.0020- Initial version
-- 13.07.2017    kashisag  ECPD-45817: Replaced sysdate with Ecdp_Timestamp.getCurrentSysdate
----------------------------------------------------------------------------------------------------
SELECT
sd.daytime,
o.class_name,
o.object_id,
p.code_text summary_type,
1 sort_order,
'P' AS RECORD_STATUS,
USER AS CREATED_BY,
Ecdp_Timestamp.getCurrentSysdate AS CREATED_DATE,
USER AS LAST_UPDATED_BY,
Ecdp_Timestamp.getCurrentSysdate AS LAST_UPDATED_DATE,
NULL AS REV_NO,
NULL AS REV_TEXT,
EcBp_Deferment.GetPlannedVolumes(o.object_id,'OIL',sd.daytime) OIL,
EcBp_Deferment.GetPlannedVolumes(o.object_id,'GAS',sd.daytime) GAS,
EcBp_Deferment.GetPlannedVolumes(o.object_id,'COND',sd.daytime) COND,
EcBp_Deferment.GetPlannedVolumes(o.object_id,'WATER',sd.daytime) WATER,
EcBp_Deferment.GetPlannedVolumes(o.object_id,'WAT_INJ',sd.daytime) WATER_INJ,
EcBp_Deferment.GetPlannedVolumes(o.object_id,'GAS_INJ',sd.daytime) GAS_INJ,
EcBp_Deferment.GetPlannedVolumes(o.object_id,'STEAM_INJ',sd.daytime) STEAM_INJ
FROM fcty_version oa, production_facility o, system_days sd, prosty_codes p
WHERE sd.daytime BETWEEN o.start_date AND NVL(o.end_date,sd.daytime) AND sd.daytime <> NVL(o.end_date,sd.daytime-1)
AND p.code_type='DAILY_DEF_SUM_LABEL' AND p.code='PLANNED'
AND oa.object_id = o.object_id
AND o.CLASS_NAME='FCTY_CLASS_1'
UNION
SELECT
sd.daytime,
o.class_name,
o.object_id,
p.code_text summary_type,
2 sort_order,
'P' AS RECORD_STATUS,
USER AS CREATED_BY,
Ecdp_Timestamp.getCurrentSysdate AS CREATED_DATE,
USER AS LAST_UPDATED_BY,
Ecdp_Timestamp.getCurrentSysdate AS LAST_UPDATED_DATE,
NULL AS REV_NO,
NULL AS REV_TEXT,
EcBp_Deferment.GetActualVolumes(o.object_id,'OIL',sd.daytime) OIL,
EcBp_Deferment.GetActualVolumes(o.object_id,'GAS',sd.daytime) GAS,
EcBp_Deferment.GetActualVolumes(o.object_id,'COND',sd.daytime) COND,
EcBp_Deferment.GetActualVolumes(o.object_id,'WATER',sd.daytime) WATER,
EcBp_Deferment.GetActualVolumes(o.object_id,'WAT_INJ',sd.daytime) WATER_INJ,
EcBp_Deferment.GetActualVolumes(o.object_id,'GAS_INJ',sd.daytime) GAS_INJ,
EcBp_Deferment.GetActualVolumes(o.object_id,'STEAM_INJ',sd.daytime) STEAM_INJ
FROM fcty_version oa, production_facility o, system_days sd, prosty_codes p
WHERE sd.daytime BETWEEN o.start_date AND NVL(o.end_date,sd.daytime) AND sd.daytime <> NVL(o.end_date,sd.daytime-1)
AND p.code_type='DAILY_DEF_SUM_LABEL' AND p.code='ACTUAL'
AND oa.object_id = o.object_id
AND o.CLASS_NAME='FCTY_CLASS_1'
UNION
SELECT
sd.daytime,
o.class_name,
o.object_id,
p.code_text summary_type,
3 sort_order,
'P' AS RECORD_STATUS,
USER AS CREATED_BY,
Ecdp_Timestamp.getCurrentSysdate AS CREATED_DATE,
USER AS LAST_UPDATED_BY,
Ecdp_Timestamp.getCurrentSysdate AS LAST_UPDATED_DATE,
NULL AS REV_NO,
NULL AS REV_TEXT,
EcBp_Deferment.GetPlannedVolumes(o.object_id,'OIL',sd.daytime) - EcBp_Deferment.GetActualVolumes(o.object_id,'OIL',sd.daytime) OIL,
EcBp_Deferment.GetPlannedVolumes(o.object_id,'GAS',sd.daytime) - EcBp_Deferment.GetActualVolumes( o.object_id,'GAS',sd.daytime) GAS,
EcBp_Deferment.GetPlannedVolumes(o.object_id,'COND',sd.daytime) - EcBp_Deferment.GetActualVolumes(o.object_id,'COND',sd.daytime) COND,
EcBp_Deferment.GetPlannedVolumes(o.object_id,'WATER',sd.daytime) - EcBp_Deferment.GetActualVolumes(o.object_id,'WATER',sd.daytime) WATER,
EcBp_Deferment.GetPlannedVolumes(o.object_id,'WAT_INJ',sd.daytime) - EcBp_Deferment.GetActualVolumes(o.object_id,'WAT_INJ',sd.daytime) WAT_INJ,
EcBp_Deferment.GetPlannedVolumes(o.object_id,'GAS_INJ',sd.daytime) - EcBp_Deferment.GetActualVolumes(o.object_id,'GAS_INJ',sd.daytime) GAS_INJ,
EcBp_Deferment.GetPlannedVolumes(o.object_id,'STEAM_INJ',sd.daytime) - EcBp_Deferment.GetActualVolumes(o.object_id,'STEAM_INJ',sd.daytime) STEAM_INJ
FROM fcty_version oa, production_facility o, system_days sd, prosty_codes p
WHERE sd.daytime BETWEEN o.start_date AND NVL(o.end_date,sd.daytime) AND sd.daytime <> NVL(o.end_date,sd.daytime-1)
AND p.code_type='DAILY_DEF_SUM_LABEL' AND p.code='DEFERRED'
AND oa.object_id = o.object_id
AND o.CLASS_NAME='FCTY_CLASS_1'
UNION
SELECT
sd.daytime,
o.class_name,
o.object_id,
p.code_text summary_type,
4 sort_order,
'P' AS RECORD_STATUS,
USER AS CREATED_BY,
Ecdp_Timestamp.getCurrentSysdate AS CREATED_DATE,
USER AS LAST_UPDATED_BY,
Ecdp_Timestamp.getCurrentSysdate AS LAST_UPDATED_DATE,
NULL AS REV_NO,
NULL AS REV_TEXT,
EcBp_Deferment.GetAssignedDeferVolumes(o.object_id,'OIL',sd.daytime) OIL,
EcBp_Deferment.GetAssignedDeferVolumes(o.object_id,'GAS',sd.daytime) GAS,
EcBp_Deferment.GetAssignedDeferVolumes(o.object_id,'COND',sd.daytime) COND,
EcBp_Deferment.GetAssignedDeferVolumes(o.object_id,'WATER',sd.daytime) WATER,
EcBp_Deferment.GetAssignedDeferVolumes(o.object_id,'WAT_INJ',sd.daytime) WATER_INJ,
EcBp_Deferment.GetAssignedDeferVolumes(o.object_id,'GAS_INJ',sd.daytime) GAS_INJ,
EcBp_Deferment.GetAssignedDeferVolumes(o.object_id,'STEAM_INJ',sd.daytime) STEAM_INJ
FROM fcty_version oa, production_facility o, system_days sd, prosty_codes p
WHERE sd.daytime BETWEEN o.start_date AND NVL(o.end_date,sd.daytime) AND sd.daytime <> NVL(o.end_date,sd.daytime-1)
AND p.code_type='DAILY_DEF_SUM_LABEL' AND p.code='ASSIGNED_DEFERMENT'
AND oa.object_id = o.object_id
AND o.CLASS_NAME='FCTY_CLASS_1'
UNION
SELECT
sd.daytime,
o.class_name,
o.object_id,
p.code_text summary_type,
5 sort_order,
'P' AS RECORD_STATUS,
USER AS CREATED_BY,
Ecdp_Timestamp.getCurrentSysdate AS CREATED_DATE,
USER AS LAST_UPDATED_BY,
Ecdp_Timestamp.getCurrentSysdate AS LAST_UPDATED_DATE,
NULL AS REV_NO,
NULL AS REV_TEXT,
EcBp_Deferment.GetPlannedVolumes(o.object_id,'OIL',sd.daytime) - EcBp_Deferment.GetActualVolumes(o.object_id,'OIL',sd.daytime) - EcBp_Deferment.GetAssignedDeferVolumes(o.object_id,'OIL',sd.daytime ) OIL,
EcBp_Deferment.GetPlannedVolumes(o.object_id,'GAS',sd.daytime) - EcBp_Deferment.GetActualVolumes(o.object_id,'GAS',sd.daytime) - EcBp_Deferment.GetAssignedDeferVolumes(o.object_id,'GAS',sd.daytime) GAS,
EcBp_Deferment.GetPlannedVolumes(o.object_id,'COND',sd.daytime) - EcBp_Deferment.GetActualVolumes(o.object_id,'COND',sd.daytime) - EcBp_Deferment.GetAssignedDeferVolumes(o.object_id,'COND',sd.daytime) COND,
EcBp_Deferment.GetPlannedVolumes(o.object_id,'WATER',sd.daytime) - EcBp_Deferment.GetActualVolumes(o.object_id,'WATER',sd.daytime) - EcBp_Deferment.GetAssignedDeferVolumes(o.object_id,'WATER',sd.daytime) WATER,
EcBp_Deferment.GetPlannedVolumes(o.object_id,'WAT_INJ',sd.daytime) - EcBp_Deferment.GetActualVolumes(o.object_id,'WAT_INJ',sd.daytime ) - EcBp_Deferment.GetAssignedDeferVolumes(o.object_id,'WAT_INJ',sd.daytime) WAT_INJ,
EcBp_Deferment.GetPlannedVolumes(o.object_id,'GAS_INJ',sd.daytime) -EcBp_Deferment.GetActualVolumes(o.object_id,'GAS_INJ',sd.daytime) -EcBp_Deferment.GetAssignedDeferVolumes( o.object_id,'GAS_INJ',sd.daytime) GAS_INJ,
EcBp_Deferment.GetPlannedVolumes(o.object_id,'STEAM_INJ',sd.daytime) - EcBp_Deferment.GetActualVolumes(o.object_id,'STEAM_INJ',sd.daytime) - EcBp_Deferment.GetAssignedDeferVolumes(o.object_id,'STEAM_INJ',sd.daytime) STEAM_INJ
FROM fcty_version oa, production_facility o, system_days sd,  prosty_codes p
WHERE sd.daytime BETWEEN o.start_date AND NVL(o.end_date,sd.daytime) AND sd.daytime <> NVL(o.end_date,sd.daytime-1)
AND p.code_type='DAILY_DEF_SUM_LABEL' AND p.code='UNASSIGNED_DEFERMENT'
AND oa.object_id = o.object_id
AND o.CLASS_NAME='FCTY_CLASS_1'
)