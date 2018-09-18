CREATE OR REPLACE FORCE VIEW "V_DAYLIGHT_SAVING_CHANGES" ("TIME_ZONE_REGION", "FROM_DATE_UTC", "FROM_DATE", "NEW_FROM_DATE", "OFFSET") AS 
  SELECT t.pref_verdi time_zone_region,
       daytime from_date_utc,
       ecdp_date_time.utc2local(daytime-2/24)+2/24 from_date,
       ecdp_date_time.utc2local(daytime) new_from_date,
       decode(attribute_value,0,-1,1) offset
FROM ctrl_system_attribute, t_preferanse t
WHERE  t.PREF_ID = 'TIME_ZONE_REGION'
AND attribute_type = 'UTC2LOCAL_DIFF'
UNION ALL
SELECT pdv.time_zone_region,
       d.daytime from_date_utc,
       ecdp_date_time.utc2local(d.daytime-2/24,pdv.object_id)+2/24 from_date,
       ecdp_date_time.utc2local(d.daytime,pdv.object_id) new_from_date,
       decode(d.dst_flag,0,-1,1) offset
FROM production_day_version pdv, PDAY_DST d
WHERE pdv.object_id = d.object_id
AND   d.daytime >= pdv.daytime
AND   d.daytime < Nvl(pdv.end_date,d.daytime+1)