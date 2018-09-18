CREATE OR REPLACE FORCE EDITIONABLE VIEW "V_INV_LAYER_F_TOTAL_POSITION" ("POSITION", "OBJECT_ID", "OBJECT_CODE", "DAYTIME", "FIELD_NAME", "RATE", "PRICE_UNIT", "YEAR_OPENING_POS_QTY1", "UOM1_CODE1", "PPA_QTY1", "UOM1_CODE2", "YTD_MOVEMENT_QTY1", "UOM1_CODE3", "CLOSING_POSITION_QTY1", "PRICE_VALUE", "PRICING_CURR_CODE", "MEMO_VALUE", "MEMO_CURRENCY_CODE", "DIST_ID", "VALUE_1", "VALUE_2", "VALUE_3", "VALUE_4", "VALUE_5", "VALUE_6", "VALUE_7", "VALUE_8", "VALUE_9", "VALUE_10", "TEXT_1", "TEXT_2", "TEXT_3", "TEXT_4", "DATE_1", "DATE_2", "DATE_3", "DATE_4", "DATE_5", "RECORD_STATUS", "CREATED_BY", "CREATED_DATE", "LAST_UPDATED_BY", "LAST_UPDATED_DATE", "REV_NO", "REV_TEXT") AS 
  SELECT -- Inv Layer, Current Layer, CODE = DAYTIME
       'UNDERLIFT' AS position,
       idv.object_id,
       idv.year_code AS object_code,
       idv.daytime,
       ec_field_version.name(idv.dist_id, idv.daytime, '<=') AS field_name,
       idv.ul_rate AS rate,
       (SELECT ec_currency.object_code(ec_inv_valuation.ul_pricing_currency_id(idv.object_id, idv.daytime, to_char(idv.daytime, 'YYYY'), '<=')) || '/' || idv.uom1_code FROM dual) AS price_unit,
       idv.opening_ul_position_qty1 AS year_opening_pos_qty1,
       idv.uom1_code AS uom1_code1,
       idv.ppa_qty1 AS ppa_qty1,
       idv.uom1_code AS uom1_code2,
       idv.ytd_ul_mov_qty1 AS ytd_movement_qty1,
       idv.uom1_code AS uom1_code3,
       idv.closing_ul_position_qty1 AS closing_position_qty1,
       idv.ul_price_value AS price_value,
       ec_currency.object_code(ec_inventory_version.ul_pricing_currency_id(idv.object_id, idv.daytime, '<=')) AS pricing_curr_code,
       idv.ul_memo_value AS memo_value,
       ec_currency.object_code(ec_inventory_version.ul_memo_currency_id(idv.object_id, idv.daytime, '<=')) AS memo_currency_code,
       idv.dist_id,
       idv.value_1,
       idv.value_2,
       idv.value_3,
       idv.value_4,
       idv.value_5,
       idv.value_6,
       idv.value_7,
       idv.value_8,
       idv.value_9,
       idv.value_10,
       idv.text_1,
       idv.text_2,
       idv.text_3,
       idv.text_4,
       idv.date_1,
       idv.date_2,
       idv.date_3,
       idv.date_4,
       idv.date_5,
       idv.record_status,
       idv.created_by,
       idv.created_date,
       idv.last_updated_by,
       idv.last_updated_date,
       idv.rev_no,
       idv.rev_text
  FROM inv_dist_valuation idv, inventory_version oa, inventory o
 WHERE idv.object_id = oa.object_id
   AND oa.object_id = o.object_id
   AND idv.daytime >= trunc(oa.daytime, 'MONTH')
   AND oa.daytime =
       (SELECT MIN(daytime)
          FROM inventory_version v2
         WHERE v2.object_id = oa.object_id
           AND idv.daytime >= trunc(v2.daytime, 'MONTH')
           AND idv.daytime < nvl(v2.end_date, idv.daytime + 1))
UNION ALL
SELECT 'OVERLIFT' AS position,
       idv.object_id,
       idv.year_code AS object_code,
       idv.daytime,
       ec_field_version.name(idv.dist_id, idv.daytime, '<=') AS field_name,
       idv.ol_rate AS rate,
       (SELECT ec_currency.object_code(ec_inv_valuation.ol_pricing_currency_id(idv.object_id, idv.daytime, to_char(idv.daytime, 'YYYY'), '<=')) || '/' || idv.uom1_code FROM dual) AS price_unit,
       idv.opening_ol_position_qty1 AS year_opening_pos_qty1,
       idv.uom1_code AS uom1_code1,
       idv.ppa_qty1,
       idv.uom1_code AS uom1_code2,
       idv.ytd_ol_mov_qty1 AS ytd_movement_qty1,
       idv.uom1_code AS uom1_code3,
       idv.closing_ol_position_qty1 AS closing_position_qty1,
       idv.ol_price_value AS price_value,
       ec_currency.object_code(ec_inventory_version.ol_pricing_currency_id(idv.object_id, idv.daytime, '<=')) AS pricing_curr_code,
       idv.ol_memo_value AS memo_value,
       ec_currency.object_code(ec_inventory_version.ol_memo_currency_id(idv.object_id, idv.daytime, '<=')) AS memo_currency_code,
       idv.dist_id,
       idv.value_1,
       idv.value_2,
       idv.value_3,
       idv.value_4,
       idv.value_5,
       idv.value_6,
       idv.value_7,
       idv.value_8,
       idv.value_9,
       idv.value_10,
       idv.text_1,
       idv.text_2,
       idv.text_3,
       idv.text_4,
       idv.date_1,
       idv.date_2,
       idv.date_3,
       idv.date_4,
       idv.date_5,
       idv.record_status,
       idv.created_by,
       idv.created_date,
       idv.last_updated_by,
       idv.last_updated_date,
       idv.rev_no,
       idv.rev_text
  FROM inv_dist_valuation idv, inventory_version oa, inventory o
 WHERE idv.object_id = oa.object_id
   AND oa.object_id = o.object_id
   AND idv.daytime >= trunc(oa.daytime, 'MONTH')
   AND oa.daytime =
       (SELECT MIN(daytime)
          FROM inventory_version v2
         WHERE v2.object_id = oa.object_id
           AND idv.daytime >= trunc(v2.daytime, 'MONTH')
           AND idv.daytime < nvl(v2.end_date, idv.daytime + 1))
UNION ALL
SELECT 'PHYSICAL_STOCK' AS position,
       idv.object_id,
       idv.year_code AS object_code,
       idv.daytime,
       ec_field_version.name(idv.dist_id, idv.daytime, '<=') AS field_name,
       idv.ps_rate AS rate,
       (SELECT ec_currency.object_code(ec_inv_valuation.ul_pricing_currency_id(idv.object_id, idv.daytime, to_char(idv.daytime, 'YYYY'), '<=')) || '/' || idv.uom1_code FROM dual) AS price_unit,
       idv.opening_ps_position_qty1 AS year_opening_pos_qty1,
       idv.uom1_code AS uom1_code1,
       idv.ppa_qty1,
       idv.uom1_code AS uom1_code2,
       idv.ytd_ps_movement_qty1 AS ytd_movement_qty1,
       idv.uom1_code AS uom1_code3,
       idv.closing_ps_position_qty1 AS closing_position_qty1,
       idv.ps_price_value AS price_value,
       ec_currency.object_code(ec_inventory_version.ul_pricing_currency_id(idv.object_id, idv.daytime, '<=')) AS pricing_curr_code,
       idv.ps_memo_value AS memo_value,
       ec_currency.object_code(ec_inventory_version.ul_memo_currency_id(idv.object_id, idv.daytime, '<=')) AS memo_currency_code,
       idv.dist_id,
       idv.value_1,
       idv.value_2,
       idv.value_3,
       idv.value_4,
       idv.value_5,
       idv.value_6,
       idv.value_7,
       idv.value_8,
       idv.value_9,
       idv.value_10,
       idv.text_1,
       idv.text_2,
       idv.text_3,
       idv.text_4,
       idv.date_1,
       idv.date_2,
       idv.date_3,
       idv.date_4,
       idv.date_5,
       idv.record_status,
       idv.created_by,
       idv.created_date,
       idv.last_updated_by,
       idv.last_updated_date,
       idv.rev_no,
       idv.rev_text
  FROM inv_dist_valuation idv, inventory_version oa, inventory o
 WHERE idv.object_id = oa.object_id
   AND oa.object_id = o.object_id
   AND idv.daytime >= trunc(oa.daytime, 'MONTH')
   AND oa.daytime =
       (SELECT MIN(daytime)
          FROM inventory_version v2
         WHERE v2.object_id = oa.object_id
           AND idv.daytime >= trunc(v2.daytime, 'MONTH')
           AND idv.daytime < nvl(v2.end_date, idv.daytime + 1))