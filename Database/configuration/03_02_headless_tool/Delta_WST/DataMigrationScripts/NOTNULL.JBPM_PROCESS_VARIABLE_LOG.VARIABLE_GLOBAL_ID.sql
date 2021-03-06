DECLARE 
HASENTRY NUMBER;
BEGIN
SELECT COUNT(*) INTO HASENTRY FROM USER_TRIGGERS 
		WHERE TRIGGER_NAME = 'IU_JBPM_PROCESS_VARIABLE_LOG'; 
		IF HASENTRY > 0 THEN 
		EXECUTE IMMEDIATE 'ALTER TRIGGER IU_JBPM_PROCESS_VARIABLE_LOG DISABLE';
		END IF;
		
	update jbpm_PROCESS_VARIABLE_LOG set variable_global_id = 'fcd1bf1b/'|| NAME ||'/'|| NAME ||'/'|| VARIABLE_TYPE ||'/'|| NODE_ID ||'/'|| PROCESS_INSTANCE_ID where node_id <> '-1';
	
	SELECT COUNT(*) INTO HASENTRY FROM USER_TRIGGERS 
		WHERE TRIGGER_NAME = 'IU_JBPM_PROCESS_VARIABLE_LOG'; 
		IF HASENTRY > 0 THEN 
		EXECUTE IMMEDIATE 'ALTER TRIGGER IU_JBPM_PROCESS_VARIABLE_LOG ENABLE';
		END IF;
		
	EXCEPTION
   WHEN OTHERS 
     THEN
       IF HASENTRY > 0 THEN 
           EXECUTE IMMEDIATE 'ALTER TRIGGER IU_JBPM_PROCESS_VARIABLE_LOG ENABLE';
       END IF;
        
        raise_application_error(-20000,
                            'ERROR: Some Other fatal error occured :- '||SQLERRM);
END;
--~^UTDELIM^~--

DECLARE 
HASENTRY NUMBER;
BEGIN
SELECT COUNT(*) INTO HASENTRY FROM USER_TRIGGERS 
		WHERE TRIGGER_NAME = 'IU_JBPM_PROCESS_VARIABLE_LOG'; 
		IF HASENTRY > 0 THEN 
		EXECUTE IMMEDIATE 'ALTER TRIGGER IU_JBPM_PROCESS_VARIABLE_LOG DISABLE';
		END IF;
		
	update jbpm_PROCESS_VARIABLE_LOG set variable_global_id = 'fcd1bf1b/'|| NAME ||'/'|| NAME ||'/'|| VARIABLE_TYPE ||'//'|| PROCESS_INSTANCE_ID where node_id = '-1';
	
	SELECT COUNT(*) INTO HASENTRY FROM USER_TRIGGERS 
		WHERE TRIGGER_NAME = 'IU_JBPM_PROCESS_VARIABLE_LOG'; 
		IF HASENTRY > 0 THEN 
		EXECUTE IMMEDIATE 'ALTER TRIGGER IU_JBPM_PROCESS_VARIABLE_LOG ENABLE';
		END IF;
		
	EXCEPTION
   WHEN OTHERS 
     THEN
       IF HASENTRY > 0 THEN 
           EXECUTE IMMEDIATE 'ALTER TRIGGER IU_JBPM_PROCESS_VARIABLE_LOG ENABLE';
       END IF;
        
        raise_application_error(-20000,
                            'ERROR: Some Other fatal error occured :- '||SQLERRM);
END;
--~^UTDELIM^~--