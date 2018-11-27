CREATE OR REPLACE FORCE EDITIONABLE VIEW "V_WELL_PERF_INTERVAL_COMP" ("OBJECT_ID", "WELL_ID", "RBF_OBJECT_ID", "DAYTIME", "COMPONENT_NO", "RECORD_STATUS", "CREATED_BY", "CREATED_DATE", "LAST_UPDATED_BY", "LAST_UPDATED_DATE", "REV_NO", "REV_TEXT") AS 
  (
-------------------------------------------------------------------------------------
--  V_WELL_PERF_INTERVAL_COMP
--
-- $Revision: 1.3 $
--
--  Purpose: Get all combinations of wells, perforation interval and component for a given day
--           Used by the perforation interval allocation to split down allocated well figures down to
--           perforation interval level.
--
--  History:
--
--  Date      Modified by    Comment
--  16-Mar-07 Olav Naerland  Initial version
-- 13.07.2017 kashisag   ECPD-45817: Replaced sysdate with Ecdp_Timestamp.getCurrentSysdate
-------------------------------------------------------------------------------------
SELECT DISTINCT
       pi.object_id as OBJECT_ID,
       w.object_id AS WELL_ID,
       piv.resv_block_formation_id as RBF_OBJECT_ID,
       sd.daytime AS daytime,
       hc.component_no AS COMPONENT_NO,
       'P' AS RECORD_STATUS,
       USER AS CREATED_BY,
       Ecdp_Timestamp.getCurrentSysdate AS CREATED_DATE,
       USER AS LAST_UPDATED_BY,
       Ecdp_Timestamp.getCurrentSysdate AS LAST_UPDATED_DATE,
       NULL AS REV_NO,
       NULL AS REV_TEXT
FROM well_version wv, well w, system_days sd, webo_bore wb ,webo_interval wbi, perf_interval pi, perf_interval_version piv, hydrocarbon_component hc
 WHERE wb.well_id = w.object_id
 AND wv.object_id = w.object_id
 AND wv.alloc_flag = 'Y'
 AND wv.daytime <= sd.daytime
 AND NVL(wv.end_date,sd.daytime+1) > sd.daytime
 AND pi.object_id = piv.object_id
 AND piv.daytime <= sd.daytime
 AND NVL(piv.end_date,sd.daytime+1) > sd.daytime
 AND piv.alloc_flag = 'Y'
 AND wbi.well_bore_id = wb.object_id
 AND pi.webo_interval_id = wbi.object_id
 AND sd.daytime BETWEEN wb.start_date AND Nvl(wb.end_date-1,sd.daytime+1)
 AND sd.daytime BETWEEN wbi.start_date AND Nvl(wbi.end_date-1,sd.daytime+1)
 AND sd.daytime BETWEEN w.start_date AND Nvl(w.end_date-1,sd.daytime+1)
 AND sd.daytime BETWEEN pi.start_date AND Nvl(pi.end_date-1,sd.daytime+1)
)