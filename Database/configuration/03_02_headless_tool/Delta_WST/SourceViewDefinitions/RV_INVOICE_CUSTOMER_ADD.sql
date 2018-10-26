CREATE OR REPLACE FORCE EDITIONABLE VIEW "RV_INVOICE_CUSTOMER_ADD" ("DOCUMENT_KEY", "OUR_CONTACT", "PRODUCTION_DAY", "NAME", "OFFICIAL_NAME", "ADDRESS_1", "ADDRESS_2", "ADDRESS_3", "ADDRESS_4", "ADDRESS_5", "ADDRESS_6", "ADDRESS_7", "ADDRESS_8", "PHONE", "FAX", "CUSTOMER_ID", "VAT_REG_NO", "CHAMBER_COMMERCE", "REPORTER_CODE") AS 
  SELECT
  d.document_key,
  d.our_contact,
  c.production_day,
  c.name,
  c.official_name,
  c.address_1,
  c.address_2,
  c.address_3,
  c.address_4,
  c.address_5,
  c.address_6,
  c.address_7,
  c.address_8,
  c.phone,
  c.fax,
  c.object_id CUSTOMER_id,
  dc.VAT_REG_NO,
  NULL chamber_commerce,
  NULL reporter_code
FROM
     rv_customer               c,
     rv_cont_document_customer dc,
     rv_cont_document          d
WHERE dc.document_key = d.document_key
AND   dc.customer_id = c.object_id
AND   TRUNC(c.production_day, 'DD') = TRUNC(d.daytime, 'DD')