DECLARE
  HASENTRY NUMBER;
BEGIN
  SELECT COUNT(*)
    INTO HASENTRY
    FROM USER_TRIGGERS
   WHERE TRIGGER_NAME = 'IU_FCST_STORAGE_MTH_JN';
  IF HASENTRY > 0 THEN
    EXECUTE IMMEDIATE 'ALTER TRIGGER IU_FCST_STORAGE_MTH_JN DISABLE';
  END IF;
  UPDATE FCST_STORAGE_MTH_JN SET GAS_MASS_RATE = NET_GAS_RATE_MASS;
  IF HASENTRY > 0 THEN
    EXECUTE IMMEDIATE 'ALTER TRIGGER IU_FCST_STORAGE_MTH_JN ENABLE';
  END IF;
EXCEPTION
WHEN OTHERS THEN 	
	IF HASENTRY > 0 THEN 
        EXECUTE IMMEDIATE 'ALTER TRIGGER IU_FCST_STORAGE_MTH_JN ENABLE';
    END IF;    
        raise_application_error(-20000,'ERROR: Some Other fatal error occured :- '||SQLERRM);

END;
--~^UTDELIM^~--
