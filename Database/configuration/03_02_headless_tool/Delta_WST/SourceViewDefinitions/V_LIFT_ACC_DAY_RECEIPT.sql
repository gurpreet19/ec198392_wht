CREATE OR REPLACE FORCE EDITIONABLE VIEW "V_LIFT_ACC_DAY_RECEIPT" ("OBJECT_ID", "DAYTIME", "LIFTED_QTY", "LIFTED_QTY2", "LIFTED_QTY3", "UNLOAD_QTY", "UNLOAD_QTY2", "UNLOAD_QTY3", "GRS_VOL_NOMINATED", "GRS_VOL_NOMINATED2", "GRS_VOL_NOMINATED3", "GRS_VOL_REQUESTED", "GRS_VOL_REQUESTED2", "GRS_VOL_REQUESTED3", "GRS_VOL_SCHEDULE", "GRS_VOL_SCHEDULED2", "GRS_VOL_SCHEDULED3", "CARGO_NO", "PARCEL_NO", "NOM_SEQUENCE", "RECORD_STATUS", "CREATED_BY", "CREATED_DATE", "LAST_UPDATED_BY", "LAST_UPDATED_DATE", "REV_NO", "REV_TEXT") AS 
  (
----------------------------------------------------------------------------------------------------
-- File name: v_lift_acc_day_receipt.sql
-- View name: v_lift_acc_day_receipt
--
-- $Revision: 1.4 $
--
-- Purpose  :
--
-- Modification history:
--
-- Date       Whom  	Change description:
-- ---------- ----  --------------------------------------------------------------------------------
-- 28.12.2009 KSN  		Intial version
-- 17.02.2016 asareswi	ECPD-33012 : Added function to calculate grs_vol_nominated, grs_vol_nominated2, grs_vol_nominated3.
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
               NVL(NVL(ecbp_storage_lift_nomination.calcActualSplitQty(sl.parcel_no, sl.company_id, sl.lifting_account_id),
                     ecbp_storage_lift_nomination.calcNomSplitQty(sl.parcel_no, sl.company_id, sl.lifting_account_id))
                     ,     nvl(ecbp_storage_lift_nomination.getLiftedVol(n.parcel_no), n.grs_vol_nominated)
                     ) grs_vol_nominated,
               NVL(NVL(ecbp_storage_lift_nomination.calcActualSplitQty(sl.parcel_no, sl.company_id, sl.lifting_account_id, 1),
                     ecbp_storage_lift_nomination.calcNomSplitQty(sl.parcel_no, sl.company_id, sl.lifting_account_id, 1))
                     ,     nvl(ecbp_storage_lift_nomination.getLiftedVol(n.parcel_no, 1), n.grs_vol_nominated2)
                     ) grs_vol_nominated2,
               NVL(NVL(ecbp_storage_lift_nomination.calcActualSplitQty(sl.parcel_no, sl.company_id, sl.lifting_account_id, 2),
                     ecbp_storage_lift_nomination.calcNomSplitQty(sl.parcel_no, sl.company_id, sl.lifting_account_id, 2))
                     ,     nvl(ecbp_storage_lift_nomination.getLiftedVol(n.parcel_no, 2), n.grs_vol_nominated3)
                     ) grs_vol_nominated3,
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
               decode(nvl(ec_lifting_account.lift_agreement_ind(n.lifting_account_id), 'N'), 'N', n.lifting_account_id, sl.lifting_account_id) as lifting_account_id
          FROM storage_lift_nomination n, cargo_transport t, storage_lift_nom_split sl, cargo_status_mapping csm
         WHERE t.cargo_no(+) = n.cargo_no
		   AND t.cargo_status= csm.cargo_status
           AND (t.cargo_no IS NULL OR csm.ec_cargo_status <> 'D')
		   AND sl.parcel_no (+) = n.parcel_no) l
 WHERE l.firm_date(+) = f.daytime
   AND l.lifting_account_id(+) = f.object_id
)