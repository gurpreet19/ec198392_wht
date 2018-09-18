CREATE OR REPLACE FORCE EDITIONABLE VIEW "V_TRANS_INV_NAV_INV" ("OBJECT_ID", "DAYTIME", "END_DATE", "PROD_STREAM_GROUP_ID", "REVN_PROD_STREAM_ID", "SEQ_NO", "NEXT_INV", "PREV_INV", "RECORD_STATUS", "CREATED_BY", "CREATED_DATE", "LAST_UPDATED_BY", "LAST_UPDATED_DATE", "REV_NO", "REV_TEXT") AS 
  SELECT tip.inventory_id As object_id,
       tip.daytime,
       tip.end_date,
       cce.object_id prod_stream_group_id,
       tip.object_id as revn_prod_stream_id,
       tip.exec_order seq_no,
       ecdp_trans_inventory.GetNextInventory(cce.object_id,tip.object_id,tip.inventory_id,tip.daytime) NEXT_INV,
       ecdp_trans_inventory.GetPreviousInventory(cce.object_id,tip.object_id,tip.inventory_id,tip.daytime) PREV_INV,
       tip.RECORD_STATUS,
       tip.CREATED_BY ,
       tip.CREATED_DATE ,
       tip.LAST_UPDATED_BY ,
       tip.LAST_UPDATED_DATE  ,
       tip.REV_NO  ,
       tip.REV_TEXT
  FROM
       TRANS_INV_PROD_STREAM tip,
       calc_collection_element cce
  WHERE cce.element_id = tip.object_id