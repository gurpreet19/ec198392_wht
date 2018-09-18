CREATE OR REPLACE FORCE EDITIONABLE VIEW "V_DAYS_IN_MONTH" ("DAY", "RECORD_STATUS", "CREATED_BY", "CREATED_DATE", "LAST_UPDATED_BY", "LAST_UPDATED_DATE", "REV_NO", "REV_TEXT") AS 
  SELECT level day
,NULL record_status
,NULL created_by
,NULL created_date
,NULL last_updated_by
,NULL last_updated_date
,NULL rev_no
,NULL rev_text
FROM dual
CONNECT BY level <= 31