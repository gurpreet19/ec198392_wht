CREATE OR REPLACE FORCE EDITIONABLE VIEW "V_FCST_CARGO_PLAN_NAVIGATOR" ("CARGO_NO", "CARGO_NAME", "FORECAST_ID", "OBJECT_ID", "DELETED_IND", "CARGO_STATUS", "CARRIER_ID", "RECORD_STATUS", "CREATED_BY", "CREATED_DATE", "LAST_UPDATED_BY", "LAST_UPDATED_DATE", "REV_NO", "REV_TEXT") AS 
  (
/**************************************************************
** Script:	v_fcst_cargo_plan_navigator.SQL
**
** $Revision: 1.3 $
**
** Purpose:
**
** General Logic:
**
** Created:   06.06.2008  Solveig I. Monsen
**
**
-- Modification history:
--
-- Date       Whom     Change description:
-- ---------- -------  --------------------------------------------------------------------------------
**************************************************************/
SELECT c.cargo_no,
       c.cargo_name,
       c.forecast_id,
       n.object_id,
	   n.deleted_ind,
       c.cargo_status,
       c.carrier_id,
       to_char(null) record_status,
	   to_char(null) created_by,
	   to_date(null) created_date,
	   to_char(null) last_updated_by,
	   to_date(null) last_updated_date,
	   to_number(null) rev_no,
	   to_char(null) rev_text
FROM	cargo_fcst_transport c,
     	stor_fcst_lift_nom n
WHERE	c.cargo_no = n.cargo_no AND c.forecast_id = n.forecast_id
GROUP BY c.cargo_no,
       c.cargo_name,
       c.forecast_id,
       n.object_id,
       n.deleted_ind,
       c.cargo_status,
       c.carrier_id,
       c.record_status,
       c.rev_text,
       c.rev_no,
       c.created_by,
       c.created_date,
       c.last_updated_by,
       c.last_updated_date
)