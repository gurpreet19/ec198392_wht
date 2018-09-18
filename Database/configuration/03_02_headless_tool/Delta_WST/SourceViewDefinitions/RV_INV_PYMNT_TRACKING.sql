CREATE OR REPLACE FORCE EDITIONABLE VIEW "RV_INV_PYMNT_TRACKING" ("DOCUMENT_KEY", "DESCRIPTION", "AMOUNT", "ITEM", "DAYTIME", "RECEIVER_ID", "DEBIT_CREDIT_IND") AS 
  select c.document_key,
       nvl(c.PAYMENT_DESCRIPTION, '') description,
       decode(c.debit_credit_ind, 'C',-1,1) * sum(c.AMOUNT_INC_VAT) amount,
       c.item,
       c.daytime,
       c.receiver_id,
       c.debit_credit_ind
  from rv_cont_postings_aggregated c
 where c.payment = 'Y'
   and nvl(ec_cont_document.doc_booking_total(c.document_key), 0) >= 0
   and c.financial_code in ('SALE', 'TA_INCOME','JOU_ENT')
 GROUP BY document_key,PAYMENT_DESCRIPTION,item,receiver_id,debit_credit_ind,daytime
union
-- PURCHASE
select c.document_key,
       nvl(c.PAYMENT_DESCRIPTION, '') description,
       decode(c.debit_credit_ind, 'D',-1,1) * sum(c.AMOUNT_INC_VAT) amount,
       c.item,
       c.daytime,
       c.receiver_id,
       c.debit_credit_ind
  from rv_cont_postings_aggregated c
 where c.payment = 'Y'
   and nvl(ec_cont_document.doc_booking_total(c.document_key), 0) >= 0
   and c.financial_code in ('PURCHASE', 'TA_COST')
GROUP BY document_key,PAYMENT_DESCRIPTION,item,receiver_id,debit_credit_ind,daytime
union
-- CREDIT NOTE
select c.document_key,
       nvl(c.PAYMENT_DESCRIPTION, '') description,
       decode(c.debit_credit_ind, 'D',-1,1) * sum(c.AMOUNT_INC_VAT) amount,
       c.item,
       c.daytime,
       c.receiver_id,
       c.debit_credit_ind
  from rv_cont_postings_aggregated c
 where c.payment = 'Y'
   and nvl(ec_cont_document.doc_booking_total(c.document_key), 0) < 0
   and c.financial_code in ('SALE', 'TA_INCOME','JOU_ENT')
GROUP BY document_key,PAYMENT_DESCRIPTION,item,receiver_id,debit_credit_ind,daytime
union
-- NEGATIVE PURCHASE
select c.document_key,
       nvl(c.PAYMENT_DESCRIPTION, '') description,
       decode(c.debit_credit_ind, 'C',-1,1) * sum(c.AMOUNT_INC_VAT) amount,
       c.item,
       c.daytime,
       c.receiver_id,
       c.debit_credit_ind
  from rv_cont_postings_aggregated c
 where c.payment = 'Y'
   and nvl(ec_cont_document.doc_booking_total(c.document_key), 0) < 0
   and c.financial_code in ('PURCHASE', 'TA_COST')
GROUP BY document_key,PAYMENT_DESCRIPTION,item,receiver_id,debit_credit_ind,daytime
 order by daytime