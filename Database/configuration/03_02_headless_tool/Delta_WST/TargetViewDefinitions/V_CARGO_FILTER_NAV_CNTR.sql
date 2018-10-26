CREATE OR REPLACE FORCE VIEW "V_CARGO_FILTER_NAV_CNTR" ("CARGO_NO", "CARGO_NAME", "OBJECT_ID", "LIFTING_ACCOUNT_ID", "CARGO_STATUS", "CARRIER_ID", "CONTRACT_ID", "RECORD_STATUS", "REV_TEXT", "REV_NO", "CREATED_BY", "CREATED_DATE", "LAST_UPDATED_BY", "LAST_UPDATED_DATE") AS 
  (
/**************************************************************
** Script:	v_cargo_filter_nav_cntr.SQL
**
** $Revision: 1.1 $
**
** Purpose:
**
** General Logic:
**
** Created:   03.09.2008  masamken
**
**
-- Modification history:
--
-- Date       Whom     Change description:
-- ---------- -------  --------------------------------------------------------------------------------
--
**************************************************************/
SELECT c.cargo_no,
       c.cargo_name,
       n.object_id,
       n.lifting_account_id,
       c.cargo_status,
       c.carrier_id,
       n.contract_id,
       c.record_status,
       c.rev_text,
       c.rev_no,
       c.created_by,
       c.created_date,
       c.last_updated_by,
       c.last_updated_date
FROM	cargo_transport c,
     	storage_lift_nomination n
WHERE	c.cargo_no = n.cargo_no
GROUP BY c.cargo_no,
       c.cargo_name,
       n.object_id,
       n.lifting_account_id,
       c.cargo_status,
       n.contract_id,
       c.carrier_id,
       c.record_status,
       c.rev_text,
       c.rev_no,
       c.created_by,
       c.created_date,
       c.last_updated_by,
       c.last_updated_date
)