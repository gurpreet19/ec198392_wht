CREATE OR REPLACE FORCE EDITIONABLE VIEW "V_TRANS_INV_SKIP_VAR" ("OBJECT_ID", "DAYTIME", "PROJECT_ID", "PRODUCT_ID", "TRANS_PROD_SET_ITEM_ID", "COST_TYPE", "LINE_TAG", "VARIABLE_ID", "RECORD_STATUS", "CREATED_BY", "CREATED_DATE", "LAST_UPDATED_BY", "LAST_UPDATED_DATE", "REV_NO", "REV_TEXT", "APPROVAL_BY", "APPROVAL_DATE", "APPROVAL_STATE", "VAR_EXEC_ORDER", "REC_ID", "VAR_KEY", "SKIP") AS 
  SELECT tilpv.object_id object_id,
       sd.daytime daytime,
       tilpv.Prod_Stream_Id project_id,
       tilpv.product_id,
       tilpv.product_id || '|' || COST_TYPE TRANS_PROD_SET_ITEM_ID,
       tilpv.cost_type,
       tilpv.line_tag,
       tilpv.config_variable_id variable_id,
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
       tilpv.exec_order var_exec_order,
       tilpv.REC_ID,
       PROD_STREAM_ID || '|' || EXEC_ORDER || '|' || CONFIG_VARIABLE_ID || '|' ||
       tilpv.product_id || '|' || COST_TYPE var_key,
       'YES' Skip
  FROM (select distinct daytime from System_Mth_Status) sd,
       (select object_id          object_id,
               Prod_Stream_Id,
               product_id,
               cost_type,
               line_tag,
               daytime,
               end_date,
               config_variable_id,
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
               var_exec_order     exec_order,
               REC_ID
          from trans_inv_li_pr_var
        union all
        select tips.inventory_id        object_id,
               tips.object_ID           Prod_Stream_Id,
               product_id,
               COST_TYPE,
               line_tag,
               tilpvx.daytime,
               tilpvx.end_date,
               config_variable_id       variable_id,
               tilpvx.RECORD_STATUS,
               tilpvx.CREATED_BY,
               tilpvx.CREATED_DATE,
               tilpvx.LAST_UPDATED_BY,
               tilpvx.LAST_UPDATED_DATE,
               tilpvx.REV_NO,
               tilpvx.REV_TEXT,
               tilpvx.APPROVAL_BY,
               tilpvx.APPROVAL_DATE,
               tilpvx.APPROVAL_STATE,
               var_exec_order,
               tilpvx.REC_ID
          from trans_inv_li_pr_var     tilpvx,
               trans_inv_prod_stream   tips,
               trans_inventory_version tiv,
               trans_inv_prod_stream   tips_template
         where tips_template.inventory_id = tilpvx.object_id --Inventory Template
           and tiv.config_template = tips_template.inventory_id -- Inventory Template
           and tiv.object_id = tips.inventory_id -- None Template Inventory
           and not exists (select object_id
                  from trans_inv_li_pr_var
                 where object_id = tiv.object_id
                   and prod_stream_id = tips.object_id
                   and id = tilpvx.id)) tilpv,
       config_variable tv
 WHERE tilpv.DAYTIME <= sd.daytime
   and nvl(tilpv.end_date, sd.daytime + 1) > sd.daytime
   and tilpv.DAYTIME <= sd.daytime
   and nvl(tilpv.end_date, sd.daytime + 1) > sd.daytime
   and nvl(tv.end_date, sd.daytime + 1) > sd.daytime
   and tv.object_id = tilpv.config_variable_id
   AND ecdp_trans_inventory.SkipVariable(tilpv.Prod_Stream_Id,
                                         tilpv.object_id,
                                         sd.daytime,
                                         tilpv.product_id,
                                         tilpv.cost_type,
                                         tilpv.line_tag,
                                         tilpv.EXEC_ORDER,
                                         tilpv.config_variable_id) = 'YES'