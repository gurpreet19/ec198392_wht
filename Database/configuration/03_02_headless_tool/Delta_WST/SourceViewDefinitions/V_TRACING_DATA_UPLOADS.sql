CREATE OR REPLACE FORCE EDITIONABLE VIEW "V_TRACING_DATA_UPLOADS" ("HEADING", "PROCESS", "DATA_ENTITY_CAT", "SORT_ORDER", "DATA_ENTITY_DAYTIME", "PERIOD", "DATA_ENTITY_ID", "DATA_ENTITY_TYPE", "PROPERTY_OBJ_CODE", "PROPERTY_OBJ_ID", "PARENT_PROJECT_OBJ_CODE", "PARENT_PROJECT_OBJ_ID", "PROJECT_OBJ_CODE", "PROJECT_OBJ_ID", "DEP_STATUS", "BOX_TEXT_1", "BOX_TEXT_2", "BOX_TEXT_3", "BOX_TEXT_4", "BOX_TEXT_5", "BOX_TEXT_6", "BOX_TEXT_COLOR_1", "BOX_TEXT_COLOR_2", "BOX_TEXT_COLOR_3", "BOX_TEXT_COLOR_4", "BOX_TEXT_COLOR_5", "BOX_TEXT_COLOR_6", "TOP_TEXT_1", "TOP_TEXT_2", "TOP_TEXT_3", "TOP_TEXT_4", "TOP_TEXT_5", "TOP_TEXT_6", "TOP_TEXT_7", "TOP_TEXT_8", "TOP_TEXT_9", "TOP_TEXT_10", "TOP_TEXT_11", "TOP_TEXT_12", "TOP_TEXT_COLOR_1", "TOP_TEXT_COLOR_2", "TOP_TEXT_COLOR_3", "TOP_TEXT_COLOR_4", "TOP_TEXT_COLOR_5", "TOP_TEXT_COLOR_6", "TOP_TEXT_COLOR_7", "TOP_TEXT_COLOR_8", "TOP_TEXT_COLOR_9", "TOP_TEXT_COLOR_10", "TOP_TEXT_COLOR_11", "TOP_TEXT_COLOR_12", "BOTTOM_TEXT_1", "BOTTOM_TEXT_2", "BOTTOM_TEXT_3", "BOTTOM_TEXT_4", "BOTTOM_TEXT_5", "BOTTOM_TEXT_6", "BOTTOM_TEXT_7", "BOTTOM_TEXT_8", "BOTTOM_TEXT_9", "BOTTOM_TEXT_10", "BOTTOM_TEXT_11", "BOTTOM_TEXT_12", "BOTTOM_TEXT_COLOR_1", "BOTTOM_TEXT_COLOR_2", "BOTTOM_TEXT_COLOR_3", "BOTTOM_TEXT_COLOR_4", "BOTTOM_TEXT_COLOR_5", "BOTTOM_TEXT_COLOR_6", "BOTTOM_TEXT_COLOR_7", "BOTTOM_TEXT_COLOR_8", "BOTTOM_TEXT_COLOR_9", "BOTTOM_TEXT_COLOR_10", "BOTTOM_TEXT_COLOR_11", "BOTTOM_TEXT_COLOR_12", "ICON_1", "ICON_2", "ICON_3", "ICON_4", "ICON_5", "ACTUAL_ACCRUAL_CODE", "FORECAST_IND", "DEPRECATED_IND", "RECORD_STATUS", "CREATED_BY", "CREATED_DATE", "LAST_UPDATED_BY", "LAST_UPDATED_DATE", "REV_NO", "REV_TEXT", "APPROVAL_BY", "APPROVAL_DATE", "APPROVAL_STATE", "REC_ID") AS 
  select
  'Data Uploads'                                                                                                              as HEADING,
  null                                                                                                                        as PROCESS,
  'DATA_UPLOADS'                                                                                                              as DATA_ENTITY_CAT,
  2                                                                                                                           as SORT_ORDER,
  x.upload_date                                                                                                               as DATA_ENTITY_DAYTIME,
  x.PERIOD                                                                                                                    as PERIOD,
  TO_CHAR(x.period,'YYYY-MM-DD')||'$'||x.source_doc_name||'$'||x.source_doc_ver                                               as DATA_ENTITY_ID,
  'IFAC_JOURNAL_ENTRY'                                                                                                        as DATA_ENTITY_TYPE,
  null                                                                                                                        as PROPERTY_OBJ_CODE,
  null                                                                                                                        as PROPERTY_OBJ_ID,
  null                                                                                                                        as PARENT_PROJECT_OBJ_CODE,
  null                                                                                                                        as PARENT_PROJECT_OBJ_ID,
  null                                                                                                                        as PROJECT_OBJ_CODE,
  null                                                                                                                        as PROJECT_OBJ_ID,
  nvl(ec_prosty_codes.code_text(x.RECORD_STATUS,'TRACING_STATUS'),ec_prosty_codes.code_text(x.RECORD_STATUS, 'TRACING_STATUS')) as DEP_STATUS,
  'Upload: '|| x.SOURCE_DOC_NAME                                                                                              as BOX_TEXT_1,
  'Upload version: '|| x.SOURCE_DOC_VER                                                                                       as BOX_TEXT_2,
  'Reference ID: ' || nvl(dfd.reference_id,'None')                                                                            as BOX_TEXT_3,
  'Status: ' || nvl(ec_prosty_codes.code_text(x.record_status,'IFAC_JE_STATUS'),ec_prosty_codes.code_text(x.record_status, 'IFAC_JE_STATUS')) as BOX_TEXT_4,
  'Created by: '|| nvl(ec_t_basis_user.given_name(x.created_by),x.created_by) ||' '|| ec_t_basis_user.surname(x.created_by)   as BOX_TEXT_5,
  'Last Updated by: '|| nvl(ec_t_basis_user.given_name(x.LAST_UPDATED_BY),x.LAST_UPDATED_BY) ||' '|| ec_t_basis_user.surname(x.LAST_UPDATED_BY)   as BOX_TEXT_6,
  NULL                                                                                                                        as BOX_TEXT_COLOR_1,
  NULL                                                                                                                        as BOX_TEXT_COLOR_2,
  NULL                                                                                                                        as BOX_TEXT_COLOR_3,
  NULL                                                                                                                        as BOX_TEXT_COLOR_4,
  NULL                                                                                                                        as BOX_TEXT_COLOR_5,
  NULL                                                                                                                        as BOX_TEXT_COLOR_6,
  null                                                                                                                        as TOP_TEXT_1,
  null                                                                                                                        as TOP_TEXT_2,
  null                                                                                                                        as TOP_TEXT_3,
  null                                                                                                                        as TOP_TEXT_4,
  null                                                                                                                        as TOP_TEXT_5,
  null                                                                                                                        as TOP_TEXT_6,
  null                                                                                                                        as TOP_TEXT_7,
  null                                                                                                                        as TOP_TEXT_8,
  null                                                                                                                        as TOP_TEXT_9,
  null                                                                                                                        as TOP_TEXT_10,
  null                                                                                                                        as TOP_TEXT_11,
  null                                                                                                                        as TOP_TEXT_12,
  null                                                                                                                        as TOP_TEXT_COLOR_1,
  null                                                                                                                        as TOP_TEXT_COLOR_2,
  null                                                                                                                        as TOP_TEXT_COLOR_3,
  null                                                                                                                        as TOP_TEXT_COLOR_4,
  null                                                                                                                        as TOP_TEXT_COLOR_5,
  null                                                                                                                        as TOP_TEXT_COLOR_6,
  null                                                                                                                        as TOP_TEXT_COLOR_7,
  null                                                                                                                        as TOP_TEXT_COLOR_8,
  null                                                                                                                        as TOP_TEXT_COLOR_9,
  null                                                                                                                        as TOP_TEXT_COLOR_10,
  null                                                                                                                        as TOP_TEXT_COLOR_11,
  null                                                                                                                        as TOP_TEXT_COLOR_12,
  null                                                                                                                        as BOTTOM_TEXT_1,
  null                                                                                                                        as BOTTOM_TEXT_2,
  null                                                                                                                        as BOTTOM_TEXT_3,
  null                                                                                                                        as BOTTOM_TEXT_4,
  null                                                                                                                        as BOTTOM_TEXT_5,
  null                                                                                                                        as BOTTOM_TEXT_6,
  null                                                                                                                        as BOTTOM_TEXT_7,
  null                                                                                                                        as BOTTOM_TEXT_8,
  null                                                                                                                        as BOTTOM_TEXT_9,
  null                                                                                                                        as BOTTOM_TEXT_10,
  null                                                                                                                        as BOTTOM_TEXT_11,
  null                                                                                                                        as BOTTOM_TEXT_12,
  null                                                                                                                        as BOTTOM_TEXT_COLOR_1,
  null                                                                                                                        as BOTTOM_TEXT_COLOR_2,
  null                                                                                                                        as BOTTOM_TEXT_COLOR_3,
  null                                                                                                                        as BOTTOM_TEXT_COLOR_4,
  null                                                                                                                        as BOTTOM_TEXT_COLOR_5,
  null                                                                                                                        as BOTTOM_TEXT_COLOR_6,
  null                                                                                                                        as BOTTOM_TEXT_COLOR_7,
  null                                                                                                                        as BOTTOM_TEXT_COLOR_8,
  null                                                                                                                        as BOTTOM_TEXT_COLOR_9,
  null                                                                                                                        as BOTTOM_TEXT_COLOR_10,
  null                                                                                                                        as BOTTOM_TEXT_COLOR_11,
  null                                                                                                                        as BOTTOM_TEXT_COLOR_12,
  decode(nvl(dfd.reference_id,'NULL'), 'NULL', 'tracing/WARNING.png', 'tracing/OK.png')                                       as ICON_1,
  'tracing/' || x.record_status || '.png'                                                                                     as ICON_2,
  decode(ecdp_visual_tracing.GetForwardReference(dfd.reference_id, 'IFAC_JOURNAL_ENTRY'),'true','tracing/LOCK.png','')        as ICON_3,
  decode(ecdp_visual_tracing.GetNotesReference(TO_CHAR(x.period,'YYYY-MM-DD')||'$'||x.source_doc_name||'$'||x.source_doc_ver, 'IFAC_JOURNAL_ENTRY'),'true','tracing/NOTES.png','') as ICON_4,
  NULL                                                                                                                        as ICON_5,
  NULL                                                                                                                        as ACTUAL_ACCRUAL_CODE,
  'N'                                                                                                                         as FORECAST_IND,
  decode(ec_dataset_flow_document.status('IFAC_JOURNAL_ENTRY',dfd.reference_id),'D','Y','N')                                  as DEPRECATED_IND,
  x.RECORD_STATUS                                                                                                             as RECORD_STATUS,
  x.CREATED_BY                                                                                                                as CREATED_BY,
  x.CREATED_DATE                                                                                                              as CREATED_DATE,
  x.LAST_UPDATED_BY                                                                                                           as LAST_UPDATED_BY,
  x.LAST_UPDATED_DATE                                                                                                         as LAST_UPDATED_DATE,
  x.REV_NO                                                                                                                    as REV_NO,
  x.REV_TEXT                                                                                                                  as REV_TEXT,
  x.APPROVAL_BY                                                                                                               as APPROVAL_BY,
  x.APPROVAL_DATE                                                                                                             as APPROVAL_DATE,
  null                                                                                                                        as APPROVAL_STATE,
  null                                                                                                                        as REC_ID
FROM V_IFAC_JOURNAL_ENTRY_DOC x
  left join dataset_flow_document dfd on TO_CHAR(x.period,'YYYY-MM-DD')||'$'||x.source_doc_name||'$'||x.source_doc_ver = dfd.reference_id