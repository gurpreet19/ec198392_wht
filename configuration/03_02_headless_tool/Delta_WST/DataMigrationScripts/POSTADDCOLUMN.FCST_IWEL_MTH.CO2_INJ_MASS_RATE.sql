DECLARE 
HASENTRY NUMBER;
BEGIN
     SELECT COUNT(*) INTO HASENTRY FROM USER_TRIGGERS 
	 WHERE TRIGGER_NAME = 'IU_FCST_IWEL_MTH'; 
	 
	 IF HASENTRY > 0 THEN 
	 EXECUTE IMMEDIATE 'ALTER TRIGGER IU_FCST_IWEL_MTH DISABLE';
	 END IF;
	 
	UPDATE FCST_IWEL_MTH 
	SET CO2_INJ_MASS_RATE = CO2_RATE_MASS_MTH;
	
	
	IF HASENTRY > 0 THEN 
	 EXECUTE IMMEDIATE 'ALTER TRIGGER IU_FCST_IWEL_MTH ENABLE';
	 END IF;
	 
EXCEPTION
WHEN OTHERS THEN 	
	IF HASENTRY > 0 THEN 
        EXECUTE IMMEDIATE 'ALTER TRIGGER IU_FCST_IWEL_MTH ENABLE';
    END IF;    
        raise_application_error(-20000,'ERROR: Some Other fatal error occured :- '||SQLERRM);
END;
--~^UTDELIM^~--