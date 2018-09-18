CREATE OR REPLACE FORCE EDITIONABLE VIEW "V_CONT_LINE_ITEM_DIST_SUM" ("OBJECT_ID", "DAYTIME", "DIST_ID", "STREAM_ITEM_NAME", "TRANSACTION_KEY", "DOCUMENT_KEY", "SPLIT_SHARE", "SPLIT_SHARE_QTY2", "SPLIT_SHARE_QTY3", "SPLIT_SHARE_QTY4", "ALLOC_STREAM_ITEM_NAME", "SPLIT_VALUE", "REPORT_CATEGORY_CODE", "LINE_ITEM_VALUE", "VALUE_ADJUSTMENT", "CONTRIBUTION_FACTOR", "QTY1", "UOM1_CODE", "QTY2", "UOM2_CODE", "QTY3", "UOM3_CODE", "QTY4", "UOM4_CODE", "NON_ADJUSTED_VALUE", "PRICING_VALUE", "PRICING_VAT_VALUE", "PRICING_CURRENCY_CODE", "BOOKING_VALUE", "BOOKING_VAT_VALUE", "BOOKING_CURRENCY_CODE", "MEMO_VALUE", "MEMO_VAT_VALUE", "MEMO_CURRENCY_CODE", "PRICE_CONCEPT_CODE", "PRICE_ELEMENT_CODE", "STIM_VALUE_CATEGORY_CODE", "JV_BILLABLE", "COMMENTS", "STREAM_ITEM_ID", "STREAM_ITEM_CODE", "NODE_ID", "NODE_CODE", "ALLOC_STREAM_ITEM_ID", "ALLOC_STREAM_ITEM_CODE", "FIELD_ID", "FIELD_CODE", "RECORD_STATUS", "CREATED_BY", "CREATED_DATE", "LAST_UPDATED_BY", "LAST_UPDATED_DATE", "REV_NO", "REV_TEXT", "APPROVAL_STATE", "APPROVAL_BY", "APPROVAL_DATE", "REC_ID", "PROFIT_CENTRE_ID") AS 
  SELECT ctlid.object_id AS object_id,
       ctlid.daytime AS daytime,
       ctlid.dist_id AS dist_id,
       ecdp_objects.getobjname(ctlid.stream_item_id, ctlid.daytime) AS stream_item_name,
       ctlid.transaction_key AS transaction_key,
       ctlid.document_key AS document_key,
       ecdp_line_item.split_share_rebalance(1,ctlid.line_item_key,ctlid.dist_id,split_share) AS split_share,
       ecdp_line_item.split_share_rebalance(2,ctlid.line_item_key,ctlid.dist_id,split_share_qty2) split_share_qty2,
       ecdp_line_item.split_share_rebalance(3,ctlid.line_item_key,ctlid.dist_id,split_share_qty3) split_share_qty3,
       ecdp_line_item.split_share_rebalance(4,ctlid.line_item_key,ctlid.dist_id,split_share_qty4) split_share_qty4,
       ecdp_objects.getobjname(ctlid.alloc_stream_item_id, ctlid.daytime) AS alloc_stream_item_name,
       ctlid.split_value AS split_value,
       ctlid.report_category_code AS report_category_code,
       ctlid.line_item_value AS line_item_value,
       ctlid.value_adjustment AS value_adjustment,
       ctlid.contribution_factor AS contribution_factor,
       ctlid.qty1 AS qty1,
       ctlid.uom1_code AS uom1_code,
       ctlid.qty2 AS qty2,
       ctlid.uom2_code AS uom2_code,
       ctlid.qty3 AS qty3,
       ctlid.uom3_code AS uom3_code,
       ctlid.qty4 AS qty4,
       ctlid.uom4_code AS uom4_code,
       (SELECT SUM(d.non_adjusted_value)
          FROM cont_line_item_dist d
         WHERE d.transaction_key = ctlid.transaction_key
           AND d.stream_item_id = ctlid.stream_item_id) AS non_adjusted_value,
       (SELECT SUM(d.pricing_value)
          FROM cont_line_item_dist d
         WHERE d.transaction_key = ctlid.transaction_key
           AND d.stream_item_id = ctlid.stream_item_id) AS pricing_value,
       (SELECT SUM(d.pricing_vat_value)
          FROM cont_line_item_dist d
         WHERE d.transaction_key = ctlid.transaction_key
           AND d.stream_item_id = ctlid.stream_item_id) AS pricing_vat_value,
       ec_cont_transaction.pricing_currency_code(ctlid.transaction_key) AS pricing_currency_code,
       (SELECT SUM(d.booking_value)
          FROM cont_line_item_dist d
         WHERE d.transaction_key = ctlid.transaction_key
           AND d.stream_item_id = ctlid.stream_item_id) AS booking_value,
       (SELECT SUM(d.booking_vat_value)
          FROM cont_line_item_dist d
         WHERE d.transaction_key = ctlid.transaction_key
           AND d.stream_item_id = ctlid.stream_item_id) AS booking_vat_value,
       ec_cont_document.booking_currency_code(ctlid.document_key) AS booking_currency_code,
       (SELECT SUM(d.memo_value)
          FROM cont_line_item_dist d
         WHERE d.transaction_key = ctlid.transaction_key
           AND d.stream_item_id = ctlid.stream_item_id) AS memo_value,
       (SELECT SUM(d.memo_vat_value)
          FROM cont_line_item_dist d
         WHERE d.transaction_key = ctlid.transaction_key
           AND d.stream_item_id = ctlid.stream_item_id) AS memo_vat_value,
       ec_cont_document.memo_currency_code(ctlid.document_key) AS memo_currency_code,
       ctlid.price_concept_code AS price_concept_code,
       ctlid.price_element_code AS price_element_code,
       ctlid.stim_value_category_code AS stim_value_category_code,
       ctlid.jv_billable AS jv_billable,
       ctlid.comments AS comments,
       ctlid.stream_item_id AS stream_item_id,
       ec_stream_item.object_code(ctlid.stream_item_id) AS stream_item_code,
       ctlid.node_id AS node_id,
       ec_node.object_code(ctlid.node_id) AS node_code,
       ctlid.alloc_stream_item_id AS alloc_stream_item_id,
       ec_stream_item.object_code(ctlid.alloc_stream_item_id) AS alloc_stream_item_code,
       ctlid.dist_id AS field_id,
       ec_field.object_code(ctlid.dist_id) AS field_code,
       ctlid.record_status AS record_status,
       ctlid.created_by AS created_by,
       ctlid.created_date AS created_date,
       ctlid.last_updated_by AS last_updated_by,
       ctlid.last_updated_date AS last_updated_date,
       ctlid.rev_no AS rev_no,
       ctlid.rev_text AS rev_text,
       ctlid.approval_state AS approval_state,
       ctlid.approval_by AS approval_by,
       ctlid.approval_date AS approval_date,
       ctlid.rec_id AS rec_id,
       ctlid.profit_centre_id as profit_centre_id
  FROM (SELECT *
          FROM cont_line_item_dist c0
         WHERE c0.line_item_key =
               (SELECT c1.line_item_key
                  FROM cont_line_item c1
                 WHERE c1.transaction_key = c0.transaction_key
                 AND c1.line_item_based_type = DECODE(EcDp_Transaction.GetQtyLICount(c1.transaction_key), 0, c1.line_item_based_type, 'QTY')
                 AND ROWNUM = 1)) ctlid