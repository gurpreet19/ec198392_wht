CREATE OR REPLACE FORCE EDITIONABLE VIEW "V_DAYLIGHT_SAVING_CHANGES" ("TIME_ZONE_REGION", "FROM_DATE_UTC", "FROM_DATE", "NEW_FROM_DATE", "OFFSET") AS 
  WITH config AS -- base configuration
 (SELECT pref_verdi time_zone,
         TO_DATE('2000-01-01', 'YYYY-MM-DD') from_daytime,
         TRUNC(SYSDATE, 'yy') + 6 * 365 - 1/24 to_daytime
    FROM t_preferanse
   WHERE pref_id = 'TIME_ZONE_REGION'
 UNION ALL SELECT time_zone_region,
         TO_DATE('2000-01-01', 'YYYY-MM-DD'),
         TRUNC(SYSDATE, 'yy') + 6 * 365 - 1/24
       FROM production_day_version
       WHERE time_zone_region IS NOT NULL
 ),
date_cte AS -- CTE to find all days between from_daytime - to_daytime
 (SELECT from_daytime + ROWNUM -1 daytime
    FROM config
    CONNECT BY ROWNUM <= to_daytime - from_daytime),
dst_sub AS -- date, utc offset, and next-day utc_offset
 (SELECT g.time_zone, daytime,
         TO_NUMBER(TO_CHAR(FROM_TZ(CAST(daytime AS TIMESTAMP), g.time_zone),
                           'TZH')) +
         TO_NUMBER(TO_CHAR(FROM_TZ(CAST(daytime AS TIMESTAMP), g.time_zone),
                           'TZM')) / 60 offset,
         TO_NUMBER(TO_CHAR(FROM_TZ(CAST(daytime + 1 AS TIMESTAMP), g.time_zone),
                           'TZH')) +
         TO_NUMBER(TO_CHAR(FROM_TZ(CAST(daytime + 1 AS TIMESTAMP), g.time_zone),
                           'TZM')) / 60 next_offset
    FROM date_cte t, config g ),
main_sub AS  -- main query with time_zone, date where switch happens, offsets, and time when dst switch happen
 (SELECT config.time_zone,
         daytime,
         Ecdp_Timestamp_Utils.getDSTTime(config.time_zone, daytime) dst_switch,
         offset,
         next_offset
    FROM dst_sub INNER JOIN config ON dst_sub.time_zone = config.time_zone
   WHERE offset <> next_offset
   ORDER BY daytime)
-- special query when dst not observed
SELECT time_zone time_zone_region,
       TO_DATE('2000-01-01', 'yyyy-mm-dd') from_date_utc,
       TO_DATE('2000-01-01', 'yyyy-mm-dd') from_date,
       TO_DATE('2000-01-01', 'yyyy-mm-dd') new_from_date,
       -1 offset
  FROM config
 WHERE 0 = (SELECT COUNT(1) FROM dst_sub WHERE dst_sub.time_zone = config.time_zone AND offset <> next_offset)
UNION ALL
SELECT time_zone,
       dst_switch,
       dst_switch + offset/24,
       CAST(FROM_TZ(CAST(dst_switch AS TIMESTAMP), 'UTC') AT TIME ZONE time_zone AS DATE),
       next_offset - offset
  FROM main_sub