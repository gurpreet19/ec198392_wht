CREATE OR REPLACE FORCE EDITIONABLE VIEW "V_TRANSACTION_VALUE_OVERVIEW" ("ROW_TYPE", "NAME", "OBJECT_ID", "QTY1", "FREE_UNIT_QTY", "UOM1_CODE", "UNIT_PRICE", "UNIT_PRICE_UNIT", "PRICING_VALUE", "PRICING_CURR_CODE", "MEMO_VALUE", "MEMO_CURR_CODE", "BOOKING_VALUE", "BOOKING_CURR_CODE", "LOCAL_VALUE", "LOCAL_CURR_CODE", "LINE_ITEM_BASED_TYPE", "LINE_ITEM_TYPE", "LINE_ITEM_KEY", "INTEREST_FROM_DATE", "COMMENTS", "SORT_ORDER", "TRANSACTION_KEY", "DOCUMENT_KEY", "VAT_CODE", "VAT_NAME", "VAT_RATE", "VAT_DESCRIPTION", "VAT_LEGAL_TEXT", "RECORD_STATUS", "CREATED_BY", "CREATED_DATE", "LAST_UPDATED_BY", "LAST_UPDATED_DATE", "REV_NO", "REV_TEXT") AS 
  (
 SELECT 'LINE ITEMS' as row_type,
        NAME,
        OBJECT_ID,
        QTY1,
        FREE_UNIT_QTY,
        UOM1_CODE,
        UNIT_PRICE,
        UNIT_PRICE_UNIT,
        PRICING_VALUE,
        ec_cont_transaction.pricing_currency_code(transaction_key) PRICING_CURR_CODE,
        MEMO_VALUE,
        ec_cont_document.memo_currency_code(document_key) MEMO_CURR_CODE,
        BOOKING_VALUE,
        ec_cont_document.booking_currency_code(document_key) BOOKING_CURR_CODE,
        LOCAL_VALUE,
        ec_Currency.object_code(ec_Company_Version.local_currency_id(ec_contract_version.company_id(object_id,daytime,'<='),daytime,'<=')) local_curr_code,
        LINE_ITEM_BASED_TYPE,
        LINE_ITEM_TYPE,
        LINE_ITEM_KEY,
        interest_from_date,
        COMMENTS,
        SORT_ORDER,
        TRANSACTION_KEY,
        DOCUMENT_KEY,
        VAT_CODE,
        ec_vat_code_version.name(ec_vat_code.object_id_by_uk(vat_code),daytime,'<=') VAT_NAME,
        VAT_RATE,
        ec_vat_code_version.comments(ec_vat_code.object_id_by_uk(vat_code),daytime,'<=') VAT_DESCRIPTION,
        ec_vat_code_version.legal_text(ec_vat_code.object_id_by_uk(vat_code),daytime,'<=') VAT_LEGAL_TEXT,
        RECORD_STATUS,
        CREATED_BY,
        CREATED_DATE,
        LAST_UPDATED_BY,
        LAST_UPDATED_DATE,
        REV_NO,
        REV_TEXT
   FROM CONT_LINE_ITEM t
 UNION
 SELECT 'SPACE LINE' as row_type,
        NULL AS NAME,
        t2.object_id,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL interest_from_date,
        NULL comments,
        9999999910 SORT_ORDER,
        t2.TRANSACTION_KEY,
        t2.DOCUMENT_KEY,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL RECORD_STATUS,
        NULL CREATED_BY,
        NULL CREATED_DATE,
        NULL LAST_UPDATED_BY,
        NULL LAST_UPDATED_DATE,
        NULL REV_NO,
        NULL REV_TEXT
   FROM cont_line_item t2
 UNION
 SELECT 'SUBTOTALS' as row_type,
        ecdp_language.translateByPropLang('Subtotal Transaction Value') NAME,
        OBJECT_ID,
        NULL QTY1,
        NULL FREE_UNIT_QTY,
        NULL UOM1_CODE,
        NULL UNIT_PRICE,
        NULL UNIT_PRICE_UNIT,
        TRANS_PRICING_VALUE,
        ec_cont_transaction.pricing_currency_code(transaction_key) PRICING_CURR_CODE,
        TRANS_MEMO_VALUE,
        ec_cont_document.memo_currency_code(document_key) MEMO_CURR_CODE,
        TRANS_BOOKING_VALUE,
        ec_cont_document.booking_currency_code(document_key) BOOKING_CURR_CODE,
        TRANS_LOCAL_VALUE,
        ec_Currency.object_code(ec_Company_Version.local_currency_id(ec_contract_version.company_id(object_id,daytime,'<='),daytime,'<=')) local_curr_code,
        '' LINE_ITEM_BASED_TYPE,
        '' LINE_ITEM_TYPE,
        '' LINE_ITEM_KEY,
        NULL interest_from_date,
        NULL comments,
        9999999920 SORT_ORDER,
        TRANSACTION_KEY,
        DOCUMENT_KEY,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        RECORD_STATUS,
        CREATED_BY,
        CREATED_DATE,
        LAST_UPDATED_BY,
        LAST_UPDATED_DATE,
        REV_NO,
        REV_TEXT
   FROM CONT_TRANSACTION
 UNION
 SELECT 'VAT' as row_type,
        ecdp_language.translateByPropLang('VAT') || ': ' || decode(ec_cont_document.status_code(document_key),'ACCRUAL','(Accrual)') NAME,
        OBJECT_ID,
        NULL QTY1,
        NULL FREE_UNIT_QTY,
        NULL UOM1_CODE,
        NULL UNIT_PRICE,
        NULL UNIT_PRICE_UNIT,
        TRANS_PRICING_VAT,
        ec_cont_transaction.pricing_currency_code(transaction_key) PRICING_CURR_CODE,
        TRANS_MEMO_VAT,
        ec_cont_document.memo_currency_code(document_key) MEMO_CURR_CODE,
        TRANS_BOOKING_VAT,
        ec_cont_document.booking_currency_code(document_key) BOOKING_CURR_CODE,
        TRANS_LOCAL_VAT,
        ec_Currency.object_code(ec_Company_Version.local_currency_id(ec_contract_version.company_id(object_id,daytime,'<='),daytime,'<=')) local_curr_code,
        '' LINE_ITEM_BASED_TYPE,
        '' LINE_ITEM_TYPE,
        '' LINE_ITEM_KEY,
        null interest_from_date,
        null COMMENTS,
        9999999930 SORT_ORDER,
        TRANSACTION_KEY,
        DOCUMENT_KEY,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        RECORD_STATUS,
        CREATED_BY,
        CREATED_DATE,
        LAST_UPDATED_BY,
        LAST_UPDATED_DATE,
        REV_NO,
        REV_TEXT
   FROM CONT_TRANSACTION
 UNION
 SELECT 'TOTALS' as row_type,
        ecdp_language.translateByPropLang('Total Transaction Value') NAME,
        OBJECT_ID,
        NULL QTY1,
        NULL FREE_UNIT_QTY,
        NULL UOM1_CODE,
        NULL UNIT_PRICE,
        NULL UNIT_PRICE_UNIT,
        TRANS_PRICING_TOTAL,
        ec_cont_transaction.pricing_currency_code(transaction_key) PRICING_CURR_CODE,
        TRANS_MEMO_TOTAL,
        ec_cont_document.memo_currency_code(document_key) MEMO_CURR_CODE,
        TRANS_BOOKING_TOTAL,
        ec_cont_document.booking_currency_code(document_key) BOOKING_CURR_CODE,
        TRANS_LOCAL_TOTAL,
        ec_Currency.object_code(ec_Company_Version.local_currency_id(ec_contract_version.company_id(object_id,daytime,'<='),daytime,'<=')) local_curr_code,
        '' LINE_ITEM_BASED_TYPE,
        '' LINE_ITEM_TYPE,
        '' LINE_ITEM_KEY,
        null interest_from_date,
        null COMMENTS,
        9999999940 SORT_ORDER,
        TRANSACTION_KEY,
        DOCUMENT_KEY,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        RECORD_STATUS,
        CREATED_BY,
        CREATED_DATE,
        LAST_UPDATED_BY,
        LAST_UPDATED_DATE,
        REV_NO,
        REV_TEXT
   FROM CONT_TRANSACTION
) -- Order By: see query xml (com\ec\revn\sp\view\xml\query\get_transaction_values_table.xml)