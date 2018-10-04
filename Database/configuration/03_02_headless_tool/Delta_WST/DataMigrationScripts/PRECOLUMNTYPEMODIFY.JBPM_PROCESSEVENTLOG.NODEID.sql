-- =================================
-- 01 - TABLE jbpm_ProcessEventLog
-- =================================
-- changes nodeId column data type from number to varchar2
--
-- as Oracle only permits the operations when all cells in the column is null,
-- we have to create a temporary column, copy values to that one and move them
-- back after the column modification
--
-- the required change in data model file is to modify nodeId data type from
-- number to varchar2(512)

alter table jbpm_ProcessEventLog add nodeId_new varchar2(512 char)
--~^UTDELIM^~--
DECLARE 
HASENTRY NUMBER;
BEGIN
SELECT COUNT(*) INTO HASENTRY FROM USER_TRIGGERS 
		WHERE TRIGGER_NAME = 'IU_JBPM_PROCESSEVENTLOG'; 
		IF HASENTRY > 0 THEN 
		EXECUTE IMMEDIATE 'ALTER TRIGGER IU_JBPM_PROCESSEVENTLOG DISABLE';
		END IF;
		
	update jbpm_ProcessEventLog set nodeId_new = to_char(nodeId);
	update jbpm_ProcessEventLog set nodeId = null;
	
SELECT COUNT(*) INTO HASENTRY FROM USER_TRIGGERS 
		WHERE TRIGGER_NAME = 'IU_JBPM_PROCESSEVENTLOG'; 
		IF HASENTRY > 0 THEN 
		EXECUTE IMMEDIATE 'ALTER TRIGGER IU_JBPM_PROCESSEVENTLOG ENABLE';
		END IF;
		
EXCEPTION
   WHEN OTHERS 
     THEN
       IF HASENTRY > 0 THEN 
           EXECUTE IMMEDIATE 'ALTER TRIGGER IU_JBPM_PROCESSEVENTLOG ENABLE';
       END IF;
        
        raise_application_error(-20000,
                            'ERROR: Some Other fatal error occured :- '||SQLERRM);
END;
--~^UTDELIM^~--

alter table jbpm_ProcessEventLog modify nodeId varchar2(512 char)
--~^UTDELIM^~--
DECLARE 
HASENTRY NUMBER;
BEGIN
SELECT COUNT(*) INTO HASENTRY FROM USER_TRIGGERS 
		WHERE TRIGGER_NAME = 'IU_JBPM_PROCESSEVENTLOG'; 
		IF HASENTRY > 0 THEN 
		EXECUTE IMMEDIATE 'ALTER TRIGGER IU_JBPM_PROCESSEVENTLOG DISABLE';
		END IF;
		
	update jbpm_ProcessEventLog set nodeId = nodeId_new;
	
	SELECT COUNT(*) INTO HASENTRY FROM USER_TRIGGERS 
		WHERE TRIGGER_NAME = 'IU_JBPM_PROCESSEVENTLOG'; 
		IF HASENTRY > 0 THEN 
		EXECUTE IMMEDIATE 'ALTER TRIGGER IU_JBPM_PROCESSEVENTLOG ENABLE';
		END IF;
		
	EXCEPTION
   WHEN OTHERS 
     THEN
       IF HASENTRY > 0 THEN 
           EXECUTE IMMEDIATE 'ALTER TRIGGER IU_JBPM_PROCESSEVENTLOG ENABLE';
       END IF;
        
        raise_application_error(-20000,
                            'ERROR: Some Other fatal error occured :- '||SQLERRM);
		
END;
--~^UTDELIM^~--

alter table jbpm_ProcessEventLog drop column nodeId_new
--~^UTDELIM^~--

alter table jbpm_ProcessEventLog add processinstanceid_new varchar2(255 char)
--~^UTDELIM^~--

alter table jbpm_ProcessEventLog modify processinstanceid null
--~^UTDELIM^~--
DECLARE 
HASENTRY NUMBER;
BEGIN
SELECT COUNT(*) INTO HASENTRY FROM USER_TRIGGERS 
		WHERE TRIGGER_NAME = 'IU_JBPM_PROCESSEVENTLOG'; 
		IF HASENTRY > 0 THEN 
		EXECUTE IMMEDIATE 'ALTER TRIGGER IU_JBPM_PROCESSEVENTLOG DISABLE';
		END IF;
		
	update jbpm_ProcessEventLog set processinstanceid_new = to_char(processinstanceid);
	update jbpm_ProcessEventLog set processinstanceid = null;
	
	SELECT COUNT(*) INTO HASENTRY FROM USER_TRIGGERS 
		WHERE TRIGGER_NAME = 'IU_JBPM_PROCESSEVENTLOG'; 
		IF HASENTRY > 0 THEN 
		EXECUTE IMMEDIATE 'ALTER TRIGGER IU_JBPM_PROCESSEVENTLOG ENABLE';
		END IF;
		
	EXCEPTION
   WHEN OTHERS 
     THEN
       IF HASENTRY > 0 THEN 
           EXECUTE IMMEDIATE 'ALTER TRIGGER IU_JBPM_PROCESSEVENTLOG ENABLE';
       END IF;
        
        raise_application_error(-20000,
                            'ERROR: Some Other fatal error occured :- '||SQLERRM);
END;
--~^UTDELIM^~--

alter table jbpm_ProcessEventLog modify processinstanceid varchar2(255 char)
--~^UTDELIM^~--
DECLARE 
HASENTRY NUMBER;
BEGIN
SELECT COUNT(*) INTO HASENTRY FROM USER_TRIGGERS 
		WHERE TRIGGER_NAME = 'IU_JBPM_PROCESSEVENTLOG'; 
		IF HASENTRY > 0 THEN 
		EXECUTE IMMEDIATE 'ALTER TRIGGER IU_JBPM_PROCESSEVENTLOG DISABLE';
		END IF;
		
	update jbpm_ProcessEventLog set processinstanceid = processinstanceid_new;
	
	SELECT COUNT(*) INTO HASENTRY FROM USER_TRIGGERS 
		WHERE TRIGGER_NAME = 'IU_JBPM_PROCESSEVENTLOG'; 
		IF HASENTRY > 0 THEN 
		EXECUTE IMMEDIATE 'ALTER TRIGGER IU_JBPM_PROCESSEVENTLOG ENABLE';
		END IF;
		
EXCEPTION
   WHEN OTHERS 
     THEN
       IF HASENTRY > 0 THEN 
           EXECUTE IMMEDIATE 'ALTER TRIGGER IU_JBPM_PROCESSEVENTLOG ENABLE';
       END IF;
        
        raise_application_error(-20000,
                            'ERROR: Some Other fatal error occured :- '||SQLERRM);
END;
--~^UTDELIM^~--

alter table jbpm_ProcessEventLog drop column processinstanceid_new
--~^UTDELIM^~--

alter table jbpm_ProcessEventLog modify processinstanceid not null
--~^UTDELIM^~--