CREATE OR REPLACE FORCE EDITIONABLE VIEW "V_STOR_NOM_RECEIPT" ("OBJECT_ID", "DAYTIME", "START_LIFTING_DATE", "RECEIPT_NO", "RECEIPT_TYPE", "LIFTING_ACCOUNT_ID", "RECEIPT_STATUS", "RECEIPT_NAME", "LOCATION_ID", "REQ_GRS_VOL", "REQ_GRS_VOL2", "REQ_GRS_VOL3", "NOM_LIFTED_QTY", "NOM_LIFTED_QTY2", "NOM_LIFTED_QTY3", "LIFTED_QTY", "LIFTED_QTY2", "LIFTED_QTY3", "BALANCE_DELTA_QTY", "BALANCE_DELTA_QTY2", "BALANCE_DELTA_QTY3", "RECORD_STATUS", "CREATED_BY", "CREATED_DATE", "LAST_UPDATED_BY", "LAST_UPDATED_DATE", "REV_NO", "REV_TEXT") AS 
  (
----------------------------------------------------------------------------------------------------
-- File name: v_stor_nom_receipt .sql
-- View name: v_stor_nom_receipt
--
-- $Revision: 1.1 $
--
-- Purpose  : View created for new BF CP.0067:Sub Daily Receipts Details
--
-- Modification history:
--
-- Date       Whom      Change description:
-- ---------- --------  --------------------------------------------------------------------------------
-- 09.10.2015 thotesan  Intial version
-- 17.20.2016 asareswi	Added storage_lift_nom_split table and calculating NOM_LIFTED_QTY, NOM_LIFTED_QTY2, NOM_LIFTED_QTY3 by function.
----------------------------------------------------------------------------------------------------
SELECT n.object_id,
       n.NOM_FIRM_DATE DAYTIME,
       n.START_LIFTING_DATE START_LIFTING_DATE,
       n.PARCEL_NO RECEIPT_NO,
       'LIFTING' RECEIPT_TYPE,
       decode(nvl(ec_lifting_account.lift_agreement_ind(n.lifting_account_id), 'N'), 'N', n.lifting_account_id, sl.lifting_account_id) as lifting_account_id,
       c.cargo_status RECEIPT_STATUS,
       c.cargo_name RECEIPT_NAME,
       c.berth_id location_id,
       n.GRS_VOL_REQUESTED REQ_GRS_VOL,
       n.GRS_VOL_REQUESTED2 REQ_GRS_VOL2,
       n.GRS_VOL_REQUESTED3 REQ_GRS_VOL3,
       NVL(NVL(ecbp_storage_lift_nomination.calcActualSplitQty(sl.parcel_no, sl.company_id, sl.lifting_account_id),
                     ecbp_storage_lift_nomination.calcNomSplitQty(sl.parcel_no, sl.company_id, sl.lifting_account_id))
                     ,     nvl(ecbp_storage_lift_nomination.getLiftedVol(n.parcel_no), n.grs_vol_nominated)
                     ) NOM_LIFTED_QTY,
	   NVL(NVL(ecbp_storage_lift_nomination.calcActualSplitQty(sl.parcel_no, sl.company_id, sl.lifting_account_id, 1),
			 ecbp_storage_lift_nomination.calcNomSplitQty(sl.parcel_no, sl.company_id, sl.lifting_account_id, 1))
			 ,     nvl(ecbp_storage_lift_nomination.getLiftedVol(n.parcel_no, 1), n.grs_vol_nominated2)
			 ) NOM_LIFTED_QTY2,
	   NVL(NVL(ecbp_storage_lift_nomination.calcActualSplitQty(sl.parcel_no, sl.company_id, sl.lifting_account_id, 2),
			 ecbp_storage_lift_nomination.calcNomSplitQty(sl.parcel_no, sl.company_id, sl.lifting_account_id, 2))
			 ,     nvl(ecbp_storage_lift_nomination.getLiftedVol(n.parcel_no, 2), n.grs_vol_nominated3)
			 ) NOM_LIFTED_QTY3,
       EcBp_Storage_Lift_Nomination.getLiftedVol(n.PARCEL_NO) AS LIFTED_QTY,
       EcBp_Storage_Lift_Nomination.getLiftedVol(n.PARCEL_NO,1) AS LIFTED_QTY2,
       EcBp_Storage_Lift_Nomination.getLiftedVol(n.PARCEL_NO,2) AS LIFTED_QTY3,
       Nvl(ecbp_storage_lift_nomination.getLoadBalDeltaVol(n.parcel_no), BALANCE_DELTA_QTY) BALANCE_DELTA_QTY,
       Nvl(ecbp_storage_lift_nomination.getLoadBalDeltaVol(n.parcel_no, 1), BALANCE_DELTA_QTY) BALANCE_DELTA_QTY2,
       Nvl(ecbp_storage_lift_nomination.getLoadBalDeltaVol(n.parcel_no, 2), BALANCE_DELTA_QTY) BALANCE_DELTA_QTY3,
       to_char(null) record_status,
       to_char(null) created_by,
       to_date(null) created_date,
       to_char(null) last_updated_by,
       to_date(null) last_updated_date,
       to_number(null) rev_no,
       to_char(null) rev_text
  FROM storage_lift_nomination n, cargo_transport c, storage_lift_nom_split sl
 WHERE n.cargo_no = c.cargo_no(+)
 AND sl.parcel_no (+) = n.parcel_no
UNION
SELECT la.storage_id object_id,
       a.daytime,
       a.daytime START_LIFTING_DATE,
       --a.adjustement_no receipt_no,
       NULL receipt_no,
       'ADJ_SINGLE' RECEIPT_TYPE,
       a.object_id lifting_account_id,
       'BOOKED' RECEIPT_STATUS,
       null RECEIPT_NAME,
       la.storage_id location_id,
       null REQ_GRS_VOL,
       null REQ_GRS_VOL2,
       null REQ_GRS_VOL3,
       ADJ_QTY NOM_LIFTED_QTY,
       ADJ_QTY2 NOM_LIFTED_QTY2,
       ADJ_QTY3 NOM_LIFTED_QTY3,
       null LIFTED_QTY,
       null LIFTED_QTY2,
       null LIFTED_QTY3,
       null BALANCE_DELTA_QTY,
       null BALANCE_DELTA_QTY2,
       null BALANCE_DELTA_QTY3,
       to_char(null) record_status,
       to_char(null) created_by,
       to_date(null) created_date,
       to_char(null) last_updated_by,
       to_date(null) last_updated_date,
       to_number(null) rev_no,
       to_char(null) rev_text
  FROM lift_account_adj_single a, lifting_account la
 WHERE a.object_id = la.object_id
UNION
SELECT la.storage_id object_id,
       a.daytime,
       a.daytime START_LIFTING_DATE,
       --a.adjustement_no receipt_no,
       NULL receipt_no,
       'ADJ' RECEIPT_TYPE,
       a.object_id lifting_account_id,
       'BOOKED' RECEIPT_STATUS,
       ecdp_objects.GetObjName(a.to_object_id, a.daytime) RECEIPT_NAME,
       la.storage_id location_id,
       null REQ_GRS_VOL,
       null REQ_GRS_VOL2,
       null REQ_GRS_VOL3,
       ADJ_QTY NOM_LIFTED_QTY,
       ADJ_QTY2 NOM_LIFTED_QTY2,
       ADJ_QTY3 NOM_LIFTED_QTY3,
       null LIFTED_QTY,
       null LIFTED_QTY2,
       null LIFTED_QTY3,
       null BALANCE_DELTA_QTY,
       null BALANCE_DELTA_QTY2,
       null BALANCE_DELTA_QTY3,
       to_char(null) record_status,
       to_char(null) created_by,
       to_date(null) created_date,
       to_char(null) last_updated_by,
       to_date(null) last_updated_date,
       to_number(null) rev_no,
       to_char(null) rev_text
       FROM lift_account_adjustment a, lifting_account la
 WHERE a.object_id = la.object_id
UNION
SELECT la.storage_id object_id,
       a.daytime,
       a.daytime START_LIFTING_DATE,
       --a.adjustement_no receipt_no,
       NULL receipt_no,
       'ADJ' RECEIPT_TYPE,
       a.object_id lifting_account_id,
       'BOOKED' RECEIPT_STATUS,
       ecdp_objects.GetObjName(a.object_id, a.daytime) RECEIPT_NAME,
       la.storage_id location_id,
       null REQ_GRS_VOL,
       null REQ_GRS_VOL2,
       null REQ_GRS_VOL3,
       ADJ_QTY NOM_LIFTED_QTY,
       ADJ_QTY2 NOM_LIFTED_QTY2,
       ADJ_QTY3 NOM_LIFTED_QTY3,
       null LIFTED_QTY,
       null LIFTED_QTY2,
       null LIFTED_QTY3,
       null BALANCE_DELTA_QTY,
       null BALANCE_DELTA_QTY2,
       null BALANCE_DELTA_QTY3,
       to_char(null) record_status,
       to_char(null) created_by,
       to_date(null) created_date,
       to_char(null) last_updated_by,
       to_date(null) last_updated_date,
       to_number(null) rev_no,
       to_char(null) rev_text
  FROM lift_account_adjustment a, lifting_account la
 WHERE a.to_object_id = la.object_id
)