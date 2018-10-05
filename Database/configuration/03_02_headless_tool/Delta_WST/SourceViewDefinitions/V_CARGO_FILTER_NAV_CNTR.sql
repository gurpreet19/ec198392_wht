CREATE OR REPLACE FORCE EDITIONABLE VIEW "V_CARGO_FILTER_NAV_CNTR" ("CARGO_NO", "CARGO_NAME", "FROM_NOM_DATE", "TO_NOM_DATE", "OBJECT_ID", "LIFTING_ACCOUNT_ID", "CARGO_STATUS", "CARRIER_ID", "CONTRACT_ID", "RECORD_STATUS", "REV_TEXT", "REV_NO", "CREATED_BY", "CREATED_DATE", "LAST_UPDATED_BY", "LAST_UPDATED_DATE") AS 
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
-- 17-10-2016 asareswi ECPD-32545: Added to_nom_date,from_nom_date column to improve the performance of query
**************************************************************/
SELECT c.cargo_no,
       c.cargo_name,
       mindate from_nom_date,
	   maxdate to_nom_date,
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
     	storage_lift_nomination n,
		(select min(nom_firm_date) mindate, max(nom_firm_date) maxdate, cargo_no from storage_lift_nomination sln group by cargo_no) s
WHERE	c.cargo_no = n.cargo_no
AND   	s.cargo_no = c.cargo_no
GROUP BY c.cargo_no,
       c.cargo_name,
       mindate,
	   maxdate,
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