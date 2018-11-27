CREATE OR REPLACE FORCE EDITIONABLE VIEW "RV_CARGO_PERCENT_LINE_ITEM" ("DOCUMENT_KEY", "PRODUCT_NAME", "VAT_CODE", "VAT_RATE", "VENDOR_ID", "LINE_ITEM_KEY", "CONT_LI_NAME", "PERCENTAGE_BASE_AMOUNT", "PERCENTAGE_VALUE", "BOOKING_VALUE", "BOOKING_CURRENCY_CODE", "SORT_ORDER", "DISCHARGE_PORT_NAME", "LOADING_PORT_NAME", "CARGO_NAME", "CARRIER_ID", "BL_DATE", "DAYTIME", "DOCUMENT_DATE", "UOM1_CODE", "UOM2_CODE", "UOM3_CODE", "UOM4_CODE") AS 
  select max(d.document_key) document_key,
       max(ec_product_version.name(t.product_id, t.daytime, '<=')) product_name,
       ec_vat_code_version.fin_vat_code(ec_vat_code.object_id_by_uk(max(t.vat_code)),
                                        max(t.daytime),
                                        '<=') vat_code,
       max(lic.vat_rate) vat_rate,
       lic.vendor_id,
       max(lic.line_item_key) line_item_key,
       max(li.name) cont_li_name,
       max(li.percentage_base_amount) percentage_base_amount,
       max(li.percentage_value) percentage_value,
       sum(lic.booking_value) booking_value,
       max(d.booking_currency_code) booking_currency_code,
       max(li.sort_order) sort_order,
       ec_port_version.name(t.discharge_port_id, max(d.daytime), '<=') discharge_port_name,
       ec_port_version.name(t.loading_port_id, max(d.daytime), '<=') loading_port_name,
       t.cargo_name,
       t.carrier_id,
       t.bl_date,
       max(d.daytime) daytime,
       max(d.document_date) document_date,
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
   and t.document_key = li.document_key
   and li.document_key = lic.document_key
   and t.transaction_key = li.transaction_key
   and t.transaction_key = tq.transaction_key (+)
   and lic.line_item_key = li.line_item_key
   and li.line_item_based_type like '%PERCENTAGE%'
   and d.production_day = t.production_day
   and t.production_day = li.production_day
   and li.production_day = lic.production_day
   and lic.production_day = d.daytime
 group by lic.document_key,
          lic.vendor_id,
          lic.customer_id,
          t.discharge_port_id,
          t.loading_port_id,
          t.cargo_name,
          t.parcel_name,
          t.carrier_id,
          t.bl_date,
          t.transaction_key,
          lic.line_item_key
 order by max(t.sort_order), max(li.line_item_key)