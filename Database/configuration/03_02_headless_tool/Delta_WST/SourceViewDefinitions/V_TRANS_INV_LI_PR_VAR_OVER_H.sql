CREATE OR REPLACE FORCE EDITIONABLE VIEW "V_TRANS_INV_LI_PR_VAR_OVER_H" ("OBJECT_ID", "PROD_STREAM_ID", "DAYTIME", "LINE_TAG", "VAR_EXEC_ORDER", "PRODUCT_ID", "COST_TYPE", "CONFIG_VARIABLE_ID", "END_DATE", "NAME", "REVERSE_VALUE_IND", "NET_ZERO_IND", "ROUND_IND", "ID", "TYPE", "TEXT_1", "TEXT_2", "TEXT_3", "TEXT_4", "TEXT_5", "TEXT_6", "TEXT_7", "TEXT_8", "TEXT_9", "TEXT_10", "VALUE_1", "VALUE_2", "VALUE_3", "VALUE_4", "VALUE_5", "DATE_1", "DATE_2", "DATE_3", "DATE_4", "DATE_5", "REF_OBJECT_ID_1", "REF_OBJECT_ID_2", "REF_OBJECT_ID_3", "REF_OBJECT_ID_4", "REF_OBJECT_ID_5", "DIMENSION", "TRANS_DEF_DIMENSION", "RECORD_STATUS", "CREATED_BY", "CREATED_DATE", "LAST_UPDATED_BY", "LAST_UPDATED_DATE", "REV_NO", "REV_TEXT", "APPROVAL_BY", "APPROVAL_DATE", "APPROVAL_STATE", "REC_ID", "POST_PROCESS_IND", "COPY_IND", "OVER_IND", "DISABLED_IND", "JN_DATETIME", "JN_OPERATION") AS 
  select tilpv.OBJECT_ID,
       tilpv.PROD_STREAM_ID,
       tilpv.DAYTIME,
       tilpv.LINE_TAG,
       tilpv.VAR_EXEC_ORDER,
       tilpv.PRODUCT_ID,
       tilpv.COST_TYPE,
       tilpv.CONFIG_VARIABLE_ID,
       tilpv.END_DATE,
       tilpv.NAME,
       tilpv.REVERSE_VALUE_IND,
       tilpv.NET_ZERO_IND,
       tilpv.ROUND_IND,
       tilpv.ID,
       tilpv.TYPE,
       tilpv.TEXT_1,
       tilpv.TEXT_2,
       tilpv.TEXT_3,
       tilpv.TEXT_4,
       tilpv.TEXT_5,
       tilpv.TEXT_6,
       tilpv.TEXT_7,
       tilpv.TEXT_8,
       tilpv.TEXT_9,
       tilpv.TEXT_10,
       tilpv.VALUE_1,
       tilpv.VALUE_2,
       tilpv.VALUE_3,
       tilpv.VALUE_4,
       tilpv.VALUE_5,
       tilpv.DATE_1,
       tilpv.DATE_2,
       tilpv.DATE_3,
       tilpv.DATE_4,
       tilpv.DATE_5,
       tilpv.REF_OBJECT_ID_1,
       tilpv.REF_OBJECT_ID_2,
       tilpv.REF_OBJECT_ID_3,
       tilpv.REF_OBJECT_ID_4,
       tilpv.REF_OBJECT_ID_5,
       tilpv.DIMENSION,
       tilpv.TRANS_DEF_DIMENSION,
       tilpv.RECORD_STATUS,
       tilpv.CREATED_BY,
       tilpv.CREATED_DATE,
       tilpv.LAST_UPDATED_BY,
       tilpv.LAST_UPDATED_DATE,
       tilpv.REV_NO,
       tilpv.REV_TEXT,
       tilpv.APPROVAL_BY,
       tilpv.APPROVAL_DATE,
       tilpv.APPROVAL_STATE,
       tilpv.REC_ID,
       tilpv.POST_PROCESS_IND
       ,'N' COPY_IND
       ,tilpv.OVER_IND
       ,tilpv.disabled_ind
       ,tilpv.JN_DATETIME
       ,tilpv.JN_OPERATION
  from V_TRANS_INV_LI_PR_VAR_HIST     tilpv
 union
select tips.inventory_id OBJECT_ID,
       tips.object_ID,
       tilpv.DAYTIME,
       tilpv.LINE_TAG,
       tilpv.VAR_EXEC_ORDER,
       tilpv.PRODUCT_ID,
       tilpv.COST_TYPE,
       tilpv.CONFIG_VARIABLE_ID,
       tilpv.END_DATE,
       tilpv.NAME,
       tilpv.REVERSE_VALUE_IND,
       tilpv.NET_ZERO_IND,
       tilpv.ROUND_IND,
       tilpv.ID,
       tilpv.TYPE,
       tilpv.TEXT_1,
       tilpv.TEXT_2,
       tilpv.TEXT_3,
       tilpv.TEXT_4,
       tilpv.TEXT_5,
       tilpv.TEXT_6,
       tilpv.TEXT_7,
       tilpv.TEXT_8,
       tilpv.TEXT_9,
       tilpv.TEXT_10,
       tilpv.VALUE_1,
       tilpv.VALUE_2,
       tilpv.VALUE_3,
       tilpv.VALUE_4,
       tilpv.VALUE_5,
       tilpv.DATE_1,
       tilpv.DATE_2,
       tilpv.DATE_3,
       tilpv.DATE_4,
       tilpv.DATE_5,
       tilpv.REF_OBJECT_ID_1,
       tilpv.REF_OBJECT_ID_2,
       tilpv.REF_OBJECT_ID_3,
       tilpv.REF_OBJECT_ID_4,
       tilpv.REF_OBJECT_ID_5,
       tilpv.DIMENSION,
       tilpv.TRANS_DEF_DIMENSION,
       tilpv.RECORD_STATUS,
       tilpv.CREATED_BY,
       tilpv.CREATED_DATE,
       tilpv.LAST_UPDATED_BY,
       tilpv.LAST_UPDATED_DATE,
       tilpv.REV_NO,
       tilpv.REV_TEXT,
       tilpv.APPROVAL_BY,
       tilpv.APPROVAL_DATE,
       tilpv.APPROVAL_STATE,
       tilpv.REC_ID,
       tilpv.POST_PROCESS_IND
       ,'Y' COPY_IND
       ,tilpv.OVER_IND
       ,tilpv.DISABLED_IND
       ,sysdate jn_datetime
       ,tilpv.JN_OPERATION
  from V_TRANS_INV_LI_PR_VAR_HIST     tilpv,
       v_trans_inv_prod_stream_hist   tips,
       v_trans_inventory_history tiv,
       v_trans_inv_prod_stream_hist   tips_template
 where tips_template.inventory_id = tilpv.object_id --Inventory Template
   and tiv.config_template =tips_template.inventory_id -- Inventory Template
   and tiv.object_id = tips.inventory_id -- None Template Inventory
   and not exists
       (select object_id from V_TRANS_INV_LI_PR_VAR_HIST v1
               where v1.object_id = tiv.object_id
               and v1.prod_stream_id = tips.object_id
               and v1.id = tilpv.id
               and v1.JN_DATETIME= (select MAX(v2.JN_DATETIME) from V_TRANS_INV_LI_PR_VAR_HIST v2
                                                     where v2.object_id = tiv.object_id
                                                     and v2.prod_stream_id = tips.object_id
                                                     and id = tilpv.id)
                and v1.JN_OPERATION <> 'DEL')