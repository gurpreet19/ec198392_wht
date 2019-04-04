 DECLARE 
HASENTRY NUMBER;
BEGIN
     SELECT COUNT(*) INTO HASENTRY FROM USER_TRIGGERS 
	 WHERE TRIGGER_NAME = 'IU_FCST_PWEL_DAY'; 
	 
	 IF HASENTRY > 0 THEN 
	 EXECUTE IMMEDIATE 'ALTER TRIGGER IU_FCST_PWEL_DAY DISABLE';
	 END IF;
	 
	UPDATE FCST_PWEL_DAY 
	SET NET_OIL_MASS_RATE = NET_OIL_RATE_MASS;
	
		IF HASENTRY > 0 THEN 
	 EXECUTE IMMEDIATE 'ALTER TRIGGER IU_FCST_PWEL_DAY ENABLE';
	 END IF;
	 
EXCEPTION
WHEN OTHERS THEN 	
	IF HASENTRY > 0 THEN 
        EXECUTE IMMEDIATE 'ALTER TRIGGER IU_FCST_PWEL_DAY ENABLE';
    END IF;    
        raise_application_error(-20000,'ERROR: Some Other fatal error occured :- '||SQLERRM);
END;
--~^UTDELIM^~--