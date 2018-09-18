CREATE OR REPLACE FORCE EDITIONABLE VIEW "V_TRANS_INV_PROD_STREAM_HIST" ("JN_OPERATION", "JN_ORACLE_USER", "JN_DATETIME", "JN_NOTES", "JN_APPLN", "JN_SESSION", "OBJECT_ID", "PROJECT_EXTRACT_ID", "STREAM_EXTRACT_ID", "DAYTIME", "END_DATE", "EXEC_ORDER", "INVENTORY_ID", "COMMENTS", "TEXT_1", "TEXT_2", "TEXT_3", "TEXT_4", "TEXT_5", "TEXT_6", "TEXT_7", "TEXT_8", "TEXT_9", "TEXT_10", "VALUE_1", "VALUE_2", "VALUE_3", "VALUE_4", "VALUE_5", "VALUE_6", "VALUE_7", "VALUE_8", "VALUE_9", "VALUE_10", "DATE_1", "DATE_2", "DATE_3", "DATE_4", "DATE_5", "DATE_6", "DATE_7", "DATE_8", "DATE_9", "DATE_10", "REF_OBJECT_ID_1", "REF_OBJECT_ID_2", "REF_OBJECT_ID_3", "REF_OBJECT_ID_4", "REF_OBJECT_ID_5", "REF_OBJECT_ID_6", "REF_OBJECT_ID_7", "REF_OBJECT_ID_8", "REF_OBJECT_ID_9", "REF_OBJECT_ID_10", "DIM_SET_ITEM_ID_1", "DIM_SET_ITEM_ID_2", "TEMPLATE_SET_ID", "RECORD_STATUS", "CREATED_BY", "CREATED_DATE", "LAST_UPDATED_BY", "LAST_UPDATED_DATE", "REV_NO", "REV_TEXT", "APPROVAL_BY", "APPROVAL_DATE", "APPROVAL_STATE", "REC_ID") AS 
  (
----------------------------------------------------------------------------------------------------
-- File name: v_trans_inv_prod_stream_hist.sql
-- View name: v_trans_inv_prod_stream_hist
--
-- $Revision: 1.0 $
--
-- Purpose  : combine both Historical and Current version of records.
--
-- Modification history:
--
-- Date       Whom       Change description:
-- ---------- ----       --------------------------------------------------------------------------------
-- 25.10.2016 hannnyii
----------------------------------------------------------------------------------------------------
  SELECT "JN_OPERATION","JN_ORACLE_USER","JN_DATETIME","JN_NOTES","JN_APPLN","JN_SESSION","OBJECT_ID","PROJECT_EXTRACT_ID","STREAM_EXTRACT_ID","DAYTIME","END_DATE","EXEC_ORDER","INVENTORY_ID","COMMENTS","TEXT_1","TEXT_2","TEXT_3","TEXT_4","TEXT_5","TEXT_6","TEXT_7","TEXT_8","TEXT_9","TEXT_10","VALUE_1","VALUE_2","VALUE_3","VALUE_4","VALUE_5","VALUE_6","VALUE_7","VALUE_8","VALUE_9","VALUE_10","DATE_1","DATE_2","DATE_3","DATE_4","DATE_5","DATE_6","DATE_7","DATE_8","DATE_9","DATE_10","REF_OBJECT_ID_1","REF_OBJECT_ID_2","REF_OBJECT_ID_3","REF_OBJECT_ID_4","REF_OBJECT_ID_5","REF_OBJECT_ID_6","REF_OBJECT_ID_7","REF_OBJECT_ID_8","REF_OBJECT_ID_9","REF_OBJECT_ID_10","DIM_SET_ITEM_ID_1","DIM_SET_ITEM_ID_2","TEMPLATE_SET_ID","RECORD_STATUS","CREATED_BY","CREATED_DATE","LAST_UPDATED_BY","LAST_UPDATED_DATE","REV_NO","REV_TEXT","APPROVAL_BY","APPROVAL_DATE","APPROVAL_STATE","REC_ID" FROM (
    SELECT
    'CURRENT' jn_operation
    ,NVL(last_updated_by,created_by) jn_oracle_user
    ,sysdate jn_datetime
    ,'CURRENT' jn_notes
    ,NULL jn_appln
    ,NULL jn_session
    ,trans_inv_prod_stream.OBJECT_ID
    ,trans_inv_prod_stream.PROJECT_EXTRACT_ID
    ,trans_inv_prod_stream.STREAM_EXTRACT_ID
    ,trans_inv_prod_stream.DAYTIME
    ,trans_inv_prod_stream.END_DATE
    ,trans_inv_prod_stream.EXEC_ORDER
    ,trans_inv_prod_stream.INVENTORY_ID
    ,trans_inv_prod_stream.COMMENTS
    ,trans_inv_prod_stream.TEXT_1
    ,trans_inv_prod_stream.TEXT_2
    ,trans_inv_prod_stream.TEXT_3
    ,trans_inv_prod_stream.TEXT_4
    ,trans_inv_prod_stream.TEXT_5
    ,trans_inv_prod_stream.TEXT_6
    ,trans_inv_prod_stream.TEXT_7
    ,trans_inv_prod_stream.TEXT_8
    ,trans_inv_prod_stream.TEXT_9
    ,trans_inv_prod_stream.TEXT_10
    ,trans_inv_prod_stream.VALUE_1
    ,trans_inv_prod_stream.VALUE_2
    ,trans_inv_prod_stream.VALUE_3
    ,trans_inv_prod_stream.VALUE_4
    ,trans_inv_prod_stream.VALUE_5
    ,trans_inv_prod_stream.VALUE_6
    ,trans_inv_prod_stream.VALUE_7
    ,trans_inv_prod_stream.VALUE_8
    ,trans_inv_prod_stream.VALUE_9
    ,trans_inv_prod_stream.VALUE_10
    ,trans_inv_prod_stream.DATE_1
    ,trans_inv_prod_stream.DATE_2
    ,trans_inv_prod_stream.DATE_3
    ,trans_inv_prod_stream.DATE_4
    ,trans_inv_prod_stream.DATE_5
    ,trans_inv_prod_stream.DATE_6
    ,trans_inv_prod_stream.DATE_7
    ,trans_inv_prod_stream.DATE_8
    ,trans_inv_prod_stream.DATE_9
    ,trans_inv_prod_stream.DATE_10
    ,trans_inv_prod_stream.REF_OBJECT_ID_1
    ,trans_inv_prod_stream.REF_OBJECT_ID_2
    ,trans_inv_prod_stream.REF_OBJECT_ID_3
    ,trans_inv_prod_stream.REF_OBJECT_ID_4
    ,trans_inv_prod_stream.REF_OBJECT_ID_5
    ,trans_inv_prod_stream.REF_OBJECT_ID_6
    ,trans_inv_prod_stream.REF_OBJECT_ID_7
    ,trans_inv_prod_stream.REF_OBJECT_ID_8
    ,trans_inv_prod_stream.REF_OBJECT_ID_9
    ,trans_inv_prod_stream.REF_OBJECT_ID_10
    ,trans_inv_prod_stream.DIM_SET_ITEM_ID_1
    ,trans_inv_prod_stream.DIM_SET_ITEM_ID_2
    ,trans_inv_prod_stream.TEMPLATE_SET_ID
    ,trans_inv_prod_stream.RECORD_STATUS
    ,trans_inv_prod_stream.CREATED_BY
    ,trans_inv_prod_stream.CREATED_DATE
    ,trans_inv_prod_stream.LAST_UPDATED_BY
    ,trans_inv_prod_stream.LAST_UPDATED_DATE
    ,trans_inv_prod_stream.REV_NO
    ,trans_inv_prod_stream.REV_TEXT
    ,trans_inv_prod_stream.APPROVAL_BY
    ,trans_inv_prod_stream.APPROVAL_DATE
    ,trans_inv_prod_stream.APPROVAL_STATE
    ,trans_inv_prod_stream.REC_ID
    FROM trans_inv_prod_stream
    UNION
    SELECT
	 jn_operation
    ,jn_oracle_user
    ,Ecdp_Date_Time.getCurrentDBSysdate(jn_datetime)
    ,jn_notes
    ,jn_appln
    ,jn_session
    ,trans_inv_prod_stream_jn.OBJECT_ID
    ,trans_inv_prod_stream_jn.PROJECT_EXTRACT_ID
    ,trans_inv_prod_stream_jn.STREAM_EXTRACT_ID
    ,trans_inv_prod_stream_jn.DAYTIME
    ,trans_inv_prod_stream_jn.END_DATE
    ,trans_inv_prod_stream_jn.EXEC_ORDER
    ,trans_inv_prod_stream_jn.INVENTORY_ID
    ,trans_inv_prod_stream_jn.COMMENTS
    ,trans_inv_prod_stream_jn.TEXT_1
    ,trans_inv_prod_stream_jn.TEXT_2
    ,trans_inv_prod_stream_jn.TEXT_3
    ,trans_inv_prod_stream_jn.TEXT_4
    ,trans_inv_prod_stream_jn.TEXT_5
    ,trans_inv_prod_stream_jn.TEXT_6
    ,trans_inv_prod_stream_jn.TEXT_7
    ,trans_inv_prod_stream_jn.TEXT_8
    ,trans_inv_prod_stream_jn.TEXT_9
    ,trans_inv_prod_stream_jn.TEXT_10
    ,trans_inv_prod_stream_jn.VALUE_1
    ,trans_inv_prod_stream_jn.VALUE_2
    ,trans_inv_prod_stream_jn.VALUE_3
    ,trans_inv_prod_stream_jn.VALUE_4
    ,trans_inv_prod_stream_jn.VALUE_5
    ,trans_inv_prod_stream_jn.VALUE_6
    ,trans_inv_prod_stream_jn.VALUE_7
    ,trans_inv_prod_stream_jn.VALUE_8
    ,trans_inv_prod_stream_jn.VALUE_9
    ,trans_inv_prod_stream_jn.VALUE_10
    ,trans_inv_prod_stream_jn.DATE_1
    ,trans_inv_prod_stream_jn.DATE_2
    ,trans_inv_prod_stream_jn.DATE_3
    ,trans_inv_prod_stream_jn.DATE_4
    ,trans_inv_prod_stream_jn.DATE_5
    ,trans_inv_prod_stream_jn.DATE_6
    ,trans_inv_prod_stream_jn.DATE_7
    ,trans_inv_prod_stream_jn.DATE_8
    ,trans_inv_prod_stream_jn.DATE_9
    ,trans_inv_prod_stream_jn.DATE_10
    ,trans_inv_prod_stream_jn.REF_OBJECT_ID_1
    ,trans_inv_prod_stream_jn.REF_OBJECT_ID_2
    ,trans_inv_prod_stream_jn.REF_OBJECT_ID_3
    ,trans_inv_prod_stream_jn.REF_OBJECT_ID_4
    ,trans_inv_prod_stream_jn.REF_OBJECT_ID_5
    ,trans_inv_prod_stream_jn.REF_OBJECT_ID_6
    ,trans_inv_prod_stream_jn.REF_OBJECT_ID_7
    ,trans_inv_prod_stream_jn.REF_OBJECT_ID_8
    ,trans_inv_prod_stream_jn.REF_OBJECT_ID_9
    ,trans_inv_prod_stream_jn.REF_OBJECT_ID_10
    ,trans_inv_prod_stream_jn.DIM_SET_ITEM_ID_1
    ,trans_inv_prod_stream_jn.DIM_SET_ITEM_ID_2
    ,trans_inv_prod_stream_jn.TEMPLATE_SET_ID
    ,trans_inv_prod_stream_jn.RECORD_STATUS
    ,trans_inv_prod_stream_jn.CREATED_BY
    ,trans_inv_prod_stream_jn.CREATED_DATE
    ,trans_inv_prod_stream_jn.LAST_UPDATED_BY
    ,trans_inv_prod_stream_jn.LAST_UPDATED_DATE
    ,trans_inv_prod_stream_jn.REV_NO
    ,trans_inv_prod_stream_jn.REV_TEXT
    ,trans_inv_prod_stream_jn.APPROVAL_BY
    ,trans_inv_prod_stream_jn.APPROVAL_DATE
    ,trans_inv_prod_stream_jn.APPROVAL_STATE
    ,trans_inv_prod_stream_jn.REC_ID
    FROM trans_inv_prod_stream_jn
  )
)