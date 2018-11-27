CREATE OR REPLACE FORCE EDITIONABLE VIEW "V_FI_DATASET_POPUP" ("CODE_TEXT", "CODE", "SORT_ORDER", "RECORD_STATUS", "CREATED_BY", "CREATED_DATE", "LAST_UPDATED_BY", "LAST_UPDATED_DATE", "REV_NO", "REV_TEXT") AS 
  SELECT code_text,
         code,
         sort_order,
         NULL record_status,
         NULL created_by,
         NULL created_date,
         NULL last_updated_by,
         NULL last_updated_date,
         NULL rev_no,
         NULL rev_text
  FROM (SELECT *
          FROM tv_ec_codes_popup
         WHERE code_type = 'FIN_ITEM_DATASET'
         AND is_active = 'Y'
          ORDER BY sort_order
      )
   WHERE rownum <= 10