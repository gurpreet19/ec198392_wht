CREATE OR REPLACE FORCE EDITIONABLE VIEW "V_FCST_MTH_GPURCH_MEMBER_REVN" ("SORT_ORDER", "NR_EDITABLE_IND", "OBJECT_ID", "MEMBER_NO", "DAYTIME", "MONTH_LABEL", "PURCHASE_QTY", "COST_PRICE", "SALES_PRICE", "FOREX", "LOCAL_COST_PRICE", "LOCAL_SALES_PRICE", "PURCHASE_COST", "SALES_REVENUE", "NET_REVENUE", "STATUS", "FOREX_CURRENCY_ID", "PRICE_CURRENCY_ID", "UOM", "RECORD_STATUS", "CREATED_BY", "CREATED_DATE", "LAST_UPDATED_BY", "LAST_UPDATED_DATE", "REV_NO", "REV_TEXT") AS 
  (
    SELECT '1_MTH' SORT_ORDER,
           'N' NR_EDITABLE_IND,
           fc.object_id OBJECT_ID,
           fm.member_no MEMBER_NO,
           fms.daytime DAYTIME,
           INITCAP(TO_CHAR(fms.daytime, 'Mon')) month_label,
           fms.net_qty purchase_qty,
           fms.cost_price cost_price,
           fms.sales_price sales_price,
           fms.forex forex,
           (fms.cost_price * fms.forex) local_cost_price,
           (fms.sales_price * fms.forex) local_sales_price,
           (fms.cost_price * fms.forex * fms.net_qty) purchase_cost,
           (fms.sales_price * fms.forex * fms.net_qty) sales_revenue,
           fms.local_net_revenue net_revenue,--  (nvl(fms.cost_price,0) * nvl(fms.forex,0) * nvl(fms.net_qty,0)) + (nvl(fms.sales_price,0) * nvl(fms.forex,0) * nvl(fms.net_qty,0)) NET_REVENUE,
            fms.RECORD_STATUS status,
           fms.forex_currency_id,
           fms.price_currency_id,
           fms.uom UOM,
           fms.RECORD_STATUS,
           fms.CREATED_BY,
           fms.CREATED_DATE,
           fms.LAST_UPDATED_BY,
           fms.LAST_UPDATED_DATE,
           fms.REV_NO,
           fms.REV_TEXT
      FROM forecast fc, forecast_version fv, fcst_member fm, fcst_mth_status fms
     WHERE fc.object_id = fv.object_id
       AND fv.daytime = (SELECT MAX(fv2.daytime) FROM forecast_version fv2 WHERE fv2.object_id = fc.object_id AND fv2.daytime <= fc.start_date)
       AND fc.object_id = fm.object_id
       AND fm.member_no = fms.member_no
       AND fm.product_collection_type = 'GAS_PURCHASE'
UNION ALL
  -- Prior Year Adjustment
    SELECT '3_YR' SORT_ORDER,
           'Y' NR_EDITABLE_IND,
           fc.object_id OBJECT_ID,
           fm.member_no MEMBER_NO,
           fys.daytime DAYTIME,
           'Prior Year Adj' month_label,
           fys.net_qty purchase_qty,
           null cost_price,
           null sales_price,
           null forex,
           null local_cost_price,
           null local_sales_price,
           null purchase_cost,
           null sales_revenue,
           fys.local_net_revenue NET_REVENUE,
           NULL status,
           fys.forex_currency_id,
           fys.price_currency_id,
           fys.uom UOM,
           fys.RECORD_STATUS,
           fys.CREATED_BY,
           fys.CREATED_DATE,
           fys.LAST_UPDATED_BY,
           fys.LAST_UPDATED_DATE,
           fys.REV_NO,
           fys.REV_TEXT
      FROM forecast fc, forecast_version fv, fcst_member fm, fcst_yr_status fys
     WHERE fc.object_id = fv.object_id
       AND fv.daytime = (SELECT MAX(fv2.daytime) FROM forecast_version fv2 WHERE fv2.object_id = fc.object_id AND fv2.daytime <= fc.start_date)
       AND fc.object_id = fm.object_id
       AND fm.member_no = fys.member_no
       AND fm.product_collection_type = 'GAS_PURCHASE'
)