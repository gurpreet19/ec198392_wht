CREATE MATERIALIZED VIEW class_attr_presentation 
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
with class_attr_property_max as(
  select p1.class_name, p1.attribute_name, p1.property_code, p1.property_value
  from class_attr_property_cnfg p1, class_cnfg cc, class_attribute_cnfg ca
  where p1.presentation_cntx in ('/EC', '/')
  and cc.class_name=p1.class_name
  and ca.class_name=p1.class_name
  and ca.attribute_name=p1.attribute_name
  and ec_install_constants.isBlockedAppSpaceCntx(cc.app_space_cntx) = 0
  and ec_install_constants.isBlockedAppSpaceCntx(ca.app_space_cntx) = 0
  and p1.owner_cntx = (
        select max(p1_1.owner_cntx)
        from class_attr_property_cnfg p1_1
        where p1.class_name = p1_1.class_name
        and   p1.attribute_name = p1_1.attribute_name
        and p1.property_code = p1_1.property_code
        and p1.presentation_cntx = p1_1.presentation_cntx
        )
  ),
  class_attr_static as (
  select p1.class_name, p1.attribute_name, listagg(p1.property_code||'='||p1.property_value,';') WITHIN GROUP (ORDER BY p1.property_code) static_presentation_syntax
  from class_attr_property_cnfg p1, class_cnfg cc
  where p1.presentation_cntx in ('/EC')
  and   p1.property_type = 'STATIC_PRESENTATION'
  and   cc.class_name=p1.class_name
  and   ec_install_constants.isBlockedAppSpaceCntx(cc.app_space_cntx) = 0
  and   p1.owner_cntx = (
        select max(p1_1.owner_cntx)
        from class_attr_property_cnfg p1_1
        where p1.class_name = p1_1.class_name
        and   p1.attribute_name = p1_1.attribute_name
        and p1.property_code = p1_1.property_code
        and p1.presentation_cntx = p1_1.presentation_cntx
        )
  group by p1.class_name, p1.attribute_name
  )
select
ca.CLASS_NAME
,ca.attribute_name
,cast(p1.property_value as varchar(4000)) as presentation_syntax-- Replaced for EC 12.0 tempory --> ,cast(ecdp_classmeta_cnfg.getDynamicPresentationSyntax(ca.class_name, ca.attribute_name) as varchar(4000)) as presentation_syntax
,cast(psp1.static_presentation_syntax as varchar(4000)) as static_presentation_syntax
,cast(p2.property_value as number) as sort_order
,cast(p3.property_value as varchar(4000)) as db_pres_syntax
,cast(p4.property_value as varchar(32)) as label_id
,cast(p5.property_value as varchar(64)) as label
,cast(p6.property_value as varchar(32)) as uom_code
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
left join class_attr_static psp1 on (ca.class_name = psp1.class_name and ca.attribute_name = psp1.attribute_name)
left join class_attr_property_max p1 on (ca.class_name = p1.class_name and ca.attribute_name = p1.attribute_name and p1.property_code = 'PresentationSyntax' ) -- <-- added for EC 12.0 tempory
left join class_attr_property_max p2 on (ca.class_name = p2.class_name and ca.attribute_name = p2.attribute_name and p2.property_code = 'SCREEN_SORT_ORDER' )
left join class_attr_property_max p3 on (ca.class_name = p3.class_name and ca.attribute_name = p3.attribute_name and p3.property_code = 'DB_PRES_SYNTAX' )
left join class_attr_property_max p4 on (ca.class_name = p4.class_name and ca.attribute_name = p4.attribute_name and p4.property_code = 'LABEL_ID' )
left join class_attr_property_max p5 on (ca.class_name = p5.class_name and ca.attribute_name = p5.attribute_name and p5.property_code = 'LABEL' )
left join class_attr_property_max p6 on (ca.class_name = p6.class_name and ca.attribute_name = p6.attribute_name and p6.property_code = 'UOM_CODE' )
where ec_install_constants.isBlockedAppSpaceCntx(ca.app_space_cntx) = 0;  


create unique index uix_class_attr_presentation on class_attr_presentation(class_name,attribute_name)
TABLESPACE &ts_index
/


PROMPT Creating Index 'IR_CLASS_ATTR_PRESENTATION'
CREATE INDEX IR_CLASS_ATTR_PRESENTATION ON CLASS_ATTR_PRESENTATION
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
