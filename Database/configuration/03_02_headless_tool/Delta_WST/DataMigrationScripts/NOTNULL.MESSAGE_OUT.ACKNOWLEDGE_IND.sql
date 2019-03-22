-- ECPD21577_MESSAGE_OUT  ...
DECLARE
HASENTRY NUMBER;
BEGIN
SELECT COUNT(*) INTO HASENTRY FROM USER_TRIGGERS 
		WHERE TRIGGER_NAME = 'IU_MESSAGE_OUT'; 
		IF HASENTRY > 0 THEN 
		EXECUTE IMMEDIATE 'ALTER TRIGGER IU_MESSAGE_OUT DISABLE';
		END IF;
UPDATE MESSAGE_OUT SET ACKNOWLEDGE_IND = 'N' WHERE ACKNOWLEDGE_IND IS NULL;

IF HASENTRY > 0 THEN 
		EXECUTE IMMEDIATE 'ALTER TRIGGER IU_MESSAGE_OUT ENABLE';
		END IF;

EXCEPTION
   WHEN OTHERS 
     THEN
       IF HASENTRY > 0 THEN 
           EXECUTE IMMEDIATE 'ALTER TRIGGER IU_MESSAGE_OUT ENABLE';
       END IF;
        
        raise_application_error(-20000,
                            'ERROR: Some Other fatal error occured :- '||SQLERRM);
							

END;
--~^UTDELIM^~--