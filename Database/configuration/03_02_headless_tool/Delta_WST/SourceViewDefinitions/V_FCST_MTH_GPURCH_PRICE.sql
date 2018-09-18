CREATE OR REPLACE FORCE EDITIONABLE VIEW "V_FCST_MTH_GPURCH_PRICE" ("OBJECT_ID", "CONTRACT_ID", "PRODUCT_ID", "DAYTIME", "COST_PRICE", "SALES_PRICE", "FOREX", "MEMBER_NO", "SORT_ORDER", "UOM", "PRICE_CURRENCY_ID", "FOREX_CURRENCY_ID", "CP_EDITABLE_IND", "SP_EDITABLE_IND", "FX_EDITABLE_IND", "RECORD_STATUS", "CREATED_BY", "CREATED_DATE", "LAST_UPDATED_BY", "LAST_UPDATED_DATE", "REV_NO", "REV_TEXT") AS 
  SELECT fms.object_id,
       fm.contract_id,
       fm.product_id,
       fms.daytime,
       fms.cost_price,
       fms.sales_price,
       fms.forex,
       fms.member_no,
       '1_MTH' sort_order,
       fms.uom UOM,
       fms.price_currency_id,
       fms.forex_currency_id,
       DECODE(ec_forecast_version.populate_method(f.object_id,f.start_date,'<='),'PLAN', 'Y',
                 DECODE(ecdp_revn_forecast.isPriorToPlanDate(f.object_id,fms.daytime),'TRUE', 'N', 'Y')) CP_EDITABLE_IND,
       DECODE(ec_forecast_version.populate_method(f.object_id,f.start_date,'<='),'PLAN', 'Y',
                 DECODE(ecdp_revn_forecast.isPriorToPlanDate(f.object_id,fms.daytime),'TRUE', 'N', 'Y')) SP_EDITABLE_IND,
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
   AND fm.product_collection_type = 'GAS_PURCHASE'