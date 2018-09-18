CREATE OR REPLACE FORCE EDITIONABLE VIEW "RV_CARGO_INVOICE" ("CONTRACT_NAME", "CONTRACT_CODE", "COMPANY_ID", "VENDOR_ID", "VENDOR_CODE", "VENDOR_COMPANY_ID", "AMOUNT_IN_WORDS_IND", "AMOUNT_IN_WORDS", "DOCUMENT_KEY", "STATUS_CODE", "OBJECT_ID", "DOCUMENT_NUMBER", "DAYTIME", "DOCUMENT_DATE", "PAY_DATE", "USE_CURRENCY_100_IND", "VAT_REG_NO", "CUSTOMER_NAME", "CUSTOMER_ID", "DOC_BOOKING_TOTAL", "DOC_BOOKING_VALUE", "DOC_BOOKING_VAT", "OWNER_COMPANY_CODE", "FINANCIAL_CODE", "PAYMENT_TERM", "PAYMENT_TERM_DESCRIPTION", "PRECEDING_DOCUMENT_NUMBER", "PRECEDING_DOCUMENT_DAYTIME", "PRECEDING_DOCUMENT_DATE", "TRANSACTION_KEY", "BL_DATE", "PRICE_CONCEPT_CODE", "VAT_CODE", "VAT_DESCRIPTION", "LOADING_DATE_COMMENCED", "LOADING_DATE_COMPLETED", "BOOKING_CURRENCY_CODE", "CURR_UOM", "CURR_UOM_100", "TRANS_BOOKING_VAT", "DISCHARGE_PORT_NAME", "LOADING_PORT_NAME", "TRANS_BOOKING_VALUE", "TRANS_BOOKING_TOTAL", "VAT_LEGAL_TEXT", "EX_PRICING_BOOKING", "CARRIER_NAME", "CARGO_NAME", "CONT_LI_NAME", "LI_BASED_TYPE", "QTY1", "BOOKING_VALUE", "BOOKING_VAT_VALUE", "PRICING_VAT_VALUE", "UOM1_CODE", "UOM2_CODE", "UOM3_CODE", "UOM4_CODE") AS 
  (
select max(c.name) contract_name,
       max(c.code) contract_code,
       max(d.company_id) company_id,
       lic.vendor_id,
       max(v.code) vendor_code,
       ec_company.company_id(lic.vendor_id) vendor_company_id,
       max(cd.amount_in_words_ind) amount_in_words_ind,
       max(d.amount_in_words) amount_in_words,
       d.document_key document_key,
       max(d.status_code) status_code,
       max(d.object_id) object_id,
       max(nvl(d.document_number, 'NOT ASSIGNED')) document_number,
       max(d.daytime) daytime,
       max(d.document_date) document_date,
       nvl(max(to_char(d.pay_date, 'dd-Mon-yyyy')),
           decode(max(cd.payment_scheme_id),
                  null,
                  null,
                  'Payment details below')) pay_date,
       max(d.use_currency_100_ind) use_currency_100_ind,
       decode(max(d.financial_code),
              'SALE',
              max(dc.vat_reg_no),
              'PURCHASE',
              max(dv.vat_reg_no),
              'TA_INCOME',
              max(dc.vat_reg_no),
              'TA_COST',
              max(dv.vat_reg_no),
              'JOU_ENT',
              max(dc.vat_reg_no)) vat_reg_no,
              max(cr.fin_code) customer_name,
       max(dc.customer_id) customer_id,
       max(d.doc_booking_total) doc_booking_total,
       max(d.doc_booking_value) doc_booking_value,
       max(d.doc_booking_vat) doc_booking_vat,
       max(d.owner_company_code) owner_company_code,
       max(d.financial_code) financial_code,
       max((ec_payment_term_version.name(dv.payment_term_id, d.daytime, '<='))) payment_term,
       max((ec_payment_term.description(dv.payment_term_id))) payment_term_description,
       ec_cont_document.document_number(max(d.preceding_document_key)) preceding_document_number,
       ec_cont_document.daytime(max(d.preceding_document_key)) preceding_document_daytime,
       ec_cont_document.document_date(max(d.preceding_document_key)) preceding_document_date,
       max(t.transaction_key) transaction_key,
       max(t.bl_date) bl_date,
       max(t.price_concept_code) price_concept_code,
       ec_vat_code_version.fin_vat_code(ec_vat_code.object_id_by_uk(max(t.vat_code)),
                                        max(t.daytime),
                                        '<=') vat_code,
       max(t.vat_description) vat_description,
       max(t.loading_date_commenced) loading_date_commenced,
       max(t.loading_date_completed) loading_date_completed,
       max(t.booking_currency_code) booking_currency_code,
       max(t.booking_currency_code) || '/' || tq.uom1_code curr_uom,
       max(t.booking_currency_code) || ' ' ||
       ec_currency_version.unit100(max(t.booking_currency_id),
                                   max(t.daytime),
                                   '<=') || '/' || tq.uom1_code curr_uom_100,
       max(t.trans_booking_vat) trans_booking_vat,
       ec_port_version.name(t.discharge_port_id, max(d.daytime), '<=') discharge_port_name,
       ec_port_version.name(t.loading_port_id, max(d.daytime), '<=') loading_port_name,
       max((select sum(i.booking_value) + sum(i.booking_vat_value)
             from cont_line_item i, cont_transaction tr
            where i.document_key = d.document_key
              and i.transaction_key = tr.transaction_key
              and tr.supply_from_date = t.supply_from_date
              and tr.supply_to_date = t.supply_to_date)) trans_booking_value,
       max(t.trans_booking_total) trans_booking_total,
       max(t.vat_legal_text) vat_legal_text,
       max(t.ex_pricing_booking) ex_pricing_booking,
       max(ec_carrier_version.name(t.carrier_id, t.daytime, '<=')) carrier_name,
       t.cargo_name,
       max(lic.name) cont_li_name,
       max(lic.line_item_based_type) li_based_type,
       max(lic.qty1) qty1,
       max(lic.booking_value) booking_value,
       max(lic.booking_vat_value) booking_vat_value,
       max(lic.pricing_vat_value) pricing_vat_value,
       tq.uom1_code uom1_code,
       tq.uom2_code uom2_code,
       tq.uom3_code uom3_code,
       tq.uom4_code uom4_code
  from rv_contract               c,
       rv_contract_doc           cd,
       rv_cont_document          d,
       rv_cont_transaction       t,
       rv_cont_transaction_qty   tq,
       rv_cont_li_dist_company   lic,
       rv_cont_document_customer dc,
       rv_cont_document_vendor   dv,
       rv_contract_vend_parties  cvp,
       rv_vendor                 v,
       rv_customer               cr
 WHERE ecDp_Document.getDistinctTransType(d.document_key) = 'CARGO_BASED'
   and d.contract_doc_id = cd.object_id
   and d.document_key = t.document_key
   and d.document_key = dc.document_key
   and dc.document_key = dv.document_key
   and dc.customer_id = cr.object_id
   and lic.vendor_id = dv.vendor_id
   and dv.vendor_id = v.object_id
   and cvp.object_id = d.object_id
   and cvp.vendor_id = v.object_id
   and cvp.party_role = 'VENDOR'
   and t.transaction_key = tq.transaction_key (+)
   and t.transaction_key = lic.transaction_key
   and t.object_id = c.object_id
   and TRUNC(c.production_day, 'DD') = TRUNC(d.daytime, 'DD')
   and TRUNC(cd.production_day, 'DD') = TRUNC(d.daytime, 'DD')
   and TRUNC(cr.production_day, 'DD') = TRUNC(d.daytime, 'DD')
   and TRUNC(v.production_day, 'DD') = TRUNC(d.daytime, 'DD')
 group by d.document_key,
          lic.vendor_id,
          lic.customer_id,
          t.loading_port_id,
          t.discharge_port_id,
          t.cargo_name,
          t.carrier_id,
          t.bl_date,
          tq.uom1_code,
          tq.uom2_code,
          tq.uom3_code,
          tq.uom4_code
)