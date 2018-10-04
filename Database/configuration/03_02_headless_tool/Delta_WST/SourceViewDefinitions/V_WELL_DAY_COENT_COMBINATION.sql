CREATE OR REPLACE FORCE EDITIONABLE VIEW "V_WELL_DAY_COENT_COMBINATION" ("OBJECT_ID", "DAYTIME", "COMMERCIAL_ENTITY_ID", "RECORD_STATUS", "CREATED_BY", "CREATED_DATE", "LAST_UPDATED_BY", "LAST_UPDATED_DATE", "REV_NO", "REV_TEXT") AS 
  (
SELECT DISTINCT
	w.object_id,
	sd.daytime AS daytime,
	rbfv.commercial_entity_id AS commercial_entity_id,
	w.record_status,
	w.created_by,
	w.created_date,
	w.last_updated_by,
	w.last_updated_date,
	w.rev_no,
	w.rev_text
FROM 	resv_block_formation rbf
,       rbf_version rbfv
,   perf_interval pi
, 	webo_interval wbi
, 	webo_bore wb
, 	well w
, 	system_days sd
WHERE 	w.object_id = wb.well_id
AND	wbi.well_bore_id = wb.object_id
AND pi.webo_interval_id = wbi.object_id
--AND pi.resv_block_formation_id = rbf.object_id
AND 	rbf.object_id = rbfv.object_id
AND	rbfv.commercial_entity_id is not null
AND 	sd.daytime BETWEEN wb.start_date AND Nvl(wb.end_date-1,sd.daytime+1)
AND 	sd.daytime BETWEEN wbi.start_date AND Nvl(wbi.end_date-1,sd.daytime+1)
AND 	sd.daytime BETWEEN pi.start_date AND Nvl(pi.end_date-1,sd.daytime+1)
AND 	sd.daytime BETWEEN w.start_date AND Nvl(w.end_date-1,sd.daytime+1)
AND 	sd.daytime BETWEEN rbf.start_date AND Nvl(rbf.end_date-1,sd.daytime+1)
AND 	sd.daytime BETWEEN rbfv.daytime AND Nvl(rbfv.end_date-1,sd.daytime+1)
)