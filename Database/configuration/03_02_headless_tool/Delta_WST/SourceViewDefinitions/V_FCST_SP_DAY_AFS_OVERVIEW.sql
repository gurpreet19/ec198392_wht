CREATE OR REPLACE FORCE EDITIONABLE VIEW "V_FCST_SP_DAY_AFS_OVERVIEW" ("AFS_SEQ", "OBJECT_ID", "DAYTIME", "TRANSACTION_TYPE", "ACTUAL_QTY", "AVAIL_GRS_QTY", "AVAIL_ADJ_QTY", "AVAIL_NET_QTY", "FORECAST_ID", "VALUE_1", "VALUE_2", "VALUE_3", "VALUE_4", "VALUE_5", "VALUE_6", "VALUE_7", "VALUE_8", "VALUE_9", "VALUE_10", "VALUE_11", "VALUE_12", "VALUE_13", "VALUE_14", "VALUE_15", "VALUE_16", "VALUE_17", "VALUE_18", "VALUE_19", "VALUE_20", "VALUE_21", "VALUE_22", "VALUE_23", "VALUE_24", "VALUE_25", "VALUE_26", "VALUE_27", "VALUE_28", "VALUE_29", "VALUE_30", "TEXT_1", "TEXT_2", "TEXT_3", "TEXT_4", "TEXT_5", "TEXT_6", "TEXT_7", "TEXT_8", "TEXT_9", "TEXT_10", "TEXT_11", "TEXT_12", "TEXT_13", "TEXT_14", "TEXT_15", "DATE_1", "DATE_2", "DATE_3", "DATE_4", "DATE_5", "COMPANY_ID", "COMPANY_VALUE", "RECORD_STATUS", "CREATED_BY", "CREATED_DATE", "LAST_UPDATED_BY", "LAST_UPDATED_DATE", "REV_NO", "REV_TEXT") AS 
  (
----------------------------------------------------------------------------------------------------
-- File name: v_fcst_sp_day_afs_overview.sql
-- View name: v_fcst_sp_day_afs_overview
--
-- $Revision: 1.1.2.2 $
--
-- Purpose  : Use as source for classes used to present producer as a cross tab.
--          : There is also a trigger behind this view making it possible to do updates.
--
-- Modification history:
--
-- Date       Whom      Change description:
-- ---------- --------  --------------------------------------------------------------------------------
-- 27.02.2015 farhaann  ECPD-30121: Initial version
----------------------------------------------------------------------------------------------------
SELECT a.AFS_SEQ,
	   a.OBJECT_ID,
       a.DAYTIME,
       a.TRANSACTION_TYPE,
       a.ACTUAL_QTY,
       a.AVAIL_GRS_QTY,
       a.AVAIL_ADJ_QTY,
       a.AVAIL_NET_QTY,
       a.FORECAST_ID,
       a.VALUE_1  VALUE_1,
       a.VALUE_2  VALUE_2,
       a.VALUE_3  VALUE_3,
       a.VALUE_4  VALUE_4,
       a.VALUE_5  VALUE_5,
       a.VALUE_6  VALUE_6,
       a.VALUE_7  VALUE_7,
       a.VALUE_8  VALUE_8,
       a.VALUE_9  VALUE_9,
       a.VALUE_10 VALUE_10,
       a.VALUE_11 VALUE_11,
       a.VALUE_12 VALUE_12,
       a.VALUE_13 VALUE_13,
       a.VALUE_14 VALUE_14,
       a.VALUE_15 VALUE_15,
       a.VALUE_16 VALUE_16,
       a.VALUE_17 VALUE_17,
       a.VALUE_18 VALUE_18,
       a.VALUE_19 VALUE_19,
       a.VALUE_20 VALUE_20,
       a.VALUE_21 VALUE_21,
       a.VALUE_22 VALUE_22,
       a.VALUE_23 VALUE_23,
       a.VALUE_24 VALUE_24,
       a.VALUE_25 VALUE_25,
       a.VALUE_26 VALUE_26,
       a.VALUE_27 VALUE_27,
       a.VALUE_28 VALUE_28,
       a.VALUE_29 VALUE_29,
       a.VALUE_30 VALUE_30,
       a.TEXT_1  TEXT_1,
       a.TEXT_2  TEXT_2,
       a.TEXT_3  TEXT_3,
       a.TEXT_4  TEXT_4,
       a.TEXT_5  TEXT_5,
       a.TEXT_6  TEXT_6,
       a.TEXT_7  TEXT_7,
       a.TEXT_8  TEXT_8,
       a.TEXT_9  TEXT_9,
       a.TEXT_10 TEXT_10,
       a.TEXT_11 TEXT_11,
       a.TEXT_12 TEXT_12,
       a.TEXT_13 TEXT_13,
       a.TEXT_14 TEXT_14,
       a.TEXT_15 TEXT_15,
       a.DATE_1  DATE_1,
       a.DATE_2  DATE_2,
       a.DATE_3  DATE_3,
       a.DATE_4  DATE_4,
       a.DATE_5  DATE_5,
       b.COMPANY_ID AS COMPANY_ID,
       b.AVAIL_NET_QTY AS COMPANY_VALUE,
       b.RECORD_STATUS,
       b.CREATED_BY,
       b.CREATED_DATE,
       b.LAST_UPDATED_BY,
       b.LAST_UPDATED_DATE,
       b.REV_NO,
       b.REV_TEXT
  FROM FCST_SP_DAY_AFS a, FCST_SP_DAY_CPY_AFS b
 WHERE a.OBJECT_ID        = b.OBJECT_ID
   AND a.FORECAST_ID      = b.FORECAST_ID
   AND a.DAYTIME          = b.DAYTIME
   AND a.TRANSACTION_TYPE = b.TRANSACTION_TYPE
)