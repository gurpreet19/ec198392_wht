CREATE OR REPLACE FORCE EDITIONABLE VIEW "V_FCST_STORAGE_YEAR" ("DAYTIME", "CLASS_NAME", "OBJECT_ID", "FORECAST_ID", "RECORD_STATUS", "CREATED_BY", "CREATED_DATE", "LAST_UPDATED_BY", "LAST_UPDATED_DATE", "REV_NO", "REV_TEXT") AS 
  (
----------------------------------------------------------------------------------------------------
-- File name v_fcst_storage_year.sql
-- View name v_fcst_storage_year.
--
-- $Revision: 1.1 $
--
-- Purpose : Get cargo calendar details for Berth Slot Calendar
--
-- Modification history
--
-- 	Date       	Whom  		Change description
-- 	---------- 	--------	--------------------------------------------------------------------------------
--  11.01.2015  thotesan    ECPD-31109: Initial version
------------------------------------------------------------------------------------------------------------
SELECT distinct (trunc(f.DAYTIME, 'YEAR')) DAYTIME,
                fc.class_name as CLASS_NAME,
                f.OBJECT_ID as OBJECT_ID,
                f.FORECAST_ID as FORECAST_ID,
                NULL as RECORD_STATUS,
                NULL as CREATED_BY,
                NULL as CREATED_DATE,
                NULL as LAST_UPDATED_BY,
                NULL as LAST_UPDATED_DATE,
                NULL as REV_NO,
                NULL as REV_TEXT
  from STOR_DAY_FCST_FCAST f, FORECAST fc
 where fc.class_name = 'FORECAST_TRAN_CP'
   AND f.forecast_id = fc.object_id
   AND NVL(fc.storage_id, f.object_id) = f.object_id
)