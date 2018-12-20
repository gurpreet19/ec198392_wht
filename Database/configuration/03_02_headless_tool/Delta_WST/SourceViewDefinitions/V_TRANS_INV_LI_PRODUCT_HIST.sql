CREATE OR REPLACE FORCE EDITIONABLE VIEW "V_TRANS_INV_LI_PRODUCT_HIST" ("JN_OPERATION", "JN_ORACLE_USER", "JN_DATETIME", "JN_NOTES", "JN_APPLN", "JN_SESSION", "OBJECT_ID", "DESCRIPTION", "DAYTIME", "LINE_TAG", "END_DATE", "NAME", "SEQ_NO", "EXEC_ORDER", "VAL_EXEC_ORDER", "QUANTITY_SOURCE_METHOD", "PRORATE_IND", "PRORATE_LINE", "VAL_EXTRACT_TAG", "QTY_EXTRACT_TAG", "VAL_EXTRACT_TYPE", "QTY_EXTRACT_TYPE", "EXTR_VAL_NET_ZERO", "EXTRACT_REVRS_VAL", "EXTRACT_REVRS_QTY", "VALUE_METHOD", "PRODUCT_ID", "COST_TYPE", "TRANS_DEF_DIMENSION", "PRICE_INDEX_ID", "ID", "TEXT_1", "TEXT_2", "TEXT_3", "TEXT_4", "TEXT_5", "TEXT_6", "TEXT_7", "TEXT_8", "TEXT_9", "TEXT_10", "VALUE_1", "VALUE_2", "VALUE_3", "VALUE_4", "VALUE_5", "DATE_1", "DATE_2", "DATE_3", "DATE_4", "DATE_5", "REF_OBJECT_ID_1", "REF_OBJECT_ID_2", "REF_OBJECT_ID_3", "REF_OBJECT_ID_4", "REF_OBJECT_ID_5", "PRORATE_DIM_TO_PROD_ID", "RECORD_STATUS", "CREATED_BY", "CREATED_DATE", "LAST_UPDATED_BY", "LAST_UPDATED_DATE", "REV_NO", "REV_TEXT", "APPROVAL_BY", "APPROVAL_DATE", "APPROVAL_STATE", "REC_ID") AS 
  (
----------------------------------------------------------------------------------------------------
-- File name: V_trans_inv_li_product_HIST.sql
-- View name: V_trans_inv_li_product_HIST
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
  SELECT "JN_OPERATION","JN_ORACLE_USER","JN_DATETIME","JN_NOTES","JN_APPLN","JN_SESSION","OBJECT_ID","DESCRIPTION","DAYTIME","LINE_TAG","END_DATE","NAME","SEQ_NO","EXEC_ORDER","VAL_EXEC_ORDER","QUANTITY_SOURCE_METHOD","PRORATE_IND","PRORATE_LINE","VAL_EXTRACT_TAG","QTY_EXTRACT_TAG","VAL_EXTRACT_TYPE","QTY_EXTRACT_TYPE","EXTR_VAL_NET_ZERO","EXTRACT_REVRS_VAL","EXTRACT_REVRS_QTY","VALUE_METHOD","PRODUCT_ID","COST_TYPE","TRANS_DEF_DIMENSION","PRICE_INDEX_ID","ID","TEXT_1","TEXT_2","TEXT_3","TEXT_4","TEXT_5","TEXT_6","TEXT_7","TEXT_8","TEXT_9","TEXT_10","VALUE_1","VALUE_2","VALUE_3","VALUE_4","VALUE_5","DATE_1","DATE_2","DATE_3","DATE_4","DATE_5","REF_OBJECT_ID_1","REF_OBJECT_ID_2","REF_OBJECT_ID_3","REF_OBJECT_ID_4","REF_OBJECT_ID_5","PRORATE_DIM_TO_PROD_ID","RECORD_STATUS","CREATED_BY","CREATED_DATE","LAST_UPDATED_BY","LAST_UPDATED_DATE","REV_NO","REV_TEXT","APPROVAL_BY","APPROVAL_DATE","APPROVAL_STATE","REC_ID"
  FROM (
		SELECT
		'CURRENT' jn_operation
		,NVL(last_updated_by,created_by) jn_oracle_user
		,sysdate jn_datetime
		,'CURRENT' jn_notes
		,NULL jn_appln
		,NULL jn_session
		,OBJECT_ID
		,DESCRIPTION
		,DAYTIME
		,LINE_TAG
		,END_DATE
		,NAME
		,SEQ_NO
		,EXEC_ORDER
		,VAL_EXEC_ORDER
		,QUANTITY_SOURCE_METHOD
		,PRORATE_IND
		,PRORATE_LINE
		,VAL_EXTRACT_TAG
		,QTY_EXTRACT_TAG
		,VAL_EXTRACT_TYPE
		,QTY_EXTRACT_TYPE
		,EXTR_VAL_NET_ZERO
		,EXTRACT_REVRS_VAL
		,EXTRACT_REVRS_QTY
		,VALUE_METHOD
		,PRODUCT_ID
		,COST_TYPE
		,TRANS_DEF_DIMENSION
		,PRICE_INDEX_ID
		,ID
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
		,PRORATE_DIM_TO_PROD_ID
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
			trans_inv_li_product
		UNION
    SELECT JN_OPERATION
		,JN_ORACLE_USER
		,Ecdp_Date_Time.getCurrentDBSysdate(JN_DATETIME)
		,JN_NOTES
		,JN_APPLN
		,JN_SESSION
		,OBJECT_ID
		,DESCRIPTION
		,DAYTIME
		,LINE_TAG
		,END_DATE
		,NAME
		,SEQ_NO
		,EXEC_ORDER
		,VAL_EXEC_ORDER
		,QUANTITY_SOURCE_METHOD
		,PRORATE_IND
		,PRORATE_LINE
		,VAL_EXTRACT_TAG
		,QTY_EXTRACT_TAG
		,VAL_EXTRACT_TYPE
		,QTY_EXTRACT_TYPE
		,EXTR_VAL_NET_ZERO
		,EXTRACT_REVRS_VAL
		,EXTRACT_REVRS_QTY
		,VALUE_METHOD
		,PRODUCT_ID
		,COST_TYPE
		,TRANS_DEF_DIMENSION
		,PRICE_INDEX_ID
		,ID
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
		,PRORATE_DIM_TO_PROD_ID
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
 FROM
    trans_inv_li_product_jn
  )
)