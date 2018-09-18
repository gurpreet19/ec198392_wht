CREATE OR REPLACE FORCE EDITIONABLE VIEW "V_LIFT_ACC_DAY_RECEIPT2" ("OBJECT_ID", "DAYTIME", "LIFTED_QTY", "LIFTED_QTY2", "LIFTED_QTY3", "UNLOAD_QTY", "UNLOAD_QTY2", "UNLOAD_QTY3", "GRS_VOL_NOMINATED", "GRS_VOL_NOMINATED2", "GRS_VOL_NOMINATED3", "GRS_VOL_REQUESTED", "GRS_VOL_REQUESTED2", "GRS_VOL_REQUESTED3", "GRS_VOL_SCHEDULE", "GRS_VOL_SCHEDULED2", "GRS_VOL_SCHEDULED3", "LAUF_QTY", "LAUF_QTY2", "LAUF_QTY3", "CARGO_NO", "PARCEL_NO", "NOM_SEQUENCE", "RECORD_STATUS", "CREATED_BY", "CREATED_DATE", "LAST_UPDATED_BY", "LAST_UPDATED_DATE", "REV_NO", "REV_TEXT") AS 
  (
----------------------------------------------------------------------------------------------------
-- File name: v_lift_acc_day_receipt2.sql
-- View name: v_lift_acc_day_receipt2
--
-- $Revision: 1.3 $
--
-- Purpose  :
--
-- Modification history:
--
-- Date       Whom  Change description:
-- ---------- ----  --------------------------------------------------------------------------------
-- 12.11.2012 meisihil  Intial version
-- 17.02.2016 asareswi	ECPD-33012 : Added function to calculate grs_vol_nominated, grs_vol_requested, grs_vol_schedule
-- 04.07.2017 baratmah ECPD-45870 Fixed filtering on cargo status
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
	   l.LAUF_QTY,
	   l.LAUF_QTY2,
	   l.LAUF_QTY3,
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
				nvl(ue_storage_lift_nomination.calcAggrSubDaySplitQty(sl.parcel_no, sl.company_id, sl.lifting_account_id, sn.production_day, 'LIFTED', 0),
				   ue_Storage_Lift_Nomination.aggrSubDayLifting (n.PARCEL_NO, sn.production_day, 'LIFTED', 0)) lifted_qty,
				nvl(ue_storage_lift_nomination.calcAggrSubDaySplitQty(sl.parcel_no, sl.company_id, sl.lifting_account_id, sn.production_day, 'LIFTED', 1),
				   ue_Storage_Lift_Nomination.aggrSubDayLifting (n.PARCEL_NO, sn.production_day, 'LIFTED', 1)) lifted_qty2,
				nvl(ue_storage_lift_nomination.calcAggrSubDaySplitQty(sl.parcel_no, sl.company_id, sl.lifting_account_id, sn.production_day, 'LIFTED', 2),
				   ue_Storage_Lift_Nomination.aggrSubDayLifting (n.PARCEL_NO, sn.production_day, 'LIFTED', 2)) lifted_qty3,
				nvl(ue_storage_lift_nomination.calcAggrSubDaySplitQty(sl.parcel_no, sl.company_id, sl.lifting_account_id, sn.production_day, 'UNLOAD', 0),
				   ue_Storage_Lift_Nomination.aggrSubDayLifting (n.PARCEL_NO, sn.production_day, 'UNLOAD', 0)) unload_qty,
				nvl(ue_storage_lift_nomination.calcAggrSubDaySplitQty(sl.parcel_no, sl.company_id, sl.lifting_account_id, sn.production_day, 'UNLOAD', 1),
				   ue_Storage_Lift_Nomination.aggrSubDayLifting (n.PARCEL_NO, sn.production_day, 'UNLOAD', 2)) unload_qty2,
				nvl(ue_storage_lift_nomination.calcAggrSubDaySplitQty(sl.parcel_no, sl.company_id, sl.lifting_account_id, sn.production_day, 'UNLOAD', 2),
				   ue_Storage_Lift_Nomination.aggrSubDayLifting (n.PARCEL_NO, sn.production_day, 'UNLOAD', 3)) unload_qty3,
				nvl(ue_storage_lift_nomination.calcAggrSubDaySplitQty(sl.parcel_no, sl.company_id, sl.lifting_account_id, sn.production_day, 'NOMINATED', 0),
				   ue_Storage_Lift_Nomination.aggrSubDayLifting (n.PARCEL_NO, sn.production_day, 'NOMINATED', 0)) grs_vol_nominated,
				nvl(ue_storage_lift_nomination.calcAggrSubDaySplitQty(sl.parcel_no, sl.company_id, sl.lifting_account_id, sn.production_day, 'NOMINATED', 1),
				   ue_Storage_Lift_Nomination.aggrSubDayLifting (n.PARCEL_NO, sn.production_day, 'NOMINATED', 1)) grs_vol_nominated2,
				nvl(ue_storage_lift_nomination.calcAggrSubDaySplitQty(sl.parcel_no, sl.company_id, sl.lifting_account_id, sn.production_day, 'NOMINATED', 2),
				   ue_Storage_Lift_Nomination.aggrSubDayLifting (n.PARCEL_NO, sn.production_day, 'NOMINATED', 2)) grs_vol_nominated3,
				nvl(ue_storage_lift_nomination.calcAggrSubDaySplitQty(sl.parcel_no, sl.company_id, sl.lifting_account_id, sn.production_day, 'REQUESTED', 0),
				ue_Storage_Lift_Nomination.aggrSubDayLifting (n.PARCEL_NO, sn.production_day, 'REQUESTED', 0)) grs_vol_requested,
				nvl(ue_storage_lift_nomination.calcAggrSubDaySplitQty(sl.parcel_no, sl.company_id, sl.lifting_account_id, sn.production_day, 'REQUESTED', 1),
				ue_Storage_Lift_Nomination.aggrSubDayLifting (n.PARCEL_NO, sn.production_day, 'REQUESTED', 1)) grs_vol_requested2,
				nvl(ue_storage_lift_nomination.calcAggrSubDaySplitQty(sl.parcel_no, sl.company_id, sl.lifting_account_id, sn.production_day, 'REQUESTED', 2),
				ue_Storage_Lift_Nomination.aggrSubDayLifting (n.PARCEL_NO, sn.production_day, 'REQUESTED', 2)) grs_vol_requested3,
				nvl(ue_storage_lift_nomination.calcAggrSubDaySplitQty(sl.parcel_no, sl.company_id, sl.lifting_account_id, sn.production_day, 'SCHEDULED', 0),
				ue_Storage_Lift_Nomination.aggrSubDayLifting (n.PARCEL_NO, sn.production_day, 'SCHEDULED', 0)) grs_vol_schedule,
				nvl(ue_storage_lift_nomination.calcAggrSubDaySplitQty(sl.parcel_no, sl.company_id, sl.lifting_account_id, sn.production_day, 'SCHEDULED', 1),
				ue_Storage_Lift_Nomination.aggrSubDayLifting (n.PARCEL_NO, sn.production_day, 'SCHEDULED', 1)) grs_vol_scheduled2,
				nvl(ue_storage_lift_nomination.calcAggrSubDaySplitQty(sl.parcel_no, sl.company_id, sl.lifting_account_id, sn.production_day, 'SCHEDULED', 2),
				ue_Storage_Lift_Nomination.aggrSubDayLifting (n.PARCEL_NO, sn.production_day, 'SCHEDULED', 2)) grs_vol_scheduled3,
				nvl(ue_storage_lift_nomination.calcAggrSubDaySplitQty(sl.parcel_no, sl.company_id, sl.lifting_account_id, sn.production_day, 'LAUF', 0),
				ue_Storage_Lift_Nomination.aggrSubDayLifting (n.PARCEL_NO, sn.production_day, 'LAUF', 0)) lauf_qty,
				nvl(ue_storage_lift_nomination.calcAggrSubDaySplitQty(sl.parcel_no, sl.company_id, sl.lifting_account_id, sn.production_day, 'LAUF', 1),
				ue_Storage_Lift_Nomination.aggrSubDayLifting (n.PARCEL_NO, sn.production_day, 'LAUF', 1)) lauf_qty2,
				nvl(ue_storage_lift_nomination.calcAggrSubDaySplitQty(sl.parcel_no, sl.company_id, sl.lifting_account_id, sn.production_day, 'LAUF', 2),
				ue_Storage_Lift_Nomination.aggrSubDayLifting (n.PARCEL_NO, sn.production_day, 'LAUF', 2)) lauf_qty3,
				sn.production_day firm_date,
				n.CARGO_NO,
				n.PARCEL_NO,
				n.NOM_SEQUENCE,
				decode(nvl(ec_lifting_account.lift_agreement_ind(n.lifting_account_id), 'N'), 'N',
                          n.lifting_account_id, sl.lifting_account_id) as lifting_account_id
          FROM storage_lift_nomination n, cargo_transport t,
				storage_lift_nom_split sl,cargo_status_mapping csm,
      	       (SELECT distinct production_day, parcel_no FROM stor_sub_day_lift_nom) sn
         WHERE t.cargo_no(+) = n.cargo_no
		   AND t.cargo_status= csm.cargo_status
           AND (t.cargo_no IS NULL OR csm.ec_cargo_status <> 'D')
		   AND n.parcel_no = sn.parcel_no
		   AND sl.parcel_no (+) = n.parcel_no) l
 WHERE l.firm_date(+) = f.daytime
   AND l.lifting_account_id(+) = f.object_id
)