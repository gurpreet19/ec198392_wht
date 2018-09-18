CREATE OR REPLACE FORCE EDITIONABLE VIEW "V_IMP_STAGING_INTERFACE" ("CODE", "RECORD_STATUS", "CREATED_BY", "CREATED_DATE", "LAST_UPDATED_BY", "LAST_UPDATED_DATE", "REV_NO", "REV_TEXT") AS 
  SELECT code,
       'P' AS RECORD_STATUS,
       null AS CREATED_BY,
       null AS CREATED_DATE,
       null AS LAST_UPDATED_BY,
       null AS LAST_UPDATED_DATE,
       null AS REV_NO,
       null AS REV_TEXT
  FROM (SELECT DISTINCT i.INTERFACE_CODE CODE
          FROM imp_source_interface i
        MINUS
        SELECT DISTINCT s.INTERFACE_CODE
          FROM imp_staging s
         WHERE s.record_status in ('A')
        UNION
        SELECT DISTINCT s.INTERFACE_CODE
          FROM imp_staging s
         WHERE s.record_status in ('P', 'V'))
 ORDER BY 1 ASC