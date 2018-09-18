CREATE OR REPLACE FORCE EDITIONABLE VIEW "RV_BANK_ACCOUNT_INFO" ("RECEIVER_ID", "TYPE", "BANK_NAME", "BANK_ADDRESS_CONCAT", "BANK_ADDRESS_1", "BANK_ADDRESS_2", "BANK_ADDRESS_3", "BANK_ADDRESS_4", "BANK_ADDRESS_5", "BANK_ADDRESS_6", "BANK_ADDRESS_7", "BANK_ADDRESS_8", "BANK_SWIFT_CODE", "BANK_ACC_NAME", "ACCOUNT_NUMBER", "ACCOUNT_IBAN", "BANK_ACC_HOLDER", "DOCUMENT_KEY") AS 
  (
SELECT DISTINCT lic.vendor_id receiver_id, 'VENDOR' TYPE,
       b.name bank_name,
      (b.address_1 || ' ' || b.address_2 || ' ' || b.address_3 || ' ' || b.address_4) bank_address_concat,
       b.address_1 bank_address_1,
       b.address_2 bank_address_2,
       b.address_3 bank_address_3,
       b.address_4 bank_address_4,
       b.address_5 bank_address_5,
       b.address_6 bank_address_6,
       b.address_7 bank_address_7,
       b.address_8 bank_address_8,
       b.bank_swift_code bank_swift_code,
       ba.name bank_acc_name,
       ba.account_number account_number,
       ba.account_iban account_iban,
       ec_company_version.name(ba.vendor_id, ba.daytime, '<=') bank_acc_holder,
       d.document_key document_key
  FROM rv_contract               c,
       rv_cont_document          d,
       rv_cont_document_customer dc,
       rv_cont_document_vendor   dv,
       rv_cont_li_dist_company   lic,
       rv_vendor                 v,
       rv_customer               cr,
       rv_bank                   b,
       rv_bank_account           ba
 WHERE c.object_id = d.object_id
   AND dv.document_key = d.document_key
   AND dc.document_key = d.document_key
   AND cr.object_id = dc.customer_id
   AND v.object_id = dv.vendor_id
   AND lic.vendor_id = dv.vendor_id
   AND lic.customer_id = dc.customer_id
   AND lic.document_key = d.document_key
   AND b.object_id = ba.bank_id
   AND ba.object_id =dv.bank_account_id
   AND TRUNC(b.production_day, 'DD') = TRUNC(d.daytime, 'DD')
   AND TRUNC(ba.production_day, 'DD') = TRUNC(d.daytime, 'DD')
   AND TRUNC(c.production_day, 'DD') = TRUNC(d.daytime, 'DD')
   AND TRUNC(cr.production_day, 'DD') = TRUNC(d.daytime, 'DD')
   AND TRUNC(v.production_day, 'DD') = TRUNC(d.daytime, 'DD')
UNION ALL
SELECT DISTINCT lic.customer_id receiver_id, 'CUSTOMER' TYPE,
       b.name bank_name,
      (b.address_1 || ' ' || b.address_2 || ' ' || b.address_3 || ' ' || b.address_4) bank_address_concat,
       b.address_1 bank_address_1,
       b.address_2 bank_address_2,
       b.address_3 bank_address_3,
       b.address_4 bank_address_4,
       b.address_5 bank_address_5,
       b.address_6 bank_address_6,
       b.address_7 bank_address_7,
       b.address_8 bank_address_8,
       b.bank_swift_code bank_swift_code,
       ba.name bank_acc_name,
       ba.account_number account_number,
       ba.account_iban account_iban,
       ec_company_version.name(ba.vendor_id, ba.daytime, '<=') bank_acc_holder,
       d.document_key document_key
  FROM rv_contract               c,
       rv_cont_document          d,
       rv_cont_document_customer dc,
       rv_cont_document_vendor   dv,
       rv_cont_li_dist_company   lic,
       rv_vendor                 v,
       rv_customer               cr,
       rv_bank                   b,
       rv_bank_account           ba
 WHERE c.object_id = d.object_id
   AND dv.document_key = d.document_key
   AND dc.document_key = d.document_key
   AND cr.object_id = dc.customer_id
   AND v.object_id = dv.vendor_id
   AND lic.vendor_id = dv.vendor_id
   AND lic.customer_id = dc.customer_id
   AND lic.document_key = d.document_key
   AND b.object_id = ba.bank_id
   AND ba.object_id = dc.bank_account_id
   AND TRUNC(b.production_day, 'DD') = TRUNC(d.daytime, 'DD')
   AND TRUNC(ba.production_day, 'DD') = TRUNC(d.daytime, 'DD')
   AND TRUNC(c.production_day, 'DD') = TRUNC(d.daytime, 'DD')
   AND TRUNC(cr.production_day, 'DD') = TRUNC(d.daytime, 'DD')
   AND TRUNC(v.production_day, 'DD') = TRUNC(d.daytime, 'DD')
)