CREATE OR REPLACE FORCE EDITIONABLE VIEW "V_LIFT_ACC_SUB_DAY_ENT" ("OBJECT_ID", "DAYTIME", "SUMMER_TIME", "PRODUCTION_DAY", "FORECAST_QTY", "FORECAST_QTY2", "FORECAST_QTY3", "OFFICIAL_QTY", "OFFICIAL_QTY2", "OFFICIAL_QTY3", "CLOSING_BALANCE", "CLOSING_BALANCE2", "CLOSING_BALANCE3", "GRS_VOL_NOMINATED", "GRS_VOL_NOMINATED2", "GRS_VOL_NOMINATED3", "CARGO_NO", "PARCEL_NO", "NOM_SEQUENCE", "RECORD_STATUS", "CREATED_BY", "CREATED_DATE", "LAST_UPDATED_BY", "LAST_UPDATED_DATE", "REV_NO", "REV_TEXT") AS 
  (
----------------------------------------------------------------------------------------------------
-- File name: v_lift_acc_sub_day_ent.sql
-- View name: v_lift_acc_sub_day_ent
--
-- $Revision: 1.7 $
--
-- Purpose  :
--
-- Modification history:
--
-- Date       Whom  	Change description:
-- ---------- ----  --------------------------------------------------------------------------------
-- 23.12.2009 KSN  		Intial version
-- 22.02.2012 leeeejin 	Modify grs_vol_nominated and lifting_account_id values
-- 01-04-2015 asareswi 	Modify changed package name ecbp_storage_lift_nomination.calcSplitQty to ue_storage_lift_nomination.calcSplitQty.
-- 04.07.2017 baratmah  ECPD-45870 Fixed filtering on cargo status
----------------------------------------------------------------------------------------------------
SELECT f.object_id,
       f.daytime,
       f.summer_time,
       f.production_day,
       f.forecast_qty,
       f.forecast_qty2,
       f.forecast_qty3,
	(select official_qty FROM lift_acc_sub_day_official WHERE daytime = f.daytime AND summer_time = f.summer_time AND object_id = f.object_id) official_qty,
	(select official_qty2 FROM lift_acc_sub_day_official WHERE daytime = f.daytime AND summer_time = f.summer_time AND object_id = f.object_id) official_qty2,
	(select official_qty3 FROM lift_acc_sub_day_official WHERE daytime = f.daytime AND summer_time = f.summer_time AND object_id = f.object_id) official_qty3,
       (select EcBp_Lift_Acc_Balance.calcEstClosingBalanceSubDay(f.object_id,f.daytime, f.summer_time) from dual) CLOSING_BALANCE,
       (select EcBp_Lift_Acc_Balance.calcEstClosingBalanceSubDay(f.object_id,f.daytime, f.summer_time, 1) from dual) CLOSING_BALANCE2,
       (select EcBp_Lift_Acc_Balance.calcEstClosingBalanceSubDay(f.object_id,f.daytime, f.summer_time, 2) from dual) CLOSING_BALANCE3,
       l.grs_vol_nominated,
       l.grs_vol_nominated2,
       l.grs_vol_nominated3,
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
               NVL(ue_storage_lift_nomination.calcSplitQty(sl.parcel_no, sl.company_id, sl.lifting_account_id, sn.production_day, nvl(ecbp_storage_lift_nomination.getLiftedVolSubDay(n.parcel_no, sn.daytime, sn.summer_time), sn.grs_vol_nominated)),
                   nvl(ecbp_storage_lift_nomination.getLiftedVolSubDay(n.parcel_no, sn.daytime, sn.summer_time), sn.grs_vol_nominated)) grs_vol_nominated,
               NVL(ue_storage_lift_nomination.calcSplitQty(sl.parcel_no, sl.company_id, sl.lifting_account_id, sn.production_day, nvl(ecbp_storage_lift_nomination.getLiftedVolSubDay(n.parcel_no, sn.daytime, sn.summer_time, 1), sn.grs_vol_nominated2)),
                   nvl(ecbp_storage_lift_nomination.getLiftedVolSubDay(n.parcel_no, sn.daytime, sn.summer_time, 1), sn.grs_vol_nominated2)) grs_vol_nominated2,
               NVL(ue_storage_lift_nomination.calcSplitQty(sl.parcel_no, sl.company_id, sl.lifting_account_id, sn.production_day, nvl(ecbp_storage_lift_nomination.getLiftedVolSubDay(n.parcel_no, sn.daytime, sn.summer_time, 2), sn.grs_vol_nominated3)),
                   nvl(ecbp_storage_lift_nomination.getLiftedVolSubDay(n.parcel_no, sn.daytime, sn.summer_time, 2), sn.grs_vol_nominated3)) grs_vol_nominated3,
               sn.daytime firm_date_time,
               sn.summer_time summer_time,
               n.CARGO_NO,
               n.PARCEL_NO,
               n.NOM_SEQUENCE,
               decode(nvl(ec_lifting_account.lift_agreement_ind(n.lifting_account_id), 'N'), 'N',
               n.lifting_account_id, sl.lifting_account_id) as lifting_account_id
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