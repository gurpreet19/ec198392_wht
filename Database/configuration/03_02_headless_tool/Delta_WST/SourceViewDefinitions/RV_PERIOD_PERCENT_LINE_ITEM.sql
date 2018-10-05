CREATE OR REPLACE FORCE EDITIONABLE VIEW "RV_PERIOD_PERCENT_LINE_ITEM" ("PRODUCT_NAME", "VAT_RATE", "CONT_LI_NAME", "PERCENTAGE_BASE_AMOUNT", "PERCENTAGE_VALUE", "BOOKING_VALUE", "BOOKING_CURRENCY_CODE", "FIELD_CODE", "SORT_ORDER", "LINE_ITEM_KEY", "VENDOR_ID", "SUPPLY_FROM_DATE", "SUPPLY_TO_DATE", "DOCUMENT_KEY", "UOM1_CODE", "UOM2_CODE", "UOM3_CODE", "UOM4_CODE") AS 
  select max(ec_product_version.name(t.product_id, t.daytime, '<=')) product_name,
       max(lic.vat_rate) * 100 vat_rate,
       max(li.name) cont_li_name,
       max(li.percentage_base_amount) percentage_base_amount,
       max(li.percentage_value) percentage_value,
       sum(lic.booking_value) booking_value,
       max(d.booking_currency_code) booking_currency_code,
       max(lic.field_code) field_code,
       max(li.sort_order) sort_order,
       lic.line_item_key,
       lic.vendor_id,
       t.supply_from_date,
       t.supply_to_date,
       max(d.document_key) document_key,
       max(tq.uom1_code) uom1_code,
       max(tq.uom2_code) uom2_code,
       max(tq.uom3_code) uom3_code,
       max(tq.uom4_code) uom4_code
  from rv_cont_document        d,
       rv_cont_transaction     t,
       rv_cont_transaction_qty tq,
       rv_cont_line_item       li,
       rv_cont_li_dist_company lic
 WHERE t.document_key = d.document_key
   and t.DOCUMENT_KEY = li.DOCUMENT_KEY
   and li.line_item_key = lic.line_item_key
   and t.transaction_key = li.transaction_key
   and t.transaction_key = tq.transaction_key (+)
   and lic.line_item_based_type like '%PERCENTAGE%'
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
 order by max(t.sort_order), max(li.line_item_key)