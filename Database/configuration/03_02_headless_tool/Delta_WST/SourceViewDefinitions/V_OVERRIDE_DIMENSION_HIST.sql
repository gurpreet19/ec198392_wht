CREATE OR REPLACE FORCE EDITIONABLE VIEW "V_OVERRIDE_DIMENSION_HIST" ("JN_OPERATION", "JN_ORACLE_USER", "JN_DATETIME", "JN_NOTES", "JN_APPLN", "JN_SESSION", "OBJECT_ID", "PROJECT_ID", "TRANS_INV_ID", "COMMENTS", "DAYTIME", "LINE_TAG", "DIM_SET_ITEM_ID_1", "END_DATE", "DIM_SET_ITEM_ID_2", "DISABLED_IND", "EXEC_ORDER", "TEXT_1", "TEXT_2", "TEXT_3", "TEXT_4", "TEXT_5", "TEXT_6", "TEXT_7", "TEXT_8", "TEXT_9", "TEXT_10", "VALUE_1", "VALUE_2", "VALUE_3", "VALUE_4", "VALUE_5", "VALUE_6", "VALUE_7", "VALUE_8", "VALUE_9", "VALUE_10", "DATE_1", "DATE_2", "DATE_3", "DATE_4", "DATE_5", "DATE_6", "DATE_7", "DATE_8", "DATE_9", "DATE_10", "REF_OBJECT_ID_1", "REF_OBJECT_ID_2", "REF_OBJECT_ID_3", "REF_OBJECT_ID_4", "REF_OBJECT_ID_5", "REF_OBJECT_ID_6", "REF_OBJECT_ID_7", "REF_OBJECT_ID_8", "REF_OBJECT_ID_9", "REF_OBJECT_ID_10", "RECORD_STATUS", "CREATED_BY", "CREATED_DATE", "LAST_UPDATED_BY", "LAST_UPDATED_DATE", "REV_NO", "REV_TEXT", "APPROVAL_BY", "APPROVAL_DATE", "APPROVAL_STATE", "REC_ID") AS 
  (
----------------------------------------------------------------------------------------------------
-- File name: V_OVERRIDE_DIMENSION_HIST.sql
-- View name: V_OVERRIDE_DIMENSION_HIST
--
-- $Revision: 1.0 $
--
-- Purpose  : combine both Historical and Current version of records.
--
-- Modification history:
--9
-- Date       Whom       Change description:
-- ---------- ----       --------------------------------------------------------------------------------
-- 21.12.2017 padekdee
----------------------------------------------------------------------------------------------------
SELECT "JN_OPERATION","JN_ORACLE_USER","JN_DATETIME","JN_NOTES","JN_APPLN","JN_SESSION","OBJECT_ID","PROJECT_ID","TRANS_INV_ID","COMMENTS","DAYTIME","LINE_TAG","DIM_SET_ITEM_ID_1","END_DATE","DIM_SET_ITEM_ID_2","DISABLED_IND","EXEC_ORDER","KEY"/*"VAL_EXEC_ORDER","PRODUCT_SOURCE_METHOD","ROUND_TRANSACTION_IND","ROUND_VALUE_IND","TYPE","CURRENT_PERIOD_ONLY_IND","PRORATE_LINE","REBALANCE_METHOD","XFER_IN_TRANS_ID","XFER_IN_LINE","DIMENSION_TMPL_ID","TRANS_DEF_DIMENSION","DIMENSION_OVER_MONTH_IND","STREAM_ID","POST_PROCESS_IND",*/"TEXT_1","TEXT_2","TEXT_3","TEXT_4","TEXT_5","TEXT_6","TEXT_7","TEXT_8","TEXT_9","TEXT_10","VALUE_1","VALUE_2","VALUE_3","VALUE_4","VALUE_5","VALUE_6","VALUE_7","VALUE_8","VALUE_9","VALUE_10","DATE_1","DATE_2","DATE_3","DATE_4","DATE_5","DATE_6","DATE_7","DATE_8","DATE_9","DATE_10","REF_OBJECT_ID_1","REF_OBJECT_ID_2","REF_OBJECT_ID_3","REF_OBJECT_ID_4","REF_OBJECT_ID_5","REF_OBJECT_ID_6","REF_OBJECT_ID_7","REF_OBJECT_ID_8","REF_OBJECT_ID_9","REF_OBJECT_ID_10","RECORD_STATUS","CREATED_BY","CREATED_DATE","LAST_UPDATED_BY","LAST_UPDATED_DATE","REV_NO","REV_TEXT","APPROVAL_BY","APPROVAL_DATE","APPROVAL_STATE","REC_ID" FROM (
    SELECT
      'CURRENT' jn_operation
      ,NVL(last_updated_by,created_by) jn_oracle_user
      ,sysdate jn_datetime
      ,'CURRENT' jn_notes
      ,NULL jn_appln
      ,NULL jn_session
      ,OBJECT_ID
      ,DAYTIME
      ,END_DATE
      ,PROJECT_ID
      ,TRANS_INV_ID
      ,LINE_TAG
      ,KEY
      ,EXEC_ORDER
      ,DISABLED_IND
      ,COMMENTS
      ,DIM_SET_ITEM_ID_1
      ,DIM_SET_ITEM_ID_2
      ,TEXT_1
      ,TEXT_2
      ,TEXT_3
      ,TEXT_4
      ,TEXT_5
      ,TEXT_6
      ,TEXT_7
      ,TEXT_8
      ,TEXT_9
      ,TEXT_10
      ,VALUE_1
      ,VALUE_2
      ,VALUE_3
      ,VALUE_4
      ,VALUE_5
      ,VALUE_6
      ,VALUE_7
      ,VALUE_8
      ,VALUE_9
      ,VALUE_10
      ,DATE_1
      ,DATE_2
      ,DATE_3
      ,DATE_4
      ,DATE_5
      ,DATE_6
      ,DATE_7
      ,DATE_8
      ,DATE_9
      ,DATE_10
      ,REF_OBJECT_ID_1
      ,REF_OBJECT_ID_2
      ,REF_OBJECT_ID_3
      ,REF_OBJECT_ID_4
      ,REF_OBJECT_ID_5
      ,REF_OBJECT_ID_6
      ,REF_OBJECT_ID_7
      ,REF_OBJECT_ID_8
      ,REF_OBJECT_ID_9
      ,REF_OBJECT_ID_10
      ,RECORD_STATUS
      ,CREATED_BY
      ,CREATED_DATE
      ,LAST_UPDATED_BY
      ,LAST_UPDATED_DATE
      ,REV_NO
      ,REV_TEXT
      ,APPROVAL_BY
      ,APPROVAL_DATE
      ,APPROVAL_STATE
      ,REC_ID
      from
      override_dimension
    UNION
    SELECT
		JN_OPERATION,
		JN_ORACLE_USER,
		Ecdp_Date_Time.getCurrentDBSysdate(JN_DATETIME),
		JN_NOTES,
		JN_APPLN,
		JN_SESSION,
		OBJECT_ID,
		DAYTIME,
		END_DATE,
		PROJECT_ID,
		TRANS_INV_ID,
		LINE_TAG,
		KEY,
		EXEC_ORDER,
		DISABLED_IND,
		COMMENTS,
		DIM_SET_ITEM_ID_1,
		DIM_SET_ITEM_ID_2,
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
		VALUE_6,
		VALUE_7,
		VALUE_8,
		VALUE_9,
		VALUE_10,
		DATE_1,
		DATE_2,
		DATE_3,
		DATE_4,
		DATE_5,
		DATE_6,
		DATE_7,
		DATE_8,
		DATE_9,
		DATE_10,
		REF_OBJECT_ID_1,
		REF_OBJECT_ID_2,
		REF_OBJECT_ID_3,
		REF_OBJECT_ID_4,
		REF_OBJECT_ID_5,
		REF_OBJECT_ID_6,
		REF_OBJECT_ID_7,
		REF_OBJECT_ID_8,
		REF_OBJECT_ID_9,
		REF_OBJECT_ID_10,
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
     FROM
    override_dimension_jn
  )
)