CREATE OR REPLACE FORCE EDITIONABLE VIEW "V_NODE_VERSION_HIST" ("JN_UPD_CREATE_DATE", "JN_OPERATION", "JN_ORACLE_USER", "JN_DATETIME", "JN_NOTES", "JN_APPLN", "JN_SESSION", "OBJECT_ID", "DAYTIME", "END_DATE", "NAME", "NODE_CATEGORY", "CALC_RULE_ID", "ALLOCATEABLE_OBJ_ID", "ALLOC_SEQ", "ALLOC_FLAG", "CAN_PROC_GAS", "CAN_PROC_OIL", "CAN_PROC_COND", "CAN_PROC_WAT", "CAN_PROC_GASINJ", "CAN_PROC_WATINJ", "CAN_PROC_STEAMINJ", "CAN_PROC_GASLIFT", "CAN_PROC_DILUENT", "CAN_PROC_CO2", "CAN_PROC_CO2INJ", "DIAGRAM_LAYOUT_INFO", "COUNTRY_ID", "FIELD_ID", "FIELD_GROUP_ID", "RECONCILIATION_METHOD", "COMMENTS", "TEXT_1", "TEXT_2", "TEXT_3", "TEXT_4", "TEXT_5", "TEXT_6", "TEXT_7", "TEXT_8", "TEXT_9", "TEXT_10", "VALUE_1", "VALUE_2", "VALUE_3", "VALUE_4", "VALUE_5", "DATE_1", "DATE_2", "DATE_3", "DATE_4", "DATE_5", "REF_OBJECT_ID_1", "REF_OBJECT_ID_2", "REF_OBJECT_ID_3", "REF_OBJECT_ID_4", "REF_OBJECT_ID_5", "RECORD_STATUS", "CREATED_BY", "CREATED_DATE", "LAST_UPDATED_BY", "LAST_UPDATED_DATE", "REV_NO", "REV_TEXT", "APPROVAL_BY", "APPROVAL_DATE", "APPROVAL_STATE", "REC_ID") AS 
  (
----------------------------------------------------------------------------------------------------
-- File name: v_node_version_hist.sql
-- View name: v_node_version_hist
--
-- $Revision: 1.0 $
--
-- Purpose  : combine both Historical and Current version of records.
--
-- Modification history:
--9
-- Date       Whom       Change description:
-- ---------- ----       --------------------------------------------------------------------------------
-- 27.10.2015 wonggkai   ECPD-30931:Intial version
----------------------------------------------------------------------------------------------------
	SELECT "JN_UPD_CREATE_DATE","JN_OPERATION","JN_ORACLE_USER","JN_DATETIME","JN_NOTES","JN_APPLN","JN_SESSION","OBJECT_ID","DAYTIME","END_DATE","NAME","NODE_CATEGORY","CALC_RULE_ID","ALLOCATEABLE_OBJ_ID","ALLOC_SEQ","ALLOC_FLAG","CAN_PROC_GAS","CAN_PROC_OIL","CAN_PROC_COND","CAN_PROC_WAT","CAN_PROC_GASINJ","CAN_PROC_WATINJ","CAN_PROC_STEAMINJ","CAN_PROC_GASLIFT","CAN_PROC_DILUENT","CAN_PROC_CO2","CAN_PROC_CO2INJ","DIAGRAM_LAYOUT_INFO","COUNTRY_ID","FIELD_ID","FIELD_GROUP_ID","RECONCILIATION_METHOD","COMMENTS","TEXT_1","TEXT_2","TEXT_3","TEXT_4","TEXT_5","TEXT_6","TEXT_7","TEXT_8","TEXT_9","TEXT_10","VALUE_1","VALUE_2","VALUE_3","VALUE_4","VALUE_5","DATE_1","DATE_2","DATE_3","DATE_4","DATE_5","REF_OBJECT_ID_1","REF_OBJECT_ID_2","REF_OBJECT_ID_3","REF_OBJECT_ID_4","REF_OBJECT_ID_5","RECORD_STATUS","CREATED_BY","CREATED_DATE","LAST_UPDATED_BY","LAST_UPDATED_DATE","REV_NO","REV_TEXT","APPROVAL_BY","APPROVAL_DATE","APPROVAL_STATE","REC_ID" FROM (
	  SELECT
		NVL(LAST_UPDATED_DATE,created_date) jn_upd_create_date
		,'CURRENT' jn_operation
		,NVL(last_updated_by,created_by) jn_oracle_user
		,NVL(LAST_UPDATED_DATE,created_date) jn_datetime
		,'CURRENT' jn_notes
		,NULL jn_appln
		,NULL jn_session
		,node_version.*
	  FROM node_version
	  UNION
	  SELECT
		NVL(LAST_UPDATED_DATE,created_date) jn_upd_create_date
		,node_version_jn.*
	  FROM node_version_jn
	)
)