CREATE OR REPLACE FORCE EDITIONABLE VIEW "V_TRANS_INV_SKIP_INV" ("OBJECT_ID", "PROJECT_ID", "DAYTIME", "RECORD_STATUS", "CREATED_BY", "CREATED_DATE", "LAST_UPDATED_BY", "LAST_UPDATED_DATE", "REV_NO", "REV_TEXT", "APPROVAL_BY", "APPROVAL_DATE", "APPROVAL_STATE", "REC_ID", "SKIP") AS 
  SELECT tips.inventory_id object_id,
       tips.object_id project_id,
       sd.daytime daytime,
        tips.RECORD_STATUS
         ,tips.CREATED_BY
         ,tips.CREATED_DATE
         ,tips.LAST_UPDATED_BY
         ,tips.LAST_UPDATED_DATE
         ,tips.REV_NO
         ,tips.REV_TEXT
         ,tips.APPROVAL_BY
         ,tips.APPROVAL_DATE
         ,tips.APPROVAL_STATE
         ,tips.REC_ID,
       --tiv.contract_id,
       'YES' Skip
  FROM (select distinct daytime from System_Mth_Status)                         sd,
       trans_inv_prod_stream tips
 WHERE nvl(tips.end_date, sd.daytime + 1) > sd.daytime
      and tips.DAYTIME <= sd.daytime
      AND ecdp_trans_inventory.skipInventory(tips.object_id,tips.inventory_id, sd.daytime) = 'YES'