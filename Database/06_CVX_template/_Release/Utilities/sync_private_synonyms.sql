Prompt Starting sync_private_synonyms.sql, arg1: &&operation

DECLARE

CURSOR c_object_without_synonym(cp_operation VARCHAR2) IS
SELECT 'CREATE SYNONYM ' ||  a.object_name || ' FOR ECKERNEL_' || cp_operation || '.' || a.object_name || CHR(10) text
FROM all_objects a
WHERE a.owner = 'ECKERNEL_' || cp_operation
AND a.object_type in ('PACKAGE','VIEW','TABLE','SEQUENCE','TYPE')
AND a.object_name not like 'MLOG$%'
AND a.object_name not like 'BIN$%'
AND NOT EXISTS (
SELECT 1 FROM user_synonyms us
WHERE us.SYNONYM_NAME = a.object_name
AND us.TABLE_OWNER = a.owner
AND us.TABLE_NAME = a.object_name
)
;

CURSOR c_synonym_without_object(cp_operation VARCHAR2) IS
SELECT 'DROP SYNONYM ' || us.synonym_name || CHR(10) text
FROM user_synonyms us
WHERE NOT EXISTS (
SELECT 1 FROM all_objects a
WHERE a.owner = 'ECKERNEL_' || cp_operation
AND a.object_name = us.table_name
AND a.owner = us.table_owner
AND a.object_name = us.synonym_name
);

   lv2_operation  VARCHAR2(100) := '&operation';
   lv2_sql        VARCHAR2(2000);

   lv2_errPrefix  VARCHAR2(100) := '-----Synonym Stmt Error List:-----';
   lv2_errorMsg   VARCHAR2(32767) := lv2_errPrefix;

BEGIN

/*   
  BEGIN
    EXECUTE IMMEDIATE 'PURGE RECYCLEBIN';       
  EXCEPTION
    WHEN OTHERS THEN
      NULL;  
  END;
*/   
   lv2_operation := UPPER(lv2_operation); -- The owner name in the Oracle dictionary is in upper case
   
   FOR cur_rec IN c_object_without_synonym(lv2_operation) LOOP

      lv2_sql := cur_rec.text;

      BEGIN
         EXECUTE IMMEDIATE lv2_sql;
      EXCEPTION
        WHEN OTHERS THEN
          IF (length(lv2_errorMsg) + length(lv2_sql) + length(sqlerrm) + 100) < 32767 THEN
            lv2_errorMsg := lv2_errorMsg || chr(10) || 'Create synonym stmt failed: [' || lv2_sql || ']. Error msg: [' || sqlerrm || ']';
          END IF;
      END;

   END LOOP;

   FOR cur_rec IN c_synonym_without_object(lv2_operation) LOOP

      lv2_sql := cur_rec.text;

      BEGIN
         EXECUTE IMMEDIATE lv2_sql;
      EXCEPTION
        WHEN OTHERS THEN
          IF (length(lv2_errorMsg) + length(lv2_sql) + length(sqlerrm) + 100) < 32767 THEN
            lv2_errorMsg := lv2_errorMsg || chr(10) || 'Drop synonym stmt failed: [' || lv2_sql || ']. Error msg: [' || sqlerrm || ']';
          END IF;
      END;

   END LOOP;

   IF length(lv2_errorMsg) > length(lv2_errPrefix) THEN
     raise_application_error(-20000, 'Error when executing "sync_private_synonyms.sql". The following statements failed:' || chr(10) || lv2_errorMsg);
   END IF;
/*
  BEGIN
    EXECUTE IMMEDIATE 'PURGE RECYCLEBIN';       
  EXCEPTION
    WHEN OTHERS THEN
      NULL;  
  END;
*/
END;
/
