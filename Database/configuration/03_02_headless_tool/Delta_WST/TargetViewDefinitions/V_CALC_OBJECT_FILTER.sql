CREATE OR REPLACE FORCE VIEW "V_CALC_OBJECT_FILTER" ("OBJECT_ID", "OBJECT_TYPE_CODE", "IMPL_CLASS_NAME", "SQL_SYNTAX", "CALC_OBJ_ATTR_FILTER", "PARAMETER_FILTER", "RECORD_STATUS", "CREATED_BY", "CREATED_DATE", "LAST_UPDATED_BY", "LAST_UPDATED_DATE", "REV_NO", "REV_TEXT") AS 
  (
----------------------------------------------------------------------------------------------------
--
-- Purpose  : Lists all attributes and relation that are or could potentially be used for filtering an
--            object type. Used together with an instead-of trigger to present a more user-friendly
--            list in the screen where the user doesn't have to insert rows manually.
--
----------------------------------------------------------------------------------------------------
-- All explicit filters
select cof.object_id,
       cof.object_type_code,
       cof.impl_class_name,
       cof.sql_syntax,
       cof.calc_obj_attr_filter,
       cof.parameter_filter,
       cof.record_status,
       cof.created_by,
       cof.created_date,
       cof.last_updated_by,
       cof.last_updated_date,
       cof.rev_no,
       cof.rev_text
from calc_object_filter cof
UNION ALL
-- All attributes without explicit filters
select otic.object_id,
       otic.object_type_code,
       otic.class_name as impl_class_name,
       carp.sql_syntax,
       NULL as calc_obj_attr_filter,
       NULL as parameter_filter,
       NULL as record_status,
       NULL as created_by,
       NULL as created_date,
       NULL as last_updated_by,
       NULL as last_updated_date,
       0 as rev_no,
       NULL as rev_text
from (  -- *** Sub-query for getting all classes that implement a given object type ***
        -- For all DB object types there should be a class with the
        -- same name as the object type code. This is always included.
        select cot.object_id,
               cot.object_type_code,
               'N' excluded_ind,
               cot.object_type_code as class_name
        from calc_object_type cot
        where cot.calc_obj_type_category = 'DB'
        UNION ALL
        -- For interface classes, we also scan class dependency to find any child classes.
        -- Note that the child class might be flagged for exclusion.
        select cot.object_id,
               cot.object_type_code,
               DECODE(INSTR((','||cot.excl_impl_class_list||','), (','||c.class_name||',')),0,'N','Y') excluded_ind,
               c.class_name
        from class c, calc_object_type cot
        where cot.calc_obj_type_category = 'DB'
        and c.class_name in (
              select cd.child_class
              from class_dependency cd
              where cd.dependency_type = 'IMPLEMENTS'
              and cd.parent_class = cot.object_type_code
        )
     ) otic,
     (
        -- *** Sub-query for getting all class attributes and class relations ***
        select ca.class_name, ca.attribute_name as sql_syntax
        from class_attribute ca
        UNION ALL
        select cr.to_class_name as class_name, cr.role_name||'_ID' as sql_syntax
        from class_relation cr
     ) carp
where carp.class_name=otic.class_name
and otic.excluded_ind='N'
and carp.sql_syntax not in (
    select sql_syntax
    from calc_object_filter cof
    where cof.object_id = otic.object_id
    and cof.object_type_code = otic.object_type_code
    and cof.impl_class_name = otic.class_name
   )
)