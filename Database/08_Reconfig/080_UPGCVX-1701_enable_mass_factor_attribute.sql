-- Enable attribute 'MASS_FACTOR which is needed in the allocation
update class_attr_property_cnfg set property_value = 'N' where class_name = 'IWEL_MTH_ALLOC' and attribute_name = 'MASS_FACTOR' and property_code = 'DISABLED_IND';
