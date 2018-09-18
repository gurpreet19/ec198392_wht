CREATE OR REPLACE FORCE EDITIONABLE VIEW "RV_VALUE_PART_RECEIVER" ("DOCUMENT_KEY", "VENDOR_ID", "LABEL", "RECEIVER", "GIVER", "RECEIVER_ID", "VALUE_PART", "AMOUNT_NOT_INVOICED", "AMOUNT_INVOICED") AS 
  SELECT cdc.document_key,
       cdc.company_id vendor_id,
       'Receiver of value excl VAT from ' label,
       ec_company_version.official_name(cdc.exvat_receiver_id,
                                        cd.daytime,
                                        '<=') receiver,
       ec_company_version.official_name(company_id, cd.daytime, '<=') giver,
       cdc.exvat_receiver_id receiver_id,
       'EXVAT' value_part,
       clic.booking_value amount_not_invoiced,
       clic.booking_vat_value amount_invoiced
  from cont_document_company cdc,
       cont_document         cd,
       cont_li_dist_company  clic
 where cdc.document_key = cd.document_key
   and cdc.company_role = 'VENDOR'
   and cdc.exvat_receiver_id <> cdc.company_id
   and cdc.vat_receiver_id = cdc.company_id
   and clic.document_key = cd.document_key
   and clic.vendor_id = cdc.company_id
UNION ALL
SELECT cdc.document_key,
       cdc.company_id vendor_id,
       'Receiver of VAT from ' label,
       ec_company_version.official_name(cdc.vat_receiver_id,
                                        cd.daytime,
                                        '<=') receiver,
       ec_company_version.official_name(company_id, cd.daytime, '<=') giver,
       cdc.vat_receiver_id receiver_id,
       'VAT' value_part,
       clic.booking_vat_value amount_not_invoiced,
       clic.booking_value amount_invoiced
  from cont_document_company cdc,
       cont_document         cd,
       cont_li_dist_company  clic
 where cdc.document_key = cd.document_key
   and cdc.company_role = 'VENDOR'
   and cdc.vat_receiver_id <> cdc.company_id
   and cdc.exvat_receiver_id = cdc.company_id
   and clic.document_key = cd.document_key
   and clic.vendor_id = cdc.company_id
UNION ALL
SELECT cdc.document_key,
       cdc.company_id vendor_id,
       'Receiver of both VAT and EXVAT from ' label,
       ec_company_version.official_name(cdc.exvat_receiver_id,
                                        cd.daytime,
                                        '<=') receiver,
       ec_company_version.official_name(company_id, cd.daytime, '<=') giver,
       cdc.exvat_receiver_id receiver_id,
       'EXVAT' value_part,
       clic.booking_value + clic.booking_vat_value amount_not_invoiced,
       0 amount_invoiced
  from cont_document_company cdc,
       cont_document         cd,
       cont_li_dist_company  clic
 where cdc.document_key = cd.document_key
   and cdc.company_role = 'VENDOR'
   and cdc.exvat_receiver_id <> cdc.company_id
   and cdc.vat_receiver_id <> cdc.company_id
   and clic.document_key = cd.document_key
   and clic.vendor_id = cdc.company_id