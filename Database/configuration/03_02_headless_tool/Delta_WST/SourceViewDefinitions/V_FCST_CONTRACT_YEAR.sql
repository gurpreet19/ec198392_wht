CREATE OR REPLACE FORCE EDITIONABLE VIEW "V_FCST_CONTRACT_YEAR" ("DAYTIME", "CLASS_NAME", "OBJECT_ID", "FORECAST_ID", "RECORD_STATUS", "CREATED_BY", "CREATED_DATE", "LAST_UPDATED_BY", "LAST_UPDATED_DATE", "REV_NO", "REV_TEXT") AS 
  (
---------------------------------------------------------------------------------------------------
-- File name v_fcst_contract_year.sql
-- View name v_fcst_contract_year
--
-- $Revision: 1.1 $
--
-- Purpose
-- To return rows by contract and year.
-- Modification history
--
-- 	Date       	Whom      	Change description
-- 	--------- 	--------  	----------------------------------------------------------------------------
--	16.12.2013 	muhammah	ECPD-26100: New business function: Forecast Contract KPI Monitoring
----------------------------------------------------------------------------------------------------
select
distinct(trunc(f.DAYTIME,'YEAR')) DAYTIME,
fc.class_name as CLASS_NAME,
c.OBJECT_ID as OBJECT_ID,
f.FORECAST_ID as FORECAST_ID,
NULL as RECORD_STATUS,
NULL as CREATED_BY,
NULL as CREATED_DATE,
NULL as LAST_UPDATED_BY,
NULL as LAST_UPDATED_DATE,
NULL as REV_NO,
NULL as REV_TEXT
from CONTRACT c,STOR_DAY_FCST_FCAST f, FORECAST fc
where fc.class_name='FORECAST_TRAN_CP' and c.start_date <= trunc(f.DAYTIME,'YEAR') and (c.end_date > trunc(f.DAYTIME,'YEAR') or c.end_date IS NULL)
)