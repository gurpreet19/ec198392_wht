CREATE OR REPLACE FORCE VIEW "CLASS_REL_PROPERTY" ("FROM_CLASS_NAME", "TO_CLASS_NAME", "ROLE_NAME", "PROPERTY_CODE", "PRESENTATION_CNTX", "PROPERTY_TYPE", "PROPERTY_VALUE", "RECORD_STATUS", "CREATED_BY", "CREATED_DATE", "LAST_UPDATED_BY", "LAST_UPDATED_DATE", "REV_NO", "REV_TEXT", "APPROVAL_STATE", "APPROVAL_BY", "APPROVAL_DATE", "REC_ID") AS 
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
)