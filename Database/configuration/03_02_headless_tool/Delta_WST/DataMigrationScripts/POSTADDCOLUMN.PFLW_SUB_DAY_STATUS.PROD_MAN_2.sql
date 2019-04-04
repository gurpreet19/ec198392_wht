DECLARE 
     sqlQuery clob:='COMMENT ON COLUMN PFLW_SUB_DAY_STATUS.PROD_MAN_2 IS ''Prod Man 2 valve Status''';
BEGIN
     EXECUTE IMMEDIATE sqlQuery;
     dbms_output.put_line('SUCCESS: ' || sqlQuery);
     EXCEPTION     
         WHEN OTHERS THEN
            --UPDATE_MILESTONE_WITH_ERROR('post_add_table_column');
            raise_application_error(-20000, 'FATAL  ERROR: ' || sqlerrm);
END;
--~^UTDELIM^~--