CREATE OR REPLACE FORCE EDITIONABLE VIEW "V_WELL_DAY_ALLOC" ("OBJECT_ID", "DAYTIME", "WELL_NAME", "WELL_TYPE", "ALLOC_NET_OIL_VOL", "ALLOC_COND_VOL", "ALLOC_GAS_VOL", "ALLOC_WATER_VOL", "ALLOC_GAS_INJ_VOL", "ALLOC_WATER_INJ_VOL", "ALLOC_STEAM_INJ_VOL", "ALLOC_NET_OIL_MASS", "ALLOC_COND_MASS", "ALLOC_GAS_MASS", "ALLOC_WATER_MASS", "ALLOC_GAS_INJ_MASS", "ALLOC_STEAM_INJ_MASS", "RECORD_STATUS", "CREATED_BY", "CREATED_DATE", "LAST_UPDATED_BY", "LAST_UPDATED_DATE", "REV_NO", "REV_TEXT") AS 
  (
  ----------------------------------------------------------------------------------------------------
  -- File name: V_WELL_DAY_ALLOC.SQL
  -- View name: V_WELL_DAY_ALLOC
  --
  --
  -- Purpose  : Purpose of this view is to fetch columns from PWEL_DAY_ALLOC and IWEL_DAY_ALLOC tables
  --
  -- Modification history:
  --
  -- Date       Whom      Change description:
  -- ---------- ----      --------------------------------------------------------------------------------
  -- 2018-08-28 rainanid  ECPD-55788 : Initial version
  ----------------------------------------------------------------------------------------------------
  select wv.object_id object_id,
    coalesce(pw.daytime,iw.daytime) daytime,
    name well_name,
    well_type,
    alloc_net_oil_vol,
    alloc_cond_vol,
    alloc_gas_vol,
    alloc_water_vol,
    decode(iw.inj_type,'GI',ec_iwel_day_alloc.alloc_inj_vol(iw.object_id,iw.daytime ,iw.inj_type)) alloc_gas_inj_vol,
    decode(iw.inj_type,'WI',ec_iwel_day_alloc.alloc_inj_vol(iw.object_id,iw.daytime,iw.inj_type)) alloc_water_inj_vol,
    decode(iw.inj_type,'SI',ec_iwel_day_alloc.alloc_inj_vol(iw.object_id,iw.daytime, iw.inj_type)) alloc_steam_inj_vol,
    alloc_net_oil_mass,
    alloc_cond_mass,
    alloc_gas_mass,
    alloc_water_mass,
    decode(iw.inj_type,'GI',ec_iwel_day_alloc.alloc_inj_mass(iw.object_id,iw.daytime,iw.inj_type)) alloc_gas_inj_mass,
    decode(iw.inj_type,'SI',ec_iwel_day_alloc.alloc_inj_mass(iw.object_id,iw.daytime,iw.inj_type)) alloc_steam_inj_mass,
    coalesce(pw.record_status,iw.record_status) record_status,
    coalesce(pw.created_by,iw.created_by) created_by,
    coalesce(pw.created_date,iw.created_date) created_date,
    coalesce(pw.last_updated_by,iw.last_updated_by) last_updated_by,
    coalesce(pw.last_updated_date,iw.last_updated_date) last_updated_date,
    coalesce(pw.rev_no,iw.rev_no) rev_no,
    coalesce(pw.rev_text,iw.rev_text) rev_text
  from well_version wv
  left outer join pwel_day_alloc pw
  on (wv.object_id =pw.object_id
  and  pw.daytime >= wv.daytime
  and pw.daytime < nvl(wv.end_date,pw.daytime + 1))
  left outer join iwel_day_alloc iw
  on (wv.object_id =iw.object_id
  and  iw.daytime >= wv.daytime
  and iw.daytime < nvl(wv.end_date,iw.daytime + 1))
  where coalesce(pw.daytime,iw.daytime) is not null
)