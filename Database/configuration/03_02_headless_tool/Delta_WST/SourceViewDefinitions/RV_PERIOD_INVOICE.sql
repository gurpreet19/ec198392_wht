CREATE OR REPLACE FORCE EDITIONABLE VIEW "RV_PERIOD_INVOICE" ("MVD", "COMPANY_ID", "PRODUCTION_DAY", "CONTRACT_ID", "CONTRACT_NAME", "CONTRACT_CODE", "TRANS_TYPE", "VENDOR_ID", "VENDOR_COMPANY_ID", "VENDOR_CODE", "CUSTOMER_ID", "AMOUNT_IN_WORDS_IND", "AMOUNT_IN_WORDS", "DOCUMENT_KEY", "OBJECT_ID", "DOCUMENT_NUMBER", "DAYTIME", "DOCUMENT_DATE", "PAY_DATE", "VAT_REG_NO", "CUSTOMER_NAME", "DOC_BOOKING_TOTAL", "OWNER_COMPANY_CODE", "FINANCIAL_CODE", "PAYMENT_TERM", "PAYMENT_TERM_DESCRIPTION", "PRECEDING_DOCUMENT_NUMBER", "PRECEDING_DOCUMENT_DAYTIME", "PRECEDING_DOCUMENT_DATE", "TRANSACTION_KEY", "SUPPLY_FROM_DATE", "SUPPLY_TO_DATE", "PRODUCT_CODE", "BOOKING_CURRENCY_CODE", "VAT_LEGAL_TEXT", "EX_PRICING_BOOKING", "UOM1_CODE", "UOM2_CODE", "UOM3_CODE", "UOM4_CODE", "TEMPLATE_CODE", "DESCRIPTION") AS 
  (
    SELECT ecdp_document.ismultivendordocument(d.document_key) mvd,
        MAX(oa.company_id) company_id,
        MAX(s.daytime) production_day,
        MAX(o.object_id) AS CONTRACT_ID,
        MAX(oa.name) AS contract_name,
        MAX(o.object_code) AS contract_code,
        oa.contract_group_code AS Trans_Type,
        lic.vendor_id,
        ec_company.company_id(lic.vendor_id) AS vendor_company_id,
        MAX(v.code) AS vendor_code,
        lic.customer_id,
        MAX(cd.amount_in_words_ind) AS amount_in_words_ind,
        MAX(d.amount_in_words) AS amount_in_words,
        d.document_key AS document_key,
        MAX(d.object_id) AS object_id,
        NVL(MAX(d.document_number), 'NOT ASSIGNED') AS document_number,
        MAX(d.daytime) AS daytime,
        MAX(d.document_date) AS document_date,
        NVL(to_char(MAX(d.pay_date), 'dd-Mon-yyyy'),DECODE(MAX(cd.payment_scheme_id),null,null,'Payment details below')) AS pay_date,
        DECODE(MAX(d.financial_code),'SALE',MAX(dc.vat_reg_no),'PURCHASE',MAX(dv.vat_reg_no),'TA_INCOME',MAX(dc.vat_reg_no),'TA_COST',MAX(dv.vat_reg_no),'JOU_ENT',MAX(dc.vat_reg_no)) AS vat_reg_no,
        max(cr.fin_code) customer_name,
        MAX(d.doc_booking_total) AS doc_booking_total,
        MAX(d.owner_company_code) AS owner_company_code,
        MAX(d.financial_code) AS financial_code,
        MAX(ec_payment_term_version.name(dv.payment_term_id, d.daytime, '<=')) AS payment_term,
        MAX(ec_payment_term.description(dv.payment_term_id)) AS payment_term_description,
        ec_cont_document.document_number(MAX(d.preceding_document_key)) AS preceding_document_number,
        ec_cont_document.daytime(MAX(d.preceding_document_key)) AS preceding_document_daytime,
        ec_cont_document.document_date(MAX(d.preceding_document_key)) AS preceding_document_date,
        MAX(t.transaction_key) AS transaction_key,
        t.supply_from_date AS supply_from_date,
        t.supply_to_date AS supply_to_date,
        MAX(t.product_code) AS product_code,
        MAX(d.BOOKING_CURRENCY_CODE) AS booking_currency_code,
        MAX(t.vat_legal_text) AS vat_legal_text,
        MAX(t.ex_pricing_booking) AS ex_pricing_booking,
        tq.uom1_code AS uom1_code,
        tq.uom2_code AS uom2_code,
        tq.uom3_code AS uom3_code,
        tq.uom4_code AS uom4_code,
        o.template_code AS template_code,
        MAX(o.description) AS description
    FROM CONTRACT_VERSION oa,
        CONTRACT o,
        system_days s,
        ov_contract_doc cd,
        dv_cont_document d,
        dv_cont_transaction t,
        dv_cont_transaction_qty tq,
        dv_cont_document_customer dc,
        dv_cont_document_vendor dv,
        dv_cont_li_dist_company lic,
        ov_vendor v,
        ov_customer cr
    WHERE oa.object_id = o.object_id
        AND o.object_id = d.object_id
        AND d.contract_doc_id = cd.object_id
        AND t.document_key = d.document_key
        AND t.transaction_key = tq.transaction_key (+)
        AND dv.document_key = d.document_key
        AND dc.document_key = d.document_key
        AND cr.object_id = dc.customer_id
        AND v.object_id = dv.vendor_id
        AND lic.vendor_id = dv.vendor_id
        AND lic.transaction_key = t.transaction_key
        AND cd.DOC_SCOPE = 'PERIOD_BASED'
        AND s.daytime >= oa.daytime
        AND trunc(s.daytime, 'DD') = trunc(d.daytime, 'DD')
        AND (s.daytime < oa.end_date OR oa.end_date IS NULL)
        AND (s.daytime < o.end_date OR o.end_date IS NULL)
    GROUP BY d.document_key,
        lic.vendor_id,
        lic.customer_id,
        t.supply_from_date,
        t.supply_to_date,
        tq.uom1_code,
        tq.uom2_code,
        tq.uom3_code,
        tq.uom4_code,o.template_code,oa.contract_group_code)
    ORDER BY MAX(t.supply_from_date),
          MAX(t.supply_to_date),
          MAX(t.product_code),
          MAX(lic.line_item_based_type) desc