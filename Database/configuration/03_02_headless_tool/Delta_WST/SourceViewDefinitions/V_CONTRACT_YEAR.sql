CREATE OR REPLACE FORCE EDITIONABLE VIEW "V_CONTRACT_YEAR" ("DAYTIME", "OBJECT_ID", "RECORD_STATUS", "CREATED_BY", "CREATED_DATE", "LAST_UPDATED_BY", "LAST_UPDATED_DATE", "REV_NO", "REV_TEXT") AS 
  (
---------------------------------------------------------------------------------------------------
-- File name v_contract_year.sql
-- View name v_contract_year
--
-- $Revision: 1.2 $
--
-- Purpose
-- To return rows by contract and year.
-- Modification history
--
-- Date       Whom      Change description
-- ---------- ----      ----------------------------------------------------------------------------
--12 Dec 2012 muhammah	ECPD-20117: New business function: CP.0027 - Contract KPI Monitoring
--30 Sep 2013 leeeewei  ECPD-25563: Modified where clause
----------------------------------------------------------------------------------------------------
select
	distinct(trunc(f.DAYTIME,'YEAR')) DAYTIME,
	c.OBJECT_ID as OBJECT_ID,
	NULL as RECORD_STATUS,
	NULL as CREATED_BY,
	NULL as CREATED_DATE,
	NULL as LAST_UPDATED_BY,
	NULL as LAST_UPDATED_DATE,
	NULL as REV_NO,
	NULL as REV_TEXT
from CONTRACT c,STOR_DAY_FORECAST f
where c.start_date <= trunc(f.DAYTIME,'YEAR')  and (c.end_date > trunc(f.DAYTIME,'YEAR') or c.end_date IS NULL)
)