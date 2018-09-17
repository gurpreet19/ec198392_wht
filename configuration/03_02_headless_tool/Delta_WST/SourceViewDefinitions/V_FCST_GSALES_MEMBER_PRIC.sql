CREATE OR REPLACE FORCE EDITIONABLE VIEW "V_FCST_GSALES_MEMBER_PRIC" ("OBJECT_ID", "NAME", "FIELD_ID", "PRODUCT_ID", "PRICE_CURRENCY_ID", "FOREX_CURRENCY_ID", "UOM", "TERM_PRICE", "SPOT_PRICE", "FOREX", "LOCAL_TERM_PRICE", "LOCAL_SPOT_PRICE", "CREATED_BY", "CREATED_DATE", "LAST_UPDATED_BY", "LAST_UPDATED_DATE", "REV_NO", "REV_TEXT", "RECORD_STATUS") AS 
  SELECT f.object_id,
       fv.name,
       fm.field_id,
       fm.product_id,
       ec_fcst_mth_status.price_currency_id(fm.member_no, f.start_date, '<=') PRICE_CURRENCY_ID,
       ec_fcst_mth_status.forex_currency_id(fm.member_no, f.start_date, '<=') FOREX_CURRENCY_ID,
       ec_fcst_mth_status.uom(fm.member_no, f.start_date, '<=') UOM,
       ec_fcst_mth_status.math_term_price(fm.member_no,f.start_date,add_months(f.start_date, 12),'AVG') term_price,
       ec_fcst_mth_status.math_spot_price(fm.member_no,f.start_date,add_months(f.start_date, 12),'AVG') spot_price,
       avg(ec_fcst_mth_status.math_forex(fm.member_no,f.start_date,add_months(f.start_date, 12),'AVG')) forex,
       ec_fcst_mth_status.math_local_term_price(fm.member_no,f.start_date,add_months(f.start_date, 12),'AVG') local_term_price,
       ec_fcst_mth_status.math_local_spot_price(fm.member_no,f.start_date,add_months(f.start_date, 12),'AVG') local_spot_price,
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
 GROUP BY f.object_id,
          fv.name,
          f.start_date,
          f.object_code,
          fm.field_id,
          fm.product_id,
          fm.member_no,
          ec_fcst_mth_status.price_currency_id(fm.member_no, f.start_date, '<='),
          ec_fcst_mth_status.forex_currency_id(fm.member_no, f.start_date, '<='),
          ec_fcst_mth_status.uom(fm.member_no, f.start_date, '<=')