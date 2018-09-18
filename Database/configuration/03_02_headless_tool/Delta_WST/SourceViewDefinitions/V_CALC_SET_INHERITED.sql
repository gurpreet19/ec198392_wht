CREATE OR REPLACE FORCE EDITIONABLE VIEW "V_CALC_SET_INHERITED" ("OBJECT_ID", "DAYTIME", "NAME", "CALC_SET_NAME", "CALC_CONTEXT_ID", "CALC_OBJECT_TYPE_CODE", "CALC_SET_TYPE", "SORT_BY_SQL_SYNTAX", "DESCRIPTION", "SET_OPERATOR", "BASE_CALC_SET_NAME", "INHERITED_FROM_ID", "INHERITED_FROM_NAME", "RECORD_STATUS", "CREATED_BY", "CREATED_DATE", "LAST_UPDATED_BY", "LAST_UPDATED_DATE", "REV_NO", "REV_TEXT") AS 
  (
----------------------------------------------------------------------------------------------------
--
-- Purpose  : Lists all sets available to a calculation that are inherited from parent calculations.
--
----------------------------------------------------------------------------------------------------
select c.object_id,
       c.daytime,
       c.name as name,
       s.calc_set_name,
       s.calc_context_id,
       s.calc_object_type_code,
       s.calc_set_type,
       s.sort_by_sql_syntax,
       nvl(s.description_override,Ecdp_Calc_Mapping.getSetDescription(s.CALC_CONTEXT_ID,s.OBJECT_ID,s.CALC_SET_NAME,s.CALC_OBJECT_TYPE_CODE,s.CALC_SET_TYPE,s.BASE_CALC_SET_NAME,s.SORT_ORDER,s.SORT_BY_SQL_SYNTAX,s.DESCRIPTION_OVERRIDE,s.SET_OPERATOR,s.DAYTIME)) as description,
       s.set_operator,
       s.base_calc_set_name,
       s.object_id as inherited_from_id,
       ec_calculation_version.name(s.object_id, s.daytime) inherited_from_name,
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
UNION ALL
select c.object_id,
       c.daytime,
       c.name as name,
       s.calc_set_name,
       s.calc_context_id,
       s.calc_object_type_code,
       s.calc_set_type,
       s.sort_by_sql_syntax,
       nvl(s.description_override,Ecdp_Calc_Mapping.getSetDescription(s.CALC_CONTEXT_ID,s.OBJECT_ID,s.CALC_SET_NAME,s.CALC_OBJECT_TYPE_CODE,s.CALC_SET_TYPE,s.BASE_CALC_SET_NAME,s.SORT_ORDER,s.SORT_BY_SQL_SYNTAX,s.DESCRIPTION_OVERRIDE,s.SET_OPERATOR,s.DAYTIME)) as description,
       s.set_operator,
       s.base_calc_set_name,
       s.object_id as inherited_from_id,
       c.name inherited_from_name,
       s.RECORD_STATUS,
       s.CREATED_BY,
       s.CREATED_DATE,
       s.LAST_UPDATED_BY,
       s.LAST_UPDATED_DATE,
       s.REV_NO,
       s.REV_TEXT
from calc_set s, calculation_version c
where s.daytime = c.daytime
and s.object_id = c.object_id
and s.calc_set_type = 'LIBRARY_INHERITED'
)