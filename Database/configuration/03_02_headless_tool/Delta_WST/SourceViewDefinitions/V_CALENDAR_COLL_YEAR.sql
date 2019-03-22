CREATE OR REPLACE FORCE EDITIONABLE VIEW "V_CALENDAR_COLL_YEAR" ("CALENDAR_COLLECTION_ID", "OBJECT_ID", "DAYTIME", "YEAR", "RECORD_STATUS", "CREATED_BY", "CREATED_DATE", "LAST_UPDATED_BY", "LAST_UPDATED_DATE", "REV_NO", "REV_TEXT") AS 
  SELECT ccs.calendar_collection_id,
       cd.object_id,
       cd.daytime,
       EXTRACT(YEAR FROM cd.daytime) AS year,
       NULL record_status,
       NULL created_by,
       NULL created_date,
       NULL last_updated_by,
       NULL last_updated_date,
       NULL rev_no,
       NULL rev_text
FROM calendar_coll_setup ccs,
     v_calendar_year cd
WHERE ccs.object_id = cd.object_id
ORDER BY ccs.calendar_collection_id, cd.daytime