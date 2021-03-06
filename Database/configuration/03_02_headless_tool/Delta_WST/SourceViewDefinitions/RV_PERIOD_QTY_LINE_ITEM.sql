CREATE OR REPLACE FORCE EDITIONABLE VIEW "RV_PERIOD_QTY_LINE_ITEM" ("LINE_ITEM_KEY", "FIELD_CODE", "CONT_LI_NAME", "PRODUCT_NAME", "DELIVERY_PT_NAME", "QTY1", "QTY2", "QTY3", "QTY4", "FREE_UNIT_QTY", "VAT_RATE", "VENDOR_ID", "UNIT_PRICE", "UNIT_PRICE_100", "UNIT_PRICE_UNIT", "LI_BASED_TYPE", "PRICING_VALUE", "BOOKING_VALUE", "USE_CURRENCY_100_IND", "CURR_UOM", "CURR_FREE_UOM", "CURR_UOM_100", "CURR_FREE_UOM_100", "BOOKING_CURRENCY_CODE", "PRICING_CURRENCY_CODE", "DOCUMENT_KEY", "SUPPLY_FROM_DATE", "SUPPLY_TO_DATE", "LI_SORT_ORDER", "TRANS_SORT_ORDER", "PRINT_UOM2_IND", "PRINT_UOM3_IND", "PRINT_UOM4_IND", "PRICE_DECIMAL_SEQ", "UOM1_CODE", "UOM2_CODE", "UOM3_CODE", "UOM4_CODE", "UOM1_DECIMAL_SEQ", "UOM2_DECIMAL_SEQ", "UOM3_DECIMAL_SEQ", "UOM4_DECIMAL_SEQ", "MOVE_QTY_TO_VO_IND") AS 
  select max(lic.line_item_key) line_item_key,
       max(lic.field_code) field_code,
       max(li.name) cont_li_name,
       max(ec_product_version.name(t.product_id, t.daytime, '<=')) product_name,
       ec_delpnt_version.name(max(t.delivery_point_id),
                              max(t.daytime),
                              '<=') delivery_pt_name,
       sum(lic.qty1) qty1,
       sum(lic.qty2) qty2,
       sum(lic.qty3) qty3,
       sum(lic.qty4) qty4,
       max(li.free_unit_qty) free_unit_qty,
       max(lic.vat_rate) vat_rate,
       lic.vendor_id,
       max(li.unit_price) unit_price,
       max(li.unit_price) * 100 unit_price_100,
       max(li.unit_price_unit) unit_price_unit,
       max(lic.line_item_based_type) li_based_type,
       sum(lic.pricing_value) pricing_value,
       sum(lic.booking_value) booking_value,
       max(d.use_currency_100_ind) use_currency_100_ind,
       max(t.pricing_currency_code) || '/' || max(tq.uom1_code) curr_uom,
       max(t.pricing_currency_code) || '/' || max(li.unit_price_unit) curr_free_uom,
       max(t.pricing_currency_code) || ' ' ||
       ec_currency_version.unit100(max(t.pricing_currency_id),
                                   max(t.daytime),
                                   '<=') || '/' || max(tq.uom1_code) curr_uom_100,
       max(t.pricing_currency_code) || ' ' ||
       ec_currency_version.unit100(max(t.pricing_currency_id),
                                   max(t.daytime),
                                   '<=') || '/' || max(li.unit_price_unit) curr_free_uom_100,
       max(d.booking_currency_code) booking_currency_code,
       MAX(t.PRICING_CURR_CODE) pricing_currency_code,
       max(d.document_key) document_key,
       t.supply_from_date,
       t.supply_to_date,
       max(li.sort_order) li_sort_order,
       max(t.sort_order) trans_sort_order,
       decode(max(t.uom2_print_decimals),null,'N','Y') print_uom2_ind,
       decode(max(t.uom3_print_decimals),null,'N','Y') print_uom3_ind,
       decode(max(t.uom4_print_decimals),null,'N','Y') print_uom4_ind,
       ecdp_contract_setup.getnumseq(ec_contract_version.price_decimals(max(d.object_id),max(d.daytime),'<='),'0') price_Decimal_Seq,
       max(tq.uom1_code) uom1_code,
       max(tq.uom2_code) uom2_code,
       max(tq.uom3_code) uom3_code,
       max(tq.uom4_code) uom4_code,
       max(t.Uom1_Decimal_Seq) Uom1_Decimal_Seq,
       max(t.Uom2_Decimal_Seq) Uom2_Decimal_Seq,
       max(t.Uom3_Decimal_Seq) Uom3_Decimal_Seq,
       max(t.Uom4_Decimal_Seq) Uom4_Decimal_Seq,
       max(li.move_qty_to_vo_ind) move_qty_to_vo_ind
  from rv_cont_document        d,
       rv_cont_transaction     t,
       rv_cont_transaction_qty tq,
       rv_cont_line_item       li,
       rv_cont_li_dist_company lic
 WHERE d.document_key = t.document_key
   and t.transaction_key = li.transaction_key
   and t.transaction_key = tq.transaction_key (+)
   and li.line_item_key = lic.line_item_key
   and lic.line_item_based_type IN
       ('QTY', 'FREE_UNIT_PRICE_OBJECT', 'CALC_VALUE', 'FIXED_VALUE',
        'FREE_UNIT')
 group by lic.vendor_id,
          lic.customer_id,
          t.product_code,
          t.supply_from_date,
          t.supply_to_date,
          t.delivery_point_code,
          t.transaction_key,
          li.line_item_key