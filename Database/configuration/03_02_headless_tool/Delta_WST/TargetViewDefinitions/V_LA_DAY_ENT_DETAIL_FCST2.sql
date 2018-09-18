CREATE OR REPLACE FORCE VIEW "V_LA_DAY_ENT_DETAIL_FCST2" ("OBJECT_ID", "DAYTIME", "FORECAST_ID", "PROD_QTY", "PROD_QTY2", "PROD_QTY3", "CLOSING_BALANCE", "CLOSING_BALANCE2", "CLOSING_BALANCE3", "PARCEL_NO", "CARGO_NO", "NOM_SEQUENCE", "GRS_VOL_NOMINATED", "GRS_VOL_NOMINATED2", "GRS_VOL_NOMINATED3", "RECORD_STATUS", "CREATED_BY", "CREATED_DATE", "LAST_UPDATED_BY", "LAST_UPDATED_DATE", "REV_NO", "REV_TEXT") AS 
  (
----------------------------------------------------------------------------------------------------
-- File name: v_la_day_ent_detail_fcst2.sql
-- View name: v_la_day_ent_detail_fcst2
--
-- $Revision: 1.1.2.1 $
--
-- Purpose  :
--
-- Modification history:
--
-- Date       Whom      Change description:
-- ---------- --------  --------------------------------------------------------------------------------
-- 09.11.2012 meisihil  Intial version
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
  FROM LIFT_ACC_DAY_FCST_FCAST la,
       (SELECT n.object_id,
       	       n.forecast_id,
               ue_Stor_Fcst_Lift_Nom.aggrSubDayLifting(n.forecast_id, n.PARCEL_NO, sn.production_day) grs_vol_nominated,
               ue_Stor_Fcst_Lift_Nom.aggrSubDayLifting(n.forecast_id, n.PARCEL_NO, sn.production_day, NULL, 1) grs_vol_nominated2,
               ue_Stor_Fcst_Lift_Nom.aggrSubDayLifting(n.forecast_id, n.PARCEL_NO, sn.production_day, NULL, 2) grs_vol_nominated3,
               sn.production_day firm_date,
               n.CARGO_NO,
               n.PARCEL_NO,
               n.NOM_SEQUENCE,
               n.lifting_account_id
          FROM stor_fcst_lift_nom n, cargo_fcst_transport t,
      	   (SELECT distinct forecast_id, production_day, parcel_no FROM stor_fcst_sub_day_lift_nom) sn
         WHERE t.cargo_no(+) = n.cargo_no
           AND t.forecast_id (+) = n.forecast_id
           AND n.parcel_no = sn.parcel_no
           AND n.forecast_id = sn.forecast_id
           AND t.cargo_status <> 'D'
		   AND nvl(n.deleted_ind, 'N') <> 'Y') n
 where n.lifting_account_id(+) = la.object_id
   AND n.firm_date(+) = la.daytime
   AND n.forecast_id (+)= la.forecast_id
)