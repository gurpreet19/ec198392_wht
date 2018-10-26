CREATE OR REPLACE FORCE EDITIONABLE VIEW "V_FCST_LIFT_ACC_DAY_RECEIPT2" ("OBJECT_ID", "DAYTIME", "FORECAST_ID", "GRS_VOL_NOMINATED", "GRS_VOL_NOMINATED2", "GRS_VOL_NOMINATED3", "GRS_VOL_REQUESTED", "GRS_VOL_REQUESTED2", "GRS_VOL_REQUESTED3", "GRS_VOL_SCHEDULE", "GRS_VOL_SCHEDULED2", "GRS_VOL_SCHEDULED3", "CARGO_NO", "PARCEL_NO", "NOM_SEQUENCE", "RECORD_STATUS", "CREATED_BY", "CREATED_DATE", "LAST_UPDATED_BY", "LAST_UPDATED_DATE", "REV_NO", "REV_TEXT") AS 
  (
----------------------------------------------------------------------------------------------------
-- File name: v_fcst_lift_acc_day_receipt2.sql
-- View name: v_fcst_lift_acc_day_receipt2
--
-- $Revision: 1.3 $
--
-- Purpose  :
--
-- Modification history:
--
-- Date       Whom      Change description:
-- ---------- ----      --------------------------------------------------------------------------------
-- 09.11.2012 meisihil  Intial version
-- 28.03.2017 farhaann  ECPD-44120: Added fcst_stor_lift_cpy_split table and modified GRS_VOL_NOMINATED, GRS_VOL_NOMINATED2, GRS_VOL_NOMINATED3,
--                      GRS_VOL_REQUESTED, GRS_VOL_REQUESTED2, GRS_VOL_REQUESTED3
--                      GRS_VOL_SCHEDULE, GRS_VOL_SCHEDULED2 and GRS_VOL_SCHEDULED3
-- 17.07.2017 baratmah  ECPD-45870 Fixed filtering on cargo status
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
			   nvl(ue_Stor_Fcst_Lift_Nom.calcAggrSubDaySplitQty(sl.forecast_id, sl.parcel_no, sl.company_id, sl.lifting_account_id, sn.production_day, 'NOMINATED', 0), ue_Stor_Fcst_Lift_Nom.aggrSubDayLifting(n.forecast_id, n.parcel_no, sn.production_day, 'NOMINATED', 0)) GRS_VOL_NOMINATED,
			   nvl(ue_Stor_Fcst_Lift_Nom.calcAggrSubDaySplitQty(sl.forecast_id, sl.parcel_no, sl.company_id, sl.lifting_account_id, sn.production_day, 'NOMINATED', 1), ue_Stor_Fcst_Lift_Nom.aggrSubDayLifting(n.forecast_id, n.parcel_no, sn.production_day, 'NOMINATED', 1)) GRS_VOL_NOMINATED2,
			   nvl(ue_Stor_Fcst_Lift_Nom.calcAggrSubDaySplitQty(sl.forecast_id, sl.parcel_no, sl.company_id, sl.lifting_account_id, sn.production_day, 'NOMINATED', 2), ue_Stor_Fcst_Lift_Nom.aggrSubDayLifting(n.forecast_id, n.parcel_no, sn.production_day, 'NOMINATED', 2)) GRS_VOL_NOMINATED3,
			   nvl(ue_Stor_Fcst_Lift_Nom.calcAggrSubDaySplitQty(sl.forecast_id, sl.parcel_no, sl.company_id, sl.lifting_account_id, sn.production_day, 'REQUESTED', 0), ue_Stor_Fcst_Lift_Nom.aggrSubDayLifting(n.forecast_id, n.parcel_no, sn.production_day, 'REQUESTED', 0)) GRS_VOL_REQUESTED,
			   nvl(ue_Stor_Fcst_Lift_Nom.calcAggrSubDaySplitQty(sl.forecast_id, sl.parcel_no, sl.company_id, sl.lifting_account_id, sn.production_day, 'REQUESTED', 1), ue_Stor_Fcst_Lift_Nom.aggrSubDayLifting(n.forecast_id, n.parcel_no, sn.production_day, 'REQUESTED', 1)) GRS_VOL_REQUESTED2,
			   nvl(ue_Stor_Fcst_Lift_Nom.calcAggrSubDaySplitQty(sl.forecast_id, sl.parcel_no, sl.company_id, sl.lifting_account_id, sn.production_day, 'REQUESTED', 2), ue_Stor_Fcst_Lift_Nom.aggrSubDayLifting(n.forecast_id, n.parcel_no, sn.production_day, 'REQUESTED', 2)) GRS_VOL_REQUESTED3,
			   nvl(ue_Stor_Fcst_Lift_Nom.calcAggrSubDaySplitQty(sl.forecast_id, sl.parcel_no, sl.company_id, sl.lifting_account_id, sn.production_day, 'SCHEDULED', 0), ue_Stor_Fcst_Lift_Nom.aggrSubDayLifting(n.forecast_id, n.parcel_no, sn.production_day, 'SCHEDULED', 0)) GRS_VOL_SCHEDULE,
			   nvl(ue_Stor_Fcst_Lift_Nom.calcAggrSubDaySplitQty(sl.forecast_id, sl.parcel_no, sl.company_id, sl.lifting_account_id, sn.production_day, 'SCHEDULED', 1), ue_Stor_Fcst_Lift_Nom.aggrSubDayLifting(n.forecast_id, n.parcel_no, sn.production_day, 'SCHEDULED', 1)) GRS_VOL_SCHEDULED2,
			   nvl(ue_Stor_Fcst_Lift_Nom.calcAggrSubDaySplitQty(sl.forecast_id, sl.parcel_no, sl.company_id, sl.lifting_account_id, sn.production_day, 'SCHEDULED', 2), ue_Stor_Fcst_Lift_Nom.aggrSubDayLifting(n.forecast_id, n.parcel_no, sn.production_day, 'SCHEDULED', 2)) GRS_VOL_SCHEDULED3,
               sn.production_day firm_date,
               n.CARGO_NO,
               n.PARCEL_NO,
               n.NOM_SEQUENCE,
			   decode(nvl(ec_lifting_account.lift_agreement_ind(n.lifting_account_id), 'N'), 'N', n.lifting_account_id, sl.lifting_account_id) as lifting_account_id
         FROM stor_fcst_lift_nom n, cargo_fcst_transport t, fcst_stor_lift_cpy_split sl, cargo_status_mapping csm,
      	   (SELECT distinct forecast_id, production_day, parcel_no FROM stor_fcst_sub_day_lift_nom) sn
         WHERE t.cargo_no(+) = n.cargo_no
		   AND t.cargo_status= csm.cargo_status
		   AND t.forecast_id (+) = n.forecast_id
		   AND sl.forecast_id (+) = n.forecast_id
           AND n.parcel_no = sn.parcel_no
           AND n.forecast_id = sn.forecast_id
           AND (t.cargo_no IS NULL OR csm.ec_cargo_status <> 'D')
		   AND nvl(n.DELETED_IND, 'N') <> 'Y'
		   AND sl.parcel_no (+) = n.parcel_no) l
 WHERE l.firm_date(+) = f.daytime
   AND l.lifting_account_id(+) = f.object_id
   AND l.forecast_id (+)= f.forecast_id
)