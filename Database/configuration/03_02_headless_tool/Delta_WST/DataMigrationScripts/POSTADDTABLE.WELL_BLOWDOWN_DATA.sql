DECLARE 
	 sqlQuery clob:='COMMENT ON TABLE WELL_BLOWDOWN_DATA  IS ''It maintains Well test reading with frequency mentioned with corresponding well blowdown event.''';
BEGIN
     EXECUTE IMMEDIATE sqlQuery;
     dbms_output.put_line('SUCCESS: ' || sqlQuery);
     EXCEPTION     
         WHEN OTHERS THEN
            --UPDATE_MILESTONE_WITH_ERROR('post_add_table_column');
            raise_application_error(-20000, 'FATAL  ERROR: ' || sqlerrm);
END;
--~^UTDELIM^~--
