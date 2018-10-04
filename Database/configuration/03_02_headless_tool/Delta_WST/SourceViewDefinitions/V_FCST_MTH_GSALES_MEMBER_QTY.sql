CREATE OR REPLACE FORCE EDITIONABLE VIEW "V_FCST_MTH_GSALES_MEMBER_QTY" ("SORT_ORDER", "NQ_EDITABLE_IND", "CA_EDITABLE_IND", "SA_EDITABLE_IND", "TS_EDITABLE_IND", "SS_EDITABLE_IND", "SQ_EDITABLE_IND", "INV_EDITABLE_IND", "INV_OPENING_POS_EDIT_IND", "INV_PLAN_EDITABLE_IND", "OBJECT_ID", "MEMBER_NO", "MEMBER_TYPE", "FIELD_ID", "FIELD_CODE", "PRODUCT_ID", "PRODUCT_CODE", "DAYTIME", "MONTH_LABEL", "STATUS", "INV_OPENING_POS_QTY", "UOM", "NET_QTY", "COMMERCIAL_ADJ_QTY", "SWAP_ADJ_QTY", "AVAIL_SALE_QTY", "INV_MOV_QTY", "SALE_QTY", "TERM_SALE_QTY", "SPOT_SALE_QTY", "INV_CLOSING_POS_QTY", "INV_RATE", "INV_CLOSING_VALUE", "PRICE_CURRENCY_CODE", "FOREX_CURRENCY_CODE", "PYA_IND", "RECORD_STATUS", "CREATED_BY", "CREATED_DATE", "LAST_UPDATED_BY", "LAST_UPDATED_DATE", "REV_NO", "REV_TEXT") AS 
  (
    SELECT '1_MTH' SORT_ORDER,
           DECODE(ecdp_revn_forecast.RevnFcstProductInQtyFcst(fc.object_id, fm.product_id, fm.field_id, ec_stream_item_version.company_id(fm.stream_item_id, fc.start_date, '<='), fc.start_date), 'TRUE', 'N',
                  DECODE(ec_forecast_version.populate_method(fc.object_id,fc.start_date,'<='),'PLAN', 'Y',
                        DECODE(ecdp_revn_forecast.isPriorToPlanDate(fc.object_id,fms.daytime),'TRUE', 'N', 'Y'))) NQ_EDITABLE_IND,
           DECODE(fm.adj_stream_item_id, NULL, 'N',
                 DECODE(ec_forecast_version.populate_method(fc.object_id,fc.start_date,'<='),'PLAN', 'Y',
                       DECODE(ecdp_revn_forecast.isPriorToPlanDate(fc.object_id,fms.daytime),'TRUE', 'N', 'Y'))) CA_EDITABLE_IND,
           DECODE(fm.swap_stream_item_id, NULL, 'N',
                  DECODE(ec_forecast_version.populate_method(fc.object_id,fc.start_date,'<='),'PLAN', 'Y',
           DECODE(ecdp_revn_forecast.isPriorToPlanDate(fc.object_id,fms.daytime),'TRUE', 'N', 'Y'))) SA_EDITABLE_IND,
           'N' TS_EDITABLE_IND, -- Only Sales Qty is potentially editable
           'N' SS_EDITABLE_IND, -- Only Sales Qty is potentially editable
          DECODE(ec_forecast_version.populate_method(fc.object_id,fc.start_date,'<='),'PLAN', 'Y',
          DECODE(ecdp_revn_forecast.isPriorToPlanDate(fc.object_id,fms.daytime),'TRUE', 'N', 'Y')) SQ_EDITABLE_IND,
           DECODE(ec_forecast_version.populate_method(fc.object_id,fc.start_date,'<='),'PLAN', 'Y',
                 DECODE(ecdp_revn_forecast.isPriorToPlanDate(fc.object_id,fms.daytime),'TRUE', 'N', 'Y')) INV_EDITABLE_IND,
           DECODE(ec_forecast_version.populate_method(fc.object_id,fc.start_date,'<='),'YEAR_TO_MONTH', 'N',
               DECODE(ecdp_revn_forecast.isPriorToPlanDate(fc.object_id,fms.daytime),'TRUE', 'Y', 'N')) INV_OPENING_POS_EDIT_IND,
           DECODE(ec_forecast_version.populate_method(fc.object_id,fc.start_date,'<='),'PLAN', 'Y',
                 DECODE(ecdp_revn_forecast.isPriorToPlanDate(fc.object_id,fms.daytime),'TRUE', 'N', 'Y')) INV_PLAN_EDITABLE_IND,
           fc.object_id OBJECT_ID,
           fm.member_no MEMBER_NO,
           fm.member_type MEMBER_TYPE,
           fm.field_id FIELD_ID,
           ec_field.object_code(fm.field_id) FIELD_CODE,
           fm.product_id PRODUCT_ID,
           ec_product.object_code(fm.product_id) PRODUCT_CODE,
           fms.daytime DAYTIME,
           INITCAP(TO_CHAR(fms.daytime, 'MON')) MONTH_LABEL,
           fms.status STATUS,
           fms.inv_opening_pos_qty,
           fms.uom UOM,
           fms.net_qty NET_QTY,
           fms.commercial_adj_qty COMMERCIAL_ADJ_QTY,
           fms.swap_adj_qty SWAP_ADJ_QTY,
           (NVL(fms.net_qty,0)+NVL(fms.commercial_adj_qty,0)+NVL(fms.swap_adj_qty,0)+nvl(fms.inv_opening_pos_qty,0)) AVAIL_SALE_QTY,
           -- If prior to plan date, actual inventory numbers are used to find the inventory movement
           DECODE(ecdp_revn_forecast.isPriorToPlanDate(fc.object_id,fms.daytime),'TRUE', nvl(fms.inv_closing_pos_qty,0) - nvl(fms.inv_opening_pos_qty,0),((NVL(fms.net_qty,0)+(NVL(fms.commercial_adj_qty,0)+NVL(fms.swap_adj_qty,0)))-NVL(fms.sale_qty,0))) INV_MOV_QTY,
           fms.sale_qty SALE_QTY,
           fms.term_sale_qty TERM_SALE_QTY,
           fms.spot_sale_qty SPOT_SALE_QTY,
           fms.inv_closing_pos_qty,
           fms.inv_rate,
           fms.inv_closing_value,
           ec_currency.object_code(fms.price_currency_id) price_currency_code,
           ec_currency.object_code(fms.forex_currency_id) forex_currency_code,
           'N' PYA_IND,
           fms.RECORD_STATUS,
           fms.CREATED_BY,
           fms.CREATED_DATE,
           fms.LAST_UPDATED_BY,
           fms.LAST_UPDATED_DATE,
           fms.REV_NO,
           fms.REV_TEXT
      FROM forecast fc, fcst_member fm, fcst_mth_status fms
     WHERE fc.object_id = fm.object_id
       AND fm.member_no = fms.member_no
       AND fm.product_collection_type = 'GAS_SALES'
UNION ALL
  -- Prior Year Adjustment
    SELECT '3_YR' SORT_ORDER,
           DECODE(ecdp_revn_forecast.RevnFcstProductInQtyFcst(fc.object_id, fm.product_id, fm.field_id, ec_stream_item_version.company_id(fm.stream_item_id, fc.start_date, '<='), fc.start_date), 'TRUE', 'N', 'Y') NQ_EDITABLE_IND,
           'N' CA_EDITABLE_IND,
           DECODE(fm.swap_stream_item_id, NULL, 'N', 'Y') SA_EDITABLE_IND,
           'N' TS_EDITABLE_IND,  -- Term sale qty is only editable in PYA row
           'N' SS_EDITABLE_IND,  -- Spot sale qty is only editable in PYA row
           'N' SQ_EDITABLE_IND,  -- Displays sum of TS and SS
           'N' INV_EDITABLE_IND, -- Inventory columns should not be editable
           'N' INV_OPENING_POS_EDIT_IND,
           'N' INV_PLAN_EDITABLE_IND, -- Inventory columns should not be editable
           fc.object_id OBJECT_ID,
           fm.member_no MEMBER_NO,
           fm.member_type MEMBER_TYPE,
           fm.field_id FIELD_ID,
           ec_field.object_code(fm.field_id) FIELD_CODE,
           fm.product_id PRODUCT_ID,
           ec_product.object_code(fm.product_id) PRODUCT_CODE,
           fys.daytime DAYTIME,
           'Prior Year' MONTH_LABEL,
           'Adjustment' STATUS,
           fys.inv_opening_pos_qty,
           fys.uom UOM,
           fys.net_qty NET_QTY,
           fys.commercial_adj_qty COMMERCIAL_ADJ_QTY,
           fys.swap_adj_qty SWAP_ADJ_QTY,
           (NVL(fys.net_qty,0)+NVL(fys.commercial_adj_qty,0)+NVL(fys.swap_adj_qty,0)+nvl(fys.inv_opening_pos_qty,0)) AVAIL_SALE_QTY,
           NULL INV_MOV_QTY,
           NVL(fys.term_sale_qty,0) + NVL(fys.spot_sale_qty,0) SALE_QTY,
           fys.term_sale_qty TERM_SALE_QTY,
           fys.spot_sale_qty SPOT_SALE_QTY,
           fys.inv_closing_pos_qty,
           fys.inv_rate,
           fys.inv_closing_value,
           ec_currency.object_code(fys.price_currency_id) price_currency_code,
           ec_currency.object_code(fys.forex_currency_id) forex_currency_code,
           'Y' PYA_IND,
           fys.RECORD_STATUS,
           fys.CREATED_BY,
           fys.CREATED_DATE,
           fys.LAST_UPDATED_BY,
           fys.LAST_UPDATED_DATE,
           fys.REV_NO,
           fys.REV_TEXT
      FROM forecast fc, fcst_member fm, fcst_yr_status fys
     WHERE fc.object_id = fm.object_id
       AND fm.member_no = fys.member_no
       AND fm.product_collection_type = 'GAS_SALES'
)