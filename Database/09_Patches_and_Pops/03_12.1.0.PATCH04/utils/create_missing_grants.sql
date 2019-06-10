Prompt Starting create_missing_grants.sql, arg1: &&operation

DECLARE

   lv2_operation  VARCHAR2(100) := '&operation';   

BEGIN
  
   lv2_operation := UPPER(lv2_operation); -- The grantee name in the Oracle dictionary is in upper case

   ecdp_dynsql.execute_statement('DELETE FROM T_TEMPTEXT WHERE ID = ''GRANT_MISSING''');
   commit;

   ECDB_BUILDUTILS.CreateMissingGrants('APP_READ_ROLE_' || lv2_operation,'READ');   
   ECDB_BUILDUTILS.CreateMissingGrants('APP_WRITE_ROLE_' || lv2_operation,'WRITE');   
   ECDB_BUILDUTILS.CreateMissingGrants('REPORT_ROLE_' || lv2_operation,'REPORT');   
   
END;
/
