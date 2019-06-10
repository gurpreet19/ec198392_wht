
PROMPT Enabling constraints for tables: [&1]

DECLARE

CURSOR c_ref_constraint(cp_tables VARCHAR2) IS
SELECT 'ALTER TABLE ' || c.table_name || ' ENABLE CONSTRAINT ' || c.constraint_name exec_stmt
FROM user_constraints c, user_constraints p
WHERE p.owner = c.owner
AND c.r_constraint_name = p.constraint_name
AND p.constraint_type IN ('P','U') 
AND p.table_name like cp_tables
AND c.r_owner = c.owner
AND c.constraint_type = 'R'
AND c.owner = user;

lv2_table_spec VARCHAR2(2000);

BEGIN

   lv2_table_spec := RTRIM(Nvl('&1',' ')) || '%';

   FOR cur_rec IN c_ref_constraint(lv2_table_spec) LOOP

      EXECUTE IMMEDIATE cur_rec.exec_stmt;
   
   END LOOP;

END;
/
