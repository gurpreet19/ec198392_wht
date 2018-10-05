CREATE OR REPLACE FORCE EDITIONABLE VIEW "V_COST_MAPPING_FIN_ACCOUNT" ("FIN_ACCOUNT_CODE", "DAYTIME", "RECORD_STATUS", "CREATED_BY", "CREATED_DATE", "LAST_UPDATED_BY", "LAST_UPDATED_DATE", "REV_NO", "REV_TEXT", "APPROVAL_STATE", "APPROVAL_BY", "APPROVAL_DATE") AS 
  SELECT fa.object_code fin_account_code,
       fav.daytime,
       'P' record_status,
       'SYSTEM' created_by,
       date '1900-01-01' created_date,
       'SYSTEM' last_updated_by,
       date '1900-01-01' last_updated_date,
       0 rev_no,
       null rev_text,
       null approval_state,
       null approval_by,
       null approval_date
  FROM fin_account fa, fin_account_version fav
 WHERE fa.object_id = fav.object_id
 ORDER BY fin_account_code