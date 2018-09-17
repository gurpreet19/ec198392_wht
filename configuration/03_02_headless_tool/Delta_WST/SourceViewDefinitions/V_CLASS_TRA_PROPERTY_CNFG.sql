CREATE OR REPLACE FORCE EDITIONABLE VIEW "V_CLASS_TRA_PROPERTY_CNFG" ("CLASS_NAME", "TRIGGERING_EVENT", "TRIGGER_TYPE", "SORT_ORDER", "PROPERTY_CODE", "OWNER_CNTX", "PROPERTY_TYPE", "PROPERTY_VALUE", "RECORD_STATUS", "CREATED_BY", "CREATED_DATE", "LAST_UPDATED_BY", "LAST_UPDATED_DATE", "REV_NO", "REV_TEXT", "APPROVAL_BY", "APPROVAL_DATE", "APPROVAL_STATE", "REC_ID") AS 
  (
select
    c.class_name,
    c.triggering_event,
    c.trigger_type,
    c.sort_order,
    c.property_code,
    c.owner_cntx,
    c.property_type,
    c.property_value,
    c.record_status,
    c.created_by,
    c.created_date,
    c.last_updated_by,
    c.last_updated_date,
    c.rev_no,
    c.rev_text,
    c.approval_by,
    c.approval_date,
    c.approval_state,
    c.rec_id
from class_tra_property_cnfg c
where owner_cntx = ( select max(owner_cntx)
               from class_tra_property_cnfg c2
               where c.class_name = c2.class_name
                and  c.triggering_event = c2.triggering_event
                and  c.trigger_type = c2.trigger_type
                and  c.sort_order = c2.sort_order
                and  c.property_code = c2.property_code
               )
)