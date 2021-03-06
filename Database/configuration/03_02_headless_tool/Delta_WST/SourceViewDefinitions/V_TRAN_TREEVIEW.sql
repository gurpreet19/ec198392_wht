CREATE OR REPLACE FORCE EDITIONABLE VIEW "V_TRAN_TREEVIEW" ("BUSINESS_UNIT_ID", "BUSINESS_UNIT_CODE", "TS_OBJECT_ID", "TS_CODE", "TS_CLASS_NAME", "TS_TREEVIEW_CLASS", "TS_NAME", "TS_DAYTIME", "TS_END_DATE", "TZ_OBJECT_ID", "TZ_CODE", "TZ_CLASS_NAME", "TZ_TREEVIEW_CLASS", "TZ_NAME", "TZ_DAYTIME", "TZ_END_DATE", "TZ_LOCATION_TYPE", "TZ_TREEVIEW_CODE", "TZ_TREEVIEW_NAME", "TZ_SORT_NAME", "CONTRACT_ID", "NL_OBJECT_ID", "NL_CODE", "NL_CLASS_NAME", "NL_TREEVIEW_CLASS", "NL_NAME", "NL_DAYTIME", "NL_END_DATE", "OBJECT_ID", "GASDAY", "ICON", "RECORD_STATUS", "CREATED_BY", "CREATED_DATE", "LAST_UPDATED_BY", "LAST_UPDATED_DATE", "REV_NO", "REV_TEXT", "APPROVAL_STATE", "APPROVAL_BY", "APPROVAL_DATE", "REC_ID") AS 
  select tsa.business_unit_id as business_unit_id,
       EC_BUSINESS_UNIT.object_code(tsa.business_unit_id) as business_unit_code,
       ts.object_id as ts_object_id,
       ts.object_code as ts_code,
       'TRANSPORT_SYSTEM' as ts_class_name,
       'TRAN_SYSTEM_TREEVIEW' as ts_treeview_class,
       tsa.name as ts_name,
       tsa.daytime as ts_daytime,
       ts.end_date as ts_end_date,
       tz.object_id as tz_object_id,
       tz.object_code as tz_code,
       'TRANSPORT_ZONE' as tz_class_name,
       'TRAN_ZONE_TREEVIEW' as tz_treeview_class,
       tza.name as tz_name,
       tza.daytime as tz_daytime,
       tz.end_date as tz_end_date,
       'ENTRY' as tz_location_type,
       'Entry ' || tz.object_code as tz_treeview_code,
       'Entry ' || tza.name as tz_treeview_name,
	   tza.name || 1 as tz_sort_name,
       cc.contract_id as contract_id,
       nl.object_id as nl_object_id,
       nl.code as nl_code,
       'NOMINATION_LOCATION' as nl_class_name,
       'LOCATION_TREEVIEW' as nl_treeview_class,
       nl.name as nl_name,
       nl.daytime as nl_daytime,
       nl.end_date as nl_end_date,
       dcv.object_id as object_id,
       dcv.daytime as gasday,
       ue_contract_capacity.getDayIconPath(dcv.object_id, dcv.daytime, NVL(dcv.vol_qty, NVL(dcv.mass_qty, dcv.energy_qty))) as icon,
       dcv.record_status as record_status,
       dcv.created_by as created_by,
       dcv.created_date as created_date,
       dcv.last_updated_by as last_updated_by,
       dcv.last_updated_date as last_updated_date,
       dcv.rev_no as rev_no,
       dcv.rev_text as rev_text,
       dcv.approval_state as approval_state,
       dcv.approval_by as approval_by,
       dcv.approval_date as approval_date,
       dcv.rec_id as rec_id
from   TRANSPORT_ZONE tz,
       TRAN_ZONE_VERSION tza,
       TRANSPORT_SYSTEM ts,
       TRAN_SYSTEM_VERSION tsa,
       iv_nomination_location nl,
       CONTRACT_CAPACITY cc,
       cntr_day_cap dcv
where  tz.object_id=tza.object_id
and    ts.object_id=tsa.object_id
and    nl.entry_transport_zone_id = tz.object_id
and    tza.transport_system_id = ts.object_id
and    nl.object_id = cc.LOCATION_ID
and    cc.object_id = dcv.object_id
and    dcv.class_name = 'TRCN_DAY_CAP'
union all
select tsa.business_unit_id as business_unit_id,
       EC_BUSINESS_UNIT.object_code(tsa.business_unit_id) as business_unit_code,
       ts.object_id as ts_object_id,
       ts.object_code as ts_code,
       'TRANSPORT_SYSTEM' as ts_class_name,
       'TRAN_SYSTEM_TREEVIEW' as ts_treeview_class,
       tsa.name as ts_name,
       tsa.daytime as ts_daytime,
       ts.end_date as ts_end_date,
       tz.object_id as tz_object_id,
       tz.object_code as tz_code,
       'TRANSPORT_ZONE' as tz_class_name,
       'TRAN_ZONE_TREEVIEW' as tz_treeview_class,
       tza.name as tz_name,
       tza.daytime as tz_daytime,
       tz.end_date as tz_end_date,
       'EXIT' as tz_location_type,
       'Exit ' || tz.object_code as tz_treeview_code,
       'Exit ' || tza.name as tz_treeview_name,
	   tza.name || 3 as tz_sort_name,
       cc.contract_id as contract_id,
       nl.object_id as nl_object_id,
       nl.code as nl_code,
       'NOMINATION_LOCATION' as nl_class_name,
       'LOCATION_TREEVIEW' as nl_treeview_class,
       nl.name as nl_name,
       nl.daytime as nl_daytime,
       nl.end_date as nl_end_date,
       dcv.object_id as object_id,
       dcv.daytime as gasday,
       ue_contract_capacity.getDayIconPath(dcv.object_id, dcv.daytime, NVL(dcv.vol_qty, NVL(dcv.mass_qty, dcv.energy_qty))) as icon,
       dcv.record_status as record_status,
       dcv.created_by as created_by,
       dcv.created_date as created_date,
       dcv.last_updated_by as last_updated_by,
       dcv.last_updated_date as last_updated_date,
       dcv.rev_no as rev_no,
       dcv.rev_text as rev_text,
       dcv.approval_state as approval_state,
       dcv.approval_by as approval_by,
       dcv.approval_date as approval_date,
       dcv.rec_id as rec_id
from   TRANSPORT_ZONE tz,
       TRAN_ZONE_VERSION tza,
       TRANSPORT_SYSTEM ts,
       TRAN_SYSTEM_VERSION tsa,
       iv_nomination_location nl,
       CONTRACT_CAPACITY cc,
       cntr_day_cap dcv
where  ts.object_id=tsa.object_id
and    nl.exit_transport_zone_id = tz.object_id
and    tz.object_id=tza.object_id
and    tza.transport_system_id = ts.object_id
and    nl.object_id = cc.LOCATION_ID
and    cc.object_id = dcv.object_id
and    dcv.class_name = 'TRCN_DAY_CAP'
union all
select tsa.business_unit_id as business_unit_id,
       EC_BUSINESS_UNIT.object_code(tsa.business_unit_id) as business_unit_code,
       ts.object_id as ts_object_id,
       ts.object_code as ts_code,
       'TRANSPORT_SYSTEM' as ts_class_name,
       'TRAN_SYSTEM_TREEVIEW' as ts_treeview_class,
       tsa.name as ts_name,
       tsa.daytime as ts_daytime,
       ts.end_date as ts_end_date,
       tz.object_id as tz_object_id,
       tz.object_code as tz_code,
       'TRANSPORT_ZONE' as tz_class_name,
       'TRAN_ZONE_TREEVIEW' as tz_treeview_class,
       tza.name as tz_name,
       tza.daytime as tz_daytime,
       tz.end_date as tz_end_date,
       'INSIDE' as tz_location_type,
       'Inside ' || tz.object_code as tz_treeview_code,
       'Inside ' || tza.name as tz_treeview_name,
	   tza.name || 2 as tz_sort_name,
       cc.contract_id as contract_id,
       nl.object_id as nl_object_id,
       nl.code as nl_code,
       'NOMINATION_LOCATION' as nl_class_name,
       'LOCATION_TREEVIEW' as nl_treeview_class,
       nl.name as nl_name,
       nl.daytime as nl_daytime,
       nl.end_date as nl_end_date,
       dcv.object_id as object_id,
       dcv.daytime as gasday,
       ue_contract_capacity.getDayIconPath(dcv.object_id, dcv.daytime, NVL(dcv.vol_qty, NVL(dcv.mass_qty, dcv.energy_qty))) as icon,
       dcv.record_status as record_status,
       dcv.created_by as created_by,
       dcv.created_date as created_date,
       dcv.last_updated_by as last_updated_by,
       dcv.last_updated_date as last_updated_date,
       dcv.rev_no as rev_no,
       dcv.rev_text as rev_text,
       dcv.approval_state as approval_state,
       dcv.approval_by as approval_by,
       dcv.approval_date as approval_date,
       dcv.rec_id as rec_id
from   TRANSPORT_ZONE tz,
       TRAN_ZONE_VERSION tza,
       TRANSPORT_SYSTEM ts,
       TRAN_SYSTEM_VERSION tsa,
       iv_nomination_location nl,
       CONTRACT_CAPACITY cc,
       cntr_day_cap dcv
where  tz.object_id=tza.object_id
and    ts.object_id=tsa.object_id
and    nl.inside_transport_zone_id = tz.object_id
and    tza.transport_system_id = ts.object_id
and    nl.object_id = cc.LOCATION_ID
and    cc.object_id = dcv.object_id
and    dcv.class_name = 'TRCN_DAY_CAP'