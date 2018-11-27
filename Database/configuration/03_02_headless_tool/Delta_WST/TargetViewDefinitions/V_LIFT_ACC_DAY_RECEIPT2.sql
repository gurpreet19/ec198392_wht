CREATE OR REPLACE FORCE VIEW "V_LIFT_ACC_DAY_RECEIPT2" ("OBJECT_ID", "DAYTIME", "LIFTED_QTY", "LIFTED_QTY2", "LIFTED_QTY3", "UNLOAD_QTY", "UNLOAD_QTY2", "UNLOAD_QTY3", "GRS_VOL_NOMINATED", "GRS_VOL_NOMINATED2", "GRS_VOL_NOMINATED3", "GRS_VOL_REQUESTED", "GRS_VOL_REQUESTED2", "GRS_VOL_REQUESTED3", "GRS_VOL_SCHEDULE", "GRS_VOL_SCHEDULED2", "GRS_VOL_SCHEDULED3", "CARGO_NO", "PARCEL_NO", "NOM_SEQUENCE", "RECORD_STATUS", "CREATED_BY", "CREATED_DATE", "LAST_UPDATED_BY", "LAST_UPDATED_DATE", "REV_NO", "REV_TEXT") AS 
  (
----------------------------------------------------------------------------------------------------
-- File name: v_lift_acc_day_receipt2.sql
-- View name: v_lift_acc_day_receipt2
--
-- $Revision: 1.1.2.1 $
--
-- Purpose  :
--
-- Modification history:
--
-- Date       Whom  Change description:
-- ---------- ----  --------------------------------------------------------------------------------
-- 12.11.2012 meisihil  Intial version
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
               ue_Storage_Lift_Nomination.aggrSubDayLifting(n.PARCEL_NO, sn.production_day, 'LIFTED', 0) lifted_qty,
               ue_Storage_Lift_Nomination.aggrSubDayLifting(n.PARCEL_NO, sn.production_day, 'LIFTED', 1) lifted_qty2,
			   ue_Storage_Lift_Nomination.aggrSubDayLifting(n.PARCEL_NO, sn.production_day, 'LIFTED', 2) lifted_qty3,
               ue_Storage_Lift_Nomination.aggrSubDayLifting(n.PARCEL_NO, sn.production_day, 'UNLOAD', 0) unload_qty,
               ue_Storage_Lift_Nomination.aggrSubDayLifting(n.PARCEL_NO, sn.production_day, 'UNLOAD', 1) unload_qty2,
			   ue_Storage_Lift_Nomination.aggrSubDayLifting(n.PARCEL_NO, sn.production_day, 'UNLOAD', 2) unload_qty3,
               ue_Storage_Lift_Nomination.aggrSubDayLifting(n.PARCEL_NO, sn.production_day, 'NOMINATED', 0) GRS_VOL_NOMINATED,
               ue_Storage_Lift_Nomination.aggrSubDayLifting(n.PARCEL_NO, sn.production_day, 'NOMINATED', 1) grs_vol_nominated2,
			   ue_Storage_Lift_Nomination.aggrSubDayLifting(n.PARCEL_NO, sn.production_day, 'NOMINATED', 2) grs_vol_nominated3,
               ue_Storage_Lift_Nomination.aggrSubDayLifting(n.PARCEL_NO, sn.production_day, 'REQUESTED', 0) GRS_VOL_REQUESTED,
               ue_Storage_Lift_Nomination.aggrSubDayLifting(n.PARCEL_NO, sn.production_day, 'REQUESTED', 1) GRS_VOL_REQUESTED2,
			   ue_Storage_Lift_Nomination.aggrSubDayLifting(n.PARCEL_NO, sn.production_day, 'REQUESTED', 2) GRS_VOL_REQUESTED3,
               ue_Storage_Lift_Nomination.aggrSubDayLifting(n.PARCEL_NO, sn.production_day, 'SCHEDULED', 0) GRS_VOL_SCHEDULE,
               ue_Storage_Lift_Nomination.aggrSubDayLifting(n.PARCEL_NO, sn.production_day, 'SCHEDULED', 1) GRS_VOL_SCHEDULED2,
			   ue_Storage_Lift_Nomination.aggrSubDayLifting(n.PARCEL_NO, sn.production_day, 'SCHEDULED', 2) GRS_VOL_SCHEDULED3,
               sn.production_day firm_date,
               n.CARGO_NO,
               n.PARCEL_NO,
               n.NOM_SEQUENCE,
               n.LIFTING_ACCOUNT_ID
          FROM storage_lift_nomination n, cargo_transport t,
      	       (SELECT distinct production_day, parcel_no FROM stor_sub_day_lift_nom) sn
         WHERE t.cargo_no(+) = n.cargo_no
           AND t.cargo_status <> 'D'
		   AND n.parcel_no = sn.parcel_no) l
 WHERE l.firm_date(+) = f.daytime
   AND l.lifting_account_id(+) = f.object_id
)