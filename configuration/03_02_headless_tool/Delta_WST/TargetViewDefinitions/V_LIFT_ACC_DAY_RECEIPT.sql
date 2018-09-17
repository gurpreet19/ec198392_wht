CREATE OR REPLACE FORCE VIEW "V_LIFT_ACC_DAY_RECEIPT" ("OBJECT_ID", "DAYTIME", "LIFTED_QTY", "LIFTED_QTY2", "LIFTED_QTY3", "UNLOAD_QTY", "UNLOAD_QTY2", "UNLOAD_QTY3", "GRS_VOL_NOMINATED", "GRS_VOL_NOMINATED2", "GRS_VOL_NOMINATED3", "GRS_VOL_REQUESTED", "GRS_VOL_REQUESTED2", "GRS_VOL_REQUESTED3", "GRS_VOL_SCHEDULE", "GRS_VOL_SCHEDULED2", "GRS_VOL_SCHEDULED3", "CARGO_NO", "PARCEL_NO", "NOM_SEQUENCE", "RECORD_STATUS", "CREATED_BY", "CREATED_DATE", "LAST_UPDATED_BY", "LAST_UPDATED_DATE", "REV_NO", "REV_TEXT") AS 
  (
----------------------------------------------------------------------------------------------------
-- File name: v_lift_acc_day_receipt.sql
-- View name: v_lift_acc_day_receipt
--
-- $Revision: 1.3 $
--
-- Purpose  :
--
-- Modification history:
--
-- Date       Whom  Change description:
-- ---------- ----  --------------------------------------------------------------------------------
-- 28.12.2009 KSN  Intial version
----------------------------------------------------------------------------------------------------
SELECT f.object_id,
       f.daytime,
       l.lifted_qty,
       l.lifted_qty2,
	   l.lifted_qty3,
       l.unload_qty,
       l.unload_qty2,
	   l.unload_qty3,
       l.GRS_VOL_NOMINATED,
       l.grs_vol_nominated2,
	   l.grs_vol_nominated3,
       l.GRS_VOL_REQUESTED,
       l.GRS_VOL_REQUESTED2,
	   l.GRS_VOL_REQUESTED3,
       l.GRS_VOL_SCHEDULE,
       l.GRS_VOL_SCHEDULED2,
	   l.GRS_VOL_SCHEDULED3,
       l.CARGO_NO,
       l.PARCEL_NO,
       l.NOM_SEQUENCE,
       to_char(null) record_status,
       to_char(null) created_by,
       to_date(null) created_date,
       to_char(null) last_updated_by,
       to_date(null) last_updated_date,
       to_number(null) rev_no,
       to_char(null) rev_text
  FROM LIFT_ACC_DAY_FORECAST f,
       (SELECT n.object_id,
               EcBP_Storage_Lift_Nomination.getLiftedVol(n.PARCEL_NO) lifted_qty,
               EcBP_Storage_Lift_Nomination.getLiftedVol(n.PARCEL_NO, 1) lifted_qty2,
			   EcBP_Storage_Lift_Nomination.getLiftedVol(n.PARCEL_NO, 2) lifted_qty3,
               EcBP_Storage_Lift_Nomination.GETUNLOADVOL(n.PARCEL_NO) unload_qty,
               EcBP_Storage_Lift_Nomination.GETUNLOADVOL(n.PARCEL_NO, 1) unload_qty2,
			   EcBP_Storage_Lift_Nomination.GETUNLOADVOL(n.PARCEL_NO, 2) unload_qty3,
               n.GRS_VOL_NOMINATED,
               n.grs_vol_nominated2,
			   n.grs_vol_nominated3,
               n.GRS_VOL_REQUESTED,
               n.GRS_VOL_REQUESTED2,
			   n.GRS_VOL_REQUESTED3,
               n.GRS_VOL_SCHEDULE,
               n.GRS_VOL_SCHEDULED2,
			   n.GRS_VOL_SCHEDULED3,
               Nvl(n.bl_date, n.nom_firm_date) firm_date,
               n.CARGO_NO,
               n.PARCEL_NO,
               n.NOM_SEQUENCE,
               n.LIFTING_ACCOUNT_ID
          FROM storage_lift_nomination n, cargo_transport t
         WHERE t.cargo_no(+) = n.cargo_no
           AND t.cargo_status <> 'D') l
 WHERE l.firm_date(+) = f.daytime
   AND l.lifting_account_id(+) = f.object_id
)