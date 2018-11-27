CREATE OR REPLACE FORCE EDITIONABLE VIEW "V_CLASS_ATTR_PROPERTY_CNFG" ("CLASS_NAME", "ATTRIBUTE_NAME", "PROPERTY_CODE", "OWNER_CNTX", "PRESENTATION_CNTX", "PROPERTY_TYPE", "PROPERTY_VALUE", "RECORD_STATUS", "CREATED_BY", "CREATED_DATE", "LAST_UPDATED_BY", "LAST_UPDATED_DATE", "REV_NO", "REV_TEXT", "APPROVAL_STATE", "APPROVAL_BY", "APPROVAL_DATE", "REC_ID") AS 
  (
select
  c.class_name
  ,c.attribute_name
  ,c.property_code
  ,c.owner_cntx
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
where owner_cntx = ( select max(owner_cntx)
               from class_attr_property_cnfg c2
               where c.class_name = c2.class_name
                and  c.attribute_name = c2.attribute_name
                and  c.property_code = c2.property_code
                and  c.presentation_cntx = c2.presentation_cntx
               )
)
union all
select
   a.class_name
  ,a.attribute_name
  ,'DB_PRES_SYNTAX' as property_code
  ,r.owner_cntx
  ,r.presentation_cntx
  ,r.property_type
  ,replace(replace(replace(replace(replace(r.property_value,'#ATTRIBUTE_NAME#',a.attribute_name),'#CLASS_NAME#',a.class_name),'#REFERENCE_TYPE#',a.reference_type),'#REFERENCE_KET#',a.reference_key),'#REFERENCE_VALUE#',a.reference_value) as property_value
  ,r.record_status
  ,r.created_by
  ,r.created_date
  ,r.last_updated_by
  ,r.last_updated_date
  ,r.rev_no
  ,r.rev_text
  ,r.approval_state
  ,r.approval_by
  ,r.approval_date
  ,r.rec_id
from class_attribute_cnfg a
inner join class_attr_property_cnfg r on r.class_name=a.reference_type and r.attribute_name='CODE' and r.property_code='REF_DB_PRES_SYNTAX'
where not exists (select 1 from class_attr_property_cnfg where class_name=a.class_name and attribute_name=a.attribute_name and property_code='DB_PRES_SYNTAX')
and r.owner_cntx = ( select max(owner_cntx)
               from class_attr_property_cnfg r2
               where r.class_name = r2.class_name
                and  r.attribute_name = r2.attribute_name
                and  r.property_code = r2.property_code
                and  r.presentation_cntx = r2.presentation_cntx
)