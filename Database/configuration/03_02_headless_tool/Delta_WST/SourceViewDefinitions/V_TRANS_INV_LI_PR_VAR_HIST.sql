CREATE OR REPLACE FORCE EDITIONABLE VIEW "V_TRANS_INV_LI_PR_VAR_HIST" ("JN_OPERATION", "JN_ORACLE_USER", "JN_DATETIME", "JN_NOTES", "JN_APPLN", "JN_SESSION", "OBJECT_ID", "PROD_STREAM_ID", "DAYTIME", "LINE_TAG", "VAR_EXEC_ORDER", "PRODUCT_ID", "COST_TYPE", "TRANS_DEF_DIMENSION", "CONFIG_VARIABLE_ID", "END_DATE", "ID", "NAME", "REVERSE_VALUE_IND", "NET_ZERO_IND", "ROUND_IND", "DISABLED_IND", "OVER_IND", "POST_PROCESS_IND", "TYPE", "TEXT_1", "TEXT_2", "TEXT_3", "TEXT_4", "TEXT_5", "TEXT_6", "TEXT_7", "TEXT_8", "TEXT_9", "TEXT_10", "VALUE_1", "VALUE_2", "VALUE_3", "VALUE_4", "VALUE_5", "DATE_1", "DATE_2", "DATE_3", "DATE_4", "DATE_5", "REF_OBJECT_ID_1", "REF_OBJECT_ID_2", "REF_OBJECT_ID_3", "REF_OBJECT_ID_4", "REF_OBJECT_ID_5", "DIMENSION", "RECORD_STATUS", "CREATED_BY", "CREATED_DATE", "LAST_UPDATED_BY", "LAST_UPDATED_DATE", "REV_NO", "REV_TEXT", "APPROVAL_BY", "APPROVAL_DATE", "APPROVAL_STATE", "REC_ID") AS 
  (
----------------------------------------------------------------------------------------------------
-- File name: v_trans_inv_li_pr_var_hist.sql
-- View name: v_trans_inv_li_pr_var_hist
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
  SELECT "JN_OPERATION","JN_ORACLE_USER","JN_DATETIME","JN_NOTES","JN_APPLN","JN_SESSION","OBJECT_ID","PROD_STREAM_ID","DAYTIME","LINE_TAG","VAR_EXEC_ORDER","PRODUCT_ID","COST_TYPE","TRANS_DEF_DIMENSION","CONFIG_VARIABLE_ID","END_DATE","ID","NAME","REVERSE_VALUE_IND","NET_ZERO_IND","ROUND_IND","DISABLED_IND","OVER_IND","POST_PROCESS_IND","TYPE","TEXT_1","TEXT_2","TEXT_3","TEXT_4","TEXT_5","TEXT_6","TEXT_7","TEXT_8","TEXT_9","TEXT_10","VALUE_1","VALUE_2","VALUE_3","VALUE_4","VALUE_5","DATE_1","DATE_2","DATE_3","DATE_4","DATE_5","REF_OBJECT_ID_1","REF_OBJECT_ID_2","REF_OBJECT_ID_3","REF_OBJECT_ID_4","REF_OBJECT_ID_5","DIMENSION","RECORD_STATUS","CREATED_BY","CREATED_DATE","LAST_UPDATED_BY","LAST_UPDATED_DATE","REV_NO","REV_TEXT","APPROVAL_BY","APPROVAL_DATE","APPROVAL_STATE","REC_ID" FROM (
    SELECT
    'CURRENT' jn_operation
    ,NVL(last_updated_by,created_by) jn_oracle_user
    ,sysdate  jn_datetime
    ,'CURRENT' jn_notes
    ,NULL jn_appln
    ,NULL jn_session
    ,trans_inv_li_pr_var.OBJECT_ID
    ,trans_inv_li_pr_var.PROD_STREAM_ID
    ,trans_inv_li_pr_var.DAYTIME
    ,trans_inv_li_pr_var.LINE_TAG
    ,trans_inv_li_pr_var.VAR_EXEC_ORDER
    ,trans_inv_li_pr_var.PRODUCT_ID
    ,trans_inv_li_pr_var.COST_TYPE
    ,trans_inv_li_pr_var.TRANS_DEF_DIMENSION
    ,trans_inv_li_pr_var.CONFIG_VARIABLE_ID
    ,trans_inv_li_pr_var.END_DATE
    ,trans_inv_li_pr_var.ID
    ,trans_inv_li_pr_var.NAME
    ,trans_inv_li_pr_var.REVERSE_VALUE_IND
    ,trans_inv_li_pr_var.NET_ZERO_IND
    ,trans_inv_li_pr_var.ROUND_IND
    ,trans_inv_li_pr_var.POST_PROCESS_IND
    ,trans_inv_li_pr_var.TYPE
    ,trans_inv_li_pr_var.Disabled_Ind
    ,trans_inv_li_pr_var.Over_Ind
    ,trans_inv_li_pr_var.TEXT_1
    ,trans_inv_li_pr_var.TEXT_2
    ,trans_inv_li_pr_var.TEXT_3
    ,trans_inv_li_pr_var.TEXT_4
    ,trans_inv_li_pr_var.TEXT_5
    ,trans_inv_li_pr_var.TEXT_6
    ,trans_inv_li_pr_var.TEXT_7
    ,trans_inv_li_pr_var.TEXT_8
    ,trans_inv_li_pr_var.TEXT_9
    ,trans_inv_li_pr_var.TEXT_10
    ,trans_inv_li_pr_var.VALUE_1
    ,trans_inv_li_pr_var.VALUE_2
    ,trans_inv_li_pr_var.VALUE_3
    ,trans_inv_li_pr_var.VALUE_4
    ,trans_inv_li_pr_var.VALUE_5
    ,trans_inv_li_pr_var.DATE_1
    ,trans_inv_li_pr_var.DATE_2
    ,trans_inv_li_pr_var.DATE_3
    ,trans_inv_li_pr_var.DATE_4
    ,trans_inv_li_pr_var.DATE_5
    ,trans_inv_li_pr_var.REF_OBJECT_ID_1
    ,trans_inv_li_pr_var.REF_OBJECT_ID_2
    ,trans_inv_li_pr_var.REF_OBJECT_ID_3
    ,trans_inv_li_pr_var.REF_OBJECT_ID_4
    ,trans_inv_li_pr_var.REF_OBJECT_ID_5
    ,trans_inv_li_pr_var.DIMENSION
    ,trans_inv_li_pr_var.RECORD_STATUS
    ,trans_inv_li_pr_var.CREATED_BY
    ,trans_inv_li_pr_var.CREATED_DATE
    ,trans_inv_li_pr_var.LAST_UPDATED_BY
    ,trans_inv_li_pr_var.LAST_UPDATED_DATE
    ,trans_inv_li_pr_var.REV_NO
    ,trans_inv_li_pr_var.REV_TEXT
    ,trans_inv_li_pr_var.APPROVAL_BY
    ,trans_inv_li_pr_var.APPROVAL_DATE
    ,trans_inv_li_pr_var.APPROVAL_STATE
    ,trans_inv_li_pr_var.REC_ID
    FROM trans_inv_li_pr_var
    UNION
    SELECT
    jn_operation
    ,jn_oracle_user
    ,Ecdp_Date_Time.getCurrentDBSysdate(jn_datetime)
    ,jn_notes
    ,jn_appln
    ,jn_session
    ,OBJECT_ID
    ,PROD_STREAM_ID
    ,DAYTIME
    ,LINE_TAG
    ,VAR_EXEC_ORDER
    ,PRODUCT_ID
    ,COST_TYPE
    ,TRANS_DEF_DIMENSION
    ,CONFIG_VARIABLE_ID
    ,END_DATE
    ,ID
    ,NAME
    ,REVERSE_VALUE_IND
    ,NET_ZERO_IND
    ,ROUND_IND
    ,POST_PROCESS_IND
    ,TYPE
    ,disabled_ind
    ,Over_Ind
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
    ,DIMENSION
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
    FROM trans_inv_li_pr_var_jn
  )
)