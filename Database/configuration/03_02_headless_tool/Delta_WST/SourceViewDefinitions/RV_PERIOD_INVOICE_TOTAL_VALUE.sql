CREATE OR REPLACE FORCE EDITIONABLE VIEW "RV_PERIOD_INVOICE_TOTAL_VALUE" ("BOOKING_VALUE_SUBTOTAL", "BOOKING_VAT_VALUE_SUBTOTAL", "BOOKING_VALUE_TOTAL_SUBTOTAL", "VAT_RATE", "BOOKING_CURRENCY_CODE", "EX_BOOKING_LOCAL", "VENDOR_ID", "DOCUMENT_KEY", "SUPPLY_FROM_DATE", "SUPPLY_TO_DATE", "OBJECT_ID") AS 
  select sum(lic.booking_value) booking_value_subtotal,
       sum(lic.booking_vat_value) booking_vat_value_subtotal,
       (sum(lic.booking_value) + sum(lic.booking_vat_value)) booking_value_total_subtotal,
       max(lic.vat_rate) vat_rate,
       max(d.booking_currency_code) booking_currency_code,
       max(d.doc_local_total)/decode(nvl(max(d.doc_booking_total),1),0,1,nvl(max(d.doc_booking_total),1)) ex_booking_local,
       lic.vendor_id vendor_id,
       max(d.document_key) document_key,
       max(t.supply_from_date) supply_from_date,
       max(t.supply_to_date) supply_to_date,
       MAX(d.object_id) object_id
  from rv_cont_document        d,
       rv_cont_line_item       li,
       rv_cont_li_dist_company lic,
       rv_cont_transaction     t
 where t.document_key = d.document_key
   and t.transaction_key = li.transaction_key
   and li.line_item_key = lic.line_item_key
   group by d.document_key,lic.vendor_id, lic.customer_id