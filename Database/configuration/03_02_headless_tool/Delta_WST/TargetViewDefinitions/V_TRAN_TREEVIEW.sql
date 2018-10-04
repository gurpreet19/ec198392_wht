CREATE OR REPLACE FORCE VIEW "V_TRAN_TREEVIEW" ("BUSINESS_UNIT_ID", "BUSINESS_UNIT_CODE", "TS_OBJECT_ID", "TS_CODE", "TS_CLASS_NAME", "TS_TREEVIEW_CLASS", "TS_NAME", "TS_DAYTIME", "TS_END_DATE", "TZ_OBJECT_ID", "TZ_CODE", "TZ_CLASS_NAME", "TZ_TREEVIEW_CLASS", "TZ_NAME", "TZ_DAYTIME", "TZ_END_DATE", "TZ_LOCATION_TYPE", "TZ_TREEVIEW_CODE", "TZ_TREEVIEW_NAME", "NP_OBJECT_ID", "NP_CODE", "NP_CLASS_NAME", "NP_NAME", "NP_DAYTIME", "NP_END_DATE", "CONTRACT_ID", "CONTRACT_CODE", "CONTRACT_AREA_ID", "NL_OBJECT_ID", "NL_CODE", "NL_CLASS_NAME", "NL_TREEVIEW_CLASS", "NL_NAME", "NL_DAYTIME", "NL_END_DATE", "OBJECT_ID", "GASDAY", "ICON", "RECORD_STATUS", "CREATED_BY", "CREATED_DATE", "LAST_UPDATED_BY", "LAST_UPDATED_DATE", "REV_NO", "REV_TEXT", "APPROVAL_STATE", "APPROVAL_BY", "APPROVAL_DATE", "REC_ID") AS 
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
       'ENRTY' as tz_location_type,
       'Entry ' || tz.object_code as tz_treeview_code,
       'Entry ' || tza.name as tz_treeview_name,
       np.object_id as np_object_id,
       np.object_code as np_code,
      'NOMINATION_POINT' as np_class_name,
       npa.name as np_name,
       npa.daytime as np_daytime,
       np.end_date as np_end_date,
       np.contract_id as contract_id,
       EC_CONTRACT.object_code(np.contract_id) as contract_code,
       ec_contract_version.contract_area_id(np.contract_id,npa.daytime) as contract_area_id,
       nl.object_id as nl_object_id,
       nl.object_code as nl_code,
       'DELIVERY_POINT' as nl_class_name,
       'LOCATION_TREEVIEW' as nl_treeview_class,
       nla.name as nl_name,
       nla.daytime as nl_daytime,
       nl.end_date as nl_end_date,
       dcv.object_id as object_id,
       dcv.daytime as gasday,
       ue_contract_capacity.getDayIconPath(dcv.object_id, dcv.daytime) as icon,
       nl.record_status as record_status,
       nl.created_by as created_by,
       nl.created_date as created_date,
       nl.last_updated_by as last_updated_by,
       nl.last_updated_date as last_updated_date,
       nl.rev_no as rev_no,
       nl.rev_text as rev_text,
       nl.approval_state as approval_state,
       nl.approval_by as approval_by,
       nl.approval_date as approval_date,
       nl.rec_id as rec_id
from   TRANSPORT_ZONE tz,
       TRAN_ZONE_VERSION tza,
       TRANSPORT_SYSTEM ts,
       TRAN_SYSTEM_VERSION tsa,
       NOMINATION_POINT np,
       NOMPNT_VERSION npa,
       DELIVERY_POINT nl,
       DELPNT_VERSION nla,
       CONTRACT_CAPACITY cc,
       CNTR_CAPACITY_VERSION cca,
       cntr_day_cap dcv
where  tz.object_id=tza.object_id
and    ts.object_id=tsa.object_id
and    nl.object_id=nla.object_id
and    np.object_id=npa.object_id
and    cc.object_id=cca.object_id
and    np.entry_location_id = nl.object_id
and    nla.entry_transport_zone_id = tz.object_id
and    tza.transport_system_id = ts.object_id
and    nl.object_id = cc.LOCATION_ID
and    np.contract_id = cc.contract_id
and    cc.object_id = dcv.object_id
and    dcv.class_name = 'TRCN_CAP_DAY_ADJUSTED'
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
       np.object_id as np_object_id,
       np.object_code as np_code,
      'NOMINATION_POINT' as np_class_name,
       npa.name as np_name,
       npa.daytime as np_daytime,
       np.end_date as np_end_date,
       np.contract_id as contract_id,
       EC_CONTRACT.object_code(np.contract_id) as contract_code,
       ec_contract_version.contract_area_id(np.contract_id,npa.daytime) as contract_area_id,
       nl.object_id as nl_object_id,
       nl.object_code as nl_code,
       'DELIVERY_POINT' as nl_class_name,
       'LOCATION_TREEVIEW' as nl_treeview_class,
       nla.name as nl_name,
       nla.daytime as nl_daytime,
       nl.end_date as nl_end_date,
       dcv.object_id as object_id,
       dcv.daytime as gasday,
       ue_contract_capacity.getDayIconPath(dcv.object_id, dcv.daytime) as icon,
       nl.record_status as record_status,
       nl.created_by as created_by,
       nl.created_date as created_date,
       nl.last_updated_by as last_updated_by,
       nl.last_updated_date as last_updated_date,
       nl.rev_no as rev_no,
       nl.rev_text as rev_text,
       nl.approval_state as approval_state,
       nl.approval_by as approval_by,
       nl.approval_date as approval_date,
       nl.rec_id as rec_id
from   TRANSPORT_ZONE tz,
       TRAN_ZONE_VERSION tza,
       TRANSPORT_SYSTEM ts,
       TRAN_SYSTEM_VERSION tsa,
       NOMINATION_POINT np,
       NOMPNT_VERSION npa,
       DELIVERY_POINT nl,
       DELPNT_VERSION nla,
       CONTRACT_CAPACITY cc,
       CNTR_CAPACITY_VERSION cca,
       cntr_day_cap dcv
where  ts.object_id=tsa.object_id
and    np.object_id=npa.object_id
and    np.exit_location_id = nl.object_id
and    nl.object_id=nla.object_id
and    cc.object_id=cca.object_id
and    nla.exit_transport_zone_id = tz.object_id
and    tz.object_id=tza.object_id
and    tza.transport_system_id = ts.object_id
and    nl.object_id = cc.LOCATION_ID
and    np.contract_id = cc.contract_id
and    cc.object_id = dcv.object_id
and    dcv.class_name = 'TRCN_CAP_DAY_ADJUSTED'
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
       np.object_id as np_object_id,
       np.object_code as np_code,
      'NOMINATION_POINT' as np_class_name,
       npa.name as np_name,
       npa.daytime as np_daytime,
       np.end_date as np_end_date,
       np.contract_id as contract_id,
       EC_CONTRACT.object_code(np.contract_id) as contract_code,
       ec_contract_version.contract_area_id(np.contract_id,npa.daytime) as contract_area_id,
       nl.object_id as nl_object_id,
       nl.object_code as nl_code,
       'DELIVERY_POINT' as nl_class_name,
       'LOCATION_TREEVIEW' as nl_treeview_class,
       nla.name as nl_name,
       nla.daytime as nl_daytime,
       nl.end_date as nl_end_date,
       dcv.object_id as object_id,
       dcv.daytime as gasday,
       ue_contract_capacity.getDayIconPath(dcv.object_id, dcv.daytime) as icon,
       nl.record_status as record_status,
       nl.created_by as created_by,
       nl.created_date as created_date,
       nl.last_updated_by as last_updated_by,
       nl.last_updated_date as last_updated_date,
       nl.rev_no as rev_no,
       nl.rev_text as rev_text,
       nl.approval_state as approval_state,
       nl.approval_by as approval_by,
       nl.approval_date as approval_date,
       nl.rec_id as rec_id
from   TRANSPORT_ZONE tz,
       TRAN_ZONE_VERSION tza,
       TRANSPORT_SYSTEM ts,
       TRAN_SYSTEM_VERSION tsa,
       NOMINATION_POINT np,
       NOMPNT_VERSION npa,
       DELIVERY_POINT nl,
       DELPNT_VERSION nla,
       CONTRACT_CAPACITY cc,
       CNTR_CAPACITY_VERSION cca,
       cntr_day_cap dcv
where  tz.object_id=tza.object_id
and    ts.object_id=tsa.object_id
and    nl.object_id=nla.object_id
and    np.object_id=npa.object_id
and    cc.object_id=cca.object_id
and    np.exit_location_id = nl.object_id
and    nla.inside_transport_zone_id = tz.object_id
and    tza.transport_system_id = ts.object_id
and    nl.object_id = cc.LOCATION_ID
and    np.contract_id = cc.contract_id
and    cc.object_id = dcv.object_id
and    dcv.class_name = 'TRCN_CAP_DAY_ADJUSTED'