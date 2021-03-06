DECLARE 
HASENTRY NUMBER; 
BEGIN
	SELECT COUNT(*) INTO HASENTRY FROM USER_TRIGGERS 
		WHERE TRIGGER_NAME = 'IU_EQUIPMENT'; 
		IF HASENTRY > 0 THEN 
		EXECUTE IMMEDIATE 'ALTER TRIGGER IU_EQUIPMENT DISABLE';
		END IF;

	UPDATE EQUIPMENT SET EQPM_TYPE = CLASS_NAME WHERE EQPM_TYPE IS NULL;
	UPDATE EQUIPMENT SET CLASS_NAME = 'EQPM' WHERE EQPM_TYPE <> 'TEST_DEVICE';
		
	SELECT COUNT(*) INTO HASENTRY FROM USER_TRIGGERS 
		WHERE TRIGGER_NAME = 'IU_EQUIPMENT'; 
		IF HASENTRY > 0 THEN 
		EXECUTE IMMEDIATE 'ALTER TRIGGER IU_EQUIPMENT ENABLE';
		END IF;
EXCEPTION
   WHEN OTHERS 
     THEN

       IF HASENTRY > 0 THEN 
           EXECUTE IMMEDIATE 'ALTER TRIGGER IU_EQUIPMENT ENABLE';
       END IF;
        
        raise_application_error(-20000,
                            'ERROR: Some Other fatal error occured :- '||SQLERRM);

END;
--~^UTDELIM^~--	