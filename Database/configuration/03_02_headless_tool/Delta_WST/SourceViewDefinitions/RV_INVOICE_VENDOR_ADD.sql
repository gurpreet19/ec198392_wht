CREATE OR REPLACE FORCE EDITIONABLE VIEW "RV_INVOICE_VENDOR_ADD" ("DOCUMENT_KEY", "OUR_CONTACT", "PRODUCTION_DAY", "NAME", "OFFICIAL_NAME", "ADDRESS_1", "ADDRESS_2", "ADDRESS_3", "ADDRESS_4", "ADDRESS_5", "ADDRESS_6", "ADDRESS_7", "ADDRESS_8", "PHONE", "FAX", "VENDOR_ID", "VAT_REG_NO", "CHAMBER_COMMERCE", "REPORTER_CODE") AS 
  SELECT
  d.document_key,
  d.our_contact,
  v.production_day,
  V.NAME,
  v.official_name,
  v.address_1,
  v.address_2,
  v.address_3,
  v.address_4,
  v.address_5,
  v.address_6,
  v.address_7,
  v.address_8,
  v.phone,
  v.fax,
  v.object_id vendor_id,
  dv.vat_reg_no,
  v.chamber_commerce,
  v.reporter_code
FROM rv_vendor                 v,
     rv_cont_document_vendor   dv,
     rv_cont_document          d
WHERE dv.document_key = d.document_key
AND   dv.vendor_id = v.object_id
AND   TRUNC(v.production_day, 'DD') = TRUNC(d.daytime, 'DD')