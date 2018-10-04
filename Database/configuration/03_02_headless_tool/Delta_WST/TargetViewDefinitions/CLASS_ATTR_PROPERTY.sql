CREATE OR REPLACE FORCE VIEW "CLASS_ATTR_PROPERTY" ("CLASS_NAME", "ATTRIBUTE_NAME", "PROPERTY_CODE", "PRESENTATION_CNTX", "PROPERTY_TYPE", "PROPERTY_VALUE", "RECORD_STATUS", "CREATED_BY", "CREATED_DATE", "LAST_UPDATED_BY", "LAST_UPDATED_DATE", "REV_NO", "REV_TEXT", "APPROVAL_STATE", "APPROVAL_BY", "APPROVAL_DATE", "REC_ID") AS 
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
)