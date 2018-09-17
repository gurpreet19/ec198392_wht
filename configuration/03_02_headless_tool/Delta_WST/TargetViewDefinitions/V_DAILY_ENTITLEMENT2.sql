CREATE OR REPLACE FORCE VIEW "V_DAILY_ENTITLEMENT2" ("OBJECT_ID", "DAYTIME", "CARGO_NO", "PARCEL_NO", "NOM_SEQUENCE", "LIFTING_ACCOUNT_ID", "NOM_LIFTED_QTY", "NOM_LIFTED_QTY2", "NOM_LIFTED_QTY3", "PROD_QTY", "PROD_QTY2", "PROD_QTY3", "CLOSING_BALANCE", "CLOSING_BALANCE2", "CLOSING_BALANCE3", "RECORD_STATUS", "CREATED_BY", "CREATED_DATE", "LAST_UPDATED_BY", "LAST_UPDATED_DATE", "REV_NO", "REV_TEXT") AS 
  (
----------------------------------------------------------------------------------------------------
-- File name: v_daily_entitlement2.sql
-- View name: v_daily_entitlement2
--
-- $Revision: 1.1.2.1 $
--
-- Purpose  :
--
-- Modification history:
--
-- Date       Whom  Change description:
-- ---------- ----  --------------------------------------------------------------------------------
-- 09.11.2012 meisihil  Intial version
----------------------------------------------------------------------------------------------------
SELECT /*+ UNNEST */ fc.object_id,
		fc.daytime,
		l.CARGO_NO,
		l.PARCEL_NO,
		l.NOM_SEQUENCE,
		l.LIFTING_ACCOUNT_ID,
		l.GRS_VOL_NOMINATED NOM_LIFTED_QTY,
		l.GRS_VOL_NOMINATED2 NOM_LIFTED_QTY2,
		l.GRS_VOL_NOMINATED3 NOM_LIFTED_QTY3,
		Nvl(ec_STOR_DAY_OFFICIAL.OFFICIAL_QTY(fc.OBJECT_ID,fc.DAYTIME),fc.forecast_qty) PROD_QTY,
		Nvl(ec_STOR_DAY_OFFICIAL.OFFICIAL_QTY2(fc.OBJECT_ID,fc.DAYTIME),fc.forecast_qty2) PROD_QTY2,
		Nvl(ec_STOR_DAY_OFFICIAL.OFFICIAL_QTY3(fc.OBJECT_ID,fc.DAYTIME),fc.forecast_qty3) PROD_QTY3,
		EcDp_Storage_Balance.calcStorageLevel(fc.OBJECT_ID, fc.DAYTIME) CLOSING_BALANCE,
		EcDp_Storage_Balance.calcStorageLevel(fc.OBJECT_ID, fc.DAYTIME, NULL, 1) CLOSING_BALANCE2,
		EcDp_Storage_Balance.calcStorageLevel(fc.OBJECT_ID, fc.DAYTIME, NULL, 2) CLOSING_BALANCE3,
		to_char(null) record_status,
		to_char(null) created_by,
		to_date(null) created_date,
		to_char(null) last_updated_by,
		to_date(null) last_updated_date,
		to_number(null) rev_no,
		to_char(null) rev_text
FROM stor_day_forecast fc,
     (SELECT n.object_id,
             ue_Storage_Lift_Nomination.aggrSubDayLifting(n.PARCEL_NO, sn.production_day) grs_vol_nominated,
             ue_Storage_Lift_Nomination.aggrSubDayLifting(n.PARCEL_NO, sn.production_day, NULL, 1) grs_vol_nominated2,
             ue_Storage_Lift_Nomination.aggrSubDayLifting(n.PARCEL_NO, sn.production_day, NULL, 2) grs_vol_nominated3,
             sn.production_day firm_date,
             n.CARGO_NO,
             n.PARCEL_NO,
             n.NOM_SEQUENCE,
             n.LIFTING_ACCOUNT_ID
      FROM storage_lift_nomination n, cargo_transport t,
      	   (SELECT distinct production_day, parcel_no FROM stor_sub_day_lift_nom) sn
      WHERE t.cargo_no (+)= n.cargo_no
      AND n.parcel_no = sn.parcel_no
      AND t.cargo_status <> 'D') l
WHERE l.firm_date (+)= fc.daytime
  AND l.object_id (+)= fc.object_id
GROUP BY
  fc.object_id, fc.daytime,l.NOM_SEQUENCE,l.CARGO_NO, l.PARCEL_NO, l.LIFTING_ACCOUNT_ID, l.GRS_VOL_NOMINATED, l.GRS_VOL_NOMINATED2, l.GRS_VOL_NOMINATED3, fc.forecast_qty, fc.forecast_qty2, fc.forecast_qty3
)