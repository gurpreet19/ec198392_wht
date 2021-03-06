CREATE OR REPLACE FORCE EDITIONABLE VIEW "V_FCST_SUMM_PHASE_DAY" ("FORECAST_ID", "SCENARIO_ID", "DAYTIME", "PHASE_CODE", "PHASE_NAME", "SORT_ORDER", "POT_UNCONSTR", "CONSTR", "POT_CONSTR", "S1P_SHORTFALL", "S1U_SHORTFALL", "S2_SHORTFALL", "INT_CONSUMPT", "LOSSES", "COMPENSATION", "AVAIL_EXPORT", "INJ", "RECORD_STATUS", "CREATED_BY", "CREATED_DATE", "LAST_UPDATED_BY", "LAST_UPDATED_DATE", "REV_NO", "REV_TEXT") AS 
  (
----------------------------------------------------------------------------------------------------
-- File name: V_FCST_SUMM_PHASE_DAY.SQL
-- View name: V_FCST_SUMM_PHASE_DAY
--
-- $Revision: 1.3 $
--
-- Purpose  : The forecasted daily PHASE data
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
       a.DAYTIME AS DAYTIME,
       b.PHASE_CODE AS PHASE_CODE,
       b.PHASE_NAME AS PHASE_NAME,
       b.SORT_ORDER AS SORT_ORDER,
       a.OIL_POT_UNCONSTR AS POT_UNCONSTR,
       a.OIL_CONSTRAINTS AS CONSTR,
       a.OIL_POT_CONSTR AS POT_CONSTR,
       a.OIL_S1P_SHORTFALL AS S1P_SHORTFALL,
       a.OIL_S1U_SHORTFALL AS S1U_SHORTFALL,
       a.OIL_S2_SHORTFALL AS S2_SHORTFALL,
       a.OIL_INT_CONSUMPT AS INT_CONSUMPT,
       a.OIL_LOSSES AS LOSSES,
       a.OIL_COMPENSATION AS COMPENSATION,
       a.OIL_AVAIL_EXPORT AS AVAIL_EXPORT,
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
UNION ALL
SELECT a.FORECAST_ID AS FORECAST_ID,
       a.SCENARIO_ID AS SCENARIO_ID,
       a.DAYTIME AS DAYTIME,
       b.PHASE_CODE AS PHASE_CODE,
       b.PHASE_NAME AS PHASE_NAME,
       b.SORT_ORDER AS SORT_ORDER,
       a.GAS_POT_UNCONSTR AS POT_UNCONSTR,
       a.GAS_CONSTRAINTS AS CONSTR,
       a.GAS_POT_CONSTR AS POT_CONSTR,
       a.GAS_S1P_SHORTFALL AS S1P_SHORTFALL,
       a.GAS_S1U_SHORTFALL AS S1U_SHORTFALL,
       a.GAS_S2_SHORTFALL AS S2_SHORTFALL,
       a.GAS_INT_CONSUMPT AS INT_CONSUMPT,
       a.GAS_LOSSES AS LOSSES,
       a.GAS_COMPENSATION AS COMPENSATION,
       a.GAS_AVAIL_EXPORT AS AVAIL_EXPORT,
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
UNION ALL
SELECT a.FORECAST_ID AS FORECAST_ID,
       a.SCENARIO_ID AS SCENARIO_ID,
       a.DAYTIME AS DAYTIME,
       b.PHASE_CODE AS PHASE_CODE,
       b.PHASE_NAME AS PHASE_NAME,
       b.SORT_ORDER AS SORT_ORDER,
       a.WAT_POT_UNCONSTR AS POT_UNCONSTR,
       a.WAT_CONSTRAINTS AS CONSTR,
       a.WAT_POT_CONSTR AS POT_CONSTR,
       a.WAT_S1P_SHORTFALL AS S1P_SHORTFALL,
       a.WAT_S1U_SHORTFALL AS S1U_SHORTFALL,
       a.WAT_S2_SHORTFALL AS S2_SHORTFALL,
       a.WAT_INT_CONSUMPT AS INT_CONSUMPT,
       a.WAT_LOSSES AS LOSSES,
       a.WAT_COMPENSATION AS COMPENSATION,
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
UNION ALL
SELECT a.FORECAST_ID AS FORECAST_ID,
       a.SCENARIO_ID AS SCENARIO_ID,
       a.DAYTIME AS DAYTIME,
       b.PHASE_CODE AS PHASE_CODE,
       b.PHASE_NAME AS PHASE_NAME,
       b.SORT_ORDER AS SORT_ORDER,
       a.COND_POT_UNCONSTR AS POT_UNCONSTR,
       a.COND_CONSTRAINTS AS CONSTR,
       a.COND_POT_CONSTR AS POT_CONSTR,
       a.COND_S1P_SHORTFALL AS S1P_SHORTFALL,
       a.COND_S1U_SHORTFALL AS S1U_SHORTFALL,
       a.COND_S2_SHORTFALL AS S2_SHORTFALL,
       a.COND_INT_CONSUMPT AS INT_CONSUMPT,
       a.COND_LOSSES AS LOSSES,
       a.COND_COMPENSATION AS COMPENSATION,
       a.COND_AVAIL_EXPORT AS AVAIL_EXPORT,
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
UNION ALL
SELECT a.FORECAST_ID AS FORECAST_ID,
       a.SCENARIO_ID AS SCENARIO_ID,
       a.DAYTIME AS DAYTIME,
       b.PHASE_CODE AS PHASE_CODE,
       b.PHASE_NAME AS PHASE_NAME,
       b.SORT_ORDER AS SORT_ORDER,
       a.GL_POT_UNCONSTR AS POT_UNCONSTR,
       a.GL_CONSTRAINTS AS CONSTR,
       a.GL_POT_CONSTR AS POT_CONSTR,
       a.GL_S1P_SHORTFALL AS S1P_SHORTFALL,
       a.GL_S1U_SHORTFALL AS S1U_SHORTFALL,
       a.GL_S2_SHORTFALL AS S2_SHORTFALL,
       NULL AS INT_CONSUMPT,
       a.GL_LOSSES AS LOSSES,
       a.GL_COMPENSATION AS COMPENSATION,
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
UNION ALL
SELECT a.FORECAST_ID AS FORECAST_ID,
       a.SCENARIO_ID AS SCENARIO_ID,
       a.DAYTIME AS DAYTIME,
       b.PHASE_CODE AS PHASE_CODE,
       b.PHASE_NAME AS PHASE_NAME,
       b.SORT_ORDER AS SORT_ORDER,
       a.DL_POT_UNCONSTR AS POT_UNCONSTR,
       a.DL_CONSTRAINTS AS CONSTR,
       a.DL_POT_CONSTR AS POT_CONSTR,
       a.DL_S1P_SHORTFALL AS S1P_SHORTFALL,
       a.DL_S1U_SHORTFALL AS S1U_SHORTFALL,
       a.DL_S2_SHORTFALL AS S2_SHORTFALL,
       NULL AS INT_CONSUMPT,
       a.DL_LOSSES AS LOSSES,
       a.DL_COMPENSATION AS COMPENSATION,
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
UNION ALL
SELECT a.FORECAST_ID AS FORECAST_ID,
       a.SCENARIO_ID AS SCENARIO_ID,
       a.DAYTIME AS DAYTIME,
       b.PHASE_CODE AS PHASE_CODE,
       b.PHASE_NAME AS PHASE_NAME,
       b.SORT_ORDER AS SORT_ORDER,
       a.WI_POT_UNCONSTR AS POT_UNCONSTR,
       a.WI_CONSTRAINTS AS CONSTR,
       a.WI_POT_CONSTR AS POT_CONSTR,
       a.WI_S1P_SHORTFALL AS S1P_SHORTFALL,
       a.WI_S1U_SHORTFALL AS S1U_SHORTFALL,
       a.WI_S2_SHORTFALL AS S2_SHORTFALL,
       NULL AS INT_CONSUMPT,
       a.WI_LOSSES AS LOSSES,
       a.WI_COMPENSATION AS COMPENSATION,
       NULL AS AVAIL_EXPORT,
       a.WAT_INJ AS INJ,
       NULL AS RECORD_STATUS,
       NULL AS CREATED_BY,
       NULL AS CREATED_DATE,
       NULL AS LAST_UPDATED_BY,
       NULL AS LAST_UPDATED_DATE,
       NULL AS REV_NO,
       NULL AS REV_TEXT
FROM FCST_SUMMARY_DAY a, V_FCST_SUMM_PHASES b
WHERE b.PHASE_CODE = 'WI'
UNION ALL
SELECT a.FORECAST_ID AS FORECAST_ID,
       a.SCENARIO_ID AS SCENARIO_ID,
       a.DAYTIME AS DAYTIME,
       b.PHASE_CODE AS PHASE_CODE,
       b.PHASE_NAME AS PHASE_NAME,
       b.SORT_ORDER AS SORT_ORDER,
       a.GI_POT_UNCONSTR AS POT_UNCONSTR,
       a.GI_CONSTRAINTS AS CONSTR,
       a.GI_POT_CONSTR AS POT_CONSTR,
       a.GI_S1P_SHORTFALL AS S1P_SHORTFALL,
       a.GI_S1U_SHORTFALL AS S1U_SHORTFALL,
       a.GI_S2_SHORTFALL AS S2_SHORTFALL,
       NULL AS INT_CONSUMPT,
       a.GI_LOSSES AS LOSSES,
       a.GI_COMPENSATION AS COMPENSATION,
       NULL AS AVAIL_EXPORT,
       a.GAS_INJ AS INJ,
       NULL AS RECORD_STATUS,
       NULL AS CREATED_BY,
       NULL AS CREATED_DATE,
       NULL AS LAST_UPDATED_BY,
       NULL AS LAST_UPDATED_DATE,
       NULL AS REV_NO,
       NULL AS REV_TEXT
FROM FCST_SUMMARY_DAY a, V_FCST_SUMM_PHASES b
WHERE b.PHASE_CODE = 'GI'
UNION ALL
SELECT a.FORECAST_ID AS FORECAST_ID,
       a.SCENARIO_ID AS SCENARIO_ID,
       a.DAYTIME AS DAYTIME,
       b.PHASE_CODE AS PHASE_CODE,
       b.PHASE_NAME AS PHASE_NAME,
       b.SORT_ORDER AS SORT_ORDER,
       a.SI_POT_UNCONSTR AS POT_UNCONSTR,
       a.SI_CONSTRAINTS AS CONSTR,
       a.SI_POT_CONSTR AS POT_CONSTR,
       a.SI_S1P_SHORTFALL AS S1P_SHORTFALL,
       a.SI_S1U_SHORTFALL AS S1U_SHORTFALL,
       a.SI_S2_SHORTFALL AS S2_SHORTFALL,
       NULL AS INT_CONSUMPT,
       a.SI_LOSSES AS LOSSES,
       a.SI_COMPENSATION AS COMPENSATION,
       NULL AS AVAIL_EXPORT,
       a.STEAM_INJ AS INJ,
       NULL AS RECORD_STATUS,
       NULL AS CREATED_BY,
       NULL AS CREATED_DATE,
       NULL AS LAST_UPDATED_BY,
       NULL AS LAST_UPDATED_DATE,
       NULL AS REV_NO,
       NULL AS REV_TEXT
FROM FCST_SUMMARY_DAY a, V_FCST_SUMM_PHASES b
WHERE b.PHASE_CODE = 'SI'
UNION ALL
SELECT a.FORECAST_ID AS FORECAST_ID,
       a.SCENARIO_ID AS SCENARIO_ID,
       a.DAYTIME AS DAYTIME,
       b.PHASE_CODE AS PHASE_CODE,
       b.PHASE_NAME AS PHASE_NAME,
       b.SORT_ORDER AS SORT_ORDER,
       a.CI_POT_UNCONSTR AS POT_UNCONSTR,
       a.CI_CONSTRAINTS AS CONSTR,
       a.CI_POT_CONSTR AS POT_CONSTR,
       a.CI_S1P_SHORTFALL AS S1P_SHORTFALL,
       a.CI_S1U_SHORTFALL AS S1U_SHORTFALL,
       a.CI_S2_SHORTFALL AS S2_SHORTFALL,
       NULL AS INT_CONSUMPT,
       a.CI_LOSSES AS LOSSES,
       a.CI_COMPENSATION AS COMPENSATION,
       NULL AS AVAIL_EXPORT,
       a.CO2_INJ AS INJ,
       NULL AS RECORD_STATUS,
       NULL AS CREATED_BY,
       NULL AS CREATED_DATE,
       NULL AS LAST_UPDATED_BY,
       NULL AS LAST_UPDATED_DATE,
       NULL AS REV_NO,
       NULL AS REV_TEXT
FROM FCST_SUMMARY_DAY a, V_FCST_SUMM_PHASES b
WHERE b.PHASE_CODE = 'CI'
)