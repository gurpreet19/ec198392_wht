CREATE OR REPLACE FORCE EDITIONABLE VIEW "V_DAO_META" ("SECTION", "CLASS_NAME", "SOURCE_NAME", "PROPERTY_NAME", "ALIAS_PROPERTY", "REL_CLASS_NAME", "ROLE_NAME", "ACCESS_CONTROL_METHOD", "ACCESS_CONTROL_IND", "DATA_TYPE", "IS_KEY", "IS_MANDATORY", "IS_REPORT_ONLY", "DB_MAPPING_TYPE", "DB_SQL_SYNTAX", "DATE_HANDELING", "IS_POPUP", "IS_RELATION", "IS_RELATION_CODE", "IS_READ_ONLY", "VIEWHIDDEN", "GROUP_TYPE", "SORT_ORDER", "REFERENCE_TYPE", "REFERENCE_KEY", "REFERENCE_VALUE") AS 
  SELECT
    1 AS section,
    ca.class_name class_name,
    decode(c.class_type,'INTERFACE','IV_','DATA','DV_','TABLE','TV_','REPORT','RV_','SUB_CLASS','OSV_','OV_') || ca.class_name source_name,
    ca.attribute_name property_name,
    null alias_property,
    NULL rel_class_name,
    NULL role_name,
    NULL access_control_method,
    Ecdp_Classmeta_Cnfg.getAccessControlInd(c.class_name) AS access_control_ind,
    ca.data_type data_type,
    ca.is_key,
    Ecdp_Classmeta_Cnfg.isMandatory(ca.class_name, ca.attribute_name) is_mandatory,
    Ecdp_Classmeta_Cnfg.isReportOnly(ca.class_name, ca.attribute_name) is_report_only,
    'COLUMN' db_mapping_type,
    DECODE(ca.attribute_name,'OBJECT_START_DATE','START_DATE','END_DATE') db_sql_syntax,
    ecdp_classMeta.getClassDateHandeling(c.class_name,c.class_type) date_handeling,
    'N' is_popup,
    'N' is_relation,
    'N' is_relation_code,
    'N' is_read_only,
    ecdp_classMeta_cnfg.getMaxStaticPresProperty(ca.class_name, ca.attribute_name, 'viewhidden') viewhidden,
    NULL group_type,
    EcDp_ClassMeta_Cnfg.getScreenSortOrder(ca.class_name, ca.attribute_name) sort_order,
	ca.reference_type,
	ca.reference_key,
	ca.reference_value
FROM class_attribute_cnfg ca, class_cnfg c
WHERE c.class_name = ca.class_name
  AND Ecdp_Classmeta_Cnfg.isDisabled(ca.class_name, ca.attribute_name) = 'N'
  AND ca.attribute_name IN ('OBJECT_START_DATE','OBJECT_END_DATE')
UNION ALL
-- select to get object_code for data classes
SELECT
  2 AS section,
  c.class_name class_name,
  decode(c.class_type,'INTERFACE','IV_','DATA','DV_','TABLE','TV_','REPORT','RV_','SUB_CLASS','OSV_','OV_') || c.class_name source_name,
  'OBJECT_CODE' property_name,
  null alias_property,
  NULL rel_class_name,
  NULL role_name,
  NULL access_control_method,
  Ecdp_Classmeta_Cnfg.getAccessControlInd(c.class_name) AS access_control_ind,
  'STRING' data_type,
  'N' is_key,
  'N' is_mandatory,
  'N' is_report_only,
  NULL db_mapping_type,
  NULL db_sql_syntax,
  ecdp_classMeta.getClassDateHandeling(c.class_name,c.class_type) date_handeling,
  'N' is_popup,
  'N' is_relation,
  'N' is_relation_code,
  'N' is_read_only,
  'true' viewhidden,
  NULL group_type,
  9999 sort_order,
  null AS reference_type,
  null AS reference_key,
  null AS reference_value
FROM class_cnfg c
WHERE c.class_type = 'DATA'
AND c.owner_class_name is not null
AND NOT EXISTS (SELECT 1 FROM class_attribute_cnfg WHERE class_name = c.class_name AND attribute_name = 'OBJECT_CODE')
UNION ALL
-- select to get class name on interfaces
SELECT
  3 AS section,
  c.class_name class_name,
  decode(c.class_type,'INTERFACE','IV_','DATA','DV_','TABLE','TV_','REPORT','RV_','SUB_CLASS','OSV_','OV_') || c.class_name source_name,
  'CLASS_NAME' property_name,
  null alias_property,
  NULL rel_class_name,
  NULL role_name,
  NULL access_control_method,
  Ecdp_Classmeta_Cnfg.getAccessControlInd(c.class_name) AS access_control_ind,
  'STRING' data_type,
  'N' is_key,
  'N' is_mandatory,
  'N' is_report_only,
  NULL db_mapping_type,
  NULL db_sql_syntax,
  ecdp_classMeta.getClassDateHandeling(c.class_name,c.class_type) date_handeling,
  'N' is_popup,
  'N' is_relation,
  'N' is_relation_code,
  'N' is_read_only,
  NULL viewhidden,
  NULL group_type,
  1 sort_order,
  null AS reference_type,
  null AS reference_key,
  null AS reference_value
FROM class_cnfg c
WHERE c.class_type = 'INTERFACE'
UNION ALL
-- select to get all other attributes on class
SELECT
  4 AS section,
  ca.class_name class_name,
  decode(c.class_type,'INTERFACE','IV_','DATA','DV_','TABLE','TV_','REPORT','RV_','SUB_CLASS','OSV_','OV_') || ca.class_name source_name,
  ca.attribute_name property_name,
  null alias_property,
  NULL rel_class_name,
  NULL role_name,
  NULL access_control_method,
  Ecdp_Classmeta_Cnfg.getAccessControlInd(c.class_name) AS access_control_ind,
  ca.data_type data_type,
  ca.is_key,
  Ecdp_Classmeta_Cnfg.isMandatory(ca.class_name, ca.attribute_name) is_mandatory,
  Ecdp_Classmeta_Cnfg.isReportOnly(ca.class_name, ca.attribute_name) is_report_only,
  ca.db_mapping_type,
  ca.db_sql_syntax,
  ecdp_classMeta.getClassDateHandeling(c.class_name,c.class_type) date_handeling,
  'N' is_popup,
  'N' is_relation,
  'N' is_relation_code,
  Ecdp_Classmeta_Cnfg.isReadOnly(ca.class_name, ca.attribute_name) is_read_only,
  ecdp_classMeta_cnfg.getMaxStaticPresProperty(ca.class_name, ca.attribute_name, 'viewhidden') viewhidden,
  NULL group_type,
  EcDp_ClassMeta_Cnfg.getScreenSortOrder(ca.class_name, ca.attribute_name) sort_order,
  ca.reference_type,
  ca.reference_key,
  ca.reference_value
FROM class_attribute_cnfg ca, class_cnfg c
WHERE c.class_name = ca.class_name
  AND Ecdp_Classmeta_Cnfg.isDisabled(ca.class_name, ca.attribute_name) = 'N'
  AND ca.attribute_name NOT IN ('OBJECT_START_DATE','OBJECT_END_DATE')
UNION ALL
-- select to get attribute alias/popup
SELECT
  5 AS section,
  ca.class_name class_name,
  decode(c.class_type,'INTERFACE','IV_','DATA','DV_','TABLE','TV_','REPORT','RV_','SUB_CLASS','OSV_','OV_') || ca.class_name source_name,
  ca.attribute_name||'_POPUP' property_name,
  EcDp_ClassMeta_Cnfg.getDbPresSyntax(ca.class_name, ca.attribute_name) alias_property,
  NULL rel_class_name,
  NULL role_name,
    NULL access_control_method,
  Ecdp_Classmeta_Cnfg.getAccessControlInd(c.class_name) AS access_control_ind,
  'STRING' data_type,
  'N' is_key,
  'N' is_mandatory,
  Ecdp_Classmeta_Cnfg.isReportOnly(ca.class_name, ca.attribute_name) is_report_only,
  NULL db_mapping_type,
  NULL db_sql_syntax,
  ecdp_classMeta.getClassDateHandeling(c.class_name,c.class_type) date_handeling,
  'Y' is_popup,
  'N' is_relation,
  'N' is_relation_code,
  'N' is_read_only,
  ecdp_classMeta_cnfg.getMaxStaticPresProperty(ca.class_name, ca.attribute_name, 'viewhidden') viewhidden,
  NULL group_type,
  EcDp_ClassMeta_Cnfg.getScreenSortOrder(ca.class_name, ca.attribute_name) sort_order,
  ca.reference_type,
  ca.reference_key,
  ca.reference_value
 FROM class_attribute_cnfg ca, class_cnfg c
WHERE c.class_name = ca.class_name
  AND Ecdp_Classmeta_Cnfg.isDisabled(ca.class_name, ca.attribute_name) = 'N'
  AND EcDp_ClassMeta_Cnfg.getDbPresSyntax(ca.class_name, ca.attribute_name) IS NOT NULL
UNION ALL
-- select to get releation
SELECT
  6 AS section,
  cr.to_class_name class_name,
  decode(c.class_type,'INTERFACE','IV_','DATA','DV_','SUB_CLASS','OSV_','OV_') || cr.to_class_name source_name,
  cr.role_name || '_ID' property_name,
  null alias_property,
  cr.from_class_name rel_class_name,
  cr.role_name,
  Ecdp_Classmeta_Cnfg.getAccessControlMethod(cr.from_class_name, cr.to_class_name, cr.role_name) AS access_control_method,
  Ecdp_Classmeta_Cnfg.getAccessControlInd(c.class_name) AS access_control_ind,
  'STRING' data_type,
  cr.is_key,
  Ecdp_Classmeta_Cnfg.isMandatory(cr.from_class_name, cr.to_class_name, cr.role_name) is_mandatory,
  Ecdp_Classmeta_Cnfg.isReportOnly(cr.from_class_name, cr.to_class_name, cr.role_name) is_report_only,
  cr.db_mapping_type,
  cr.db_sql_syntax,
  ecdp_classMeta.getClassDateHandeling(c.class_name,c.class_type) date_handeling,
  'N' is_popup,
  'Y' is_relation,
  'N' is_relation_code,
  'N' is_read_only,
  ecdp_classMeta_cnfg.getMaxStaticPresProperty(cr.from_class_name, cr.to_class_name, cr.role_name, 'viewhidden') viewhidden,
  cr.group_type,
  Ecdp_Classmeta_Cnfg.getDbSortOrder(cr.from_class_name, cr.to_class_name, cr.role_name) sort_order,
  null AS reference_type,
  null AS reference_key,
  null AS reference_value
FROM class_relation_cnfg cr, class_cnfg c
WHERE c.class_name = cr.to_class_name
  AND cr.multiplicity IN ('1:1', '1:N')
  AND Ecdp_Classmeta_Cnfg.isDisabled(cr.from_class_name, cr.to_class_name, cr.role_name) = 'N'
  AND cr.group_type IS NULL
UNION ALL
-- get class relation alias
SELECT
  7 AS section,
  cr.to_class_name class_name,
  decode(c.class_type,'INTERFACE','IV_','DATA','DV_','SUB_CLASS','OSV_','OV_') || cr.to_class_name source_name,
  cr.role_name || '_POPUP' property_name,
  Ecdp_Classmeta_Cnfg.getDbPresSyntax(cr.from_class_name, cr.to_class_name, cr.role_name) alias_property,
  cr.from_class_name rel_class_name,
  cr.role_name,
  NULL access_control_method,
  Ecdp_Classmeta_Cnfg.getAccessControlInd(c.class_name) AS access_control_ind,
  'STRING' data_type,
  'N' is_key, -- cr.is_key,
  Ecdp_Classmeta_Cnfg.isMandatory(cr.from_class_name, cr.to_class_name, cr.role_name) is_mandatory,
  Ecdp_Classmeta_Cnfg.isReportOnly(cr.from_class_name, cr.to_class_name, cr.role_name) is_report_only,
  NULL db_mapping_type,
  NULL db_sql_syntax,
  ecdp_classMeta.getClassDateHandeling(c.class_name,c.class_type) date_handeling,
  'Y' is_popup,
  'Y' is_relation,
  'N' is_relation_code,
  'N' is_read_only,
  ecdp_classMeta_cnfg.getMaxStaticPresProperty(cr.from_class_name, cr.to_class_name, cr.role_name, 'viewhidden') viewhidden,
  cr.group_type,
  Ecdp_Classmeta_Cnfg.getDbSortOrder(cr.from_class_name, cr.to_class_name, cr.role_name) sort_order,
  null AS reference_type,
  null AS reference_key,
  null AS reference_value
FROM class_relation_cnfg cr, class_cnfg c
WHERE c.class_name = cr.to_class_name
  AND multiplicity IN ('1:1', '1:N')
  AND Ecdp_Classmeta_Cnfg.getDbPresSyntax(cr.from_class_name, cr.to_class_name, cr.role_name) IS not null
  AND Ecdp_Classmeta_Cnfg.isDisabled(cr.from_class_name, cr.to_class_name, cr.role_name) = 'N'
  AND cr.group_type IS NULL
UNION ALL
-- get class relation CODE property
SELECT
  8 AS section,
  cr.to_class_name,
  decode(c.class_type,'INTERFACE','IV_','DATA','DV_','SUB_CLASS','OSV_','OV_') || cr.to_class_name source_name,
  cr.role_name || '_CODE' property_name,
  '' alias_property,
  cr.from_class_name rel_class_name,
  cr.role_name,
  NULL access_control_method,
  Ecdp_Classmeta_Cnfg.getAccessControlInd(c.class_name) AS access_control_ind,
  'STRING' data_type,
  'N' is_key,
  Ecdp_Classmeta_Cnfg.isMandatory(cr.from_class_name, cr.to_class_name, cr.role_name) is_mandatory,
  Ecdp_Classmeta_Cnfg.isReportOnly(cr.from_class_name, cr.to_class_name, cr.role_name) is_report_only,
  NULL db_mapping_type,
  NULL db_sql_syntax,
  ecdp_classMeta.getClassDateHandeling(c.class_name,c.class_type) date_handeling,
  'N' is_popup,
  'Y' is_relation,
  'Y' is_relation_code,
  'N' is_read_only,
  'true' viewhidden,
  cr.group_type,
  Ecdp_Classmeta_Cnfg.getDbSortOrder(cr.from_class_name, cr.to_class_name, cr.role_name) sort_order,
  null AS reference_type,
  null AS reference_key,
  null AS reference_value
FROM class_relation_cnfg cr, class_cnfg c
WHERE c.class_name = cr.to_class_name
  AND multiplicity IN ('1:1', '1:N')
  AND Ecdp_Classmeta_Cnfg.isDisabled(cr.from_class_name, cr.to_class_name, cr.role_name) = 'N'
  AND cr.group_type IS NULL
UNION ALL
-- get group relation ID
SELECT
  9 AS section,
  gl.class_name,
  ecdp_classmeta.getClassViewName(gl.class_name) source_name,
  cr.role_name || '_ID' property_name,
  null alias_property,
  cr.from_class_name rel_class_name,
  cr.role_name,
  DECODE(gl.to_class_name,gl.class_name,Ecdp_Classmeta_Cnfg.getAccessControlMethod(cr.from_class_name, cr.to_class_name, cr.role_name),NULL) access_control_method,
  Ecdp_Classmeta_Cnfg.getAccessControlInd(c.class_name) AS access_control_ind,
  'STRING' data_type,
  cr.is_key,
  Ecdp_Classmeta_Cnfg.isMandatory(cr.from_class_name, cr.to_class_name, cr.role_name) is_mandatory,
  Ecdp_Classmeta_Cnfg.isReportOnly(cr.from_class_name, cr.to_class_name, cr.role_name) is_report_only,
  cr.db_mapping_type,
  cr.db_sql_syntax,
  'OBJECT' date_handeling,
  'N' is_popup,
  'Y' is_relation,
  'N' is_relation_code,
  DECODE(EcDp_ClassMeta.IsParentRelation(gl.class_name,cr.from_class_name,cr.role_name),'Y','N','N','Y') is_read_only,
  ecdp_classMeta_cnfg.getMaxStaticPresProperty(cr.from_class_name, cr.to_class_name, cr.role_name, 'viewhidden') viewhidden,
  cr.group_type,
  Ecdp_Classmeta_Cnfg.getDbSortOrder(cr.from_class_name, cr.to_class_name, cr.role_name) sort_order,
  null AS reference_type,
  null AS reference_key,
  null AS reference_value
FROM class_relation_cnfg cr, v_group_level gl, class_cnfg c
WHERE  cr.from_class_name = gl.from_class_name
   AND cr.to_class_name = gl.to_class_name
   AND cr.role_name = gl.role_name
  AND cr.multiplicity IN ('1:1', '1:N')
   AND cr.group_type IS NOT NULL
   AND Ecdp_Classmeta_Cnfg.isDisabled(cr.from_class_name, cr.to_class_name, cr.role_name) = 'N'
   AND gl.to_class_name = (SELECT min(to_class_name) -- If several ancestors point to the same object, select one
                          FROM v_group_level
                          WHERE class_name = gl.class_name
                          AND from_class_name = gl.from_class_name
                          AND role_name = gl.role_name)
   AND c.class_name=gl.class_name
UNION ALL
-- get group relation POPUP
SELECT
  10 AS section,
  gl.class_name class_name,
  ecdp_classmeta.getClassViewName(gl.class_name) source_name,
  cr.role_name || '_POPUP' property_name,
  Ecdp_Classmeta_Cnfg.getDbPresSyntax(cr.from_class_name, cr.to_class_name, cr.role_name) alias_property,
  cr.from_class_name rel_class_name,
  cr.role_name,
  NULL access_control_method,
  Ecdp_Classmeta_Cnfg.getAccessControlInd(c.class_name) AS access_control_ind,
  'STRING' data_type,
  cr.is_key,
  Ecdp_Classmeta_Cnfg.isMandatory(cr.from_class_name, cr.to_class_name, cr.role_name) is_mandatory,
  Ecdp_Classmeta_Cnfg.isReportOnly(cr.from_class_name, cr.to_class_name, cr.role_name) is_report_only,
  NULL db_mapping_type,
  NULL db_sql_syntax,
  'OBJECT' date_handeling,
  'Y' is_popup,
  'Y' is_relation,
  'N' is_relation_code,
  DECODE(EcDp_ClassMeta.IsParentRelation(gl.class_name,cr.from_class_name,cr.role_name),'Y','N','N','Y') is_read_only,
  NULL viewhidden,
  cr.group_type,
  ecdp_classmeta.getGroupModelDepPopupSortOrder(cr.to_class_name, cr.from_class_name, cr.role_name) AS sort_order,
  null AS reference_type,
  null AS reference_key,
  null AS reference_value
FROM class_relation_cnfg cr, v_group_level gl, class_cnfg c
WHERE cr.from_class_name = gl.from_class_name
   AND cr.to_class_name = gl.to_class_name
   AND cr.role_name = gl.role_name
  AND cr.multiplicity IN ('1:1', '1:N')
   AND cr.group_type IS NOT NULL
   AND Ecdp_Classmeta_Cnfg.getDbPresSyntax(cr.from_class_name, cr.to_class_name, cr.role_name) IS NOT NULL
   AND Ecdp_Classmeta_Cnfg.isDisabled(cr.from_class_name, cr.to_class_name, cr.role_name) = 'N'
   AND gl.to_class_name = (SELECT min(to_class_name) -- If several ancestors point to the same object, select one
                          FROM v_group_level
                          WHERE class_name = gl.class_name
                          AND from_class_name = gl.from_class_name
                          AND role_name = gl.role_name)
   AND c.class_name=gl.class_name
UNION ALL
-- get group relation CODE
SELECT
  11 AS section,
  gl.class_name class_name,
  ecdp_classmeta.getClassViewName(gl.class_name) source_name,
  cr.role_name || '_CODE' property_name,
  null alias_property,
  cr.from_class_name rel_class_name,
  cr.role_name,
  NULL access_control_method,
  Ecdp_Classmeta_Cnfg.getAccessControlInd(c.class_name) AS access_control_ind,
  'STRING' data_type,
  cr.is_key,
  Ecdp_Classmeta_Cnfg.isMandatory(cr.from_class_name, cr.to_class_name, cr.role_name) is_mandatory,
  Ecdp_Classmeta_Cnfg.isReportOnly(cr.from_class_name, cr.to_class_name, cr.role_name) is_report_only,
  cr.db_mapping_type,
  Replace(cr.db_sql_syntax,'_ID','_CODE') db_sql_syntax,
  'OBJECT' date_handeling,
  'N' is_popup,
  'Y' is_relation,
  'Y' is_relation_code,
  DECODE(EcDp_ClassMeta.IsParentRelation(gl.class_name,cr.from_class_name,cr.role_name),'Y','N','N','Y') is_read_only,
  'true' viewhidden,
  cr.group_type,
  Ecdp_Classmeta_Cnfg.getDbSortOrder(cr.from_class_name, cr.to_class_name, cr.role_name) sort_order,
  null AS reference_type,
  null AS reference_key,
  null AS reference_value
FROM class_relation_cnfg cr, v_group_level gl, class_cnfg c
WHERE cr.from_class_name = gl.from_class_name
   AND cr.to_class_name = gl.to_class_name
   AND cr.role_name = gl.role_name
  AND cr.multiplicity IN ('1:1', '1:N')
   AND cr.group_type IS NOT NULL
   AND Ecdp_Classmeta_Cnfg.isDisabled(cr.from_class_name, cr.to_class_name, cr.role_name) = 'N'
   AND gl.to_class_name = (SELECT min(to_class_name) -- If several ancestors point to the same object, select one
                          FROM v_group_level
                          WHERE class_name = gl.class_name
                          AND from_class_name = gl.from_class_name
                          AND role_name = gl.role_name)
   AND c.class_name=gl.class_name