CREATE OR REPLACE FORCE VIEW "V_STREAM_NODE_DIAGRAM_META" ("NAME", "FULL_NAME", "IMPLEMENTING_CLASS", "EC_DATA_CLASS", "OBJECT_TYPE", "RECORD_STATUS", "CREATED_BY", "CREATED_DATE", "LAST_UPDATED_BY", "LAST_UPDATED_DATE", "REV_NO", "REV_TEXT") AS 
  (
SELECT
   c.class_name AS name,
   c.label AS full_name,
   'com.ec.prod.co.netscreens.AllocationNode' AS implementing_class,
   c.class_name AS ec_data_class,
   'NODE' AS object_type,
   'P' AS record_status,
   NULL AS created_by,
   NULL AS created_date,
   NULL AS last_updated_by,
   NULL AS last_updated_date,
   0 AS rev_no,
   NULL AS rev_text
FROM class_dependency d,class c
WHERE d.parent_class='ALLOC_NODE'
AND d.dependency_type='IMPLEMENTS'
AND c.class_name=d.child_class
UNION ALL
SELECT
   class_name AS name,
   'EC Stream' AS full_name,
   'com.ec.prod.co.netscreens.AllocationLink' AS implementing_class,
   'ALLOC_STREAM' AS ec_data_class,
   'LINK' AS object_type,
   'P' AS record_status,
   NULL AS created_by,
   NULL AS created_date,
   NULL AS last_updated_by,
   NULL AS last_updated_date,
   0 AS rev_no,
   NULL AS rev_text
FROM class c, class_dependency d
where d.parent_class = 'ALLOC_STREAM'
and d.dependency_type = 'IMPLEMENTS'
and d.child_class = c.class_name
and c.class_name not like 'IMP_WELL_%_STREAM'
UNION ALL
SELECT
   class_name AS name,
   'Group Stream' AS full_name,
   'com.ec.prod.co.netscreens.WellGroupLink' AS implementing_class,
   'SND_WELL_GROUP_STREAM' AS ec_data_class,
   'LINK' AS object_type,
   'P' AS record_status,
   NULL AS created_by,
   NULL AS created_date,
   NULL AS last_updated_by,
   NULL AS last_updated_date,
   0 AS rev_no,
   NULL AS rev_text
FROM class
where class_name = 'SND_WELL_GROUP_STREAM'
UNION ALL
SELECT
   'SND_WELL_GROUP' AS name,
   'Well group' AS full_name,
   'com.ec.prod.co.netscreens.WellGroupNode' AS implementing_class,
   'SND_WELL_GROUP' AS ec_data_class,
   'NODE' AS object_type,
   'P' AS record_status,
   NULL AS created_by,
   NULL AS created_date,
   NULL AS last_updated_by,
   NULL AS last_updated_date,
   0 AS rev_no,
   NULL AS rev_text
FROM class
where class_name = 'SND_WELL_GROUP'
)