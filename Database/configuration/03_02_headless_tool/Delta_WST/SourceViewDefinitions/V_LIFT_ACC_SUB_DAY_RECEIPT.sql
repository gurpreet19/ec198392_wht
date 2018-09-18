CREATE OR REPLACE FORCE EDITIONABLE VIEW "V_LIFT_ACC_SUB_DAY_RECEIPT" ("OBJECT_ID", "DAYTIME", "SUMMER_TIME", "PRODUCTION_DAY", "LIFTED_QTY", "LIFTED_QTY2", "LIFTED_QTY3", "UNLOAD_QTY", "UNLOAD_QTY2", "UNLOAD_QTY3", "GRS_VOL_NOMINATED", "GRS_VOL_NOMINATED2", "GRS_VOL_NOMINATED3", "GRS_VOL_REQUESTED", "GRS_VOL_REQUESTED2", "GRS_VOL_REQUESTED3", "GRS_VOL_SCHEDULE", "GRS_VOL_SCHEDULED2", "GRS_VOL_SCHEDULED3", "CARGO_NO", "PARCEL_NO", "NOM_SEQUENCE", "RECORD_STATUS", "CREATED_BY", "CREATED_DATE", "LAST_UPDATED_BY", "LAST_UPDATED_DATE", "REV_NO", "REV_TEXT") AS 
  (
----------------------------------------------------------------------------------------------------
-- File name: v_lift_acc_sub_day_receipt.sql
-- View name: v_lift_acc_sub_day_receipt
--
-- $Revision: 1.5 $
--
-- Purpose  :
--
-- Modification history:
--
-- Date       Whom  	Change description:
-- ---------- ----  --------------------------------------------------------------------------------
-- 28.12.2009 KSN  		Intial version
-- 17.02.2016 asareswi	ECPD-33012: Added function getSubDaySplitQty
-- 04.07.2017 baratmah ECPD-45870 Fixed filtering on cargo status
----------------------------------------------------------------------------------------------------
SELECT f.object_id,
       f.daytime,
       f.summer_time,
       f.production_day,
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
  FROM LIFT_ACC_SUB_DAY_FORECAST f,
       (SELECT n.object_id,
               nvl(ue_storage_lift_nomination.getSubDaySplitQty(sl.parcel_no, sl.company_id, sl.lifting_account_id, sn.production_day, sn.lifted_qty, 'LIFTED'), sn.lifted_qty) lifted_qty,
               nvl(ue_storage_lift_nomination.getSubDaySplitQty(sl.parcel_no, sl.company_id, sl.lifting_account_id, sn.production_day, sn.lifted_qty2, 'LIFTED'), sn.lifted_qty2) lifted_qty2,
               nvl(ue_storage_lift_nomination.getSubDaySplitQty(sl.parcel_no, sl.company_id, sl.lifting_account_id, sn.production_day, sn.lifted_qty3, 'LIFTED'), sn.lifted_qty3) lifted_qty3,
               nvl(ue_storage_lift_nomination.getSubDaySplitQty(sl.parcel_no, sl.company_id, sl.lifting_account_id, sn.production_day, sn.unload_qty, 'UNLOAD'), sn.unload_qty) unload_qty,
			   nvl(ue_storage_lift_nomination.getSubDaySplitQty(sl.parcel_no, sl.company_id, sl.lifting_account_id, sn.production_day, sn.unload_qty2, 'UNLOAD'), sn.unload_qty2) unload_qty2,
			   nvl(ue_storage_lift_nomination.getSubDaySplitQty(sl.parcel_no, sl.company_id, sl.lifting_account_id, sn.production_day, sn.unload_qty3, 'UNLOAD'), sn.unload_qty3) unload_qty3,
               nvl(ue_storage_lift_nomination.getSubDaySplitQty(sl.parcel_no, sl.company_id, sl.lifting_account_id, sn.production_day, sn.grs_vol_nominated, 'NOMINATED'), sn.grs_vol_nominated) grs_vol_nominated,
			   nvl(ue_storage_lift_nomination.getSubDaySplitQty(sl.parcel_no, sl.company_id, sl.lifting_account_id, sn.production_day, sn.grs_vol_nominated2, 'NOMINATED'), sn.grs_vol_nominated2) grs_vol_nominated2,
			   nvl(ue_storage_lift_nomination.getSubDaySplitQty(sl.parcel_no, sl.company_id, sl.lifting_account_id, sn.production_day, sn.grs_vol_nominated3, 'NOMINATED'), sn.grs_vol_nominated3) grs_vol_nominated3,
               nvl(ue_storage_lift_nomination.getSubDaySplitQty(sl.parcel_no, sl.company_id, sl.lifting_account_id, sn.production_day, sn.grs_vol_requested, 'REQUESTED'), sn.grs_vol_requested) grs_vol_requested,
			   nvl(ue_storage_lift_nomination.getSubDaySplitQty(sl.parcel_no, sl.company_id, sl.lifting_account_id, sn.production_day, sn.grs_vol_requested2, 'REQUESTED'), sn.grs_vol_requested2) grs_vol_requested2,
			   nvl(ue_storage_lift_nomination.getSubDaySplitQty(sl.parcel_no, sl.company_id, sl.lifting_account_id, sn.production_day, sn.grs_vol_requested3, 'REQUESTED'), sn.grs_vol_requested3) grs_vol_requested3,
			   nvl(ue_storage_lift_nomination.getSubDaySplitQty(sl.parcel_no, sl.company_id, sl.lifting_account_id, sn.production_day, sn.grs_vol_schedule, 'SCHEDULED'), sn.grs_vol_schedule) grs_vol_schedule,
			   nvl(ue_storage_lift_nomination.getSubDaySplitQty(sl.parcel_no, sl.company_id, sl.lifting_account_id, sn.production_day, sn.grs_vol_scheduled2, 'SCHEDULED'), sn.grs_vol_scheduled2) grs_vol_scheduled2,
			   nvl(ue_storage_lift_nomination.getSubDaySplitQty(sl.parcel_no, sl.company_id, sl.lifting_account_id, sn.production_day, sn.grs_vol_scheduled3, 'SCHEDULED'), sn.grs_vol_scheduled3) grs_vol_scheduled3,
               sn.daytime firm_date_time,
               sn.summer_time summer_time,
               n.CARGO_NO,
               n.PARCEL_NO,
               n.NOM_SEQUENCE,
               decode(nvl(ec_lifting_account.lift_agreement_ind(n.lifting_account_id), 'N'), 'N', n.lifting_account_id, sl.lifting_account_id) as lifting_account_id
          FROM storage_lift_nomination n, cargo_transport t, storage_lift_nom_split sl, stor_sub_day_lift_nom sn, cargo_status_mapping csm
         WHERE t.cargo_no(+) = n.cargo_no
		   AND t.cargo_status= csm.cargo_status
           AND (t.cargo_no IS NULL OR csm.ec_cargo_status <> 'D')
		   AND sl.parcel_no (+) = n.parcel_no
           AND n.parcel_no = sn.parcel_no) l
 WHERE l.firm_date_time(+) = f.daytime
   AND l.summer_time(+) = f.summer_time
   AND l.lifting_account_id(+) = f.object_id
)