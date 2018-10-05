DECLARE 
	 sqlQuery clob:='COMMENT ON COLUMN PWEL_SUB_DAY_STATUS.AVG_SAND_RATE_2 IS ''Measured Sand Rate 2 Value''';
BEGIN
     EXECUTE IMMEDIATE sqlQuery;
     dbms_output.put_line('SUCCESS: ' || sqlQuery);
     EXCEPTION     
         WHEN OTHERS THEN
            --UPDATE_MILESTONE_WITH_ERROR('post_add_table_column');
            raise_application_error(-20000, 'FATAL  ERROR: ' || sqlerrm);
END;
--~^UTDELIM^~--