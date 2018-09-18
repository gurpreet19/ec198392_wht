CREATE OR REPLACE FORCE EDITIONABLE VIEW "V_NETWORK_EDITOR_META" ("NAME", "FULL_NAME", "IMPLEMENTING_CLASS", "EC_DATA_CLASS", "OBJECT_TYPE", "RECORD_STATUS", "CREATED_BY", "CREATED_DATE", "LAST_UPDATED_BY", "LAST_UPDATED_DATE", "REV_NO", "REV_TEXT") AS 
  (
SELECT
   class_name AS name,
   'EC Non-Alloc Stream' AS full_name,
   'com.ec.prod.co.netscreens.AllocationLink' AS implementing_class,
   'ALLOC_REVN_STREAM' AS ec_data_class,
   'LINK' AS object_type,
   'P' AS record_status,
   NULL AS created_by,
   NULL AS created_date,
   NULL AS last_updated_by,
   NULL AS last_updated_date,
   0 AS rev_no,
   NULL AS rev_text
FROM class_cnfg
where class_name = 'STREAM'
UNION ALL
SELECT
   class_name AS name,
   EcDp_ClassMeta_Cnfg.getLabel(class_name) AS full_name,
   'com.ec.prod.co.netscreens.AllocationNode' AS implementing_class,
   class_name AS ec_data_class,
   'NODE' AS object_type,
   'P' AS record_status,
   NULL AS created_by,
   NULL AS created_date,
   NULL AS last_updated_by,
   NULL AS last_updated_date,
   0 AS rev_no,
   NULL AS rev_text
FROM class_cnfg
where class_name = 'NODE'
)