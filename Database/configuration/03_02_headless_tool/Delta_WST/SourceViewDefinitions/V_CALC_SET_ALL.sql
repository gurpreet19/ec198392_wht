CREATE OR REPLACE FORCE EDITIONABLE VIEW "V_CALC_SET_ALL" ("OBJECT_ID", "DAYTIME", "CALC_CONTEXT_ID", "CALC_SET_NAME", "CALC_SET_TYPE_CODE", "CALC_SET_TYPE_TEXT", "CALC_OBJECT_TYPE_CODE", "CALC_OBJECT_TYPE_NAME", "SCOPE_NAME", "INHERITED_FROM_ID", "INHERITED_FROM_NAME", "DESCRIPTION", "RECORD_STATUS", "CREATED_BY", "CREATED_DATE", "LAST_UPDATED_BY", "LAST_UPDATED_DATE", "REV_NO", "REV_TEXT") AS 
  (
----------------------------------------------------------------------------------------------------
--
-- Purpose  : All sets available for a caluclation, including sets inherited from parent calculations
--
----------------------------------------------------------------------------------------------------
-- 'global' pre-defined set
select c.object_id,
       c.daytime,
       ec_calculation.calc_context_id(c.object_id) calc_context_id,
       'global' as calc_set_name,
       '' as calc_set_type_code,
       '' as calc_set_type_text,
       '' as calc_object_type_code,
       '' as calc_object_type_name,
       'System' as scope_name,
       NULL as inherited_from_id,
       '' as inherited_from_name,
       'Global object used for global attributes' as description,
       NULL as RECORD_STATUS,
       NULL as CREATED_BY,
       NULL as CREATED_DATE,
       NULL as LAST_UPDATED_BY,
       NULL as LAST_UPDATED_DATE,
       NULL as REV_NO,
       NULL as REV_TEXT
from calculation_version c
UNION ALL
-- 'empty' pre-defined set
select c.object_id,
       c.daytime,
       ec_calculation.calc_context_id(c.object_id) calc_context_id,
       'empty' as calc_set_name,
       '' as calc_set_type_code,
       '' as calc_set_type_text,
       '' as calc_object_type_code,
       '' as calc_object_type_name,
       'System' as scope_name,
       NULL as inherited_from_id,
       '' as inherited_from_name,
       'Set without any elements' as description,
       NULL as RECORD_STATUS,
       NULL as CREATED_BY,
       NULL as CREATED_DATE,
       NULL as LAST_UPDATED_BY,
       NULL as LAST_UPDATED_DATE,
       NULL as REV_NO,
       NULL as REV_TEXT
from calculation_version c
UNION ALL
-- 'system' pre-defined set
select c.object_id,
       c.daytime,
       ec_calculation.calc_context_id(c.object_id) calc_context_id,
       'system' as calc_set_name,
       '' as calc_set_type_code,
       '' as calc_set_type_text,
       '' as calc_object_type_code,
       '' as calc_object_type_name,
       'System' as scope_name,
       NULL as inherited_from_id,
       '' as inherited_from_name,
       'System object used for system variables' as description,
       NULL as RECORD_STATUS,
       NULL as CREATED_BY,
       NULL as CREATED_DATE,
       NULL as LAST_UPDATED_BY,
       NULL as LAST_UPDATED_DATE,
       NULL as REV_NO,
       NULL as REV_TEXT
from calculation_version c
UNION ALL
-- 'objects' pre-defined set
select c.object_id,
       c.daytime,
       ec_calculation.calc_context_id(c.object_id) calc_context_id,
       'objects' as calc_set_name,
       '' as calc_set_type_code,
       '' as calc_set_type_text,
       '' as calc_object_type_code,
       '' as calc_object_type_name,
       'System' as scope_name,
       NULL as inherited_from_id,
       '' as inherited_from_name,
       'All objects' as description,
       NULL as RECORD_STATUS,
       NULL as CREATED_BY,
       NULL as CREATED_DATE,
       NULL as LAST_UPDATED_BY,
       NULL as LAST_UPDATED_DATE,
       NULL as REV_NO,
       NULL as REV_TEXT
from calculation_version c
UNION ALL
-- Local sets
select s.object_id,
       s.daytime,
       s.calc_context_id,
       s.calc_set_name,
       s.calc_set_type as calc_set_type_code,
       ec_prosty_codes.code_text(s.calc_set_type,'CALC_SET_TYPE') as calc_set_type_text,
       s.calc_object_type_code,
       NVL(ec_calc_object_type.label_override(s.calc_context_id, s.calc_object_type_code), Nvl(EcDp_ClassMeta_Cnfg.getLabel(s.calc_object_type_code),s.calc_object_type_code)) calc_object_type_name,
       'Local' as scope_name,
       NULL as inherited_from_id,
       '' as inherited_from_name,
       nvl(s.description_override,Ecdp_Calc_Mapping.getSetDescription(s.CALC_CONTEXT_ID,s.OBJECT_ID,s.CALC_SET_NAME,s.CALC_OBJECT_TYPE_CODE,s.CALC_SET_TYPE,s.BASE_CALC_SET_NAME,s.SORT_ORDER,s.SORT_BY_SQL_SYNTAX,s.DESCRIPTION_OVERRIDE,s.SET_OPERATOR,s.DAYTIME)) as description,
       s.RECORD_STATUS,
       s.CREATED_BY,
       s.CREATED_DATE,
       s.LAST_UPDATED_BY,
       s.LAST_UPDATED_DATE,
       s.REV_NO,
       s.REV_TEXT
from calc_set s
where s.calc_set_type<>'LIBRARY_INHERITED'
UNION ALL
-- Sets inherited from library interface/caller
select s.object_id,
       s.daytime,
       s.calc_context_id,
       s.calc_set_name,
       s.calc_set_type as calc_set_type_code,
       ec_prosty_codes.code_text(s.calc_set_type,'CALC_SET_TYPE') as calc_set_type_text,
       s.calc_object_type_code,
       NVL(ec_calc_object_type.label_override(s.calc_context_id, s.calc_object_type_code), Nvl(EcDp_ClassMeta_Cnfg.getLabel(s.calc_object_type_code),s.calc_object_type_code)) calc_object_type_name,
       'Inherited' as scope_name,
       s.object_id as inherited_from_id,
       ec_calculation_version.name(s.object_id, s.daytime) as inherited_from_name,
       nvl(s.description_override,Ecdp_Calc_Mapping.getSetDescription(s.CALC_CONTEXT_ID,s.OBJECT_ID,s.CALC_SET_NAME,s.CALC_OBJECT_TYPE_CODE,s.CALC_SET_TYPE,s.BASE_CALC_SET_NAME,s.SORT_ORDER,s.SORT_BY_SQL_SYNTAX,s.DESCRIPTION_OVERRIDE,s.SET_OPERATOR,s.DAYTIME)) as description,
       s.RECORD_STATUS,
       s.CREATED_BY,
       s.CREATED_DATE,
       s.LAST_UPDATED_BY,
       s.LAST_UPDATED_DATE,
       s.REV_NO,
       s.REV_TEXT
from calc_set s
where s.calc_set_type='LIBRARY_INHERITED'
UNION ALL
-- Inherited sets
select c.object_id,
       c.daytime,
       s.calc_context_id,
       s.calc_set_name,
       s.calc_set_type as calc_set_type_code,
       ec_prosty_codes.code_text(s.calc_set_type,'CALC_SET_TYPE') as calc_set_type_text,
       s.calc_object_type_code,
       NVL(ec_calc_object_type.label_override(s.calc_context_id, s.calc_object_type_code), Nvl(EcDp_ClassMeta_Cnfg.getLabel(s.calc_object_type_code),s.calc_object_type_code)) calc_object_type_name,
       'Inherited' as scope_name,
       s.object_id as inherited_from_id,
       ec_calculation_version.name(s.object_id, s.daytime) as inherited_from_name,
       nvl(s.description_override,Ecdp_Calc_Mapping.getSetDescription(s.CALC_CONTEXT_ID,s.OBJECT_ID,s.CALC_SET_NAME,s.CALC_OBJECT_TYPE_CODE,s.CALC_SET_TYPE,s.BASE_CALC_SET_NAME,s.SORT_ORDER,s.SORT_BY_SQL_SYNTAX,s.DESCRIPTION_OVERRIDE,s.SET_OPERATOR,s.DAYTIME)) as description,
       s.RECORD_STATUS,
       s.CREATED_BY,
       s.CREATED_DATE,
       s.LAST_UPDATED_BY,
       s.LAST_UPDATED_DATE,
       s.REV_NO,
       s.REV_TEXT
from calc_set s, calculation_version c
where s.daytime = c.daytime
and s.object_id IN (
  -- All parent calculations, stopping when we reach something that is not a private sub
  select calculation_id
  from calc_process_element e, calc_process_elm_version ev
  where e.object_id=ev.object_id
  and ev.daytime=c.daytime
  and ec_calculation.calc_scope(ev.implementing_calc_id)='PRIVATE_SUB'
  start with ev.implementing_calc_id=c.object_id
  connect by ev.implementing_calc_id=prior e.calculation_id
)
)