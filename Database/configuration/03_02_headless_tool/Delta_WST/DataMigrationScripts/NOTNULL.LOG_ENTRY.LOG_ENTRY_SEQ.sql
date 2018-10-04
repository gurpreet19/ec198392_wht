-- ECPD-25675_2_LOG_ENTRY_UPGRADE_SCRIPT...
--upgrade script table log_entry
DECLARE 
HASENTRY NUMBER;
BEGIN
	SELECT COUNT(*) INTO HASENTRY FROM USER_TRIGGERS 
		WHERE TRIGGER_NAME = 'IU_LOG_ENTRY'; 
		IF HASENTRY > 0 THEN 
		EXECUTE IMMEDIATE 'ALTER TRIGGER IU_LOG_ENTRY DISABLE';
		END IF;

	UPDATE LOG_ENTRY SET LOG_ENTRY_SEQ = ECDP_SYSTEM_KEY.ASSIGNNEXTNUMBER('LOG_ENTRY') WHERE LOG_ENTRY.LOG_ENTRY_SEQ IS NULL;
	
	SELECT COUNT(*) INTO HASENTRY FROM USER_TRIGGERS 
		WHERE TRIGGER_NAME = 'IU_LOG_ENTRY'; 
		IF HASENTRY > 0 THEN 
		EXECUTE IMMEDIATE 'ALTER TRIGGER IU_LOG_ENTRY ENABLE';
		END IF;
EXCEPTION
   WHEN OTHERS 
     THEN
        IF HASENTRY > 0 THEN 
           EXECUTE IMMEDIATE 'ALTER TRIGGER IU_LOG_ENTRY ENABLE';
       END IF;
    raise_application_error(-20000,
                            'ERROR: Some Other fatal error occured :- '||SQLERRM);
  
END;
--~^UTDELIM^~--
