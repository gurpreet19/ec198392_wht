CREATE OR REPLACE FORCE EDITIONABLE VIEW "V_TRANS_INV_SUMMARY_ITEM_HIST" ("JN_OPERATION", "JN_ORACLE_USER", "JN_DATETIME", "JN_NOTES", "JN_APPLN", "JN_SESSION", "OBJECT_ID", "TRANS_INV_ID", "DAYTIME", "END_DATE", "SOURCE_PROD_STREAM_ID", "SOURCE_TRANS_INV_ID", "SOURCE_TRANS_INV_LINE", "REVERSE_IND", "SORT_ORDER", "ID", "LAYER_METHOD", "DIMENSIONS", "PROD_MTH", "TEXT_1", "TEXT_2", "TEXT_3", "TEXT_4", "TEXT_5", "TEXT_6", "TEXT_7", "TEXT_8", "TEXT_9", "TEXT_10", "VALUE_1", "VALUE_2", "VALUE_3", "VALUE_4", "VALUE_5", "VALUE_6", "VALUE_7", "VALUE_8", "VALUE_9", "VALUE_10", "DATE_1", "DATE_2", "DATE_3", "DATE_4", "DATE_5", "DATE_6", "DATE_7", "DATE_8", "DATE_9", "DATE_10", "REF_OBJECT_ID_1", "REF_OBJECT_ID_2", "REF_OBJECT_ID_3", "REF_OBJECT_ID_4", "REF_OBJECT_ID_5", "REF_OBJECT_ID_6", "REF_OBJECT_ID_7", "REF_OBJECT_ID_8", "REF_OBJECT_ID_9", "REF_OBJECT_ID_10", "DIM_SET_ITEM_ID_1", "DIM_SET_ITEM_ID_2", "RECORD_STATUS", "CREATED_BY", "CREATED_DATE", "LAST_UPDATED_BY", "LAST_UPDATED_DATE", "REV_NO", "REV_TEXT", "APPROVAL_BY", "APPROVAL_DATE", "APPROVAL_STATE", "REC_ID") AS 
  (
----------------------------------------------------------------------------------------------------
-- File name: v_trans_inventory_version_hist.sql
-- View name: v_trans_inventory_version_hist
--
-- $Revision: 1.0 $
--
-- Purpose  : combine both Historical and Current version of records.
--
-- Modification history:
--9
-- Date       Whom       Change description:
-- ---------- ----       --------------------------------------------------------------------------------
-- 25.10.2016 hannnyii
----------------------------------------------------------------------------------------------------
     SELECT "JN_OPERATION","JN_ORACLE_USER","JN_DATETIME","JN_NOTES","JN_APPLN","JN_SESSION","OBJECT_ID","TRANS_INV_ID","DAYTIME","END_DATE","SOURCE_PROD_STREAM_ID","SOURCE_TRANS_INV_ID","SOURCE_TRANS_INV_LINE","REVERSE_IND","SORT_ORDER","ID","LAYER_METHOD","DIMENSIONS","PROD_MTH","TEXT_1","TEXT_2","TEXT_3","TEXT_4","TEXT_5","TEXT_6","TEXT_7","TEXT_8","TEXT_9","TEXT_10","VALUE_1","VALUE_2","VALUE_3","VALUE_4","VALUE_5","VALUE_6","VALUE_7","VALUE_8","VALUE_9","VALUE_10","DATE_1","DATE_2","DATE_3","DATE_4","DATE_5","DATE_6","DATE_7","DATE_8","DATE_9","DATE_10","REF_OBJECT_ID_1","REF_OBJECT_ID_2","REF_OBJECT_ID_3","REF_OBJECT_ID_4","REF_OBJECT_ID_5","REF_OBJECT_ID_6","REF_OBJECT_ID_7","REF_OBJECT_ID_8","REF_OBJECT_ID_9","REF_OBJECT_ID_10","DIM_SET_ITEM_ID_1","DIM_SET_ITEM_ID_2","RECORD_STATUS","CREATED_BY","CREATED_DATE","LAST_UPDATED_BY","LAST_UPDATED_DATE","REV_NO","REV_TEXT","APPROVAL_BY","APPROVAL_DATE","APPROVAL_STATE","REC_ID" FROM (
    SELECT
    'CURRENT' jn_operation
    ,NVL(last_updated_by,created_by) jn_oracle_user
    ,Ecdp_Timestamp.getCurrentSysdate jn_datetime
    ,'CURRENT' jn_notes
    ,NULL jn_appln
    ,NULL jn_session
    ,OBJECT_ID
    ,TRANS_INV_ID
    ,DAYTIME
    ,END_DATE
    ,SOURCE_PROD_STREAM_ID
    ,SOURCE_TRANS_INV_ID
    ,SOURCE_TRANS_INV_LINE
    ,REVERSE_IND
    ,SORT_ORDER
    ,ID
    ,LAYER_METHOD
    ,DIMENSIONS
    ,PROD_MTH
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
    ,DIM_SET_ITEM_ID_1
    ,DIM_SET_ITEM_ID_2
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
    FROM trans_inv_summary_item
    UNION
    SELECT
     jn_operation
    ,jn_oracle_user
    ,jn_datetime
    ,jn_notes
    ,jn_appln
    ,jn_session
    ,OBJECT_ID
    ,TRANS_INV_ID
    ,DAYTIME
    ,END_DATE
    ,SOURCE_PROD_STREAM_ID
    ,SOURCE_TRANS_INV_ID
    ,SOURCE_TRANS_INV_LINE
    ,REVERSE_IND
    ,SORT_ORDER
    ,ID
    ,LAYER_METHOD
    ,DIMENSIONS
    ,PROD_MTH
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
    ,DIM_SET_ITEM_ID_1
    ,DIM_SET_ITEM_ID_2
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
    FROM trans_inv_summary_item_jn
  )
)