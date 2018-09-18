CREATE OR REPLACE FORCE EDITIONABLE VIEW "V_COST_MAP_SRC_SETUP_HIST" ("JN_OPERATION", "JN_ORACLE_USER", "JN_DATETIME", "JN_NOTES", "JN_APPLN", "JN_SESSION", "OBJECT_ID", "DAYTIME", "SRC_TYPE", "SRC_CODE", "OPERATOR", "GROUP_NO", "OBJECT_TYPE", "COMMENTS", "TEXT_1", "TEXT_2", "TEXT_3", "TEXT_4", "TEXT_5", "TEXT_6", "TEXT_7", "TEXT_8", "TEXT_9", "TEXT_10", "VALUE_1", "VALUE_2", "VALUE_3", "VALUE_4", "VALUE_5", "DATE_1", "DATE_2", "DATE_3", "DATE_4", "DATE_5", "REF_OBJECT_ID_1", "REF_OBJECT_ID_2", "REF_OBJECT_ID_3", "REF_OBJECT_ID_4", "REF_OBJECT_ID_5", "SPLIT_KEY_SOURCE", "RECORD_STATUS", "CREATED_BY", "CREATED_DATE", "LAST_UPDATED_BY", "LAST_UPDATED_DATE", "REV_NO", "REV_TEXT", "APPROVAL_BY", "APPROVAL_DATE", "APPROVAL_STATE", "REC_ID") AS 
  (
----------------------------------------------------------------------------------------------------
-- File name: v_cost_map_src_setup_hist.sql
-- View name: v_cost_map_src_setup_hist
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
-- 26.03.2018 fladebre   Changed from "Including" to "To" based "end-date" handling for historical/journal rows by adding 1 sec to the CURRENT rows.
---------------------------------------------------------------------------------------------------------
SELECT "JN_OPERATION","JN_ORACLE_USER","JN_DATETIME","JN_NOTES","JN_APPLN","JN_SESSION","OBJECT_ID","DAYTIME","SRC_TYPE","SRC_CODE","OPERATOR","GROUP_NO","OBJECT_TYPE","COMMENTS","TEXT_1","TEXT_2","TEXT_3","TEXT_4","TEXT_5","TEXT_6","TEXT_7","TEXT_8","TEXT_9","TEXT_10","VALUE_1","VALUE_2","VALUE_3","VALUE_4","VALUE_5","DATE_1","DATE_2","DATE_3","DATE_4","DATE_5","REF_OBJECT_ID_1","REF_OBJECT_ID_2","REF_OBJECT_ID_3","REF_OBJECT_ID_4","REF_OBJECT_ID_5","SPLIT_KEY_SOURCE","RECORD_STATUS","CREATED_BY","CREATED_DATE","LAST_UPDATED_BY","LAST_UPDATED_DATE","REV_NO","REV_TEXT","APPROVAL_BY","APPROVAL_DATE","APPROVAL_STATE","REC_ID" FROM (
    SELECT
        'CURRENT' jn_operation
        ,NVL(last_updated_by,created_by) jn_oracle_user
        ,Ecdp_Timestamp.getCurrentSysdate + INTERVAL '1' SECOND jn_datetime
        ,'CURRENT' jn_notes
        ,NULL jn_appln
        ,NULL jn_session
        ,OBJECT_ID,
		DAYTIME,
		SRC_TYPE,
		SRC_CODE,
		OPERATOR,
		GROUP_NO,
		OBJECT_TYPE,
		COMMENTS,
		TEXT_1,
		TEXT_2,
		TEXT_3,
		TEXT_4,
		TEXT_5,
		TEXT_6,
		TEXT_7,
		TEXT_8,
		TEXT_9,
		TEXT_10,
		VALUE_1,
		VALUE_2,
		VALUE_3,
		VALUE_4,
		VALUE_5,
		DATE_1,
		DATE_2,
		DATE_3,
		DATE_4,
		DATE_5,
		REF_OBJECT_ID_1,
		REF_OBJECT_ID_2,
		REF_OBJECT_ID_3,
		REF_OBJECT_ID_4,
		REF_OBJECT_ID_5,
		SPLIT_KEY_SOURCE,
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
    FROM COST_MAPPING_SRC_SETUP
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
		SRC_TYPE,
		SRC_CODE,
		OPERATOR,
		GROUP_NO,
		OBJECT_TYPE,
		COMMENTS,
		TEXT_1,
		TEXT_2,
		TEXT_3,
		TEXT_4,
		TEXT_5,
		TEXT_6,
		TEXT_7,
		TEXT_8,
		TEXT_9,
		TEXT_10,
		VALUE_1,
		VALUE_2,
		VALUE_3,
		VALUE_4,
		VALUE_5,
		DATE_1,
		DATE_2,
		DATE_3,
		DATE_4,
		DATE_5,
		REF_OBJECT_ID_1,
		REF_OBJECT_ID_2,
		REF_OBJECT_ID_3,
		REF_OBJECT_ID_4,
		REF_OBJECT_ID_5,
		SPLIT_KEY_SOURCE,
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
    FROM COST_MAPPING_SRC_SETUP_JN
  )
)