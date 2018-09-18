CREATE OR REPLACE FORCE VIEW "V_CALC_VAR_ALL" ("OBJECT_ID", "DAYTIME", "CALC_VAR_SIGNATURE", "NAME", "CALC_CONTEXT_ID", "DIM1_OBJECT_TYPE_CODE", "DIM2_OBJECT_TYPE_CODE", "DIM3_OBJECT_TYPE_CODE", "DIM4_OBJECT_TYPE_CODE", "DIM5_OBJECT_TYPE_CODE", "DESCRIPTION", "SCOPE_NAME", "INHERITED_FROM_ID", "INHERITED_FROM_NAME", "MAPPINGS_IND", "RECORD_STATUS", "CREATED_BY", "CREATED_DATE", "LAST_UPDATED_BY", "LAST_UPDATED_DATE", "REV_NO", "REV_TEXT") AS 
  (
----------------------------------------------------------------------------------------------------
--
-- Purpose  : Lists all varaibles available to a calculation, including variables inherited from
--            the context and parent calculations.
--
----------------------------------------------------------------------------------------------------
-- Local variables
select v.object_id,
       v.daytime,
       v.calc_var_signature,
       v.name,
       v.calc_context_id,
       v.dim1_object_type_code,
       v.dim2_object_type_code,
       v.dim3_object_type_code,
       v.dim4_object_type_code,
       v.dim5_object_type_code,
       v.description,
       'Local' as scope_name,
       NULL as inherited_from_id,
       NULL as inherited_from_name,
       NULL as mappings_ind,
       v.RECORD_STATUS,
       v.CREATED_BY,
       v.CREATED_DATE,
       v.LAST_UPDATED_BY,
       v.LAST_UPDATED_DATE,
       v.REV_NO,
       v.REV_TEXT
from calc_variable_local v
UNION ALL
-- Global variables from the calculation context
select cv.object_id,
       cv.daytime,
       v.calc_var_signature,
       v.name,
       c.calc_context_id,
       v.dim1_object_type_code,
       v.dim2_object_type_code,
       v.dim3_object_type_code,
       v.dim4_object_type_code,
       v.dim5_object_type_code,
       v.description,
       'Context' as scope_name,
       c.calc_context_id as inherited_from_id,
       ec_calc_context_version.name(c.calc_context_id, cv.daytime, '<=') as inherited_from_name,
       EcDp_Calc_Mapping.getVariableMappingsInd(c.calc_context_id, v.calc_var_signature) as mappings_ind,
       v.RECORD_STATUS,
       v.CREATED_BY,
       v.CREATED_DATE,
       v.LAST_UPDATED_BY,
       v.LAST_UPDATED_DATE,
       v.REV_NO,
       v.REV_TEXT
from calc_variable v, calculation c, calculation_version cv
where v.object_id = c.calc_context_id
and cv.object_id = c.object_id
and v.active_ind = 'Y'
UNION ALL
-- Inherited from parent calculations
select cv.object_id,
       cv.daytime,
       v.calc_var_signature,
       v.name,
       v.calc_context_id,
       v.dim1_object_type_code,
       v.dim2_object_type_code,
       v.dim3_object_type_code,
       v.dim4_object_type_code,
       v.dim5_object_type_code,
       v.description,
       'Inherited' as scope_name,
       v.object_id as inherited_from_id,
       ec_calculation_version.name(v.object_id, v.daytime) inherited_from_name,
       NULL as mappings_ind,
       v.RECORD_STATUS,
       v.CREATED_BY,
       v.CREATED_DATE,
       v.LAST_UPDATED_BY,
       v.LAST_UPDATED_DATE,
       v.REV_NO,
       v.REV_TEXT
from calc_variable_local v, calculation_version cv
where v.daytime = cv.daytime
and v.object_id IN (
  -- All parent calculations, stopping when we reach something that is not a private sub
  select calculation_id
  from calc_process_element e, calc_process_elm_version ev
  where e.object_id=ev.object_id
  and ev.daytime=cv.daytime
  and ec_calculation.calc_scope(ev.implementing_calc_id)='PRIVATE_SUB'
  start with ev.implementing_calc_id=cv.object_id
  connect by ev.implementing_calc_id=prior e.calculation_id
)
)