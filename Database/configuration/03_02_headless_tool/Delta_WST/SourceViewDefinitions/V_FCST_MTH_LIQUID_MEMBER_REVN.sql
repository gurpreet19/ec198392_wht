CREATE OR REPLACE FORCE EDITIONABLE VIEW "V_FCST_MTH_LIQUID_MEMBER_REVN" ("SORT_ORDER", "PA_EDITABLE_IND", "VA_EDITABLE_IND", "OBJECT_ID", "MEMBER_NO", "DAYTIME", "MONTH_LABEL", "SALE_QTY", "NET_PRICE", "FOREX", "LOCAL_PRICE", "GROSS_REVENUE", "PCT_ADJ_PRICE", "VALUE_ADJ_PRICE", "NET_REVENUE", "STATUS", "FOREX_CURRENCY_ID", "PRICE_CURRENCY_ID", "UOM", "RECORD_STATUS", "CREATED_BY", "CREATED_DATE", "LAST_UPDATED_BY", "LAST_UPDATED_DATE", "REV_NO", "REV_TEXT") AS 
  (
    SELECT '1_MTH' SORT_ORDER,
           DECODE(ec_fcst_product_setup.pct_adj_ind(fc.object_id, fm.product_id, fm.product_context, fm.product_collection_type), 'Y',
                 DECODE(ec_forecast_version.populate_method(fc.object_id,fc.start_date,'<='),'PLAN', 'Y',
                       DECODE(ecdp_revn_forecast.isPriorToPlanDate(fc.object_id,fms.daytime),'TRUE', 'N', 'Y')), 'N') PA_EDITABLE_IND,
           DECODE(ec_forecast_version.populate_method(fc.object_id,fc.start_date,'<='),'PLAN', 'Y',
                 DECODE(ecdp_revn_forecast.isPriorToPlanDate(fc.object_id,fms.daytime),'TRUE', 'N', 'Y')) VA_EDITABLE_IND,
           fc.object_id OBJECT_ID,
           fm.member_no MEMBER_NO,
           fms.daytime DAYTIME,
           INITCAP(TO_CHAR(fms.daytime, 'Mon')) month_label,
           fms.sale_qty,
           fms.net_price net_price,
           fms.forex forex,
           fms.local_spot_price local_price,
           fms.local_gross_revenue gross_revenue,
           fms.pct_adj_price pct_adj_price,
           fms.value_adj_price value_adj_price,
           fms.local_net_revenue net_revenue,
           DECODE(fms.RECORD_STATUS, 'P', 'PROVISIONAL', 'V', 'VERIFIED', 'APPROVED') status,
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
       AND fm.product_collection_type = 'LIQUID'
UNION ALL
  -- Prior Year Adjustment
    SELECT '3_YR' SORT_ORDER,
           'N' PA_EDITABLE_IND,
           'N' VA_EDITABLE_IND,
           fc.object_id OBJECT_ID,
           fm.member_no MEMBER_NO,
           fys.daytime DAYTIME,
           'Prior Year Adj' month_label,
           fys.sale_qty,
           null net_price,
           null forex,
           null local_price,
           fys.local_gross_revenue gross_revenue,
           null pct_adj_price,
           fys.value_adj_price value_adj_price,
           fys.local_net_revenue net_revenue,
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
       AND fm.product_collection_type = 'LIQUID'
)