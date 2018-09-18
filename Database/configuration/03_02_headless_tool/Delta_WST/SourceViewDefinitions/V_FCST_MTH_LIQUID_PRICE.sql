CREATE OR REPLACE FORCE EDITIONABLE VIEW "V_FCST_MTH_LIQUID_PRICE" ("OBJECT_ID", "FIELD_ID", "PRODUCT_ID", "MEMBER_NO", "DAYTIME", "BASE_PRICE", "DIFFERENTIAL", "NET_PRICE", "FOREX", "LOCAL_SPOT_PRICE", "SORT_ORDER", "UOM", "PRICE_CURRENCY_ID", "FOREX_CURRENCY_ID", "BP_EDITABLE_IND", "DF_EDITABLE_IND", "FX_EDITABLE_IND", "RECORD_STATUS", "CREATED_BY", "CREATED_DATE", "LAST_UPDATED_BY", "LAST_UPDATED_DATE", "REV_NO", "REV_TEXT") AS 
  SELECT fms.object_id,
       fm.field_id,
       fm.product_id,
       fm.member_no,
       fms.daytime,
       fms.base_price,
       fms.differential,
       fms.net_price,
       fms.forex,
       fms.local_spot_price,
       '1_MTH' sort_order,
       fms.uom UOM,
       fms.price_currency_id,
       fms.forex_currency_id,
       DECODE(ec_forecast_version.populate_method(f.object_id,f.start_date,'<='),'PLAN', 'Y',
                 DECODE(ecdp_revn_forecast.isPriorToPlanDate(f.object_id,fms.daytime),'TRUE', 'N', 'Y')) BP_EDITABLE_IND,
       DECODE(ec_forecast_version.populate_method(f.object_id,f.start_date,'<='),'PLAN', 'Y',
                 DECODE(ecdp_revn_forecast.isPriorToPlanDate(f.object_id,fms.daytime),'TRUE', 'N', 'Y')) DF_EDITABLE_IND,
       DECODE(fms.price_currency_id, fms.forex_currency_id, 'N',
             DECODE(ec_forecast_version.populate_method(f.object_id,f.start_date,'<='),'PLAN', 'Y',
                   DECODE(ecdp_revn_forecast.isPriorToPlanDate(f.object_id,fms.daytime),'TRUE', 'N', 'Y'))) FX_EDITABLE_IND,
       fms.RECORD_STATUS,
       fms.CREATED_BY,
       fms.CREATED_DATE,
       fms.LAST_UPDATED_BY,
       fms.LAST_UPDATED_DATE,
       fms.REV_NO,
       fms.REV_TEXT
  FROM forecast f, forecast_version fv, fcst_mth_status fms, fcst_member fm
 WHERE f.object_id = fv.object_id
   AND f.object_id = fm.object_id
   AND fm.member_no = fms.member_no
   AND (fm.object_id, fm.member_no) IN
       (select object_id, member_no from fcst_mth_status)
   AND fv.daytime = (SELECT max(daytime)
                       FROM forecast_version
                      WHERE object_id = fv.object_id
                        AND daytime <= f.start_date)
   AND f.functional_area_code = 'REVENUE_FORECAST'
   AND fm.product_collection_type = 'LIQUID'