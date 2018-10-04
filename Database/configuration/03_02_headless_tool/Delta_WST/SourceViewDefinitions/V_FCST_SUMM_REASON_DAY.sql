CREATE OR REPLACE FORCE EDITIONABLE VIEW "V_FCST_SUMM_REASON_DAY" ("REASON_CODE_1", "DAYTIME", "FORECAST_ID", "OBJECT_ID", "OIL_LOSS_VOLUME", "GAS_LOSS_VOLUME", "COND_LOSS_VOLUME", "WATER_LOSS_VOLUME", "WATER_INJ_LOSS_VOLUME", "STEAM_INJ_LOSS_VOLUME", "GAS_INJ_LOSS_VOLUME", "DILUENT_LOSS_VOLUME", "GAS_LIFT_LOSS_VOLUME", "CO2_INJ_LOSS_VOLUME", "RECORD_STATUS", "CREATED_BY", "CREATED_DATE", "LAST_UPDATED_BY", "LAST_UPDATED_DATE", "REV_NO", "REV_TEXT") AS 
  (
----------------------------------------------------------------------------------------------------
-- File name: v_fcst_summ_reason_day.sql
-- View name: V_FCST_SUMM_REASON_DAY
--
-- $Revision: 1.0 $
--
-- Purpose  : Aggregate the monthly records of FCST_WELL_EVENT by Reason code
--
-- Modification history:
--
-- Date       Whom       Change description:
-- ---------- ----       --------------------------------------------------------------------------------
-- 30.08.2016 jainnraj   ECPD-37327:Intial version
-- 02.09.2016 jainnraj   ECPD-37327:Changed REASON_CODE to REASON_CODE_1
-- 13.09.2016 jainnraj   ECPD-37327:Removed grouping from transformer and Added groups in view
-- 22.09.2016 jainnraj   ECPD-37327:Removed ec_prosty_codes WELL_DT_REASON_CODE
-- 23.09.2016 jainnraj   ECPD-39068:Added support for C02
----------------------------------------------------------------------------------------------------
SELECT we.reason_code_1  AS REASON_CODE_1,
       TRUNC(wec.daytime) AS DAYTIME,
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
       FCST_WELL_EVENT_ALLOC wec
WHERE
       we.reason_code_1 IS NOT NULL
AND    we.event_no=wec.event_no
GROUP BY
         we.reason_code_1 ,
          TRUNC(wec.daytime),
          we.forecast_id,
          we.object_id
)