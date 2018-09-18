CREATE OR REPLACE FORCE EDITIONABLE VIEW "V_DIMENSION_ITEMS_LINE_HIST" ("DIM_OBJECT_ID", "DIM_ITEM_1", "DIM_ITEM_2", "DIM_ITEM_ID_1", "DIM_ITEM_ID_2", "DIM_SET_1", "DIM_SET_2", "END_DATE", "EXEC_ORDER", "DEFAULT_EXEC", "GROUP_ID", "DAYTIME", "JN_DATETIME", "CONTRACT_ID", "OBJECT_ID", "TAG", "RECORD_STATUS", "CREATED_BY", "CREATED_DATE", "LAST_UPDATED_BY", "LAST_UPDATED_DATE", "REV_NO", "REV_TEXT", "COMMENTS", "DISABLED_IND") AS 
  SELECT tdgs1.dim_code || '|' || tdgs2.dim_code AS DIM_OBJECT_ID,
       tdgs1.dim_code DIM_ITEM_1,
       tdgs2.dim_code DIM_ITEM_2,
       tdgs1.dim_code DIM_ITEM_ID_1,
       tdgs2.dim_code DIM_ITEM_ID_2,
       NULL DIM_SET_1,
       NULL DIM_SET_2,
       add_months(sm.daytime,1)-1 end_date,
       tdgs1.ATTRIBUTE_NUMBER * 10000 + tdgs2.ATTRIBUTE_NUMBER EXEC_ORDER,
       tdgs1.ATTRIBUTE_NUMBER * 10000 + tdgs2.ATTRIBUTE_NUMBER default_exec,
       NULL as group_id,
       sm.daytime,
       tip.jn_datetime jn_datetime,
       tip.object_id contract_id,
       tip.inventory_id object_id,
       til.tag,
       tip.record_status,
       tip.created_by,
       tip.created_date,
       tip.last_updated_by,
       tip.last_updated_date,
       tip.rev_no,
       tip.rev_text,
       tip.comments,
       'N' disabled_ind
  FROM (SELECT X.* FROM CNTR_ATTR_DIMENSION X WHERE ATTRIBUTE_NAME='TRANS_INV_DIM_1') tdgs1,
       (SELECT X.* FROM CNTR_ATTR_DIMENSION X WHERE ATTRIBUTE_NAME='TRANS_INV_DIM_2') tdgs2,
       (SELECT DISTINCT DAYTIME FROM SYSTEM_MTH_STATUS) sm,
       v_trans_inv_prod_stream_hist tip,
       TRANS_INV_LINE_OVERRIDE til
 WHERE tip.object_id = tdgs1.object_id
   AND tip.object_id = tdgs2.object_id
   AND sm.daytime < nvl(tdgs1.end_date,sm.daytime+1)
   AND sm.daytime >= tdgs1.daytime
   AND sm.daytime < nvl(tdgs2.end_date,sm.daytime+1)
   AND sm.daytime >= tdgs1.daytime
   AND sm.daytime >= tip.daytime
   AND sm.daytime < nvl(tip.end_date,sm.daytime+1)
   AND til.object_id = tip.inventory_id
   AND sm.daytime >= til.daytime
   AND sm.daytime < nvl(til.end_date,sm.daytime+1)
   AND NOT EXISTS (SELECT 1 FROM
             V_OVERRIDE_DIMENSION_HIST od
             WHERE od.project_id = tip.object_id
             and od.trans_inv_id  = tip.inventory_id
             and od.line_tag  = til.tag
             and od.dim_set_item_id_1 = tdgs1.DIM_CODE
             and od.dim_set_item_id_2 = tdgs2.DIM_CODE
             and od.daytime  <= sm.daytime
             and od.end_date  > sm.daytime)
UNION ALL
-- 2 Dimension Product Override
select tdgs1.dim_code || '|' || tdgs2.dim_code AS DIM_OBJECT_ID,
       tdgs1.dim_code DIM_ITEM_1,
       tdgs2.dim_code DIM_ITEM_2,
       tdgs1.dim_code DIM_ITEM_ID_1,
       tdgs2.dim_code DIM_ITEM_ID_2,
       NULL DIM_SET_1,
       NULL DIM_SET_2,
       add_months(sm.daytime,1)-1 end_date,
       nvl(od.exec_order, tdgs1.ATTRIBUTE_NUMBER * 10000 + tdgs2.ATTRIBUTE_NUMBER) EXEC_ORDER,
       tdgs1.ATTRIBUTE_NUMBER * 10000 + tdgs2.ATTRIBUTE_NUMBER default_exec,
       NULL as group_id,
       sm.daytime,
       od.jn_datetime jn_datetime,
       tip.object_id contract_id,
       tip.inventory_id object_id,
       til.tag,
       tip.record_status,
       tip.created_by,
       tip.created_date,
       tip.last_updated_by,
       tip.last_updated_date,
       tip.rev_no,
       tip.rev_text,
       od.COMMENTS,
       nvl(od.disabled_ind,'N')
  FROM (SELECT X.* FROM CNTR_ATTR_DIMENSION X WHERE ATTRIBUTE_NAME='TRANS_INV_DIM_1') tdgs1,
       (SELECT X.* FROM CNTR_ATTR_DIMENSION X WHERE ATTRIBUTE_NAME='TRANS_INV_DIM_2') tdgs2,
       (SELECT DISTINCT DAYTIME FROM SYSTEM_MTH_STATUS) sm,
       v_trans_inv_prod_stream_hist tip,
       TRANS_INV_LINE til,
       V_OVERRIDE_DIMENSION_HIST od
 WHERE tip.object_id = tdgs1.object_id
   AND tip.object_id = tdgs2.object_id
   AND sm.daytime < nvl(tdgs1.end_date,sm.daytime+1)
   AND sm.daytime >= tdgs1.daytime
   AND sm.daytime < nvl(tdgs2.end_date,sm.daytime+1)
   AND sm.daytime >= tdgs2.daytime
   AND sm.daytime >= tip.daytime
   AND sm.daytime < nvl(tip.end_date,sm.daytime+1)
   AND til.object_id = tip.inventory_id
   AND sm.daytime >= til.daytime
   AND sm.daytime < nvl(til.end_date,sm.daytime+1)
   AND od.project_id = tip.object_id
   and od.line_tag  = til.tag
   and od.dim_set_item_id_1 = tdgs1.dim_code
   and od.dim_set_item_id_2 = tdgs2.dim_code
   and od.daytime  <= sm.daytime
   and od.end_date  > sm.daytime
UNION ALL
-- 1 Dimension Line No Override
SELECT tdgs1.dim_code ||'|'|| tdgs2.dim_code,
       tdgs1.dim_code DIM_ITEM_1,
       tdgs2.dim_code DIM_ITEM_2,
       tdgs1.dim_code DIM_ITEM_ID_1,
       tdgs2.dim_code DIM_ITEM_ID_2,
       null DIM_SET_1,
       NULL,
       add_months(sm.daytime,1)-1 end_date,
       tdgs1.ATTRIBUTE_NUMBER * 10000 + tdgs2.ATTRIBUTE_NUMBER  EXEC_ORDER,
       tdgs1.ATTRIBUTE_NUMBER * 10000 + tdgs2.ATTRIBUTE_NUMBER default_exec,
       NULL as group_id,
       sm.daytime,
       tip.jn_datetime jn_datetime,
       tip.object_id contract_id,
       tip.inventory_id trans_inv_id,
       til.tag,
       tip.record_status,
       tip.created_by,
       tip.created_date,
       tip.last_updated_by,
       tip.last_updated_date,
       tip.rev_no,
       tip.rev_text,
       tip.comments,
       'N' disabled_ind
  FROM (SELECT X.* FROM CNTR_ATTR_DIMENSION X WHERE ATTRIBUTE_NAME='TRANS_INV_DIM_1') tdgs1,
       (SELECT X.* FROM CNTR_ATTR_DIMENSION X WHERE ATTRIBUTE_NAME='TRANS_INV_DIM_2') tdgs2,
       (SELECT DISTINCT DAYTIME FROM SYSTEM_MTH_STATUS
       union SELECT DAYTIME FROM TRANS_INV_LINE) sm,
       v_trans_inv_prod_stream_hist tip,
       TRANS_INV_LINE til,
       v_Trans_Inventory_History t
 WHERE t.object_id = tip.inventory_id
   AND tdgs1.object_id = tip.object_id
   AND sm.daytime >= tdgs1.daytime
   AND sm.daytime < nvl(tdgs1.end_date,sm.daytime+1)
   AND sm.daytime < nvl(tdgs2.end_date,sm.daytime+1)
   AND sm.daytime >= tdgs2.daytime
   AND tdgs2.object_id = tip.object_id
   AND nvl(t.config_template,t.object_id) = til.OBJECT_ID
   AND sm.daytime >= til.daytime
   AND sm.daytime < nvl(til.end_date,sm.daytime+1)
   AND not exists (SELECT 1
                   FROM V_OVERRIDE_DIMENSION_HIST od
                   WHERE    od.project_id = tip.object_id
                           and od.trans_inv_id = tip.inventory_id
                           and od.line_tag = til.tag
                           and od.daytime <= sm.daytime
                           and nvl(od.end_date,sm.daytime+1) > sm.daytime
                           and od.dim_set_item_id_1 = tdgs1.dim_code
                           and od.dim_set_item_id_2 = tdgs2.dim_code)
   AND NOT EXISTS (SELECT 1
                   FROM TRANS_INV_LINE_OVERRIDE tilo
                   WHERE  tilo.contract_id = tip.object_id
                           and tilo.object_id = tip.inventory_id
                           and tilo.tag = til.tag
                           and tilo.daytime <= sm.daytime
                           and nvl(tilo.end_date,sm.daytime+1) > sm.daytime)
UNION ALL
-- 1 Dimension Product Override
select tdgs1.dim_code || '|'  AS DIM_OBJECT_ID,
       tdgs1.dim_code DIM_ITEM_1,
       NULL DIM_ITEM_2,
       tdgs1.dim_code DIM_ITEM_ID_1,
       NULL DIM_ITEM_ID_2,
       NULL DIM_SET_1,
       NULL DIM_SET_2,
       add_months(sm.daytime,1)-1 end_date,
       nvl(od.exec_order, tdgs1.ATTRIBUTE_NUMBER * 10000)   EXEC_ORDER,
       tdgs1.ATTRIBUTE_NUMBER * 10000  default_exec,
       NULL as group_id,
       sm.daytime,
       od.jn_datetime jn_datetime,
       tip.object_id contract_id,
       tip.inventory_id object_id,
       til.tag,
       tip.record_status,
       tip.created_by,
       tip.created_date,
       tip.last_updated_by,
       tip.last_updated_date,
       tip.rev_no,
       tip.rev_text,
       od.comments,
       nvl(od.disabled_ind,'N')
  FROM (SELECT X.* FROM CNTR_ATTR_DIMENSION X WHERE ATTRIBUTE_NAME='TRANS_INV_DIM_1') tdgs1,
       (SELECT DISTINCT DAYTIME FROM SYSTEM_MTH_STATUS) sm,
       v_trans_inv_prod_stream_hist tip,
       TRANS_INV_LINE til,
       V_OVERRIDE_DIMENSION_HIST od
 WHERE tip.object_id = tdgs1.object_id
   AND sm.daytime < nvl(tdgs1.end_date,sm.daytime+1)
   AND sm.daytime >= tdgs1.daytime
   AND sm.daytime >= tip.daytime
   AND sm.daytime < nvl(tip.end_date,sm.daytime+1)
   AND til.object_id = tip.inventory_id
   AND sm.daytime >= til.daytime
   AND sm.daytime < nvl(til.end_date,sm.daytime+1)
   AND od.project_id = tip.object_id
  AND NOT EXISTS
   (SELECT OBJECT_ID FROM CNTR_ATTR_DIMENSION X WHERE ATTRIBUTE_NAME='TRANS_INV_DIM_2'
           AND sm.daytime >= daytime
           AND sm.daytime < nvl(end_date,sm.daytime+1)
           AND object_id = tip.object_id)
   and od.trans_inv_id  = tip.inventory_id
   and od.line_tag  = til.tag
   and od.dim_set_item_id_1 = tdgs1.dim_code
   and od.dim_set_item_id_2 = NULL
   and od.daytime  <= sm.daytime
   and od.end_date  > sm.daytime
UNION ALL
-- 1 Dimension Line No Override
SELECT tdgs1.dim_code ||'|',
       tdgs1.dim_code DIM_ITEM_1,
       NULL,
       tdgs1.dim_code DIM_ITEM_ID_1,
       NULL DIM_ITEM_ID_2,
       null DIM_SET_1,
       NULL,
       add_months(sm.daytime,1)-1 end_date,
       tdgs1.ATTRIBUTE_NUMBER * 10000  EXEC_ORDER,
       tdgs1.ATTRIBUTE_NUMBER * 10000 default_exec,
       NULL as group_id,
       sm.daytime,
       tip.jn_datetime jn_datetime,
       tip.object_id contract_id,
       tip.inventory_id trans_inv_id,
       til.tag,
       tip.record_status,
       tip.created_by,
       tip.created_date,
       tip.last_updated_by,
       tip.last_updated_date,
       tip.rev_no,
       tip.rev_text,
       tip.comments,
       'N' disabled_ind
  FROM (SELECT X.* FROM CNTR_ATTR_DIMENSION X WHERE ATTRIBUTE_NAME='TRANS_INV_DIM_1') tdgs1,
       (SELECT DISTINCT DAYTIME FROM SYSTEM_MTH_STATUS) sm,
       v_trans_inv_prod_stream_hist tip,
       TRANS_INV_LINE til
 WHERE tdgs1.object_id = tip.object_id
   AND sm.daytime >= tdgs1.daytime
   AND sm.daytime < nvl(tdgs1.end_date,sm.daytime+1)
   AND NOT EXISTS
       (SELECT OBJECT_ID FROM CNTR_ATTR_DIMENSION X WHERE ATTRIBUTE_NAME='TRANS_INV_DIM_2'
               AND sm.daytime >= daytime
               AND sm.daytime < nvl(end_date,sm.daytime+1)
               AND object_id = tip.object_id)
   AND til.object_id = tip.inventory_id
   AND sm.daytime >= til.daytime
   AND sm.daytime < nvl(til.end_date,sm.daytime+1)
   AND not exists (SELECT 1
                   FROM V_OVERRIDE_DIMENSION_HIST od
                   WHERE    od.project_id = tip.object_id
                           and od.trans_inv_id = tip.inventory_id
                           and od.line_tag = til.tag
                           and od.daytime <= sm.daytime
                           and nvl(od.end_date,sm.daytime+1) > sm.daytime
                           and od.dim_set_item_id_1 = tdgs1.dim_code
                           and od.dim_set_item_id_2 is null)
   AND NOT EXISTS (SELECT 1
                   FROM TRANS_INV_LINE_OVERRIDE tilo
                   WHERE  tilo.contract_id = tip.object_id
                           and tilo.object_id = tip.inventory_id
                           and tilo.tag = til.tag
                           and tilo.daytime <= sm.daytime
                           and nvl(tilo.end_date,sm.daytime+1) > sm.daytime)
UNION ALL
-- 1 Dimension Override
SELECT tdgs1.dim_code ||'|',
       tdgs1.dim_code DIM_ITEM_1,
       tdgs2.dim_code DIM_ITEM_2,
       tdgs1.dim_code DIM_ITEM_ID_1,
       tdgs2.dim_code DIM_ITEM_ID_2,
       NULL DIM_SET_1,
       NULL,
       add_months(sm.daytime,1)-1 end_date,
       (tdgs1.ATTRIBUTE_NUMBER *10000)+tdgs2.attribute_number  EXEC_ORDER,
       (tdgs1.ATTRIBUTE_NUMBER *10000)+tdgs2.attribute_number default_exec,
       NULL as group_id,
       sm.daytime,
       sysdate jn_datetime,
       tip.object_id contract_id,
       tip.inventory_id trans_inv_id,
       til.tag,
       tip.record_status,
       tip.created_by,
       tip.created_date,
       tip.last_updated_by,
       tip.last_updated_date,
       tip.rev_no,
       tip.rev_text,
       tip.comments,
       'N'
  FROM(SELECT X.* FROM CNTR_ATTR_DIMENSION X WHERE ATTRIBUTE_NAME='TRANS_INV_DIM_1') tdgs1,
       (SELECT X.* FROM CNTR_ATTR_DIMENSION X WHERE ATTRIBUTE_NAME='TRANS_INV_DIM_2') tdgs2,
       (SELECT DISTINCT DAYTIME FROM SYSTEM_MTH_STATUS
       union SELECT DAYTIME FROM TRANS_INV_LINE) sm,
       v_trans_inv_prod_stream_hist tip,
       TRANS_INV_LINE til,
       v_Trans_Inventory_History t
 WHERE tdgs1.object_id = tip.object_id
   AND sm.daytime >= tdgs1.daytime
   AND sm.daytime < nvl(tdgs1.end_date,sm.daytime+1)
   AND sm.daytime < nvl(tdgs2.end_date,sm.daytime+1)
   AND sm.daytime >= tdgs2.daytime
   AND tdgs2.object_id = tip.object_id
   AND til.object_id = tip.inventory_id
   AND nvl(t.config_template,t.object_id) = tip.inventory_id
   AND sm.daytime >= til.daytime
   AND sm.daytime < nvl(til.end_date,sm.daytime+1)
   and exists(SELECT 1
                   FROM V_OVERRIDE_DIMENSION_HIST od1
                   WHERE    od1.project_id = tip.object_id
                           and (od1.trans_inv_id = t.config_template OR od1.trans_inv_id =  t.object_id)
                           and od1.line_tag = til.tag
                           and od1.daytime <= sm.daytime
                           and nvl(od1.end_date,sm.daytime+1) > sm.daytime
                           and od1.jn_datetime =
   (SELECT max(jn_datetime)
                   FROM V_OVERRIDE_DIMENSION_HIST od2
                   WHERE    od2.project_id = tip.object_id
                           and (od2.trans_inv_id = t.config_template OR od2.trans_inv_id =  t.object_id)
                           and od2.line_tag = til.tag
                           and od2.daytime <= sm.daytime
                           and nvl(od2.end_date,sm.daytime+1) > sm.daytime)
                           and od1.JN_OPERATION='DEL')