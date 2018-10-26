DECLARE 
HASENTRY NUMBER;
BEGIN 
	SELECT COUNT(*) INTO HASENTRY FROM USER_TRIGGERS 
		WHERE TRIGGER_NAME = 'IU_CONTRACT_ACCOUNT'; 
		IF HASENTRY > 0 THEN 
		EXECUTE IMMEDIATE 'ALTER TRIGGER IU_CONTRACT_ACCOUNT DISABLE';
		END IF;

	UPDATE CONTRACT_ACCOUNT SET DAYTIME=EC_CONTRACT.START_DATE(OBJECT_ID) WHERE DAYTIME IS NULL;
	
	SELECT COUNT(*) INTO HASENTRY FROM USER_TRIGGERS 
		WHERE TRIGGER_NAME = 'IU_CONTRACT_ACCOUNT'; 
		IF HASENTRY > 0 THEN 
		EXECUTE IMMEDIATE 'ALTER TRIGGER IU_CONTRACT_ACCOUNT ENABLE';
		END IF;
EXCEPTION
   WHEN OTHERS 
     THEN

       IF HASENTRY > 0 THEN 
           EXECUTE IMMEDIATE 'ALTER TRIGGER IU_CONTRACT_ACCOUNT ENABLE';
       END IF;
        
        raise_application_error(-20000,
                            'ERROR: Some Other fatal error occured :- '||SQLERRM);


END;
--~^UTDELIM^~--	