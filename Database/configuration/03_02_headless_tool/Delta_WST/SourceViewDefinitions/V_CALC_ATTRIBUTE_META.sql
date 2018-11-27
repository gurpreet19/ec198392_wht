CREATE OR REPLACE FORCE EDITIONABLE VIEW "V_CALC_ATTRIBUTE_META" ("CLASS_OBJECT_TYPE", "CLASS_NAME", "SQL_SYNTAX", "OBJECT_TYPE", "DATA_TYPE", "NAME", "IS_KEY", "IS_CALC_TYPE", "IS_SEQ_NO", "FILTER", "CALC_CONTEXT_ID", "RECORD_STATUS", "CREATED_BY", "CREATED_DATE", "LAST_UPDATED_BY", "LAST_UPDATED_DATE", "REV_NO", "REV_TEXT") AS 
  (
------------------------------------------------------------------------------------
--  v_calc_attribute_meta
--
--  $Revision: 1.16 $
--
--  Purpose:   Used by the calculation engine to determine which attributes
--             are available and how they are persisted in the database.
--             Also used by the "Node type editor" client to show the user a
--             list of available attributes.
--
--  Add owner_object_type for attributes
--  Join context into attribute table
--
--  When        Who  Why
--  ----------  ---  --------
--  2005-03-04  HUS  Initial version
-------------------------------------------------------------------------------------
select
   cdm.object_type_code as class_object_type,
   cdm.impl_class_name as class_name,
   cdm.sql_syntax,
   coa.value_object_type_code as object_type,
   decode(ca.data_type, 'INTEGER','NUMBER',null, 'STRING',ca.data_type) as data_type,
   cdm.name,
   decode(cdm.name,'Key','Y','N') AS is_key,
   cdm.is_calc_rule_code as is_calc_type,
   cdm.is_calc_rule_seq as is_seq_no,
   decode(cof.calc_obj_attr_filter, null, cof.parameter_filter, decode(cof.parameter_filter, null,cof.calc_obj_attr_filter,cof.calc_obj_attr_filter ||','|| cof.parameter_filter))  as filter,
   cdm.object_id as calc_context_id,
   cdm.RECORD_STATUS,
   cdm.CREATED_BY,
   cdm.CREATED_DATE,
   cdm.LAST_UPDATED_BY,
   cdm.LAST_UPDATED_DATE,
   cdm.REV_NO,
   cdm.REV_TEXT
from calc_obj_attr_db_mapping cdm, calc_object_attribute coa, calc_object_filter cof, class_attribute_cnfg ca
where cdm.object_id = coa.object_id (+)
and cdm.object_type_code = coa.object_type_code (+)
and cdm.name = coa.name (+)
and cdm.object_id = cof.object_id (+)
and cdm.object_type_code = cof.object_type_code (+)
and cdm.sql_syntax = cof.sql_syntax (+)
and cdm.impl_class_name = ca.class_name (+)
and cdm.sql_syntax = ca.attribute_name (+)
union all
select
   cof.object_type_code as class_object_type,
   cof.impl_class_name as class_name,
   cof.sql_syntax,
   '' as object_type,
   decode(ca.data_type,'INTEGER','NUMBER', null, 'STRING',ca.data_type) as data_type,
   cdm.name,
   decode(cdm.name,'Key','Y','N') AS is_key,
   cdm.is_calc_rule_code as is_calc_type,
   cdm.is_calc_rule_seq as is_seq_no,
   decode(cof.calc_obj_attr_filter, null, cof.parameter_filter, decode(cof.parameter_filter, null,cof.calc_obj_attr_filter,cof.calc_obj_attr_filter ||','|| cof.parameter_filter))  as filter,
   cof.object_id as calc_context_id,
   cdm.RECORD_STATUS,
   cdm.CREATED_BY,
   cdm.CREATED_DATE,
   cdm.LAST_UPDATED_BY,
   cdm.LAST_UPDATED_DATE,
   cdm.REV_NO,
   cdm.REV_TEXT
/*
from calc_object_filter cof, calc_obj_attr_db_mapping cdm, class_attribute ca
where cof.object_id = cdm.object_id (+)
and cof.object_type_code = cdm.object_type_code (+)
and cof.sql_syntax = cdm.sql_syntax (+)
and cdm.object_type_code is null
and cof.object_type_code = ca.class_name (+)
and cof.sql_syntax = ca.attribute_name (+)
*/
from ( calc_object_filter cof left join calc_obj_attr_db_mapping cdm
on (cof.object_id = cdm.object_id
and cof.object_type_code = cdm.object_type_code
and cof.sql_syntax = cdm.sql_syntax
))  left join class_attribute_cnfg ca on
(cof.impl_class_name = ca.class_name
and  cof.sql_syntax = ca.attribute_name )
where cdm.object_type_code is null
)