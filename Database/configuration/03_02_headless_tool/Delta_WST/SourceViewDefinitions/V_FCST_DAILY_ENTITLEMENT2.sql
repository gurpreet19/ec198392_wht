CREATE OR REPLACE FORCE EDITIONABLE VIEW "V_FCST_DAILY_ENTITLEMENT2" ("OBJECT_ID", "DAYTIME", "FORECAST_ID", "CARGO_NO", "PARCEL_NO", "NOM_SEQUENCE", "LIFTING_ACCOUNT_ID", "NOM_LIFTED_QTY", "NOM_LIFTED_QTY2", "NOM_LIFTED_QTY3", "PROD_QTY", "PROD_QTY2", "PROD_QTY3", "CLOSING_BALANCE", "CLOSING_BALANCE2", "CLOSING_BALANCE3", "RECORD_STATUS", "CREATED_BY", "CREATED_DATE", "LAST_UPDATED_BY", "LAST_UPDATED_DATE", "REV_NO", "REV_TEXT") AS 
  (
----------------------------------------------------------------------------------------------------
-- File name: v_fcst_daily_entitlement2.sql
-- View name: v_fcst_daily_entitlement2
--
-- $Revision: 1.3 $
--
-- Purpose  :
--
-- Modification history:
--
-- Date       Whom  Change description:
-- ---------- ----  --------------------------------------------------------------------------------
-- 09.11.2012 meisihil  Intial version
-- 04.07.2017 baratmah ECPD-45870 Fixed filtering on cargo status
----------------------------------------------------------------------------------------------------
SELECT fc.object_id,
		fc.daytime,
		fc.forecast_id,
		l.CARGO_NO,
		l.PARCEL_NO,
    		l.NOM_SEQUENCE,
		l.LIFTING_ACCOUNT_ID,
       l.grs_vol_nominated NOM_LIFTED_QTY,
       l.grs_vol_nominated2 NOM_LIFTED_QTY2,
       l.grs_vol_nominated3 NOM_LIFTED_QTY3,
		fc.forecast_qty PROD_QTY,
		fc.forecast_qty2 PROD_QTY2,
		fc.forecast_qty3 PROD_QTY3,
		EcDp_Stor_fcst_Balance.calcStorageLevel(fc.OBJECT_ID, fc.forecast_id, fc.DAYTIME) CLOSING_BALANCE,
		EcDp_Stor_fcst_Balance.calcStorageLevel(fc.OBJECT_ID, fc.forecast_id, fc.DAYTIME, 1) CLOSING_BALANCE2,
		EcDp_Stor_fcst_Balance.calcStorageLevel(fc.OBJECT_ID, fc.forecast_id, fc.DAYTIME, 2) CLOSING_BALANCE3,
		to_char(null) record_status,
		to_char(null) created_by,
		to_date(null) created_date,
		to_char(null) last_updated_by,
		to_date(null) last_updated_date,
		to_number(null) rev_no,
		to_char(null) rev_text
FROM stor_day_fcst_fcast fc,
     (SELECT n.object_id,
     		 n.forecast_id,
             ue_Stor_Fcst_Lift_Nom.aggrSubDayLifting(n.forecast_id, n.PARCEL_NO, sn.production_day) grs_vol_nominated,
             ue_Stor_Fcst_Lift_Nom.aggrSubDayLifting(n.forecast_id, n.PARCEL_NO, sn.production_day, NULL, 1) grs_vol_nominated2,
             ue_Stor_Fcst_Lift_Nom.aggrSubDayLifting(n.forecast_id, n.PARCEL_NO, sn.production_day, NULL, 2) grs_vol_nominated3,
             sn.production_day nom_firm_date,
             n.CARGO_NO,
             n.PARCEL_NO,
             n.NOM_SEQUENCE,
             n.LIFTING_ACCOUNT_ID
      FROM stor_fcst_lift_nom n, cargo_fcst_transport t, cargo_status_mapping csm,
      	   (SELECT distinct forecast_id, production_day, parcel_no FROM stor_fcst_sub_day_lift_nom) sn
      WHERE t.cargo_no (+)= n.cargo_no
	  AND t.cargo_status= csm.cargo_status
      AND t.forecast_id (+) = n.forecast_id
      AND n.parcel_no = sn.parcel_no
      AND n.forecast_id = sn.forecast_id
      AND (t.cargo_no IS NULL OR csm.ec_cargo_status <> 'D')
      AND nvl(n.DELETED_IND, 'N') <> 'Y') l
WHERE l.nom_firm_date (+)= fc.daytime
  AND l.object_id (+)= fc.object_id
  AND l.forecast_id (+)= fc.forecast_id
)