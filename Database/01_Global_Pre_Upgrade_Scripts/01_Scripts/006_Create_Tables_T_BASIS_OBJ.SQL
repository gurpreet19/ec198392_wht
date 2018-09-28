declare
  cursor c_pre_upg_tables is 
    select object_name
    from   user_objects
    where  object_type = 'TABLE'
    and    object_name in ( 'T_BASIS_OBJECT'
                          , 'T_BASIS_ACCESS'
                          , 'T_BASIS_USERROLE'
                          , 'T_BASIS_ROLE'
                          , 'CTRL_TV_PRESENTATION'
                          , 'STRM_TRANSPORT_EVENT'
                          , 'WELL_TRANSPORT_EVENT'
                          , 'OBJECT_TRANSPORT_EVENT'
                          )
    order by object_name;
    
  ll_stmt long;
begin
  for c_pre_upg_table in c_pre_upg_tables loop
    begin
      dbms_output.put_line('Creating pre_upg table [ PRE_UPG_'||c_pre_upg_table.object_name||' ]');
      ll_stmt := 'create table pre_upg_'||c_pre_upg_table.object_name||' as select * from '||c_pre_upg_table.object_name;
      execute immediate ll_stmt;
    end;
  end loop;
end;
/
