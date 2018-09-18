DECLARE 
 	 constraint_not_exists exception;  
 	 pragma exception_init (constraint_not_exists , -02443);  
	 sqlQuery clob:='ALTER TABLE NETWORK_LAYOUT DROP CONSTRAINT PK_NETWORK_LAYOUT'; 
BEGIN 
	 EXECUTE IMMEDIATE sqlQuery; 
	 dbms_output.put_line('SUCCESS: ' || sqlQuery); 
	 EXCEPTION 
	 	  when constraint_not_exists  then 
  	 	 	 dbms_output.put_line('WARNING: ' || sqlQuery); 
  	 	 	 dbms_output.put_line('ORA-02443: Cannot drop constraint - nonexistent constraint'); 
  	 	 WHEN OTHERS THEN 
	 	 	 -- UPDATE_MILESTONE_WITH_ERROR('pre_table_column_not_null'); 
	 	 	 raise_application_error(-20000, 'FATAL  ERROR: ' || sqlerrm); 
END;
--~^UTDELIM^~--

DECLARE 
	 no_such_index  exception;  
 	 pragma exception_init (no_such_index , -01418);  
	 sqlQuery clob:='DROP INDEX PK_NETWORK_LAYOUT'; 
BEGIN 
	 EXECUTE IMMEDIATE sqlQuery; 
	 dbms_output.put_line('SUCCESS: ' || sqlQuery); 
	 EXCEPTION 
	 	 when no_such_index  then 
  	 	 	 dbms_output.put_line('WARNING: ' || sqlQuery); 
  	 	 	 dbms_output.put_line('ORA-01418: specified index does not exists'); 
  	 	 WHEN OTHERS THEN 
	 	 	 -- UPDATE_MILESTONE_WITH_ERROR('pre_table_column_not_null'); 
	 	 	 raise_application_error(-20000, 'FATAL  ERROR: ' || sqlerrm); 
END;
--~^UTDELIM^~--

BEGIN
	INSERT INTO network_layout (network_id, object_id, daytime, layout_info) 
       SELECT nl.network_id, ov.object_id, ov.daytime, nl.layout_info
       FROM   network_layout nl
       INNER  JOIN objects_version ov ON ov.object_id=nl.object_id
       WHERE  nl.daytime IS NULL;
END;
--~^UTDELIM^~--

BEGIN
	DELETE FROM network_layout WHERE daytime IS NULL;
END;
--~^UTDELIM^~--

DECLARE 
	 only_one_pk  exception;  
 	 pragma exception_init (only_one_pk , -02260);  
	 sqlQuery clob:='ALTER TABLE network_layout ADD CONSTRAINT pk_network_layout PRIMARY KEY (network_id, object_id)'; 
BEGIN 
	 EXECUTE IMMEDIATE sqlQuery; 
	 dbms_output.put_line('SUCCESS: ' || sqlQuery); 
	 EXCEPTION 
	 	 when only_one_pk  then 
  	 	 	 dbms_output.put_line('WARNING: ' || sqlQuery); 
  	 	 	 dbms_output.put_line('ORA-02260: table can have only one primary key'); 
  	 	 WHEN OTHERS THEN 
	 	 	 -- UPDATE_MILESTONE_WITH_ERROR('pre_table_column_not_null'); 
	 	 	 raise_application_error(-20000, 'FATAL  ERROR: ' || sqlerrm); 
END;
--~^UTDELIM^~--

