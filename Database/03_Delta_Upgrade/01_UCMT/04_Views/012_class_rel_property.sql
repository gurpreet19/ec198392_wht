CREATE OR REPLACE VIEW class_rel_property 
-------------------------------------------------------------------------------------
--
-- $Revision: 1.4 $
--
--  Purpose: Select the row with the higherst owner context, allowing templates and projects to
--           override product settings without changing the product row. 
--
-------------------------------------------------------------------------------------
AS
(               
select c.from_class_name,
       c.to_class_name,
       c.role_name, 
       c.property_code,
       c.presentation_cntx,
       c.property_type,
       c.property_value,
       c.record_status,
       c.created_by,
       c.created_date,
       c.last_updated_by,
       c.last_updated_date,
       c.rev_no,
       c.rev_text,
       c.approval_state,
       c.approval_by,
       c.approval_date,
       c.rec_id  
from class_rel_property_cnfg c
left join class_cnfg tc on tc.class_name = c.to_class_name and ec_install_constants.isBlockedAppSpaceCntx(tc.app_space_cntx) = 0
left join class_cnfg fc on tc.class_name = c.from_class_name and ec_install_constants.isBlockedAppSpaceCntx(fc.app_space_cntx) = 0
where owner_cntx = ( select max(owner_cntx) 
               from class_rel_property_cnfg c2 
               where c.from_class_name = c2.from_class_name
                and  c.to_class_name = c2.to_class_name
                and  c.role_name = c2.role_name
                and  c.property_code = c2.property_code
                and  c.presentation_cntx = c2.presentation_cntx
               )
);

/*
create unique index uix_class_rel_pres on class_rel_pres(from_class_name,to_class_name, role_name,property_code,operation_id,presentation_cntx)
TABLESPACE &ts_index
*/


