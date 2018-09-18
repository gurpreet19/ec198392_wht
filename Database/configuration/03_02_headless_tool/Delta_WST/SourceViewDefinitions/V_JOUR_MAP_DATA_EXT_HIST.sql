CREATE OR REPLACE FORCE EDITIONABLE VIEW "V_JOUR_MAP_DATA_EXT_HIST" ("JN_OPERATION", "JN_ORACLE_USER", "JN_DATETIME", "JN_NOTES", "JN_APPLN", "JN_SESSION", "OBJECT_ID", "DAYTIME", "REVN_DATA_FILTER_ID", "EXTRACT_VALUE_TYPE", "EXTRACT_ATTRIBUTE", "RECORD_STATUS", "CREATED_BY", "CREATED_DATE", "LAST_UPDATED_BY", "LAST_UPDATED_DATE", "REV_NO", "REV_TEXT", "APPROVAL_BY", "APPROVAL_DATE", "APPROVAL_STATE", "REC_ID") AS 
  (
----------------------------------------------------------------------------------------------------
-- File name: v_JOUR_MAP_DATA_EXT_HIST.sql
-- View name: v_JOUR_MAP_DATA_EXT_HIST
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
  SELECT "JN_OPERATION","JN_ORACLE_USER","JN_DATETIME","JN_NOTES","JN_APPLN","JN_SESSION","OBJECT_ID","DAYTIME","REVN_DATA_FILTER_ID","EXTRACT_VALUE_TYPE","EXTRACT_ATTRIBUTE","RECORD_STATUS","CREATED_BY","CREATED_DATE","LAST_UPDATED_BY","LAST_UPDATED_DATE","REV_NO","REV_TEXT","APPROVAL_BY","APPROVAL_DATE","APPROVAL_STATE","REC_ID" FROM (
    SELECT
    'CURRENT' jn_operation
    ,NVL(last_updated_by,created_by) jn_oracle_user
    ,Ecdp_Timestamp.getCurrentSysdate jn_datetime
    ,'CURRENT' jn_notes
    ,NULL jn_appln
    ,NULL jn_session
    ,OBJECT_ID,
	DAYTIME,
	REVN_DATA_FILTER_ID,
	EXTRACT_VALUE_TYPE,
	EXTRACT_ATTRIBUTE,
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
    FROM JOURNAL_MAPPING_DATA_EXT
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
	REVN_DATA_FILTER_ID,
	EXTRACT_VALUE_TYPE,
	EXTRACT_ATTRIBUTE,
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
    FROM JOURNAL_MAPPING_DATA_EXT_JN
  )
)