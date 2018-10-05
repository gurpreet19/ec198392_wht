CREATE OR REPLACE FORCE EDITIONABLE VIEW "V_BU_DAY_SUMMARY" ("OBJECT_ID", "DAYTIME", "RECORD_STATUS", "CREATED_BY", "CREATED_DATE", "LAST_UPDATED_BY", "LAST_UPDATED_DATE", "REV_NO", "REV_TEXT") AS 
  (
---------------------------------------------------------------------------------------------------
-- File name v_bu_day_summary.sql
-- View name v_bu_day_summary
--
-- $Revision: 1.2 $
--
-- Purpose
-- Will show one gas day summary per day per business unit.
--
-- Modification history
--
-- Date       Whom      Change description
-- ---------- --------  ----------------------------------------------------------------------------
--12 Dec 2013 farhaann	ECPD-26073: New business function: GD.0115 - Gas Day Summary
----------------------------------------------------------------------------------------------------
select
  bu.object_id OBJECT_ID,
  sd.daytime DAYTIME,
  to_char('P') record_status,
  to_char(null) created_by,
  to_date(null, 'yyyy-mm-dd') created_date,
  to_char(null) last_updated_by,
  to_date(null, 'yyyy-mm-dd') last_updated_date,
  to_number(null) rev_no,
  to_char(null) rev_text
from business_unit bu, system_days sd
where bu.start_date <= sd.daytime
and (bu.end_date is null or bu.end_date < sd.daytime)
)