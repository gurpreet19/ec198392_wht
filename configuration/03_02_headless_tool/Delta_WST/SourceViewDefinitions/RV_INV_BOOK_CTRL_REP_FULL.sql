CREATE OR REPLACE FORCE EDITIONABLE VIEW "RV_INV_BOOK_CTRL_REP_FULL" ("NUM", "OBJECT_ID", "DAYTIME", "YEAR_CODE", "PK", "ACCT", "COSTOBJECT", "PRODUCT", "ACCT_DESC", "DR_BOOKING_VALUE", "CR_BOOKING_VALUE", "DR_LOCAL", "CR_LOCAL", "DR_GROUP", "CR_GROUP") AS 
  (
SELECT 1 num,
       idv.object_id,
       idv.daytime,
       idv.year_code,
       idv.fin_debit_posting_key pk,
       idv.Fin_Debit_Gl_Account acct,
       idv.fin_debit_cost_object costobject,
       ec_product_version.name(idv.product_id, idv.daytime, '<=') product,
       ec_fin_account_version.name(idv.fin_debit_account_id,
                                   idv.daytime,
                                   '<=') acct_desc,
       case when (nvl(idv.ul_booking_value,0) > 0 AND nvl(idv.ol_booking_value,0) = 0) then idv.ul_booking_value
            when (nvl(idv.ul_booking_value,0) = 0  AND nvl(idv.ol_booking_value,0) > 0) then idv.ol_booking_value end dr_booking_value,
       NULL cr_booking_value,
       case when (nvl(idv.ul_booking_value,0) > 0 AND nvl(idv.ol_booking_value,0) = 0) then idv.ul_local_value
            when (nvl(idv.ul_booking_value,0) = 0  AND nvl(idv.ol_booking_value,0) > 0) then idv.ol_local_value end dr_local,
       NULL cr_local,
       case when (nvl(idv.ul_booking_value,0) > 0 AND nvl(idv.ol_booking_value,0) = 0) then idv.ul_group_value
            when (nvl(idv.ul_booking_value,0) = 0  AND nvl(idv.ol_booking_value,0) > 0) then idv.ol_group_value end dr_group,
       NULL cr_group
  FROM rv_inv_valuation iv, rv_inv_dist_valuation idv
 WHERE idv.object_id = iv.object_id
   AND idv.daytime = iv.daytime
   AND idv.year_code = iv.year_code
   AND nvl(iv.document_level_code,'OPEN') <> 'OPEN'
--   AND idv.year_code = to_char(idv.daytime, 'YYYY')
   AND ecdp_inventory.isinunderlift(idv.object_id,idv.daytime) = 'TRUE'
   AND
   ((
       nvl(idv.ul_booking_value,0) > 0 AND nvl(idv.ol_booking_value,0) = 0
   )
   OR
   (
       nvl(idv.ul_booking_value,0) = 0 AND nvl(idv.ol_booking_value,0) > 0
   ))
   AND NVL(ec_ctrl_system_attribute.attribute_text(idv.daytime, 'CUST_IN_BOOK_REPORT', '<='), 'XXX') <> 'CUSTOM'
UNION ALL
SELECT 2 num,
       idv.object_id,
       idv.daytime,
       idv.year_code,
       idv.fin_credit_posting_key pk,
       idv.Fin_credit_Gl_Account acct,
       idv.fin_credit_cost_object costobject,
       ec_product_version.name(idv.product_id, idv.daytime, '<=') product,
       ec_fin_account_version.name(idv.fin_credit_account_id,
                                   idv.daytime,
                                   '<=') acct_desc,
       NULL dr_booking_value,
       case when (nvl(idv.ul_booking_value,0) = 0 AND nvl(idv.ol_booking_value,0) < 0) then idv.ol_booking_value
            when (nvl(idv.ul_booking_value,0) < 0 AND nvl(idv.ol_booking_value,0) = 0) then idv.ul_booking_value end cr_booking_value,
       NULL dr_local,
       case when (nvl(idv.ul_booking_value,0) = 0 AND nvl(idv.ol_booking_value,0) < 0) then idv.ol_local_value
            when (nvl(idv.ul_booking_value,0) < 0 AND nvl(idv.ol_booking_value,0) = 0) then idv.ul_local_value end cr_local,
       NULL dr_group,
       case when (nvl(idv.ul_booking_value,0) = 0 AND nvl(idv.ol_booking_value,0) < 0) then idv.ol_group_value
            when (nvl(idv.ul_booking_value,0) < 0 AND nvl(idv.ol_booking_value,0) = 0) then idv.ul_group_value end cr_group
       FROM rv_inv_valuation iv, rv_inv_dist_valuation idv
 WHERE idv.object_id = iv.object_id
   AND idv.daytime = iv.daytime
   AND idv.year_code = iv.year_code
   AND nvl(iv.document_level_code,'OPEN') <> 'OPEN'
--   AND idv.year_code = to_char(idv.daytime, 'YYYY')
   AND ecdp_inventory.isinunderlift(idv.object_id,idv.daytime) = 'TRUE'
   AND
   ((
       nvl(idv.ul_booking_value,0) = 0 AND nvl(idv.ol_booking_value,0) < 0
   )
   OR
   (
       nvl(idv.ul_booking_value,0) < 0 AND nvl(idv.ol_booking_value,0) = 0
   ))
   AND NVL(ec_ctrl_system_attribute.attribute_text(idv.daytime, 'CUST_IN_BOOK_REPORT', '<='), 'XXX') <> 'CUSTOM'
UNION ALL
SELECT 3 num,
       idv.object_id,
       idv.daytime,
       idv.year_code,
       idv.fin_debit_posting_key pk,
       idv.Fin_Debit_Gl_Account acct,
       idv.fin_debit_cost_object costobject,
       ec_product_version.name(idv.product_id, idv.daytime, '<=') product,
       ec_fin_account_version.name(idv.fin_debit_account_id,
                                   idv.daytime,
                                   '<=') acct_desc,
       case when (nvl(idv.ul_booking_value,0) > 0 AND nvl(idv.ol_booking_value,0) = 0) then idv.ul_booking_value
            when (nvl(idv.ul_booking_value,0) = 0 AND nvl(idv.ol_booking_value,0) > 0) then idv.ol_booking_value end dr_booking_value,
       NULL cr_booking_value,
       case when (nvl(idv.ul_booking_value,0) > 0 AND nvl(idv.ol_booking_value,0) = 0) then idv.ul_local_value
            when (nvl(idv.ul_booking_value,0) = 0 AND nvl(idv.ol_booking_value,0) > 0) then idv.ol_local_value end dr_local,
       NULL cr_local,
       case when (nvl(idv.ul_booking_value,0) > 0 AND nvl(idv.ol_booking_value,0) = 0) then idv.ul_group_value
            when (nvl(idv.ul_booking_value,0) = 0 AND nvl(idv.ol_booking_value,0) > 0) then idv.ol_group_value end dr_group,
       NULL cr_group
  FROM rv_inv_valuation iv, rv_inv_dist_valuation idv
 WHERE idv.object_id = iv.object_id
   AND idv.daytime = iv.daytime
   AND idv.year_code = iv.year_code
   AND nvl(iv.document_level_code,'OPEN') <> 'OPEN'
--   AND idv.year_code = to_char(idv.daytime, 'YYYY')
   AND ecdp_inventory.isinunderlift(idv.object_id,idv.daytime) = 'FALSE'
   AND
   ((
       nvl(idv.ul_booking_value,0) > 0 AND nvl(idv.ol_booking_value,0) = 0
   )
   OR
   (
       nvl(idv.ul_booking_value,0) = 0 AND nvl(idv.ol_booking_value,0) > 0
   ))
   AND NVL(ec_ctrl_system_attribute.attribute_text(idv.daytime, 'CUST_IN_BOOK_REPORT', '<='), 'XXX') <> 'CUSTOM'
UNION ALL
SELECT 4 num,
       idv.object_id,
       idv.daytime,
       idv.year_code,
       idv.fin_credit_posting_key pk,
       idv.Fin_credit_Gl_Account acct,
       idv.fin_credit_cost_object costobject,
       ec_product_version.name(idv.product_id, idv.daytime, '<=') product,
       ec_fin_account_version.name(idv.fin_credit_account_id,
                                   idv.daytime,
                                   '<=') acct_desc,
       NULL dr_booking_value,
       case when (nvl(idv.ul_booking_value,0) = 0 AND nvl(idv.ol_booking_value,0) < 0) then idv.ol_booking_value
            when (nvl(idv.ul_booking_value,0) < 0 AND nvl(idv.ol_booking_value,0) = 0) then idv.ul_booking_value end cr_booking_value,
       NULL dr_local,
       case when (nvl(idv.ul_booking_value,0) = 0 AND nvl(idv.ol_booking_value,0) < 0) then idv.ol_local_value
            when (nvl(idv.ul_booking_value,0) < 0 AND nvl(idv.ol_booking_value,0) = 0) then idv.ul_local_value end cr_local,
       NULL dr_group,
       case when (nvl(idv.ul_booking_value,0) = 0 AND nvl(idv.ol_booking_value,0) < 0) then idv.ol_group_value
            when (nvl(idv.ul_booking_value,0) < 0 AND nvl(idv.ol_booking_value,0) = 0) then idv.ul_group_value end cr_group
       FROM rv_inv_valuation iv, rv_inv_dist_valuation idv
 WHERE idv.object_id = iv.object_id
   AND idv.daytime = iv.daytime
   AND idv.year_code = iv.year_code
   AND nvl(iv.document_level_code,'OPEN') <> 'OPEN'
--   AND idv.year_code = to_char(idv.daytime, 'YYYY')
   AND ecdp_inventory.isinunderlift(idv.object_id,idv.daytime) = 'FALSE'
   AND
   ((
       nvl(idv.ul_booking_value,0) = 0 AND nvl(idv.ol_booking_value,0) < 0
   )
   OR
   (
       nvl(idv.ul_booking_value,0) < 0 AND nvl(idv.ol_booking_value,0) = 0
   ))
   AND NVL(ec_ctrl_system_attribute.attribute_text(idv.daytime, 'CUST_IN_BOOK_REPORT', '<='), 'XXX') <> 'CUSTOM'
UNION ALL
SELECT 5 num,
       idv.object_id,
       idv.daytime,
       idv.year_code,
       idv.fin_ps_debit_posting_key pk,
       idv.Fin_ps_debit_Gl_Account acct,
       idv.fin_ps_debit_cost_object costobject,
       ec_product_version.name(idv.product_id, idv.daytime, '<=') product,
       ec_fin_account_version.name(idv.fin_ps_debit_account_id,
                                   idv.daytime,
                                   '<=') acct_desc,
       idv.ps_booking_value dr_booking_value,
       NULL cr_booking_value,
       idv.ps_local_value dr_local,
       NULL cr_local,
       idv.ps_group_value dr_group,
       NULL cr_group
  FROM rv_inv_valuation iv, rv_inv_dist_valuation idv
 WHERE idv.object_id = iv.object_id
   AND idv.daytime = iv.daytime
   AND idv.year_code = iv.year_code
   AND nvl(iv.document_level_code,'OPEN') <> 'OPEN'
   AND ec_inventory_version.physical_stock_ind(idv.object_id, idv.daytime, '<=') = 'Y'
--   AND idv.year_code = to_char(idv.daytime, 'YYYY')
   AND ecdp_inventory.isinunderlift(idv.object_id,idv.daytime) = 'TRUE'
   AND NVL(ec_ctrl_system_attribute.attribute_text(idv.daytime, 'CUST_IN_BOOK_REPORT', '<='), 'XXX') <> 'CUSTOM'
 UNION ALL
SELECT 6 num,
       idv.object_id,
       idv.daytime,
       idv.year_code,
       idv.fin_ps_credit_post_key pk,
       idv.Fin_ps_credit_Gl_Account acct,
       idv.fin_ps_credit_cost_obj costobject,
       ec_product_version.name(idv.product_id, idv.daytime, '<=') product,
       ec_fin_account_version.name(idv.fin_ps_credit_account_id,
                                   idv.daytime,
                                   '<=') acct_desc,
       NULL dr_booking_value,
       idv.ps_booking_value cr_booking_value,
       NULL dr_local,
       idv.ps_local_value cr_local,
       NULL dr_group,
       idv.ps_group_value cr_group
  FROM rv_inv_valuation iv, rv_inv_dist_valuation idv
 WHERE idv.object_id = iv.object_id
   AND idv.daytime = iv.daytime
   AND idv.year_code = iv.year_code
   AND nvl(iv.document_level_code,'OPEN') <> 'OPEN'
   AND ec_inventory_version.physical_stock_ind(idv.object_id, idv.daytime, '<=') = 'Y'
--   AND idv.year_code = to_char(idv.daytime, 'YYYY')
   AND ecdp_inventory.isinunderlift(idv.object_id,idv.daytime) = 'FALSE'
   AND NVL(ec_ctrl_system_attribute.attribute_text(idv.daytime, 'CUST_IN_BOOK_REPORT', '<='), 'XXX') <> 'CUSTOM'
UNION ALL
SELECT 7 num,
       idv.object_id,
       idv.daytime,
       idv.year_code,
       idv.fin_credit_posting_key pk,
       idv.Fin_credit_Gl_Account acct,
       idv.fin_credit_cost_object costobject,
       ec_product_version.name(idv.product_id, idv.daytime, '<=') product,
       ec_fin_account_version.name(idv.fin_credit_account_id,
                                   idv.daytime,
                                   '<=') acct_desc,
       NULL dr_booking_value,
       case when (nvl(idv.ul_booking_value,0) > 0 AND nvl(idv.ol_booking_value,0) = 0) then idv.ul_booking_value
            when (nvl(idv.ul_booking_value,0) = 0 AND nvl(idv.ol_booking_value,0) > 0) then idv.ol_booking_value end cr_booking_value,
       NULL dr_local,
       case when (nvl(idv.ul_booking_value,0) > 0 AND nvl(idv.ol_booking_value,0) = 0) then idv.ul_local_value
            when (nvl(idv.ul_booking_value,0) = 0 AND nvl(idv.ol_booking_value,0) > 0) then idv.ol_local_value end cr_local,
       NULL dr_group,
       case when (nvl(idv.ul_booking_value,0) > 0 AND nvl(idv.ol_booking_value,0) = 0) then idv.ul_group_value
            when (nvl(idv.ul_booking_value,0) = 0 AND nvl(idv.ol_booking_value,0) > 0) then idv.ol_group_value end cr_group
  FROM rv_inv_valuation iv, rv_inv_dist_valuation idv
 WHERE idv.object_id = iv.object_id
   AND idv.daytime = iv.daytime
   AND idv.year_code = iv.year_code
   AND nvl(iv.document_level_code,'OPEN') <> 'OPEN'
--   AND idv.year_code = to_char(idv.daytime, 'YYYY')
   AND ecdp_inventory.isinunderlift(idv.object_id,idv.daytime) = 'TRUE'
   AND
   ((
       nvl(idv.ul_booking_value,0) > 0 AND nvl(idv.ol_booking_value,0) = 0
   )
   OR
   (
       nvl(idv.ul_booking_value,0) = 0 AND nvl(idv.ol_booking_value,0) > 0
   ))
   AND NVL(ec_ctrl_system_attribute.attribute_text(idv.daytime, 'CUST_IN_BOOK_REPORT', '<='), 'XXX') <> 'CUSTOM'
UNION ALL
SELECT 8 num,
       idv.object_id,
       idv.daytime,
       idv.year_code,
       idv.fin_debit_posting_key pk,
       idv.Fin_debit_Gl_Account acct,
       idv.fin_debit_cost_object costobject,
       ec_product_version.name(idv.product_id, idv.daytime, '<=') product,
       ec_fin_account_version.name(idv.fin_debit_account_id,
                                   idv.daytime,
                                   '<=') acct_desc,
       case when (nvl(idv.ul_booking_value,0) = 0 AND nvl(idv.ol_booking_value,0) < 0) then idv.ol_booking_value
            when (nvl(idv.ul_booking_value,0) < 0 AND nvl(idv.ol_booking_value,0) = 0) then idv.ul_booking_value end dr_booking_value,
       NULL cr_booking_value,
       case when (nvl(idv.ul_booking_value,0) = 0 AND nvl(idv.ol_booking_value,0) < 0) then idv.ol_local_value
            when (nvl(idv.ul_booking_value,0) < 0 AND nvl(idv.ol_booking_value,0) = 0) then idv.ul_local_value end dr_local,
       NULL cr_local,
       case when (nvl(idv.ul_booking_value,0) = 0 AND nvl(idv.ol_booking_value,0) < 0) then idv.ol_group_value
            when (nvl(idv.ul_booking_value,0) < 0 AND nvl(idv.ol_booking_value,0) = 0) then idv.ul_group_value end dr_group,
       NULL cr_group
  FROM rv_inv_valuation iv, rv_inv_dist_valuation idv
 WHERE idv.object_id = iv.object_id
   AND idv.daytime = iv.daytime
   AND idv.year_code = iv.year_code
   AND nvl(iv.document_level_code,'OPEN') <> 'OPEN'
--   AND idv.year_code = to_char(idv.daytime, 'YYYY')
   AND ecdp_inventory.isinunderlift(idv.object_id,idv.daytime) = 'TRUE'
   AND
   ((
       nvl(idv.ul_booking_value,0) = 0 AND nvl(idv.ol_booking_value,0) < 0
   )
   OR
   (
       nvl(idv.ul_booking_value,0) < 0 AND nvl(idv.ol_booking_value,0) = 0
   ))
   AND NVL(ec_ctrl_system_attribute.attribute_text(idv.daytime, 'CUST_IN_BOOK_REPORT', '<='), 'XXX') <> 'CUSTOM'
UNION ALL
SELECT 9 num,
       idv.object_id,
       idv.daytime,
       idv.year_code,
       idv.fin_credit_posting_key pk,
       idv.Fin_credit_Gl_Account acct,
       idv.fin_credit_cost_object costobject,
       ec_product_version.name(idv.product_id, idv.daytime, '<=') product,
       ec_fin_account_version.name(idv.fin_credit_account_id,
                                   idv.daytime,
                                   '<=') acct_desc,
       NULL dr_booking_value,
       case when (nvl(idv.ul_booking_value,0) > 0 AND nvl(idv.ol_booking_value,0) = 0) then idv.ul_booking_value
            when (nvl(idv.ul_booking_value,0) = 0 AND nvl(idv.ol_booking_value,0) > 0) then idv.ol_booking_value end cr_booking_value,
       NULL dr_local,
       case when (nvl(idv.ul_booking_value,0) > 0 AND nvl(idv.ol_booking_value,0) = 0) then idv.ul_local_value
            when (nvl(idv.ul_booking_value,0) = 0 AND nvl(idv.ol_booking_value,0) > 0) then idv.ol_local_value end cr_local,
       NULL dr_group,
       case when (nvl(idv.ul_booking_value,0) > 0 AND nvl(idv.ol_booking_value,0) = 0) then idv.ul_group_value
            when (nvl(idv.ul_booking_value,0) = 0 AND nvl(idv.ol_booking_value,0) > 0) then idv.ol_group_value end cr_group
  FROM rv_inv_valuation iv, rv_inv_dist_valuation idv
 WHERE idv.object_id = iv.object_id
   AND idv.daytime = iv.daytime
   AND idv.year_code = iv.year_code
   AND nvl(iv.document_level_code,'OPEN') <> 'OPEN'
--   AND idv.year_code = to_char(idv.daytime, 'YYYY')
   AND ecdp_inventory.isinunderlift(idv.object_id,idv.daytime) = 'FALSE'
   AND
   ((
       nvl(idv.ul_booking_value,0) > 0 AND nvl(idv.ol_booking_value,0) = 0
   )
   OR
   (
       nvl(idv.ul_booking_value,0) = 0 AND nvl(idv.ol_booking_value,0) > 0
   ))
   AND NVL(ec_ctrl_system_attribute.attribute_text(idv.daytime, 'CUST_IN_BOOK_REPORT', '<='), 'XXX') <> 'CUSTOM'
UNION ALL
SELECT 10 num,
       idv.object_id,
       idv.daytime,
       idv.year_code,
       idv.fin_debit_posting_key pk,
       idv.Fin_debit_Gl_Account acct,
       idv.fin_debit_cost_object costobject,
       ec_product_version.name(idv.product_id, idv.daytime, '<=') product,
       ec_fin_account_version.name(idv.fin_debit_account_id,
                                   idv.daytime,
                                   '<=') acct_desc,
       case when (nvl(idv.ul_booking_value,0) = 0 AND nvl(idv.ol_booking_value,0) < 0) then idv.ol_booking_value
            when (nvl(idv.ul_booking_value,0) < 0 AND nvl(idv.ol_booking_value,0) = 0) then idv.ul_booking_value end dr_booking_value,
       NULL cr_booking_value,
       case when (nvl(idv.ul_booking_value,0) = 0 AND nvl(idv.ol_booking_value,0) < 0) then idv.ol_local_value
            when (nvl(idv.ul_booking_value,0) < 0 AND nvl(idv.ol_booking_value,0) = 0) then idv.ul_local_value end dr_local,
       NULL cr_local,
       case when (nvl(idv.ul_booking_value,0) = 0 AND nvl(idv.ol_booking_value,0) < 0) then idv.ol_group_value
            when (nvl(idv.ul_booking_value,0) < 0 AND nvl(idv.ol_booking_value,0) = 0) then idv.ul_group_value end dr_group,
       NULL cr_group
  FROM rv_inv_valuation iv, rv_inv_dist_valuation idv
 WHERE idv.object_id = iv.object_id
   AND idv.daytime = iv.daytime
   AND idv.year_code = iv.year_code
   AND nvl(iv.document_level_code,'OPEN') <> 'OPEN'
--   AND idv.year_code = to_char(idv.daytime, 'YYYY')
   AND ecdp_inventory.isinunderlift(idv.object_id,idv.daytime) = 'FALSE'
   AND
   ((
       nvl(idv.ul_booking_value,0) = 0 AND nvl(idv.ol_booking_value,0) < 0
   )
   OR
   (
       nvl(idv.ul_booking_value,0) < 0 AND nvl(idv.ol_booking_value,0) = 0
   ))
   AND NVL(ec_ctrl_system_attribute.attribute_text(idv.daytime, 'CUST_IN_BOOK_REPORT', '<='), 'XXX') <> 'CUSTOM'
UNION ALL
SELECT 11 num,
       idv.object_id,
       idv.daytime,
       idv.year_code,
       idv.fin_ps_credit_post_key pk,
       idv.Fin_ps_credit_Gl_Account acct,
       idv.fin_ps_credit_cost_obj costobject,
       ec_product_version.name(idv.product_id, idv.daytime, '<=') product,
       ec_fin_account_version.name(idv.fin_ps_credit_account_id,
                                   idv.daytime,
                                   '<=') acct_desc,
       NULL dr_booking_value,
       idv.ps_booking_value cr_booking_value,
       NULL dr_local,
       idv.ps_local_value cr_local,
       NULL dr_group,
       idv.ps_group_value cr_group
  FROM rv_inv_valuation iv, rv_inv_dist_valuation idv
 WHERE idv.object_id = iv.object_id
   AND idv.daytime = iv.daytime
   AND idv.year_code = iv.year_code
   AND nvl(iv.document_level_code,'OPEN') <> 'OPEN'
   AND ec_inventory_version.physical_stock_ind(idv.object_id, idv.daytime, '<=') = 'Y'
--   AND idv.year_code = to_char(idv.daytime, 'YYYY')
   AND ecdp_inventory.isinunderlift(idv.object_id,idv.daytime) = 'TRUE'
   AND NVL(ec_ctrl_system_attribute.attribute_text(idv.daytime, 'CUST_IN_BOOK_REPORT', '<='), 'XXX') <> 'CUSTOM'
  UNION ALL
SELECT 12 num,
       idv.object_id,
       idv.daytime,
       idv.year_code,
       idv.fin_ps_debit_posting_key pk,
       idv.Fin_ps_debit_Gl_Account acct,
       idv.fin_ps_debit_cost_object costobject,
       ec_product_version.name(idv.product_id, idv.daytime, '<=') product,
       ec_fin_account_version.name(idv.fin_ps_debit_account_id,
                                   idv.daytime,
                                   '<=') acct_desc,
       idv.ps_booking_value dr_booking_value,
       NULL cr_booking_value,
       idv.ps_local_value dr_local,
       NULL cr_local,
       idv.ps_group_value dr_group,
       NULL cr_group
  FROM rv_inv_valuation iv, rv_inv_dist_valuation idv
 WHERE idv.object_id = iv.object_id
   AND idv.daytime = iv.daytime
   AND idv.year_code = iv.year_code
   AND nvl(iv.document_level_code,'OPEN') <> 'OPEN'
   AND ec_inventory_version.physical_stock_ind(idv.object_id, idv.daytime, '<=') = 'Y'
--   AND idv.year_code = to_char(idv.daytime, 'YYYY')
   AND ecdp_inventory.isinunderlift(idv.object_id,idv.daytime) = 'FALSE'
   AND NVL(ec_ctrl_system_attribute.attribute_text(idv.daytime, 'CUST_IN_BOOK_REPORT', '<='), 'XXX') <> 'CUSTOM'
   )
UNION ALL
SELECT "NUM","OBJECT_ID","DAYTIME","YEAR_CODE","PK","ACCT","COSTOBJECT","PRODUCT","ACCT_DESC","DR_BOOKING_VALUE","CR_BOOKING_VALUE","DR_LOCAL","CR_LOCAL","DR_GROUP","CR_GROUP" FROM Z_RV_INV_BOOK_CTRL_REP_FULL