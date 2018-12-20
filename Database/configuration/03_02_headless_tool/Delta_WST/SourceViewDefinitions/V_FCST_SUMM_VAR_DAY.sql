CREATE OR REPLACE FORCE EDITIONABLE VIEW "V_FCST_SUMM_VAR_DAY" ("FORECAST_ID", "OBJECT_ID", "DAYTIME", "VARIABLE_CODE", "VARIABLE_NAME", "SORT_ORDER", "OIL", "GAS", "WAT", "COND", "GL", "DL", "WI", "GI", "SI", "CI", "RECORD_STATUS", "CREATED_BY", "CREATED_DATE", "LAST_UPDATED_BY", "LAST_UPDATED_DATE", "REV_NO", "REV_TEXT") AS 
  (
----------------------------------------------------------------------------------------------------
-- File name: V_FCST_SUMM_VAR_DAY.SQL
-- View name: V_FCST_SUMM_VAR_DAY
--
--
-- Purpose  : The forecasted daily variable data
--
-- Modification history:
--
-- Date       Whom      Change description:
-- ---------- ----      --------------------------------------------------------------------------------
-- 2016-08-23 leongwen  ECPD-37329 : Initial version
----------------------------------------------------------------------------------------------------
SELECT a.FORECAST_ID AS FORECAST_ID,
       a.OBJECT_ID AS OBJECT_ID,
       a.DAYTIME AS DAYTIME,
       b.VARIABLE_CODE AS VARIABLE_CODE,
       b.VARIABLE_NAME AS VARIABLE_NAME,
       b.SORT_ORDER AS SORT_ORDER,
       a.OIL_POT_UNCONSTR AS OIL,
       a.GAS_POT_UNCONSTR AS GAS,
       a.WAT_POT_UNCONSTR AS WAT,
       a.COND_POT_UNCONSTR AS COND,
       a.GL_POT_UNCONSTR AS GL,
       a.DL_POT_UNCONSTR AS DL,
       a.WI_POT_UNCONSTR AS WI,
       a.GI_POT_UNCONSTR AS GI,
       a.SI_POT_UNCONSTR AS SI,
       a.CI_POT_UNCONSTR AS CI,
       NULL AS RECORD_STATUS,
       NULL AS CREATED_BY,
       NULL AS CREATED_DATE,
       NULL AS LAST_UPDATED_BY,
       NULL AS LAST_UPDATED_DATE,
       NULL AS REV_NO,
       NULL AS REV_TEXT
FROM FCST_SUMMARY_DAY a, V_FCST_SUMM_VARIABLES b
WHERE b.VARIABLE_CODE = 'POT_UNCONSTR'
UNION ALL
SELECT a.FORECAST_ID AS FORECAST_ID,
       a.OBJECT_ID AS OBJECT_ID,
       a.DAYTIME AS DAYTIME,
       b.VARIABLE_CODE AS VARIABLE_CODE,
       b.VARIABLE_NAME AS VARIABLE_NAME,
       b.SORT_ORDER AS SORT_ORDER,
       a.OIL_CONSTRAINTS AS OIL,
       a.GAS_CONSTRAINTS AS GAS,
       a.WAT_CONSTRAINTS AS WAT,
       a.COND_CONSTRAINTS AS COND,
       a.GL_CONSTRAINTS AS GL,
       a.DL_CONSTRAINTS AS DL,
       a.WI_CONSTRAINTS AS WI,
       a.GI_CONSTRAINTS AS GI,
       a.SI_CONSTRAINTS AS SI,
       a.CI_CONSTRAINTS AS CI,
       NULL AS RECORD_STATUS,
       NULL AS CREATED_BY,
       NULL AS CREATED_DATE,
       NULL AS LAST_UPDATED_BY,
       NULL AS LAST_UPDATED_DATE,
       NULL AS REV_NO,
       NULL AS REV_TEXT
FROM FCST_SUMMARY_DAY a, V_FCST_SUMM_VARIABLES b
WHERE b.VARIABLE_CODE = 'CONSTRAINTS'
UNION ALL
SELECT a.FORECAST_ID AS FORECAST_ID,
       a.OBJECT_ID AS OBJECT_ID,
       a.DAYTIME AS DAYTIME,
       b.VARIABLE_CODE AS VARIABLE_CODE,
       b.VARIABLE_NAME AS VARIABLE_NAME,
       b.SORT_ORDER AS SORT_ORDER,
       a.OIL_POT_CONSTR AS OIL,
       a.GAS_POT_CONSTR AS GAS,
       a.WAT_POT_CONSTR AS WAT,
       a.COND_POT_CONSTR AS COND,
       a.GL_POT_CONSTR AS GL,
       a.DL_POT_CONSTR AS DL,
       a.WI_POT_CONSTR AS WI,
       a.GI_POT_CONSTR AS GI,
       a.SI_POT_CONSTR AS SI,
       a.CI_POT_CONSTR AS CI,
       NULL AS RECORD_STATUS,
       NULL AS CREATED_BY,
       NULL AS CREATED_DATE,
       NULL AS LAST_UPDATED_BY,
       NULL AS LAST_UPDATED_DATE,
       NULL AS REV_NO,
       NULL AS REV_TEXT
FROM FCST_SUMMARY_DAY a, V_FCST_SUMM_VARIABLES b
WHERE b.VARIABLE_CODE = 'POT_CONSTR'
UNION ALL
SELECT a.FORECAST_ID AS FORECAST_ID,
       a.OBJECT_ID AS OBJECT_ID,
       a.DAYTIME AS DAYTIME,
       b.VARIABLE_CODE AS VARIABLE_CODE,
       b.VARIABLE_NAME AS VARIABLE_NAME,
       b.SORT_ORDER AS SORT_ORDER,
       a.OIL_S1P_SHORTFALL AS OIL,
       a.GAS_S1P_SHORTFALL AS GAS,
       a.WAT_S1P_SHORTFALL AS WAT,
       a.COND_S1P_SHORTFALL AS COND,
       a.GL_S1P_SHORTFALL AS GL,
       a.DL_S1P_SHORTFALL AS DL,
       a.WI_S1P_SHORTFALL AS WI,
       a.GI_S1P_SHORTFALL AS GI,
       a.SI_S1P_SHORTFALL AS SI,
       a.CI_S1P_SHORTFALL AS CI,
       NULL AS RECORD_STATUS,
       NULL AS CREATED_BY,
       NULL AS CREATED_DATE,
       NULL AS LAST_UPDATED_BY,
       NULL AS LAST_UPDATED_DATE,
       NULL AS REV_NO,
       NULL AS REV_TEXT
FROM FCST_SUMMARY_DAY a, V_FCST_SUMM_VARIABLES b
WHERE b.VARIABLE_CODE = 'S1P_SHORTFALL'
UNION ALL
SELECT a.FORECAST_ID AS FORECAST_ID,
       a.OBJECT_ID AS OBJECT_ID,
       a.DAYTIME AS DAYTIME,
       b.VARIABLE_CODE AS VARIABLE_CODE,
       b.VARIABLE_NAME AS VARIABLE_NAME,
       b.SORT_ORDER AS SORT_ORDER,
       a.OIL_S1U_SHORTFALL AS OIL,
       a.GAS_S1U_SHORTFALL AS GAS,
       a.WAT_S1U_SHORTFALL AS WAT,
       a.COND_S1U_SHORTFALL AS COND,
       a.GL_S1U_SHORTFALL AS GL,
       a.DL_S1U_SHORTFALL AS DL,
       a.WI_S1U_SHORTFALL AS WI,
       a.GI_S1U_SHORTFALL AS GI,
       a.SI_S1U_SHORTFALL AS SI,
       a.CI_S1U_SHORTFALL AS CI,
       NULL AS RECORD_STATUS,
       NULL AS CREATED_BY,
       NULL AS CREATED_DATE,
       NULL AS LAST_UPDATED_BY,
       NULL AS LAST_UPDATED_DATE,
       NULL AS REV_NO,
       NULL AS REV_TEXT
FROM FCST_SUMMARY_DAY a, V_FCST_SUMM_VARIABLES b
WHERE b.VARIABLE_CODE = 'S1U_SHORTFALL'
UNION ALL
SELECT a.FORECAST_ID AS FORECAST_ID,
       a.OBJECT_ID AS OBJECT_ID,
       a.DAYTIME AS DAYTIME,
       b.VARIABLE_CODE AS VARIABLE_CODE,
       b.VARIABLE_NAME AS VARIABLE_NAME,
       b.SORT_ORDER AS SORT_ORDER,
       a.OIL_S2_SHORTFALL AS OIL,
       a.GAS_S2_SHORTFALL AS GAS,
       a.WAT_S2_SHORTFALL AS WAT,
       a.COND_S2_SHORTFALL AS COND,
       a.GL_S2_SHORTFALL AS GL,
       a.DL_S2_SHORTFALL AS DL,
       a.WI_S2_SHORTFALL AS WI,
       a.GI_S2_SHORTFALL AS GI,
       a.SI_S2_SHORTFALL AS SI,
       a.CI_S2_SHORTFALL AS CI,
       NULL AS RECORD_STATUS,
       NULL AS CREATED_BY,
       NULL AS CREATED_DATE,
       NULL AS LAST_UPDATED_BY,
       NULL AS LAST_UPDATED_DATE,
       NULL AS REV_NO,
       NULL AS REV_TEXT
FROM FCST_SUMMARY_DAY a, V_FCST_SUMM_VARIABLES b
WHERE b.VARIABLE_CODE = 'S2_SHORTFALL'
UNION ALL
SELECT a.FORECAST_ID AS FORECAST_ID,
       a.OBJECT_ID AS OBJECT_ID,
       a.DAYTIME AS DAYTIME,
       b.VARIABLE_CODE AS VARIABLE_CODE,
       b.VARIABLE_NAME AS VARIABLE_NAME,
       b.SORT_ORDER AS SORT_ORDER,
       NULL AS OIL,
       NULL AS GAS,
       NULL AS WAT,
       NULL AS COND,
       NULL AS GL,
       NULL AS DL,
       a.WAT_INJ AS WI,
       a.GAS_INJ AS GI,
       a.STEAM_INJ AS SI,
       a.CO2_INJ AS CI,
       NULL AS RECORD_STATUS,
       NULL AS CREATED_BY,
       NULL AS CREATED_DATE,
       NULL AS LAST_UPDATED_BY,
       NULL AS LAST_UPDATED_DATE,
       NULL AS REV_NO,
       NULL AS REV_TEXT
FROM FCST_SUMMARY_DAY a, V_FCST_SUMM_VARIABLES b
WHERE b.VARIABLE_CODE = 'INJ'
UNION ALL
SELECT a.FORECAST_ID AS FORECAST_ID,
       a.OBJECT_ID AS OBJECT_ID,
       a.DAYTIME AS DAYTIME,
       b.VARIABLE_CODE AS VARIABLE_CODE,
       b.VARIABLE_NAME AS VARIABLE_NAME,
       b.SORT_ORDER AS SORT_ORDER,
       a.OIL_INT_CONSUMPT AS OIL,
       a.GAS_INT_CONSUMPT AS GAS,
       a.WAT_INT_CONSUMPT AS WAT,
       a.COND_INT_CONSUMPT AS COND,
       NULL AS GL,
       NULL AS DL,
       NULL AS WI,
       NULL AS GI,
       NULL AS SI,
       NULL AS CI,
       NULL AS RECORD_STATUS,
       NULL AS CREATED_BY,
       NULL AS CREATED_DATE,
       NULL AS LAST_UPDATED_BY,
       NULL AS LAST_UPDATED_DATE,
       NULL AS REV_NO,
       NULL AS REV_TEXT
FROM FCST_SUMMARY_DAY a, V_FCST_SUMM_VARIABLES b
WHERE b.VARIABLE_CODE = 'INT_CONSUMPT'
UNION ALL
SELECT a.FORECAST_ID AS FORECAST_ID,
       a.OBJECT_ID AS OBJECT_ID,
       a.DAYTIME AS DAYTIME,
       b.VARIABLE_CODE AS VARIABLE_CODE,
       b.VARIABLE_NAME AS VARIABLE_NAME,
       b.SORT_ORDER AS SORT_ORDER,
       a.OIL_LOSSES AS OIL,
       a.GAS_LOSSES AS GAS,
       a.WAT_LOSSES AS WAT,
       a.COND_LOSSES AS COND,
       a.GL_LOSSES AS GL,
       a.DL_LOSSES AS DL,
       a.WI_LOSSES AS WI,
       a.GI_LOSSES AS GI,
       a.SI_LOSSES AS SI,
       a.CI_LOSSES AS CI,
       NULL AS RECORD_STATUS,
       NULL AS CREATED_BY,
       NULL AS CREATED_DATE,
       NULL AS LAST_UPDATED_BY,
       NULL AS LAST_UPDATED_DATE,
       NULL AS REV_NO,
       NULL AS REV_TEXT
FROM FCST_SUMMARY_DAY a, V_FCST_SUMM_VARIABLES b
WHERE b.VARIABLE_CODE = 'LOSSES'
UNION ALL
SELECT a.FORECAST_ID AS FORECAST_ID,
       a.OBJECT_ID AS OBJECT_ID,
       a.DAYTIME AS DAYTIME,
       b.VARIABLE_CODE AS VARIABLE_CODE,
       b.VARIABLE_NAME AS VARIABLE_NAME,
       b.SORT_ORDER AS SORT_ORDER,
       a.OIL_COMPENSATION AS OIL,
       a.GAS_COMPENSATION AS GAS,
       a.WAT_COMPENSATION AS WAT,
       a.COND_COMPENSATION AS COND,
       a.GL_COMPENSATION AS GL,
       a.DL_COMPENSATION AS DL,
       a.WI_COMPENSATION AS WI,
       a.GI_COMPENSATION AS GI,
       a.SI_COMPENSATION AS SI,
       a.CI_COMPENSATION AS CI,
       NULL AS RECORD_STATUS,
       NULL AS CREATED_BY,
       NULL AS CREATED_DATE,
       NULL AS LAST_UPDATED_BY,
       NULL AS LAST_UPDATED_DATE,
       NULL AS REV_NO,
       NULL AS REV_TEXT
FROM FCST_SUMMARY_DAY a, V_FCST_SUMM_VARIABLES b
WHERE b.VARIABLE_CODE = 'COMPENSATION'
UNION ALL
SELECT a.FORECAST_ID AS FORECAST_ID,
       a.OBJECT_ID AS OBJECT_ID,
       a.DAYTIME AS DAYTIME,
       b.VARIABLE_CODE AS VARIABLE_CODE,
       b.VARIABLE_NAME AS VARIABLE_NAME,
       b.SORT_ORDER AS SORT_ORDER,
       a.OIL_AVAIL_EXPORT AS OIL,
       a.GAS_AVAIL_EXPORT AS GAS,
       NULL AS WAT,
       a.COND_AVAIL_EXPORT AS COND,
       NULL AS GL,
       NULL AS DL,
       NULL AS WI,
       NULL AS GI,
       NULL AS SI,
       NULL AS CI,
       NULL AS RECORD_STATUS,
       NULL AS CREATED_BY,
       NULL AS CREATED_DATE,
       NULL AS LAST_UPDATED_BY,
       NULL AS LAST_UPDATED_DATE,
       NULL AS REV_NO,
       NULL AS REV_TEXT
FROM FCST_SUMMARY_DAY a, V_FCST_SUMM_VARIABLES b
WHERE b.VARIABLE_CODE = 'AVAIL_EXPORT'
)