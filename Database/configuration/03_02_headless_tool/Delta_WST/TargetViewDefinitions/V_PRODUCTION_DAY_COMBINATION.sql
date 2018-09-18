CREATE OR REPLACE FORCE VIEW "V_PRODUCTION_DAY_COMBINATION" ("OBJECT_ID", "DAYTIME", "START_TIME", "END_TIME", "RECORD_STATUS", "CREATED_BY", "CREATED_DATE", "LAST_UPDATED_BY", "LAST_UPDATED_DATE", "REV_NO", "REV_TEXT") AS 
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
       to_char(EcDp_Date_Time.utc2local(Ecdp_Date_Time.getProductionDayStartTimeUTC(o.object_id,sd.daytime), ov.object_id),'yyyy-mm-dd"T"hh24:mi:ss') as start_time,
       to_char(EcDp_Date_Time.utc2local(Ecdp_Date_Time.getProductionDayStartTimeUTC(o.object_id,sd.daytime+1), ov.object_id),'yyyy-mm-dd"T"hh24:mi:ss') as end_time,
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