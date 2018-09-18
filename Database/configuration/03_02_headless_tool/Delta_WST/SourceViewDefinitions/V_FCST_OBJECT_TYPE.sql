CREATE OR REPLACE FORCE EDITIONABLE VIEW "V_FCST_OBJECT_TYPE" ("GROUP_TYPE", "OBJECT_TYPE", "OBJECT_LABEL", "RECORD_STATUS", "CREATED_BY", "CREATED_DATE", "LAST_UPDATED_BY", "LAST_UPDATED_DATE", "REV_NO", "REV_TEXT", "APPROVAL_STATE", "APPROVAL_BY", "APPROVAL_DATE", "REC_ID") AS 
  (
----------------------------------------------------------------------------------------------------
-- File name: v_fcst_object_type.sql
-- View name: v_fcst_object_type
--
-- $Revision: 1.0 $
--
-- Purpose  : Used to fetch object types for FORECAST_GROUP CLASS
--
-- Modification history:
-- Date       Whom       Change description:
-- ---------- ----       --------------------------------------------------------------------------------
-- 12.05.2016 kashisag   ECPD-34297:Intial version
----------------------------------------------------------------------------------------------------
select g.GROUP_TYPE as GROUP_TYPE,
       g.FROM_CLASS_NAME as OBJECT_TYPE,
       EcDp_ClassMeta_Cnfg.getLabel(g.FROM_CLASS_NAME) as OBJECT_LABEL,
	   NULL AS RECORD_STATUS,
       NULL AS CREATED_BY,
       NULL AS CREATED_DATE,
       NULL AS LAST_UPDATED_BY,
       NULL AS LAST_UPDATED_DATE,
       NULL AS REV_NO,
       NULL AS REV_TEXT,
       NULL AS APPROVAL_STATE,
       NULL AS APPROVAL_BY,
       NULL AS APPROVAL_DATE,
       NULL AS REC_ID
  from class_relation_cnfg g
 where group_type in ('operational', 'geographical')
   and EcDp_ClassMeta_Cnfg.isDisabled(g.from_class_name, g.to_class_name, g.role_name) = 'N'
   and g.TO_CLASS_NAME like 'FORECAST_GROUP'
)