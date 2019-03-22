CREATE OR REPLACE FORCE EDITIONABLE VIEW "V_CALENDAR_COLL_DAY_COMMENT" ("CALENDAR_COLLECTION_ID", "COMMENT_NO", "OBJECT_ID", "DAYTIME", "COMMENTS", "RECORD_STATUS", "CREATED_BY", "CREATED_DATE", "LAST_UPDATED_BY", "LAST_UPDATED_DATE", "REV_NO", "REV_TEXT") AS 
  SELECT ccs.calendar_collection_id,
       cdc.comment_no,
       cdc.object_id,
       cdc.daytime,
       cdc.comments,
       NULL record_status,
       NULL created_by,
       NULL created_date,
       NULL last_updated_by,
       NULL last_updated_date,
       NULL rev_no,
       NULL rev_text
FROM calendar_coll_setup ccs,
     calendar_day_comment cdc
WHERE ccs.object_id = cdc.object_id