DECLARE 
HASENTRY NUMBER;
BEGIN
	-- The script below will move the data from PERF_INTERVAL.RESV_BLOCK_FORMATION_ID to PERF_INTERVAL_VERSION.RESV_BLOCK_FORMATION_ID.
	-- RESV_BLOCK_FORMATION_ID will be dropped from PERF_INTERVAL table and the column is now available in PERF_INTERVAL_VERSION table.
	SELECT COUNT(*) INTO HASENTRY FROM USER_TRIGGERS 
		WHERE TRIGGER_NAME = 'IU_PERF_INTERVAL_VERSION'; 
		IF HASENTRY > 0 THEN 
		EXECUTE IMMEDIATE 'ALTER TRIGGER IU_PERF_INTERVAL_VERSION DISABLE';
		END IF;
		
			UPDATE PERF_INTERVAL_VERSION PIV 
			SET PIV.RESV_BLOCK_FORMATION_ID = (SELECT PI.RESV_BLOCK_FORMATION_ID FROM PERF_INTERVAL PI WHERE PI.OBJECT_ID = PIV.OBJECT_ID) 
			WHERE PIV.RESV_BLOCK_FORMATION_ID IS NULL;
	
	SELECT COUNT(*) INTO HASENTRY FROM USER_TRIGGERS 
		WHERE TRIGGER_NAME = 'IU_PERF_INTERVAL_VERSION'; 
		IF HASENTRY > 0 THEN 
		EXECUTE IMMEDIATE 'ALTER TRIGGER IU_PERF_INTERVAL_VERSION ENABLE';
		END IF;
EXCEPTION
   WHEN OTHERS 
     THEN

       IF HASENTRY > 0 THEN 
           EXECUTE IMMEDIATE 'ALTER TRIGGER IU_PERF_INTERVAL_VERSION ENABLE';
       END IF;
        
        raise_application_error(-20000,
                            'ERROR: Some Other fatal error occured :- '||SQLERRM);


END;
--~^UTDELIM^~--