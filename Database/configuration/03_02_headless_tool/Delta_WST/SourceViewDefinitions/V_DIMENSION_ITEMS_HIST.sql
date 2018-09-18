CREATE OR REPLACE FORCE EDITIONABLE VIEW "V_DIMENSION_ITEMS_HIST" ("DIM_OBJECT_ID", "DIM_ITEM_1", "DIM_ITEM_2", "DIM_ITEM_ID_1", "DIM_ITEM_ID_2", "DIM_SET_1", "DIM_SET_2", "END_DATE", "EXEC_ORDER", "DEFAULT_EXEC", "GROUP_ID", "DAYTIME", "JN_DATETIME", "CONTRACT_ID", "OBJECT_ID", "RECORD_STATUS", "CREATED_BY", "CREATED_DATE", "LAST_UPDATED_BY", "LAST_UPDATED_DATE", "REV_NO", "REV_TEXT", "COMMENTS") AS 
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
       v_trans_inv_prod_stream_hist tip
 WHERE tip.object_id = tdgs1.object_id
   AND tip.object_id = tdgs2.object_id
   AND sm.daytime < nvl(tdgs1.end_date,sm.daytime+1)
   AND sm.daytime >= tdgs1.daytime
   AND sm.daytime < nvl(tdgs2.end_date,sm.daytime+1)
   AND sm.daytime >= tdgs2.daytime
   AND sm.daytime >= tip.daytime
   AND sm.daytime < nvl(tip.end_date,sm.daytime+1)
UNION ALL
SELECT tdgs1.dim_code ||'|',
       tdgs1.dim_code DIM_ITEM_1,
       NULL,
       tdgs1.dim_code DIM_ITEM_ID_1,
       NULL DIM_ITEM_ID_2,
       null DIM_SET_1,
       NULL,
       add_months(sm.daytime,1)-1 end_date,
       tdgs1.Attribute_Number  EXEC_ORDER,
       tdgs1.Attribute_Number default_exec,
       NULL as group_id,
       sm.daytime,
       tip.jn_datetime jn_datetime,
       tip.object_id contract_id,
       tip.inventory_id trans_inv_id,
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
       v_trans_inv_prod_stream_hist tip
 WHERE tdgs1.object_id = tip.object_id
   AND sm.daytime >= tdgs1.daytime
   AND sm.daytime < nvl(tdgs1.end_date,sm.daytime+1)
   AND not exists (SELECT object_id FROM CNTR_ATTR_DIMENSION X WHERE ATTRIBUTE_NAME='TRANS_INV_DIM_2' AND OBJECT_ID = tip.object_id
       AND sm.daytime >= daytime
   AND sm.daytime < nvl(end_date,sm.daytime+1))