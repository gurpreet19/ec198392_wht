 DECLARE 
HASENTRY NUMBER;
BEGIN
     SELECT COUNT(*) INTO HASENTRY FROM USER_TRIGGERS 
	 WHERE TRIGGER_NAME = 'IU_FCST_PWEL_DAY_JN'; 
	 
	 IF HASENTRY > 0 THEN 
	 EXECUTE IMMEDIATE 'ALTER TRIGGER IU_FCST_PWEL_DAY_JN DISABLE';
	 END IF;
	 
	UPDATE FCST_PWEL_DAY_JN 
	SET WATER_MASS_RATE = WATER_RATE_MASS;
	
	 IF HASENTRY > 0 THEN 
	 EXECUTE IMMEDIATE 'ALTER TRIGGER IU_FCST_PWEL_DAY_JN ENABLE';
	 END IF;
EXCEPTION
WHEN OTHERS THEN 	
	IF HASENTRY > 0 THEN 
        EXECUTE IMMEDIATE 'ALTER TRIGGER IU_FCST_PWEL_DAY_JN ENABLE';
    END IF;    
        raise_application_error(-20000,'ERROR: Some Other fatal error occured :- '||SQLERRM);
END;
--~^UTDELIM^~--