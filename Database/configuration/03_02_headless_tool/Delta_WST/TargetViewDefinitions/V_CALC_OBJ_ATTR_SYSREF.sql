CREATE OR REPLACE FORCE VIEW "V_CALC_OBJ_ATTR_SYSREF" ("OBJECT_ID", "CLASS_ATTR_NAME", "CLASS_ATTR_LABEL") AS 
  (
----------------------------------------------------------------------------------------------------
--
-- Purpose  : Lists all attributes in SYSTEM_REF_VALUE that are or could be exposed
--            as global attributes to the allocation engine.
--
----------------------------------------------------------------------------------------------------
select cc.object_id, a.attribute_name as class_attr_name, p.label as class_attr_label
from class_attribute a, class_attr_presentation p, calc_context cc
where a.class_name = p.class_name
and a.attribute_name = p.attribute_name
and NVL(a.disabled_ind,'N')<>'Y'
and NVL(a.report_only_ind,'N')<>'Y'
and a.class_name = 'SYSTEM_REF_VALUE'
and NVL(a.is_key,'N')<>'Y'
)