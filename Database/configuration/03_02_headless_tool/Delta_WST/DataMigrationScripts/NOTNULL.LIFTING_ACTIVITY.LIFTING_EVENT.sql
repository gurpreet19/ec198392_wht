DECLARE 
HASENTRY NUMBER;
BEGIN 
	SELECT COUNT(*) INTO HASENTRY FROM USER_TRIGGERS 
		WHERE TRIGGER_NAME = 'IU_LIFTING_ACTIVITY'; 
		IF HASENTRY > 0 THEN 
		EXECUTE IMMEDIATE 'ALTER TRIGGER IU_LIFTING_ACTIVITY DISABLE';
		END IF;

	UPDATE LIFTING_ACTIVITY A SET A.LIFTING_EVENT = (SELECT B.LIFTING_EVENT FROM LIFTING_ACTIVITY_CODE B WHERE A.ACTIVITY_CODE = B.ACTIVITY_CODE) WHERE A.LIFTING_EVENT IS NULL;
	
	SELECT COUNT(*) INTO HASENTRY FROM USER_TRIGGERS 
		WHERE TRIGGER_NAME = 'IU_LIFTING_ACTIVITY'; 
		IF HASENTRY > 0 THEN 
		EXECUTE IMMEDIATE 'ALTER TRIGGER IU_LIFTING_ACTIVITY ENABLE';
		END IF;
EXCEPTION
   WHEN OTHERS 
     THEN

       IF HASENTRY > 0 THEN 
           EXECUTE IMMEDIATE 'ALTER TRIGGER IU_LIFTING_ACTIVITY ENABLE';
       END IF;
        
        raise_application_error(-20000,
                            'ERROR: Some Other fatal error occured :- '||SQLERRM);


END;
--~^UTDELIM^~--	