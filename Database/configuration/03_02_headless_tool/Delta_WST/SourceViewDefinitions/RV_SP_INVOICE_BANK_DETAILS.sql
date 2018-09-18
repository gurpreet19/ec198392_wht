CREATE OR REPLACE FORCE EDITIONABLE VIEW "RV_SP_INVOICE_BANK_DETAILS" ("OBJECT_ID", "DOCUMENT_KEY", "COMPANY_ID", "CUSTOMER_CODE", "CUSTOMER_NAME", "BANK_DETAILS", "BANK_INFO", "BANK_ACCOUNT_INFO", "VAT_REG_NO", "DUE_DATE", "AMOUNT", "BOOKING_CURRENCY_CODE") AS 
  (
SELECT   v.object_id                                                                                      OBJECT_ID
         ,v.document_key                                                                                  DOCUMENT_KEY
         ,v.company_id                                                                                    COMPANY_ID
         ,RTRIM(RPAD(ec_company.object_code(v.company_id),250))                                           CUSTOMER_CODE
         ,RTRIM(RPAD(ec_company_version.name(v.company_id,ec_cont_document.daytime(v.document_key)),250)) CUSTOMER_NAME
         ,RTRIM(RPAD(v.bank_info || ' ' || v.bank_account_info,250))                                      BANK_DETAILS
         ,v.bank_info                                                                                     BANK_INFO
         ,v.bank_account_info                                                                             BANK_ACCOUNT_INFO
         ,v.vat_reg_no                                                                                    VAT_REG_NO
         ,v.due_date                                                                                      DUE_DATE
         ,v.amount                                                                                        AMOUNT
         ,ec_cont_document.booking_currency_code(v.document_key)                                          BOOKING_CURRENCY_CODE
FROM     cont_document_company v, company c
WHERE    v.company_id = c.object_id
AND      c.class_name = 'CUSTOMER'
)