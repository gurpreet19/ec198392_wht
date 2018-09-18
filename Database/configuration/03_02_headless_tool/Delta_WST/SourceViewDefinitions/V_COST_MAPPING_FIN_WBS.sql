CREATE OR REPLACE FORCE EDITIONABLE VIEW "V_COST_MAPPING_FIN_WBS" ("FIN_WBS_CODE", "DAYTIME", "RECORD_STATUS", "CREATED_BY", "CREATED_DATE", "LAST_UPDATED_BY", "LAST_UPDATED_DATE", "REV_NO", "REV_TEXT", "APPROVAL_STATE", "APPROVAL_BY", "APPROVAL_DATE") AS 
  SELECT w.object_code fin_wbs_code,
       wv.daytime,
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
  FROM fin_wbs w, fin_wbs_version wv
 WHERE w.object_id = wv.object_id
 ORDER BY fin_wbs_code