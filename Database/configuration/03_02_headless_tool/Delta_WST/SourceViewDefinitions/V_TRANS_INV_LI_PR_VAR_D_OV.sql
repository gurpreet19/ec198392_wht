CREATE OR REPLACE FORCE EDITIONABLE VIEW "V_TRANS_INV_LI_PR_VAR_D_OV" ("OBJECT_ID", "DAYTIME", "LINE_TAG", "VARIABLE_EXEC_ORDER", "PRODUCT_ID", "COST_TYPE", "CONFIG_VARIABLE_ID", "END_DATE", "NAME", "KEY", "DIMENSION", "CONFIG_VARIABLE_PARAM_ID", "PROD_STREAM_ID", "TRANS_PARAM_SOURCE_ID", "TEXT", "TEXT_1", "TEXT_2", "TEXT_3", "TEXT_4", "TEXT_5", "TEXT_6", "TEXT_7", "TEXT_8", "TEXT_9", "TEXT_10", "VALUE_1", "VALUE_2", "VALUE_3", "VALUE_4", "VALUE_5", "DATE_1", "DATE_2", "DATE_3", "DATE_4", "DATE_5", "REF_OBJECT_ID_1", "REF_OBJECT_ID_2", "REF_OBJECT_ID_3", "REF_OBJECT_ID_4", "REF_OBJECT_ID_5", "RECORD_STATUS", "CREATED_BY", "CREATED_DATE", "LAST_UPDATED_BY", "LAST_UPDATED_DATE", "REV_NO", "REV_TEXT", "APPROVAL_BY", "APPROVAL_DATE", "APPROVAL_STATE", "REC_ID", "COPY_IND") AS 
  SELECT tilpvp.OBJECT_ID,
       tilpvp.DAYTIME,
       tilpvp.LINE_TAG,
       tilpvp.VARIABLE_EXEC_ORDER,
       tilpvp.PRODUCT_ID,
       tilpvp.COST_TYPE,
       tilpvp.CONFIG_VARIABLE_ID,
       tilpvp.END_DATE,
       tilpvp.NAME,
       tilpvp.KEY,
       tilpvp.DIMENSION,
       tilpvp.CONFIG_VARIABLE_PARAM_ID,
       tilpvp.PROD_STREAM_ID,
       tilpvp.TRANS_PARAM_SOURCE_ID,
       tilpvp.TEXT,
       tilpvp.TEXT_1,
       tilpvp.TEXT_2,
       tilpvp.TEXT_3,
       tilpvp.TEXT_4,
       tilpvp.TEXT_5,
       tilpvp.TEXT_6,
       tilpvp.TEXT_7,
       tilpvp.TEXT_8,
       tilpvp.TEXT_9,
       tilpvp.TEXT_10,
       tilpvp.VALUE_1,
       tilpvp.VALUE_2,
       tilpvp.VALUE_3,
       tilpvp.VALUE_4,
       tilpvp.VALUE_5,
       tilpvp.DATE_1,
       tilpvp.DATE_2,
       tilpvp.DATE_3,
       tilpvp.DATE_4,
       tilpvp.DATE_5,
       tilpvp.REF_OBJECT_ID_1,
       tilpvp.REF_OBJECT_ID_2,
       tilpvp.REF_OBJECT_ID_3,
       tilpvp.REF_OBJECT_ID_4,
       tilpvp.REF_OBJECT_ID_5,
       tilpvp.RECORD_STATUS,
       tilpvp.CREATED_BY,
       tilpvp.CREATED_DATE,
       tilpvp.LAST_UPDATED_BY,
       tilpvp.LAST_UPDATED_DATE,
       tilpvp.REV_NO,
       tilpvp.REV_TEXT,
       tilpvp.APPROVAL_BY,
       tilpvp.APPROVAL_DATE,
       tilpvp.APPROVAL_STATE,
       tilpvp.REC_ID
       ,'N' COPY_IND
  from trans_inv_li_pr_var_dim tilpvp
union
select tips.INVENTORY_ID,
      tilpvp.DAYTIME,
       tilpvp.LINE_TAG,
       tilpvp.VARIABLE_EXEC_ORDER,
       tilpvp.PRODUCT_ID,
       tilpvp.COST_TYPE,
       tilpvp.CONFIG_VARIABLE_ID,
       tilpvp.END_DATE,
       tilpvp.NAME,
       tilpvp.KEY,
       tilpvp.DIMENSION,
       tilpvp.CONFIG_VARIABLE_PARAM_ID,
       tips.object_ID,
       tilpvp.TRANS_PARAM_SOURCE_ID,
       tilpvp.TEXT,
       tilpvp.TEXT_1,
       tilpvp.TEXT_2,
       tilpvp.TEXT_3,
       tilpvp.TEXT_4,
       tilpvp.TEXT_5,
       tilpvp.TEXT_6,
       tilpvp.TEXT_7,
       tilpvp.TEXT_8,
       tilpvp.TEXT_9,
       tilpvp.TEXT_10,
       tilpvp.VALUE_1,
       tilpvp.VALUE_2,
       tilpvp.VALUE_3,
       tilpvp.VALUE_4,
       tilpvp.VALUE_5,
       tilpvp.DATE_1,
       tilpvp.DATE_2,
       tilpvp.DATE_3,
       tilpvp.DATE_4,
       tilpvp.DATE_5,
       tilpvp.REF_OBJECT_ID_1,
       tilpvp.REF_OBJECT_ID_2,
       tilpvp.REF_OBJECT_ID_3,
       tilpvp.REF_OBJECT_ID_4,
       tilpvp.REF_OBJECT_ID_5,
       tilpvp.RECORD_STATUS,
       tilpvp.CREATED_BY,
       tilpvp.CREATED_DATE,
       tilpvp.LAST_UPDATED_BY,
       tilpvp.LAST_UPDATED_DATE,
       tilpvp.REV_NO,
       tilpvp.REV_TEXT,
       tilpvp.APPROVAL_BY,
       tilpvp.APPROVAL_DATE,
       tilpvp.APPROVAL_STATE,
       tilpvp.REC_ID
       ,'Y' COPY_IND
  from trans_inv_li_pr_var     tilpv,
       trans_inv_prod_stream   tips,
       trans_inventory_version tiv,
       trans_inv_prod_stream   tips_template,
       trans_inv_li_pr_var_dim tilpvp
 where tips_template.inventory_id = tilpv.object_id --Inventory Template
   and tiv.config_template = tips_template.inventory_id -- Inventory Template
   and tiv.object_id = tips.inventory_id -- None Template Inventory
   and (tilpvp.config_variable_id = tilpv.config_variable_id
       and tilpvp.object_id = tilpv.object_id
       and tilpvp.daytime = tilpv.daytime
       and tilpvp.prod_stream_id = tilpv.prod_stream_id
       and tilpvp.product_id = tilpv.product_id
       and tilpvp.cost_type = tilpv.cost_type
       and tilpvp.line_tag = tilpv.line_tag
       and tilpvp.variable_exec_order = tilpv.var_exec_order
       )
   and not exists (select object_id
          from trans_inv_li_pr_var
         where object_id = tiv.object_id
           and prod_stream_id = tips.object_id
           and id = tilpv.id)