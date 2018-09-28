CREATE MATERIALIZED VIEW class_rel_db_mapping 
-------------------------------------------------------------------------------------
--
-- $Revision: 1.4 $
--
--  Purpose: Select the row with the higherst owner context, allowing templates and projects to
--           override product settings without changing the product row. 
--
-------------------------------------------------------------------------------------
BUILD IMMEDIATE
REFRESH ON DEMAND
AS
with class_rel_property_max as(
  select from_class_name, to_class_name, role_name, property_code, property_value
  from class_rel_property_cnfg p1
  where p1.presentation_cntx in ('/EC', '/')
  and owner_cntx = (
        select max(owner_cntx)
        from class_rel_property_cnfg p1_1
        where p1.from_class_name = p1_1.from_class_name
        and   p1.to_class_name = p1_1.to_class_name
        and   p1.role_name = p1_1.role_name
        and p1.property_code = p1_1.property_code
        and p1.presentation_cntx = p1_1.presentation_cntx
        )
)
select
cr.from_CLASS_NAME
,cr.to_class_name
,cr.role_name
,cr.db_mapping_type
,cr.db_sql_syntax
,cast(p1.property_value as number) as sort_order
,cr.RECORD_STATUS
,cr.CREATED_BY
,cr.CREATED_DATE
,cr.LAST_UPDATED_BY
,cr.LAST_UPDATED_DATE
,cr.REV_NO
,cr.REV_TEXT
,cr.APPROVAL_STATE
,cr.APPROVAL_BY
,cr.APPROVAL_DATE
,cr.REC_ID
from class_relation_cnfg cr
left join class_cnfg tc on tc.class_name = cr.to_class_name and ec_install_constants.isBlockedAppSpaceCntx(tc.app_space_cntx) = 0
left join class_cnfg fc on fc.class_name = cr.from_class_name and ec_install_constants.isBlockedAppSpaceCntx(fc.app_space_cntx) = 0
left join class_rel_property_max p1 on (cr.from_class_name = p1.from_class_name and cr.to_class_name = p1.to_class_name and cr.role_name = p1.role_name and p1.property_code = 'DB_SORT_ORDER' )
where ec_install_constants.isBlockedAppSpaceCntx(cr.app_space_cntx) = 0;

create unique index uix_class_rel_db_mapping on Class_rel_db_mapping(from_class_name,to_class_name,role_name)
TABLESPACE &ts_index
/


PROMPT Creating Index 'IR_CLASS_REL_DB_MAPPING'
CREATE INDEX IR_CLASS_REL_DB_MAPPING ON CLASS_REL_DB_MAPPING
 (REC_ID)
 INITRANS 2
 MAXTRANS 255
 PCTFREE 50
 STORAGE
 (
   PCTINCREASE 50
   NEXT 65536
 )
 TABLESPACE &ts_index
/
