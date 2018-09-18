CREATE OR REPLACE FORCE EDITIONABLE VIEW "V_FCST_CARRIER_UTIL_CALC" ("DAYTIME", "FROM_DATE", "TO_DATE", "OBJECT_ID", "PRODUCT_GROUP", "FORECAST_ID", "UTILIZED", "SORT_ORDER", "RECORD_STATUS", "CREATED_BY", "CREATED_DATE", "LAST_UPDATED_BY", "LAST_UPDATED_DATE", "REV_NO", "REV_TEXT") AS 
  (SELECT distinct d_from.daytime daytime,
       d_from.daytime from_date,
       d_to.daytime to_date,
       carriers.object_id,
       carriers.product_group,
       fcst.object_id as forecast_id,
       ue_Stor_Fcst_Lift_Nom.getCarrierUtilisation(fcst.object_id, d_from.daytime, d_to.daytime, carriers.object_id) as utilized,
       carriers.sort_order,
       null as record_status,
       null as created_by,
       null as created_date,
       null as last_updated_by,
       null as last_updated_date,
       null as rev_no,
       null as rev_text
  FROM ( SELECT c.object_id, c.product_group, c.sort_order, c.daytime, c.end_date
         FROM carrier_version c) carriers,
       system_days d_from,
       system_days d_to,
       forecast fcst
 where carriers.daytime <= d_from.daytime
   and nvl(carriers.end_date, d_from.daytime +1) >= d_from.daytime)