CREATE OR REPLACE FORCE EDITIONABLE VIEW "V_CONTRACT_PRICE_OBJECTS" ("PO_TYPE", "CONTRACT_ID", "PRICE_OBJECT_ID", "PRICE_OBJECT_CODE", "PRICE_OBJECT_NAME", "PRODUCT_ID", "PRODUCT_CODE", "PRODUCT_NAME", "PRICE_CONCEPT_CODE", "PRICE_CONCEPT_NAME", "UOM", "CURRENCY_ID", "DAYTIME", "END_DATE", "OBJECT_START_DATE", "OBJECT_END_DATE", "RECORD_STATUS", "CREATED_BY", "CREATED_DATE", "LAST_UPDATED_BY", "LAST_UPDATED_DATE", "REV_NO", "REV_TEXT", "APPROVAL_STATE", "APPROVAL_BY", "APPROVAL_DATE", "REC_ID", "REVN_IND", "PRICE_ROUNDING_RULE") AS 
  SELECT 'CONTRACT'        po_type,
       pp.contract_id    contract_id,
       pp.object_id      price_object_id,
       pp.object_code    price_object_code,
       ppv.name          price_object_name,
       pp.product_id     product_id,
       ec_product.object_code(pp.product_id) product_code,
       ec_product_version.name(pp.product_id, ppv.daytime, '<=') product_name,
       pp.price_concept_code,
       ec_price_concept.name(pp.price_concept_code) price_concept_name,
       ppv.uom,
       ppv.currency_id,
       ppv.daytime,
       ppv.end_date,
       pp.start_date object_start_date,
       pp.end_date object_end_date,
       ppv.record_status,
       ppv.created_by,
       ppv.created_date,
       ppv.last_updated_by,
       ppv.last_updated_date,
       ppv.rev_no,
       ppv.rev_text,
       ppv.approval_state,
       ppv.approval_by,
       ppv.approval_date,
       ppv.rec_id,
       pp.revn_ind,
       ppv.price_rounding_rule
  FROM product_price pp, product_price_version ppv
 WHERE pp.object_id = ppv.object_id
   AND pp.contract_id IS NOT NULL
   -- Any price object daytime/version limitations must be applied to the outside query. This view will return all available versions.
UNION
SELECT 'GENERAL'         po_type,
       c.object_id       contract_id,
       gpp.object_id     price_object_id,
       gpp.object_code   price_object_code,
       gppv.name         price_object_name,
       gpp.product_id    product_id,
       ec_product.object_code(gpp.product_id) product_code,
       ec_product_version.name(gpp.product_id, gppv.daytime, '<=') product_name,
       gpp.price_concept_code,
       ec_price_concept.name(gpp.price_concept_code) price_concept_name,
       gppv.uom,
       gppv.currency_id,
       cps.daytime,
       cps.end_date,
       gpp.start_date object_start_date,
       gpp.end_date object_end_date,
       gppv.record_status,
       gppv.created_by,
       gppv.created_date,
       gppv.last_updated_by,
       gppv.last_updated_date,
       gppv.rev_no,
       gppv.rev_text,
       gppv.approval_state,
       gppv.approval_by,
       gppv.approval_date,
       gppv.rec_id,
       gpp.revn_ind,
       gppv.price_rounding_rule
  FROM contract c, contract_price_setup cps, product_price gpp, product_price_version gppv
 WHERE gpp.object_id = gppv.object_id
   AND gpp.contract_id IS NULL
   AND cps.object_id = c.object_id
   AND cps.product_price_id = gpp.object_id
   AND cps.daytime >= gppv.daytime
   AND cps.end_date <= nvl(gppv.end_date, cps.end_date + 1)
  -- Any price object daytime/version limitations must be applied to the outside query. This view will return all available versions.