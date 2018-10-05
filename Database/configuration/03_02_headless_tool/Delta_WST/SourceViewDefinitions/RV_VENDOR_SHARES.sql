CREATE OR REPLACE FORCE EDITIONABLE VIEW "RV_VENDOR_SHARES" ("VENDOR_ID", "BOOKING_CURRENCY_CODE", "OFFICIAL_NAME", "VENDOR_SHARE", "TOTAL_VALUE", "VALUE_EX_VAT", "VAT", "DOCUMENT_KEY") AS 
  (
select clic.vendor_id,
       Ec_Cont_Document.Booking_Currency_Code(clic.document_key) AS booking_currency_code,
       ec_company_version.official_name(clic.vendor_id,max(clic.daytime),'<=') official_name,
       ecdp_document.getdocumentvendorshareactual(clic.document_key,clic.vendor_id) vendor_share,
       abs(sum(clic.booking_value)+sum(clic.booking_vat_value)) total_value,
       abs(sum(clic.booking_value)) value_ex_vat,
       abs(sum(clic.booking_vat_value)) vat,
       clic.document_key
  from rv_cont_li_dist_company clic
  group by clic.document_key,clic.vendor_id
)
order by ec_company_version.official_name(clic.vendor_id,max(clic.daytime),'<=')