CREATE OR REPLACE FORCE EDITIONABLE VIEW "V_FCST_STOR_SUB_DAY_ENT" ("OBJECT_ID", "DAYTIME", "SUMMER_TIME", "FORECAST_ID", "PRODUCTION_DAY", "CARGO_NO", "PARCEL_NO", "NOM_SEQUENCE", "LIFTING_ACCOUNT_ID", "NOM_LIFTED_QTY", "NOM_LIFTED_QTY2", "NOM_LIFTED_QTY3", "PROD_QTY", "PROD_QTY2", "PROD_QTY3", "CLOSING_BALANCE", "CLOSING_BALANCE2", "CLOSING_BALANCE3", "RECORD_STATUS", "CREATED_BY", "CREATED_DATE", "LAST_UPDATED_BY", "LAST_UPDATED_DATE", "REV_NO", "REV_TEXT") AS 
  (
----------------------------------------------------------------------------------------------------
-- File name: v_fcst_stor_sub_day_ent.sql
-- View name: v_fcst_stor_sub_day_ent
--
-- $Revision: 1.6 $
--
-- Purpose  :
--
-- Modification history:
--
-- Date       Whom      Change description:
-- ---------- ----      --------------------------------------------------------------------------------
-- 04.12.2009 KSN       Intial version
-- 19.02.2010 masamken  update the view with forecast values for clossing balance  (calcStorageLevelSubDay)
-- 17.07.2017 baratmah  ECPD-45870 Fixed filtering on cargo status
----------------------------------------------------------------------------------------------------
SELECT fc.object_id,
       fc.daytime,
       fc.SUMMER_TIME,
	   fc.forecast_id,
       fc.PRODUCTION_DAY,
       l.CARGO_NO,
       l.PARCEL_NO,
       l.NOM_SEQUENCE,
       l.LIFTING_ACCOUNT_ID,
    decode(nvl(ec_forecast.cargo_off_qty_ind(fc.forecast_id),'N'),'N',l.grs_vol_nominated ,nvl(ecbp_storage_lift_nomination.getLiftedVolSubDay(l.parcel_no, fc.DAYTIME, fc.summer_time),l.grs_vol_nominated)) NOM_LIFTED_QTY,
    decode(nvl(ec_forecast.cargo_off_qty_ind(fc.forecast_id),'N'),'N',l.grs_vol_nominated2 ,nvl(ecbp_storage_lift_nomination.getLiftedVolSubDay(l.parcel_no, fc.DAYTIME, fc.summer_time, 1),l.grs_vol_nominated2)) NOM_LIFTED_QTY2,
    decode(nvl(ec_forecast.cargo_off_qty_ind(fc.forecast_id),'N'),'N',l.grs_vol_nominated3 ,nvl(ecbp_storage_lift_nomination.getLiftedVolSubDay(l.parcel_no, fc.DAYTIME, fc.summer_time, 2),l.grs_vol_nominated3)) NOM_LIFTED_QTY3,
	   fc.forecast_qty PROD_QTY,
	   fc.forecast_qty2 PROD_QTY2,
       fc.forecast_qty3 PROD_QTY3,
   	   (SELECT EcDp_Stor_Fcst_Balance.calcStorageLevelSubDay(fc.OBJECT_ID, fc.forecast_id, fc.DAYTIME, fc.summer_time) FROM dual) CLOSING_BALANCE,
	   (SELECT EcDp_Stor_Fcst_Balance.calcStorageLevelSubDay(fc.OBJECT_ID, fc.forecast_id, fc.DAYTIME, fc.summer_time, 1) FROM dual) CLOSING_BALANCE2,
       (SELECT EcDp_Stor_Fcst_Balance.calcStorageLevelSubDay(fc.OBJECT_ID, fc.forecast_id, fc.DAYTIME, fc.summer_time, 2) FROM dual) CLOSING_BALANCE3,
       to_char(null) record_status,
       to_char(null) created_by,
       to_date(null) created_date,
       to_char(null) last_updated_by,
       to_date(null) last_updated_date,
       to_number(null) rev_no,
       to_char(null) rev_text
  FROM stor_sub_day_fcst_fcast fc,
       (SELECT n.object_id,
			   n.forecast_id,
               n.CARGO_NO,
               n.PARCEL_NO,
               n.NOM_SEQUENCE,
               n.LIFTING_ACCOUNT_ID,
               sn.grs_vol_nominated grs_vol_nominated,
               sn.grs_vol_nominated2 grs_vol_nominated2,
               sn.grs_vol_nominated3 grs_vol_nominated3,
               sn.daytime firm_date_time,
               sn.summer_time summer_time
		  FROM stor_fcst_lift_nom n, cargo_fcst_transport t, stor_fcst_sub_day_lift_nom sn, cargo_status_mapping csm
         WHERE t.cargo_no(+) = n.cargo_no
		   AND t.cargo_status= csm.cargo_status
		   AND t.forecast_id (+) = n.forecast_id
           AND n.parcel_no = sn.parcel_no
           AND n.forecast_id = sn.forecast_id
           AND (t.cargo_no IS NULL OR csm.ec_cargo_status <> 'D')
		   AND nvl(n.DELETED_IND, 'N') <> 'Y') l
 WHERE l.firm_date_time(+) = fc.daytime
   AND l.summer_time(+) = fc.summer_time
   AND l.object_id(+) = fc.object_id
   AND l.forecast_id (+)= fc.forecast_id
 GROUP BY fc.object_id,
          fc.daytime,
 	    	  fc.forecast_id,
          fc.SUMMER_TIME,
          fc.PRODUCTION_DAY,
          l.NOM_SEQUENCE,
          l.CARGO_NO,
          l.PARCEL_NO,
          l.LIFTING_ACCOUNT_ID,
          l.GRS_VOL_NOMINATED,
		      l.GRS_VOL_NOMINATED2,
 		      l.GRS_VOL_NOMINATED3,
              fc.forecast_qty,
     		  fc.forecast_qty2,
     		  fc.forecast_qty3
)