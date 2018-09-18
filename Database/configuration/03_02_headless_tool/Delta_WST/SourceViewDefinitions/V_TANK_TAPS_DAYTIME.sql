CREATE OR REPLACE FORCE EDITIONABLE VIEW "V_TANK_TAPS_DAYTIME" ("DAYTIME", "OBJECT_ID", "END_DATE", "TANK_HEIGHT", "RECORD_STATUS", "CREATED_BY", "CREATED_DATE", "LAST_UPDATED_BY", "LAST_UPDATED_DATE", "REV_NO", "REV_TEXT") AS 
  (
------------------------------------------------------------------------------------
--  v_tank_taps_daytime
--
-- $Revision: 1.2 $
--
--  Purpose:   Get all distinct tap taps grouped by each tank's daytime and object_id.
--             Used in tank taps screen
--  Note:
--
--  When           Who           Why
--  -------------- ------------ --------
--  24-Sept-2012   Mak Kam Jie  Used in tank taps screen
-------------------------------------------------------------------------------------
SELECT a.daytime,
       a.object_id,
       MAX(a.end_date),
       MAX(a.tank_height),
       MAX(a.record_status),
       MAX(a.created_by),
       MAX(a.created_date),
       MAX(a.last_updated_by),
       MAX(a.last_updated_date),
       MAX(a.rev_no),
       MAX(a.rev_text)
FROM tank_taps a
GROUP BY a.object_id, a.daytime
)