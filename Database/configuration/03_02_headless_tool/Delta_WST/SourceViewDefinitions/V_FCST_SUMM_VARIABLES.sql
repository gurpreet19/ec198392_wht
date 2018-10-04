CREATE OR REPLACE FORCE EDITIONABLE VIEW "V_FCST_SUMM_VARIABLES" ("VARIABLE_CODE", "VARIABLE_NAME", "SORT_ORDER", "RECORD_STATUS", "CREATED_BY", "CREATED_DATE", "LAST_UPDATED_BY", "LAST_UPDATED_DATE", "REV_NO", "REV_TEXT") AS 
  (
----------------------------------------------------------------------------------------------------
-- File name: V_FCST_SUMM_VARIABLES.SQL
-- View name: V_FCST_SUMM_VARIABLES
--
-- Purpose  : The variables being used for the Forecast Summary
--
-- Modification history:
--
-- Date       Whom      Change description:
-- ---------- ----      --------------------------------------------------------------------------------
-- 2016-08-23 leongwen  ECPD-37329 : Initial version
--------------------------------------------------------------------------------------------------------
SELECT  'POT_UNCONSTR'              AS VARIABLE_CODE,
        'Unconstrained Potential'   AS VARIABLE_NAME,
        1                           AS SORT_ORDER,
        TO_CHAR(NULL)               AS RECORD_STATUS,
        TO_CHAR(NULL)               AS CREATED_BY,
        TO_DATE(NULL)               AS CREATED_DATE,
        TO_CHAR(NULL)               AS LAST_UPDATED_BY,
        TO_DATE(NULL)               AS LAST_UPDATED_DATE,
        TO_NUMBER(NULL)             AS REV_NO,
        TO_CHAR(NULL)               AS REV_TEXT
FROM CTRL_DB_VERSION
WHERE DB_VERSION=1
UNION
SELECT  'CONSTRAINTS'               AS VARIABLE_CODE,
        'Constraints'               AS VARIABLE_NAME,
        2                           AS SORT_ORDER,
        TO_CHAR(NULL)               AS RECORD_STATUS,
        TO_CHAR(NULL)               AS CREATED_BY,
        TO_DATE(NULL)               AS CREATED_DATE,
        TO_CHAR(NULL)               AS LAST_UPDATED_BY,
        TO_DATE(NULL)               AS LAST_UPDATED_DATE,
        TO_NUMBER(NULL)             AS REV_NO,
        TO_CHAR(NULL)               AS REV_TEXT
FROM CTRL_DB_VERSION
WHERE DB_VERSION=1
UNION
SELECT  'POT_CONSTR'                AS VARIABLE_CODE,
        'Constrained Potential'     AS VARIABLE_NAME,
        3                           AS SORT_ORDER,
        TO_CHAR(NULL)               AS RECORD_STATUS,
        TO_CHAR(NULL)               AS CREATED_BY,
        TO_DATE(NULL)               AS CREATED_DATE,
        TO_CHAR(NULL)               AS LAST_UPDATED_BY,
        TO_DATE(NULL)               AS LAST_UPDATED_DATE,
        TO_NUMBER(NULL)             AS REV_NO,
        TO_CHAR(NULL)               AS REV_TEXT
FROM CTRL_DB_VERSION
WHERE DB_VERSION=1
UNION
SELECT  'S1P_SHORTFALL'             AS VARIABLE_CODE,
        'Planned Shortfall'         AS VARIABLE_NAME,
        4                           AS SORT_ORDER,
        TO_CHAR(NULL)               AS RECORD_STATUS,
        TO_CHAR(NULL)               AS CREATED_BY,
        TO_DATE(NULL)               AS CREATED_DATE,
        TO_CHAR(NULL)               AS LAST_UPDATED_BY,
        TO_DATE(NULL)               AS LAST_UPDATED_DATE,
        TO_NUMBER(NULL)             AS REV_NO,
        TO_CHAR(NULL)               AS REV_TEXT
FROM CTRL_DB_VERSION
WHERE DB_VERSION=1
UNION
SELECT  'S1U_SHORTFALL'             AS VARIABLE_CODE,
        'Unplanned Shortfall'       AS VARIABLE_NAME,
        5                           AS SORT_ORDER,
        TO_CHAR(NULL)               AS RECORD_STATUS,
        TO_CHAR(NULL)               AS CREATED_BY,
        TO_DATE(NULL)               AS CREATED_DATE,
        TO_CHAR(NULL)               AS LAST_UPDATED_BY,
        TO_DATE(NULL)               AS LAST_UPDATED_DATE,
        TO_NUMBER(NULL)             AS REV_NO,
        TO_CHAR(NULL)               AS REV_TEXT
FROM CTRL_DB_VERSION
WHERE DB_VERSION=1
UNION
SELECT  'S2_SHORTFALL'              AS VARIABLE_CODE,
        'Non Op Shortfall'          AS VARIABLE_NAME,
        6                           AS SORT_ORDER,
        TO_CHAR(NULL)               AS RECORD_STATUS,
        TO_CHAR(NULL)               AS CREATED_BY,
        TO_DATE(NULL)               AS CREATED_DATE,
        TO_CHAR(NULL)               AS LAST_UPDATED_BY,
        TO_DATE(NULL)               AS LAST_UPDATED_DATE,
        TO_NUMBER(NULL)             AS REV_NO,
        TO_CHAR(NULL)               AS REV_TEXT
FROM CTRL_DB_VERSION
WHERE DB_VERSION=1
UNION
SELECT  'INJ'                       AS VARIABLE_CODE,
        'Injection'                 AS VARIABLE_NAME,
        7                           AS SORT_ORDER,
        TO_CHAR(NULL)               AS RECORD_STATUS,
        TO_CHAR(NULL)               AS CREATED_BY,
        TO_DATE(NULL)               AS CREATED_DATE,
        TO_CHAR(NULL)               AS LAST_UPDATED_BY,
        TO_DATE(NULL)               AS LAST_UPDATED_DATE,
        TO_NUMBER(NULL)             AS REV_NO,
        TO_CHAR(NULL)               AS REV_TEXT
FROM CTRL_DB_VERSION
WHERE DB_VERSION=1
UNION
SELECT  'INT_CONSUMPT'              AS VARIABLE_CODE,
        'Internal Consumption'      AS VARIABLE_NAME,
        8                           AS SORT_ORDER,
        TO_CHAR(NULL)               AS RECORD_STATUS,
        TO_CHAR(NULL)               AS CREATED_BY,
        TO_DATE(NULL)               AS CREATED_DATE,
        TO_CHAR(NULL)               AS LAST_UPDATED_BY,
        TO_DATE(NULL)               AS LAST_UPDATED_DATE,
        TO_NUMBER(NULL)             AS REV_NO,
        TO_CHAR(NULL)               AS REV_TEXT
FROM CTRL_DB_VERSION
WHERE DB_VERSION=1
UNION
SELECT  'LOSSES'                    AS VARIABLE_CODE,
        'Losses'                    AS VARIABLE_NAME,
        9                           AS SORT_ORDER,
        TO_CHAR(NULL)               AS RECORD_STATUS,
        TO_CHAR(NULL)               AS CREATED_BY,
        TO_DATE(NULL)               AS CREATED_DATE,
        TO_CHAR(NULL)               AS LAST_UPDATED_BY,
        TO_DATE(NULL)               AS LAST_UPDATED_DATE,
        TO_NUMBER(NULL)             AS REV_NO,
        TO_CHAR(NULL)               AS REV_TEXT
FROM CTRL_DB_VERSION
WHERE DB_VERSION=1
UNION
SELECT  'COMPENSATION'              AS VARIABLE_CODE,
        'Compensation'              AS VARIABLE_NAME,
        10                          AS SORT_ORDER,
        TO_CHAR(NULL)               AS RECORD_STATUS,
        TO_CHAR(NULL)               AS CREATED_BY,
        TO_DATE(NULL)               AS CREATED_DATE,
        TO_CHAR(NULL)               AS LAST_UPDATED_BY,
        TO_DATE(NULL)               AS LAST_UPDATED_DATE,
        TO_NUMBER(NULL)             AS REV_NO,
        TO_CHAR(NULL)               AS REV_TEXT
FROM CTRL_DB_VERSION
WHERE DB_VERSION=1
UNION
SELECT  'AVAIL_EXPORT'              AS VARIABLE_CODE,
        'Available for Export'      AS VARIABLE_NAME,
        11                          AS SORT_ORDER,
        TO_CHAR(NULL)               AS RECORD_STATUS,
        TO_CHAR(NULL)               AS CREATED_BY,
        TO_DATE(NULL)               AS CREATED_DATE,
        TO_CHAR(NULL)               AS LAST_UPDATED_BY,
        TO_DATE(NULL)               AS LAST_UPDATED_DATE,
        TO_NUMBER(NULL)             AS REV_NO,
        TO_CHAR(NULL)               AS REV_TEXT
FROM CTRL_DB_VERSION
WHERE DB_VERSION=1
) ORDER BY SORT_ORDER