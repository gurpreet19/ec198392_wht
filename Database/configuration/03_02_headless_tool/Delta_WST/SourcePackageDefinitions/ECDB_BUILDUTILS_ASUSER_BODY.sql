CREATE OR REPLACE PACKAGE BODY ecdb_buildutils_asuser AS

--<EC-DOC>
-------------------------------------------------------------------------------------------------
-- Function       : SyncPrivateSynonyms
-- Description    : Create synonyms for energyx_ schema
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
PROCEDURE SyncPrivateSynonyms
--</EC-DOC>
is

CURSOR c_object_without_synonym(cp_operation VARCHAR2) IS
SELECT 'CREATE SYNONYM ' ||  a.object_name || ' FOR ECKERNEL_' || cp_operation || '.' || a.object_name || CHR(10) text
FROM all_objects a
WHERE a.owner = 'ECKERNEL_' || cp_operation
AND a.object_type in ('PACKAGE','VIEW','TABLE','SEQUENCE','TYPE')
AND a.object_name not like 'MLOG$%'
AND a.object_name not like 'BIN$%'
AND a.object_name NOT IN ('ECDP_DYNSQL','ECDB_BUILDUTILS')
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

   lv2_operation  VARCHAR2(100);
   lv2_sql        VARCHAR2(2000);

   lv2_errPrefix  VARCHAR2(100) := '-----Synonym Stmt Error List:-----';
   lv2_errorMsg   VARCHAR2(32767) := lv2_errPrefix;

BEGIN
   select substr(user, instr(user,'_')+1) into lv2_operation from dual;

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
END SyncPrivateSynonyms;


END ecdb_buildutils_asuser;