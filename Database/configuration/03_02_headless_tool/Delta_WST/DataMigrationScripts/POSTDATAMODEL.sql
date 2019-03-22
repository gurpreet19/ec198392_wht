ALTER TABLE QBL_EXPORT_WHERE_COND DISABLE ALL TRIGGERS
--~^UTDELIM^~--

ALTER TABLE QBL_EXPORT_ORDER_BY DISABLE ALL TRIGGERS
--~^UTDELIM^~--

ALTER TABLE QBL_EXPORT_COLUMNS DISABLE ALL TRIGGERS
--~^UTDELIM^~--

-- ECPD22650_qbl_export_query_default_record...

BEGIN

	UPDATE QBL_EXPORT_WHERE_COND
	SET QBL_EXPORT_QUERY_NO =
		   (SELECT QBL_EXPORT_QUERY_NO
			  FROM QBL_EXPORT_QUERY
			 WHERE REPORT_VIEW = OBJECT_ID)
	WHERE QBL_EXPORT_QUERY_NO IS NULL;
	

	UPDATE QBL_EXPORT_ORDER_BY
	SET QBL_EXPORT_QUERY_NO =
		   (SELECT QBL_EXPORT_QUERY_NO
			  FROM QBL_EXPORT_QUERY
			 WHERE REPORT_VIEW = OBJECT_ID)
	WHERE QBL_EXPORT_QUERY_NO IS NULL;
	

	UPDATE QBL_EXPORT_COLUMNS
	SET QBL_EXPORT_QUERY_NO =
		   (SELECT QBL_EXPORT_QUERY_NO
			  FROM QBL_EXPORT_QUERY
			 WHERE REPORT_VIEW = OBJECT_ID)
	WHERE QBL_EXPORT_QUERY_NO IS NULL;
END;
--~^UTDELIM^~--

ALTER TABLE QBL_EXPORT_WHERE_COND ENABLE ALL TRIGGERS
--~^UTDELIM^~--

ALTER TABLE QBL_EXPORT_ORDER_BY ENABLE ALL TRIGGERS
--~^UTDELIM^~--

ALTER TABLE QBL_EXPORT_COLUMNS ENABLE ALL TRIGGERS
--~^UTDELIM^~--
-- START OF 01_ecpd_34718_upgrade_script_ec_01_tag_rename
-- updates viewer tag names
DECLARE 
HASENTRY NUMBER;
BEGIN
	SELECT COUNT(*) INTO HASENTRY FROM USER_TRIGGERS 
		WHERE TRIGGER_NAME = 'IU_BPM_VIEWER_TAG'; 
		IF HASENTRY > 0 THEN 
		EXECUTE IMMEDIATE 'ALTER TRIGGER IU_BPM_VIEWER_TAG DISABLE';
		END IF;
		
	update BPM_VIEWER_TAG set TAG = 'ecbpm__node_active' where TAG = 'active';

	SELECT COUNT(*) INTO HASENTRY FROM USER_TRIGGERS 
		WHERE TRIGGER_NAME = 'IU_BPM_VIEWER_TAG'; 
		IF HASENTRY > 0 THEN 
		EXECUTE IMMEDIATE 'ALTER TRIGGER IU_BPM_VIEWER_TAG ENABLE';
		END IF;
		
		
   EXCEPTION
   WHEN OTHERS 
     THEN
       IF HASENTRY > 0 THEN 
           EXECUTE IMMEDIATE 'ALTER TRIGGER IU_BPM_VIEWER_TAG ENABLE';
       END IF;
        
        raise_application_error(-20000,
                            'ERROR: Some Other fatal error occured :- '||SQLERRM);
END;
--~^UTDELIM^~--	

DECLARE 
HASENTRY NUMBER;
BEGIN
	SELECT COUNT(*) INTO HASENTRY FROM USER_TRIGGERS 
		WHERE TRIGGER_NAME = 'IU_BPM_VIEWER_TAG_ATT'; 
		IF HASENTRY > 0 THEN 
		EXECUTE IMMEDIATE 'ALTER TRIGGER IU_BPM_VIEWER_TAG_ATT DISABLE';
		END IF;
	
	update BPM_VIEWER_TAG_ATT set TAG = 'ecbpm__node_active' where TAG = 'active';
		
	SELECT COUNT(*) INTO HASENTRY FROM USER_TRIGGERS 
		WHERE TRIGGER_NAME = 'IU_BPM_VIEWER_TAG_ATT'; 
		IF HASENTRY > 0 THEN 
		EXECUTE IMMEDIATE 'ALTER TRIGGER IU_BPM_VIEWER_TAG_ATT ENABLE';
		END IF;
		
   EXCEPTION
   WHEN OTHERS 
     THEN
       IF HASENTRY > 0 THEN 
           EXECUTE IMMEDIATE 'ALTER TRIGGER IU_BPM_VIEWER_TAG_ATT ENABLE';
       END IF;
        
        raise_application_error(-20000,
                            'ERROR: Some Other fatal error occured :- '||SQLERRM);
END;
--~^UTDELIM^~--	

DECLARE 
HASENTRY NUMBER;
BEGIN
	SELECT COUNT(*) INTO HASENTRY FROM USER_TRIGGERS 
		WHERE TRIGGER_NAME = 'IU_BPM_VIEWER_TAG'; 
		IF HASENTRY > 0 THEN 
		EXECUTE IMMEDIATE 'ALTER TRIGGER IU_BPM_VIEWER_TAG DISABLE';
		END IF;
		
	update BPM_VIEWER_TAG set TAG = 'ecbpm__node_completed' where TAG = 'completed';

	SELECT COUNT(*) INTO HASENTRY FROM USER_TRIGGERS 
		WHERE TRIGGER_NAME = 'IU_BPM_VIEWER_TAG'; 
		IF HASENTRY > 0 THEN 
		EXECUTE IMMEDIATE 'ALTER TRIGGER IU_BPM_VIEWER_TAG ENABLE';
		END IF;
		
   EXCEPTION
   WHEN OTHERS 
     THEN
       IF HASENTRY > 0 THEN 
           EXECUTE IMMEDIATE 'ALTER TRIGGER IU_BPM_VIEWER_TAG ENABLE';
       END IF;
        
        raise_application_error(-20000,
                            'ERROR: Some Other fatal error occured :- '||SQLERRM);
END;
--~^UTDELIM^~--	

DECLARE 
HASENTRY NUMBER;
BEGIN
	SELECT COUNT(*) INTO HASENTRY FROM USER_TRIGGERS 
		WHERE TRIGGER_NAME = 'IU_BPM_VIEWER_TAG_ATT'; 
		IF HASENTRY > 0 THEN 
		EXECUTE IMMEDIATE 'ALTER TRIGGER IU_BPM_VIEWER_TAG_ATT DISABLE';
		END IF;
	
	update BPM_VIEWER_TAG_ATT set TAG = 'ecbpm__node_completed' where TAG = 'completed';
		
	SELECT COUNT(*) INTO HASENTRY FROM USER_TRIGGERS 
		WHERE TRIGGER_NAME = 'IU_BPM_VIEWER_TAG_ATT'; 
		IF HASENTRY > 0 THEN 
		EXECUTE IMMEDIATE 'ALTER TRIGGER IU_BPM_VIEWER_TAG_ATT ENABLE';
		END IF;
		
   EXCEPTION
   WHEN OTHERS 
     THEN
       IF HASENTRY > 0 THEN 
           EXECUTE IMMEDIATE 'ALTER TRIGGER IU_BPM_VIEWER_TAG_ATT ENABLE';
       END IF;
        
        raise_application_error(-20000,
                            'ERROR: Some Other fatal error occured :- '||SQLERRM);
END;
--~^UTDELIM^~--	

DECLARE 
HASENTRY NUMBER;
BEGIN
	SELECT COUNT(*) INTO HASENTRY FROM USER_TRIGGERS 
		WHERE TRIGGER_NAME = 'IU_BPM_VIEWER_TAG'; 
		IF HASENTRY > 0 THEN 
		EXECUTE IMMEDIATE 'ALTER TRIGGER IU_BPM_VIEWER_TAG DISABLE';
		END IF;
		
	update BPM_VIEWER_TAG set TAG = 'ecbpm__node_pending' where TAG = 'pending';

	SELECT COUNT(*) INTO HASENTRY FROM USER_TRIGGERS 
		WHERE TRIGGER_NAME = 'IU_BPM_VIEWER_TAG'; 
		IF HASENTRY > 0 THEN 
		EXECUTE IMMEDIATE 'ALTER TRIGGER IU_BPM_VIEWER_TAG ENABLE';
		END IF;
		
   EXCEPTION
   WHEN OTHERS 
     THEN
       IF HASENTRY > 0 THEN 
           EXECUTE IMMEDIATE 'ALTER TRIGGER IU_BPM_VIEWER_TAG ENABLE';
       END IF;
        
        raise_application_error(-20000,
                            'ERROR: Some Other fatal error occured :- '||SQLERRM);
END;
--~^UTDELIM^~--	

DECLARE 
HASENTRY NUMBER;
BEGIN
	SELECT COUNT(*) INTO HASENTRY FROM USER_TRIGGERS 
		WHERE TRIGGER_NAME = 'IU_BPM_VIEWER_TAG_ATT'; 
		IF HASENTRY > 0 THEN 
		EXECUTE IMMEDIATE 'ALTER TRIGGER IU_BPM_VIEWER_TAG_ATT DISABLE';
		END IF;
	
	update BPM_VIEWER_TAG_ATT set TAG = 'ecbpm__node_pending' where TAG = 'pending';
		
	SELECT COUNT(*) INTO HASENTRY FROM USER_TRIGGERS 
		WHERE TRIGGER_NAME = 'IU_BPM_VIEWER_TAG_ATT'; 
		IF HASENTRY > 0 THEN 
		EXECUTE IMMEDIATE 'ALTER TRIGGER IU_BPM_VIEWER_TAG_ATT ENABLE';
		END IF;
		
	EXCEPTION
   WHEN OTHERS 
     THEN
       IF HASENTRY > 0 THEN 
           EXECUTE IMMEDIATE 'ALTER TRIGGER IU_BPM_VIEWER_TAG_ATT ENABLE';
       END IF;
        
        raise_application_error(-20000,
                            'ERROR: Some Other fatal error occured :- '||SQLERRM);
END;
--~^UTDELIM^~--	

DECLARE 
HASENTRY NUMBER;
BEGIN
	SELECT COUNT(*) INTO HASENTRY FROM USER_TRIGGERS 
		WHERE TRIGGER_NAME = 'IU_BPM_VIEWER_TAG'; 
		IF HASENTRY > 0 THEN 
		EXECUTE IMMEDIATE 'ALTER TRIGGER IU_BPM_VIEWER_TAG DISABLE';
		END IF;
		
	update BPM_VIEWER_TAG set TAG = 'ecbpm__process_action_ba_warning' where TAG = 'process_action_ba_warning';

	SELECT COUNT(*) INTO HASENTRY FROM USER_TRIGGERS 
		WHERE TRIGGER_NAME = 'IU_BPM_VIEWER_TAG'; 
		IF HASENTRY > 0 THEN 
		EXECUTE IMMEDIATE 'ALTER TRIGGER IU_BPM_VIEWER_TAG ENABLE';
		END IF;
		
	EXCEPTION
   WHEN OTHERS 
     THEN
       IF HASENTRY > 0 THEN 
           EXECUTE IMMEDIATE 'ALTER TRIGGER IU_BPM_VIEWER_TAG ENABLE';
       END IF;
        
        raise_application_error(-20000,
                            'ERROR: Some Other fatal error occured :- '||SQLERRM);
END;
--~^UTDELIM^~--	

DECLARE 
HASENTRY NUMBER;
BEGIN
	SELECT COUNT(*) INTO HASENTRY FROM USER_TRIGGERS 
		WHERE TRIGGER_NAME = 'IU_BPM_VIEWER_TAG_ATT'; 
		IF HASENTRY > 0 THEN 
		EXECUTE IMMEDIATE 'ALTER TRIGGER IU_BPM_VIEWER_TAG_ATT DISABLE';
		END IF;
	
	update BPM_VIEWER_TAG_ATT set TAG = 'ecbpm__process_action_ba_warning' where TAG = 'process_action_ba_warning';
		
	SELECT COUNT(*) INTO HASENTRY FROM USER_TRIGGERS 
		WHERE TRIGGER_NAME = 'IU_BPM_VIEWER_TAG_ATT'; 
		IF HASENTRY > 0 THEN 
		EXECUTE IMMEDIATE 'ALTER TRIGGER IU_BPM_VIEWER_TAG_ATT ENABLE';
		END IF;
		
	EXCEPTION
   WHEN OTHERS 
     THEN
       IF HASENTRY > 0 THEN 
           EXECUTE IMMEDIATE 'ALTER TRIGGER IU_BPM_VIEWER_TAG_ATT ENABLE';
       END IF;
        
        raise_application_error(-20000,
                            'ERROR: Some Other fatal error occured :- '||SQLERRM);
END;
--~^UTDELIM^~--	

DECLARE 
HASENTRY NUMBER;
BEGIN
	SELECT COUNT(*) INTO HASENTRY FROM USER_TRIGGERS 
		WHERE TRIGGER_NAME = 'IU_BPM_VIEWER_TAG'; 
		IF HASENTRY > 0 THEN 
		EXECUTE IMMEDIATE 'ALTER TRIGGER IU_BPM_VIEWER_TAG DISABLE';
		END IF;
		
	update BPM_VIEWER_TAG set TAG = 'ecbpm__process_action_error' where TAG = 'process_action_error';

	SELECT COUNT(*) INTO HASENTRY FROM USER_TRIGGERS 
		WHERE TRIGGER_NAME = 'IU_BPM_VIEWER_TAG'; 
		IF HASENTRY > 0 THEN 
		EXECUTE IMMEDIATE 'ALTER TRIGGER IU_BPM_VIEWER_TAG ENABLE';
		END IF;
		
	EXCEPTION
   WHEN OTHERS 
     THEN
       IF HASENTRY > 0 THEN 
           EXECUTE IMMEDIATE 'ALTER TRIGGER IU_BPM_VIEWER_TAG ENABLE';
       END IF;
        
        raise_application_error(-20000,
                            'ERROR: Some Other fatal error occured :- '||SQLERRM);
END;
--~^UTDELIM^~--	

DECLARE 
HASENTRY NUMBER;
BEGIN
	SELECT COUNT(*) INTO HASENTRY FROM USER_TRIGGERS 
		WHERE TRIGGER_NAME = 'IU_BPM_VIEWER_TAG_ATT'; 
		IF HASENTRY > 0 THEN 
		EXECUTE IMMEDIATE 'ALTER TRIGGER IU_BPM_VIEWER_TAG_ATT DISABLE';
		END IF;
	
	update BPM_VIEWER_TAG_ATT set TAG = 'ecbpm__process_action_error' where TAG = 'process_action_error';
		
	SELECT COUNT(*) INTO HASENTRY FROM USER_TRIGGERS 
		WHERE TRIGGER_NAME = 'IU_BPM_VIEWER_TAG_ATT'; 
		IF HASENTRY > 0 THEN 
		EXECUTE IMMEDIATE 'ALTER TRIGGER IU_BPM_VIEWER_TAG_ATT ENABLE';
		END IF;
		
	EXCEPTION
   WHEN OTHERS 
     THEN
       IF HASENTRY > 0 THEN 
           EXECUTE IMMEDIATE 'ALTER TRIGGER IU_BPM_VIEWER_TAG_ATT ENABLE';
       END IF;
        
        raise_application_error(-20000,
                            'ERROR: Some Other fatal error occured :- '||SQLERRM);
END;
-- END OF 01_ecpd_34718_upgrade_script_ec_01_tag_rename
--~^UTDELIM^~--	



-- START OF 01_ecpd_34718_upgrade_script_jbpm_01_tag_rename
-- updates viewer tag names on jbpm data
DECLARE 
HASENTRY NUMBER;
BEGIN
	SELECT COUNT(*) INTO HASENTRY FROM USER_TRIGGERS 
		WHERE TRIGGER_NAME = 'IU_JBPM_BPM_OBJ_META'; 
		IF HASENTRY > 0 THEN 
		EXECUTE IMMEDIATE 'ALTER TRIGGER IU_JBPM_BPM_OBJ_META DISABLE';
		END IF;
		
	update JBPM_BPM_OBJ_META set VALUE = '{".value":"ecbpm__node_active",".class":"java.lang.String"}' where NAME = 'ecbpm.domain.viewer.node.tag' and dbms_lob.compare(VALUE, '{".value":"active",".class":"java.lang.String"}') = 0;
	
	SELECT COUNT(*) INTO HASENTRY FROM USER_TRIGGERS 
		WHERE TRIGGER_NAME = 'IU_JBPM_BPM_OBJ_META'; 
		IF HASENTRY > 0 THEN 
		EXECUTE IMMEDIATE 'ALTER TRIGGER IU_JBPM_BPM_OBJ_META ENABLE';
		END IF;
		
	EXCEPTION
   WHEN OTHERS 
     THEN
       IF HASENTRY > 0 THEN 
           EXECUTE IMMEDIATE 'ALTER TRIGGER IU_JBPM_BPM_OBJ_META ENABLE';
       END IF;
        
        raise_application_error(-20000,
                            'ERROR: Some Other fatal error occured :- '||SQLERRM);
END;
--~^UTDELIM^~--	

DECLARE 
HASENTRY NUMBER;
BEGIN
	SELECT COUNT(*) INTO HASENTRY FROM USER_TRIGGERS 
		WHERE TRIGGER_NAME = 'IU_JBPM_BPM_OBJ_META'; 
		IF HASENTRY > 0 THEN 
		EXECUTE IMMEDIATE 'ALTER TRIGGER IU_JBPM_BPM_OBJ_META DISABLE';
		END IF;
		
	update JBPM_BPM_OBJ_META set VALUE = '{".value":"ecbpm__node_completed",".class":"java.lang.String"}' where NAME = 'ecbpm.domain.viewer.node.tag' and dbms_lob.compare(VALUE, '{".value":"ecbpm__node_completed",".class":"java.lang.String"}') = 0;
	
	SELECT COUNT(*) INTO HASENTRY FROM USER_TRIGGERS 
		WHERE TRIGGER_NAME = 'IU_JBPM_BPM_OBJ_META'; 
		IF HASENTRY > 0 THEN 
		EXECUTE IMMEDIATE 'ALTER TRIGGER IU_JBPM_BPM_OBJ_META ENABLE';
		END IF;
		
		EXCEPTION
   WHEN OTHERS 
     THEN
       IF HASENTRY > 0 THEN 
           EXECUTE IMMEDIATE 'ALTER TRIGGER IU_JBPM_BPM_OBJ_META ENABLE';
       END IF;
        
        raise_application_error(-20000,
                            'ERROR: Some Other fatal error occured :- '||SQLERRM);
END;
--~^UTDELIM^~--	

DECLARE 
HASENTRY NUMBER;
BEGIN
	SELECT COUNT(*) INTO HASENTRY FROM USER_TRIGGERS 
		WHERE TRIGGER_NAME = 'IU_JBPM_BPM_OBJ_META'; 
		IF HASENTRY > 0 THEN 
		EXECUTE IMMEDIATE 'ALTER TRIGGER IU_JBPM_BPM_OBJ_META DISABLE';
		END IF;
		
	update JBPM_BPM_OBJ_META set VALUE = '{".value":"ecbpm__node_pending",".class":"java.lang.String"}' where NAME = 'ecbpm.domain.viewer.node.tag' and dbms_lob.compare(VALUE, '{".value":"pending",".class":"java.lang.String"}') = 0;
	
	SELECT COUNT(*) INTO HASENTRY FROM USER_TRIGGERS 
		WHERE TRIGGER_NAME = 'IU_JBPM_BPM_OBJ_META'; 
		IF HASENTRY > 0 THEN 
		EXECUTE IMMEDIATE 'ALTER TRIGGER IU_JBPM_BPM_OBJ_META ENABLE';
		END IF;
		
		
		EXCEPTION
   WHEN OTHERS 
     THEN
       IF HASENTRY > 0 THEN 
           EXECUTE IMMEDIATE 'ALTER TRIGGER IU_JBPM_BPM_OBJ_META ENABLE';
       END IF;
        
        raise_application_error(-20000,
                            'ERROR: Some Other fatal error occured :- '||SQLERRM);
END;
--~^UTDELIM^~--	

DECLARE 
HASENTRY NUMBER;
BEGIN
	SELECT COUNT(*) INTO HASENTRY FROM USER_TRIGGERS 
		WHERE TRIGGER_NAME = 'IU_JBPM_BPM_OBJ_META'; 
		IF HASENTRY > 0 THEN 
		EXECUTE IMMEDIATE 'ALTER TRIGGER IU_JBPM_BPM_OBJ_META DISABLE';
		END IF;
		
	update JBPM_BPM_OBJ_META set VALUE = '{".value":"ecbpm__process_action_ba_warning",".class":"java.lang.String"}' where NAME = 'ecbpm.domain.viewer.node.tag' and dbms_lob.compare(VALUE, '{".value":"process_action_ba_warning",".class":"java.lang.String"}') = 0;
	
	SELECT COUNT(*) INTO HASENTRY FROM USER_TRIGGERS 
		WHERE TRIGGER_NAME = 'IU_JBPM_BPM_OBJ_META'; 
		IF HASENTRY > 0 THEN 
		EXECUTE IMMEDIATE 'ALTER TRIGGER IU_JBPM_BPM_OBJ_META ENABLE';
		END IF;
		
	
		EXCEPTION
   WHEN OTHERS 
     THEN
       IF HASENTRY > 0 THEN 
           EXECUTE IMMEDIATE 'ALTER TRIGGER IU_JBPM_BPM_OBJ_META ENABLE';
       END IF;
        
        raise_application_error(-20000,
                            'ERROR: Some Other fatal error occured :- '||SQLERRM);
END;
--~^UTDELIM^~--	

DECLARE 
HASENTRY NUMBER;
BEGIN
	SELECT COUNT(*) INTO HASENTRY FROM USER_TRIGGERS 
		WHERE TRIGGER_NAME = 'IU_JBPM_BPM_OBJ_META'; 
		IF HASENTRY > 0 THEN 
		EXECUTE IMMEDIATE 'ALTER TRIGGER IU_JBPM_BPM_OBJ_META DISABLE';
		END IF;
		
	update JBPM_BPM_OBJ_META set VALUE = '{".value":"ecbpm__process_action_error",".class":"java.lang.String"}' where NAME = 'ecbpm.domain.viewer.node.tag' and dbms_lob.compare(VALUE, '{".value":"process_action_error",".class":"java.lang.String"}') = 0;
	
	SELECT COUNT(*) INTO HASENTRY FROM USER_TRIGGERS 
		WHERE TRIGGER_NAME = 'IU_JBPM_BPM_OBJ_META'; 
		IF HASENTRY > 0 THEN 
		EXECUTE IMMEDIATE 'ALTER TRIGGER IU_JBPM_BPM_OBJ_META ENABLE';
		END IF;
		
	
		EXCEPTION
   WHEN OTHERS 
     THEN
       IF HASENTRY > 0 THEN 
           EXECUTE IMMEDIATE 'ALTER TRIGGER IU_JBPM_BPM_OBJ_META ENABLE';
       END IF;
        
        raise_application_error(-20000,
                            'ERROR: Some Other fatal error occured :- '||SQLERRM);
END;
--~^UTDELIM^~--	

DECLARE 
HASENTRY NUMBER;
BEGIN
	SELECT COUNT(*) INTO HASENTRY FROM USER_TRIGGERS 
		WHERE TRIGGER_NAME = 'IU_JBPM_BPM_OBJ_META'; 
		IF HASENTRY > 0 THEN 
		EXECUTE IMMEDIATE 'ALTER TRIGGER IU_JBPM_BPM_OBJ_META DISABLE';
		END IF;
		
	update jbpm_bpm_obj_meta set name = 'ecbpm.domain.vtag.tag' where name = 'ecbpm.domain.viewer.node.tag';
	
	SELECT COUNT(*) INTO HASENTRY FROM USER_TRIGGERS 
		WHERE TRIGGER_NAME = 'IU_JBPM_BPM_OBJ_META'; 
		IF HASENTRY > 0 THEN 
		EXECUTE IMMEDIATE 'ALTER TRIGGER IU_JBPM_BPM_OBJ_META ENABLE';
		END IF;
		
	
		EXCEPTION
   WHEN OTHERS 
     THEN
       IF HASENTRY > 0 THEN 
           EXECUTE IMMEDIATE 'ALTER TRIGGER IU_JBPM_BPM_OBJ_META ENABLE';
       END IF;
        
        raise_application_error(-20000,
                            'ERROR: Some Other fatal error occured :- '||SQLERRM);
END;

-- END OF 01_ecpd_34718_upgrade_script_jbpm_01_tag_rename
--~^UTDELIM^~--


--START OF 01_ecpd_34256_update_script_update_screen_url
BEGIN
	update ctrl_tv_presentation set COMPONENT_EXT_NAME = '/com.ec.bpm.ext.ec.web/process_overview' where COMPONENT_EXT_NAME ='/com.ec.bpm.ext.ec.web/jbpm_process_overview';
END;
--~^UTDELIM^~--			

BEGIN
	update T_BASIS_OBJECT set OBJECT_NAME = '/com.ec.bpm.ext.ec.web/process_overview' where OBJECT_NAME = '/com.ec.bpm.ext.ec.web/jbpm_process_overview';
END;
--END OF 01_ecpd_34256_update_script_update_screen_url
--~^UTDELIM^~--			


--START OF 02_ecpd_34256_update_script_create_missing_meta_ba_number
DECLARE
    CURSOR get_process_constants IS
        SELECT to_char(var_log.value_json) AS json, 
            var_log.owner_global_id, 
            pi.EXTERNALID AS deployment_id, 
            pi.PROCESSINSTANCEID AS process_instance_id, 
            pi.PROCESSID AS process_id
        FROM jbpm_process_variable_log var_log, jbpm_processinstancelog pi
        WHERE var_log.name = 'ec.extension.process.constants' AND var_log.process_instance_id = pi.id;
        
    json VARCHAR2(4000);
    owner_global_id VARCHAR2(1000);
    owner_ref_json VARCHAR2(1000);
    
    var_declare_idx NUMBER;
    var_value_start_idx NUMBER;
    var_value_len NUMBER;
    var_name VARCHAR2(1000) := 'ec.extension.internal.businessActionNo';
    var_target_meta_name VARCHAR2(1000) := 'readonly:com.ec.bpm.ext.ec.process.business_action_number';
    var_value VARCHAR2(1000);
    test_num NUMBER;
BEGIN
    FOR c IN get_process_constants LOOP
        json := c.json;
        owner_global_id := c.owner_global_id;
        var_declare_idx := INSTRC(json, '"' || var_name || '"');
        var_value_start_idx := INSTRC(json, '{".value":', var_declare_idx) + LENGTH('{".value":');
        var_value_len := INSTRC(json, ',".class"', var_value_start_idx) - var_value_start_idx;
        var_value := SUBSTRC(json, var_value_start_idx, var_value_len);
        owner_ref_json := '["1ebd446a",' || c.process_instance_id || ',"' || c.process_id || '","' || c.deployment_id || '"]';
        
        
        BEGIN
            test_num := to_number(var_value);
        EXCEPTION
            WHEN OTHERS THEN
                CONTINUE;
        END;
        
        INSERT INTO jbpm_bpm_obj_meta (OWNER_GLOBAL_ID, NAME, CORRELATION_GLOBAL_ID, CORRELATION_REF_JSON, CREATED_DATE, OWNER_REF_JSON, VALUE)
        VALUES (owner_global_id, var_target_meta_name, owner_global_id, owner_ref_json, SYSDATE, owner_ref_json, '{".value":' || var_value || ',".class":"java.lang.Long"}');
    END LOOP;
END;
--END OF 02_ecpd_34256_update_script_create_missing_meta_ba_number
--~^UTDELIM^~--			


--START OF 03_ecpd_34256_update_script_create_missing_meta_schedule_number
DECLARE
    CURSOR get_process_constants IS
        SELECT to_char(var_log.value_json) AS json, 
            var_log.owner_global_id, 
            pi.EXTERNALID AS deployment_id, 
            pi.PROCESSINSTANCEID AS process_instance_id, 
            pi.PROCESSID AS process_id
        FROM jbpm_process_variable_log var_log, jbpm_processinstancelog pi
        WHERE var_log.name = 'ec.extension.process.constants' AND var_log.process_instance_id = pi.id;
        
    json VARCHAR2(4000);
    owner_global_id VARCHAR2(1000);
    owner_ref_json VARCHAR2(1000);
    
    var_declare_idx NUMBER;
    var_value_start_idx NUMBER;
    var_value_len NUMBER;
    var_name VARCHAR2(1000) := 'ec.extension.internal.scheduleNo';
    var_target_meta_name VARCHAR2(1000) := 'readonly:com.ec.bpm.ext.ec.process.schedule_number';
    var_value VARCHAR2(1000);
    test_num NUMBER;
BEGIN
    FOR c IN get_process_constants LOOP
        json := c.json;
        owner_global_id := c.owner_global_id;
        var_declare_idx := INSTRC(json, '"' || var_name || '"');
        var_value_start_idx := INSTRC(json, '{".value":', var_declare_idx) + LENGTH('{".value":');
        var_value_len := INSTRC(json, ',".class"', var_value_start_idx) - var_value_start_idx;
        var_value := SUBSTRC(json, var_value_start_idx, var_value_len);
        owner_ref_json := '["1ebd446a",' || c.process_instance_id || ',"' || c.process_id || '","' || c.deployment_id || '"]';
        
        
        BEGIN
            test_num := to_number(var_value);
        EXCEPTION
            WHEN OTHERS THEN
                CONTINUE;
        END;
        
        INSERT INTO jbpm_bpm_obj_meta (OWNER_GLOBAL_ID, NAME, CORRELATION_GLOBAL_ID, CORRELATION_REF_JSON, CREATED_DATE, OWNER_REF_JSON, VALUE)
        VALUES (owner_global_id, var_target_meta_name, owner_global_id, owner_ref_json, SYSDATE, owner_ref_json, '{".value":' || var_value || ',".class":"java.lang.Long"}');
    END LOOP;
END;
--END OF 03_ecpd_34256_update_script_create_missing_meta_schedule_number
--~^UTDELIM^~--			


--START OF 04_ecpd_34256_update_script_create_missing_meta_pi_creator
DECLARE
    CURSOR get_process_constants IS
        SELECT to_char(var_log.value_json) AS json, 
            var_log.owner_global_id, 
            pi.EXTERNALID AS deployment_id, 
            pi.PROCESSINSTANCEID AS process_instance_id, 
            pi.PROCESSID AS process_id
        FROM jbpm_process_variable_log var_log, jbpm_processinstancelog pi
        WHERE var_log.name = 'ec.extension.process.constants' AND var_log.process_instance_id = pi.id;

    json VARCHAR2(4000);
    owner_global_id VARCHAR2(1000);
    owner_ref_json VARCHAR2(1000);

    var_declare_idx NUMBER;
    var_value_start_idx NUMBER;
    var_value_len NUMBER;
    var_name VARCHAR2(1000) := 'ec.extension.internal.instanceInitiator';
    var_target_meta_name VARCHAR2(1000) := 'readonly:com.ec.bpm.ext.ec.process.process_creator';
    var_value VARCHAR2(1000);
BEGIN
    FOR c IN get_process_constants LOOP
        json := c.json;
        owner_global_id := c.owner_global_id;
        var_declare_idx := INSTRC(json, '"' || var_name || '"');
        var_value_start_idx := INSTRC(json, '{".value":', var_declare_idx) + LENGTH('{".value":');
        var_value_len := INSTRC(json, ',".class"', var_value_start_idx) - var_value_start_idx;
        var_value := SUBSTRC(json, var_value_start_idx, var_value_len);
        owner_ref_json := '["1ebd446a",' || c.process_instance_id || ',"' || c.process_id || '","' || c.deployment_id || '"]';

        INSERT INTO jbpm_bpm_obj_meta (OWNER_GLOBAL_ID, NAME, CORRELATION_GLOBAL_ID, CORRELATION_REF_JSON, CREATED_DATE, OWNER_REF_JSON, VALUE)
        VALUES (owner_global_id, var_target_meta_name, owner_global_id, owner_ref_json, SYSDATE, owner_ref_json, '{".value":' || var_value || ',".class":"java.lang.String"}');
    END LOOP;
END;
--END OF 04_ecpd_34256_update_script_create_missing_meta_pi_creator
--~^UTDELIM^~--

BEGIN

	update ctrl_tv_presentation set COMPONENT_EXT_NAME = '/com.ec.bpm.ext.ec.web/process_action' where COMPONENT_EXT_NAME ='/com.ec.bpm.ext.ec.web/jbpm_process_action';
	
END;
--~^UTDELIM^~--	

BEGIN

		
	update T_BASIS_OBJECT set OBJECT_NAME = '/com.ec.bpm.ext.ec.web/process_action' where OBJECT_NAME = '/com.ec.bpm.ext.ec.web/jbpm_process_action';
	
END;
--~^UTDELIM^~--		






BEGIN
	DELETE from BPM_EC_GCOMMAND_HANDLER WHERE BPM_EC_GCOMMAND_HANDLER_ID = 2;
END;
--~^UTDELIM^~--

BEGIN
	DELETE from BPM_EC_GCOMMAND WHERE COMMAND_NAME = '{ExecuteCalculationAction}';
END;
--~^UTDELIM^~--

BEGIN
	DELETE from BPM_EC_GCOMMAND_HANDLER WHERE BPM_EC_GCOMMAND_HANDLER_ID = 4;
END;
--~^UTDELIM^~--

BEGIN
	DELETE from BPM_EC_GCOMMAND where command_name = '{ExecuteEcisTransformAndLoadAction}';
END;
--~^UTDELIM^~--

BEGIN
  EXECUTE IMMEDIATE 'DROP MATERIALIZED VIEW CLASS';
EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE != -12003 THEN
      RAISE;
    END IF;
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
  where p1.presentation_cntx in ('/EC')
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

DECLARE 
	 index_exists  exception;  
 	 pragma exception_init (index_exists , -00955);  
	 sqlQuery clob:='create unique index UIX_CLASS on Class(Class_name) TABLESPACE &ts_index'; 
BEGIN 
	 EXECUTE IMMEDIATE sqlQuery; 
	 dbms_output.put_line('SUCCESS: ' || sqlQuery); 
	 EXCEPTION 
	 	 when index_exists  then 
  	 	 	 dbms_output.put_line('WARNING: ' || sqlQuery); 
  	 	 	 dbms_output.put_line('ORA-00955: name is already being used by existing object'); 
  	 	 WHEN OTHERS THEN 
	 	 	 --UPDATE_MILESTONE_WITH_ERROR('modify_table_indexes'); 
	 	 	 raise_application_error(-20000, 'FATAL  ERROR: ' || sqlerrm); 
END;
--~^UTDELIM^~--

DECLARE 
	 index_exists  exception;  
 	 pragma exception_init (index_exists , -00955);  
	 sqlQuery clob:='create unique index UIX_CLASS on Class(Class_name) TABLESPACE &ts_index'; 
BEGIN 
	 EXECUTE IMMEDIATE sqlQuery; 
	 dbms_output.put_line('SUCCESS: ' || sqlQuery); 
	 EXCEPTION 
	 	 when index_exists  then 
  	 	 	 dbms_output.put_line('WARNING: ' || sqlQuery); 
  	 	 	 dbms_output.put_line('ORA-00955: name is already being used by existing object'); 
  	 	 WHEN OTHERS THEN 
	 	 	 --UPDATE_MILESTONE_WITH_ERROR('modify_table_indexes'); 
	 	 	 raise_application_error(-20000, 'FATAL  ERROR: ' || sqlerrm); 
END;
--~^UTDELIM^~--

DECLARE 
	 index_exists  exception;  
 	 pragma exception_init (index_exists , -00955);  
	 sqlQuery clob:='CREATE INDEX IFK_CLASS_2 ON CLASS (OWNER_CLASS_NAME) INITRANS 2 MAXTRANS 255 PCTFREE 50 STORAGE ( PCTINCREASE 50 NEXT 65536 ) TABLESPACE &ts_index'; 
BEGIN 
	 EXECUTE IMMEDIATE sqlQuery; 
	 dbms_output.put_line('SUCCESS: ' || sqlQuery); 
	 EXCEPTION 
	 	 when index_exists  then 
  	 	 	 dbms_output.put_line('WARNING: ' || sqlQuery); 
  	 	 	 dbms_output.put_line('ORA-00955: name is already being used by existing object'); 
  	 	 WHEN OTHERS THEN 
	 	 	 --UPDATE_MILESTONE_WITH_ERROR('modify_table_indexes'); 
	 	 	 raise_application_error(-20000, 'FATAL  ERROR: ' || sqlerrm); 
END;

--~^UTDELIM^~--

DECLARE 
	 index_exists  exception;  
 	 pragma exception_init (index_exists , -00955);  
	 sqlQuery clob:='CREATE INDEX IFK_CLASS_1 ON CLASS (SUPER_CLASS) INITRANS 2 MAXTRANS 255 PCTFREE 50 STORAGE ( PCTINCREASE 50 NEXT 65536 ) TABLESPACE &ts_index'; 
BEGIN 
	 EXECUTE IMMEDIATE sqlQuery; 
	 dbms_output.put_line('SUCCESS: ' || sqlQuery); 
	 EXCEPTION 
	 	 when index_exists  then 
  	 	 	 dbms_output.put_line('WARNING: ' || sqlQuery); 
  	 	 	 dbms_output.put_line('ORA-00955: name is already being used by existing object'); 
  	 	 WHEN OTHERS THEN 
	 	 	 --UPDATE_MILESTONE_WITH_ERROR('modify_table_indexes'); 
	 	 	 raise_application_error(-20000, 'FATAL  ERROR: ' || sqlerrm); 
END;
--~^UTDELIM^~--

DECLARE 
	 index_exists  exception;  
 	 pragma exception_init (index_exists , -00955);  
	 sqlQuery clob:='CREATE INDEX IR_CLASS ON CLASS (REC_ID) INITRANS 2 MAXTRANS 255 PCTFREE 50 STORAGE ( PCTINCREASE 50 NEXT 65536 ) TABLESPACE &ts_index'; 
BEGIN 
	 EXECUTE IMMEDIATE sqlQuery; 
	 dbms_output.put_line('SUCCESS: ' || sqlQuery); 
	 EXCEPTION 
	 	 when index_exists  then 
  	 	 	 dbms_output.put_line('WARNING: ' || sqlQuery); 
  	 	 	 dbms_output.put_line('ORA-00955: name is already being used by existing object'); 
  	 	 WHEN OTHERS THEN 
	 	 	 --UPDATE_MILESTONE_WITH_ERROR('modify_table_indexes'); 
	 	 	 raise_application_error(-20000, 'FATAL  ERROR: ' || sqlerrm); 
END;
--~^UTDELIM^~--

BEGIN
	delete from bpm_proc_ov_config_att where key = 1;
END;
--~^UTDELIM^~--

BEGIN
	delete from bpm_proc_ov_list_property where id = 1;
END;
--~^UTDELIM^~--

DECLARE
     HASENTRY NUMBER;
     sqlQuery clob:='update bpm_proc_ov_list_property set id = 1 where id = 2';
BEGIN
  
  SELECT COUNT(*) INTO HASENTRY FROM USER_TRIGGERS 
		WHERE TRIGGER_NAME = 'IU_BPM_PROC_OV_LIST_PROPERTY'; 
		IF HASENTRY > 0 THEN 
		EXECUTE IMMEDIATE 'ALTER TRIGGER IU_BPM_PROC_OV_LIST_PROPERTY DISABLE';
		END IF;
		
     EXECUTE IMMEDIATE sqlQuery;
	 
	 SELECT COUNT(*) INTO HASENTRY FROM USER_TRIGGERS 
		WHERE TRIGGER_NAME = 'IU_BPM_PROC_OV_LIST_PROPERTY'; 
		IF HASENTRY > 0 THEN 
		EXECUTE IMMEDIATE 'ALTER TRIGGER IU_BPM_PROC_OV_LIST_PROPERTY ENABLE';
		END IF;
		
     dbms_output.put_line('SUCCESS: ' || sqlQuery);
     dbms_output.put_line('No of Rows Updated:' || sql%rowcount);
     EXCEPTION
        WHEN OTHERS THEN
		IF HASENTRY > 0 THEN 
		EXECUTE IMMEDIATE 'ALTER TRIGGER IU_BPM_PROC_OV_LIST_PROPERTY ENABLE';
		END IF;
         --UPDATE_MILESTONE_WITH_ERROR('post_data_model');
        raise_application_error(-20000, 'ERROR: Some Other fatal error occured' || SQLERRM);
 END;
--~^UTDELIM^~--

DECLARE
     HASENTRY NUMBER;
     sqlQuery clob:='update bpm_proc_ov_config_att set key = 1 where key = 2';
BEGIN
    SELECT COUNT(*) INTO HASENTRY FROM USER_TRIGGERS 
		WHERE TRIGGER_NAME = 'IU_BPM_PROC_OV_CONFIG_ATT'; 
		IF HASENTRY > 0 THEN 
		EXECUTE IMMEDIATE 'ALTER TRIGGER IU_BPM_PROC_OV_CONFIG_ATT DISABLE';
		END IF;
		
     EXECUTE IMMEDIATE sqlQuery;
	 
	 SELECT COUNT(*) INTO HASENTRY FROM USER_TRIGGERS 
		WHERE TRIGGER_NAME = 'IU_BPM_PROC_OV_CONFIG_ATT'; 
		IF HASENTRY > 0 THEN 
		EXECUTE IMMEDIATE 'ALTER TRIGGER IU_BPM_PROC_OV_CONFIG_ATT ENABLE';
		END IF;
		
     dbms_output.put_line('SUCCESS: ' || sqlQuery);
     dbms_output.put_line('No of Rows Updated:' || sql%rowcount);
     EXCEPTION
        WHEN OTHERS THEN
		IF HASENTRY > 0 THEN 
		EXECUTE IMMEDIATE 'ALTER TRIGGER IU_BPM_PROC_OV_CONFIG_ATT ENABLE';
		END IF;
         --UPDATE_MILESTONE_WITH_ERROR('post_data_model');
         raise_application_error(-20000, 'ERROR: Some Other fatal error occured' || SQLERRM);
 END;
--~^UTDELIM^~--

DECLARE
     HASENTRY NUMBER;
     sqlQuery clob:='update bpm_proc_ov_list_property set id = 2 where id = 3';
BEGIN

    SELECT COUNT(*) INTO HASENTRY FROM USER_TRIGGERS 
		WHERE TRIGGER_NAME = 'IU_BPM_PROC_OV_LIST_PROPERTY'; 
		IF HASENTRY > 0 THEN 
		EXECUTE IMMEDIATE 'ALTER TRIGGER IU_BPM_PROC_OV_LIST_PROPERTY DISABLE';
		END IF;
		
     EXECUTE IMMEDIATE sqlQuery;
	 
	  SELECT COUNT(*) INTO HASENTRY FROM USER_TRIGGERS 
		WHERE TRIGGER_NAME = 'IU_BPM_PROC_OV_LIST_PROPERTY'; 
		IF HASENTRY > 0 THEN 
		EXECUTE IMMEDIATE 'ALTER TRIGGER IU_BPM_PROC_OV_LIST_PROPERTY ENABLE';
		END IF;
		
     dbms_output.put_line('SUCCESS: ' || sqlQuery);
     dbms_output.put_line('No of Rows Updated:' || sql%rowcount);
     EXCEPTION
        WHEN OTHERS THEN
         --UPDATE_MILESTONE_WITH_ERROR('post_data_model');
		IF HASENTRY > 0 THEN 
		EXECUTE IMMEDIATE 'ALTER TRIGGER IU_BPM_PROC_OV_LIST_PROPERTY ENABLE';
		END IF;
         raise_application_error(-20000, 'ERROR: Some Other fatal error occured' || SQLERRM);
 END;
--~^UTDELIM^~--

DECLARE
     HASENTRY NUMBER;
     sqlQuery clob:='update bpm_proc_ov_config_att set key = 2 where key = 3';
BEGIN

     SELECT COUNT(*) INTO HASENTRY FROM USER_TRIGGERS 
		WHERE TRIGGER_NAME = 'IU_BPM_PROC_OV_CONFIG_ATT'; 
		IF HASENTRY > 0 THEN 
		EXECUTE IMMEDIATE 'ALTER TRIGGER IU_BPM_PROC_OV_CONFIG_ATT DISABLE';
		END IF;
		
     EXECUTE IMMEDIATE sqlQuery;
	 
	  SELECT COUNT(*) INTO HASENTRY FROM USER_TRIGGERS 
		WHERE TRIGGER_NAME = 'IU_BPM_PROC_OV_CONFIG_ATT'; 
		IF HASENTRY > 0 THEN 
		EXECUTE IMMEDIATE 'ALTER TRIGGER IU_BPM_PROC_OV_CONFIG_ATT ENABLE';
		END IF;
     dbms_output.put_line('SUCCESS: ' || sqlQuery);
     dbms_output.put_line('No of Rows Updated:' || sql%rowcount);
     EXCEPTION
        WHEN OTHERS THEN
		IF HASENTRY > 0 THEN 
		EXECUTE IMMEDIATE 'ALTER TRIGGER IU_BPM_PROC_OV_CONFIG_ATT ENABLE';
		END IF;
         --UPDATE_MILESTONE_WITH_ERROR('post_data_model');
         raise_application_error(-20000, 'ERROR: Some Other fatal error occured' || SQLERRM);
 END;
--~^UTDELIM^~--

DECLARE
      HASENTRY NUMBER;
     sqlQuery clob:='update bpm_proc_ov_list_property set id = 3 where id = 4';
BEGIN

       SELECT COUNT(*) INTO HASENTRY FROM USER_TRIGGERS 
		WHERE TRIGGER_NAME = 'IU_BPM_PROC_OV_LIST_PROPERTY'; 
		IF HASENTRY > 0 THEN 
		EXECUTE IMMEDIATE 'ALTER TRIGGER IU_BPM_PROC_OV_LIST_PROPERTY DISABLE';
		END IF;
		
     EXECUTE IMMEDIATE sqlQuery;
	 
	  SELECT COUNT(*) INTO HASENTRY FROM USER_TRIGGERS 
		WHERE TRIGGER_NAME = 'IU_BPM_PROC_OV_LIST_PROPERTY'; 
		IF HASENTRY > 0 THEN 
		EXECUTE IMMEDIATE 'ALTER TRIGGER IU_BPM_PROC_OV_LIST_PROPERTY ENABLE';
		END IF;
		
		
     dbms_output.put_line('SUCCESS: ' || sqlQuery);
     dbms_output.put_line('No of Rows Updated:' || sql%rowcount);
     EXCEPTION
        WHEN OTHERS THEN
		IF HASENTRY > 0 THEN 
		EXECUTE IMMEDIATE 'ALTER TRIGGER IU_BPM_PROC_OV_LIST_PROPERTY ENABLE';
		END IF;
         --UPDATE_MILESTONE_WITH_ERROR('post_data_model');
         raise_application_error(-20000, 'ERROR: Some Other fatal error occured' || SQLERRM);
 END;
--~^UTDELIM^~--

DECLARE
      HASENTRY NUMBER;
     sqlQuery clob:='update bpm_proc_ov_config_att set key = 3 where key = 4';
BEGIN
     SELECT COUNT(*) INTO HASENTRY FROM USER_TRIGGERS 
		WHERE TRIGGER_NAME = 'IU_BPM_PROC_OV_CONFIG_ATT'; 
		IF HASENTRY > 0 THEN 
		EXECUTE IMMEDIATE 'ALTER TRIGGER IU_BPM_PROC_OV_CONFIG_ATT DISABLE';
		END IF;

     EXECUTE IMMEDIATE sqlQuery;
	 
	  SELECT COUNT(*) INTO HASENTRY FROM USER_TRIGGERS 
		WHERE TRIGGER_NAME = 'IU_BPM_PROC_OV_CONFIG_ATT'; 
		IF HASENTRY > 0 THEN 
		EXECUTE IMMEDIATE 'ALTER TRIGGER IU_BPM_PROC_OV_CONFIG_ATT ENABLE';
		END IF;
		
     dbms_output.put_line('SUCCESS: ' || sqlQuery);
     dbms_output.put_line('No of Rows Updated:' || sql%rowcount);
     EXCEPTION
        WHEN OTHERS THEN
		IF HASENTRY > 0 THEN 
		EXECUTE IMMEDIATE 'ALTER TRIGGER IU_BPM_PROC_OV_CONFIG_ATT ENABLE';
		END IF;
         --UPDATE_MILESTONE_WITH_ERROR('post_data_model');
         raise_application_error(-20000, 'ERROR: Some Other fatal error occured' || SQLERRM);
 END;
--~^UTDELIM^~--

DECLARE
      HASENTRY NUMBER;
     sqlQuery clob:='update bpm_proc_ov_list_property set id = 4 where id = 5';
BEGIN

     SELECT COUNT(*) INTO HASENTRY FROM USER_TRIGGERS 
		WHERE TRIGGER_NAME = 'IU_BPM_PROC_OV_LIST_PROPERTY'; 
		IF HASENTRY > 0 THEN 
		EXECUTE IMMEDIATE 'ALTER TRIGGER IU_BPM_PROC_OV_LIST_PROPERTY DISABLE';
		END IF;
		
     EXECUTE IMMEDIATE sqlQuery;
	 
	 
	  SELECT COUNT(*) INTO HASENTRY FROM USER_TRIGGERS 
		WHERE TRIGGER_NAME = 'IU_BPM_PROC_OV_LIST_PROPERTY'; 
		IF HASENTRY > 0 THEN 
		EXECUTE IMMEDIATE 'ALTER TRIGGER IU_BPM_PROC_OV_LIST_PROPERTY ENABLE';
		END IF;
	 
     dbms_output.put_line('SUCCESS: ' || sqlQuery);
     dbms_output.put_line('No of Rows Updated:' || sql%rowcount);
     EXCEPTION
        WHEN OTHERS THEN
		IF HASENTRY > 0 THEN 
		EXECUTE IMMEDIATE 'ALTER TRIGGER IU_BPM_PROC_OV_LIST_PROPERTY ENABLE';
		END IF;
         --UPDATE_MILESTONE_WITH_ERROR('post_data_model');
         raise_application_error(-20000, 'ERROR: Some Other fatal error occured' || SQLERRM);
 END;
--~^UTDELIM^~--

DECLARE
        HASENTRY NUMBER;
     sqlQuery clob:='update bpm_proc_ov_config_att set key = 4 where key = 5';
BEGIN
      SELECT COUNT(*) INTO HASENTRY FROM USER_TRIGGERS 
		WHERE TRIGGER_NAME = 'IU_BPM_PROC_OV_CONFIG_ATT'; 
		IF HASENTRY > 0 THEN 
		EXECUTE IMMEDIATE 'ALTER TRIGGER IU_BPM_PROC_OV_CONFIG_ATT DISABLE';
		END IF;
		
     EXECUTE IMMEDIATE sqlQuery;
	 
	  SELECT COUNT(*) INTO HASENTRY FROM USER_TRIGGERS 
		WHERE TRIGGER_NAME = 'IU_BPM_PROC_OV_CONFIG_ATT'; 
		IF HASENTRY > 0 THEN 
		EXECUTE IMMEDIATE 'ALTER TRIGGER IU_BPM_PROC_OV_CONFIG_ATT ENABLE';
		END IF;
	 
     dbms_output.put_line('SUCCESS: ' || sqlQuery);
     dbms_output.put_line('No of Rows Updated:' || sql%rowcount);
     EXCEPTION
        WHEN OTHERS THEN
		IF HASENTRY > 0 THEN 
		EXECUTE IMMEDIATE 'ALTER TRIGGER IU_BPM_PROC_OV_CONFIG_ATT ENABLE';
		END IF;
         --UPDATE_MILESTONE_WITH_ERROR('post_data_model');
         raise_application_error(-20000, 'ERROR: Some Other fatal error occured' || SQLERRM);
 END;
--~^UTDELIM^~--

DECLARE
   HASENTRY NUMBER;
     sqlQuery clob:='update bpm_proc_ov_config_att set value = 10 where key = 1 and name = ''order''';
BEGIN

SELECT COUNT(*) INTO HASENTRY FROM USER_TRIGGERS 
		WHERE TRIGGER_NAME = 'IU_BPM_PROC_OV_CONFIG_ATT'; 
		IF HASENTRY > 0 THEN 
		EXECUTE IMMEDIATE 'ALTER TRIGGER IU_BPM_PROC_OV_CONFIG_ATT DISABLE';
		END IF;
		
     EXECUTE IMMEDIATE sqlQuery;
	 
	 SELECT COUNT(*) INTO HASENTRY FROM USER_TRIGGERS 
		WHERE TRIGGER_NAME = 'IU_BPM_PROC_OV_CONFIG_ATT'; 
		IF HASENTRY > 0 THEN 
		EXECUTE IMMEDIATE 'ALTER TRIGGER IU_BPM_PROC_OV_CONFIG_ATT ENABLE';
		END IF;
		
     dbms_output.put_line('SUCCESS: ' || sqlQuery);
     dbms_output.put_line('No of Rows Updated:' || sql%rowcount);
     EXCEPTION
        WHEN OTHERS THEN
		IF HASENTRY > 0 THEN 
		EXECUTE IMMEDIATE 'ALTER TRIGGER IU_BPM_PROC_OV_CONFIG_ATT ENABLE';
		END IF;
         --UPDATE_MILESTONE_WITH_ERROR('post_data_model');
         raise_application_error(-20000, 'ERROR: Some Other fatal error occured' || SQLERRM);
 END;
--~^UTDELIM^~--

DECLARE
 HASENTRY NUMBER;
     sqlQuery clob:='update bpm_proc_ov_config_att set value = 20 where key = 2 and name = ''order''';
BEGIN

    SELECT COUNT(*) INTO HASENTRY FROM USER_TRIGGERS 
		WHERE TRIGGER_NAME = 'IU_BPM_PROC_OV_CONFIG_ATT'; 
		IF HASENTRY > 0 THEN 
		EXECUTE IMMEDIATE 'ALTER TRIGGER IU_BPM_PROC_OV_CONFIG_ATT DISABLE';
		END IF;
		
     EXECUTE IMMEDIATE sqlQuery;
	 
	  SELECT COUNT(*) INTO HASENTRY FROM USER_TRIGGERS 
		WHERE TRIGGER_NAME = 'IU_BPM_PROC_OV_CONFIG_ATT'; 
		IF HASENTRY > 0 THEN 
		EXECUTE IMMEDIATE 'ALTER TRIGGER IU_BPM_PROC_OV_CONFIG_ATT ENABLE';
		END IF;
		
     dbms_output.put_line('SUCCESS: ' || sqlQuery);
     dbms_output.put_line('No of Rows Updated:' || sql%rowcount);
     EXCEPTION
        WHEN OTHERS THEN
		IF HASENTRY > 0 THEN 
		EXECUTE IMMEDIATE 'ALTER TRIGGER IU_BPM_PROC_OV_CONFIG_ATT ENABLE';
		END IF;
         --UPDATE_MILESTONE_WITH_ERROR('post_data_model');
         raise_application_error(-20000, 'ERROR: Some Other fatal error occured' || SQLERRM);
 END;
--~^UTDELIM^~--

DECLARE
 HASENTRY NUMBER;
     sqlQuery clob:='update bpm_proc_ov_config_att set value = 30 where key = 3 and name = ''order''';
BEGIN

SELECT COUNT(*) INTO HASENTRY FROM USER_TRIGGERS 
		WHERE TRIGGER_NAME = 'IU_BPM_PROC_OV_CONFIG_ATT'; 
		IF HASENTRY > 0 THEN 
		EXECUTE IMMEDIATE 'ALTER TRIGGER IU_BPM_PROC_OV_CONFIG_ATT DISABLE';
		END IF;
		
	 EXECUTE IMMEDIATE sqlQuery;
	 
	  SELECT COUNT(*) INTO HASENTRY FROM USER_TRIGGERS 
		WHERE TRIGGER_NAME = 'IU_BPM_PROC_OV_CONFIG_ATT'; 
		IF HASENTRY > 0 THEN 
		EXECUTE IMMEDIATE 'ALTER TRIGGER IU_BPM_PROC_OV_CONFIG_ATT ENABLE';
		END IF;
		
     dbms_output.put_line('SUCCESS: ' || sqlQuery);
     dbms_output.put_line('No of Rows Updated:' || sql%rowcount);
     EXCEPTION
        WHEN OTHERS THEN
		IF HASENTRY > 0 THEN 
		EXECUTE IMMEDIATE 'ALTER TRIGGER IU_BPM_PROC_OV_CONFIG_ATT ENABLE';
		END IF;
         --UPDATE_MILESTONE_WITH_ERROR('post_data_model');
         raise_application_error(-20000, 'ERROR: Some Other fatal error occured' || SQLERRM);
 END;
--~^UTDELIM^~--

DECLARE
 HASENTRY NUMBER;
     sqlQuery clob:='update bpm_proc_ov_config_att set value = 40 where key = 4 and name = ''order''';
BEGIN
SELECT COUNT(*) INTO HASENTRY FROM USER_TRIGGERS 
		WHERE TRIGGER_NAME = 'IU_BPM_PROC_OV_CONFIG_ATT'; 
		IF HASENTRY > 0 THEN 
		EXECUTE IMMEDIATE 'ALTER TRIGGER IU_BPM_PROC_OV_CONFIG_ATT DISABLE';
		END IF;
		
     EXECUTE IMMEDIATE sqlQuery;
	 
	  SELECT COUNT(*) INTO HASENTRY FROM USER_TRIGGERS 
		WHERE TRIGGER_NAME = 'IU_BPM_PROC_OV_CONFIG_ATT'; 
		IF HASENTRY > 0 THEN 
		EXECUTE IMMEDIATE 'ALTER TRIGGER IU_BPM_PROC_OV_CONFIG_ATT ENABLE';
		END IF;
	 
     dbms_output.put_line('SUCCESS: ' || sqlQuery);
     dbms_output.put_line('No of Rows Updated:' || sql%rowcount);
     EXCEPTION
        WHEN OTHERS THEN
		IF HASENTRY > 0 THEN 
		EXECUTE IMMEDIATE 'ALTER TRIGGER IU_BPM_PROC_OV_CONFIG_ATT ENABLE';
		END IF;
         --UPDATE_MILESTONE_WITH_ERROR('post_data_model');
         raise_application_error(-20000, 'ERROR: Some Other fatal error occured'|| SQLERRM);
 END;
--~^UTDELIM^~--

BEGIN
  EXECUTE IMMEDIATE 'DROP MATERIALIZED VIEW class_rel_presentation';
EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE != -12003 THEN
      RAISE;
    END IF;
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
  where p1.presentation_cntx = '/EC'
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

DECLARE 
	 index_exists  exception;  
 	 pragma exception_init (index_exists , -00955);  
	 sqlQuery clob:='create unique index uix_class_rel_presentation on class_rel_presentation(from_class_name,to_class_name, role_name) TABLESPACE &ts_index'; 
BEGIN 
	 EXECUTE IMMEDIATE sqlQuery; 
	 dbms_output.put_line('SUCCESS: ' || sqlQuery); 
	 EXCEPTION 
	 	 when index_exists  then 
  	 	 	 dbms_output.put_line('WARNING: ' || sqlQuery); 
  	 	 	 dbms_output.put_line('ORA-00955: name is already being used by existing object'); 
  	 	 WHEN OTHERS THEN 
	 	 	 --UPDATE_MILESTONE_WITH_ERROR('post_data_model'); 
	 	 	 raise_application_error(-20000, 'FATAL  ERROR: ' || sqlerrm); 
END;
--~^UTDELIM^~--

DECLARE 
	 index_exists  exception;  
 	 pragma exception_init (index_exists , -00955);  
	 sqlQuery clob:='CREATE INDEX IR_CLASS_REL_PRESENTATION ON CLASS_REL_PRESENTATION (REC_ID) INITRANS 2 MAXTRANS 255 PCTFREE 50 STORAGE ( PCTINCREASE 50 NEXT 65536 ) TABLESPACE &ts_index'; 
BEGIN 
	 EXECUTE IMMEDIATE sqlQuery; 
	 dbms_output.put_line('SUCCESS: ' || sqlQuery); 
	 EXCEPTION 
	 	 when index_exists  then 
  	 	 	 dbms_output.put_line('WARNING: ' || sqlQuery); 
  	 	 	 dbms_output.put_line('ORA-00955: name is already being used by existing object'); 
  	 	 WHEN OTHERS THEN 
	 	 	 --UPDATE_MILESTONE_WITH_ERROR('post_data_model'); 
	 	 	 raise_application_error(-20000, 'FATAL  ERROR: ' || sqlerrm); 
END;
--~^UTDELIM^~--

DECLARE
 HASENTRY NUMBER;
     sqlQuery clob:='update bpm_proc_ov_config_att set value = 40 where key = 4 and name = ''order''';
BEGIN
SELECT COUNT(*) INTO HASENTRY FROM USER_TRIGGERS 
		WHERE TRIGGER_NAME = 'IU_BPM_PROC_OV_CONFIG_ATT'; 
		IF HASENTRY > 0 THEN 
		EXECUTE IMMEDIATE 'ALTER TRIGGER IU_BPM_PROC_OV_CONFIG_ATT DISABLE';
		END IF;

     EXECUTE IMMEDIATE sqlQuery;
	 
	   SELECT COUNT(*) INTO HASENTRY FROM USER_TRIGGERS 
		WHERE TRIGGER_NAME = 'IU_BPM_PROC_OV_CONFIG_ATT'; 
		IF HASENTRY > 0 THEN 
		EXECUTE IMMEDIATE 'ALTER TRIGGER IU_BPM_PROC_OV_CONFIG_ATT ENABLE';
		END IF;
	 
     dbms_output.put_line('SUCCESS: ' || sqlQuery);
     dbms_output.put_line('No of Rows Updated:' || sql%rowcount);
     EXCEPTION
        WHEN OTHERS THEN
		IF HASENTRY > 0 THEN 
		EXECUTE IMMEDIATE 'ALTER TRIGGER IU_BPM_PROC_OV_CONFIG_ATT ENABLE';
		END IF;
         --UPDATE_MILESTONE_WITH_ERROR('post_data_model');
         raise_application_error(-20000, 'ERROR: Some Other fatal error occured'|| SQLERRM);
 END;
--~^UTDELIM^~--

BEGIN
  EXECUTE IMMEDIATE 'DROP MATERIALIZED VIEW class_attr_presentation';
EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE != -12003 THEN
      RAISE;
    END IF;
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
  where p1.presentation_cntx in ('/EC')
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

DECLARE 
	 index_exists  exception;  
 	 pragma exception_init (index_exists , -00955);  
	 sqlQuery clob:='create unique index uix_class_attr_presentation on class_attr_presentation(class_name,attribute_name) TABLESPACE &ts_index'; 
BEGIN 
	 EXECUTE IMMEDIATE sqlQuery; 
	 dbms_output.put_line('SUCCESS: ' || sqlQuery); 
	 EXCEPTION 
	 	 when index_exists  then 
  	 	 	 dbms_output.put_line('WARNING: ' || sqlQuery); 
  	 	 	 dbms_output.put_line('ORA-00955: name is already being used by existing object'); 
  	 	 WHEN OTHERS THEN 
	 	 	 --UPDATE_MILESTONE_WITH_ERROR('post_data_model'); 
	 	 	 raise_application_error(-20000, 'FATAL  ERROR: ' || sqlerrm); 
END;
--~^UTDELIM^~--

DECLARE 
	 index_exists  exception;  
 	 pragma exception_init (index_exists , -00955);  
	 sqlQuery clob:='CREATE INDEX IR_CLASS_ATTR_PRESENTATION ON CLASS_ATTR_PRESENTATION (REC_ID) INITRANS 2 MAXTRANS 255 PCTFREE 50 STORAGE ( PCTINCREASE 50 NEXT 65536 ) TABLESPACE &ts_index'; 
BEGIN 
	 EXECUTE IMMEDIATE sqlQuery; 
	 dbms_output.put_line('SUCCESS: ' || sqlQuery); 
	 EXCEPTION 
	 	 when index_exists  then 
  	 	 	 dbms_output.put_line('WARNING: ' || sqlQuery); 
  	 	 	 dbms_output.put_line('ORA-00955: name is already being used by existing object'); 
  	 	 WHEN OTHERS THEN 
	 	 	 --UPDATE_MILESTONE_WITH_ERROR('post_data_model'); 
	 	 	 raise_application_error(-20000, 'FATAL  ERROR: ' || sqlerrm); 
END;
--~^UTDELIM^~--
	COMMENT ON TABLE CTRL_ANALYTICS IS 'This table is used for storing analytics data'
--~^UTDELIM^~--

	COMMENT ON COLUMN CTRL_ANALYTICS.EVENT_ID IS 'Unique ID for a Analytics event. Typically a SYS_GUID().'
--~^UTDELIM^~--

	COMMENT ON COLUMN CTRL_ANALYTICS.EVENT_NAME IS 'Name of Analytics event.'
--~^UTDELIM^~--

	COMMENT ON COLUMN CTRL_ANALYTICS.CATEGORY IS 'Category of Analytics event.'
--~^UTDELIM^~--

	COMMENT ON COLUMN CTRL_ANALYTICS.DAYTIME IS 'Date/time stamp of Analytics event.'
--~^UTDELIM^~--

	COMMENT ON COLUMN CTRL_ANALYTICS.USER_ID IS 'User ID for a Analytics event.'
--~^UTDELIM^~--

	COMMENT ON COLUMN CTRL_ANALYTICS.SOURCE IS 'Source for a Analytics event.'
--~^UTDELIM^~--

	COMMENT ON COLUMN CTRL_ANALYTICS.PAYLOAD_A IS 'Payload text A for a Analytics event.'
--~^UTDELIM^~--

	COMMENT ON COLUMN CTRL_ANALYTICS.PAYLOAD_B IS 'Payload text B for a Analytics event.'
--~^UTDELIM^~--

	COMMENT ON COLUMN CTRL_ANALYTICS.PAYLOAD_C IS 'Payload number C for a Analytics event.'
--~^UTDELIM^~--

	COMMENT ON COLUMN CTRL_ANALYTICS.PAYLOAD_D IS 'Payload number D for a Analytics event.'
--~^UTDELIM^~--

	COMMENT ON COLUMN CTRL_ANALYTICS.SUMMARY IS 'Summary text for a Analytics event.'
--~^UTDELIM^~--

	COMMENT ON COLUMN CTRL_ANALYTICS.DETAIL IS 'Detailed text for a Analytics event.'
--~^UTDELIM^~--

	COMMENT ON TABLE CTRL_JOB_EXEC IS 'Tracks history of the asyncronous JobExecutor'
--~^UTDELIM^~--

	COMMENT ON TABLE IMP_AGENT_CONFIG IS 'Holding configuration values for ECIS agents'
--~^UTDELIM^~--

	COMMENT ON TABLE CALC_GRP_CONTEXT IS 'List of Calculation Group contexts.'
--~^UTDELIM^~--

	COMMENT ON TABLE CALC_GRP_CONTEXT_VERSION IS 'List of Calculation Group contexts.'
--~^UTDELIM^~--

	COMMENT ON TABLE CALC_GRP_CONTEXT_VERSION_JN IS 'List of Calculation Group contexts.'
--~^UTDELIM^~--

BEGIN 
	delete from BPM_PROC_OV_LIST_PROPERTY where property_clazz = 'HIx29f+7-parent_process_template_name';
END;
--~^UTDELIM^~--

BEGIN 
	delete from BPM_PROC_OV_LIST_PROPERTY where property_clazz = '6rBUAERQ-parent_process_ins_id';
END;
--~^UTDELIM^~--

BEGIN 
	delete from BPM_PROC_OV_LIST_PROPERTY where property_clazz = 'ZWoMd+C3-parent_process_id';
END;
--~^UTDELIM^~--

BEGIN
	DELETE ctrl_system_attribute WHERE attribute_type = 'UTC2LOCALDEFAULT';
END;
--~^UTDELIM^~--

BEGIN
	DELETE ctrl_system_attribute WHERE attribute_type = 'UTC2LOCAL_DIFF';
END;
--~^UTDELIM^~--

begin
	update EC_JBPM_TASK set COMMENTS = TEXT_3,last_updated_by = last_updated_by, last_updated_date = last_updated_date
	 WHERE ( (COMMENTS <> TEXT_3)
		  OR (COMMENTS is null and TEXT_3 is not null))
	 AND TABLE_CLASS_NAME='EC_JBPM_TASK';
end;
--~^UTDELIM^~--

begin
update EC_JBPM_TASK set NO = TEXT_2,last_updated_by = last_updated_by, last_updated_date = last_updated_date
 WHERE ( (NO <> TEXT_2)
      OR (NO is null and TEXT_2 is not null))
 AND TABLE_CLASS_NAME='EC_JBPM_TASK';
end;
--~^UTDELIM^~--


begin
	update EC_JBPM_TASK set YES = TEXT_1,last_updated_by = last_updated_by, last_updated_date = last_updated_date
	 WHERE ( (YES <> TEXT_1)
		  OR (YES is null and TEXT_1 is not null))
	 AND TABLE_CLASS_NAME='EC_JBPM_TASK';
end;
--~^UTDELIM^~--


begin
	update EC_JBPM_TASK set COMMENTS = TEXT_1,last_updated_by = last_updated_by, last_updated_date = last_updated_date
	 WHERE ( (COMMENTS <> TEXT_1)
		  OR (COMMENTS is null and TEXT_1 is not null))
	 AND TABLE_CLASS_NAME='EC_JBPM_TASK_2';
end;
--~^UTDELIM^~--


begin
	update EC_JBPM_TASK set START_DATE = DATE_1,last_updated_by = last_updated_by, last_updated_date = last_updated_date
	 WHERE ( (START_DATE <> DATE_1)
		  OR (START_DATE is null and DATE_1 is not null))
	 AND TABLE_CLASS_NAME='EC_JBPM_TASK_2';
end;
--~^UTDELIM^~--


begin
	update EC_JBPM_TASK set COMMENTS = TEXT_2,last_updated_by = last_updated_by, last_updated_date = last_updated_date
	 WHERE ( (COMMENTS <> TEXT_2)
		  OR (COMMENTS is null and TEXT_2 is not null))
	 AND TABLE_CLASS_NAME='EC_JBPM_TASK_3';
end;
--~^UTDELIM^~--


begin
	update EC_JBPM_TASK set FCTY_OBJECT_ID = TEXT_1,last_updated_by = last_updated_by, last_updated_date = last_updated_date
	 WHERE ( (FCTY_OBJECT_ID <> TEXT_1)
		  OR (FCTY_OBJECT_ID is null and TEXT_1 is not null))
	 AND TABLE_CLASS_NAME='EC_JBPM_TASK_3';
end;
--~^UTDELIM^~--


begin
	update EC_JBPM_TASK set START_DATE = DATE_1,last_updated_by = last_updated_by, last_updated_date = last_updated_date
	 WHERE ( (START_DATE <> DATE_1)
		  OR (START_DATE is null and DATE_1 is not null))
	 AND TABLE_CLASS_NAME='EC_JBPM_TASK_3';
end;
--~^UTDELIM^~--


begin
	update TAG_EVENT_STATUS set AVG_BH_PRESS = VALUE_3,last_updated_by = last_updated_by, last_updated_date = last_updated_date
	 WHERE ( (AVG_BH_PRESS <> VALUE_3)
		  OR (AVG_BH_PRESS is null and VALUE_3 is not null))
	 AND STAGING_TYPE='TAG_EVENT_STATUS_1';
end;
--~^UTDELIM^~--


begin
	update TAG_EVENT_STATUS set AVG_BH_TEMP = VALUE_4,last_updated_by = last_updated_by, last_updated_date = last_updated_date
	 WHERE ( (AVG_BH_TEMP <> VALUE_4)
		  OR (AVG_BH_TEMP is null and VALUE_4 is not null))
	 AND STAGING_TYPE='TAG_EVENT_STATUS_1';
end;
--~^UTDELIM^~--


begin
	update TAG_EVENT_STATUS set AVG_WH_PRESS = VALUE_1,last_updated_by = last_updated_by, last_updated_date = last_updated_date
	 WHERE ( (AVG_WH_PRESS <> VALUE_1)
		  OR (AVG_WH_PRESS is null and VALUE_1 is not null))
	 AND STAGING_TYPE='TAG_EVENT_STATUS_1';
end;
--~^UTDELIM^~--


begin
	update TAG_EVENT_STATUS set AVG_WH_TEMP = VALUE_2,last_updated_by = last_updated_by, last_updated_date = last_updated_date
	 WHERE ( (AVG_WH_TEMP <> VALUE_2)
		  OR (AVG_WH_TEMP is null and VALUE_2 is not null))
	 AND STAGING_TYPE='TAG_EVENT_STATUS_1';
end;
--~^UTDELIM^~--


begin
	update TAG_EVENT_STATUS set AVG_GAS_RATE = VALUE_2,last_updated_by = last_updated_by, last_updated_date = last_updated_date
	 WHERE ( (AVG_GAS_RATE <> VALUE_2)
		  OR (AVG_GAS_RATE is null and VALUE_2 is not null))
	 AND STAGING_TYPE='TAG_EVENT_STATUS_2';
end;
--~^UTDELIM^~--


begin
	update TAG_EVENT_STATUS set AVG_OIL_RATE = VALUE_1,last_updated_by = last_updated_by, last_updated_date = last_updated_date
	 WHERE ( (AVG_OIL_RATE <> VALUE_1)
		  OR (AVG_OIL_RATE is null and VALUE_1 is not null))
	 AND STAGING_TYPE='TAG_EVENT_STATUS_2';
end;
--~^UTDELIM^~--


begin
	update TAG_EVENT_STATUS set AVG_WATER_RATE = VALUE_3,last_updated_by = last_updated_by, last_updated_date = last_updated_date
	 WHERE ( (AVG_WATER_RATE <> VALUE_3)
		  OR (AVG_WATER_RATE is null and VALUE_3 is not null))
	 AND STAGING_TYPE='TAG_EVENT_STATUS_2';
end;
--~^UTDELIM^~--


begin
	update TAG_EVENT_STATUS set AVG_OIL_RATE = VALUE_1,last_updated_by = last_updated_by, last_updated_date = last_updated_date
	 WHERE ( (AVG_OIL_RATE <> VALUE_1)
		  OR (AVG_OIL_RATE is null and VALUE_1 is not null))
	 AND STAGING_TYPE='TAG_EVENT_STATUS_3';
end;
--~^UTDELIM^~--


begin
	update EQPM_EVENT_STATUS set REPDATE = DATE_1,last_updated_by = last_updated_by, last_updated_date = last_updated_date
	 WHERE ( (REPDATE <> DATE_1)
		  OR (REPDATE is null and DATE_1 is not null))
	 AND EQPM_EVENT_STATUS.CLASS_NAME='EQPM_COND_SURGE_DRUM';
end;
--~^UTDELIM^~--


begin
	update EQPM_EVENT_STATUS set REPDATE = DATE_1,last_updated_by = last_updated_by, last_updated_date = last_updated_date
	 WHERE ( (REPDATE <> DATE_1)
		  OR (REPDATE is null and DATE_1 is not null))
	 AND EQPM_EVENT_STATUS.CLASS_NAME='EQPM_DEHYDRATOR';
end;
--~^UTDELIM^~--


begin
	update EQPM_EVENT_STATUS set REPDATE = DATE_1,last_updated_by = last_updated_by, last_updated_date = last_updated_date
	 WHERE ( (REPDATE <> DATE_1)
		  OR (REPDATE is null and DATE_1 is not null))
	 AND EQPM_EVENT_STATUS.CLASS_NAME='EQPM_EMULSIFIER';
end;
--~^UTDELIM^~--


begin
	update EQPM_EVENT_STATUS set REPDATE = DATE_1,last_updated_by = last_updated_by, last_updated_date = last_updated_date
	 WHERE ( (REPDATE <> DATE_1)
		  OR (REPDATE is null and DATE_1 is not null))
	 AND EQPM_EVENT_STATUS.CLASS_NAME='EQPM_CHILLER';
end;
--~^UTDELIM^~--


begin
	update EQPM_EVENT_STATUS set REPDATE = DATE_1,last_updated_by = last_updated_by, last_updated_date = last_updated_date
	 WHERE ( (REPDATE <> DATE_1)
		  OR (REPDATE is null and DATE_1 is not null))
	 AND EQPM_EVENT_STATUS.CLASS_NAME='EQPM_CO2_REMOVAL';
end;
--~^UTDELIM^~--


begin
	update EQPM_EVENT_STATUS set REPDATE = DATE_1,last_updated_by = last_updated_by, last_updated_date = last_updated_date
	 WHERE ( (REPDATE <> DATE_1)
		  OR (REPDATE is null and DATE_1 is not null))
	 AND EQPM_EVENT_STATUS.CLASS_NAME='EQPM_MERCURY_REMOVAL';
end;
--~^UTDELIM^~--


begin
	update EQPM_EVENT_STATUS set REPDATE = DATE_1,last_updated_by = last_updated_by, last_updated_date = last_updated_date
	 WHERE ( (REPDATE <> DATE_1)
		  OR (REPDATE is null and DATE_1 is not null))
	 AND EQPM_EVENT_STATUS.CLASS_NAME='EQPM_REBOILER';
end;
--~^UTDELIM^~--


begin
	update EQPM_EVENT_STATUS set CARFILTERIN = DATE_3,last_updated_by = last_updated_by, last_updated_date = last_updated_date
	 WHERE ( (CARFILTERIN <> DATE_3)
		  OR (CARFILTERIN is null and DATE_3 is not null))
	 AND EQPM_EVENT_STATUS.CLASS_NAME='EQPM_REVERSE_OSMOSIS';
end;
--~^UTDELIM^~--


begin
update EQPM_EVENT_STATUS set CARFILTEROUT = DATE_4,last_updated_by = last_updated_by, last_updated_date = last_updated_date
 WHERE ( (CARFILTEROUT <> DATE_4)
      OR (CARFILTEROUT is null and DATE_4 is not null))
 AND EQPM_EVENT_STATUS.CLASS_NAME='EQPM_REVERSE_OSMOSIS';
end;
--~^UTDELIM^~--


begin
update EQPM_EVENT_STATUS set MMFILTERIN = DATE_1,last_updated_by = last_updated_by, last_updated_date = last_updated_date
 WHERE ( (MMFILTERIN <> DATE_1)
      OR (MMFILTERIN is null and DATE_1 is not null))
 AND EQPM_EVENT_STATUS.CLASS_NAME='EQPM_REVERSE_OSMOSIS';
end;
--~^UTDELIM^~--


begin
update EQPM_EVENT_STATUS set MMFILTEROUT = DATE_2,last_updated_by = last_updated_by, last_updated_date = last_updated_date
 WHERE ( (MMFILTEROUT <> DATE_2)
      OR (MMFILTEROUT is null and DATE_2 is not null))
 AND EQPM_EVENT_STATUS.CLASS_NAME='EQPM_REVERSE_OSMOSIS';
end;
--~^UTDELIM^~--


begin
update EQPM_EVENT_STATUS set ROFILTERIN = DATE_5,last_updated_by = last_updated_by, last_updated_date = last_updated_date
 WHERE ( (ROFILTERIN <> DATE_5)
      OR (ROFILTERIN is null and DATE_5 is not null))
 AND EQPM_EVENT_STATUS.CLASS_NAME='EQPM_REVERSE_OSMOSIS';
end;
--~^UTDELIM^~--


begin
update EQPM_EVENT_STATUS set ROFILTEROUT = DATE_6,last_updated_by = last_updated_by, last_updated_date = last_updated_date
 WHERE ( (ROFILTEROUT <> DATE_6)
      OR (ROFILTEROUT is null and DATE_6 is not null))
 AND EQPM_EVENT_STATUS.CLASS_NAME='EQPM_REVERSE_OSMOSIS';
end;
--~^UTDELIM^~--


begin
update EQPM_EVENT_STATUS set REPDATE = DATE_1,last_updated_by = last_updated_by, last_updated_date = last_updated_date
 WHERE ( (REPDATE <> DATE_1)
      OR (REPDATE is null and DATE_1 is not null))
 AND EQPM_EVENT_STATUS.CLASS_NAME='EQPM_STABILIZER';
end;
--~^UTDELIM^~--


begin
update EQPM_EVENT_STATUS set REPDATE = DATE_1,last_updated_by = last_updated_by, last_updated_date = last_updated_date
 WHERE ( (REPDATE <> DATE_1)
      OR (REPDATE is null and DATE_1 is not null))
 AND EQPM_EVENT_STATUS.CLASS_NAME='EQPM_WATER_TREATMENT';
end;
--~^UTDELIM^~--


begin
update CONTRACT_PARTY_SHARE set BALANCE_IND = TEXT_1,last_updated_by = last_updated_by, last_updated_date = last_updated_date
 WHERE ( (BALANCE_IND <> TEXT_1)
      OR (BALANCE_IND is null and TEXT_1 is not null))
 AND EC_COMPANY.class_name(CONTRACT_PARTY_SHARE.COMPANY_ID) = 'COMPANY';
end;
--~^UTDELIM^~--


begin
update CONTRACT_PARTY_SHARE set BALANCE_IND = TEXT_1,last_updated_by = last_updated_by, last_updated_date = last_updated_date
 WHERE ( (BALANCE_IND <> TEXT_1)
      OR (BALANCE_IND is null and TEXT_1 is not null))
 AND CLASS_NAME = 'DIVISION_ORDER_SHARE';
end;
--~^UTDELIM^~--


begin
update CONTRACT_PARTY_SHARE set BALANCE_IND = TEXT_1,last_updated_by = last_updated_by, last_updated_date = last_updated_date
 WHERE ( (BALANCE_IND <> TEXT_1)
      OR (BALANCE_IND is null and TEXT_1 is not null))
 AND CLASS_NAME = 'ROYALTY_PARTY_SHARE';
end;
--~^UTDELIM^~--



begin
update EC_JBPM_TASK_JN set COMMENTS = TEXT_3,last_updated_by = last_updated_by, last_updated_date = last_updated_date
 WHERE ( (COMMENTS <> TEXT_3)
      OR (COMMENTS is null and TEXT_3 is not null))
 AND TABLE_CLASS_NAME='EC_JBPM_TASK';
end;
--~^UTDELIM^~--


begin
update EC_JBPM_TASK_JN set NO = TEXT_2,last_updated_by = last_updated_by, last_updated_date = last_updated_date
 WHERE ( (NO <> TEXT_2)
      OR (NO is null and TEXT_2 is not null))
 AND TABLE_CLASS_NAME='EC_JBPM_TASK';
end;
--~^UTDELIM^~--


begin
update EC_JBPM_TASK_JN set YES = TEXT_1,last_updated_by = last_updated_by, last_updated_date = last_updated_date
 WHERE ( (YES <> TEXT_1)
      OR (YES is null and TEXT_1 is not null))
 AND TABLE_CLASS_NAME='EC_JBPM_TASK';
end;
--~^UTDELIM^~--


begin
update EC_JBPM_TASK_JN set COMMENTS = TEXT_1,last_updated_by = last_updated_by, last_updated_date = last_updated_date
 WHERE ( (COMMENTS <> TEXT_1)
      OR (COMMENTS is null and TEXT_1 is not null))
 AND TABLE_CLASS_NAME='EC_JBPM_TASK_2';
end;
--~^UTDELIM^~--


begin
update EC_JBPM_TASK_JN set START_DATE = DATE_1,last_updated_by = last_updated_by, last_updated_date = last_updated_date
 WHERE ( (START_DATE <> DATE_1)
      OR (START_DATE is null and DATE_1 is not null))
 AND TABLE_CLASS_NAME='EC_JBPM_TASK_2';
end;
--~^UTDELIM^~--


begin
update EC_JBPM_TASK_JN set COMMENTS = TEXT_2,last_updated_by = last_updated_by, last_updated_date = last_updated_date
 WHERE ( (COMMENTS <> TEXT_2)
      OR (COMMENTS is null and TEXT_2 is not null))
 AND TABLE_CLASS_NAME='EC_JBPM_TASK_3';
end;
--~^UTDELIM^~--


begin
update EC_JBPM_TASK_JN set FCTY_OBJECT_ID = TEXT_1,last_updated_by = last_updated_by, last_updated_date = last_updated_date
 WHERE ( (FCTY_OBJECT_ID <> TEXT_1)
      OR (FCTY_OBJECT_ID is null and TEXT_1 is not null))
 AND TABLE_CLASS_NAME='EC_JBPM_TASK_3';
end;
--~^UTDELIM^~--


begin
update EC_JBPM_TASK_JN set START_DATE = DATE_1,last_updated_by = last_updated_by, last_updated_date = last_updated_date
 WHERE ( (START_DATE <> DATE_1)
      OR (START_DATE is null and DATE_1 is not null))
 AND TABLE_CLASS_NAME='EC_JBPM_TASK_3';
end;
--~^UTDELIM^~--


begin
update TAG_EVENT_STATUS_JN set AVG_BH_PRESS = VALUE_3,last_updated_by = last_updated_by, last_updated_date = last_updated_date
 WHERE ( (AVG_BH_PRESS <> VALUE_3)
      OR (AVG_BH_PRESS is null and VALUE_3 is not null))
 AND STAGING_TYPE='TAG_EVENT_STATUS_1';
end;
--~^UTDELIM^~--


begin
update TAG_EVENT_STATUS_JN set AVG_BH_TEMP = VALUE_4,last_updated_by = last_updated_by, last_updated_date = last_updated_date
 WHERE ( (AVG_BH_TEMP <> VALUE_4)
      OR (AVG_BH_TEMP is null and VALUE_4 is not null))
 AND STAGING_TYPE='TAG_EVENT_STATUS_1';
end;
--~^UTDELIM^~--


begin
update TAG_EVENT_STATUS_JN set AVG_WH_PRESS = VALUE_1,last_updated_by = last_updated_by, last_updated_date = last_updated_date
 WHERE ( (AVG_WH_PRESS <> VALUE_1)
      OR (AVG_WH_PRESS is null and VALUE_1 is not null))
 AND STAGING_TYPE='TAG_EVENT_STATUS_1';
end;
--~^UTDELIM^~--


begin
update TAG_EVENT_STATUS_JN set AVG_WH_TEMP = VALUE_2,last_updated_by = last_updated_by, last_updated_date = last_updated_date
 WHERE ( (AVG_WH_TEMP <> VALUE_2)
      OR (AVG_WH_TEMP is null and VALUE_2 is not null))
 AND STAGING_TYPE='TAG_EVENT_STATUS_1';
end;
--~^UTDELIM^~--


begin
update TAG_EVENT_STATUS_JN set AVG_GAS_RATE = VALUE_2,last_updated_by = last_updated_by, last_updated_date = last_updated_date
 WHERE ( (AVG_GAS_RATE <> VALUE_2)
      OR (AVG_GAS_RATE is null and VALUE_2 is not null))
 AND STAGING_TYPE='TAG_EVENT_STATUS_2';
end;
--~^UTDELIM^~--


begin
update TAG_EVENT_STATUS_JN set AVG_OIL_RATE = VALUE_1,last_updated_by = last_updated_by, last_updated_date = last_updated_date
 WHERE ( (AVG_OIL_RATE <> VALUE_1)
      OR (AVG_OIL_RATE is null and VALUE_1 is not null))
 AND STAGING_TYPE='TAG_EVENT_STATUS_2';
end;
--~^UTDELIM^~--


begin
update TAG_EVENT_STATUS_JN set AVG_WATER_RATE = VALUE_3,last_updated_by = last_updated_by, last_updated_date = last_updated_date
 WHERE ( (AVG_WATER_RATE <> VALUE_3)
      OR (AVG_WATER_RATE is null and VALUE_3 is not null))
 AND STAGING_TYPE='TAG_EVENT_STATUS_2';
end;
--~^UTDELIM^~--


begin
update TAG_EVENT_STATUS_JN set AVG_OIL_RATE = VALUE_1,last_updated_by = last_updated_by, last_updated_date = last_updated_date
 WHERE ( (AVG_OIL_RATE <> VALUE_1)
      OR (AVG_OIL_RATE is null and VALUE_1 is not null))
 AND STAGING_TYPE='TAG_EVENT_STATUS_3';
end;
--~^UTDELIM^~--


begin
update EQPM_EVENT_STATUS_JN set REPDATE = DATE_1,last_updated_by = last_updated_by, last_updated_date = last_updated_date
 WHERE ( (REPDATE <> DATE_1)
      OR (REPDATE is null and DATE_1 is not null))
 AND EQPM_EVENT_STATUS_JN.CLASS_NAME='EQPM_COND_SURGE_DRUM';
end;
--~^UTDELIM^~--


begin
update EQPM_EVENT_STATUS_JN set REPDATE = DATE_1,last_updated_by = last_updated_by, last_updated_date = last_updated_date
 WHERE ( (REPDATE <> DATE_1)
      OR (REPDATE is null and DATE_1 is not null))
 AND EQPM_EVENT_STATUS_JN.CLASS_NAME='EQPM_DEHYDRATOR';
end;
--~^UTDELIM^~--


begin
update EQPM_EVENT_STATUS_JN set REPDATE = DATE_1,last_updated_by = last_updated_by, last_updated_date = last_updated_date
 WHERE ( (REPDATE <> DATE_1)
      OR (REPDATE is null and DATE_1 is not null))
 AND EQPM_EVENT_STATUS_JN.CLASS_NAME='EQPM_EMULSIFIER';
end;
--~^UTDELIM^~--


begin
update EQPM_EVENT_STATUS_JN set REPDATE = DATE_1,last_updated_by = last_updated_by, last_updated_date = last_updated_date
 WHERE ( (REPDATE <> DATE_1)
      OR (REPDATE is null and DATE_1 is not null))
 AND EQPM_EVENT_STATUS_JN.CLASS_NAME='EQPM_CHILLER';
end;
--~^UTDELIM^~--


begin
update EQPM_EVENT_STATUS_JN set REPDATE = DATE_1,last_updated_by = last_updated_by, last_updated_date = last_updated_date
 WHERE ( (REPDATE <> DATE_1)
      OR (REPDATE is null and DATE_1 is not null))
 AND EQPM_EVENT_STATUS_JN.CLASS_NAME='EQPM_CO2_REMOVAL';
end;
--~^UTDELIM^~--


begin
update EQPM_EVENT_STATUS_JN set REPDATE = DATE_1,last_updated_by = last_updated_by, last_updated_date = last_updated_date
 WHERE ( (REPDATE <> DATE_1)
      OR (REPDATE is null and DATE_1 is not null))
 AND EQPM_EVENT_STATUS_JN.CLASS_NAME='EQPM_MERCURY_REMOVAL';
end;
--~^UTDELIM^~--


begin
update EQPM_EVENT_STATUS_JN set REPDATE = DATE_1,last_updated_by = last_updated_by, last_updated_date = last_updated_date
 WHERE ( (REPDATE <> DATE_1)
      OR (REPDATE is null and DATE_1 is not null))
 AND EQPM_EVENT_STATUS_JN.CLASS_NAME='EQPM_REBOILER';
end;
--~^UTDELIM^~--


begin
update EQPM_EVENT_STATUS_JN set CARFILTERIN = DATE_3,last_updated_by = last_updated_by, last_updated_date = last_updated_date
 WHERE ( (CARFILTERIN <> DATE_3)
      OR (CARFILTERIN is null and DATE_3 is not null))
 AND EQPM_EVENT_STATUS_JN.CLASS_NAME='EQPM_REVERSE_OSMOSIS';
end;
--~^UTDELIM^~--


begin
update EQPM_EVENT_STATUS_JN set CARFILTEROUT = DATE_4,last_updated_by = last_updated_by, last_updated_date = last_updated_date
 WHERE ( (CARFILTEROUT <> DATE_4)
      OR (CARFILTEROUT is null and DATE_4 is not null))
 AND EQPM_EVENT_STATUS_JN.CLASS_NAME='EQPM_REVERSE_OSMOSIS';
end;
--~^UTDELIM^~--


begin
update EQPM_EVENT_STATUS_JN set MMFILTERIN = DATE_1,last_updated_by = last_updated_by, last_updated_date = last_updated_date
 WHERE ( (MMFILTERIN <> DATE_1)
      OR (MMFILTERIN is null and DATE_1 is not null))
 AND EQPM_EVENT_STATUS_JN.CLASS_NAME='EQPM_REVERSE_OSMOSIS';
end;
--~^UTDELIM^~--


begin
update EQPM_EVENT_STATUS_JN set MMFILTEROUT = DATE_2,last_updated_by = last_updated_by, last_updated_date = last_updated_date
 WHERE ( (MMFILTEROUT <> DATE_2)
      OR (MMFILTEROUT is null and DATE_2 is not null))
 AND EQPM_EVENT_STATUS_JN.CLASS_NAME='EQPM_REVERSE_OSMOSIS';
end;
--~^UTDELIM^~--


begin
update EQPM_EVENT_STATUS_JN set ROFILTERIN = DATE_5,last_updated_by = last_updated_by, last_updated_date = last_updated_date
 WHERE ( (ROFILTERIN <> DATE_5)
      OR (ROFILTERIN is null and DATE_5 is not null))
 AND EQPM_EVENT_STATUS_JN.CLASS_NAME='EQPM_REVERSE_OSMOSIS';
end;
--~^UTDELIM^~--


begin
update EQPM_EVENT_STATUS_JN set ROFILTEROUT = DATE_6,last_updated_by = last_updated_by, last_updated_date = last_updated_date
 WHERE ( (ROFILTEROUT <> DATE_6)
      OR (ROFILTEROUT is null and DATE_6 is not null))
 AND EQPM_EVENT_STATUS_JN.CLASS_NAME='EQPM_REVERSE_OSMOSIS';
end;
--~^UTDELIM^~--


begin
update EQPM_EVENT_STATUS_JN set REPDATE = DATE_1,last_updated_by = last_updated_by, last_updated_date = last_updated_date
 WHERE ( (REPDATE <> DATE_1)
      OR (REPDATE is null and DATE_1 is not null))
 AND EQPM_EVENT_STATUS_JN.CLASS_NAME='EQPM_STABILIZER';
end;
--~^UTDELIM^~--


begin
update EQPM_EVENT_STATUS_JN set REPDATE = DATE_1,last_updated_by = last_updated_by, last_updated_date = last_updated_date
 WHERE ( (REPDATE <> DATE_1)
      OR (REPDATE is null and DATE_1 is not null))
 AND EQPM_EVENT_STATUS_JN.CLASS_NAME='EQPM_WATER_TREATMENT';
end;
--~^UTDELIM^~--


begin
update CONTRACT_PARTY_SHARE_JN set BALANCE_IND = TEXT_1,last_updated_by = last_updated_by, last_updated_date = last_updated_date
 WHERE ( (BALANCE_IND <> TEXT_1)
      OR (BALANCE_IND is null and TEXT_1 is not null))
 AND EC_COMPANY.class_name(CONTRACT_PARTY_SHARE_JN.COMPANY_ID) = 'COMPANY';
end;
--~^UTDELIM^~--


begin
update CONTRACT_PARTY_SHARE_JN set BALANCE_IND = TEXT_1,last_updated_by = last_updated_by, last_updated_date = last_updated_date
 WHERE ( (BALANCE_IND <> TEXT_1)
      OR (BALANCE_IND is null and TEXT_1 is not null))
 AND CLASS_NAME = 'DIVISION_ORDER_SHARE';
end;
--~^UTDELIM^~--


begin
update CONTRACT_PARTY_SHARE_JN set BALANCE_IND = TEXT_1,last_updated_by = last_updated_by, last_updated_date = last_updated_date
 WHERE ( (BALANCE_IND <> TEXT_1)
      OR (BALANCE_IND is null and TEXT_1 is not null))
 AND CLASS_NAME = 'ROYALTY_PARTY_SHARE';
end;
--~^UTDELIM^~--

begin
update REVN_LOG set PARAM_TEXT_1 = TEXT_1,last_updated_by = last_updated_by, last_updated_date = last_updated_date
 WHERE ( (PARAM_TEXT_1 <> TEXT_1)
      OR (PARAM_TEXT_1 is null and TEXT_1 is not null))
 AND CATEGORY = 'COST_MAP';
end;
--~^UTDELIM^~--


begin
update REVN_LOG set PARAM_DATE_1 = DATE_1,last_updated_by = last_updated_by, last_updated_date = last_updated_date
 WHERE ( (PARAM_DATE_1 <> DATE_1)
      OR (PARAM_DATE_1 is null and DATE_1 is not null))
 AND CATEGORY = 'COST_MAP';
end;
--~^UTDELIM^~--


begin
update REVN_LOG set PARAM_DATE_1 = DATE_1,last_updated_by = last_updated_by, last_updated_date = last_updated_date
 WHERE ( (PARAM_DATE_1 <> DATE_1)
      OR (PARAM_DATE_1 is null and DATE_1 is not null))
 AND CATEGORY = 'SUMMARY_PC';
end;
--~^UTDELIM^~--


begin
update REVN_LOG set PARAM_TEXT_3 = TEXT_3,last_updated_by = last_updated_by, last_updated_date = last_updated_date
 WHERE ( (PARAM_TEXT_3 <> TEXT_3)
      OR (PARAM_TEXT_3 is null and TEXT_3 is not null))
 AND CATEGORY = 'SUMMARY_PC';
end;
--~^UTDELIM^~--


begin
update REVN_LOG set PARAM_TEXT_2 = TEXT_2,last_updated_by = last_updated_by, last_updated_date = last_updated_date
 WHERE ( (PARAM_TEXT_2 <> TEXT_2)
      OR (PARAM_TEXT_2 is null and TEXT_2 is not null))
 AND CATEGORY = 'SUMMARY_PC';
end;
--~^UTDELIM^~--


begin
update REVN_LOG_ITEM set PARAM_TEXT_4 = TEXT_4,last_updated_by = last_updated_by, last_updated_date = last_updated_date
 WHERE ( (PARAM_TEXT_4 <> TEXT_4)
      OR (PARAM_TEXT_4 is null and TEXT_4 is not null))
 AND CATEGORY = 'SUMMARY_PC';
end;
--~^UTDELIM^~--


begin
update REVN_LOG_ITEM set PARAM_DATE_1 = DATE_1,last_updated_by = last_updated_by, last_updated_date = last_updated_date
 WHERE ( (PARAM_DATE_1 <> DATE_1)
      OR (PARAM_DATE_1 is null and DATE_1 is not null))
 AND CATEGORY = 'SUMMARY_PC';
end;
--~^UTDELIM^~--

create or replace procedure temp_Migratebyrename(p_table_name varchar2, 
                                                p_from_column_name varchar2, 
                                                p_to_column_name varchar2, 
                                                p_data_type varchar2,
                                                p_data_length number)
is

  cursor c_columns_exists(p_table_name varchar2, p_column_name varchar2,p_data_type varchar2) is
  select 1 from cols c
  where c.table_name = p_table_name
  and   c.column_name = p_column_name
  and   c.data_type = p_data_type;

ln_newcolumn_exists NUMBER;
ln_oldColumn_exists NUMBER;
lv2_sql      varchar2(4000);

begin

  ln_newcolumn_exists := 0;
  ln_oldColumn_exists := 0;

  For curNew in c_columns_exists(p_table_name, p_to_column_name,p_data_type) LOOP
    ln_newcolumn_exists := 1;
  END LOOP;


  For curOld in c_columns_exists(p_table_name, p_from_column_name,p_data_type) LOOP
    ln_oldcolumn_exists := 1;
  END LOOP;

  IF ln_newcolumn_exists = 0 and ln_oldcolumn_exists = 1 THEN  -- This is what we expect if the script is run for the first time

     EXECUTE IMMEDIATE 'alter table '||p_table_name||' rename column '||p_from_column_name||' to '||p_to_column_name;

     if p_data_type = 'VARCHAR2' THEN
        EXECUTE IMMEDIATE 'alter table '||p_table_name||' add '||p_from_column_name||' '||p_data_type|| '('||p_data_length||')';
     else
        EXECUTE IMMEDIATE 'alter table '||p_table_name||' add '||p_from_column_name||' '||p_data_type;
     end if;

     -- Need to regenerate ec packages used in AUT trigger  
     EcDp_Generate.generate(p_table_name, EcDp_Generate.PACKAGES);


  ELSIF ln_newcolumn_exists = 1 and ln_oldcolumn_exists = 1 THEN  -- The new column already exists, so try to run an upgrade instead of the rename

     lv2_sql := 'update '||p_table_name||' set '||p_to_column_name||' = '||p_from_column_name||', last_updated_by = last_updated_by, last_updated_date = last_updated_date'
                ||' WHERE ( ('||p_to_column_name||' <> '||p_from_column_name||') OR ('||p_to_column_name||' is null and '||p_from_column_name||' is not null))';

     EXECUTE IMMEDIATE lv2_sql;

  ELSE  -- We have an unsupported state, either the from column does not exists, or the column already existed with a wrong data type

    Raise_Application_Error (-20000, 'Attempt to rename '||p_table_name||'.'||p_from_column_name||' to '||p_to_column_name||' failed because of missing source column or wrong data type.');
  END IF;


end;
--~^UTDELIM^~--

BEGIN
 
temp_Migratebyrename('CALC_REFERENCE','VALUE_1','AMOUNT','NUMBER',22);                                                                                                                                                                                                                                                                                                                                                                                                                                      
temp_Migratebyrename('CALC_REFERENCE','TEXT_1','CALC_SCOPE','VARCHAR2',240);                                                                                                                                                                                                                                                                                                                                                                                                                                
temp_Migratebyrename('COST_MAPPING_VERSION','TEXT_1','SRC_EXPENDITURE_TYPE','VARCHAR2',240);                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                
temp_Migratebyrename('COST_MAPPING_VERSION','TEXT_2','TRG_EXPENDITURE_TYPE','VARCHAR2',240);                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      
temp_Migratebyrename('REVN_LOG_ITEM','TEXT_1','PARAM_TEXT_1','VARCHAR2',2000);                                                                                                                                                                                                                                                                                                                                                                                                                              
temp_Migratebyrename('REVN_LOG_ITEM','TEXT_2','PARAM_TEXT_2','VARCHAR2',2000);                                                                                                                                                                                                                                                                                                                                                                                                                                     
temp_Migratebyrename('REVN_LOG_ITEM','TEXT_3','PARAM_TEXT_3','VARCHAR2',2000);                                                                                                                                                                                                                                                                                                                                                                                                                                  
temp_Migratebyrename('REPORT_REF_CONNECTION','TEXT_1','MATERIAL','VARCHAR2',240);                                                                                                                                                                                                                                                                                                            temp_Migratebyrename('REPORT_REF_CONNECTION','TEXT_2','DOCUMENT_TYPE','VARCHAR2',240); 
 
temp_Migratebyrename('REPORT_REF_CONNECTION','TEXT_3','TRANSACTION_TYPE','VARCHAR2',240); 
 
temp_Migratebyrename('REPORT_REF_CONNECTION','TEXT_4','PRODUCT','VARCHAR2',240);  

temp_Migratebyrename('IMP_SOURCE_XML_PATH','TEXT_1','CONDITION','VARCHAR2',2000);                                                                                                                                                                                                                                                                                                                                                                                                                           
temp_Migratebyrename('IMP_SOURCE_XML_PATH','TEXT_2','ALT_PATH','VARCHAR2',2000);                                                                                                                                                                                                                                                                                                                                                                                                                            
temp_Migratebyrename('COST_MAPPING_VERSION','TEXT_1','SRC_EXPENDITURE_TYPE','VARCHAR2',240);                                                                                                                                                                                                                                                                                                                                                                                                              
temp_Migratebyrename('COST_MAPPING_VERSION','TEXT_2','TRG_EXPENDITURE_TYPE','VARCHAR2',240);                                                                                                                                                                                                                                                                                                                                                                                                              

temp_Migratebyrename('CALC_REFERENCE_JN','VALUE_1','AMOUNT','NUMBER',22);                                                                                                                                                                                                                                                                                                                                                                                                                                   
temp_Migratebyrename('CALC_REFERENCE_JN','TEXT_1','CALC_SCOPE','VARCHAR2',240);                                                                                                                                                                                                                                                                                                                                                                                                                             
temp_Migratebyrename('COST_MAPPING_VERSION_JN','TEXT_1','SRC_EXPENDITURE_TYPE','VARCHAR2',240);                                                                                                                                                                                                                                                                                                                                                                                                                                                      
temp_Migratebyrename('COST_MAPPING_VERSION_JN','TEXT_2','TRG_EXPENDITURE_TYPE','VARCHAR2',240);                                                                                                                                                                                            
temp_Migratebyrename('REPORT_REF_CONNECTION_JN','TEXT_1','MATERIAL','VARCHAR2',240); 

temp_Migratebyrename('REPORT_REF_CONNECTION_JN','TEXT_2','DOCUMENT_TYPE','VARCHAR2',240);   
 
temp_Migratebyrename('REPORT_REF_CONNECTION_JN','TEXT_3','TRANSACTION_TYPE','VARCHAR2',240);  
 
temp_Migratebyrename('REPORT_REF_CONNECTION_JN','TEXT_4','PRODUCT','VARCHAR2',240);  
 
temp_Migratebyrename('IMP_SOURCE_XML_PATH_JN','TEXT_1','CONDITION','VARCHAR2',2000);                                                                                                                                                                                                                                                                                                                                                                                                                        
temp_Migratebyrename('IMP_SOURCE_XML_PATH_JN','TEXT_2','ALT_PATH','VARCHAR2',2000);                                                                                                                                                                                                                                                                                                                                                                                                                         
temp_Migratebyrename('COST_MAPPING_VERSION_JN','TEXT_1','SRC_EXPENDITURE_TYPE','VARCHAR2',240);                                                                                                                                                                                                                                                                                                                                                                                                           
temp_Migratebyrename('COST_MAPPING_VERSION_JN','TEXT_2','TRG_EXPENDITURE_TYPE','VARCHAR2',240);

END;
--~^UTDELIM^~--

BEGIN
update jbpm_ProcessInstanceLog set processType = 1;
update jbpm_RequestInfo set priority = 5;
END;
--~^UTDELIM^~--

BEGIN
update jbpm_AuditTaskImpl ati set lastModificationDate = (
    select max(logTime) from jbpm_TaskEvent where taskId=ati.taskId group by taskId
);
END;
--~^UTDELIM^~--


DECLARE
BEGIN
  INSERT INTO T_PREFERANSE (pref_id, pref_verdi, pref_beskr) 
    SELECT 'UNIT_CONTEXT', 'EC_UNIT_CONTEXT', 'Default EC unit context'
    FROM dual
    WHERE NOT EXISTS (SELECT 1 FROM t_preferanse WHERE pref_id = 'UNIT_CONTEXT' AND pref_verdi = 'EC_UNIT_CONTEXT');
    
  INSERT INTO T_PREFERANSE (pref_id, pref_verdi, pref_beskr) 
    SELECT 'CONV_CONTEXT', 'EC_CONV_CONTEXT', 'Default EC conversion context'
    FROM dual
    WHERE NOT EXISTS (SELECT 1 FROM t_preferanse WHERE pref_id = 'CONV_CONTEXT' AND pref_verdi = 'EC_CONV_CONTEXT');
END;
--~^UTDELIM^~--
