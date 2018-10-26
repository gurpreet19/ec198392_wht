CREATE OR REPLACE FORCE EDITIONABLE VIEW "V_IMP_STAGING_FILENAME" ("INTERFACE_CODE", "FILE_NAME", "RECORD_STATUS", "CREATED_BY", "CREATED_DATE", "LAST_UPDATED_BY", "LAST_UPDATED_DATE", "REV_NO", "REV_TEXT") AS 
  SELECT DISTINCT s.INTERFACE_CODE,
                s.FILE_NAME,
                'P' AS RECORD_STATUS ,
                null AS CREATED_BY,
                null AS CREATED_DATE,
                null AS LAST_UPDATED_BY,
                null AS LAST_UPDATED_DATE,
                null AS REV_NO,
                null AS REV_TEXT
  FROM imp_staging s
 WHERE s.record_status in ('P', 'V')
 order by s.INTERFACE_CODE ASC