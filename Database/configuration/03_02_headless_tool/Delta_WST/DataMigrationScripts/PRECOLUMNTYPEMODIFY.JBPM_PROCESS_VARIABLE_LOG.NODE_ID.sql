-- =================================
-- 02 - TABLE jbpm_PROCESS_VARIABLE_LOG
-- =================================
-- changes node_id column data type from number to varchar2
--
-- as Oracle only permits the operations when all cells in the column is null,
-- we have to create a temporary column, copy values to that one and move them
-- back after the column modification
--
-- the required change in data model file is to modify nodeId data type from
-- number to varchar2(512)
declare
    cursor c_constraint_name is
        SELECT CONSTRAINT_NAME
        FROM user_constraints
        WHERE constraint_type = 'P'
            AND table_name = 'JBPM_PROCESS_VARIABLE_LOG';

    v_pk_name varchar2(32);
begin
    for n in c_constraint_name loop
        v_pk_name := n.CONSTRAINT_NAME;
    end loop;

    execute immediate 'alter table JBPM_PROCESS_VARIABLE_LOG disable constraint ' || v_pk_name;
end;
--~^UTDELIM^~--

alter table jbpm_PROCESS_VARIABLE_LOG add node_id_new varchar2(512 char)
--~^UTDELIM^~--
DECLARE 
HASENTRY NUMBER;
BEGIN
SELECT COUNT(*) INTO HASENTRY FROM USER_TRIGGERS 
		WHERE TRIGGER_NAME = 'IU_JBPM_PROCESS_VARIABLE_LOG'; 
		IF HASENTRY > 0 THEN 
		EXECUTE IMMEDIATE 'ALTER TRIGGER IU_JBPM_PROCESS_VARIABLE_LOG DISABLE';
		END IF;
		
	update jbpm_PROCESS_VARIABLE_LOG set node_id_new = to_char(node_id);
	
SELECT COUNT(*) INTO HASENTRY FROM USER_TRIGGERS 
		WHERE TRIGGER_NAME = 'IU_JBPM_PROCESS_VARIABLE_LOG'; 
		IF HASENTRY > 0 THEN 
		EXECUTE IMMEDIATE 'ALTER TRIGGER IU_JBPM_PROCESS_VARIABLE_LOG ENABLE';
		END IF;
		
EXCEPTION
   WHEN OTHERS 
     THEN
       IF HASENTRY > 0 THEN 
           EXECUTE IMMEDIATE 'ALTER TRIGGER IU_JBPM_PROCESS_VARIABLE_LOG ENABLE';
       END IF;
        
        raise_application_error(-20000,
                            'ERROR: Some Other fatal error occured :- '||SQLERRM);
END;
--~^UTDELIM^~--

alter table jbpm_PROCESS_VARIABLE_LOG modify node_id null
--~^UTDELIM^~--
DECLARE 
HASENTRY NUMBER;
BEGIN
SELECT COUNT(*) INTO HASENTRY FROM USER_TRIGGERS 
		WHERE TRIGGER_NAME = 'IU_JBPM_PROCESS_VARIABLE_LOG'; 
		IF HASENTRY > 0 THEN 
		EXECUTE IMMEDIATE 'ALTER TRIGGER IU_JBPM_PROCESS_VARIABLE_LOG DISABLE';
		END IF;
		
	update jbpm_PROCESS_VARIABLE_LOG set node_id = null;
	
	SELECT COUNT(*) INTO HASENTRY FROM USER_TRIGGERS 
		WHERE TRIGGER_NAME = 'IU_JBPM_PROCESS_VARIABLE_LOG'; 
		IF HASENTRY > 0 THEN 
		EXECUTE IMMEDIATE 'ALTER TRIGGER IU_JBPM_PROCESS_VARIABLE_LOG ENABLE';
		END IF;
		
	EXCEPTION
   WHEN OTHERS 
     THEN
       IF HASENTRY > 0 THEN 
           EXECUTE IMMEDIATE 'ALTER TRIGGER IU_JBPM_PROCESS_VARIABLE_LOG ENABLE';
       END IF;
        
        raise_application_error(-20000,
                            'ERROR: Some Other fatal error occured :- '||SQLERRM);
END;
--~^UTDELIM^~--

alter table jbpm_PROCESS_VARIABLE_LOG modify node_id varchar2(512 char)
--~^UTDELIM^~--
DECLARE 
HASENTRY NUMBER;
BEGIN

SELECT COUNT(*) INTO HASENTRY FROM USER_TRIGGERS 
		WHERE TRIGGER_NAME = 'IU_JBPM_PROCESS_VARIABLE_LOG'; 
		IF HASENTRY > 0 THEN 
		EXECUTE IMMEDIATE 'ALTER TRIGGER IU_JBPM_PROCESS_VARIABLE_LOG DISABLE';
		END IF;
		
	update jbpm_PROCESS_VARIABLE_LOG set node_id = node_id_new;
	
	SELECT COUNT(*) INTO HASENTRY FROM USER_TRIGGERS 
		WHERE TRIGGER_NAME = 'IU_JBPM_PROCESS_VARIABLE_LOG'; 
		IF HASENTRY > 0 THEN 
		EXECUTE IMMEDIATE 'ALTER TRIGGER IU_JBPM_PROCESS_VARIABLE_LOG ENABLE';
		END IF;
		
	EXCEPTION
   WHEN OTHERS 
     THEN
       IF HASENTRY > 0 THEN 
           EXECUTE IMMEDIATE 'ALTER TRIGGER IU_JBPM_PROCESS_VARIABLE_LOG ENABLE';
       END IF;
        
        raise_application_error(-20000,
                            'ERROR: Some Other fatal error occured :- '||SQLERRM);
END;
--~^UTDELIM^~--

alter table jbpm_PROCESS_VARIABLE_LOG drop column node_id_new
--~^UTDELIM^~--

declare
    cursor c_constraint_name is
        SELECT CONSTRAINT_NAME
        FROM user_constraints
        WHERE constraint_type = 'P'
            AND table_name = 'JBPM_PROCESS_VARIABLE_LOG';

    v_pk_name varchar2(32);
begin
    for n in c_constraint_name loop
        v_pk_name := n.CONSTRAINT_NAME;
    end loop;

    execute immediate 'alter table JBPM_PROCESS_VARIABLE_LOG enable constraint ' || v_pk_name;
end;
--~^UTDELIM^~--
