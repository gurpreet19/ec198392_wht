CREATE OR REPLACE FORCE EDITIONABLE VIEW "RV_INVOICE_HEADER" ("LABEL", "REP_HEADER", "REP_STATUS", "DOCUMENT_KEY") AS 
  SELECT decode(NVL(d.document_level_code, 'OPEN'),
              'OPEN',
              'DRAFT',
              'VALID1',
              'DRAFT',
              null) label,
ec_doc_template_version.label(decode(d.CUR_DOC_TEMPLATE_NAME, d.INV_DOC_TEMPLATE_NAME, d.INV_DOC_TEMPLATE_ID, d.DOC_TEMPLATE_NAME, d.DOC_TEMPLATE_ID, null),d.daytime,'<=') rep_header,
DECODE(NVL(d.status_code, 'FINAL'),
              'ACCRUAL',
              'ACCRUAL - FOR INTERNAL USE ONLY',
              null) rep_status ,
              d.document_key
  from rv_cont_document d