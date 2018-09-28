declare 
  cursor c_invalid_objects is 
    select object_type
    ,      object_name
    ,      status
    ,      'alter '||regexp_replace(object_type, ' BODY$', '', 1, 0, 'i')||' '||object_name||' compile'||regexp_replace(object_type, regexp_replace(object_type, ' BODY$', '', 1, 0, 'i'), '', 1, 0, 'i') stmt
    from   user_objects 
    where  status <> 'VALID'
    order by decode(object_type, 'TYPE', 1, 'TYPE BODY', 2, 'TRIGGER', 3, 'PACKAGE', 4, 'PACKAGE BODY', 5, 'PROCEDURE', 6, 'VIEW', 7, 8);
  
  lv_new_status varchar2(255);
  ll_stmt       long;
begin
  for c_invalid_object in c_invalid_objects loop
    begin
      ll_stmt := c_invalid_object.stmt;
      begin
        execute immediate ll_stmt;
        execute immediate 'select status from user_objects where object_type = '''||c_invalid_object.object_type||''' and object_name = '''||c_invalid_object.object_name||'''' into lv_new_status;
      exception when others then
        lv_new_status := 'RECOMPILE FAILED';
      end;
      dbms_output.put_line(rpad('Recompile object '||c_invalid_object.object_type, 35, ' ')||' - '||rpad(regexp_replace(c_invalid_object.object_name, 'ERROR', '*****', 1, 0, 'i'), 35, ' ')||' with result [ '||lv_new_status||' ]');
    end;
  end loop; 
end;
/
