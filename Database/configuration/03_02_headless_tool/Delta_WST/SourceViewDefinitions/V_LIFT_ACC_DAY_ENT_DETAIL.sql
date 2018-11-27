CREATE OR REPLACE FORCE EDITIONABLE VIEW "V_LIFT_ACC_DAY_ENT_DETAIL" ("OBJECT_ID", "DAYTIME", "FORECAST_QTY", "FORECAST_QTY2", "FORECAST_QTY3", "OFFICIAL_QTY", "OFFICIAL_QTY2", "OFFICIAL_QTY3", "PROD_QTY", "PROD_QTY2", "PROD_QTY3", "CLOSING_BALANCE", "CLOSING_BALANCE2", "CLOSING_BALANCE3", "PARCEL_NO", "CARGO_NO", "NOM_SEQUENCE", "GRS_VOL_NOMINATED", "GRS_VOL_NOMINATED2", "GRS_VOL_NOMINATED3", "RECORD_STATUS", "CREATED_BY", "CREATED_DATE", "LAST_UPDATED_BY", "LAST_UPDATED_DATE", "REV_NO", "REV_TEXT") AS 
  (
----------------------------------------------------------------------------------------------------
-- File name: v_lift_acc_day_ent_detail .sql
-- View name: v_lift_acc_day_ent_detail
--
-- $Revision: 1.7 $
--
-- Purpose  :
--
-- Modification history:
--
-- Date       Whom      Change description:
-- ---------- --------  --------------------------------------------------------------------------------
-- 08.01.2009 lauuufus  Intial version
-- 03.03.2012 muhammah	ECPD-19580
-- 04.07.2017 baratmah ECPD-45870 Fixed filtering on cargo status
----------------------------------------------------------------------------------------------------
SELECT la.object_id,
       la.daytime,
	     la.forecast_qty,
       la.forecast_qty2,
       la.forecast_qty3,
       (select ec_lift_acc_day_official.official_qty(la.object_id, la.daytime) from dual) official_qty,
       (select ec_lift_acc_day_official.official_qty2(la.object_id, la.daytime) from dual) official_qty2,
       (select ec_lift_acc_day_official.official_qty3(la.object_id, la.daytime) from dual) official_qty3,
       (select nvl(ec_lift_acc_day_official.official_qty(la.object_id, la.daytime), la.forecast_qty) from dual) PROD_QTY,
       (select nvl(ec_lift_acc_day_official.official_qty2(la.object_id, la.daytime), la.forecast_qty2) from dual) PROD_QTY2,
       (select nvl(ec_lift_acc_day_official.official_qty3(la.object_id, la.daytime), la.forecast_qty3) from dual) PROD_QTY3,
       (select EcBp_Lift_Acc_Balance.calcEstClosingBalanceDay(la.object_id, la.daytime) from dual) CLOSING_BALANCE,
       (select EcBp_Lift_Acc_Balance.calcEstClosingBalanceDay(la.object_id, la.daytime, 1) from dual) CLOSING_BALANCE2,
       (select EcBp_Lift_Acc_Balance.calcEstClosingBalanceDay(la.object_id, la.daytime, 2) from dual) CLOSING_BALANCE3,
       n.parcel_no,
       n.cargo_no,
       n.nom_sequence,
       n.grs_vol_nominated,
       n.grs_vol_nominated2,
       n.grs_vol_nominated3,
       to_char(null) record_status,
       to_char(null) created_by,
       to_date(null) created_date,
       to_char(null) last_updated_by,
       to_date(null) last_updated_date,
       to_number(null) rev_no,
       to_char(null) rev_text
  FROM LIFT_ACC_DAY_FORECAST la,
       (SELECT n.object_id,
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
               Nvl(n.bl_date, n.nom_firm_date) firm_date,
               n.CARGO_NO,
               n.PARCEL_NO,
               n.NOM_SEQUENCE,
               decode(nvl(ec_lifting_account.lift_agreement_ind(n.lifting_account_id), 'N'), 'N',
                          n.lifting_account_id, sl.lifting_account_id) as lifting_account_id
          FROM storage_lift_nomination n, cargo_transport t, storage_lift_nom_split sl, cargo_status_mapping csm
         WHERE t.cargo_no(+) = n.cargo_no
		   AND t.cargo_status= csm.cargo_status
           AND (t.cargo_no IS NULL OR csm.ec_cargo_status <> 'D' )
		   AND sl.parcel_no (+) = n.parcel_no) n
 where n.lifting_account_id(+) = la.object_id
   and n.firm_date(+) = la.daytime
)