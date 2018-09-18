CREATE OR REPLACE FORCE EDITIONABLE VIEW "RV_SP_INVOICE" ("OBJECT_ID", "DOCUMENT_KEY", "DOCUMENT_NUMBER", "DAYTIME", "DOCUMENT_DATE", "PRICING_CURRENCY_CODE", "DOC_BOOKING_VALUE", "DOC_BOOKING_VAT", "DOC_BOOKING_TOTAL", "BOOKING_CURRENCY_CODE", "DOC_AMOUNT_IN_WORDS", "DOC_AMOUNT_IN_WORDS_IND", "DOC_PAY_DATE", "DOC_PAYMENT_TERMS", "TRANSACTION_KEY", "TRANSACTION_NAME", "TRANS_SORT_ORDER", "TRANS_PRICING_VALUE", "TRANS_PRICING_VAT", "TRANS_PRICING_TOTAL", "TRANS_BOOKING_VALUE", "TRANS_BOOKING_VAT", "TRANS_BOOKING_TOTAL", "TRANS_PRODUCT_NAME", "TRANS_SALES_ORDER", "TRANS_DELIVERY_POINT", "TRANS_VAT_CODE", "TRANS_VAT_DESCRIPTION", "LI_SORT_ORDER", "LI_NAME", "LI_UNIT_PRICE", "LI_UNIT_PRICE_UNIT", "LI_FREE_UNIT_QTY", "LI_INTEREST_TYPE", "LI_INTEREST_BASE_AMOUNT", "LI_BASE_RATE", "LI_RATE_OFFSET", "LI_GROSS_RATE", "LI_INTEREST_FROM_DATE", "LI_INTEREST_TO_DATE", "LI_RATE_DAYS", "LI_QTY1", "UOM1_CODE", "LI_QTY2", "UOM2_CODE", "LI_QTY3", "UOM3_CODE", "LI_QTY4", "UOM4_CODE", "LI_PRICING_VALUE", "LI_BOOKING_VALUE", "LI_BASED_TYPE") AS 
  (
SELECT   cd.object_id                                                                                                                   OBJECT_ID
        ,cd.document_key                                                                                                                DOCUMENT_KEY
        ,cd.document_number                                                                                                             DOCUMENT_NUMBER
        ,cd.daytime                                                                                                                     DAYTIME
        ,cd.document_date                                                                                                               DOCUMENT_DATE
        ,ct.pricing_currency_code                                                                                                       PRICING_CURRENCY_CODE
        ,cd.doc_booking_value                                                                                                           DOC_BOOKING_VALUE
        ,cd.doc_booking_vat                                                                                                             DOC_BOOKING_VAT
        ,cd.doc_booking_total                                                                                                           DOC_BOOKING_TOTAL
        ,cd.booking_currency_code                                                                                                       BOOKING_CURRENCY_CODE
        ,cd.amount_in_words                                                                                                             DOC_AMOUNT_IN_WORDS
        ,cd.amount_in_words_ind                                                                                                         DOC_AMOUNT_IN_WORDS_IND
        ,cd.pay_date                                                                                                                    DOC_PAY_DATE
        ,cd.payment_term_name                                                                                                           DOC_PAYMENT_TERMS
        ,ct.transaction_key                                                                                                             TRANSACTION_KEY
        ,ct.name                                                                                                                        TRANSACTION_NAME
        ,ct.sort_order                                                                                                                  TRANS_SORT_ORDER
        ,ct.trans_pricing_value                                                                                                         TRANS_PRICING_VALUE
        ,ct.trans_pricing_vat                                                                                                           TRANS_PRICING_VAT
        ,ct.trans_pricing_total                                                                                                         TRANS_PRICING_TOTAL
        ,ct.trans_booking_value                                                                                                         TRANS_BOOKING_VALUE
        ,ct.trans_booking_vat                                                                                                           TRANS_BOOKING_VAT
        ,ct.trans_booking_total                                                                                                         TRANS_BOOKING_TOTAL
        ,RTRIM(RPAD(ec_product_version.name(ct.product_id,ct.daytime,'<='),250))                                                        TRANS_PRODUCT_NAME
        ,RTRIM(RPAD(ct.sales_order,250))                                                                                                TRANS_SALES_ORDER
        ,RTRIM(RPAD(ec_delpnt_version.name(ct.delivery_point_id,ct.daytime,'<='),250))                                                  TRANS_DELIVERY_POINT
        ,ct.vat_code                                                                                                                    TRANS_VAT_CODE
        ,ct.vat_description                                                                                                             TRANS_VAT_DESCRIPTION
        ,cli.sort_order                                                                                                                 LI_SORT_ORDER
        ,RTRIM(RPAD(cli.name,250))                                                                                                      LI_NAME
        ,cli.unit_price                                                                                                                 LI_UNIT_PRICE
        ,RTRIM(RPAD(cli.unit_price_unit,250))                                                                                           LI_UNIT_PRICE_UNIT
        ,cli.free_unit_qty                                                                                                              LI_FREE_UNIT_QTY
        ,RTRIM(RPAD(cli.interest_type,250))                                                                                             LI_INTEREST_TYPE
        ,cli.interest_base_amount                                                                                                       LI_INTEREST_BASE_AMOUNT
        ,cli.base_rate                                                                                                                  LI_BASE_RATE
        ,cli.rate_offset                                                                                                                LI_RATE_OFFSET
        ,cli.gross_rate                                                                                                                 LI_GROSS_RATE
        ,cli.interest_from_date                                                                                                         LI_INTEREST_FROM_DATE
        ,cli.interest_to_date                                                                                                           LI_INTEREST_TO_DATE
        ,cli.rate_days                                                                                                                  LI_RATE_DAYS
        ,cli.qty1                                                                                                                       LI_QTY1
        ,ctq.uom1_code                                                                                                                  UOM1_CODE
        ,decode(ct.uom2_print_decimals,null,to_number(null),cli.qty2)                                                                   LI_QTY2
        ,decode(ct.uom2_print_decimals,null,null,ctq.uom2_code)                                                                         UOM2_CODE
        ,decode(ct.uom3_print_decimals,null,to_number(null),cli.qty3)                                                                   LI_QTY3
        ,decode(ct.uom3_print_decimals,null,null,ctq.uom3_code)                                                                         UOM3_CODE
        ,decode(ct.uom4_print_decimals,null,to_number(null),cli.qty4)                                                                   LI_QTY4
        ,decode(ct.uom4_print_decimals,null,null,ctq.uom4_code)                                                                         UOM4_CODE
        ,cli.pricing_value                                                                                                              LI_PRICING_VALUE
        ,cli.booking_value                                                                                                              LI_BOOKING_VALUE
        ,cli.line_item_based_type                                                                                                       LI_BASED_TYPE
FROM    cont_document cd,
        cont_transaction ct,
        cont_transaction_qty ctq,
        cont_line_item cli
WHERE cd.object_id = ct.object_id
AND cd.document_key = ct.document_key
AND cli.object_id = ct.object_id
AND cli.transaction_key = ct.transaction_key
and ctq.transaction_key = ct.transaction_key
)