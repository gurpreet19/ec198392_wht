CREATE OR REPLACE FORCE EDITIONABLE VIEW "V_STIM_FCST_FORMULA" ("FORECAST_ID", "OBJECT_ID", "STREAM_ITEM_ID", "DAYTIME", "COMMENTS", "RECORD_STATUS", "CREATED_BY", "CREATED_DATE", "LAST_UPDATED_BY", "LAST_UPDATED_DATE", "REV_NO", "REV_TEXT") AS 
  (
----------------------------------------------------------------------------------------------------
--
-- File name: v_stim_fcst_formula.sql
-- View name: v_stim_fcst_formula
--
-- $Revision: 1.3 $
--
-- Purpose  : This view is in use in the cascade to get the correct formulas
--
-- Modification history:
--
-- Version  Date        Whom    Change description:
-----------------------------------------------------------------------------------------------------------------------------------
--         21.03.2007 SRA   Initial version
-----------------------------------------------------------------------------------------------------------------------------------
-- "Actual" Formula
(SELECT f1.object_id forecast_id,
sif1.object_id object_id,
sif1.stream_item_id stream_item_id,
sif1.daytime,
sif1.comments,
sif1.record_status,
sif1.created_by,
sif1.created_date,
sif1.last_updated_by,
sif1.last_updated_date,
sif1.rev_no,
sif1.rev_text
FROM stream_item_formula sif1, forecast f1
WHERE NOT EXISTS (SELECT 1 FROM stim_fcst_formula sff1 WHERE (forecast_id = f1.object_id OR sff1.forecast_id = 'GENERAL_FCST_FORMULA')
                  AND sff1.object_id = sif1.object_id)
UNION ALL
-- General Forecast Formula
SELECT f2.object_id forecast_id,
sff2.object_id object_id,
sff2.stream_item_id stream_item_id,
sff2.daytime,
sff2.comments,
sff2.record_status,
sff2.created_by,
sff2.created_date,
sff2.last_updated_by,
sff2.last_updated_date,
sff2.rev_no,
sff2.rev_text
FROM stim_fcst_formula sff2, forecast f2
WHERE forecast_id = 'GENERAL_FCST_FORMULA'
UNION ALL
-- Spesific Forecast Formula
SELECT sff3.forecast_id,
sff3.object_id object_id,
sff3.stream_item_id stream_item_id,
sff3.daytime,
sff3.comments,
sff3.record_status,
sff3.created_by,
sff3.created_date,
sff3.last_updated_by,
sff3.last_updated_date,
sff3.rev_no,
sff3.rev_text
FROM stim_fcst_formula sff3
WHERE forecast_id <> 'GENERAL_FCST_FORMULA'
)
)