CREATE OR REPLACE FORCE EDITIONABLE VIEW "V_DAILY_DEFERMENT_SUMMARY" ("DAYTIME", "CLASS_NAME", "OBJECT_ID", "SUMMARY_TYPE", "SORT_ORDER", "RECORD_STATUS", "CREATED_BY", "CREATED_DATE", "LAST_UPDATED_BY", "LAST_UPDATED_DATE", "REV_NO", "REV_TEXT", "OIL", "GAS", "COND", "WATER_INJ", "GAS_INJ", "STEAM_INJ", "WATER", "OIL_MASS", "GAS_MASS", "WATER_INJ_MASS", "GAS_INJ_MASS", "WATER_MASS", "COND_MASS", "STEAM_INJ_MASS", "GAS_ENERGY") AS 
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
EcBp_Defer_Summary.GetPlannedVolumes(o.object_id,'OIL',sd.daytime) OIL,
EcBp_Defer_Summary.GetPlannedVolumes(o.object_id,'GAS',sd.daytime) GAS,
EcBp_Defer_Summary.GetPlannedVolumes(o.object_id,'COND',sd.daytime) COND,
EcBp_Defer_Summary.GetPlannedVolumes(o.object_id,'WAT_INJ',sd.daytime) WATER_INJ,
EcBp_Defer_Summary.GetPlannedVolumes(o.object_id,'GAS_INJ',sd.daytime) GAS_INJ,
EcBp_Defer_Summary.GetPlannedVolumes(o.object_id,'STEAM_INJ',sd.daytime) STEAM_INJ,
EcBp_Defer_Summary.GetPlannedVolumes(o.object_id,'WATER',sd.daytime) WATER,
EcBp_Defer_Summary.GetPlannedVolumes(o.object_id,'OIL_MASS',sd.daytime) OIL_MASS,
EcBp_Defer_Summary.GetPlannedVolumes(o.object_id,'GAS_MASS',sd.daytime) GAS_MASS,
EcBp_Defer_Summary.GetPlannedVolumes(o.object_id,'WATER_INJ_MASS',sd.daytime) WATER_INJ_MASS,
EcBp_Defer_Summary.GetPlannedVolumes(o.object_id,'GAS_INJ_MASS',sd.daytime) GAS_INJ_MASS,
EcBp_Defer_Summary.GetPlannedVolumes(o.object_id,'WATER_MASS',sd.daytime) WATER_MASS,
EcBp_Defer_Summary.GetPlannedVolumes(o.object_id,'COND_MASS',sd.daytime) COND_MASS,
EcBp_Defer_Summary.GetPlannedVolumes(o.object_id,'STEAM_INJ_MASS',sd.daytime) STEAM_INJ_MASS,
EcBp_Defer_Summary.GetPlannedVolumes(o.object_id,'GAS_ENERGY',sd.daytime) GAS_ENERGY
FROM fcty_version oa, production_facility o, system_days sd, ctrl_system_attribute c, prosty_codes p
WHERE sd.daytime BETWEEN o.start_date AND NVL(o.end_date,sd.daytime) AND sd.daytime <> NVL(o.end_date,sd.daytime-1)
AND sd.daytime BETWEEN c.daytime AND NVL(c.end_date,sd.daytime) AND sd.daytime <> NVL(c.end_date,sd.daytime-1)
AND p.code_type='DAILY_DEF_SUM_LABEL' AND p.code='PLANNED'
AND oa.object_id = o.object_id
AND o.CLASS_NAME='FCTY_CLASS_1'
AND c.attribute_type='DAILY_DEFERMENT_LEVEL' AND c.attribute_text='FCTY_CLASS_1'
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
EcBp_Defer_Summary.GetActualVolumes(o.object_id,'OIL',sd.daytime) OIL,
EcBp_Defer_Summary.GetActualVolumes(o.object_id,'GAS',sd.daytime) GAS,
EcBp_Defer_Summary.GetActualVolumes(o.object_id,'COND',sd.daytime) COND,
EcBp_Defer_Summary.GetActualVolumes(o.object_id,'WAT_INJ',sd.daytime) WATER_INJ,
EcBp_Defer_Summary.GetActualVolumes(o.object_id,'GAS_INJ',sd.daytime) GAS_INJ,
EcBp_Defer_Summary.GetActualVolumes(o.object_id,'STEAM_INJ',sd.daytime) STEAM_INJ,
EcBp_Defer_Summary.GetActualVolumes(o.object_id,'WATER',sd.daytime) WATER,
EcBp_Defer_Summary.GetActualVolumes(o.object_id,'OIL_MASS',sd.daytime) OIL_MASS,
EcBp_Defer_Summary.GetActualVolumes(o.object_id,'GAS_MASS',sd.daytime) GAS_MASS,
EcBp_Defer_Summary.GetActualVolumes(o.object_id,'WATER_INJ_MASS',sd.daytime) WATER_INJ_MASS,
EcBp_Defer_Summary.GetActualVolumes(o.object_id,'GAS_INJ_MASS',sd.daytime) GAS_INJ_MASS,
EcBp_Defer_Summary.GetActualVolumes(o.object_id,'WATER_MASS',sd.daytime) WATER_MASS,
EcBp_Defer_Summary.GetActualVolumes(o.object_id,'COND_MASS',sd.daytime) COND_MASS,
EcBp_Defer_Summary.GetActualVolumes(o.object_id,'STEAM_INJ_MASS',sd.daytime) STEAM_INJ_MASS,
EcBp_Defer_Summary.GetActualVolumes(o.object_id,'GAS_ENERGY',sd.daytime) GAS_ENERGY
FROM fcty_version oa, production_facility o, system_days sd, ctrl_system_attribute c, prosty_codes p
WHERE sd.daytime BETWEEN o.start_date AND NVL(o.end_date,sd.daytime) AND sd.daytime <> NVL(o.end_date,sd.daytime-1)
AND sd.daytime BETWEEN c.daytime AND NVL(c.end_date,sd.daytime) AND sd.daytime <> NVL(c.end_date,sd.daytime-1)
AND p.code_type='DAILY_DEF_SUM_LABEL' AND p.code='ACTUAL'
AND oa.object_id = o.object_id
AND o.CLASS_NAME='FCTY_CLASS_1'
AND c.attribute_type='DAILY_DEFERMENT_LEVEL' AND c.attribute_text='FCTY_CLASS_1'
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
EcBp_Defer_Summary.GetPlannedVolumes(o.object_id,'OIL',sd.daytime) - EcBp_Defer_Summary.GetActualVolumes(o.object_id,'OIL',sd.daytime) OIL,
EcBp_Defer_Summary.GetPlannedVolumes(o.object_id,'GAS',sd.daytime) - EcBp_Defer_Summary.GetActualVolumes( o.object_id,'GAS',sd.daytime) GAS,
EcBp_Defer_Summary.GetPlannedVolumes(o.object_id,'COND',sd.daytime) - EcBp_Defer_Summary.GetActualVolumes(o.object_id,'COND',sd.daytime) COND,
EcBp_Defer_Summary.GetPlannedVolumes(o.object_id,'WAT_INJ',sd.daytime) - EcBp_Defer_Summary.GetActualVolumes(o.object_id,'WAT_INJ',sd.daytime) WAT_INJ,
EcBp_Defer_Summary.GetPlannedVolumes(o.object_id,'GAS_INJ',sd.daytime) - EcBp_Defer_Summary.GetActualVolumes(o.object_id,'GAS_INJ',sd.daytime) GAS_INJ,
EcBp_Defer_Summary.GetPlannedVolumes(o.object_id,'STEAM_INJ',sd.daytime) - EcBp_Defer_Summary.GetActualVolumes(o.object_id,'STEAM_INJ',sd.daytime) STEAM_INJ,
EcBp_Defer_Summary.GetPlannedVolumes(o.object_id,'WATER',sd.daytime) - EcBp_Defer_Summary.GetActualVolumes(o.object_id,'WATER',sd.daytime) WATER,
EcBp_Defer_Summary.GetPlannedVolumes(o.object_id,'OIL_MASS',sd.daytime) - EcBp_Defer_Summary.GetActualVolumes(o.object_id,'OIL_MASS',sd.daytime) OIL_MASS,
EcBp_Defer_Summary.GetPlannedVolumes(o.object_id,'GAS_MASS',sd.daytime) - EcBp_Defer_Summary.GetActualVolumes(o.object_id,'GAS_MASS',sd.daytime) GAS_MASS,
EcBp_Defer_Summary.GetPlannedVolumes(o.object_id,'WATER_INJ_MASS',sd.daytime) - EcBp_Defer_Summary.GetActualVolumes(o.object_id,'WATER_INJ_MASS',sd.daytime) WATER_INJ_MASS,
EcBp_Defer_Summary.GetPlannedVolumes(o.object_id,'GAS_INJ_MASS',sd.daytime) - EcBp_Defer_Summary.GetActualVolumes(o.object_id,'GAS_INJ_MASS',sd.daytime) GAS_INJ_MASS,
EcBp_Defer_Summary.GetPlannedVolumes(o.object_id,'WATER_MASS',sd.daytime) - EcBp_Defer_Summary.GetActualVolumes(o.object_id,'WATER_MASS',sd.daytime) WATER_MASS,
EcBp_Defer_Summary.GetPlannedVolumes(o.object_id,'COND_MASS',sd.daytime) - EcBp_Defer_Summary.GetActualVolumes(o.object_id,'COND_MASS',sd.daytime) COND_MASS,
EcBp_Defer_Summary.GetPlannedVolumes(o.object_id,'STEAM_INJ_MASS',sd.daytime) - EcBp_Defer_Summary.GetActualVolumes(o.object_id,'STEAM_INJ_MASS',sd.daytime) STEAM_INJ_MASS,
EcBp_Defer_Summary.GetPlannedVolumes(o.object_id,'GAS_ENERGY',sd.daytime) - EcBp_Defer_Summary.GetActualVolumes(o.object_id,'GAS_ENERGY',sd.daytime) GAS_ENERGY
FROM fcty_version oa, production_facility o, system_days sd, ctrl_system_attribute c, prosty_codes p
WHERE sd.daytime BETWEEN o.start_date AND NVL(o.end_date,sd.daytime) AND sd.daytime <> NVL(o.end_date,sd.daytime-1)
AND sd.daytime BETWEEN c.daytime AND NVL(c.end_date,sd.daytime) AND sd.daytime <> NVL(c.end_date,sd.daytime-1)
AND p.code_type='DAILY_DEF_SUM_LABEL' AND p.code='DEFERRED'
AND oa.object_id = o.object_id
AND o.CLASS_NAME='FCTY_CLASS_1'
AND c.attribute_type= 'DAILY_DEFERMENT_LEVEL' AND c.attribute_text='FCTY_CLASS_1'
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
EcBp_Defer_Summary.GetAssignedDeferVolumes(o.object_id,'OIL',sd.daytime) OIL,
EcBp_Defer_Summary.GetAssignedDeferVolumes(o.object_id,'GAS',sd.daytime) GAS,
EcBp_Defer_Summary.GetAssignedDeferVolumes(o.object_id,'COND',sd.daytime) COND,
EcBp_Defer_Summary.GetAssignedDeferVolumes(o.object_id,'WAT_INJ',sd.daytime) WATER_INJ,
EcBp_Defer_Summary.GetAssignedDeferVolumes(o.object_id,'GAS_INJ',sd.daytime) GAS_INJ,
EcBp_Defer_Summary.GetAssignedDeferVolumes(o.object_id,'STEAM_INJ',sd.daytime) STEAM_INJ,
EcBp_Defer_Summary.GetAssignedDeferVolumes(o.object_id,'WATER',sd.daytime) WATER,
EcBp_Defer_Summary.GetAssignedDeferVolumes(o.object_id,'OIL_MASS',sd.daytime) OIL_MASS,
EcBp_Defer_Summary.GetAssignedDeferVolumes(o.object_id,'GAS_MASS',sd.daytime) GAS_MASS,
EcBp_Defer_Summary.GetAssignedDeferVolumes(o.object_id,'WATER_INJ_MASS',sd.daytime) WATER_INJ_MASS,
EcBp_Defer_Summary.GetAssignedDeferVolumes(o.object_id,'GAS_INJ_MASS',sd.daytime) GAS_INJ_MASS,
EcBp_Defer_Summary.GetAssignedDeferVolumes(o.object_id,'WATER_MASS',sd.daytime) WATER_MASS,
EcBp_Defer_Summary.GetAssignedDeferVolumes(o.object_id,'COND_MASS',sd.daytime) COND_MASS,
EcBp_Defer_Summary.GetAssignedDeferVolumes(o.object_id,'STEAM_INJ_MASS',sd.daytime) STEAM_INJ_MASS,
EcBp_Defer_Summary.GetAssignedDeferVolumes(o.object_id,'GAS_ENERGY',sd.daytime) GAS_ENERGY
FROM fcty_version oa, production_facility o, system_days sd, ctrl_system_attribute c, prosty_codes p
WHERE sd.daytime BETWEEN o.start_date AND NVL(o.end_date,sd.daytime) AND sd.daytime <> NVL(o.end_date,sd.daytime-1)
AND sd.daytime BETWEEN c.daytime AND NVL(c.end_date,sd.daytime) AND sd.daytime <> NVL(c.end_date,sd.daytime-1)
AND p.code_type='DAILY_DEF_SUM_LABEL' AND p.code='ASSIGNED_DEFERMENT'
AND oa.object_id = o.object_id
AND o.CLASS_NAME='FCTY_CLASS_1'
AND c.attribute_type='DAILY_DEFERMENT_LEVEL' AND c.attribute_text='FCTY_CLASS_1'
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
EcBp_Defer_Summary.GetPlannedVolumes(o.object_id,'OIL',sd.daytime) - EcBp_Defer_Summary.GetActualVolumes(o.object_id,'OIL',sd.daytime) - EcBp_Defer_Summary.GetAssignedDeferVolumes(o.object_id,'OIL',sd.daytime ) OIL,
EcBp_Defer_Summary.GetPlannedVolumes(o.object_id,'GAS',sd.daytime) - EcBp_Defer_Summary.GetActualVolumes(o.object_id,'GAS',sd.daytime) - EcBp_Defer_Summary.GetAssignedDeferVolumes(o.object_id,'GAS',sd.daytime) GAS,
EcBp_Defer_Summary.GetPlannedVolumes(o.object_id,'COND',sd.daytime) - EcBp_Defer_Summary.GetActualVolumes(o.object_id,'COND',sd.daytime) - EcBp_Defer_Summary.GetAssignedDeferVolumes(o.object_id,'COND',sd.daytime) COND,
EcBp_Defer_Summary.GetPlannedVolumes(o.object_id,'WAT_INJ',sd.daytime) - EcBp_Defer_Summary.GetActualVolumes(o.object_id,'WAT_INJ',sd.daytime ) - EcBp_Defer_Summary.GetAssignedDeferVolumes(o.object_id,'WAT_INJ',sd.daytime) WAT_INJ,
EcBp_Defer_Summary.GetPlannedVolumes(o.object_id,'GAS_INJ',sd.daytime) - EcBp_Defer_Summary.GetActualVolumes(o.object_id,'GAS_INJ',sd.daytime) - EcBp_Defer_Summary.GetAssignedDeferVolumes( o.object_id,'GAS_INJ',sd.daytime) GAS_INJ,
EcBp_Defer_Summary.GetPlannedVolumes(o.object_id,'STEAM_INJ',sd.daytime) - EcBp_Defer_Summary.GetActualVolumes(o.object_id,'STEAM_INJ',sd.daytime) - EcBp_Defer_Summary.GetAssignedDeferVolumes(o.object_id,'STEAM_INJ',sd.daytime) STEAM_INJ,
EcBp_Defer_Summary.GetPlannedVolumes(o.object_id,'WATER',sd.daytime) - EcBp_Defer_Summary.GetActualVolumes(o.object_id,'WATER',sd.daytime) - EcBp_Defer_Summary.GetAssignedDeferVolumes(o.object_id,'WATER',sd.daytime) WATER,
EcBp_Defer_Summary.GetPlannedVolumes(o.object_id,'OIL_MASS',sd.daytime) - EcBp_Defer_Summary.GetActualVolumes(o.object_id,'OIL_MASS',sd.daytime) - EcBp_Defer_Summary.GetAssignedDeferVolumes(o.object_id,'OIL_MASS',sd.daytime) OIL_MASS,
EcBp_Defer_Summary.GetPlannedVolumes(o.object_id,'GAS_MASS',sd.daytime) - EcBp_Defer_Summary.GetActualVolumes(o.object_id,'GAS_MASS',sd.daytime) - EcBp_Defer_Summary.GetAssignedDeferVolumes(o.object_id,'GAS_MASS',sd.daytime) GAS_MASS,
EcBp_Defer_Summary.GetPlannedVolumes(o.object_id,'WATER_INJ_MASS',sd.daytime) - EcBp_Defer_Summary.GetActualVolumes(o.object_id,'WATER_INJ_MASS',sd.daytime) - EcBp_Defer_Summary.GetAssignedDeferVolumes(o.object_id,'WATER_INJ_MASS',sd.daytime) WATER_INJ_MASS,
EcBp_Defer_Summary.GetPlannedVolumes(o.object_id,'GAS_INJ_MASS',sd.daytime) - EcBp_Defer_Summary.GetActualVolumes(o.object_id,'GAS_INJ_MASS',sd.daytime) - EcBp_Defer_Summary.GetAssignedDeferVolumes(o.object_id,'GAS_INJ_MASS',sd.daytime) GAS_INJ_MASS,
EcBp_Defer_Summary.GetPlannedVolumes(o.object_id,'WATER_MASS',sd.daytime) - EcBp_Defer_Summary.GetActualVolumes(o.object_id,'WATER_MASS',sd.daytime) - EcBp_Defer_Summary.GetAssignedDeferVolumes(o.object_id,'WATER_MASS',sd.daytime) WATER_MASS,
EcBp_Defer_Summary.GetPlannedVolumes(o.object_id,'COND_MASS',sd.daytime) - EcBp_Defer_Summary.GetActualVolumes(o.object_id,'COND_MASS',sd.daytime) - EcBp_Defer_Summary.GetAssignedDeferVolumes(o.object_id,'COND_MASS',sd.daytime) COND_MASS,
EcBp_Defer_Summary.GetPlannedVolumes(o.object_id,'STEAM_INJ_MASS',sd.daytime) - EcBp_Defer_Summary.GetActualVolumes(o.object_id,'STEAM_INJ_MASS',sd.daytime) - EcBp_Defer_Summary.GetAssignedDeferVolumes(o.object_id,'STEAM_INJ_MASS',sd.daytime) STEAM_INJ_MASS,
EcBp_Defer_Summary.GetPlannedVolumes(o.object_id,'GAS_ENERGY',sd.daytime) - EcBp_Defer_Summary.GetActualVolumes(o.object_id,'GAS_ENERGY',sd.daytime) - EcBp_Defer_Summary.GetAssignedDeferVolumes(o.object_id,'GAS_ENERGY',sd.daytime) GAS_ENERGY
FROM fcty_version oa, production_facility o, system_days sd, ctrl_system_attribute c, prosty_codes p
WHERE sd.daytime BETWEEN o.start_date AND NVL(o.end_date,sd.daytime) AND sd.daytime <> NVL(o.end_date,sd.daytime-1)
AND sd.daytime BETWEEN c.daytime AND NVL(c.end_date,sd.daytime) AND sd.daytime <> NVL(c.end_date,sd.daytime-1)
AND p.code_type='DAILY_DEF_SUM_LABEL' AND p.code='UNASSIGNED_DEFERMENT'
AND oa.object_id = o.object_id
AND o.CLASS_NAME='FCTY_CLASS_1'
AND c.attribute_type= 'DAILY_DEFERMENT_LEVEL' AND c.attribute_text='FCTY_CLASS_1'
UNION
--
-- Fcty Class 2
--
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
EcBp_Defer_Summary.GetPlannedVolumes(o.object_id,'OIL',sd.daytime) OIL,
EcBp_Defer_Summary.GetPlannedVolumes(o.object_id,'GAS',sd.daytime) GAS,
EcBp_Defer_Summary.GetPlannedVolumes(o.object_id,'COND',sd.daytime) COND,
EcBp_Defer_Summary.GetPlannedVolumes(o.object_id,'WAT_INJ',sd.daytime) WATER_INJ,
EcBp_Defer_Summary.GetPlannedVolumes(o.object_id,'GAS_INJ',sd.daytime) GAS_INJ,
EcBp_Defer_Summary.GetPlannedVolumes(o.object_id,'STEAM_INJ',sd.daytime) STEAM_INJ,
EcBp_Defer_Summary.GetPlannedVolumes(o.object_id,'WATER',sd.daytime) WATER,
EcBp_Defer_Summary.GetPlannedVolumes(o.object_id,'OIL_MASS',sd.daytime) OIL_MASS,
EcBp_Defer_Summary.GetPlannedVolumes(o.object_id,'GAS_MASS',sd.daytime) GAS_MASS,
EcBp_Defer_Summary.GetPlannedVolumes(o.object_id,'WATER_INJ_MASS',sd.daytime) WATER_INJ_MASS,
EcBp_Defer_Summary.GetPlannedVolumes(o.object_id,'GAS_INJ_MASS',sd.daytime) GAS_INJ_MASS,
EcBp_Defer_Summary.GetPlannedVolumes(o.object_id,'WATER_MASS',sd.daytime) WATER_MASS,
EcBp_Defer_Summary.GetPlannedVolumes(o.object_id,'COND_MASS',sd.daytime) COND_MASS,
EcBp_Defer_Summary.GetPlannedVolumes(o.object_id,'STEAM_INJ_MASS',sd.daytime) STEAM_INJ_MASS,
EcBp_Defer_Summary.GetPlannedVolumes(o.object_id,'GAS_ENERGY',sd.daytime) GAS_ENERGY
FROM fcty_version oa, production_facility o, system_days sd, ctrl_system_attribute c, prosty_codes p
WHERE sd.daytime BETWEEN o.start_date AND NVL(o.end_date,sd.daytime) AND sd.daytime <> NVL(o.end_date,sd.daytime-1)
AND sd.daytime BETWEEN c.daytime AND NVL(c.end_date,sd.daytime) AND sd.daytime <> NVL(c.end_date,sd.daytime-1)
AND p.code_type='DAILY_DEF_SUM_LABEL' AND p.code='PLANNED'
AND oa.object_id = o.object_id
AND o.CLASS_NAME='FCTY_CLASS_2'
AND c.attribute_type='DAILY_DEFERMENT_LEVEL' AND c.attribute_text='FCTY_CLASS_2'
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
EcBp_Defer_Summary.GetActualVolumes(o.object_id,'OIL',sd.daytime) OIL,
EcBp_Defer_Summary.GetActualVolumes(o.object_id,'GAS',sd.daytime) GAS,
EcBp_Defer_Summary.GetActualVolumes(o.object_id,'COND',sd.daytime) COND,
EcBp_Defer_Summary.GetActualVolumes(o.object_id,'WAT_INJ',sd.daytime) WATER_INJ,
EcBp_Defer_Summary.GetActualVolumes(o.object_id,'GAS_INJ',sd.daytime) GAS_INJ,
EcBp_Defer_Summary.GetActualVolumes(o.object_id,'STEAM_INJ',sd.daytime) STEAM_INJ,
EcBp_Defer_Summary.GetActualVolumes(o.object_id,'WATER',sd.daytime) WATER,
EcBp_Defer_Summary.GetActualVolumes(o.object_id,'OIL_MASS',sd.daytime) OIL_MASS,
EcBp_Defer_Summary.GetActualVolumes(o.object_id,'GAS_MASS',sd.daytime) GAS_MASS,
EcBp_Defer_Summary.GetActualVolumes(o.object_id,'WATER_INJ_MASS',sd.daytime) WATER_INJ_MASS,
EcBp_Defer_Summary.GetActualVolumes(o.object_id,'GAS_INJ_MASS',sd.daytime) GAS_INJ_MASS,
EcBp_Defer_Summary.GetActualVolumes(o.object_id,'WATER_MASS',sd.daytime) WATER_MASS,
EcBp_Defer_Summary.GetActualVolumes(o.object_id,'COND_MASS',sd.daytime) COND_MASS,
EcBp_Defer_Summary.GetActualVolumes(o.object_id,'STEAM_INJ_MASS',sd.daytime) STEAM_INJ_MASS,
EcBp_Defer_Summary.GetActualVolumes(o.object_id,'GAS_ENERGY',sd.daytime) GAS_ENERGY
FROM fcty_version oa, production_facility o, system_days sd, ctrl_system_attribute c, prosty_codes p
WHERE sd.daytime BETWEEN o.start_date AND NVL(o.end_date,sd.daytime) AND sd.daytime <> NVL(o.end_date,sd.daytime-1)
AND sd.daytime BETWEEN c.daytime AND NVL(c.end_date,sd.daytime) AND sd.daytime <> NVL(c.end_date,sd.daytime-1)
AND p.code_type='DAILY_DEF_SUM_LABEL' AND p.code='ACTUAL'
AND oa.object_id = o.object_id
AND o.CLASS_NAME='FCTY_CLASS_2'
AND c.attribute_type='DAILY_DEFERMENT_LEVEL' AND c.attribute_text='FCTY_CLASS_2'
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
EcBp_Defer_Summary.GetPlannedVolumes(o.object_id,'OIL',sd.daytime) - EcBp_Defer_Summary.GetActualVolumes(o.object_id,'OIL',sd.daytime) OIL,
EcBp_Defer_Summary.GetPlannedVolumes(o.object_id,'GAS',sd.daytime) - EcBp_Defer_Summary.GetActualVolumes( o.object_id,'GAS',sd.daytime) GAS,
EcBp_Defer_Summary.GetPlannedVolumes(o.object_id,'COND',sd.daytime) - EcBp_Defer_Summary.GetActualVolumes(o.object_id,'COND',sd.daytime) COND,
EcBp_Defer_Summary.GetPlannedVolumes(o.object_id,'WAT_INJ',sd.daytime) - EcBp_Defer_Summary.GetActualVolumes(o.object_id,'WAT_INJ',sd.daytime) WAT_INJ,
EcBp_Defer_Summary.GetPlannedVolumes(o.object_id,'GAS_INJ',sd.daytime) - EcBp_Defer_Summary.GetActualVolumes(o.object_id,'GAS_INJ',sd.daytime) GAS_INJ,
EcBp_Defer_Summary.GetPlannedVolumes(o.object_id,'STEAM_INJ',sd.daytime) - EcBp_Defer_Summary.GetActualVolumes(o.object_id,'STEAM_INJ',sd.daytime) STEAM_INJ,
EcBp_Defer_Summary.GetPlannedVolumes(o.object_id,'WATER',sd.daytime) - EcBp_Defer_Summary.GetActualVolumes(o.object_id,'WATER',sd.daytime) WATER,
EcBp_Defer_Summary.GetPlannedVolumes(o.object_id,'OIL_MASS',sd.daytime) - EcBp_Defer_Summary.GetActualVolumes(o.object_id,'OIL_MASS',sd.daytime) OIL_MASS,
EcBp_Defer_Summary.GetPlannedVolumes(o.object_id,'GAS_MASS',sd.daytime) - EcBp_Defer_Summary.GetActualVolumes(o.object_id,'GAS_MASS',sd.daytime) GAS_MASS,
EcBp_Defer_Summary.GetPlannedVolumes(o.object_id,'WATER_INJ_MASS',sd.daytime) - EcBp_Defer_Summary.GetActualVolumes(o.object_id,'WATER_INJ_MASS',sd.daytime) WATER_INJ_MASS,
EcBp_Defer_Summary.GetPlannedVolumes(o.object_id,'GAS_INJ_MASS',sd.daytime) - EcBp_Defer_Summary.GetActualVolumes(o.object_id,'GAS_INJ_MASS',sd.daytime) GAS_INJ_MASS,
EcBp_Defer_Summary.GetPlannedVolumes(o.object_id,'WATER_MASS',sd.daytime) - EcBp_Defer_Summary.GetActualVolumes(o.object_id,'WATER_MASS',sd.daytime) WATER_MASS,
EcBp_Defer_Summary.GetPlannedVolumes(o.object_id,'COND_MASS',sd.daytime) - EcBp_Defer_Summary.GetActualVolumes(o.object_id,'COND_MASS',sd.daytime) COND_MASS,
EcBp_Defer_Summary.GetPlannedVolumes(o.object_id,'STEAM_INJ_MASS',sd.daytime) - EcBp_Defer_Summary.GetActualVolumes(o.object_id,'STEAM_INJ_MASS',sd.daytime) STEAM_INJ_MASS,
EcBp_Defer_Summary.GetPlannedVolumes(o.object_id,'GAS_ENERGY',sd.daytime) - EcBp_Defer_Summary.GetActualVolumes(o.object_id,'GAS_ENERGY',sd.daytime) GAS_ENERGY
FROM fcty_version oa, production_facility o, system_days sd, ctrl_system_attribute c, prosty_codes p
WHERE sd.daytime BETWEEN o.start_date AND NVL(o.end_date,sd.daytime) AND sd.daytime <> NVL(o.end_date,sd.daytime-1)
AND sd.daytime BETWEEN c.daytime AND NVL(c.end_date,sd.daytime) AND sd.daytime <> NVL(c.end_date,sd.daytime-1)
AND p.code_type='DAILY_DEF_SUM_LABEL' AND p.code='DEFERRED'
AND oa.object_id = o.object_id
AND o.CLASS_NAME='FCTY_CLASS_2'
AND c.attribute_type= 'DAILY_DEFERMENT_LEVEL' AND c.attribute_text='FCTY_CLASS_2'
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
EcBp_Defer_Summary.GetAssignedDeferVolumes(o.object_id,'OIL',sd.daytime) OIL,
EcBp_Defer_Summary.GetAssignedDeferVolumes(o.object_id,'GAS',sd.daytime) GAS,
EcBp_Defer_Summary.GetAssignedDeferVolumes(o.object_id,'COND',sd.daytime) COND,
EcBp_Defer_Summary.GetAssignedDeferVolumes(o.object_id,'WAT_INJ',sd.daytime) WATER_INJ,
EcBp_Defer_Summary.GetAssignedDeferVolumes(o.object_id,'GAS_INJ',sd.daytime) GAS_INJ,
EcBp_Defer_Summary.GetAssignedDeferVolumes(o.object_id,'STEAM_INJ',sd.daytime) STEAM_INJ,
EcBp_Defer_Summary.GetAssignedDeferVolumes(o.object_id,'WATER',sd.daytime) WATER,
EcBp_Defer_Summary.GetAssignedDeferVolumes(o.object_id,'OIL_MASS',sd.daytime) OIL_MASS,
EcBp_Defer_Summary.GetAssignedDeferVolumes(o.object_id,'GAS_MASS',sd.daytime) GAS_MASS,
EcBp_Defer_Summary.GetAssignedDeferVolumes(o.object_id,'WATER_INJ_MASS',sd.daytime) WATER_INJ_MASS,
EcBp_Defer_Summary.GetAssignedDeferVolumes(o.object_id,'GAS_INJ_MASS',sd.daytime) GAS_INJ_MASS,
EcBp_Defer_Summary.GetAssignedDeferVolumes(o.object_id,'WATER_MASS',sd.daytime) WATER_MASS,
EcBp_Defer_Summary.GetAssignedDeferVolumes(o.object_id,'COND_MASS',sd.daytime) COND_MASS,
EcBp_Defer_Summary.GetAssignedDeferVolumes(o.object_id,'STEAM_INJ_MASS',sd.daytime) STEAM_INJ_MASS,
EcBp_Defer_Summary.GetAssignedDeferVolumes(o.object_id,'GAS_ENERGY',sd.daytime) GAS_ENERGY
FROM fcty_version oa, production_facility o, system_days sd, ctrl_system_attribute c, prosty_codes p
WHERE sd.daytime BETWEEN o.start_date AND NVL(o.end_date,sd.daytime) AND sd.daytime <> NVL(o.end_date,sd.daytime-1)
AND sd.daytime BETWEEN c.daytime AND NVL(c.end_date,sd.daytime) AND sd.daytime <> NVL(c.end_date,sd.daytime-1)
AND p.code_type='DAILY_DEF_SUM_LABEL' AND p.code='ASSIGNED_DEFERMENT'
AND p.code_type='DAILY_DEF_SUM_LABEL' AND p.code='ASSIGNED_DEFERMENT'
AND oa.object_id = o.object_id
AND o.CLASS_NAME='FCTY_CLASS_2'
AND c.attribute_type='DAILY_DEFERMENT_LEVEL' AND c.attribute_text='FCTY_CLASS_2'
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
EcBp_Defer_Summary.GetPlannedVolumes(o.object_id,'OIL',sd.daytime) - EcBp_Defer_Summary.GetActualVolumes(o.object_id,'OIL',sd.daytime) - EcBp_Defer_Summary.GetAssignedDeferVolumes(o.object_id,'OIL',sd.daytime ) OIL,
EcBp_Defer_Summary.GetPlannedVolumes(o.object_id,'GAS',sd.daytime) - EcBp_Defer_Summary.GetActualVolumes(o.object_id,'GAS',sd.daytime) - EcBp_Defer_Summary.GetAssignedDeferVolumes(o.object_id,'GAS',sd.daytime) GAS,
EcBp_Defer_Summary.GetPlannedVolumes(o.object_id,'COND',sd.daytime) - EcBp_Defer_Summary.GetActualVolumes(o.object_id,'COND',sd.daytime) - EcBp_Defer_Summary.GetAssignedDeferVolumes(o.object_id,'COND',sd.daytime) COND,
EcBp_Defer_Summary.GetPlannedVolumes(o.object_id,'WAT_INJ',sd.daytime) - EcBp_Defer_Summary.GetActualVolumes(o.object_id,'WAT_INJ',sd.daytime ) - EcBp_Defer_Summary.GetAssignedDeferVolumes(o.object_id,'WAT_INJ',sd.daytime) WAT_INJ,
EcBp_Defer_Summary.GetPlannedVolumes(o.object_id,'GAS_INJ',sd.daytime) - EcBp_Defer_Summary.GetActualVolumes(o.object_id,'GAS_INJ',sd.daytime) - EcBp_Defer_Summary.GetAssignedDeferVolumes( o.object_id,'GAS_INJ',sd.daytime) GAS_INJ,
EcBp_Defer_Summary.GetPlannedVolumes(o.object_id,'STEAM_INJ',sd.daytime) - EcBp_Defer_Summary.GetActualVolumes(o.object_id,'STEAM_INJ',sd.daytime) - EcBp_Defer_Summary.GetAssignedDeferVolumes(o.object_id,'STEAM_INJ',sd.daytime) STEAM_INJ,
EcBp_Defer_Summary.GetPlannedVolumes(o.object_id,'WATER',sd.daytime) - EcBp_Defer_Summary.GetActualVolumes(o.object_id,'WATER',sd.daytime) - EcBp_Defer_Summary.GetAssignedDeferVolumes(o.object_id,'WATER',sd.daytime) WATER,
EcBp_Defer_Summary.GetPlannedVolumes(o.object_id,'OIL_MASS',sd.daytime) - EcBp_Defer_Summary.GetActualVolumes(o.object_id,'OIL_MASS',sd.daytime) - EcBp_Defer_Summary.GetAssignedDeferVolumes(o.object_id,'OIL_MASS',sd.daytime) OIL_MASS,
EcBp_Defer_Summary.GetPlannedVolumes(o.object_id,'GAS_MASS',sd.daytime) - EcBp_Defer_Summary.GetActualVolumes(o.object_id,'GAS_MASS',sd.daytime) - EcBp_Defer_Summary.GetAssignedDeferVolumes(o.object_id,'GAS_MASS',sd.daytime) GAS_MASS,
EcBp_Defer_Summary.GetPlannedVolumes(o.object_id,'WATER_INJ_MASS',sd.daytime) - EcBp_Defer_Summary.GetActualVolumes(o.object_id,'WATER_INJ_MASS',sd.daytime) - EcBp_Defer_Summary.GetAssignedDeferVolumes(o.object_id,'WATER_INJ_MASS',sd.daytime) WATER_INJ_MASS,
EcBp_Defer_Summary.GetPlannedVolumes(o.object_id,'GAS_INJ_MASS',sd.daytime) - EcBp_Defer_Summary.GetActualVolumes(o.object_id,'GAS_INJ_MASS',sd.daytime) - EcBp_Defer_Summary.GetAssignedDeferVolumes(o.object_id,'GAS_INJ_MASS',sd.daytime) GAS_INJ_MASS,
EcBp_Defer_Summary.GetPlannedVolumes(o.object_id,'WATER_MASS',sd.daytime) - EcBp_Defer_Summary.GetActualVolumes(o.object_id,'WATER_MASS',sd.daytime) - EcBp_Defer_Summary.GetAssignedDeferVolumes(o.object_id,'WATER_MASS',sd.daytime) WATER_MASS,
EcBp_Defer_Summary.GetPlannedVolumes(o.object_id,'COND_MASS',sd.daytime) - EcBp_Defer_Summary.GetActualVolumes(o.object_id,'COND_MASS',sd.daytime) - EcBp_Defer_Summary.GetAssignedDeferVolumes(o.object_id,'COND_MASS',sd.daytime) COND_MASS,
EcBp_Defer_Summary.GetPlannedVolumes(o.object_id,'STEAM_INJ_MASS',sd.daytime) - EcBp_Defer_Summary.GetActualVolumes(o.object_id,'STEAM_INJ_MASS',sd.daytime) - EcBp_Defer_Summary.GetAssignedDeferVolumes(o.object_id,'STEAM_INJ_MASS',sd.daytime) STEAM_INJ_MASS,
EcBp_Defer_Summary.GetPlannedVolumes(o.object_id,'GAS_ENERGY',sd.daytime) - EcBp_Defer_Summary.GetActualVolumes(o.object_id,'GAS_ENERGY',sd.daytime) - EcBp_Defer_Summary.GetAssignedDeferVolumes(o.object_id,'GAS_ENERGY',sd.daytime) GAS_ENERGY
FROM fcty_version oa, production_facility o, system_days sd, ctrl_system_attribute c, prosty_codes p
WHERE sd.daytime BETWEEN o.start_date AND NVL(o.end_date,sd.daytime) AND sd.daytime <> NVL(o.end_date,sd.daytime-1)
AND sd.daytime BETWEEN c.daytime AND NVL(c.end_date,sd.daytime) AND sd.daytime <> NVL(c.end_date,sd.daytime-1)
AND p.code_type='DAILY_DEF_SUM_LABEL' AND p.code='UNASSIGNED_DEFERMENT'
AND oa.object_id = o.object_id
AND o.CLASS_NAME='FCTY_CLASS_2'
AND c.attribute_type= 'DAILY_DEFERMENT_LEVEL' AND c.attribute_text='FCTY_CLASS_2'
--
-- Sub Area
UNION
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
EcBp_Defer_Summary.GetPlannedVolumes(o.object_id,'OIL',sd.daytime) OIL,
EcBp_Defer_Summary.GetPlannedVolumes(o.object_id,'GAS',sd.daytime) GAS,
EcBp_Defer_Summary.GetPlannedVolumes(o.object_id,'COND',sd.daytime) COND,
EcBp_Defer_Summary.GetPlannedVolumes(o.object_id,'WAT_INJ',sd.daytime) WATER_INJ,
EcBp_Defer_Summary.GetPlannedVolumes(o.object_id,'GAS_INJ',sd.daytime) GAS_INJ,
EcBp_Defer_Summary.GetPlannedVolumes(o.object_id,'STEAM_INJ',sd.daytime) STEAM_INJ,
EcBp_Defer_Summary.GetPlannedVolumes(o.object_id,'WATER',sd.daytime) WATER,
EcBp_Defer_Summary.GetPlannedVolumes(o.object_id,'OIL_MASS',sd.daytime) OIL_MASS,
EcBp_Defer_Summary.GetPlannedVolumes(o.object_id,'GAS_MASS',sd.daytime) GAS_MASS,
EcBp_Defer_Summary.GetPlannedVolumes(o.object_id,'WATER_INJ_MASS',sd.daytime) WATER_INJ_MASS,
EcBp_Defer_Summary.GetPlannedVolumes(o.object_id,'GAS_INJ_MASS',sd.daytime) GAS_INJ_MASS,
EcBp_Defer_Summary.GetPlannedVolumes(o.object_id,'WATER_MASS',sd.daytime) WATER_MASS,
EcBp_Defer_Summary.GetPlannedVolumes(o.object_id,'COND_MASS',sd.daytime) COND_MASS,
EcBp_Defer_Summary.GetPlannedVolumes(o.object_id,'STEAM_INJ_MASS',sd.daytime) STEAM_INJ_MASS,
EcBp_Defer_Summary.GetPlannedVolumes(o.object_id,'GAS_ENERGY',sd.daytime) GAS_ENERGY
FROM geogr_area_version oa, geographical_area o, system_days sd, ctrl_system_attribute c, prosty_codes p
WHERE sd.daytime BETWEEN o.start_date AND NVL(o.end_date,sd.daytime) AND sd.daytime <> NVL(o.end_date,sd.daytime-1)
AND sd.daytime BETWEEN c.daytime AND NVL(c.end_date,sd.daytime) AND sd.daytime <> NVL(c.end_date,sd.daytime-1)
AND p.code_type='DAILY_DEF_SUM_LABEL' AND p.code='PLANNED'
AND oa.object_id = o.object_id
AND o.CLASS_NAME='SUB_AREA'
AND c.attribute_type='DAILY_DEFERMENT_LEVEL' AND c.attribute_text='SUB_AREA'
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
EcBp_Defer_Summary.GetActualVolumes(o.object_id,'OIL',sd.daytime) OIL,
EcBp_Defer_Summary.GetActualVolumes(o.object_id,'GAS',sd.daytime) GAS,
EcBp_Defer_Summary.GetActualVolumes(o.object_id,'COND',sd.daytime) COND,
EcBp_Defer_Summary.GetActualVolumes(o.object_id,'WAT_INJ',sd.daytime) WATER_INJ,
EcBp_Defer_Summary.GetActualVolumes(o.object_id,'GAS_INJ',sd.daytime) GAS_INJ,
EcBp_Defer_Summary.GetActualVolumes(o.object_id,'STEAM_INJ',sd.daytime) STEAM_INJ,
EcBp_Defer_Summary.GetActualVolumes(o.object_id,'WATER',sd.daytime) WATER,
EcBp_Defer_Summary.GetActualVolumes(o.object_id,'OIL_MASS',sd.daytime) OIL_MASS,
EcBp_Defer_Summary.GetActualVolumes(o.object_id,'GAS_MASS',sd.daytime) GAS_MASS,
EcBp_Defer_Summary.GetActualVolumes(o.object_id,'WATER_INJ_MASS',sd.daytime) WATER_INJ_MASS,
EcBp_Defer_Summary.GetActualVolumes(o.object_id,'GAS_INJ_MASS',sd.daytime) GAS_INJ_MASS,
EcBp_Defer_Summary.GetActualVolumes(o.object_id,'WATER_MASS',sd.daytime) WATER_MASS,
EcBp_Defer_Summary.GetActualVolumes(o.object_id,'COND_MASS',sd.daytime) COND_MASS,
EcBp_Defer_Summary.GetActualVolumes(o.object_id,'STEAM_INJ_MASS',sd.daytime) STEAM_INJ_MASS,
EcBp_Defer_Summary.GetActualVolumes(o.object_id,'GAS_ENERGY',sd.daytime) GAS_ENERGY
FROM geogr_area_version oa, geographical_area o, system_days sd, ctrl_system_attribute c, prosty_codes p
WHERE sd.daytime BETWEEN o.start_date AND NVL(o.end_date,sd.daytime) AND sd.daytime <> NVL(o.end_date,sd.daytime-1)
AND sd.daytime BETWEEN c.daytime AND NVL(c.end_date,sd.daytime) AND sd.daytime <> NVL(c.end_date,sd.daytime-1)
AND p.code_type='DAILY_DEF_SUM_LABEL' AND p.code='ACTUAL'
AND oa.object_id = o.object_id
AND o.CLASS_NAME='SUB_AREA'
AND c.attribute_type='DAILY_DEFERMENT_LEVEL' AND c.attribute_text='SUB_AREA'
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
EcBp_Defer_Summary.GetPlannedVolumes(o.object_id,'OIL',sd.daytime) - EcBp_Defer_Summary.GetActualVolumes(o.object_id,'OIL',sd.daytime) OIL,
EcBp_Defer_Summary.GetPlannedVolumes(o.object_id,'GAS',sd.daytime) - EcBp_Defer_Summary.GetActualVolumes( o.object_id,'GAS',sd.daytime) GAS,
EcBp_Defer_Summary.GetPlannedVolumes(o.object_id,'COND',sd.daytime) - EcBp_Defer_Summary.GetActualVolumes(o.object_id,'COND',sd.daytime) COND,
EcBp_Defer_Summary.GetPlannedVolumes(o.object_id,'WAT_INJ',sd.daytime) - EcBp_Defer_Summary.GetActualVolumes(o.object_id,'WAT_INJ',sd.daytime) WAT_INJ,
EcBp_Defer_Summary.GetPlannedVolumes(o.object_id,'GAS_INJ',sd.daytime) - EcBp_Defer_Summary.GetActualVolumes(o.object_id,'GAS_INJ',sd.daytime) GAS_INJ,
EcBp_Defer_Summary.GetPlannedVolumes(o.object_id,'STEAM_INJ',sd.daytime) - EcBp_Defer_Summary.GetActualVolumes(o.object_id,'STEAM_INJ',sd.daytime) STEAM_INJ,
EcBp_Defer_Summary.GetPlannedVolumes(o.object_id,'WATER',sd.daytime) - EcBp_Defer_Summary.GetActualVolumes(o.object_id,'WATER',sd.daytime) WATER,
EcBp_Defer_Summary.GetPlannedVolumes(o.object_id,'OIL_MASS',sd.daytime) - EcBp_Defer_Summary.GetActualVolumes(o.object_id,'OIL_MASS',sd.daytime) OIL_MASS,
EcBp_Defer_Summary.GetPlannedVolumes(o.object_id,'GAS_MASS',sd.daytime) - EcBp_Defer_Summary.GetActualVolumes(o.object_id,'GAS_MASS',sd.daytime) GAS_MASS,
EcBp_Defer_Summary.GetPlannedVolumes(o.object_id,'WATER_INJ_MASS',sd.daytime) - EcBp_Defer_Summary.GetActualVolumes(o.object_id,'WATER_INJ_MASS',sd.daytime) WATER_INJ_MASS,
EcBp_Defer_Summary.GetPlannedVolumes(o.object_id,'GAS_INJ_MASS',sd.daytime) - EcBp_Defer_Summary.GetActualVolumes(o.object_id,'GAS_INJ_MASS',sd.daytime) GAS_INJ_MASS,
EcBp_Defer_Summary.GetPlannedVolumes(o.object_id,'WATER_MASS',sd.daytime) - EcBp_Defer_Summary.GetActualVolumes(o.object_id,'WATER_MASS',sd.daytime) WATER_MASS,
EcBp_Defer_Summary.GetPlannedVolumes(o.object_id,'COND_MASS',sd.daytime) - EcBp_Defer_Summary.GetActualVolumes(o.object_id,'COND_MASS',sd.daytime) COND_MASS,
EcBp_Defer_Summary.GetPlannedVolumes(o.object_id,'STEAM_INJ_MASS',sd.daytime) - EcBp_Defer_Summary.GetActualVolumes(o.object_id,'STEAM_INJ_MASS',sd.daytime) STEAM_INJ_MASS,
EcBp_Defer_Summary.GetPlannedVolumes(o.object_id,'GAS_ENERGY',sd.daytime) - EcBp_Defer_Summary.GetActualVolumes(o.object_id,'GAS_ENERGY',sd.daytime) GAS_ENERGY
FROM geogr_area_version oa, geographical_area o, system_days sd, ctrl_system_attribute c, prosty_codes p
WHERE sd.daytime BETWEEN o.start_date AND NVL(o.end_date,sd.daytime) AND sd.daytime <> NVL(o.end_date,sd.daytime-1)
AND sd.daytime BETWEEN c.daytime AND NVL(c.end_date,sd.daytime) AND sd.daytime <> NVL(c.end_date,sd.daytime-1)
AND p.code_type='DAILY_DEF_SUM_LABEL' AND p.code='DEFERRED'
AND oa.object_id = o.object_id
AND o.CLASS_NAME='SUB_AREA'
AND c.attribute_type= 'DAILY_DEFERMENT_LEVEL' AND c.attribute_text='SUB_AREA'
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
EcBp_Defer_Summary.GetAssignedDeferVolumes(o.object_id,'OIL',sd.daytime) OIL,
EcBp_Defer_Summary.GetAssignedDeferVolumes(o.object_id,'GAS',sd.daytime) GAS,
EcBp_Defer_Summary.GetAssignedDeferVolumes(o.object_id,'COND',sd.daytime) COND,
EcBp_Defer_Summary.GetAssignedDeferVolumes(o.object_id,'WAT_INJ',sd.daytime) WATER_INJ,
EcBp_Defer_Summary.GetAssignedDeferVolumes(o.object_id,'GAS_INJ',sd.daytime) GAS_INJ,
EcBp_Defer_Summary.GetAssignedDeferVolumes(o.object_id,'STEAM_INJ',sd.daytime) STEAM_INJ,
EcBp_Defer_Summary.GetAssignedDeferVolumes(o.object_id,'WATER',sd.daytime) WATER,
EcBp_Defer_Summary.GetAssignedDeferVolumes(o.object_id,'OIL_MASS',sd.daytime) OIL_MASS,
EcBp_Defer_Summary.GetAssignedDeferVolumes(o.object_id,'GAS_MASS',sd.daytime) GAS_MASS,
EcBp_Defer_Summary.GetAssignedDeferVolumes(o.object_id,'WATER_INJ_MASS',sd.daytime) WATER_INJ_MASS,
EcBp_Defer_Summary.GetAssignedDeferVolumes(o.object_id,'GAS_INJ_MASS',sd.daytime) GAS_INJ_MASS,
EcBp_Defer_Summary.GetAssignedDeferVolumes(o.object_id,'WATER_MASS',sd.daytime) WATER_MASS,
EcBp_Defer_Summary.GetAssignedDeferVolumes(o.object_id,'COND_MASS',sd.daytime) COND_MASS,
EcBp_Defer_Summary.GetAssignedDeferVolumes(o.object_id,'STEAM_INJ_MASS',sd.daytime) STEAM_INJ_MASS,
EcBp_Defer_Summary.GetAssignedDeferVolumes(o.object_id,'GAS_ENERGY',sd.daytime) GAS_ENERGY
FROM geogr_area_version oa, geographical_area o, system_days sd, ctrl_system_attribute c, prosty_codes p
WHERE sd.daytime BETWEEN o.start_date AND NVL(o.end_date,sd.daytime) AND sd.daytime <> NVL(o.end_date,sd.daytime-1)
AND sd.daytime BETWEEN c.daytime AND NVL(c.end_date,sd.daytime) AND sd.daytime <> NVL(c.end_date,sd.daytime-1)
AND p.code_type='DAILY_DEF_SUM_LABEL' AND p.code='ASSIGNED_DEFERMENT'
AND oa.object_id = o.object_id
AND o.CLASS_NAME='SUB_AREA'
AND c.attribute_type='DAILY_DEFERMENT_LEVEL' AND c.attribute_text='SUB_AREA'
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
EcBp_Defer_Summary.GetPlannedVolumes(o.object_id,'OIL',sd.daytime) - EcBp_Defer_Summary.GetActualVolumes(o.object_id,'OIL',sd.daytime) - EcBp_Defer_Summary.GetAssignedDeferVolumes(o.object_id,'OIL',sd.daytime ) OIL,
EcBp_Defer_Summary.GetPlannedVolumes(o.object_id,'GAS',sd.daytime) - EcBp_Defer_Summary.GetActualVolumes(o.object_id,'GAS',sd.daytime) - EcBp_Defer_Summary.GetAssignedDeferVolumes(o.object_id,'GAS',sd.daytime) GAS,
EcBp_Defer_Summary.GetPlannedVolumes(o.object_id,'COND',sd.daytime) - EcBp_Defer_Summary.GetActualVolumes(o.object_id,'COND',sd.daytime) - EcBp_Defer_Summary.GetAssignedDeferVolumes(o.object_id,'COND',sd.daytime) COND,
EcBp_Defer_Summary.GetPlannedVolumes(o.object_id,'WAT_INJ',sd.daytime) - EcBp_Defer_Summary.GetActualVolumes(o.object_id,'WAT_INJ',sd.daytime ) - EcBp_Defer_Summary.GetAssignedDeferVolumes(o.object_id,'WAT_INJ',sd.daytime) WAT_INJ,
EcBp_Defer_Summary.GetPlannedVolumes(o.object_id,'GAS_INJ',sd.daytime) - EcBp_Defer_Summary.GetActualVolumes(o.object_id,'GAS_INJ',sd.daytime) - EcBp_Defer_Summary.GetAssignedDeferVolumes( o.object_id,'GAS_INJ',sd.daytime) GAS_INJ,
EcBp_Defer_Summary.GetPlannedVolumes(o.object_id,'STEAM_INJ',sd.daytime) - EcBp_Defer_Summary.GetActualVolumes(o.object_id,'STEAM_INJ',sd.daytime) - EcBp_Defer_Summary.GetAssignedDeferVolumes(o.object_id,'STEAM_INJ',sd.daytime) STEAM_INJ,
EcBp_Defer_Summary.GetPlannedVolumes(o.object_id,'WATER',sd.daytime) - EcBp_Defer_Summary.GetActualVolumes(o.object_id,'WATER',sd.daytime) - EcBp_Defer_Summary.GetAssignedDeferVolumes(o.object_id,'WATER',sd.daytime) WATER,
EcBp_Defer_Summary.GetPlannedVolumes(o.object_id,'OIL_MASS',sd.daytime) - EcBp_Defer_Summary.GetActualVolumes(o.object_id,'OIL_MASS',sd.daytime) - EcBp_Defer_Summary.GetAssignedDeferVolumes(o.object_id,'OIL_MASS',sd.daytime) OIL_MASS,
EcBp_Defer_Summary.GetPlannedVolumes(o.object_id,'GAS_MASS',sd.daytime) - EcBp_Defer_Summary.GetActualVolumes(o.object_id,'GAS_MASS',sd.daytime) - EcBp_Defer_Summary.GetAssignedDeferVolumes(o.object_id,'GAS_MASS',sd.daytime) GAS_MASS,
EcBp_Defer_Summary.GetPlannedVolumes(o.object_id,'WATER_INJ_MASS',sd.daytime) - EcBp_Defer_Summary.GetActualVolumes(o.object_id,'WATER_INJ_MASS',sd.daytime) - EcBp_Defer_Summary.GetAssignedDeferVolumes(o.object_id,'WATER_INJ_MASS',sd.daytime) WATER_INJ_MASS,
EcBp_Defer_Summary.GetPlannedVolumes(o.object_id,'GAS_INJ_MASS',sd.daytime) - EcBp_Defer_Summary.GetActualVolumes(o.object_id,'GAS_INJ_MASS',sd.daytime) - EcBp_Defer_Summary.GetAssignedDeferVolumes(o.object_id,'GAS_INJ_MASS',sd.daytime) GAS_INJ_MASS,
EcBp_Defer_Summary.GetPlannedVolumes(o.object_id,'WATER_MASS',sd.daytime) - EcBp_Defer_Summary.GetActualVolumes(o.object_id,'WATER_MASS',sd.daytime) - EcBp_Defer_Summary.GetAssignedDeferVolumes(o.object_id,'WATER_MASS',sd.daytime) WATER_MASS,
EcBp_Defer_Summary.GetPlannedVolumes(o.object_id,'COND_MASS',sd.daytime) - EcBp_Defer_Summary.GetActualVolumes(o.object_id,'COND_MASS',sd.daytime) - EcBp_Defer_Summary.GetAssignedDeferVolumes(o.object_id,'COND_MASS',sd.daytime) COND_MASS,
EcBp_Defer_Summary.GetPlannedVolumes(o.object_id,'STEAM_INJ_MASS',sd.daytime) - EcBp_Defer_Summary.GetActualVolumes(o.object_id,'STEAM_INJ_MASS',sd.daytime) - EcBp_Defer_Summary.GetAssignedDeferVolumes(o.object_id,'STEAM_INJ_MASS',sd.daytime) STEAM_INJ_MASS,
EcBp_Defer_Summary.GetPlannedVolumes(o.object_id,'GAS_ENERGY',sd.daytime) - EcBp_Defer_Summary.GetActualVolumes(o.object_id,'GAS_ENERGY',sd.daytime) - EcBp_Defer_Summary.GetAssignedDeferVolumes(o.object_id,'GAS_ENERGY',sd.daytime) GAS_ENERGY
FROM geogr_area_version oa, geographical_area o, system_days sd, ctrl_system_attribute c, prosty_codes p
WHERE sd.daytime BETWEEN o.start_date AND NVL(o.end_date,sd.daytime) AND sd.daytime <> NVL(o.end_date,sd.daytime-1)
AND sd.daytime BETWEEN c.daytime AND NVL(c.end_date,sd.daytime) AND sd.daytime <> NVL(c.end_date,sd.daytime-1)
AND p.code_type='DAILY_DEF_SUM_LABEL' AND p.code='UNASSIGNED_DEFERMENT'
AND oa.object_id = o.object_id
AND o.CLASS_NAME='SUB_AREA'
AND c.attribute_type= 'DAILY_DEFERMENT_LEVEL' AND c.attribute_text='SUB_AREA'