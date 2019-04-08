-- ECPD25043_LIFTING_ACTIVITY_CODE_UPGRADE...
DECLARE 
HASENTRY NUMBER;
BEGIN
	SELECT COUNT(*) INTO HASENTRY FROM USER_TRIGGERS 
		WHERE TRIGGER_NAME = 'IU_LIFTING_ACTIVITY_CODE'; 
		IF HASENTRY > 0 THEN 
		EXECUTE IMMEDIATE 'ALTER TRIGGER IU_LIFTING_ACTIVITY_CODE DISABLE';
		END IF;

	UPDATE LIFTING_ACTIVITY_CODE SET LIFTING_TYPE = 'LOAD' WHERE LIFTING_START_IND = 'Y' OR LIFTING_START_IND = 'Y';
	
	SELECT COUNT(*) INTO HASENTRY FROM USER_TRIGGERS 
		WHERE TRIGGER_NAME = 'IU_LIFTING_ACTIVITY_CODE'; 
		IF HASENTRY > 0 THEN 
		EXECUTE IMMEDIATE 'ALTER TRIGGER IU_LIFTING_ACTIVITY_CODE ENABLE';
		END IF;
EXCEPTION
   WHEN OTHERS 
     THEN

       IF HASENTRY > 0 THEN 
           EXECUTE IMMEDIATE 'ALTER TRIGGER IU_LIFTING_ACTIVITY_CODE ENABLE';
       END IF;
        
        raise_application_error(-20000,
                            'ERROR: Some Other fatal error occured :- '||SQLERRM);


END;
--~^UTDELIM^~--