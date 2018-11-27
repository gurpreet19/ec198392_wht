CREATE OR REPLACE FORCE EDITIONABLE VIEW "V_TRANS_INV_STREAM" ("REF_ID", "STREAM", "TYPE", "KEY", "STREAM_ID", "TRANS_INV_ID", "NODE_ID", "OBJECT_ID", "LINE_TAG", "LABEL", "SEQ_NO", "DAYTIME", "END_DATE", "RECORD_STATUS", "CREATED_BY", "CREATED_DATE", "LAST_UPDATED_BY", "LAST_UPDATED_DATE", "REV_NO", "REV_TEXT", "APPROVAL_STATE", "APPROVAL_BY", "APPROVAL_DATE", "REC_ID") AS 
  SELECT nvl(ti.object_id,ti.node_id) ref_id,
       NVL(sv.name,'Manual Created') stream,
       ec_prosty_codes.code_text(til.type,'TRANS_TEMPL_LINE_TYPE') type,
       til.tag key,
       sv.object_id stream_id,
       til.object_id trans_inv_id,
       ti.node_id,
       ti.alloc_network_id object_id,
       til.tag line_tag,
       til.label label,
       til.seq_no,
       til.daytime,
       til.end_date,
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
       TRANS_INV_LINE til,
       TRANS_INVENTORY_VERSION tiv,
       TRANS_INVENTORY ti,
       STRM_VERSION SV
 WHERE
   ti.object_id = tiv.object_id
   AND til.object_id = tiv.object_id
   AND sv.object_id(+) = til.stream_id
   AND sv.daytime(+) <= til.daytime
   AND nvl(sv.end_date,to_date('123199','mmddyy'))>= nvl(til.end_date,to_date('123199','mmddyy'))
UNION -- No Line Created yet connected to stream by from node
SELECT nvl((select max(ti.object_id) from trans_inventory_version tiv, trans_inventory ti where ti.object_id = tiv.object_id
       and ti.alloc_network_id = cce.object_id and ti.node_id = cce.element_id),n.object_id),
       sv.name,
       DECODE(nvl(sv.to_node_id,'X'),'X','Decrease','Transfer out'),
       sv.object_id,
       sv.object_id,
       null,
       cce.element_id,
       cce.object_id,
       null,
       null,
       DECODE(nvl(sv.to_node_id,'x'),'x',600,800),
       cce.daytime,
       cce.end_date,
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
FROM   STRM_VERSION sv,
       STREAM s,
       NODE n,
       CALC_COLLECTION_ELEMENT CCE,
       contract c
WHERE cce.element_id = sv.from_node_id
  AND s.object_id = sv.object_id
  AND cce.element_id = n.object_id
  and cce.daytime >= n.start_date
  AND nvl(s.end_date,to_date('123199','mmddyy'))>= nvl(cce.end_date,nvl(s.end_date,to_date('123199','mmddyy')))
  AND nvl(n.end_date,to_date('123199','mmddyy'))>= nvl(cce.end_date,nvl(n.end_date,to_date('123199','mmddyy')))
  AND not exists(SELECT nvl(ti.object_id,'x')
                   FROM trans_inv_line til,
                        trans_inventory ti,
                        trans_inventory_version tiv
                  WHERE til.stream_id = sv.object_id
                    AND ti.object_id = til.object_id
                    AND ti.node_id = cce.element_id
                    AND tiv.object_id = ti.object_id
                    AND ti.alloc_network_id = cce.object_id)
UNION -- No Line Created yet connected to stream by to node
SELECT nvl((select max(ti.object_id) from trans_inventory_version tiv, trans_inventory ti where ti.object_id = tiv.object_id and
       ti.alloc_network_id = cce.object_id and ti.node_id = cce.element_id),n.object_id),
       sv.name,
       DECODE(NVL(sv.from_node_id,'X'),'X','Increase','Transfer out'),
       sv.object_id,
       sv.object_id,
       null,
       cce.element_id,
       cce.object_id,
       null,
       null,
       DECODE(nvl(sv.from_node_id,'x'),'x',300,100),
       cce.daytime,
       cce.end_date,
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
FROM   STRM_VERSION sv,
       STREAM s,
       NODE n,
       CALC_COLLECTION_ELEMENT CCE
WHERE s.object_id = sv.object_id
  and cce.daytime >= n.start_date
  AND cce.element_id = sv.to_node_id
  AND cce.element_id = n.object_id
  AND s.object_id = sv.object_id
  AND nvl(s.end_date,to_date('123199','mmddyy'))>= nvl(cce.end_date,nvl(s.end_date,to_date('123199','mmddyy')))
  AND nvl(n.end_date,to_date('123199','mmddyy'))>= nvl(cce.end_date,nvl(n.end_date,to_date('123199','mmddyy')))
  AND not exists(SELECT nvl(ti.object_id,'x')
                   FROM trans_inv_line til,
                        trans_inventory ti,
                        trans_inventory_version tiv
                  WHERE til.stream_id = sv.object_id
                    AND ti.object_id = til.object_id
                    AND ti.node_id = cce.element_id
                    AND tiv.object_id = ti.object_id
                    AND ti.alloc_network_id = cce.object_id)