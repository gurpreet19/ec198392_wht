CREATE OR REPLACE FORCE EDITIONABLE VIEW "V_FCST_SUMM_REASON" ("REASON_CODE_1", "FROM_MONTH", "TO_MONTH", "FORECAST_ID", "OBJECT_ID", "OIL_LOSS_VOLUME", "GAS_LOSS_VOLUME", "COND_LOSS_VOLUME", "WATER_LOSS_VOLUME", "WATER_INJ_LOSS_VOLUME", "STEAM_INJ_LOSS_VOLUME", "GAS_INJ_LOSS_VOLUME", "DILUENT_LOSS_VOLUME", "GAS_LIFT_LOSS_VOLUME", "CO2_INJ_LOSS_VOLUME", "RECORD_STATUS", "CREATED_BY", "CREATED_DATE", "LAST_UPDATED_BY", "LAST_UPDATED_DATE", "REV_NO", "REV_TEXT") AS 
  WITH mth_count AS (SELECT
      MONTHS_BETWEEN(MAX(TRUNC(end_date,'MONTH')),MIN(TRUNC(start_date,'MONTH'))) AS mth,MIN(TRUNC(start_date,'MONTH')) min_dt
      FROM forecast WHERE class_name='FORECAST_PROD' )
SELECT we.reason_code_1  AS REASON_CODE_1,
       m1.mth from_month,
       m2.mth to_month,
       we.forecast_id,
       we.object_id,
       SUM(wec.deferred_net_oil_vol) AS OIL_LOSS_VOLUME,
       SUM(wec.deferred_gas_vol) AS GAS_LOSS_VOLUME,
       SUM(wec.deferred_cond_vol) AS COND_LOSS_VOLUME,
       SUM(wec.deferred_water_vol) AS WATER_LOSS_VOLUME,
       SUM(wec.deferred_water_inj_vol) AS WATER_INJ_LOSS_VOLUME,
       SUM(wec.deferred_steam_inj_vol) AS STEAM_INJ_LOSS_VOLUME,
       SUM(wec.deferred_gas_inj_vol) AS GAS_INJ_LOSS_VOLUME,
       SUM(wec.deferred_diluent_vol) AS DILUENT_LOSS_VOLUME,
       SUM(wec.deferred_gl_vol) AS GAS_LIFT_LOSS_VOLUME,
       SUM(wec.deferred_co2_inj_vol) AS CO2_INJ_LOSS_VOLUME,
       NULL AS RECORD_STATUS,
       NULL AS CREATED_BY,
       NULL AS CREATED_DATE,
       NULL AS LAST_UPDATED_BY,
       NULL AS LAST_UPDATED_DATE,
       NULL AS REV_NO,
       NULL AS REV_TEXT
FROM
       FCST_WELL_EVENT we,
       FCST_WELL_EVENT_ALLOC wec,
       (select add_months(mth_count.min_dt, LEVEL-1) AS mth FROM ctrl_db_version,mth_count
       WHERE DB_VERSION=1 connect by LEVEL <= mth_count.mth+12) m1,
       (select add_months(mth_count.min_dt, LEVEL-1) AS mth FROM ctrl_db_version,mth_count
       WHERE DB_VERSION=1 connect by LEVEL <= mth_count.mth+12) m2
WHERE
       we.reason_code_1 IS NOT NULL
AND    we.event_no=wec.event_no
AND   TRUNC(wec.daytime, 'MONTH') BETWEEN m1.mth and m2.mth
GROUP BY we.reason_code_1 ,
         we.forecast_id,
         we.object_id,
         m1.mth,
         m2.mth