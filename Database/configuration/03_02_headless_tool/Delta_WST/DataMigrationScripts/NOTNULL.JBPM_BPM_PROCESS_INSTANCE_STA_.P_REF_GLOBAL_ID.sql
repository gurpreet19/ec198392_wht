DECLARE 
HASENTRY NUMBER;
BEGIN
        SELECT COUNT(*) INTO HASENTRY FROM USER_TRIGGERS 
		WHERE TRIGGER_NAME = 'IU_JBPM_BPM_PROCESS_INSTANCE_STA_'; 
		IF HASENTRY > 0 THEN 
		EXECUTE IMMEDIATE 'ALTER TRIGGER IU_JBPM_BPM_PROCESS_INSTANCE_STA_ DISABLE';
		END IF;
		
	update JBPM_BPM_PROCESS_INSTANCE_STA_ set p_ref_global_id = '2e318fbf/' || substrc(pi_ref_global_id, instrc(pi_ref_global_id, '/', 10) + 1, length(pi_ref_global_id));
	
	
        SELECT COUNT(*) INTO HASENTRY FROM USER_TRIGGERS 
		WHERE TRIGGER_NAME = 'IU_JBPM_BPM_PROCESS_INSTANCE_STA_'; 
		IF HASENTRY > 0 THEN 
		EXECUTE IMMEDIATE 'ALTER TRIGGER IU_JBPM_BPM_PROCESS_INSTANCE_STA_ ENABLE';
		END IF;
		
	EXCEPTION
   WHEN OTHERS 
     THEN
       IF HASENTRY > 0 THEN 
           EXECUTE IMMEDIATE 'ALTER TRIGGER IU_JBPM_BPM_PROCESS_INSTANCE_STA_ ENABLE';
       END IF;
        
        raise_application_error(-20000,
                            'ERROR: Some Other fatal error occured :- '||SQLERRM);
END;
--~^UTDELIM^~--