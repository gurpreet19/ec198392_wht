CREATE MATERIALIZED VIEW class_relation 
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
  select p1.from_class_name, p1.to_class_name, p1.role_name, p1.property_code, p1.property_value
  from class_rel_property_cnfg p1, class_cnfg cc
  where p1.presentation_cntx in ('/', '/EC')
  and cc.class_name=p1.to_class_name
  and ec_install_constants.isBlockedAppSpaceCntx(cc.app_space_cntx) = 0
  and p1.owner_cntx = (
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
,cr.is_key
,cast(p0.property_value as varchar2(50)) as name
,cast(p1.property_value as varchar2(1)) as is_mandatory
,cr.is_bidirectional
,cr.app_space_cntx as context_code
,cr.group_type
,cr.multiplicity
,cast(p2.property_value as varchar2(1)) as disabled_ind
,cast(p3.property_value as varchar2(1)) as report_only_ind
,cast(p4.property_value as varchar2(32)) as access_control_method
,cast(p5.property_value as number) as alloc_priority
,cast(null as varchar2(4000)) as calc_mapping_syntax
,cast(p7.property_value as varchar2(4000)) as description
,cast(p8.property_value as varchar2(1)) as approval_ind
,cast(p9.property_value as varchar2(1)) as reverse_approval_ind
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
inner join class_cnfg tc on tc.class_name = cr.to_class_name and ec_install_constants.isBlockedAppSpaceCntx(tc.app_space_cntx) = 0
inner join class_cnfg fc on fc.class_name = cr.from_class_name and ec_install_constants.isBlockedAppSpaceCntx(fc.app_space_cntx) = 0
left join class_rel_property_max p0 on (cr.from_class_name = p0.from_class_name and cr.to_class_name = p0.to_class_name and cr.role_name = p0.role_name and p0.property_code = 'NAME' )
left join class_rel_property_max p1 on (cr.from_class_name = p1.from_class_name and cr.to_class_name = p1.to_class_name and cr.role_name = p1.role_name and p1.property_code = 'IS_MANDATORY' )
left join class_rel_property_max p2 on (cr.from_class_name = p2.from_class_name and cr.to_class_name = p2.to_class_name and cr.role_name = p2.role_name and p2.property_code = 'DISABLED_IND' )
left join class_rel_property_max p3 on (cr.from_class_name = p3.from_class_name and cr.to_class_name = p3.to_class_name and cr.role_name = p3.role_name and p3.property_code = 'REPORT_ONLY_IND' )
left join class_rel_property_max p4 on (cr.from_class_name = p4.from_class_name and cr.to_class_name = p4.to_class_name and cr.role_name = p4.role_name and p4.property_code = 'ACCESS_CONTROL_METHOD' )
left join class_rel_property_max p5 on (cr.from_class_name = p5.from_class_name and cr.to_class_name = p5.to_class_name and cr.role_name = p5.role_name and p5.property_code = 'ALLOC_PRIORITY' )
left join class_rel_property_max p7 on (cr.from_class_name = p7.from_class_name and cr.to_class_name = p7.to_class_name and cr.role_name = p7.role_name and p7.property_code = 'DESCRIPTION' )
left join class_rel_property_max p8 on (cr.from_class_name = p8.from_class_name and cr.to_class_name = p8.to_class_name and cr.role_name = p8.role_name and p8.property_code = 'APPROVAL_IND' )
left join class_rel_property_max p9 on (cr.from_class_name = p9.from_class_name and cr.to_class_name = p9.to_class_name and cr.role_name = p9.role_name and p9.property_code = 'REVERSE_APPROVAL_IND' )
where ec_install_constants.isBlockedAppSpaceCntx(cr.app_space_cntx) = 0;
  

create unique index uix_class_relation on Class_relation(from_class_name,to_class_name,role_name)
TABLESPACE &ts_index
/



PROMPT Creating Index 'IFK_CLASS_RELATION_2'
CREATE INDEX IFK_CLASS_RELATION_2 ON CLASS_RELATION
 (TO_CLASS_NAME)
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

PROMPT Creating Index 'IR_CLASS_RELATION'
CREATE INDEX IR_CLASS_RELATION ON CLASS_RELATION
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
