CREATE OR REPLACE FORCE EDITIONABLE VIEW "V_DEF_SUMM_FCTY_2" ("SUMMARY_TYPE", "DAYTIME", "OBJECT_ID", "OIL", "GAS", "COND", "WATER", "WATER_INJ", "GAS_INJ", "STEAM_INJ", "SORT_ORDER", "RECORD_STATUS", "CREATED_BY", "CREATED_DATE", "LAST_UPDATED_BY", "LAST_UPDATED_DATE", "REV_NO", "REV_TEXT") AS 
  (
----------------------------------------------------------------------------------------------------
-- File name: V_DEF_SUMM_FCTY_2.sql
-- View name: V_DEF_SUMM_FCTY_2
--
-- $Revision: 1.0 $
--
-- Purpose  : This view is used to find total planned, actual, assigned deferment and unassigned deferment for Facility Class 2 at given date.
--
-- Modification history:
--
-- Date       Whom     Change description:
-- ---------- ----     --------------------------------------------------------------------------------
-- 04.11.2018 khatrnit ECPD-58811: Created view
----------------------------------------------------------------------------------------------------
SELECT
p.code_text summary_type,
sd.daytime daytime,
oa.op_fcty_class_2_id object_id,
SUM(EcBp_Deferment.GetPlannedVolumes(oa.object_id,'OIL',sd.daytime)) OIL,
SUM(EcBp_Deferment.GetPlannedVolumes(oa.object_id,'GAS',sd.daytime)) GAS,
SUM(EcBp_Deferment.GetPlannedVolumes(oa.object_id,'COND',sd.daytime)) COND,
SUM(EcBp_Deferment.GetPlannedVolumes(oa.object_id,'WATER',sd.daytime)) WATER,
SUM(EcBp_Deferment.GetPlannedVolumes(oa.object_id,'WAT_INJ',sd.daytime)) WATER_INJ,
SUM(EcBp_Deferment.GetPlannedVolumes(oa.object_id,'GAS_INJ',sd.daytime)) GAS_INJ,
SUM(EcBp_Deferment.GetPlannedVolumes(oa.object_id,'STEAM_INJ',sd.daytime)) STEAM_INJ,
1 sort_order,
'P' AS RECORD_STATUS,
USER AS CREATED_BY,
Ecdp_Timestamp.getCurrentSysdate AS CREATED_DATE,
USER AS LAST_UPDATED_BY,
Ecdp_Timestamp.getCurrentSysdate AS LAST_UPDATED_DATE,
NULL AS REV_NO,
NULL AS REV_TEXT
FROM fcty_version oa, production_facility o, system_days sd, prosty_codes p
WHERE sd.daytime BETWEEN oa.daytime AND NVL(oa.end_date,sd.daytime) AND sd.daytime <> NVL(oa.end_date,sd.daytime-1)
AND p.code_type='DAILY_DEF_SUM_LABEL' AND p.code='PLANNED'
AND oa.object_id = o.object_id
AND o.CLASS_NAME='FCTY_CLASS_1'
GROUP BY p.code_text, sd.daytime, oa.op_fcty_class_2_id
UNION
SELECT
p.code_text summary_type,
sd.daytime daytime,
oa.op_fcty_class_2_id object_id,
SUM(EcBp_Deferment.GetActualVolumes(oa.object_id,'OIL',sd.daytime)) OIL,
SUM(EcBp_Deferment.GetActualVolumes(oa.object_id,'GAS',sd.daytime)) GAS,
SUM(EcBp_Deferment.GetActualVolumes(oa.object_id,'COND',sd.daytime)) COND,
SUM(EcBp_Deferment.GetActualVolumes(oa.object_id,'WATER',sd.daytime)) WATER,
SUM(EcBp_Deferment.GetActualVolumes(oa.object_id,'WAT_INJ',sd.daytime)) WATER_INJ,
SUM(EcBp_Deferment.GetActualVolumes(oa.object_id,'GAS_INJ',sd.daytime)) GAS_INJ,
SUM(EcBp_Deferment.GetActualVolumes(oa.object_id,'STEAM_INJ',sd.daytime)) STEAM_INJ,
2 sort_order,
'P' AS RECORD_STATUS,
USER AS CREATED_BY,
Ecdp_Timestamp.getCurrentSysdate AS CREATED_DATE,
USER AS LAST_UPDATED_BY,
Ecdp_Timestamp.getCurrentSysdate AS LAST_UPDATED_DATE,
NULL AS REV_NO,
NULL AS REV_TEXT
FROM fcty_version oa, production_facility o, system_days sd, prosty_codes p
WHERE sd.daytime BETWEEN oa.daytime AND NVL(oa.end_date,sd.daytime) AND sd.daytime <> NVL(oa.end_date,sd.daytime-1)
AND p.code_type='DAILY_DEF_SUM_LABEL' AND p.code='ACTUAL'
AND oa.object_id = o.object_id
AND o.CLASS_NAME='FCTY_CLASS_1'
GROUP BY p.code_text, sd.daytime, oa.op_fcty_class_2_id
UNION
SELECT
p.code_text summary_type,
sd.daytime daytime,
oa.op_fcty_class_2_id object_id,
SUM(EcBp_Deferment.GetPlannedVolumes(oa.object_id,'OIL',sd.daytime) - EcBp_Deferment.GetActualVolumes(oa.object_id,'OIL',sd.daytime)) OIL,
SUM(EcBp_Deferment.GetPlannedVolumes(oa.object_id,'GAS',sd.daytime) - EcBp_Deferment.GetActualVolumes(oa.object_id,'GAS',sd.daytime)) GAS,
SUM(EcBp_Deferment.GetPlannedVolumes(oa.object_id,'COND',sd.daytime) - EcBp_Deferment.GetActualVolumes(oa.object_id,'COND',sd.daytime)) COND,
SUM(EcBp_Deferment.GetPlannedVolumes(oa.object_id,'WATER',sd.daytime) - EcBp_Deferment.GetActualVolumes(oa.object_id,'WATER',sd.daytime)) WATER,
SUM(EcBp_Deferment.GetPlannedVolumes(oa.object_id,'WAT_INJ',sd.daytime) - EcBp_Deferment.GetActualVolumes(oa.object_id,'WAT_INJ',sd.daytime)) WAT_INJ,
SUM(EcBp_Deferment.GetPlannedVolumes(oa.object_id,'GAS_INJ',sd.daytime) - EcBp_Deferment.GetActualVolumes(oa.object_id,'GAS_INJ',sd.daytime)) GAS_INJ,
SUM(EcBp_Deferment.GetPlannedVolumes(oa.object_id,'STEAM_INJ',sd.daytime) - EcBp_Deferment.GetActualVolumes(oa.object_id,'STEAM_INJ',sd.daytime)) STEAM_INJ,
3 sort_order,
'P' AS RECORD_STATUS,
USER AS CREATED_BY,
Ecdp_Timestamp.getCurrentSysdate AS CREATED_DATE,
USER AS LAST_UPDATED_BY,
Ecdp_Timestamp.getCurrentSysdate AS LAST_UPDATED_DATE,
NULL AS REV_NO,
NULL AS REV_TEXT
FROM fcty_version oa, production_facility o, system_days sd, prosty_codes p
WHERE sd.daytime BETWEEN oa.daytime AND NVL(oa.end_date,sd.daytime) AND sd.daytime <> NVL(oa.end_date,sd.daytime-1)
AND p.code_type='DAILY_DEF_SUM_LABEL' AND p.code='DEFERRED'
AND oa.object_id = o.object_id
AND o.CLASS_NAME='FCTY_CLASS_1'
GROUP BY p.code_text, sd.daytime, oa.op_fcty_class_2_id
UNION
SELECT
p.code_text summary_type,
sd.daytime daytime,
oa.op_fcty_class_2_id object_id,
SUM(EcBp_Deferment.GetAssignedDeferVolumes(oa.object_id,'OIL',sd.daytime)) OIL,
SUM(EcBp_Deferment.GetAssignedDeferVolumes(oa.object_id,'GAS',sd.daytime)) GAS,
SUM(EcBp_Deferment.GetAssignedDeferVolumes(oa.object_id,'COND',sd.daytime)) COND,
SUM(EcBp_Deferment.GetAssignedDeferVolumes(oa.object_id,'WATER',sd.daytime)) WATER,
SUM(EcBp_Deferment.GetAssignedDeferVolumes(oa.object_id,'WAT_INJ',sd.daytime)) WATER_INJ,
SUM(EcBp_Deferment.GetAssignedDeferVolumes(oa.object_id,'GAS_INJ',sd.daytime)) GAS_INJ,
SUM(EcBp_Deferment.GetAssignedDeferVolumes(oa.object_id,'STEAM_INJ',sd.daytime)) STEAM_INJ,
4 sort_order,
'P' AS RECORD_STATUS,
USER AS CREATED_BY,
Ecdp_Timestamp.getCurrentSysdate AS CREATED_DATE,
USER AS LAST_UPDATED_BY,
Ecdp_Timestamp.getCurrentSysdate AS LAST_UPDATED_DATE,
NULL AS REV_NO,
NULL AS REV_TEXT
FROM fcty_version oa, production_facility o, system_days sd, prosty_codes p
WHERE sd.daytime BETWEEN oa.daytime AND NVL(oa.end_date,sd.daytime) AND sd.daytime <> NVL(oa.end_date,sd.daytime-1)
AND p.code_type='DAILY_DEF_SUM_LABEL' AND p.code='ASSIGNED_DEFERMENT'
AND oa.object_id = o.object_id
AND o.CLASS_NAME='FCTY_CLASS_1'
GROUP BY p.code_text, sd.daytime, oa.op_fcty_class_2_id
UNION
SELECT
p.code_text summary_type,
sd.daytime daytime,
oa.op_fcty_class_2_id object_id,
SUM(EcBp_Deferment.GetPlannedVolumes(oa.object_id,'OIL',sd.daytime) - EcBp_Deferment.GetActualVolumes(oa.object_id,'OIL',sd.daytime) - EcBp_Deferment.GetAssignedDeferVolumes(oa.object_id,'OIL',sd.daytime )) OIL,
SUM(EcBp_Deferment.GetPlannedVolumes(oa.object_id,'GAS',sd.daytime) - EcBp_Deferment.GetActualVolumes(oa.object_id,'GAS',sd.daytime) - EcBp_Deferment.GetAssignedDeferVolumes(o.object_id,'GAS',sd.daytime)) GAS,
SUM(EcBp_Deferment.GetPlannedVolumes(oa.object_id,'COND',sd.daytime) - EcBp_Deferment.GetActualVolumes(oa.object_id,'COND',sd.daytime) - EcBp_Deferment.GetAssignedDeferVolumes(oa.object_id,'COND',sd.daytime)) COND,
SUM(EcBp_Deferment.GetPlannedVolumes(oa.object_id,'WATER',sd.daytime) - EcBp_Deferment.GetActualVolumes(oa.object_id,'WATER',sd.daytime) - EcBp_Deferment.GetAssignedDeferVolumes(oa.object_id,'WATER',sd.daytime)) WATER,
SUM(EcBp_Deferment.GetPlannedVolumes(oa.object_id,'WAT_INJ',sd.daytime) - EcBp_Deferment.GetActualVolumes(oa.object_id,'WAT_INJ',sd.daytime ) - EcBp_Deferment.GetAssignedDeferVolumes(oa.object_id,'WAT_INJ',sd.daytime)) WAT_INJ,
SUM(EcBp_Deferment.GetPlannedVolumes(oa.object_id,'GAS_INJ',sd.daytime) -EcBp_Deferment.GetActualVolumes(oa.object_id,'GAS_INJ',sd.daytime) -EcBp_Deferment.GetAssignedDeferVolumes( oa.object_id,'GAS_INJ',sd.daytime)) GAS_INJ,
SUM(EcBp_Deferment.GetPlannedVolumes(oa.object_id,'STEAM_INJ',sd.daytime) - EcBp_Deferment.GetActualVolumes(oa.object_id,'STEAM_INJ',sd.daytime) - EcBp_Deferment.GetAssignedDeferVolumes(oa.object_id,'STEAM_INJ',sd.daytime)) STEAM_INJ,
5 sort_order,
'P' AS RECORD_STATUS,
USER AS CREATED_BY,
Ecdp_Timestamp.getCurrentSysdate AS CREATED_DATE,
USER AS LAST_UPDATED_BY,
Ecdp_Timestamp.getCurrentSysdate AS LAST_UPDATED_DATE,
NULL AS REV_NO,
NULL AS REV_TEXT
FROM fcty_version oa, production_facility o, system_days sd,  prosty_codes p
WHERE sd.daytime BETWEEN oa.daytime AND NVL(oa.end_date,sd.daytime) AND sd.daytime <> NVL(oa.end_date,sd.daytime-1)
AND p.code_type='DAILY_DEF_SUM_LABEL' AND p.code='UNASSIGNED_DEFERMENT'
AND oa.object_id = o.object_id
AND o.CLASS_NAME='FCTY_CLASS_1'
GROUP BY p.code_text, sd.daytime, oa.op_fcty_class_2_id
)