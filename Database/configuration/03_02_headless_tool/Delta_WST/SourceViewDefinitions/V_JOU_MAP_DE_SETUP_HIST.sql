CREATE OR REPLACE FORCE EDITIONABLE VIEW "V_JOU_MAP_DE_SETUP_HIST" ("JN_OPERATION", "JN_ORACLE_USER", "JN_DATETIME", "JN_NOTES", "JN_APPLN", "JN_SESSION", "OBJECT_ID", "DAYTIME", "PARAMETER_NAME", "VALUE_CATEGORY", "VALUE", "RECORD_STATUS", "CREATED_BY", "CREATED_DATE", "LAST_UPDATED_BY", "LAST_UPDATED_DATE", "REV_NO", "REV_TEXT", "APPROVAL_BY", "APPROVAL_DATE", "APPROVAL_STATE", "REC_ID") AS 
  (
----------------------------------------------------------------------------------------------------
-- File name: v_JOU_MAP_DE_SETUP_HIST.sql
-- View name: v_JOU_MAP_DE_SETUP_HIST
--
-- $Revision: 1.0 $
--
-- Purpose  : combine both Historical and Current version of records.
--
-- Modification history:
--9
-- Date       Whom       Change description:
-- ---------- ----       --------------------------------------------------------------------------------
-- 14.09.2016 lewisbra
----------------------------------------------------------------------------------------------------
  SELECT "JN_OPERATION","JN_ORACLE_USER","JN_DATETIME","JN_NOTES","JN_APPLN","JN_SESSION","OBJECT_ID","DAYTIME","PARAMETER_NAME","VALUE_CATEGORY","VALUE","RECORD_STATUS","CREATED_BY","CREATED_DATE","LAST_UPDATED_BY","LAST_UPDATED_DATE","REV_NO","REV_TEXT","APPROVAL_BY","APPROVAL_DATE","APPROVAL_STATE","REC_ID" FROM (
    SELECT
    'CURRENT' jn_operation
    ,NVL(last_updated_by,created_by) jn_oracle_user
    ,Ecdp_Timestamp.getCurrentSysdate + INTERVAL '1' SECOND jn_datetime
    ,'CURRENT' jn_notes
    ,NULL jn_appln
    ,NULL jn_session
    ,OBJECT_ID,
	DAYTIME,
	PARAMETER_NAME,
	VALUE_CATEGORY,
	VALUE,
	RECORD_STATUS,
	CREATED_BY,
	CREATED_DATE,
	LAST_UPDATED_BY,
	LAST_UPDATED_DATE,
	REV_NO,
	REV_TEXT,
	APPROVAL_BY,
	APPROVAL_DATE,
	APPROVAL_STATE,
	REC_ID
    FROM JOURNAL_MAP_DATA_EXT_SETUP t
    UNION
    SELECT
	jn_operation
    ,jn_oracle_user
    ,jn_datetime
    ,jn_notes
    ,jn_appln
    ,jn_session
    ,OBJECT_ID,
	DAYTIME,
	PARAMETER_NAME,
	VALUE_CATEGORY,
	VALUE,
	RECORD_STATUS,
	CREATED_BY,
	CREATED_DATE,
	LAST_UPDATED_BY,
	LAST_UPDATED_DATE,
	REV_NO,
	REV_TEXT,
	APPROVAL_BY,
	APPROVAL_DATE,
	APPROVAL_STATE,
	REC_ID
    FROM JOURNAL_MAP_DATA_EXT_SETUP_JN tjn
  )
)