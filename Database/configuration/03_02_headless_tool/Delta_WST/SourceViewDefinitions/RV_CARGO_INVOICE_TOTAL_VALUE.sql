CREATE OR REPLACE FORCE EDITIONABLE VIEW "RV_CARGO_INVOICE_TOTAL_VALUE" ("VAT_VALUE", "VAT_RATE", "FIN_VAT_CODE", "BOOKING_CURRENCY_CODE", "TRANS_BOOKING_VALUE", "DOC_BOOKING_VAT", "DOCUMENT_KEY") AS 
  select sum(c.booking_vat_value) vat_value,
       max(c.vat_rate)*100 vat_rate,
       ec_vat_code_version.fin_vat_code(ec_vat_code.object_id_by_uk(t.vat_code),max(c.daytime),'<=') fin_vat_code,
       max(t.booking_currency_code) booking_currency_code,
       max(t.trans_booking_value) trans_booking_value,
       max(d.doc_booking_vat) doc_booking_vat,
       MAX(d.document_key) document_key
 FROM rv_cont_line_item_dist c, rv_cont_transaction t, rv_cont_document d
 where c.transaction_key = t.transaction_key
 and   t.document_key = d.document_key
 group by t.vat_code