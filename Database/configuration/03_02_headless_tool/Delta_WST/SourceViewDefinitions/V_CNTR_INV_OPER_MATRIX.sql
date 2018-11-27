CREATE OR REPLACE FORCE EDITIONABLE VIEW "V_CNTR_INV_OPER_MATRIX" ("OBJECT_ID", "DAYTIME", "CONTRACT_ID", "LOCATION_ID", "INVENTORY_TYPE", "DEBIT_QTY", "CREDIT_QTY", "TRANSACTION_SEQ", "RECORD_STATUS", "CREATED_BY", "CREATED_DATE", "LAST_UPDATED_BY", "LAST_UPDATED_DATE", "REV_NO", "REV_TEXT") AS 
  (
----------------------------------------------------------------------------------------------------
-- File name v_cntr_inv_oper_matrix.sql
-- View name v_cntr_inv_oper_matrix
--
-- $Revision: 1.3 $
--
-- Purpose
--
-- Modification history
--
-- Date       Whom      Change description
-- ---------- ----      --------------------------------------------------------------------------------
-- 23-07-2012 leeeewei  Created view for daily contract inventory matrix
-- 10-10-2014 leeeewei  Added nvl for inventory_type
----------------------------------------------------------------------------------------------------
select d.object_id,
       d.daytime,
       c.contract_id,
       c.location_id,
       nvl(c.inventory_type,'NULL')inventory_type,
       t.debit_qty,
       t.credit_qty,
       t.transaction_seq,
       d.record_status,
       d.created_by,
       d.created_date,
       t.last_updated_by,
       t.last_updated_date,
       nvl(t.rev_no,0) as rev_no,
       t.rev_text
  from cntr_day_loc_inventory d,
       cntr_day_loc_inv_trans t,
       contract_inventory     c
 where c.object_id = d.object_id
   and d.object_id = t.object_id(+)
   and d.daytime = t.daytime(+)
   and t.transaction_type(+) = ue_contract_inventory.getTransactionType
)