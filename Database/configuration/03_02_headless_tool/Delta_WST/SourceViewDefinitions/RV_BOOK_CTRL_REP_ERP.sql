CREATE OR REPLACE FORCE EDITIONABLE VIEW "RV_BOOK_CTRL_REP_ERP" ("DOCUMENT_KEY", "PK", "DR_BOOKING_VALUE", "CR_BOOKING_VALUE", "DR_LOCAL", "CR_LOCAL", "DR_GROUP", "CR_GROUP", "ACCT", "COSTOBJECT", "PRODUCT", "ACCT_DESC", "ACC_SORT", "PAY_DATE", "VAT_CODE", "VAT_AMOUNT", "VAT_AMOUNT_LOC") AS 
  SELECT
       cp.document_key                                                  document_key,
       cp.fin_posting_key                                               pk,
       DECODE(cp.fin_debit_credit_code,'DEBIT',cp.booking_amount,NULL)  dr_booking_value,
       DECODE(cp.fin_debit_credit_code,'CREDIT',cp.booking_amount,NULL) cr_booking_value,
       DECODE(cp.fin_debit_credit_code,'DEBIT',cp.local_amount,NULL)    dr_local,
       DECODE(cp.fin_debit_credit_code,'CREDIT',cp.local_amount,NULL)   cr_local,
       NULL                                                             dr_group,
       NULL                                                             cr_group,
       cp.fin_gl_account_code                                           acct,
       cp.fin_cost_object_code                                          costobject,
       NULL                                                             product,
       cp.fin_account_descr                                             acct_desc,
       ec_prosty_codes.sort_order(
              ec_fin_account_version.fin_account_cat_code(
                cp.fin_gl_account_id,cp.daytime,'<='),
              'FIN_ACCOUNT_CATEGORY_CODE')                              acc_sort,
       NVL(ecdp_contract_setup.GetPayDate(
              cp.object_id,
              cp.document_key,
              ec_cont_document.payment_term_base_code(cp.document_key),
              cp.fin_payment_term_id,
              cp.daytime), cp.daytime)                                  pay_date,
       cp.fin_vat_code                                                  vat_code,
       cp.vat_amount                                                    vat_amount,
       cp.vat_local_amount                                              vat_amount_loc
 FROM cont_erp_postings cp
ORDER BY daytime ASC,
         acc_sort ASC,
         acct ASC,
         pk ASC,
         costobject ASC