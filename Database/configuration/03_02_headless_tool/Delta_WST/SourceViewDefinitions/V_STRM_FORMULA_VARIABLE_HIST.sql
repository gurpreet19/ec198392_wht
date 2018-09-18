CREATE OR REPLACE FORCE EDITIONABLE VIEW "V_STRM_FORMULA_VARIABLE_HIST" ("JN_UPD_CREATE_DATE", "JN_OPERATION", "JN_ORACLE_USER", "JN_DATETIME", "JN_NOTES", "JN_APPLN", "JN_SESSION", "FORMULA_NO", "VARIABLE_NAME", "CLASS_NAME", "OBJECT_ID", "OBJECT_METHOD", "COMMENTS", "RECORD_STATUS", "CREATED_BY", "CREATED_DATE", "LAST_UPDATED_BY", "LAST_UPDATED_DATE", "REV_NO", "REV_TEXT", "APPROVAL_BY", "APPROVAL_DATE", "APPROVAL_STATE", "REC_ID") AS 
  (
----------------------------------------------------------------------------------------------------
-- File name: v_strm_formula_variable_hist.sql
-- View name: v_strm_formula_variable_hist
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
	SELECT "JN_UPD_CREATE_DATE","JN_OPERATION","JN_ORACLE_USER","JN_DATETIME","JN_NOTES","JN_APPLN","JN_SESSION","FORMULA_NO","VARIABLE_NAME","CLASS_NAME","OBJECT_ID","OBJECT_METHOD","COMMENTS","RECORD_STATUS","CREATED_BY","CREATED_DATE","LAST_UPDATED_BY","LAST_UPDATED_DATE","REV_NO","REV_TEXT","APPROVAL_BY","APPROVAL_DATE","APPROVAL_STATE","REC_ID" FROM (
	  SELECT
		NVL(LAST_UPDATED_DATE,created_date) jn_upd_create_date
		,'CURRENT' jn_operation
		,NVL(last_updated_by,created_by) jn_oracle_user
		,NVL(LAST_UPDATED_DATE,created_date) jn_datetime
		,'CURRENT' jn_notes
		,NULL jn_appln
		,NULL jn_session
		,STRM_FORMULA_VARIABLE.*
	  FROM STRM_FORMULA_VARIABLE
	  UNION
	  SELECT
		NVL(LAST_UPDATED_DATE,created_date) jn_upd_create_date
		,STRM_FORMULA_VARIABLE_JN.*
	  FROM STRM_FORMULA_VARIABLE_JN
	)
)