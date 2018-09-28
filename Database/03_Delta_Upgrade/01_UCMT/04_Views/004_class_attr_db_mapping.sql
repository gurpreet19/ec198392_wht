CREATE MATERIALIZED VIEW class_attr_db_mapping 
-------------------------------------------------------------------------------------
-- class_db_mapping
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
with class_attr_property_max as(
  select p1.class_name, p1.attribute_name, p1.property_code, p1.property_value
  from class_attr_property_cnfg p1, class_cnfg cc, class_attribute_cnfg ca
  where p1.presentation_cntx in ('/EC', '/')
  and cc.class_name=p1.class_name
  and ca.class_name=p1.class_name
  and ca.attribute_name=p1.attribute_name
  and ec_install_constants.isBlockedAppSpaceCntx(cc.app_space_cntx) = 0
  and ec_install_constants.isBlockedAppSpaceCntx(ca.app_space_cntx) = 0
  and owner_cntx = (
        select max(owner_cntx)
        from class_attr_property_cnfg p1_1
        where p1.class_name = p1_1.class_name
        and   p1.attribute_name = p1_1.attribute_name
        and p1.property_code = p1_1.property_code
        and p1.presentation_cntx = p1_1.presentation_cntx
        )
)
select
ca.CLASS_NAME
,ca.attribute_name
,ca.db_mapping_type
,ca.db_sql_syntax
,cast(p1.property_value as number) as sort_order
,ca.db_join_table
,ca.db_join_where
,ca.RECORD_STATUS
,ca.CREATED_BY
,ca.CREATED_DATE
,ca.LAST_UPDATED_BY
,ca.LAST_UPDATED_DATE
,ca.REV_NO
,ca.REV_TEXT
,ca.APPROVAL_STATE
,ca.APPROVAL_BY
,ca.APPROVAL_DATE
,ca.REC_ID
from class_attribute_cnfg ca
inner join class_cnfg cc on cc.class_name = ca.class_name and ec_install_constants.isBlockedAppSpaceCntx(cc.app_space_cntx) = 0
left join class_attr_property_max p1 on (ca.class_name = p1.class_name and ca.attribute_name = p1.attribute_name and p1.property_code = 'DB_SORT_ORDER' )
where ec_install_constants.isBlockedAppSpaceCntx(ca.app_space_cntx) = 0;

create unique index uix_class_attr_db_mapping on Class_attr_db_mapping(Class_name,attribute_name)
TABLESPACE &ts_index
/


PROMPT Creating Index 'IR_CLASS_ATTR_DB_MAPPING'
CREATE INDEX IR_CLASS_ATTR_DB_MAPPING ON CLASS_ATTR_DB_MAPPING
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
