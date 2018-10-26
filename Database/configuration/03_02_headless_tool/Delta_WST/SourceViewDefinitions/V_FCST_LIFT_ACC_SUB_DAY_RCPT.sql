CREATE OR REPLACE FORCE EDITIONABLE VIEW "V_FCST_LIFT_ACC_SUB_DAY_RCPT" ("OBJECT_ID", "DAYTIME", "FORECAST_ID", "SUMMER_TIME", "PRODUCTION_DAY", "GRS_VOL_NOMINATED", "GRS_VOL_NOMINATED2", "GRS_VOL_NOMINATED3", "GRS_VOL_REQUESTED", "GRS_VOL_REQUESTED2", "GRS_VOL_REQUESTED3", "GRS_VOL_SCHEDULE", "GRS_VOL_SCHEDULED2", "GRS_VOL_SCHEDULED3", "CARGO_NO", "PARCEL_NO", "NOM_SEQUENCE", "RECORD_STATUS", "CREATED_BY", "CREATED_DATE", "LAST_UPDATED_BY", "LAST_UPDATED_DATE", "REV_NO", "REV_TEXT") AS 
  (
----------------------------------------------------------------------------------------------------
-- File name: v_fcst_lift_acc_sub_day_rcpt.sql
-- View name: v_fcst_lift_acc_sub_day_rcpt
--
-- $Revision: 1.4 $
--
-- Purpose  :
--
-- Modification history:
--
-- Date       Whom             Change description:
-- ---------- ----             --------------------------------------------------------------------------------
-- 17.02.2010 Kenneth Masamba  Intial version
-- 28.03.2017 farhaann         ECPD-44120: Added fcst_stor_lift_cpy_split table and modified GRS_VOL_NOMINATED, GRS_VOL_NOMINATED2, GRS_VOL_NOMINATED3,
--                             GRS_VOL_REQUESTED, GRS_VOL_REQUESTED2, GRS_VOL_REQUESTED3
--                             GRS_VOL_SCHEDULE, GRS_VOL_SCHEDULED2 and GRS_VOL_SCHEDULED3
-- 17.07.2017 baratmah  	   ECPD-45870 Fixed filtering on cargo status
----------------------------------------------------------------------------------------------------
SELECT f.object_id,
       f.daytime,
	   f.forecast_id,
       f.summer_time,
       f.production_day,
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
  FROM lift_acc_sub_day_fcst_fc f,
       (SELECT n.object_id,
               n.forecast_id,
               nvl(ue_Stor_Fcst_Lift_Nom.getSubDaySplitQty(sl.forecast_id, sl.parcel_no, sl.company_id, sl.lifting_account_id, sn.production_day, sn.grs_vol_nominated, 'NOMINATED'), sn.grs_vol_nominated) grs_vol_nominated,
			   nvl(ue_Stor_Fcst_Lift_Nom.getSubDaySplitQty(sl.forecast_id, sl.parcel_no, sl.company_id, sl.lifting_account_id, sn.production_day, sn.grs_vol_nominated2, 'NOMINATED'), sn.grs_vol_nominated2) grs_vol_nominated2,
			   nvl(ue_Stor_Fcst_Lift_Nom.getSubDaySplitQty(sl.forecast_id, sl.parcel_no, sl.company_id, sl.lifting_account_id, sn.production_day, sn.grs_vol_nominated3, 'NOMINATED'), sn.grs_vol_nominated3) grs_vol_nominated3,
			   nvl(ue_Stor_Fcst_Lift_Nom.getSubDaySplitQty(sl.forecast_id, sl.parcel_no, sl.company_id, sl.lifting_account_id, sn.production_day, sn.grs_vol_requested, 'REQUESTED'), sn.grs_vol_requested) grs_vol_requested,
			   nvl(ue_Stor_Fcst_Lift_Nom.getSubDaySplitQty(sl.forecast_id, sl.parcel_no, sl.company_id, sl.lifting_account_id, sn.production_day, sn.grs_vol_requested2, 'REQUESTED'), sn.grs_vol_requested2) grs_vol_requested2,
			   nvl(ue_Stor_Fcst_Lift_Nom.getSubDaySplitQty(sl.forecast_id, sl.parcel_no, sl.company_id, sl.lifting_account_id, sn.production_day, sn.grs_vol_requested3, 'REQUESTED'), sn.grs_vol_requested3) grs_vol_requested3,
			   nvl(ue_Stor_Fcst_Lift_Nom.getSubDaySplitQty(sl.forecast_id, sl.parcel_no, sl.company_id, sl.lifting_account_id, sn.production_day, sn.grs_vol_schedule, 'SCHEDULED'), sn.grs_vol_schedule) grs_vol_schedule,
			   nvl(ue_Stor_Fcst_Lift_Nom.getSubDaySplitQty(sl.forecast_id, sl.parcel_no, sl.company_id, sl.lifting_account_id, sn.production_day, sn.grs_vol_scheduled2, 'SCHEDULED'), sn.grs_vol_scheduled2) grs_vol_scheduled2,
			   nvl(ue_Stor_Fcst_Lift_Nom.getSubDaySplitQty(sl.forecast_id, sl.parcel_no, sl.company_id, sl.lifting_account_id, sn.production_day, sn.grs_vol_scheduled3, 'SCHEDULED'), sn.grs_vol_scheduled3) grs_vol_scheduled3,
               sn.daytime firm_date_time,
               sn.summer_time summer_time,
               n.CARGO_NO,
               n.PARCEL_NO,
               n.NOM_SEQUENCE,
			   decode(nvl(ec_lifting_account.lift_agreement_ind(n.lifting_account_id), 'N'), 'N', n.lifting_account_id, sl.lifting_account_id) as LIFTING_ACCOUNT_ID
          FROM stor_fcst_lift_nom n, cargo_fcst_transport t, stor_fcst_sub_day_lift_nom sn, fcst_stor_lift_cpy_split sl, cargo_status_mapping csm
         WHERE t.cargo_no(+) = n.cargo_no
		   AND t.cargo_status= csm.cargo_status
           AND t.forecast_id (+) = n.forecast_id
	       AND sl.forecast_id (+) = n.forecast_id
           AND n.parcel_no = sn.parcel_no
		   AND sl.parcel_no (+) = n.parcel_no
           AND n.forecast_id = sn.forecast_id
           AND (t.cargo_no IS NULL OR csm.ec_cargo_status <> 'D')
       AND nvl(n.DELETED_IND, 'N') <> 'Y') l
 WHERE l.firm_date_time(+) = f.daytime
   AND l.summer_time(+) = f.summer_time
   AND l.lifting_account_id(+) = f.object_id
   AND l.forecast_id (+)= f.forecast_id
)