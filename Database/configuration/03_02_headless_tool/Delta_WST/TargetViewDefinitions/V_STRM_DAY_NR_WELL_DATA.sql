CREATE OR REPLACE FORCE VIEW "V_STRM_DAY_NR_WELL_DATA" ("OBJECT_ID", "DAYTIME", "DAILY_RELEASE", "NON_ROU_REL_OVERRIDE", "WELL_ID", "WELL_VOL_NR_OVERRIDE", "WELL_VOL_DAILY_RELEASE", "CREATED_BY", "CREATED_DATE", "LAST_UPDATED_BY", "LAST_UPDATED_DATE", "RECORD_STATUS", "REV_NO", "REV_TEXT") AS 
  (
-------------------------------------------------------------------------------------
--  V_STRM_DAY_NR_WELL_DATA
--
--  $Revision: 1.4.2.3 $
--
--  Purpose: Calcualte the well share of the non routine vent and flare using the well potential
--
-- Modification history:
--
-- Date       Whom     Change description:
-- ---------- -------- --------------------------------------------------------------------------------
-- 13.06.2012 choonshu Modified to improve performance
-- 10.09.2012 leongwen ECPD-21939: Fixed the error causes the incorrect value in WELL_VOL_NR_OVERRIDE attribute, added the optimer hint to use INDEX_JOIN,
--                                 fixed the column names in sequence of (object_id, daytime, asset_id, start_daytime) to utilize indexes supports in GROUP BY and WHERE CLAUSE(s).
-------------------------------------------------------------------------------------
SELECT object_id, daytime,
	sum(daily_release) daily_release,
	sum(non_rou_rel_override) non_rou_rel_override,
	well_id,
	sum(well_vol_nr_override) well_vol_nr_override,
	sum(well_vol_daily_release) well_vol_daily_release,
	TO_CHAR(NULL) created_by,
  TO_DATE(NULL) created_date,
  TO_CHAR(NULL) last_updated_by,
  TO_DATE(NULL) last_updated_date,
  'P' record_status,
  0 rev_no,
  TO_CHAR(NULL) rev_text
  from (
	SELECT /*+ INDEX_JOIN(w I_STRM_DAY_ASSET_WELL_DATA_1 s I_STRM_DAY_ASSET_DATA_1 t I_STRM_DAY_ASSET_WELL_DATA_1) */
       s.object_id,
       s.daytime,
       sum(s.daily_release) daily_release,
       sum(s.non_rou_rel_override) non_rou_rel_override,
       w.well_id,
       sum(s.non_rou_rel_override * ecbp_stream_ventflare.calcWellContrib(w.object_id, w.class_name, w.daytime, w.asset_id, w.start_daytime, w.well_id) /
           t.total_well_contrib) well_vol_nr_override,
       sum(s.daily_release * ecbp_stream_ventflare.calcWellContrib(w.object_id, w.class_name, w.daytime, w.asset_id, w.start_daytime, w.well_id) /
           t.total_well_contrib) well_vol_daily_release,
       TO_CHAR(NULL) created_by,
       TO_DATE(NULL) created_date,
       TO_CHAR(NULL) last_updated_by,
       TO_DATE(NULL) last_updated_date,
       'P' record_status,
       0 rev_no,
       TO_CHAR(NULL) rev_text
	FROM STRM_DAY_ASSET_WELL_DATA w,
       STRM_DAY_ASSET_DATA S,
       (SELECT w1.object_id,
               w1.daytime,
               w1.asset_id,
               w1.start_daytime,
               sum(ecbp_stream_ventflare.calcWellContrib(w1.object_id, w1.class_name, w1.daytime, w1.asset_id, w1.start_daytime, w1.well_id)) total_well_contrib
        FROM STRM_DAY_ASSET_WELL_DATA w1
        GROUP BY w1.object_id, w1.daytime, w1.asset_id, w1.start_daytime) T
	WHERE w.object_id = s.object_id
	   AND w.daytime = s.daytime
     AND w.asset_id = s.asset_id
	   AND w.start_daytime = s.start_daytime
	   AND w.object_id = t.object_id
	   AND w.daytime = t.daytime
	   AND w.asset_id = t.asset_id
	   AND w.start_daytime = t.start_daytime
	GROUP BY s.object_id, s.daytime, w.well_id
	union all
	SELECT
		STRM_DAY_ASSET_DATA.OBJECT_ID AS OBJECT_ID,
		STRM_DAY_ASSET_DATA.DAYTIME AS DAYTIME,
		ecbp_stream_ventflare.calcWellContrib(STRM_DAY_ASSET_DATA.OBJECT_ID, STRM_DAY_ASSET_DATA.CLASS_NAME,STRM_DAY_ASSET_DATA.DAYTIME,STRM_DAY_ASSET_DATA.ASSET_ID,		   STRM_DAY_ASSET_DATA.START_DAYTIME, STRM_DAY_ASSET_DATA.ASSET_ID) AS daily_release,
		STRM_DAY_ASSET_DATA.NON_ROU_REL_OVERRIDE as non_rou_rel_override,
		STRM_DAY_ASSET_DATA.asset_id as well_id,
		nvl(NON_ROU_REL_OVERRIDE,ecbp_stream_ventflare.calcWellContrib(STRM_DAY_ASSET_DATA.OBJECT_ID, STRM_DAY_ASSET_DATA.CLASS_NAME,STRM_DAY_ASSET_DATA.DAYTIME,  		 STRM_DAY_ASSET_DATA.ASSET_ID,STRM_DAY_ASSET_DATA.START_DAYTIME, STRM_DAY_ASSET_DATA.ASSET_ID)) well_vol_daily_release,
		STRM_DAY_ASSET_DATA.non_rou_rel_override as well_vol_nr_override,
		STRM_DAY_ASSET_DATA.CREATED_BY AS CREATED_BY,
		STRM_DAY_ASSET_DATA.CREATED_DATE AS CREATED_DATE,
		STRM_DAY_ASSET_DATA.LAST_UPDATED_BY AS LAST_UPDATED_BY,
		STRM_DAY_ASSET_DATA.LAST_UPDATED_DATE AS LAST_UPDATED_DATE,
		STRM_DAY_ASSET_DATA.RECORD_STATUS AS RECORD_STATUS,
		STRM_DAY_ASSET_DATA.REV_NO AS REV_NO,
		STRM_DAY_ASSET_DATA.REV_TEXT AS REV_TEXT
	FROM STRM_DAY_ASSET_DATA, STRM_VERSION oa, STREAM o
	WHERE STRM_DAY_ASSET_DATA.object_id = oa.object_id
		AND oa.object_id = o.object_id
		AND STRM_DAY_ASSET_DATA.daytime >= oa.daytime
		AND STRM_DAY_ASSET_DATA.daytime < nvl(oa.end_date,STRM_DAY_ASSET_DATA.daytime + 1)
		AND STRM_DAY_ASSET_DATA.CLASS_NAME='STRM_DAY_NR_WELL')
GROUP BY object_id, daytime, well_id)