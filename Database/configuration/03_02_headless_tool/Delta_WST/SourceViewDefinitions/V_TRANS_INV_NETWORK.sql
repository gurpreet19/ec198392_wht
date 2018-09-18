CREATE OR REPLACE FORCE EDITIONABLE VIEW "V_TRANS_INV_NETWORK" ("ALLOC_NETWORK_CODE", "NODE_CODE", "INV_CODE", "DAYTIME", "END_DATE", "OBJECT_START_DATE", "OBJECT_END_DATE", "SEQ_NO", "OBJECT_ID", "NODE_NAME", "INV_NAME", "REF_ID", "NODE_ID", "TRANS_INV_ID", "RECORD_STATUS", "CREATED_BY", "CREATED_DATE", "LAST_UPDATED_BY", "LAST_UPDATED_DATE", "REV_NO", "REV_TEXT", "APPROVAL_STATE", "APPROVAL_BY", "APPROVAL_DATE", "REC_ID") AS 
  SELECT  --Where no inventory created yet
          ecdp_objects.GetObjCode(nvl(cc.OBJECT_ID,cc.object_id)) alloc_network_code,
          cc.object_code node_code,
          null inv_code,
          cc.daytime daytime,
          cc.end_date end_date,
          cc.obj_start_date object_start_date,
          cc.end_date object_end_date,
          ec_node_version.alloc_seq(ELEMENT_ID,cc.daytime,'<=') seq_no,
          cc.object_id,
          ec_node_version.name(ELEMENT_ID,cc.daytime,'<=') node_name,
          null inv_name,
          cc.element_id ref_id,
          cc.element_id node_id,
          null trans_inv_id,
          null record_status,
          null created_by,
          null created_date,
          null last_updated_by,
          null last_updated_date,
          null rev_no,
          null rev_text,
          null approval_state,
          null approval_by,
          null approval_date,
          null rec_id
   FROM  node n,
          (SELECT cce.element_id,
                cc.object_id,
                cce.daytime,
                cce.end_date,
                cc.object_code,
                cc.start_Date obj_start_date,
                cc.end_date obj_end_date,
                ecdp_objects.getobjcode(cce.element_id),
                ecdp_objects.getobjcode(cc.object_id)
           FROM
              CALC_COLLECTION_ELEMENT cce,
              CALC_COLLECTION_VERSION ccv,
              CALC_COLLECTION cc
        WHERE cce.object_id = cc.object_id
           AND ccv.object_id = cc.object_id
           AND cce.daytime >= ccv.daytime
           AND cce.daytime < nvl(ccv.end_date,cce.daytime + 1)
           AND cc.class_name='ALLOC_NETWORK') cc
  WHERE (cc.element_id,cc.object_id) NOT IN
        (select nvl(ti.node_id,'x'),nvl(ti.alloc_network_id,'x')
           FROM trans_inventory ti,
                trans_inventory_version tiv
          WHERE ti.object_id = tiv.object_id)
    AND n.object_id = cc.element_id
    AND nvl(n.end_date,to_date('123199','mmddyy'))>= nvl(cc.end_date,nvl(n.end_date,to_date('123199','mmddyy')))
UNION ALL --Where inventory created but no node
SELECT
          ecdp_objects.GetObjCode(ti.alloc_network_id) alloc_network_code,
          null node_code,
          ti.object_code inv_code,
          tiv.daytime,
          tiv.end_date end_date,
          ti.start_date object_start_date,
          ti.end_date object_end_date,
          tiv.seq_no seq_no,
          ti.alloc_network_id as object_id,
          'Manually Created' node_name,
          name inv_name,
          ti.object_id ref_id,
          null node_id,
          ti.object_id,
          null record_status,
          null created_by,
          null created_date,
          null last_updated_by,
          null last_updated_date,
          null rev_no,
          null rev_text,
          null approval_state,
          null approval_by,
          null approval_date,
          null rec_id
  FROM
          TRANS_INVENTORY ti,
          TRANS_INVENTORY_VERSION tiv
  WHERE   ti.object_id = tiv.object_id
      AND ti.node_id is null
UNION ALL -- those in both node and transaction inventory
     SELECT
          ecdp_objects.GetObjCode(cc.OBJECT_ID) alloc_network_code,
          n.object_code node_code,
          ti.object_code inv_code,
          tiv.daytime daytime,
          tiv.end_date end_date,
          ti.start_date object_start_date,
          ti.end_date object_end_date,
          tiv.seq_no seq_no,
          cc.object_id as object_id,
          nv.name node_name,
          tiv.name inv_name,
          ti.object_id ref_id,
          n.object_id node_id,
          ti.object_id,
          null record_status,
          null created_by,
          null created_date,
          null last_updated_by,
          null last_updated_date,
          null rev_no,
          null rev_text,
          null approval_state,
          null approval_by,
          null approval_date,
          null rec_id
FROM      TRANS_INVENTORY ti,
          TRANS_INVENTORY_VERSION tiv,
          NODE n,
          NODE_VERSION nv,
          CALC_COLLECTION_ELEMENT cce,
          CALC_COLLECTION_VERSION ccv,
          CALC_COLLECTION cc
    WHERE cce.object_id = cc.object_id
      AND ccv.object_id = cc.object_id
      AND n.object_id = cce.element_id
      AND n.object_id = nv.object_id
      AND ti.object_id = tiv.object_id
      AND ti.alloc_network_id = cc.object_id
      AND tiv.object_id = ti.object_id
      AND ti.node_id = n.object_id
  AND nvl(n.end_date,to_date('123199','mmddyy'))>= nvl(cce.end_date,nvl(n.end_date,to_date('123199','mmddyy')))