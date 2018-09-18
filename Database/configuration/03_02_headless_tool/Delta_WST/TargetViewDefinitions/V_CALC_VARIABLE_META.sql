CREATE OR REPLACE FORCE VIEW "V_CALC_VARIABLE_META" ("CALC_CONTEXT_ID", "CLASS_NAME", "SQL_SYNTAX", "OWNER_CLASS_NAME", "CLASS_TYPE", "OBJECT_TYPE", "IS_SAMPLE", "DATA_TYPE", "NAME", "PRECISION", "DIM0_OBJECT_TYPE", "DIM1_OBJECT_TYPE", "DIM2_OBJECT_TYPE", "DIM3_OBJECT_TYPE", "DIM4_OBJECT_TYPE", "DIM0_DATA_TYPE", "DIM1_DATA_TYPE", "DIM2_DATA_TYPE", "DIM3_DATA_TYPE", "DIM4_DATA_TYPE", "DIM0_ATTRIBUTE_NAME", "DIM1_ATTRIBUTE_NAME", "DIM2_ATTRIBUTE_NAME", "DIM3_ATTRIBUTE_NAME", "DIM4_ATTRIBUTE_NAME", "DIM2_SET_BY_TRIGGER", "DIM3_SET_BY_TRIGGER", "DIM4_SET_BY_TRIGGER", "ACCESS_MODE", "SOURCE_NAME", "DATE_HANDLING_PROPS", "CALC_DATE_HANDLING", "VALID_FROM_ATTR_NAME", "VALID_TO_ATTR_NAME", "PROD_DAY_ATTR_NAME", "SUB_DAILY_IND", "IS_ADVANCED", "DATASETS", "QUALIFIER_DATA_TYPE", "QUALIFIER_ATTRIBUTE_NAME", "QUALIFIER_PARAM_NAME", "ALWAYS_INSERT", "TIME_SCOPE_CODE", "DESCRIPTION", "RECORD_STATUS", "CREATED_BY", "CREATED_DATE", "LAST_UPDATED_BY", "LAST_UPDATED_DATE", "REV_NO", "REV_TEXT") AS 
  (
------------------------------------------------------------------------------------
--  v_calc_variable_meta
--
--  $Revision: 1.25 $
--
--  Purpose:   Used by the calculation engine to determine which variables that
--             are available and where they are persisted in the database.
--             Also used by the "Node type editor" client to show the user a list of public
--             variables.
--
--
--  When        Who  Why
--  ----------  ---  --------
--  2005-03-04  HUS  Initial version
--  2006-03-17  HLH  Added support for Set by Trigger (Tracker #3372)
--  2006-05-08  JBE  Added support for extended AccessMode, allowing S, D and SO
-------------------------------------------------------------------------------------
SELECT
   cv.object_id as calc_context_id,
   cvr.cls_name as class_name,
   cvr.sql_syntax,
   c.owner_class_name,
   c.class_type,
   cv.calc_object_type_code as object_type,
   decode(cvr.calc_date_handling, 'FIXED_INTERVALS', 'N','Y') as is_sample,
   cv.calc_var_data_type as data_type,
   cv.name,
   cv.default_precision as precision,
   cv.dim1_object_type_code as dim0_object_type,
   cv.dim2_object_type_code as dim1_object_type,
   cv.dim3_object_type_code as dim2_object_type,
   cv.dim4_object_type_code as dim3_object_type,
   cv.dim5_object_type_code as dim4_object_type,
   NVL(ec_calc_object_type.data_type(cv.object_id,cv.dim1_object_type_code),DECODE(cv.dim1_object_type_code,NULL,NULL,'STRING')) as dim0_data_type,
   NVL(ec_calc_object_type.data_type(cv.object_id,cv.dim2_object_type_code),DECODE(cv.dim2_object_type_code,NULL,NULL,'STRING')) as dim1_data_type,
   NVL(ec_calc_object_type.data_type(cv.object_id,cv.dim3_object_type_code),DECODE(cv.dim3_object_type_code,NULL,NULL,'STRING')) as dim2_data_type,
   NVL(ec_calc_object_type.data_type(cv.object_id,cv.dim4_object_type_code),DECODE(cv.dim4_object_type_code,NULL,NULL,'STRING')) as dim3_data_type,
   NVL(ec_calc_object_type.data_type(cv.object_id,cv.dim5_object_type_code),DECODE(cv.dim5_object_type_code,NULL,NULL,'STRING')) as dim4_data_type,
   ecdp_calc_mapping.getReadDimAttributeName(cv.object_id,cv.calc_var_signature,cvr.calc_dataset,cvr.cls_name,1) as dim0_attribute_name,
   ecdp_calc_mapping.getReadDimAttributeName(cv.object_id,cv.calc_var_signature,cvr.calc_dataset,cvr.cls_name,2) as dim1_attribute_name,
   ecdp_calc_mapping.getReadDimAttributeName(cv.object_id,cv.calc_var_signature,cvr.calc_dataset,cvr.cls_name,3) as dim2_attribute_name,
   ecdp_calc_mapping.getReadDimAttributeName(cv.object_id,cv.calc_var_signature,cvr.calc_dataset,cvr.cls_name,4) as dim3_attribute_name,
   ecdp_calc_mapping.getReadDimAttributeName(cv.object_id,cv.calc_var_signature,cvr.calc_dataset,cvr.cls_name,5) as dim4_attribute_name,
   '' as dim2_set_by_trigger,
   '' as dim3_set_by_trigger,
   '' as dim4_set_by_trigger,
   'R' AS access_mode,
   DECODE(c.CLASS_TYPE,'INTERFACE','IV_','DATA','DV_','TABLE','TV_','SUB_CLASS','OSV_','OV_') || cvr.cls_name AS source_name,
   EcDp_Calc_Meta.getDateHandlingProperties(c.class_name) AS date_handling_props,
   cvr.calc_date_handling as calc_date_handling,
   cvr.valid_from_attr_name as valid_from_attr_name,
   cvr.valid_to_attr_name as valid_to_attr_name,
   cvr.prod_day_attr_name as prod_day_attr_name,
   cvr.sub_daily_ind as sub_daily_ind,
   NVL(cv.advanced_ind, 'N') as is_advanced,
   cvr.calc_dataset as datasets,
   ecdp_calc_mapping.getQualifierReadDataType (cv.object_id,cv.calc_var_signature,cvr.calc_dataset,cvr.cls_name) as qualifier_data_type,
   ecdp_calc_mapping.getQualifierReadAttributeName (cv.object_id,cv.calc_var_signature,cvr.calc_dataset,cvr.cls_name) as qualifier_attribute_name,
   ecdp_calc_mapping.getQualifierReadParamName (cv.object_id,cv.calc_var_signature,cvr.calc_dataset,cvr.cls_name) as qualifier_param_name,
   '' as always_insert,
   c.time_scope_code,
   cv.description,
   cv.record_status,
   cv.created_by,
   cv.created_date,
   cv.last_updated_by,
   cv.last_updated_date,
   cv.rev_no,
   cv.rev_text
  from calc_variable cv, calc_var_read_mapping cvr, class  c
  where cvr.cls_name = c.class_name
  and cv.object_id = cvr.object_id
  and cv.calc_var_signature = cvr.calc_var_signature
  and cv.active_ind = 'Y'
  and EcDp_Calc_Mapping.keyReadMappingsSupportedByOE(cvr.object_id, cvr.calc_var_signature, cvr.calc_dataset, cvr.cls_name)='Y'
  union all
SELECT
   cv.object_id as calc_context_id,
   cvw.cls_name as class_name,
   cvw.sql_syntax,
   c.owner_class_name,
   c.class_type,
   cv.calc_object_type_code as object_type,
   'N' as is_sample,
   cv.calc_var_data_type as data_type,
   cv.name,
   cv.default_precision as precision,
   cv.dim1_object_type_code as dim0_object_type,
   cv.dim2_object_type_code as dim1_object_type,
   cv.dim3_object_type_code as dim2_object_type,
   cv.dim4_object_type_code as dim3_object_type,
   cv.dim5_object_type_code as dim4_object_type,
   NVL(ec_calc_object_type.data_type(cv.object_id,cv.dim1_object_type_code),DECODE(cv.dim1_object_type_code,NULL,NULL,'STRING')) as dim0_data_type,
   NVL(ec_calc_object_type.data_type(cv.object_id,cv.dim2_object_type_code),DECODE(cv.dim2_object_type_code,NULL,NULL,'STRING')) as dim1_data_type,
   NVL(ec_calc_object_type.data_type(cv.object_id,cv.dim3_object_type_code),DECODE(cv.dim3_object_type_code,NULL,NULL,'STRING')) as dim2_data_type,
   NVL(ec_calc_object_type.data_type(cv.object_id,cv.dim4_object_type_code),DECODE(cv.dim4_object_type_code,NULL,NULL,'STRING')) as dim3_data_type,
   NVL(ec_calc_object_type.data_type(cv.object_id,cv.dim5_object_type_code),DECODE(cv.dim5_object_type_code,NULL,NULL,'STRING')) as dim4_data_type,
   ecdp_calc_mapping.getWriteDimAttributeName(cv.object_id,cv.calc_var_signature,cvw.calc_dataset,cvw.cls_name,1) as dim0_attribute_name,
   ecdp_calc_mapping.getWriteDimAttributeName(cv.object_id,cv.calc_var_signature,cvw.calc_dataset,cvw.cls_name,2) as dim1_attribute_name,
   ecdp_calc_mapping.getWriteDimAttributeName(cv.object_id,cv.calc_var_signature,cvw.calc_dataset,cvw.cls_name,3) as dim2_attribute_name,
   ecdp_calc_mapping.getWriteDimAttributeName(cv.object_id,cv.calc_var_signature,cvw.calc_dataset,cvw.cls_name,4) as dim3_attribute_name,
   ecdp_calc_mapping.getWriteDimAttributeName(cv.object_id,cv.calc_var_signature,cvw.calc_dataset,cvw.cls_name,5) as dim4_attribute_name,
   cvw.dim3_trigger_ind as dim2_set_by_trigger,
   cvw.dim4_trigger_ind as dim3_set_by_trigger,
   cvw.dim5_trigger_ind as dim4_set_by_trigger,
   'W' AS access_mode,
   DECODE(c.CLASS_TYPE,'INTERFACE','IV_','DATA','DV_','TABLE','TV_','SUB_CLASS','OSV_','OV_') || cvw.cls_name AS source_name,
   EcDp_Calc_Meta.getDateHandlingProperties(c.class_name) AS date_handling_props,
   '' as calc_date_handling,
   '' as valid_from_attr_name,
   '' as valid_to_attr_name,
   '' as prod_day_attr_name,
   '' as sub_daily_ind,
   NVL(cv.advanced_ind, 'N') as is_advanced,
   cvw.calc_dataset as datasets,
   ecdp_calc_mapping.getQualifierWriteDataType (cv.object_id,cv.calc_var_signature,cvw.calc_dataset,cvw.cls_name) as qualifier_data_type,
   ecdp_calc_mapping.getQualifierWriteAttributeName (cv.object_id,cv.calc_var_signature,cvw.calc_dataset,cvw.cls_name) as qualifier_attribute_name,
   ecdp_calc_mapping.getQualifierWriteParamName(cv.object_id,cv.calc_var_signature,cvw.calc_dataset,cvw.cls_name) as qualifier_param_name,
   cvw.always_insert_ind as always_insert,
   c.time_scope_code,
   cv.description,
   cv.record_status,
   cv.created_by,
   cv.created_date,
   cv.last_updated_by,
   cv.last_updated_date,
   cv.rev_no,
   cv.rev_text
  from calc_variable cv, calc_var_write_mapping cvw, class  c
  where cvw.cls_name = c.class_name
  and cv.object_id = cvw.object_id
  and cv.calc_var_signature = cvw.calc_var_signature
  and cv.active_ind = 'Y'
  and EcDp_Calc_Mapping.keyWriteMappingsSupportedByOE(cvw.object_id, cvw.calc_var_signature, cvw.calc_dataset, cvw.cls_name)='Y'
)