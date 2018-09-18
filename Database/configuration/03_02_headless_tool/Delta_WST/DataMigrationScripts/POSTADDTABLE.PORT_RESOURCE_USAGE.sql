DECLARE 
     sqlQuery clob:='COMMENT ON TABLE PORT_RESOURCE_USAGE IS ''This table will hold port resource usage objects based on port resource usage template.''';
BEGIN
     EXECUTE IMMEDIATE sqlQuery;
     dbms_output.put_line('SUCCESS: ' || sqlQuery);
     EXCEPTION     
         WHEN OTHERS THEN
            --UPDATE_MILESTONE_WITH_ERROR('add_table');
            raise_application_error(-20000, 'FATAL  ERROR: ' || sqlerrm);
END;
--~^UTDELIM^~--