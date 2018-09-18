CREATE OR REPLACE FORCE EDITIONABLE VIEW "RV_SP_INVOICE_ADDRESSES" ("OBJECT_ID", "DOCUMENT_KEY", "CUSTOMER_NAME", "CUSTOMER_ADDRESS_1", "CUSTOMER_ADDRESS_2", "CUSTOMER_ADDRESS_3", "CUSTOMER_ADDRESS_4", "CUSTOMER_ADDRESS_5", "CUSTOMER_ADDRESS_6", "CUSTOMER_ADDRESS_7", "CUSTOMER_ADDRESS_8", "VENDOR_NAME", "VENDOR_ADDRESS_1", "VENDOR_ADDRESS_2", "VENDOR_ADDRESS_3", "VENDOR_ADDRESS_4", "VENDOR_ADDRESS_5", "VENDOR_ADDRESS_6", "VENDOR_ADDRESS_7", "VENDOR_ADDRESS_8") AS 
  (
SELECT   cdc.object_id                                                                                          OBJECT_ID
         ,cdc.document_key                                                                                      DOCUMENT_KEY
         ,ec_company_version.name(cdc.company_id,cd.daytime,'<=')                                               CUSTOMER_NAME
         ,ec_company_version.address_1(cdc.company_id,cd.daytime,'<=')                                          CUSTOMER_ADDRESS_1
         ,ec_company_version.address_2(cdc.company_id,cd.daytime,'<=')                                          CUSTOMER_ADDRESS_2
         ,ec_company_version.address_3(cdc.company_id,cd.daytime,'<=')                                          CUSTOMER_ADDRESS_3
         ,ec_company_version.address_4(cdc.company_id,cd.daytime,'<=')                                          CUSTOMER_ADDRESS_4
         ,ec_company_version.address_5(cdc.company_id,cd.daytime,'<=')                                          CUSTOMER_ADDRESS_5
         ,ec_company_version.address_6(cdc.company_id,cd.daytime,'<=')                                          CUSTOMER_ADDRESS_6
         ,ec_company_version.address_7(cdc.company_id,cd.daytime,'<=')                                          CUSTOMER_ADDRESS_7
         ,ec_company_version.address_8(cdc.company_id,cd.daytime,'<=')                                          CUSTOMER_ADDRESS_8
         ,ec_company_version.name(cdv.company_id,cd.daytime,'<=')                                               VENDOR_NAME
         ,ec_company_version.address_1(cdv.company_id,cd.daytime,'<=')                                          VENDOR_ADDRESS_1
         ,ec_company_version.address_2(cdv.company_id,cd.daytime,'<=')                                          VENDOR_ADDRESS_2
         ,ec_company_version.address_3(cdv.company_id,cd.daytime,'<=')                                          VENDOR_ADDRESS_3
         ,ec_company_version.address_4(cdv.company_id,cd.daytime,'<=')                                          VENDOR_ADDRESS_4
         ,ec_company_version.address_5(cdv.company_id,cd.daytime,'<=')                                          VENDOR_ADDRESS_5
         ,ec_company_version.address_6(cdv.company_id,cd.daytime,'<=')                                          VENDOR_ADDRESS_6
         ,ec_company_version.address_7(cdv.company_id,cd.daytime,'<=')                                          VENDOR_ADDRESS_7
         ,ec_company_version.address_8(cdv.company_id,cd.daytime,'<=')                                          VENDOR_ADDRESS_8
FROM     cont_document_company cdc,
         cont_document_company cdv,
         cont_document cd,
         company c,
         company cv
WHERE    cd.object_id = cdc.object_id
AND      cd.object_id = cdv.object_id
AND      cd.document_key = cdc.document_key
AND      cd.document_key = cdv.document_key
AND      cdc.company_id = c.object_id
AND      cdv.company_id = cv.object_id
AND      c.class_name = 'CUSTOMER'
AND      cv.class_name = 'VENDOR'
)