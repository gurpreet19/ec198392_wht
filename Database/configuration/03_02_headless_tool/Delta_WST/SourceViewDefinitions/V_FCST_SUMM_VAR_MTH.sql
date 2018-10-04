CREATE OR REPLACE FORCE EDITIONABLE VIEW "V_FCST_SUMM_VAR_MTH" ("FORECAST_ID", "OBJECT_ID", "MONTH", "VARIABLE_CODE", "VARIABLE_NAME", "SORT_ORDER", "OIL", "GAS", "WAT", "COND", "GL", "DL", "WI", "GI", "SI", "CI", "RECORD_STATUS", "CREATED_BY", "CREATED_DATE", "LAST_UPDATED_BY", "LAST_UPDATED_DATE", "REV_NO", "REV_TEXT") AS 
  (
----------------------------------------------------------------------------------------------------
-- File name: V_FCST_SUMM_VAR_MTH.SQL
-- View name: V_FCST_SUMM_VAR_MTH
--
--
-- Purpose  : The forecasted average monthly variable data
--
-- Modification history:
--
-- Date       Whom      Change description:
-- ---------- ----      --------------------------------------------------------------------------------
-- 2016-08-23 leongwen  ECPD-37329 : Initial version
----------------------------------------------------------------------------------------------------
SELECT a.FORECAST_ID AS FORECAST_ID,
       a.OBJECT_ID AS OBJECT_ID,
       TRUNC(a.DAYTIME, 'MONTH') AS MONTH,
       b.VARIABLE_CODE AS VARIABLE_CODE,
       b.VARIABLE_NAME AS VARIABLE_NAME,
       b.SORT_ORDER AS SORT_ORDER,
       AVG(a.OIL_POT_UNCONSTR) AS OIL,
       AVG(a.GAS_POT_UNCONSTR) AS GAS,
       AVG(a.WAT_POT_UNCONSTR) AS WAT,
       AVG(a.COND_POT_UNCONSTR) AS COND,
       AVG(a.GL_POT_UNCONSTR) AS GL,
       AVG(a.DL_POT_UNCONSTR) AS DL,
       AVG(a.WI_POT_UNCONSTR) AS WI,
       AVG(a.GI_POT_UNCONSTR) AS GI,
       AVG(a.SI_POT_UNCONSTR) AS SI,
       AVG(a.CI_POT_UNCONSTR) AS CI,
       NULL AS RECORD_STATUS,
       NULL AS CREATED_BY,
       NULL AS CREATED_DATE,
       NULL AS LAST_UPDATED_BY,
       NULL AS LAST_UPDATED_DATE,
       NULL AS REV_NO,
       NULL AS REV_TEXT
FROM FCST_SUMMARY_DAY a, V_FCST_SUMM_VARIABLES b
WHERE b.VARIABLE_CODE = 'POT_UNCONSTR'
GROUP BY a.FORECAST_ID, a.OBJECT_ID, TRUNC(a.DAYTIME, 'MONTH'), b.VARIABLE_CODE, b.VARIABLE_NAME, b.SORT_ORDER
UNION ALL
SELECT a.FORECAST_ID AS FORECAST_ID,
       a.OBJECT_ID AS OBJECT_ID,
       TRUNC(a.DAYTIME, 'MONTH') AS MONTH,
       b.VARIABLE_CODE AS VARIABLE_CODE,
       b.VARIABLE_NAME AS VARIABLE_NAME,
       b.SORT_ORDER AS SORT_ORDER,
       AVG(a.OIL_CONSTRAINTS) AS OIL,
       AVG(a.GAS_CONSTRAINTS) AS GAS,
       AVG(a.WAT_CONSTRAINTS) AS WAT,
       AVG(a.COND_CONSTRAINTS) AS COND,
       AVG(a.GL_CONSTRAINTS) AS GL,
       AVG(a.DL_CONSTRAINTS) AS DL,
       AVG(a.WI_CONSTRAINTS) AS WI,
       AVG(a.GI_CONSTRAINTS) AS GI,
       AVG(a.SI_CONSTRAINTS) AS SI,
       AVG(a.CI_CONSTRAINTS) AS CI,
       NULL AS RECORD_STATUS,
       NULL AS CREATED_BY,
       NULL AS CREATED_DATE,
       NULL AS LAST_UPDATED_BY,
       NULL AS LAST_UPDATED_DATE,
       NULL AS REV_NO,
       NULL AS REV_TEXT
FROM FCST_SUMMARY_DAY a, V_FCST_SUMM_VARIABLES b
WHERE b.VARIABLE_CODE = 'CONSTRAINTS'
GROUP BY a.FORECAST_ID, a.OBJECT_ID, TRUNC(a.DAYTIME, 'MONTH'), b.VARIABLE_CODE, b.VARIABLE_NAME, b.SORT_ORDER
UNION ALL
SELECT a.FORECAST_ID AS FORECAST_ID,
       a.OBJECT_ID AS OBJECT_ID,
       TRUNC(a.DAYTIME, 'MONTH') AS MONTH,
       b.VARIABLE_CODE AS VARIABLE_CODE,
       b.VARIABLE_NAME AS VARIABLE_NAME,
       b.SORT_ORDER AS SORT_ORDER,
       AVG(a.OIL_POT_CONSTR) AS OIL,
       AVG(a.GAS_POT_CONSTR) AS GAS,
       AVG(a.WAT_POT_CONSTR) AS WAT,
       AVG(a.COND_POT_CONSTR) AS COND,
       AVG(a.GL_POT_CONSTR) AS GL,
       AVG(a.DL_POT_CONSTR) AS DL,
       AVG(a.WI_POT_CONSTR) AS WI,
       AVG(a.GI_POT_CONSTR) AS GI,
       AVG(a.SI_POT_CONSTR) AS SI,
       AVG(a.CI_POT_CONSTR) AS CI,
       NULL AS RECORD_STATUS,
       NULL AS CREATED_BY,
       NULL AS CREATED_DATE,
       NULL AS LAST_UPDATED_BY,
       NULL AS LAST_UPDATED_DATE,
       NULL AS REV_NO,
       NULL AS REV_TEXT
FROM FCST_SUMMARY_DAY a, V_FCST_SUMM_VARIABLES b
WHERE b.VARIABLE_CODE = 'POT_CONSTR'
GROUP BY a.FORECAST_ID, a.OBJECT_ID, TRUNC(a.DAYTIME, 'MONTH'), b.VARIABLE_CODE, b.VARIABLE_NAME, b.SORT_ORDER
UNION ALL
SELECT a.FORECAST_ID AS FORECAST_ID,
       a.OBJECT_ID AS OBJECT_ID,
       TRUNC(a.DAYTIME, 'MONTH') AS MONTH,
       b.VARIABLE_CODE AS VARIABLE_CODE,
       b.VARIABLE_NAME AS VARIABLE_NAME,
       b.SORT_ORDER AS SORT_ORDER,
       AVG(a.OIL_S1P_SHORTFALL) AS OIL,
       AVG(a.GAS_S1P_SHORTFALL) AS GAS,
       AVG(a.WAT_S1P_SHORTFALL) AS WAT,
       AVG(a.COND_S1P_SHORTFALL) AS COND,
       AVG(a.GL_S1P_SHORTFALL) AS GL,
       AVG(a.DL_S1P_SHORTFALL) AS DL,
       AVG(a.WI_S1P_SHORTFALL) AS WI,
       AVG(a.GI_S1P_SHORTFALL) AS GI,
       AVG(a.SI_S1P_SHORTFALL) AS SI,
       AVG(a.CI_S1P_SHORTFALL) AS CI,
       NULL AS RECORD_STATUS,
       NULL AS CREATED_BY,
       NULL AS CREATED_DATE,
       NULL AS LAST_UPDATED_BY,
       NULL AS LAST_UPDATED_DATE,
       NULL AS REV_NO,
       NULL AS REV_TEXT
FROM FCST_SUMMARY_DAY a, V_FCST_SUMM_VARIABLES b
WHERE b.VARIABLE_CODE = 'S1P_SHORTFALL'
GROUP BY a.FORECAST_ID, a.OBJECT_ID, TRUNC(a.DAYTIME, 'MONTH'), b.VARIABLE_CODE, b.VARIABLE_NAME, b.SORT_ORDER
UNION ALL
SELECT a.FORECAST_ID AS FORECAST_ID,
       a.OBJECT_ID AS OBJECT_ID,
       TRUNC(a.DAYTIME, 'MONTH') AS MONTH,
       b.VARIABLE_CODE AS VARIABLE_CODE,
       b.VARIABLE_NAME AS VARIABLE_NAME,
       b.SORT_ORDER AS SORT_ORDER,
       AVG(a.OIL_S1U_SHORTFALL) AS OIL,
       AVG(a.GAS_S1U_SHORTFALL) AS GAS,
       AVG(a.WAT_S1U_SHORTFALL) AS WAT,
       AVG(a.COND_S1U_SHORTFALL) AS COND,
       AVG(a.GL_S1U_SHORTFALL) AS GL,
       AVG(a.DL_S1U_SHORTFALL) AS DL,
       AVG(a.WI_S1U_SHORTFALL) AS WI,
       AVG(a.GI_S1U_SHORTFALL) AS GI,
       AVG(a.SI_S1U_SHORTFALL) AS SI,
       AVG(a.CI_S1U_SHORTFALL) AS CI,
       NULL AS RECORD_STATUS,
       NULL AS CREATED_BY,
       NULL AS CREATED_DATE,
       NULL AS LAST_UPDATED_BY,
       NULL AS LAST_UPDATED_DATE,
       NULL AS REV_NO,
       NULL AS REV_TEXT
FROM FCST_SUMMARY_DAY a, V_FCST_SUMM_VARIABLES b
WHERE b.VARIABLE_CODE = 'S1U_SHORTFALL'
GROUP BY a.FORECAST_ID, a.OBJECT_ID, TRUNC(a.DAYTIME, 'MONTH'), b.VARIABLE_CODE, b.VARIABLE_NAME, b.SORT_ORDER
UNION ALL
SELECT a.FORECAST_ID AS FORECAST_ID,
       a.OBJECT_ID AS OBJECT_ID,
       TRUNC(a.DAYTIME, 'MONTH') AS MONTH,
       b.VARIABLE_CODE AS VARIABLE_CODE,
       b.VARIABLE_NAME AS VARIABLE_NAME,
       b.SORT_ORDER AS SORT_ORDER,
       AVG(a.OIL_S2_SHORTFALL) AS OIL,
       AVG(a.GAS_S2_SHORTFALL) AS GAS,
       AVG(a.WAT_S2_SHORTFALL) AS WAT,
       AVG(a.COND_S2_SHORTFALL) AS COND,
       AVG(a.GL_S2_SHORTFALL) AS GL,
       AVG(a.DL_S2_SHORTFALL) AS DL,
       AVG(a.WI_S2_SHORTFALL) AS WI,
       AVG(a.GI_S2_SHORTFALL) AS GI,
       AVG(a.SI_S2_SHORTFALL) AS SI,
       AVG(a.CI_S2_SHORTFALL) AS CI,
       NULL AS RECORD_STATUS,
       NULL AS CREATED_BY,
       NULL AS CREATED_DATE,
       NULL AS LAST_UPDATED_BY,
       NULL AS LAST_UPDATED_DATE,
       NULL AS REV_NO,
       NULL AS REV_TEXT
FROM FCST_SUMMARY_DAY a, V_FCST_SUMM_VARIABLES b
WHERE b.VARIABLE_CODE = 'S2_SHORTFALL'
GROUP BY a.FORECAST_ID, a.OBJECT_ID, TRUNC(a.DAYTIME, 'MONTH'), b.VARIABLE_CODE, b.VARIABLE_NAME, b.SORT_ORDER
UNION ALL
SELECT a.FORECAST_ID AS FORECAST_ID,
       a.OBJECT_ID AS OBJECT_ID,
       TRUNC(a.DAYTIME, 'MONTH') AS MONTH,
       b.VARIABLE_CODE AS VARIABLE_CODE,
       b.VARIABLE_NAME AS VARIABLE_NAME,
       b.SORT_ORDER AS SORT_ORDER,
       NULL AS OIL,
       NULL AS GAS,
       NULL AS WAT,
       NULL AS COND,
       NULL AS GL,
       NULL AS DL,
       AVG(a.WAT_INJ) AS WI,
       AVG(a.GAS_INJ) AS GI,
       AVG(a.STEAM_INJ) AS SI,
       AVG(a.CO2_INJ) AS CI,
       NULL AS RECORD_STATUS,
       NULL AS CREATED_BY,
       NULL AS CREATED_DATE,
       NULL AS LAST_UPDATED_BY,
       NULL AS LAST_UPDATED_DATE,
       NULL AS REV_NO,
       NULL AS REV_TEXT
FROM FCST_SUMMARY_DAY a, V_FCST_SUMM_VARIABLES b
WHERE b.VARIABLE_CODE = 'INJ'
GROUP BY a.FORECAST_ID, a.OBJECT_ID, TRUNC(a.DAYTIME, 'MONTH'), b.VARIABLE_CODE, b.VARIABLE_NAME, b.SORT_ORDER
UNION ALL
SELECT a.FORECAST_ID AS FORECAST_ID,
       a.OBJECT_ID AS OBJECT_ID,
       TRUNC(a.DAYTIME, 'MONTH') AS MONTH,
       b.VARIABLE_CODE AS VARIABLE_CODE,
       b.VARIABLE_NAME AS VARIABLE_NAME,
       b.SORT_ORDER AS SORT_ORDER,
       AVG(a.OIL_INT_CONSUMPT) AS OIL,
       AVG(a.GAS_INT_CONSUMPT) AS GAS,
       AVG(a.WAT_INT_CONSUMPT) AS WAT,
       AVG(a.COND_INT_CONSUMPT) AS COND,
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
GROUP BY a.FORECAST_ID, a.OBJECT_ID, TRUNC(a.DAYTIME, 'MONTH'), b.VARIABLE_CODE, b.VARIABLE_NAME, b.SORT_ORDER
UNION ALL
SELECT a.FORECAST_ID AS FORECAST_ID,
       a.OBJECT_ID AS OBJECT_ID,
       TRUNC(a.DAYTIME, 'MONTH') AS MONTH,
       b.VARIABLE_CODE AS VARIABLE_CODE,
       b.VARIABLE_NAME AS VARIABLE_NAME,
       b.SORT_ORDER AS SORT_ORDER,
       AVG(a.OIL_LOSSES) AS OIL,
       AVG(a.GAS_LOSSES) AS GAS,
       AVG(a.WAT_LOSSES) AS WAT,
       AVG(a.COND_LOSSES) AS COND,
       AVG(a.GL_LOSSES) AS GL,
       AVG(a.DL_LOSSES) AS DL,
       AVG(a.WI_LOSSES) AS WI,
       AVG(a.GI_LOSSES) AS GI,
       AVG(a.SI_LOSSES) AS SI,
       AVG(a.CI_LOSSES) AS CI,
       NULL AS RECORD_STATUS,
       NULL AS CREATED_BY,
       NULL AS CREATED_DATE,
       NULL AS LAST_UPDATED_BY,
       NULL AS LAST_UPDATED_DATE,
       NULL AS REV_NO,
       NULL AS REV_TEXT
FROM FCST_SUMMARY_DAY a, V_FCST_SUMM_VARIABLES b
WHERE b.VARIABLE_CODE = 'LOSSES'
GROUP BY a.FORECAST_ID, a.OBJECT_ID, TRUNC(a.DAYTIME, 'MONTH'), b.VARIABLE_CODE, b.VARIABLE_NAME, b.SORT_ORDER
UNION ALL
SELECT a.FORECAST_ID AS FORECAST_ID,
       a.OBJECT_ID AS OBJECT_ID,
       TRUNC(a.DAYTIME, 'MONTH') AS MONTH,
       b.VARIABLE_CODE AS VARIABLE_CODE,
       b.VARIABLE_NAME AS VARIABLE_NAME,
       b.SORT_ORDER AS SORT_ORDER,
       AVG(a.OIL_COMPENSATION) AS OIL,
       AVG(a.GAS_COMPENSATION) AS GAS,
       AVG(a.WAT_COMPENSATION) AS WAT,
       AVG(a.COND_COMPENSATION) AS COND,
       AVG(a.GL_COMPENSATION) AS GL,
       AVG(a.DL_COMPENSATION) AS DL,
       AVG(a.WI_COMPENSATION) AS WI,
       AVG(a.GI_COMPENSATION) AS GI,
       AVG(a.SI_COMPENSATION) AS SI,
       AVG(a.CI_COMPENSATION) AS CI,
       NULL AS RECORD_STATUS,
       NULL AS CREATED_BY,
       NULL AS CREATED_DATE,
       NULL AS LAST_UPDATED_BY,
       NULL AS LAST_UPDATED_DATE,
       NULL AS REV_NO,
       NULL AS REV_TEXT
FROM FCST_SUMMARY_DAY a, V_FCST_SUMM_VARIABLES b
WHERE b.VARIABLE_CODE = 'COMPENSATION'
GROUP BY a.FORECAST_ID, a.OBJECT_ID, TRUNC(a.DAYTIME, 'MONTH'), b.VARIABLE_CODE, b.VARIABLE_NAME, b.SORT_ORDER
UNION ALL
SELECT a.FORECAST_ID AS FORECAST_ID,
       a.OBJECT_ID AS OBJECT_ID,
       TRUNC(a.DAYTIME, 'MONTH') AS MONTH,
       b.VARIABLE_CODE AS VARIABLE_CODE,
       b.VARIABLE_NAME AS VARIABLE_NAME,
       b.SORT_ORDER AS SORT_ORDER,
       AVG(a.OIL_AVAIL_EXPORT) AS OIL,
       AVG(a.GAS_AVAIL_EXPORT) AS GAS,
       NULL AS WAT,
       AVG(a.COND_AVAIL_EXPORT) AS COND,
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
GROUP BY a.FORECAST_ID, a.OBJECT_ID, TRUNC(a.DAYTIME, 'MONTH'), b.VARIABLE_CODE, b.VARIABLE_NAME, b.SORT_ORDER
)