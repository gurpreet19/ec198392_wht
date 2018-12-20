
ALTER TABLE JBPM_BPM_OBJ_META ADD VALUE_NEW VARCHAR2(2048 CHAR)
--~^UTDELIM^~--
DECLARE 
HASENTRY NUMBER;
BEGIN
SELECT COUNT(*) INTO HASENTRY FROM USER_TRIGGERS 
		WHERE TRIGGER_NAME = 'IU_JBPM_BPM_OBJ_META'; 
		IF HASENTRY > 0 THEN 
		EXECUTE IMMEDIATE 'ALTER TRIGGER IU_JBPM_BPM_OBJ_META DISABLE';
		END IF;
		
	UPDATE JBPM_BPM_OBJ_META SET VALUE_NEW = TO_CHAR(SUBSTR(VALUE, 1, 2047));
	
	SELECT COUNT(*) INTO HASENTRY FROM USER_TRIGGERS 
		WHERE TRIGGER_NAME = 'IU_JBPM_BPM_OBJ_META'; 
		IF HASENTRY > 0 THEN 
		EXECUTE IMMEDIATE 'ALTER TRIGGER IU_JBPM_BPM_OBJ_META ENABLE';
		END IF;
		
EXCEPTION
WHEN OTHERS THEN 	
	IF HASENTRY > 0 THEN 
        EXECUTE IMMEDIATE 'ALTER TRIGGER IU_JBPM_BPM_OBJ_META ENABLE';
    END IF;    
        raise_application_error(-20000,'ERROR: Some Other fatal error occured :- '||SQLERRM);
END;
--~^UTDELIM^~--

ALTER TABLE JBPM_BPM_OBJ_META DROP COLUMN VALUE
--~^UTDELIM^~--

ALTER TABLE JBPM_BPM_OBJ_META RENAME COLUMN VALUE_NEW TO VALUE
--~^UTDELIM^~--