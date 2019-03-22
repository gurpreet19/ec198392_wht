CREATE OR REPLACE PACKAGE BODY ecdb_buildutils AS

--<EC-DOC>
-------------------------------------------------------------------------------------------------
-- Function       : AddMissingGrantsReadOnly
-- Description    : Grant select on Eckernel objects to given role
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : user_objects
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
-------------------------------------------------------------------------------------------------
PROCEDURE AddMissingGrantsReadOnly(p_role_name IN VARCHAR2)
--</EC-DOC>
is

   CURSOR c_object_to_grant IS
   select /*+ Rule */ 'GRANT READ ON ' || a.object_name || ' to ' || p_role_name  || chr(10) text
   from user_objects a
       left join user_tab_privs b on ( b.grantee = p_role_name
                                       and b.table_name = a.object_name
                                       and b.privilege = 'SELECT')
   where a.object_type in ('VIEW','TABLE','SEQUENCE')
   AND   b.grantee is null
   AND   not exists ( select 'x'
                        from   user_tables b
                        where  b.iot_type   = 'IOT_OVERFLOW'
                        and    b.table_name = a.object_name
                      )
   UNION all
   select /*+ Rule */ 'GRANT EXECUTE ON ' || a.object_name || ' to ' || p_role_name  || chr(10) text
   from user_objects a
   left join user_tab_privs b on ( b.grantee = p_role_name
                                   and b.table_name = a.object_name
                                   and b.privilege = 'EXECUTE')
   where object_type in ('PACKAGE','PROCEDURE','FUNCTION','TYPE')
   AND   a.object_name NOT IN ('ECDP_DYNSQL','ECDB_BUILDUTILS')
   AND   b.grantee is null;

   lv2_sql        VARCHAR2(2000);

   lv2_errPrefix  VARCHAR2(100) := '-----Grant Stmt Error List:-----';
   lv2_errorMsg   VARCHAR2(32767) := lv2_errPrefix;


BEGIN

  FOR cur_rec IN c_object_to_grant LOOP

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
     ecdp_dynsql.WriteTempText('GRANT_MISSING','Error when executing AddMissingGrantsReadOnly. The following statements failed:' || chr(10) || lv2_errorMsg);
   END IF;




END  AddMissingGrantsReadOnly;

--<EC-DOC>
-------------------------------------------------------------------------------------------------
-- Function       : AddMissingGrantsWrite
-- Description    : Grant select,insert, update, delete on Eckernel objects to given role
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : user_objects
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
-------------------------------------------------------------------------------------------------
PROCEDURE AddMissingGrantsWrite(p_role_name IN VARCHAR2)
--</EC-DOC>
is

CURSOR c_object_to_grant IS
select 'GRANT EXECUTE ON ' || a.object_name || ' To ' || p_role_name || chr(10) text
from user_objects a
left join user_tab_privs b on ( b.grantee =  p_role_name
                                     and b.table_name = a.object_name
                                     and b.privilege = 'EXECUTE')
where object_type in ('PACKAGE','PROCEDURE','FUNCTION','TYPE')
AND   a.object_name NOT IN ('ECDP_DYNSQL','ECDB_BUILDUTILS')
AND   b.grantee is null
UNION all
SELECT 'GRANT SELECT ON ' || a.object_name || ' TO ' || p_role_name  || chr(10) text
from user_objects a
     left join user_tab_privs b on ( b.grantee = p_role_name
                                     and b.table_name = a.object_name
                                     and b.privilege = 'SELECT')
where a.object_type in ('TABLE','SEQUENCE')
AND   b.grantee is null
AND   not exists ( select 'x'
                   from   user_tables b
                   where  b.iot_type   = 'IOT_OVERFLOW'
                   and    b.table_name = a.object_name
                 )
UNION all
SELECT 'GRANT SELECT ON ' || a.object_name || ' TO ' || p_role_name  || chr(10) text
from user_objects a
     left join user_tab_privs b on ( b.grantee = p_role_name
                                     and b.table_name = a.object_name
                                     and b.privilege = 'SELECT')
where a.object_type = 'VIEW'
AND   b.grantee is null
AND   a.object_name not like '%JN'
UNION all
SELECT 'GRANT INSERT ON ' || a.object_name || ' TO ' || p_role_name  || chr(10) text
from user_objects a
     left join user_tab_privs b on ( b.grantee = p_role_name
                                     and b.table_name = a.object_name
                                     and b.privilege = 'INSERT')
where a.object_type in ('TABLE')
AND   b.grantee is null
AND   not exists ( select 'x'
                   from   user_tables b
                   where  b.iot_type   = 'IOT_OVERFLOW'
                   and    b.table_name = a.object_name
                 )
UNION all
SELECT 'GRANT UPDATE ON ' || a.object_name || ' TO ' || p_role_name  || chr(10) text
from user_objects a
     left join user_tab_privs b on ( b.grantee = p_role_name
                                     and b.table_name = a.object_name
                                     and b.privilege = 'UPDATE')
where a.object_type in ('TABLE')
AND   b.grantee is null
AND   not exists ( select 'x'
                   from   user_tables b
                   where  b.iot_type   = 'IOT_OVERFLOW'
                   and    b.table_name = a.object_name
                 )
UNION all
SELECT 'GRANT DELETE ON ' || a.object_name || ' TO ' || p_role_name  || chr(10) text
from user_objects a
     left join user_tab_privs b on ( b.grantee = p_role_name
                                     and b.table_name = a.object_name
                                     and b.privilege = 'DELETE')
where a.object_type in ('TABLE')
AND   b.grantee is null
AND   not exists ( select 'x'
                   from   user_tables b
                   where  b.iot_type   = 'IOT_OVERFLOW'
                   and    b.table_name = a.object_name
                 )
UNION all
SELECT 'GRANT INSERT,UPDATE,DELETE ON ' || a.object_name || ' TO ' || p_role_name  || chr(10) text
from user_objects a
     left join user_tab_privs b on ( b.grantee = p_role_name
                                     and b.table_name = a.object_name
                                     and b.privilege = 'INSERT')
     left join user_triggers ut on ( ut.table_name = a.object_name
                                     and ut.trigger_type = 'INSTEAD OF'
                                     and ut.table_owner = user )
where a.object_type in ('VIEW')
AND   not (a.object_name like '%JN')
AND   not (a.object_name like 'RV%')
AND   b.grantee is null
AND   ( ( not substr(a.object_name,1,2) in('DV','TV','IV') ) OR  (ut.trigger_name is not  null) )
AND   not a.object_name in ('DAO_CLASS_DEPENDENCY','DAO_META','DEFERMENT_GROUPS','GROUPS','OBJECTS','OBJECTS_VERSION')
and  not exists ( select 1 from class_cnfg c where c.class_name = substr(a.object_name,4) and substr(a.object_name,1,3) in ('DV','TV','IV')  and ecdp_classmeta_cnfg.isReadOnly(c.class_name) = 'Y')
;

   lv2_sql        VARCHAR2(2000);

   lv2_errPrefix  VARCHAR2(100) := '-----Grant Stmt Error List:-----';
   lv2_errorMsg   VARCHAR2(32767) := lv2_errPrefix;


BEGIN

  FOR cur_rec IN c_object_to_grant LOOP

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
     ecdp_dynsql.WriteTempText('GRANT_MISSING','Error when executing AddMissingGrantsWrite. The following statements failed:' || chr(10) || lv2_errorMsg);
   END IF;




END  AddMissingGrantsWrite;

--<EC-DOC>
-------------------------------------------------------------------------------------------------
-- Function       : AddMissingGrantsReport
-- Description    : Grant select on Eckernel report views to given role
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : user_objects
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
-------------------------------------------------------------------------------------------------
PROCEDURE AddMissingGrantsReport(p_role_name IN VARCHAR2)
--</EC-DOC>

is

   CURSOR c_object_to_grant IS
   SELECT 'GRANT SELECT ON ' || a.object_name || ' to ' || p_role_name || chr(10) text
   from user_objects a
     left join user_tab_privs b on ( b.grantee = p_role_name
                                     and b.table_name = a.object_name
                                     and b.privilege = 'SELECT')
   where a.object_type = 'VIEW'
   and a.object_name like 'RV_%'
   AND   b.grantee is null;


   lv2_sql        VARCHAR2(2000);

   lv2_errPrefix  VARCHAR2(100) := '-----Grant Stmt Error List:-----';
   lv2_errorMsg   VARCHAR2(32767) := lv2_errPrefix;


BEGIN

  FOR cur_rec IN c_object_to_grant LOOP

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
     ecdp_dynsql.WriteTempText('GRANT_MISSING','Error when executing AddMissingGrantsReport. The following statements failed:' || chr(10) || lv2_errorMsg);
   END IF;


END  AddMissingGrantsReport;


--<EC-DOC>
-------------------------------------------------------------------------------------------------
-- Function       : CreateMissingGrants
-- Description    : create missing Grants for Eckernel objects based on given role type
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : user_objects
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
-------------------------------------------------------------------------------------------------
PROCEDURE CreateMissingGrants(p_role_name IN VARCHAR2, p_role_type IN VARCHAR2)
--</EC-DOC>
Is


BEGIN


   IF p_role_type = 'READ' then

      AddMissingGrantsReadOnly(p_role_name);

   end if;

   IF p_role_type = 'WRITE' then

      AddMissingGrantsWrite(p_role_name);

   end if;

   IF p_role_type = 'REPORT' then

      AddMissingGrantsReport(p_role_name);

   end if;


END CreateMissingGrants;

END ecdb_buildutils;