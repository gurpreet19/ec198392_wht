CREATE OR REPLACE FORCE VIEW "V_STOR_SUB_DAY_ENTITLEMENT" ("OBJECT_ID", "DAYTIME", "SUMMER_TIME", "PRODUCTION_DAY", "CARGO_NO", "PARCEL_NO", "NOM_SEQUENCE", "LIFTING_ACCOUNT_ID", "NOM_LIFTED_QTY", "NOM_LIFTED_QTY2", "NOM_LIFTED_QTY3", "PROD_QTY", "PROD_QTY2", "PROD_QTY3", "CLOSING_BALANCE", "CLOSING_BALANCE2", "CLOSING_BALANCE3", "RECORD_STATUS", "CREATED_BY", "CREATED_DATE", "LAST_UPDATED_BY", "LAST_UPDATED_DATE", "REV_NO", "REV_TEXT") AS 
  (
----------------------------------------------------------------------------------------------------
-- File name: v_stor_sub_day_entitlement.sql
-- View name: v_stor_sub_day_entitlement
--
-- $Revision: 1.3.4.1 $
--
-- Purpose  :
--
-- Modification history:
--
-- Date       Whom  Change description:
-- ---------- ----  --------------------------------------------------------------------------------
-- 04.12.2009 KSN  Intial version
----------------------------------------------------------------------------------------------------
SELECT fc.object_id,
       fc.daytime,
       fc.SUMMER_TIME,
       fc.PRODUCTION_DAY,
       l.CARGO_NO,
       l.PARCEL_NO,
       l.NOM_SEQUENCE,
       l.LIFTING_ACCOUNT_ID,
       l.GRS_VOL_NOMINATED NOM_LIFTED_QTY,
	     l.GRS_VOL_NOMINATED2 NOM_LIFTED_QTY2,
       l.GRS_VOL_NOMINATED3 NOM_LIFTED_QTY3,
	(SELECT Nvl((SELECT official_qty FROM stor_sub_day_official WHERE daytime = fc.daytime AND summer_time = fc.summer_time AND object_id = fc.object_id), fc.forecast_qty) FROM dual) PROD_QTY,
	(SELECT Nvl((SELECT official_qty2 FROM stor_sub_day_official WHERE daytime = fc.daytime AND summer_time = fc.summer_time AND object_id = fc.object_id), fc.forecast_qty2) FROM dual) PROD_QTY2,
	(SELECT Nvl((SELECT official_qty3 FROM stor_sub_day_official WHERE daytime = fc.daytime AND summer_time = fc.summer_time AND object_id = fc.object_id), fc.forecast_qty3) FROM dual) PROD_QTY3,
       (SELECT EcDp_Storage_Balance.calcStorageLevelSubDay(fc.OBJECT_ID, fc.DAYTIME, fc.summer_time) FROM dual) CLOSING_BALANCE,
	     (SELECT EcDp_Storage_Balance.calcStorageLevelSubDay(fc.OBJECT_ID, fc.DAYTIME, fc.summer_time, 1) FROM dual) CLOSING_BALANCE2,
       (SELECT EcDp_Storage_Balance.calcStorageLevelSubDay(fc.OBJECT_ID, fc.DAYTIME, fc.summer_time, 2) FROM dual) CLOSING_BALANCE3,
       to_char(null) record_status,
       to_char(null) created_by,
       to_date(null) created_date,
       to_char(null) last_updated_by,
       to_date(null) last_updated_date,
       to_number(null) rev_no,
       to_char(null) rev_text
  FROM stor_sub_day_forecast fc,
       (SELECT n.object_id,
               nvl(ecbp_storage_lift_nomination.getLiftedVolSubDay(n.parcel_no, sn.daytime, sn.summer_time), sn.grs_vol_nominated) grs_vol_nominated,
               nvl(ecbp_storage_lift_nomination.getLiftedVolSubDay(n.parcel_no, sn.daytime, sn.summer_time, 1), sn.grs_vol_nominated2)   grs_vol_nominated2,
               nvl(ecbp_storage_lift_nomination.getLiftedVolSubDay(n.parcel_no, sn.daytime, sn.summer_time, 2), sn.grs_vol_nominated3)   grs_vol_nominated3,
               sn.daytime firm_date_time,
               sn.summer_time summer_time,
               n.CARGO_NO,
               n.PARCEL_NO,
               n.NOM_SEQUENCE,
               n.LIFTING_ACCOUNT_ID
          FROM storage_lift_nomination n, cargo_transport t, stor_sub_day_lift_nom sn
         WHERE n.parcel_no = sn.parcel_no
           AND t.cargo_no(+) = n.cargo_no
           AND t.cargo_status <> 'D') l
 WHERE l.firm_date_time(+) = fc.daytime
   AND l.summer_time(+) = fc.summer_time
   AND l.object_id(+) = fc.object_id
 GROUP BY fc.object_id,
          fc.daytime,
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