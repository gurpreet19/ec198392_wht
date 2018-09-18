CREATE OR REPLACE FORCE EDITIONABLE VIEW "V_CALENDAR_USAGE" ("CALENDAR_ID", "CAL_COLL_CODE", "CAL_COLL_NAME", "VALID_FROM", "RECORD_STATUS", "CREATED_BY", "CREATED_DATE", "LAST_UPDATED_BY", "LAST_UPDATED_DATE", "REV_NO", "REV_TEXT") AS 
  SELECT x.object_id    calendar_id,
       c.object_code  cal_coll_code,
       v.name         cal_coll_name,
       x.daytime      valid_from,
       NULL           record_status,
       NULL           created_by,
       NULL           created_date,
       NULL           last_updated_by,
       NULL           last_updated_date,
       NULL           rev_no,
       NULL           rev_text
  FROM calendar_coll_setup x,
       calendar_collection c,
       calendar_coll_version v
 WHERE x.calendar_collection_id = c.object_id
   AND c.object_id = v.object_id
   AND x.daytime BETWEEN v.daytime AND NVL(v.end_date, x.daytime + 1)