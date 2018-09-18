CREATE OR REPLACE FORCE EDITIONABLE VIEW "V_CALC_OBJ_ATTR_SYSREF" ("OBJECT_ID", "CLASS_ATTR_NAME", "CLASS_ATTR_LABEL") AS 
  (
----------------------------------------------------------------------------------------------------
--
-- Purpose  : Lists all attributes in SYSTEM_REF_VALUE that are or could be exposed
--            as global attributes to the allocation engine.
--
----------------------------------------------------------------------------------------------------
select cc.object_id, a.attribute_name as class_attr_name, EcDp_ClassMeta_Cnfg.getLabel(a.class_name, a.attribute_name) as class_attr_label
from class_attribute_cnfg a, calc_context cc
where EcDp_ClassMeta_Cnfg.isDisabled(a.class_name, a.attribute_name)<>'Y'
and EcDp_ClassMeta_Cnfg.isReportOnly(a.class_name, a.attribute_name)<>'Y'
and a.class_name = 'SYSTEM_REF_VALUE'
and NVL(a.is_key,'N')<>'Y'
)