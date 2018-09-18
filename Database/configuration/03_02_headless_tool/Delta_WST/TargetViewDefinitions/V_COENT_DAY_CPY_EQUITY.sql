CREATE OR REPLACE FORCE VIEW "V_COENT_DAY_CPY_EQUITY" ("OBJECT_ID", "COMPANY_ID", "DAYTIME", "ECO_SHARE", "RECORD_STATUS", "CREATED_BY", "CREATED_DATE", "LAST_UPDATED_BY", "LAST_UPDATED_DATE", "REV_NO", "REV_TEXT") AS 
  (
-------------------------------------------------------------------------------------
--  V_COENT_DAY_CPY_EQUITY
--
-- $Revision: 1.1 $
--
--  Purpose: Present the commercial entity and company in equity share
--
--  Note:
-------------------------------------------------------------------------------------
SELECT 	e.object_id,
		e.company_id,
		sd.daytime,
		e.eco_share,
		e.record_status,
		e.created_by,
		e.created_date,
		e.last_updated_by,
		e.last_updated_date,
		e.rev_no,
		e.rev_text
FROM  commercial_entity ce,
      equity_share e,
      company c,
      system_days sd
WHERE e.object_id = ce.object_id
      AND e.company_id = c.object_id
      AND sd.daytime >= e.daytime
      AND sd.daytime <= nvl(e.end_date, sd.daytime)
)