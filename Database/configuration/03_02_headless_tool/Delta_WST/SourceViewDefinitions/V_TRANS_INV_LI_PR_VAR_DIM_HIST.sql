CREATE OR REPLACE FORCE EDITIONABLE VIEW "V_TRANS_INV_LI_PR_VAR_DIM_HIST" ("JN_OPERATION", "JN_ORACLE_USER", "JN_DATETIME", "JN_NOTES", "JN_APPLN", "JN_SESSION", "OBJECT_ID", "PROD_STREAM_ID", "DAYTIME", "LINE_TAG", "VARIABLE_EXEC_ORDER", "PRODUCT_ID", "COST_TYPE", "CONFIG_VARIABLE_ID", "END_DATE", "NAME", "KEY", "DIMENSION", "CONFIG_VARIABLE_PARAM_ID", "TRANS_PARAM_SOURCE_ID", "TEXT", "TEXT_1", "TEXT_2", "TEXT_3", "TEXT_4", "TEXT_5", "TEXT_6", "TEXT_7", "TEXT_8", "TEXT_9", "TEXT_10", "VALUE_1", "VALUE_2", "VALUE_3", "VALUE_4", "VALUE_5", "DATE_1", "DATE_2", "DATE_3", "DATE_4", "DATE_5", "REF_OBJECT_ID_1", "REF_OBJECT_ID_2", "REF_OBJECT_ID_3", "REF_OBJECT_ID_4", "REF_OBJECT_ID_5", "RECORD_STATUS", "CREATED_BY", "CREATED_DATE", "LAST_UPDATED_BY", "LAST_UPDATED_DATE", "REV_NO", "REV_TEXT", "APPROVAL_BY", "APPROVAL_DATE", "APPROVAL_STATE", "REC_ID") AS 
  (
----------------------------------------------------------------------------------------------------
-- File name: v_trans_inv_li_pr_var_dim_hist.sql
-- View name: v_trans_inv_li_pr_var_dim_hist
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
  SELECT "JN_OPERATION","JN_ORACLE_USER","JN_DATETIME","JN_NOTES","JN_APPLN","JN_SESSION","OBJECT_ID","PROD_STREAM_ID","DAYTIME","LINE_TAG","VARIABLE_EXEC_ORDER","PRODUCT_ID","COST_TYPE","CONFIG_VARIABLE_ID","END_DATE","NAME","KEY","DIMENSION","CONFIG_VARIABLE_PARAM_ID","TRANS_PARAM_SOURCE_ID","TEXT","TEXT_1","TEXT_2","TEXT_3","TEXT_4","TEXT_5","TEXT_6","TEXT_7","TEXT_8","TEXT_9","TEXT_10","VALUE_1","VALUE_2","VALUE_3","VALUE_4","VALUE_5","DATE_1","DATE_2","DATE_3","DATE_4","DATE_5","REF_OBJECT_ID_1","REF_OBJECT_ID_2","REF_OBJECT_ID_3","REF_OBJECT_ID_4","REF_OBJECT_ID_5","RECORD_STATUS","CREATED_BY","CREATED_DATE","LAST_UPDATED_BY","LAST_UPDATED_DATE","REV_NO","REV_TEXT","APPROVAL_BY","APPROVAL_DATE","APPROVAL_STATE","REC_ID" FROM (
    SELECT
    'CURRENT' jn_operation
    ,NVL(last_updated_by,created_by) jn_oracle_user
    ,sysdate jn_datetime
    ,'CURRENT' jn_notes
    ,NULL jn_appln
    ,NULL jn_session
    ,trans_inv_li_pr_var_dim.OBJECT_ID
    ,trans_inv_li_pr_var_dim.PROD_STREAM_ID
    ,trans_inv_li_pr_var_dim.DAYTIME
    ,trans_inv_li_pr_var_dim.LINE_TAG
    ,trans_inv_li_pr_var_dim.VARIABLE_EXEC_ORDER
    ,trans_inv_li_pr_var_dim.PRODUCT_ID
    ,trans_inv_li_pr_var_dim.COST_TYPE
    ,trans_inv_li_pr_var_dim.CONFIG_VARIABLE_ID
    ,trans_inv_li_pr_var_dim.END_DATE
    ,trans_inv_li_pr_var_dim.NAME
    ,trans_inv_li_pr_var_dim.KEY
    ,trans_inv_li_pr_var_dim.DIMENSION
    ,trans_inv_li_pr_var_dim.CONFIG_VARIABLE_PARAM_ID
    ,trans_inv_li_pr_var_dim.TRANS_PARAM_SOURCE_ID
    ,trans_inv_li_pr_var_dim.TEXT
    ,trans_inv_li_pr_var_dim.TEXT_1
    ,trans_inv_li_pr_var_dim.TEXT_2
    ,trans_inv_li_pr_var_dim.TEXT_3
    ,trans_inv_li_pr_var_dim.TEXT_4
    ,trans_inv_li_pr_var_dim.TEXT_5
    ,trans_inv_li_pr_var_dim.TEXT_6
    ,trans_inv_li_pr_var_dim.TEXT_7
    ,trans_inv_li_pr_var_dim.TEXT_8
    ,trans_inv_li_pr_var_dim.TEXT_9
    ,trans_inv_li_pr_var_dim.TEXT_10
    ,trans_inv_li_pr_var_dim.VALUE_1
    ,trans_inv_li_pr_var_dim.VALUE_2
    ,trans_inv_li_pr_var_dim.VALUE_3
    ,trans_inv_li_pr_var_dim.VALUE_4
    ,trans_inv_li_pr_var_dim.VALUE_5
    ,trans_inv_li_pr_var_dim.DATE_1
    ,trans_inv_li_pr_var_dim.DATE_2
    ,trans_inv_li_pr_var_dim.DATE_3
    ,trans_inv_li_pr_var_dim.DATE_4
    ,trans_inv_li_pr_var_dim.DATE_5
    ,trans_inv_li_pr_var_dim.REF_OBJECT_ID_1
    ,trans_inv_li_pr_var_dim.REF_OBJECT_ID_2
    ,trans_inv_li_pr_var_dim.REF_OBJECT_ID_3
    ,trans_inv_li_pr_var_dim.REF_OBJECT_ID_4
    ,trans_inv_li_pr_var_dim.REF_OBJECT_ID_5
    ,trans_inv_li_pr_var_dim.RECORD_STATUS
    ,trans_inv_li_pr_var_dim.CREATED_BY
    ,trans_inv_li_pr_var_dim.CREATED_DATE
    ,trans_inv_li_pr_var_dim.LAST_UPDATED_BY
    ,trans_inv_li_pr_var_dim.LAST_UPDATED_DATE
    ,trans_inv_li_pr_var_dim.REV_NO
    ,trans_inv_li_pr_var_dim.REV_TEXT
    ,trans_inv_li_pr_var_dim.APPROVAL_BY
    ,trans_inv_li_pr_var_dim.APPROVAL_DATE
    ,trans_inv_li_pr_var_dim.APPROVAL_STATE
    ,trans_inv_li_pr_var_dim.REC_ID
    FROM trans_inv_li_pr_var_dim
    UNION
    SELECT
    JN_OPERATION
	,JN_ORACLE_USER
	,Ecdp_Date_Time.getCurrentDBSysdate(JN_DATETIME)
	,JN_NOTES
	,JN_APPLN
	,JN_SESSION
	,OBJECT_ID
    ,PROD_STREAM_ID
    ,DAYTIME
    ,LINE_TAG
    ,VARIABLE_EXEC_ORDER
    ,PRODUCT_ID
    ,COST_TYPE
    ,CONFIG_VARIABLE_ID
    ,END_DATE
    ,NAME
    ,KEY
    ,DIMENSION
    ,CONFIG_VARIABLE_PARAM_ID
    ,TRANS_PARAM_SOURCE_ID
    ,TEXT
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
    ,DATE_1
    ,DATE_2
    ,DATE_3
    ,DATE_4
    ,DATE_5
    ,REF_OBJECT_ID_1
    ,REF_OBJECT_ID_2
    ,REF_OBJECT_ID_3
    ,REF_OBJECT_ID_4
    ,REF_OBJECT_ID_5
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
    FROM trans_inv_li_pr_var_dim_jn
  )
)