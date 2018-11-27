CREATE OR REPLACE FORCE VIEW "V_WELL_RESV_BLOCK_FORMATION" ("OBJECT_ID", "WELL_ID", "DAYTIME", "RECORD_STATUS", "CREATED_BY", "CREATED_DATE", "LAST_UPDATED_BY", "LAST_UPDATED_DATE", "REV_NO", "REV_TEXT") AS 
  (
-------------------------------------------------------------------------------------
--  v_well_resv_block_formation
--
-- $Revision: 1.4 $
--
--  Purpose: Get all combinations of wells and reservoir block formations for a given day
--           Used by the reservoir allocation to split down allocated well figures down to
--           reservoir level.
--
--  History:
--
--  Date      Modified by    Comment
--  28-Nov-05 ROV            Tracker 2742: Initial version
--  29-Nov-05 ROV            Tracker 2742: Performance tuning
--  08-Nov-06 ZAKIIARI       Tracker 4512: Moved RBF relation from WBI to Perf Interval
-------------------------------------------------------------------------------------
SELECT DISTINCT
rbf.object_id AS OBJECT_ID,
w.object_id AS WELL_ID,
sd.daytime AS daytime,
'P' AS RECORD_STATUS,
USER AS CREATED_BY,
SYSDATE AS CREATED_DATE,
USER AS LAST_UPDATED_BY,
SYSDATE AS LAST_UPDATED_DATE,
NULL AS REV_NO,
NULL AS REV_TEXT
FROM well_version wv, well w, system_days sd, webo_bore wb ,webo_interval wbi, perf_interval pi, resv_block_formation rbf, rbf_version rbfv
 WHERE wb.well_id = w.object_id
 AND wv.object_id = w.object_id
 AND wv.alloc_flag = 'Y'
 AND wv.daytime <= sd.daytime
 AND NVL(wv.end_date,sd.daytime+1) > sd.daytime
 AND rbf.object_id = rbfv.object_id
 AND rbfv.daytime <= sd.daytime
 AND NVL(rbfv.end_date,sd.daytime+1) > sd.daytime
 AND rbfv.alloc_flag = 'Y'
 AND wbi.well_bore_id = wb.object_id
 AND pi.webo_interval_id = wbi.object_id
 AND pi.resv_block_formation_id = rbf.object_id
 AND sd.daytime BETWEEN rbf.start_date AND Nvl(rbf.end_date-1,sd.daytime+1)
 AND sd.daytime BETWEEN wb.start_date AND Nvl(wb.end_date-1,sd.daytime+1)
 AND sd.daytime BETWEEN wbi.start_date AND Nvl(wbi.end_date-1,sd.daytime+1)
 AND sd.daytime BETWEEN w.start_date AND Nvl(w.end_date-1,sd.daytime+1)
 AND sd.daytime BETWEEN pi.start_date AND Nvl(pi.end_date-1,sd.daytime+1)
)