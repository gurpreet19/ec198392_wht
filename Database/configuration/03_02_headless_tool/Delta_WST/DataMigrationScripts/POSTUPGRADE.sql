select EcDp_System_key.assignNextNumber('MHM_MSG') from dual
--~^UTDELIM^~--	

BEGIN
	UPDATE assign_id SET MAX_ID = (select CASE WHEN MAX(MESSAGE_ID) IS NULL THEN 1 ELSE MAX(MESSAGE_ID) + 1 END from mhm_msg) WHERE TABLENAME = 'MHM_MSG';
END;
--~^UTDELIM^~--	

-- task domain
DECLARE 
HASENTRY NUMBER;
BEGIN
SELECT COUNT(*) INTO HASENTRY FROM USER_TRIGGERS 
		WHERE TRIGGER_NAME = 'IU_JBPM_BMP_OBJ'; 
		IF HASENTRY > 0 THEN 
		EXECUTE IMMEDIATE 'ALTER TRIGGER IU_JBPM_BMP_OBJ DISABLE';
		END IF;
		
	update jbpm_bpm_obj
	set OWNER_GLOBAL_ID = 'c27771a1/' || OWNER_GLOBAL_ID,
		OWNER_REF_JSON = EcDp_BPM_util_json.insert_array_element(OWNER_REF_JSON, '"c27771a1"', 0)
	where VALUE_TYPE_NAME in (
		'com.ec.bpm.domain.task.reads.TaskResult',
		'com.ec.bpm.domain.task.reads.TaskSummary',
		'com.ec.bpm.domain.task.reads.TaskDetail');
		
 SELECT COUNT(*) INTO HASENTRY FROM USER_TRIGGERS 
		WHERE TRIGGER_NAME = 'IU_JBPM_BMP_OBJ'; 
		IF HASENTRY > 0 THEN 
		EXECUTE IMMEDIATE 'ALTER TRIGGER IU_JBPM_BMP_OBJ ENABLE';
		END IF;
		
	 EXCEPTION
   WHEN OTHERS 
     THEN
       IF HASENTRY > 0 THEN 
           EXECUTE IMMEDIATE 'ALTER TRIGGER IU_JBPM_BMP_OBJ ENABLE';
       END IF;
        
        raise_application_error(-20000,
                            'ERROR: Some Other fatal error occured :- '||SQLERRM);
END;
--~^UTDELIM^~--
DECLARE 
HASENTRY NUMBER;
BEGIN

SELECT COUNT(*) INTO HASENTRY FROM USER_TRIGGERS 
		WHERE TRIGGER_NAME = 'IU_JBPM_BMP_OBJ'; 
		IF HASENTRY > 0 THEN 
		EXECUTE IMMEDIATE 'ALTER TRIGGER IU_JBPM_BMP_OBJ DISABLE';
		END IF;
		
		
	update jbpm_bpm_obj
	set VALUE = EcDp_BPM_util_json_clob.replace_value(
			VALUE,
			'_of/.class',
			'"com.ec.bpm.domain.process.model.task.UserTaskRef"')
	where VALUE_TYPE_NAME in (
		'com.ec.bpm.domain.task.reads.TaskResult',
		'com.ec.bpm.domain.task.reads.TaskSummary',
		'com.ec.bpm.domain.task.reads.TaskDetail');
		
			SELECT COUNT(*) INTO HASENTRY FROM USER_TRIGGERS 
		WHERE TRIGGER_NAME = 'IU_JBPM_BMP_OBJ'; 
		IF HASENTRY > 0 THEN 
		EXECUTE IMMEDIATE 'ALTER TRIGGER IU_JBPM_BMP_OBJ ENABLE';
		END IF;
		
	 EXCEPTION
   WHEN OTHERS 
     THEN
       IF HASENTRY > 0 THEN 
           EXECUTE IMMEDIATE 'ALTER TRIGGER IU_JBPM_BMP_OBJ ENABLE';
       END IF;
        
        raise_application_error(-20000,
                            'ERROR: Some Other fatal error occured :- '||SQLERRM);
END;
--~^UTDELIM^~--
DECLARE 
HASENTRY NUMBER;
BEGIN
SELECT COUNT(*) INTO HASENTRY FROM USER_TRIGGERS 
		WHERE TRIGGER_NAME = 'IU_JBPM_BMP_OBJ'; 
		IF HASENTRY > 0 THEN 
		EXECUTE IMMEDIATE 'ALTER TRIGGER IU_JBPM_BMP_OBJ DISABLE';
		END IF;
		
	update jbpm_bpm_obj
	set VALUE = EcDp_BPM_util_json_clob.insert_array_element(
			VALUE,
			'_of/id/.elements',
			'{".value":"c27771a1",".class":"java.lang.String"},{".value":"8470cc7",".class":"java.lang.String"}',
			0)
	where VALUE_TYPE_NAME in (
		'com.ec.bpm.domain.task.reads.TaskResult',
		'com.ec.bpm.domain.task.reads.TaskSummary',
		'com.ec.bpm.domain.task.reads.TaskDetail');
		
	SELECT COUNT(*) INTO HASENTRY FROM USER_TRIGGERS 
		WHERE TRIGGER_NAME = 'IU_JBPM_BMP_OBJ'; 
		IF HASENTRY > 0 THEN 
		EXECUTE IMMEDIATE 'ALTER TRIGGER IU_JBPM_BMP_OBJ ENABLE';
		END IF;
		
	 EXCEPTION
   WHEN OTHERS 
     THEN
       IF HASENTRY > 0 THEN 
           EXECUTE IMMEDIATE 'ALTER TRIGGER IU_JBPM_BMP_OBJ ENABLE';
       END IF;
        
        raise_application_error(-20000,
                            'ERROR: Some Other fatal error occured :- '||SQLERRM);
		
END;
--~^UTDELIM^~--
DECLARE 
HASENTRY NUMBER;
BEGIN
SELECT COUNT(*) INTO HASENTRY FROM USER_TRIGGERS 
		WHERE TRIGGER_NAME = 'IU_JBPM_BMP_OBJ'; 
		IF HASENTRY > 0 THEN 
		EXECUTE IMMEDIATE 'ALTER TRIGGER IU_JBPM_BMP_OBJ DISABLE';
		END IF;
		
	update jbpm_bpm_obj
	set VALUE = EcDp_BPM_util_json_clob.replace_value(
			VALUE,
			'processInstance/.class',
			'"com.ec.bpm.domain.process.model.process.ProcessInstanceRef"')
	where VALUE_TYPE_NAME = 'com.ec.bpm.domain.task.reads.TaskSummary';
	
	SELECT COUNT(*) INTO HASENTRY FROM USER_TRIGGERS 
		WHERE TRIGGER_NAME = 'IU_JBPM_BMP_OBJ'; 
		IF HASENTRY > 0 THEN 
		EXECUTE IMMEDIATE 'ALTER TRIGGER IU_JBPM_BMP_OBJ ENABLE';
		END IF;
		
	 EXCEPTION
   WHEN OTHERS 
     THEN
       IF HASENTRY > 0 THEN 
           EXECUTE IMMEDIATE 'ALTER TRIGGER IU_JBPM_BMP_OBJ ENABLE';
       END IF;
        
        raise_application_error(-20000,
                            'ERROR: Some Other fatal error occured :- '||SQLERRM);
END;
--~^UTDELIM^~--

DECLARE 
HASENTRY NUMBER;
BEGIN

SELECT COUNT(*) INTO HASENTRY FROM USER_TRIGGERS 
		WHERE TRIGGER_NAME = 'IU_JBPM_BMP_OBJ'; 
		IF HASENTRY > 0 THEN 
		EXECUTE IMMEDIATE 'ALTER TRIGGER IU_JBPM_BMP_OBJ DISABLE';
		END IF;
		
	update jbpm_bpm_obj
	set VALUE = EcDp_BPM_util_json_clob.insert_array_element(
			VALUE,
			'processInstance/id',
			'{".value":"1ebd446a",".class":"java.lang.String"}',
			0)
	where VALUE_TYPE_NAME = 'com.ec.bpm.domain.task.reads.TaskSummary';
	
	SELECT COUNT(*) INTO HASENTRY FROM USER_TRIGGERS 
		WHERE TRIGGER_NAME = 'IU_JBPM_BMP_OBJ'; 
		IF HASENTRY > 0 THEN 
		EXECUTE IMMEDIATE 'ALTER TRIGGER IU_JBPM_BMP_OBJ ENABLE';
		END IF;
		
	 EXCEPTION
   WHEN OTHERS 
     THEN
       IF HASENTRY > 0 THEN 
           EXECUTE IMMEDIATE 'ALTER TRIGGER IU_JBPM_BMP_OBJ ENABLE';
       END IF;
        
        raise_application_error(-20000,
                            'ERROR: Some Other fatal error occured :- '||SQLERRM);
END;
--~^UTDELIM^~--

DECLARE 
HASENTRY NUMBER;
BEGIN

SELECT COUNT(*) INTO HASENTRY FROM USER_TRIGGERS 
		WHERE TRIGGER_NAME = 'IU_JBPM_BMP_OBJ'; 
		IF HASENTRY > 0 THEN 
		EXECUTE IMMEDIATE 'ALTER TRIGGER IU_JBPM_BMP_OBJ DISABLE';
		END IF;
		
	update jbpm_bpm_obj
	set VALUE = EcDp_BPM_util_json_clob.replace_name(
			VALUE,
			'processInstance',
			'"correlation"')
	where VALUE_TYPE_NAME = 'com.ec.bpm.domain.task.reads.TaskSummary';
	
	SELECT COUNT(*) INTO HASENTRY FROM USER_TRIGGERS 
		WHERE TRIGGER_NAME = 'IU_JBPM_BMP_OBJ'; 
		IF HASENTRY > 0 THEN 
		EXECUTE IMMEDIATE 'ALTER TRIGGER IU_JBPM_BMP_OBJ ENABLE';
		END IF;
		
	 EXCEPTION
   WHEN OTHERS 
     THEN
       IF HASENTRY > 0 THEN 
           EXECUTE IMMEDIATE 'ALTER TRIGGER IU_JBPM_BMP_OBJ ENABLE';
       END IF;
        
        raise_application_error(-20000,
                            'ERROR: Some Other fatal error occured :- '||SQLERRM);
END;
--~^UTDELIM^~--

DECLARE 
HASENTRY NUMBER;
BEGIN

SELECT COUNT(*) INTO HASENTRY FROM USER_TRIGGERS 
		WHERE TRIGGER_NAME = 'IU_JBPM_BMP_OBJ'; 
		IF HASENTRY > 0 THEN 
		EXECUTE IMMEDIATE 'ALTER TRIGGER IU_JBPM_BMP_OBJ DISABLE';
		END IF;
		
	update jbpm_bpm_obj
	set VALUE = EcDp_BPM_util_json_clob.replace_name(
			VALUE,
			'createdOn',
			'"createdAt"')
	where VALUE_TYPE_NAME = 'com.ec.bpm.domain.task.reads.TaskSummary';
	
	SELECT COUNT(*) INTO HASENTRY FROM USER_TRIGGERS 
		WHERE TRIGGER_NAME = 'IU_JBPM_BMP_OBJ'; 
		IF HASENTRY > 0 THEN 
		EXECUTE IMMEDIATE 'ALTER TRIGGER IU_JBPM_BMP_OBJ ENABLE';
		END IF;
		
EXCEPTION
   WHEN OTHERS 
     THEN
       IF HASENTRY > 0 THEN 
           EXECUTE IMMEDIATE 'ALTER TRIGGER IU_JBPM_BMP_OBJ ENABLE';
       END IF;
        
        raise_application_error(-20000,
                            'ERROR: Some Other fatal error occured :- '||SQLERRM);
		
END;
--~^UTDELIM^~--

DECLARE 
HASENTRY NUMBER;
BEGIN

SELECT COUNT(*) INTO HASENTRY FROM USER_TRIGGERS 
		WHERE TRIGGER_NAME = 'IU_JBPM_BMP_OBJ'; 
		IF HASENTRY > 0 THEN 
		EXECUTE IMMEDIATE 'ALTER TRIGGER IU_JBPM_BMP_OBJ DISABLE';
		END IF;
		
	update jbpm_bpm_obj
	set VALUE = EcDp_BPM_util_json_clob.replace_value(
			VALUE,
			'documentContentId/.class',
			'"com.ec.bpm.domain.task.reads.TaskContentRef"')
	where VALUE_TYPE_NAME = 'com.ec.bpm.domain.task.reads.TaskSummary';
	
	SELECT COUNT(*) INTO HASENTRY FROM USER_TRIGGERS 
		WHERE TRIGGER_NAME = 'IU_JBPM_BMP_OBJ'; 
		IF HASENTRY > 0 THEN 
		EXECUTE IMMEDIATE 'ALTER TRIGGER IU_JBPM_BMP_OBJ ENABLE';
		END IF;
		
	EXCEPTION
   WHEN OTHERS 
     THEN
       IF HASENTRY > 0 THEN 
           EXECUTE IMMEDIATE 'ALTER TRIGGER IU_JBPM_BMP_OBJ ENABLE';
       END IF;
        
        raise_application_error(-20000,
                            'ERROR: Some Other fatal error occured :- '||SQLERRM);
END;
--~^UTDELIM^~--
DECLARE 
HASENTRY NUMBER;
BEGIN

SELECT COUNT(*) INTO HASENTRY FROM USER_TRIGGERS 
		WHERE TRIGGER_NAME = 'IU_JBPM_BMP_OBJ'; 
		IF HASENTRY > 0 THEN 
		EXECUTE IMMEDIATE 'ALTER TRIGGER IU_JBPM_BMP_OBJ DISABLE';
		END IF;
		
	update jbpm_bpm_obj
	set VALUE = EcDp_BPM_util_json_clob.insert_array_element(
			VALUE,
			'documentContentId/id',
			'{".value":"b70eabd0",".class":"java.lang.String"}',
			0)
	where VALUE_TYPE_NAME = 'com.ec.bpm.domain.task.reads.TaskSummary';
	
	SELECT COUNT(*) INTO HASENTRY FROM USER_TRIGGERS 
		WHERE TRIGGER_NAME = 'IU_JBPM_BMP_OBJ'; 
		IF HASENTRY > 0 THEN 
		EXECUTE IMMEDIATE 'ALTER TRIGGER IU_JBPM_BMP_OBJ ENABLE';
		END IF;
		
	EXCEPTION
   WHEN OTHERS 
     THEN
       IF HASENTRY > 0 THEN 
           EXECUTE IMMEDIATE 'ALTER TRIGGER IU_JBPM_BMP_OBJ ENABLE';
       END IF;
        
        raise_application_error(-20000,
                            'ERROR: Some Other fatal error occured :- '||SQLERRM);
		
END;
--~^UTDELIM^~--


DECLARE 
HASENTRY NUMBER;
BEGIN

SELECT COUNT(*) INTO HASENTRY FROM USER_TRIGGERS 
		WHERE TRIGGER_NAME = 'IU_JBPM_BMP_OBJ'; 
		IF HASENTRY > 0 THEN 
		EXECUTE IMMEDIATE 'ALTER TRIGGER IU_JBPM_BMP_OBJ DISABLE';
		END IF;
		
		
	update jbpm_bpm_obj
	set VALUE = EcDp_BPM_util_json_clob.replace_value(
			VALUE,
			'outputContentId/.class',
			'"com.ec.bpm.domain.task.reads.TaskContentRef"')
	where VALUE_TYPE_NAME = 'com.ec.bpm.domain.task.reads.TaskSummary';
	
	SELECT COUNT(*) INTO HASENTRY FROM USER_TRIGGERS 
		WHERE TRIGGER_NAME = 'IU_JBPM_BMP_OBJ'; 
		IF HASENTRY > 0 THEN 
		EXECUTE IMMEDIATE 'ALTER TRIGGER IU_JBPM_BMP_OBJ ENABLE';
		END IF;
		
	EXCEPTION
   WHEN OTHERS 
     THEN
       IF HASENTRY > 0 THEN 
           EXECUTE IMMEDIATE 'ALTER TRIGGER IU_JBPM_BMP_OBJ ENABLE';
       END IF;
        
        raise_application_error(-20000,
                            'ERROR: Some Other fatal error occured :- '||SQLERRM);
END;
--~^UTDELIM^~--
DECLARE 
HASENTRY NUMBER;
BEGIN
SELECT COUNT(*) INTO HASENTRY FROM USER_TRIGGERS 
		WHERE TRIGGER_NAME = 'IU_JBPM_BMP_OBJ'; 
		IF HASENTRY > 0 THEN 
		EXECUTE IMMEDIATE 'ALTER TRIGGER IU_JBPM_BMP_OBJ DISABLE';
		END IF;
		
	update jbpm_bpm_obj
	set VALUE = EcDp_BPM_util_json_clob.insert_array_element(
			VALUE,
			'outputContentId/id',
			'{".value":"b70eabd0",".class":"java.lang.String"}',
			0)
	where VALUE_TYPE_NAME = 'com.ec.bpm.domain.task.reads.TaskSummary';
	
	SELECT COUNT(*) INTO HASENTRY FROM USER_TRIGGERS 
		WHERE TRIGGER_NAME = 'IU_JBPM_BMP_OBJ'; 
		IF HASENTRY > 0 THEN 
		EXECUTE IMMEDIATE 'ALTER TRIGGER IU_JBPM_BMP_OBJ ENABLE';
		END IF;
		
	EXCEPTION
   WHEN OTHERS 
     THEN
       IF HASENTRY > 0 THEN 
           EXECUTE IMMEDIATE 'ALTER TRIGGER IU_JBPM_BMP_OBJ ENABLE';
       END IF;
        
        raise_application_error(-20000,
                            'ERROR: Some Other fatal error occured :- '||SQLERRM);
END;
--~^UTDELIM^~--
DECLARE 
HASENTRY NUMBER;

BEGIN

SELECT COUNT(*) INTO HASENTRY FROM USER_TRIGGERS 
		WHERE TRIGGER_NAME = 'IU_JBPM_BMP_OBJ'; 
		IF HASENTRY > 0 THEN 
		EXECUTE IMMEDIATE 'ALTER TRIGGER IU_JBPM_BMP_OBJ DISABLE';
		END IF;
		
	update jbpm_bpm_obj
	set VALUE = EcDp_BPM_util_json_clob.replace_name(
			VALUE,
			'values',
			'"result"')
	where VALUE_TYPE_NAME = 'com.ec.bpm.domain.task.reads.TaskResult';
	
	SELECT COUNT(*) INTO HASENTRY FROM USER_TRIGGERS 
		WHERE TRIGGER_NAME = 'IU_JBPM_BMP_OBJ'; 
		IF HASENTRY > 0 THEN 
		EXECUTE IMMEDIATE 'ALTER TRIGGER IU_JBPM_BMP_OBJ ENABLE';
		END IF;
		
	EXCEPTION
   WHEN OTHERS 
     THEN
       IF HASENTRY > 0 THEN 
           EXECUTE IMMEDIATE 'ALTER TRIGGER IU_JBPM_BMP_OBJ ENABLE';
       END IF;
        
        raise_application_error(-20000,
                            'ERROR: Some Other fatal error occured :- '||SQLERRM);
END;
--~^UTDELIM^~--

DECLARE 
HASENTRY NUMBER;
BEGIN

SELECT COUNT(*) INTO HASENTRY FROM USER_TRIGGERS 
		WHERE TRIGGER_NAME = 'IU_JBPM_BMP_OBJ_RELATION'; 
		IF HASENTRY > 0 THEN 
		EXECUTE IMMEDIATE 'ALTER TRIGGER IU_JBPM_BMP_OBJ_RELATION DISABLE';
		END IF;
		
	update jbpm_bpm_obj_relation
	set REF_JSON = EcDp_BPM_util_json.insert_array_element(REF_JSON, '"c27771a1"', 0)
	where RELATION_NAME in (
		'ecbpm.domain.task.correlated_process_instance',
		'ecbpm.domain.task.correlated_node_instance');
		
		SELECT COUNT(*) INTO HASENTRY FROM USER_TRIGGERS 
		WHERE TRIGGER_NAME = 'IU_JBPM_BMP_OBJ_RELATION'; 
		IF HASENTRY > 0 THEN 
		EXECUTE IMMEDIATE 'ALTER TRIGGER IU_JBPM_BMP_OBJ_RELATION ENABLE';
		END IF;
		
	EXCEPTION
   WHEN OTHERS 
     THEN
       IF HASENTRY > 0 THEN 
           EXECUTE IMMEDIATE 'ALTER TRIGGER IU_JBPM_BMP_OBJ_RELATION ENABLE';
       END IF;
        
        raise_application_error(-20000,
                            'ERROR: Some Other fatal error occured :- '||SQLERRM);
END;
--~^UTDELIM^~--
DECLARE 
HASENTRY NUMBER;
BEGIN
SELECT COUNT(*) INTO HASENTRY FROM USER_TRIGGERS 
		WHERE TRIGGER_NAME = 'IU_JBPM_BMP_OBJ_RELATION'; 
		IF HASENTRY > 0 THEN 
		EXECUTE IMMEDIATE 'ALTER TRIGGER IU_JBPM_BMP_OBJ_RELATION DISABLE';
		END IF;
		
	update jbpm_bpm_obj_relation
	set RELATED_REF_JSON = EcDp_BPM_util_json.insert_array_element(RELATED_REF_JSON, '"c27771a1"', 0)
	where RELATION_NAME in (
		'ecbpm.domain.task.correlated_task');
		
SELECT COUNT(*) INTO HASENTRY FROM USER_TRIGGERS 
		WHERE TRIGGER_NAME = 'IU_JBPM_BMP_OBJ_RELATION'; 
		IF HASENTRY > 0 THEN 
		EXECUTE IMMEDIATE 'ALTER TRIGGER IU_JBPM_BMP_OBJ_RELATION ENABLE';
		END IF;
		
	EXCEPTION
   WHEN OTHERS 
     THEN
       IF HASENTRY > 0 THEN 
           EXECUTE IMMEDIATE 'ALTER TRIGGER IU_JBPM_BMP_OBJ_RELATION ENABLE';
       END IF;
        
        raise_application_error(-20000,
                            'ERROR: Some Other fatal error occured :- '||SQLERRM);
END;
--~^UTDELIM^~--

BEGIN
	insert into jbpm_bpm_task (GLOBAL_ID, REF_JSON, STATE_DEFINITION, STATE, CORRELATION_GLOBAL_ID, CORRELATION_REF_JSON, ASSIGNEE)
	select 'c27771a1/8470cc7/' || ID,
		'["c27771a1","8470cc7","' || ID || '"]',
		'default',
		 DECODE(STATUS, 'Created', 0, 'Ready', 0, 'Reserved', 1, 'InProgress', 2, 'Suspended', 4, 'Completed', 3, 'Failed', 4, 'Error', 4, 'Exited', 4, 'Obsolete', 4),
		 '1ebd446a/' || PROCESSINSTANCEID || '/' || PROCESSID || '/' || DEPLOYMENTID,
		 '["1ebd446a",' || PROCESSINSTANCEID || ',"' || PROCESSID || '","' || DEPLOYMENTID || '"]',
		 ACTUALOWNER
	from jbpm_task
	where PROCESSINSTANCEID is not null;
END;
--~^UTDELIM^~--

-- process domain

DECLARE 
HASENTRY NUMBER;
BEGIN

SELECT COUNT(*) INTO HASENTRY FROM USER_TRIGGERS 
		WHERE TRIGGER_NAME = 'IU_JBPM_BMP_OBJ_META'; 
		IF HASENTRY > 0 THEN 
		EXECUTE IMMEDIATE 'ALTER TRIGGER IU_JBPM_BMP_OBJ_META DISABLE';
		END IF;
		
	update jbpm_bpm_obj_meta
	set VALUE = EcDp_BPM_util_json.without_quotes(EcDp_BPM_util_json.value_of(VALUE))
	where NAME in (
		'readonly:ecbpm.domain.process.node.name',
		'readonly:ecbpm.domain.process.node.service_task_name',
		'ecbpm.domain.process.label',
		'ecbpm.domain.vtag.tag');
		
		SELECT COUNT(*) INTO HASENTRY FROM USER_TRIGGERS 
		WHERE TRIGGER_NAME = 'IU_JBPM_BMP_OBJ_META'; 
		IF HASENTRY > 0 THEN 
		EXECUTE IMMEDIATE 'ALTER TRIGGER IU_JBPM_BMP_OBJ_META ENABLE';
		END IF;
		
	EXCEPTION
   WHEN OTHERS 
     THEN
       IF HASENTRY > 0 THEN 
           EXECUTE IMMEDIATE 'ALTER TRIGGER IU_JBPM_BMP_OBJ_META ENABLE';
       END IF;
        
        raise_application_error(-20000,
                            'ERROR: Some Other fatal error occured :- '||SQLERRM);
END;
--~^UTDELIM^~--

-- ext_ec
DECLARE 
HASENTRY NUMBER;
BEGIN

SELECT COUNT(*) INTO HASENTRY FROM USER_TRIGGERS 
		WHERE TRIGGER_NAME = 'IU_JBPM_BMP_OBJ_META'; 
		IF HASENTRY > 0 THEN 
		EXECUTE IMMEDIATE 'ALTER TRIGGER IU_JBPM_BMP_OBJ_META DISABLE';
		END IF;
		
	update jbpm_bpm_obj_meta
	set VALUE = EcDp_BPM_util_json.without_quotes(EcDp_BPM_util_json.value_of(VALUE))
	where NAME in (
		'readonly:com.ec.bpm.ext.ec.process.business_action_number',
		'readonly:com.ec.bpm.ext.ec.process.process_creator',
		'readonly:com.ec.bpm.ext.ec.process.schedule_number',
		'readonly:com.ec.bpm.ext.ec.process_creator');
		
		SELECT COUNT(*) INTO HASENTRY FROM USER_TRIGGERS 
		WHERE TRIGGER_NAME = 'IU_JBPM_BMP_OBJ_META'; 
		IF HASENTRY > 0 THEN 
		EXECUTE IMMEDIATE 'ALTER TRIGGER IU_JBPM_BMP_OBJ_META ENABLE';
		END IF;
		
EXCEPTION
   WHEN OTHERS 
     THEN
       IF HASENTRY > 0 THEN 
           EXECUTE IMMEDIATE 'ALTER TRIGGER IU_JBPM_BMP_OBJ_META ENABLE';
       END IF;
        
        raise_application_error(-20000,
                            'ERROR: Some Other fatal error occured :- '||SQLERRM);
END;
--~^UTDELIM^~--

-- process action domain
DECLARE 
HASENTRY NUMBER;

BEGIN

SELECT COUNT(*) INTO HASENTRY FROM USER_TRIGGERS 
		WHERE TRIGGER_NAME = 'IU_JBPM_BMP_OBJ_META'; 
		IF HASENTRY > 0 THEN 
		EXECUTE IMMEDIATE 'ALTER TRIGGER IU_JBPM_BMP_OBJ_META DISABLE';
		END IF;
		
	update jbpm_bpm_obj_meta
	set VALUE = EcDp_BPM_util_json.without_quotes(EcDp_BPM_util_json.value_of(VALUE))
	where NAME in (
		'readonly:ecbpm.domain.proaction.node.process_action_name');
		
		SELECT COUNT(*) INTO HASENTRY FROM USER_TRIGGERS 
		WHERE TRIGGER_NAME = 'IU_JBPM_BMP_OBJ_META'; 
		IF HASENTRY > 0 THEN 
		EXECUTE IMMEDIATE 'ALTER TRIGGER IU_JBPM_BMP_OBJ_META ENABLE';
		END IF;
		
	EXCEPTION
   WHEN OTHERS 
     THEN
       IF HASENTRY > 0 THEN 
           EXECUTE IMMEDIATE 'ALTER TRIGGER IU_JBPM_BMP_OBJ_META ENABLE';
       END IF;
        
        raise_application_error(-20000,
                            'ERROR: Some Other fatal error occured :- '||SQLERRM);
END;
--~^UTDELIM^~--

DECLARE

CURSOR c_report_sets IS 
       select report_set_no, name, functional_area_id 
       from report_set;
       
CURSOR c_reports(p_report_set_no NUMBER) IS 
       select report_set_no, report_runable_no, functional_area_id, sort_order 
       from tv_report_set_list 
       where report_set_no = p_report_set_no;

CURSOR c_report_params(p_report_set_no NUMBER) IS 
       select parameter_value, parameter_name, daytime 
       from tv_report_set_param
       where report_set_no = p_report_set_no;

p_new_report_set_no number;
p_old_name varchar(100);

BEGIN

  -- copy report sets
  FOR cur_set IN c_report_sets LOOP
    insert into report_set (name, functional_area_id ) 
	  values ( concat(cur_set.name, '_NEW'), cur_set.functional_area_id ); 
    
    -- Find the new report set no
    select (select report_set_no from report_set where name = concat(cur_set.name, '_NEW')) 
    into p_new_report_set_no 
    from dual;

    
    -- copy the reports for the report set    
    FOR cur_report IN c_reports(cur_set.report_set_no) LOOP 
        insert into tv_report_set_list (report_set_no, report_runable_no, functional_area_id, sort_order)
        values (p_new_report_set_no, cur_report.report_runable_no, cur_report.functional_area_id, cur_report.sort_order ); 
    END LOOP;

    -- copy parameter values           
    FOR cur_rep_params IN c_report_params(cur_set.report_set_no) LOOP 
        update tv_report_set_param 
        set parameter_value = cur_rep_params.parameter_value 
        where report_set_no = p_new_report_set_no 
              and daytime = cur_rep_params.daytime
              and parameter_name = cur_rep_params.parameter_name;
    END LOOP;

    -- remember old name
    p_old_name := cur_set.name;

    delete from tv_report_set_list where report_set_no = cur_set.report_set_no;
    delete from tv_report_set where report_set_no = cur_set.report_set_no;
    update tv_report_set set name = p_old_name where report_set_no = p_new_report_set_no;

  END LOOP;  
END;
--~^UTDELIM^~--
CREATE SEQUENCE TASK_VAR_ID_SEQ
--~^UTDELIM^~--

CREATE SEQUENCE QUERY_DEF_ID_SEQ
--~^UTDELIM^~--

DROP SEQUENCE PROCESS_LOG_ID_SEQ
--~^UTDELIM^~--

DROP SEQUENCE NODE_PARAM_LOG_ID_SEQ
--~^UTDELIM^~--

CREATE SEQUENCE JBPM_BPM_DATA_SET_USAGE_WS_SEQ
--~^UTDELIM^~--

BEGIN
	INSERT INTO T_BASIS_USERROLE
	(USER_ID, ROLE_ID, APP_ID)
	SELECT USER_ID, 'admin', 1
	FROM T_BASIS_USERROLE
	 WHERE ROLE_ID = 'JBPM.ADMIN'
	AND NOT EXISTS
	(SELECT USER_ID FROM T_BASIS_USERROLE WHERE ROLE_ID = 'admin');	
END;
--~^UTDELIM^~--
-- This script will create report areas based on existing report groups, and will add report area on report definition groups. 
--ALTER TABLE REPORT_DEFINITION_GROUP ADD (REPORT_AREA_ID VARCHAR2(32));
--ALTER TABLE REPORT_DEFINITION_GROUP_JN ADD (REPORT_AREA_ID VARCHAR2(32));

DECLARE
-- Report definition groups that needs to be updated 
CURSOR c_report_def_groups IS
        SELECT rep_group_code, report_group_code
        FROM report_definition_group 
        WHERE report_group_code is not null and report_area_id is null;
		
CURSOR c_report_def_groups_jn IS
        SELECT rep_group_code, report_group_code
        FROM report_definition_group_jn
        WHERE report_group_code is not null and report_area_id is null;
       
BEGIN
  -- Insert Report Areas based on existing ec codes
  insert into OV_REPORT_AREA (CODE, NAME, OBJECT_START_DATE) 
    select CODE, CODE_TEXT, to_date( '01-01-1900', 'dd-mm-yyyy') FROM TV_EC_CODES T WHERE CODE_TYPE = 'REPORT_GROUP' and not exists( select object_code from report_area where object_code = T.CODE ) ;

  -- Update report definitions with the report area in report_definition_group table
  FOR cur_rec IN c_report_def_groups LOOP
    update report_definition_group set report_area_id = (select object_id from report_area where object_code = cur_rec.report_group_code) where report_group_code = cur_rec.report_group_code ;
  END LOOP;
  
  -- Update report definitions with the report area in report_definition_group_jn table
  FOR cur_rec IN c_report_def_groups_jn LOOP
    update report_definition_group_jn set report_area_id = (select object_id from report_area where object_code = cur_rec.report_group_code) where report_group_code = cur_rec.report_group_code ;
  END LOOP;
END;
--~^UTDELIM^~--

BEGIN
	ecdp_classmeta.RefreshMViews;
END;
--~^UTDELIM^~--
BEGIN
ecdp_viewlayer.BuildViewLayer('FIN_ITEM_DATASET_MATRIX',p_force => 'Y'); 
END;
--~^UTDELIM^~--

BEGIN
UPDATE VIEWLAYER_DIRTY_LOG SET DIRTY_IND = 'Y' WHERE OBJECT_NAME= 'CALC_COLLECTION_ELEMENT';
END;
--~^UTDELIM^~--

BEGIN 

MERGE INTO CLASS_ATTRIBUTE_CNFG o USING 
(
SELECT
 null APP_SPACE_CNTX, null ATTRIBUTE_NAME, null CLASS_NAME, null DATA_TYPE, null DB_JOIN_TABLE, null DB_JOIN_WHERE, null DB_MAPPING_TYPE, null DB_SQL_SYNTAX, null IS_KEY FROM DUAL WHERE 1=0
UNION 
 SELECT 'DELETE_CANDIDATE', 'DATE_1', 'TANK_FINDER_OBJECTS', 'DATE', null, null, 'COLUMN', 'DATE_1', 'N' FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'DATE_1', 'VAT_CUST_COUNTRY_SETUP', 'DATE', null, null, 'COLUMN', 'DATE_1', null FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'DATE_1', 'VAT_DEST_COUNTRY_SETUP', 'DATE', null, null, 'COLUMN', 'DATE_1', null FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'DATE_1', 'VAT_ORIG_COUNTRY_SETUP', 'DATE', null, null, 'COLUMN', 'DATE_1', null FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'DATE_1', 'VAT_VEND_COUNTRY_SETUP', 'DATE', null, null, 'COLUMN', 'DATE_1', null FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'DATE_10', 'VAT_CUST_COUNTRY_SETUP', 'DATE', null, null, 'COLUMN', 'DATE_10', null FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'DATE_10', 'VAT_DEST_COUNTRY_SETUP', 'DATE', null, null, 'COLUMN', 'DATE_10', null FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'DATE_10', 'VAT_ORIG_COUNTRY_SETUP', 'DATE', null, null, 'COLUMN', 'DATE_10', null FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'DATE_10', 'VAT_VEND_COUNTRY_SETUP', 'DATE', null, null, 'COLUMN', 'DATE_10', null FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'DATE_2', 'TANK_FINDER_OBJECTS', 'DATE', null, null, 'COLUMN', 'DATE_2', 'N' FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'DATE_2', 'VAT_CUST_COUNTRY_SETUP', 'DATE', null, null, 'COLUMN', 'DATE_2', null FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'DATE_2', 'VAT_DEST_COUNTRY_SETUP', 'DATE', null, null, 'COLUMN', 'DATE_2', null FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'DATE_2', 'VAT_ORIG_COUNTRY_SETUP', 'DATE', null, null, 'COLUMN', 'DATE_2', null FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'DATE_2', 'VAT_VEND_COUNTRY_SETUP', 'DATE', null, null, 'COLUMN', 'DATE_2', null FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'DATE_3', 'TANK_FINDER_OBJECTS', 'DATE', null, null, 'COLUMN', 'DATE_3', 'N' FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'DATE_3', 'VAT_CUST_COUNTRY_SETUP', 'DATE', null, null, 'COLUMN', 'DATE_3', null FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'DATE_3', 'VAT_DEST_COUNTRY_SETUP', 'DATE', null, null, 'COLUMN', 'DATE_3', null FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'DATE_3', 'VAT_ORIG_COUNTRY_SETUP', 'DATE', null, null, 'COLUMN', 'DATE_3', null FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'DATE_3', 'VAT_VEND_COUNTRY_SETUP', 'DATE', null, null, 'COLUMN', 'DATE_3', null FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'DATE_4', 'TANK_FINDER_OBJECTS', 'DATE', null, null, 'COLUMN', 'DATE_4', 'N' FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'DATE_4', 'VAT_CUST_COUNTRY_SETUP', 'DATE', null, null, 'COLUMN', 'DATE_4', null FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'DATE_4', 'VAT_DEST_COUNTRY_SETUP', 'DATE', null, null, 'COLUMN', 'DATE_4', null FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'DATE_4', 'VAT_ORIG_COUNTRY_SETUP', 'DATE', null, null, 'COLUMN', 'DATE_4', null FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'DATE_4', 'VAT_VEND_COUNTRY_SETUP', 'DATE', null, null, 'COLUMN', 'DATE_4', null FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'DATE_5', 'TANK_FINDER_OBJECTS', 'DATE', null, null, 'COLUMN', 'DATE_5', 'N' FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'DATE_5', 'VAT_CUST_COUNTRY_SETUP', 'DATE', null, null, 'COLUMN', 'DATE_5', null FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'DATE_5', 'VAT_DEST_COUNTRY_SETUP', 'DATE', null, null, 'COLUMN', 'DATE_5', null FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'DATE_5', 'VAT_ORIG_COUNTRY_SETUP', 'DATE', null, null, 'COLUMN', 'DATE_5', null FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'DATE_5', 'VAT_VEND_COUNTRY_SETUP', 'DATE', null, null, 'COLUMN', 'DATE_5', null FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'DATE_6', 'VAT_CUST_COUNTRY_SETUP', 'DATE', null, null, 'COLUMN', 'DATE_6', null FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'DATE_6', 'VAT_DEST_COUNTRY_SETUP', 'DATE', null, null, 'COLUMN', 'DATE_6', null FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'DATE_6', 'VAT_ORIG_COUNTRY_SETUP', 'DATE', null, null, 'COLUMN', 'DATE_6', null FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'DATE_6', 'VAT_VEND_COUNTRY_SETUP', 'DATE', null, null, 'COLUMN', 'DATE_6', null FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'DATE_7', 'VAT_CUST_COUNTRY_SETUP', 'DATE', null, null, 'COLUMN', 'DATE_7', null FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'DATE_7', 'VAT_DEST_COUNTRY_SETUP', 'DATE', null, null, 'COLUMN', 'DATE_7', null FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'DATE_7', 'VAT_ORIG_COUNTRY_SETUP', 'DATE', null, null, 'COLUMN', 'DATE_7', null FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'DATE_7', 'VAT_VEND_COUNTRY_SETUP', 'DATE', null, null, 'COLUMN', 'DATE_7', null FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'DATE_8', 'VAT_CUST_COUNTRY_SETUP', 'DATE', null, null, 'COLUMN', 'DATE_8', null FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'DATE_8', 'VAT_DEST_COUNTRY_SETUP', 'DATE', null, null, 'COLUMN', 'DATE_8', null FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'DATE_8', 'VAT_ORIG_COUNTRY_SETUP', 'DATE', null, null, 'COLUMN', 'DATE_8', null FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'DATE_8', 'VAT_VEND_COUNTRY_SETUP', 'DATE', null, null, 'COLUMN', 'DATE_8', null FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'DATE_9', 'VAT_CUST_COUNTRY_SETUP', 'DATE', null, null, 'COLUMN', 'DATE_9', null FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'DATE_9', 'VAT_DEST_COUNTRY_SETUP', 'DATE', null, null, 'COLUMN', 'DATE_9', null FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'DATE_9', 'VAT_ORIG_COUNTRY_SETUP', 'DATE', null, null, 'COLUMN', 'DATE_9', null FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'DATE_9', 'VAT_VEND_COUNTRY_SETUP', 'DATE', null, null, 'COLUMN', 'DATE_9', null FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'TEXT_1', 'TANK_FINDER_OBJECTS', 'STRING', null, null, 'COLUMN', 'TEXT_1', 'N' FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'TEXT_1', 'VAT_CUST_COUNTRY_SETUP', 'STRING', null, null, 'COLUMN', 'TEXT_1', null FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'TEXT_1', 'VAT_DEST_COUNTRY_SETUP', 'STRING', null, null, 'COLUMN', 'TEXT_1', null FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'TEXT_1', 'VAT_ORIG_COUNTRY_SETUP', 'STRING', null, null, 'COLUMN', 'TEXT_1', null FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'TEXT_1', 'VAT_VEND_COUNTRY_SETUP', 'STRING', null, null, 'COLUMN', 'TEXT_1', null FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'TEXT_10', 'TANK_FINDER_OBJECTS', 'STRING', null, null, 'COLUMN', 'TEXT_10', 'N' FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'TEXT_10', 'VAT_CUST_COUNTRY_SETUP', 'STRING', null, null, 'COLUMN', 'TEXT_10', null FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'TEXT_10', 'VAT_DEST_COUNTRY_SETUP', 'STRING', null, null, 'COLUMN', 'TEXT_10', null FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'TEXT_10', 'VAT_ORIG_COUNTRY_SETUP', 'STRING', null, null, 'COLUMN', 'TEXT_10', null FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'TEXT_10', 'VAT_VEND_COUNTRY_SETUP', 'STRING', null, null, 'COLUMN', 'TEXT_10', null FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'TEXT_2', 'TANK_FINDER_OBJECTS', 'STRING', null, null, 'COLUMN', 'TEXT_2', 'N' FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'TEXT_2', 'VAT_CUST_COUNTRY_SETUP', 'STRING', null, null, 'COLUMN', 'TEXT_2', null FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'TEXT_2', 'VAT_DEST_COUNTRY_SETUP', 'STRING', null, null, 'COLUMN', 'TEXT_2', null FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'TEXT_2', 'VAT_ORIG_COUNTRY_SETUP', 'STRING', null, null, 'COLUMN', 'TEXT_2', null FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'TEXT_2', 'VAT_VEND_COUNTRY_SETUP', 'STRING', null, null, 'COLUMN', 'TEXT_2', null FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'TEXT_3', 'TANK_FINDER_OBJECTS', 'STRING', null, null, 'COLUMN', 'TEXT_3', 'N' FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'TEXT_3', 'VAT_CUST_COUNTRY_SETUP', 'STRING', null, null, 'COLUMN', 'TEXT_3', null FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'TEXT_3', 'VAT_DEST_COUNTRY_SETUP', 'STRING', null, null, 'COLUMN', 'TEXT_3', null FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'TEXT_3', 'VAT_ORIG_COUNTRY_SETUP', 'STRING', null, null, 'COLUMN', 'TEXT_3', null FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'TEXT_3', 'VAT_VEND_COUNTRY_SETUP', 'STRING', null, null, 'COLUMN', 'TEXT_3', null FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'TEXT_4', 'TANK_FINDER_OBJECTS', 'STRING', null, null, 'COLUMN', 'TEXT_4', 'N' FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'TEXT_4', 'VAT_CUST_COUNTRY_SETUP', 'STRING', null, null, 'COLUMN', 'TEXT_4', null FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'TEXT_4', 'VAT_DEST_COUNTRY_SETUP', 'STRING', null, null, 'COLUMN', 'TEXT_4', null FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'TEXT_4', 'VAT_ORIG_COUNTRY_SETUP', 'STRING', null, null, 'COLUMN', 'TEXT_4', null FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'TEXT_4', 'VAT_VEND_COUNTRY_SETUP', 'STRING', null, null, 'COLUMN', 'TEXT_4', null FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'TEXT_5', 'TANK_FINDER_OBJECTS', 'STRING', null, null, 'COLUMN', 'TEXT_5', 'N' FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'TEXT_5', 'VAT_CUST_COUNTRY_SETUP', 'STRING', null, null, 'COLUMN', 'TEXT_5', null FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'TEXT_5', 'VAT_DEST_COUNTRY_SETUP', 'STRING', null, null, 'COLUMN', 'TEXT_5', null FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'TEXT_5', 'VAT_ORIG_COUNTRY_SETUP', 'STRING', null, null, 'COLUMN', 'TEXT_5', null FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'TEXT_5', 'VAT_VEND_COUNTRY_SETUP', 'STRING', null, null, 'COLUMN', 'TEXT_5', null FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'TEXT_6', 'TANK_FINDER_OBJECTS', 'STRING', null, null, 'COLUMN', 'TEXT_6', 'N' FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'TEXT_6', 'VAT_CUST_COUNTRY_SETUP', 'STRING', null, null, 'COLUMN', 'TEXT_6', null FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'TEXT_6', 'VAT_DEST_COUNTRY_SETUP', 'STRING', null, null, 'COLUMN', 'TEXT_6', null FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'TEXT_6', 'VAT_ORIG_COUNTRY_SETUP', 'STRING', null, null, 'COLUMN', 'TEXT_6', null FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'TEXT_6', 'VAT_VEND_COUNTRY_SETUP', 'STRING', null, null, 'COLUMN', 'TEXT_6', null FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'TEXT_7', 'TANK_FINDER_OBJECTS', 'STRING', null, null, 'COLUMN', 'TEXT_7', 'N' FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'TEXT_7', 'VAT_CUST_COUNTRY_SETUP', 'STRING', null, null, 'COLUMN', 'TEXT_7', null FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'TEXT_7', 'VAT_DEST_COUNTRY_SETUP', 'STRING', null, null, 'COLUMN', 'TEXT_7', null FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'TEXT_7', 'VAT_ORIG_COUNTRY_SETUP', 'STRING', null, null, 'COLUMN', 'TEXT_7', null FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'TEXT_7', 'VAT_VEND_COUNTRY_SETUP', 'STRING', null, null, 'COLUMN', 'TEXT_7', null FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'TEXT_8', 'REPORT_REF_CONN', 'STRING', null, null, 'COLUMN', 'TEXT_8', 'N' FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'TEXT_8', 'REPORT_REF_CONN_CM', 'STRING', null, null, 'COLUMN', 'TEXT_8', 'N' FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'TEXT_8', 'REPORT_REF_CONN_DOC', 'STRING', null, null, 'COLUMN', 'TEXT_8', 'N' FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'TEXT_8', 'REPORT_REF_CONN_TI', 'STRING', null, null, 'COLUMN', 'TEXT_8', 'N' FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'TEXT_8', 'REPORT_REF_CONN_TI_LINE', 'STRING', null, null, 'COLUMN', 'TEXT_8', 'N' FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'TEXT_8', 'TANK_FINDER_OBJECTS', 'STRING', null, null, 'COLUMN', 'TEXT_8', 'N' FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'TEXT_8', 'VAT_CUST_COUNTRY_SETUP', 'STRING', null, null, 'COLUMN', 'TEXT_8', null FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'TEXT_8', 'VAT_DEST_COUNTRY_SETUP', 'STRING', null, null, 'COLUMN', 'TEXT_8', null FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'TEXT_8', 'VAT_ORIG_COUNTRY_SETUP', 'STRING', null, null, 'COLUMN', 'TEXT_8', null FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'TEXT_8', 'VAT_VEND_COUNTRY_SETUP', 'STRING', null, null, 'COLUMN', 'TEXT_8', null FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'TEXT_9', 'REPORT_REF_CONN', 'STRING', null, null, 'COLUMN', 'TEXT_9', 'N' FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'TEXT_9', 'REPORT_REF_CONN_CM', 'STRING', null, null, 'COLUMN', 'TEXT_9', 'N' FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'TEXT_9', 'REPORT_REF_CONN_DOC', 'STRING', null, null, 'COLUMN', 'TEXT_9', 'N' FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'TEXT_9', 'REPORT_REF_CONN_TI', 'STRING', null, null, 'COLUMN', 'TEXT_9', 'N' FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'TEXT_9', 'REPORT_REF_CONN_TI_LINE', 'STRING', null, null, 'COLUMN', 'TEXT_9', 'N' FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'TEXT_9', 'TANK_FINDER_OBJECTS', 'STRING', null, null, 'COLUMN', 'TEXT_9', 'N' FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'TEXT_9', 'VAT_CUST_COUNTRY_SETUP', 'STRING', null, null, 'COLUMN', 'TEXT_9', null FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'TEXT_9', 'VAT_DEST_COUNTRY_SETUP', 'STRING', null, null, 'COLUMN', 'TEXT_9', null FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'TEXT_9', 'VAT_ORIG_COUNTRY_SETUP', 'STRING', null, null, 'COLUMN', 'TEXT_9', null FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'TEXT_9', 'VAT_VEND_COUNTRY_SETUP', 'STRING', null, null, 'COLUMN', 'TEXT_9', null FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'VALUE_1', 'OBJECT_CALC_COMPONENT', 'NUMBER', null, null, 'COLUMN', 'VALUE_1', null FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'VALUE_1', 'REVN_CARGO_DG_LOG', 'NUMBER', null, null, 'COLUMN', 'VALUE_1', 'N' FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'VALUE_1', 'REVN_CASCADE_LOG', 'NUMBER', null, null, 'COLUMN', 'VALUE_1', 'N' FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'VALUE_1', 'REVN_COST_MAP_LOG', 'NUMBER', null, null, 'COLUMN', 'VALUE_1', 'N' FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'VALUE_1', 'REVN_ERP_DG_LOG', 'NUMBER', null, null, 'COLUMN', 'VALUE_1', 'N' FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'VALUE_1', 'REVN_INTERFACE_LOG', 'NUMBER', null, null, 'COLUMN', 'VALUE_1', 'N' FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'VALUE_1', 'REVN_PERIOD_DG_LOG', 'NUMBER', null, null, 'COLUMN', 'VALUE_1', 'N' FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'VALUE_1', 'REVN_REVERSE_DG_LOG', 'NUMBER', null, null, 'COLUMN', 'VALUE_1', 'N' FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'VALUE_1', 'REVN_SUMMARY_PC_LOG', 'NUMBER', null, null, 'COLUMN', 'VALUE_1', 'N' FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'VALUE_1', 'REVN_TI_LOG', 'NUMBER', null, null, 'COLUMN', 'VALUE_1', 'N' FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'VALUE_1', 'VAT_CUST_COUNTRY_SETUP', 'NUMBER', null, null, 'COLUMN', 'VALUE_1', null FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'VALUE_1', 'VAT_DEST_COUNTRY_SETUP', 'NUMBER', null, null, 'COLUMN', 'VALUE_1', null FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'VALUE_1', 'VAT_ORIG_COUNTRY_SETUP', 'NUMBER', null, null, 'COLUMN', 'VALUE_1', null FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'VALUE_1', 'VAT_VEND_COUNTRY_SETUP', 'NUMBER', null, null, 'COLUMN', 'VALUE_1', null FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'VALUE_10', 'VAT_CUST_COUNTRY_SETUP', 'NUMBER', null, null, 'COLUMN', 'VALUE_10', null FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'VALUE_10', 'VAT_DEST_COUNTRY_SETUP', 'NUMBER', null, null, 'COLUMN', 'VALUE_10', null FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'VALUE_10', 'VAT_ORIG_COUNTRY_SETUP', 'NUMBER', null, null, 'COLUMN', 'VALUE_10', null FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'VALUE_10', 'VAT_VEND_COUNTRY_SETUP', 'NUMBER', null, null, 'COLUMN', 'VALUE_10', null FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'VALUE_2', 'OBJECT_CALC_COMPONENT', 'NUMBER', null, null, 'COLUMN', 'VALUE_2', null FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'VALUE_2', 'VAT_CUST_COUNTRY_SETUP', 'NUMBER', null, null, 'COLUMN', 'VALUE_2', null FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'VALUE_2', 'VAT_DEST_COUNTRY_SETUP', 'NUMBER', null, null, 'COLUMN', 'VALUE_2', null FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'VALUE_2', 'VAT_ORIG_COUNTRY_SETUP', 'NUMBER', null, null, 'COLUMN', 'VALUE_2', null FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'VALUE_2', 'VAT_VEND_COUNTRY_SETUP', 'NUMBER', null, null, 'COLUMN', 'VALUE_2', null FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'VALUE_3', 'OBJECT_CALC_COMPONENT', 'NUMBER', null, null, 'COLUMN', 'VALUE_3', null FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'VALUE_3', 'VAT_CUST_COUNTRY_SETUP', 'NUMBER', null, null, 'COLUMN', 'VALUE_3', null FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'VALUE_3', 'VAT_DEST_COUNTRY_SETUP', 'NUMBER', null, null, 'COLUMN', 'VALUE_3', null FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'VALUE_3', 'VAT_ORIG_COUNTRY_SETUP', 'NUMBER', null, null, 'COLUMN', 'VALUE_3', null FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'VALUE_3', 'VAT_VEND_COUNTRY_SETUP', 'NUMBER', null, null, 'COLUMN', 'VALUE_3', null FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'VALUE_4', 'OBJECT_CALC_COMPONENT', 'NUMBER', null, null, 'COLUMN', 'VALUE_4', null FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'VALUE_4', 'VAT_CUST_COUNTRY_SETUP', 'NUMBER', null, null, 'COLUMN', 'VALUE_4', null FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'VALUE_4', 'VAT_DEST_COUNTRY_SETUP', 'NUMBER', null, null, 'COLUMN', 'VALUE_4', null FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'VALUE_4', 'VAT_ORIG_COUNTRY_SETUP', 'NUMBER', null, null, 'COLUMN', 'VALUE_4', null FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'VALUE_4', 'VAT_VEND_COUNTRY_SETUP', 'NUMBER', null, null, 'COLUMN', 'VALUE_4', null FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'VALUE_5', 'OBJECT_CALC_COMPONENT', 'NUMBER', null, null, 'COLUMN', 'VALUE_5', null FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'VALUE_5', 'VAT_CUST_COUNTRY_SETUP', 'NUMBER', null, null, 'COLUMN', 'VALUE_5', null FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'VALUE_5', 'VAT_DEST_COUNTRY_SETUP', 'NUMBER', null, null, 'COLUMN', 'VALUE_5', null FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'VALUE_5', 'VAT_ORIG_COUNTRY_SETUP', 'NUMBER', null, null, 'COLUMN', 'VALUE_5', null FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'VALUE_5', 'VAT_VEND_COUNTRY_SETUP', 'NUMBER', null, null, 'COLUMN', 'VALUE_5', null FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'VALUE_6', 'VAT_CUST_COUNTRY_SETUP', 'NUMBER', null, null, 'COLUMN', 'VALUE_6', null FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'VALUE_6', 'VAT_DEST_COUNTRY_SETUP', 'NUMBER', null, null, 'COLUMN', 'VALUE_6', null FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'VALUE_6', 'VAT_ORIG_COUNTRY_SETUP', 'NUMBER', null, null, 'COLUMN', 'VALUE_6', null FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'VALUE_6', 'VAT_VEND_COUNTRY_SETUP', 'NUMBER', null, null, 'COLUMN', 'VALUE_6', null FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'VALUE_7', 'VAT_CUST_COUNTRY_SETUP', 'NUMBER', null, null, 'COLUMN', 'VALUE_7', null FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'VALUE_7', 'VAT_DEST_COUNTRY_SETUP', 'NUMBER', null, null, 'COLUMN', 'VALUE_7', null FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'VALUE_7', 'VAT_ORIG_COUNTRY_SETUP', 'NUMBER', null, null, 'COLUMN', 'VALUE_7', null FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'VALUE_7', 'VAT_VEND_COUNTRY_SETUP', 'NUMBER', null, null, 'COLUMN', 'VALUE_7', null FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'VALUE_8', 'VAT_CUST_COUNTRY_SETUP', 'NUMBER', null, null, 'COLUMN', 'VALUE_8', null FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'VALUE_8', 'VAT_DEST_COUNTRY_SETUP', 'NUMBER', null, null, 'COLUMN', 'VALUE_8', null FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'VALUE_8', 'VAT_ORIG_COUNTRY_SETUP', 'NUMBER', null, null, 'COLUMN', 'VALUE_8', null FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'VALUE_8', 'VAT_VEND_COUNTRY_SETUP', 'NUMBER', null, null, 'COLUMN', 'VALUE_8', null FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'VALUE_9', 'VAT_CUST_COUNTRY_SETUP', 'NUMBER', null, null, 'COLUMN', 'VALUE_9', null FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'VALUE_9', 'VAT_DEST_COUNTRY_SETUP', 'NUMBER', null, null, 'COLUMN', 'VALUE_9', null FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'VALUE_9', 'VAT_ORIG_COUNTRY_SETUP', 'NUMBER', null, null, 'COLUMN', 'VALUE_9', null FROM DUAL 
UNION 
 SELECT 'DELETE_CANDIDATE', 'VALUE_9', 'VAT_VEND_COUNTRY_SETUP', 'NUMBER', null, null, 'COLUMN', 'VALUE_9', null FROM DUAL
 ) n
ON (o.ATTRIBUTE_NAME = n.ATTRIBUTE_NAME
 AND o.CLASS_NAME = n.CLASS_NAME)
WHEN MATCHED THEN UPDATE SET
o.APP_SPACE_CNTX = n.APP_SPACE_CNTX
,o.DATA_TYPE = n.DATA_TYPE
,o.DB_JOIN_TABLE = n.DB_JOIN_TABLE
,o.DB_JOIN_WHERE = n.DB_JOIN_WHERE
,o.DB_MAPPING_TYPE = n.DB_MAPPING_TYPE
,o.DB_SQL_SYNTAX = n.DB_SQL_SYNTAX
,o.IS_KEY = n.IS_KEY
,o.LAST_UPDATED_BY = 'UPGD-TOOL-12.0-DM'
,o.REV_NO = o.REV_NO+1
WHEN NOT MATCHED THEN INSERT
(APP_SPACE_CNTX,ATTRIBUTE_NAME,CLASS_NAME,DATA_TYPE,DB_JOIN_TABLE,DB_JOIN_WHERE,DB_MAPPING_TYPE,DB_SQL_SYNTAX,IS_KEY,CREATED_BY)
VALUES( n.APP_SPACE_CNTX, n.ATTRIBUTE_NAME, n.CLASS_NAME, n.DATA_TYPE, n.DB_JOIN_TABLE, n.DB_JOIN_WHERE, n.DB_MAPPING_TYPE, n.DB_SQL_SYNTAX, n.IS_KEY,'UPGD-TOOL-12.0-DM');


MERGE INTO CLASS_ATTR_PROPERTY_CNFG o USING 
(
SELECT
 null ATTRIBUTE_NAME, null CLASS_NAME, null OWNER_CNTX, null PRESENTATION_CNTX, null PROPERTY_CODE, null PROPERTY_TYPE, null PROPERTY_VALUE FROM DUAL WHERE 1=0
UNION 
 SELECT 'DATE_1', 'TANK_FINDER_OBJECTS', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '9114' FROM DUAL 
UNION 
 SELECT 'DATE_1', 'TANK_FINDER_OBJECTS', '1000', '/', 'DISABLED_IND', 'VIEWLAYER', 'Y' FROM DUAL 
UNION 
 SELECT 'DATE_1', 'TANK_FINDER_OBJECTS', '1000', '/', 'IS_MANDATORY', 'VIEWLAYER', 'N' FROM DUAL 
UNION 
 SELECT 'DATE_1', 'TANK_FINDER_OBJECTS', '1000', '/EC', 'DESCRIPTION', 'APPLICATION', 'Date 1' FROM DUAL 
UNION 
 SELECT 'DATE_1', 'TANK_FINDER_OBJECTS', '1000', '/EC', 'LABEL', 'APPLICATION', 'Date 1' FROM DUAL 
UNION 
 SELECT 'DATE_1', 'TANK_FINDER_OBJECTS', '1000', '/EC', 'NAME', 'APPLICATION', 'Date 1' FROM DUAL 
UNION 
 SELECT 'DATE_1', 'TANK_FINDER_OBJECTS', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '9114' FROM DUAL 
UNION 
 SELECT 'DATE_1', 'TANK_FINDER_OBJECTS', '1000', '/EC', 'vieweditable', 'STATIC_PRESENTATION', 'false' FROM DUAL 
UNION 
 SELECT 'DATE_1', 'TANK_FINDER_OBJECTS', '1000', '/EC', 'viewwidth', 'STATIC_PRESENTATION', '150' FROM DUAL 
UNION 
 SELECT 'DATE_1', 'VAT_CUST_COUNTRY_SETUP', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '260' FROM DUAL 
UNION 
 SELECT 'DATE_1', 'VAT_CUST_COUNTRY_SETUP', '1000', '/', 'DISABLED_IND', 'VIEWLAYER', 'Y' FROM DUAL 
UNION 
 SELECT 'DATE_1', 'VAT_CUST_COUNTRY_SETUP', '1000', '/EC', 'DESCRIPTION', 'APPLICATION', 'Standard date field that can be used by projects' FROM DUAL 
UNION 
 SELECT 'DATE_1', 'VAT_CUST_COUNTRY_SETUP', '1000', '/EC', 'LABEL', 'APPLICATION', 'Date 1' FROM DUAL 
UNION 
 SELECT 'DATE_1', 'VAT_CUST_COUNTRY_SETUP', '1000', '/EC', 'NAME', 'APPLICATION', 'Date 1' FROM DUAL 
UNION 
 SELECT 'DATE_1', 'VAT_CUST_COUNTRY_SETUP', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '260' FROM DUAL 
UNION 
 SELECT 'DATE_1', 'VAT_CUST_COUNTRY_SETUP', '1000', '/EC', 'viewwidth', 'STATIC_PRESENTATION', '120' FROM DUAL 
UNION 
 SELECT 'DATE_1', 'VAT_DEST_COUNTRY_SETUP', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '260' FROM DUAL 
UNION 
 SELECT 'DATE_1', 'VAT_DEST_COUNTRY_SETUP', '1000', '/', 'DISABLED_IND', 'VIEWLAYER', 'Y' FROM DUAL 
UNION 
 SELECT 'DATE_1', 'VAT_DEST_COUNTRY_SETUP', '1000', '/EC', 'DESCRIPTION', 'APPLICATION', 'Standard date field that can be used by projects' FROM DUAL 
UNION 
 SELECT 'DATE_1', 'VAT_DEST_COUNTRY_SETUP', '1000', '/EC', 'LABEL', 'APPLICATION', 'Date 1' FROM DUAL 
UNION 
 SELECT 'DATE_1', 'VAT_DEST_COUNTRY_SETUP', '1000', '/EC', 'NAME', 'APPLICATION', 'Date 1' FROM DUAL 
UNION 
 SELECT 'DATE_1', 'VAT_DEST_COUNTRY_SETUP', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '260' FROM DUAL 
UNION 
 SELECT 'DATE_1', 'VAT_DEST_COUNTRY_SETUP', '1000', '/EC', 'viewwidth', 'STATIC_PRESENTATION', '120' FROM DUAL 
UNION 
 SELECT 'DATE_1', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '260' FROM DUAL 
UNION 
 SELECT 'DATE_1', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/', 'DISABLED_IND', 'VIEWLAYER', 'Y' FROM DUAL 
UNION 
 SELECT 'DATE_1', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/EC', 'DESCRIPTION', 'APPLICATION', 'Standard date field that can be used by projects' FROM DUAL 
UNION 
 SELECT 'DATE_1', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/EC', 'LABEL', 'APPLICATION', 'Date 1' FROM DUAL 
UNION 
 SELECT 'DATE_1', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/EC', 'NAME', 'APPLICATION', 'Date 1' FROM DUAL 
UNION 
 SELECT 'DATE_1', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '260' FROM DUAL 
UNION 
 SELECT 'DATE_1', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/EC', 'viewwidth', 'STATIC_PRESENTATION', '120' FROM DUAL 
UNION 
 SELECT 'DATE_1', 'VAT_VEND_COUNTRY_SETUP', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '260' FROM DUAL 
UNION 
 SELECT 'DATE_1', 'VAT_VEND_COUNTRY_SETUP', '1000', '/', 'DISABLED_IND', 'VIEWLAYER', 'Y' FROM DUAL 
UNION 
 SELECT 'DATE_1', 'VAT_VEND_COUNTRY_SETUP', '1000', '/EC', 'DESCRIPTION', 'APPLICATION', 'Standard date field that can be used by projects' FROM DUAL 
UNION 
 SELECT 'DATE_1', 'VAT_VEND_COUNTRY_SETUP', '1000', '/EC', 'LABEL', 'APPLICATION', 'Date 1' FROM DUAL 
UNION 
 SELECT 'DATE_1', 'VAT_VEND_COUNTRY_SETUP', '1000', '/EC', 'NAME', 'APPLICATION', 'Date 1' FROM DUAL 
UNION 
 SELECT 'DATE_1', 'VAT_VEND_COUNTRY_SETUP', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '260' FROM DUAL 
UNION 
 SELECT 'DATE_1', 'VAT_VEND_COUNTRY_SETUP', '1000', '/EC', 'viewwidth', 'STATIC_PRESENTATION', '120' FROM DUAL 
UNION 
 SELECT 'DATE_10', 'VAT_CUST_COUNTRY_SETUP', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '350' FROM DUAL 
UNION 
 SELECT 'DATE_10', 'VAT_CUST_COUNTRY_SETUP', '1000', '/', 'DISABLED_IND', 'VIEWLAYER', 'Y' FROM DUAL 
UNION 
 SELECT 'DATE_10', 'VAT_CUST_COUNTRY_SETUP', '1000', '/EC', 'DESCRIPTION', 'APPLICATION', 'Standard date field that can be used by projects' FROM DUAL 
UNION 
 SELECT 'DATE_10', 'VAT_CUST_COUNTRY_SETUP', '1000', '/EC', 'LABEL', 'APPLICATION', 'Date 10' FROM DUAL 
UNION 
 SELECT 'DATE_10', 'VAT_CUST_COUNTRY_SETUP', '1000', '/EC', 'NAME', 'APPLICATION', 'Date 10' FROM DUAL 
UNION 
 SELECT 'DATE_10', 'VAT_CUST_COUNTRY_SETUP', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '350' FROM DUAL 
UNION 
 SELECT 'DATE_10', 'VAT_CUST_COUNTRY_SETUP', '1000', '/EC', 'viewwidth', 'STATIC_PRESENTATION', '120' FROM DUAL 
UNION 
 SELECT 'DATE_10', 'VAT_DEST_COUNTRY_SETUP', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '350' FROM DUAL 
UNION 
 SELECT 'DATE_10', 'VAT_DEST_COUNTRY_SETUP', '1000', '/', 'DISABLED_IND', 'VIEWLAYER', 'Y' FROM DUAL 
UNION 
 SELECT 'DATE_10', 'VAT_DEST_COUNTRY_SETUP', '1000', '/EC', 'DESCRIPTION', 'APPLICATION', 'Standard date field that can be used by projects' FROM DUAL 
UNION 
 SELECT 'DATE_10', 'VAT_DEST_COUNTRY_SETUP', '1000', '/EC', 'LABEL', 'APPLICATION', 'Date 10' FROM DUAL 
UNION 
 SELECT 'DATE_10', 'VAT_DEST_COUNTRY_SETUP', '1000', '/EC', 'NAME', 'APPLICATION', 'Date 10' FROM DUAL 
UNION 
 SELECT 'DATE_10', 'VAT_DEST_COUNTRY_SETUP', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '350' FROM DUAL 
UNION 
 SELECT 'DATE_10', 'VAT_DEST_COUNTRY_SETUP', '1000', '/EC', 'viewwidth', 'STATIC_PRESENTATION', '120' FROM DUAL 
UNION 
 SELECT 'DATE_10', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '350' FROM DUAL 
UNION 
 SELECT 'DATE_10', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/', 'DISABLED_IND', 'VIEWLAYER', 'Y' FROM DUAL 
UNION 
 SELECT 'DATE_10', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/EC', 'DESCRIPTION', 'APPLICATION', 'Standard date field that can be used by projects' FROM DUAL 
UNION 
 SELECT 'DATE_10', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/EC', 'LABEL', 'APPLICATION', 'Date 10' FROM DUAL 
UNION 
 SELECT 'DATE_10', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/EC', 'NAME', 'APPLICATION', 'Date 10' FROM DUAL 
UNION 
 SELECT 'DATE_10', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '350' FROM DUAL 
UNION 
 SELECT 'DATE_10', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/EC', 'viewwidth', 'STATIC_PRESENTATION', '120' FROM DUAL 
UNION 
 SELECT 'DATE_10', 'VAT_VEND_COUNTRY_SETUP', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '350' FROM DUAL 
UNION 
 SELECT 'DATE_10', 'VAT_VEND_COUNTRY_SETUP', '1000', '/', 'DISABLED_IND', 'VIEWLAYER', 'Y' FROM DUAL 
UNION 
 SELECT 'DATE_10', 'VAT_VEND_COUNTRY_SETUP', '1000', '/EC', 'DESCRIPTION', 'APPLICATION', 'Standard date field that can be used by projects' FROM DUAL 
UNION 
 SELECT 'DATE_10', 'VAT_VEND_COUNTRY_SETUP', '1000', '/EC', 'LABEL', 'APPLICATION', 'Date 10' FROM DUAL 
UNION 
 SELECT 'DATE_10', 'VAT_VEND_COUNTRY_SETUP', '1000', '/EC', 'NAME', 'APPLICATION', 'Date 10' FROM DUAL 
UNION 
 SELECT 'DATE_10', 'VAT_VEND_COUNTRY_SETUP', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '350' FROM DUAL 
UNION 
 SELECT 'DATE_10', 'VAT_VEND_COUNTRY_SETUP', '1000', '/EC', 'viewwidth', 'STATIC_PRESENTATION', '120' FROM DUAL 
UNION 
 SELECT 'DATE_2', 'TANK_FINDER_OBJECTS', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '9115' FROM DUAL 
UNION 
 SELECT 'DATE_2', 'TANK_FINDER_OBJECTS', '1000', '/', 'DISABLED_IND', 'VIEWLAYER', 'Y' FROM DUAL 
UNION 
 SELECT 'DATE_2', 'TANK_FINDER_OBJECTS', '1000', '/', 'IS_MANDATORY', 'VIEWLAYER', 'N' FROM DUAL 
UNION 
 SELECT 'DATE_2', 'TANK_FINDER_OBJECTS', '1000', '/EC', 'DESCRIPTION', 'APPLICATION', 'Date 2' FROM DUAL 
UNION 
 SELECT 'DATE_2', 'TANK_FINDER_OBJECTS', '1000', '/EC', 'LABEL', 'APPLICATION', 'Date 2' FROM DUAL 
UNION 
 SELECT 'DATE_2', 'TANK_FINDER_OBJECTS', '1000', '/EC', 'NAME', 'APPLICATION', 'Date 2' FROM DUAL 
UNION 
 SELECT 'DATE_2', 'TANK_FINDER_OBJECTS', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '9115' FROM DUAL 
UNION 
 SELECT 'DATE_2', 'TANK_FINDER_OBJECTS', '1000', '/EC', 'vieweditable', 'STATIC_PRESENTATION', 'false' FROM DUAL 
UNION 
 SELECT 'DATE_2', 'TANK_FINDER_OBJECTS', '1000', '/EC', 'viewwidth', 'STATIC_PRESENTATION', '150' FROM DUAL 
UNION 
 SELECT 'DATE_2', 'VAT_CUST_COUNTRY_SETUP', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '270' FROM DUAL 
UNION 
 SELECT 'DATE_2', 'VAT_CUST_COUNTRY_SETUP', '1000', '/', 'DISABLED_IND', 'VIEWLAYER', 'Y' FROM DUAL 
UNION 
 SELECT 'DATE_2', 'VAT_CUST_COUNTRY_SETUP', '1000', '/EC', 'DESCRIPTION', 'APPLICATION', 'Standard date field that can be used by projects' FROM DUAL 
UNION 
 SELECT 'DATE_2', 'VAT_CUST_COUNTRY_SETUP', '1000', '/EC', 'LABEL', 'APPLICATION', 'Date 2' FROM DUAL 
UNION 
 SELECT 'DATE_2', 'VAT_CUST_COUNTRY_SETUP', '1000', '/EC', 'NAME', 'APPLICATION', 'Date 2' FROM DUAL 
UNION 
 SELECT 'DATE_2', 'VAT_CUST_COUNTRY_SETUP', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '270' FROM DUAL 
UNION 
 SELECT 'DATE_2', 'VAT_CUST_COUNTRY_SETUP', '1000', '/EC', 'viewwidth', 'STATIC_PRESENTATION', '120' FROM DUAL 
UNION 
 SELECT 'DATE_2', 'VAT_DEST_COUNTRY_SETUP', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '270' FROM DUAL 
UNION 
 SELECT 'DATE_2', 'VAT_DEST_COUNTRY_SETUP', '1000', '/', 'DISABLED_IND', 'VIEWLAYER', 'Y' FROM DUAL 
UNION 
 SELECT 'DATE_2', 'VAT_DEST_COUNTRY_SETUP', '1000', '/EC', 'DESCRIPTION', 'APPLICATION', 'Standard date field that can be used by projects' FROM DUAL 
UNION 
 SELECT 'DATE_2', 'VAT_DEST_COUNTRY_SETUP', '1000', '/EC', 'LABEL', 'APPLICATION', 'Date 2' FROM DUAL 
UNION 
 SELECT 'DATE_2', 'VAT_DEST_COUNTRY_SETUP', '1000', '/EC', 'NAME', 'APPLICATION', 'Date 2' FROM DUAL 
UNION 
 SELECT 'DATE_2', 'VAT_DEST_COUNTRY_SETUP', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '270' FROM DUAL 
UNION 
 SELECT 'DATE_2', 'VAT_DEST_COUNTRY_SETUP', '1000', '/EC', 'viewwidth', 'STATIC_PRESENTATION', '120' FROM DUAL 
UNION 
 SELECT 'DATE_2', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '270' FROM DUAL 
UNION 
 SELECT 'DATE_2', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/', 'DISABLED_IND', 'VIEWLAYER', 'Y' FROM DUAL 
UNION 
 SELECT 'DATE_2', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/EC', 'DESCRIPTION', 'APPLICATION', 'Standard date field that can be used by projects' FROM DUAL 
UNION 
 SELECT 'DATE_2', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/EC', 'LABEL', 'APPLICATION', 'Date 2' FROM DUAL 
UNION 
 SELECT 'DATE_2', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/EC', 'NAME', 'APPLICATION', 'Date 2' FROM DUAL 
UNION 
 SELECT 'DATE_2', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '270' FROM DUAL 
UNION 
 SELECT 'DATE_2', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/EC', 'viewwidth', 'STATIC_PRESENTATION', '120' FROM DUAL 
UNION 
 SELECT 'DATE_2', 'VAT_VEND_COUNTRY_SETUP', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '270' FROM DUAL 
UNION 
 SELECT 'DATE_2', 'VAT_VEND_COUNTRY_SETUP', '1000', '/', 'DISABLED_IND', 'VIEWLAYER', 'Y' FROM DUAL 
UNION 
 SELECT 'DATE_2', 'VAT_VEND_COUNTRY_SETUP', '1000', '/EC', 'DESCRIPTION', 'APPLICATION', 'Standard date field that can be used by projects' FROM DUAL 
UNION 
 SELECT 'DATE_2', 'VAT_VEND_COUNTRY_SETUP', '1000', '/EC', 'LABEL', 'APPLICATION', 'Date 2' FROM DUAL 
UNION 
 SELECT 'DATE_2', 'VAT_VEND_COUNTRY_SETUP', '1000', '/EC', 'NAME', 'APPLICATION', 'Date 2' FROM DUAL 
UNION 
 SELECT 'DATE_2', 'VAT_VEND_COUNTRY_SETUP', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '270' FROM DUAL 
UNION 
 SELECT 'DATE_2', 'VAT_VEND_COUNTRY_SETUP', '1000', '/EC', 'viewwidth', 'STATIC_PRESENTATION', '120' FROM DUAL 
UNION 
 SELECT 'DATE_3', 'TANK_FINDER_OBJECTS', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '9116' FROM DUAL 
UNION 
 SELECT 'DATE_3', 'TANK_FINDER_OBJECTS', '1000', '/', 'DISABLED_IND', 'VIEWLAYER', 'Y' FROM DUAL 
UNION 
 SELECT 'DATE_3', 'TANK_FINDER_OBJECTS', '1000', '/', 'IS_MANDATORY', 'VIEWLAYER', 'N' FROM DUAL 
UNION 
 SELECT 'DATE_3', 'TANK_FINDER_OBJECTS', '1000', '/EC', 'DESCRIPTION', 'APPLICATION', 'Date 3' FROM DUAL 
UNION 
 SELECT 'DATE_3', 'TANK_FINDER_OBJECTS', '1000', '/EC', 'LABEL', 'APPLICATION', 'Date 3' FROM DUAL 
UNION 
 SELECT 'DATE_3', 'TANK_FINDER_OBJECTS', '1000', '/EC', 'NAME', 'APPLICATION', 'Date 3' FROM DUAL 
UNION 
 SELECT 'DATE_3', 'TANK_FINDER_OBJECTS', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '9116' FROM DUAL 
UNION 
 SELECT 'DATE_3', 'TANK_FINDER_OBJECTS', '1000', '/EC', 'vieweditable', 'STATIC_PRESENTATION', 'false' FROM DUAL 
UNION 
 SELECT 'DATE_3', 'TANK_FINDER_OBJECTS', '1000', '/EC', 'viewwidth', 'STATIC_PRESENTATION', '150' FROM DUAL 
UNION 
 SELECT 'DATE_3', 'VAT_CUST_COUNTRY_SETUP', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '280' FROM DUAL 
UNION 
 SELECT 'DATE_3', 'VAT_CUST_COUNTRY_SETUP', '1000', '/', 'DISABLED_IND', 'VIEWLAYER', 'Y' FROM DUAL 
UNION 
 SELECT 'DATE_3', 'VAT_CUST_COUNTRY_SETUP', '1000', '/EC', 'DESCRIPTION', 'APPLICATION', 'Standard date field that can be used by projects' FROM DUAL 
UNION 
 SELECT 'DATE_3', 'VAT_CUST_COUNTRY_SETUP', '1000', '/EC', 'LABEL', 'APPLICATION', 'Date 3' FROM DUAL 
UNION 
 SELECT 'DATE_3', 'VAT_CUST_COUNTRY_SETUP', '1000', '/EC', 'NAME', 'APPLICATION', 'Date 3' FROM DUAL 
UNION 
 SELECT 'DATE_3', 'VAT_CUST_COUNTRY_SETUP', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '280' FROM DUAL 
UNION 
 SELECT 'DATE_3', 'VAT_CUST_COUNTRY_SETUP', '1000', '/EC', 'viewwidth', 'STATIC_PRESENTATION', '120' FROM DUAL 
UNION 
 SELECT 'DATE_3', 'VAT_DEST_COUNTRY_SETUP', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '280' FROM DUAL 
UNION 
 SELECT 'DATE_3', 'VAT_DEST_COUNTRY_SETUP', '1000', '/', 'DISABLED_IND', 'VIEWLAYER', 'Y' FROM DUAL 
UNION 
 SELECT 'DATE_3', 'VAT_DEST_COUNTRY_SETUP', '1000', '/EC', 'DESCRIPTION', 'APPLICATION', 'Standard date field that can be used by projects' FROM DUAL 
UNION 
 SELECT 'DATE_3', 'VAT_DEST_COUNTRY_SETUP', '1000', '/EC', 'LABEL', 'APPLICATION', 'Date 3' FROM DUAL 
UNION 
 SELECT 'DATE_3', 'VAT_DEST_COUNTRY_SETUP', '1000', '/EC', 'NAME', 'APPLICATION', 'Date 3' FROM DUAL 
UNION 
 SELECT 'DATE_3', 'VAT_DEST_COUNTRY_SETUP', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '280' FROM DUAL 
UNION 
 SELECT 'DATE_3', 'VAT_DEST_COUNTRY_SETUP', '1000', '/EC', 'viewwidth', 'STATIC_PRESENTATION', '120' FROM DUAL 
UNION 
 SELECT 'DATE_3', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '280' FROM DUAL 
UNION 
 SELECT 'DATE_3', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/', 'DISABLED_IND', 'VIEWLAYER', 'Y' FROM DUAL 
UNION 
 SELECT 'DATE_3', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/EC', 'DESCRIPTION', 'APPLICATION', 'Standard date field that can be used by projects' FROM DUAL 
UNION 
 SELECT 'DATE_3', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/EC', 'LABEL', 'APPLICATION', 'Date 3' FROM DUAL 
UNION 
 SELECT 'DATE_3', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/EC', 'NAME', 'APPLICATION', 'Date 3' FROM DUAL 
UNION 
 SELECT 'DATE_3', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '280' FROM DUAL 
UNION 
 SELECT 'DATE_3', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/EC', 'viewwidth', 'STATIC_PRESENTATION', '120' FROM DUAL 
UNION 
 SELECT 'DATE_3', 'VAT_VEND_COUNTRY_SETUP', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '280' FROM DUAL 
UNION 
 SELECT 'DATE_3', 'VAT_VEND_COUNTRY_SETUP', '1000', '/', 'DISABLED_IND', 'VIEWLAYER', 'Y' FROM DUAL 
UNION 
 SELECT 'DATE_3', 'VAT_VEND_COUNTRY_SETUP', '1000', '/EC', 'DESCRIPTION', 'APPLICATION', 'Standard date field that can be used by projects' FROM DUAL 
UNION 
 SELECT 'DATE_3', 'VAT_VEND_COUNTRY_SETUP', '1000', '/EC', 'LABEL', 'APPLICATION', 'Date 3' FROM DUAL 
UNION 
 SELECT 'DATE_3', 'VAT_VEND_COUNTRY_SETUP', '1000', '/EC', 'NAME', 'APPLICATION', 'Date 3' FROM DUAL 
UNION 
 SELECT 'DATE_3', 'VAT_VEND_COUNTRY_SETUP', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '280' FROM DUAL 
UNION 
 SELECT 'DATE_3', 'VAT_VEND_COUNTRY_SETUP', '1000', '/EC', 'viewwidth', 'STATIC_PRESENTATION', '120' FROM DUAL 
UNION 
 SELECT 'DATE_4', 'TANK_FINDER_OBJECTS', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '9117' FROM DUAL 
UNION 
 SELECT 'DATE_4', 'TANK_FINDER_OBJECTS', '1000', '/', 'DISABLED_IND', 'VIEWLAYER', 'Y' FROM DUAL 
UNION 
 SELECT 'DATE_4', 'TANK_FINDER_OBJECTS', '1000', '/', 'IS_MANDATORY', 'VIEWLAYER', 'N' FROM DUAL 
UNION 
 SELECT 'DATE_4', 'TANK_FINDER_OBJECTS', '1000', '/EC', 'DESCRIPTION', 'APPLICATION', 'Date 4' FROM DUAL 
UNION 
 SELECT 'DATE_4', 'TANK_FINDER_OBJECTS', '1000', '/EC', 'LABEL', 'APPLICATION', 'Date 4' FROM DUAL 
UNION 
 SELECT 'DATE_4', 'TANK_FINDER_OBJECTS', '1000', '/EC', 'NAME', 'APPLICATION', 'Date 4' FROM DUAL 
UNION 
 SELECT 'DATE_4', 'TANK_FINDER_OBJECTS', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '9117' FROM DUAL 
UNION 
 SELECT 'DATE_4', 'TANK_FINDER_OBJECTS', '1000', '/EC', 'vieweditable', 'STATIC_PRESENTATION', 'false' FROM DUAL 
UNION 
 SELECT 'DATE_4', 'TANK_FINDER_OBJECTS', '1000', '/EC', 'viewwidth', 'STATIC_PRESENTATION', '150' FROM DUAL 
UNION 
 SELECT 'DATE_4', 'VAT_CUST_COUNTRY_SETUP', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '290' FROM DUAL 
UNION 
 SELECT 'DATE_4', 'VAT_CUST_COUNTRY_SETUP', '1000', '/', 'DISABLED_IND', 'VIEWLAYER', 'Y' FROM DUAL 
UNION 
 SELECT 'DATE_4', 'VAT_CUST_COUNTRY_SETUP', '1000', '/EC', 'DESCRIPTION', 'APPLICATION', 'Standard date field that can be used by projects' FROM DUAL 
UNION 
 SELECT 'DATE_4', 'VAT_CUST_COUNTRY_SETUP', '1000', '/EC', 'LABEL', 'APPLICATION', 'Date 4' FROM DUAL 
UNION 
 SELECT 'DATE_4', 'VAT_CUST_COUNTRY_SETUP', '1000', '/EC', 'NAME', 'APPLICATION', 'Date 4' FROM DUAL 
UNION 
 SELECT 'DATE_4', 'VAT_CUST_COUNTRY_SETUP', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '290' FROM DUAL 
UNION 
 SELECT 'DATE_4', 'VAT_CUST_COUNTRY_SETUP', '1000', '/EC', 'viewwidth', 'STATIC_PRESENTATION', '120' FROM DUAL 
UNION 
 SELECT 'DATE_4', 'VAT_DEST_COUNTRY_SETUP', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '290' FROM DUAL 
UNION 
 SELECT 'DATE_4', 'VAT_DEST_COUNTRY_SETUP', '1000', '/', 'DISABLED_IND', 'VIEWLAYER', 'Y' FROM DUAL 
UNION 
 SELECT 'DATE_4', 'VAT_DEST_COUNTRY_SETUP', '1000', '/EC', 'DESCRIPTION', 'APPLICATION', 'Standard date field that can be used by projects' FROM DUAL 
UNION 
 SELECT 'DATE_4', 'VAT_DEST_COUNTRY_SETUP', '1000', '/EC', 'LABEL', 'APPLICATION', 'Date 4' FROM DUAL 
UNION 
 SELECT 'DATE_4', 'VAT_DEST_COUNTRY_SETUP', '1000', '/EC', 'NAME', 'APPLICATION', 'Date 4' FROM DUAL 
UNION 
 SELECT 'DATE_4', 'VAT_DEST_COUNTRY_SETUP', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '290' FROM DUAL 
UNION 
 SELECT 'DATE_4', 'VAT_DEST_COUNTRY_SETUP', '1000', '/EC', 'viewwidth', 'STATIC_PRESENTATION', '120' FROM DUAL 
UNION 
 SELECT 'DATE_4', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '290' FROM DUAL 
UNION 
 SELECT 'DATE_4', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/', 'DISABLED_IND', 'VIEWLAYER', 'Y' FROM DUAL 
UNION 
 SELECT 'DATE_4', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/EC', 'DESCRIPTION', 'APPLICATION', 'Standard date field that can be used by projects' FROM DUAL 
UNION 
 SELECT 'DATE_4', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/EC', 'LABEL', 'APPLICATION', 'Date 4' FROM DUAL 
UNION 
 SELECT 'DATE_4', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/EC', 'NAME', 'APPLICATION', 'Date 4' FROM DUAL 
UNION 
 SELECT 'DATE_4', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '290' FROM DUAL 
UNION 
 SELECT 'DATE_4', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/EC', 'viewwidth', 'STATIC_PRESENTATION', '120' FROM DUAL 
UNION 
 SELECT 'DATE_4', 'VAT_VEND_COUNTRY_SETUP', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '290' FROM DUAL 
UNION 
 SELECT 'DATE_4', 'VAT_VEND_COUNTRY_SETUP', '1000', '/', 'DISABLED_IND', 'VIEWLAYER', 'Y' FROM DUAL 
UNION 
 SELECT 'DATE_4', 'VAT_VEND_COUNTRY_SETUP', '1000', '/EC', 'DESCRIPTION', 'APPLICATION', 'Standard date field that can be used by projects' FROM DUAL 
UNION 
 SELECT 'DATE_4', 'VAT_VEND_COUNTRY_SETUP', '1000', '/EC', 'LABEL', 'APPLICATION', 'Date 4' FROM DUAL 
UNION 
 SELECT 'DATE_4', 'VAT_VEND_COUNTRY_SETUP', '1000', '/EC', 'NAME', 'APPLICATION', 'Date 4' FROM DUAL 
UNION 
 SELECT 'DATE_4', 'VAT_VEND_COUNTRY_SETUP', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '290' FROM DUAL 
UNION 
 SELECT 'DATE_4', 'VAT_VEND_COUNTRY_SETUP', '1000', '/EC', 'viewwidth', 'STATIC_PRESENTATION', '120' FROM DUAL 
UNION 
 SELECT 'DATE_5', 'TANK_FINDER_OBJECTS', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '9118' FROM DUAL 
UNION 
 SELECT 'DATE_5', 'TANK_FINDER_OBJECTS', '1000', '/', 'DISABLED_IND', 'VIEWLAYER', 'Y' FROM DUAL 
UNION 
 SELECT 'DATE_5', 'TANK_FINDER_OBJECTS', '1000', '/', 'IS_MANDATORY', 'VIEWLAYER', 'N' FROM DUAL 
UNION 
 SELECT 'DATE_5', 'TANK_FINDER_OBJECTS', '1000', '/EC', 'DESCRIPTION', 'APPLICATION', 'Date 5' FROM DUAL 
UNION 
 SELECT 'DATE_5', 'TANK_FINDER_OBJECTS', '1000', '/EC', 'LABEL', 'APPLICATION', 'Date 5' FROM DUAL 
UNION 
 SELECT 'DATE_5', 'TANK_FINDER_OBJECTS', '1000', '/EC', 'NAME', 'APPLICATION', 'Date 5' FROM DUAL 
UNION 
 SELECT 'DATE_5', 'TANK_FINDER_OBJECTS', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '9118' FROM DUAL 
UNION 
 SELECT 'DATE_5', 'TANK_FINDER_OBJECTS', '1000', '/EC', 'vieweditable', 'STATIC_PRESENTATION', 'false' FROM DUAL 
UNION 
 SELECT 'DATE_5', 'TANK_FINDER_OBJECTS', '1000', '/EC', 'viewwidth', 'STATIC_PRESENTATION', '150' FROM DUAL 
UNION 
 SELECT 'DATE_5', 'VAT_CUST_COUNTRY_SETUP', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '300' FROM DUAL 
UNION 
 SELECT 'DATE_5', 'VAT_CUST_COUNTRY_SETUP', '1000', '/', 'DISABLED_IND', 'VIEWLAYER', 'Y' FROM DUAL 
UNION 
 SELECT 'DATE_5', 'VAT_CUST_COUNTRY_SETUP', '1000', '/EC', 'DESCRIPTION', 'APPLICATION', 'Standard date field that can be used by projects' FROM DUAL 
UNION 
 SELECT 'DATE_5', 'VAT_CUST_COUNTRY_SETUP', '1000', '/EC', 'LABEL', 'APPLICATION', 'Date 5' FROM DUAL 
UNION 
 SELECT 'DATE_5', 'VAT_CUST_COUNTRY_SETUP', '1000', '/EC', 'NAME', 'APPLICATION', 'Date 5' FROM DUAL 
UNION 
 SELECT 'DATE_5', 'VAT_CUST_COUNTRY_SETUP', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '300' FROM DUAL 
UNION 
 SELECT 'DATE_5', 'VAT_CUST_COUNTRY_SETUP', '1000', '/EC', 'viewwidth', 'STATIC_PRESENTATION', '120' FROM DUAL 
UNION 
 SELECT 'DATE_5', 'VAT_DEST_COUNTRY_SETUP', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '300' FROM DUAL 
UNION 
 SELECT 'DATE_5', 'VAT_DEST_COUNTRY_SETUP', '1000', '/', 'DISABLED_IND', 'VIEWLAYER', 'Y' FROM DUAL 
UNION 
 SELECT 'DATE_5', 'VAT_DEST_COUNTRY_SETUP', '1000', '/EC', 'DESCRIPTION', 'APPLICATION', 'Standard date field that can be used by projects' FROM DUAL 
UNION 
 SELECT 'DATE_5', 'VAT_DEST_COUNTRY_SETUP', '1000', '/EC', 'LABEL', 'APPLICATION', 'Date 5' FROM DUAL 
UNION 
 SELECT 'DATE_5', 'VAT_DEST_COUNTRY_SETUP', '1000', '/EC', 'NAME', 'APPLICATION', 'Date 5' FROM DUAL 
UNION 
 SELECT 'DATE_5', 'VAT_DEST_COUNTRY_SETUP', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '300' FROM DUAL 
UNION 
 SELECT 'DATE_5', 'VAT_DEST_COUNTRY_SETUP', '1000', '/EC', 'viewwidth', 'STATIC_PRESENTATION', '120' FROM DUAL 
UNION 
 SELECT 'DATE_5', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '300' FROM DUAL 
UNION 
 SELECT 'DATE_5', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/', 'DISABLED_IND', 'VIEWLAYER', 'Y' FROM DUAL 
UNION 
 SELECT 'DATE_5', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/EC', 'DESCRIPTION', 'APPLICATION', 'Standard date field that can be used by projects' FROM DUAL 
UNION 
 SELECT 'DATE_5', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/EC', 'LABEL', 'APPLICATION', 'Date 5' FROM DUAL 
UNION 
 SELECT 'DATE_5', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/EC', 'NAME', 'APPLICATION', 'Date 5' FROM DUAL 
UNION 
 SELECT 'DATE_5', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '300' FROM DUAL 
UNION 
 SELECT 'DATE_5', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/EC', 'viewwidth', 'STATIC_PRESENTATION', '120' FROM DUAL 
UNION 
 SELECT 'DATE_5', 'VAT_VEND_COUNTRY_SETUP', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '300' FROM DUAL 
UNION 
 SELECT 'DATE_5', 'VAT_VEND_COUNTRY_SETUP', '1000', '/', 'DISABLED_IND', 'VIEWLAYER', 'Y' FROM DUAL 
UNION 
 SELECT 'DATE_5', 'VAT_VEND_COUNTRY_SETUP', '1000', '/EC', 'DESCRIPTION', 'APPLICATION', 'Standard date field that can be used by projects' FROM DUAL 
UNION 
 SELECT 'DATE_5', 'VAT_VEND_COUNTRY_SETUP', '1000', '/EC', 'LABEL', 'APPLICATION', 'Date 5' FROM DUAL 
UNION 
 SELECT 'DATE_5', 'VAT_VEND_COUNTRY_SETUP', '1000', '/EC', 'NAME', 'APPLICATION', 'Date 5' FROM DUAL 
UNION 
 SELECT 'DATE_5', 'VAT_VEND_COUNTRY_SETUP', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '300' FROM DUAL 
UNION 
 SELECT 'DATE_5', 'VAT_VEND_COUNTRY_SETUP', '1000', '/EC', 'viewwidth', 'STATIC_PRESENTATION', '120' FROM DUAL 
UNION 
 SELECT 'DATE_6', 'VAT_CUST_COUNTRY_SETUP', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '310' FROM DUAL 
UNION 
 SELECT 'DATE_6', 'VAT_CUST_COUNTRY_SETUP', '1000', '/', 'DISABLED_IND', 'VIEWLAYER', 'Y' FROM DUAL 
UNION 
 SELECT 'DATE_6', 'VAT_CUST_COUNTRY_SETUP', '1000', '/EC', 'DESCRIPTION', 'APPLICATION', 'Standard date field that can be used by projects' FROM DUAL 
UNION 
 SELECT 'DATE_6', 'VAT_CUST_COUNTRY_SETUP', '1000', '/EC', 'LABEL', 'APPLICATION', 'Date 6' FROM DUAL 
UNION 
 SELECT 'DATE_6', 'VAT_CUST_COUNTRY_SETUP', '1000', '/EC', 'NAME', 'APPLICATION', 'Date 6' FROM DUAL 
UNION 
 SELECT 'DATE_6', 'VAT_CUST_COUNTRY_SETUP', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '310' FROM DUAL 
UNION 
 SELECT 'DATE_6', 'VAT_CUST_COUNTRY_SETUP', '1000', '/EC', 'viewwidth', 'STATIC_PRESENTATION', '120' FROM DUAL 
UNION 
 SELECT 'DATE_6', 'VAT_DEST_COUNTRY_SETUP', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '310' FROM DUAL 
UNION 
 SELECT 'DATE_6', 'VAT_DEST_COUNTRY_SETUP', '1000', '/', 'DISABLED_IND', 'VIEWLAYER', 'Y' FROM DUAL 
UNION 
 SELECT 'DATE_6', 'VAT_DEST_COUNTRY_SETUP', '1000', '/EC', 'DESCRIPTION', 'APPLICATION', 'Standard date field that can be used by projects' FROM DUAL 
UNION 
 SELECT 'DATE_6', 'VAT_DEST_COUNTRY_SETUP', '1000', '/EC', 'LABEL', 'APPLICATION', 'Date 6' FROM DUAL 
UNION 
 SELECT 'DATE_6', 'VAT_DEST_COUNTRY_SETUP', '1000', '/EC', 'NAME', 'APPLICATION', 'Date 6' FROM DUAL 
UNION 
 SELECT 'DATE_6', 'VAT_DEST_COUNTRY_SETUP', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '310' FROM DUAL 
UNION 
 SELECT 'DATE_6', 'VAT_DEST_COUNTRY_SETUP', '1000', '/EC', 'viewwidth', 'STATIC_PRESENTATION', '120' FROM DUAL 
UNION 
 SELECT 'DATE_6', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '310' FROM DUAL 
UNION 
 SELECT 'DATE_6', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/', 'DISABLED_IND', 'VIEWLAYER', 'Y' FROM DUAL 
UNION 
 SELECT 'DATE_6', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/EC', 'DESCRIPTION', 'APPLICATION', 'Standard date field that can be used by projects' FROM DUAL 
UNION 
 SELECT 'DATE_6', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/EC', 'LABEL', 'APPLICATION', 'Date 6' FROM DUAL 
UNION 
 SELECT 'DATE_6', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/EC', 'NAME', 'APPLICATION', 'Date 6' FROM DUAL 
UNION 
 SELECT 'DATE_6', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '310' FROM DUAL 
UNION 
 SELECT 'DATE_6', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/EC', 'viewwidth', 'STATIC_PRESENTATION', '120' FROM DUAL 
UNION 
 SELECT 'DATE_6', 'VAT_VEND_COUNTRY_SETUP', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '310' FROM DUAL 
UNION 
 SELECT 'DATE_6', 'VAT_VEND_COUNTRY_SETUP', '1000', '/', 'DISABLED_IND', 'VIEWLAYER', 'Y' FROM DUAL 
UNION 
 SELECT 'DATE_6', 'VAT_VEND_COUNTRY_SETUP', '1000', '/EC', 'DESCRIPTION', 'APPLICATION', 'Standard date field that can be used by projects' FROM DUAL 
UNION 
 SELECT 'DATE_6', 'VAT_VEND_COUNTRY_SETUP', '1000', '/EC', 'LABEL', 'APPLICATION', 'Date 6' FROM DUAL 
UNION 
 SELECT 'DATE_6', 'VAT_VEND_COUNTRY_SETUP', '1000', '/EC', 'NAME', 'APPLICATION', 'Date 6' FROM DUAL 
UNION 
 SELECT 'DATE_6', 'VAT_VEND_COUNTRY_SETUP', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '310' FROM DUAL 
UNION 
 SELECT 'DATE_6', 'VAT_VEND_COUNTRY_SETUP', '1000', '/EC', 'viewwidth', 'STATIC_PRESENTATION', '120' FROM DUAL 
UNION 
 SELECT 'DATE_7', 'VAT_CUST_COUNTRY_SETUP', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '320' FROM DUAL 
UNION 
 SELECT 'DATE_7', 'VAT_CUST_COUNTRY_SETUP', '1000', '/', 'DISABLED_IND', 'VIEWLAYER', 'Y' FROM DUAL 
UNION 
 SELECT 'DATE_7', 'VAT_CUST_COUNTRY_SETUP', '1000', '/EC', 'DESCRIPTION', 'APPLICATION', 'Standard date field that can be used by projects' FROM DUAL 
UNION 
 SELECT 'DATE_7', 'VAT_CUST_COUNTRY_SETUP', '1000', '/EC', 'LABEL', 'APPLICATION', 'Date 7' FROM DUAL 
UNION 
 SELECT 'DATE_7', 'VAT_CUST_COUNTRY_SETUP', '1000', '/EC', 'NAME', 'APPLICATION', 'Date 7' FROM DUAL 
UNION 
 SELECT 'DATE_7', 'VAT_CUST_COUNTRY_SETUP', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '320' FROM DUAL 
UNION 
 SELECT 'DATE_7', 'VAT_CUST_COUNTRY_SETUP', '1000', '/EC', 'viewwidth', 'STATIC_PRESENTATION', '120' FROM DUAL 
UNION 
 SELECT 'DATE_7', 'VAT_DEST_COUNTRY_SETUP', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '320' FROM DUAL 
UNION 
 SELECT 'DATE_7', 'VAT_DEST_COUNTRY_SETUP', '1000', '/', 'DISABLED_IND', 'VIEWLAYER', 'Y' FROM DUAL 
UNION 
 SELECT 'DATE_7', 'VAT_DEST_COUNTRY_SETUP', '1000', '/EC', 'DESCRIPTION', 'APPLICATION', 'Standard date field that can be used by projects' FROM DUAL 
UNION 
 SELECT 'DATE_7', 'VAT_DEST_COUNTRY_SETUP', '1000', '/EC', 'LABEL', 'APPLICATION', 'Date 7' FROM DUAL 
UNION 
 SELECT 'DATE_7', 'VAT_DEST_COUNTRY_SETUP', '1000', '/EC', 'NAME', 'APPLICATION', 'Date 7' FROM DUAL 
UNION 
 SELECT 'DATE_7', 'VAT_DEST_COUNTRY_SETUP', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '320' FROM DUAL 
UNION 
 SELECT 'DATE_7', 'VAT_DEST_COUNTRY_SETUP', '1000', '/EC', 'viewwidth', 'STATIC_PRESENTATION', '120' FROM DUAL 
UNION 
 SELECT 'DATE_7', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '320' FROM DUAL 
UNION 
 SELECT 'DATE_7', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/', 'DISABLED_IND', 'VIEWLAYER', 'Y' FROM DUAL 
UNION 
 SELECT 'DATE_7', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/EC', 'DESCRIPTION', 'APPLICATION', 'Standard date field that can be used by projects' FROM DUAL 
UNION 
 SELECT 'DATE_7', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/EC', 'LABEL', 'APPLICATION', 'Date 7' FROM DUAL 
UNION 
 SELECT 'DATE_7', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/EC', 'NAME', 'APPLICATION', 'Date 7' FROM DUAL 
UNION 
 SELECT 'DATE_7', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '320' FROM DUAL 
UNION 
 SELECT 'DATE_7', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/EC', 'viewwidth', 'STATIC_PRESENTATION', '120' FROM DUAL 
UNION 
 SELECT 'DATE_7', 'VAT_VEND_COUNTRY_SETUP', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '320' FROM DUAL 
UNION 
 SELECT 'DATE_7', 'VAT_VEND_COUNTRY_SETUP', '1000', '/', 'DISABLED_IND', 'VIEWLAYER', 'Y' FROM DUAL 
UNION 
 SELECT 'DATE_7', 'VAT_VEND_COUNTRY_SETUP', '1000', '/EC', 'DESCRIPTION', 'APPLICATION', 'Standard date field that can be used by projects' FROM DUAL 
UNION 
 SELECT 'DATE_7', 'VAT_VEND_COUNTRY_SETUP', '1000', '/EC', 'LABEL', 'APPLICATION', 'Date 7' FROM DUAL 
UNION 
 SELECT 'DATE_7', 'VAT_VEND_COUNTRY_SETUP', '1000', '/EC', 'NAME', 'APPLICATION', 'Date 7' FROM DUAL 
UNION 
 SELECT 'DATE_7', 'VAT_VEND_COUNTRY_SETUP', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '320' FROM DUAL 
UNION 
 SELECT 'DATE_7', 'VAT_VEND_COUNTRY_SETUP', '1000', '/EC', 'viewwidth', 'STATIC_PRESENTATION', '120' FROM DUAL 
UNION 
 SELECT 'DATE_8', 'VAT_CUST_COUNTRY_SETUP', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '330' FROM DUAL 
UNION 
 SELECT 'DATE_8', 'VAT_CUST_COUNTRY_SETUP', '1000', '/', 'DISABLED_IND', 'VIEWLAYER', 'Y' FROM DUAL 
UNION 
 SELECT 'DATE_8', 'VAT_CUST_COUNTRY_SETUP', '1000', '/EC', 'DESCRIPTION', 'APPLICATION', 'Standard date field that can be used by projects' FROM DUAL 
UNION 
 SELECT 'DATE_8', 'VAT_CUST_COUNTRY_SETUP', '1000', '/EC', 'LABEL', 'APPLICATION', 'Date 8' FROM DUAL 
UNION 
 SELECT 'DATE_8', 'VAT_CUST_COUNTRY_SETUP', '1000', '/EC', 'NAME', 'APPLICATION', 'Date 8' FROM DUAL 
UNION 
 SELECT 'DATE_8', 'VAT_CUST_COUNTRY_SETUP', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '330' FROM DUAL 
UNION 
 SELECT 'DATE_8', 'VAT_CUST_COUNTRY_SETUP', '1000', '/EC', 'viewwidth', 'STATIC_PRESENTATION', '120' FROM DUAL 
UNION 
 SELECT 'DATE_8', 'VAT_DEST_COUNTRY_SETUP', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '330' FROM DUAL 
UNION 
 SELECT 'DATE_8', 'VAT_DEST_COUNTRY_SETUP', '1000', '/', 'DISABLED_IND', 'VIEWLAYER', 'Y' FROM DUAL 
UNION 
 SELECT 'DATE_8', 'VAT_DEST_COUNTRY_SETUP', '1000', '/EC', 'DESCRIPTION', 'APPLICATION', 'Standard date field that can be used by projects' FROM DUAL 
UNION 
 SELECT 'DATE_8', 'VAT_DEST_COUNTRY_SETUP', '1000', '/EC', 'LABEL', 'APPLICATION', 'Date 8' FROM DUAL 
UNION 
 SELECT 'DATE_8', 'VAT_DEST_COUNTRY_SETUP', '1000', '/EC', 'NAME', 'APPLICATION', 'Date 8' FROM DUAL 
UNION 
 SELECT 'DATE_8', 'VAT_DEST_COUNTRY_SETUP', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '330' FROM DUAL 
UNION 
 SELECT 'DATE_8', 'VAT_DEST_COUNTRY_SETUP', '1000', '/EC', 'viewwidth', 'STATIC_PRESENTATION', '120' FROM DUAL 
UNION 
 SELECT 'DATE_8', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '330' FROM DUAL 
UNION 
 SELECT 'DATE_8', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/', 'DISABLED_IND', 'VIEWLAYER', 'Y' FROM DUAL 
UNION 
 SELECT 'DATE_8', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/EC', 'DESCRIPTION', 'APPLICATION', 'Standard date field that can be used by projects' FROM DUAL 
UNION 
 SELECT 'DATE_8', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/EC', 'LABEL', 'APPLICATION', 'Date 8' FROM DUAL 
UNION 
 SELECT 'DATE_8', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/EC', 'NAME', 'APPLICATION', 'Date 8' FROM DUAL 
UNION 
 SELECT 'DATE_8', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '330' FROM DUAL 
UNION 
 SELECT 'DATE_8', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/EC', 'viewwidth', 'STATIC_PRESENTATION', '120' FROM DUAL 
UNION 
 SELECT 'DATE_8', 'VAT_VEND_COUNTRY_SETUP', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '330' FROM DUAL 
UNION 
 SELECT 'DATE_8', 'VAT_VEND_COUNTRY_SETUP', '1000', '/', 'DISABLED_IND', 'VIEWLAYER', 'Y' FROM DUAL 
UNION 
 SELECT 'DATE_8', 'VAT_VEND_COUNTRY_SETUP', '1000', '/EC', 'DESCRIPTION', 'APPLICATION', 'Standard date field that can be used by projects' FROM DUAL 
UNION 
 SELECT 'DATE_8', 'VAT_VEND_COUNTRY_SETUP', '1000', '/EC', 'LABEL', 'APPLICATION', 'Date 8' FROM DUAL 
UNION 
 SELECT 'DATE_8', 'VAT_VEND_COUNTRY_SETUP', '1000', '/EC', 'NAME', 'APPLICATION', 'Date 8' FROM DUAL 
UNION 
 SELECT 'DATE_8', 'VAT_VEND_COUNTRY_SETUP', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '330' FROM DUAL 
UNION 
 SELECT 'DATE_8', 'VAT_VEND_COUNTRY_SETUP', '1000', '/EC', 'viewwidth', 'STATIC_PRESENTATION', '120' FROM DUAL 
UNION 
 SELECT 'DATE_9', 'VAT_CUST_COUNTRY_SETUP', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '340' FROM DUAL 
UNION 
 SELECT 'DATE_9', 'VAT_CUST_COUNTRY_SETUP', '1000', '/', 'DISABLED_IND', 'VIEWLAYER', 'Y' FROM DUAL 
UNION 
 SELECT 'DATE_9', 'VAT_CUST_COUNTRY_SETUP', '1000', '/EC', 'DESCRIPTION', 'APPLICATION', 'Standard date field that can be used by projects' FROM DUAL 
UNION 
 SELECT 'DATE_9', 'VAT_CUST_COUNTRY_SETUP', '1000', '/EC', 'LABEL', 'APPLICATION', 'Date 9' FROM DUAL 
UNION 
 SELECT 'DATE_9', 'VAT_CUST_COUNTRY_SETUP', '1000', '/EC', 'NAME', 'APPLICATION', 'Date 9' FROM DUAL 
UNION 
 SELECT 'DATE_9', 'VAT_CUST_COUNTRY_SETUP', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '340' FROM DUAL 
UNION 
 SELECT 'DATE_9', 'VAT_CUST_COUNTRY_SETUP', '1000', '/EC', 'viewwidth', 'STATIC_PRESENTATION', '120' FROM DUAL 
UNION 
 SELECT 'DATE_9', 'VAT_DEST_COUNTRY_SETUP', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '340' FROM DUAL 
UNION 
 SELECT 'DATE_9', 'VAT_DEST_COUNTRY_SETUP', '1000', '/', 'DISABLED_IND', 'VIEWLAYER', 'Y' FROM DUAL 
UNION 
 SELECT 'DATE_9', 'VAT_DEST_COUNTRY_SETUP', '1000', '/EC', 'DESCRIPTION', 'APPLICATION', 'Standard date field that can be used by projects' FROM DUAL 
UNION 
 SELECT 'DATE_9', 'VAT_DEST_COUNTRY_SETUP', '1000', '/EC', 'LABEL', 'APPLICATION', 'Date 9' FROM DUAL 
UNION 
 SELECT 'DATE_9', 'VAT_DEST_COUNTRY_SETUP', '1000', '/EC', 'NAME', 'APPLICATION', 'Date 9' FROM DUAL 
UNION 
 SELECT 'DATE_9', 'VAT_DEST_COUNTRY_SETUP', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '340' FROM DUAL 
UNION 
 SELECT 'DATE_9', 'VAT_DEST_COUNTRY_SETUP', '1000', '/EC', 'viewwidth', 'STATIC_PRESENTATION', '120' FROM DUAL 
UNION 
 SELECT 'DATE_9', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '340' FROM DUAL 
UNION 
 SELECT 'DATE_9', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/', 'DISABLED_IND', 'VIEWLAYER', 'Y' FROM DUAL 
UNION 
 SELECT 'DATE_9', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/EC', 'DESCRIPTION', 'APPLICATION', 'Standard date field that can be used by projects' FROM DUAL 
UNION 
 SELECT 'DATE_9', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/EC', 'LABEL', 'APPLICATION', 'Date 9' FROM DUAL 
UNION 
 SELECT 'DATE_9', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/EC', 'NAME', 'APPLICATION', 'Date 9' FROM DUAL 
UNION 
 SELECT 'DATE_9', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '340' FROM DUAL 
UNION 
 SELECT 'DATE_9', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/EC', 'viewwidth', 'STATIC_PRESENTATION', '120' FROM DUAL 
UNION 
 SELECT 'DATE_9', 'VAT_VEND_COUNTRY_SETUP', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '340' FROM DUAL 
UNION 
 SELECT 'DATE_9', 'VAT_VEND_COUNTRY_SETUP', '1000', '/', 'DISABLED_IND', 'VIEWLAYER', 'Y' FROM DUAL 
UNION 
 SELECT 'DATE_9', 'VAT_VEND_COUNTRY_SETUP', '1000', '/EC', 'DESCRIPTION', 'APPLICATION', 'Standard date field that can be used by projects' FROM DUAL 
UNION 
 SELECT 'DATE_9', 'VAT_VEND_COUNTRY_SETUP', '1000', '/EC', 'LABEL', 'APPLICATION', 'Date 9' FROM DUAL 
UNION 
 SELECT 'DATE_9', 'VAT_VEND_COUNTRY_SETUP', '1000', '/EC', 'NAME', 'APPLICATION', 'Date 9' FROM DUAL 
UNION 
 SELECT 'DATE_9', 'VAT_VEND_COUNTRY_SETUP', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '340' FROM DUAL 
UNION 
 SELECT 'DATE_9', 'VAT_VEND_COUNTRY_SETUP', '1000', '/EC', 'viewwidth', 'STATIC_PRESENTATION', '120' FROM DUAL 
UNION 
 SELECT 'TEXT_1', 'TANK_FINDER_OBJECTS', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '9155' FROM DUAL 
UNION 
 SELECT 'TEXT_1', 'TANK_FINDER_OBJECTS', '1000', '/', 'DISABLED_IND', 'VIEWLAYER', 'Y' FROM DUAL 
UNION 
 SELECT 'TEXT_1', 'TANK_FINDER_OBJECTS', '1000', '/', 'IS_MANDATORY', 'VIEWLAYER', 'N' FROM DUAL 
UNION 
 SELECT 'TEXT_1', 'TANK_FINDER_OBJECTS', '1000', '/EC', 'DESCRIPTION', 'APPLICATION', 'TEXT_1' FROM DUAL 
UNION 
 SELECT 'TEXT_1', 'TANK_FINDER_OBJECTS', '1000', '/EC', 'LABEL', 'APPLICATION', 'Text 1' FROM DUAL 
UNION 
 SELECT 'TEXT_1', 'TANK_FINDER_OBJECTS', '1000', '/EC', 'NAME', 'APPLICATION', 'Text 1' FROM DUAL 
UNION 
 SELECT 'TEXT_1', 'TANK_FINDER_OBJECTS', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '9155' FROM DUAL 
UNION 
 SELECT 'TEXT_1', 'TANK_FINDER_OBJECTS', '1000', '/EC', 'vieweditable', 'STATIC_PRESENTATION', 'false' FROM DUAL 
UNION 
 SELECT 'TEXT_1', 'TANK_FINDER_OBJECTS', '1000', '/EC', 'viewwidth', 'STATIC_PRESENTATION', '150' FROM DUAL 
UNION 
 SELECT 'TEXT_1', 'VAT_CUST_COUNTRY_SETUP', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '60' FROM DUAL 
UNION 
 SELECT 'TEXT_1', 'VAT_CUST_COUNTRY_SETUP', '1000', '/', 'DISABLED_IND', 'VIEWLAYER', 'Y' FROM DUAL 
UNION 
 SELECT 'TEXT_1', 'VAT_CUST_COUNTRY_SETUP', '1000', '/EC', 'DESCRIPTION', 'APPLICATION', 'Standard text field that can be used by projects' FROM DUAL 
UNION 
 SELECT 'TEXT_1', 'VAT_CUST_COUNTRY_SETUP', '1000', '/EC', 'LABEL', 'APPLICATION', 'Text 1' FROM DUAL 
UNION 
 SELECT 'TEXT_1', 'VAT_CUST_COUNTRY_SETUP', '1000', '/EC', 'NAME', 'APPLICATION', 'Text 1' FROM DUAL 
UNION 
 SELECT 'TEXT_1', 'VAT_CUST_COUNTRY_SETUP', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '60' FROM DUAL 
UNION 
 SELECT 'TEXT_1', 'VAT_CUST_COUNTRY_SETUP', '1000', '/EC', 'viewwidth', 'STATIC_PRESENTATION', '120' FROM DUAL 
UNION 
 SELECT 'TEXT_1', 'VAT_DEST_COUNTRY_SETUP', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '60' FROM DUAL 
UNION 
 SELECT 'TEXT_1', 'VAT_DEST_COUNTRY_SETUP', '1000', '/', 'DISABLED_IND', 'VIEWLAYER', 'Y' FROM DUAL 
UNION 
 SELECT 'TEXT_1', 'VAT_DEST_COUNTRY_SETUP', '1000', '/EC', 'DESCRIPTION', 'APPLICATION', 'Standard text field that can be used by projects' FROM DUAL 
UNION 
 SELECT 'TEXT_1', 'VAT_DEST_COUNTRY_SETUP', '1000', '/EC', 'LABEL', 'APPLICATION', 'Text 1' FROM DUAL 
UNION 
 SELECT 'TEXT_1', 'VAT_DEST_COUNTRY_SETUP', '1000', '/EC', 'NAME', 'APPLICATION', 'Text 1' FROM DUAL 
UNION 
 SELECT 'TEXT_1', 'VAT_DEST_COUNTRY_SETUP', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '60' FROM DUAL 
UNION 
 SELECT 'TEXT_1', 'VAT_DEST_COUNTRY_SETUP', '1000', '/EC', 'viewwidth', 'STATIC_PRESENTATION', '120' FROM DUAL 
UNION 
 SELECT 'TEXT_1', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '60' FROM DUAL 
UNION 
 SELECT 'TEXT_1', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/', 'DISABLED_IND', 'VIEWLAYER', 'Y' FROM DUAL 
UNION 
 SELECT 'TEXT_1', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/EC', 'DESCRIPTION', 'APPLICATION', 'Standard text field that can be used by projects' FROM DUAL 
UNION 
 SELECT 'TEXT_1', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/EC', 'LABEL', 'APPLICATION', 'Text 1' FROM DUAL 
UNION 
 SELECT 'TEXT_1', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/EC', 'NAME', 'APPLICATION', 'Text 1' FROM DUAL 
UNION 
 SELECT 'TEXT_1', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '60' FROM DUAL 
UNION 
 SELECT 'TEXT_1', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/EC', 'viewwidth', 'STATIC_PRESENTATION', '120' FROM DUAL 
UNION 
 SELECT 'TEXT_1', 'VAT_VEND_COUNTRY_SETUP', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '60' FROM DUAL 
UNION 
 SELECT 'TEXT_1', 'VAT_VEND_COUNTRY_SETUP', '1000', '/', 'DISABLED_IND', 'VIEWLAYER', 'Y' FROM DUAL 
UNION 
 SELECT 'TEXT_1', 'VAT_VEND_COUNTRY_SETUP', '1000', '/EC', 'DESCRIPTION', 'APPLICATION', 'Standard text field that can be used by projects' FROM DUAL 
UNION 
 SELECT 'TEXT_1', 'VAT_VEND_COUNTRY_SETUP', '1000', '/EC', 'LABEL', 'APPLICATION', 'Text 1' FROM DUAL 
UNION 
 SELECT 'TEXT_1', 'VAT_VEND_COUNTRY_SETUP', '1000', '/EC', 'NAME', 'APPLICATION', 'Text 1' FROM DUAL 
UNION 
 SELECT 'TEXT_1', 'VAT_VEND_COUNTRY_SETUP', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '60' FROM DUAL 
UNION 
 SELECT 'TEXT_1', 'VAT_VEND_COUNTRY_SETUP', '1000', '/EC', 'viewwidth', 'STATIC_PRESENTATION', '120' FROM DUAL 
UNION 
 SELECT 'TEXT_10', 'TANK_FINDER_OBJECTS', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '9164' FROM DUAL 
UNION 
 SELECT 'TEXT_10', 'TANK_FINDER_OBJECTS', '1000', '/', 'DISABLED_IND', 'VIEWLAYER', 'Y' FROM DUAL 
UNION 
 SELECT 'TEXT_10', 'TANK_FINDER_OBJECTS', '1000', '/', 'IS_MANDATORY', 'VIEWLAYER', 'N' FROM DUAL 
UNION 
 SELECT 'TEXT_10', 'TANK_FINDER_OBJECTS', '1000', '/EC', 'DESCRIPTION', 'APPLICATION', 'TEXT_10' FROM DUAL 
UNION 
 SELECT 'TEXT_10', 'TANK_FINDER_OBJECTS', '1000', '/EC', 'LABEL', 'APPLICATION', 'Text 10' FROM DUAL 
UNION 
 SELECT 'TEXT_10', 'TANK_FINDER_OBJECTS', '1000', '/EC', 'NAME', 'APPLICATION', 'Text 10' FROM DUAL 
UNION 
 SELECT 'TEXT_10', 'TANK_FINDER_OBJECTS', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '9164' FROM DUAL 
UNION 
 SELECT 'TEXT_10', 'TANK_FINDER_OBJECTS', '1000', '/EC', 'vieweditable', 'STATIC_PRESENTATION', 'false' FROM DUAL 
UNION 
 SELECT 'TEXT_10', 'TANK_FINDER_OBJECTS', '1000', '/EC', 'viewwidth', 'STATIC_PRESENTATION', '150' FROM DUAL 
UNION 
 SELECT 'TEXT_10', 'VAT_CUST_COUNTRY_SETUP', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '150' FROM DUAL 
UNION 
 SELECT 'TEXT_10', 'VAT_CUST_COUNTRY_SETUP', '1000', '/', 'DISABLED_IND', 'VIEWLAYER', 'Y' FROM DUAL 
UNION 
 SELECT 'TEXT_10', 'VAT_CUST_COUNTRY_SETUP', '1000', '/EC', 'DESCRIPTION', 'APPLICATION', 'Standard text field that can be used by projects' FROM DUAL 
UNION 
 SELECT 'TEXT_10', 'VAT_CUST_COUNTRY_SETUP', '1000', '/EC', 'LABEL', 'APPLICATION', 'Text 10' FROM DUAL 
UNION 
 SELECT 'TEXT_10', 'VAT_CUST_COUNTRY_SETUP', '1000', '/EC', 'NAME', 'APPLICATION', 'Text 10' FROM DUAL 
UNION 
 SELECT 'TEXT_10', 'VAT_CUST_COUNTRY_SETUP', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '150' FROM DUAL 
UNION 
 SELECT 'TEXT_10', 'VAT_CUST_COUNTRY_SETUP', '1000', '/EC', 'viewwidth', 'STATIC_PRESENTATION', '120' FROM DUAL 
UNION 
 SELECT 'TEXT_10', 'VAT_DEST_COUNTRY_SETUP', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '150' FROM DUAL 
UNION 
 SELECT 'TEXT_10', 'VAT_DEST_COUNTRY_SETUP', '1000', '/', 'DISABLED_IND', 'VIEWLAYER', 'Y' FROM DUAL 
UNION 
 SELECT 'TEXT_10', 'VAT_DEST_COUNTRY_SETUP', '1000', '/EC', 'DESCRIPTION', 'APPLICATION', 'Standard text field that can be used by projects' FROM DUAL 
UNION 
 SELECT 'TEXT_10', 'VAT_DEST_COUNTRY_SETUP', '1000', '/EC', 'LABEL', 'APPLICATION', 'Text 10' FROM DUAL 
UNION 
 SELECT 'TEXT_10', 'VAT_DEST_COUNTRY_SETUP', '1000', '/EC', 'NAME', 'APPLICATION', 'Text 10' FROM DUAL 
UNION 
 SELECT 'TEXT_10', 'VAT_DEST_COUNTRY_SETUP', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '150' FROM DUAL 
UNION 
 SELECT 'TEXT_10', 'VAT_DEST_COUNTRY_SETUP', '1000', '/EC', 'viewwidth', 'STATIC_PRESENTATION', '120' FROM DUAL 
UNION 
 SELECT 'TEXT_10', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '150' FROM DUAL 
UNION 
 SELECT 'TEXT_10', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/', 'DISABLED_IND', 'VIEWLAYER', 'Y' FROM DUAL 
UNION 
 SELECT 'TEXT_10', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/EC', 'DESCRIPTION', 'APPLICATION', 'Standard text field that can be used by projects' FROM DUAL 
UNION 
 SELECT 'TEXT_10', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/EC', 'LABEL', 'APPLICATION', 'Text 10' FROM DUAL 
UNION 
 SELECT 'TEXT_10', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/EC', 'NAME', 'APPLICATION', 'Text 10' FROM DUAL 
UNION 
 SELECT 'TEXT_10', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '150' FROM DUAL 
UNION 
 SELECT 'TEXT_10', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/EC', 'viewwidth', 'STATIC_PRESENTATION', '120' FROM DUAL 
UNION 
 SELECT 'TEXT_10', 'VAT_VEND_COUNTRY_SETUP', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '150' FROM DUAL 
UNION 
 SELECT 'TEXT_10', 'VAT_VEND_COUNTRY_SETUP', '1000', '/', 'DISABLED_IND', 'VIEWLAYER', 'Y' FROM DUAL 
UNION 
 SELECT 'TEXT_10', 'VAT_VEND_COUNTRY_SETUP', '1000', '/EC', 'DESCRIPTION', 'APPLICATION', 'Standard text field that can be used by projects' FROM DUAL 
UNION 
 SELECT 'TEXT_10', 'VAT_VEND_COUNTRY_SETUP', '1000', '/EC', 'LABEL', 'APPLICATION', 'Text 10' FROM DUAL 
UNION 
 SELECT 'TEXT_10', 'VAT_VEND_COUNTRY_SETUP', '1000', '/EC', 'NAME', 'APPLICATION', 'Text 10' FROM DUAL 
UNION 
 SELECT 'TEXT_10', 'VAT_VEND_COUNTRY_SETUP', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '150' FROM DUAL 
UNION 
 SELECT 'TEXT_10', 'VAT_VEND_COUNTRY_SETUP', '1000', '/EC', 'viewwidth', 'STATIC_PRESENTATION', '120' FROM DUAL 
UNION 
 SELECT 'TEXT_2', 'TANK_FINDER_OBJECTS', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '9156' FROM DUAL 
UNION 
 SELECT 'TEXT_2', 'TANK_FINDER_OBJECTS', '1000', '/', 'DISABLED_IND', 'VIEWLAYER', 'Y' FROM DUAL 
UNION 
 SELECT 'TEXT_2', 'TANK_FINDER_OBJECTS', '1000', '/', 'IS_MANDATORY', 'VIEWLAYER', 'N' FROM DUAL 
UNION 
 SELECT 'TEXT_2', 'TANK_FINDER_OBJECTS', '1000', '/EC', 'DESCRIPTION', 'APPLICATION', 'TEXT_2' FROM DUAL 
UNION 
 SELECT 'TEXT_2', 'TANK_FINDER_OBJECTS', '1000', '/EC', 'LABEL', 'APPLICATION', 'Text 2' FROM DUAL 
UNION 
 SELECT 'TEXT_2', 'TANK_FINDER_OBJECTS', '1000', '/EC', 'NAME', 'APPLICATION', 'Text 2' FROM DUAL 
UNION 
 SELECT 'TEXT_2', 'TANK_FINDER_OBJECTS', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '9156' FROM DUAL 
UNION 
 SELECT 'TEXT_2', 'TANK_FINDER_OBJECTS', '1000', '/EC', 'vieweditable', 'STATIC_PRESENTATION', 'false' FROM DUAL 
UNION 
 SELECT 'TEXT_2', 'TANK_FINDER_OBJECTS', '1000', '/EC', 'viewwidth', 'STATIC_PRESENTATION', '150' FROM DUAL 
UNION 
 SELECT 'TEXT_2', 'VAT_CUST_COUNTRY_SETUP', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '70' FROM DUAL 
UNION 
 SELECT 'TEXT_2', 'VAT_CUST_COUNTRY_SETUP', '1000', '/', 'DISABLED_IND', 'VIEWLAYER', 'Y' FROM DUAL 
UNION 
 SELECT 'TEXT_2', 'VAT_CUST_COUNTRY_SETUP', '1000', '/EC', 'DESCRIPTION', 'APPLICATION', 'Standard text field that can be used by projects' FROM DUAL 
UNION 
 SELECT 'TEXT_2', 'VAT_CUST_COUNTRY_SETUP', '1000', '/EC', 'LABEL', 'APPLICATION', 'Text 2' FROM DUAL 
UNION 
 SELECT 'TEXT_2', 'VAT_CUST_COUNTRY_SETUP', '1000', '/EC', 'NAME', 'APPLICATION', 'Text 2' FROM DUAL 
UNION 
 SELECT 'TEXT_2', 'VAT_CUST_COUNTRY_SETUP', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '70' FROM DUAL 
UNION 
 SELECT 'TEXT_2', 'VAT_CUST_COUNTRY_SETUP', '1000', '/EC', 'viewwidth', 'STATIC_PRESENTATION', '120' FROM DUAL 
UNION 
 SELECT 'TEXT_2', 'VAT_DEST_COUNTRY_SETUP', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '70' FROM DUAL 
UNION 
 SELECT 'TEXT_2', 'VAT_DEST_COUNTRY_SETUP', '1000', '/', 'DISABLED_IND', 'VIEWLAYER', 'Y' FROM DUAL 
UNION 
 SELECT 'TEXT_2', 'VAT_DEST_COUNTRY_SETUP', '1000', '/EC', 'DESCRIPTION', 'APPLICATION', 'Standard text field that can be used by projects' FROM DUAL 
UNION 
 SELECT 'TEXT_2', 'VAT_DEST_COUNTRY_SETUP', '1000', '/EC', 'LABEL', 'APPLICATION', 'Text 2' FROM DUAL 
UNION 
 SELECT 'TEXT_2', 'VAT_DEST_COUNTRY_SETUP', '1000', '/EC', 'NAME', 'APPLICATION', 'Text 2' FROM DUAL 
UNION 
 SELECT 'TEXT_2', 'VAT_DEST_COUNTRY_SETUP', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '70' FROM DUAL 
UNION 
 SELECT 'TEXT_2', 'VAT_DEST_COUNTRY_SETUP', '1000', '/EC', 'viewwidth', 'STATIC_PRESENTATION', '120' FROM DUAL 
UNION 
 SELECT 'TEXT_2', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '70' FROM DUAL 
UNION 
 SELECT 'TEXT_2', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/', 'DISABLED_IND', 'VIEWLAYER', 'Y' FROM DUAL 
UNION 
 SELECT 'TEXT_2', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/EC', 'DESCRIPTION', 'APPLICATION', 'Standard text field that can be used by projects' FROM DUAL 
UNION 
 SELECT 'TEXT_2', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/EC', 'LABEL', 'APPLICATION', 'Text 2' FROM DUAL 
UNION 
 SELECT 'TEXT_2', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/EC', 'NAME', 'APPLICATION', 'Text 2' FROM DUAL 
UNION 
 SELECT 'TEXT_2', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '70' FROM DUAL 
UNION 
 SELECT 'TEXT_2', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/EC', 'viewwidth', 'STATIC_PRESENTATION', '120' FROM DUAL 
UNION 
 SELECT 'TEXT_2', 'VAT_VEND_COUNTRY_SETUP', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '70' FROM DUAL 
UNION 
 SELECT 'TEXT_2', 'VAT_VEND_COUNTRY_SETUP', '1000', '/', 'DISABLED_IND', 'VIEWLAYER', 'Y' FROM DUAL 
UNION 
 SELECT 'TEXT_2', 'VAT_VEND_COUNTRY_SETUP', '1000', '/EC', 'DESCRIPTION', 'APPLICATION', 'Standard text field that can be used by projects' FROM DUAL 
UNION 
 SELECT 'TEXT_2', 'VAT_VEND_COUNTRY_SETUP', '1000', '/EC', 'LABEL', 'APPLICATION', 'Text 2' FROM DUAL 
UNION 
 SELECT 'TEXT_2', 'VAT_VEND_COUNTRY_SETUP', '1000', '/EC', 'NAME', 'APPLICATION', 'Text 2' FROM DUAL 
UNION 
 SELECT 'TEXT_2', 'VAT_VEND_COUNTRY_SETUP', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '70' FROM DUAL 
UNION 
 SELECT 'TEXT_2', 'VAT_VEND_COUNTRY_SETUP', '1000', '/EC', 'viewwidth', 'STATIC_PRESENTATION', '120' FROM DUAL 
UNION 
 SELECT 'TEXT_3', 'TANK_FINDER_OBJECTS', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '9157' FROM DUAL 
UNION 
 SELECT 'TEXT_3', 'TANK_FINDER_OBJECTS', '1000', '/', 'DISABLED_IND', 'VIEWLAYER', 'Y' FROM DUAL 
UNION 
 SELECT 'TEXT_3', 'TANK_FINDER_OBJECTS', '1000', '/', 'IS_MANDATORY', 'VIEWLAYER', 'N' FROM DUAL 
UNION 
 SELECT 'TEXT_3', 'TANK_FINDER_OBJECTS', '1000', '/EC', 'DESCRIPTION', 'APPLICATION', 'TEXT_3' FROM DUAL 
UNION 
 SELECT 'TEXT_3', 'TANK_FINDER_OBJECTS', '1000', '/EC', 'LABEL', 'APPLICATION', 'Text 3' FROM DUAL 
UNION 
 SELECT 'TEXT_3', 'TANK_FINDER_OBJECTS', '1000', '/EC', 'NAME', 'APPLICATION', 'Text 3' FROM DUAL 
UNION 
 SELECT 'TEXT_3', 'TANK_FINDER_OBJECTS', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '9157' FROM DUAL 
UNION 
 SELECT 'TEXT_3', 'TANK_FINDER_OBJECTS', '1000', '/EC', 'vieweditable', 'STATIC_PRESENTATION', 'false' FROM DUAL 
UNION 
 SELECT 'TEXT_3', 'TANK_FINDER_OBJECTS', '1000', '/EC', 'viewwidth', 'STATIC_PRESENTATION', '150' FROM DUAL 
UNION 
 SELECT 'TEXT_3', 'VAT_CUST_COUNTRY_SETUP', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '80' FROM DUAL 
UNION 
 SELECT 'TEXT_3', 'VAT_CUST_COUNTRY_SETUP', '1000', '/', 'DISABLED_IND', 'VIEWLAYER', 'Y' FROM DUAL 
UNION 
 SELECT 'TEXT_3', 'VAT_CUST_COUNTRY_SETUP', '1000', '/EC', 'DESCRIPTION', 'APPLICATION', 'Standard text field that can be used by projects' FROM DUAL 
UNION 
 SELECT 'TEXT_3', 'VAT_CUST_COUNTRY_SETUP', '1000', '/EC', 'LABEL', 'APPLICATION', 'Text 3' FROM DUAL 
UNION 
 SELECT 'TEXT_3', 'VAT_CUST_COUNTRY_SETUP', '1000', '/EC', 'NAME', 'APPLICATION', 'Text 3' FROM DUAL 
UNION 
 SELECT 'TEXT_3', 'VAT_CUST_COUNTRY_SETUP', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '80' FROM DUAL 
UNION 
 SELECT 'TEXT_3', 'VAT_CUST_COUNTRY_SETUP', '1000', '/EC', 'viewwidth', 'STATIC_PRESENTATION', '120' FROM DUAL 
UNION 
 SELECT 'TEXT_3', 'VAT_DEST_COUNTRY_SETUP', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '80' FROM DUAL 
UNION 
 SELECT 'TEXT_3', 'VAT_DEST_COUNTRY_SETUP', '1000', '/', 'DISABLED_IND', 'VIEWLAYER', 'Y' FROM DUAL 
UNION 
 SELECT 'TEXT_3', 'VAT_DEST_COUNTRY_SETUP', '1000', '/EC', 'DESCRIPTION', 'APPLICATION', 'Standard text field that can be used by projects' FROM DUAL 
UNION 
 SELECT 'TEXT_3', 'VAT_DEST_COUNTRY_SETUP', '1000', '/EC', 'LABEL', 'APPLICATION', 'Text 3' FROM DUAL 
UNION 
 SELECT 'TEXT_3', 'VAT_DEST_COUNTRY_SETUP', '1000', '/EC', 'NAME', 'APPLICATION', 'Text 3' FROM DUAL 
UNION 
 SELECT 'TEXT_3', 'VAT_DEST_COUNTRY_SETUP', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '80' FROM DUAL 
UNION 
 SELECT 'TEXT_3', 'VAT_DEST_COUNTRY_SETUP', '1000', '/EC', 'viewwidth', 'STATIC_PRESENTATION', '120' FROM DUAL 
UNION 
 SELECT 'TEXT_3', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '80' FROM DUAL 
UNION 
 SELECT 'TEXT_3', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/', 'DISABLED_IND', 'VIEWLAYER', 'Y' FROM DUAL 
UNION 
 SELECT 'TEXT_3', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/EC', 'DESCRIPTION', 'APPLICATION', 'Standard text field that can be used by projects' FROM DUAL 
UNION 
 SELECT 'TEXT_3', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/EC', 'LABEL', 'APPLICATION', 'Text 3' FROM DUAL 
UNION 
 SELECT 'TEXT_3', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/EC', 'NAME', 'APPLICATION', 'Text 3' FROM DUAL 
UNION 
 SELECT 'TEXT_3', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '80' FROM DUAL 
UNION 
 SELECT 'TEXT_3', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/EC', 'viewwidth', 'STATIC_PRESENTATION', '120' FROM DUAL 
UNION 
 SELECT 'TEXT_3', 'VAT_VEND_COUNTRY_SETUP', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '80' FROM DUAL 
UNION 
 SELECT 'TEXT_3', 'VAT_VEND_COUNTRY_SETUP', '1000', '/', 'DISABLED_IND', 'VIEWLAYER', 'Y' FROM DUAL 
UNION 
 SELECT 'TEXT_3', 'VAT_VEND_COUNTRY_SETUP', '1000', '/EC', 'DESCRIPTION', 'APPLICATION', 'Standard text field that can be used by projects' FROM DUAL 
UNION 
 SELECT 'TEXT_3', 'VAT_VEND_COUNTRY_SETUP', '1000', '/EC', 'LABEL', 'APPLICATION', 'Text 3' FROM DUAL 
UNION 
 SELECT 'TEXT_3', 'VAT_VEND_COUNTRY_SETUP', '1000', '/EC', 'NAME', 'APPLICATION', 'Text 3' FROM DUAL 
UNION 
 SELECT 'TEXT_3', 'VAT_VEND_COUNTRY_SETUP', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '80' FROM DUAL 
UNION 
 SELECT 'TEXT_3', 'VAT_VEND_COUNTRY_SETUP', '1000', '/EC', 'viewwidth', 'STATIC_PRESENTATION', '120' FROM DUAL 
UNION 
 SELECT 'TEXT_4', 'TANK_FINDER_OBJECTS', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '9158' FROM DUAL 
UNION 
 SELECT 'TEXT_4', 'TANK_FINDER_OBJECTS', '1000', '/', 'DISABLED_IND', 'VIEWLAYER', 'Y' FROM DUAL 
UNION 
 SELECT 'TEXT_4', 'TANK_FINDER_OBJECTS', '1000', '/', 'IS_MANDATORY', 'VIEWLAYER', 'N' FROM DUAL 
UNION 
 SELECT 'TEXT_4', 'TANK_FINDER_OBJECTS', '1000', '/EC', 'DESCRIPTION', 'APPLICATION', 'TEXT_4' FROM DUAL 
UNION 
 SELECT 'TEXT_4', 'TANK_FINDER_OBJECTS', '1000', '/EC', 'LABEL', 'APPLICATION', 'Text 4' FROM DUAL 
UNION 
 SELECT 'TEXT_4', 'TANK_FINDER_OBJECTS', '1000', '/EC', 'NAME', 'APPLICATION', 'Text 4' FROM DUAL 
UNION 
 SELECT 'TEXT_4', 'TANK_FINDER_OBJECTS', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '9158' FROM DUAL 
UNION 
 SELECT 'TEXT_4', 'TANK_FINDER_OBJECTS', '1000', '/EC', 'vieweditable', 'STATIC_PRESENTATION', 'false' FROM DUAL 
UNION 
 SELECT 'TEXT_4', 'TANK_FINDER_OBJECTS', '1000', '/EC', 'viewwidth', 'STATIC_PRESENTATION', '150' FROM DUAL 
UNION 
 SELECT 'TEXT_4', 'VAT_CUST_COUNTRY_SETUP', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '90' FROM DUAL 
UNION 
 SELECT 'TEXT_4', 'VAT_CUST_COUNTRY_SETUP', '1000', '/', 'DISABLED_IND', 'VIEWLAYER', 'Y' FROM DUAL 
UNION 
 SELECT 'TEXT_4', 'VAT_CUST_COUNTRY_SETUP', '1000', '/EC', 'DESCRIPTION', 'APPLICATION', 'Standard text field that can be used by projects' FROM DUAL 
UNION 
 SELECT 'TEXT_4', 'VAT_CUST_COUNTRY_SETUP', '1000', '/EC', 'LABEL', 'APPLICATION', 'Text 4' FROM DUAL 
UNION 
 SELECT 'TEXT_4', 'VAT_CUST_COUNTRY_SETUP', '1000', '/EC', 'NAME', 'APPLICATION', 'Text 4' FROM DUAL 
UNION 
 SELECT 'TEXT_4', 'VAT_CUST_COUNTRY_SETUP', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '90' FROM DUAL 
UNION 
 SELECT 'TEXT_4', 'VAT_CUST_COUNTRY_SETUP', '1000', '/EC', 'viewwidth', 'STATIC_PRESENTATION', '120' FROM DUAL 
UNION 
 SELECT 'TEXT_4', 'VAT_DEST_COUNTRY_SETUP', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '90' FROM DUAL 
UNION 
 SELECT 'TEXT_4', 'VAT_DEST_COUNTRY_SETUP', '1000', '/', 'DISABLED_IND', 'VIEWLAYER', 'Y' FROM DUAL 
UNION 
 SELECT 'TEXT_4', 'VAT_DEST_COUNTRY_SETUP', '1000', '/EC', 'DESCRIPTION', 'APPLICATION', 'Standard text field that can be used by projects' FROM DUAL 
UNION 
 SELECT 'TEXT_4', 'VAT_DEST_COUNTRY_SETUP', '1000', '/EC', 'LABEL', 'APPLICATION', 'Text 4' FROM DUAL 
UNION 
 SELECT 'TEXT_4', 'VAT_DEST_COUNTRY_SETUP', '1000', '/EC', 'NAME', 'APPLICATION', 'Text 4' FROM DUAL 
UNION 
 SELECT 'TEXT_4', 'VAT_DEST_COUNTRY_SETUP', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '90' FROM DUAL 
UNION 
 SELECT 'TEXT_4', 'VAT_DEST_COUNTRY_SETUP', '1000', '/EC', 'viewwidth', 'STATIC_PRESENTATION', '120' FROM DUAL 
UNION 
 SELECT 'TEXT_4', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '90' FROM DUAL 
UNION 
 SELECT 'TEXT_4', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/', 'DISABLED_IND', 'VIEWLAYER', 'Y' FROM DUAL 
UNION 
 SELECT 'TEXT_4', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/EC', 'DESCRIPTION', 'APPLICATION', 'Standard text field that can be used by projects' FROM DUAL 
UNION 
 SELECT 'TEXT_4', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/EC', 'LABEL', 'APPLICATION', 'Text 4' FROM DUAL
) n
ON (o.ATTRIBUTE_NAME = n.ATTRIBUTE_NAME
 AND o.CLASS_NAME = n.CLASS_NAME
 AND o.OWNER_CNTX = n.OWNER_CNTX
 AND o.PRESENTATION_CNTX = n.PRESENTATION_CNTX
 AND o.PROPERTY_CODE = n.PROPERTY_CODE
 AND o.PROPERTY_TYPE = n.PROPERTY_TYPE)
WHEN MATCHED THEN UPDATE SET
o.PROPERTY_VALUE = n.PROPERTY_VALUE
,o.LAST_UPDATED_BY = 'UPGD-TOOL-12.0-DM'
,o.REV_NO = o.REV_NO+1
WHEN NOT MATCHED THEN INSERT
(ATTRIBUTE_NAME,CLASS_NAME,OWNER_CNTX,PRESENTATION_CNTX,PROPERTY_CODE,PROPERTY_TYPE,PROPERTY_VALUE,CREATED_BY)
VALUES( n.ATTRIBUTE_NAME, n.CLASS_NAME, n.OWNER_CNTX, n.PRESENTATION_CNTX, n.PROPERTY_CODE, n.PROPERTY_TYPE, n.PROPERTY_VALUE,'UPGD-TOOL-12.0-DM');

MERGE INTO CLASS_ATTR_PROPERTY_CNFG o USING 
(
SELECT
 null ATTRIBUTE_NAME, null CLASS_NAME, null OWNER_CNTX, null PRESENTATION_CNTX, null PROPERTY_CODE, null PROPERTY_TYPE, null PROPERTY_VALUE FROM DUAL WHERE 1=0
UNION 
 SELECT 'TEXT_4', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/EC', 'NAME', 'APPLICATION', 'Text 4' FROM DUAL 
UNION 
 SELECT 'TEXT_4', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '90' FROM DUAL 
UNION 
 SELECT 'TEXT_4', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/EC', 'viewwidth', 'STATIC_PRESENTATION', '120' FROM DUAL 
UNION 
 SELECT 'TEXT_4', 'VAT_VEND_COUNTRY_SETUP', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '90' FROM DUAL 
UNION 
 SELECT 'TEXT_4', 'VAT_VEND_COUNTRY_SETUP', '1000', '/', 'DISABLED_IND', 'VIEWLAYER', 'Y' FROM DUAL 
UNION 
 SELECT 'TEXT_4', 'VAT_VEND_COUNTRY_SETUP', '1000', '/EC', 'DESCRIPTION', 'APPLICATION', 'Standard text field that can be used by projects' FROM DUAL 
UNION 
 SELECT 'TEXT_4', 'VAT_VEND_COUNTRY_SETUP', '1000', '/EC', 'LABEL', 'APPLICATION', 'Text 4' FROM DUAL 
UNION 
 SELECT 'TEXT_4', 'VAT_VEND_COUNTRY_SETUP', '1000', '/EC', 'NAME', 'APPLICATION', 'Text 4' FROM DUAL 
UNION 
 SELECT 'TEXT_4', 'VAT_VEND_COUNTRY_SETUP', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '90' FROM DUAL 
UNION 
 SELECT 'TEXT_4', 'VAT_VEND_COUNTRY_SETUP', '1000', '/EC', 'viewwidth', 'STATIC_PRESENTATION', '120' FROM DUAL 
UNION 
 SELECT 'TEXT_5', 'TANK_FINDER_OBJECTS', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '9159' FROM DUAL 
UNION 
 SELECT 'TEXT_5', 'TANK_FINDER_OBJECTS', '1000', '/', 'DISABLED_IND', 'VIEWLAYER', 'Y' FROM DUAL 
UNION 
 SELECT 'TEXT_5', 'TANK_FINDER_OBJECTS', '1000', '/', 'IS_MANDATORY', 'VIEWLAYER', 'N' FROM DUAL 
UNION 
 SELECT 'TEXT_5', 'TANK_FINDER_OBJECTS', '1000', '/EC', 'DESCRIPTION', 'APPLICATION', 'TEXT_5' FROM DUAL 
UNION 
 SELECT 'TEXT_5', 'TANK_FINDER_OBJECTS', '1000', '/EC', 'LABEL', 'APPLICATION', 'Text 5' FROM DUAL 
UNION 
 SELECT 'TEXT_5', 'TANK_FINDER_OBJECTS', '1000', '/EC', 'NAME', 'APPLICATION', 'Text 5' FROM DUAL 
UNION 
 SELECT 'TEXT_5', 'TANK_FINDER_OBJECTS', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '9159' FROM DUAL 
UNION 
 SELECT 'TEXT_5', 'TANK_FINDER_OBJECTS', '1000', '/EC', 'vieweditable', 'STATIC_PRESENTATION', 'false' FROM DUAL 
UNION 
 SELECT 'TEXT_5', 'TANK_FINDER_OBJECTS', '1000', '/EC', 'viewwidth', 'STATIC_PRESENTATION', '150' FROM DUAL 
UNION 
 SELECT 'TEXT_5', 'VAT_CUST_COUNTRY_SETUP', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '100' FROM DUAL 
UNION 
 SELECT 'TEXT_5', 'VAT_CUST_COUNTRY_SETUP', '1000', '/', 'DISABLED_IND', 'VIEWLAYER', 'Y' FROM DUAL 
UNION 
 SELECT 'TEXT_5', 'VAT_CUST_COUNTRY_SETUP', '1000', '/EC', 'DESCRIPTION', 'APPLICATION', 'Standard text field that can be used by projects' FROM DUAL 
UNION 
 SELECT 'TEXT_5', 'VAT_CUST_COUNTRY_SETUP', '1000', '/EC', 'LABEL', 'APPLICATION', 'Text 5' FROM DUAL 
UNION 
 SELECT 'TEXT_5', 'VAT_CUST_COUNTRY_SETUP', '1000', '/EC', 'NAME', 'APPLICATION', 'Text 5' FROM DUAL 
UNION 
 SELECT 'TEXT_5', 'VAT_CUST_COUNTRY_SETUP', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '100' FROM DUAL 
UNION 
 SELECT 'TEXT_5', 'VAT_CUST_COUNTRY_SETUP', '1000', '/EC', 'viewwidth', 'STATIC_PRESENTATION', '120' FROM DUAL 
UNION 
 SELECT 'TEXT_5', 'VAT_DEST_COUNTRY_SETUP', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '100' FROM DUAL 
UNION 
 SELECT 'TEXT_5', 'VAT_DEST_COUNTRY_SETUP', '1000', '/', 'DISABLED_IND', 'VIEWLAYER', 'Y' FROM DUAL 
UNION 
 SELECT 'TEXT_5', 'VAT_DEST_COUNTRY_SETUP', '1000', '/EC', 'DESCRIPTION', 'APPLICATION', 'Standard text field that can be used by projects' FROM DUAL 
UNION 
 SELECT 'TEXT_5', 'VAT_DEST_COUNTRY_SETUP', '1000', '/EC', 'LABEL', 'APPLICATION', 'Text 5' FROM DUAL 
UNION 
 SELECT 'TEXT_5', 'VAT_DEST_COUNTRY_SETUP', '1000', '/EC', 'NAME', 'APPLICATION', 'Text 5' FROM DUAL 
UNION 
 SELECT 'TEXT_5', 'VAT_DEST_COUNTRY_SETUP', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '100' FROM DUAL 
UNION 
 SELECT 'TEXT_5', 'VAT_DEST_COUNTRY_SETUP', '1000', '/EC', 'viewwidth', 'STATIC_PRESENTATION', '120' FROM DUAL 
UNION 
 SELECT 'TEXT_5', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '100' FROM DUAL 
UNION 
 SELECT 'TEXT_5', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/', 'DISABLED_IND', 'VIEWLAYER', 'Y' FROM DUAL 
UNION 
 SELECT 'TEXT_5', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/EC', 'DESCRIPTION', 'APPLICATION', 'Standard text field that can be used by projects' FROM DUAL 
UNION 
 SELECT 'TEXT_5', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/EC', 'LABEL', 'APPLICATION', 'Text 5' FROM DUAL 
UNION 
 SELECT 'TEXT_5', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/EC', 'NAME', 'APPLICATION', 'Text 5' FROM DUAL 
UNION 
 SELECT 'TEXT_5', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '100' FROM DUAL 
UNION 
 SELECT 'TEXT_5', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/EC', 'viewwidth', 'STATIC_PRESENTATION', '120' FROM DUAL 
UNION 
 SELECT 'TEXT_5', 'VAT_VEND_COUNTRY_SETUP', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '100' FROM DUAL 
UNION 
 SELECT 'TEXT_5', 'VAT_VEND_COUNTRY_SETUP', '1000', '/', 'DISABLED_IND', 'VIEWLAYER', 'Y' FROM DUAL 
UNION 
 SELECT 'TEXT_5', 'VAT_VEND_COUNTRY_SETUP', '1000', '/EC', 'DESCRIPTION', 'APPLICATION', 'Standard text field that can be used by projects' FROM DUAL 
UNION 
 SELECT 'TEXT_5', 'VAT_VEND_COUNTRY_SETUP', '1000', '/EC', 'LABEL', 'APPLICATION', 'Text 5' FROM DUAL 
UNION 
 SELECT 'TEXT_5', 'VAT_VEND_COUNTRY_SETUP', '1000', '/EC', 'NAME', 'APPLICATION', 'Text 5' FROM DUAL 
UNION 
 SELECT 'TEXT_5', 'VAT_VEND_COUNTRY_SETUP', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '100' FROM DUAL 
UNION 
 SELECT 'TEXT_5', 'VAT_VEND_COUNTRY_SETUP', '1000', '/EC', 'viewwidth', 'STATIC_PRESENTATION', '120' FROM DUAL 
UNION 
 SELECT 'TEXT_6', 'TANK_FINDER_OBJECTS', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '9160' FROM DUAL 
UNION 
 SELECT 'TEXT_6', 'TANK_FINDER_OBJECTS', '1000', '/', 'DISABLED_IND', 'VIEWLAYER', 'Y' FROM DUAL 
UNION 
 SELECT 'TEXT_6', 'TANK_FINDER_OBJECTS', '1000', '/', 'IS_MANDATORY', 'VIEWLAYER', 'N' FROM DUAL 
UNION 
 SELECT 'TEXT_6', 'TANK_FINDER_OBJECTS', '1000', '/EC', 'DESCRIPTION', 'APPLICATION', 'TEXT_6' FROM DUAL 
UNION 
 SELECT 'TEXT_6', 'TANK_FINDER_OBJECTS', '1000', '/EC', 'LABEL', 'APPLICATION', 'Text 6' FROM DUAL 
UNION 
 SELECT 'TEXT_6', 'TANK_FINDER_OBJECTS', '1000', '/EC', 'NAME', 'APPLICATION', 'Text 6' FROM DUAL 
UNION 
 SELECT 'TEXT_6', 'TANK_FINDER_OBJECTS', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '9160' FROM DUAL 
UNION 
 SELECT 'TEXT_6', 'TANK_FINDER_OBJECTS', '1000', '/EC', 'vieweditable', 'STATIC_PRESENTATION', 'false' FROM DUAL 
UNION 
 SELECT 'TEXT_6', 'TANK_FINDER_OBJECTS', '1000', '/EC', 'viewwidth', 'STATIC_PRESENTATION', '150' FROM DUAL 
UNION 
 SELECT 'TEXT_6', 'VAT_CUST_COUNTRY_SETUP', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '110' FROM DUAL 
UNION 
 SELECT 'TEXT_6', 'VAT_CUST_COUNTRY_SETUP', '1000', '/', 'DISABLED_IND', 'VIEWLAYER', 'Y' FROM DUAL 
UNION 
 SELECT 'TEXT_6', 'VAT_CUST_COUNTRY_SETUP', '1000', '/EC', 'DESCRIPTION', 'APPLICATION', 'Standard text field that can be used by projects' FROM DUAL 
UNION 
 SELECT 'TEXT_6', 'VAT_CUST_COUNTRY_SETUP', '1000', '/EC', 'LABEL', 'APPLICATION', 'Text 6' FROM DUAL 
UNION 
 SELECT 'TEXT_6', 'VAT_CUST_COUNTRY_SETUP', '1000', '/EC', 'NAME', 'APPLICATION', 'Text 6' FROM DUAL 
UNION 
 SELECT 'TEXT_6', 'VAT_CUST_COUNTRY_SETUP', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '110' FROM DUAL 
UNION 
 SELECT 'TEXT_6', 'VAT_CUST_COUNTRY_SETUP', '1000', '/EC', 'viewwidth', 'STATIC_PRESENTATION', '120' FROM DUAL 
UNION 
 SELECT 'TEXT_6', 'VAT_DEST_COUNTRY_SETUP', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '110' FROM DUAL 
UNION 
 SELECT 'TEXT_6', 'VAT_DEST_COUNTRY_SETUP', '1000', '/', 'DISABLED_IND', 'VIEWLAYER', 'Y' FROM DUAL 
UNION 
 SELECT 'TEXT_6', 'VAT_DEST_COUNTRY_SETUP', '1000', '/EC', 'DESCRIPTION', 'APPLICATION', 'Standard text field that can be used by projects' FROM DUAL 
UNION 
 SELECT 'TEXT_6', 'VAT_DEST_COUNTRY_SETUP', '1000', '/EC', 'LABEL', 'APPLICATION', 'Text 6' FROM DUAL 
UNION 
 SELECT 'TEXT_6', 'VAT_DEST_COUNTRY_SETUP', '1000', '/EC', 'NAME', 'APPLICATION', 'Text 6' FROM DUAL 
UNION 
 SELECT 'TEXT_6', 'VAT_DEST_COUNTRY_SETUP', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '110' FROM DUAL 
UNION 
 SELECT 'TEXT_6', 'VAT_DEST_COUNTRY_SETUP', '1000', '/EC', 'viewwidth', 'STATIC_PRESENTATION', '120' FROM DUAL 
UNION 
 SELECT 'TEXT_6', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '110' FROM DUAL 
UNION 
 SELECT 'TEXT_6', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/', 'DISABLED_IND', 'VIEWLAYER', 'Y' FROM DUAL 
UNION 
 SELECT 'TEXT_6', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/EC', 'DESCRIPTION', 'APPLICATION', 'Standard text field that can be used by projects' FROM DUAL 
UNION 
 SELECT 'TEXT_6', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/EC', 'LABEL', 'APPLICATION', 'Text 6' FROM DUAL 
UNION 
 SELECT 'TEXT_6', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/EC', 'NAME', 'APPLICATION', 'Text 6' FROM DUAL 
UNION 
 SELECT 'TEXT_6', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '110' FROM DUAL 
UNION 
 SELECT 'TEXT_6', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/EC', 'viewwidth', 'STATIC_PRESENTATION', '120' FROM DUAL 
UNION 
 SELECT 'TEXT_6', 'VAT_VEND_COUNTRY_SETUP', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '110' FROM DUAL 
UNION 
 SELECT 'TEXT_6', 'VAT_VEND_COUNTRY_SETUP', '1000', '/', 'DISABLED_IND', 'VIEWLAYER', 'Y' FROM DUAL 
UNION 
 SELECT 'TEXT_6', 'VAT_VEND_COUNTRY_SETUP', '1000', '/EC', 'DESCRIPTION', 'APPLICATION', 'Standard text field that can be used by projects' FROM DUAL 
UNION 
 SELECT 'TEXT_6', 'VAT_VEND_COUNTRY_SETUP', '1000', '/EC', 'LABEL', 'APPLICATION', 'Text 6' FROM DUAL 
UNION 
 SELECT 'TEXT_6', 'VAT_VEND_COUNTRY_SETUP', '1000', '/EC', 'NAME', 'APPLICATION', 'Text 6' FROM DUAL 
UNION 
 SELECT 'TEXT_6', 'VAT_VEND_COUNTRY_SETUP', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '110' FROM DUAL 
UNION 
 SELECT 'TEXT_6', 'VAT_VEND_COUNTRY_SETUP', '1000', '/EC', 'viewwidth', 'STATIC_PRESENTATION', '120' FROM DUAL 
UNION 
 SELECT 'TEXT_7', 'TANK_FINDER_OBJECTS', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '9161' FROM DUAL 
UNION 
 SELECT 'TEXT_7', 'TANK_FINDER_OBJECTS', '1000', '/', 'DISABLED_IND', 'VIEWLAYER', 'Y' FROM DUAL 
UNION 
 SELECT 'TEXT_7', 'TANK_FINDER_OBJECTS', '1000', '/', 'IS_MANDATORY', 'VIEWLAYER', 'N' FROM DUAL 
UNION 
 SELECT 'TEXT_7', 'TANK_FINDER_OBJECTS', '1000', '/EC', 'DESCRIPTION', 'APPLICATION', 'TEXT_7' FROM DUAL 
UNION 
 SELECT 'TEXT_7', 'TANK_FINDER_OBJECTS', '1000', '/EC', 'LABEL', 'APPLICATION', 'Text 7' FROM DUAL 
UNION 
 SELECT 'TEXT_7', 'TANK_FINDER_OBJECTS', '1000', '/EC', 'NAME', 'APPLICATION', 'Text 7' FROM DUAL 
UNION 
 SELECT 'TEXT_7', 'TANK_FINDER_OBJECTS', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '9161' FROM DUAL 
UNION 
 SELECT 'TEXT_7', 'TANK_FINDER_OBJECTS', '1000', '/EC', 'vieweditable', 'STATIC_PRESENTATION', 'false' FROM DUAL 
UNION 
 SELECT 'TEXT_7', 'TANK_FINDER_OBJECTS', '1000', '/EC', 'viewwidth', 'STATIC_PRESENTATION', '150' FROM DUAL 
UNION 
 SELECT 'TEXT_7', 'VAT_CUST_COUNTRY_SETUP', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '120' FROM DUAL 
UNION 
 SELECT 'TEXT_7', 'VAT_CUST_COUNTRY_SETUP', '1000', '/', 'DISABLED_IND', 'VIEWLAYER', 'Y' FROM DUAL 
UNION 
 SELECT 'TEXT_7', 'VAT_CUST_COUNTRY_SETUP', '1000', '/EC', 'DESCRIPTION', 'APPLICATION', 'Standard text field that can be used by projects' FROM DUAL 
UNION 
 SELECT 'TEXT_7', 'VAT_CUST_COUNTRY_SETUP', '1000', '/EC', 'LABEL', 'APPLICATION', 'Text 7' FROM DUAL 
UNION 
 SELECT 'TEXT_7', 'VAT_CUST_COUNTRY_SETUP', '1000', '/EC', 'NAME', 'APPLICATION', 'Text 7' FROM DUAL 
UNION 
 SELECT 'TEXT_7', 'VAT_CUST_COUNTRY_SETUP', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '120' FROM DUAL 
UNION 
 SELECT 'TEXT_7', 'VAT_CUST_COUNTRY_SETUP', '1000', '/EC', 'viewwidth', 'STATIC_PRESENTATION', '120' FROM DUAL 
UNION 
 SELECT 'TEXT_7', 'VAT_DEST_COUNTRY_SETUP', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '120' FROM DUAL 
UNION 
 SELECT 'TEXT_7', 'VAT_DEST_COUNTRY_SETUP', '1000', '/', 'DISABLED_IND', 'VIEWLAYER', 'Y' FROM DUAL 
UNION 
 SELECT 'TEXT_7', 'VAT_DEST_COUNTRY_SETUP', '1000', '/EC', 'DESCRIPTION', 'APPLICATION', 'Standard text field that can be used by projects' FROM DUAL 
UNION 
 SELECT 'TEXT_7', 'VAT_DEST_COUNTRY_SETUP', '1000', '/EC', 'LABEL', 'APPLICATION', 'Text 7' FROM DUAL 
UNION 
 SELECT 'TEXT_7', 'VAT_DEST_COUNTRY_SETUP', '1000', '/EC', 'NAME', 'APPLICATION', 'Text 7' FROM DUAL 
UNION 
 SELECT 'TEXT_7', 'VAT_DEST_COUNTRY_SETUP', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '120' FROM DUAL 
UNION 
 SELECT 'TEXT_7', 'VAT_DEST_COUNTRY_SETUP', '1000', '/EC', 'viewwidth', 'STATIC_PRESENTATION', '120' FROM DUAL 
UNION 
 SELECT 'TEXT_7', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '120' FROM DUAL 
UNION 
 SELECT 'TEXT_7', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/', 'DISABLED_IND', 'VIEWLAYER', 'Y' FROM DUAL 
UNION 
 SELECT 'TEXT_7', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/EC', 'DESCRIPTION', 'APPLICATION', 'Standard text field that can be used by projects' FROM DUAL 
UNION 
 SELECT 'TEXT_7', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/EC', 'LABEL', 'APPLICATION', 'Text 7' FROM DUAL 
UNION 
 SELECT 'TEXT_7', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/EC', 'NAME', 'APPLICATION', 'Text 7' FROM DUAL 
UNION 
 SELECT 'TEXT_7', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '120' FROM DUAL 
UNION 
 SELECT 'TEXT_7', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/EC', 'viewwidth', 'STATIC_PRESENTATION', '120' FROM DUAL 
UNION 
 SELECT 'TEXT_7', 'VAT_VEND_COUNTRY_SETUP', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '120' FROM DUAL 
UNION 
 SELECT 'TEXT_7', 'VAT_VEND_COUNTRY_SETUP', '1000', '/', 'DISABLED_IND', 'VIEWLAYER', 'Y' FROM DUAL 
UNION 
 SELECT 'TEXT_7', 'VAT_VEND_COUNTRY_SETUP', '1000', '/EC', 'DESCRIPTION', 'APPLICATION', 'Standard text field that can be used by projects' FROM DUAL 
UNION 
 SELECT 'TEXT_7', 'VAT_VEND_COUNTRY_SETUP', '1000', '/EC', 'LABEL', 'APPLICATION', 'Text 7' FROM DUAL 
UNION 
 SELECT 'TEXT_7', 'VAT_VEND_COUNTRY_SETUP', '1000', '/EC', 'NAME', 'APPLICATION', 'Text 7' FROM DUAL 
UNION 
 SELECT 'TEXT_7', 'VAT_VEND_COUNTRY_SETUP', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '120' FROM DUAL 
UNION 
 SELECT 'TEXT_7', 'VAT_VEND_COUNTRY_SETUP', '1000', '/EC', 'viewwidth', 'STATIC_PRESENTATION', '120' FROM DUAL 
UNION 
 SELECT 'TEXT_8', 'REPORT_REF_CONN', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '100' FROM DUAL 
UNION 
 SELECT 'TEXT_8', 'REPORT_REF_CONN', '1000', '/', 'DISABLED_IND', 'VIEWLAYER', 'N' FROM DUAL 
UNION 
 SELECT 'TEXT_8', 'REPORT_REF_CONN', '1000', '/', 'IS_MANDATORY', 'VIEWLAYER', 'N' FROM DUAL 
UNION 
 SELECT 'TEXT_8', 'REPORT_REF_CONN', '1000', '/EC', 'LABEL', 'APPLICATION', 'AL/Royalty' FROM DUAL 
UNION 
 SELECT 'TEXT_8', 'REPORT_REF_CONN', '1000', '/EC', 'PopupCache', 'STATIC_PRESENTATION', 'true' FROM DUAL 
UNION 
 SELECT 'TEXT_8', 'REPORT_REF_CONN', '1000', '/EC', 'PopupDependency', 'STATIC_PRESENTATION', 'Screen.this.currentRow.TEXT_8=ReturnField.NAME' FROM DUAL 
UNION 
 SELECT 'TEXT_8', 'REPORT_REF_CONN', '1000', '/EC', 'PopupHeight', 'STATIC_PRESENTATION', '300' FROM DUAL 
UNION 
 SELECT 'TEXT_8', 'REPORT_REF_CONN', '1000', '/EC', 'PopupLayout', 'STATIC_PRESENTATION', '/com.ec.revn.cd/layout/ec_codes.xml' FROM DUAL 
UNION 
 SELECT 'TEXT_8', 'REPORT_REF_CONN', '1000', '/EC', 'PopupQueryURL', 'STATIC_PRESENTATION', '/com.ec.revn.sp/query/get_transaction_mapping_other_line_item_popup.xml' FROM DUAL 
UNION 
 SELECT 'TEXT_8', 'REPORT_REF_CONN', '1000', '/EC', 'PopupReturnColumn', 'STATIC_PRESENTATION', 'CODE_TEXT' FROM DUAL 
UNION 
 SELECT 'TEXT_8', 'REPORT_REF_CONN', '1000', '/EC', 'PopupWhereColumn', 'STATIC_PRESENTATION', 'CODE_TYPE' FROM DUAL 
UNION 
 SELECT 'TEXT_8', 'REPORT_REF_CONN', '1000', '/EC', 'PopupWhereOperator', 'STATIC_PRESENTATION', '=' FROM DUAL 
UNION 
 SELECT 'TEXT_8', 'REPORT_REF_CONN', '1000', '/EC', 'PopupWhereValue', 'STATIC_PRESENTATION', 'YES_NO' FROM DUAL 
UNION 
 SELECT 'TEXT_8', 'REPORT_REF_CONN', '1000', '/EC', 'PopupWidth', 'STATIC_PRESENTATION', '350' FROM DUAL 
UNION 
 SELECT 'TEXT_8', 'REPORT_REF_CONN', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '100' FROM DUAL 
UNION 
 SELECT 'TEXT_8', 'REPORT_REF_CONN', '1000', '/EC', 'viewhidden', 'DYNAMIC_PRESENTATION', 'DECODE(REF_CLASS,''COST_MAPPING'',null,''false'')' FROM DUAL 
UNION 
 SELECT 'TEXT_8', 'REPORT_REF_CONN', '1000', '/EC', 'viewtranslate', 'STATIC_PRESENTATION', 'true' FROM DUAL 
UNION 
 SELECT 'TEXT_8', 'REPORT_REF_CONN', '1000', '/EC', 'viewwidth', 'STATIC_PRESENTATION', '150' FROM DUAL 
UNION 
 SELECT 'TEXT_8', 'REPORT_REF_CONN_CM', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '120' FROM DUAL 
UNION 
 SELECT 'TEXT_8', 'REPORT_REF_CONN_CM', '1000', '/', 'DISABLED_IND', 'VIEWLAYER', 'N' FROM DUAL 
UNION 
 SELECT 'TEXT_8', 'REPORT_REF_CONN_CM', '1000', '/', 'IS_MANDATORY', 'VIEWLAYER', 'N' FROM DUAL 
UNION 
 SELECT 'TEXT_8', 'REPORT_REF_CONN_CM', '1000', '/EC', 'LABEL', 'APPLICATION', 'AL/Royalty' FROM DUAL 
UNION 
 SELECT 'TEXT_8', 'REPORT_REF_CONN_CM', '1000', '/EC', 'PopupDependency', 'STATIC_PRESENTATION', 'Screen.this.currentRow.TEXT_8=ReturnField.CODE' FROM DUAL 
UNION 
 SELECT 'TEXT_8', 'REPORT_REF_CONN_CM', '1000', '/EC', 'PopupHeight', 'STATIC_PRESENTATION', '300' FROM DUAL 
UNION 
 SELECT 'TEXT_8', 'REPORT_REF_CONN_CM', '1000', '/EC', 'PopupLayout', 'STATIC_PRESENTATION', '/com.ec.frmw.co.screens/layout/ec_code_popup.xml' FROM DUAL 
UNION 
 SELECT 'TEXT_8', 'REPORT_REF_CONN_CM', '1000', '/EC', 'PopupQueryURL', 'STATIC_PRESENTATION', '/com.ec.frmw.co.screens/query/ec_code_popup.xml' FROM DUAL 
UNION 
 SELECT 'TEXT_8', 'REPORT_REF_CONN_CM', '1000', '/EC', 'PopupReturnColumn', 'STATIC_PRESENTATION', 'CODE_TEXT' FROM DUAL 
UNION 
 SELECT 'TEXT_8', 'REPORT_REF_CONN_CM', '1000', '/EC', 'PopupWhereColumn', 'STATIC_PRESENTATION', 'CODE_TYPE' FROM DUAL 
UNION 
 SELECT 'TEXT_8', 'REPORT_REF_CONN_CM', '1000', '/EC', 'PopupWhereOperator', 'STATIC_PRESENTATION', '=' FROM DUAL 
UNION 
 SELECT 'TEXT_8', 'REPORT_REF_CONN_CM', '1000', '/EC', 'PopupWhereValue', 'STATIC_PRESENTATION', 'YES_NO' FROM DUAL 
UNION 
 SELECT 'TEXT_8', 'REPORT_REF_CONN_CM', '1000', '/EC', 'PopupWidth', 'STATIC_PRESENTATION', '250' FROM DUAL 
UNION 
 SELECT 'TEXT_8', 'REPORT_REF_CONN_CM', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '120' FROM DUAL 
UNION 
 SELECT 'TEXT_8', 'REPORT_REF_CONN_CM', '1000', '/EC', 'viewwidth', 'STATIC_PRESENTATION', '150' FROM DUAL 
UNION 
 SELECT 'TEXT_8', 'REPORT_REF_CONN_DOC', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '100' FROM DUAL 
UNION 
 SELECT 'TEXT_8', 'REPORT_REF_CONN_DOC', '1000', '/', 'DISABLED_IND', 'VIEWLAYER', 'Y' FROM DUAL 
UNION 
 SELECT 'TEXT_8', 'REPORT_REF_CONN_DOC', '1000', '/', 'IS_MANDATORY', 'VIEWLAYER', 'N' FROM DUAL 
UNION 
 SELECT 'TEXT_8', 'REPORT_REF_CONN_DOC', '1000', '/EC', 'LABEL', 'APPLICATION', 'AL/Royalty' FROM DUAL 
UNION 
 SELECT 'TEXT_8', 'REPORT_REF_CONN_DOC', '1000', '/EC', 'PopupCache', 'STATIC_PRESENTATION', 'true' FROM DUAL 
UNION 
 SELECT 'TEXT_8', 'REPORT_REF_CONN_DOC', '1000', '/EC', 'PopupDependency', 'STATIC_PRESENTATION', 'Screen.this.currentRow.TEXT_8=ReturnField.NAME' FROM DUAL 
UNION 
 SELECT 'TEXT_8', 'REPORT_REF_CONN_DOC', '1000', '/EC', 'PopupHeight', 'STATIC_PRESENTATION', '300' FROM DUAL 
UNION 
 SELECT 'TEXT_8', 'REPORT_REF_CONN_DOC', '1000', '/EC', 'PopupLayout', 'STATIC_PRESENTATION', '/com.ec.revn.cd/layout/ec_codes.xml' FROM DUAL 
UNION 
 SELECT 'TEXT_8', 'REPORT_REF_CONN_DOC', '1000', '/EC', 'PopupQueryURL', 'STATIC_PRESENTATION', '/com.ec.revn.sp/query/get_transaction_mapping_other_line_item_popup.xml' FROM DUAL 
UNION 
 SELECT 'TEXT_8', 'REPORT_REF_CONN_DOC', '1000', '/EC', 'PopupReturnColumn', 'STATIC_PRESENTATION', 'CODE_TEXT' FROM DUAL 
UNION 
 SELECT 'TEXT_8', 'REPORT_REF_CONN_DOC', '1000', '/EC', 'PopupWhereColumn', 'STATIC_PRESENTATION', 'CODE_TYPE' FROM DUAL 
UNION 
 SELECT 'TEXT_8', 'REPORT_REF_CONN_DOC', '1000', '/EC', 'PopupWhereOperator', 'STATIC_PRESENTATION', '=' FROM DUAL 
UNION 
 SELECT 'TEXT_8', 'REPORT_REF_CONN_DOC', '1000', '/EC', 'PopupWhereValue', 'STATIC_PRESENTATION', 'YES_NO' FROM DUAL 
UNION 
 SELECT 'TEXT_8', 'REPORT_REF_CONN_DOC', '1000', '/EC', 'PopupWidth', 'STATIC_PRESENTATION', '350' FROM DUAL 
UNION 
 SELECT 'TEXT_8', 'REPORT_REF_CONN_DOC', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '100' FROM DUAL 
UNION 
 SELECT 'TEXT_8', 'REPORT_REF_CONN_DOC', '1000', '/EC', 'viewhidden', 'DYNAMIC_PRESENTATION', 'DECODE(REF_CLASS,''COST_MAPPING'',null,''false'')' FROM DUAL 
UNION 
 SELECT 'TEXT_8', 'REPORT_REF_CONN_DOC', '1000', '/EC', 'viewtranslate', 'STATIC_PRESENTATION', 'true' FROM DUAL 
UNION 
 SELECT 'TEXT_8', 'REPORT_REF_CONN_DOC', '1000', '/EC', 'viewwidth', 'STATIC_PRESENTATION', '150' FROM DUAL 
UNION 
 SELECT 'TEXT_8', 'REPORT_REF_CONN_TI', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '100' FROM DUAL 
UNION 
 SELECT 'TEXT_8', 'REPORT_REF_CONN_TI', '1000', '/', 'DISABLED_IND', 'VIEWLAYER', 'Y' FROM DUAL 
UNION 
 SELECT 'TEXT_8', 'REPORT_REF_CONN_TI', '1000', '/', 'IS_MANDATORY', 'VIEWLAYER', 'N' FROM DUAL 
UNION 
 SELECT 'TEXT_8', 'REPORT_REF_CONN_TI', '1000', '/EC', 'LABEL', 'APPLICATION', 'AL/Royalty' FROM DUAL 
UNION 
 SELECT 'TEXT_8', 'REPORT_REF_CONN_TI', '1000', '/EC', 'PopupCache', 'STATIC_PRESENTATION', 'true' FROM DUAL 
UNION 
 SELECT 'TEXT_8', 'REPORT_REF_CONN_TI', '1000', '/EC', 'PopupDependency', 'STATIC_PRESENTATION', 'Screen.this.currentRow.TEXT_8=ReturnField.NAME' FROM DUAL 
UNION 
 SELECT 'TEXT_8', 'REPORT_REF_CONN_TI', '1000', '/EC', 'PopupHeight', 'STATIC_PRESENTATION', '300' FROM DUAL 
UNION 
 SELECT 'TEXT_8', 'REPORT_REF_CONN_TI', '1000', '/EC', 'PopupLayout', 'STATIC_PRESENTATION', '/com.ec.revn.cd/layout/ec_codes.xml' FROM DUAL 
UNION 
 SELECT 'TEXT_8', 'REPORT_REF_CONN_TI', '1000', '/EC', 'PopupQueryURL', 'STATIC_PRESENTATION', '/com.ec.revn.sp/query/get_transaction_mapping_other_line_item_popup.xml' FROM DUAL 
UNION 
 SELECT 'TEXT_8', 'REPORT_REF_CONN_TI', '1000', '/EC', 'PopupReturnColumn', 'STATIC_PRESENTATION', 'CODE_TEXT' FROM DUAL 
UNION 
 SELECT 'TEXT_8', 'REPORT_REF_CONN_TI', '1000', '/EC', 'PopupWhereColumn', 'STATIC_PRESENTATION', 'CODE_TYPE' FROM DUAL 
UNION 
 SELECT 'TEXT_8', 'REPORT_REF_CONN_TI', '1000', '/EC', 'PopupWhereOperator', 'STATIC_PRESENTATION', '=' FROM DUAL 
UNION 
 SELECT 'TEXT_8', 'REPORT_REF_CONN_TI', '1000', '/EC', 'PopupWhereValue', 'STATIC_PRESENTATION', 'YES_NO' FROM DUAL 
UNION 
 SELECT 'TEXT_8', 'REPORT_REF_CONN_TI', '1000', '/EC', 'PopupWidth', 'STATIC_PRESENTATION', '350' FROM DUAL 
UNION 
 SELECT 'TEXT_8', 'REPORT_REF_CONN_TI', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '100' FROM DUAL 
UNION 
 SELECT 'TEXT_8', 'REPORT_REF_CONN_TI', '1000', '/EC', 'viewhidden', 'DYNAMIC_PRESENTATION', 'DECODE(REF_CLASS,''COST_MAPPING'',null,''false'')' FROM DUAL 
UNION 
 SELECT 'TEXT_8', 'REPORT_REF_CONN_TI', '1000', '/EC', 'viewtranslate', 'STATIC_PRESENTATION', 'true' FROM DUAL 
UNION 
 SELECT 'TEXT_8', 'REPORT_REF_CONN_TI', '1000', '/EC', 'viewwidth', 'STATIC_PRESENTATION', '150' FROM DUAL 
UNION 
 SELECT 'TEXT_8', 'REPORT_REF_CONN_TI_LINE', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '100' FROM DUAL 
UNION 
 SELECT 'TEXT_8', 'REPORT_REF_CONN_TI_LINE', '1000', '/', 'DISABLED_IND', 'VIEWLAYER', 'Y' FROM DUAL 
UNION 
 SELECT 'TEXT_8', 'REPORT_REF_CONN_TI_LINE', '1000', '/', 'IS_MANDATORY', 'VIEWLAYER', 'N' FROM DUAL 
UNION 
 SELECT 'TEXT_8', 'REPORT_REF_CONN_TI_LINE', '1000', '/EC', 'LABEL', 'APPLICATION', 'AL/Royalty' FROM DUAL 
UNION 
 SELECT 'TEXT_8', 'REPORT_REF_CONN_TI_LINE', '1000', '/EC', 'PopupCache', 'STATIC_PRESENTATION', 'true' FROM DUAL 
UNION 
 SELECT 'TEXT_8', 'REPORT_REF_CONN_TI_LINE', '1000', '/EC', 'PopupDependency', 'STATIC_PRESENTATION', 'Screen.this.currentRow.TEXT_8=ReturnField.NAME' FROM DUAL 
UNION 
 SELECT 'TEXT_8', 'REPORT_REF_CONN_TI_LINE', '1000', '/EC', 'PopupHeight', 'STATIC_PRESENTATION', '300' FROM DUAL 
UNION 
 SELECT 'TEXT_8', 'REPORT_REF_CONN_TI_LINE', '1000', '/EC', 'PopupLayout', 'STATIC_PRESENTATION', '/com.ec.revn.cd/layout/ec_codes.xml' FROM DUAL 
UNION 
 SELECT 'TEXT_8', 'REPORT_REF_CONN_TI_LINE', '1000', '/EC', 'PopupQueryURL', 'STATIC_PRESENTATION', '/com.ec.revn.sp/query/get_transaction_mapping_other_line_item_popup.xml' FROM DUAL 
UNION 
 SELECT 'TEXT_8', 'REPORT_REF_CONN_TI_LINE', '1000', '/EC', 'PopupReturnColumn', 'STATIC_PRESENTATION', 'CODE_TEXT' FROM DUAL 
UNION 
 SELECT 'TEXT_8', 'REPORT_REF_CONN_TI_LINE', '1000', '/EC', 'PopupWhereColumn', 'STATIC_PRESENTATION', 'CODE_TYPE' FROM DUAL 
UNION 
 SELECT 'TEXT_8', 'REPORT_REF_CONN_TI_LINE', '1000', '/EC', 'PopupWhereOperator', 'STATIC_PRESENTATION', '=' FROM DUAL 
UNION 
 SELECT 'TEXT_8', 'REPORT_REF_CONN_TI_LINE', '1000', '/EC', 'PopupWhereValue', 'STATIC_PRESENTATION', 'YES_NO' FROM DUAL 
UNION 
 SELECT 'TEXT_8', 'REPORT_REF_CONN_TI_LINE', '1000', '/EC', 'PopupWidth', 'STATIC_PRESENTATION', '350' FROM DUAL 
UNION 
 SELECT 'TEXT_8', 'REPORT_REF_CONN_TI_LINE', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '100' FROM DUAL 
UNION 
 SELECT 'TEXT_8', 'REPORT_REF_CONN_TI_LINE', '1000', '/EC', 'viewhidden', 'DYNAMIC_PRESENTATION', 'DECODE(REF_CLASS,''COST_MAPPING'',null,''false'')' FROM DUAL 
UNION 
 SELECT 'TEXT_8', 'REPORT_REF_CONN_TI_LINE', '1000', '/EC', 'viewtranslate', 'STATIC_PRESENTATION', 'true' FROM DUAL 
UNION 
 SELECT 'TEXT_8', 'REPORT_REF_CONN_TI_LINE', '1000', '/EC', 'viewwidth', 'STATIC_PRESENTATION', '150' FROM DUAL 
UNION 
 SELECT 'TEXT_8', 'TANK_FINDER_OBJECTS', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '9162' FROM DUAL 
UNION 
 SELECT 'TEXT_8', 'TANK_FINDER_OBJECTS', '1000', '/', 'DISABLED_IND', 'VIEWLAYER', 'Y' FROM DUAL 
UNION 
 SELECT 'TEXT_8', 'TANK_FINDER_OBJECTS', '1000', '/', 'IS_MANDATORY', 'VIEWLAYER', 'N' FROM DUAL 
UNION 
 SELECT 'TEXT_8', 'TANK_FINDER_OBJECTS', '1000', '/EC', 'DESCRIPTION', 'APPLICATION', 'TEXT_8' FROM DUAL 
UNION 
 SELECT 'TEXT_8', 'TANK_FINDER_OBJECTS', '1000', '/EC', 'LABEL', 'APPLICATION', 'Text 8' FROM DUAL 
UNION 
 SELECT 'TEXT_8', 'TANK_FINDER_OBJECTS', '1000', '/EC', 'NAME', 'APPLICATION', 'Text 8' FROM DUAL 
UNION 
 SELECT 'TEXT_8', 'TANK_FINDER_OBJECTS', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '9162' FROM DUAL 
UNION 
 SELECT 'TEXT_8', 'TANK_FINDER_OBJECTS', '1000', '/EC', 'vieweditable', 'STATIC_PRESENTATION', 'false' FROM DUAL 
UNION 
 SELECT 'TEXT_8', 'TANK_FINDER_OBJECTS', '1000', '/EC', 'viewwidth', 'STATIC_PRESENTATION', '150' FROM DUAL 
UNION 
 SELECT 'TEXT_8', 'VAT_CUST_COUNTRY_SETUP', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '130' FROM DUAL 
UNION 
 SELECT 'TEXT_8', 'VAT_CUST_COUNTRY_SETUP', '1000', '/', 'DISABLED_IND', 'VIEWLAYER', 'Y' FROM DUAL 
UNION 
 SELECT 'TEXT_8', 'VAT_CUST_COUNTRY_SETUP', '1000', '/EC', 'DESCRIPTION', 'APPLICATION', 'Standard text field that can be used by projects' FROM DUAL 
UNION 
 SELECT 'TEXT_8', 'VAT_CUST_COUNTRY_SETUP', '1000', '/EC', 'LABEL', 'APPLICATION', 'Text 8' FROM DUAL 
UNION 
 SELECT 'TEXT_8', 'VAT_CUST_COUNTRY_SETUP', '1000', '/EC', 'NAME', 'APPLICATION', 'Text 8' FROM DUAL 
UNION 
 SELECT 'TEXT_8', 'VAT_CUST_COUNTRY_SETUP', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '130' FROM DUAL 
UNION 
 SELECT 'TEXT_8', 'VAT_CUST_COUNTRY_SETUP', '1000', '/EC', 'viewwidth', 'STATIC_PRESENTATION', '120' FROM DUAL 
UNION 
 SELECT 'TEXT_8', 'VAT_DEST_COUNTRY_SETUP', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '130' FROM DUAL 
UNION 
 SELECT 'TEXT_8', 'VAT_DEST_COUNTRY_SETUP', '1000', '/', 'DISABLED_IND', 'VIEWLAYER', 'Y' FROM DUAL 
UNION 
 SELECT 'TEXT_8', 'VAT_DEST_COUNTRY_SETUP', '1000', '/EC', 'DESCRIPTION', 'APPLICATION', 'Standard text field that can be used by projects' FROM DUAL 
UNION 
 SELECT 'TEXT_8', 'VAT_DEST_COUNTRY_SETUP', '1000', '/EC', 'LABEL', 'APPLICATION', 'Text 8' FROM DUAL 
UNION 
 SELECT 'TEXT_8', 'VAT_DEST_COUNTRY_SETUP', '1000', '/EC', 'NAME', 'APPLICATION', 'Text 8' FROM DUAL 
UNION 
 SELECT 'TEXT_8', 'VAT_DEST_COUNTRY_SETUP', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '130' FROM DUAL 
UNION 
 SELECT 'TEXT_8', 'VAT_DEST_COUNTRY_SETUP', '1000', '/EC', 'viewwidth', 'STATIC_PRESENTATION', '120' FROM DUAL 
UNION 
 SELECT 'TEXT_8', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '130' FROM DUAL 
UNION 
 SELECT 'TEXT_8', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/', 'DISABLED_IND', 'VIEWLAYER', 'Y' FROM DUAL 
UNION 
 SELECT 'TEXT_8', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/EC', 'DESCRIPTION', 'APPLICATION', 'Standard text field that can be used by projects' FROM DUAL 
UNION 
 SELECT 'TEXT_8', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/EC', 'LABEL', 'APPLICATION', 'Text 8' FROM DUAL 
UNION 
 SELECT 'TEXT_8', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/EC', 'NAME', 'APPLICATION', 'Text 8' FROM DUAL 
UNION 
 SELECT 'TEXT_8', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '130' FROM DUAL 
UNION 
 SELECT 'TEXT_8', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/EC', 'viewwidth', 'STATIC_PRESENTATION', '120' FROM DUAL 
UNION 
 SELECT 'TEXT_8', 'VAT_VEND_COUNTRY_SETUP', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '130' FROM DUAL 
UNION 
 SELECT 'TEXT_8', 'VAT_VEND_COUNTRY_SETUP', '1000', '/', 'DISABLED_IND', 'VIEWLAYER', 'Y' FROM DUAL 
UNION 
 SELECT 'TEXT_8', 'VAT_VEND_COUNTRY_SETUP', '1000', '/EC', 'DESCRIPTION', 'APPLICATION', 'Standard text field that can be used by projects' FROM DUAL 
UNION 
 SELECT 'TEXT_8', 'VAT_VEND_COUNTRY_SETUP', '1000', '/EC', 'LABEL', 'APPLICATION', 'Text 8' FROM DUAL 
UNION 
 SELECT 'TEXT_8', 'VAT_VEND_COUNTRY_SETUP', '1000', '/EC', 'NAME', 'APPLICATION', 'Text 8' FROM DUAL 
UNION 
 SELECT 'TEXT_8', 'VAT_VEND_COUNTRY_SETUP', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '130' FROM DUAL 
UNION 
 SELECT 'TEXT_8', 'VAT_VEND_COUNTRY_SETUP', '1000', '/EC', 'viewwidth', 'STATIC_PRESENTATION', '120' FROM DUAL 
UNION 
 SELECT 'TEXT_9', 'REPORT_REF_CONN', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '100' FROM DUAL 
UNION 
 SELECT 'TEXT_9', 'REPORT_REF_CONN', '1000', '/', 'DISABLED_IND', 'VIEWLAYER', 'N' FROM DUAL 
UNION 
 SELECT 'TEXT_9', 'REPORT_REF_CONN', '1000', '/', 'IS_MANDATORY', 'VIEWLAYER', 'N' FROM DUAL 
UNION 
 SELECT 'TEXT_9', 'REPORT_REF_CONN', '1000', '/EC', 'LABEL', 'APPLICATION', 'Location' FROM DUAL 
UNION 
 SELECT 'TEXT_9', 'REPORT_REF_CONN', '1000', '/EC', 'PopupCache', 'STATIC_PRESENTATION', 'true' FROM DUAL 
UNION 
 SELECT 'TEXT_9', 'REPORT_REF_CONN', '1000', '/EC', 'PopupDependency', 'STATIC_PRESENTATION', 'Screen.this.currentRow.TEXT_9=ReturnField.CODE' FROM DUAL 
UNION 
 SELECT 'TEXT_9', 'REPORT_REF_CONN', '1000', '/EC', 'PopupHeight', 'STATIC_PRESENTATION', '300' FROM DUAL 
UNION 
 SELECT 'TEXT_9', 'REPORT_REF_CONN', '1000', '/EC', 'PopupLayout', 'STATIC_PRESENTATION', '/com.ec.revn.cd/layout/ec_codes.xml' FROM DUAL 
UNION 
 SELECT 'TEXT_9', 'REPORT_REF_CONN', '1000', '/EC', 'PopupQueryURL', 'STATIC_PRESENTATION', '/com.ec.revn.sp/query/get_transaction_mapping_other_line_item_popup.xml' FROM DUAL 
UNION 
 SELECT 'TEXT_9', 'REPORT_REF_CONN', '1000', '/EC', 'PopupReturnColumn', 'STATIC_PRESENTATION', 'CODE_TEXT' FROM DUAL 
UNION 
 SELECT 'TEXT_9', 'REPORT_REF_CONN', '1000', '/EC', 'PopupWhereColumn', 'STATIC_PRESENTATION', 'CODE_TYPE' FROM DUAL 
UNION 
 SELECT 'TEXT_9', 'REPORT_REF_CONN', '1000', '/EC', 'PopupWhereOperator', 'STATIC_PRESENTATION', '=' FROM DUAL 
UNION 
 SELECT 'TEXT_9', 'REPORT_REF_CONN', '1000', '/EC', 'PopupWhereValue', 'STATIC_PRESENTATION', 'CVE_LOCATION' FROM DUAL 
UNION 
 SELECT 'TEXT_9', 'REPORT_REF_CONN', '1000', '/EC', 'PopupWidth', 'STATIC_PRESENTATION', '350' FROM DUAL 
UNION 
 SELECT 'TEXT_9', 'REPORT_REF_CONN', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '100' FROM DUAL 
UNION 
 SELECT 'TEXT_9', 'REPORT_REF_CONN', '1000', '/EC', 'viewhidden', 'DYNAMIC_PRESENTATION', 'DECODE(REF_CLASS,''COST_MAPPING'',null,''false'')' FROM DUAL 
UNION 
 SELECT 'TEXT_9', 'REPORT_REF_CONN', '1000', '/EC', 'viewtranslate', 'STATIC_PRESENTATION', 'true' FROM DUAL 
UNION 
 SELECT 'TEXT_9', 'REPORT_REF_CONN', '1000', '/EC', 'viewwidth', 'STATIC_PRESENTATION', '150' FROM DUAL 
UNION 
 SELECT 'TEXT_9', 'REPORT_REF_CONN_CM', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '130' FROM DUAL 
UNION 
 SELECT 'TEXT_9', 'REPORT_REF_CONN_CM', '1000', '/', 'DISABLED_IND', 'VIEWLAYER', 'N' FROM DUAL 
UNION 
 SELECT 'TEXT_9', 'REPORT_REF_CONN_CM', '1000', '/', 'IS_MANDATORY', 'VIEWLAYER', 'N' FROM DUAL 
UNION 
 SELECT 'TEXT_9', 'REPORT_REF_CONN_CM', '1000', '/EC', 'LABEL', 'APPLICATION', 'Location' FROM DUAL 
UNION 
 SELECT 'TEXT_9', 'REPORT_REF_CONN_CM', '1000', '/EC', 'PopupDependency', 'STATIC_PRESENTATION', 'Screen.this.currentRow.TEXT_9=ReturnField.CODE' FROM DUAL 
UNION 
 SELECT 'TEXT_9', 'REPORT_REF_CONN_CM', '1000', '/EC', 'PopupHeight', 'STATIC_PRESENTATION', '300' FROM DUAL 
UNION 
 SELECT 'TEXT_9', 'REPORT_REF_CONN_CM', '1000', '/EC', 'PopupLayout', 'STATIC_PRESENTATION', '/com.ec.frmw.co.screens/layout/ec_code_popup.xml' FROM DUAL 
UNION 
 SELECT 'TEXT_9', 'REPORT_REF_CONN_CM', '1000', '/EC', 'PopupQueryURL', 'STATIC_PRESENTATION', '/com.ec.frmw.co.screens/query/ec_code_popup.xml' FROM DUAL 
UNION 
 SELECT 'TEXT_9', 'REPORT_REF_CONN_CM', '1000', '/EC', 'PopupReturnColumn', 'STATIC_PRESENTATION', 'CODE_TEXT' FROM DUAL 
UNION 
 SELECT 'TEXT_9', 'REPORT_REF_CONN_CM', '1000', '/EC', 'PopupWhereColumn', 'STATIC_PRESENTATION', 'CODE_TYPE' FROM DUAL 
UNION 
 SELECT 'TEXT_9', 'REPORT_REF_CONN_CM', '1000', '/EC', 'PopupWhereOperator', 'STATIC_PRESENTATION', '=' FROM DUAL 
UNION 
 SELECT 'TEXT_9', 'REPORT_REF_CONN_CM', '1000', '/EC', 'PopupWhereValue', 'STATIC_PRESENTATION', 'CVE_LOCATION' FROM DUAL 
UNION 
 SELECT 'TEXT_9', 'REPORT_REF_CONN_CM', '1000', '/EC', 'PopupWidth', 'STATIC_PRESENTATION', '250' FROM DUAL 
UNION 
 SELECT 'TEXT_9', 'REPORT_REF_CONN_CM', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '130' FROM DUAL 
UNION 
 SELECT 'TEXT_9', 'REPORT_REF_CONN_CM', '1000', '/EC', 'viewwidth', 'STATIC_PRESENTATION', '150' FROM DUAL 
UNION 
 SELECT 'TEXT_9', 'REPORT_REF_CONN_DOC', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '100' FROM DUAL 
UNION 
 SELECT 'TEXT_9', 'REPORT_REF_CONN_DOC', '1000', '/', 'DISABLED_IND', 'VIEWLAYER', 'Y' FROM DUAL 
UNION 
 SELECT 'TEXT_9', 'REPORT_REF_CONN_DOC', '1000', '/', 'IS_MANDATORY', 'VIEWLAYER', 'N' FROM DUAL 
UNION 
 SELECT 'TEXT_9', 'REPORT_REF_CONN_DOC', '1000', '/EC', 'LABEL', 'APPLICATION', 'Location' FROM DUAL 
UNION 
 SELECT 'TEXT_9', 'REPORT_REF_CONN_DOC', '1000', '/EC', 'PopupCache', 'STATIC_PRESENTATION', 'true' FROM DUAL 
UNION 
 SELECT 'TEXT_9', 'REPORT_REF_CONN_DOC', '1000', '/EC', 'PopupDependency', 'STATIC_PRESENTATION', 'Screen.this.currentRow.TEXT_9=ReturnField.CODE' FROM DUAL 
UNION 
 SELECT 'TEXT_9', 'REPORT_REF_CONN_DOC', '1000', '/EC', 'PopupHeight', 'STATIC_PRESENTATION', '300' FROM DUAL 
UNION 
 SELECT 'TEXT_9', 'REPORT_REF_CONN_DOC', '1000', '/EC', 'PopupLayout', 'STATIC_PRESENTATION', '/com.ec.revn.cd/layout/ec_codes.xml' FROM DUAL 
UNION 
 SELECT 'TEXT_9', 'REPORT_REF_CONN_DOC', '1000', '/EC', 'PopupQueryURL', 'STATIC_PRESENTATION', '/com.ec.revn.sp/query/get_transaction_mapping_other_line_item_popup.xml' FROM DUAL 
UNION 
 SELECT 'TEXT_9', 'REPORT_REF_CONN_DOC', '1000', '/EC', 'PopupReturnColumn', 'STATIC_PRESENTATION', 'CODE_TEXT' FROM DUAL 
UNION 
 SELECT 'TEXT_9', 'REPORT_REF_CONN_DOC', '1000', '/EC', 'PopupWhereColumn', 'STATIC_PRESENTATION', 'CODE_TYPE' FROM DUAL 
UNION 
 SELECT 'TEXT_9', 'REPORT_REF_CONN_DOC', '1000', '/EC', 'PopupWhereOperator', 'STATIC_PRESENTATION', '=' FROM DUAL 
UNION 
 SELECT 'TEXT_9', 'REPORT_REF_CONN_DOC', '1000', '/EC', 'PopupWhereValue', 'STATIC_PRESENTATION', 'CVE_LOCATION' FROM DUAL 
UNION 
 SELECT 'TEXT_9', 'REPORT_REF_CONN_DOC', '1000', '/EC', 'PopupWidth', 'STATIC_PRESENTATION', '350' FROM DUAL 
UNION 
 SELECT 'TEXT_9', 'REPORT_REF_CONN_DOC', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '100' FROM DUAL 
UNION 
 SELECT 'TEXT_9', 'REPORT_REF_CONN_DOC', '1000', '/EC', 'viewhidden', 'DYNAMIC_PRESENTATION', 'DECODE(REF_CLASS,''COST_MAPPING'',null,''false'')' FROM DUAL 
UNION 
 SELECT 'TEXT_9', 'REPORT_REF_CONN_DOC', '1000', '/EC', 'viewtranslate', 'STATIC_PRESENTATION', 'true' FROM DUAL 
UNION 
 SELECT 'TEXT_9', 'REPORT_REF_CONN_DOC', '1000', '/EC', 'viewwidth', 'STATIC_PRESENTATION', '150' FROM DUAL 
UNION 
 SELECT 'TEXT_9', 'REPORT_REF_CONN_TI', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '100' FROM DUAL 
UNION 
 SELECT 'TEXT_9', 'REPORT_REF_CONN_TI', '1000', '/', 'DISABLED_IND', 'VIEWLAYER', 'Y' FROM DUAL 
UNION 
 SELECT 'TEXT_9', 'REPORT_REF_CONN_TI', '1000', '/', 'IS_MANDATORY', 'VIEWLAYER', 'N' FROM DUAL 
UNION 
 SELECT 'TEXT_9', 'REPORT_REF_CONN_TI', '1000', '/EC', 'LABEL', 'APPLICATION', 'Location' FROM DUAL 
UNION 
 SELECT 'TEXT_9', 'REPORT_REF_CONN_TI', '1000', '/EC', 'PopupCache', 'STATIC_PRESENTATION', 'true' FROM DUAL 
UNION 
 SELECT 'TEXT_9', 'REPORT_REF_CONN_TI', '1000', '/EC', 'PopupDependency', 'STATIC_PRESENTATION', 'Screen.this.currentRow.TEXT_9=ReturnField.CODE' FROM DUAL 
UNION 
 SELECT 'TEXT_9', 'REPORT_REF_CONN_TI', '1000', '/EC', 'PopupHeight', 'STATIC_PRESENTATION', '300' FROM DUAL 
UNION 
 SELECT 'TEXT_9', 'REPORT_REF_CONN_TI', '1000', '/EC', 'PopupLayout', 'STATIC_PRESENTATION', '/com.ec.revn.cd/layout/ec_codes.xml' FROM DUAL 
UNION 
 SELECT 'TEXT_9', 'REPORT_REF_CONN_TI', '1000', '/EC', 'PopupQueryURL', 'STATIC_PRESENTATION', '/com.ec.revn.sp/query/get_transaction_mapping_other_line_item_popup.xml' FROM DUAL 
UNION 
 SELECT 'TEXT_9', 'REPORT_REF_CONN_TI', '1000', '/EC', 'PopupReturnColumn', 'STATIC_PRESENTATION', 'CODE_TEXT' FROM DUAL 
UNION 
 SELECT 'TEXT_9', 'REPORT_REF_CONN_TI', '1000', '/EC', 'PopupWhereColumn', 'STATIC_PRESENTATION', 'CODE_TYPE' FROM DUAL 
UNION 
 SELECT 'TEXT_9', 'REPORT_REF_CONN_TI', '1000', '/EC', 'PopupWhereOperator', 'STATIC_PRESENTATION', '=' FROM DUAL 
UNION 
 SELECT 'TEXT_9', 'REPORT_REF_CONN_TI', '1000', '/EC', 'PopupWhereValue', 'STATIC_PRESENTATION', 'CVE_LOCATION' FROM DUAL 
UNION 
 SELECT 'TEXT_9', 'REPORT_REF_CONN_TI', '1000', '/EC', 'PopupWidth', 'STATIC_PRESENTATION', '350' FROM DUAL 
UNION 
 SELECT 'TEXT_9', 'REPORT_REF_CONN_TI', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '100' FROM DUAL 
UNION 
 SELECT 'TEXT_9', 'REPORT_REF_CONN_TI', '1000', '/EC', 'viewhidden', 'DYNAMIC_PRESENTATION', 'DECODE(REF_CLASS,''COST_MAPPING'',null,''false'')' FROM DUAL 
UNION 
 SELECT 'TEXT_9', 'REPORT_REF_CONN_TI', '1000', '/EC', 'viewtranslate', 'STATIC_PRESENTATION', 'true' FROM DUAL 
UNION 
 SELECT 'TEXT_9', 'REPORT_REF_CONN_TI', '1000', '/EC', 'viewwidth', 'STATIC_PRESENTATION', '150' FROM DUAL 
UNION 
 SELECT 'TEXT_9', 'REPORT_REF_CONN_TI_LINE', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '100' FROM DUAL 
UNION 
 SELECT 'TEXT_9', 'REPORT_REF_CONN_TI_LINE', '1000', '/', 'DISABLED_IND', 'VIEWLAYER', 'Y' FROM DUAL 
UNION 
 SELECT 'TEXT_9', 'REPORT_REF_CONN_TI_LINE', '1000', '/', 'IS_MANDATORY', 'VIEWLAYER', 'N' FROM DUAL 
UNION 
 SELECT 'TEXT_9', 'REPORT_REF_CONN_TI_LINE', '1000', '/EC', 'LABEL', 'APPLICATION', 'Location' FROM DUAL 
UNION 
 SELECT 'TEXT_9', 'REPORT_REF_CONN_TI_LINE', '1000', '/EC', 'PopupCache', 'STATIC_PRESENTATION', 'true' FROM DUAL 
UNION 
 SELECT 'TEXT_9', 'REPORT_REF_CONN_TI_LINE', '1000', '/EC', 'PopupDependency', 'STATIC_PRESENTATION', 'Screen.this.currentRow.TEXT_9=ReturnField.CODE' FROM DUAL 
UNION 
 SELECT 'TEXT_9', 'REPORT_REF_CONN_TI_LINE', '1000', '/EC', 'PopupHeight', 'STATIC_PRESENTATION', '300' FROM DUAL 
UNION 
 SELECT 'TEXT_9', 'REPORT_REF_CONN_TI_LINE', '1000', '/EC', 'PopupLayout', 'STATIC_PRESENTATION', '/com.ec.revn.cd/layout/ec_codes.xml' FROM DUAL 
UNION 
 SELECT 'TEXT_9', 'REPORT_REF_CONN_TI_LINE', '1000', '/EC', 'PopupQueryURL', 'STATIC_PRESENTATION', '/com.ec.revn.sp/query/get_transaction_mapping_other_line_item_popup.xml' FROM DUAL 
UNION 
 SELECT 'TEXT_9', 'REPORT_REF_CONN_TI_LINE', '1000', '/EC', 'PopupReturnColumn', 'STATIC_PRESENTATION', 'CODE_TEXT' FROM DUAL 
UNION 
 SELECT 'TEXT_9', 'REPORT_REF_CONN_TI_LINE', '1000', '/EC', 'PopupWhereColumn', 'STATIC_PRESENTATION', 'CODE_TYPE' FROM DUAL 
UNION 
 SELECT 'TEXT_9', 'REPORT_REF_CONN_TI_LINE', '1000', '/EC', 'PopupWhereOperator', 'STATIC_PRESENTATION', '=' FROM DUAL 
UNION 
 SELECT 'TEXT_9', 'REPORT_REF_CONN_TI_LINE', '1000', '/EC', 'PopupWhereValue', 'STATIC_PRESENTATION', 'CVE_LOCATION' FROM DUAL 
UNION 
 SELECT 'TEXT_9', 'REPORT_REF_CONN_TI_LINE', '1000', '/EC', 'PopupWidth', 'STATIC_PRESENTATION', '350' FROM DUAL 
UNION 
 SELECT 'TEXT_9', 'REPORT_REF_CONN_TI_LINE', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '100' FROM DUAL 
UNION 
 SELECT 'TEXT_9', 'REPORT_REF_CONN_TI_LINE', '1000', '/EC', 'viewhidden', 'DYNAMIC_PRESENTATION', 'DECODE(REF_CLASS,''COST_MAPPING'',null,''false'')' FROM DUAL 
UNION 
 SELECT 'TEXT_9', 'REPORT_REF_CONN_TI_LINE', '1000', '/EC', 'viewtranslate', 'STATIC_PRESENTATION', 'true' FROM DUAL 
UNION 
 SELECT 'TEXT_9', 'REPORT_REF_CONN_TI_LINE', '1000', '/EC', 'viewwidth', 'STATIC_PRESENTATION', '150' FROM DUAL 
UNION 
 SELECT 'TEXT_9', 'TANK_FINDER_OBJECTS', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '9163' FROM DUAL 
UNION 
 SELECT 'TEXT_9', 'TANK_FINDER_OBJECTS', '1000', '/', 'DISABLED_IND', 'VIEWLAYER', 'Y' FROM DUAL 
UNION 
 SELECT 'TEXT_9', 'TANK_FINDER_OBJECTS', '1000', '/', 'IS_MANDATORY', 'VIEWLAYER', 'N' FROM DUAL 
UNION 
 SELECT 'TEXT_9', 'TANK_FINDER_OBJECTS', '1000', '/EC', 'DESCRIPTION', 'APPLICATION', 'TEXT_9' FROM DUAL 
UNION 
 SELECT 'TEXT_9', 'TANK_FINDER_OBJECTS', '1000', '/EC', 'LABEL', 'APPLICATION', 'Text 9' FROM DUAL 
UNION 
 SELECT 'TEXT_9', 'TANK_FINDER_OBJECTS', '1000', '/EC', 'NAME', 'APPLICATION', 'Text 9' FROM DUAL 
UNION 
 SELECT 'TEXT_9', 'TANK_FINDER_OBJECTS', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '9163' FROM DUAL 
UNION 
 SELECT 'TEXT_9', 'TANK_FINDER_OBJECTS', '1000', '/EC', 'vieweditable', 'STATIC_PRESENTATION', 'false' FROM DUAL 
UNION 
 SELECT 'TEXT_9', 'TANK_FINDER_OBJECTS', '1000', '/EC', 'viewwidth', 'STATIC_PRESENTATION', '150' FROM DUAL 
UNION 
 SELECT 'TEXT_9', 'VAT_CUST_COUNTRY_SETUP', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '140' FROM DUAL 
UNION 
 SELECT 'TEXT_9', 'VAT_CUST_COUNTRY_SETUP', '1000', '/', 'DISABLED_IND', 'VIEWLAYER', 'Y' FROM DUAL 
UNION 
 SELECT 'TEXT_9', 'VAT_CUST_COUNTRY_SETUP', '1000', '/EC', 'DESCRIPTION', 'APPLICATION', 'Standard text field that can be used by projects' FROM DUAL 
UNION 
 SELECT 'TEXT_9', 'VAT_CUST_COUNTRY_SETUP', '1000', '/EC', 'LABEL', 'APPLICATION', 'Text 9' FROM DUAL 
UNION 
 SELECT 'TEXT_9', 'VAT_CUST_COUNTRY_SETUP', '1000', '/EC', 'NAME', 'APPLICATION', 'Text 9' FROM DUAL 
UNION 
 SELECT 'TEXT_9', 'VAT_CUST_COUNTRY_SETUP', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '140' FROM DUAL 
UNION 
 SELECT 'TEXT_9', 'VAT_CUST_COUNTRY_SETUP', '1000', '/EC', 'viewwidth', 'STATIC_PRESENTATION', '120' FROM DUAL 
UNION 
 SELECT 'TEXT_9', 'VAT_DEST_COUNTRY_SETUP', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '140' FROM DUAL 
UNION 
 SELECT 'TEXT_9', 'VAT_DEST_COUNTRY_SETUP', '1000', '/', 'DISABLED_IND', 'VIEWLAYER', 'Y' FROM DUAL 
UNION 
 SELECT 'TEXT_9', 'VAT_DEST_COUNTRY_SETUP', '1000', '/EC', 'DESCRIPTION', 'APPLICATION', 'Standard text field that can be used by projects' FROM DUAL 
UNION 
 SELECT 'TEXT_9', 'VAT_DEST_COUNTRY_SETUP', '1000', '/EC', 'LABEL', 'APPLICATION', 'Text 9' FROM DUAL 
UNION 
 SELECT 'TEXT_9', 'VAT_DEST_COUNTRY_SETUP', '1000', '/EC', 'NAME', 'APPLICATION', 'Text 9' FROM DUAL 
UNION 
 SELECT 'TEXT_9', 'VAT_DEST_COUNTRY_SETUP', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '140' FROM DUAL 
UNION 
 SELECT 'TEXT_9', 'VAT_DEST_COUNTRY_SETUP', '1000', '/EC', 'viewwidth', 'STATIC_PRESENTATION', '120' FROM DUAL 
UNION 
 SELECT 'TEXT_9', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '140' FROM DUAL 
UNION 
 SELECT 'TEXT_9', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/', 'DISABLED_IND', 'VIEWLAYER', 'Y' FROM DUAL 
UNION 
 SELECT 'TEXT_9', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/EC', 'DESCRIPTION', 'APPLICATION', 'Standard text field that can be used by projects' FROM DUAL 
UNION 
 SELECT 'TEXT_9', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/EC', 'LABEL', 'APPLICATION', 'Text 9' FROM DUAL 
UNION 
 SELECT 'TEXT_9', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/EC', 'NAME', 'APPLICATION', 'Text 9' FROM DUAL 
UNION 
 SELECT 'TEXT_9', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '140' FROM DUAL 
UNION 
 SELECT 'TEXT_9', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/EC', 'viewwidth', 'STATIC_PRESENTATION', '120' FROM DUAL 
UNION 
 SELECT 'TEXT_9', 'VAT_VEND_COUNTRY_SETUP', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '140' FROM DUAL 
UNION 
 SELECT 'TEXT_9', 'VAT_VEND_COUNTRY_SETUP', '1000', '/', 'DISABLED_IND', 'VIEWLAYER', 'Y' FROM DUAL 
UNION 
 SELECT 'TEXT_9', 'VAT_VEND_COUNTRY_SETUP', '1000', '/EC', 'DESCRIPTION', 'APPLICATION', 'Standard text field that can be used by projects' FROM DUAL 
UNION 
 SELECT 'TEXT_9', 'VAT_VEND_COUNTRY_SETUP', '1000', '/EC', 'LABEL', 'APPLICATION', 'Text 9' FROM DUAL 
UNION 
 SELECT 'TEXT_9', 'VAT_VEND_COUNTRY_SETUP', '1000', '/EC', 'NAME', 'APPLICATION', 'Text 9' FROM DUAL 
UNION 
 SELECT 'TEXT_9', 'VAT_VEND_COUNTRY_SETUP', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '140' FROM DUAL 
UNION 
 SELECT 'TEXT_9', 'VAT_VEND_COUNTRY_SETUP', '1000', '/EC', 'viewwidth', 'STATIC_PRESENTATION', '120' FROM DUAL 
UNION 
 SELECT 'VALUE_1', 'OBJECT_CALC_COMPONENT', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '600' FROM DUAL 
UNION 
 SELECT 'VALUE_1', 'OBJECT_CALC_COMPONENT', '1000', '/EC', 'LABEL', 'APPLICATION', 'Value Column 1' FROM DUAL 
UNION 
 SELECT 'VALUE_1', 'OBJECT_CALC_COMPONENT', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '600' FROM DUAL 
UNION 
 SELECT 'VALUE_1', 'REVN_CARGO_DG_LOG', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '900' FROM DUAL 
UNION 
 SELECT 'VALUE_1', 'REVN_CARGO_DG_LOG', '1000', '/', 'DISABLED_IND', 'VIEWLAYER', 'N' FROM DUAL 
UNION 
 SELECT 'VALUE_1', 'REVN_CARGO_DG_LOG', '1000', '/', 'IS_MANDATORY', 'VIEWLAYER', 'N' FROM DUAL 
UNION 
 SELECT 'VALUE_1', 'REVN_CARGO_DG_LOG', '1000', '/EC', 'DESCRIPTION', 'APPLICATION', 'Standard value field that can be used by projects' FROM DUAL 
UNION 
 SELECT 'VALUE_1', 'REVN_CARGO_DG_LOG', '1000', '/EC', 'LABEL', 'APPLICATION', 'Value 1' FROM DUAL 
UNION 
 SELECT 'VALUE_1', 'REVN_CARGO_DG_LOG', '1000', '/EC', 'NAME', 'APPLICATION', 'Value 1' FROM DUAL 
UNION 
 SELECT 'VALUE_1', 'REVN_CARGO_DG_LOG', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '900' FROM DUAL 
UNION 
 SELECT 'VALUE_1', 'REVN_CARGO_DG_LOG', '1000', '/EC', 'viewhidden', 'STATIC_PRESENTATION', 'true' FROM DUAL 
UNION 
 SELECT 'VALUE_1', 'REVN_CARGO_DG_LOG', '1000', '/EC', 'viewwidth', 'STATIC_PRESENTATION', '47' FROM DUAL 
UNION 
 SELECT 'VALUE_1', 'REVN_CASCADE_LOG', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '900' FROM DUAL 
UNION 
 SELECT 'VALUE_1', 'REVN_CASCADE_LOG', '1000', '/', 'DISABLED_IND', 'VIEWLAYER', 'N' FROM DUAL 
UNION 
 SELECT 'VALUE_1', 'REVN_CASCADE_LOG', '1000', '/', 'IS_MANDATORY', 'VIEWLAYER', 'N' FROM DUAL 
UNION 
 SELECT 'VALUE_1', 'REVN_CASCADE_LOG', '1000', '/EC', 'DESCRIPTION', 'APPLICATION', 'Standard value field that can be used by projects' FROM DUAL 
UNION 
 SELECT 'VALUE_1', 'REVN_CASCADE_LOG', '1000', '/EC', 'LABEL', 'APPLICATION', 'Value 1' FROM DUAL 
UNION 
 SELECT 'VALUE_1', 'REVN_CASCADE_LOG', '1000', '/EC', 'NAME', 'APPLICATION', 'Value 1' FROM DUAL 
UNION 
 SELECT 'VALUE_1', 'REVN_CASCADE_LOG', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '900' FROM DUAL 
UNION 
 SELECT 'VALUE_1', 'REVN_CASCADE_LOG', '1000', '/EC', 'viewhidden', 'STATIC_PRESENTATION', 'true' FROM DUAL 
UNION 
 SELECT 'VALUE_1', 'REVN_CASCADE_LOG', '1000', '/EC', 'viewwidth', 'STATIC_PRESENTATION', '300' FROM DUAL 
UNION 
 SELECT 'VALUE_1', 'REVN_COST_MAP_LOG', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '110' FROM DUAL 
UNION 
 SELECT 'VALUE_1', 'REVN_COST_MAP_LOG', '1000', '/', 'DISABLED_IND', 'VIEWLAYER', 'N' FROM DUAL 
UNION 
 SELECT 'VALUE_1', 'REVN_COST_MAP_LOG', '1000', '/', 'IS_MANDATORY', 'VIEWLAYER', 'N' FROM DUAL 
UNION 
 SELECT 'VALUE_1', 'REVN_COST_MAP_LOG', '1000', '/EC', 'DESCRIPTION', 'APPLICATION', 'Standard value field that can be used by projects' FROM DUAL 
UNION 
 SELECT 'VALUE_1', 'REVN_COST_MAP_LOG', '1000', '/EC', 'LABEL', 'APPLICATION', 'Value 1' FROM DUAL 
UNION 
 SELECT 'VALUE_1', 'REVN_COST_MAP_LOG', '1000', '/EC', 'NAME', 'APPLICATION', 'Value 1' FROM DUAL 
UNION 
 SELECT 'VALUE_1', 'REVN_COST_MAP_LOG', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '110' FROM DUAL 
UNION 
 SELECT 'VALUE_1', 'REVN_COST_MAP_LOG', '1000', '/EC', 'viewhidden', 'STATIC_PRESENTATION', 'true' FROM DUAL 
UNION 
 SELECT 'VALUE_1', 'REVN_COST_MAP_LOG', '1000', '/EC', 'viewwidth', 'STATIC_PRESENTATION', '47' FROM DUAL 
UNION 
 SELECT 'VALUE_1', 'REVN_ERP_DG_LOG', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '900' FROM DUAL 
UNION 
 SELECT 'VALUE_1', 'REVN_ERP_DG_LOG', '1000', '/', 'DISABLED_IND', 'VIEWLAYER', 'N' FROM DUAL 
UNION 
 SELECT 'VALUE_1', 'REVN_ERP_DG_LOG', '1000', '/', 'IS_MANDATORY', 'VIEWLAYER', 'N' FROM DUAL 
UNION 
 SELECT 'VALUE_1', 'REVN_ERP_DG_LOG', '1000', '/EC', 'DESCRIPTION', 'APPLICATION', 'Standard value field that can be used by projects' FROM DUAL 
UNION 
 SELECT 'VALUE_1', 'REVN_ERP_DG_LOG', '1000', '/EC', 'LABEL', 'APPLICATION', 'Value 1' FROM DUAL 
UNION 
 SELECT 'VALUE_1', 'REVN_ERP_DG_LOG', '1000', '/EC', 'NAME', 'APPLICATION', 'Value 1' FROM DUAL 
UNION 
 SELECT 'VALUE_1', 'REVN_ERP_DG_LOG', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '900' FROM DUAL 
UNION 
 SELECT 'VALUE_1', 'REVN_ERP_DG_LOG', '1000', '/EC', 'viewhidden', 'STATIC_PRESENTATION', 'true' FROM DUAL 
UNION 
 SELECT 'VALUE_1', 'REVN_ERP_DG_LOG', '1000', '/EC', 'viewwidth', 'STATIC_PRESENTATION', '47' FROM DUAL 
UNION 
 SELECT 'VALUE_1', 'REVN_INTERFACE_LOG', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '900' FROM DUAL 
UNION 
 SELECT 'VALUE_1', 'REVN_INTERFACE_LOG', '1000', '/', 'DISABLED_IND', 'VIEWLAYER', 'N' FROM DUAL 
UNION 
 SELECT 'VALUE_1', 'REVN_INTERFACE_LOG', '1000', '/', 'IS_MANDATORY', 'VIEWLAYER', 'N' FROM DUAL 
UNION 
 SELECT 'VALUE_1', 'REVN_INTERFACE_LOG', '1000', '/EC', 'DESCRIPTION', 'APPLICATION', 'Standard value field that can be used by projects' FROM DUAL 
UNION 
 SELECT 'VALUE_1', 'REVN_INTERFACE_LOG', '1000', '/EC', 'LABEL', 'APPLICATION', 'Source Entry No' FROM DUAL 
UNION 
 SELECT 'VALUE_1', 'REVN_INTERFACE_LOG', '1000', '/EC', 'NAME', 'APPLICATION', 'Source Entry No' FROM DUAL 
UNION 
 SELECT 'VALUE_1', 'REVN_INTERFACE_LOG', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '900' FROM DUAL 
UNION 
 SELECT 'VALUE_1', 'REVN_INTERFACE_LOG', '1000', '/EC', 'sortheader', 'STATIC_PRESENTATION', 'true' FROM DUAL 
UNION 
 SELECT 'VALUE_1', 'REVN_INTERFACE_LOG', '1000', '/EC', 'vieweditable', 'STATIC_PRESENTATION', 'false' FROM DUAL 
UNION 
 SELECT 'VALUE_1', 'REVN_INTERFACE_LOG', '1000', '/EC', 'viewtype', 'STATIC_PRESENTATION', 'label' FROM DUAL 
UNION 
 SELECT 'VALUE_1', 'REVN_INTERFACE_LOG', '1000', '/EC', 'viewwidth', 'STATIC_PRESENTATION', '300' FROM DUAL 
UNION 
 SELECT 'VALUE_1', 'REVN_PERIOD_DG_LOG', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '900' FROM DUAL 
UNION 
 SELECT 'VALUE_1', 'REVN_PERIOD_DG_LOG', '1000', '/', 'DISABLED_IND', 'VIEWLAYER', 'N' FROM DUAL 
UNION 
 SELECT 'VALUE_1', 'REVN_PERIOD_DG_LOG', '1000', '/', 'IS_MANDATORY', 'VIEWLAYER', 'N' FROM DUAL 
UNION 
 SELECT 'VALUE_1', 'REVN_PERIOD_DG_LOG', '1000', '/EC', 'DESCRIPTION', 'APPLICATION', 'Standard value field that can be used by projects' FROM DUAL 
UNION 
 SELECT 'VALUE_1', 'REVN_PERIOD_DG_LOG', '1000', '/EC', 'LABEL', 'APPLICATION', 'Value 1' FROM DUAL 
UNION 
 SELECT 'VALUE_1', 'REVN_PERIOD_DG_LOG', '1000', '/EC', 'NAME', 'APPLICATION', 'Value 1' FROM DUAL 
UNION 
 SELECT 'VALUE_1', 'REVN_PERIOD_DG_LOG', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '900' FROM DUAL 
UNION 
 SELECT 'VALUE_1', 'REVN_PERIOD_DG_LOG', '1000', '/EC', 'viewhidden', 'STATIC_PRESENTATION', 'true' FROM DUAL 
UNION 
 SELECT 'VALUE_1', 'REVN_PERIOD_DG_LOG', '1000', '/EC', 'viewwidth', 'STATIC_PRESENTATION', '300' FROM DUAL 
UNION 
 SELECT 'VALUE_1', 'REVN_REVERSE_DG_LOG', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '900' FROM DUAL 
UNION 
 SELECT 'VALUE_1', 'REVN_REVERSE_DG_LOG', '1000', '/', 'DISABLED_IND', 'VIEWLAYER', 'N' FROM DUAL 
UNION 
 SELECT 'VALUE_1', 'REVN_REVERSE_DG_LOG', '1000', '/', 'IS_MANDATORY', 'VIEWLAYER', 'N' FROM DUAL 
UNION 
 SELECT 'VALUE_1', 'REVN_REVERSE_DG_LOG', '1000', '/EC', 'DESCRIPTION', 'APPLICATION', 'Standard value field that can be used by projects' FROM DUAL 
UNION 
 SELECT 'VALUE_1', 'REVN_REVERSE_DG_LOG', '1000', '/EC', 'LABEL', 'APPLICATION', 'Value 1' FROM DUAL 
UNION 
 SELECT 'VALUE_1', 'REVN_REVERSE_DG_LOG', '1000', '/EC', 'NAME', 'APPLICATION', 'Value 1' FROM DUAL 
UNION 
 SELECT 'VALUE_1', 'REVN_REVERSE_DG_LOG', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '900' FROM DUAL 
UNION 
 SELECT 'VALUE_1', 'REVN_REVERSE_DG_LOG', '1000', '/EC', 'viewhidden', 'STATIC_PRESENTATION', 'true' FROM DUAL 
UNION 
 SELECT 'VALUE_1', 'REVN_REVERSE_DG_LOG', '1000', '/EC', 'viewwidth', 'STATIC_PRESENTATION', '47' FROM DUAL 
UNION 
 SELECT 'VALUE_1', 'REVN_SUMMARY_PC_LOG', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '130' FROM DUAL 
UNION 
 SELECT 'VALUE_1', 'REVN_SUMMARY_PC_LOG', '1000', '/', 'DISABLED_IND', 'VIEWLAYER', 'N' FROM DUAL 
UNION 
 SELECT 'VALUE_1', 'REVN_SUMMARY_PC_LOG', '1000', '/', 'IS_MANDATORY', 'VIEWLAYER', 'N' FROM DUAL 
UNION 
 SELECT 'VALUE_1', 'REVN_SUMMARY_PC_LOG', '1000', '/EC', 'DESCRIPTION', 'APPLICATION', 'Standard value field that can be used by projects' FROM DUAL 
UNION 
 SELECT 'VALUE_1', 'REVN_SUMMARY_PC_LOG', '1000', '/EC', 'LABEL', 'APPLICATION', 'Value 1' FROM DUAL 
UNION 
 SELECT 'VALUE_1', 'REVN_SUMMARY_PC_LOG', '1000', '/EC', 'NAME', 'APPLICATION', 'Value 1' FROM DUAL 
UNION 
 SELECT 'VALUE_1', 'REVN_SUMMARY_PC_LOG', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '130' FROM DUAL 
UNION 
 SELECT 'VALUE_1', 'REVN_SUMMARY_PC_LOG', '1000', '/EC', 'viewhidden', 'STATIC_PRESENTATION', 'true' FROM DUAL 
UNION 
 SELECT 'VALUE_1', 'REVN_SUMMARY_PC_LOG', '1000', '/EC', 'viewwidth', 'STATIC_PRESENTATION', '47' FROM DUAL 
UNION 
 SELECT 'VALUE_1', 'REVN_TI_LOG', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '900' FROM DUAL 
UNION 
 SELECT 'VALUE_1', 'REVN_TI_LOG', '1000', '/', 'DISABLED_IND', 'VIEWLAYER', 'N' FROM DUAL 
UNION 
 SELECT 'VALUE_1', 'REVN_TI_LOG', '1000', '/', 'IS_MANDATORY', 'VIEWLAYER', 'N' FROM DUAL 
UNION 
 SELECT 'VALUE_1', 'REVN_TI_LOG', '1000', '/EC', 'DESCRIPTION', 'APPLICATION', 'Standard value field that can be used by projects' FROM DUAL 
UNION 
 SELECT 'VALUE_1', 'REVN_TI_LOG', '1000', '/EC', 'LABEL', 'APPLICATION', 'Value 1' FROM DUAL 
UNION 
 SELECT 'VALUE_1', 'REVN_TI_LOG', '1000', '/EC', 'NAME', 'APPLICATION', 'Value 1' FROM DUAL 
UNION 
 SELECT 'VALUE_1', 'REVN_TI_LOG', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '900' FROM DUAL 
UNION 
 SELECT 'VALUE_1', 'REVN_TI_LOG', '1000', '/EC', 'viewhidden', 'STATIC_PRESENTATION', 'true' FROM DUAL 
UNION 
 SELECT 'VALUE_1', 'REVN_TI_LOG', '1000', '/EC', 'viewwidth', 'STATIC_PRESENTATION', '300' FROM DUAL 
UNION 
 SELECT 'VALUE_1', 'VAT_CUST_COUNTRY_SETUP', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '160' FROM DUAL 
UNION 
 SELECT 'VALUE_1', 'VAT_CUST_COUNTRY_SETUP', '1000', '/', 'DISABLED_IND', 'VIEWLAYER', 'Y' FROM DUAL 
UNION 
 SELECT 'VALUE_1', 'VAT_CUST_COUNTRY_SETUP', '1000', '/EC', 'DESCRIPTION', 'APPLICATION', 'Standard value field that can be used by projects' FROM DUAL 
UNION 
 SELECT 'VALUE_1', 'VAT_CUST_COUNTRY_SETUP', '1000', '/EC', 'LABEL', 'APPLICATION', 'Value 1' FROM DUAL 
UNION 
 SELECT 'VALUE_1', 'VAT_CUST_COUNTRY_SETUP', '1000', '/EC', 'NAME', 'APPLICATION', 'Value 1' FROM DUAL 
UNION 
 SELECT 'VALUE_1', 'VAT_CUST_COUNTRY_SETUP', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '160' FROM DUAL 
UNION 
 SELECT 'VALUE_1', 'VAT_CUST_COUNTRY_SETUP', '1000', '/EC', 'viewwidth', 'STATIC_PRESENTATION', '120' FROM DUAL 
UNION 
 SELECT 'VALUE_1', 'VAT_DEST_COUNTRY_SETUP', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '160' FROM DUAL 
UNION 
 SELECT 'VALUE_1', 'VAT_DEST_COUNTRY_SETUP', '1000', '/', 'DISABLED_IND', 'VIEWLAYER', 'Y' FROM DUAL 
UNION 
 SELECT 'VALUE_1', 'VAT_DEST_COUNTRY_SETUP', '1000', '/EC', 'DESCRIPTION', 'APPLICATION', 'Standard value field that can be used by projects' FROM DUAL 
UNION 
 SELECT 'VALUE_1', 'VAT_DEST_COUNTRY_SETUP', '1000', '/EC', 'LABEL', 'APPLICATION', 'Value 1' FROM DUAL 
UNION 
 SELECT 'VALUE_1', 'VAT_DEST_COUNTRY_SETUP', '1000', '/EC', 'NAME', 'APPLICATION', 'Value 1' FROM DUAL 
UNION 
 SELECT 'VALUE_1', 'VAT_DEST_COUNTRY_SETUP', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '160' FROM DUAL 
UNION 
 SELECT 'VALUE_1', 'VAT_DEST_COUNTRY_SETUP', '1000', '/EC', 'viewwidth', 'STATIC_PRESENTATION', '120' FROM DUAL 
UNION 
 SELECT 'VALUE_1', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '160' FROM DUAL 
UNION 
 SELECT 'VALUE_1', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/', 'DISABLED_IND', 'VIEWLAYER', 'Y' FROM DUAL 
UNION 
 SELECT 'VALUE_1', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/EC', 'DESCRIPTION', 'APPLICATION', 'Standard value field that can be used by projects' FROM DUAL 
UNION 
 SELECT 'VALUE_1', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/EC', 'LABEL', 'APPLICATION', 'Value 1' FROM DUAL 
UNION 
 SELECT 'VALUE_1', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/EC', 'NAME', 'APPLICATION', 'Value 1' FROM DUAL 
UNION 
 SELECT 'VALUE_1', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '160' FROM DUAL 
UNION 
 SELECT 'VALUE_1', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/EC', 'viewwidth', 'STATIC_PRESENTATION', '120' FROM DUAL 
UNION 
 SELECT 'VALUE_1', 'VAT_VEND_COUNTRY_SETUP', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '160' FROM DUAL 
UNION 
 SELECT 'VALUE_1', 'VAT_VEND_COUNTRY_SETUP', '1000', '/', 'DISABLED_IND', 'VIEWLAYER', 'Y' FROM DUAL 
UNION 
 SELECT 'VALUE_1', 'VAT_VEND_COUNTRY_SETUP', '1000', '/EC', 'DESCRIPTION', 'APPLICATION', 'Standard value field that can be used by projects' FROM DUAL 
UNION 
 SELECT 'VALUE_1', 'VAT_VEND_COUNTRY_SETUP', '1000', '/EC', 'LABEL', 'APPLICATION', 'Value 1' FROM DUAL 
UNION 
 SELECT 'VALUE_1', 'VAT_VEND_COUNTRY_SETUP', '1000', '/EC', 'NAME', 'APPLICATION', 'Value 1' FROM DUAL 
UNION 
 SELECT 'VALUE_1', 'VAT_VEND_COUNTRY_SETUP', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '160' FROM DUAL 
UNION 
 SELECT 'VALUE_1', 'VAT_VEND_COUNTRY_SETUP', '1000', '/EC', 'viewwidth', 'STATIC_PRESENTATION', '120' FROM DUAL 
UNION 
 SELECT 'VALUE_10', 'VAT_CUST_COUNTRY_SETUP', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '250' FROM DUAL 
UNION 
 SELECT 'VALUE_10', 'VAT_CUST_COUNTRY_SETUP', '1000', '/', 'DISABLED_IND', 'VIEWLAYER', 'Y' FROM DUAL 
UNION 
 SELECT 'VALUE_10', 'VAT_CUST_COUNTRY_SETUP', '1000', '/EC', 'DESCRIPTION', 'APPLICATION', 'Standard value field that can be used by projects' FROM DUAL 
UNION 
 SELECT 'VALUE_10', 'VAT_CUST_COUNTRY_SETUP', '1000', '/EC', 'LABEL', 'APPLICATION', 'Value 10' FROM DUAL 
UNION 
 SELECT 'VALUE_10', 'VAT_CUST_COUNTRY_SETUP', '1000', '/EC', 'NAME', 'APPLICATION', 'Value 10' FROM DUAL 
UNION 
 SELECT 'VALUE_10', 'VAT_CUST_COUNTRY_SETUP', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '250' FROM DUAL 
UNION 
 SELECT 'VALUE_10', 'VAT_CUST_COUNTRY_SETUP', '1000', '/EC', 'viewwidth', 'STATIC_PRESENTATION', '120' FROM DUAL 
UNION 
 SELECT 'VALUE_10', 'VAT_DEST_COUNTRY_SETUP', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '250' FROM DUAL 
UNION 
 SELECT 'VALUE_10', 'VAT_DEST_COUNTRY_SETUP', '1000', '/', 'DISABLED_IND', 'VIEWLAYER', 'Y' FROM DUAL 
UNION 
 SELECT 'VALUE_10', 'VAT_DEST_COUNTRY_SETUP', '1000', '/EC', 'DESCRIPTION', 'APPLICATION', 'Standard value field that can be used by projects' FROM DUAL 
UNION 
 SELECT 'VALUE_10', 'VAT_DEST_COUNTRY_SETUP', '1000', '/EC', 'LABEL', 'APPLICATION', 'Value 10' FROM DUAL 
UNION 
 SELECT 'VALUE_10', 'VAT_DEST_COUNTRY_SETUP', '1000', '/EC', 'NAME', 'APPLICATION', 'Value 10' FROM DUAL 
UNION 
 SELECT 'VALUE_10', 'VAT_DEST_COUNTRY_SETUP', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '250' FROM DUAL 
UNION 
 SELECT 'VALUE_10', 'VAT_DEST_COUNTRY_SETUP', '1000', '/EC', 'viewwidth', 'STATIC_PRESENTATION', '120' FROM DUAL 
UNION 
 SELECT 'VALUE_10', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '250' FROM DUAL 
UNION 
 SELECT 'VALUE_10', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/', 'DISABLED_IND', 'VIEWLAYER', 'Y' FROM DUAL 
UNION 
 SELECT 'VALUE_10', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/EC', 'DESCRIPTION', 'APPLICATION', 'Standard value field that can be used by projects' FROM DUAL
) n
ON (o.ATTRIBUTE_NAME = n.ATTRIBUTE_NAME
 AND o.CLASS_NAME = n.CLASS_NAME
 AND o.OWNER_CNTX = n.OWNER_CNTX
 AND o.PRESENTATION_CNTX = n.PRESENTATION_CNTX
 AND o.PROPERTY_CODE = n.PROPERTY_CODE
 AND o.PROPERTY_TYPE = n.PROPERTY_TYPE)
WHEN MATCHED THEN UPDATE SET
o.PROPERTY_VALUE = n.PROPERTY_VALUE
,o.LAST_UPDATED_BY = 'UPGD-TOOL-12.0-DM'
,o.REV_NO = o.REV_NO+1
WHEN NOT MATCHED THEN INSERT
(ATTRIBUTE_NAME,CLASS_NAME,OWNER_CNTX,PRESENTATION_CNTX,PROPERTY_CODE,PROPERTY_TYPE,PROPERTY_VALUE,CREATED_BY)
VALUES( n.ATTRIBUTE_NAME, n.CLASS_NAME, n.OWNER_CNTX, n.PRESENTATION_CNTX, n.PROPERTY_CODE, n.PROPERTY_TYPE, n.PROPERTY_VALUE,'UPGD-TOOL-12.0-DM');


MERGE INTO CLASS_ATTR_PROPERTY_CNFG o USING 
(
SELECT
 null ATTRIBUTE_NAME, null CLASS_NAME, null OWNER_CNTX, null PRESENTATION_CNTX, null PROPERTY_CODE, null PROPERTY_TYPE, null PROPERTY_VALUE FROM DUAL WHERE 1=0
UNION 
 SELECT 'VALUE_10', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/EC', 'LABEL', 'APPLICATION', 'Value 10' FROM DUAL 
UNION 
 SELECT 'VALUE_10', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/EC', 'NAME', 'APPLICATION', 'Value 10' FROM DUAL 
UNION 
 SELECT 'VALUE_10', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '250' FROM DUAL 
UNION 
 SELECT 'VALUE_10', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/EC', 'viewwidth', 'STATIC_PRESENTATION', '120' FROM DUAL 
UNION 
 SELECT 'VALUE_10', 'VAT_VEND_COUNTRY_SETUP', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '250' FROM DUAL 
UNION 
 SELECT 'VALUE_10', 'VAT_VEND_COUNTRY_SETUP', '1000', '/', 'DISABLED_IND', 'VIEWLAYER', 'Y' FROM DUAL 
UNION 
 SELECT 'VALUE_10', 'VAT_VEND_COUNTRY_SETUP', '1000', '/EC', 'DESCRIPTION', 'APPLICATION', 'Standard value field that can be used by projects' FROM DUAL 
UNION 
 SELECT 'VALUE_10', 'VAT_VEND_COUNTRY_SETUP', '1000', '/EC', 'LABEL', 'APPLICATION', 'Value 10' FROM DUAL 
UNION 
 SELECT 'VALUE_10', 'VAT_VEND_COUNTRY_SETUP', '1000', '/EC', 'NAME', 'APPLICATION', 'Value 10' FROM DUAL 
UNION 
 SELECT 'VALUE_10', 'VAT_VEND_COUNTRY_SETUP', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '250' FROM DUAL 
UNION 
 SELECT 'VALUE_10', 'VAT_VEND_COUNTRY_SETUP', '1000', '/EC', 'viewwidth', 'STATIC_PRESENTATION', '120' FROM DUAL 
UNION 
 SELECT 'VALUE_2', 'OBJECT_CALC_COMPONENT', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '700' FROM DUAL 
UNION 
 SELECT 'VALUE_2', 'OBJECT_CALC_COMPONENT', '1000', '/EC', 'LABEL', 'APPLICATION', 'Value Column 2' FROM DUAL 
UNION 
 SELECT 'VALUE_2', 'OBJECT_CALC_COMPONENT', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '700' FROM DUAL 
UNION 
 SELECT 'VALUE_2', 'VAT_CUST_COUNTRY_SETUP', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '170' FROM DUAL 
UNION 
 SELECT 'VALUE_2', 'VAT_CUST_COUNTRY_SETUP', '1000', '/', 'DISABLED_IND', 'VIEWLAYER', 'Y' FROM DUAL 
UNION 
 SELECT 'VALUE_2', 'VAT_CUST_COUNTRY_SETUP', '1000', '/EC', 'DESCRIPTION', 'APPLICATION', 'Standard value field that can be used by projects' FROM DUAL 
UNION 
 SELECT 'VALUE_2', 'VAT_CUST_COUNTRY_SETUP', '1000', '/EC', 'LABEL', 'APPLICATION', 'Value 2' FROM DUAL 
UNION 
 SELECT 'VALUE_2', 'VAT_CUST_COUNTRY_SETUP', '1000', '/EC', 'NAME', 'APPLICATION', 'Value 2' FROM DUAL 
UNION 
 SELECT 'VALUE_2', 'VAT_CUST_COUNTRY_SETUP', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '170' FROM DUAL 
UNION 
 SELECT 'VALUE_2', 'VAT_CUST_COUNTRY_SETUP', '1000', '/EC', 'viewwidth', 'STATIC_PRESENTATION', '120' FROM DUAL 
UNION 
 SELECT 'VALUE_2', 'VAT_DEST_COUNTRY_SETUP', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '170' FROM DUAL 
UNION 
 SELECT 'VALUE_2', 'VAT_DEST_COUNTRY_SETUP', '1000', '/', 'DISABLED_IND', 'VIEWLAYER', 'Y' FROM DUAL 
UNION 
 SELECT 'VALUE_2', 'VAT_DEST_COUNTRY_SETUP', '1000', '/EC', 'DESCRIPTION', 'APPLICATION', 'Standard value field that can be used by projects' FROM DUAL 
UNION 
 SELECT 'VALUE_2', 'VAT_DEST_COUNTRY_SETUP', '1000', '/EC', 'LABEL', 'APPLICATION', 'Value 2' FROM DUAL 
UNION 
 SELECT 'VALUE_2', 'VAT_DEST_COUNTRY_SETUP', '1000', '/EC', 'NAME', 'APPLICATION', 'Value 2' FROM DUAL 
UNION 
 SELECT 'VALUE_2', 'VAT_DEST_COUNTRY_SETUP', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '170' FROM DUAL 
UNION 
 SELECT 'VALUE_2', 'VAT_DEST_COUNTRY_SETUP', '1000', '/EC', 'viewwidth', 'STATIC_PRESENTATION', '120' FROM DUAL 
UNION 
 SELECT 'VALUE_2', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '170' FROM DUAL 
UNION 
 SELECT 'VALUE_2', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/', 'DISABLED_IND', 'VIEWLAYER', 'Y' FROM DUAL 
UNION 
 SELECT 'VALUE_2', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/EC', 'DESCRIPTION', 'APPLICATION', 'Standard value field that can be used by projects' FROM DUAL 
UNION 
 SELECT 'VALUE_2', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/EC', 'LABEL', 'APPLICATION', 'Value 2' FROM DUAL 
UNION 
 SELECT 'VALUE_2', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/EC', 'NAME', 'APPLICATION', 'Value 2' FROM DUAL 
UNION 
 SELECT 'VALUE_2', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '170' FROM DUAL 
UNION 
 SELECT 'VALUE_2', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/EC', 'viewwidth', 'STATIC_PRESENTATION', '120' FROM DUAL 
UNION 
 SELECT 'VALUE_2', 'VAT_VEND_COUNTRY_SETUP', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '170' FROM DUAL 
UNION 
 SELECT 'VALUE_2', 'VAT_VEND_COUNTRY_SETUP', '1000', '/', 'DISABLED_IND', 'VIEWLAYER', 'Y' FROM DUAL 
UNION 
 SELECT 'VALUE_2', 'VAT_VEND_COUNTRY_SETUP', '1000', '/EC', 'DESCRIPTION', 'APPLICATION', 'Standard value field that can be used by projects' FROM DUAL 
UNION 
 SELECT 'VALUE_2', 'VAT_VEND_COUNTRY_SETUP', '1000', '/EC', 'LABEL', 'APPLICATION', 'Value 2' FROM DUAL 
UNION 
 SELECT 'VALUE_2', 'VAT_VEND_COUNTRY_SETUP', '1000', '/EC', 'NAME', 'APPLICATION', 'Value 2' FROM DUAL 
UNION 
 SELECT 'VALUE_2', 'VAT_VEND_COUNTRY_SETUP', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '170' FROM DUAL 
UNION 
 SELECT 'VALUE_2', 'VAT_VEND_COUNTRY_SETUP', '1000', '/EC', 'viewwidth', 'STATIC_PRESENTATION', '120' FROM DUAL 
UNION 
 SELECT 'VALUE_3', 'OBJECT_CALC_COMPONENT', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '800' FROM DUAL 
UNION 
 SELECT 'VALUE_3', 'OBJECT_CALC_COMPONENT', '1000', '/EC', 'LABEL', 'APPLICATION', 'Value Column 3' FROM DUAL 
UNION 
 SELECT 'VALUE_3', 'OBJECT_CALC_COMPONENT', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '800' FROM DUAL 
UNION 
 SELECT 'VALUE_3', 'VAT_CUST_COUNTRY_SETUP', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '180' FROM DUAL 
UNION 
 SELECT 'VALUE_3', 'VAT_CUST_COUNTRY_SETUP', '1000', '/', 'DISABLED_IND', 'VIEWLAYER', 'Y' FROM DUAL 
UNION 
 SELECT 'VALUE_3', 'VAT_CUST_COUNTRY_SETUP', '1000', '/EC', 'DESCRIPTION', 'APPLICATION', 'Standard value field that can be used by projects' FROM DUAL 
UNION 
 SELECT 'VALUE_3', 'VAT_CUST_COUNTRY_SETUP', '1000', '/EC', 'LABEL', 'APPLICATION', 'Value 3' FROM DUAL 
UNION 
 SELECT 'VALUE_3', 'VAT_CUST_COUNTRY_SETUP', '1000', '/EC', 'NAME', 'APPLICATION', 'Value 3' FROM DUAL 
UNION 
 SELECT 'VALUE_3', 'VAT_CUST_COUNTRY_SETUP', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '180' FROM DUAL 
UNION 
 SELECT 'VALUE_3', 'VAT_CUST_COUNTRY_SETUP', '1000', '/EC', 'viewwidth', 'STATIC_PRESENTATION', '120' FROM DUAL 
UNION 
 SELECT 'VALUE_3', 'VAT_DEST_COUNTRY_SETUP', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '180' FROM DUAL 
UNION 
 SELECT 'VALUE_3', 'VAT_DEST_COUNTRY_SETUP', '1000', '/', 'DISABLED_IND', 'VIEWLAYER', 'Y' FROM DUAL 
UNION 
 SELECT 'VALUE_3', 'VAT_DEST_COUNTRY_SETUP', '1000', '/EC', 'DESCRIPTION', 'APPLICATION', 'Standard value field that can be used by projects' FROM DUAL 
UNION 
 SELECT 'VALUE_3', 'VAT_DEST_COUNTRY_SETUP', '1000', '/EC', 'LABEL', 'APPLICATION', 'Value 3' FROM DUAL 
UNION 
 SELECT 'VALUE_3', 'VAT_DEST_COUNTRY_SETUP', '1000', '/EC', 'NAME', 'APPLICATION', 'Value 3' FROM DUAL 
UNION 
 SELECT 'VALUE_3', 'VAT_DEST_COUNTRY_SETUP', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '180' FROM DUAL 
UNION 
 SELECT 'VALUE_3', 'VAT_DEST_COUNTRY_SETUP', '1000', '/EC', 'viewwidth', 'STATIC_PRESENTATION', '120' FROM DUAL 
UNION 
 SELECT 'VALUE_3', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '180' FROM DUAL 
UNION 
 SELECT 'VALUE_3', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/', 'DISABLED_IND', 'VIEWLAYER', 'Y' FROM DUAL 
UNION 
 SELECT 'VALUE_3', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/EC', 'DESCRIPTION', 'APPLICATION', 'Standard value field that can be used by projects' FROM DUAL 
UNION 
 SELECT 'VALUE_3', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/EC', 'LABEL', 'APPLICATION', 'Value 3' FROM DUAL 
UNION 
 SELECT 'VALUE_3', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/EC', 'NAME', 'APPLICATION', 'Value 3' FROM DUAL 
UNION 
 SELECT 'VALUE_3', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '180' FROM DUAL 
UNION 
 SELECT 'VALUE_3', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/EC', 'viewwidth', 'STATIC_PRESENTATION', '120' FROM DUAL 
UNION 
 SELECT 'VALUE_3', 'VAT_VEND_COUNTRY_SETUP', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '180' FROM DUAL 
UNION 
 SELECT 'VALUE_3', 'VAT_VEND_COUNTRY_SETUP', '1000', '/', 'DISABLED_IND', 'VIEWLAYER', 'Y' FROM DUAL 
UNION 
 SELECT 'VALUE_3', 'VAT_VEND_COUNTRY_SETUP', '1000', '/EC', 'DESCRIPTION', 'APPLICATION', 'Standard value field that can be used by projects' FROM DUAL 
UNION 
 SELECT 'VALUE_3', 'VAT_VEND_COUNTRY_SETUP', '1000', '/EC', 'LABEL', 'APPLICATION', 'Value 3' FROM DUAL 
UNION 
 SELECT 'VALUE_3', 'VAT_VEND_COUNTRY_SETUP', '1000', '/EC', 'NAME', 'APPLICATION', 'Value 3' FROM DUAL 
UNION 
 SELECT 'VALUE_3', 'VAT_VEND_COUNTRY_SETUP', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '180' FROM DUAL 
UNION 
 SELECT 'VALUE_3', 'VAT_VEND_COUNTRY_SETUP', '1000', '/EC', 'viewwidth', 'STATIC_PRESENTATION', '120' FROM DUAL 
UNION 
 SELECT 'VALUE_4', 'OBJECT_CALC_COMPONENT', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '900' FROM DUAL 
UNION 
 SELECT 'VALUE_4', 'OBJECT_CALC_COMPONENT', '1000', '/EC', 'LABEL', 'APPLICATION', 'Value Column 4' FROM DUAL 
UNION 
 SELECT 'VALUE_4', 'OBJECT_CALC_COMPONENT', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '900' FROM DUAL 
UNION 
 SELECT 'VALUE_4', 'VAT_CUST_COUNTRY_SETUP', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '190' FROM DUAL 
UNION 
 SELECT 'VALUE_4', 'VAT_CUST_COUNTRY_SETUP', '1000', '/', 'DISABLED_IND', 'VIEWLAYER', 'Y' FROM DUAL 
UNION 
 SELECT 'VALUE_4', 'VAT_CUST_COUNTRY_SETUP', '1000', '/EC', 'DESCRIPTION', 'APPLICATION', 'Standard value field that can be used by projects' FROM DUAL 
UNION 
 SELECT 'VALUE_4', 'VAT_CUST_COUNTRY_SETUP', '1000', '/EC', 'LABEL', 'APPLICATION', 'Value 4' FROM DUAL 
UNION 
 SELECT 'VALUE_4', 'VAT_CUST_COUNTRY_SETUP', '1000', '/EC', 'NAME', 'APPLICATION', 'Value 4' FROM DUAL 
UNION 
 SELECT 'VALUE_4', 'VAT_CUST_COUNTRY_SETUP', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '190' FROM DUAL 
UNION 
 SELECT 'VALUE_4', 'VAT_CUST_COUNTRY_SETUP', '1000', '/EC', 'viewwidth', 'STATIC_PRESENTATION', '120' FROM DUAL 
UNION 
 SELECT 'VALUE_4', 'VAT_DEST_COUNTRY_SETUP', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '190' FROM DUAL 
UNION 
 SELECT 'VALUE_4', 'VAT_DEST_COUNTRY_SETUP', '1000', '/', 'DISABLED_IND', 'VIEWLAYER', 'Y' FROM DUAL 
UNION 
 SELECT 'VALUE_4', 'VAT_DEST_COUNTRY_SETUP', '1000', '/EC', 'DESCRIPTION', 'APPLICATION', 'Standard value field that can be used by projects' FROM DUAL 
UNION 
 SELECT 'VALUE_4', 'VAT_DEST_COUNTRY_SETUP', '1000', '/EC', 'LABEL', 'APPLICATION', 'Value 4' FROM DUAL 
UNION 
 SELECT 'VALUE_4', 'VAT_DEST_COUNTRY_SETUP', '1000', '/EC', 'NAME', 'APPLICATION', 'Value 4' FROM DUAL 
UNION 
 SELECT 'VALUE_4', 'VAT_DEST_COUNTRY_SETUP', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '190' FROM DUAL 
UNION 
 SELECT 'VALUE_4', 'VAT_DEST_COUNTRY_SETUP', '1000', '/EC', 'viewwidth', 'STATIC_PRESENTATION', '120' FROM DUAL 
UNION 
 SELECT 'VALUE_4', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '190' FROM DUAL 
UNION 
 SELECT 'VALUE_4', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/', 'DISABLED_IND', 'VIEWLAYER', 'Y' FROM DUAL 
UNION 
 SELECT 'VALUE_4', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/EC', 'DESCRIPTION', 'APPLICATION', 'Standard value field that can be used by projects' FROM DUAL 
UNION 
 SELECT 'VALUE_4', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/EC', 'LABEL', 'APPLICATION', 'Value 4' FROM DUAL 
UNION 
 SELECT 'VALUE_4', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/EC', 'NAME', 'APPLICATION', 'Value 4' FROM DUAL 
UNION 
 SELECT 'VALUE_4', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '190' FROM DUAL 
UNION 
 SELECT 'VALUE_4', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/EC', 'viewwidth', 'STATIC_PRESENTATION', '120' FROM DUAL 
UNION 
 SELECT 'VALUE_4', 'VAT_VEND_COUNTRY_SETUP', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '190' FROM DUAL 
UNION 
 SELECT 'VALUE_4', 'VAT_VEND_COUNTRY_SETUP', '1000', '/', 'DISABLED_IND', 'VIEWLAYER', 'Y' FROM DUAL 
UNION 
 SELECT 'VALUE_4', 'VAT_VEND_COUNTRY_SETUP', '1000', '/EC', 'DESCRIPTION', 'APPLICATION', 'Standard value field that can be used by projects' FROM DUAL 
UNION 
 SELECT 'VALUE_4', 'VAT_VEND_COUNTRY_SETUP', '1000', '/EC', 'LABEL', 'APPLICATION', 'Value 4' FROM DUAL 
UNION 
 SELECT 'VALUE_4', 'VAT_VEND_COUNTRY_SETUP', '1000', '/EC', 'NAME', 'APPLICATION', 'Value 4' FROM DUAL 
UNION 
 SELECT 'VALUE_4', 'VAT_VEND_COUNTRY_SETUP', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '190' FROM DUAL 
UNION 
 SELECT 'VALUE_4', 'VAT_VEND_COUNTRY_SETUP', '1000', '/EC', 'viewwidth', 'STATIC_PRESENTATION', '120' FROM DUAL 
UNION 
 SELECT 'VALUE_5', 'OBJECT_CALC_COMPONENT', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '1000' FROM DUAL 
UNION 
 SELECT 'VALUE_5', 'OBJECT_CALC_COMPONENT', '1000', '/EC', 'LABEL', 'APPLICATION', 'Value Column 5' FROM DUAL 
UNION 
 SELECT 'VALUE_5', 'OBJECT_CALC_COMPONENT', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '1000' FROM DUAL 
UNION 
 SELECT 'VALUE_5', 'VAT_CUST_COUNTRY_SETUP', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '200' FROM DUAL 
UNION 
 SELECT 'VALUE_5', 'VAT_CUST_COUNTRY_SETUP', '1000', '/', 'DISABLED_IND', 'VIEWLAYER', 'Y' FROM DUAL 
UNION 
 SELECT 'VALUE_5', 'VAT_CUST_COUNTRY_SETUP', '1000', '/EC', 'DESCRIPTION', 'APPLICATION', 'Standard value field that can be used by projects' FROM DUAL 
UNION 
 SELECT 'VALUE_5', 'VAT_CUST_COUNTRY_SETUP', '1000', '/EC', 'LABEL', 'APPLICATION', 'Value 5' FROM DUAL 
UNION 
 SELECT 'VALUE_5', 'VAT_CUST_COUNTRY_SETUP', '1000', '/EC', 'NAME', 'APPLICATION', 'Value 5' FROM DUAL 
UNION 
 SELECT 'VALUE_5', 'VAT_CUST_COUNTRY_SETUP', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '200' FROM DUAL 
UNION 
 SELECT 'VALUE_5', 'VAT_CUST_COUNTRY_SETUP', '1000', '/EC', 'viewwidth', 'STATIC_PRESENTATION', '120' FROM DUAL 
UNION 
 SELECT 'VALUE_5', 'VAT_DEST_COUNTRY_SETUP', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '200' FROM DUAL 
UNION 
 SELECT 'VALUE_5', 'VAT_DEST_COUNTRY_SETUP', '1000', '/', 'DISABLED_IND', 'VIEWLAYER', 'Y' FROM DUAL 
UNION 
 SELECT 'VALUE_5', 'VAT_DEST_COUNTRY_SETUP', '1000', '/EC', 'DESCRIPTION', 'APPLICATION', 'Standard value field that can be used by projects' FROM DUAL 
UNION 
 SELECT 'VALUE_5', 'VAT_DEST_COUNTRY_SETUP', '1000', '/EC', 'LABEL', 'APPLICATION', 'Value 5' FROM DUAL 
UNION 
 SELECT 'VALUE_5', 'VAT_DEST_COUNTRY_SETUP', '1000', '/EC', 'NAME', 'APPLICATION', 'Value 5' FROM DUAL 
UNION 
 SELECT 'VALUE_5', 'VAT_DEST_COUNTRY_SETUP', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '200' FROM DUAL 
UNION 
 SELECT 'VALUE_5', 'VAT_DEST_COUNTRY_SETUP', '1000', '/EC', 'viewwidth', 'STATIC_PRESENTATION', '120' FROM DUAL 
UNION 
 SELECT 'VALUE_5', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '200' FROM DUAL 
UNION 
 SELECT 'VALUE_5', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/', 'DISABLED_IND', 'VIEWLAYER', 'Y' FROM DUAL 
UNION 
 SELECT 'VALUE_5', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/EC', 'DESCRIPTION', 'APPLICATION', 'Standard value field that can be used by projects' FROM DUAL 
UNION 
 SELECT 'VALUE_5', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/EC', 'LABEL', 'APPLICATION', 'Value 5' FROM DUAL 
UNION 
 SELECT 'VALUE_5', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/EC', 'NAME', 'APPLICATION', 'Value 5' FROM DUAL 
UNION 
 SELECT 'VALUE_5', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '200' FROM DUAL 
UNION 
 SELECT 'VALUE_5', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/EC', 'viewwidth', 'STATIC_PRESENTATION', '120' FROM DUAL 
UNION 
 SELECT 'VALUE_5', 'VAT_VEND_COUNTRY_SETUP', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '200' FROM DUAL 
UNION 
 SELECT 'VALUE_5', 'VAT_VEND_COUNTRY_SETUP', '1000', '/', 'DISABLED_IND', 'VIEWLAYER', 'Y' FROM DUAL 
UNION 
 SELECT 'VALUE_5', 'VAT_VEND_COUNTRY_SETUP', '1000', '/EC', 'DESCRIPTION', 'APPLICATION', 'Standard value field that can be used by projects' FROM DUAL 
UNION 
 SELECT 'VALUE_5', 'VAT_VEND_COUNTRY_SETUP', '1000', '/EC', 'LABEL', 'APPLICATION', 'Value 5' FROM DUAL 
UNION 
 SELECT 'VALUE_5', 'VAT_VEND_COUNTRY_SETUP', '1000', '/EC', 'NAME', 'APPLICATION', 'Value 5' FROM DUAL 
UNION 
 SELECT 'VALUE_5', 'VAT_VEND_COUNTRY_SETUP', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '200' FROM DUAL 
UNION 
 SELECT 'VALUE_5', 'VAT_VEND_COUNTRY_SETUP', '1000', '/EC', 'viewwidth', 'STATIC_PRESENTATION', '120' FROM DUAL 
UNION 
 SELECT 'VALUE_6', 'VAT_CUST_COUNTRY_SETUP', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '210' FROM DUAL 
UNION 
 SELECT 'VALUE_6', 'VAT_CUST_COUNTRY_SETUP', '1000', '/', 'DISABLED_IND', 'VIEWLAYER', 'Y' FROM DUAL 
UNION 
 SELECT 'VALUE_6', 'VAT_CUST_COUNTRY_SETUP', '1000', '/EC', 'DESCRIPTION', 'APPLICATION', 'Standard value field that can be used by projects' FROM DUAL 
UNION 
 SELECT 'VALUE_6', 'VAT_CUST_COUNTRY_SETUP', '1000', '/EC', 'LABEL', 'APPLICATION', 'Value 6' FROM DUAL 
UNION 
 SELECT 'VALUE_6', 'VAT_CUST_COUNTRY_SETUP', '1000', '/EC', 'NAME', 'APPLICATION', 'Value 6' FROM DUAL 
UNION 
 SELECT 'VALUE_6', 'VAT_CUST_COUNTRY_SETUP', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '210' FROM DUAL 
UNION 
 SELECT 'VALUE_6', 'VAT_CUST_COUNTRY_SETUP', '1000', '/EC', 'viewwidth', 'STATIC_PRESENTATION', '120' FROM DUAL 
UNION 
 SELECT 'VALUE_6', 'VAT_DEST_COUNTRY_SETUP', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '210' FROM DUAL 
UNION 
 SELECT 'VALUE_6', 'VAT_DEST_COUNTRY_SETUP', '1000', '/', 'DISABLED_IND', 'VIEWLAYER', 'Y' FROM DUAL 
UNION 
 SELECT 'VALUE_6', 'VAT_DEST_COUNTRY_SETUP', '1000', '/EC', 'DESCRIPTION', 'APPLICATION', 'Standard value field that can be used by projects' FROM DUAL 
UNION 
 SELECT 'VALUE_6', 'VAT_DEST_COUNTRY_SETUP', '1000', '/EC', 'LABEL', 'APPLICATION', 'Value 6' FROM DUAL 
UNION 
 SELECT 'VALUE_6', 'VAT_DEST_COUNTRY_SETUP', '1000', '/EC', 'NAME', 'APPLICATION', 'Value 6' FROM DUAL 
UNION 
 SELECT 'VALUE_6', 'VAT_DEST_COUNTRY_SETUP', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '210' FROM DUAL 
UNION 
 SELECT 'VALUE_6', 'VAT_DEST_COUNTRY_SETUP', '1000', '/EC', 'viewwidth', 'STATIC_PRESENTATION', '120' FROM DUAL 
UNION 
 SELECT 'VALUE_6', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '210' FROM DUAL 
UNION 
 SELECT 'VALUE_6', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/', 'DISABLED_IND', 'VIEWLAYER', 'Y' FROM DUAL 
UNION 
 SELECT 'VALUE_6', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/EC', 'DESCRIPTION', 'APPLICATION', 'Standard value field that can be used by projects' FROM DUAL 
UNION 
 SELECT 'VALUE_6', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/EC', 'LABEL', 'APPLICATION', 'Value 6' FROM DUAL 
UNION 
 SELECT 'VALUE_6', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/EC', 'NAME', 'APPLICATION', 'Value 6' FROM DUAL 
UNION 
 SELECT 'VALUE_6', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '210' FROM DUAL 
UNION 
 SELECT 'VALUE_6', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/EC', 'viewwidth', 'STATIC_PRESENTATION', '120' FROM DUAL 
UNION 
 SELECT 'VALUE_6', 'VAT_VEND_COUNTRY_SETUP', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '210' FROM DUAL 
UNION 
 SELECT 'VALUE_6', 'VAT_VEND_COUNTRY_SETUP', '1000', '/', 'DISABLED_IND', 'VIEWLAYER', 'Y' FROM DUAL 
UNION 
 SELECT 'VALUE_6', 'VAT_VEND_COUNTRY_SETUP', '1000', '/EC', 'DESCRIPTION', 'APPLICATION', 'Standard value field that can be used by projects' FROM DUAL 
UNION 
 SELECT 'VALUE_6', 'VAT_VEND_COUNTRY_SETUP', '1000', '/EC', 'LABEL', 'APPLICATION', 'Value 6' FROM DUAL 
UNION 
 SELECT 'VALUE_6', 'VAT_VEND_COUNTRY_SETUP', '1000', '/EC', 'NAME', 'APPLICATION', 'Value 6' FROM DUAL 
UNION 
 SELECT 'VALUE_6', 'VAT_VEND_COUNTRY_SETUP', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '210' FROM DUAL 
UNION 
 SELECT 'VALUE_6', 'VAT_VEND_COUNTRY_SETUP', '1000', '/EC', 'viewwidth', 'STATIC_PRESENTATION', '120' FROM DUAL 
UNION 
 SELECT 'VALUE_7', 'VAT_CUST_COUNTRY_SETUP', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '220' FROM DUAL 
UNION 
 SELECT 'VALUE_7', 'VAT_CUST_COUNTRY_SETUP', '1000', '/', 'DISABLED_IND', 'VIEWLAYER', 'Y' FROM DUAL 
UNION 
 SELECT 'VALUE_7', 'VAT_CUST_COUNTRY_SETUP', '1000', '/EC', 'DESCRIPTION', 'APPLICATION', 'Standard value field that can be used by projects' FROM DUAL 
UNION 
 SELECT 'VALUE_7', 'VAT_CUST_COUNTRY_SETUP', '1000', '/EC', 'LABEL', 'APPLICATION', 'Value 7' FROM DUAL 
UNION 
 SELECT 'VALUE_7', 'VAT_CUST_COUNTRY_SETUP', '1000', '/EC', 'NAME', 'APPLICATION', 'Value 7' FROM DUAL 
UNION 
 SELECT 'VALUE_7', 'VAT_CUST_COUNTRY_SETUP', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '220' FROM DUAL 
UNION 
 SELECT 'VALUE_7', 'VAT_CUST_COUNTRY_SETUP', '1000', '/EC', 'viewwidth', 'STATIC_PRESENTATION', '120' FROM DUAL 
UNION 
 SELECT 'VALUE_7', 'VAT_DEST_COUNTRY_SETUP', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '220' FROM DUAL 
UNION 
 SELECT 'VALUE_7', 'VAT_DEST_COUNTRY_SETUP', '1000', '/', 'DISABLED_IND', 'VIEWLAYER', 'Y' FROM DUAL 
UNION 
 SELECT 'VALUE_7', 'VAT_DEST_COUNTRY_SETUP', '1000', '/EC', 'DESCRIPTION', 'APPLICATION', 'Standard value field that can be used by projects' FROM DUAL 
UNION 
 SELECT 'VALUE_7', 'VAT_DEST_COUNTRY_SETUP', '1000', '/EC', 'LABEL', 'APPLICATION', 'Value 7' FROM DUAL 
UNION 
 SELECT 'VALUE_7', 'VAT_DEST_COUNTRY_SETUP', '1000', '/EC', 'NAME', 'APPLICATION', 'Value 7' FROM DUAL 
UNION 
 SELECT 'VALUE_7', 'VAT_DEST_COUNTRY_SETUP', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '220' FROM DUAL 
UNION 
 SELECT 'VALUE_7', 'VAT_DEST_COUNTRY_SETUP', '1000', '/EC', 'viewwidth', 'STATIC_PRESENTATION', '120' FROM DUAL 
UNION 
 SELECT 'VALUE_7', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '220' FROM DUAL 
UNION 
 SELECT 'VALUE_7', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/', 'DISABLED_IND', 'VIEWLAYER', 'Y' FROM DUAL 
UNION 
 SELECT 'VALUE_7', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/EC', 'DESCRIPTION', 'APPLICATION', 'Standard value field that can be used by projects' FROM DUAL 
UNION 
 SELECT 'VALUE_7', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/EC', 'LABEL', 'APPLICATION', 'Value 7' FROM DUAL 
UNION 
 SELECT 'VALUE_7', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/EC', 'NAME', 'APPLICATION', 'Value 7' FROM DUAL 
UNION 
 SELECT 'VALUE_7', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '220' FROM DUAL 
UNION 
 SELECT 'VALUE_7', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/EC', 'viewwidth', 'STATIC_PRESENTATION', '120' FROM DUAL 
UNION 
 SELECT 'VALUE_7', 'VAT_VEND_COUNTRY_SETUP', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '220' FROM DUAL 
UNION 
 SELECT 'VALUE_7', 'VAT_VEND_COUNTRY_SETUP', '1000', '/', 'DISABLED_IND', 'VIEWLAYER', 'Y' FROM DUAL 
UNION 
 SELECT 'VALUE_7', 'VAT_VEND_COUNTRY_SETUP', '1000', '/EC', 'DESCRIPTION', 'APPLICATION', 'Standard value field that can be used by projects' FROM DUAL 
UNION 
 SELECT 'VALUE_7', 'VAT_VEND_COUNTRY_SETUP', '1000', '/EC', 'LABEL', 'APPLICATION', 'Value 7' FROM DUAL 
UNION 
 SELECT 'VALUE_7', 'VAT_VEND_COUNTRY_SETUP', '1000', '/EC', 'NAME', 'APPLICATION', 'Value 7' FROM DUAL 
UNION 
 SELECT 'VALUE_7', 'VAT_VEND_COUNTRY_SETUP', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '220' FROM DUAL 
UNION 
 SELECT 'VALUE_7', 'VAT_VEND_COUNTRY_SETUP', '1000', '/EC', 'viewwidth', 'STATIC_PRESENTATION', '120' FROM DUAL 
UNION 
 SELECT 'VALUE_8', 'VAT_CUST_COUNTRY_SETUP', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '230' FROM DUAL 
UNION 
 SELECT 'VALUE_8', 'VAT_CUST_COUNTRY_SETUP', '1000', '/', 'DISABLED_IND', 'VIEWLAYER', 'Y' FROM DUAL 
UNION 
 SELECT 'VALUE_8', 'VAT_CUST_COUNTRY_SETUP', '1000', '/EC', 'DESCRIPTION', 'APPLICATION', 'Standard value field that can be used by projects' FROM DUAL 
UNION 
 SELECT 'VALUE_8', 'VAT_CUST_COUNTRY_SETUP', '1000', '/EC', 'LABEL', 'APPLICATION', 'Value 8' FROM DUAL 
UNION 
 SELECT 'VALUE_8', 'VAT_CUST_COUNTRY_SETUP', '1000', '/EC', 'NAME', 'APPLICATION', 'Value 8' FROM DUAL 
UNION 
 SELECT 'VALUE_8', 'VAT_CUST_COUNTRY_SETUP', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '230' FROM DUAL 
UNION 
 SELECT 'VALUE_8', 'VAT_CUST_COUNTRY_SETUP', '1000', '/EC', 'viewwidth', 'STATIC_PRESENTATION', '120' FROM DUAL 
UNION 
 SELECT 'VALUE_8', 'VAT_DEST_COUNTRY_SETUP', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '230' FROM DUAL 
UNION 
 SELECT 'VALUE_8', 'VAT_DEST_COUNTRY_SETUP', '1000', '/', 'DISABLED_IND', 'VIEWLAYER', 'Y' FROM DUAL 
UNION 
 SELECT 'VALUE_8', 'VAT_DEST_COUNTRY_SETUP', '1000', '/EC', 'DESCRIPTION', 'APPLICATION', 'Standard value field that can be used by projects' FROM DUAL 
UNION 
 SELECT 'VALUE_8', 'VAT_DEST_COUNTRY_SETUP', '1000', '/EC', 'LABEL', 'APPLICATION', 'Value 8' FROM DUAL 
UNION 
 SELECT 'VALUE_8', 'VAT_DEST_COUNTRY_SETUP', '1000', '/EC', 'NAME', 'APPLICATION', 'Value 8' FROM DUAL 
UNION 
 SELECT 'VALUE_8', 'VAT_DEST_COUNTRY_SETUP', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '230' FROM DUAL 
UNION 
 SELECT 'VALUE_8', 'VAT_DEST_COUNTRY_SETUP', '1000', '/EC', 'viewwidth', 'STATIC_PRESENTATION', '120' FROM DUAL 
UNION 
 SELECT 'VALUE_8', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '230' FROM DUAL 
UNION 
 SELECT 'VALUE_8', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/', 'DISABLED_IND', 'VIEWLAYER', 'Y' FROM DUAL 
UNION 
 SELECT 'VALUE_8', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/EC', 'DESCRIPTION', 'APPLICATION', 'Standard value field that can be used by projects' FROM DUAL 
UNION 
 SELECT 'VALUE_8', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/EC', 'LABEL', 'APPLICATION', 'Value 8' FROM DUAL 
UNION 
 SELECT 'VALUE_8', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/EC', 'NAME', 'APPLICATION', 'Value 8' FROM DUAL 
UNION 
 SELECT 'VALUE_8', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '230' FROM DUAL 
UNION 
 SELECT 'VALUE_8', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/EC', 'viewwidth', 'STATIC_PRESENTATION', '120' FROM DUAL 
UNION 
 SELECT 'VALUE_8', 'VAT_VEND_COUNTRY_SETUP', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '230' FROM DUAL 
UNION 
 SELECT 'VALUE_8', 'VAT_VEND_COUNTRY_SETUP', '1000', '/', 'DISABLED_IND', 'VIEWLAYER', 'Y' FROM DUAL 
UNION 
 SELECT 'VALUE_8', 'VAT_VEND_COUNTRY_SETUP', '1000', '/EC', 'DESCRIPTION', 'APPLICATION', 'Standard value field that can be used by projects' FROM DUAL 
UNION 
 SELECT 'VALUE_8', 'VAT_VEND_COUNTRY_SETUP', '1000', '/EC', 'LABEL', 'APPLICATION', 'Value 8' FROM DUAL 
UNION 
 SELECT 'VALUE_8', 'VAT_VEND_COUNTRY_SETUP', '1000', '/EC', 'NAME', 'APPLICATION', 'Value 8' FROM DUAL 
UNION 
 SELECT 'VALUE_8', 'VAT_VEND_COUNTRY_SETUP', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '230' FROM DUAL 
UNION 
 SELECT 'VALUE_8', 'VAT_VEND_COUNTRY_SETUP', '1000', '/EC', 'viewwidth', 'STATIC_PRESENTATION', '120' FROM DUAL 
UNION 
 SELECT 'VALUE_9', 'VAT_CUST_COUNTRY_SETUP', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '240' FROM DUAL 
UNION 
 SELECT 'VALUE_9', 'VAT_CUST_COUNTRY_SETUP', '1000', '/', 'DISABLED_IND', 'VIEWLAYER', 'Y' FROM DUAL 
UNION 
 SELECT 'VALUE_9', 'VAT_CUST_COUNTRY_SETUP', '1000', '/EC', 'DESCRIPTION', 'APPLICATION', 'Standard value field that can be used by projects' FROM DUAL 
UNION 
 SELECT 'VALUE_9', 'VAT_CUST_COUNTRY_SETUP', '1000', '/EC', 'LABEL', 'APPLICATION', 'Value 9' FROM DUAL 
UNION 
 SELECT 'VALUE_9', 'VAT_CUST_COUNTRY_SETUP', '1000', '/EC', 'NAME', 'APPLICATION', 'Value 9' FROM DUAL 
UNION 
 SELECT 'VALUE_9', 'VAT_CUST_COUNTRY_SETUP', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '240' FROM DUAL 
UNION 
 SELECT 'VALUE_9', 'VAT_CUST_COUNTRY_SETUP', '1000', '/EC', 'viewwidth', 'STATIC_PRESENTATION', '120' FROM DUAL 
UNION 
 SELECT 'VALUE_9', 'VAT_DEST_COUNTRY_SETUP', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '240' FROM DUAL 
UNION 
 SELECT 'VALUE_9', 'VAT_DEST_COUNTRY_SETUP', '1000', '/', 'DISABLED_IND', 'VIEWLAYER', 'Y' FROM DUAL 
UNION 
 SELECT 'VALUE_9', 'VAT_DEST_COUNTRY_SETUP', '1000', '/EC', 'DESCRIPTION', 'APPLICATION', 'Standard value field that can be used by projects' FROM DUAL 
UNION 
 SELECT 'VALUE_9', 'VAT_DEST_COUNTRY_SETUP', '1000', '/EC', 'LABEL', 'APPLICATION', 'Value 9' FROM DUAL 
UNION 
 SELECT 'VALUE_9', 'VAT_DEST_COUNTRY_SETUP', '1000', '/EC', 'NAME', 'APPLICATION', 'Value 9' FROM DUAL 
UNION 
 SELECT 'VALUE_9', 'VAT_DEST_COUNTRY_SETUP', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '240' FROM DUAL 
UNION 
 SELECT 'VALUE_9', 'VAT_DEST_COUNTRY_SETUP', '1000', '/EC', 'viewwidth', 'STATIC_PRESENTATION', '120' FROM DUAL 
UNION 
 SELECT 'VALUE_9', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '240' FROM DUAL 
UNION 
 SELECT 'VALUE_9', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/', 'DISABLED_IND', 'VIEWLAYER', 'Y' FROM DUAL 
UNION 
 SELECT 'VALUE_9', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/EC', 'DESCRIPTION', 'APPLICATION', 'Standard value field that can be used by projects' FROM DUAL 
UNION 
 SELECT 'VALUE_9', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/EC', 'LABEL', 'APPLICATION', 'Value 9' FROM DUAL 
UNION 
 SELECT 'VALUE_9', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/EC', 'NAME', 'APPLICATION', 'Value 9' FROM DUAL 
UNION 
 SELECT 'VALUE_9', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '240' FROM DUAL 
UNION 
 SELECT 'VALUE_9', 'VAT_ORIG_COUNTRY_SETUP', '1000', '/EC', 'viewwidth', 'STATIC_PRESENTATION', '120' FROM DUAL 
UNION 
 SELECT 'VALUE_9', 'VAT_VEND_COUNTRY_SETUP', '1000', '/', 'DB_SORT_ORDER', 'VIEWLAYER', '240' FROM DUAL 
UNION 
 SELECT 'VALUE_9', 'VAT_VEND_COUNTRY_SETUP', '1000', '/', 'DISABLED_IND', 'VIEWLAYER', 'Y' FROM DUAL 
UNION 
 SELECT 'VALUE_9', 'VAT_VEND_COUNTRY_SETUP', '1000', '/EC', 'DESCRIPTION', 'APPLICATION', 'Standard value field that can be used by projects' FROM DUAL 
UNION 
 SELECT 'VALUE_9', 'VAT_VEND_COUNTRY_SETUP', '1000', '/EC', 'LABEL', 'APPLICATION', 'Value 9' FROM DUAL 
UNION 
 SELECT 'VALUE_9', 'VAT_VEND_COUNTRY_SETUP', '1000', '/EC', 'NAME', 'APPLICATION', 'Value 9' FROM DUAL 
UNION 
 SELECT 'VALUE_9', 'VAT_VEND_COUNTRY_SETUP', '1000', '/EC', 'SCREEN_SORT_ORDER', 'APPLICATION', '240' FROM DUAL 
UNION 
 SELECT 'VALUE_9', 'VAT_VEND_COUNTRY_SETUP', '1000', '/EC', 'viewwidth', 'STATIC_PRESENTATION', '120' FROM DUAL
) n
ON (o.ATTRIBUTE_NAME = n.ATTRIBUTE_NAME
 AND o.CLASS_NAME = n.CLASS_NAME
 AND o.OWNER_CNTX = n.OWNER_CNTX
 AND o.PRESENTATION_CNTX = n.PRESENTATION_CNTX
 AND o.PROPERTY_CODE = n.PROPERTY_CODE
 AND o.PROPERTY_TYPE = n.PROPERTY_TYPE)
WHEN MATCHED THEN UPDATE SET
o.PROPERTY_VALUE = n.PROPERTY_VALUE
,o.LAST_UPDATED_BY = 'UPGD-TOOL-12.0-DM'
,o.REV_NO = o.REV_NO+1
WHEN NOT MATCHED THEN INSERT
(ATTRIBUTE_NAME,CLASS_NAME,OWNER_CNTX,PRESENTATION_CNTX,PROPERTY_CODE,PROPERTY_TYPE,PROPERTY_VALUE,CREATED_BY)
VALUES( n.ATTRIBUTE_NAME, n.CLASS_NAME, n.OWNER_CNTX, n.PRESENTATION_CNTX, n.PROPERTY_CODE, n.PROPERTY_TYPE, n.PROPERTY_VALUE,'UPGD-TOOL-12.0-DM');

END;
--~^UTDELIM^~--

begin
  for c in (
    select table_name from user_tables
      where table_name in
      (
        'PROD_AREA_FORECAST', 
        'PROD_FIELD_FORECAST',
        'PROD_PRODUNIT_FORECAST',
        'PROD_FORECAST',
        'PROD_STORAGE_FORECAST',
        'PROD_SUB_AREA_FORECAST',
        'PROD_SUB_FIELD_FORECAST',
        'PROD_WELL_FORECAST'
    ) )
    LOOP 
    EcDp_Generate.generate(c.table_name,EcDp_Generate.IU_TRIGGERS);
    END LOOP;
END;
--~^UTDELIM^~--  

begin
  for c in (
    select table_name from user_tables
      where table_name in
      (
      'PROD_AREA_FORECAST',
      'PROD_FIELD_FORECAST',
      'PROD_FORECAST',
      'PROD_PRODUNIT_FORECAST',
      'PROD_STORAGE_FORECAST',
      'PROD_SUB_AREA_FORECAST',
      'PROD_SUB_FIELD_FORECAST',
      'PROD_WELL_FORECAST' 
    ) )
    LOOP
      EcDp_Generate.generate(c.table_name,EcDp_Generate.IUR_TRIGGERS);
    END LOOP;
END;
--~^UTDELIM^~-- 

BEGIN
	EXECUTE IMMEDIATE 'DROP MATERIALIZED VIEW CLASS';
EXCEPTION
WHEN OTHERS
THEN
 NULL;
END;
--~^UTDELIM^~--


CREATE MATERIALIZED VIEW CLASS 
-------------------------------------------------------------------------------------
-- CLASS
--
-- $Revision: 1.4 $
--
--  Purpose: Select the row from Class_cnfg with the higherst owner context, allowing templates and projects to
--           override product settings without changing the product row. 
--
-------------------------------------------------------------------------------------
BUILD IMMEDIATE
REFRESH ON DEMAND
AS
with class_property_max as(
  select class_name, property_code, property_value
  from class_property_cnfg p1 
  where p1.presentation_cntx in ('/', '/EC')
  and owner_cntx = (
        select max(owner_cntx) 
        from class_property_cnfg p1_1
        where p1.class_name = p1_1.class_name 
        and p1.property_code = p1_1.property_code
        and p1.presentation_cntx = p1_1.presentation_cntx
        )  
)
select 
c.CLASS_NAME                                      
,cast(null as varchar2(24)) as SUPER_CLASS                                     
,c.CLASS_TYPE                                      
,c.APP_SPACE_CNTX as APP_SPACE_CODE                                  
,c.TIME_SCOPE_CODE    
,c.OWNER_CLASS_NAME    
,cast(p3.property_value as varchar2(24)) as CLASS_SHORT_CODE
,cast(p4.property_value as varchar2(100)) as LABEL
,cast(p5.property_value as varchar2(1)) as ENSURE_REV_TEXT_ON_UPD
,cast(p6.property_value as varchar2(1)) as READ_ONLY_IND
,cast(p7.property_value as varchar2(1)) as INCLUDE_IN_VALIDATION
,cast(p18.property_value as varchar2(1)) as CALC_ENGINE_TABLE_WRITE_IND
,cast(p8.property_value as varchar2(4000)) as JOURNAL_RULE_DB_SYNTAX
,cast(NULL as varchar2(4000)) as CALC_MAPPING_SYNTAX
,cast(p10.property_value as varchar2(4000)) as LOCK_RULE
,cast(p11.property_value as varchar2(1)) as LOCK_IND
,cast(p12.property_value as varchar2(1)) as ACCESS_CONTROL_IND
,cast(p13.property_value as varchar2(1)) as APPROVAL_IND
,cast(p14.property_value as varchar2(1)) as SKIP_TRG_CHECK_IND
,cast(p15.property_value as varchar2(1)) as INCLUDE_WEBSERVICE
,cast(p16.property_value as varchar2(1)) as CREATE_EV_IND
,cast(p19.property_value as varchar2(1)) as INCLUDE_IN_MAPPING_IND
,cast(p17.property_value as varchar2(4000)) as DESCRIPTION
, cast(null as varchar2(24)) as CLASS_VERSION                                   
,c.RECORD_STATUS                                   
,c.CREATED_BY                                      
,c.CREATED_DATE                                    
,c.LAST_UPDATED_BY                                 
,c.LAST_UPDATED_DATE                               
,c.REV_NO                                          
,c.REV_TEXT                                        
,c.APPROVAL_STATE                                  
,c.APPROVAL_BY                                     
,c.APPROVAL_DATE                                   
,c.REC_ID                                          
from class_cnfg c
left join class_property_max p3 on (c.class_name = p3.class_name and p3.property_code = 'CLASS_SHORT_CODE' )
left join class_property_max p4 on (c.class_name = p4.class_name and p4.property_code = 'LABEL' )
left join class_property_max p5 on (c.class_name = p5.class_name and p5.property_code = 'ENSURE_REV_TEXT_ON_UPD' )
left join class_property_max p6 on (c.class_name = p6.class_name and p6.property_code = 'READ_ONLY_IND' )
left join class_property_max p7 on (c.class_name = p7.class_name and p7.property_code = 'INCLUDE_IN_VALIDATION' )
left join class_property_max p8 on (c.class_name = p8.class_name and p8.property_code = 'JOURNAL_RULE_DB_SYNTAX' )
left join class_property_max p10 on (c.class_name = p10.class_name and p10.property_code = 'LOCK_RULE' )
left join class_property_max p11 on (c.class_name = p11.class_name and p11.property_code = 'LOCK_IND' )
left join class_property_max p12 on (c.class_name = p12.class_name and p12.property_code = 'ACCESS_CONTROL_IND' )
left join class_property_max p13 on (c.class_name = p13.class_name and p13.property_code = 'APPROVAL_IND' )
left join class_property_max p14 on (c.class_name = p14.class_name and p14.property_code = 'SKIP_TRG_CHECK_IND' )
left join class_property_max p15 on (c.class_name = p15.class_name and p15.property_code = 'INCLUDE_WEBSERVICE' )
left join class_property_max p16 on (c.class_name = p16.class_name and p16.property_code = 'CREATE_EV_IND' )
left join class_property_max p17 on (c.class_name = p17.class_name and p17.property_code = 'DESCRIPTION' )
left join class_property_max p18 on (c.class_name = p18.class_name and p18.property_code = 'CALC_ENGINE_TABLE_WRITE_IND' )
left join class_property_max p19 on (c.class_name = p19.class_name and p19.property_code = 'INCLUDE_IN_MAPPING_IND' )
WHERE ec_install_constants.isBlockedAppSpaceCntx(c.app_space_cntx) = 0
--~^UTDELIM^~--

create unique index UIX_CLASS on Class(Class_name)
TABLESPACE &ts_index
--~^UTDELIM^~--

CREATE INDEX IFK_CLASS_2 ON CLASS
 (OWNER_CLASS_NAME)
 INITRANS 2
 MAXTRANS 255
 PCTFREE 50
 STORAGE
 (
   PCTINCREASE 50
   NEXT 65536
 )
 TABLESPACE &ts_index
--~^UTDELIM^~--

CREATE INDEX IFK_CLASS_1 ON CLASS
 (SUPER_CLASS)
 INITRANS 2
 MAXTRANS 255
 PCTFREE 50
 STORAGE
 (
   PCTINCREASE 50
   NEXT 65536
 )
 TABLESPACE &ts_index
--~^UTDELIM^~--

CREATE INDEX IR_CLASS ON CLASS
 (REC_ID)
 INITRANS 2
 MAXTRANS 255
 PCTFREE 50
 STORAGE
 (
   PCTINCREASE 50
   NEXT 65536
 )
 TABLESPACE &ts_index
--~^UTDELIM^~--

BEGIN
	EXECUTE IMMEDIATE 'DROP MATERIALIZED VIEW class_attribute';
EXCEPTION
WHEN OTHERS
THEN
 NULL;
END;
--~^UTDELIM^~--


CREATE MATERIALIZED VIEW class_attribute 
-------------------------------------------------------------------------------------
-- class_db_mapping
--
-- $Revision: 1.4 $
--
--  Purpose: Select the row with the higherst owner context, allowing templates and projects to
--           override product settings without changing the product row. 
--
-------------------------------------------------------------------------------------
BUILD IMMEDIATE
REFRESH ON DEMAND
AS
with class_attr_property_max as(
  select p1.class_name, p1.attribute_name, p1.property_code, p1.property_value
  from class_attr_property_cnfg p1, class_cnfg cc, class_attribute_cnfg ca 
  where p1.presentation_cntx in ('/EC', '/')
  and cc.class_name=p1.class_name
  and ca.class_name=p1.class_name
  and ca.attribute_name=p1.attribute_name    
  and ec_install_constants.isBlockedAppSpaceCntx(cc.app_space_cntx) = 0
  and ec_install_constants.isBlockedAppSpaceCntx(ca.app_space_cntx) = 0
  and p1.owner_cntx = (
        select max(owner_cntx) 
        from class_attr_property_cnfg p1_1
        where p1.class_name = p1_1.class_name 
        and   p1.attribute_name = p1_1.attribute_name
        and p1.property_code = p1_1.property_code
        and p1.presentation_cntx = p1_1.presentation_cntx
        )  
)
select 
ca.CLASS_NAME
,ca.attribute_name                                      
,ca.is_key
,cast(p1.property_value as varchar2(1)) as is_mandatory
,ca.APP_SPACE_CNTX as CONTEXT_CODE                                  
,ca.data_type
,cast(null as varchar2(4000)) as calc_mapping_syntax
,cast(null as varchar2(32)) as precision
,cast(null as varchar2(4000)) as default_value
,cast(p5.property_value as varchar2(1)) as disabled_ind
,cast(null as varchar2(1)) as disabled_calc_ind
,cast(p7.property_value as varchar2(1)) as report_only_ind
,cast(p8.property_value as varchar2(4000)) as description
,cast(p9.property_value as varchar2(240)) as name
,cast(null as varchar2(240)) as default_client_value
,cast(p10.property_value as varchar2(1)) as read_only_ind
,ca.RECORD_STATUS                                   
,ca.CREATED_BY                                      
,ca.CREATED_DATE                                    
,ca.LAST_UPDATED_BY                                 
,ca.LAST_UPDATED_DATE                               
,ca.REV_NO                                          
,ca.REV_TEXT                                        
,ca.APPROVAL_STATE                                  
,ca.APPROVAL_BY                                     
,ca.APPROVAL_DATE                                   
,ca.REC_ID                                          
from class_attribute_cnfg ca
inner join class_cnfg cc on cc.class_name = ca.class_name and ec_install_constants.isBlockedAppSpaceCntx(cc.app_space_cntx) = 0
left join class_attr_property_max p1 on (ca.class_name = p1.class_name and ca.attribute_name = p1.attribute_name and p1.property_code = 'IS_MANDATORY' )
left join class_attr_property_max p5 on (ca.class_name = p5.class_name and ca.attribute_name = p5.attribute_name and p5.property_code = 'DISABLED_IND' )
left join class_attr_property_max p7 on (ca.class_name = p7.class_name and ca.attribute_name = p7.attribute_name and p7.property_code = 'REPORT_ONLY_IND' )
left join class_attr_property_max p8 on (ca.class_name = p8.class_name and ca.attribute_name = p8.attribute_name and p8.property_code = 'DESCRIPTION' )
left join class_attr_property_max p9 on (ca.class_name = p9.class_name and ca.attribute_name = p9.attribute_name and p9.property_code = 'NAME' )
left join class_attr_property_max p10 on (ca.class_name = p10.class_name and ca.attribute_name = p10.attribute_name and p10.property_code = 'READ_ONLY_IND' )
where ec_install_constants.isBlockedAppSpaceCntx(ca.app_space_cntx) = 0
--~^UTDELIM^~--

create unique index uix_class_attribute on Class_attribute(Class_name,attribute_name)
TABLESPACE &ts_index
--~^UTDELIM^~--

BEGIN
	EXECUTE IMMEDIATE 'DROP MATERIALIZED VIEW class_attr_db_mapping';
EXCEPTION
WHEN OTHERS
THEN
 NULL;
END;
--~^UTDELIM^~--

CREATE MATERIALIZED VIEW class_attr_db_mapping 
-------------------------------------------------------------------------------------
-- class_db_mapping
--
-- $Revision: 1.4 $
--
--  Purpose: Select the row with the higherst owner context, allowing templates and projects to
--           override product settings without changing the product row. 
--
-------------------------------------------------------------------------------------
BUILD IMMEDIATE
REFRESH ON DEMAND
AS
with class_attr_property_max as(
  select p1.class_name, p1.attribute_name, p1.property_code, p1.property_value
  from class_attr_property_cnfg p1, class_cnfg cc, class_attribute_cnfg ca  
  where p1.presentation_cntx in ('/EC', '/')
  and cc.class_name=p1.class_name
  and ca.class_name=p1.class_name
  and ca.attribute_name=p1.attribute_name
  and ec_install_constants.isBlockedAppSpaceCntx(cc.app_space_cntx) = 0
  and ec_install_constants.isBlockedAppSpaceCntx(ca.app_space_cntx) = 0
  and owner_cntx = (
        select max(owner_cntx) 
        from class_attr_property_cnfg p1_1
        where p1.class_name = p1_1.class_name 
        and   p1.attribute_name = p1_1.attribute_name
        and p1.property_code = p1_1.property_code
        and p1.presentation_cntx = p1_1.presentation_cntx
        )  
)
select 
ca.CLASS_NAME
,ca.attribute_name                                      
,ca.db_mapping_type
,ca.db_sql_syntax
,cast(p1.property_value as number) as sort_order
,ca.db_join_table                                   
,ca.db_join_where                                   
,ca.RECORD_STATUS                                   
,ca.CREATED_BY                                      
,ca.CREATED_DATE                                    
,ca.LAST_UPDATED_BY                                 
,ca.LAST_UPDATED_DATE                               
,ca.REV_NO                                          
,ca.REV_TEXT                                        
,ca.APPROVAL_STATE                                  
,ca.APPROVAL_BY                                     
,ca.APPROVAL_DATE                                   
,ca.REC_ID                                          
from class_attribute_cnfg ca
inner join class_cnfg cc on cc.class_name = ca.class_name and ec_install_constants.isBlockedAppSpaceCntx(cc.app_space_cntx) = 0
left join class_attr_property_max p1 on (ca.class_name = p1.class_name and ca.attribute_name = p1.attribute_name and p1.property_code = 'DB_SORT_ORDER' )
where ec_install_constants.isBlockedAppSpaceCntx(ca.app_space_cntx) = 0
--~^UTDELIM^~--

create unique index uix_class_attr_db_mapping on Class_attr_db_mapping(Class_name,attribute_name)
TABLESPACE &ts_index
--~^UTDELIM^~--

CREATE INDEX IR_CLASS_ATTR_DB_MAPPING ON CLASS_ATTR_DB_MAPPING
 (REC_ID)
 INITRANS 2
 MAXTRANS 255
 PCTFREE 50
 STORAGE
 (
   PCTINCREASE 50
   NEXT 65536
 )
 TABLESPACE &ts_index
--~^UTDELIM^~--

BEGIN
	EXECUTE IMMEDIATE 'DROP MATERIALIZED VIEW class_attr_presentation';
EXCEPTION
WHEN OTHERS
THEN
 NULL;
END;
--~^UTDELIM^~--

CREATE MATERIALIZED VIEW class_attr_presentation 
-------------------------------------------------------------------------------------
--
-- $Revision: 1.4 $
--
--  Purpose: Select the row with the higherst owner context, allowing templates and projects to
--           override product settings without changing the product row. 
--
-------------------------------------------------------------------------------------
BUILD IMMEDIATE
REFRESH ON DEMAND
AS
with class_attr_property_max as(
  select p1.class_name, p1.attribute_name, p1.property_code, p1.property_value
  from class_attr_property_cnfg p1, class_cnfg cc, class_attribute_cnfg ca   
  where p1.presentation_cntx in ('/EC', '/')
  and cc.class_name=p1.class_name
  and ca.class_name=p1.class_name
  and ca.attribute_name=p1.attribute_name  
  and ec_install_constants.isBlockedAppSpaceCntx(cc.app_space_cntx) = 0  
  and ec_install_constants.isBlockedAppSpaceCntx(ca.app_space_cntx) = 0  
  and p1.owner_cntx = (
        select max(p1_1.owner_cntx) 
        from class_attr_property_cnfg p1_1
        where p1.class_name = p1_1.class_name 
        and   p1.attribute_name = p1_1.attribute_name
        and p1.property_code = p1_1.property_code
        and p1.presentation_cntx = p1_1.presentation_cntx
        )  
  ), 
  class_attr_static as (
  select p1.class_name, p1.attribute_name, listagg(p1.property_code||'='||p1.property_value,';') WITHIN GROUP (ORDER BY p1.property_code) static_presentation_syntax
  from class_attr_property_cnfg p1, class_cnfg cc  
  where p1.presentation_cntx in ('/EC')
  and   p1.property_type = 'STATIC_PRESENTATION'
  and   cc.class_name=p1.class_name
  and   ec_install_constants.isBlockedAppSpaceCntx(cc.app_space_cntx) = 0  
  and   p1.owner_cntx = (
        select max(p1_1.owner_cntx) 
        from class_attr_property_cnfg p1_1
        where p1.class_name = p1_1.class_name 
        and   p1.attribute_name = p1_1.attribute_name
        and p1.property_code = p1_1.property_code
        and p1.presentation_cntx = p1_1.presentation_cntx
        )  
  group by p1.class_name, p1.attribute_name      
  )
select 
ca.CLASS_NAME
,ca.attribute_name                                      
,cast(ecdp_classmeta_cnfg.getDynamicPresentationSyntax(ca.class_name, ca.attribute_name) as varchar(4000)) as presentation_syntax
,cast(psp1.static_presentation_syntax as varchar(4000)) as static_presentation_syntax
,cast(p2.property_value as number) as sort_order
,cast(p3.property_value as varchar(4000)) as db_pres_syntax
,cast(p4.property_value as varchar(32)) as label_id
,cast(p5.property_value as varchar(64)) as label
,cast(p6.property_value as varchar(32)) as uom_code
,ca.RECORD_STATUS                                   
,ca.CREATED_BY                                      
,ca.CREATED_DATE                                    
,ca.LAST_UPDATED_BY                                 
,ca.LAST_UPDATED_DATE                               
,ca.REV_NO                                          
,ca.REV_TEXT                                        
,ca.APPROVAL_STATE                                  
,ca.APPROVAL_BY                                     
,ca.APPROVAL_DATE                                   
,ca.REC_ID                                          
from class_attribute_cnfg ca
inner join class_cnfg cc on cc.class_name = ca.class_name and ec_install_constants.isBlockedAppSpaceCntx(cc.app_space_cntx) = 0
left join class_attr_static psp1 on (ca.class_name = psp1.class_name and ca.attribute_name = psp1.attribute_name)
left join class_attr_property_max p2 on (ca.class_name = p2.class_name and ca.attribute_name = p2.attribute_name and p2.property_code = 'SCREEN_SORT_ORDER' )
left join class_attr_property_max p3 on (ca.class_name = p3.class_name and ca.attribute_name = p3.attribute_name and p3.property_code = 'DB_PRES_SYNTAX' )
left join class_attr_property_max p4 on (ca.class_name = p4.class_name and ca.attribute_name = p4.attribute_name and p4.property_code = 'LABEL_ID' )
left join class_attr_property_max p5 on (ca.class_name = p5.class_name and ca.attribute_name = p5.attribute_name and p5.property_code = 'LABEL' )
left join class_attr_property_max p6 on (ca.class_name = p6.class_name and ca.attribute_name = p6.attribute_name and p6.property_code = 'UOM_CODE' )
where ec_install_constants.isBlockedAppSpaceCntx(ca.app_space_cntx) = 0
--~^UTDELIM^~--

create unique index uix_class_attr_presentation on class_attr_presentation(class_name,attribute_name)
TABLESPACE &ts_index
--~^UTDELIM^~--

CREATE INDEX IR_CLASS_ATTR_PRESENTATION ON CLASS_ATTR_PRESENTATION
 (REC_ID)
 INITRANS 2
 MAXTRANS 255
 PCTFREE 50
 STORAGE
 (
   PCTINCREASE 50
   NEXT 65536
 )
 TABLESPACE &ts_index
--~^UTDELIM^~--

BEGIN
	EXECUTE IMMEDIATE 'DROP MATERIALIZED VIEW class_relation';
EXCEPTION
WHEN OTHERS
THEN
 NULL;
END;
--~^UTDELIM^~--

CREATE MATERIALIZED VIEW class_relation 
-------------------------------------------------------------------------------------
--
-- $Revision: 1.4 $
--
--  Purpose: Select the row with the higherst owner context, allowing templates and projects to
--           override product settings without changing the product row. 
--
-------------------------------------------------------------------------------------
BUILD IMMEDIATE
REFRESH ON DEMAND
AS
with class_rel_property_max as(
  select p1.from_class_name, p1.to_class_name, p1.role_name, p1.property_code, p1.property_value
  from class_rel_property_cnfg p1, class_cnfg cc 
  where p1.presentation_cntx in ('/', '/EC')
  and cc.class_name=p1.to_class_name
  and ec_install_constants.isBlockedAppSpaceCntx(cc.app_space_cntx) = 0  
  and p1.owner_cntx = (
        select max(owner_cntx) 
        from class_rel_property_cnfg p1_1
        where p1.from_class_name = p1_1.from_class_name 
        and   p1.to_class_name = p1_1.to_class_name
        and   p1.role_name = p1_1.role_name
        and p1.property_code = p1_1.property_code
        and p1.presentation_cntx = p1_1.presentation_cntx
        )  
)
select 
cr.from_CLASS_NAME
,cr.to_class_name
,cr.role_name                                      
,cr.is_key
,cast(p0.property_value as varchar2(50)) as name
,cast(p1.property_value as varchar2(1)) as is_mandatory
,cr.is_bidirectional
,cr.app_space_cntx as context_code
,cr.group_type
,cr.multiplicity
,cast(p2.property_value as varchar2(1)) as disabled_ind
,cast(p3.property_value as varchar2(1)) as report_only_ind
,cast(p4.property_value as varchar2(32)) as access_control_method
,cast(p5.property_value as number) as alloc_priority
,cast(null as varchar2(4000)) as calc_mapping_syntax
,cast(p7.property_value as varchar2(4000)) as description
,cast(p8.property_value as varchar2(1)) as approval_ind
,cast(p9.property_value as varchar2(1)) as reverse_approval_ind
,cr.RECORD_STATUS                                   
,cr.CREATED_BY                                      
,cr.CREATED_DATE                                    
,cr.LAST_UPDATED_BY                                 
,cr.LAST_UPDATED_DATE                               
,cr.REV_NO                                          
,cr.REV_TEXT                                        
,cr.APPROVAL_STATE                                  
,cr.APPROVAL_BY                                     
,cr.APPROVAL_DATE                                   
,cr.REC_ID                                          
from class_relation_cnfg cr
inner join class_cnfg tc on tc.class_name = cr.to_class_name and ec_install_constants.isBlockedAppSpaceCntx(tc.app_space_cntx) = 0
inner join class_cnfg fc on fc.class_name = cr.from_class_name and ec_install_constants.isBlockedAppSpaceCntx(fc.app_space_cntx) = 0
left join class_rel_property_max p0 on (cr.from_class_name = p0.from_class_name and cr.to_class_name = p0.to_class_name and cr.role_name = p0.role_name and p0.property_code = 'NAME' )
left join class_rel_property_max p1 on (cr.from_class_name = p1.from_class_name and cr.to_class_name = p1.to_class_name and cr.role_name = p1.role_name and p1.property_code = 'IS_MANDATORY' )
left join class_rel_property_max p2 on (cr.from_class_name = p2.from_class_name and cr.to_class_name = p2.to_class_name and cr.role_name = p2.role_name and p2.property_code = 'DISABLED_IND' )
left join class_rel_property_max p3 on (cr.from_class_name = p3.from_class_name and cr.to_class_name = p3.to_class_name and cr.role_name = p3.role_name and p3.property_code = 'REPORT_ONLY_IND' )
left join class_rel_property_max p4 on (cr.from_class_name = p4.from_class_name and cr.to_class_name = p4.to_class_name and cr.role_name = p4.role_name and p4.property_code = 'ACCESS_CONTROL_METHOD' )
left join class_rel_property_max p5 on (cr.from_class_name = p5.from_class_name and cr.to_class_name = p5.to_class_name and cr.role_name = p5.role_name and p5.property_code = 'ALLOC_PRIORITY' )
left join class_rel_property_max p7 on (cr.from_class_name = p7.from_class_name and cr.to_class_name = p7.to_class_name and cr.role_name = p7.role_name and p7.property_code = 'DESCRIPTION' )
left join class_rel_property_max p8 on (cr.from_class_name = p8.from_class_name and cr.to_class_name = p8.to_class_name and cr.role_name = p8.role_name and p8.property_code = 'APPROVAL_IND' )
left join class_rel_property_max p9 on (cr.from_class_name = p9.from_class_name and cr.to_class_name = p9.to_class_name and cr.role_name = p9.role_name and p9.property_code = 'REVERSE_APPROVAL_IND' )
where ec_install_constants.isBlockedAppSpaceCntx(cr.app_space_cntx) = 0
--~^UTDELIM^~--

create unique index uix_class_relation on Class_relation(from_class_name,to_class_name,role_name)
TABLESPACE &ts_index
--~^UTDELIM^~--

CREATE INDEX IFK_CLASS_RELATION_2 ON CLASS_RELATION
 (TO_CLASS_NAME)
 INITRANS 2
 MAXTRANS 255
 PCTFREE 50
 STORAGE
 (
   PCTINCREASE 50
   NEXT 65536
 )
 TABLESPACE &ts_index
--~^UTDELIM^~--

CREATE INDEX IR_CLASS_RELATION ON CLASS_RELATION
 (REC_ID)
 INITRANS 2
 MAXTRANS 255
 PCTFREE 50
 STORAGE
 (
   PCTINCREASE 50
   NEXT 65536
 )
 TABLESPACE &ts_index
--~^UTDELIM^~--


BEGIN
	EXECUTE IMMEDIATE 'DROP MATERIALIZED VIEW class_rel_db_mapping';
EXCEPTION
WHEN OTHERS
THEN
 NULL;
END;
--~^UTDELIM^~--

CREATE MATERIALIZED VIEW class_rel_db_mapping 
-------------------------------------------------------------------------------------
--
-- $Revision: 1.4 $
--
--  Purpose: Select the row with the higherst owner context, allowing templates and projects to
--           override product settings without changing the product row. 
--
-------------------------------------------------------------------------------------
BUILD IMMEDIATE
REFRESH ON DEMAND
AS
with class_rel_property_max as(
  select from_class_name, to_class_name, role_name, property_code, property_value
  from class_rel_property_cnfg p1 
  where p1.presentation_cntx in ('/EC', '/')
  and owner_cntx = (
        select max(owner_cntx) 
        from class_rel_property_cnfg p1_1
        where p1.from_class_name = p1_1.from_class_name 
        and   p1.to_class_name = p1_1.to_class_name
        and   p1.role_name = p1_1.role_name
        and p1.property_code = p1_1.property_code
        and p1.presentation_cntx = p1_1.presentation_cntx
        )  
)
select 
cr.from_CLASS_NAME
,cr.to_class_name
,cr.role_name                                      
,cr.db_mapping_type
,cr.db_sql_syntax
,cast(p1.property_value as number) as sort_order
,cr.RECORD_STATUS                                   
,cr.CREATED_BY                                      
,cr.CREATED_DATE                                    
,cr.LAST_UPDATED_BY                                 
,cr.LAST_UPDATED_DATE                               
,cr.REV_NO                                          
,cr.REV_TEXT                                        
,cr.APPROVAL_STATE                                  
,cr.APPROVAL_BY                                     
,cr.APPROVAL_DATE                                   
,cr.REC_ID                                          
from class_relation_cnfg cr
left join class_cnfg tc on tc.class_name = cr.to_class_name and ec_install_constants.isBlockedAppSpaceCntx(tc.app_space_cntx) = 0
left join class_cnfg fc on fc.class_name = cr.from_class_name and ec_install_constants.isBlockedAppSpaceCntx(fc.app_space_cntx) = 0
left join class_rel_property_max p1 on (cr.from_class_name = p1.from_class_name and cr.to_class_name = p1.to_class_name and cr.role_name = p1.role_name and p1.property_code = 'DB_SORT_ORDER' )
where ec_install_constants.isBlockedAppSpaceCntx(cr.app_space_cntx) = 0
--~^UTDELIM^~--

create unique index uix_class_rel_db_mapping on Class_rel_db_mapping(from_class_name,to_class_name,role_name)
TABLESPACE &ts_index
--~^UTDELIM^~--

CREATE INDEX IR_CLASS_REL_DB_MAPPING ON CLASS_REL_DB_MAPPING
 (REC_ID)
 INITRANS 2
 MAXTRANS 255
 PCTFREE 50
 STORAGE
 (
   PCTINCREASE 50
   NEXT 65536
 )
 TABLESPACE &ts_index
--~^UTDELIM^~--

BEGIN
	EXECUTE IMMEDIATE 'DROP MATERIALIZED VIEW class_rel_presentation';
EXCEPTION
WHEN OTHERS
THEN
 NULL;
END;
--~^UTDELIM^~--

CREATE MATERIALIZED VIEW class_rel_presentation 
-------------------------------------------------------------------------------------
--
-- $Revision: 1.4 $
--
--  Purpose: Select the row with the higherst owner context, allowing templates and projects to
--           override product settings without changing the product row. 
--
-------------------------------------------------------------------------------------
BUILD IMMEDIATE
REFRESH ON DEMAND
AS
with class_rel_property_max as(
  select p1.from_class_name, p1.to_class_name, p1.role_name, p1.property_code, p1.property_value
  from class_rel_property_cnfg p1, class_cnfg cc 
  where p1.presentation_cntx in ('/EC', '/')
  and cc.class_name=p1.to_class_name
  and ec_install_constants.isBlockedAppSpaceCntx(cc.app_space_cntx) = 0    
  and owner_cntx = (
        select max(owner_cntx) 
        from class_rel_property_cnfg p1_1
        where p1.from_class_name = p1_1.from_class_name 
        and   p1.to_class_name = p1_1.to_class_name
        and   p1.role_name = p1_1.role_name
        and   p1.property_code = p1_1.property_code
        and   p1.presentation_cntx = p1_1.presentation_cntx
        )  
),
  class_rel_static as (
  select p1.from_class_name, p1.to_class_name, p1.role_name, listagg(p1.property_code||'='||p1.property_value,';') WITHIN GROUP (ORDER BY p1.property_code) static_presentation_syntax
  from class_rel_property_cnfg p1, class_cnfg cc 
  where p1.presentation_cntx = '/EC'
  and   p1.property_type = 'STATIC_PRESENTATION'
  and   cc.class_name=p1.to_class_name
  and   ec_install_constants.isBlockedAppSpaceCntx(cc.app_space_cntx) = 0      
  and   p1.owner_cntx = (
        select max(owner_cntx) 
        from class_rel_property_cnfg p1_1
        where p1.from_class_name = p1_1.from_class_name 
        and   p1.to_class_name = p1_1.to_class_name
        and   p1.role_name = p1_1.role_name
        and   p1.property_code = p1_1.property_code
        and   p1.presentation_cntx = p1_1.presentation_cntx
        )  
  group by p1.from_class_name, p1.to_class_name, p1.role_name      
  )
select 
cr.from_CLASS_NAME
,cr.to_class_name
,cr.role_name                                      
,cast(psp1.static_presentation_syntax as varchar(4000)) as static_presentation_syntax
,cast(ecdp_classmeta_cnfg.getDynamicPresentationSyntax(cr.from_class_name, cr.to_class_name, cr.role_name) as varchar2(4000)) as presentation_syntax
,cast(p2.property_value as varchar2(4000)) as db_pres_syntax
,cast(p3.property_value as varchar2(64)) as label
,cr.RECORD_STATUS                                   
,cr.CREATED_BY                                      
,cr.CREATED_DATE                                    
,cr.LAST_UPDATED_BY                                 
,cr.LAST_UPDATED_DATE                               
,cr.REV_NO                                          
,cr.REV_TEXT                                        
,cr.APPROVAL_STATE                                  
,cr.APPROVAL_BY                                     
,cr.APPROVAL_DATE                                   
,cr.REC_ID                                          
from class_relation_cnfg cr
inner join class_cnfg tc on tc.class_name = cr.to_class_name and ec_install_constants.isBlockedAppSpaceCntx(tc.app_space_cntx) = 0
inner join class_cnfg fc on fc.class_name = cr.from_class_name and ec_install_constants.isBlockedAppSpaceCntx(fc.app_space_cntx) = 0
left join class_rel_static psp1 on (cr.from_class_name = psp1.from_class_name and cr.to_class_name = psp1.to_class_name and cr.role_name = psp1.role_name )
left join class_rel_property_max p2 on (cr.from_class_name = p2.from_class_name and cr.to_class_name = p2.to_class_name and cr.role_name = p2.role_name and p2.property_code = 'DB_PRES_SYNTAX' )
left join class_rel_property_max p3 on (cr.from_class_name = p3.from_class_name and cr.to_class_name = p3.to_class_name and cr.role_name = p3.role_name and p3.property_code = 'LABEL' )
where ec_install_constants.isBlockedAppSpaceCntx(cr.app_space_cntx) = 0
--~^UTDELIM^~--

create unique index uix_class_rel_presentation on class_rel_presentation(from_class_name,to_class_name, role_name)
TABLESPACE &ts_index
--~^UTDELIM^~--

CREATE INDEX IR_CLASS_REL_PRESENTATION ON CLASS_REL_PRESENTATION
 (REC_ID)
 INITRANS 2
 MAXTRANS 255
 PCTFREE 50
 STORAGE
 (
   PCTINCREASE 50
   NEXT 65536
 )
 TABLESPACE &ts_index
--~^UTDELIM^~--

DECLARE
BEGIN
  ecdp_viewlayer_utils.buildObjectRelCascadeView;

  UPDATE production_day_version SET production_day_offset_hrs = ecdp_timestamp_utils.timeOffsetToHrs(offset) WHERE production_day_offset_hrs IS NULL;
  
  UPDATE objects_version_table 
  SET    production_day_id = EcDp_Objects.resolveProductionDayId(class_name, object_id, daytime)
  WHERE  production_day_id IS NULL;

  UPDATE objects_version_table 
  SET    time_zone = EcDp_Objects.resolveDomainObjectName('TIME_ZONE_REGION', class_name, object_id, daytime)
  WHERE  time_zone IS NULL;

  COMMIT;
END;
--~^UTDELIM^~--

begin
 execute immediate 'create table RESTORE_OBJECT_DEF(type VARCHAR2(30),table_name VARCHAR2(30),name VARCHAR2(1000),definition CLOB)';
END;
--~^UTDELIM^~--

begin   
 execute immediate 'create sequence utctime_sequence minvalue 1 maxvalue 10000 start with 1 increment by 1 nocache';
END;
--~^UTDELIM^~--

begin
 execute immediate 'create table UTC_TIMEZONE_MASTER(job_no NUMBER,table_name VARCHAR2(40),status VARCHAR2(1) default ''P'')';
END;
--~^UTDELIM^~--

begin
	insert into utc_timezone_master (JOB_NO, TABLE_NAME, STATUS) values (1, 'CNTR_ACC_SUB_DAY_STATUS', 'P');
	insert into utc_timezone_master (JOB_NO, TABLE_NAME, STATUS) values (1, 'CNTR_ACC_SUB_DAY_STATUS_JN', 'P');
	insert into utc_timezone_master (JOB_NO, TABLE_NAME, STATUS) values (1, 'CNTR_SUB_DAY_CAP', 'P');
	insert into utc_timezone_master (JOB_NO, TABLE_NAME, STATUS) values (1, 'CNTR_SUB_DAY_CAP_JN', 'P');
	insert into utc_timezone_master (JOB_NO, TABLE_NAME, STATUS) values (1, 'CNTR_SUB_DAY_DP_AVAIL', 'P');
	insert into utc_timezone_master (JOB_NO, TABLE_NAME, STATUS) values (1, 'CNTR_SUB_DAY_DP_AVAIL_JN', 'P');
	insert into utc_timezone_master (JOB_NO, TABLE_NAME, STATUS) values (1, 'CNTR_SUB_DAY_DP_DELIVERY', 'P');
	insert into utc_timezone_master (JOB_NO, TABLE_NAME, STATUS) values (1, 'CNTR_SUB_DAY_DP_DELIVERY_JN', 'P');
	insert into utc_timezone_master (JOB_NO, TABLE_NAME, STATUS) values (1, 'CNTR_SUB_DAY_DP_FORECAST', 'P');
	insert into utc_timezone_master (JOB_NO, TABLE_NAME, STATUS) values (1, 'CNTR_SUB_DAY_DP_FORECAST_JN', 'P');
	insert into utc_timezone_master (JOB_NO, TABLE_NAME, STATUS) values (1, 'CNTR_SUB_DAY_DP_NOM', 'P');
	insert into utc_timezone_master (JOB_NO, TABLE_NAME, STATUS) values (1, 'CNTR_SUB_DAY_DP_NOM_JN', 'P');
	insert into utc_timezone_master (JOB_NO, TABLE_NAME, STATUS) values (1, 'CNTR_SUB_DAY_DP_SHIP_NOM', 'P');
	insert into utc_timezone_master (JOB_NO, TABLE_NAME, STATUS) values (1, 'CNTR_SUB_DAY_DP_SHIP_NOM_JN', 'P');
	insert into utc_timezone_master (JOB_NO, TABLE_NAME, STATUS) values (1, 'CNTR_SUB_DAY_STATUS', 'P');
	insert into utc_timezone_master (JOB_NO, TABLE_NAME, STATUS) values (1, 'CNTR_SUB_DAY_STATUS_JN', 'P');
	insert into utc_timezone_master (JOB_NO, TABLE_NAME, STATUS) values (1, 'DEFER_LOSS_STRM_EVENT', 'P');
	insert into utc_timezone_master (JOB_NO, TABLE_NAME, STATUS) values (1, 'DEFER_LOSS_STRM_EVENT_JN', 'P');
	insert into utc_timezone_master (JOB_NO, TABLE_NAME, STATUS) values (1, 'DELPNT_SUB_DAY_TARGET', 'P');
	insert into utc_timezone_master (JOB_NO, TABLE_NAME, STATUS) values (1, 'DELPNT_SUB_DAY_TARGET_JN', 'P');
	insert into utc_timezone_master (JOB_NO, TABLE_NAME, STATUS) values (1, 'EQPM_ANALYSIS', 'P');
	insert into utc_timezone_master (JOB_NO, TABLE_NAME, STATUS) values (1, 'EQPM_ANALYSIS_JN', 'P');
	insert into utc_timezone_master (JOB_NO, TABLE_NAME, STATUS) values (1, 'EQPM_EVENT', 'P');
	insert into utc_timezone_master (JOB_NO, TABLE_NAME, STATUS) values (1, 'EQPM_EVENT_JN', 'P');
	insert into utc_timezone_master (JOB_NO, TABLE_NAME, STATUS) values (1, 'EQPM_EVENT_STATUS', 'P');
	insert into utc_timezone_master (JOB_NO, TABLE_NAME, STATUS) values (1, 'EQPM_EVENT_STATUS_JN', 'P');
	insert into utc_timezone_master (JOB_NO, TABLE_NAME, STATUS) values (1, 'EQPM_SUB_DAY_RESTRICTION', 'P');
	insert into utc_timezone_master (JOB_NO, TABLE_NAME, STATUS) values (1, 'EQPM_SUB_DAY_RESTRICTION_JN', 'P');
	insert into utc_timezone_master (JOB_NO, TABLE_NAME, STATUS) values (1, 'FCST_COMPENSATION_EVENTS', 'P');
	insert into utc_timezone_master (JOB_NO, TABLE_NAME, STATUS) values (1, 'FCST_COMPENSATION_EVENTS_JN', 'P');
	insert into utc_timezone_master (JOB_NO, TABLE_NAME, STATUS) values (1, 'WELL_TRANSPORT_EVENT', 'P');
	insert into utc_timezone_master (JOB_NO, TABLE_NAME, STATUS) values (1, 'WELL_TRANSPORT_EVENT_JN', 'P');
	insert into utc_timezone_master (JOB_NO, TABLE_NAME, STATUS) values (1, 'STRM_TRANSPORT_EVENT', 'P');
	insert into utc_timezone_master (JOB_NO, TABLE_NAME, STATUS) values (1, 'STRM_TRANSPORT_EVENT_JN', 'P');
	insert into utc_timezone_master (JOB_NO, TABLE_NAME, STATUS) values (2, 'FCST_LIFT_ACC_ADJ', 'P');
	insert into utc_timezone_master (JOB_NO, TABLE_NAME, STATUS) values (2, 'FCST_LIFT_ACC_ADJ_JN', 'P');
	insert into utc_timezone_master (JOB_NO, TABLE_NAME, STATUS) values (2, 'FCST_LIFT_ACC_ADJ_SINGLE', 'P');
	insert into utc_timezone_master (JOB_NO, TABLE_NAME, STATUS) values (2, 'FCST_LIFT_ACC_ADJ_SINGLE_JN', 'P');
	insert into utc_timezone_master (JOB_NO, TABLE_NAME, STATUS) values (2, 'FCST_NOMPNT_SUB_DAY_EVENT', 'P');
	insert into utc_timezone_master (JOB_NO, TABLE_NAME, STATUS) values (2, 'FCST_NOMPNT_SUB_DAY_EVENT_JN', 'P');
	insert into utc_timezone_master (JOB_NO, TABLE_NAME, STATUS) values (2, 'FLOWLINE_SUB_WELL_CONN', 'P');
	insert into utc_timezone_master (JOB_NO, TABLE_NAME, STATUS) values (2, 'FLOWLINE_SUB_WELL_CONN_JN', 'P');
	insert into utc_timezone_master (JOB_NO, TABLE_NAME, STATUS) values (2, 'FLWL_SUB_DAY_ALLOC', 'P');
	insert into utc_timezone_master (JOB_NO, TABLE_NAME, STATUS) values (2, 'FLWL_SUB_DAY_ALLOC_JN', 'P');
	insert into utc_timezone_master (JOB_NO, TABLE_NAME, STATUS) values (2, 'IFLW_PERIOD_STATUS', 'P');
	insert into utc_timezone_master (JOB_NO, TABLE_NAME, STATUS) values (2, 'IFLW_PERIOD_STATUS_JN', 'P');
	insert into utc_timezone_master (JOB_NO, TABLE_NAME, STATUS) values (2, 'IFLW_SUB_DAY_STATUS', 'P');
	insert into utc_timezone_master (JOB_NO, TABLE_NAME, STATUS) values (2, 'IFLW_SUB_DAY_STATUS_JN', 'P');
	insert into utc_timezone_master (JOB_NO, TABLE_NAME, STATUS) values (2, 'IWEL_PERIOD_STATUS', 'P');
	insert into utc_timezone_master (JOB_NO, TABLE_NAME, STATUS) values (2, 'IWEL_PERIOD_STATUS_JN', 'P');
	insert into utc_timezone_master (JOB_NO, TABLE_NAME, STATUS) values (2, 'IWEL_SUB_DAY_STATUS', 'P');
	insert into utc_timezone_master (JOB_NO, TABLE_NAME, STATUS) values (2, 'IWEL_SUB_DAY_STATUS_JN', 'P');
	insert into utc_timezone_master (JOB_NO, TABLE_NAME, STATUS) values (2, 'LIFT_ACCOUNT_ADJUSTMENT', 'P');
	insert into utc_timezone_master (JOB_NO, TABLE_NAME, STATUS) values (2, 'LIFT_ACCOUNT_ADJUSTMENT_JN', 'P');
	insert into utc_timezone_master (JOB_NO, TABLE_NAME, STATUS) values (2, 'LIFT_ACCOUNT_ADJ_SINGLE', 'P');
	insert into utc_timezone_master (JOB_NO, TABLE_NAME, STATUS) values (2, 'LIFT_ACCOUNT_ADJ_SINGLE_JN', 'P');
	insert into utc_timezone_master (JOB_NO, TABLE_NAME, STATUS) values (2, 'LIFT_ACC_SUB_DAY_BAL_AL', 'P');
	insert into utc_timezone_master (JOB_NO, TABLE_NAME, STATUS) values (2, 'LIFT_ACC_SUB_DAY_BAL_AL_JN', 'P');
	insert into utc_timezone_master (JOB_NO, TABLE_NAME, STATUS) values (2, 'LIFT_ACC_SUB_DAY_FCST_FC', 'P');
	insert into utc_timezone_master (JOB_NO, TABLE_NAME, STATUS) values (2, 'LIFT_ACC_SUB_DAY_FCST_FC_JN', 'P');
	insert into utc_timezone_master (JOB_NO, TABLE_NAME, STATUS) values (2, 'LIFT_ACC_SUB_DAY_FORECAST', 'P');
	insert into utc_timezone_master (JOB_NO, TABLE_NAME, STATUS) values (2, 'LIFT_ACC_SUB_DAY_FORECAST_JN', 'P');
	insert into utc_timezone_master (JOB_NO, TABLE_NAME, STATUS) values (2, 'LIFT_ACC_SUB_DAY_OFFICIAL', 'P');
	insert into utc_timezone_master (JOB_NO, TABLE_NAME, STATUS) values (2, 'LIFT_ACC_SUB_DAY_OFFICIAL_JN', 'P');
	insert into utc_timezone_master (JOB_NO, TABLE_NAME, STATUS) values (2, 'METER_SUB_DAY_MEAS', 'P');
	insert into utc_timezone_master (JOB_NO, TABLE_NAME, STATUS) values (2, 'METER_SUB_DAY_MEAS_JN', 'P');
	insert into utc_timezone_master (JOB_NO, TABLE_NAME, STATUS) values (2, 'MSG_CNTR_SUB_DAY_DP_SHIP', 'P');
	insert into utc_timezone_master (JOB_NO, TABLE_NAME, STATUS) values (2, 'MSG_CNTR_SUB_DAY_DP_SHIP_JN', 'P');
	insert into utc_timezone_master (JOB_NO, TABLE_NAME, STATUS) values (3, 'NOMPNT_SUB_DAY_CONFIRMATION', 'P');
	insert into utc_timezone_master (JOB_NO, TABLE_NAME, STATUS) values (3, 'NOMPNT_SUB_DAY_CONFIRMATION_JN', 'P');
	insert into utc_timezone_master (JOB_NO, TABLE_NAME, STATUS) values (3, 'NOMPNT_SUB_DAY_DELIVERY', 'P');
	insert into utc_timezone_master (JOB_NO, TABLE_NAME, STATUS) values (3, 'NOMPNT_SUB_DAY_DELIVERY_JN', 'P');
	insert into utc_timezone_master (JOB_NO, TABLE_NAME, STATUS) values (3, 'NOMPNT_SUB_DAY_NOMINATION', 'P');
	insert into utc_timezone_master (JOB_NO, TABLE_NAME, STATUS) values (3, 'NOMPNT_SUB_DAY_NOMINATION_JN', 'P');
	insert into utc_timezone_master (JOB_NO, TABLE_NAME, STATUS) values (3, 'OBJECT_PLAN', 'P');
	insert into utc_timezone_master (JOB_NO, TABLE_NAME, STATUS) values (3, 'OBJECT_PLAN_JN', 'P');
	insert into utc_timezone_master (JOB_NO, TABLE_NAME, STATUS) values (3, 'OBJLOC_SUB_DAY_NOMINATION', 'P');
	insert into utc_timezone_master (JOB_NO, TABLE_NAME, STATUS) values (3, 'OBJLOC_SUB_DAY_NOMINATION_JN', 'P');
	insert into utc_timezone_master (JOB_NO, TABLE_NAME, STATUS) values (3, 'OBJLOC_SUB_DAY_TARGET', 'P');
	insert into utc_timezone_master (JOB_NO, TABLE_NAME, STATUS) values (3, 'OBJLOC_SUB_DAY_TARGET_JN', 'P');
	insert into utc_timezone_master (JOB_NO, TABLE_NAME, STATUS) values (3, 'OBJ_TRAN_SUB_DAY_NOM_BOUND', 'P');
	insert into utc_timezone_master (JOB_NO, TABLE_NAME, STATUS) values (3, 'OBJ_TRAN_SUB_DAY_NOM_BOUND_JN', 'P');
	insert into utc_timezone_master (JOB_NO, TABLE_NAME, STATUS) values (3, 'OPLOC_SUB_DAY_RESTRICT', 'P');
	insert into utc_timezone_master (JOB_NO, TABLE_NAME, STATUS) values (3, 'OPLOC_SUB_DAY_RESTRICT_JN', 'P');
	insert into utc_timezone_master (JOB_NO, TABLE_NAME, STATUS) values (3, 'PERF_PERIOD_STATUS', 'P');
	insert into utc_timezone_master (JOB_NO, TABLE_NAME, STATUS) values (3, 'PERF_PERIOD_STATUS_JN', 'P');
	insert into utc_timezone_master (JOB_NO, TABLE_NAME, STATUS) values (3, 'PFLW_SAMPLE', 'P');
	insert into utc_timezone_master (JOB_NO, TABLE_NAME, STATUS) values (3, 'PFLW_SAMPLE_JN', 'P');
	insert into utc_timezone_master (JOB_NO, TABLE_NAME, STATUS) values (3, 'PFLW_SUB_DAY_STATUS', 'P');
	insert into utc_timezone_master (JOB_NO, TABLE_NAME, STATUS) values (3, 'PFLW_SUB_DAY_STATUS_JN', 'P');
	insert into utc_timezone_master (JOB_NO, TABLE_NAME, STATUS) values (3, 'PIPE_PC_TRANSACTION', 'P');
	insert into utc_timezone_master (JOB_NO, TABLE_NAME, STATUS) values (3, 'PIPE_PC_TRANSACTION_JN', 'P');
	insert into utc_timezone_master (JOB_NO, TABLE_NAME, STATUS) values (3, 'PIPE_PIGGING_EVENT', 'P');
	insert into utc_timezone_master (JOB_NO, TABLE_NAME, STATUS) values (3, 'PIPE_PIGGING_EVENT_JN', 'P');
	insert into utc_timezone_master (JOB_NO, TABLE_NAME, STATUS) values (3, 'PIPE_SUB_DAY_ALLOC', 'P');
	insert into utc_timezone_master (JOB_NO, TABLE_NAME, STATUS) values (3, 'PIPE_SUB_DAY_ALLOC_JN', 'P');
	insert into utc_timezone_master (JOB_NO, TABLE_NAME, STATUS) values (3, 'PIPE_SUB_DAY_PC_ALLOC', 'P');
	insert into utc_timezone_master (JOB_NO, TABLE_NAME, STATUS) values (3, 'PIPE_SUB_DAY_PC_ALLOC_JN', 'P');
	insert into utc_timezone_master (JOB_NO, TABLE_NAME, STATUS) values (3, 'PIPE_SUB_DAY_PC_STATUS', 'P');
	insert into utc_timezone_master (JOB_NO, TABLE_NAME, STATUS) values (3, 'PIPE_SUB_DAY_PC_STATUS_JN', 'P');
	insert into utc_timezone_master (JOB_NO, TABLE_NAME, STATUS) values (3, 'PRICE_INDEX_SUB_DAY_VALUE', 'P');
	insert into utc_timezone_master (JOB_NO, TABLE_NAME, STATUS) values (3, 'PRICE_INDEX_SUB_DAY_VALUE_JN', 'P');
	insert into utc_timezone_master (JOB_NO, TABLE_NAME, STATUS) values (4, 'PROD_PRICE_SUB_DAY_VALUE', 'P');
	insert into utc_timezone_master (JOB_NO, TABLE_NAME, STATUS) values (4, 'PROD_PRICE_SUB_DAY_VALUE_JN', 'P');
	insert into utc_timezone_master (JOB_NO, TABLE_NAME, STATUS) values (4, 'PSEP_SUB_DAY_STATUS', 'P');
	insert into utc_timezone_master (JOB_NO, TABLE_NAME, STATUS) values (4, 'PSEP_SUB_DAY_STATUS_JN', 'P');
	insert into utc_timezone_master (JOB_NO, TABLE_NAME, STATUS) values (4, 'PTST_EVENT', 'P');
	insert into utc_timezone_master (JOB_NO, TABLE_NAME, STATUS) values (4, 'PTST_EVENT_JN', 'P');
	insert into utc_timezone_master (JOB_NO, TABLE_NAME, STATUS) values (4, 'PWEL_PERIOD_STATUS', 'P');
	insert into utc_timezone_master (JOB_NO, TABLE_NAME, STATUS) values (4, 'PWEL_PERIOD_STATUS_JN', 'P');
	insert into utc_timezone_master (JOB_NO, TABLE_NAME, STATUS) values (4, 'PWEL_SAMPLE', 'P');
	insert into utc_timezone_master (JOB_NO, TABLE_NAME, STATUS) values (4, 'PWEL_SAMPLE_JN', 'P');
	insert into utc_timezone_master (JOB_NO, TABLE_NAME, STATUS) values (4, 'PWEL_SUB_DAY_ALLOC', 'P');
	insert into utc_timezone_master (JOB_NO, TABLE_NAME, STATUS) values (4, 'PWEL_SUB_DAY_ALLOC_JN', 'P');
	insert into utc_timezone_master (JOB_NO, TABLE_NAME, STATUS) values (4, 'PWEL_SUB_DAY_STATUS', 'P');
	insert into utc_timezone_master (JOB_NO, TABLE_NAME, STATUS) values (4, 'PWEL_SUB_DAY_STATUS_JN', 'P');
	insert into utc_timezone_master (JOB_NO, TABLE_NAME, STATUS) values (4, 'SEPA_SUB_DAY_ALLOC', 'P');
	insert into utc_timezone_master (JOB_NO, TABLE_NAME, STATUS) values (4, 'SEPA_SUB_DAY_ALLOC_JN', 'P');
	insert into utc_timezone_master (JOB_NO, TABLE_NAME, STATUS) values (4, 'SEPA_SUB_DAY_PC_ALLOC', 'P');
	insert into utc_timezone_master (JOB_NO, TABLE_NAME, STATUS) values (4, 'SEPA_SUB_DAY_PC_ALLOC_JN', 'P');
	insert into utc_timezone_master (JOB_NO, TABLE_NAME, STATUS) values (4, 'STOR_FCST_SUB_DAY_LIFT_NOM', 'P');
	insert into utc_timezone_master (JOB_NO, TABLE_NAME, STATUS) values (4, 'STOR_FCST_SUB_DAY_LIFT_NOM_JN', 'P');
	insert into utc_timezone_master (JOB_NO, TABLE_NAME, STATUS) values (4, 'STOR_SUB_DAY_BAL_ALLOC', 'P');
	insert into utc_timezone_master (JOB_NO, TABLE_NAME, STATUS) values (4, 'STOR_SUB_DAY_BAL_ALLOC_JN', 'P');
	insert into utc_timezone_master (JOB_NO, TABLE_NAME, STATUS) values (4, 'STOR_SUB_DAY_FCST_FCAST', 'P');
	insert into utc_timezone_master (JOB_NO, TABLE_NAME, STATUS) values (4, 'STOR_SUB_DAY_FCST_FCAST_JN', 'P');
	insert into utc_timezone_master (JOB_NO, TABLE_NAME, STATUS) values (4, 'STOR_SUB_DAY_FORECAST', 'P');
	insert into utc_timezone_master (JOB_NO, TABLE_NAME, STATUS) values (4, 'STOR_SUB_DAY_FORECAST_JN', 'P');
	insert into utc_timezone_master (JOB_NO, TABLE_NAME, STATUS) values (4, 'STOR_SUB_DAY_LIFT_NOM', 'P');
	insert into utc_timezone_master (JOB_NO, TABLE_NAME, STATUS) values (4, 'STOR_SUB_DAY_LIFT_NOM_JN', 'P');
	insert into utc_timezone_master (JOB_NO, TABLE_NAME, STATUS) values (4, 'STOR_SUB_DAY_OFFICIAL', 'P');
	insert into utc_timezone_master (JOB_NO, TABLE_NAME, STATUS) values (4, 'STOR_SUB_DAY_OFFICIAL_JN', 'P');
	insert into utc_timezone_master (JOB_NO, TABLE_NAME, STATUS) values (4, 'STOR_SUB_DAY_PC_FCST', 'P');
	insert into utc_timezone_master (JOB_NO, TABLE_NAME, STATUS) values (4, 'STOR_SUB_DAY_PC_FCST_JN', 'P');
	insert into utc_timezone_master (JOB_NO, TABLE_NAME, STATUS) values (4, 'STRM_EVENT', 'P');
	insert into utc_timezone_master (JOB_NO, TABLE_NAME, STATUS) values (4, 'STRM_EVENT_JN', 'P');
	insert into utc_timezone_master (JOB_NO, TABLE_NAME, STATUS) values (5, 'STRM_SAMPLE', 'P');
	insert into utc_timezone_master (JOB_NO, TABLE_NAME, STATUS) values (5, 'STRM_SAMPLE_JN', 'P');
	insert into utc_timezone_master (JOB_NO, TABLE_NAME, STATUS) values (5, 'STRM_SUB_DAY_ALLOC', 'P');
	insert into utc_timezone_master (JOB_NO, TABLE_NAME, STATUS) values (5, 'STRM_SUB_DAY_ALLOC_JN', 'P');
	insert into utc_timezone_master (JOB_NO, TABLE_NAME, STATUS) values (5, 'STRM_SUB_DAY_CPYCP_ALLOC', 'P');
	insert into utc_timezone_master (JOB_NO, TABLE_NAME, STATUS) values (5, 'STRM_SUB_DAY_CPYCP_ALLOC_JN', 'P');
	insert into utc_timezone_master (JOB_NO, TABLE_NAME, STATUS) values (5, 'STRM_SUB_DAY_CPY_ALLOC', 'P');
	insert into utc_timezone_master (JOB_NO, TABLE_NAME, STATUS) values (5, 'STRM_SUB_DAY_CPY_ALLOC_JN', 'P');
	insert into utc_timezone_master (JOB_NO, TABLE_NAME, STATUS) values (5, 'STRM_SUB_DAY_CP_ALLOC', 'P');
	insert into utc_timezone_master (JOB_NO, TABLE_NAME, STATUS) values (5, 'STRM_SUB_DAY_CP_ALLOC_JN', 'P');
	insert into utc_timezone_master (JOB_NO, TABLE_NAME, STATUS) values (5, 'STRM_SUB_DAY_PCCPY_ALLOC', 'P');
	insert into utc_timezone_master (JOB_NO, TABLE_NAME, STATUS) values (5, 'STRM_SUB_DAY_PCCPY_ALLOC_JN', 'P');
	insert into utc_timezone_master (JOB_NO, TABLE_NAME, STATUS) values (5, 'STRM_SUB_DAY_PC_ALLOC', 'P');
	insert into utc_timezone_master (JOB_NO, TABLE_NAME, STATUS) values (5, 'STRM_SUB_DAY_PC_ALLOC_JN', 'P');
	insert into utc_timezone_master (JOB_NO, TABLE_NAME, STATUS) values (5, 'STRM_SUB_DAY_PC_CP_ALLOC', 'P');
	insert into utc_timezone_master (JOB_NO, TABLE_NAME, STATUS) values (5, 'STRM_SUB_DAY_PC_CP_ALLOC_JN', 'P');
	insert into utc_timezone_master (JOB_NO, TABLE_NAME, STATUS) values (5, 'STRM_SUB_DAY_SCHEME', 'P');
	insert into utc_timezone_master (JOB_NO, TABLE_NAME, STATUS) values (5, 'STRM_SUB_DAY_SCHEME_JN', 'P');
	insert into utc_timezone_master (JOB_NO, TABLE_NAME, STATUS) values (5, 'STRM_SUB_DAY_STATUS', 'P');
	insert into utc_timezone_master (JOB_NO, TABLE_NAME, STATUS) values (5, 'STRM_SUB_DAY_STATUS_JN', 'P');
	insert into utc_timezone_master (JOB_NO, TABLE_NAME, STATUS) values (5, 'STRM_WELL_CONN', 'P');
	insert into utc_timezone_master (JOB_NO, TABLE_NAME, STATUS) values (5, 'STRM_WELL_CONN_JN', 'P');
	insert into utc_timezone_master (JOB_NO, TABLE_NAME, STATUS) values (5, 'TEST_DEVICE_SAMPLE', 'P');
	insert into utc_timezone_master (JOB_NO, TABLE_NAME, STATUS) values (5, 'TEST_DEVICE_SAMPLE_JN', 'P');
	insert into utc_timezone_master (JOB_NO, TABLE_NAME, STATUS) values (5, 'WBI_SAMPLE', 'P');
	insert into utc_timezone_master (JOB_NO, TABLE_NAME, STATUS) values (5, 'WBI_SAMPLE_JN', 'P');
	insert into utc_timezone_master (JOB_NO, TABLE_NAME, STATUS) values (5, 'WBI_SUB_DAY_STATUS', 'P');
	insert into utc_timezone_master (JOB_NO, TABLE_NAME, STATUS) values (5, 'WBI_SUB_DAY_STATUS_JN', 'P');
	insert into utc_timezone_master (JOB_NO, TABLE_NAME, STATUS) values (5, 'WELL_EVENT', 'P');
	insert into utc_timezone_master (JOB_NO, TABLE_NAME, STATUS) values (5, 'WELL_EVENT_JN', 'P');
	insert into utc_timezone_master (JOB_NO, TABLE_NAME, STATUS) values (5, 'WELL_PERIOD_TOTALIZER', 'P');
	insert into utc_timezone_master (JOB_NO, TABLE_NAME, STATUS) values (5, 'WELL_PERIOD_TOTALIZER_JN', 'P');
	insert into utc_timezone_master (JOB_NO, TABLE_NAME, STATUS) values (5, 'WELL_SWING_CONNECTION', 'P');
	insert into utc_timezone_master (JOB_NO, TABLE_NAME, STATUS) values (5, 'WELL_SWING_CONNECTION_JN', 'P');

	commit;
end;
--~^UTDELIM^~--

CREATE OR REPLACE PACKAGE ecdp_localtimestamp IS
	FUNCTION local2utc( p_daytime DATE, p_timezone varchar2) RETURN DATE;
END ecdp_localtimestamp;
--~^UTDELIM^~--

CREATE OR REPLACE PACKAGE BODY ecdp_localtimestamp IS

FUNCTION local2utc( p_daytime DATE, p_timezone varchar2) RETURN DATE IS
  ld_return_date    DATE;
BEGIN

  BEGIN
    ld_return_date := CAST(FROM_TZ(CAST(p_daytime AS TIMESTAMP), p_timezone) AT TIME ZONE 'UTC' AS DATE);
  EXCEPTION WHEN OTHERS THEN
    IF SQLCODE = -1878 THEN
     -- Invalid date. Return NULL, according to previous code
     ld_return_date := NULL;
    ELSE
      RAISE;
    END IF;
  END;

  RETURN ld_return_date;
END local2utc;

END ecdp_localtimestamp;
--~^UTDELIM^~--

CREATE OR REPLACE PACKAGE populate_utc_timezone IS
  /**************************************************************
  ** Package:    temp_copyRenameTable
  **
  ** $Revision: 1.14 $
  **
  ** Filename:   temp_copyRenameTable-head.sql
  **
  ** Part of :   Upgrade 12.1
  **
  ** Purpose:
  **
  ** General Logic:
  **
  ** Document References:
  **
  **
  ** Created:   21.12.98  Arild Vervik, ISI AS
  ** Modified:  22.11.18  Gaurav Parmani
  **
  **************************************************************/

  PROCEDURE utctime_update(p_table_name varchar2,
                              p_timezone   varchar2,
                              p_tablespace varchar2);
    PROCEDURE executeJob(p_job_no number);

END;
--~^UTDELIM^~--

CREATE OR REPLACE PACKAGE BODY populate_utc_timezone IS

  syntax_error EXCEPTION;
  P_PRIMARY_KEY       VARCHAR2(30) := 'PRIMARY_KEY';
  P_FOREIGN_KEY       VARCHAR2(30) := 'FOREIGN_KEY';
  P_CHILD_FOREIGN_KEY VARCHAR2(30) := 'CHILD_FOREIGN_KEY';
  P_UNIQUE_KEY        VARCHAR2(30) := 'UNIQUE_KEY';
  P_CHECK_CONS        VARCHAR2(30) := 'CHECK_CONSTRAINT';
  P_INDEXES           VARCHAR2(30) := 'INDEXES';
  P_TRIGGER           VARCHAR2(30) := 'TRIGGER';
  P_COMMENT           VARCHAR2(30) := 'COMMENT';
  P_COL_COMMENT       VARCHAR2(30) := 'COLUMN_COMMENT';
  P_DEFAULT_VALUE     VARCHAR2(30) := 'DEFAULT_VALUE';
  p_seq_no            number;
  v_sql               varchar2(1000);
  p_count             number;
  v_utc_end_date      number;
  v_summer_time       number;
  v_end_summer_time   number;
  l_exception EXCEPTION;
  PRAGMA EXCEPTION_INIT(l_exception, -01442);

  PROCEDURE executeJob(p_job_no number) IS

    lv2_timezone   varchar2(100);
    lv2_tablespace varchar2(100);

  BEGIN

   select pref_verdi into lv2_timezone  from t_preferanse where pref_id = 'TIME_ZONE_REGION';
   select pref_verdi into lv2_tablespace  from t_preferanse where pref_id = 'TS_DATA';

    for i in (select table_name from UTC_TIMEZONE_MASTER a
               where a.job_no = p_job_no and status = 'P') loop

      v_sql := 'select count(1) from ' || i.table_name ||
               ' where rownum<2 ';

      execute immediate v_sql into p_count;

      if p_count <> 0 then

        BEGIN

          ecdp_dynsql.WriteTempText(i.table_name, '--- Executing Job ----' || p_job_no || ' for table ' || i.table_name);
          utctime_update(i.TABLE_NAME, lv2_timezone, lv2_tablespace);

          update UTC_TIMEZONE_MASTER set status = 'C' where job_no = p_job_no and table_name = i.table_name;
        EXCEPTION
          WHEN OTHERS THEN
            update UTC_TIMEZONE_MASTER set status = 'F' where job_no = p_job_no and table_name = i.table_name;

        END;

      else

        ecdp_dynsql.WriteTempText(i.table_name,'Count is 0 for table : ' || i.table_name);
        update UTC_TIMEZONE_MASTER set status = 'N' where job_no = p_job_no and table_name = i.table_name;

      end if;

      commit;

    END LOOP; -- exit when all tables data has been proceed

  END executeJob;

  PROCEDURE restore_objects(P_TABLE_NAME VARCHAR2, P_NAME VARCHAR2) is

    CURSOR c_RESTORE_OBJECT_DEF IS
      SELECT * FROM RESTORE_OBJECT_DEF Y WHERE Y.TYPE = P_NAME and y.table_name=P_TABLE_NAME;

  begin

    FOR i in c_RESTORE_OBJECT_DEF LOOP
      Begin
        ecdp_dynsql.WriteTempText(i.table_name,'Restore  :: ' || P_NAME || ' Name :: ' || i.name);
        execute immediate i.Definition;
      Exception
        when l_exception then
          null;
        when others then
          ecdp_dynsql.WriteTempText(p_table_name,'ERROR while Restoring ' || P_NAME ||
           ' for :: ' || p_table_name || ' ' || sqlcode || ' ' || sqlerrm);
      end;
    END LOOP;
  end;

  --<EC-DOC>
  ---------------------------------------------------------------------------------------------------
  -- function       : utctime_update
  -- Description    : Copy table content to a new table including population of UTC_DAYTIME based on
  --                   DAYTIME, summertime flag and UTC_END_DATE based on ENDDATE,end summertime flag
  --
  -- Preconditions  : Table has OBJECT_ID, DAYTIME,, SUMMER_TIME,,UTC_DAYTIME
  --                  columns, according to EC standard
  --                  Tables which have END_DATE has UTC_END_DATE column.Also END_SUMMERTIME is present as per the applicability
  --                  All DAYTIME and END_DATE values is valid for assosiated time_zone.
  --
  --
  --
  -- Postcondition  : UTC_DAYTIME and UTC_END_DATE is populated and all triggers, constraints, indexes which are lost
  --                  during population are regenerated after the population is done.
  -- Using Tables   :
  --
  -- Using functions:
  --
  -- Configuration
  -- required       :
  --
  -- Behavior      :
  --
  ---------------------------------------------------------------------------------------------------

  --</EC-DOC>

  PROCEDURE utctime_update(p_table_name varchar2,
                           p_timezone   varchar2,
                           p_tablespace varchar2) is

    cursor c_table_columns is
      select column_name from user_tab_columns where table_name = p_table_name
             and column_name not in  ('OBJECT_ID', 'UTC_DAYTIME', 'UTC_END_DATE') order by COLUMN_ID;

    cursor c_indexes is
      select * from user_indexes a where table_name = p_table_name
      and not exists(select 1 from user_constraints b where b.CONSTRAINT_NAME = a.INDEX_NAME);

    cursor c_triggers is
       SELECT TRIGGER_NAME NAME,REPLACE(REPLACE(TRIM(BOTH ' ' FROM TRIM(
       BOTH CHR(13) FROM TRIM(BOTH CHR(10) FROM REPLACE(DBMS_METADATA.GET_DDL('TRIGGER',TRIGGER_NAME),'"' || USER || '".',''))))
       ,'ALTER TRIGGER "' || TRIGGER_NAME || '" ENABLE'),'ALTER TRIGGER "' || TRIGGER_NAME || '" DISABLE') TEXT
       FROM USER_TRIGGERS WHERE taBLE_name = p_table_name ORDER BY TRIGGER_NAME;

    cursor c_fk_cons is
      select uc1.constraint_name,uc1.table_name,uc2.table_name reference_table,uc2.CONSTRAINT_NAME reference_cons_name
       from user_constraints uc1, user_constraints uc2 where uc1.table_name = p_table_name
       and uc1.constraint_type = 'R' and uc2.constraint_name = uc1.r_constraint_name;

     cursor c_child_cons is
         select uc1.constraint_name,uc1.table_name,uc2.table_name reference_table,uc2.CONSTRAINT_NAME reference_cons_name
         from user_constraints uc1, user_constraints uc2
         where uc2.table_name =p_table_name and uc1.constraint_type = 'R'
         and uc2.constraint_name = uc1.r_constraint_name
         AND uc1.TABLE_NAME<>uc2.TABLE_NAME;

    cursor c_pk_cons is
      select * from user_constraints uc1
      where uc1.table_name = p_table_name
      and uc1.constraint_type = 'P';

    cursor c_uk_cons is
      select * from user_constraints uc1
      where uc1.table_name = p_table_name
      and uc1.constraint_type = 'U';

    cursor c_check_cons is
      select * from user_constraints uc1
       where uc1.table_name = p_table_name
       and uc1.constraint_type = 'C';

   cursor c_comments is
       select c.TABLE_NAME, c.COMMENTS from user_tab_comments c where
       c.TABLE_NAME = p_table_name AND C.COMMENTS is not null;

   cursor c_col_comments is
       select c.TABLE_NAME, c.COLUMN_NAME, c.COMMENTS from user_col_comments c
       where c.TABLE_NAME = p_table_name AND C.COMMENTS is not null;

   cursor c_time_zones is
      select time_zone from objects_version_table o
      where time_zone <> p_timezone
      group by time_zone
      order by time_zone;

   cursor c_default_value is
       select a.TABLE_NAME,a.COLUMN_NAME,a.DATA_DEFAULT from user_tab_columns a where
       a.table_name =p_table_name and data_default is not null;

    lv2_columns varchar2(32000);
    lv2_sql     varchar2(32000);
    lv3_sql     varchar2(32000);

    TYPE l_tab is table of VARCHAR2(2000);
    lv2_tz_offset    varchar2(10);
    ln_originalcount number;
    ln_newcount      number;
    l_sql            varchar2(2000);
    l_col_tab        l_tab;
    r_col_tab        l_tab;
    l_child_col_tab  l_tab;
    r_child_col_tab  l_tab;
    l_columns        varchar2(4000);
    r_columns        varchar2(4000);
    l_child_columns  varchar2(4000);
    r_child_columns        varchar2(4000);

  begin

    select utctime_sequence.nextval into p_seq_no from dual;

    ecdp_dynsql.WriteTempText(p_table_name,'Fetching Index Definition :: ' || p_table_name);

    FOR i in c_indexes LOOP
      insert into RESTORE_OBJECT_DEF
      values
        (P_INDEXES,
         p_table_name,
         i.index_name,
         dbms_metadata.get_ddl('INDEX', i.index_name));
      commit;
    END LOOP;

     ecdp_dynsql.WriteTempText(p_table_name,'Fetching Column Default Value Definition for :: ' || p_table_name);

    FOR i in c_default_value LOOP
      insert into RESTORE_OBJECT_DEF values
      (P_DEFAULT_VALUE,p_table_name,null,'alter table ' || i.TABLE_NAME || ' modify ' || i.COLUMN_NAME || ' default ' ||  i.DATA_DEFAULT);
   END LOOP;

    ecdp_dynsql.WriteTempText(p_table_name,'Fetching Table Comments Definition :: ' || p_table_name);

    FOR i in c_comments LOOP
      insert into RESTORE_OBJECT_DEF values
        (P_COMMENT,p_table_name,null,'Comment on Table ' || i.table_name || ' is ''' || i.comments || '''');
    END LOOP;

    ecdp_dynsql.WriteTempText(p_table_name,'Fetching Table Column Comments Definition :: '
      ||  p_table_name);

    FOR i in c_col_comments LOOP
      insert into RESTORE_OBJECT_DEF
      values
        (P_COL_COMMENT,p_table_name,i.column_name, 'Comment on Column ' || i.table_name || '.' || i.column_name || ' is ''' || i.comments || '''');
    END LOOP;

    ecdp_dynsql.WriteTempText(p_table_name, 'Fetching Trigger Definition');

    FOR i in c_triggers LOOP
      insert into RESTORE_OBJECT_DEF
      values
        (P_TRIGGER, p_table_name, i.name, i.text);
    END LOOP;

    ecdp_dynsql.WriteTempText(p_table_name,
                              'Fetching Foreign Key constraint :: ' ||
                              p_table_name);

    FOR i in c_fk_cons LOOP
      BEGIN
        select column_name bulk collect into l_col_tab
          from user_cons_columns ucc where constraint_name = i.constraint_name order by ucc.POSITION;

         select column_name bulk collect into r_col_tab
          from user_cons_columns ucc where constraint_name = i.reference_cons_name order by ucc.POSITION;
      EXCEPTION
        WHEN OTHERS THEN
       ecdp_dynsql.WriteTempText(p_table_name,'ERROR while fetching foreign key columns for '
        || p_table_name || ' ' || sqlcode || sqlerrm);
      END;

      l_columns := '';
      r_columns := '';

     FOR j in 1 .. l_col_tab.count LOOP
        l_columns := l_columns || l_col_tab(j);
        if (j <> l_col_tab.count) then
          l_columns := l_columns || ',';
        end if;
      END LOOP;

       FOR k in 1 .. r_col_tab.count LOOP
        r_columns := r_columns || r_col_tab(k);
        if (k <> r_col_tab.count) then
          r_columns := r_columns || ',';
        end if;
      END LOOP;

      l_sql := 'ALTER TABLE ' || i.table_name || ' ADD CONSTRAINT ' ||
               i.constraint_name || ' FOREIGN KEY (' || l_columns ||
               ') REFERENCES ' || i.reference_table || '( ' || r_columns || ')';

      insert into RESTORE_OBJECT_DEF
      values
        (P_FOREIGN_KEY, p_table_name, i.constraint_name, l_sql);
    END LOOP;

    ecdp_dynsql.WriteTempText(p_table_name,'Fetching Child Table constraint for  :: ' || p_table_name);

    FOR i in c_child_cons LOOP
      BEGIN
        select column_name  bulk collect into l_child_col_tab
        from user_cons_columns ucc where constraint_name = i.constraint_name order by ucc.POSITION;

        select column_name bulk collect into r_child_col_tab
        from user_cons_columns ucc where constraint_name = i.reference_cons_name order by ucc.POSITION;

      EXCEPTION
        WHEN OTHERS THEN
        ecdp_dynsql.WriteTempText(p_table_name,'ERROR while fetching child foreign key columns for '
        || p_table_name || sqlcode || sqlerrm);
      END;
      l_child_columns := '';
      r_child_columns := '';

      FOR j in 1 .. l_child_col_tab.count LOOP
        l_child_columns := l_child_columns || l_child_col_tab(j);
        if (j <> l_child_col_tab.count) then
          l_child_columns := l_child_columns || ',';
        end if;
      END LOOP;

       FOR h in 1 .. r_child_col_tab.count LOOP
        r_child_columns := r_child_columns || r_child_col_tab(h);
        if (h <> r_child_col_tab.count) then
          r_child_columns := r_child_columns || ',';
        end if;
      END LOOP;

      l_sql := 'ALTER TABLE ' || i.table_name || ' ADD CONSTRAINT ' ||
               i.constraint_name || ' FOREIGN KEY (' || l_child_columns ||
               ') REFERENCES ' || i.reference_table || '( ' ||
               r_child_columns || ')';

      insert into RESTORE_OBJECT_DEF
      values
        (P_CHILD_FOREIGN_KEY, p_table_name, i.constraint_name, l_sql);
    END LOOP;

    ecdp_dynsql.WriteTempText(p_table_name,
                              'Fetching Primary Key constraint :: ' ||
                              p_table_name);
    FOR i in c_pk_cons LOOP
      BEGIN
        select column_name bulk collect into l_col_tab
        from user_cons_columns ucc where constraint_name = i.constraint_name ORDER BY UCC.POSITION;
      EXCEPTION
        WHEN OTHERS THEN
           ecdp_dynsql.WriteTempText(p_table_name,'ERROR while fetching primary key columns for '
        || p_table_name || sqlcode || sqlerrm);
      END;
      l_columns := '';

      FOR j in 1 .. l_col_tab.count LOOP
        l_columns := l_columns || l_col_tab(j);
        if (j <> l_col_tab.count) then
          l_columns := l_columns || ',';
        end if;
      END LOOP;

      l_sql := 'ALTER TABLE ' || i.table_name || ' ADD CONSTRAINT ' ||
               i.constraint_name || ' PRIMARY KEY (' || l_columns || ')';
      insert into RESTORE_OBJECT_DEF
      values
        (P_PRIMARY_KEY, p_table_name, i.constraint_name, l_sql);

    END LOOP;

    ecdp_dynsql.WriteTempText(p_table_name,'Fetching Unique Key constraint :: ' || p_table_name);

    FOR i in c_uk_cons LOOP
      BEGIN
        select column_name bulk collect into l_col_tab
        from user_cons_columns ucc  where constraint_name = i.constraint_name ORDER BY UCC.POSITION;
      EXCEPTION
        WHEN OTHERS THEN
            ecdp_dynsql.WriteTempText(p_table_name,'ERROR while fetching unique
             key columns for ' || p_table_name || sqlcode || sqlerrm);
      END;
      l_columns := '';

      FOR j in 1 .. l_col_tab.count LOOP
        l_columns := l_columns || l_col_tab(j);
        if (j <> l_col_tab.count) then
          l_columns := l_columns || ',';
        end if;
      END LOOP;

      l_sql := 'ALTER TABLE ' || i.table_name || ' ADD CONSTRAINT ' ||
               i.constraint_name || ' UNIQUE (' || l_columns || ')';
      insert into RESTORE_OBJECT_DEF
      values
        (P_UNIQUE_KEY, p_table_name, i.constraint_name, l_sql);

    END LOOP;

    ecdp_dynsql.WriteTempText(p_table_name,'Fetching Check constraints :: ' || p_table_name);
    FOR i in c_check_cons LOOP
      insert into RESTORE_OBJECT_DEF
      values
        (P_CHECK_CONS,
         p_table_name,
         i.constraint_name,
         dbms_metadata.get_ddl('CONSTRAINT', i.constraint_name));
    END LOOP;

    commit;

    -- Assuming that the majority of the objects initially will have the given time_zone (system default) the strategy is
    -- to populate the table with UTC based on that time zone, and ignoring the summertime flag
    -- will fix these rows afterwards together with objects belonging to other time zones
    -- Measurements indicates that is it is faster to have simple functions in the create table select that is correct for most of the rows,
    -- rather than checking each row for special handeling.

    --  lv2_columns := 'OBJECT_ID, CAST(FROM_TZ(CAST(daytime AS localtimestamp), '''||p_timezone||''') AT TIME ZONE ''UTC'' AS DATE) as UTC_DAYTIME ';
    --  Using function call here to handle if the daytime localtimestamp is not valid for the default time zone, this can happen on spring daylight saving
    --  if there are some objects belonging to another time zone, or there are ERRORs in the data.
    begin

       select count(1) into v_utc_end_date from user_tab_columns y where y.TABLE_NAME=p_table_name
       and y.COLUMN_NAME='UTC_END_DATE';

       select count(1) into v_summer_time from user_tab_columns y where y.TABLE_NAME=p_table_name
       and y.COLUMN_NAME='SUMMER_TIME';

       select count(1) into v_end_summer_time from user_tab_columns y where y.TABLE_NAME=p_table_name
       and y.COLUMN_NAME='END_SUMMER_TIME';

      lv2_columns := 'OBJECT_ID, EcDp_localTimestamp.local2utc(daytime,''' ||
                     p_timezone || ''') as UTC_DAYTIME ';

      If v_utc_end_date <> 0 then
        lv2_columns := lv2_columns || ',EcDp_localTimestamp.local2utc(end_date,''' ||
                       p_timezone || ''') as UTC_END_DATE';

      end if;

    end;

    FOR curCol in c_table_columns LOOP

      lv2_columns := lv2_columns || ', ' || curCol.column_name;

    END LOOP;

    -- It will still work if the table is empty, to complext to differensiate if the rowcount is small
    -- Assuming that the majority of rows will be in the default time zone, don't try to filter here copy all rows and the update for the exceptions
    -- Have tried the other approach and even with a nologging approach it is much slower
    lv2_sql := 'CREATE TABLE TEMP_TAB_' || p_seq_no || ' tablespace ' ||  p_tablespace || ' NOLOGGING AS
                SELECT ' || lv2_columns || ' FROM ' || p_table_name || ' t ';

    begin
      ecdp_dynsql.WriteTempText(p_table_name,'Creating Temperory table for :: ' || p_table_name);
      EXECUTE IMMEDIATE lv2_sql;
    exception
      when others then
        ecdp_dynsql.WriteTempText(p_table_name,'ERROR while Creating Temperory table for :: ' || p_table_name || sqlcode || sqlerrm);
    end;
    

    -- Update UTC_DAYTIME and UTC_END_DATE for the objects linked with another time zone
    FOR curTZ in c_time_zones LOOP

      -- Update UTC_DAYTIME by default for other timezone
      lv2_sql := 'UPDATE TEMP_TAB_' || p_seq_no ||
                 '  t set UTC_DAYTIME = ecdp_localtimestamp.local2utc(daytime,''' ||
                 curTZ.time_zone || ''') ';
      lv2_sql := lv2_sql ||
                 ' WHERE exists (select 1 from objects_version_table o ';
      lv2_sql := lv2_sql ||
                 ' where o.object_id  = t.object_id and t.daytime >= o.daytime and t.daytime < nvl(o.end_date,t.daytime+1) and o.time_zone = ''' ||
                 curTZ.time_zone || ''')';

      begin
        ecdp_dynsql.WriteTempText(p_table_name,'Updating UTC daytime for other timezone :: ' || lv2_sql);
        EXECUTE IMMEDIATE lv2_sql;
      exception
        when others then
          ecdp_dynsql.WriteTempText(p_table_name,'ERROR while Updating UTC daytime for other timezone :: ' || lv2_sql || sqlcode || sqlerrm);
      end;

      -- Update UTC_END_DATE by default for other timezone
      IF v_utc_end_date <> 0 then

        lv3_sql := 'UPDATE TEMP_TAB_' || p_seq_no ||
                   '  t set UTC_END_DATE = ecdp_localtimestamp.local2utc(END_DATE,''' || curTZ.time_zone || ''') ';
        lv3_sql := lv3_sql ||
                   ' WHERE exists (select 1 from objects_version_table o ';
        lv3_sql := lv3_sql ||
                   ' where o.object_id  = t.object_id and t.daytime >= o.daytime and t.daytime < nvl(o.end_date,t.daytime+1) and o.time_zone = ''' ||
                   curTZ.time_zone || ''')';
        begin
          ecdp_dynsql.WriteTempText(p_table_name,'Updating UTC end date for other timezone :: ' || lv3_sql);
          EXECUTE IMMEDIATE lv3_sql;
        exception
          when others then
            ecdp_dynsql.WriteTempText(p_table_name,
                                      'ERROR while Updating UTC end date for other timezone :: ' ||
                                      lv3_sql || sqlcode || sqlerrm);
        end;
      END IF;
    END LOOP;
    
    -- Handling the overlapping hour in authum when daylight saving is turned off, and we get duplicate records,
    -- Ignoring for now that there are some odd time zones where the offset is changing with other than 1 hour
    -- the default handeling over will do it correct for the winter time records, but we need to correct the summer_time = 'Y'
    -- The twist here is that it west of UTC time zone we need to add one hour going from local to utc    
    lv2_tz_offset := '-1/24';
      
    -- Need to correct the overlapping hour of UTC_DAYTIME column for all timezones
    IF v_summer_time <> 0 then
       lv2_sql := 'UPDATE  TEMP_TAB_' || p_seq_no ||
           ' t set UTC_DAYTIME = UTC_DAYTIME ' || lv2_tz_offset;
            lv2_sql := lv2_sql ||
           ' WHERE ( summer_time = ''Y'' and exists (select 1 from TEMP_TAB_' ||
           p_seq_no ||
           '  t2 where t2.object_id = t.object_id and t2.daytime = t.daytime and t2.summer_time = ''N''))';
      begin       
        ecdp_dynsql.WriteTempText(p_table_name,
                    'Updating UTC daytime for overlapping hours :: ' ||
                    lv2_sql);
        EXECUTE IMMEDIATE lv2_sql;
      exception
      when others then
        ecdp_dynsql.WriteTempText(p_table_name,
                    'ERROR while Updating daytime for overlapping hours :: ' ||
                    lv2_sql || sqlcode || sqlerrm);
      end;
    end if;


    --  Need to correct the overlapping hour of UTC_END_DATE column for all timezone
    IF v_utc_end_date <> 0 and v_end_summer_time <> 0 then

      lv3_sql := 'UPDATE  TEMP_TAB_' || p_seq_no ||
           ' t set UTC_END_DATE = UTC_END_DATE ' || lv2_tz_offset;
      lv3_sql := lv3_sql ||
           ' WHERE ( end_summer_time = ''Y'' and exists (select 1 from TEMP_TAB_' ||
           p_seq_no ||
           '  t2 where t2.object_id = t.object_id and t2.end_date = t.end_date and t2.end_summer_time = ''N''))';

      begin
          ecdp_dynsql.WriteTempText(p_table_name,
                        'Updating UTC_END_DATE for overlapping hours :: ' ||
                        lv3_sql);
          EXECUTE IMMEDIATE lv3_sql;
      exception
          when others then
            ecdp_dynsql.WriteTempText(p_table_name,
                        'ERROR while Updating UTC_END_DATE for overlapping hours :: ' ||
                        lv3_sql || sqlcode || sqlerrm);
      end;
    END IF;

    Commit;

    -- Need to add drop and rename table
    -- But first check that we got all rows over, and that we have unique utc_daytime for all rows.
    ln_originalcount := ecdp_dynsql.EXECUTE_SINGLEROW_VARCHAR2('select count(*) from ' ||
                                                               p_table_name);
    ln_newcount      := ecdp_dynsql.EXECUTE_SINGLEROW_VARCHAR2('select count(*) from TEMP_TAB_' ||
                                                               p_seq_no ||
                                                               '  where UTC_DAYTIME is not null');

    -- Not using this because it is slow (15 sec+ )
    -- select count(*) from (select distinct object_id, utc_daytime from TEMP_TAB_' || p_seq_no || ' );

    IF ln_newcount < ln_originalcount THEN

      Raise_Application_Error(-20000,
                              'Not all rows migrated for ' || p_table_name ||
                              '. compare with TEMP_TAB_' || p_seq_no ||
                              '  to look for missing values or duplicates in UTC_DAYTIME.');

    ELSE

      lv2_sql := 'DROP table ' || p_table_name ||
                 ' cascade constraints purge ';
      ecdp_dynsql.WriteTempText(p_table_name,
                                'Dropping orignal table :: ' ||
                                p_table_name);
      EXECUTE IMMEDIATE lv2_sql;

      lv2_sql := 'RENAME TEMP_TAB_' || p_seq_no || '  TO ' || p_table_name;
      ecdp_dynsql.WriteTempText(p_table_name,
                                'Renaming temp table  to orignal name :: ' ||
                                p_table_name);
      EXECUTE IMMEDIATE lv2_sql;

      ecdp_dynsql.WriteTempText(p_table_name,
                                'Restoring all Primary key, FK, Unique triggers, etc :: ' ||
                                p_table_name);

      restore_objects(p_table_name, P_DEFAULT_VALUE);
      restore_objects(p_table_name, P_PRIMARY_KEY);
      restore_objects(p_table_name, P_FOREIGN_KEY);
      restore_objects(p_table_name, P_CHILD_FOREIGN_KEY);
      restore_objects(p_table_name, P_UNIQUE_KEY);
      restore_objects(p_table_name, P_CHECK_CONS);
      restore_objects(p_table_name, P_INDEXES);
      restore_objects(p_table_name, P_TRIGGER);
      restore_objects(p_table_name, P_COMMENT);
      restore_objects(p_table_name, P_COL_COMMENT);

      ecdp_dynsql.WriteTempText(p_table_name,'Deleting records from RESTORE_OBJECT_DEF for input table :: ' || p_table_name);

     delete from RESTORE_OBJECT_DEF y where y.table_name = p_table_name;
     commit;

    END IF;

    ecdp_dynsql.WriteTempText(p_table_name,'Finished populating UTC daytime and UTC end date for :: ' || p_table_name);

  EXCEPTION
    when others then
      ecdp_dynsql.WriteTempText(p_table_name,'ERROR while processing UTC daytime
                                 for table ' || substr(sqlerrm, 1, 3000));
      RAISE;

  end utctime_update;

END;
--~^UTDELIM^~--

declare
l_var number;
v_count number;

begin
    dbms_job.submit(l_var,'populate_utc_timezone.executeJob(1);');
    
    dbms_job.submit(l_var,'populate_utc_timezone.executeJob(2);');
    
    dbms_job.submit(l_var,'populate_utc_timezone.executeJob(3);');
    
    dbms_job.submit(l_var,'populate_utc_timezone.executeJob(4);');
    
    dbms_job.submit(l_var,'populate_utc_timezone.executeJob(5);');
    
	commit; 
    
	<<default_number>>
	select count(1) into v_count from user_jobs where WHAT like 'populate_utc_timezone.executeJob(%';

	 if v_count<> 0 then 
	  dbms_lock.sleep(seconds => 30);
	  GOTO default_number;
	 end if; 
end;
--~^UTDELIM^~--

declare
begin
   
 execute immediate ' alter table strm_Well_Conn disable all triggers';
	
	UPDATE strm_well_conn t set UTC_DAYTIME = UTC_DAYTIME-1/24 WHERE ( SUMMERTIME_DAYTIME = 'Y' and 
	exists (select 1 from strm_well_conn  t2 where t2.object_id = t.object_id and t2.daytime = t.daytime and t2.SUMMERTIME_DAYTIME = 'N'));
    
	UPDATE strm_well_conn t set UTC_END_DATE = UTC_END_DATE-1/24 WHERE ( SUMMERTIME_END_DATE = 'Y' and exists (select 1 from strm_well_conn
	t2 where t2.object_id = t.object_id and t2.end_date = t.end_date and t2.SUMMERTIME_END_DATE = 'N'));
  
	UPDATE strm_well_conn_jn t set UTC_DAYTIME = UTC_DAYTIME-1/24 WHERE ( SUMMERTIME_DAYTIME = 'Y' and 
	exists (select 1 from strm_well_conn_jn  t2 where t2.object_id = t.object_id and t2.daytime = t.daytime and t2.SUMMERTIME_DAYTIME = 'N'));
    
	UPDATE strm_well_conn_jn t set UTC_END_DATE = UTC_END_DATE-1/24 WHERE ( SUMMERTIME_END_DATE = 'Y' and exists (select 1 from strm_well_conn_jn
	t2 where t2.object_id = t.object_id and t2.end_date = t.end_date and t2.SUMMERTIME_END_DATE = 'N'));
   
	commit;
  
  execute immediate 'alter table strm_Well_Conn enable all triggers';
     
end ;
--~^UTDELIM^~-- 
 
begin
execute immediate 'drop table RESTORE_OBJECT_DEF';
end ;
--~^UTDELIM^~--  

begin
execute immediate 'drop table UTC_TIMEZONE_MASTER';
end ;
--~^UTDELIM^~--  

begin
execute immediate 'drop  sequence utctime_sequence';
end ;
--~^UTDELIM^~-- 
 
begin
execute immediate 'drop package ecdp_localtimestamp';
end ;
--~^UTDELIM^~--  

begin
execute immediate 'drop package populate_utc_timezone';
end ;
--~^UTDELIM^~--
