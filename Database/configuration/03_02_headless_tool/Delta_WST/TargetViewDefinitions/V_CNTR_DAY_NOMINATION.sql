CREATE OR REPLACE FORCE VIEW "V_CNTR_DAY_NOMINATION" ("OBJECT_ID", "DAYTIME", "LOCATION_ID", "NOM_CYCLE_CODE", "OPER_NOM_IND", "RECORD_STATUS", "CREATED_BY", "CREATED_DATE", "LAST_UPDATED_BY", "LAST_UPDATED_DATE", "REV_NO", "REV_TEXT") AS 
  (
----------------------------------------------------------------------------------------------------
-- File name v_cntr_day_nomination.sql
-- View name v_cntr_day_nomination.
--
--
--
-- Purpose
--
-- Modification history
--
-- Date       Whom  Change description
-- ---------- ----  --------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
SELECT
       c.contract_id as OBJECT_ID,
       c.daytime,
       c.entry_location_id location_id,
       c.nom_cycle_code,
       nvl(c.oper_nom_ind, 'N') as OPER_NOM_IND,
       NULL AS RECORD_STATUS,
       NULL AS CREATED_BY,
       NULL AS CREATED_DATE,
       NULL AS LAST_UPDATED_BY,
       NULL AS LAST_UPDATED_DATE,
       NULL AS REV_NO,
       NULL AS REV_TEXT
FROM nompnt_day_nomination c, nomination_point n
WHERE c.contract_id = n.contract_id
      and c.entry_location_id = n.entry_location_id
	  and c.supplier_nompnt_id is not null
	  and c.nom_status != 'REJ'
	  and c.nomination_type = 'TRAN_INPUT'
group by c.contract_id, c.entry_location_id, c.daytime, c.nom_cycle_code,c.oper_nom_ind
UNION
SELECT
       c.contract_id as OBJECT_ID,
       c.daytime,
       c.exit_location_id location_id,
       c.nom_cycle_code,
       nvl(c.oper_nom_ind, 'N') as OPER_NOM_IND,
       NULL AS RECORD_STATUS,
       NULL AS CREATED_BY,
       NULL AS CREATED_DATE,
       NULL AS LAST_UPDATED_BY,
       NULL AS LAST_UPDATED_DATE,
       NULL AS REV_NO,
       NULL AS REV_TEXT
FROM nompnt_day_nomination c, nomination_point n
WHERE c.contract_id = n.contract_id
      and c.exit_location_id =  n.exit_location_id
	  and c.supplier_nompnt_id is not null
	  and c.nom_status != 'REJ'
	  and c.nomination_type = 'TRAN_OUTPUT'
group by c.contract_id, c.exit_location_id, c.daytime, c.nom_cycle_code,c.oper_nom_ind
)