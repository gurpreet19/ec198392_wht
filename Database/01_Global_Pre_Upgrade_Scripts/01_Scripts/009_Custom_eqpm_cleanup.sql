DECLARE
lv2_errorMsg VARCHAR2(32767);

Cursor c_equip_class is
select class_name from class
where class_name in (select class_name from class_db_mapping where db_object_name = 'EQUIPMENT')
and class_name<>'EQPM';

Cursor objectname(p_classname varchar2) is 
select object_name from user_objects 
where (object_name like '%'||p_classname or object_name like '%'||p_classname||'_JN') and object_type = 'VIEW';

Begin
for i in C_EQUIP_CLASS loop
  Begin
  /*Delete Custom equipment class entries*/
    Delete object_attr_editable where class_name =i.class_name;
    Delete object_attr_validation where class_name =i.class_name;
    Delete class_trigger_action where class_name =i.class_name;
    Delete class_rel_presentation where to_class_name =i.class_name;
    Delete class_rel_db_mapping where to_class_name =i.class_name;
    Delete class_relation where to_class_name =i.class_name;
    Delete class_attr_presentation where class_name =i.class_name;
    Delete class_attr_db_mapping where class_name =i.class_name;
    Delete class_attribute where class_name =i.class_name;
    Delete class_dependency where child_class =i.class_name;
    Delete class_db_mapping where class_name =i.class_name;
    Delete class where class_name =i.class_name;
    
    for j in objectname(i.class_name) loop
    /*drop Views and JN views*/
      execute immediate 'Drop view '||j.object_name;
    end loop;
  Exception when others then
    /*Log entry in t_temptext;*/
    IF (length(i.class_name) + length(sqlerrm) + 100) < 32767 THEN
           lv2_errorMsg := ' [' || i.class_name || ']. Error msg: [' || sqlerrm || ']';
	ELSE
		   lv2_errorMsg := i.class_name; 
    END IF;    
	ecdp_dynsql.WriteTempText('DROP_EQPM_CLASS','Error for Class: ' || chr(10) || lv2_errorMsg);
  End;
End Loop;
End;
/