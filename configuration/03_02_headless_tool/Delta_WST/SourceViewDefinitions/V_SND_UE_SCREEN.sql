CREATE OR REPLACE FORCE EDITIONABLE VIEW "V_SND_UE_SCREEN" ("COMPONENT_ID", "COMPONENT_LABEL", "COMPONENT_TYPE", "SORT_ORDER", "RECORD_STATUS", "CREATED_BY", "CREATED_DATE", "LAST_UPDATED_BY", "LAST_UPDATED_DATE", "REV_NO", "REV_TEXT") AS 
  SELECT
'Ue_DailyProdWellStatus' AS COMPONENT_ID
,'Daily Production Well Status' AS COMPONENT_LABEL
,'URL' AS COMPONENT_TYPE
,NULL as sort_order
,NULL as record_status
,NULL as created_by
,NULL as created_date
,NULL as last_updated_by
,NULL as last_updated_date
,NULL as rev_no
,NULL as rev_text
FROM CTRL_DB_VERSION WHERE DB_VERSION = 1
UNION
SELECT
'Ue_DailyStreamStatus' AS COMPONENT_ID
,'Daily Stream Status, by Stream' AS COMPONENT_LABEL
,'URL' AS COMPONENT_TYPE
,NULL as sort_order
,NULL as record_status
,NULL as created_by
,NULL as created_date
,NULL as last_updated_by
,NULL as last_updated_date
,NULL as rev_no
,NULL as rev_text
FROM CTRL_DB_VERSION WHERE DB_VERSION = 1