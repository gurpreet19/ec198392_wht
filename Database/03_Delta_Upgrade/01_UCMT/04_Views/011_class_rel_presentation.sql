CREATE MATERIALIZED VIEW class_rel_presentation 
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
  where p1.presentation_cntx in ('/EC', '/')
  and cc.class_name=p1.to_class_name
  and ec_install_constants.isBlockedAppSpaceCntx(cc.app_space_cntx) = 0
  and owner_cntx = (
        select max(owner_cntx)
        from class_rel_property_cnfg p1_1
        where p1.from_class_name = p1_1.from_class_name
        and   p1.to_class_name = p1_1.to_class_name
        and   p1.role_name = p1_1.role_name
        and   p1.property_code = p1_1.property_code
        and   p1.presentation_cntx = p1_1.presentation_cntx
        )
),
  class_rel_static as (
  select p1.from_class_name, p1.to_class_name, p1.role_name, listagg(p1.property_code||'='||p1.property_value,';') WITHIN GROUP (ORDER BY p1.property_code) static_presentation_syntax
  from class_rel_property_cnfg p1, class_cnfg cc
  where p1.presentation_cntx = '/EC'
  and   p1.property_type = 'STATIC_PRESENTATION'
  and   cc.class_name=p1.to_class_name
  and   ec_install_constants.isBlockedAppSpaceCntx(cc.app_space_cntx) = 0
  and   p1.owner_cntx = (
        select max(owner_cntx)
        from class_rel_property_cnfg p1_1
        where p1.from_class_name = p1_1.from_class_name
        and   p1.to_class_name = p1_1.to_class_name
        and   p1.role_name = p1_1.role_name
        and   p1.property_code = p1_1.property_code
        and   p1.presentation_cntx = p1_1.presentation_cntx
        )
  group by p1.from_class_name, p1.to_class_name, p1.role_name
  )
select
cr.from_CLASS_NAME
,cr.to_class_name
,cr.role_name
,cast(psp1.static_presentation_syntax as varchar(4000)) as static_presentation_syntax
,cast(p1.property_value as varchar2(4000)) as presentation_syntax-- Replaced for EC 12.0 tempory --> ,cast(ecdp_classmeta_cnfg.getDynamicPresentationSyntax(cr.from_class_name, cr.to_class_name, cr.role_name) as varchar2(4000)) as presentation_syntax
,cast(p2.property_value as varchar2(4000)) as db_pres_syntax
,cast(p3.property_value as varchar2(64)) as label
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
left join class_rel_static psp1 on (cr.from_class_name = psp1.from_class_name and cr.to_class_name = psp1.to_class_name and cr.role_name = psp1.role_name )
left join class_rel_property_max p1 on (cr.from_class_name = p1.from_class_name and cr.to_class_name = p1.to_class_name and cr.role_name = p1.role_name and p1.property_code = 'PresentationSyntax' ) -- <-- added for EC 12.0 tempory
left join class_rel_property_max p2 on (cr.from_class_name = p2.from_class_name and cr.to_class_name = p2.to_class_name and cr.role_name = p2.role_name and p2.property_code = 'DB_PRES_SYNTAX' )
left join class_rel_property_max p3 on (cr.from_class_name = p3.from_class_name and cr.to_class_name = p3.to_class_name and cr.role_name = p3.role_name and p3.property_code = 'LABEL' )
where ec_install_constants.isBlockedAppSpaceCntx(cr.app_space_cntx) = 0;

create unique index uix_class_rel_presentation on class_rel_presentation(from_class_name,to_class_name, role_name)
TABLESPACE &ts_index
/


PROMPT Creating Index 'IR_CLASS_REL_PRESENTATION'
CREATE INDEX IR_CLASS_REL_PRESENTATION ON CLASS_REL_PRESENTATION
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
