CREATE OR REPLACE FORCE EDITIONABLE VIEW "V_DEFER_SUM_GRAPH" ("DAYTIME", "CLASS_NAME", "OBJECT_ID", "SORT_ORDER", "RECORD_STATUS", "CREATED_BY", "CREATED_DATE", "LAST_UPDATED_BY", "LAST_UPDATED_DATE", "REV_NO", "REV_TEXT", "SUMMARY_TYPE", "OIL_SCHEDULED", "OIL_UNSCHEDULED", "OIL_UNASSIGNED", "OIL_PLANNED_ACTUAL", "GAS_SCHEDULED", "GAS_UNSCHEDULED", "GAS_UNASSIGNED", "GAS_PLANNED_ACTUAL", "COND_SCHEDULED", "COND_UNSCHEDULED", "COND_UNASSIGNED", "COND_PLANNED_ACTUAL") AS 
  (
----------------------------------------------------------------------------------------------------
-- File name: V_DEFER_SUM_GRAPH.sql
-- View name: V_DEFER_SUM_GRAPH
--
-- $Revision: 1.0 $
--
-- Purpose  : The actual, planned, deferred and unassigned deferred volumes for each day for the facility.
--
-- Modification history:
--
-- Date       Whom       Change description:
-- ---------- ----       --------------------------------------------------------------------------------
-- 15.04.2015 choooshu   ECPD-29830:Intial version
-- 13.07.2017 kashisag   ECPD-45817: Replaced sysdate with Ecdp_Timestamp.getCurrentSysdate
----------------------------------------------------------------------------------------------------
SELECT
		sd.daytime,
		o.class_name,
		o.object_id,
		1 sort_order,
		'P' AS RECORD_STATUS,
		USER AS CREATED_BY,
		Ecdp_Timestamp.getCurrentSysdate AS CREATED_DATE,
		USER AS LAST_UPDATED_BY,
		Ecdp_Timestamp.getCurrentSysdate AS LAST_UPDATED_DATE,
		NULL AS REV_NO,
		NULL AS REV_TEXT,
		'Planned' AS SUMMARY_TYPE,
       	NULL AS OIL_SCHEDULED,
       	NULL AS OIL_UNSCHEDULED,
       	NULL AS OIL_UNASSIGNED,
       	EcBp_Deferment.GetMthPlannedVolumes(o.object_id,'OIL',sd.daytime) AS OIL_PLANNED_ACTUAL,
       	NULL AS GAS_SCHEDULED,
       	NULL AS GAS_UNSCHEDULED,
       	NULL AS GAS_UNASSIGNED,
       	EcBp_Deferment.GetMthPlannedVolumes(o.object_id,'GAS',sd.daytime) AS GAS_PLANNED_ACTUAL,
       	NULL AS COND_SCHEDULED,
       	NULL AS COND_UNSCHEDULED,
       	NULL AS COND_UNASSIGNED,
       	EcBp_Deferment.GetMthPlannedVolumes(o.object_id,'COND',sd.daytime) AS COND_PLANNED_ACTUAL
FROM fcty_version oa, production_facility o, system_days sd
WHERE sd.daytime BETWEEN o.start_date AND NVL(o.end_date,sd.daytime) AND sd.daytime <> NVL(o.end_date,sd.daytime-1)
AND oa.object_id = o.object_id
AND o.CLASS_NAME='FCTY_CLASS_1'
UNION
SELECT
		sd.daytime,
		o.class_name,
		o.object_id,
		2 sort_order,
		'P' AS RECORD_STATUS,
		USER AS CREATED_BY,
		Ecdp_Timestamp.getCurrentSysdate AS CREATED_DATE,
		USER AS LAST_UPDATED_BY,
		Ecdp_Timestamp.getCurrentSysdate AS LAST_UPDATED_DATE,
		NULL AS REV_NO,
		NULL AS REV_TEXT,
		'Actual' AS SUMMARY_TYPE,
       	EcBp_Deferment.getScheduledDeferVolumes(o.object_id,'OIL',sd.daytime,'Y') AS OIL_SCHEDULED,
       	EcBp_Deferment.getScheduledDeferVolumes(o.object_id,'OIL',sd.daytime,'N') AS OIL_UNSCHEDULED,
       	EcBp_Deferment.GetMthPlannedVolumes(o.object_id,'OIL',sd.daytime) - EcBp_Deferment.GetMthActualVolumes(o.object_id,'OIL',sd.daytime) - EcBp_Deferment.GetMthAssignedDeferVolumes(o.object_id,'OIL',sd.daytime) AS OIL_UNASSIGNED,
       	EcBp_Deferment.GetMthActualVolumes(o.object_id,'OIL',sd.daytime) AS OIL_PLANNED_ACTUAL,
       	EcBp_Deferment.getScheduledDeferVolumes(o.object_id,'GAS',sd.daytime,'Y') AS GAS_SCHEDULED,
       	EcBp_Deferment.getScheduledDeferVolumes(o.object_id,'GAS',sd.daytime,'N') AS GAS_UNSCHEDULED,
       	EcBp_Deferment.GetMthPlannedVolumes(o.object_id,'GAS',sd.daytime) - EcBp_Deferment.GetMthActualVolumes(o.object_id,'GAS',sd.daytime) - EcBp_Deferment.GetMthAssignedDeferVolumes(o.object_id,'GAS',sd.daytime) AS GAS_UNASSIGNED,
       	EcBp_Deferment.GetMthActualVolumes(o.object_id,'GAS',sd.daytime) AS GAS_PLANNED_ACTUAL,
       	EcBp_Deferment.getScheduledDeferVolumes(o.object_id,'COND',sd.daytime,'Y') AS COND_SCHEDULED,
       	EcBp_Deferment.getScheduledDeferVolumes(o.object_id,'COND',sd.daytime,'N') AS COND_UNSCHEDULED,
       	EcBp_Deferment.GetMthPlannedVolumes(o.object_id,'COND',sd.daytime) - EcBp_Deferment.GetMthActualVolumes(o.object_id,'COND',sd.daytime) - EcBp_Deferment.GetMthAssignedDeferVolumes(o.object_id,'COND',sd.daytime) AS COND_UNASSIGNED,
       	EcBp_Deferment.GetMthActualVolumes(o.object_id,'COND',sd.daytime) AS COND_PLANNED_ACTUAL
FROM fcty_version oa, production_facility o, system_days sd
WHERE sd.daytime BETWEEN o.start_date AND NVL(o.end_date,sd.daytime) AND sd.daytime <> NVL(o.end_date,sd.daytime-1)
AND oa.object_id = o.object_id
AND o.CLASS_NAME='FCTY_CLASS_1'
)