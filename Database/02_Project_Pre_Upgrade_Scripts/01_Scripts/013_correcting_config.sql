update class set class_type='TABLE' , APP_SPACE_CODE='WST' where class_name ='CT_G_STOR_LIFT_ACTUAL';
update class_attribute set CONTEXT_CODE='WST' where CONTEXT_CODE is null;