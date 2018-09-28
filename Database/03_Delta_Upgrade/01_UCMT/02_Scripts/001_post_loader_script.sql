delete from class_property_cnfg cp
where not exists ( select 1 from class_cnfg c where c.class_name = cp.class_name)
and owner_cntx = -100;  

delete from class_attr_property_cnfg cap
where not exists ( select 1 from class_attribute_cnfg ca where ca.class_name = cap.class_name and ca.attribute_name = cap.attribute_name)
and owner_cntx = -100;  

delete from class_rel_property_cnfg crp
where not exists ( select 1 from class_relation_cnfg cr 
                   where cr.from_class_name = crp.from_class_name 
                   and cr.to_class_name = crp.to_class_name
                   and cr.role_name = crp.role_name
                   )
and owner_cntx = -100;  

delete from class_tra_property_cnfg cp
where not exists ( select 1 from class_trigger_actn_cnfg c 
                   where c.class_name = cp.class_name
                   and c.triggering_event = cp.triggering_event
                   and c.trigger_type = cp.trigger_type
                   and c.sort_order = cp.sort_order )
and owner_cntx = -100;  

commit;

create table u_class_attr_property_cnfg as select * from class_attr_property_cnfg where owner_cntx = -100;

ALTER TABLE CLASS_PROPERTY_CNFG ENABLE CONSTRAINT FK_CLASS_PROPERTY_CNFG;
ALTER TABLE CLASS_ATTR_PROPERTY_CNFG ENABLE CONSTRAINT FK_CLASS_ATTR_PROPERTY_CNFG;
ALTER TABLE CLASS_REL_PROPERTY_CNFG ENABLE CONSTRAINT FK_CLASS_REL_PROPERTY_CNFG_1;
ALTER TABLE CLASS_TRA_PROPERTY_CNFG ENABLE CONSTRAINT FK_CLASS_TRA_PROPERTY_CNFG;
