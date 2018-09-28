CREATE OR REPLACE VIEW class_attr_property 
-------------------------------------------------------------------------------------
--
-- $Revision: 1.4 $
--
--  Purpose: Select the row with the higherst owner context, allowing templates and projects to
--           override product settings without changing the product row. 
--
-------------------------------------------------------------------------------------
--BUILD IMMEDIATE
--REFRESH ON DEMAND
AS
(               
select 
  c.class_name        
  ,c.attribute_name    
  ,c.property_code    
  ,c.presentation_cntx 
  ,c.property_type     
  ,c.property_value    
  ,c.record_status     
  ,c.created_by        
  ,c.created_date      
  ,c.last_updated_by   
  ,c.last_updated_date 
  ,c.rev_no            
  ,c.rev_text          
  ,c.approval_state    
  ,c.approval_by       
  ,c.approval_date     
  ,c.rec_id            
from class_attr_property_cnfg c
left join class_cnfg cc on cc.class_name = c.class_name and ec_install_constants.isBlockedAppSpaceCntx(cc.app_space_cntx) = 0
where owner_cntx = ( select max(owner_cntx) 
               from class_attr_property_cnfg c2 
               where c.class_name = c2.class_name
                and  c.attribute_name = c2.attribute_name
                and  c.property_code = c2.property_code
                and  c.presentation_cntx = c2.presentation_cntx
               )
);






-- create unique index uix_class_attr_property on class_attr_pres(class_name,attribute_name,property_code,operation_id,presentation_cntx)
--TABLESPACE &ts_index
--/

