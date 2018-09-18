CREATE OR REPLACE FORCE VIEW "V_CALC_OBJECT_META" ("CLASS_NAME", "CLASS_TYPE", "OBJECT_TYPE", "DATA_TYPE", "SOURCE_NAME", "DATE_HANDLING_PROPS", "TIME_SCOPE_CODE", "CALC_CONTEXT_ID", "RECORD_STATUS", "CREATED_BY", "CREATED_DATE", "LAST_UPDATED_BY", "LAST_UPDATED_DATE", "REV_NO", "REV_TEXT") AS 
  (
------------------------------------------------------------------------------------
--  v_calc_object_meta
--
--  $Revision: 1.9 $
--
--  Purpose:   Used by the calculation engine's dynamic data read to determine which views
--             to load calculation objects from.
--
--
--  When        Who  Why
--  ----------  ---  --------
--  2005-03-04  HUS  Initial version
-------------------------------------------------------------------------------------
select
   	cot.object_type_code as class_name,
   	c.class_type as class_type,
   	cot.object_type_code as object_type,
   	NVL(cot.data_type,'STRING') data_type,
    DECODE(c.class_type,'INTERFACE','IV_','DATA','DV_','TABLE','TV_','SUB_CLASS','OSV_','OV_') || cot.object_type_code AS source_name,
   	EcDp_Calc_Meta.getDateHandlingProperties(cot.object_type_code) AS date_handling_props,
   	c.time_scope_code,
   	cot.object_id as calc_context_id,
    cot.record_status,
   	cot.CREATED_BY,
   	cot.CREATED_DATE,
   	cot.LAST_UPDATED_BY,
   	cot.LAST_UPDATED_DATE,
   	cot.REV_NO,
   	cot.REV_TEXT
from calc_object_type cot, class c
where cot.object_type_code = c.class_name
and	c.owner_class_name is null
and cot.calc_obj_type_category = 'DB'
)