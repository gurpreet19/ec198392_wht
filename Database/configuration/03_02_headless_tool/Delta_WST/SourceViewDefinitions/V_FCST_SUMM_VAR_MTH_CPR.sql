CREATE OR REPLACE FORCE EDITIONABLE VIEW "V_FCST_SUMM_VAR_MTH_CPR" ("FORECAST_ID_1", "OBJECT_ID_1", "FORECAST_ID_2", "OBJECT_ID_2", "MONTH", "VARIABLE_CODE", "VARIABLE_NAME", "SORT_ORDER", "OIL_1", "OIL_2", "OIL_DIFF", "GAS_1", "GAS_2", "GAS_DIFF", "WAT_1", "WAT_2", "WAT_DIFF", "COND_1", "COND_2", "COND_DIFF", "GL_1", "GL_2", "GL_DIFF", "DL_1", "DL_2", "DL_DIFF", "WI_1", "WI_2", "WI_DIFF", "GI_1", "GI_2", "GI_DIFF", "SI_1", "SI_2", "SI_DIFF", "CI_1", "CI_2", "CI_DIFF", "RECORD_STATUS", "CREATED_BY", "CREATED_DATE", "LAST_UPDATED_BY", "LAST_UPDATED_DATE", "REV_NO", "REV_TEXT") AS 
  SELECT
       s1.FORECAST_ID AS FORECAST_ID_1,
       s1.OBJECT_ID AS OBJECT_ID_1,
       s2.FORECAST_ID AS FORECAST_ID_2,
       s2.OBJECT_ID AS OBJECT_ID_2,
       NVL(s1.MONTH_1,s2.MONTH_2) AS MONTH,
       NVL(s1.VARIABLE_CODE_1,s2.VARIABLE_CODE_2) AS VARIABLE_CODE,
       NVL(s1.VARIABLE_NAME_1,s2.VARIABLE_NAME_2) AS VARIABLE_NAME,
       NVL(s1.SORT_ORDER_1,s2.SORT_ORDER_2) AS SORT_ORDER,
       s1.OIL_1  AS OIL_1,
       s2.OIL_2  AS OIL_2,
       COALESCE(s2.OIL_2-s1.OIL_1,s2.OIL_2,-s1.OIL_1)  AS OIL_DIFF,
       s1.GAS_1  AS GAS_1,
       s2.GAS_2  AS GAS_2,
       COALESCE(s2.GAS_2-s1.GAS_1,s2.GAS_2,-s1.GAS_1)  AS GAS_DIFF,
       s1.WAT_1  AS WAT_1,
       s2.WAT_2  AS WAT_2,
       COALESCE(s2.WAT_2-s1.WAT_1,s2.WAT_2,-s1.WAT_1)  AS WAT_DIFF,
       s1.COND_1 AS COND_1,
       s2.COND_2 AS COND_2,
       COALESCE(s2.COND_2-s1.COND_1,s2.COND_2,-s1.COND_1)  AS COND_DIFF,
       s1.GL_1   AS GL_1,
       s2.GL_2   AS GL_2,
       COALESCE(s2.GL_2-s1.GL_1,s2.GL_2,-s1.GL_1)  AS GL_DIFF,
       s1.DL_1   AS DL_1,
       s2.DL_2   AS DL_2,
       COALESCE(s2.DL_2-s1.DL_1,s2.DL_2,-s1.DL_1)  AS DL_DIFF,
       s1.WI_1   AS WI_1,
       s2.WI_2   AS WI_2,
       COALESCE(s2.WI_2-s1.WI_1,s2.WI_2,-s1.WI_1)  AS WI_DIFF,
       s1.GI_1   AS GI_1,
       s2.GI_2   AS GI_2,
       COALESCE(s2.GI_2-s1.GI_1,s2.GI_2,-s1.GI_1)  AS GI_DIFF,
       s1.SI_1   AS SI_1,
       s2.SI_2   AS SI_2,
       COALESCE(s2.SI_2-s1.SI_1,s2.SI_2,-s1.SI_1)  AS SI_DIFF,
       s1.CI_1   AS CI_1,
       s2.CI_2   AS CI_2,
       COALESCE(s2.CI_2-s1.CI_1,s2.CI_2,-s1.CI_1)  AS CI_DIFF,
       NULL AS RECORD_STATUS,
       NULL AS CREATED_BY,
       NULL AS CREATED_DATE,
       NULL AS LAST_UPDATED_BY,
       NULL AS LAST_UPDATED_DATE,
       NULL AS REV_NO,
       NULL AS REV_TEXT
FROM  (SELECT FORECAST_ID, OBJECT_ID, MONTH AS MONTH_1, VARIABLE_CODE AS VARIABLE_CODE_1, VARIABLE_NAME AS VARIABLE_NAME_1, SORT_ORDER AS SORT_ORDER_1, OIL AS OIL_1, GAS AS GAS_1, WAT AS WAT_1, COND AS COND_1, GL AS GL_1, DL AS DL_1, WI AS WI_1, GI AS GI_1, SI AS SI_1, CI AS CI_1
       FROM TABLE(EcBp_Forecast_Prod.getGrpFcstVarDataMonth('SCENARIO_1'))) s1
FULL OUTER JOIN
      (SELECT FORECAST_ID, OBJECT_ID, MONTH AS MONTH_2, VARIABLE_CODE AS VARIABLE_CODE_2, VARIABLE_NAME AS VARIABLE_NAME_2, SORT_ORDER AS SORT_ORDER_2, OIL AS OIL_2, GAS AS GAS_2, WAT AS WAT_2, COND AS COND_2, GL AS GL_2, DL AS DL_2, WI AS WI_2, GI AS GI_2, SI AS SI_2, CI AS CI_2
       FROM TABLE(EcBp_Forecast_Prod.getGrpFcstVarDataMonth('SCENARIO_2'))) s2
ON  s1.VARIABLE_CODE_1 = s2.VARIABLE_CODE_2
AND s1.MONTH_1 = s2.month_2
ORDER BY SORT_ORDER