CREATE OR REPLACE FORCE EDITIONABLE VIEW "V_CALC_OBJ_TYPE_IMPL_CLS" ("OBJECT_ID", "OBJECT_TYPE_CODE", "EXCLUDED_IND", "CLASS_NAME", "CLASS_LABEL", "RECORD_STATUS", "CREATED_BY", "CREATED_DATE", "LAST_UPDATED_BY", "LAST_UPDATED_DATE", "REV_NO", "REV_TEXT") AS 
  (
----------------------------------------------------------------------------------------------------
--
-- Purpose  : Lists all classes that implement a given object type.
--            This includes the class itself and one level of child classes for interfaces.
--
----------------------------------------------------------------------------------------------------
-- For all DB object types there should be a class with the
-- same name as the object type code. This is always included.
select cot.object_id,
       cot.object_type_code,
       'N' excluded_ind,
       c.class_name,
       EcDp_ClassMeta_Cnfg.getLabel(c.class_name) as class_label,
       c.record_status,
       c.created_by,
       c.created_date,
       c.last_updated_by,
       c.last_updated_date,
       c.rev_no,
       c.rev_text
from class_cnfg c, calc_object_type cot
where cot.calc_obj_type_category = 'DB'
and c.class_name = cot.object_type_code
UNION ALL
-- For interface classes, we also scan class dependency to find any child classes.
-- Note that the child class might be flagged for exclusion.
select cot.object_id,
       cot.object_type_code,
       DECODE(INSTR((','||cot.excl_impl_class_list||','), (','||c.class_name||',')),0,'N','Y') excluded_ind,
       c.class_name,
       EcDp_ClassMeta_Cnfg.getLabel(c.class_name) as class_label,
       c.record_status,
       c.created_by,
       c.created_date,
       c.last_updated_by,
       c.last_updated_date,
       c.rev_no,
       c.rev_text
from class_cnfg c, calc_object_type cot
where cot.calc_obj_type_category = 'DB'
and c.class_name in (
      select cd.child_class
      from class_dependency_cnfg cd
      where cd.dependency_type = 'IMPLEMENTS'
      and cd.parent_class = cot.object_type_code
      )
)