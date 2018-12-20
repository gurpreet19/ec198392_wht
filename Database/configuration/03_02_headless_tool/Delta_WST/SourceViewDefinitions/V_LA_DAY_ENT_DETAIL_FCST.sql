CREATE OR REPLACE FORCE EDITIONABLE VIEW "V_LA_DAY_ENT_DETAIL_FCST" ("OBJECT_ID", "DAYTIME", "FORECAST_ID", "PROD_QTY", "PROD_QTY2", "PROD_QTY3", "CLOSING_BALANCE", "CLOSING_BALANCE2", "CLOSING_BALANCE3", "PARCEL_NO", "CARGO_NO", "NOM_SEQUENCE", "GRS_VOL_NOMINATED", "GRS_VOL_NOMINATED2", "GRS_VOL_NOMINATED3", "RECORD_STATUS", "CREATED_BY", "CREATED_DATE", "LAST_UPDATED_BY", "LAST_UPDATED_DATE", "REV_NO", "REV_TEXT") AS 
  (
----------------------------------------------------------------------------------------------------
-- File name: v_la_day_ent_detail_fcst .sql
-- View name: v_la_day_ent_detail_fcst
--
-- $Revision: 1.6 $
--
-- Purpose  :
--
-- Modification history:
--
-- Date       Whom      Change description:
-- ---------- --------  --------------------------------------------------------------------------------
-- 08.01.2009 lauuufus  Intial version
-- 18.02.2009 masamken  add package EcBp_Lift_Acc_Fcst_Balance.calcEstClosingBalanceDay
-- 13.03.2017 farhaann  ECPD-40982: Added fcst_stor_lift_cpy_split
-- 17.07.2017 baratmah  ECPD-45870 Fixed filtering on cargo status
----------------------------------------------------------------------------------------------------
SELECT la.object_id,
       la.daytime,
       la.forecast_id,
       la.forecast_qty PROD_QTY,
       la.forecast_qty2 PROD_QTY2,
       la.forecast_qty3 PROD_QTY3,
       (select EcBp_Lift_Acc_Fcst_Balance.calcEstClosingBalanceDay(la.object_id, la.forecast_id, la.daytime) from dual) CLOSING_BALANCE,
       (select EcBp_Lift_Acc_Fcst_Balance.calcEstClosingBalanceDay(la.object_id, la.forecast_id, la.daytime, 1) from dual) CLOSING_BALANCE2,
       (select EcBp_Lift_Acc_Fcst_Balance.calcEstClosingBalanceDay(la.object_id, la.forecast_id, la.daytime, 2) from dual) CLOSING_BALANCE3,
       n.parcel_no,
       n.cargo_no,
       n.nom_sequence,
    decode(nvl(ec_forecast.cargo_off_qty_ind(la.forecast_id),'N'),'N',n.grs_vol_nominated ,nvl(ecbp_storage_lift_nomination.getLiftedVol(n.parcel_no,null),n.grs_vol_nominated)) grs_vol_nominated,
    decode(nvl(ec_forecast.cargo_off_qty_ind(la.forecast_id),'N'),'N',n.grs_vol_nominated2 ,nvl(ecbp_storage_lift_nomination.getLiftedVol(n.parcel_no,1),n.grs_vol_nominated2)) grs_vol_nominated2,
    decode(nvl(ec_forecast.cargo_off_qty_ind(la.forecast_id),'N'),'N',n.grs_vol_nominated3 ,nvl(ecbp_storage_lift_nomination.getLiftedVol(n.parcel_no,2),n.grs_vol_nominated3)) grs_vol_nominated3,
       to_char(null) record_status,
       to_char(null) created_by,
       to_date(null) created_date,
       to_char(null) last_updated_by,
       to_date(null) last_updated_date,
       to_number(null) rev_no,
       to_char(null) rev_text
  FROM LIFT_ACC_DAY_FCST_FCAST la,
       (SELECT n.object_id,
       	       n.forecast_id,
			   NVL(EcBP_Stor_Fcst_Lift_Nom.calcNomSplitQty(sl.forecast_id, sl.parcel_no, sl.company_id, sl.lifting_account_id),n.grs_vol_nominated) grs_vol_nominated,
			   NVL(EcBP_Stor_Fcst_Lift_Nom.calcNomSplitQty(sl.forecast_id, sl.parcel_no, sl.company_id, sl.lifting_account_id, 1), n.grs_vol_nominated2) grs_vol_nominated2,
			   NVL(EcBP_Stor_Fcst_Lift_Nom.calcNomSplitQty(sl.forecast_id, sl.parcel_no, sl.company_id, sl.lifting_account_id, 2), n.grs_vol_nominated3) grs_vol_nominated3,
               Nvl(n.bl_date, n.nom_firm_date) firm_date,
               n.CARGO_NO,
               n.PARCEL_NO,
               n.NOM_SEQUENCE,
               decode(nvl(ec_lifting_account.lift_agreement_ind(n.lifting_account_id), 'N'), 'N', n.lifting_account_id, sl.lifting_account_id) as lifting_account_id
          FROM stor_fcst_lift_nom n, cargo_fcst_transport t, fcst_stor_lift_cpy_split sl, cargo_status_mapping csm
         WHERE t.cargo_no(+) = n.cargo_no
		   AND t.cargo_status= csm.cargo_status
           AND t.forecast_id (+) = n.forecast_id
           AND (t.cargo_no IS NULL OR csm.ec_cargo_status <> 'D')
		   AND sl.parcel_no (+) = n.parcel_no
		   AND nvl(n.deleted_ind, 'N') <> 'Y') n
 where n.lifting_account_id(+) = la.object_id
   AND n.firm_date(+) = la.daytime
   AND n.forecast_id (+)= la.forecast_id
)