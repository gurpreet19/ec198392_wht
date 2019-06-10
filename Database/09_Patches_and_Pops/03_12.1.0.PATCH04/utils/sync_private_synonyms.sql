Prompt Starting sync_private_synonyms.sql, arg1: &&operation

DECLARE
   lv2_operation  VARCHAR2(100) := '&operation';
   lv2_sql        VARCHAR2(2000);
   lv2_errPrefix  VARCHAR2(100) := '-----Synonym Stmt Error List:-----';
   lv2_errorMsg   VARCHAR2(32767) := lv2_errPrefix;

BEGIN
   lv2_operation := UPPER(lv2_operation); -- The owner name in the Oracle dictionary is in upper case

   lv2_sql := 'BEGIN ECKERNEL_' || lv2_operation || '.ECDB_BUILDUTILS_ASUSER.SyncPrivateSynonyms; END;';

   BEGIN
        EXECUTE IMMEDIATE lv2_sql;
    EXCEPTION
    WHEN OTHERS THEN
        IF (length(lv2_errorMsg) + length(lv2_sql) + length(sqlerrm) + 100) < 32767 THEN
        lv2_errorMsg := lv2_errorMsg || chr(10) || 'Synonym stmt failed: [' || lv2_sql || ']. Error msg: [' || sqlerrm || ']';
        END IF;
    END;

   IF length(lv2_errorMsg) > length(lv2_errPrefix) THEN
     raise_application_error(-20000, 'Error when executing "sync_private_synonyms.sql". The following statements failed:' || chr(10) || lv2_errorMsg);
   END IF;
END;
/
