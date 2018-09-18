CREATE OR REPLACE FORCE EDITIONABLE VIEW "V_FCST_SUMM_PHASES" ("PHASE_CODE", "PHASE_NAME", "SORT_ORDER", "RECORD_STATUS", "CREATED_BY", "CREATED_DATE", "LAST_UPDATED_BY", "LAST_UPDATED_DATE", "REV_NO", "REV_TEXT") AS 
  (
----------------------------------------------------------------------------------------------------
-- File name: V_FCST_SUMM_PHASES.SQL
-- View name: V_FCST_SUMM_PHASES
--
-- $Revision: 1.3 $
--
-- Purpose  : The phases being used for the Forecast Summary
--
-- Modification history:
--
-- Date       Whom      Change description:
-- ---------- ----      --------------------------------------------------------------------------------
-- 2016-08-23 kashisag  ECPD-37329 : Initial version
-- 2016-09-28 leongwen  ECPD-39970 : Changed the phase sorting of Water after Cond
----------------------------------------------------------------------------------------------------
SELECT  'OIL'                       AS PHASE_CODE,
        'Oil'                       AS PHASE_NAME,
        1                           AS SORT_ORDER,
        TO_CHAR(NULL)               AS RECORD_STATUS,
        TO_CHAR(NULL)               AS CREATED_BY,
        TO_DATE(NULL)               AS CREATED_DATE,
        TO_CHAR(NULL)               AS LAST_UPDATED_BY,
        TO_DATE(NULL)               AS LAST_UPDATED_DATE,
        TO_NUMBER(NULL)             AS REV_NO,
        TO_CHAR(NULL)               AS REV_TEXT
FROM  CTRL_DB_VERSION
WHERE DB_VERSION=1
UNION
SELECT  'GAS'                       AS PHASE_CODE,
        'Gas'                       AS PHASE_NAME,
        2                           AS SORT_ORDER,
        TO_CHAR(NULL)               AS RECORD_STATUS,
        TO_CHAR(NULL)               AS CREATED_BY,
        TO_DATE(NULL)               AS CREATED_DATE,
        TO_CHAR(NULL)               AS LAST_UPDATED_BY,
        TO_DATE(NULL)               AS LAST_UPDATED_DATE,
        TO_NUMBER(NULL)             AS REV_NO,
        TO_CHAR(NULL)               AS REV_TEXT
FROM  CTRL_DB_VERSION
WHERE DB_VERSION=1
UNION
SELECT  'COND'                      AS PHASE_CODE,
        'Cond'                      AS PHASE_NAME,
        3                           AS SORT_ORDER,
        TO_CHAR(NULL)               AS RECORD_STATUS,
        TO_CHAR(NULL)               AS CREATED_BY,
        TO_DATE(NULL)               AS CREATED_DATE,
        TO_CHAR(NULL)               AS LAST_UPDATED_BY,
        TO_DATE(NULL)               AS LAST_UPDATED_DATE,
        TO_NUMBER(NULL)             AS REV_NO,
        TO_CHAR(NULL)               AS REV_TEXT
FROM  CTRL_DB_VERSION
WHERE DB_VERSION=1
UNION
SELECT  'WAT'                     AS PHASE_CODE,
        'Water'                     AS PHASE_NAME,
        4                           AS SORT_ORDER,
        TO_CHAR(NULL)               AS RECORD_STATUS,
        TO_CHAR(NULL)               AS CREATED_BY,
        TO_DATE(NULL)               AS CREATED_DATE,
        TO_CHAR(NULL)               AS LAST_UPDATED_BY,
        TO_DATE(NULL)               AS LAST_UPDATED_DATE,
        TO_NUMBER(NULL)             AS REV_NO,
        TO_CHAR(NULL)               AS REV_TEXT
FROM  CTRL_DB_VERSION
WHERE DB_VERSION=1
UNION
SELECT  'GL'                        AS PHASE_CODE,
        'Gas Lift'                  AS PHASE_NAME,
        5                           AS SORT_ORDER,
        TO_CHAR(NULL)               AS RECORD_STATUS,
        TO_CHAR(NULL)               AS CREATED_BY,
        TO_DATE(NULL)               AS CREATED_DATE,
        TO_CHAR(NULL)               AS LAST_UPDATED_BY,
        TO_DATE(NULL)               AS LAST_UPDATED_DATE,
        TO_NUMBER(NULL)             AS REV_NO,
        TO_CHAR(NULL)               AS REV_TEXT
FROM  CTRL_DB_VERSION
WHERE DB_VERSION=1
UNION
SELECT  'DL'                        AS PHASE_CODE,
        'Diluent'                   AS PHASE_NAME,
        6                           AS SORT_ORDER,
        TO_CHAR(NULL)               AS RECORD_STATUS,
        TO_CHAR(NULL)               AS CREATED_BY,
        TO_DATE(NULL)               AS CREATED_DATE,
        TO_CHAR(NULL)               AS LAST_UPDATED_BY,
        TO_DATE(NULL)               AS LAST_UPDATED_DATE,
        TO_NUMBER(NULL)             AS REV_NO,
        TO_CHAR(NULL)               AS REV_TEXT
FROM  CTRL_DB_VERSION
WHERE DB_VERSION=1
UNION
SELECT  'WI'                        AS PHASE_CODE,
        'Water Injection'           AS PHASE_NAME,
        7                           AS SORT_ORDER,
        TO_CHAR(NULL)               AS RECORD_STATUS,
        TO_CHAR(NULL)               AS CREATED_BY,
        TO_DATE(NULL)               AS CREATED_DATE,
        TO_CHAR(NULL)               AS LAST_UPDATED_BY,
        TO_DATE(NULL)               AS LAST_UPDATED_DATE,
        TO_NUMBER(NULL)             AS REV_NO,
        TO_CHAR(NULL)               AS REV_TEXT
FROM  CTRL_DB_VERSION
WHERE DB_VERSION=1
UNION
SELECT  'GI'                        AS PHASE_CODE,
        'Gas Injection'             AS PHASE_NAME,
        8                           AS SORT_ORDER,
        TO_CHAR(NULL)               AS RECORD_STATUS,
        TO_CHAR(NULL)               AS CREATED_BY,
        TO_DATE(NULL)               AS CREATED_DATE,
        TO_CHAR(NULL)               AS LAST_UPDATED_BY,
        TO_DATE(NULL)               AS LAST_UPDATED_DATE,
        TO_NUMBER(NULL)             AS REV_NO,
        TO_CHAR(NULL)               AS REV_TEXT
FROM  CTRL_DB_VERSION
WHERE DB_VERSION=1
UNION
SELECT  'SI'                        AS PHASE_CODE,
        'Steam Injection'           AS PHASE_NAME,
        9                           AS SORT_ORDER,
        TO_CHAR(NULL)               AS RECORD_STATUS,
        TO_CHAR(NULL)               AS CREATED_BY,
        TO_DATE(NULL)               AS CREATED_DATE,
        TO_CHAR(NULL)               AS LAST_UPDATED_BY,
        TO_DATE(NULL)               AS LAST_UPDATED_DATE,
        TO_NUMBER(NULL)             AS REV_NO,
        TO_CHAR(NULL)               AS REV_TEXT
FROM  CTRL_DB_VERSION
WHERE DB_VERSION=1
UNION
SELECT  'CI'              AS PHASE_CODE,
        'CO2 Injection'             AS PHASE_NAME,
        10                          AS SORT_ORDER,
        TO_CHAR(NULL)               AS RECORD_STATUS,
        TO_CHAR(NULL)               AS CREATED_BY,
        TO_DATE(NULL)               AS CREATED_DATE,
        TO_CHAR(NULL)               AS LAST_UPDATED_BY,
        TO_DATE(NULL)               AS LAST_UPDATED_DATE,
        TO_NUMBER(NULL)             AS REV_NO,
        TO_CHAR(NULL)               AS REV_TEXT
FROM  CTRL_DB_VERSION
WHERE DB_VERSION=1
) ORDER BY SORT_ORDER