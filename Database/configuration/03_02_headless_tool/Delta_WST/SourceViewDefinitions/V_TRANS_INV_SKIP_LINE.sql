CREATE OR REPLACE FORCE EDITIONABLE VIEW "V_TRANS_INV_SKIP_LINE" ("OBJECT_ID", "DAYTIME", "PRODUCT_ID", "LINE_TAG", "PROJECT_ID", "RECORD_STATUS", "CREATED_BY", "CREATED_DATE", "LAST_UPDATED_BY", "LAST_UPDATED_DATE", "REV_NO", "REV_TEXT", "APPROVAL_BY", "APPROVAL_DATE", "APPROVAL_STATE", "REC_ID", "SKIP") AS 
  SELECT tilp.object_id object_id,
       period daytime,
       null product_id,
       tilp.tag line_tag,
       tilp.contract_id project_id,
        null RECORD_STATUS
         ,null CREATED_BY
         ,null CREATED_DATE
         ,null LAST_UPDATED_BY
         ,null LAST_UPDATED_DATE
         ,null REV_NO
         ,null REV_TEXT
         ,null APPROVAL_BY
         ,null APPROVAL_DATE
         ,null  APPROVAL_STATE
         ,null REC_ID,
       'YES' Skip
  FROM v_Trans_Inv_Line_Override                tilp
  WHERE ecdp_trans_inventory.skipLine(tilp.CONTRACT_id,
                                     tilp.object_id,
                                        tilp.period,
                                        tilp.tag) = 'YES'