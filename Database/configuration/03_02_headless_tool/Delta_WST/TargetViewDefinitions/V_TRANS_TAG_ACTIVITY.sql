CREATE OR REPLACE FORCE VIEW "V_TRANS_TAG_ACTIVITY" ("DAYTIME", "DATA_CLASS", "OBJECT_REF", "LAST_TRANSFER", "RECORD_STATUS", "CREATED_BY", "CREATED_DATE", "LAST_UPDATED_BY", "LAST_UPDATED_DATE", "REV_NO", "REV_TEXT") AS 
  SELECT "DAYTIME","DATA_CLASS","OBJECT_REF","LAST_TRANSFER","RECORD_STATUS","CREATED_BY","CREATED_DATE","LAST_UPDATED_BY","LAST_UPDATED_DATE","REV_NO","REV_TEXT" FROM (
SELECT DISTINCT
       tt.last_updated_date daytime
       ,m.data_class
       ,DECODE(m.PK_ATTR_1,'OBJECT_ID', ecdp_objects.GetObjCode(m.PK_val_1),m.PK_val_1)||','||pk_val_2  object_ref
       ,tt.last_transfer
      , NULL AS RECORD_STATUS
      , NULL AS CREATED_BY
      , TO_DATE(NULL) AS CREATED_DATE
      , NULL AS LAST_UPDATED_BY
      , TO_DATE(NULL) AS LAST_UPDATED_DATE
      , NULL AS REV_NO
      , NULL AS REV_TEXT
FROM  trans_target_time tt, trans_mapping m
WHERE tt.target_tagid = m.tag_id
ORDER BY tt.last_updated_date DESC nulls last)
WHERE ROWNUM < 100