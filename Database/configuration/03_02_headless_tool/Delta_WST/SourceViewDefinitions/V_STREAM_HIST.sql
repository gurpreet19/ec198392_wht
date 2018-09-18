CREATE OR REPLACE FORCE EDITIONABLE VIEW "V_STREAM_HIST" ("JN_UPD_CREATE_DATE", "JN_OPERATION", "JN_ORACLE_USER", "JN_DATETIME", "JN_NOTES", "JN_APPLN", "JN_SESSION", "OBJECT_ID", "OBJECT_CODE", "START_DATE", "END_DATE", "TO_NODE_ID", "FROM_NODE_ID", "FIELD_ID", "PROD_FCTY_ID", "COMP_DAYTIME", "COMPONENT_SET", "MASTER_SYS_CODE", "METER_TAG", "SORT_ORDER", "RECORD_STATUS", "CREATED_BY", "CREATED_DATE", "LAST_UPDATED_BY", "LAST_UPDATED_DATE", "REV_NO", "REV_TEXT", "APPROVAL_BY", "APPROVAL_DATE", "APPROVAL_STATE", "REC_ID") AS 
  (
----------------------------------------------------------------------------------------------------
-- File name: v_stream_hist.sql
-- View name: v_stream_hist
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
	SELECT "JN_UPD_CREATE_DATE","JN_OPERATION","JN_ORACLE_USER","JN_DATETIME","JN_NOTES","JN_APPLN","JN_SESSION","OBJECT_ID","OBJECT_CODE","START_DATE","END_DATE","TO_NODE_ID","FROM_NODE_ID","FIELD_ID","PROD_FCTY_ID","COMP_DAYTIME","COMPONENT_SET","MASTER_SYS_CODE","METER_TAG","SORT_ORDER","RECORD_STATUS","CREATED_BY","CREATED_DATE","LAST_UPDATED_BY","LAST_UPDATED_DATE","REV_NO","REV_TEXT","APPROVAL_BY","APPROVAL_DATE","APPROVAL_STATE","REC_ID" FROM (
	  SELECT
		NVL(LAST_UPDATED_DATE,created_date) jn_upd_create_date
		,'CURRENT' jn_operation
		,NVL(last_updated_by,created_by) jn_oracle_user
		,NVL(LAST_UPDATED_DATE,created_date) jn_datetime
		,'CURRENT' jn_notes
		,NULL jn_appln
		,NULL jn_session
		,stream.*
	  FROM stream
	  UNION
	  SELECT
		nvl(LAST_UPDATED_DATE,created_date) jn_upd_create_date
		,stream_jn.*
	  FROM stream_jn
	)
)