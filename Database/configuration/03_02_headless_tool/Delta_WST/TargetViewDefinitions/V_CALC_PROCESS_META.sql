CREATE OR REPLACE FORCE VIEW "V_CALC_PROCESS_META" ("NAME", "FULL_NAME", "IMPLEMENTING_CLASS", "EC_DATA_CLASS", "OBJECT_TYPE", "RECORD_STATUS", "CREATED_BY", "CREATED_DATE", "LAST_UPDATED_BY", "LAST_UPDATED_DATE", "REV_NO", "REV_TEXT") AS 
  (
----------------------------------------------------------------------------------------------------
--
-- Purpose  : Provides metadata (node and stream information) to the calculation flowchart editor
--
----------------------------------------------------------------------------------------------------
SELECT
   class_name AS name,
   'Flowchart Element' AS full_name,
   'com.ec.frmw.co.netscreens.FlowChartNode' AS implementing_class,
   class_name AS ec_data_class,
   'NODE' AS object_type,
   'P' AS record_status,
   NULL AS created_by,
   NULL AS created_date,
   NULL AS last_updated_by,
   NULL AS last_updated_date,
   0 AS rev_no,
   NULL AS rev_text
FROM class
where class_name = 'CALC_PROCESS_ELEMENT'
UNION ALL
SELECT
   class_name AS name,
   'Flowchart Element' AS full_name,
   'com.ec.frmw.co.netscreens.FlowChartLink' AS implementing_class,
   class_name AS ec_data_class,
   'LINK' AS object_type,
   'P' AS record_status,
   NULL AS created_by,
   NULL AS created_date,
   NULL AS last_updated_by,
   NULL AS last_updated_date,
   0 AS rev_no,
   NULL AS rev_text
FROM class
where class_name = 'CALC_PROCESS_TRANSITION'
)