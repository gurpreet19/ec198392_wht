
select count(*) from user_objects where status='INVALID';
set linesize 180
column object_name format a32
select 
       object_name, 
       object_type, 
       to_char(created, 'mm-dd-yyyy hh24:mi') as created, 
       to_char(last_ddl_time , 'mm-dd-yyyy hh24:mi') last_ddl_time 
from user_objects where status='INVALID';
