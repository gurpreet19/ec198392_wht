CREATE OR REPLACE FORCE VIEW "V_FCST_LIFT_ACC_DAY_RECEIPT2" ("OBJECT_ID", "DAYTIME", "FORECAST_ID", "GRS_VOL_NOMINATED", "GRS_VOL_NOMINATED2", "GRS_VOL_NOMINATED3", "GRS_VOL_REQUESTED", "GRS_VOL_REQUESTED2", "GRS_VOL_REQUESTED3", "GRS_VOL_SCHEDULE", "GRS_VOL_SCHEDULED2", "GRS_VOL_SCHEDULED3", "CARGO_NO", "PARCEL_NO", "NOM_SEQUENCE", "RECORD_STATUS", "CREATED_BY", "CREATED_DATE", "LAST_UPDATED_BY", "LAST_UPDATED_DATE", "REV_NO", "REV_TEXT") AS 
  (
----------------------------------------------------------------------------------------------------
-- File name: v_fcst_lift_acc_day_receipt2.sql
-- View name: v_fcst_lift_acc_day_receipt2
--
-- $Revision: 1.1.2.1 $
--
-- Purpose  :
--
-- Modification history:
--
-- Date       Whom             Change description:
-- ---------- ----             --------------------------------------------------------------------------------
-- 09.11.2012 meisihil  Intial version
----------------------------------------------------------------------------------------------------
SELECT f.object_id,
       f.daytime,
	   f.forecast_id,
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
  FROM LIFT_ACC_DAY_FCST_FCAST f,
       (SELECT n.object_id,
	           n.forecast_id,
               ue_Stor_Fcst_Lift_Nom.aggrSubDayLifting(n.forecast_id, n.PARCEL_NO, sn.production_day, 'NOMINATED', 0) GRS_VOL_NOMINATED,
               ue_Stor_Fcst_Lift_Nom.aggrSubDayLifting(n.forecast_id, n.PARCEL_NO, sn.production_day, 'NOMINATED', 1) grs_vol_nominated2,
			   ue_Stor_Fcst_Lift_Nom.aggrSubDayLifting(n.forecast_id, n.PARCEL_NO, sn.production_day, 'NOMINATED', 2) grs_vol_nominated3,
               ue_Stor_Fcst_Lift_Nom.aggrSubDayLifting(n.forecast_id, n.PARCEL_NO, sn.production_day, 'REQUESTED', 0) GRS_VOL_REQUESTED,
               ue_Stor_Fcst_Lift_Nom.aggrSubDayLifting(n.forecast_id, n.PARCEL_NO, sn.production_day, 'REQUESTED', 1) GRS_VOL_REQUESTED2,
			   ue_Stor_Fcst_Lift_Nom.aggrSubDayLifting(n.forecast_id, n.PARCEL_NO, sn.production_day, 'REQUESTED', 2) GRS_VOL_REQUESTED3,
               ue_Stor_Fcst_Lift_Nom.aggrSubDayLifting(n.forecast_id, n.PARCEL_NO, sn.production_day, 'SCHEDULED', 0) GRS_VOL_SCHEDULE,
               ue_Stor_Fcst_Lift_Nom.aggrSubDayLifting(n.forecast_id, n.PARCEL_NO, sn.production_day, 'SCHEDULED', 1) GRS_VOL_SCHEDULED2,
			   ue_Stor_Fcst_Lift_Nom.aggrSubDayLifting(n.forecast_id, n.PARCEL_NO, sn.production_day, 'SCHEDULED', 2) GRS_VOL_SCHEDULED3,
               sn.production_day firm_date,
               n.CARGO_NO,
               n.PARCEL_NO,
               n.NOM_SEQUENCE,
               n.LIFTING_ACCOUNT_ID
         FROM stor_fcst_lift_nom n, cargo_fcst_transport t,
      	   (SELECT distinct forecast_id, production_day, parcel_no FROM stor_fcst_sub_day_lift_nom) sn
         WHERE t.cargo_no(+) = n.cargo_no
		   AND t.forecast_id (+) = n.forecast_id
           AND n.parcel_no = sn.parcel_no
           AND n.forecast_id = sn.forecast_id
           AND t.cargo_status <> 'D'
		   AND nvl(n.DELETED_IND, 'N') <> 'Y') l
 WHERE l.firm_date(+) = f.daytime
   AND l.lifting_account_id(+) = f.object_id
   AND l.forecast_id (+)= f.forecast_id
)