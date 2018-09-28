CREATE MATERIALIZED VIEW class_attribute 
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
  where p1.presentation_cntx in ('/EC')
  and cc.class_name=p1.class_name
  and ca.class_name=p1.class_name
  and ca.attribute_name=p1.attribute_name    
  and ec_install_constants.isBlockedAppSpaceCntx(cc.app_space_cntx) = 0
  and ec_install_constants.isBlockedAppSpaceCntx(ca.app_space_cntx) = 0
  and p1.owner_cntx = (
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
,ca.is_key
,cast(p1.property_value as varchar2(1)) as is_mandatory
,ca.APP_SPACE_CNTX as CONTEXT_CODE                                  
,ca.data_type
,cast(null as varchar2(4000)) as calc_mapping_syntax
,cast(null as varchar2(32)) as precision
,cast(p11.property_value as varchar2(4000)) as default_value
,cast(p5.property_value as varchar2(1)) as disabled_ind
,cast(null as varchar2(1)) as disabled_calc_ind
,cast(p7.property_value as varchar2(1)) as report_only_ind
,cast(p8.property_value as varchar2(4000)) as description
,cast(p9.property_value as varchar2(240)) as name
,cast(p12.property_value as varchar2(240)) as default_client_value
,cast(p10.property_value as varchar2(1)) as read_only_ind
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
left join class_attr_property_max p1 on (ca.class_name = p1.class_name and ca.attribute_name = p1.attribute_name and p1.property_code = 'IS_MANDATORY' )
left join class_attr_property_max p5 on (ca.class_name = p5.class_name and ca.attribute_name = p5.attribute_name and p5.property_code = 'DISABLED_IND' )
left join class_attr_property_max p7 on (ca.class_name = p7.class_name and ca.attribute_name = p7.attribute_name and p7.property_code = 'REPORT_ONLY_IND' )
left join class_attr_property_max p8 on (ca.class_name = p8.class_name and ca.attribute_name = p8.attribute_name and p8.property_code = 'DESCRIPTION' )
left join class_attr_property_max p9 on (ca.class_name = p9.class_name and ca.attribute_name = p9.attribute_name and p9.property_code = 'NAME' )
left join class_attr_property_max p10 on (ca.class_name = p10.class_name and ca.attribute_name = p10.attribute_name and p10.property_code = 'READ_ONLY_IND' )
left join class_attr_property_max p11 on (ca.class_name = p11.class_name and ca.attribute_name = p11.attribute_name and p11.property_code = 'DEFAULT_VALUE' )
left join class_attr_property_max p12 on (ca.class_name = p12.class_name and ca.attribute_name = p12.attribute_name and p12.property_code = 'DEFAULT_CLIENT_VALUE' )
where ec_install_constants.isBlockedAppSpaceCntx(ca.app_space_cntx) = 0
;



create unique index uix_class_attribute on Class_attribute(Class_name,attribute_name)
TABLESPACE &ts_index
/

