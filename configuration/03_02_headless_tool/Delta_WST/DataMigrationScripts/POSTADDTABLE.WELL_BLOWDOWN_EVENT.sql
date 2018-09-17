DECLARE 
	 sqlQuery clob:='COMMENT ON TABLE WELL_BLOWDOWN_EVENT  is ''It maintains Well Blowdown event information like date and time of event, reason and frequency with which test is conducted. Related to WR.0079''';
BEGIN
     EXECUTE IMMEDIATE sqlQuery;
     dbms_output.put_line('SUCCESS: ' || sqlQuery);
     EXCEPTION     
         WHEN OTHERS THEN
            --UPDATE_MILESTONE_WITH_ERROR('post_add_table_column');
            raise_application_error(-20000, 'FATAL  ERROR: ' || sqlerrm);
END;
--~^UTDELIM^~--
