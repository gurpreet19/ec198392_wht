CREATE OR REPLACE FORCE VIEW "V_DAILY_ENTITLEMENT" ("OBJECT_ID", "DAYTIME", "CARGO_NO", "PARCEL_NO", "NOM_SEQUENCE", "LIFTING_ACCOUNT_ID", "NOM_LIFTED_QTY", "NOM_LIFTED_QTY2", "NOM_LIFTED_QTY3", "PROD_QTY", "PROD_QTY2", "PROD_QTY3", "CLOSING_BALANCE", "CLOSING_BALANCE2", "CLOSING_BALANCE3", "RECORD_STATUS", "CREATED_BY", "CREATED_DATE", "LAST_UPDATED_BY", "LAST_UPDATED_DATE", "REV_NO", "REV_TEXT") AS 
  (
----------------------------------------------------------------------------------------------------
-- File name: v_daily_entitlement.sql
-- View name: v_daily_entitlement
--
-- $Revision: 1.14.4.1 $
--
-- Purpose  :
--
-- Modification history:
--
-- Date       Whom  Change description:
-- ---------- ----  --------------------------------------------------------------------------------
-- 30.06.2006 zakiiari  Intial version
-- 07.06.2007 kaurrjes ECPD-5805: Daily Entitlement: Cargo/Parcel name is wrong
-- 04.08.2008 lauuufus ECPD-9275 - Fixed date handling (BLDate vs. NomDate)
-- 24.08.2009 leongsei ECPD-12104: Added hint and subquery towards dual.
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
             nvl(EcBP_Storage_Lift_Nomination.getLiftedVol(n.PARCEL_NO),n.grs_vol_nominated) grs_vol_nominated,
             nvl(EcBP_Storage_Lift_Nomination.getLiftedVol(n.PARCEL_NO, 1),n.grs_vol_nominated2) grs_vol_nominated2,
             nvl(EcBP_Storage_Lift_Nomination.getLiftedVol(n.PARCEL_NO, 2),n.grs_vol_nominated3) grs_vol_nominated3,
             nvl(n.bl_date, n.nom_firm_date) firm_date	,
             n.CARGO_NO,
             n.PARCEL_NO,
             n.NOM_SEQUENCE,
             n.LIFTING_ACCOUNT_ID
      FROM storage_lift_nomination n, cargo_transport t
      WHERE t.cargo_no (+)= n.cargo_no
      AND t.cargo_status <> 'D') l
WHERE l.firm_date (+)= fc.daytime
  AND l.object_id (+)= fc.object_id
GROUP BY
  fc.object_id, fc.daytime,l.NOM_SEQUENCE,l.CARGO_NO, l.PARCEL_NO, l.LIFTING_ACCOUNT_ID, l.GRS_VOL_NOMINATED, l.GRS_VOL_NOMINATED2, l.GRS_VOL_NOMINATED3, fc.forecast_qty, fc.forecast_qty2, fc.forecast_qty3
)