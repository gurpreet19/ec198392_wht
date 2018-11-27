CREATE OR REPLACE FORCE EDITIONABLE VIEW "V_FCST_CARRIER_CHART" ("DAYTIME", "CHART_START_DATE", "CHART_END_DATE", "OBJECT_ID", "FORECAST_ID", "DETAIL_CODE", "COLOR_CODE", "CLASS", "PRODUCT_GROUP", "PARCEL_NO", "CARRIER_NAME", "CARGO_NO", "ROUTE_DAYS", "CARRIER_SORT_ORDER", "PORT_ID", "NOMINATED_QTY", "NOM_OBJECT_ID", "RECORD_STATUS", "CREATED_BY", "CREATED_DATE", "LAST_UPDATED_BY", "LAST_UPDATED_DATE", "REV_NO", "REV_TEXT") AS 
  ( SELECT r.start_date AS daytime,
       r.start_date AS chart_start_date,
       r.end_date as chart_end_date,
       r.object_id,
       r.forecast_id as forecast_id,
       'MAINTENANCE' as detail_code,
       ec_prosty_codes.alt_code('MAINTENANCE', 'CARRIER_AVAIL_DETAIL') AS COLOR_CODE,
        'FCST_OPRES_PERIOD_RESTR' class,
       ec_carrier_version.product_group(c.object_id, r.start_date,'<=') as product_group,
       null as parcel_no,
       ecdp_objects.GetObjName(r.object_id,r.start_date) as carrier_name,
       null as cargo_no,
       null as route_days,
       ec_carrier_version.sort_order(c.object_id, r.start_date, '<=') carrier_sort_order,
       NULL as port_id,
       NULL as nominated_qty,
       r.object_id as nom_object_id,
       r.record_status as record_status,
       r.created_by as created_by,
       r.created_date as created_date,
       r.last_updated_by as last_updated_by,
       r.last_updated_date as last_updated_date,
       r.rev_no as rev_no,
       r.rev_text as rev_text
  from fcst_oploc_period_restr r, carrier c, forecast f
 where r.forecast_id = f.object_id
   and r.object_id = c.object_id
   and f.start_date >= c.start_date
   and c.start_date <= r.start_date
   and r.start_date >= f.start_date
   and r.end_date < f.end_date
UNION
select s.nom_firm_date as daytime,
       s.nom_firm_date AS chart_start_date,
       s.nom_firm_date+NVL(NVL(EcDp_Carrier_Fcst.getRouteDays(s.carrier_id, s.nom_firm_date, s.object_id, s.port_id),0),0) as  chart_end_date,
       c.object_id,
       s.forecast_id forecast_id,
       'EN ROUTE' as detail_code,
       null as color_code,
       'CARRIER_PORT_ACC' CLASS,
       ec_carrier_version.product_group(c.object_id, s.nom_firm_date,'<=') as product_group,
       s.parcel_no,
       ecdp_objects.GetObjName(c.object_id,s.nom_firm_date) as carrier_name,
       s.cargo_no,
       NVL(EcDp_Carrier_Fcst.getRouteDays(s.carrier_id, s.nom_firm_date, s.object_id, s.port_id),0) as route_days,
       ec_carrier_version.sort_order(s.carrier_id, s.nom_firm_date, '<=') carrier_sort_order,
       s.port_id as port_id,
       s.grs_vol_nominated as nominated_qty,
       s.object_id as nom_object_id,
       s.record_status as record_status,
       s.created_by as created_by,
       s.created_date as created_date,
       s.last_updated_by as last_updated_by,
       s.last_updated_date as last_updated_date,
       s.rev_no as rev_no,
       s.rev_text as rev_text
  from stor_fcst_lift_nom s, forecast f, carrier c
 where s.carrier_id = c.object_id
   and s.forecast_id = f.object_id
UNION
select s.nom_firm_date as daytime,
       s.nom_firm_date+NVL(EcDp_Carrier_Fcst.getRouteDays(s.carrier_id, s.nom_firm_date, s.object_id, s.port_id),0)+1 AS chart_start_date,
       s.nom_firm_date+NVL(EcDp_Carrier_Fcst.getRouteDays(s.carrier_id, s.nom_firm_date, s.object_id, s.port_id),0)+1 as  chart_end_date,
       c.object_id,
       s.forecast_id forecast_id,
       'UNLOADING' as detail_code,
       null as color_code,
       'CARRIER_PORT_ACC' CLASS,
       ec_carrier_version.product_group(c.object_id, s.nom_firm_date,'<=') as product_group,
       s.parcel_no,
       ecdp_objects.GetObjName(c.object_id,s.nom_firm_date) as carrier_name,
       s.cargo_no,
       NVL(EcDp_Carrier_Fcst.getRouteDays(s.carrier_id, s.nom_firm_date, s.object_id, s.port_id),0) as route_days,
       ec_carrier_version.sort_order(s.carrier_id, s.nom_firm_date, '<=') carrier_sort_order,
       s.port_id as port_id,
       s.grs_vol_nominated as nominated_qty,
       s.object_id as nom_object_id,
       s.record_status as record_status,
       s.created_by as created_by,
       s.created_date as created_date,
       s.last_updated_by as last_updated_by,
       s.last_updated_date as last_updated_date,
       s.rev_no as rev_no,
       s.rev_text as rev_text
  from stor_fcst_lift_nom s, forecast f, carrier c
 where s.carrier_id = c.object_id
   and s.forecast_id = f.object_id
UNION
select s.nom_firm_date as daytime,
       s.nom_firm_date+NVL(EcDp_Carrier_Fcst.getRouteDays(s.carrier_id, s.nom_firm_date, s.object_id, s.port_id),0)+2 AS chart_start_date,
       s.nom_firm_date+NVL(EcDp_Carrier_Fcst.getRouteDays(s.carrier_id, s.nom_firm_date, s.object_id, s.port_id),0)+2 as  chart_end_date,
       c.object_id,
       s.forecast_id forecast_id,
       'RETURN' as detail_code,
       null as color_code,
       'CARRIER_PORT_ACC' CLASS,
       ec_carrier_version.product_group(c.object_id, s.nom_firm_date,'<=') as product_group,
       s.parcel_no,
       ecdp_objects.GetObjName(c.object_id,s.nom_firm_date) as carrier_name,
       s.cargo_no,
       NVL(EcDp_Carrier_Fcst.getRouteDays(s.carrier_id, s.nom_firm_date, s.object_id, s.port_id),0) as route_days,
       ec_carrier_version.sort_order(s.carrier_id, s.nom_firm_date, '<=') carrier_sort_order,
       s.port_id as port_id,
       s.grs_vol_nominated as nominated_qty,
       s.object_id as nom_object_id,
       s.record_status as record_status,
       s.created_by as created_by,
       s.created_date as created_date,
       s.last_updated_by as last_updated_by,
       s.last_updated_date as last_updated_date,
       s.rev_no as rev_no,
       s.rev_text as rev_text
  from stor_fcst_lift_nom s, forecast f, carrier c
 where s.carrier_id = c.object_id
   and s.forecast_id = f.object_id
   )