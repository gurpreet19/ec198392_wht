CREATE OR REPLACE FORCE VIEW "V_NOM_LOCATION_MATCHING" ("OBJECT_ID", "DAYTIME", "ACCEPTED_IN_QTY", "ACCEPTED_OUT_QTY", "ADJUSTED_IN_QTY", "ADJUSTED_OUT_QTY", "CONFIRMED_IN_QTY", "CONFIRMED_OUT_QTY", "SCHEDULED_IN_QTY", "SCHEDULED_OUT_QTY", "CONTRACT_ID", "NOM_CYCLE_CODE", "RECORD_STATUS", "CREATED_BY", "CREATED_DATE", "LAST_UPDATED_BY", "LAST_UPDATED_DATE", "REV_NO", "REV_TEXT") AS 
  (
----------------------------------------------------------------------------------------------------
-- File name: V_NOM_LOCATION_MATCHING.sql
-- View name: V_NOM_LOCATION_MATCHING
--
-- $Revision: 1.1.4.3 $
--
-- Purpose  :
--
-- Modification history:
--
-- Date       Whom  Change description:
-- ---------- ----  --------------------------------------------------------------------------------
-- 23.12.2011 Kenneth  Intial version
----------------------------------------------------------------------------------------------------
SELECT distinct(c.object_id),
     c.daytime,
     c.accepted_in_qty,
     c.accepted_out_qty,
       c.adjusted_in_qty,
       c.adjusted_out_qty,
       c.confirmed_in_qty,
       c.confirmed_out_qty,
       c.scheduled_in_qty,
       c.scheduled_out_qty,
       o.contract_id,
       c.nom_cycle_code,
       to_char(null) record_status,
       to_char(null) created_by,
       to_date(null) created_date,
       to_char(null) last_updated_by,
       to_date(null) last_updated_date,
       to_number(null) rev_no,
       to_char(null) rev_text
  FROM OBJLOC_DAY_NOMINATION c, NOMPNT_VERSION oa, NOMINATION_POINT o
  where (c.object_id = o.EXIT_LOCATION_ID
  or c.object_id = o.ENTRY_LOCATION_ID)
  AND oa.object_id = o.object_id
  AND c.daytime >= oa.daytime
  AND c.daytime < nvl(oa.end_date,c.daytime + 1)
)