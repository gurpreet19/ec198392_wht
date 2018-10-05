CREATE OR REPLACE FORCE EDITIONABLE VIEW "V_FCST_GSALES_MEMBER_REVN" ("OBJECT_ID", "FIELD_ID", "PRODUCT_ID", "UOM", "TERM_SALE_QTY", "SPOT_SALE_QTY", "TERM_PRICE", "SPOT_PRICE", "FOREX", "LOCAL_TERM_PRICE", "LOCAL_SPOT_PRICE", "GROSS_REVENUE", "PCT_ADJ_PRICE", "VALUE_ADJ_PRICE", "NET_REVENUE", "STATUS", "MEMBER_NO", "FORECAST_SCOPE", "FOREX_CURRENCY_ID", "PRICE_CURRENCY_ID", "SORT_ORDER", "CREATED_BY", "CREATED_DATE", "LAST_UPDATED_BY", "LAST_UPDATED_DATE", "REV_NO", "REV_TEXT", "RECORD_STATUS") AS 
  SELECT f.object_id,
       fm.field_id,
       fm.product_id,
       ec_fcst_mth_status.uom(fm.member_no, f.start_date, '<=') UOM,
       (nvl(ec_fcst_mth_status.math_term_sale_qty(fm.member_no,f.start_date,add_months(f.start_date, 12)),0) +
        nvl(ec_fcst_yr_status.math_term_sale_qty(fm.member_no,TRUNC(f.start_date,'YYYY'),TRUNC(f.start_date,'YYYY')),0)) term_sale_qty,
       ec_fcst_mth_status.math_spot_sale_qty(fm.member_no,f.start_date,add_months(f.start_date, 12)) spot_sale_qty,
       ec_fcst_mth_status.math_term_price(fm.member_no,f.start_date,add_months(f.start_date, 12), 'AVG') term_price,
       ec_fcst_mth_status.math_spot_price(fm.member_no,f.start_date,add_months(f.start_date, 12), 'AVG') spot_price,
       ec_fcst_mth_status.math_forex(fm.member_no,f.start_date,add_months(f.start_date, 12),'AVG') forex,
       ec_fcst_mth_status.math_local_term_price(fm.member_no,f.start_date,add_months(f.start_date, 12),'AVG') local_term_price,
       ec_fcst_mth_status.math_local_spot_price(fm.member_no,f.start_date,add_months(f.start_date, 12),'AVG') local_spot_price,
       ec_fcst_mth_status.math_local_gross_revenue(fm.member_no,f.start_date,add_months(f.start_date, 12)) gross_revenue,
       ec_fcst_mth_status.math_pct_adj_price(fm.member_no,f.start_date,add_months(f.start_date, 12),'AVG') pct_adj_price,
       (nvl(ec_fcst_mth_status.math_value_adj_price(fm.member_no,f.start_date,add_months(f.start_date, 12)),0) +
        nvl(ec_fcst_yr_status.math_value_adj_price(fm.member_no,TRUNC(f.start_date,'YYYY'),TRUNC(f.start_date,'YYYY')),0)) value_adj_price,
       (nvl(ec_fcst_mth_status.math_local_net_revenue(fm.member_no,f.start_date,add_months(f.start_date, 12)),0) +
        nvl(ec_fcst_yr_status.math_local_net_revenue(fm.member_no,TRUNC(f.start_date,'YYYY'),TRUNC(f.start_date,'YYYY')),0)) net_revenue,
       ecdp_revn_forecast.getAllStatusRevn(fm.object_id, fm.member_no) status,
       fm.member_no,
       fv.forecast_scope,
       ec_fcst_mth_status.forex_currency_id(fm.member_no, f.start_date, '<=') FOREX_CURRENCY_ID,
       ec_fcst_mth_status.price_currency_id(fm.member_no, f.start_date, '<=') PRICE_CURRENCY_ID,
       '1_FLD' SORT_ORDER,
       'n/a' created_by,
       to_date('01.01.1900', 'DD.MM.YYYY') created_date,
       'n/a' last_updated_by,
       to_date('01.01.1900', 'DD.MM.YYYY') last_updated_date,
       0 rev_no,
       'n/a' rev_text,
       'P' record_status
  FROM forecast f, forecast_version fv, fcst_member fm
 WHERE f.object_id = fv.object_id
   AND f.object_id = fm.object_id
   AND fv.daytime = (SELECT max(daytime)
                       FROM forecast_version
                      WHERE object_id = fv.object_id
                        AND daytime <= f.start_date)
   AND fv.company_id = ec_stream_item_version.company_id(fm.stream_item_id, f.start_date, '<=')
   AND f.functional_area_code = 'REVENUE_FORECAST'
   AND fm.product_collection_type = 'GAS_SALES'