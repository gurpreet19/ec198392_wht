CREATE OR REPLACE FORCE EDITIONABLE VIEW "V_TREND_ANALYSIS_CONFIG" ("OBJECT_ID", "RESULT_NO", "PRIMARY_IND", "DAYTIME", "TREND_ANALYSIS_IND", "TREND_RESET_IND", "RECORD_STATUS", "CREATED_BY", "CREATED_DATE", "LAST_UPDATED_BY", "LAST_UPDATED_DATE", "REV_NO", "REV_TEXT") AS 
  (
----------------------------------------------------------------------------------------------------
-- File name: v_trend_analysis_config.sql
-- View name: v_trend_analysis_config
--
-- $Revision: 1.0 $
--
-- Purpose  : Used to set trend analysis indicator in Trend Analysis screen second data section.
--
-- Modification history:
-- Date       Whom       Change description:
-- ---------- ----       --------------------------------------------------------------------------------
-- 08.21.2017 kashisag   ECPD-36645:Intial version
----------------------------------------------------------------------------------------------------
SELECT OBJECT_ID,
       RESULT_NO,
       PRIMARY_IND,
       DAYTIME,
       TREND_ANALYSIS_IND,
	   TREND_RESET_IND,
       'P' AS RECORD_STATUS  ,
       CREATED_BY  ,
       CREATED_DATE ,
       LAST_UPDATED_BY,
       LAST_UPDATED_DATE,
       REV_NO  ,
       REV_TEXT
 FROM PWEL_RESULT
WHERE PRIMARY_IND='Y'
)