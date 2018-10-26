CREATE OR REPLACE FORCE EDITIONABLE VIEW "V_DIMENSION_ITEMS_LINE" ("DIM_OBJECT_ID", "DIM_ITEM_1", "DIM_ITEM_2", "DIM_ITEM_ID_1", "DIM_ITEM_ID_2", "DIM_SET_1", "DIM_SET_2", "END_DATE", "EXEC_ORDER", "DEFAULT_EXEC", "GROUP_ID", "DAYTIME", "CONTRACT_ID", "OBJECT_ID", "TAG", "RECORD_STATUS", "CREATED_BY", "CREATED_DATE", "LAST_UPDATED_BY", "LAST_UPDATED_DATE", "REV_NO", "REV_TEXT", "COMMENTS") AS 
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
       tip.comments
  FROM (SELECT X.* FROM CNTR_ATTR_DIMENSION X WHERE ATTRIBUTE_NAME='TRANS_INV_DIM_1') tdgs1,
       (SELECT X.* FROM CNTR_ATTR_DIMENSION X WHERE ATTRIBUTE_NAME='TRANS_INV_DIM_2') tdgs2,
       (SELECT DISTINCT DAYTIME FROM SYSTEM_MTH_STATUS) sm,
       TRANS_INV_PROD_STREAM tip,
        (SELECT DAYTIME,END_DATE,TAG,OBJECT_ID FROM TRANS_INV_LINE
       UNION ALL
       SELECT   x.DAYTIME,x.END_DATE,TAG,y.object_id  FROM
                TRANS_INV_LINE X,
                trans_inventory_version y
                where Y.CONFIG_TEMPLATE  = x.object_id
                and tag not in
                (select tag from TRANS_INV_LINE where object_id =Y.object_id)) til,
       OVERRIDE_DIMENSION od
 WHERE tip.object_id = tdgs1.object_id
   AND tip.object_id = tdgs2.object_id
   AND sm.daytime < nvl(tdgs1.end_date,sm.daytime+1)
   AND sm.daytime >= tdgs1.daytime
   AND sm.daytime < nvl(tdgs2.end_date,sm.daytime+1)
   AND sm.daytime >= tdgs2.daytime
   AND sm.daytime >= tip.daytime
   AND sm.daytime >= til.daytime
   AND sm.daytime < nvl(til.end_date,sm.daytime+1)
   AND sm.daytime < nvl(tip.end_date,sm.daytime+1)
   AND til.object_id = tip.inventory_id
   AND od.project_id = tip.object_id
   and od.trans_inv_id  = tip.inventory_id
   and od.line_tag  = til.tag
   and od.dim_set_item_id_1 = tdgs1.dim_code
   and od.dim_set_item_id_2 = tdgs2.dim_code
   and od.daytime  <= sm.daytime
   and od.end_date  > sm.daytime
   and nvl(od.disabled_ind,'N') = 'N'
UNION ALL
-- 2 Dimension Line No Override
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
       tip.comments
  FROM (SELECT X.* FROM CNTR_ATTR_DIMENSION X WHERE ATTRIBUTE_NAME='TRANS_INV_DIM_1') tdgs1,
       (SELECT X.* FROM CNTR_ATTR_DIMENSION X WHERE ATTRIBUTE_NAME='TRANS_INV_DIM_2') tdgs2,
       (SELECT DISTINCT DAYTIME FROM SYSTEM_MTH_STATUS
       union SELECT DAYTIME FROM TRANS_INV_LINE) sm,
       TRANS_INV_PROD_STREAM tip,
        (SELECT DAYTIME,END_DATE,TAG,OBJECT_ID FROM TRANS_INV_LINE
       UNION ALL
       SELECT   x.DAYTIME,x.END_DATE,TAG,y.object_id  FROM
                TRANS_INV_LINE X,
                trans_inventory_version y
                where Y.CONFIG_TEMPLATE  = x.object_id
                and tag not in (select tag from TRANS_INV_LINE where object_id =Y.object_id)) til
 WHERE tdgs1.object_id = tip.object_id
   AND sm.daytime >= tdgs1.daytime
   AND sm.daytime < nvl(tdgs1.end_date,sm.daytime+1)
   AND sm.daytime < nvl(tdgs2.end_date,sm.daytime+1)
   AND sm.daytime >= tdgs2.daytime
   AND tdgs2.object_id = tip.object_id
   AND til.object_id = tip.inventory_id
   AND sm.daytime >= til.daytime
   AND sm.daytime < nvl(til.end_date,sm.daytime+1)
   AND not exists (SELECT 1
                   FROM override_dimension od
                   WHERE    od.project_id = tip.object_id
                           and od.trans_inv_id = tip.inventory_id
                           and od.line_tag = til.tag
                           and od.daytime <= sm.daytime
                           and nvl(od.end_date,sm.daytime+1) > sm.daytime
                           and od.dim_set_item_id_1 = tdgs1.dim_code
                           and od.dim_set_item_id_2 = tdgs2.dim_code)
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
       tip.comments
  FROM (SELECT X.* FROM CNTR_ATTR_DIMENSION X WHERE ATTRIBUTE_NAME='TRANS_INV_DIM_1') tdgs1,
       (SELECT DISTINCT DAYTIME FROM SYSTEM_MTH_STATUS) sm,
       TRANS_INV_PROD_STREAM tip,
        (SELECT DAYTIME,END_DATE,TAG,OBJECT_ID FROM TRANS_INV_LINE
       UNION ALL
       SELECT   x.DAYTIME,x.END_DATE,TAG,y.object_id  FROM
                TRANS_INV_LINE X,
                trans_inventory_version y
                where Y.CONFIG_TEMPLATE  = x.object_id
                and tag not in (select tag from TRANS_INV_LINE where object_id =Y.object_id)) til,
       OVERRIDE_DIMENSION od
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
   and od.daytime  >= sm.daytime
   and od.end_date  > sm.daytime
   and nvl(od.disabled_ind,'N') = 'N'
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
       tip.comments
  FROM (SELECT X.* FROM CNTR_ATTR_DIMENSION X WHERE ATTRIBUTE_NAME='TRANS_INV_DIM_1') tdgs1,
       (SELECT DISTINCT DAYTIME FROM SYSTEM_MTH_STATUS) sm,
       TRANS_INV_PROD_STREAM tip,
        (SELECT DAYTIME,END_DATE,TAG,OBJECT_ID FROM TRANS_INV_LINE
       UNION ALL
       SELECT   x.DAYTIME,x.END_DATE,TAG,y.object_id  FROM
                TRANS_INV_LINE X,
                trans_inventory_version y
                where Y.CONFIG_TEMPLATE  = x.object_id
                and tag not in (select tag from TRANS_INV_LINE where object_id =Y.object_id)) til
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
                   FROM override_dimension od
                   WHERE    od.project_id = tip.object_id
                           and od.trans_inv_id = tip.inventory_id
                           and od.line_tag = til.tag
                           and od.daytime <= sm.daytime
                           and nvl(od.end_date,sm.daytime+1) > sm.daytime
                           and od.dim_set_item_id_1 = tdgs1.dim_code
                           and od.dim_set_item_id_2 is null)
UNION ALL
-- 1 Dimension Override
SELECT tdgs1.dim_code ||'|',
       tdgs1.dim_code DIM_ITEM_1,
       NULL,
       tdgs1.dim_code DIM_ITEM_ID_1,
       NULL DIM_ITEM_ID_2,
       NULL DIM_SET_1,
       NULL,
       add_months(sm.daytime,1)-1 end_date,
       nvl(od.exec_order, tdgs1.ATTRIBUTE_NUMBER *1000)  EXEC_ORDER,
       tdgs1.ATTRIBUTE_NUMBER *1000 default_exec,
       NULL as group_id,
       sm.daytime,
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
       tip.comments
  FROM(SELECT X.* FROM CNTR_ATTR_DIMENSION X WHERE ATTRIBUTE_NAME='TRANS_INV_DIM_1') tdgs1,
       (SELECT DISTINCT DAYTIME FROM SYSTEM_MTH_STATUS
       union SELECT DAYTIME FROM TRANS_INV_LINE) sm,
       TRANS_INV_PROD_STREAM tip,
        (SELECT DAYTIME,END_DATE,TAG,OBJECT_ID FROM TRANS_INV_LINE
       UNION ALL
       SELECT   x.DAYTIME,x.END_DATE,TAG,y.object_id  FROM
                TRANS_INV_LINE X,
                trans_inventory_version y
                where Y.CONFIG_TEMPLATE  = x.object_id
                and tag not in (select tag from TRANS_INV_LINE where object_id =Y.object_id)) til,
       override_dimension od
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
   AND od.project_id = tip.object_id
   and od.trans_inv_id = tip.inventory_id
   and od.line_tag = til.tag
   and od.daytime <= sm.daytime
   and nvl(od.end_date,sm.daytime+1) > sm.daytime
   and od.dim_set_item_id_1 = tdgs1.dim_code
   and od.dim_set_item_id_2 is null
   and nvl(od.disabled_ind,'N') = 'N'