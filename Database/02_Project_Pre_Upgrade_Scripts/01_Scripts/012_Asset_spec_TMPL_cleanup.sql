-- Removing custom attributes added to product classes

declare
cursor c_list is (select class_name,attribute_name from class_attribute where CONTEXT_CODE='CVX');
begin
for i in c_list loop
Delete class_attr_presentation where class_name =i.class_name and attribute_name = i.attribute_name;
Delete class_attr_db_mapping where class_name =i.class_name and attribute_name = i.attribute_name;
Delete class_attribute where class_name =i.class_name and attribute_name = i.attribute_name;
end loop;
end;
/