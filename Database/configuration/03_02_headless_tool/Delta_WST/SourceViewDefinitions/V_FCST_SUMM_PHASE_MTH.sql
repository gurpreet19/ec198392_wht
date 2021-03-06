CREATE OR REPLACE FORCE EDITIONABLE VIEW "V_FCST_SUMM_PHASE_MTH" ("FORECAST_ID", "SCENARIO_ID", "MONTH", "PHASE_CODE", "PHASE_NAME", "SORT_ORDER", "POT_UNCONSTR", "CONSTR", "POT_CONSTR", "S1P_SHORTFALL", "S1U_SHORTFALL", "S2_SHORTFALL", "INT_CONSUMPT", "LOSSES", "COMPENSATION", "AVAIL_EXPORT", "INJ", "RECORD_STATUS", "CREATED_BY", "CREATED_DATE", "LAST_UPDATED_BY", "LAST_UPDATED_DATE", "REV_NO", "REV_TEXT") AS 
  (
----------------------------------------------------------------------------------------------------
-- File name: V_FCST_SUMM_PHASE_MTH.SQL
-- View name: V_FCST_SUMM_PHASE_MTH
--
-- $Revision: 1.3 $
--
-- Purpose  : The forecasted average monthly PHASE data
--
-- Modification history:
--
-- Date       Whom      Change description:
-- ---------- ----      --------------------------------------------------------------------------------
-- 2016-08-23 kashisag  ECPD-37329 : Initial version
-- 25.07.2018 kashisag  ECPD-56795:Updated OBJECT_ID with SCENARIO_ID
----------------------------------------------------------------------------------------------------
SELECT a.FORECAST_ID AS FORECAST_ID,
       a.SCENARIO_ID AS SCENARIO_ID,
       TRUNC(DAYTIME,'MONTH') AS MONTH,
       b.PHASE_CODE AS PHASE_CODE,
       b.PHASE_NAME AS PHASE_NAME,
       b.SORT_ORDER AS SORT_ORDER,
       AVG(a.OIL_POT_UNCONSTR) AS POT_UNCONSTR,
       AVG(a.OIL_CONSTRAINTS) AS CONSTR,
       AVG(a.OIL_POT_CONSTR) AS POT_CONSTR,
       AVG(a.OIL_S1P_SHORTFALL) AS S1P_SHORTFALL,
       AVG(a.OIL_S1U_SHORTFALL) AS S1U_SHORTFALL,
       AVG(a.OIL_S2_SHORTFALL) AS S2_SHORTFALL,
       AVG(a.OIL_INT_CONSUMPT) AS INT_CONSUMPT,
       AVG(a.OIL_LOSSES) AS LOSSES,
       AVG(a.OIL_COMPENSATION) AS COMPENSATION,
       AVG(a.OIL_AVAIL_EXPORT) AS AVAIL_EXPORT,
       NULL AS INJ,
       NULL AS RECORD_STATUS,
       NULL AS CREATED_BY,
       NULL AS CREATED_DATE,
       NULL AS LAST_UPDATED_BY,
       NULL AS LAST_UPDATED_DATE,
       NULL AS REV_NO,
       NULL AS REV_TEXT
FROM FCST_SUMMARY_DAY a, V_FCST_SUMM_PHASES b
WHERE b.PHASE_CODE = 'OIL'
GROUP BY a.FORECAST_ID, a.SCENARIO_ID,TRUNC(DAYTIME,'MONTH'),PHASE_CODE,PHASE_NAME,SORT_ORDER
UNION ALL
SELECT a.FORECAST_ID AS FORECAST_ID,
       a.SCENARIO_ID AS SCENARIO_ID,
       TRUNC(DAYTIME,'MONTH') AS MONTH,
       b.PHASE_CODE AS PHASE_CODE,
       b.PHASE_NAME AS PHASE_NAME,
       b.SORT_ORDER AS SORT_ORDER,
       AVG(a.GAS_POT_UNCONSTR) AS POT_UNCONSTR,
       AVG(a.GAS_CONSTRAINTS) AS CONSTR,
       AVG(a.GAS_POT_CONSTR) AS POT_CONSTR,
       AVG(a.GAS_S1P_SHORTFALL) AS S1P_SHORTFALL,
       AVG(a.GAS_S1U_SHORTFALL) AS S1U_SHORTFALL,
       AVG(a.GAS_S2_SHORTFALL) AS S2_SHORTFALL,
       AVG(a.GAS_INT_CONSUMPT) AS INT_CONSUMPT,
       AVG(a.GAS_LOSSES) AS LOSSES,
       AVG(a.GAS_COMPENSATION) AS COMPENSATION,
       AVG(a.GAS_AVAIL_EXPORT) AS AVAIL_EXPORT,
       NULL AS INJ,
       NULL AS RECORD_STATUS,
       NULL AS CREATED_BY,
       NULL AS CREATED_DATE,
       NULL AS LAST_UPDATED_BY,
       NULL AS LAST_UPDATED_DATE,
       NULL AS REV_NO,
       NULL AS REV_TEXT
FROM FCST_SUMMARY_DAY a, V_FCST_SUMM_PHASES b
WHERE b.PHASE_CODE = 'GAS'
GROUP BY a.FORECAST_ID, a.SCENARIO_ID,TRUNC(DAYTIME,'MONTH'),PHASE_CODE,PHASE_NAME,SORT_ORDER
UNION ALL
SELECT a.FORECAST_ID AS FORECAST_ID,
       a.SCENARIO_ID AS SCENARIO_ID,
       TRUNC(DAYTIME,'MONTH') AS MONTH,
       b.PHASE_CODE AS PHASE_CODE,
       b.PHASE_NAME AS PHASE_NAME,
       b.SORT_ORDER AS SORT_ORDER,
       AVG(a.WAT_POT_UNCONSTR) AS POT_UNCONSTR,
       AVG(a.WAT_CONSTRAINTS) AS CONSTR,
       AVG(a.WAT_POT_CONSTR) AS POT_CONSTR,
       AVG(a.WAT_S1P_SHORTFALL) AS S1P_SHORTFALL,
       AVG(a.WAT_S1U_SHORTFALL) AS S1U_SHORTFALL,
       AVG(a.WAT_S2_SHORTFALL) AS S2_SHORTFALL,
       AVG(a.WAT_INT_CONSUMPT) AS INT_CONSUMPT,
       AVG(a.WAT_LOSSES) AS LOSSES,
       AVG(a.WAT_COMPENSATION) AS COMPENSATION,
       NULL AS AVAIL_EXPORT,
       NULL AS INJ,
       NULL AS RECORD_STATUS,
       NULL AS CREATED_BY,
       NULL AS CREATED_DATE,
       NULL AS LAST_UPDATED_BY,
       NULL AS LAST_UPDATED_DATE,
       NULL AS REV_NO,
       NULL AS REV_TEXT
FROM FCST_SUMMARY_DAY a, V_FCST_SUMM_PHASES b
WHERE b.PHASE_CODE = 'WAT'
GROUP BY a.FORECAST_ID, a.SCENARIO_ID,TRUNC(DAYTIME,'MONTH'),PHASE_CODE,PHASE_NAME,SORT_ORDER
UNION ALL
SELECT a.FORECAST_ID AS FORECAST_ID,
       a.SCENARIO_ID AS SCENARIO_ID,
       TRUNC(DAYTIME,'MONTH') AS MONTH,
       b.PHASE_CODE AS PHASE_CODE,
       b.PHASE_NAME AS PHASE_NAME,
       b.SORT_ORDER AS SORT_ORDER,
       AVG(a.COND_POT_UNCONSTR) AS POT_UNCONSTR,
       AVG(a.COND_CONSTRAINTS) AS CONSTR,
       AVG(a.COND_POT_CONSTR) AS POT_CONSTR,
       AVG(a.COND_S1P_SHORTFALL) AS S1P_SHORTFALL,
       AVG(a.COND_S1U_SHORTFALL) AS S1U_SHORTFALL,
       AVG(a.COND_S2_SHORTFALL) AS S2_SHORTFALL,
       AVG(a.COND_INT_CONSUMPT) AS INT_CONSUMPT,
       AVG(a.COND_LOSSES) AS LOSSES,
       AVG(a.COND_COMPENSATION) AS COMPENSATION,
       AVG(a.COND_AVAIL_EXPORT) AS AVAIL_EXPORT,
       NULL AS INJ,
       NULL AS RECORD_STATUS,
       NULL AS CREATED_BY,
       NULL AS CREATED_DATE,
       NULL AS LAST_UPDATED_BY,
       NULL AS LAST_UPDATED_DATE,
       NULL AS REV_NO,
       NULL AS REV_TEXT
FROM FCST_SUMMARY_DAY a, V_FCST_SUMM_PHASES b
WHERE b.PHASE_CODE = 'COND'
GROUP BY a.FORECAST_ID, a.SCENARIO_ID,TRUNC(DAYTIME,'MONTH'),PHASE_CODE,PHASE_NAME,SORT_ORDER
UNION ALL
SELECT a.FORECAST_ID AS FORECAST_ID,
       a.SCENARIO_ID AS SCENARIO_ID,
       TRUNC(DAYTIME,'MONTH') AS MONTH,
       b.PHASE_CODE AS PHASE_CODE,
       b.PHASE_NAME AS PHASE_NAME,
       b.SORT_ORDER AS SORT_ORDER,
       AVG(a.GL_POT_UNCONSTR) AS POT_UNCONSTR,
       AVG(a.GL_CONSTRAINTS) AS CONSTR,
       AVG(a.GL_POT_CONSTR) AS POT_CONSTR,
       AVG(a.GL_S1P_SHORTFALL) AS S1P_SHORTFALL,
       AVG(a.GL_S1U_SHORTFALL) AS S1U_SHORTFALL,
       AVG(a.GL_S2_SHORTFALL) AS S2_SHORTFALL,
       NULL AS INT_CONSUMPT,
       AVG(a.GL_LOSSES) AS LOSSES,
       AVG(a.GL_COMPENSATION) AS COMPENSATION,
       NULL AS AVAIL_EXPORT,
       NULL AS INJ,
       NULL AS RECORD_STATUS,
       NULL AS CREATED_BY,
       NULL AS CREATED_DATE,
       NULL AS LAST_UPDATED_BY,
       NULL AS LAST_UPDATED_DATE,
       NULL AS REV_NO,
       NULL AS REV_TEXT
FROM FCST_SUMMARY_DAY a, V_FCST_SUMM_PHASES b
WHERE b.PHASE_CODE = 'GL'
GROUP BY a.FORECAST_ID, a.SCENARIO_ID,TRUNC(DAYTIME,'MONTH'),PHASE_CODE,PHASE_NAME,SORT_ORDER
UNION ALL
SELECT a.FORECAST_ID AS FORECAST_ID,
       a.SCENARIO_ID AS SCENARIO_ID,
       TRUNC(DAYTIME,'MONTH') AS MONTH,
       b.PHASE_CODE AS PHASE_CODE,
       b.PHASE_NAME AS PHASE_NAME,
       b.SORT_ORDER AS SORT_ORDER,
       AVG(a.DL_POT_UNCONSTR) AS POT_UNCONSTR,
       AVG(a.DL_CONSTRAINTS) AS CONSTR,
       AVG(a.DL_POT_CONSTR) AS POT_CONSTR,
       AVG(a.DL_S1P_SHORTFALL) AS S1P_SHORTFALL,
       AVG(a.DL_S1U_SHORTFALL) AS S1U_SHORTFALL,
       AVG(a.DL_S2_SHORTFALL) AS S2_SHORTFALL,
       NULL AS INT_CONSUMPT,
       AVG(a.DL_LOSSES) AS LOSSES,
       AVG(a.DL_COMPENSATION) AS COMPENSATION,
       NULL AS AVAIL_EXPORT,
       NULL AS INJ,
       NULL AS RECORD_STATUS,
       NULL AS CREATED_BY,
       NULL AS CREATED_DATE,
       NULL AS LAST_UPDATED_BY,
       NULL AS LAST_UPDATED_DATE,
       NULL AS REV_NO,
       NULL AS REV_TEXT
FROM FCST_SUMMARY_DAY a, V_FCST_SUMM_PHASES b
WHERE b.PHASE_CODE = 'DL'
GROUP BY a.FORECAST_ID, a.SCENARIO_ID,TRUNC(DAYTIME,'MONTH'),PHASE_CODE,PHASE_NAME,SORT_ORDER
UNION ALL
SELECT a.FORECAST_ID AS FORECAST_ID,
       a.SCENARIO_ID AS SCENARIO_ID,
       TRUNC(DAYTIME,'MONTH') AS MONTH,
       b.PHASE_CODE AS PHASE_CODE,
       b.PHASE_NAME AS PHASE_NAME,
       b.SORT_ORDER AS SORT_ORDER,
       AVG(a.WI_POT_UNCONSTR) AS POT_UNCONSTR,
       AVG(a.WI_CONSTRAINTS) AS CONSTR,
       AVG(a.WI_POT_CONSTR) AS POT_CONSTR,
       AVG(a.WI_S1P_SHORTFALL) AS S1P_SHORTFALL,
       AVG(a.WI_S1U_SHORTFALL) AS S1U_SHORTFALL,
       AVG(a.WI_S2_SHORTFALL) AS S2_SHORTFALL,
       NULL AS INT_CONSUMPT,
       AVG(a.WI_LOSSES) AS LOSSES,
       AVG(a.WI_COMPENSATION) AS COMPENSATION,
       NULL AS AVAIL_EXPORT,
       AVG(a.WAT_INJ) AS INJ,
       NULL AS RECORD_STATUS,
       NULL AS CREATED_BY,
       NULL AS CREATED_DATE,
       NULL AS LAST_UPDATED_BY,
       NULL AS LAST_UPDATED_DATE,
       NULL AS REV_NO,
       NULL AS REV_TEXT
FROM FCST_SUMMARY_DAY a, V_FCST_SUMM_PHASES b
WHERE b.PHASE_CODE = 'WI'
GROUP BY a.FORECAST_ID, a.SCENARIO_ID,TRUNC(DAYTIME,'MONTH'),PHASE_CODE,PHASE_NAME,SORT_ORDER
UNION ALL
SELECT a.FORECAST_ID AS FORECAST_ID,
       a.SCENARIO_ID AS SCENARIO_ID,
       TRUNC(DAYTIME,'MONTH') AS MONTH,
       b.PHASE_CODE AS PHASE_CODE,
       b.PHASE_NAME AS PHASE_NAME,
       b.SORT_ORDER AS SORT_ORDER,
       AVG(a.GI_POT_UNCONSTR) AS POT_UNCONSTR,
       AVG(a.GI_CONSTRAINTS) AS CONSTR,
       AVG(a.GI_POT_CONSTR) AS POT_CONSTR,
       AVG(a.GI_S1P_SHORTFALL) AS S1P_SHORTFALL,
       AVG(a.GI_S1U_SHORTFALL) AS S1U_SHORTFALL,
       AVG(a.GI_S2_SHORTFALL) AS S2_SHORTFALL,
       NULL AS INT_CONSUMPT,
       AVG(a.GI_LOSSES) AS LOSSES,
       AVG(a.GI_COMPENSATION) AS COMPENSATION,
       NULL AS AVAIL_EXPORT,
       AVG(a.GAS_INJ) AS INJ,
       NULL AS RECORD_STATUS,
       NULL AS CREATED_BY,
       NULL AS CREATED_DATE,
       NULL AS LAST_UPDATED_BY,
       NULL AS LAST_UPDATED_DATE,
       NULL AS REV_NO,
       NULL AS REV_TEXT
FROM FCST_SUMMARY_DAY a, V_FCST_SUMM_PHASES b
WHERE b.PHASE_CODE = 'GI'
GROUP BY a.FORECAST_ID, a.SCENARIO_ID,TRUNC(DAYTIME,'MONTH'),PHASE_CODE,PHASE_NAME,SORT_ORDER
UNION ALL
SELECT a.FORECAST_ID AS FORECAST_ID,
       a.SCENARIO_ID AS SCENARIO_ID,
       TRUNC(DAYTIME,'MONTH') AS MONTH,
       b.PHASE_CODE AS PHASE_CODE,
       b.PHASE_NAME AS PHASE_NAME,
       b.SORT_ORDER AS SORT_ORDER,
       AVG(a.SI_POT_UNCONSTR) AS POT_UNCONSTR,
       AVG(a.SI_CONSTRAINTS) AS CONSTR,
       AVG(a.SI_POT_CONSTR) AS POT_CONSTR,
       AVG(a.SI_S1P_SHORTFALL) AS S1P_SHORTFALL,
       AVG(a.SI_S1U_SHORTFALL) AS S1U_SHORTFALL,
       AVG(a.SI_S2_SHORTFALL) AS S2_SHORTFALL,
       NULL AS INT_CONSUMPT,
       AVG(a.SI_LOSSES) AS LOSSES,
       AVG(a.SI_COMPENSATION) AS COMPENSATION,
       NULL AS AVAIL_EXPORT,
       AVG(a.STEAM_INJ) AS INJ,
       NULL AS RECORD_STATUS,
       NULL AS CREATED_BY,
       NULL AS CREATED_DATE,
       NULL AS LAST_UPDATED_BY,
       NULL AS LAST_UPDATED_DATE,
       NULL AS REV_NO,
       NULL AS REV_TEXT
FROM FCST_SUMMARY_DAY a, V_FCST_SUMM_PHASES b
WHERE b.PHASE_CODE = 'SI'
GROUP BY a.FORECAST_ID, a.SCENARIO_ID,TRUNC(DAYTIME,'MONTH'),PHASE_CODE,PHASE_NAME,SORT_ORDER
UNION ALL
SELECT a.FORECAST_ID AS FORECAST_ID,
       a.SCENARIO_ID AS SCENARIO_ID,
       TRUNC(DAYTIME,'MONTH') AS MONTH,
       b.PHASE_CODE AS PHASE_CODE,
       b.PHASE_NAME AS PHASE_NAME,
       b.SORT_ORDER AS SORT_ORDER,
       AVG(a.CI_POT_UNCONSTR) AS POT_UNCONSTR,
       AVG(a.CI_CONSTRAINTS) AS CONSTR,
       AVG(a.CI_POT_CONSTR) AS POT_CONSTR,
       AVG(a.CI_S1P_SHORTFALL) AS S1P_SHORTFALL,
       AVG(a.CI_S1U_SHORTFALL) AS S1U_SHORTFALL,
       AVG(a.CI_S2_SHORTFALL) AS S2_SHORTFALL,
       NULL AS INT_CONSUMPT,
       AVG(a.CI_LOSSES) AS LOSSES,
       AVG(a.CI_COMPENSATION) AS COMPENSATION,
       NULL AS AVAIL_EXPORT,
       AVG(a.CO2_INJ) AS INJ,
       NULL AS RECORD_STATUS,
       NULL AS CREATED_BY,
       NULL AS CREATED_DATE,
       NULL AS LAST_UPDATED_BY,
       NULL AS LAST_UPDATED_DATE,
       NULL AS REV_NO,
       NULL AS REV_TEXT
FROM FCST_SUMMARY_DAY a, V_FCST_SUMM_PHASES b
WHERE b.PHASE_CODE = 'CI'
GROUP BY a.FORECAST_ID, a.SCENARIO_ID,TRUNC(DAYTIME,'MONTH'),PHASE_CODE,PHASE_NAME,SORT_ORDER
)