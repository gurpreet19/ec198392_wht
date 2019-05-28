alter table ctrl_system_attribute disable all triggers;
  update ctrl_system_attribute set daytime = to_date('01.01.1900','dd.mm.yyyy') where attribute_type = 'UTC2LOCAL_DIFF' and daytime = to_date('31.10.1999 01:00:00','dd.mm.yyyy hh24:mi:ss');
  update ctrl_system_attribute set daytime = to_date('31.10.2030','dd.mm.yyyy') where attribute_type = 'UTC2LOCAL_DIFF' and daytime = to_date('31.10.2030 01:00:00','dd.mm.yyyy hh24:mi:ss');  
alter table ctrl_system_attribute enable all triggers;
