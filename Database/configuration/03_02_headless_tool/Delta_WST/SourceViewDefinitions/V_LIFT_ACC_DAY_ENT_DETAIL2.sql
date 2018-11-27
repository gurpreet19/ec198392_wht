CREATE OR REPLACE FORCE EDITIONABLE VIEW "V_LIFT_ACC_DAY_ENT_DETAIL2" ("OBJECT_ID", "DAYTIME", "FORECAST_QTY", "FORECAST_QTY2", "FORECAST_QTY3", "OFFICIAL_QTY", "OFFICIAL_QTY2", "OFFICIAL_QTY3", "PROD_QTY", "PROD_QTY2", "PROD_QTY3", "CLOSING_BALANCE", "CLOSING_BALANCE2", "CLOSING_BALANCE3", "PARCEL_NO", "CARGO_NO", "NOM_SEQUENCE", "GRS_VOL_NOMINATED", "GRS_VOL_NOMINATED2", "GRS_VOL_NOMINATED3", "RECORD_STATUS", "CREATED_BY", "CREATED_DATE", "LAST_UPDATED_BY", "LAST_UPDATED_DATE", "REV_NO", "REV_TEXT") AS 
  (
----------------------------------------------------------------------------------------------------
-- File name: v_lift_acc_day_ent_detail2 .sql
-- View name: v_lift_acc_day_ent_detail2
--
-- $Revision: 1.3 $
--
-- Purpose  :
--
-- Modification history:
--
-- Date       Whom      Change description:
-- ---------- --------  --------------------------------------------------------------------------------
-- 12.11.2012 meisihil  Intial version
-- 17.07.2017 baratmah  ECPD-45870 Fixed filtering on cargo status
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
               NVL(ecbp_storage_lift_nomination.calcAggrSubDaySplitQty(sl.parcel_no, sl.company_id, sl.lifting_account_id, sn.production_day)
                     ,     ue_Storage_Lift_Nomination.aggrSubDayLifting(n.PARCEL_NO, sn.production_day)
                     ) grs_vol_nominated,
               NVL(ecbp_storage_lift_nomination.calcAggrSubDaySplitQty(sl.parcel_no, sl.company_id, sl.lifting_account_id, sn.production_day, 1)
                     ,     ue_Storage_Lift_Nomination.aggrSubDayLifting(n.PARCEL_NO, sn.production_day, NULL, 1)
                     ) grs_vol_nominated2,
               NVL(ecbp_storage_lift_nomination.calcAggrSubDaySplitQty(sl.parcel_no, sl.company_id, sl.lifting_account_id, sn.production_day, 2)
                     ,     ue_Storage_Lift_Nomination.aggrSubDayLifting(n.PARCEL_NO, sn.production_day, NULL, 2)
                     ) grs_vol_nominated3,
               sn.production_day firm_date,
               n.CARGO_NO,
               n.PARCEL_NO,
               n.NOM_SEQUENCE,
               decode(nvl(ec_lifting_account.lift_agreement_ind(n.lifting_account_id), 'N'), 'N',
                          n.lifting_account_id, sl.lifting_account_id) as lifting_account_id
          FROM storage_lift_nomination n, cargo_transport t, storage_lift_nom_split sl, cargo_status_mapping csm,
      	       (SELECT distinct production_day, parcel_no FROM stor_sub_day_lift_nom) sn
         WHERE t.cargo_no(+) = n.cargo_no
		   AND t.cargo_status= csm.cargo_status
           AND (t.cargo_no IS NULL OR csm.ec_cargo_status <> 'D')
		   AND n.parcel_no = sn.parcel_no
           AND sl.parcel_no (+) = n.parcel_no) n
 where n.lifting_account_id(+) = la.object_id
   and n.firm_date(+) = la.daytime
)