CREATE OR REPLACE FORCE EDITIONABLE VIEW "V_OVERRIDE_DIM_DIST" ("DAYTIME", "END_DATE", "PROJECT_ID", "OBJECT_ID", "LINE_TAG", "RECORD_STATUS", "CREATED_BY", "CREATED_DATE", "LAST_UPDATED_BY", "LAST_UPDATED_DATE", "REV_NO", "REV_TEXT", "APPROVAL_BY", "APPROVAL_DATE", "APPROVAL_STATE", "REC_ID") AS 
  select distinct daytime,
                end_date,
                project_id,
                trans_inv_id as object_id,
                line_tag,
                record_status     ,
                null created_by        ,
                null created_date     ,
                null last_updated_by   ,
                null last_updated_date ,
                null rev_no            ,
                null rev_text          ,
                null approval_by       ,
                null approval_date     ,
                null approval_state    ,
                null rec_id
  from override_dimension