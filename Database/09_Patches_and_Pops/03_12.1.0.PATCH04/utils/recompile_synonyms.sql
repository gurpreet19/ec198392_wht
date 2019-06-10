begin
  for c in (select object_name
              from user_objects
             where status = 'INVALID'
               and object_type = 'SYNONYM') loop
    EXECUTE IMMEDIATE 'ALTER SYNONYM '||c.object_name||' COMPILE';
  end loop;
end;
/
