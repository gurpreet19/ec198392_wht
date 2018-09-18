CREATE OR REPLACE FORCE EDITIONABLE VIEW "V_CARGO_FILTER_NAVIGATOR" ("CARGO_NO", "CARGO_NAME", "OBJECT_ID", "CARGO_STATUS", "CARRIER_ID", "FROM_NOM_DATE", "TO_NOM_DATE", "RECORD_STATUS", "CREATED_BY", "CREATED_DATE", "LAST_UPDATED_BY", "LAST_UPDATED_DATE", "REV_NO", "REV_TEXT") AS 
  (
/**************************************************************
** Script:	v_cargo_filter_navigator.SQL
**
** $Revision: 1.3 $
**
** Purpose:
**
** General Logic:
**
** Created:   08.06.2007  Kari Sandvik
**
**
-- Modification history:
--
-- Date       Whom     Change description:
-- ---------- -------  --------------------------------------------------------------------------------
-- 08-04-2008 musaamah ECPD-7253: Add column contract_id for Cargo Navigator to enable ringfencing.
-- 17-10-2016 asareswi ECPD-32545: Added to_nom_date,from_nom_date column to improve the performance of query
**************************************************************/
SELECT c.cargo_no,
       c.cargo_name,
       n.object_id,
       c.cargo_status,
       c.carrier_id,
       mindate from_nom_date,
       maxdate to_nom_date,
	   to_char(null) record_status,
	   to_char(null) created_by,
	   to_date(null) created_date,
	   to_char(null) last_updated_by,
	   to_date(null) last_updated_date,
	   to_number(null) rev_no,
	   to_char(null) rev_text
FROM	cargo_transport c,
     	storage_lift_nomination n,
		(select min(nom_firm_date) mindate, max(nom_firm_date) maxdate, cargo_no from storage_lift_nomination sln group by cargo_no) s
WHERE	c.cargo_no = n.cargo_no
		and s.cargo_no = c.cargo_no
GROUP BY c.cargo_no,
       c.cargo_name,
       n.object_id,
       c.cargo_status,
       c.carrier_id,
       mindate,
       maxdate,
       c.record_status,
       c.rev_text,
       c.rev_no,
       c.created_by,
       c.created_date,
       c.last_updated_by,
       c.last_updated_date
)