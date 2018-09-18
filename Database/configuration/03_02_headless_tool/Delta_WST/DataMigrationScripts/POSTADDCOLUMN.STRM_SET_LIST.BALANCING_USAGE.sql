DECLARE
     HASENTRY NUMBER;
     sqlQuery clob:='UPDATE STRM_SET_LIST SET BALANCING_USAGE = ''PO.0124'' WHERE BALANCING_FLAG = ''Y''';
BEGIN
SELECT COUNT(*) INTO HASENTRY FROM USER_TRIGGERS 
		WHERE TRIGGER_NAME = 'IU_STRM_SET_LIST'; 
		IF HASENTRY > 0 THEN 
		EXECUTE IMMEDIATE 'ALTER TRIGGER IU_STRM_SET_LIST DISABLE';
		END IF;
		
     EXECUTE IMMEDIATE sqlQuery;
	 
	  SELECT COUNT(*) INTO HASENTRY FROM USER_TRIGGERS 
		WHERE TRIGGER_NAME = 'IU_STRM_SET_LIST'; 
		IF HASENTRY > 0 THEN 
		EXECUTE IMMEDIATE 'ALTER TRIGGER IU_STRM_SET_LIST ENABLE';
		END IF;
	 
     dbms_output.put_line('SUCCESS: ' || sqlQuery);
     dbms_output.put_line('No of Rows Updated:' || sql%rowcount);
     EXCEPTION
        WHEN OTHERS THEN
		IF HASENTRY > 0 THEN 
		EXECUTE IMMEDIATE 'ALTER TRIGGER IU_STRM_SET_LIST ENABLE';
		END IF;
         --UPDATE_MILESTONE_WITH_ERROR('post_data_model');
         raise_application_error(-20000, 'ERROR: Some Other fatal error occured' || SQLERRM);
 END;
--~^UTDELIM^~--


DECLARE 
	 sqlQuery clob:='COMMENT ON COLUMN STRM_SET_LIST.BALANCING_USAGE IS ''Screen usage for Daily and Monthly Balancing screens.''';
BEGIN
     EXECUTE IMMEDIATE sqlQuery;
     dbms_output.put_line('SUCCESS: ' || sqlQuery);
     EXCEPTION     
         WHEN OTHERS THEN
            --UPDATE_MILESTONE_WITH_ERROR('post_add_table_column');
            raise_application_error(-20000, 'FATAL  ERROR: ' || SQLERRM);
END;
--~^UTDELIM^~--


