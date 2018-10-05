CREATE OR REPLACE FORCE EDITIONABLE VIEW "V_INV_LAYER_TOTAL_POSITION" ("POSITION", "OBJECT_ID", "OBJECT_CODE", "DAYTIME", "RATE", "PRICE_UNIT", "OPENING_POS_QTY1", "UOM1_CODE1", "UOM1_CODE2", "YTD_MOV_QTY1", "UOM1_CODE3", "CLOSING_POS_QTY1", "CLOSING_PRICE_VALUE", "PRICING_CURR_CODE", "CLOSING_MEMO_VALUE", "PRICING_CURRENCY_ID", "MEMO_CURRENCY_CODE", "MEMO_CURRENCY_ID", "VALUE_1", "VALUE_2", "VALUE_3", "VALUE_4", "VALUE_5", "TEXT_1", "TEXT_2", "TEXT_3", "TEXT_4", "TEXT_5", "TEXT_6", "TEXT_7", "TEXT_8", "TEXT_9", "TEXT_10", "DATE_1", "DATE_2", "DATE_3", "DATE_4", "DATE_5", "RECORD_STATUS", "CREATED_BY", "CREATED_DATE", "LAST_UPDATED_BY", "LAST_UPDATED_DATE", "REV_NO", "REV_TEXT") AS 
  (
SELECT  -- Inv Layer, Current Layer, CODE = DAYTIME
    'UNDERLIFT' AS POSITION,
    iv.OBJECT_ID AS OBJECT_ID,
    iv.YEAR_CODE OBJECT_CODE,
    iv.DAYTIME AS DAYTIME,
    iv.UL_RATE AS RATE,
    (select ec_currency.object_code(Ec_Inventory_Version.ul_pricing_currency_id(iv.object_id, iv.daytime, '<='))
        ||'/'||Ec_Inventory_Version.uom1_code(iv.object_id, iv.daytime, '<=') from dual) AS PRICE_UNIT,
    iv.ul_opening_pos_qty1 AS OPENING_POS_QTY1,
    Ec_Inventory_Version.uom1_code(iv.object_id, iv.daytime, '<=') AS UOM1_CODE1,
    Ec_Inventory_Version.uom1_code(iv.object_id, iv.daytime, '<=') AS UOM1_CODE2,
    iv.ytd_ul_mov_qty1 AS YTD_MOV_QTY1,
    Ec_Inventory_Version.uom1_code(iv.object_id, iv.daytime, '<=') AS UOM1_CODE3,
    iv.ul_closing_pos_qty1 AS CLOSING_POS_QTY1,
    iv.ul_price_value AS CLOSING_PRICE_VALUE,
    ec_currency.object_code(Ec_Inventory_Version.ul_pricing_currency_id(iv.object_id, iv.daytime, '<=')) AS PRICING_CURR_CODE,
    iv.ul_memo_value AS CLOSING_MEMO_VALUE,
    Ec_Inventory_Version.ul_pricing_currency_id(iv.object_id, iv.daytime, '<=') PRICING_CURRENCY_ID,
    ec_currency.object_code(Ec_Inventory_Version.ul_memo_currency_id(iv.object_id, iv.daytime, '<=')) AS MEMO_CURRENCY_CODE,
    Ec_Inventory_Version.ul_memo_currency_id(iv.object_id, iv.daytime, '<=') AS MEMO_CURRENCY_ID,
    iv.value_1,
    iv.value_2,
    iv.value_3,
    iv.value_4,
    iv.value_5,
    iv.text_1,
    iv.text_2,
    iv.text_3,
    iv.text_4,
    iv.text_5,
    iv.text_6,
    iv.text_7,
    iv.text_8,
    iv.text_9,
    iv.text_10,
    iv.date_1,
    iv.date_2,
    iv.date_3,
    iv.date_4,
    iv.date_5,
    iv.RECORD_STATUS,
    iv.CREATED_BY,
    iv.CREATED_DATE,
    iv.LAST_UPDATED_BY,
    iv.LAST_UPDATED_DATE,
    iv.REV_NO,
    iv.REV_TEXT
FROM
    INVENTORY_VERSION oa
    ,INVENTORY o
    ,INV_VALUATION iv
WHERE
    oa.object_id = o.object_id
AND oa.object_id = iv.object_id
AND TO_CHAR(iv.daytime, 'YYYY') = iv.year_Code
AND iv.daytime >= TRUNC(oa.daytime,'MONTH')
AND oa.daytime = (
    SELECT MIN(daytime) FROM INVENTORY_VERSION v2
    WHERE v2.object_id = oa.object_id
    AND   iv.daytime >= trunc(v2.daytime,'MONTH')
    AND iv.daytime < nvl(v2.end_date, iv.daytime + 1)
    )
UNION ALL
SELECT  -- Inv Layer
    'UNDERLIFT' AS POSITION,
    iv.OBJECT_ID AS OBJECT_ID,
    iv.YEAR_CODE OBJECT_CODE,
    iv.DAYTIME AS DAYTIME,
    iv.UL_RATE AS RATE,
    (select ec_currency.object_code(Ec_Inventory_Version.ul_pricing_currency_id(iv.object_id, iv.daytime, '<='))
        ||'/'||Ec_Inventory_Version.uom1_code(iv.object_id, iv.daytime, '<=') from dual) AS PRICE_UNIT,
    iv.ul_opening_pos_qty1 AS OPENING_POS_QTY1,
    Ec_Inventory_Version.uom1_code(iv.object_id, iv.daytime, '<=') AS UOM1_CODE1,
    Ec_Inventory_Version.uom1_code(iv.object_id, iv.daytime, '<=') AS UOM1_CODE2,
    iv.ytd_ul_mov_qty1 AS YTD_MOV_QTY1,
    Ec_Inventory_Version.uom1_code(iv.object_id, iv.daytime, '<=') AS UOM1_CODE3,
    iv.ul_closing_pos_qty1 AS CLOSING_POS_QTY1,
    iv.ul_price_value AS CLOSING_PRICE_VALUE,
    ec_currency.object_code(Ec_Inventory_Version.ul_pricing_currency_id(iv.object_id, iv.daytime, '<=')) AS PRICING_CURR_CODE,
    iv.ul_memo_value AS CLOSING_MEMO_VALUE,
    Ec_Inventory_Version.ul_pricing_currency_id(iv.object_id, iv.daytime, '<=') PRICING_CURRENCY_ID,
    ec_currency.object_code(Ec_Inventory_Version.ul_memo_currency_id(iv.object_id, iv.daytime, '<=')) AS MEMO_CURRENCY_CODE,
    Ec_Inventory_Version.ul_memo_currency_id(iv.object_id, iv.daytime, '<=') AS MEMO_CURRENCY_ID,
    iv.value_1,
    iv.value_2,
    iv.value_3,
    iv.value_4,
    iv.value_5,
    iv.text_1,
    iv.text_2,
    iv.text_3,
    iv.text_4,
    iv.text_5,
    iv.text_6,
    iv.text_7,
    iv.text_8,
    iv.text_9,
    iv.text_10,
    iv.date_1,
    iv.date_2,
    iv.date_3,
    iv.date_4,
    iv.date_5,
    iv.RECORD_STATUS,
    iv.CREATED_BY,
    iv.CREATED_DATE,
    iv.LAST_UPDATED_BY,
    iv.LAST_UPDATED_DATE,
    iv.REV_NO,
    iv.REV_TEXT
FROM
    INV_VALUATION iv
    ,INVENTORY_VERSION oa
    ,INVENTORY o
WHERE
    iv.object_id = oa.object_id
AND oa.object_id = o.object_id
AND TO_CHAR(iv.daytime, 'YYYY') <> iv.year_code
AND iv.daytime >= TRUNC(oa.daytime,'MONTH')
AND oa.daytime = (
    SELECT MIN(daytime) FROM INVENTORY_VERSION v2
    WHERE v2.object_id = oa.object_id
    AND   iv.daytime >= trunc(v2.daytime,'MONTH')
    AND iv.daytime < nvl(v2.end_date,iv.daytime + 1)
    )
UNION ALL
SELECT  -- Inv Layer
    'OVERLIFT' AS POSITION,
    iv.OBJECT_ID AS OBJECT_ID,
    iv.YEAR_CODE OBJECT_CODE,
    iv.DAYTIME AS DAYTIME,
    iv.OL_RATE AS RATE,
    (select ec_currency.object_code(Ec_Inventory_Version.ol_pricing_currency_id(iv.object_id, iv.daytime, '<='))
        ||'/'||Ec_Inventory_Version.uom1_code(iv.object_id, iv.daytime, '<=') from dual) AS PRICE_UNIT,
    iv.ol_opening_qty1 AS OPENING_POS_QTY1,
    Ec_Inventory_Version.uom1_code(iv.object_id, iv.daytime, '<=') AS UOM1_CODE1,
    Ec_Inventory_Version.uom1_code(iv.object_id, iv.daytime, '<=') AS UOM1_CODE2,
    iv.ytd_ol_mov_qty1 AS YTD_MOV_QTY1,
    Ec_Inventory_Version.uom1_code(iv.object_id, iv.daytime, '<=') AS UOM1_CODE3,
    iv.ol_closing_pos_qty1 AS CLOSING_POS_QTY1,
    iv.ol_price_value AS CLOSING_PRICE_VALUE,
    ec_currency.object_code(Ec_Inventory_Version.ol_pricing_currency_id(iv.object_id, iv.daytime, '<=')) AS PRICING_CURR_CODE,
    iv.ol_memo_value AS CLOSING_MEMO_VALUE,
    Ec_Inventory_Version.ol_pricing_currency_id(iv.object_id, iv.daytime, '<=') PRICING_CURRENCY_ID,
    ec_currency.object_code(Ec_Inventory_Version.ol_memo_currency_id(iv.object_id, iv.daytime, '<=')) AS MEMO_CURRENCY_CODE,
    Ec_Inventory_Version.ol_memo_currency_id(iv.object_id, iv.daytime, '<=') AS MEMO_CURRENCY_ID,
    iv.value_1,
    iv.value_2,
    iv.value_3,
    iv.value_4,
    iv.value_5,
    iv.text_1,
    iv.text_2,
    iv.text_3,
    iv.text_4,
    iv.text_5,
    iv.text_6,
    iv.text_7,
    iv.text_8,
    iv.text_9,
    iv.text_10,
    iv.date_1,
    iv.date_2,
    iv.date_3,
    iv.date_4,
    iv.date_5,
    iv.RECORD_STATUS,
    iv.CREATED_BY,
    iv.CREATED_DATE,
    iv.LAST_UPDATED_BY,
    iv.LAST_UPDATED_DATE,
    iv.REV_NO,
    iv.REV_TEXT
FROM
    INVENTORY_VERSION oa
    ,INVENTORY o
    ,INV_VALUATION iv
WHERE
    iv.object_id = oa.object_id
AND oa.object_id = o.object_id
AND oa.object_id = iv.object_id
AND iv.daytime = iv.daytime
AND iv.daytime >= TRUNC(oa.daytime,'MONTH')
AND oa.daytime = (
    SELECT MIN(daytime) FROM INVENTORY_VERSION v2
    WHERE v2.object_id = oa.object_id
    AND   iv.daytime >= trunc(v2.daytime,'MONTH')
    AND iv.daytime < nvl(v2.end_date,iv.daytime + 1)
    )
AND (iv.ol_opening_qty1 < 0 -- Overlift
OR iv.ol_closing_pos_qty1 < 0)
UNION ALL
SELECT  -- Inv Layer
    'PHYSICAL_STOCK' AS POSITION,
    iv.OBJECT_ID AS OBJECT_ID,
    iv.YEAR_CODE OBJECT_CODE,
    iv.DAYTIME AS DAYTIME,
    iv.PS_RATE AS RATE,
    (select ec_currency.object_code(Ec_Inventory_Version.ul_pricing_currency_id(iv.object_id, iv.daytime, '<='))
        ||'/'||Ec_Inventory_Version.uom1_code(iv.object_id, iv.daytime, '<=') from dual) AS PRICE_UNIT,
    iv.ps_opening_qty1 AS OPENING_POS_QTY1,
    Ec_Inventory_Version.uom1_code(iv.object_id, iv.daytime, '<=') AS UOM1_CODE1,
    Ec_Inventory_Version.uom1_code(iv.object_id, iv.daytime, '<=') AS UOM1_CODE2,
    iv.ytd_ps_mov_qty1 AS YTD_MOV_QTY1,
    Ec_Inventory_Version.uom1_code(iv.object_id, iv.daytime, '<=') AS UOM1_CODE3,
    iv.ps_closing_pos_qty1 AS CLOSING_POS_QTY1,
    iv.ps_price_value AS CLOSING_PRICE_VALUE,
    ec_currency.object_code(Ec_Inventory_Version.ul_pricing_currency_id(iv.object_id, iv.daytime, '<=')) AS PRICING_CURR_CODE,
    iv.ps_memo_value AS CLOSING_MEMO_VALUE,
    Ec_Inventory_Version.ul_pricing_currency_id(iv.object_id, iv.daytime, '<=') PRICING_CURRENCY_ID,
    ec_currency.object_code(Ec_Inventory_Version.ul_memo_currency_id(iv.object_id, iv.daytime, '<=')) AS MEMO_CURRENCY_CODE,
    Ec_Inventory_Version.ul_memo_currency_id(iv.object_id, iv.daytime, '<=') AS MEMO_CURRENCY_ID,
    iv.value_1,
    iv.value_2,
    iv.value_3,
    iv.value_4,
    iv.value_5,
    iv.text_1,
    iv.text_2,
    iv.text_3,
    iv.text_4,
    iv.text_5,
    iv.text_6,
    iv.text_7,
    iv.text_8,
    iv.text_9,
    iv.text_10,
    iv.date_1,
    iv.date_2,
    iv.date_3,
    iv.date_4,
    iv.date_5,
    iv.RECORD_STATUS,
    iv.CREATED_BY,
    iv.CREATED_DATE,
    iv.LAST_UPDATED_BY,
    iv.LAST_UPDATED_DATE,
    iv.REV_NO,
    iv.REV_TEXT
FROM
    INV_VALUATION iv
    ,INVENTORY_VERSION oa
    ,INVENTORY o
WHERE
    iv.object_id = oa.object_id
AND oa.object_id = o.object_id
AND iv.daytime >= TRUNC(oa.daytime,'MONTH')
AND oa.daytime = (
    SELECT MIN(daytime) FROM INVENTORY_VERSION v2
    WHERE v2.object_id = oa.object_id
    AND   iv.daytime >= trunc(v2.daytime,'MONTH')
    AND iv.daytime < nvl(v2.end_date,iv.daytime + 1)
    )
AND iv.ps_closing_pos_qty1 > 0 -- Physical stock
)
ORDER BY OBJECT_CODE DESC