CREATE OR REPLACE FORCE EDITIONABLE VIEW "V_COST_MAPPING_SRC_OBJECT" ("OBJECT_TYPE", "SOURCE_TYPE", "CLASS_NAME", "OBJECT_ID", "CODE", "NAME", "START_DATE", "END_DATE", "RECORD_STATUS", "CREATED_BY", "CREATED_DATE", "LAST_UPDATED_BY", "LAST_UPDATED_DATE", "REV_NO", "REV_TEXT", "APPROVAL_STATE", "APPROVAL_BY", "APPROVAL_DATE") AS 
  SELECT 'OBJECT' AS object_type,
       TYPES.source_type as source_type,
       CLASS_NAME,
       OBJECT_ID,
       CODE as CODE,
       Name as name,
       OBJECT_START_DATE as start_date,
       OBJECT_END_DATE as end_date,
       'P' record_status,
       'SYSTEM' created_by,
       date '1900-01-01' created_date,
       'SYSTEM' last_updated_by,
       date '1900-01-01' last_updated_date,
       0 rev_no,
       null rev_text,
       null approval_state,
       null approval_by,
       null approval_date
  FROM tv_objects,
       (SELECT SUBSTR(ALT_CODE, 1, INSTR(ALT_CODE, ':', 1) - 1) AS source_data_type,
               SUBSTR(ALT_CODE,
                      INSTR(ALT_CODE, ':', 1) + 1,
                      INSTR(ALT_CODE, ';', 1) - INSTR(ALT_CODE, ':', 1) - 1) AS source_data_sub_type,
               CODE     AS source_type,
               ALT_CODE
          FROM prosty_codes
         WHERE code_type = 'COST_MAPPING_SRC_TYPE') TYPES
 where class_name = TYPES.source_data_sub_type
   AND TYPES.source_data_type = 'OBJECT'
UNION ALL
   SELECT 'OBJECT',
       TYPES.source_type,
       'PROJECT',
       contract.OBJECT_ID,
       contract.object_code,
       contract_version.name as name,
       contract.START_DATE as start_date,
       contract.END_DATE as end_date,
       'P' record_status,
       'SYSTEM' created_by,
       date '1900-01-01' created_date,
       'SYSTEM' last_updated_by,
       date '1900-01-01' last_updated_date,
       0 rev_no,
       null rev_text,
       null approval_state,
       null approval_by,
       null approval_date
  FROM contract,
       contract_version,
       (SELECT SUBSTR(ALT_CODE, 1, INSTR(ALT_CODE, ':', 1) - 1) AS source_data_type,
               SUBSTR(ALT_CODE,
                      INSTR(ALT_CODE, ':', 1) + 1,
                      INSTR(ALT_CODE, ';', 1) - INSTR(ALT_CODE, ':', 1) - 1) AS source_data_sub_type,
               CODE AS source_type,
               ALT_CODE
          FROM prosty_codes
         WHERE code_type = 'COST_MAPPING_SRC_TYPE') TYPES
 where 'PROJECT' = TYPES.source_data_sub_type
   AND contract.object_id = contract_version.object_id
   AND contract_version.daytime =
       (SELECT MAX(daytime)
          FROM contract_version v
         WHERE v.object_id = contract.object_id)
   AND TYPES.source_data_type = 'OBJECT'
   AND CONTRACT.PROJECT_IND = 'Y'
UNION ALL
SELECT 'OBJECT',
       TYPES.source_type as source_type,
       prosty_codes.code_type,
       NULL,
       prosty_codes.code as CODE,
       code_text as name,
       NULL,
       NULL,
       'P' record_status,
       'SYSTEM' created_by,
       date '1900-01-01' created_date,
       'SYSTEM' last_updated_by,
       date '1900-01-01' last_updated_date,
       0 rev_no,
       null rev_text,
       null approval_state,
       null approval_by,
       null approval_date
  FROM prosty_codes,
       (SELECT SUBSTR(ALT_CODE, 1, INSTR(ALT_CODE, ':', 1) - 1) AS source_data_type,
               SUBSTR(ALT_CODE,
                      INSTR(ALT_CODE, ':', 1) + 1,
                      INSTR(ALT_CODE, ';', 1) - INSTR(ALT_CODE, ':', 1) - 1) AS source_data_sub_type,
               CODE AS source_type,
               ALT_CODE
          FROM prosty_codes
         WHERE code_type = 'COST_MAPPING_SRC_TYPE') TYPES
 where prosty_codes.code_type = TYPES.source_data_sub_type
   AND TYPES.source_data_type = 'EC_CODE'
UNION ALL
SELECT 'OBJECT_LIST',
       TYPES.source_type,
       object_list_version.class_name,
       object_list.OBJECT_ID,
       object_list.object_code,
       object_list_version.name as name,
       object_list.START_DATE as start_date,
       object_list.END_DATE as end_date,
       'P' record_status,
       'SYSTEM' created_by,
       date '1900-01-01' created_date,
       'SYSTEM' last_updated_by,
       date '1900-01-01' last_updated_date,
       0 rev_no,
       null rev_text,
       null approval_state,
       null approval_by,
       null approval_date
  FROM object_list,
       object_list_version,
       (SELECT SUBSTR(ALT_CODE, 1, INSTR(ALT_CODE, ':', 1) - 1) AS source_data_type,
               SUBSTR(ALT_CODE,
                      INSTR(ALT_CODE, ':', 1) + 1,
                      INSTR(ALT_CODE, ';', 1) - INSTR(ALT_CODE, ':', 1) - 1) AS source_data_sub_type,
               CODE AS source_type,
               ALT_CODE
          FROM prosty_codes
         WHERE code_type = 'COST_MAPPING_SRC_TYPE') TYPES
 where object_list_version.class_name = TYPES.source_data_sub_type
   AND object_list.object_id = object_list_version.object_id
   AND object_list_version.daytime =
       (SELECT MAX(daytime)
          FROM object_list_version v
         WHERE v.object_id = object_list.object_id)
   AND TYPES.source_data_type = 'OBJECT'
UNION ALL
SELECT 'OBJECT_LIST',
       TYPES.source_type,
       object_list_version.class_name,
       object_list.OBJECT_ID,
       object_list.object_code,
       object_list_version.name as name,
       object_list.START_DATE as start_date,
       object_list.END_DATE as end_Date,
       'P' record_status,
       'SYSTEM' created_by,
       date '1900-01-01' created_date,
       'SYSTEM' last_updated_by,
       date '1900-01-01' last_updated_date,
       0 rev_no,
       null rev_text,
       null approval_state,
       null approval_by,
       null approval_date
  FROM object_list,
       object_list_version,
       (SELECT SUBSTR(ALT_CODE, 1, INSTR(ALT_CODE, ':', 1) - 1) AS source_data_type,
               SUBSTR(ALT_CODE,
                      INSTR(ALT_CODE, ':', 1) + 1,
                      INSTR(ALT_CODE, ';', 1) - INSTR(ALT_CODE, ':', 1) - 1) AS source_data_sub_type,
               CODE AS source_type,
               ALT_CODE
          FROM prosty_codes
         WHERE code_type = 'COST_MAPPING_SRC_TYPE') TYPES
 where object_list_version.class_name = 'EC_CODE_OBJECT'
   AND object_list.object_id = object_list_version.object_id
   AND object_list_version.daytime =
       (SELECT MAX(daytime)
          FROM object_list_version v
         WHERE v.object_id = object_list.object_id)
   AND TYPES.source_data_type = 'EC_CODE'
   UNION ALL
       SELECT 'EC_CODE',
       TYPES.source_type as source_type,
       prosty_codes.code_type,
       NULL,
       prosty_codes.code as CODE,
       code_text as name,
       NULL,
       NULL,
       'P' record_status,
       'SYSTEM' created_by,
       date '1900-01-01' created_date,
       'SYSTEM' last_updated_by,
       date '1900-01-01' last_updated_date,
       0 rev_no,
       null rev_text,
       null approval_state,
       null approval_by,
       null approval_date
  FROM prosty_codes,
       (SELECT SUBSTR(ALT_CODE, 1, INSTR(ALT_CODE, ':', 1) - 1) AS source_data_type,
               SUBSTR(ALT_CODE,
                      INSTR(ALT_CODE, ':', 1) + 1,
                      INSTR(ALT_CODE, ';', 1) - INSTR(ALT_CODE, ':', 1) - 1) AS source_data_sub_type,
               CODE AS source_type,
               ALT_CODE
          FROM prosty_codes
         WHERE code_type = 'COST_MAPPING_SRC_TYPE') TYPES
 where prosty_codes.code_type = TYPES.source_data_sub_type
   AND TYPES.source_data_type = 'EC_CODE'