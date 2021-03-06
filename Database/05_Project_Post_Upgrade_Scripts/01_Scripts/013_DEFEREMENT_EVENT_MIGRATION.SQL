DECLARE
     HASENTRY NUMBER;
     sqlQuery clob:='UPDATE DEFERMENT_EVENT SET CLASS_NAME =''WELL_DEFERMENT_CHILD'' WHERE DEFERMENT_TYPE=''GROUP_CHILD'' AND CLASS_NAME IS NULL';
BEGIN

     SELECT COUNT(*) INTO HASENTRY FROM USER_TRIGGERS 
		WHERE TRIGGER_NAME = 'IU_WELL_DEFERMENT'; 
		IF HASENTRY > 0 THEN 
		EXECUTE IMMEDIATE 'ALTER TRIGGER IU_WELL_DEFERMENT DISABLE';
		END IF;
		
     EXECUTE IMMEDIATE sqlQuery;
	 
	  SELECT COUNT(*) INTO HASENTRY FROM USER_TRIGGERS 
		WHERE TRIGGER_NAME = 'IU_WELL_DEFERMENT'; 
		IF HASENTRY > 0 THEN 
		EXECUTE IMMEDIATE 'ALTER TRIGGER IU_WELL_DEFERMENT ENABLE';
		END IF;
		
    -- dbms_output.put_line('SUCCESS: ' || sqlQuery);
    -- dbms_output.put_line('No of Rows Updated:' || sql%rowcount);
     EXCEPTION
        WHEN OTHERS THEN
		IF HASENTRY > 0 THEN 
		EXECUTE IMMEDIATE 'ALTER TRIGGER IU_WELL_DEFERMENT ENABLE';
		END IF;
         --UPDATE_MILESTONE_WITH_ERROR('post_data_model');
         raise_application_error(-20000, 'ERROR: Some Other fatal error occured' || SQLERRM);
 END;
/



DECLARE
   HASENTRY NUMBER;
     sqlQuery clob:='UPDATE DEFERMENT_EVENT_JN SET CLASS_NAME =''WELL_DEFERMENT_CHILD'' WHERE DEFERMENT_TYPE=''GROUP_CHILD'' AND CLASS_NAME IS NULL';
BEGIN
  
       SELECT COUNT(*) INTO HASENTRY FROM USER_TRIGGERS 
		WHERE TRIGGER_NAME = 'IU_WELL_DEFERMENT_JN'; 
		IF HASENTRY > 0 THEN 
		EXECUTE IMMEDIATE 'ALTER TRIGGER IU_WELL_DEFERMENT_JN DISABLE';
		END IF;
		
     EXECUTE IMMEDIATE sqlQuery;
	 
	   SELECT COUNT(*) INTO HASENTRY FROM USER_TRIGGERS 
		WHERE TRIGGER_NAME = 'IU_WELL_DEFERMENT_JN'; 
		IF HASENTRY > 0 THEN 
		EXECUTE IMMEDIATE 'ALTER TRIGGER IU_WELL_DEFERMENT_JN ENABLE';
		END IF;
		
   --  dbms_output.put_line('SUCCESS: ' || sqlQuery);
  --   dbms_output.put_line('No of Rows Updated:' || sql%rowcount);
     EXCEPTION
        WHEN OTHERS THEN
		IF HASENTRY > 0 THEN 
		EXECUTE IMMEDIATE 'ALTER TRIGGER IU_WELL_DEFERMENT_JN ENABLE';
		END IF;
         --UPDATE_MILESTONE_WITH_ERROR('post_data_model');
         raise_application_error(-20000, 'ERROR: Some Other fatal error occured' || SQLERRM);
 END;
 /
 
 
 DECLARE
        HASENTRY NUMBER;
     sqlQuery clob:='UPDATE DEFERMENT_EVENT SET CLASS_NAME =''WELL_DEFERMENT'' WHERE DEFERMENT_TYPE IN (''GROUP'',''SINGLE'') AND CLASS_NAME IS NULL';
BEGIN

      SELECT COUNT(*) INTO HASENTRY FROM USER_TRIGGERS 
		WHERE TRIGGER_NAME = 'IU_WELL_DEFERMENT'; 
		IF HASENTRY > 0 THEN 
		EXECUTE IMMEDIATE 'ALTER TRIGGER IU_WELL_DEFERMENT DISABLE';
		END IF;
		
     EXECUTE IMMEDIATE sqlQuery;
	 
	  SELECT COUNT(*) INTO HASENTRY FROM USER_TRIGGERS 
		WHERE TRIGGER_NAME = 'IU_WELL_DEFERMENT'; 
		IF HASENTRY > 0 THEN 
		EXECUTE IMMEDIATE 'ALTER TRIGGER IU_WELL_DEFERMENT ENABLE';
		END IF;
		
	 
    -- dbms_output.put_line('SUCCESS: ' || sqlQuery);
    -- dbms_output.put_line('No of Rows Updated:' || sql%rowcount);
     EXCEPTION
        WHEN OTHERS THEN
		IF HASENTRY > 0 THEN 
		EXECUTE IMMEDIATE 'ALTER TRIGGER IU_WELL_DEFERMENT ENABLE';
		END IF;
         --UPDATE_MILESTONE_WITH_ERROR('post_data_model');
         raise_application_error(-20000, 'ERROR: Some Other fatal error occured' || SQLERRM);
 END;
 /
 
 DECLARE
      HASENTRY NUMBER;
     sqlQuery clob:='UPDATE DEFERMENT_EVENT_JN SET CLASS_NAME =''WELL_DEFERMENT'' WHERE DEFERMENT_TYPE IN (''GROUP'',''SINGLE'') AND CLASS_NAME IS NULL';
BEGIN

     
	  SELECT COUNT(*) INTO HASENTRY FROM USER_TRIGGERS 
		WHERE TRIGGER_NAME = 'IU_WELL_DEFERMENT_JN'; 
		IF HASENTRY > 0 THEN 
		EXECUTE IMMEDIATE 'ALTER TRIGGER IU_WELL_DEFERMENT_JN DISABLE';
		END IF;
		
     EXECUTE IMMEDIATE sqlQuery;
	 
	   SELECT COUNT(*) INTO HASENTRY FROM USER_TRIGGERS 
		WHERE TRIGGER_NAME = 'IU_WELL_DEFERMENT_JN'; 
		IF HASENTRY > 0 THEN 
		EXECUTE IMMEDIATE 'ALTER TRIGGER IU_WELL_DEFERMENT_JN ENABLE';
		END IF;
		
	 
   --  dbms_output.put_line('SUCCESS: ' || sqlQuery);
    -- dbms_output.put_line('No of Rows Updated:' || sql%rowcount);
     EXCEPTION
        WHEN OTHERS THEN
		IF HASENTRY > 0 THEN 
		EXECUTE IMMEDIATE 'ALTER TRIGGER IU_WELL_DEFERMENT_JN ENABLE';
		END IF;
         --UPDATE_MILESTONE_WITH_ERROR('post_data_model');
         raise_application_error(-20000, 'ERROR: Some Other fatal error occured' || SQLERRM);
 END;
/
 