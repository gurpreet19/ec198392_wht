CREATE MATERIALIZED VIEW CLASS 
-------------------------------------------------------------------------------------
-- CLASS
--
-- $Revision: 1.4 $
--
--  Purpose: Select the row from Class_cnfg with the higherst owner context, allowing templates and projects to
--           override product settings without changing the product row. 
--
-------------------------------------------------------------------------------------
BUILD IMMEDIATE
REFRESH ON DEMAND
AS
with class_property_max as(
  select class_name, property_code, property_value
  from class_property_cnfg p1 
  where p1.presentation_cntx in ('/EC')
  and owner_cntx = (
        select max(owner_cntx) 
        from class_property_cnfg p1_1
        where p1.class_name = p1_1.class_name 
        and p1.property_code = p1_1.property_code
        and p1.presentation_cntx = p1_1.presentation_cntx
        )  
)
select 
c.CLASS_NAME                                      
,cast(null as varchar2(24)) as SUPER_CLASS                                     
,c.CLASS_TYPE                                      
,c.APP_SPACE_CNTX as APP_SPACE_CODE                                  
,c.TIME_SCOPE_CODE    
,c.OWNER_CLASS_NAME    
,cast(p3.property_value as varchar2(24)) as CLASS_SHORT_CODE
,cast(p4.property_value as varchar2(100)) as LABEL
,cast(p5.property_value as varchar2(1)) as ENSURE_REV_TEXT_ON_UPD
,cast(p6.property_value as varchar2(1)) as READ_ONLY_IND
,cast(p7.property_value as varchar2(1)) as INCLUDE_IN_VALIDATION
,cast(p18.property_value as varchar2(1)) as CALC_ENGINE_TABLE_WRITE_IND
,cast(p8.property_value as varchar2(4000)) as JOURNAL_RULE_DB_SYNTAX
,cast(NULL as varchar2(4000)) as CALC_MAPPING_SYNTAX
,cast(p10.property_value as varchar2(4000)) as LOCK_RULE
,cast(p11.property_value as varchar2(1)) as LOCK_IND
,cast(p12.property_value as varchar2(1)) as ACCESS_CONTROL_IND
,cast(p13.property_value as varchar2(1)) as APPROVAL_IND
,cast(p14.property_value as varchar2(1)) as SKIP_TRG_CHECK_IND
,cast(p15.property_value as varchar2(1)) as INCLUDE_WEBSERVICE
,cast(p16.property_value as varchar2(1)) as CREATE_EV_IND
,cast(p17.property_value as varchar2(4000)) as DESCRIPTION
, cast(null as varchar2(24)) as CLASS_VERSION                                   
,c.RECORD_STATUS                                   
,c.CREATED_BY                                      
,c.CREATED_DATE                                    
,c.LAST_UPDATED_BY                                 
,c.LAST_UPDATED_DATE                               
,c.REV_NO                                          
,c.REV_TEXT                                        
,c.APPROVAL_STATE                                  
,c.APPROVAL_BY                                     
,c.APPROVAL_DATE                                   
,c.REC_ID                                          
from class_cnfg c
left join class_property_max p3 on (c.class_name = p3.class_name and p3.property_code = 'CLASS_SHORT_CODE' )
left join class_property_max p4 on (c.class_name = p4.class_name and p4.property_code = 'LABEL' )
left join class_property_max p5 on (c.class_name = p5.class_name and p5.property_code = 'ENSURE_REV_TEXT_ON_UPD' )
left join class_property_max p6 on (c.class_name = p6.class_name and p6.property_code = 'READ_ONLY_IND' )
left join class_property_max p7 on (c.class_name = p7.class_name and p7.property_code = 'INCLUDE_IN_VALIDATION' )
left join class_property_max p8 on (c.class_name = p8.class_name and p8.property_code = 'JOURNAL_RULE_DB_SYNTAX' )
left join class_property_max p10 on (c.class_name = p10.class_name and p10.property_code = 'LOCK_RULE' )
left join class_property_max p11 on (c.class_name = p11.class_name and p11.property_code = 'LOCK_IND' )
left join class_property_max p12 on (c.class_name = p12.class_name and p12.property_code = 'ACCESS_CONTROL_IND' )
left join class_property_max p13 on (c.class_name = p13.class_name and p13.property_code = 'APPROVAL_IND' )
left join class_property_max p14 on (c.class_name = p14.class_name and p14.property_code = 'SKIP_TRG_CHECK_IND' )
left join class_property_max p15 on (c.class_name = p15.class_name and p15.property_code = 'INCLUDE_WEBSERVICE' )
left join class_property_max p16 on (c.class_name = p16.class_name and p16.property_code = 'CREATE_EV_IND' )
left join class_property_max p17 on (c.class_name = p17.class_name and p17.property_code = 'DESCRIPTION' )
left join class_property_max p18 on (c.class_name = p18.class_name and p18.property_code = 'CALC_ENGINE_TABLE_WRITE_IND' )
WHERE ec_install_constants.isBlockedAppSpaceCntx(c.app_space_cntx) = 0
;

create unique index UIX_CLASS on Class(Class_name)
TABLESPACE &ts_index
/

PROMPT Creating Index 'IFK_CLASS_2'
CREATE INDEX IFK_CLASS_2 ON CLASS
 (OWNER_CLASS_NAME)
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

PROMPT Creating Index 'IFK_CLASS_1'
CREATE INDEX IFK_CLASS_1 ON CLASS
 (SUPER_CLASS)
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

PROMPT Creating Index 'IR_CLASS'
CREATE INDEX IR_CLASS ON CLASS
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

