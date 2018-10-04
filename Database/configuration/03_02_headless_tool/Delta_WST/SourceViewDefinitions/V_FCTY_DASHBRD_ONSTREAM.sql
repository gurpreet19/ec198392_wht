CREATE OR REPLACE FORCE EDITIONABLE VIEW "V_FCTY_DASHBRD_ONSTREAM" ("OBJECT_ID", "TOTAL", "DAYTIME", "WELL_TYPE", "ON_STREAM_HRS", "RECORD_STATUS", "CREATED_BY", "CREATED_DATE", "LAST_UPDATED_BY", "LAST_UPDATED_DATE", "REV_NO", "REV_TEXT") AS 
  (
----------------------------------------------------------------------------------------------------
-- File name: v_fcty_dashbrd_onstream.sql
-- View name: V_FCTY_DASHBRD_ONSTREAM
--
-- $Revision: 1.3 $
--
-- Purpose  : Filters wells (both inj and prod) that have on stream hrs more than 0.
--
-- Modification history:
--
-- Date       Whom      Change description:
-- ---------- ----      --------------------------------------------------------------------------------
-- 21.03.2018 abdulmaw  ECPD-52677:New Production Widgets: Well On Stream by Facility
----------------------------------------------------------------------------------------------------
SELECT
       pf.object_id,
       count(ec_prosty_codes.CODE_TEXT(WV.WELL_TYPE,'WELL_TYPE')) as Total,
       sd.daytime,
       wv.well_type,
       decode(wv.isinjector,'Y', ecdp_well.getIwelOnStreamHrs(wv.object_id,wv.well_type,sd.daytime), ecdp_well.getPwelOnStreamHrs(wv.object_id,sd.daytime)) on_stream_hrs,
       to_char(null) record_status,
       to_char(null) created_by,
       to_date(null) created_date,
       to_char(null) last_updated_by,
       to_date(null) last_updated_date,
       to_number(null) rev_no,
       to_char(null) rev_text
FROM   system_days sd, well_version wv, production_facility pf
WHERE  wv.op_fcty_class_1_id = pf.object_id
AND wv.daytime <= sd.daytime
AND NVL(wv.end_date,sd.daytime+1) > sd.daytime
AND decode(wv.isinjector,'Y', ecdp_well.getIwelOnStreamHrs(wv.object_id,wv.well_type,sd.daytime), ecdp_well.getPwelOnStreamHrs(wv.object_id,sd.daytime)) > 0
group by  pf.object_id,sd.daytime, wv.well_type, decode(wv.isinjector,'Y', ecdp_well.getIwelOnStreamHrs(wv.object_id,wv.well_type,sd.daytime), ecdp_well.getPwelOnStreamHrs(wv.object_id,sd.daytime))
)