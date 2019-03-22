CREATE OR REPLACE FORCE EDITIONABLE VIEW "V_TRNP_DAY_NOM_PATH_MATRIX" ("OBJECT_ID", "DAYTIME", "NOMINATION_TYPE", "NOM_CYCLE_CODE", "OPER_NOM_IND", "REF_NOMINATION_SEQ", "REQUESTED_QTY", "REQUESTED_DATE", "REQUESTED_MHM_REF", "ACCEPTED_QTY", "ACCEPTED_DATE", "EXT_ACCEPTED_QTY", "EXT_ACCEPTED_DATE", "EXT_ACCEPTED_MHM_REF", "ADJUSTED_QTY", "ADJUSTED_DATE", "EXT_ADJUSTED_QTY", "EXT_ADJUSTED_DATE", "EXT_ADJUSTED_MHM_REF", "CONFIRMED_QTY", "CONFIRMED_DATE", "EXT_CONFIRMED_QTY", "EXT_CONFIRMED_DATE", "EXT_CONFIRMED_MHM_REF", "SCHEDULED_QTY", "SCHEDULED_DATE", "NOM_STATUS", "SHIPPER_CODE", "TRANSACTION_TYPE", "PRIORITY", "CONTRACT_ID", "ENTRY_LOCATION_ID", "EXIT_LOCATION_ID", "DESIRED_PCT", "COMMENTS", "TO_NOMPNT_ID", "COUNTER_NOMPNT_ID", "SUPPLIER_NOMPNT_ID", "NOMPNT_SORT_ORDER", "TO_NOMPNT_SORT_ORDER", "RECORD_STATUS", "CREATED_BY", "CREATED_DATE", "LAST_UPDATED_BY", "LAST_UPDATED_DATE", "REV_NO", "REV_TEXT", "APPROVAL_STATE", "APPROVAL_BY", "APPROVAL_DATE", "REC_ID") AS 
  (
----------------------------------------------------------------------------------------------------
-- File name: v_trnp_day_nom_path_matrix.sql
-- View name: v_trnp_day_nom_path_matrix
--
-- $Revision: 1.6 $
--
-- Purpose  :
--
-- Modification history:
--
-- Date       Whom  Change description:
-- ---------- ----  --------------------------------------------------------------------------------
-- 08.02.2018 thotesan  Intial version
----------------------------------------------------------------------------------------------------
SELECT DISTINCT NP.object_id,
                NOMPNT_T.daytime,
                NOMPNT.nomination_type,
                NOMPNT.nom_cycle_code,
                NOMPNT.oper_nom_ind,
                NOMPNT.ref_nomination_seq,
                NOMPNT.requested_qty,
                NOMPNT.requested_date,
                NOMPNT.requested_mhm_ref,
                NOMPNT.accepted_qty,
                NOMPNT.accepted_date,
                NOMPNT.ext_accepted_qty,
                NOMPNT.ext_accepted_date,
                NOMPNT.ext_accepted_mhm_ref,
                NOMPNT.adjusted_qty,
                NOMPNT.adjusted_date,
                NOMPNT.ext_adjusted_qty,
                NOMPNT.ext_adjusted_date,
                NOMPNT.ext_adjusted_mhm_ref,
                NOMPNT.confirmed_qty,
                NOMPNT.confirmed_date,
                NOMPNT.ext_confirmed_qty,
                NOMPNT.ext_confirmed_date,
                NOMPNT.ext_confirmed_mhm_ref,
                NOMPNT.scheduled_qty,
                NOMPNT.scheduled_date,
                NOMPNT.nom_status,
                NOMPNT.shipper_code,
                NOMPNT.transaction_type,
                NOMPNT.priority,
                NOMPNT_T.contract_id,
                NOMPNT.entry_location_id,
                NOMPNT.exit_location_id,
                NOMPNT.desired_pct,
                NOMPNT.comments,
                NOMPNT_T.to_nompnt_id,
                NOMPNT.counter_nompnt_id,
                NOMPNT.supplier_nompnt_id,
                NPV.SORT_ORDER NOMPNT_SORT_ORDER,
                EC_NOMPNT_VERSION.SORT_ORDER( NOMPNT_T.to_nompnt_id, NOMPNT_T.daytime,'<=') TO_NOMPNT_SORT_ORDER,
                NOMPNT.RECORD_STATUS         AS RECORD_STATUS,
                NOMPNT.CREATED_BY            AS CREATED_BY,
                NOMPNT.CREATED_DATE          AS CREATED_DATE,
                NOMPNT.LAST_UPDATED_BY       AS LAST_UPDATED_BY,
                NOMPNT.LAST_UPDATED_DATE     AS LAST_UPDATED_DATE,
                NOMPNT.REV_NO                AS REV_NO,
                NOMPNT.REV_TEXT              AS REV_TEXT,
                NOMPNT.APPROVAL_STATE        AS APPROVAL_STATE,
                NOMPNT.APPROVAL_BY           AS APPROVAL_BY,
                NOMPNT.APPROVAL_DATE         AS APPROVAL_DATE,
                NOMPNT.REC_ID                AS REC_ID
  FROM NOMPNT_NP_DAY_NOMINATION NOMPNT,
       NOMPNT_NP_DAY_NOMINATION NOMPNT_T,
       NOMINATION_POINT         NP,
       NOMPNT_VERSION           NPV
 WHERE NOMPNT_T.CONTRACT_ID = NP.CONTRACT_ID
   AND NPV.OBJECT_ID = NP.OBJECT_ID
   AND NOMPNT.DAYTIME(+) = NOMPNT_T.DAYTIME
   AND NOMPNT.OBJECT_ID(+) = NP.OBJECT_ID
   AND NOMPNT.TO_NOMPNT_ID(+) = NOMPNT_T.TO_NOMPNT_ID
   AND NP.ENTRY_LOCATION_ID IS NOT NULL)