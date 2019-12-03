Prompt Starting create_missing_grants.sql, arg1: &&operation

DECLARE

CURSOR c_object_to_grant(cp_operation VARCHAR2) IS
select 'GRANT SELECT ON ' || a.object_name || ' to APP_READ_ROLE_' || cp_operation || chr(10) text
from user_objects a
where object_type in ('VIEW','TABLE')
AND NOT EXISTS (
select 'x' from user_tab_privs b
where b.table_name = a.object_name
and  b.privilege = 'SELECT'
and b.owner =  USER
AND b.grantee = 'APP_READ_ROLE_' || cp_operation)
UNION
select 'GRANT EXECUTE ON ' || a.object_name || ' to APP_READ_ROLE_' || cp_operation || ', APP_WRITE_ROLE_' || cp_operation || chr(10) text
from user_objects a
where object_type in ('PACKAGE','PROCEDURE','FUNCTION')
AND NOT EXISTS (
select 'x' from user_tab_privs b
where b.table_name = a.object_name
and  b.privilege = 'EXECUTE'
and b.owner =  user
and b.grantee = 'APP_READ_ROLE_' || cp_operation)
UNION
SELECT 'GRANT SELECT, INSERT, UPDATE, DELETE ON ' || a.object_name || ' TO APP_WRITE_ROLE_' || cp_operation  || chr(10) text
from user_objects a
where a.object_type = 'TABLE'
AND NOT EXISTS (
select 'x' from user_tab_privs b
where b.table_name = a.object_name
and  b.privilege = 'SELECT'
and b.owner = user
and b.grantee = 'APP_WRITE_ROLE_' || cp_operation)
UNION
SELECT 'GRANT SELECT, INSERT, UPDATE, DELETE ON ' || a.object_name || ' TO APP_WRITE_ROLE_' || cp_operation  || chr(10) text
from user_objects a
where a.object_type = 'TABLE'
AND NOT EXISTS (
select 'x' from user_tab_privs b
where b.table_name = a.object_name
and  b.privilege = 'INSERT'
and b.owner = user
and b.grantee = 'APP_WRITE_ROLE_' || cp_operation)
UNION
SELECT 'GRANT SELECT, INSERT, UPDATE, DELETE ON ' || a.object_name || ' TO APP_WRITE_ROLE_' || cp_operation  || chr(10) text
from user_objects a
where a.object_type = 'TABLE'
AND NOT EXISTS (
select 'x' from user_tab_privs b
where b.table_name = a.object_name
and  b.privilege = 'DELETE'
and b.owner = user
and b.grantee = 'APP_WRITE_ROLE_' || cp_operation)
UNION
SELECT 'GRANT SELECT, INSERT, UPDATE, DELETE ON ' || a.object_name || ' TO APP_WRITE_ROLE_' || cp_operation  || chr(10) text
from user_objects a
where a.object_type = 'TABLE'
AND NOT EXISTS (
select 'x' from user_tab_privs b
where b.table_name = a.object_name
and  b.privilege = 'UPDATE'
and b.owner = user
and b.grantee = 'APP_WRITE_ROLE_' || cp_operation)
UNION
SELECT 'GRANT SELECT ON ' || a.object_name || ' to APP_READ_ROLE_' || cp_operation || ', APP_WRITE_ROLE_' || cp_operation || chr(10) text
from user_objects a
where object_type = 'SEQUENCE'
AND NOT EXISTS (
select 'x' from user_tab_privs b
where b.table_name = a.object_name
and  b.privilege = 'SELECT'
and b.owner =  USER
AND b.grantee = 'APP_READ_ROLE_' || cp_operation)
UNION
SELECT 'GRANT SELECT, INSERT, UPDATE, DELETE ON ' || a.object_name || ' TO APP_WRITE_ROLE_' || cp_operation  || chr(10) text
from user_objects a
where a.object_type = 'VIEW'
and exists (
select 1 from user_triggers ut
where ut.table_name = a.object_name
and ut.trigger_type = 'INSTEAD OF'
and ut.table_owner = user
)
AND NOT EXISTS (
select 'x' from user_tab_privs b
where b.table_name = a.object_name
and  b.privilege = 'SELECT'
and b.owner = user
and b.grantee = 'APP_WRITE_ROLE_' || cp_operation)
UNION
SELECT 'GRANT SELECT, INSERT, UPDATE, DELETE ON ' || a.object_name || ' TO APP_WRITE_ROLE_' || cp_operation  || chr(10) text
from user_objects a
where a.object_type = 'VIEW'
and exists (
select 1 from user_triggers ut
where ut.table_name = a.object_name
and ut.trigger_type = 'INSTEAD OF'
and ut.table_owner = user
)
AND NOT EXISTS (
select 'x' from user_tab_privs b
where b.table_name = a.object_name
and  b.privilege = 'INSERT'
and b.owner = user
and b.grantee = 'APP_WRITE_ROLE_' || cp_operation)
UNION
SELECT 'GRANT SELECT, INSERT, UPDATE, DELETE ON ' || a.object_name || ' TO APP_WRITE_ROLE_' || cp_operation  || chr(10) text
from user_objects a
where a.object_type = 'VIEW'
and exists (
select 1 from user_triggers ut
where ut.table_name = a.object_name
and ut.trigger_type = 'INSTEAD OF'
and ut.table_owner = user
)
AND NOT EXISTS (
select 'x' from user_tab_privs b
where b.table_name = a.object_name
and  b.privilege = 'DELETE'
and b.owner = user
and b.grantee = 'APP_WRITE_ROLE_' || cp_operation)
UNION
SELECT 'GRANT SELECT, INSERT, UPDATE, DELETE ON ' || a.object_name || ' TO APP_WRITE_ROLE_' || cp_operation  || chr(10) text
from user_objects a
where a.object_type = 'VIEW'
and exists (
select 1 from user_triggers ut
where ut.table_name = a.object_name
and ut.trigger_type = 'INSTEAD OF'
and ut.table_owner = user
)
AND NOT EXISTS (
select 'x' from user_tab_privs b
where b.table_name = a.object_name
and  b.privilege = 'UPDATE'
and b.owner = user
and b.grantee = 'APP_WRITE_ROLE_' || cp_operation)
UNION
SELECT 'GRANT SELECT ON ' || a.object_name || ' to REPORT_ROLE_' || cp_operation || chr(10) text
from user_objects a
where a.object_type = 'VIEW'
and a.object_name like 'RV_%'
AND NOT EXISTS (
select 'x' from user_tab_privs b
where b.table_name = a.object_name
and  b.privilege = 'SELECT'
and b.owner =  USER
AND b.grantee = 'REPORT_ROLE_' || cp_operation)
UNION
SELECT 'GRANT INSERT, UPDATE, DELETE ON ' || a.object_name || ' TO APP_WRITE_ROLE_' || cp_operation  || chr(10) text
from user_objects a
where a.object_type = 'VIEW'
and substr(a.object_name,1,1) in ('V','Z')
and a.object_name not like '%_JN'
AND NOT EXISTS (
select 1 from user_triggers ut
where ut.table_name = a.object_name
and ut.trigger_type = 'INSTEAD OF'
and ut.table_owner = user
)
AND NOT EXISTS (
select 'x' from user_tab_privs b
where b.table_name = a.object_name
and  b.privilege = 'DELETE'
and b.owner = user
and b.grantee = 'APP_WRITE_ROLE_' || cp_operation)
AND OBJECT_NAME NOT LIKE 'V_QBL_%'
UNION
SELECT 'GRANT INSERT, UPDATE, DELETE ON ' || a.object_name || ' TO APP_WRITE_ROLE_' || cp_operation  || chr(10) text
from user_objects a
where a.object_type = 'VIEW'
and substr(a.object_name,1,1) in ('V','Z')
and a.object_name not like '%_JN'
AND NOT EXISTS (
select 1 from user_triggers ut
where ut.table_name = a.object_name
and ut.trigger_type = 'INSTEAD OF'
and ut.table_owner = user
)
AND NOT EXISTS (
select 'x' from user_tab_privs b
where b.table_name = a.object_name
and  b.privilege = 'UPDATE'
and b.owner = user
and b.grantee = 'APP_WRITE_ROLE_' || cp_operation)
AND OBJECT_NAME NOT LIKE 'V_QBL_%'
UNION
SELECT 'GRANT INSERT, UPDATE, DELETE ON ' || a.object_name || ' TO APP_WRITE_ROLE_' || cp_operation  || chr(10) text
from user_objects a
where a.object_type = 'VIEW'
and substr(a.object_name,1,1) in ('V','Z')
and a.object_name not like '%_JN'
AND NOT EXISTS (
select 1 from user_triggers ut
where ut.table_name = a.object_name
and ut.trigger_type = 'INSTEAD OF'
and ut.table_owner = user
)
AND NOT EXISTS (
select 'x' from user_tab_privs b
where b.table_name = a.object_name
and  b.privilege = 'INSERT'
and b.owner = user
and b.grantee = 'APP_WRITE_ROLE_' || cp_operation)
AND OBJECT_NAME NOT LIKE 'V_QBL_%'
UNION
SELECT 'GRANT EXECUTE ON ' || a.object_name || ' TO APP_WRITE_ROLE_' || cp_operation  || chr(10) text
from user_objects a
where a.object_type = 'TYPE'
AND NOT EXISTS (
select 1 from user_triggers ut
where ut.table_name = a.object_name
and ut.trigger_type = 'INSTEAD OF'
and ut.table_owner = user
)
AND NOT EXISTS (
select 'x' from user_tab_privs b
where b.table_name = a.object_name
and  b.privilege = 'EXECUTE'
and b.owner = user
and b.grantee = 'APP_WRITE_ROLE_' || cp_operation)
UNION
SELECT 'GRANT EXECUTE ON ' || a.object_name || ' TO APP_READ_ROLE_' || cp_operation  || chr(10) text
from user_objects a
where a.object_type = 'TYPE'
AND NOT EXISTS (
select 1 from user_triggers ut
where ut.table_name = a.object_name
and ut.trigger_type = 'INSTEAD OF'
and ut.table_owner = user
)
AND NOT EXISTS (
select 'x' from user_tab_privs b
where b.table_name = a.object_name
and  b.privilege = 'EXECUTE'
and b.owner = user
and b.grantee = 'APP_READ_ROLE_' || cp_operation)
MINUS
(SELECT 'GRANT SELECT ON ' || a.object_name || ' to APP_READ_ROLE_' || cp_operation || CHR(10) text
from user_objects a
where a.object_type = 'TABLE'
AND OBJECT_NAME LIKE 'BIN$%'
UNION ALL
SELECT 'GRANT SELECT, INSERT, UPDATE, DELETE ON ' || a.object_name || ' TO APP_WRITE_ROLE_' || cp_operation || CHR(10) text
from user_objects a
where a.object_type = 'TABLE'
AND OBJECT_NAME LIKE 'BIN$%');




   lv2_operation  VARCHAR2(100) := '&operation';   
   lv2_sql        VARCHAR2(2000);

   lv2_errPrefix  VARCHAR2(100) := '-----Grant Stmt Error List:-----';
   lv2_errorMsg   VARCHAR2(32767) := lv2_errPrefix;

BEGIN
   --ecdp_dynsql.PurgeRecycleBin;
   
   lv2_operation := UPPER(lv2_operation); -- The grantee name in the Oracle dictionary is in upper case
   
   FOR cur_rec IN c_object_to_grant(lv2_operation) LOOP
      
      lv2_sql := cur_rec.text; 
     
      BEGIN   
         EXECUTE IMMEDIATE lv2_sql;       
      EXCEPTION
        WHEN OTHERS THEN
          IF (length(lv2_errorMsg) + length(lv2_sql) + length(sqlerrm) + 100) < 32767 THEN
            lv2_errorMsg := lv2_errorMsg || chr(10) || 'Grant stmt failed: [' || lv2_sql || ']. Error msg: [' || sqlerrm || ']';
          END IF;
      END;   

   END LOOP;
   
   IF length(lv2_errorMsg) > length(lv2_errPrefix) THEN
    -- raise_application_error(-20000, 'Error when executing "create_missing_grants.sql". The following statements failed:' || chr(10) || lv2_errorMsg);
	Null;
   END IF;
   
END;
/