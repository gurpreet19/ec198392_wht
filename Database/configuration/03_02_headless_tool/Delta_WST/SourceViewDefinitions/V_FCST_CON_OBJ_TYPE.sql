CREATE OR REPLACE FORCE EDITIONABLE VIEW "V_FCST_CON_OBJ_TYPE" ("OBJECT_TYPE", "NAME", "RECORD_STATUS", "CREATED_BY", "CREATED_DATE", "LAST_UPDATED_BY", "LAST_UPDATED_DATE", "REV_NO", "REV_TEXT", "APPROVAL_STATE", "APPROVAL_BY", "APPROVAL_DATE", "REC_ID") AS 
  (
----------------------------------------------------------------------------------------------------
-- File name: v_fcst_object_type.sql
-- View name: v_fcst_object_type
--
-- $Revision: 1.0 $
--
-- Purpose  : Used to fetch constraint object types for Forecast object Constraint screen
--
-- Modification history:
-- Date       Whom       Change description:
-- ---------- ----       --------------------------------------------------------------------------------
-- 07.06.2016 kashisag   ECPD-34297:Intial version
----------------------------------------------------------------------------------------------------
select
       CHILD_CLASS as OBJECT_TYPE,
       EcDp_ClassMeta_Cnfg.getLabel(CHILD_CLASS) as NAME,
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
  from class_dependency_cnfg
 where parent_class ='DESIGN_CAP_OBJECTS'
  and  dependency_type='IMPLEMENTS'
)