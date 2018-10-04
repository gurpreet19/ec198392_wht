DECLARE
  HASENTRY NUMBER;
BEGIN
  SELECT COUNT(*)
    INTO HASENTRY
    FROM USER_TRIGGERS
   WHERE TRIGGER_NAME = 'IU_FCST_STORAGE_MTH';
  IF HASENTRY > 0 THEN
    EXECUTE IMMEDIATE 'ALTER TRIGGER IU_FCST_STORAGE_MTH DISABLE';
  END IF;
  UPDATE FCST_STORAGE_MTH SET NET_LIQ_MASS_RATE = NET_LIQ_RATE_MASS;
  IF HASENTRY > 0 THEN
    EXECUTE IMMEDIATE 'ALTER TRIGGER IU_FCST_STORAGE_MTH ENABLE';
  END IF;
EXCEPTION
WHEN OTHERS THEN 	
	IF HASENTRY > 0 THEN 
        EXECUTE IMMEDIATE 'ALTER TRIGGER IU_FCST_STORAGE_MTH ENABLE';
    END IF;    
        raise_application_error(-20000,'ERROR: Some Other fatal error occured :- '||SQLERRM);

END;
--~^UTDELIM^~--
