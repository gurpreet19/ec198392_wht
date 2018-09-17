CREATE OR REPLACE FORCE EDITIONABLE VIEW "V_TRANS_INV_SKIP_PROD" ("OBJECT_ID", "DAYTIME", "PRODUCT_ID", "PROJECT_ID", "COST_TYPE", "LINE_TAG", "RECORD_STATUS", "CREATED_BY", "CREATED_DATE", "LAST_UPDATED_BY", "LAST_UPDATED_DATE", "REV_NO", "REV_TEXT", "APPROVAL_BY", "APPROVAL_DATE", "APPROVAL_STATE", "REC_ID", "SKIP") AS 
  SELECT tilp.object_id object_id,
       period daytime,
       product_id || '|'||cost_type as product_id,
       project project_id,
       cost_type,
       line_tag,
        null RECORD_STATUS
         ,null CREATED_BY
         ,null CREATED_DATE
         ,null LAST_UPDATED_BY
         ,null LAST_UPDATED_DATE
         ,null REV_NO
         ,null REV_TEXT
         ,null APPROVAL_BY
         ,null APPROVAL_DATE
         ,null APPROVAL_STATE
         ,null REC_ID,
       'YES' Skip
  FROM v_TRANS_INV_LI_PR_OVER                tilp
  WHERE ecdp_trans_inventory.SkipProduct(tilp.project,
                                        tilp.object_id,
                                     period,
                                     product_id,
                                     cost_type,
                                     tilp.line_tag) = 'YES'