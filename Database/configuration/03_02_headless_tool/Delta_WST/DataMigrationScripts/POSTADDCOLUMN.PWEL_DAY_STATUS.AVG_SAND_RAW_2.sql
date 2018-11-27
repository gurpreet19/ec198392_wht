DECLARE 
	 sqlQuery clob:='COMMENT ON COLUMN PWEL_DAY_STATUS.AVG_SAND_RAW_2 IS ''Measured Sand Raw 2 Value''';
BEGIN
     EXECUTE IMMEDIATE sqlQuery;
     dbms_output.put_line('SUCCESS: ' || sqlQuery);
     EXCEPTION     
         WHEN OTHERS THEN
            --UPDATE_MILESTONE_WITH_ERROR('post_add_table_column');
            raise_application_error(-20000, 'FATAL  ERROR: ' || sqlerrm);
END;
--~^UTDELIM^~--