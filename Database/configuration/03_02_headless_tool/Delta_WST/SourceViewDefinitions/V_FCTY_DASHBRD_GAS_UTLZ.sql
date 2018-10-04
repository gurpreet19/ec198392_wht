CREATE OR REPLACE FORCE EDITIONABLE VIEW "V_FCTY_DASHBRD_GAS_UTLZ" ("OBJECT_ID", "DAYTIME", "STREAM_CATEGORY", "SUM_NET_VOL", "RECORD_STATUS", "CREATED_BY", "CREATED_DATE", "LAST_UPDATED_BY", "LAST_UPDATED_DATE", "REV_NO", "REV_TEXT") AS 
  (
----------------------------------------------------------------------------------------------------
-- File name: V_FCTY_DASHBRD_GAS_UTLZ.sql
-- View name:V_FCTY_DASHBRD_GAS_UTLZ
--
-- $Revision: 1.3 $
--
-- Purpose  : The utilization of gas for each day of the facility.
--
-- Modification history:
--
-- Date       Whom      Change description:
-- ---------- ----      --------------------------------------------------------------------------------
-- 03.05.2013 rajarsar  ECPD-23618:Intial version
----------------------------------------------------------------------------------------------------
SELECT pf.object_id,
       sd.daytime,
       ec_prosty_codes.CODE_TEXT(SV.STREAM_CATEGORY,'STREAM_CATEGORY') stream_category,
       sum(sda.net_vol) sum_net_vol,
       to_char(null) record_status,
       to_char(null) created_by,
       to_date(null) created_date,
       to_char(null) last_updated_by,
       to_date(null) last_updated_date,
       to_number(null) rev_no,
       to_char(null) rev_text
FROM   system_days sd, strm_day_alloc sda, strm_version sv, production_facility pf
WHERE  sda.object_id = sv.object_id
AND sv.op_fcty_class_1_id = pf.object_id
AND sd.daytime = sda.daytime
AND sv.stream_phase = 'GAS'
AND sv.stream_category != 'GAS_PROD'
AND sv.daytime <= sd.daytime
AND NVL(sv.end_date,sd.daytime+1) > sd.daytime
group by pf.object_id,
sd.daytime, sv.stream_category
)