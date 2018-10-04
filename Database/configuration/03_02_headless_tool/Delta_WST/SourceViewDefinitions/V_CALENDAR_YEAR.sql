CREATE OR REPLACE FORCE EDITIONABLE VIEW "V_CALENDAR_YEAR" ("OBJECT_ID", "DAYTIME", "YEAR", "RECORD_STATUS", "CREATED_BY", "CREATED_DATE", "LAST_UPDATED_BY", "LAST_UPDATED_DATE", "REV_NO", "REV_TEXT") AS 
  SELECT object_id,
       daytime,
       EXTRACT(YEAR from daytime) AS year,
       NULL record_status,
       NULL created_by,
       NULL created_date,
       NULL last_updated_by,
       NULL last_updated_date,
       NULL rev_no,
       NULL rev_text
  FROM calendar_day
 WHERE daytime = TRUNC(daytime ,'YEAR')