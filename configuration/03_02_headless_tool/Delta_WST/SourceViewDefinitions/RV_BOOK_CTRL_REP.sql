CREATE OR REPLACE FORCE EDITIONABLE VIEW "RV_BOOK_CTRL_REP" ("DOCUMENT_KEY", "PK", "DR_BOOKING_VALUE", "CR_BOOKING_VALUE", "DR_LOCAL", "CR_LOCAL", "DR_GROUP", "CR_GROUP", "ACCT", "COSTOBJECT", "PRODUCT", "ACCT_DESC", "ACC_SORT", "PAY_DATE", "VAT_CODE", "VAT_AMOUNT", "VAT_AMOUNT_LOC") AS 
  select
    cp.document_key,
    cp.fin_posting_key pk,
    sum(decode(cp.debit_credit_ind,'D',cp.amount,null)) dr_booking_value,
    sum(decode(cp.debit_credit_ind,'C',cp.amount,null)) cr_booking_value,
    sum(decode(cp.debit_credit_ind,'D',cp.local_amount,null)) dr_local,
    sum(decode(cp.debit_credit_ind,'C',cp.local_amount,null)) cr_local,
    sum(decode(cp.debit_credit_ind,'D',cp.group_amount,null)) dr_group,
    sum(decode(cp.debit_credit_ind,'C',cp.group_amount,null)) cr_group,
    cp.fin_gl_account acct,
    cp.fin_cost_object costobject,
    null product,
    ec_fin_account_version.name(cp.fin_account_id,cp.daytime,'<=') acct_desc,
    ec_prosty_codes.sort_order(ec_fin_account_version.fin_account_cat_code(cp.fin_account_id,cp.daytime,'<='), 'FIN_ACCOUNT_CATEGORY_CODE') acc_sort,
    cp.daytime pay_date,
    ec_vat_code_version.fin_vat_code(ecdp_objects.GetObjIDFromCode('VAT_CODE',cp.vat_code),daytime,'<=') vat_code,
    decode(payment, 'Y',
        case when ec_cont_document.financial_code(cp.document_key) IN ('SALE','TA_INCOME','JOU_ENT') and cp.debit_credit_ind = 'D' then
                sum(cp.amount_inc_vat) - sum(cp.amount_ex_vat)
             when ec_cont_document.financial_code(cp.document_key) IN ('SALE','TA_INCOME','JOU_ENT') and cp.debit_credit_ind = 'C' then
                -sum(cp.amount_inc_vat) + sum(cp.amount_ex_vat)
             when ec_cont_document.financial_code(cp.document_key) IN ('PURCHASE', 'TA_COST') and cp.debit_credit_ind = 'C' then
                sum(cp.amount_inc_vat) - sum(cp.amount_ex_vat)
             when ec_cont_document.financial_code(cp.document_key) IN ('PURCHASE', 'TA_COST') and cp.debit_credit_ind = 'D' then
                -sum(cp.amount_inc_vat) + sum(cp.amount_ex_vat)
        end
    ,NULL) vat_amount,
    decode(payment, 'Y',
        case when ec_cont_document.financial_code(cp.document_key) IN ('SALE','TA_INCOME','JOU_ENT') and cp.debit_credit_ind = 'D' then
                sum(cp.local_amount_inc_vat) - sum(cp.local_amount_ex_vat)
             when ec_cont_document.financial_code(cp.document_key) IN ('SALE','TA_INCOME','JOU_ENT') and cp.debit_credit_ind = 'C' then
                -sum(cp.local_amount_inc_vat) + sum(cp.local_amount_ex_vat)
             when ec_cont_document.financial_code(cp.document_key) IN ('PURCHASE', 'TA_COST') and cp.debit_credit_ind = 'C' then
                sum(cp.local_amount_inc_vat) - sum(cp.local_amount_ex_vat)
             when ec_cont_document.financial_code(cp.document_key) IN ('PURCHASE', 'TA_COST') and cp.debit_credit_ind = 'D' then
                -sum(cp.local_amount_inc_vat) + sum(cp.local_amount_ex_vat)
        end
    ,NULL) vat_amount_loc
from
    cont_postings_aggregated cp
where
    cp.post_ind = 'Y'
group by cp.document_key, cp.fin_posting_key, cp.fin_gl_account, cp.fin_cost_object, null, ec_fin_account_version.name(cp.fin_account_id,cp.daytime,'<='),
         ec_prosty_codes.sort_order(ec_fin_account_version.fin_account_cat_code(cp.fin_account_id,cp.daytime,'<='), 'FIN_ACCOUNT_CATEGORY_CODE'), cp.daytime,cp.vat_code,cp.payment, cp.debit_credit_ind,null,null,cp.text_1
order by daytime asc ,acc_sort asc, acct asc, pk asc, costobject asc