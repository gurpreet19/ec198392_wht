CREATE OR REPLACE FORCE EDITIONABLE VIEW "V_DASH_REVN_QTY" ("DAYTIME", "DAYTIME_CHAR", "STREAM_ITEM_CATEGORY_CODE", "STREAM_ITEM_CATEGORY_NAME", "BBLS15", "BBLS", "MSCF", "MNM3", "MSM3", "MV", "UST", "USTV", "MTV", "MJ100", "THERMS", "KWH", "BOE", "COMPANY_ID", "STREAM_ITEM_CATEGORY_ID", "PRODUCT_ID", "DASH_HEADER", "RECORD_STATUS", "CREATED_BY", "CREATED_DATE", "LAST_UPDATED_BY", "LAST_UPDATED_DATE", "REV_NO", "REV_TEXT", "APPROVAL_STATE", "APPROVAL_DATE", "APPROVAL_BY", "REC_ID") AS 
  select
  si.daytime as DAYTIME,
  to_char(si.daytime, 'Mon YYYY') as DAYTIME_CHAR,
  ec_stream_category.object_code(ec_stream_item_version.stream_item_category_id(max(si.object_id),si.daytime,'<=')) as stream_item_category_code,
  ec_stream_category_version.name(ec_stream_item_version.stream_item_category_id(max(si.object_id), si.daytime, '<='),si.daytime, '<=') as stream_item_category_name,
  sum(nvl(si.net_volume_bi,0)) as BBLS15,
  sum(nvl(si.net_volume_bm,0)) as BBLS,
  sum(nvl(si.net_volume_sf,0)) as MSCF,
  sum(nvl(si.net_volume_nm,0)) as MNM3,
  sum(nvl(si.net_volume_sm,0)) as MSM3,
  sum(nvl(si.net_mass_ma,0)) as MV,
  sum(nvl(si.net_mass_ua,0)) as UST,
  sum(nvl(si.net_mass_uv,0)) as USTV,
  sum(nvl(si.net_mass_mv,0)) as MTV,
  sum(nvl(si.net_energy_jo,0)) as MJ100,
  sum(nvl(si.net_energy_th,0)) as THERMS,
  sum(nvl(si.net_energy_wh,0)) as KWH,
  sum(nvl(si.net_energy_be,0)) as BOE,
  siv.company_id as company_id,
  ec_stream_item_version.stream_item_category_id(max(si.object_id), si.daytime, '<=') as stream_item_category_id,
  siv.product_id as product_id,
  'Actual Quantities by Month for Company/Product '''
            ||max(ec_company_version.name(siv.company_id,si.daytime,'<='))
            ||''''
            ||'/'''
            ||max(ec_product_version.name(siv.product_id,si.daytime,'<='))
            ||'''' as DASH_HEADER,
   max(si.RECORD_STATUS) as RECORD_STATUS,
   max(si.CREATED_BY) as CREATED_BY,
   max(si.CREATED_DATE) as CREATED_DATE,
   max(si.LAST_UPDATED_BY) as LAST_UPDATED_BY,
   max(si.LAST_UPDATED_DATE) as LAST_UPDATED_DATE,
   max(si.REV_NO) as REV_NO,
   max(si.REV_TEXT) as REV_TEXT,
   max(si.approval_state) as APPROVAL_STATE,
   max(si.approval_date) as APPROVAL_DATE,
   max(si.approval_by) as APPROVAL_BY,
   max(si.rec_id) as REC_ID
from stim_mth_actual si, stream_item_version siv
where si.object_id = siv.object_id
and siv.reporting_category = 0 --unique Stream Items
and siv.field_id <> ec_field.object_id_by_uk('SUM','FIELD')
group by si.daytime, company_id, product_id, stream_item_category_id
order by si.daytime, stream_item_category_code