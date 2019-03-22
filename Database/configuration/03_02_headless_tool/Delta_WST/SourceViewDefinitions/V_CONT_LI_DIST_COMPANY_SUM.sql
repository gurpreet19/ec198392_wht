CREATE OR REPLACE FORCE EDITIONABLE VIEW "V_CONT_LI_DIST_COMPANY_SUM" ("OBJECT_ID", "DAYTIME", "DIST_ID", "DOCUMENT_KEY", "TRANSACTION_KEY", "STREAM_ITEM_NAME", "COMP_STREAM_ITEM_NAME", "VENDOR_SHARE", "VENDOR_SHARE_QTY2", "VENDOR_SHARE_QTY3", "VENDOR_SHARE_QTY4", "SPLIT_VALUE", "CUSTOMER_SHARE", "REPORT_CATEGORY_CODE", "LINE_ITEM_VALUE", "VALUE_ADJUSTMENT", "CONTRIBUTION_FACTOR", "QTY1", "UOM1_CODE", "QTY2", "UOM2_CODE", "QTY3", "UOM3_CODE", "QTY4", "UOM4_CODE", "NON_ADJUSTED_VALUE", "PRICING_VALUE", "PRICING_VAT_VALUE", "PRICING_CURRENCY_CODE", "BOOKING_VALUE", "BOOKING_VAT_VALUE", "BOOKING_CURRENCY_CODE", "MEMO_VALUE", "MEMO_VAT_VALUE", "MEMO_CURRENCY_CODE", "SPLIT_SHARE", "PRICE_CONCEPT_CODE", "PRICE_ELEMENT_CODE", "STIM_VALUE_CATEGORY_CODE", "DESCRIPTION", "SORT_ORDER", "COMMENTS", "STREAM_ITEM_ID", "STREAM_ITEM_CODE", "CUSTOMER_ID", "CUSTOMER_CODE", "FIELD_ID", "FIELD_CODE", "NODE_ID", "NODE_CODE", "COMPANY_STREAM_ITEM_ID", "COMPANY_STREAM_ITEM_CODE", "VENDOR_ID", "VENDOR_CODE", "RECORD_STATUS", "CREATED_BY", "CREATED_DATE", "LAST_UPDATED_BY", "LAST_UPDATED_DATE", "REV_NO", "REV_TEXT", "APPROVAL_STATE", "APPROVAL_BY", "APPROVAL_DATE", "REC_ID") AS 
  SELECT ctlidc.object_id AS object_id,
       ctlidc.daytime AS daytime,
       ctlidc.dist_id AS dist_id,
       ctlidc.document_key AS document_key,
       ctlidc.transaction_key AS transaction_key,
       ec_stream_item_version.NAME(ctlidc.stream_item_id,
                                   ctlidc.daytime,
                                   '<=') AS stream_item_name,
       ec_stream_item_version.NAME(ctlidc.company_stream_item_id,
                                   ctlidc.daytime,
                                   '<=') AS comp_stream_item_name,
       ecdp_line_item.split_share_rebalance(1, ctlidc.line_item_key, ctlidc.dist_id, vendor_share,      ctlidc.vendor_id, ctlidc.stream_item_id) AS vendor_share,
       ecdp_line_item.split_share_rebalance(2, ctlidc.line_item_key, ctlidc.dist_id, vendor_share_qty2, ctlidc.vendor_id, ctlidc.stream_item_id) AS vendor_share_qty2,
       ecdp_line_item.split_share_rebalance(3, ctlidc.line_item_key, ctlidc.dist_id, vendor_share_qty3, ctlidc.vendor_id, ctlidc.stream_item_id) AS vendor_share_qty3,
       ecdp_line_item.split_share_rebalance(4, ctlidc.line_item_key, ctlidc.dist_id, vendor_share_qty4, ctlidc.vendor_id, ctlidc.stream_item_id) AS vendor_share_qty4,
       ctlidc.split_value AS split_value,
       ctlidc.customer_share AS customer_share,
       ctlidc.report_category_code AS report_category_code,
       ctlidc.line_item_value AS line_item_value,
       ctlidc.value_adjustment AS value_adjustment,
       ctlidc.contribution_factor AS contribution_factor,
       ctlidc.qty1 AS qty1,
       ctlidc.uom1_code AS uom1_code,
       ctlidc.qty2 AS qty2,
       ctlidc.uom2_code AS uom2_code,
       ctlidc.qty3 AS qty3,
       ctlidc.uom3_code AS uom3_code,
       ctlidc.qty4 AS qty4,
       ctlidc.uom4_code AS uom4_code,
       (SELECT SUM(d.non_adjusted_value)
          FROM cont_li_dist_company d
         WHERE d.transaction_key = ctlidc.transaction_key
           AND d.stream_item_id = ctlidc.stream_item_id
           AND d.company_stream_item_id = ctlidc.company_stream_item_id
           AND d.vendor_id = ctlidc.vendor_id) AS non_adjusted_value,
       (SELECT SUM(d.pricing_value)
          FROM cont_li_dist_company d
         WHERE d.transaction_key = ctlidc.transaction_key
           AND d.stream_item_id = ctlidc.stream_item_id
           AND d.company_stream_item_id = ctlidc.company_stream_item_id
           AND d.vendor_id = ctlidc.vendor_id) AS pricing_value,
       (SELECT SUM(d.pricing_vat_value)
          FROM cont_li_dist_company d
         WHERE d.transaction_key = ctlidc.transaction_key
           AND d.stream_item_id = ctlidc.stream_item_id
           AND d.company_stream_item_id = ctlidc.company_stream_item_id
           AND d.vendor_id = ctlidc.vendor_id) AS pricing_vat_value,
       ec_cont_transaction.pricing_currency_code(ctlidc.transaction_key) AS pricing_currency_code,
       (SELECT SUM(d.booking_value)
          FROM cont_li_dist_company d
         WHERE d.transaction_key = ctlidc.transaction_key
           AND d.stream_item_id = ctlidc.stream_item_id
           AND d.company_stream_item_id = ctlidc.company_stream_item_id
           AND d.vendor_id = ctlidc.vendor_id) AS booking_value,
       (SELECT SUM(d.booking_vat_value)
          FROM cont_li_dist_company d
         WHERE d.transaction_key = ctlidc.transaction_key
           AND d.stream_item_id = ctlidc.stream_item_id
           AND d.company_stream_item_id = ctlidc.company_stream_item_id
           AND d.vendor_id = ctlidc.vendor_id) AS booking_vat_value,
       ec_cont_document.booking_currency_code(ctlidc.document_key) AS booking_currency_code,
       (SELECT SUM(d.memo_value)
          FROM cont_li_dist_company d
         WHERE d.transaction_key = ctlidc.transaction_key
           AND d.stream_item_id = ctlidc.stream_item_id
           AND d.company_stream_item_id = ctlidc.company_stream_item_id
           AND d.vendor_id = ctlidc.vendor_id) AS memo_value,
       (SELECT SUM(d.memo_vat_value)
          FROM cont_li_dist_company d
         WHERE d.transaction_key = ctlidc.transaction_key
           AND d.stream_item_id = ctlidc.stream_item_id
           AND d.company_stream_item_id = ctlidc.company_stream_item_id
           AND d.vendor_id = ctlidc.vendor_id) AS memo_vat_value,
       ec_cont_document.memo_currency_code(ctlidc.document_key) AS memo_currency_code,
       ctlidc.split_share AS split_share,
       ctlidc.price_concept_code AS price_concept_code,
       ctlidc.price_element_code AS price_element_code,
       ctlidc.stim_value_category_code AS stim_value_category_code,
       ctlidc.description AS description,
       ctlidc.sort_order AS sort_order,
       ctlidc.comments AS comments,
       ctlidc.stream_item_id AS stream_item_id,
       ec_stream_item.object_code(ctlidc.stream_item_id) AS stream_item_code,
       ctlidc.customer_id AS customer_id,
       ec_company.object_code(ctlidc.customer_id) AS customer_code,
       ctlidc.dist_id AS field_id,
       ec_field.object_code(ctlidc.dist_id) AS field_code,
       ctlidc.node_id AS node_id,
       ec_node.object_code(ctlidc.node_id) AS node_code,
       ctlidc.company_stream_item_id AS company_stream_item_id,
       ec_stream_item.object_code(ctlidc.company_stream_item_id) AS company_stream_item_code,
       ctlidc.vendor_id AS vendor_id,
       ec_company.object_code(ctlidc.vendor_id) AS vendor_code,
       ctlidc.record_status AS record_status,
       ctlidc.created_by AS created_by,
       ctlidc.created_date AS created_date,
       ctlidc.last_updated_by AS last_updated_by,
       ctlidc.last_updated_date AS last_updated_date,
       ctlidc.rev_no AS rev_no,
       ctlidc.rev_text AS rev_text,
       ctlidc.approval_state AS approval_state,
       ctlidc.approval_by AS approval_by,
       ctlidc.approval_date AS approval_date,
       ctlidc.rec_id AS rec_id
  FROM (SELECT *
          FROM cont_li_dist_company c0
         WHERE c0.line_item_key =
               (SELECT line_item_key FROM
                   (SELECT c1.line_item_key
                      FROM cont_line_item c1
                     WHERE c1.transaction_key = c0.transaction_key
                       AND c1.line_item_based_type = DECODE(EcDp_Transaction.GetQtyLICount(c1.transaction_key), 0, c1.line_item_based_type, 'QTY')
                     ORDER BY c1.sort_order
                   )
                 WHERE ROWNUM = 1
               )
       ) ctlidc