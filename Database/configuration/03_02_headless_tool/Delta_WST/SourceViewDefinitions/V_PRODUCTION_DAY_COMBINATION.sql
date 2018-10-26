CREATE OR REPLACE FORCE EDITIONABLE VIEW "V_PRODUCTION_DAY_COMBINATION" ("OBJECT_ID", "DAYTIME", "START_TIME", "END_TIME", "RECORD_STATUS", "CREATED_BY", "CREATED_DATE", "LAST_UPDATED_BY", "LAST_UPDATED_DATE", "REV_NO", "REV_TEXT") AS 
  (
-------------------------------------------------------------------------------------
--  v_production_day_combination
--
-- $Revision: 1.3 $
--
--  Purpose: Get start time for system days for all production day definitions.
--
--  Note:
-------------------------------------------------------------------------------------
SELECT o.object_id,
       sd.daytime,
       TO_CHAR(sd.daytime + EcDp_ProductionDay.getTZoffsetInDays(ov.offset), 'YYYY-MM-DD"T"HH24:MI:SS') start_time,
       TO_CHAR(sd.daytime + 1 + EcDp_ProductionDay.getTZoffsetInDays(ov.offset), 'YYYY-MM-DD"T"HH24:MI:SS') end_time,
       o.record_status,
       o.created_by,
       o.created_date,
       o.last_updated_by,
       o.last_updated_date,
       o.rev_no,
       o.rev_text
  FROM production_day o,
       production_day_version ov,
       system_days sd
 WHERE o.object_id = ov.object_id
   AND sd.daytime >= o.start_date
   AND (o.end_date IS NULL OR sd.daytime < o.end_date)
   AND sd.daytime >= ov.daytime
   AND (ov.end_date IS NULL OR sd.daytime < ov.end_date)
)