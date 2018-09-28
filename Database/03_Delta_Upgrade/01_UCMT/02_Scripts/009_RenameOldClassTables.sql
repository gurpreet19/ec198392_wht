DECLARE

  CURSOR c_ref_constraint(cp_tables VARCHAR2) IS
    SELECT 'ALTER TABLE ' || c.table_name || ' DISABLE CONSTRAINT ' || c.constraint_name exec_stmt
    FROM   user_constraints c
	,      user_constraints p
    WHERE  p.owner = c.owner
    AND    c.r_constraint_name = p.constraint_name
    AND    p.constraint_type IN ('P','U') 
    AND    p.table_name like cp_tables
    AND    c.r_owner = c.owner
    AND    c.constraint_type = 'R'
    AND    c.owner = user;

BEGIN
   FOR cur_rec IN c_ref_constraint('CLASS%') LOOP
      EXECUTE IMMEDIATE cur_rec.exec_stmt;
   END LOOP;
END;
/

exec ecdp_dynsql.BackupAndDeleteTable('CLASS_TRIGGER_ACTION');
exec ecdp_dynsql.BackupAndDeleteTable('CLASS_REL_PRESENTATION');
exec ecdp_dynsql.BackupAndDeleteTable('CLASS_REL_DB_MAPPING');
exec ecdp_dynsql.BackupAndDeleteTable('CLASS_RELATION');
exec ecdp_dynsql.BackupAndDeleteTable('CLASS_DEPENDENCY');
exec ecdp_dynsql.BackupAndDeleteTable('CLASS_DB_MAPPING');
exec ecdp_dynsql.BackupAndDeleteTable('CLASS_ATTR_PRESENTATION');
exec ecdp_dynsql.BackupAndDeleteTable('CLASS_ATTR_DB_MAPPING');

--get all dependent constraints and drop them first for CLASS_ATTRIBUTE
exec ecdp_dynsql.drop_dependent_constraints('CLASS_ATTRIBUTE');
exec ecdp_dynsql.BackupAndDeleteTable('CLASS_ATTRIBUTE');

--get all dependent constraints and drop them first for CLASS
exec ecdp_dynsql.drop_dependent_constraints('CLASS');
exec ecdp_dynsql.BackupAndDeleteTable('CLASS');

Drop table CLASS_DEPENDENCY_JN;
Drop table CLASS_METHOD_DEF;
Drop table CLASS_METHOD_DEF_JN;
Drop table CLASS_METHOD_JN;
Drop table CLASS_METHOD;


DECLARE

  CURSOR c_ref_constraint(cp_tables VARCHAR2) IS
    SELECT 'ALTER TABLE ' || c.table_name || ' ENABLE CONSTRAINT ' || c.constraint_name exec_stmt
    FROM   user_constraints c
	,      user_constraints p
    WHERE  p.owner = c.owner
    AND    c.r_constraint_name = p.constraint_name
    AND    p.constraint_type IN ('P','U') 
    AND    p.table_name like cp_tables
    AND    c.r_owner = c.owner
    AND    c.constraint_type = 'R'
    AND    c.owner = user;

BEGIN
   FOR cur_rec IN c_ref_constraint('CLASS%') LOOP
      EXECUTE IMMEDIATE cur_rec.exec_stmt;
   END LOOP;
END;
/
