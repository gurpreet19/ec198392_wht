CREATE OR REPLACE FORCE EDITIONABLE VIEW "V_TRACING_DATA" ("HEADING", "PROCESS", "DATA_ENTITY_CAT", "SORT_ORDER", "DATA_ENTITY_DAYTIME", "PERIOD", "DATA_ENTITY_ID", "DATA_ENTITY_TYPE", "PROPERTY_OBJ_CODE", "PROPERTY_OBJ_ID", "PARENT_PROJECT_OBJ_CODE", "PARENT_PROJECT_OBJ_ID", "PROJECT_OBJ_CODE", "PROJECT_OBJ_ID", "DEP_STATUS", "BOX_TEXT_1", "BOX_TEXT_2", "BOX_TEXT_3", "BOX_TEXT_4", "BOX_TEXT_5", "BOX_TEXT_6", "BOX_TEXT_COLOR_1", "BOX_TEXT_COLOR_2", "BOX_TEXT_COLOR_3", "BOX_TEXT_COLOR_4", "BOX_TEXT_COLOR_5", "BOX_TEXT_COLOR_6", "TOP_TEXT_1", "TOP_TEXT_2", "TOP_TEXT_3", "TOP_TEXT_4", "TOP_TEXT_5", "TOP_TEXT_6", "TOP_TEXT_7", "TOP_TEXT_8", "TOP_TEXT_9", "TOP_TEXT_10", "TOP_TEXT_11", "TOP_TEXT_12", "TOP_TEXT_COLOR_1", "TOP_TEXT_COLOR_2", "TOP_TEXT_COLOR_3", "TOP_TEXT_COLOR_4", "TOP_TEXT_COLOR_5", "TOP_TEXT_COLOR_6", "TOP_TEXT_COLOR_7", "TOP_TEXT_COLOR_8", "TOP_TEXT_COLOR_9", "TOP_TEXT_COLOR_10", "TOP_TEXT_COLOR_11", "TOP_TEXT_COLOR_12", "BOTTOM_TEXT_1", "BOTTOM_TEXT_2", "BOTTOM_TEXT_3", "BOTTOM_TEXT_4", "BOTTOM_TEXT_5", "BOTTOM_TEXT_6", "BOTTOM_TEXT_7", "BOTTOM_TEXT_8", "BOTTOM_TEXT_9", "BOTTOM_TEXT_10", "BOTTOM_TEXT_11", "BOTTOM_TEXT_12", "BOTTOM_TEXT_COLOR_1", "BOTTOM_TEXT_COLOR_2", "BOTTOM_TEXT_COLOR_3", "BOTTOM_TEXT_COLOR_4", "BOTTOM_TEXT_COLOR_5", "BOTTOM_TEXT_COLOR_6", "BOTTOM_TEXT_COLOR_7", "BOTTOM_TEXT_COLOR_8", "BOTTOM_TEXT_COLOR_9", "BOTTOM_TEXT_COLOR_10", "BOTTOM_TEXT_COLOR_11", "BOTTOM_TEXT_COLOR_12", "ICON_1", "ICON_2", "ICON_3", "ICON_4", "ICON_5", "ACTUAL_ACCRUAL_CODE", "FORECAST_IND", "DEPRECATED_IND", "RECORD_STATUS", "CREATED_BY", "CREATED_DATE", "LAST_UPDATED_BY", "LAST_UPDATED_DATE", "REV_NO", "REV_TEXT", "APPROVAL_BY", "APPROVAL_DATE", "APPROVAL_STATE", "REC_ID") AS 
  select "HEADING","PROCESS","DATA_ENTITY_CAT","SORT_ORDER","DATA_ENTITY_DAYTIME","PERIOD","DATA_ENTITY_ID","DATA_ENTITY_TYPE","PROPERTY_OBJ_CODE","PROPERTY_OBJ_ID","PARENT_PROJECT_OBJ_CODE","PARENT_PROJECT_OBJ_ID","PROJECT_OBJ_CODE","PROJECT_OBJ_ID","DEP_STATUS","BOX_TEXT_1","BOX_TEXT_2","BOX_TEXT_3","BOX_TEXT_4","BOX_TEXT_5","BOX_TEXT_6","BOX_TEXT_COLOR_1","BOX_TEXT_COLOR_2","BOX_TEXT_COLOR_3","BOX_TEXT_COLOR_4","BOX_TEXT_COLOR_5","BOX_TEXT_COLOR_6","TOP_TEXT_1","TOP_TEXT_2","TOP_TEXT_3","TOP_TEXT_4","TOP_TEXT_5","TOP_TEXT_6","TOP_TEXT_7","TOP_TEXT_8","TOP_TEXT_9","TOP_TEXT_10","TOP_TEXT_11","TOP_TEXT_12","TOP_TEXT_COLOR_1","TOP_TEXT_COLOR_2","TOP_TEXT_COLOR_3","TOP_TEXT_COLOR_4","TOP_TEXT_COLOR_5","TOP_TEXT_COLOR_6","TOP_TEXT_COLOR_7","TOP_TEXT_COLOR_8","TOP_TEXT_COLOR_9","TOP_TEXT_COLOR_10","TOP_TEXT_COLOR_11","TOP_TEXT_COLOR_12","BOTTOM_TEXT_1","BOTTOM_TEXT_2","BOTTOM_TEXT_3","BOTTOM_TEXT_4","BOTTOM_TEXT_5","BOTTOM_TEXT_6","BOTTOM_TEXT_7","BOTTOM_TEXT_8","BOTTOM_TEXT_9","BOTTOM_TEXT_10","BOTTOM_TEXT_11","BOTTOM_TEXT_12","BOTTOM_TEXT_COLOR_1","BOTTOM_TEXT_COLOR_2","BOTTOM_TEXT_COLOR_3","BOTTOM_TEXT_COLOR_4","BOTTOM_TEXT_COLOR_5","BOTTOM_TEXT_COLOR_6","BOTTOM_TEXT_COLOR_7","BOTTOM_TEXT_COLOR_8","BOTTOM_TEXT_COLOR_9","BOTTOM_TEXT_COLOR_10","BOTTOM_TEXT_COLOR_11","BOTTOM_TEXT_COLOR_12","ICON_1","ICON_2","ICON_3","ICON_4","ICON_5","ACTUAL_ACCRUAL_CODE","FORECAST_IND","DEPRECATED_IND","RECORD_STATUS","CREATED_BY","CREATED_DATE","LAST_UPDATED_BY","LAST_UPDATED_DATE","REV_NO","REV_TEXT","APPROVAL_BY","APPROVAL_DATE","APPROVAL_STATE","REC_ID" from v_tracing_data_mapping
union all
SELECT "HEADING","PROCESS","DATA_ENTITY_CAT","SORT_ORDER","DATA_ENTITY_DAYTIME","PERIOD","DATA_ENTITY_ID","DATA_ENTITY_TYPE","PROPERTY_OBJ_CODE","PROPERTY_OBJ_ID","PARENT_PROJECT_OBJ_CODE","PARENT_PROJECT_OBJ_ID","PROJECT_OBJ_CODE","PROJECT_OBJ_ID","DEP_STATUS","BOX_TEXT_1","BOX_TEXT_2","BOX_TEXT_3","BOX_TEXT_4","BOX_TEXT_5","BOX_TEXT_6","BOX_TEXT_COLOR_1","BOX_TEXT_COLOR_2","BOX_TEXT_COLOR_3","BOX_TEXT_COLOR_4","BOX_TEXT_COLOR_5","BOX_TEXT_COLOR_6","TOP_TEXT_1","TOP_TEXT_2","TOP_TEXT_3","TOP_TEXT_4","TOP_TEXT_5","TOP_TEXT_6","TOP_TEXT_7","TOP_TEXT_8","TOP_TEXT_9","TOP_TEXT_10","TOP_TEXT_11","TOP_TEXT_12","TOP_TEXT_COLOR_1","TOP_TEXT_COLOR_2","TOP_TEXT_COLOR_3","TOP_TEXT_COLOR_4","TOP_TEXT_COLOR_5","TOP_TEXT_COLOR_6","TOP_TEXT_COLOR_7","TOP_TEXT_COLOR_8","TOP_TEXT_COLOR_9","TOP_TEXT_COLOR_10","TOP_TEXT_COLOR_11","TOP_TEXT_COLOR_12","BOTTOM_TEXT_1","BOTTOM_TEXT_2","BOTTOM_TEXT_3","BOTTOM_TEXT_4","BOTTOM_TEXT_5","BOTTOM_TEXT_6","BOTTOM_TEXT_7","BOTTOM_TEXT_8","BOTTOM_TEXT_9","BOTTOM_TEXT_10","BOTTOM_TEXT_11","BOTTOM_TEXT_12","BOTTOM_TEXT_COLOR_1","BOTTOM_TEXT_COLOR_2","BOTTOM_TEXT_COLOR_3","BOTTOM_TEXT_COLOR_4","BOTTOM_TEXT_COLOR_5","BOTTOM_TEXT_COLOR_6","BOTTOM_TEXT_COLOR_7","BOTTOM_TEXT_COLOR_8","BOTTOM_TEXT_COLOR_9","BOTTOM_TEXT_COLOR_10","BOTTOM_TEXT_COLOR_11","BOTTOM_TEXT_COLOR_12","ICON_1","ICON_2","ICON_3","ICON_4","ICON_5","ACTUAL_ACCRUAL_CODE","FORECAST_IND","DEPRECATED_IND","RECORD_STATUS","CREATED_BY","CREATED_DATE","LAST_UPDATED_BY","LAST_UPDATED_DATE","REV_NO","REV_TEXT","APPROVAL_BY","APPROVAL_DATE","APPROVAL_STATE","REC_ID" from v_tracing_data_extract
union all
select "HEADING","PROCESS","DATA_ENTITY_CAT","SORT_ORDER","DATA_ENTITY_DAYTIME","PERIOD","DATA_ENTITY_ID","DATA_ENTITY_TYPE","PROPERTY_OBJ_CODE","PROPERTY_OBJ_ID","PARENT_PROJECT_OBJ_CODE","PARENT_PROJECT_OBJ_ID","PROJECT_OBJ_CODE","PROJECT_OBJ_ID","DEP_STATUS","BOX_TEXT_1","BOX_TEXT_2","BOX_TEXT_3","BOX_TEXT_4","BOX_TEXT_5","BOX_TEXT_6","BOX_TEXT_COLOR_1","BOX_TEXT_COLOR_2","BOX_TEXT_COLOR_3","BOX_TEXT_COLOR_4","BOX_TEXT_COLOR_5","BOX_TEXT_COLOR_6","TOP_TEXT_1","TOP_TEXT_2","TOP_TEXT_3","TOP_TEXT_4","TOP_TEXT_5","TOP_TEXT_6","TOP_TEXT_7","TOP_TEXT_8","TOP_TEXT_9","TOP_TEXT_10","TOP_TEXT_11","TOP_TEXT_12","TOP_TEXT_COLOR_1","TOP_TEXT_COLOR_2","TOP_TEXT_COLOR_3","TOP_TEXT_COLOR_4","TOP_TEXT_COLOR_5","TOP_TEXT_COLOR_6","TOP_TEXT_COLOR_7","TOP_TEXT_COLOR_8","TOP_TEXT_COLOR_9","TOP_TEXT_COLOR_10","TOP_TEXT_COLOR_11","TOP_TEXT_COLOR_12","BOTTOM_TEXT_1","BOTTOM_TEXT_2","BOTTOM_TEXT_3","BOTTOM_TEXT_4","BOTTOM_TEXT_5","BOTTOM_TEXT_6","BOTTOM_TEXT_7","BOTTOM_TEXT_8","BOTTOM_TEXT_9","BOTTOM_TEXT_10","BOTTOM_TEXT_11","BOTTOM_TEXT_12","BOTTOM_TEXT_COLOR_1","BOTTOM_TEXT_COLOR_2","BOTTOM_TEXT_COLOR_3","BOTTOM_TEXT_COLOR_4","BOTTOM_TEXT_COLOR_5","BOTTOM_TEXT_COLOR_6","BOTTOM_TEXT_COLOR_7","BOTTOM_TEXT_COLOR_8","BOTTOM_TEXT_COLOR_9","BOTTOM_TEXT_COLOR_10","BOTTOM_TEXT_COLOR_11","BOTTOM_TEXT_COLOR_12","ICON_1","ICON_2","ICON_3","ICON_4","ICON_5","ACTUAL_ACCRUAL_CODE","FORECAST_IND","DEPRECATED_IND","RECORD_STATUS","CREATED_BY","CREATED_DATE","LAST_UPDATED_BY","LAST_UPDATED_DATE","REV_NO","REV_TEXT","APPROVAL_BY","APPROVAL_DATE","APPROVAL_STATE","REC_ID" from v_tracing_revn_calc
union all
SELECT "HEADING","PROCESS","DATA_ENTITY_CAT","SORT_ORDER","DATA_ENTITY_DAYTIME","PERIOD","DATA_ENTITY_ID","DATA_ENTITY_TYPE","PROPERTY_OBJ_CODE","PROPERTY_OBJ_ID","PARENT_PROJECT_OBJ_CODE","PARENT_PROJECT_OBJ_ID","PROJECT_OBJ_CODE","PROJECT_OBJ_ID","DEP_STATUS","BOX_TEXT_1","BOX_TEXT_2","BOX_TEXT_3","BOX_TEXT_4","BOX_TEXT_5","BOX_TEXT_6","BOX_TEXT_COLOR_1","BOX_TEXT_COLOR_2","BOX_TEXT_COLOR_3","BOX_TEXT_COLOR_4","BOX_TEXT_COLOR_5","BOX_TEXT_COLOR_6","TOP_TEXT_1","TOP_TEXT_2","TOP_TEXT_3","TOP_TEXT_4","TOP_TEXT_5","TOP_TEXT_6","TOP_TEXT_7","TOP_TEXT_8","TOP_TEXT_9","TOP_TEXT_10","TOP_TEXT_11","TOP_TEXT_12","TOP_TEXT_COLOR_1","TOP_TEXT_COLOR_2","TOP_TEXT_COLOR_3","TOP_TEXT_COLOR_4","TOP_TEXT_COLOR_5","TOP_TEXT_COLOR_6","TOP_TEXT_COLOR_7","TOP_TEXT_COLOR_8","TOP_TEXT_COLOR_9","TOP_TEXT_COLOR_10","TOP_TEXT_COLOR_11","TOP_TEXT_COLOR_12","BOTTOM_TEXT_1","BOTTOM_TEXT_2","BOTTOM_TEXT_3","BOTTOM_TEXT_4","BOTTOM_TEXT_5","BOTTOM_TEXT_6","BOTTOM_TEXT_7","BOTTOM_TEXT_8","BOTTOM_TEXT_9","BOTTOM_TEXT_10","BOTTOM_TEXT_11","BOTTOM_TEXT_12","BOTTOM_TEXT_COLOR_1","BOTTOM_TEXT_COLOR_2","BOTTOM_TEXT_COLOR_3","BOTTOM_TEXT_COLOR_4","BOTTOM_TEXT_COLOR_5","BOTTOM_TEXT_COLOR_6","BOTTOM_TEXT_COLOR_7","BOTTOM_TEXT_COLOR_8","BOTTOM_TEXT_COLOR_9","BOTTOM_TEXT_COLOR_10","BOTTOM_TEXT_COLOR_11","BOTTOM_TEXT_COLOR_12","ICON_1","ICON_2","ICON_3","ICON_4","ICON_5","ACTUAL_ACCRUAL_CODE","FORECAST_IND","DEPRECATED_IND","RECORD_STATUS","CREATED_BY","CREATED_DATE","LAST_UPDATED_BY","LAST_UPDATED_DATE","REV_NO","REV_TEXT","APPROVAL_BY","APPROVAL_DATE","APPROVAL_STATE","REC_ID" from v_tracing_fin_doc
union all
SELECT "HEADING","PROCESS","DATA_ENTITY_CAT","SORT_ORDER","DATA_ENTITY_DAYTIME","PERIOD","DATA_ENTITY_ID","DATA_ENTITY_TYPE","PROPERTY_OBJ_CODE","PROPERTY_OBJ_ID","PARENT_PROJECT_OBJ_CODE","PARENT_PROJECT_OBJ_ID","PROJECT_OBJ_CODE","PROJECT_OBJ_ID","DEP_STATUS","BOX_TEXT_1","BOX_TEXT_2","BOX_TEXT_3","BOX_TEXT_4","BOX_TEXT_5","BOX_TEXT_6","BOX_TEXT_COLOR_1","BOX_TEXT_COLOR_2","BOX_TEXT_COLOR_3","BOX_TEXT_COLOR_4","BOX_TEXT_COLOR_5","BOX_TEXT_COLOR_6","TOP_TEXT_1","TOP_TEXT_2","TOP_TEXT_3","TOP_TEXT_4","TOP_TEXT_5","TOP_TEXT_6","TOP_TEXT_7","TOP_TEXT_8","TOP_TEXT_9","TOP_TEXT_10","TOP_TEXT_11","TOP_TEXT_12","TOP_TEXT_COLOR_1","TOP_TEXT_COLOR_2","TOP_TEXT_COLOR_3","TOP_TEXT_COLOR_4","TOP_TEXT_COLOR_5","TOP_TEXT_COLOR_6","TOP_TEXT_COLOR_7","TOP_TEXT_COLOR_8","TOP_TEXT_COLOR_9","TOP_TEXT_COLOR_10","TOP_TEXT_COLOR_11","TOP_TEXT_COLOR_12","BOTTOM_TEXT_1","BOTTOM_TEXT_2","BOTTOM_TEXT_3","BOTTOM_TEXT_4","BOTTOM_TEXT_5","BOTTOM_TEXT_6","BOTTOM_TEXT_7","BOTTOM_TEXT_8","BOTTOM_TEXT_9","BOTTOM_TEXT_10","BOTTOM_TEXT_11","BOTTOM_TEXT_12","BOTTOM_TEXT_COLOR_1","BOTTOM_TEXT_COLOR_2","BOTTOM_TEXT_COLOR_3","BOTTOM_TEXT_COLOR_4","BOTTOM_TEXT_COLOR_5","BOTTOM_TEXT_COLOR_6","BOTTOM_TEXT_COLOR_7","BOTTOM_TEXT_COLOR_8","BOTTOM_TEXT_COLOR_9","BOTTOM_TEXT_COLOR_10","BOTTOM_TEXT_COLOR_11","BOTTOM_TEXT_COLOR_12","ICON_1","ICON_2","ICON_3","ICON_4","ICON_5","ACTUAL_ACCRUAL_CODE","FORECAST_IND","DEPRECATED_IND","RECORD_STATUS","CREATED_BY","CREATED_DATE","LAST_UPDATED_BY","LAST_UPDATED_DATE","REV_NO","REV_TEXT","APPROVAL_BY","APPROVAL_DATE","APPROVAL_STATE","REC_ID" FROM v_tracing_report
union all
SELECT "HEADING","PROCESS","DATA_ENTITY_CAT","SORT_ORDER","DATA_ENTITY_DAYTIME","PERIOD","DATA_ENTITY_ID","DATA_ENTITY_TYPE","PROPERTY_OBJ_CODE","PROPERTY_OBJ_ID","PARENT_PROJECT_OBJ_CODE","PARENT_PROJECT_OBJ_ID","PROJECT_OBJ_CODE","PROJECT_OBJ_ID","DEP_STATUS","BOX_TEXT_1","BOX_TEXT_2","BOX_TEXT_3","BOX_TEXT_4","BOX_TEXT_5","BOX_TEXT_6","BOX_TEXT_COLOR_1","BOX_TEXT_COLOR_2","BOX_TEXT_COLOR_3","BOX_TEXT_COLOR_4","BOX_TEXT_COLOR_5","BOX_TEXT_COLOR_6","TOP_TEXT_1","TOP_TEXT_2","TOP_TEXT_3","TOP_TEXT_4","TOP_TEXT_5","TOP_TEXT_6","TOP_TEXT_7","TOP_TEXT_8","TOP_TEXT_9","TOP_TEXT_10","TOP_TEXT_11","TOP_TEXT_12","TOP_TEXT_COLOR_1","TOP_TEXT_COLOR_2","TOP_TEXT_COLOR_3","TOP_TEXT_COLOR_4","TOP_TEXT_COLOR_5","TOP_TEXT_COLOR_6","TOP_TEXT_COLOR_7","TOP_TEXT_COLOR_8","TOP_TEXT_COLOR_9","TOP_TEXT_COLOR_10","TOP_TEXT_COLOR_11","TOP_TEXT_COLOR_12","BOTTOM_TEXT_1","BOTTOM_TEXT_2","BOTTOM_TEXT_3","BOTTOM_TEXT_4","BOTTOM_TEXT_5","BOTTOM_TEXT_6","BOTTOM_TEXT_7","BOTTOM_TEXT_8","BOTTOM_TEXT_9","BOTTOM_TEXT_10","BOTTOM_TEXT_11","BOTTOM_TEXT_12","BOTTOM_TEXT_COLOR_1","BOTTOM_TEXT_COLOR_2","BOTTOM_TEXT_COLOR_3","BOTTOM_TEXT_COLOR_4","BOTTOM_TEXT_COLOR_5","BOTTOM_TEXT_COLOR_6","BOTTOM_TEXT_COLOR_7","BOTTOM_TEXT_COLOR_8","BOTTOM_TEXT_COLOR_9","BOTTOM_TEXT_COLOR_10","BOTTOM_TEXT_COLOR_11","BOTTOM_TEXT_COLOR_12","ICON_1","ICON_2","ICON_3","ICON_4","ICON_5","ACTUAL_ACCRUAL_CODE","FORECAST_IND","DEPRECATED_IND","RECORD_STATUS","CREATED_BY","CREATED_DATE","LAST_UPDATED_BY","LAST_UPDATED_DATE","REV_NO","REV_TEXT","APPROVAL_BY","APPROVAL_DATE","APPROVAL_STATE","REC_ID" FROM v_tracing_data_uploads
union all
SELECT "HEADING","PROCESS","DATA_ENTITY_CAT","SORT_ORDER","DATA_ENTITY_DAYTIME","PERIOD","DATA_ENTITY_ID","DATA_ENTITY_TYPE","PROPERTY_OBJ_CODE","PROPERTY_OBJ_ID","PARENT_PROJECT_OBJ_CODE","PARENT_PROJECT_OBJ_ID","PROJECT_OBJ_CODE","PROJECT_OBJ_ID","DEP_STATUS","BOX_TEXT_1","BOX_TEXT_2","BOX_TEXT_3","BOX_TEXT_4","BOX_TEXT_5","BOX_TEXT_6","BOX_TEXT_COLOR_1","BOX_TEXT_COLOR_2","BOX_TEXT_COLOR_3","BOX_TEXT_COLOR_4","BOX_TEXT_COLOR_5","BOX_TEXT_COLOR_6","TOP_TEXT_1","TOP_TEXT_2","TOP_TEXT_3","TOP_TEXT_4","TOP_TEXT_5","TOP_TEXT_6","TOP_TEXT_7","TOP_TEXT_8","TOP_TEXT_9","TOP_TEXT_10","TOP_TEXT_11","TOP_TEXT_12","TOP_TEXT_COLOR_1","TOP_TEXT_COLOR_2","TOP_TEXT_COLOR_3","TOP_TEXT_COLOR_4","TOP_TEXT_COLOR_5","TOP_TEXT_COLOR_6","TOP_TEXT_COLOR_7","TOP_TEXT_COLOR_8","TOP_TEXT_COLOR_9","TOP_TEXT_COLOR_10","TOP_TEXT_COLOR_11","TOP_TEXT_COLOR_12","BOTTOM_TEXT_1","BOTTOM_TEXT_2","BOTTOM_TEXT_3","BOTTOM_TEXT_4","BOTTOM_TEXT_5","BOTTOM_TEXT_6","BOTTOM_TEXT_7","BOTTOM_TEXT_8","BOTTOM_TEXT_9","BOTTOM_TEXT_10","BOTTOM_TEXT_11","BOTTOM_TEXT_12","BOTTOM_TEXT_COLOR_1","BOTTOM_TEXT_COLOR_2","BOTTOM_TEXT_COLOR_3","BOTTOM_TEXT_COLOR_4","BOTTOM_TEXT_COLOR_5","BOTTOM_TEXT_COLOR_6","BOTTOM_TEXT_COLOR_7","BOTTOM_TEXT_COLOR_8","BOTTOM_TEXT_COLOR_9","BOTTOM_TEXT_COLOR_10","BOTTOM_TEXT_COLOR_11","BOTTOM_TEXT_COLOR_12","ICON_1","ICON_2","ICON_3","ICON_4","ICON_5","ACTUAL_ACCRUAL_CODE","FORECAST_IND","DEPRECATED_IND","RECORD_STATUS","CREATED_BY","CREATED_DATE","LAST_UPDATED_BY","LAST_UPDATED_DATE","REV_NO","REV_TEXT","APPROVAL_BY","APPROVAL_DATE","APPROVAL_STATE","REC_ID" FROM v_tracing_mth_alloc