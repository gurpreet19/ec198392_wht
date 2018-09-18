CREATE OR REPLACE FORCE VIEW "V_FCST_LIFT_ACC_SUB_DAY_ENT" ("OBJECT_ID", "DAYTIME", "SUMMER_TIME", "PRODUCTION_DAY", "FORECAST_QTY", "FORECAST_QTY2", "FORECAST_QTY3", "FORECAST_ID", "CLOSING_BALANCE", "CLOSING_BALANCE2", "CLOSING_BALANCE3", "GRS_VOL_NOMINATED", "GRS_VOL_NOMINATED2", "GRS_VOL_NOMINATED3", "CARGO_NO", "PARCEL_NO", "NOM_SEQUENCE", "RECORD_STATUS", "CREATED_BY", "CREATED_DATE", "LAST_UPDATED_BY", "LAST_UPDATED_DATE", "REV_NO", "REV_TEXT") AS 
  (
----------------------------------------------------------------------------------------------------
-- File name: V_FCST_LIFT_ACC_SUB_DAY_ENT.sql
-- View name: V_FCST_LIFT_ACC_SUB_DAY_ENT
--
-- $Revision: 1.5.4.1 $
--
-- Purpose  :
--
-- Modification history:
--
-- Date       Whom       Change description:
-- ---------- ----       --------------------------------------------------------------------------------
-- 23.12.2009 KSN        Intial version
-- 19.02.2010 masamken    create new function calcEstClosingBalanceSubDay
----------------------------------------------------------------------------------------------------
SELECT f.object_id,
       f.daytime,
       f.summer_time,
       f.production_day,
       f.forecast_qty,
       f.forecast_qty2,
       f.forecast_qty3,
	   f.forecast_id,
	   (select EcBp_Lift_Acc_Fcst_Balance.calcEstClosingBalanceSubDay(f.object_id, f.forecast_id, f.daytime, f.summer_time) from dual) CLOSING_BALANCE,
       (select EcBp_Lift_Acc_Fcst_Balance.calcEstClosingBalanceSubDay(f.object_id, f.forecast_id, f.daytime, f.summer_time, 1) from dual) CLOSING_BALANCE2,
       (select EcBp_Lift_Acc_Fcst_Balance.calcEstClosingBalanceSubDay(f.object_id, f.forecast_id, f.daytime, f.summer_time, 2) from dual) CLOSING_BALANCE3,
    decode(nvl(ec_forecast.cargo_off_qty_ind(f.forecast_id),'N'),'N',l.grs_vol_nominated ,nvl(ecbp_storage_lift_nomination.getLiftedVolSubDay(l.parcel_no, f.daytime, f.summer_time),l.grs_vol_nominated)) grs_vol_nominated,
    decode(nvl(ec_forecast.cargo_off_qty_ind(f.forecast_id),'N'),'N',l.grs_vol_nominated2 ,nvl(ecbp_storage_lift_nomination.getLiftedVolSubDay(l.parcel_no, f.daytime, f.summer_time, 1),l.grs_vol_nominated2)) grs_vol_nominated2,
    decode(nvl(ec_forecast.cargo_off_qty_ind(f.forecast_id),'N'),'N',l.grs_vol_nominated3 ,nvl(ecbp_storage_lift_nomination.getLiftedVolSubDay(l.parcel_no, f.daytime, f.summer_time, 2),l.grs_vol_nominated3)) grs_vol_nominated3,
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
  FROM lift_acc_sub_day_fcst_fc f,
       (SELECT n.object_id,
			   n.forecast_id,
               sn.grs_vol_nominated grs_vol_nominated,
               sn.grs_vol_nominated2 grs_vol_nominated2,
               sn.grs_vol_nominated3 grs_vol_nominated3,
               sn.daytime firm_date_time,
               sn.summer_time summer_time,
               n.CARGO_NO,
               n.PARCEL_NO,
               n.NOM_SEQUENCE,
               n.LIFTING_ACCOUNT_ID
		  FROM stor_fcst_lift_nom n, cargo_fcst_transport t, stor_fcst_sub_day_lift_nom sn
         WHERE t.cargo_no(+) = n.cargo_no
		   AND t.forecast_id (+) = n.forecast_id
           AND n.parcel_no = sn.parcel_no
           AND n.forecast_id = sn.forecast_id
           AND t.cargo_status <> 'D'
		   AND nvl(n.deleted_ind, 'N') <> 'Y') l
 WHERE l.firm_date_time(+) = f.daytime
   AND l.summer_time(+) = f.summer_time
   AND l.lifting_account_id(+) = f.object_id
   AND l.forecast_id (+)= f.forecast_id
)