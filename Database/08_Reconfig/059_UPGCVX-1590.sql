delete from class_attr_property_cnfg where class_name='OBJECT_ITEM_COMMENT' and attribute_name='OBJECT_TYPE' and PROPERTY_CODE='IS_MANDATORY' and OWNER_CNTX=2500;
update class_attr_property_cnfg set PROPERTY_VALUE='false' where class_name='OBJECT_ITEM_COMMENT' and attribute_name='OBJECT_TYPE' and PROPERTY_CODE='viewhidden' and OWNER_CNTX=0;
