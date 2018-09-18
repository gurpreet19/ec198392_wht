CREATE OR REPLACE FORCE VIEW "DAO_META" ("CLASS_NAME", "SOURCE_NAME", "PROPERTY_NAME", "ALIAS_PROPERTY", "REL_CLASS_NAME", "ROLE_NAME", "ACCESS_CONTROL_METHOD", "ACCESS_CONTROL_IND", "DATA_TYPE", "IS_KEY", "IS_MANDATORY", "IS_REPORT_ONLY", "DB_MAPPING_TYPE", "DB_SQL_SYNTAX", "ATTRIBUTES", "PRESENTATION", "DATE_HANDELING", "IS_POPUP", "IS_RELATION", "IS_RELATION_CODE", "IS_READ_ONLY", "GROUP_TYPE", "SORT_ORDER") AS 
  (
-- select to get object_start_date/object_end_date
SELECT
		ca.class_name class_name,
		decode(c.class_type,'INTERFACE','IV_','DATA','DV_','TABLE','TV_','REPORT','RV_','SUB_CLASS','OSV_','OV_') || ca.class_name source_name,
		ca.attribute_name property_name,
		null alias_property,
		NULL rel_class_name,
		NULL role_name,
		NULL access_control_method,
		NVL(c.access_control_ind,'N') AS access_control_ind,
		ca.data_type data_type,
		ca.is_key,
		ca.is_mandatory,
		ca.report_only_ind is_report_only,
		'COLUMN' db_mapping_type,
		DECODE(ca.attribute_name,'OBJECT_START_DATE','START_DATE','END_DATE') db_sql_syntax,
		'dataunit=' || ecdp_unit.getunitfromlogical(nvl(cap.uom_code,'')) || decode(cap.uom_code, null, '', ';viewlabeluom=' || ecdp_unit.GetUnitLabel(ecdp_unit.getunitfromlogical(nvl(cap.uom_code,'')))) || ';viewlabel=' || nvl(cap.label,'') || ';datarequired=' || decode(nvl(ca.is_mandatory,'N'),'Y','true','false') || decode(ecdp_classmeta.getclassattributedbmappingtype(ca.class_name, ca.attribute_name), 'FUNCTION', ';vieweditable=false', '') || ';' ||EcDp_Unit.GetViewFormatMask(cap.uom_code,cap.static_presentation_syntax) || cap.static_presentation_syntax attributes,
		cap.presentation_syntax presentation,
		ecdp_classMeta.getClassDateHandeling(c.class_name,c.class_type) date_handeling,
		'N' is_popup,
		'N' is_relation,
		'N' is_relation_code,
		'N' is_read_only,
		NULL group_type,
		cap.sort_order
FROM class_attribute ca, class_attr_presentation cap, class c
WHERE c.class_name = ca.class_name
	AND cap.class_name (+) = ca.class_name
	AND cap.attribute_name (+)= ca.attribute_name
	AND Nvl(ca.disabled_ind,'N') = 'N'
	AND ca.attribute_name IN ('OBJECT_START_DATE','OBJECT_END_DATE')
UNION ALL
-- select to get object_code for data classes
SELECT
	c.class_name class_name,
	decode(c.class_type,'INTERFACE','IV_','DATA','DV_','TABLE','TV_','REPORT','RV_','SUB_CLASS','OSV_','OV_') || c.class_name source_name,
	'OBJECT_CODE' property_name,
	null alias_property,
	NULL rel_class_name,
	NULL role_name,
	NULL access_control_method,
	NVL(c.access_control_ind,'N') AS access_control_ind,
	'STRING' data_type,
	'N'  is_key,
	'N' is_mandatory,
	'N' is_report_only,
	NULL db_mapping_type,
	NULL db_sql_syntax,
	'viewhidden=true;datarequired=false;' attributes,
	'' presentation,
	ecdp_classMeta.getClassDateHandeling(c.class_name,c.class_type) date_handeling,
	'N' is_popup,
	'N' is_relation,
	'N' is_relation_code,
	'N' is_read_only,
	NULL group_type,
	9999 sort_order
FROM class c
WHERE c.class_type = 'DATA'
AND c.owner_class_name is not null
UNION ALL
-- select to get class name on interfaces
SELECT
	c.class_name class_name,
	decode(c.class_type,'INTERFACE','IV_','DATA','DV_','TABLE','TV_','REPORT','RV_','SUB_CLASS','OSV_','OV_') || c.class_name source_name,
	'CLASS_NAME' property_name,
	null alias_property,
	NULL rel_class_name,
	NULL role_name,
	NULL access_control_method,
	NVL(c.access_control_ind,'N') AS access_control_ind,
	'STRING' data_type,
	'N'  is_key,
	'N' is_mandatory,
	'N' is_report_only,
	NULL db_mapping_type,
	NULL db_sql_syntax,
	'viewlabel=Class Name;' attributes,
	'' presentation,
	ecdp_classMeta.getClassDateHandeling(c.class_name,c.class_type) date_handeling,
	'N' is_popup,
	'N' is_relation,
	'N' is_relation_code,
	'N' is_read_only,
	NULL group_type,
	1 sort_order
FROM class c
WHERE c.class_type = 'INTERFACE'
UNION ALL
-- select to get all other attributes on class
SELECT
	cm.class_name class_name,
	decode(c.class_type,'INTERFACE','IV_','DATA','DV_','TABLE','TV_','REPORT','RV_','SUB_CLASS','OSV_','OV_') || ca.class_name source_name,
	cm.attribute_name property_name,
	null alias_property,
	NULL rel_class_name,
	NULL role_name,
	NULL access_control_method,
	NVL(c.access_control_ind,'N') AS access_control_ind,
	ca.data_type data_type,
	ca.is_key,
	ca.is_mandatory,
	ca.report_only_ind is_report_only,
	cm.db_mapping_type,
	cm.db_sql_syntax,
	'dataunit=' || ecdp_unit.getunitfromlogical(nvl(cap.uom_code,'')) || decode(INSTR(cap.static_presentation_syntax,'viewunit'),0,decode(cap.uom_code, null, '', ';viewlabeluom=' || ecdp_unit.GetUnitLabel(ecdp_unit.getviewunitfromlogical(nvl(cap.uom_code,''))) || ';viewunit=' || ecdp_unit.getviewunitfromlogical(nvl(cap.uom_code,''))),'') || ';viewlabel=' || nvl(cap.label,'') || ';datarequired=' || decode(nvl(ca.is_mandatory,'N'),'Y','true','false') || decode(nvl(cap.db_pres_syntax, 'N'), 'N', '', ';viewhidden=true') || decode(ecdp_classmeta.getclassattributedbmappingtype(ca.class_name, ca.attribute_name), 'FUNCTION', ';vieweditable=false', '') || ';' || EcDp_Unit.GetViewFormatMask(cap.uom_code,cap.static_presentation_syntax) || cap.static_presentation_syntax attributes,
	cap.presentation_syntax presentation,
	ecdp_classMeta.getClassDateHandeling(c.class_name,c.class_type) date_handeling,
	'N' is_popup,
	'N' is_relation,
	'N' is_relation_code,
	'N' is_read_only,
	NULL group_type,
	cap.sort_order
FROM class_attribute ca, class_attr_db_mapping cm, class_attr_presentation cap, class c
WHERE c.class_name = cm.class_name
	AND cm.class_name = ca.class_name
	AND cap.class_name (+) = ca.class_name
	AND cap.attribute_name (+)= ca.attribute_name
	AND cm.attribute_name = ca.attribute_name
	AND Nvl(ca.disabled_ind,'N') = 'N'
	AND ca.attribute_name NOT IN ('OBJECT_START_DATE','OBJECT_END_DATE')
UNION ALL
-- select to get attribute alias/popup
SELECT
	cm.class_name class_name,
	decode(c.class_type,'INTERFACE','IV_','DATA','DV_','TABLE','TV_','REPORT','RV_','SUB_CLASS','OSV_','OV_') || ca.class_name source_name,
	cm.attribute_name||'_POPUP' property_name,
	cap.db_pres_syntax alias_property,
	NULL rel_class_name,
	NULL role_name,
  	NULL access_control_method,
  	NVL(c.access_control_ind,'N') AS access_control_ind,
	'STRING' data_type,
	'N' is_key,
	'N' is_mandatory,
	ca.report_only_ind is_report_only,
	NULL db_mapping_type,
	NULL db_sql_syntax,
	'dataunit=' || ecdp_unit.getunitfromlogical(nvl(cap.uom_code,'')) || decode(INSTR(cap.static_presentation_syntax,'viewunit'),0,decode(cap.uom_code, null, '', ';viewlabeluom=' || ecdp_unit.GetUnitLabel(ecdp_unit.getviewunitfromlogical(nvl(cap.uom_code,''))) || ';viewunit=' || ecdp_unit.getviewunitfromlogical(nvl(cap.uom_code,''))),'') || ';viewlabel=' || nvl(cap.label,'') || ';datarequired=' || decode(nvl(ca.is_mandatory,'N'),'Y','true','false') || decode(ecdp_classmeta.getclassattributedbmappingtype(ca.class_name, ca.attribute_name), 'FUNCTION', ';vieweditable=false', '') || ';' || EcDp_Unit.GetViewFormatMask(cap.uom_code,cap.static_presentation_syntax) || cap.static_presentation_syntax attributes,
	cap.presentation_syntax presentation,
	ecdp_classMeta.getClassDateHandeling(c.class_name,c.class_type) date_handeling,
	'Y' is_popup,
	'N' is_relation,
	'N' is_relation_code,
	'N' is_read_only,
	NULL group_type,
	cap.sort_order
FROM class_attribute ca, class_attr_db_mapping cm, class_attr_presentation cap, class c
WHERE c.class_name = cm.class_name
	AND cm.class_name = ca.class_name
	AND cap.class_name (+) = ca.class_name
	AND cap.attribute_name (+)= ca.attribute_name
	AND cm.attribute_name = ca.attribute_name
	AND Nvl(ca.disabled_ind,'N') = 'N'
	AND cap.db_pres_syntax is not null
UNION ALL
-- select to get releation
SELECT
	cm.to_class_name,
	decode(c.class_type,'INTERFACE','IV_','DATA','DV_','SUB_CLASS','OSV_','OV_') || cm.to_class_name source_name,
	cm.role_name || '_ID' attribute_name,
	null alias_property,
	cm.from_class_name rel_class_name,
	cm.role_name,
	cr.access_control_method,
	NVL(c.access_control_ind,'N') AS access_control_ind,
	'STRING' data_type,
	cr.is_key,
	cr.is_mandatory,
	cr.report_only_ind is_report_only,
	cm.db_mapping_type,
	cm.db_sql_syntax,
	'viewlabel='||p.label ||';' || 'datarequired=' ||  decode(nvl(cr.is_mandatory,'N'),'Y','true','false') || decode(nvl(p.db_pres_syntax, 'N'), 'N', '', ';viewhidden=true')||';' || p.static_presentation_syntax attributes,
	p.presentation_syntax presentation,
	ecdp_classMeta.getClassDateHandeling(c.class_name,c.class_type) date_handeling,
	'N' is_popup,
	'Y' is_relation,
	'N' is_relation_code,
	'N' is_read_only,
	cr.group_type,
	cm.sort_order sort_order
FROM class_relation cr, class_rel_db_mapping cm, class_rel_presentation p,  class c
WHERE c.class_name = cm.to_class_name
	AND cr.from_class_name = cm.from_class_name
	AND cr.to_class_name = cm.to_class_name
	AND cr.role_name = cm.role_name
	AND cr.from_class_name = p.from_class_name(+)
	AND cr.to_class_name = p.to_class_name(+)
	AND cr.role_name = p.role_name(+)
	AND multiplicity IN ('1:1', '1:N')
	AND Nvl(cr.disabled_ind,'N') = 'N'
	AND cr.group_type IS NULL
UNION ALL
-- get class relation alias
SELECT
	cm.to_class_name,
	decode(c.class_type,'INTERFACE','IV_','DATA','DV_','SUB_CLASS','OSV_','OV_') || cm.to_class_name source_name,
	cm.role_name || '_POPUP' attribute_name,
	p.db_pres_syntax alias_property,
	cm.from_class_name rel_class_name,
	cm.role_name,
	NULL access_control_method,
	NVL(c.access_control_ind,'N') AS access_control_ind,
	'STRING' data_type,
	'N' is_key, -- cr.is_key,
	cr.is_mandatory,
	cr.report_only_ind is_report_only,
	NULL db_mapping_type,
	NULL db_sql_syntax,
	'viewlabel='||p.label ||';' || 'datarequired=' ||  decode(nvl(cr.is_mandatory,'N'),'Y','true','false') ||';' || p.static_presentation_syntax attributes,
	p.presentation_syntax presentation,
	ecdp_classMeta.getClassDateHandeling(c.class_name,c.class_type) date_handeling,
	'Y' is_popup,
	'Y' is_relation,
	'N' is_relation_code,
	'N' is_read_only,
	cr.group_type,
	cm.sort_order sort_order
FROM class_relation cr, class_rel_db_mapping cm, class_rel_presentation p,  class c
WHERE c.class_name = cm.to_class_name
	AND cr.from_class_name = cm.from_class_name
	AND cr.to_class_name = cm.to_class_name
	AND cr.role_name = cm.role_name
	AND cr.from_class_name = p.from_class_name
	AND cr.to_class_name = p.to_class_name
	AND cr.role_name = p.role_name
	AND multiplicity IN ('1:1', '1:N')
	AND p.db_pres_syntax IS not null
	AND Nvl(cr.disabled_ind,'N') = 'N'
	AND cr.group_type IS NULL
UNION ALL
-- get class relation CODE property
SELECT
	cm.to_class_name,
	decode(c.class_type,'INTERFACE','IV_','DATA','DV_','SUB_CLASS','OSV_','OV_') || cm.to_class_name source_name,
	cm.role_name || '_CODE' attribute_name,
	'' alias_property,
	cm.from_class_name rel_class_name,
	cm.role_name,
	NULL access_control_method,
	NVL(c.access_control_ind,'N') AS access_control_ind,
	'STRING' data_type,
	'N' is_key, -- cr.is_key,
	cr.is_mandatory,
	cr.report_only_ind is_report_only,
	NULL db_mapping_type,
	NULL db_sql_syntax,
	'viewhidden=true' attributes,
	'' presentation,
	ecdp_classMeta.getClassDateHandeling(c.class_name,c.class_type) date_handeling,
	'N' is_popup,
	'Y' is_relation,
	'Y' is_relation_code,
	'N' is_read_only,
	cr.group_type,
	cm.sort_order sort_order
FROM class_relation cr, class_rel_db_mapping cm, class_rel_presentation p,  class c
WHERE c.class_name = cm.to_class_name
	AND cr.from_class_name = cm.from_class_name
	AND cr.to_class_name = cm.to_class_name
	AND cr.role_name = cm.role_name
	AND cr.from_class_name = p.from_class_name(+)
	AND cr.to_class_name = p.to_class_name(+)
	AND cr.role_name = p.role_name(+)
	AND multiplicity IN ('1:1', '1:N')
	AND Nvl(cr.disabled_ind,'N') = 'N'
	AND cr.group_type IS NULL
UNION ALL
-- get group relation ID
SELECT
	gl.class_name,
	ecdp_classmeta.getClassViewName(gl.class_name) source_name,
	cm.role_name || '_ID' attribute_name,
	null alias_property,
	cm.from_class_name rel_class_name,
	cm.role_name,
  	DECODE(gl.to_class_name,gl.class_name,cr.access_control_method,NULL) access_control_method,
  	NVL(c.access_control_ind,'N') AS access_control_ind,
	'STRING' data_type,
	cr.is_key,
	cr.is_mandatory,
	cr.report_only_ind is_report_only,
	cm.db_mapping_type,
	cm.db_sql_syntax,
	';viewlabel='||p.label ||';' || 'datarequired=' ||  decode(nvl(cr.is_mandatory,'N'),'Y','true','false') || decode(nvl(p.db_pres_syntax, 'N'), 'N', '', ';viewhidden=true')||';' || p.static_presentation_syntax attributes,
	p.presentation_syntax presentation,
	'OBJECT' date_handeling,
	'N' is_popup,
	'Y' is_relation,
	'N' is_relation_code,
	DECODE(EcDp_ClassMeta.IsParentRelation(gl.class_name,cm.from_class_name,cm.role_name),'Y','N','N','Y') is_read_only,
	cr.group_type,
	cm.sort_order sort_order
FROM class_relation cr,  class_rel_db_mapping cm, class_rel_presentation p, v_group_level gl, class c
WHERE  cr.from_class_name = cm.from_class_name
	AND cr.to_class_name = cm.to_class_name
	AND cr.role_name = cm.role_name
	AND cr.from_class_name = p.from_class_name(+)
	AND cr.to_class_name = p.to_class_name(+)
	AND cr.role_name = p.role_name(+)
	AND cr.from_class_name = gl.from_class_name
   AND cr.to_class_name = gl.to_class_name
   AND cr.role_name = gl.role_name
	AND cr.multiplicity IN ('1:1', '1:N')
   AND cr.group_type IS NOT NULL
   AND Nvl(cr.disabled_ind,'N') = 'N'
   AND gl.to_class_name = (SELECT min(to_class_name) -- If several ancestors point to the same object, select one
                          FROM v_group_level
                          WHERE class_name = gl.class_name
                          AND from_class_name = gl.from_class_name
                          AND role_name = gl.role_name)
   AND c.class_name=gl.class_name
UNION ALL
-- get group relation POPUP
SELECT
	gl.class_name class_name,
	ecdp_classmeta.getClassViewName(gl.class_name) source_name,
	cm.role_name || '_POPUP' attribute_name,
	p.db_pres_syntax alias_property,
	cm.from_class_name rel_class_name,
	cm.role_name,
  	NULL access_control_method,
  	NVL(c.access_control_ind,'N') AS access_control_ind,
	'STRING' data_type,
	cr.is_key,
	cr.is_mandatory,
	cr.report_only_ind is_report_only,
	NULL db_mapping_type,
	NULL db_sql_syntax,
	';viewlabel='||p.label ||';' || 'datarequired=' ||  decode(nvl(cr.is_mandatory,'N'),'Y','true','false') ||';' || ecdp_classmeta.getGroupModelDepPopupPres(cr.to_class_name, cr.from_class_name, cr.role_name) attributes,
	p.presentation_syntax presentation,
	'OBJECT' date_handeling,
	'Y' is_popup,
	'Y' is_relation,
	'N' is_relation_code,
	DECODE(EcDp_ClassMeta.IsParentRelation(gl.class_name,cm.from_class_name,cm.role_name),'Y','N','N','Y') is_read_only,
	cr.group_type,
	ecdp_classmeta.getGroupModelDepPopupSortOrder(cr.to_class_name, cr.from_class_name, cr.role_name) AS sort_order
FROM class_relation cr,  class_rel_db_mapping cm, class_rel_presentation p, v_group_level gl, class c
WHERE  cr.from_class_name = cm.from_class_name
	AND cr.to_class_name = cm.to_class_name
	AND cr.role_name = cm.role_name
	AND cr.from_class_name = p.from_class_name
	AND cr.to_class_name = p.to_class_name
	AND cr.role_name = p.role_name
	AND cr.from_class_name = gl.from_class_name
   AND cr.to_class_name = gl.to_class_name
   AND cr.role_name = gl.role_name
	AND cr.multiplicity IN ('1:1', '1:N')
   AND cr.group_type IS NOT NULL
   AND p.db_pres_syntax IS NOT NULL
   AND Nvl(cr.disabled_ind,'N') = 'N'
   AND gl.to_class_name = (SELECT min(to_class_name) -- If several ancestors point to the same object, select one
                          FROM v_group_level
                          WHERE class_name = gl.class_name
                          AND from_class_name = gl.from_class_name
                          AND role_name = gl.role_name)
   AND c.class_name=gl.class_name
UNION ALL
-- get group relation CODE
SELECT
	gl.class_name class_name,
	ecdp_classmeta.getClassViewName(gl.class_name) source_name,
	cm.role_name || '_CODE' attribute_name,
	null alias_property,
	cm.from_class_name rel_class_name,
	cm.role_name,
  	NULL access_control_method,
  	NVL(c.access_control_ind,'N') AS access_control_ind,
	'STRING' data_type,
	cr.is_key,
	cr.is_mandatory,
	cr.report_only_ind is_report_only,
	cm.db_mapping_type,
	Replace(cm.db_sql_syntax,'_ID','_CODE') db_sql_syntax,
	'viewhidden=true' attributes,
	NULL presentation,
	'OBJECT' date_handeling,
	'N' is_popup,
	'Y' is_relation,
	'Y' is_relation_code,
	DECODE(EcDp_ClassMeta.IsParentRelation(gl.class_name,cm.from_class_name,cm.role_name),'Y','N','N','Y') is_read_only,
	cr.group_type,
	cm.sort_order sort_order
FROM class_relation cr,  class_rel_db_mapping cm, class_rel_presentation p, v_group_level gl, class c
WHERE  cr.from_class_name = cm.from_class_name
	AND cr.to_class_name = cm.to_class_name
	AND cr.role_name = cm.role_name
	AND cr.from_class_name = p.from_class_name(+)
	AND cr.to_class_name = p.to_class_name(+)
	AND cr.role_name = p.role_name(+)
	AND cr.from_class_name = gl.from_class_name
   AND cr.to_class_name = gl.to_class_name
   AND cr.role_name = gl.role_name
	AND cr.multiplicity IN ('1:1', '1:N')
   AND cr.group_type IS NOT NULL
   AND Nvl(cr.disabled_ind,'N') = 'N'
   AND gl.to_class_name = (SELECT min(to_class_name) -- If several ancestors point to the same object, select one
                          FROM v_group_level
                          WHERE class_name = gl.class_name
                          AND from_class_name = gl.from_class_name
                          AND role_name = gl.role_name)
   AND c.class_name=gl.class_name
)