CREATE OR REPLACE FORCE EDITIONABLE VIEW "RV_PERIOD_INV_INT_LINE_ITEM" ("DOCUMENT_KEY", "FIELD_CODE", "PRODUCT_NAME", "SUPPLY_FROM_DATE", "SUPPLY_TO_DATE", "VAT_RATE", "VENDOR_ID", "LINE_ITEM_KEY", "CONT_LI_NAME", "INTEREST_FROM_DATE", "INTEREST_TO_DATE", "INTEREST_BASE_AMOUNT", "GROSS_RATE", "RATE_DAYS", "BOOKING_VALUE", "BOOKING_CURRENCY_CODE", "UOM1_CODE", "UOM2_CODE", "UOM3_CODE", "UOM4_CODE", "SORT_ORDER") AS 
  select max(d.document_key) document_key,
       max(lic.field_code) field_code,
       max(ec_product_version.name(t.product_id, t.daytime, '<=')) product_name,
       t.supply_from_date as supply_from_date,
       t.supply_to_date as supply_to_date,
       max(lic.vat_rate) * 100 vat_rate,
       lic.vendor_id ,
       lic.line_item_key,
       max(li.name) cont_li_name,
       max(li.interest_from_date) interest_from_date,
       max(li.interest_to_date) interest_to_date,
       max(li.interest_base_amount) interest_base_amount,
       max(li.gross_rate) gross_rate,
       max(li.rate_days) rate_days,
       sum(lic.booking_value) booking_value,
       max(d.booking_currency_code) booking_currency_code,
       max(tq.uom1_code) uom1_code,
       max(tq.uom2_code) uom2_code,
       max(tq.uom3_code) uom3_code,
       max(tq.uom4_code) uom4_code,
       max(li.sort_order) sort_order
  from rv_cont_document        d,
       rv_cont_transaction     t,
       rv_cont_transaction_qty tq,
       rv_cont_line_item       li,
       rv_cont_li_dist_company lic
 WHERE t.document_key = d.document_key
   and li.document_key = t.document_key
   and lic.document_key = li.document_key
   and t.transaction_key = li.transaction_key
   and t.transaction_key = tq.transaction_key (+)
   and li.transaction_key = lic.transaction_key
   and li.line_item_key = lic.line_item_key
   and lic.line_item_based_type = 'INTEREST'
   and d.production_day = t.production_day
   and t.production_day = li.production_day
   and li.production_day = lic.production_day
   and TRUNC(lic.production_day, 'DD') = TRUNC(d.daytime, 'DD')
 group by lic.vendor_id,
          lic.customer_id,
          t.product_code,
          t.supply_from_date,
          t.supply_to_date,
          t.delivery_point_code,
          t.transaction_key,
          lic.line_item_key
 order by max(t.sort_order),
          max(li.interest_from_date),
          max(li.line_item_key)