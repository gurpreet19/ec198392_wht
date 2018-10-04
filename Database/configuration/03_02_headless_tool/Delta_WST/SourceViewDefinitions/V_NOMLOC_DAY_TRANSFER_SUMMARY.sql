CREATE OR REPLACE FORCE EDITIONABLE VIEW "V_NOMLOC_DAY_TRANSFER_SUMMARY" ("OBJECT_ID", "DAYTIME", "NOMINATION_TYPE", "REQUESTED_QTY", "RECORD_STATUS", "CREATED_BY", "CREATED_DATE", "LAST_UPDATED_BY", "LAST_UPDATED_DATE", "REV_NO", "REV_TEXT") AS 
  (
---------------------------------------------------------------------------------------------------
-- File name v_nomloc_day_transfer_summary.sql
-- View name v_nomloc_day_transfer_summary
--
-- $Revision: 1.1 $
--
-- Purpose
-- Will sum up requested transfer quantity for the nomination point.
--
-- Modification history
--
-- Date        Whom     Change description
-- ----------- -------- ---------------------------------------------------------------------------
-- 12 Dec 2013 farhaann	ECPD-26073: New business function: GD.0115 - Gas Day Summary
----------------------------------------------------------------------------------------------------
select
  nvl(np.exit_location_id, np.entry_location_id) OBJECT_ID,
  t.daytime DAYTIME,
  t.nomination_type,
  sum(requested_qty) REQUESTED_QTY,
  to_char('P') record_status,
  to_char(null) created_by,
  to_date(null, 'yyyy-mm-dd') created_date,
  to_char(null) last_updated_by,
  to_date(null, 'yyyy-mm-dd') last_updated_date,
  to_number(null) rev_no,
  to_char(null) rev_text
from nompnt_day_transfer t, nomination_point np
where t.object_id = np.object_id
and np.start_date <= t.daytime
and (np.end_date is null or np.end_date < t.daytime)
group by np.exit_location_id, np.entry_location_id, t.daytime, t. nomination_type
)