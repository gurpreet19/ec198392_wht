CREATE OR REPLACE FORCE VIEW "V_WELL_PERF_INTERVAL" ("OBJECT_ID", "WELL_ID", "RBF_OBJECT_ID", "DAYTIME", "RECORD_STATUS", "CREATED_BY", "CREATED_DATE", "LAST_UPDATED_BY", "LAST_UPDATED_DATE", "REV_NO", "REV_TEXT") AS 
  (
-------------------------------------------------------------------------------------
--  V_WELL_PERF_INTERVAL
--
-- $Revision: 1.3 $
--
--  Purpose: Get all combinations of wells and perforation interval for a given day
--           Used by the perforation interval allocation to split down allocated well figures down to
--           perforation level.
--
--  History:
--
--  Date      Modified by    Comment
--  16.03.07  Olav Naerland  Initial version.
--  08.07.08  Henk Nevland   Optimised to use new pi.well_id stored at perf_interval
-------------------------------------------------------------------------------------
SELECT DISTINCT
       pi.object_id as OBJECT_ID,
       pi.well_id AS WELL_ID,
       pi.resv_block_formation_id as RBF_OBJECT_ID,
       sd.daytime AS daytime,
       'P' AS RECORD_STATUS,
       USER AS CREATED_BY,
       SYSDATE AS CREATED_DATE,
       USER AS LAST_UPDATED_BY,
       SYSDATE AS LAST_UPDATED_DATE,
       NULL AS REV_NO,
       NULL AS REV_TEXT
FROM well_version wv, well w, system_days sd, perf_interval pi, perf_interval_version piv
WHERE pi.well_id = w.object_id
AND wv.object_id = w.object_id
AND wv.alloc_flag = 'Y'
AND wv.daytime <= sd.daytime
AND NVL(wv.end_date,sd.daytime+1) > sd.daytime
AND pi.object_id = piv.object_id
AND piv.daytime <= sd.daytime
AND NVL(piv.end_date,sd.daytime+1) > sd.daytime
AND piv.alloc_flag = 'Y'
AND sd.daytime BETWEEN w.start_date AND Nvl(w.end_date-1,sd.daytime+1)
AND sd.daytime BETWEEN pi.start_date AND Nvl(pi.end_date-1,sd.daytime+1)
)