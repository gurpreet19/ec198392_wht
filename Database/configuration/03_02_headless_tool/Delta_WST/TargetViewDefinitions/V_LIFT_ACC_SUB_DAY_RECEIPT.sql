CREATE OR REPLACE FORCE VIEW "V_LIFT_ACC_SUB_DAY_RECEIPT" ("OBJECT_ID", "DAYTIME", "SUMMER_TIME", "PRODUCTION_DAY", "LIFTED_QTY", "LIFTED_QTY2", "LIFTED_QTY3", "UNLOAD_QTY", "UNLOAD_QTY2", "UNLOAD_QTY3", "GRS_VOL_NOMINATED", "GRS_VOL_NOMINATED2", "GRS_VOL_NOMINATED3", "GRS_VOL_REQUESTED", "GRS_VOL_REQUESTED2", "GRS_VOL_REQUESTED3", "GRS_VOL_SCHEDULE", "GRS_VOL_SCHEDULED2", "GRS_VOL_SCHEDULED3", "CARGO_NO", "PARCEL_NO", "NOM_SEQUENCE", "RECORD_STATUS", "CREATED_BY", "CREATED_DATE", "LAST_UPDATED_BY", "LAST_UPDATED_DATE", "REV_NO", "REV_TEXT") AS 
  (
----------------------------------------------------------------------------------------------------
-- File name: v_lift_acc_sub_day_receipt.sql
-- View name: v_lift_acc_sub_day_receipt
--
-- $Revision: 1.3.4.1 $
--
-- Purpose  :
--
-- Modification history:
--
-- Date       Whom  Change description:
-- ---------- ----  --------------------------------------------------------------------------------
-- 28.12.2009 KSN  Intial version
----------------------------------------------------------------------------------------------------
SELECT f.object_id,
       f.daytime,
       f.summer_time,
       f.production_day,
       l.lifted_qty,
       l.lifted_qty2,
       l.lifted_qty3,
       l.unload_qty,
       l.unload_qty2,
       l.unload_qty3,
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
  FROM LIFT_ACC_SUB_DAY_FORECAST f,
       (SELECT n.object_id,
               sn.lifted_qty,
               sn.lifted_qty2,
               sn.lifted_qty3,
               sn.unload_qty,
               sn.unload_qty2,
               sn.unload_qty3,
               sn.GRS_VOL_NOMINATED,
               sn.grs_vol_nominated2,
               sn.grs_vol_nominated3,
               sn.GRS_VOL_REQUESTED,
               sn.GRS_VOL_REQUESTED2,
               sn.GRS_VOL_REQUESTED3,
               sn.GRS_VOL_SCHEDULE,
               sn.GRS_VOL_SCHEDULED2,
               sn.GRS_VOL_SCHEDULED3,
               sn.daytime firm_date_time,
               sn.summer_time summer_time,
               n.CARGO_NO,
               n.PARCEL_NO,
               n.NOM_SEQUENCE,
               n.LIFTING_ACCOUNT_ID
          FROM storage_lift_nomination n, cargo_transport t, stor_sub_day_lift_nom sn
         WHERE t.cargo_no(+) = n.cargo_no
           AND t.cargo_status <> 'D'
           AND n.parcel_no = sn.parcel_no) l
 WHERE l.firm_date_time(+) = f.daytime
   AND l.summer_time(+) = f.summer_time
   AND l.lifting_account_id(+) = f.object_id
)