CREATE OR REPLACE FORCE EDITIONABLE VIEW "V_TANK_EVENT_DIP_AND_EXP" ("DAYTIME", "RECORD_TYPE", "OBJECT_ID", "OBJECT_NAME", "RECORD_STATUS", "CREATED_BY", "CREATED_DATE", "LAST_UPDATED_BY", "LAST_UPDATED_DATE", "REV_NO", "REV_TEXT") AS 
  (
----------------------------------------------------------------------------------------------------
-- File name: v_event_tank_status_dip_exp.sql
-- View name: V_TANK_EVENT_DIP_AND_EXP
--
-- $Revision: 1.3 $
--
-- Purpose  :
--
-- Modification history:
--
-- Date       Whom      Change description:
-- ---------- --------  --------------------------------------------------------------------------------
-- 07.08.2012 abdulmaw  ECPD-20144:Added for New Screen Tank Dip and Batch Export.
-- 27.11.2012 kumarsur  ECPD-29423:Changed BF number
----------------------------------------------------------------------------------------------------
SELECT tm.daytime,
       'Gauged' as record_type,
       tm.object_id,
       ecdp_objects.GetObjName(tm.object_id, tm.daytime) as object_name,
       tm.record_status,
       tm.created_by,
       tm.created_date,
       tm.last_updated_by,
       tm.last_updated_date,
       tm.rev_no,
       tm.rev_text
FROM TANK_MEASUREMENT tm,
     TANK_VERSION tv
WHERE tm.OBJECT_ID = tv.OBJECT_ID
  AND tv.BF_USAGE = 'PO.0082'
  AND tm.MEASUREMENT_EVENT_TYPE = 'EVENT_CLOSING'
  AND tm.daytime >= tv.daytime
  AND tm.daytime < nvl(tv.end_date, tm.daytime+1)
UNION ALL
SELECT se.daytime,
       'Run Ticket' as record_type,
       se.tank_object_id AS EXPORT_TANK,
       ecdp_objects.GetObjName(se.tank_object_id, se.daytime) as object_name,
       se.record_status,
       se.created_by,
       se.created_date,
       se.last_updated_by,
       se.last_updated_date,
       se.rev_no,
       se.rev_text
FROM STRM_EVENT se
WHERE se.EVENT_TYPE = 'OIL_TANK_BATCH_EXPORT'
  AND se.tank_object_id IS NOT null
UNION ALL
SELECT ote.daytime,
       'Disposition' as record_type,
       ote.object_id,
       ecdp_objects.GetObjName(ote.object_id, ote.daytime) as object_name,
       ote.record_status,
       ote.created_by,
       ote.created_date,
       ote.last_updated_by,
       ote.last_updated_date,
       ote.rev_no,
       ote.rev_text
FROM OBJECT_TRANSPORT_EVENT ote
WHERE (ote.DATA_CLASS_NAME = 'OBJECT_SINGLE_TRANSFER'
  OR ote.DATA_CLASS_NAME = 'DISPOSITIONS')
  AND ote.object_type = 'TANK'
)