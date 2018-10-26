CREATE OR REPLACE FORCE EDITIONABLE VIEW "V_FCST_GSALES_MEMBER_QTY" ("MEMBER_NO", "OBJECT_ID", "OBJECT_START_DATE", "CODE", "FIELD_ID", "FIELD_NAME", "PRODUCT_ID", "UOM", "RECORD_STATUS", "CREATED_BY", "CREATED_DATE", "LAST_UPDATED_BY", "LAST_UPDATED_DATE", "REV_NO", "REV_TEXT", "INV_OPENING_POS_QTY", "PLAN_QTY", "COMMERCIAL_ADJ_QTY", "SWAP_ADJ_QTY", "AVAIL_SALE_QTY", "INV_MOV_QTY", "SALE_QTY", "TERM_SALE_QTY", "SPOT_SALE_QTY", "INV_CLOSING_POS_QTY", "INV_CLOSING_VALUE") AS 
  (
SELECT fm.member_no,
       fc.OBJECT_ID OBJECT_ID,
       fc.start_date OBJECT_START_DATE,
       fc.object_code CODE,
       fm.field_id FIELD_ID,
       ec_field_version.name(fm.field_id, fv.daytime, '<=') FIELD_NAME,
       fm.product_id PRODUCT_ID,
       ec_fcst_mth_status.uom(fm.member_no, fc.start_date, '<=') UOM,
       'P' RECORD_STATUS,
       'NA' CREATED_BY,
       to_date('01.01.1900','DD.MM.YYYY') CREATED_DATE,
       'NA' LAST_UPDATED_BY,
       to_date('01.01.1900','DD.MM.YYYY') LAST_UPDATED_DATE,
       0 REV_NO,
       'NA' REV_TEXT,
       MAX(ecdp_revn_forecast.getOpeningPosionByMember(fm.member_no, fc.start_date, 'MONTH')) INV_OPENING_POS_QTY,
       SUM(ecdp_revn_forecast.getPlanQtyByMember(fm.member_no, fc.start_date, 'SUM_YEAR_BY_MTH')) PLAN_QTY,
       SUM(ecdp_revn_forecast.getCommAdjQtyByMember(fm.member_no, fc.start_date, 'SUM_YEAR_BY_MTH')) COMMERCIAL_ADJ_QTY,
       SUM(ecdp_revn_forecast.getSwapAdjQtyByMember(fm.member_no, fc.start_date, 'SUM_YEAR_BY_MTH')) SWAP_ADJ_QTY,
       SUM(ecdp_revn_forecast.getAvailSalesQtyByMember(fm.member_no, fc.start_date, 'SUM_YEAR_BY_MTH')) AVAIL_SALE_QTY,
       SUM(ecdp_revn_forecast.getInventoryMovQtyGSalByMember(fm.member_no, fc.start_date, 'SUM_YEAR_BY_MTH')) INV_MOV_QTY,
       SUM(ecdp_revn_forecast.getSaleQtyByMember(fm.member_no, fc.start_date, 'SUM_YEAR_BY_MTH')) SALE_QTY,
       SUM(ecdp_revn_forecast.getTermSaleQtyByMember(fm.member_no, fc.start_date, 'SUM_YEAR_BY_MTH')) TERM_SALE_QTY,
       SUM(ecdp_revn_forecast.getSpotSaleQtyByMember(fm.member_no, fc.start_date, 'SUM_YEAR_BY_MTH')) SPOT_SALE_QTY,
       MAX(ecdp_revn_forecast.getClosingPosionByMember(fm.member_no, NVL(fc.end_date, ADD_MONTHS(TRUNC(fc.start_date,'YYYY'), 12)-1), 'MONTH')) INV_CLOSING_POS_QTY,
       MAX(ecdp_revn_forecast.getClosingValueByMember(fm.member_no, NVL(fc.end_date, ADD_MONTHS(TRUNC(fc.start_date,'YYYY'), 12)-1), 'MONTH')) INV_CLOSING_VALUE
 FROM Forecast fc, Forecast_Version fv, Fcst_Member fm
WHERE fv.object_id = fc.object_id
  AND fv.daytime = (SELECT max(daytime) FROM forecast_version WHERE object_id = fv.object_id AND daytime <= fc.start_date)
  AND fm.object_id = fc.object_id
  AND fv.company_id = ec_stream_item_version.company_id(fm.stream_item_id, fc.start_date, '<=')
  AND fc.functional_area_code = 'REVENUE_FORECAST'
  AND fm.product_collection_type = 'GAS_SALES'
  GROUP BY fc.OBJECT_ID,
       fc.start_date,
       fc.object_code,
       fm.field_id,
       ec_field_version.name(fm.field_id, fv.daytime, '<='),
       fm.product_id,
       ec_fcst_mth_status.uom(fm.member_no, fc.start_date, '<='),
       fm.member_no
)