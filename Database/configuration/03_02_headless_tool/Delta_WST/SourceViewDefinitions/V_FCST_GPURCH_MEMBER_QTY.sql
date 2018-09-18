CREATE OR REPLACE FORCE EDITIONABLE VIEW "V_FCST_GPURCH_MEMBER_QTY" ("OBJECT_ID", "OBJECT_START_DATE", "PRODUCT_ID", "CONTRACT_ID", "UOM", "CONTRACT_NAME", "PURCH_QTY", "CREATED_BY", "CREATED_DATE", "LAST_UPDATED_BY", "LAST_UPDATED_DATE", "REV_NO", "REV_TEXT", "RECORD_STATUS") AS 
  (
SELECT f.object_id OBJECT_ID,
       f.start_date OBJECT_START_DATE,
       fm.product_id PRODUCT_ID,
       fm.contract_id CONTRACT_ID,
       ec_fcst_mth_status.uom(fm.member_no, f.start_date, '<=') UOM,
       ec_contract_version.name(fm.contract_id, fv.daytime, '<=') CONTRACT_NAME,
       (sum(nvl(ec_fcst_mth_status.math_net_qty(fm.member_no,f.start_date,add_months(f.start_date, 12)),0)) +
        sum(nvl(ec_fcst_yr_status.math_net_qty(fm.member_no,f.start_date,add_months(f.start_date, 12)),0))) PURCH_QTY,
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
   AND fv.company_id = ec_contract_version.company_id(fm.contract_id, f.start_date, '<=')
   AND f.functional_area_code = 'REVENUE_FORECAST'
   AND fm.product_collection_type = 'GAS_PURCHASE'
 GROUP BY f.object_id,
          f.start_date,
          fm.product_id,
          fm.contract_id,
          ec_fcst_mth_status.uom(fm.member_no, f.start_date, '<='),
          ec_contract_version.name(fm.contract_id, fv.daytime, '<=')
)