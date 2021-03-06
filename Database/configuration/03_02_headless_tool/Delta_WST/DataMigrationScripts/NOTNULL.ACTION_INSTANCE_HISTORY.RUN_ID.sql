DECLARE
  cursor cur_id is 
    select ACTION_INSTANCE_NO, DAYTIME
      from ACTION_INSTANCE_HISTORY
      where RUN_ID IS NULL;
	
	HASENTRY NUMBER;
BEGIN
   SELECT COUNT(*) INTO HASENTRY FROM USER_TRIGGERS 
	 WHERE TRIGGER_NAME = 'IU_ACTION_INSTANCE_HISTORY'; 
	 
	 IF HASENTRY > 0 THEN 
	 EXECUTE IMMEDIATE 'ALTER TRIGGER IU_ACTION_INSTANCE_HISTORY DISABLE';
	 END IF;

  FOR i in cur_id LOOP
    BEGIN
        UPDATE ACTION_INSTANCE_HISTORY
           SET RUN_ID = (select EcDp_System_key.assignNextNumber('ACTION_INSTANCE_HISTORY') from dual)
         WHERE ACTION_INSTANCE_NO = i.ACTION_INSTANCE_NO
           AND DAYTIME = i.DAYTIME;
         
    EXCEPTION
      WHEN OTHERS THEN
        NULL;
    END;
  END LOOP;
  COMMIT;
  
   IF HASENTRY > 0 THEN 
	 EXECUTE IMMEDIATE 'ALTER TRIGGER IU_ACTION_INSTANCE_HISTORY ENABLE';
	 END IF; 	
EXCEPTION
WHEN OTHERS THEN 	
	IF HASENTRY > 0 THEN 
        EXECUTE IMMEDIATE 'ALTER TRIGGER IU_ACTION_INSTANCE_HISTORY ENABLE';
    END IF;    
        raise_application_error(-20000,'ERROR: Some Other fatal error occured :- '||SQLERRM);
END;
--~^UTDELIM^~--
