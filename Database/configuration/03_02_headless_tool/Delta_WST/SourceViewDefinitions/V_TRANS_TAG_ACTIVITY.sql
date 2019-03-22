CREATE OR REPLACE FORCE EDITIONABLE VIEW "V_TRANS_TAG_ACTIVITY" ("DAYTIME", "DATA_CLASS", "OBJECT_REF", "LAST_TRANSFER", "RECORD_STATUS", "CREATED_BY", "CREATED_DATE", "LAST_UPDATED_BY", "LAST_UPDATED_DATE", "REV_NO", "REV_TEXT") AS 
  SELECT "DAYTIME","DATA_CLASS","OBJECT_REF","LAST_TRANSFER","RECORD_STATUS","CREATED_BY","CREATED_DATE","LAST_UPDATED_BY","LAST_UPDATED_DATE","REV_NO","REV_TEXT" FROM (
SELECT DISTINCT
       tt.last_updated_date daytime
       ,m.data_class
       ,ecdp_ecishelper.getPKObjectRef(
           m.PK_ATTR_1, m.PK_val_1,
           m.PK_ATTR_2, m.PK_val_2,
           m.PK_ATTR_3, m.PK_val_3,
           m.PK_ATTR_4, m.PK_val_4,
           m.PK_ATTR_5, m.PK_val_5,
           m.PK_ATTR_6, m.PK_val_6,
           m.PK_ATTR_7, m.PK_val_7,
           m.PK_ATTR_8, m.PK_val_8,
           m.PK_ATTR_9, m.PK_val_9,
           m.PK_ATTR_10, m.PK_val_10
       ) object_ref
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
AND tt.target_sourceid = m.source_id
ORDER BY tt.last_updated_date DESC nulls last)
WHERE ROWNUM < 100