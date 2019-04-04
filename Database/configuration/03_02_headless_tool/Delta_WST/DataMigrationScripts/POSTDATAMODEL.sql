ALTER TABLE ALLOC_JOB_DEFINITION DISABLE ALL TRIGGERS
--~^UTDELIM^~--

-- ECPD21279_UPGRADE_SCRIPT...
BEGIN
	UPDATE ALLOC_JOB_DEFINITION SET CALC_CONTEXT_ID=ECDP_OBJECTS.GETOBJIDFROMCODE('CALC_CONTEXT', 'EC_PROD_DC') 
	WHERE CODE='DAILY_DEFERMENT_CALCULATIONS' AND VALID_FROM_DATE=TO_DATE('01.01.1900','dd.mm.yyyy') 
	AND CALC_CONTEXT_ID = ECDP_OBJECTS.GETOBJIDFROMCODE('CALC_CONTEXT', 'EC_PROD');
END;
--~^UTDELIM^~--

ALTER TABLE ALLOC_JOB_DEFINITION ENABLE ALL TRIGGERS
--~^UTDELIM^~--
ALTER TABLE EQPM_DAY_STATUS DISABLE ALL TRIGGERS
--~^UTDELIM^~--

-- ECPD26417_EQPM_DAY_STATUS_UPGRADE...
-- The script will move the existing values in planned_ext_dt_hrs and unplanned_ext_dt_hrs columns to the correct columns 
-- which are planned_int_dt_hrs and unplanned_int_dt_hrs respectively.

BEGIN

	UPDATE EQPM_DAY_STATUS 
	SET PLANNED_INT_DT_HRS   = PLANNED_EXT_DT_HRS,
		UNPLANNED_INT_DT_HRS = UNPLANNED_EXT_DT_HRS,
		PLANNED_EXT_DT_HRS=NULL,
		UNPLANNED_EXT_DT_HRS=NULL
	WHERE PLANNED_EXT_DT_HRS IS NOT NULL
	AND UNPLANNED_INT_DT_HRS IS NOT NULL;
END;
--~^UTDELIM^~--

ALTER TABLE EQPM_DAY_STATUS ENABLE ALL TRIGGERS
--~^UTDELIM^~--
ALTER TABLE EQPM_DAY_STATUS DISABLE ALL TRIGGERS
--~^UTDELIM^~--	

BEGIN
	-- The script will move the existing values in planned_ext_dt_hrs and unplanned_ext_dt_hrs columns to the correct columns 
	-- which are planned_int_dt_hrs and unplanned_int_dt_hrs respectively.

	UPDATE EQPM_DAY_STATUS 
	SET PLANNED_INT_DT_HRS = PLANNED_EXT_DT_HRS, 
		UNPLANNED_INT_DT_HRS = UNPLANNED_EXT_DT_HRS, 
		PLANNED_EXT_DT_HRS=NULL, 
		UNPLANNED_EXT_DT_HRS=NULL 
	WHERE PLANNED_EXT_DT_HRS IS NOT NULL OR UNPLANNED_EXT_DT_HRS IS NOT NULL;
END;
--~^UTDELIM^~--	

ALTER TABLE EQPM_DAY_STATUS ENABLE ALL TRIGGERS
--~^UTDELIM^~--	

ALTER TABLE EQPM_VERSION DISABLE ALL TRIGGERS
--~^UTDELIM^~--	

BEGIN
	DELETE FROM EQPM_VERSION WHERE OBJECT_ID IN (SELECT DISTINCT C.OBJECT_ID FROM EQUIPMENT C WHERE C.CLASS_NAME = 'TEST_DEVICE');
END;
--~^UTDELIM^~--	

ALTER TABLE EQPM_VERSION ENABLE ALL TRIGGERS
--~^UTDELIM^~--	

ALTER TABLE EQUIPMENT DISABLE ALL TRIGGERS
--~^UTDELIM^~--	

BEGIN
	DELETE FROM EQUIPMENT WHERE CLASS_NAME = 'TEST_DEVICE';   
END;
--~^UTDELIM^~--	

ALTER TABLE EQUIPMENT ENABLE ALL TRIGGERS
--~^UTDELIM^~--	

BEGIN
update assign_id
   set max_id =
       (SELECT GREATEST(max1, max2)
           FROM (SELECT max_id max1
                   FROM assign_id
                  where tablename = 'NOMLOC_PERIOD_EVENT'),
                (SELECT max_id max2
                   FROM assign_id
                  where tablename = 'FCST_NOMLOC_PERIOD_EVENT')) where tablename ='NOMLOC_PERIOD_EVENT';

update assign_id
   set max_id =
       (SELECT GREATEST(max1, max2)
           FROM (SELECT max_id max1
                   FROM assign_id
                  where tablename = 'NOMPNT_PERIOD_EVENT'),
                (SELECT max_id max2
                   FROM assign_id
                  where tablename = 'FCST_NOMPNT_PERIOD_EVENT')) where tablename ='NOMPNT_PERIOD_EVENT';
				  
update assign_id
   set max_id =
       (SELECT GREATEST(max1, max2)
           FROM (SELECT max_id max1
                   FROM assign_id
                  where tablename = 'NOMPNT_SUB_DAY_EVENT'),
                (SELECT max_id max2
                   FROM assign_id
                  where tablename = 'FCST_NOMPNT_SUB_DAY_EVENT')) where tablename ='NOMPNT_SUB_DAY_EVENT';

END;
--~^UTDELIM^~--
--START OF ECPD_30903_ECCode_Upgrade_Script
-- PURPOSE OF SCRIPT : SCRIPT IS AIMED TO
--                     1 : MOVE TRUCK COMPANY EC CODE DATA FROM PROSTY_CODE TO COMPANY CLASS
--                     2 : UPDATE CORRESPONDING COMPANY OBJECT_ID TO RESPECTIVE TABLES OF FOLLOWING SCREENS
--                         TRUCK TICKET - SINGLE TRANSFER - OBJECTS FORM
--                         TRUCK TICKET - SINGLE TRANSFER - OBJECTS
--                         TRUCK TICKET SINGLE TRANSFER
--                         TRUCK TICKET - LOAD TO WELLS
--                         TRUCK TICKET - LOAD FROM WELLS
--                         EVENT TANK STATUS - DIP AND EXPORT (DISPOSITIONS TAB)
-- CREATED  : 15-JAN-2015  (GAURAV CHAUDHARY)
--
-- MODIFICATION HISTORY:
-- DATE         WHOM      CHANGE DESCRIPTION:
-- ----         -----     -----------------------------------
-- 15-JAN-2015  CHAUDGAU  INITIAL VERSION
-- 15-MAR-2015  CHAUDGAU  MODIFIED THE INSERT PROCESS TO INSERT / UPDATE DATA IN TABLES RATHER THEN CLASS VIEW
-----------------------------------------------------------------

DECLARE
    HASENTRY1 NUMBER;
	HASENTRY2 NUMBER;
	HASENTRY3 NUMBER;
	HASENTRY4 NUMBER;
    CURSOR C_PROSTY_CODES
    IS
    SELECT *
      FROM PROSTY_CODES
     WHERE CODE_TYPE='TRUCK_COMPANY';
     
    LV2_OBJECT_ID COMPANY.OBJECT_ID%TYPE;
	

BEGIN

    FOR I IN C_PROSTY_CODES
    LOOP

	  BEGIN

		INSERT INTO COMPANY
        (
         OBJECT_CODE
         ,CLASS_NAME
         ,START_DATE
         ,DESCRIPTION
         )
        VALUES
        (
         I.CODE
        ,'COMPANY'
        ,TRUNC(I.CREATED_DATE)
        ,I.DESCRIPTION
        ) RETURNING OBJECT_ID INTO LV2_OBJECT_ID;

		INSERT INTO COMPANY_VERSION
        (
          OBJECT_ID
         ,DAYTIME
         ,NAME
         ,IS_TRUCK_COMPANY)
        VALUES
        (
          LV2_OBJECT_ID
         ,TRUNC(I.CREATED_DATE)
         ,I.CODE_TEXT
         ,'Y'
        );

	  EXCEPTION
	    WHEN DUP_VAL_ON_INDEX THEN
		 LV2_OBJECT_ID := ECDP_OBJECTS.GETOBJIDFROMCODE('COMPANY',I.CODE);
		 
		SELECT COUNT(*) INTO HASENTRY1 FROM USER_TRIGGERS 
			WHERE TRIGGER_NAME = 'IU_COMPANY_VERSION'; 
			IF HASENTRY1 > 0 THEN 
			EXECUTE IMMEDIATE 'ALTER TRIGGER IU_COMPANY_VERSION DISABLE';
			END IF;
		
		  UPDATE COMPANY_VERSION
		  SET IS_TRUCK_COMPANY='Y'
		  WHERE OBJECT_ID=LV2_OBJECT_ID;
		  
		SELECT COUNT(*) INTO HASENTRY1 FROM USER_TRIGGERS 
			WHERE TRIGGER_NAME = 'IU_COMPANY_VERSION'; 
			IF HASENTRY1 > 0 THEN 
			EXECUTE IMMEDIATE 'ALTER TRIGGER IU_COMPANY_VERSION DISABLE';
			END IF;  
	  END;

       -- TRUCK TICKET SINGLE TRANSFER SCREEN
	   -- TRUCK TICKET - LOAD TO WELLS
       -- TRUCK TICKET - LOAD FROM WELLS	   
	SELECT COUNT(*) INTO HASENTRY2 FROM USER_TRIGGERS 
		WHERE TRIGGER_NAME = 'IU_STRM_TRANSPORT_EVENT'; 
		IF HASENTRY2 > 0 THEN 
		EXECUTE IMMEDIATE 'ALTER TRIGGER IU_STRM_TRANSPORT_EVENT DISABLE';
		END IF; 
		
      UPDATE STRM_TRANSPORT_EVENT
      SET TRANSPORT_COMPANY=LV2_OBJECT_ID
      WHERE TRANSPORT_COMPANY=I.CODE;
	  
	SELECT COUNT(*) INTO HASENTRY2 FROM USER_TRIGGERS 
		WHERE TRIGGER_NAME = 'IU_STRM_TRANSPORT_EVENT'; 
		IF HASENTRY2 > 0 THEN 
		EXECUTE IMMEDIATE 'ALTER TRIGGER IU_STRM_TRANSPORT_EVENT ENABLE';
		END IF;   

      -- TRUCK TICKET - SINGLE TRANSFER - OBJECTS
      -- TRUCK TICKET - SINGLE TRANSFER - OBJECTS FORM
	  -- EVENT TANK STATUS - DIP AND EXPORT	
	SELECT COUNT(*) INTO HASENTRY3 FROM USER_TRIGGERS 
		WHERE TRIGGER_NAME = 'IU_OBJECT_TRANSPORT_EVENT'; 
		IF HASENTRY3 > 0 THEN 
		EXECUTE IMMEDIATE 'ALTER TRIGGER IU_OBJECT_TRANSPORT_EVENT DISABLE';
		END IF; 
		
      UPDATE OBJECT_TRANSPORT_EVENT
      SET TRANSPORT_COMPANY=LV2_OBJECT_ID
      WHERE TRANSPORT_COMPANY=I.CODE;
	  
	SELECT COUNT(*) INTO HASENTRY3 FROM USER_TRIGGERS 
		WHERE TRIGGER_NAME = 'IU_OBJECT_TRANSPORT_EVENT'; 
		IF HASENTRY3 > 0 THEN 
		EXECUTE IMMEDIATE 'ALTER TRIGGER IU_OBJECT_TRANSPORT_EVENT ENABLE';
		END IF;   
	 
	SELECT COUNT(*) INTO HASENTRY4 FROM USER_TRIGGERS 
		WHERE TRIGGER_NAME = 'IU_WELL_TRANSPORT_EVENT'; 
		IF HASENTRY4 > 0 THEN 
		EXECUTE IMMEDIATE 'ALTER TRIGGER IU_WELL_TRANSPORT_EVENT DISABLE';
		END IF; 
		
      UPDATE WELL_TRANSPORT_EVENT
      SET TRANSPORT_COMPANY = LV2_OBJECT_ID
      WHERE TRANSPORT_COMPANY = I.CODE;
	  
	SELECT COUNT(*) INTO HASENTRY4 FROM USER_TRIGGERS 
		WHERE TRIGGER_NAME = 'IU_WELL_TRANSPORT_EVENT'; 
		IF HASENTRY4 > 0 THEN 
		EXECUTE IMMEDIATE 'ALTER TRIGGER IU_WELL_TRANSPORT_EVENT ENABLE';
		END IF; 

   END LOOP;
    COMMIT;
   EXCEPTION
   WHEN OTHERS 
     THEN
       IF HASENTRY1 > 0 THEN 
           EXECUTE IMMEDIATE 'ALTER TRIGGER IU_COMPANY_VERSION ENABLE';
       END IF;
	   
	   IF HASENTRY2 > 0 THEN 
           EXECUTE IMMEDIATE 'ALTER TRIGGER IU_STRM_TRANSPORT_EVENT ENABLE';
       END IF;
	   
	   IF HASENTRY3 > 0 THEN 
           EXECUTE IMMEDIATE 'ALTER TRIGGER IU_OBJECT_TRANSPORT_EVENT ENABLE';
       END IF;
	   
	   IF HASENTRY4 > 0 THEN 
           EXECUTE IMMEDIATE 'ALTER TRIGGER IU_WELL_TRANSPORT_EVENT ENABLE';
       END IF;
        
        raise_application_error(-20000,
                            'ERROR: Some Other fatal error occured :- '||SQLERRM);

 
END;
--END OF ECPD_30903_ECCode_Upgrade_Script
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
--START OF UPGRADE_SCRIPT_FOR_ECPD_31576
-- This Updates Alloc Flag = N for all existing records.
DECLARE 
HASENTRY NUMBER;
BEGIN
	SELECT COUNT(*) INTO HASENTRY FROM USER_TRIGGERS 
		WHERE TRIGGER_NAME = 'IU_EXTERNAL_LOCATION'; 
		IF HASENTRY > 0 THEN 
		EXECUTE IMMEDIATE 'ALTER TRIGGER IU_EXTERNAL_LOCATION DISABLE';
		END IF;
		
	UPDATE EXTERNAL_LOCATION SET ALLOC_FLAG='N';
	
	SELECT COUNT(*) INTO HASENTRY FROM USER_TRIGGERS 
		WHERE TRIGGER_NAME = 'IU_EXTERNAL_LOCATION'; 
		IF HASENTRY > 0 THEN 
		EXECUTE IMMEDIATE 'ALTER TRIGGER IU_EXTERNAL_LOCATION ENABLE';
		END IF;
	EXCEPTION
   WHEN OTHERS 
     THEN
       IF HASENTRY > 0 THEN 
           EXECUTE IMMEDIATE 'ALTER TRIGGER IU_EXTERNAL_LOCATION ENABLE';
       END IF;
        
        raise_application_error(-20000,
                            'ERROR: Some Other fatal error occured :- '||SQLERRM);
END;
--END OF UPGRADE_SCRIPT_FOR_ECPD_31576
--~^UTDELIM^~--

BEGIN

	update ctrl_tv_presentation set COMPONENT_EXT_NAME = '/com.ec.bpm.ext.ec.web/process_action' where COMPONENT_EXT_NAME ='/com.ec.bpm.ext.ec.web/jbpm_process_action';
	
END;
--~^UTDELIM^~--	

BEGIN

		
	update T_BASIS_OBJECT set OBJECT_NAME = '/com.ec.bpm.ext.ec.web/process_action' where OBJECT_NAME = '/com.ec.bpm.ext.ec.web/jbpm_process_action';
	
END;
--~^UTDELIM^~--		






	COMMENT ON TABLE FORECAST_GROUP IS 'Persists any forecast group case.'
--~^UTDELIM^~--

	COMMENT ON TABLE FORECAST_GROUP_VERSION IS 'Persists the attributes for the forcast group case.'
--~^UTDELIM^~--

	COMMENT ON TABLE FCST_WELL_EVENT IS 'This table contains the registered forecast deferment event'
--~^UTDELIM^~--

	COMMENT ON COLUMN FCST_WELL_EVENT.OBJECT_ID IS 'Reference to the object associated with the event'
--~^UTDELIM^~--

	COMMENT ON COLUMN FCST_WELL_EVENT.OBJECT_TYPE IS 'The class name of the assigned object'
--~^UTDELIM^~--

	COMMENT ON COLUMN FCST_WELL_EVENT.EVENT_NO IS 'Primary key for the table'
--~^UTDELIM^~--

	COMMENT ON COLUMN FCST_WELL_EVENT.PARENT_EVENT_NO IS 'The parent event_no for deferment type : Group_Child'
--~^UTDELIM^~--

	COMMENT ON COLUMN FCST_WELL_EVENT.EVENT_TYPE IS 'Constraint or Down'
--~^UTDELIM^~--

	COMMENT ON COLUMN FCST_WELL_EVENT.DEFERMENT_TYPE IS 'Group, Single or Group_Child'
--~^UTDELIM^~--

	COMMENT ON COLUMN FCST_WELL_EVENT.SCHEDULED IS 'Define whether the event is scheduled'
--~^UTDELIM^~--

	COMMENT ON TABLE FCST_WELL_EVENT_ALLOC IS 'Allocated daily loss for wells affected by a deferment events for forecast'
--~^UTDELIM^~--

	COMMENT ON COLUMN FCST_WELL_EVENT_ALLOC.OBJECT_ID IS 'The WELL'
--~^UTDELIM^~--

	COMMENT ON COLUMN FCST_WELL_EVENT_ALLOC.DAYTIME IS 'The production day'
--~^UTDELIM^~--

	COMMENT ON COLUMN FCST_WELL_EVENT_ALLOC.EVENT_NO IS 'The deferment event no'
--~^UTDELIM^~--

	COMMENT ON TABLE FCST_OBJ_CONSTRAINTS IS 'Holds records in Forecast Object Constraints'
--~^UTDELIM^~--

	COMMENT ON TABLE OBJECT_DESIGN_CAPACITY IS 'Holds records of design capacities for all production phases.'
--~^UTDELIM^~--

	COMMENT ON TABLE FCST_CONSTRAINTS IS 'Holds records in Forecast Constraints'
--~^UTDELIM^~--

	COMMENT ON TABLE FCST_JOB_LOG IS 'Contains log information on Forecast PLSQL Calculations that have been performed.'
--~^UTDELIM^~--

	COMMENT ON TABLE FCST_COMPENSATION_EVENTS is 'Holds records of Compensation Events for different phases.'
--~^UTDELIM^~--

	COMMENT ON TABLE FCST_SUMMARY_DAY IS 'Holds the daily forecasted data for Forecast Summary.'
--~^UTDELIM^~--

	COMMENT ON COLUMN PFLW_SUB_DAY_STATUS.AVG_DP_VENTURI IS 'Average pressure drop over venturi.'
--~^UTDELIM^~--

	COMMENT ON COLUMN PFLW_RESULT.DP_VENTURI IS 'Pressure drop over venturi.'
--~^UTDELIM^~--

	COMMENT ON COLUMN PFLW_SAMPLE.DP_VENTURI IS 'Pressure drop over venturi.'
--~^UTDELIM^~--

	COMMENT ON COLUMN PFLW_DAY_STATUS.AVG_DP_VENTURI IS 'Average pressure drop over venturi.'
--~^UTDELIM^~--

	COMMENT ON COLUMN PSEP_DAY_STATUS.AVG_SEP_PRESS_2 IS 'Average separator pressure 2'
--~^UTDELIM^~--

	COMMENT ON COLUMN PSEP_DAY_STATUS.AVG_SEP_TEMP_2 IS 'Average separator temperature 2'
--~^UTDELIM^~--

	COMMENT ON COLUMN PSEP_SUB_DAY_STATUS.AVG_SEP_PRESS_2 IS 'Average separator pressure 2'
--~^UTDELIM^~--

	COMMENT ON COLUMN PSEP_SUB_DAY_STATUS.AVG_SEP_TEMP_2 IS 'Average separator temperature 2'
--~^UTDELIM^~--

	COMMENT ON COLUMN PSEP_SUB_DAY_STATUS.NET_GAS_DENSITY_FLC IS 'Net gas density, flowing conditions'
--~^UTDELIM^~--

	COMMENT ON COLUMN PERF_INTERVAL_VERSION.KH_PRODUCT IS 'kH Product (rock permeability * length of perforation)'
--~^UTDELIM^~--

	COMMENT ON COLUMN PWEL_RESULT.METER1_FACTOR_GAS IS 'Meter 1 Factor for Gas'
--~^UTDELIM^~--

	COMMENT ON COLUMN PWEL_RESULT.METER1_FACTOR_HCLIQ IS 'Meter 1 Factor for Liquid HC'
--~^UTDELIM^~--

	COMMENT ON COLUMN PWEL_RESULT.METER1_FACTOR_WAT IS 'Meter 1 Factor for Water'
--~^UTDELIM^~--

	COMMENT ON COLUMN PWEL_RESULT.METER2_FACTOR_GAS IS 'Meter 2 Factor for Gas'
--~^UTDELIM^~--

	COMMENT ON COLUMN PWEL_RESULT.METER2_FACTOR_HCLIQ IS 'Meter 2 Factor for Liquid HC'
--~^UTDELIM^~--

	COMMENT ON COLUMN PWEL_RESULT.METER2_FACTOR_WAT IS 'Meter 2 Factor for Water'
--~^UTDELIM^~--

	COMMENT ON COLUMN PWEL_RESULT.MPM2_COND_RATE IS 'MPM2 Condensate rate'
--~^UTDELIM^~--

	COMMENT ON COLUMN PWEL_RESULT.MPM2_GAS_RATE IS 'MPM2 Gas rate'
--~^UTDELIM^~--

	COMMENT ON COLUMN PWEL_RESULT.MPM2_OIL_RATE IS 'MPM2 Oil rate'
--~^UTDELIM^~--

	COMMENT ON COLUMN PWEL_RESULT.MPM2_WATER_RATE IS 'MPM2 Water rate'
--~^UTDELIM^~--

	COMMENT ON COLUMN PWEL_RESULT.RECALC_RATIOS IS 'Recalculate well result'
--~^UTDELIM^~--

	COMMENT ON COLUMN PWEL_DAY_STATUS.AVG_MPM2_COND_RATE IS 'MPM2 Condensate rate'
--~^UTDELIM^~--

	COMMENT ON COLUMN PWEL_DAY_STATUS.AVG_MPM2_GAS_RATE IS 'MPM2 Gas rate'
--~^UTDELIM^~--

	COMMENT ON COLUMN PWEL_DAY_STATUS.AVG_MPM2_OIL_RATE IS 'MPM2 Oil rate'

--~^UTDELIM^~--

	COMMENT ON COLUMN PWEL_DAY_STATUS.AVG_MPM2_WATER_RATE IS 'MPM2 Water rate'
--~^UTDELIM^~--

	COMMENT ON COLUMN PWEL_RESULT.METER1_FACTOR_HC IS 'Meter1 Factor for HC'
--~^UTDELIM^~--

	COMMENT ON TABLE STRM_DAY_PC_PROD_ALLOC IS 'Allocated quantities per stream, day, profit centre and product.'
--~^UTDELIM^~--

	COMMENT ON COLUMN STRM_VERSION.TOOLTIP IS 'Tooltip presentation'
--~^UTDELIM^~--

	COMMENT ON TABLE FCST_WELL_POTENTIAL IS 'Holds records in Forecast Well Potential'
--~^UTDELIM^~--

	COMMENT ON TABLE FCST_CONSUMPTION_LOSS IS 'Table is used to enter and/or verify injection, consumption and losses profiles.'
--~^UTDELIM^~--

	COMMENT ON TABLE FCST_IWEL_POTENTIAL IS 'Holds records in forecast injection well potential.'
--~^UTDELIM^~--

	COMMENT ON TABLE FCST_COMPARISON IS 'Holds records in Forecast Comparison Objects'
--~^UTDELIM^~--

	COMMENT ON TABLE FCST_WELL_SUMMARY_DAY IS 'Holds the daily forecasted data for Well Forecast Summary.'
--~^UTDELIM^~--

	COMMENT ON TABLE FCST_SCENARIO_ANALYSIS IS 'Holds the forecasted data for Forecast Scenario Analysis.'
--~^UTDELIM^~--

	COMMENT ON TABLE FCST_ANALYSIS_COMMENT IS 'Holds the comment data for Forecast Scenario Analysis.'
--~^UTDELIM^~--

	COMMENT ON TABLE FCST_QUOTA_NOM IS 'Holds records in Forecast Quota Nomination'
--~^UTDELIM^~--
DECLARE
  HASENTRY NUMBER;
BEGIN	
SELECT COUNT(*) INTO HASENTRY FROM USER_TRIGGERS 
		WHERE TRIGGER_NAME = 'IU_WELL_VERSION'; 
		IF HASENTRY > 0 THEN 
		EXECUTE IMMEDIATE 'ALTER TRIGGER IU_WELL_VERSION DISABLE';
		END IF;
		
	UPDATE WELL_VERSION SET GAS_LIFT_SUB_DAY_METHOD='CURVE_GAS_LIFT' WHERE GAS_LIFT_SUB_DAY_METHOD='CURVE';
	
	SELECT COUNT(*) INTO HASENTRY FROM USER_TRIGGERS 
		WHERE TRIGGER_NAME = 'IU_WELL_VERSION'; 
		IF HASENTRY > 0 THEN 
		EXECUTE IMMEDIATE 'ALTER TRIGGER IU_WELL_VERSION ENABLE';
		END IF;
EXCEPTION
WHEN OTHERS THEN 	
	IF HASENTRY > 0 THEN 
        EXECUTE IMMEDIATE 'ALTER TRIGGER IU_WELL_VERSION ENABLE';
    END IF;    
        raise_application_error(-20000,'ERROR: Some Other fatal error occured :- '||SQLERRM);
END;


--~^UTDELIM^~--

-- TO MAKE FORECAST_ID AS NULLABLE COLUMN
ALTER TABLE FORECAST_DOCUMENTS ADD FORECAST_ID_TEMP VARCHAR2(32) NULL

--~^UTDELIM^~--
DECLARE
  HASENTRY NUMBER;
BEGIN
SELECT COUNT(*) INTO HASENTRY FROM USER_TRIGGERS 
		WHERE TRIGGER_NAME = 'IU_FORECAST_DOCUMENTS'; 
		IF HASENTRY > 0 THEN 
		EXECUTE IMMEDIATE 'ALTER TRIGGER IU_FORECAST_DOCUMENTS DISABLE';
		END IF;
		
	UPDATE FORECAST_DOCUMENTS SET FORECAST_ID_TEMP = FORECAST_ID;
	
	SELECT COUNT(*) INTO HASENTRY FROM USER_TRIGGERS 
		WHERE TRIGGER_NAME = 'IU_FORECAST_DOCUMENTS'; 
		IF HASENTRY > 0 THEN 
		EXECUTE IMMEDIATE 'ALTER TRIGGER IU_FORECAST_DOCUMENTS ENABLE';
		END IF;
EXCEPTION
WHEN OTHERS THEN 	
	IF HASENTRY > 0 THEN 
        EXECUTE IMMEDIATE 'ALTER TRIGGER IU_FORECAST_DOCUMENTS ENABLE';
    END IF;    
        raise_application_error(-20000,'ERROR: Some Other fatal error occured :- '||SQLERRM);
END;

--~^UTDELIM^~--

ALTER TABLE FORECAST_DOCUMENTS DROP COLUMN FORECAST_ID

--~^UTDELIM^~--
ALTER TABLE FORECAST_DOCUMENTS RENAME COLUMN FORECAST_ID_TEMP TO FORECAST_ID

--~^UTDELIM^~--

ALTER TABLE FORECAST_DOCUMENTS_JN ADD FORECAST_ID_TEMP VARCHAR2(32) NULL

--~^UTDELIM^~--
DECLARE
  HASENTRY NUMBER;
BEGIN
SELECT COUNT(*) INTO HASENTRY FROM USER_TRIGGERS 
		WHERE TRIGGER_NAME = 'IU_FORECAST_DOCUMENTS_JN'; 
		IF HASENTRY > 0 THEN 
		EXECUTE IMMEDIATE 'ALTER TRIGGER IU_FORECAST_DOCUMENTS_JN DISABLE';
		END IF;
		
	UPDATE FORECAST_DOCUMENTS_JN SET FORECAST_ID_TEMP = FORECAST_ID;
	
	SELECT COUNT(*) INTO HASENTRY FROM USER_TRIGGERS 
		WHERE TRIGGER_NAME = 'IU_FORECAST_DOCUMENTS_JN'; 
		IF HASENTRY > 0 THEN 
		EXECUTE IMMEDIATE 'ALTER TRIGGER IU_FORECAST_DOCUMENTS_JN ENABLE';
		END IF;
EXCEPTION
WHEN OTHERS THEN 	
	IF HASENTRY > 0 THEN 
        EXECUTE IMMEDIATE 'ALTER TRIGGER IU_FORECAST_DOCUMENTS_JN ENABLE';
    END IF;    
        raise_application_error(-20000,'ERROR: Some Other fatal error occured :- '||SQLERRM);
END;
--~^UTDELIM^~--


ALTER TABLE FORECAST_DOCUMENTS_JN DROP COLUMN FORECAST_ID

--~^UTDELIM^~--
ALTER TABLE FORECAST_DOCUMENTS_JN RENAME COLUMN FORECAST_ID_TEMP TO FORECAST_ID

--~^UTDELIM^~--
DECLARE
  HASENTRY1 NUMBER;
  HASENTRY2 NUMBER;
BEGIN
        SELECT COUNT(*) INTO HASENTRY1 FROM USER_TRIGGERS 
		WHERE TRIGGER_NAME = 'IU_OBJECT_GROUP_CONN'; 
		IF HASENTRY1 > 0 THEN 
		EXECUTE IMMEDIATE 'ALTER TRIGGER IU_OBJECT_GROUP_CONN DISABLE';
		END IF;
		
			UPDATE OBJECT_GROUP_CONN 
			SET    OBJECT_CLASS = 'EQPM'
			WHERE  OBJECT_CLASS IN ('GENERATOR','EQUIPMENT_OTHER','HEATER','PROCESSING_UNIT','TEST_DEVICE','CO_GEN_UNIT','CHILLER','CO2_REMOVAL_UNIT','DEHYDRATOR','REBOILER','PUMP','CTRL_SAFETY_SYSTEM','INCINERATORS','SO2_SCRUBBER','ENGINE','FUEL_SYSTEMS','STEAM_GENERATOR','COMPRESSOR','EMULSIFIER','GAS_PROC_EQPM','WATER_TREATMENT_UNIT','CONDENSATE_SURGE_DRUM','MERCURY_REMOVAL_UNIT','REVERSE_OSMOSIS_UNIT','SPLITIGATOR','UTILITY_EQPM','POWER_DISTRIBUTION_EQPM','STABILIZER','VAPOUR_RECOVERY_UNIT');

		IF HASENTRY1 > 0 THEN 
		EXECUTE IMMEDIATE 'ALTER TRIGGER IU_OBJECT_GROUP_CONN ENABLE';
		END IF;
		
		SELECT COUNT(*) INTO HASENTRY2 FROM USER_TRIGGERS 
		WHERE TRIGGER_NAME = 'IU_OBJECT_GROUP'; 
		IF HASENTRY2 > 0 THEN 
		EXECUTE IMMEDIATE 'ALTER TRIGGER IU_OBJECT_GROUP DISABLE';
		END IF;
		
			UPDATE OBJECT_GROUP 
			SET    OBJECT_CLASS = 'EQPM'
			WHERE  OBJECT_CLASS IN ('GENERATOR','EQUIPMENT_OTHER','HEATER','PROCESSING_UNIT','TEST_DEVICE','CO_GEN_UNIT','CHILLER','CO2_REMOVAL_UNIT','DEHYDRATOR','REBOILER','PUMP','CTRL_SAFETY_SYSTEM','INCINERATORS','SO2_SCRUBBER','ENGINE','FUEL_SYSTEMS','STEAM_GENERATOR','COMPRESSOR','EMULSIFIER','GAS_PROC_EQPM','WATER_TREATMENT_UNIT','CONDENSATE_SURGE_DRUM','MERCURY_REMOVAL_UNIT','REVERSE_OSMOSIS_UNIT','SPLITIGATOR','UTILITY_EQPM','POWER_DISTRIBUTION_EQPM','STABILIZER','VAPOUR_RECOVERY_UNIT');

		IF HASENTRY2 > 0 THEN 
		EXECUTE IMMEDIATE 'ALTER TRIGGER IU_OBJECT_GROUP ENABLE';
		END IF;
		
		EXCEPTION		  
			 WHEN OTHERS THEN 
	    IF HASENTRY1 > 0 THEN 
			EXECUTE IMMEDIATE 'ALTER TRIGGER IU_OBJECT_GROUP_CONN ENABLE';
		END IF;
		IF HASENTRY2 > 0 THEN 
			EXECUTE IMMEDIATE 'ALTER TRIGGER IU_OBJECT_GROUP ENABLE';
		END IF;
END;
--~^UTDELIM^~--

BEGIN	   
--FRom 2016062001PROD\02_ECPD_35846_ALTER_TABLES_CON.sql
-- Delete the records from FORECAST_VERSION table.	
	DELETE FROM FORECAST_VERSION  
	WHERE EXISTS ( SELECT 1 
				   FROM FORECAST 
				   WHERE FORECAST.OBJECT_ID = FORECAST_VERSION.OBJECT_ID 
				   AND CLASS_NAME='FORECAST_PROD' )   
	AND   EXISTS (  SELECT 1
						FROM FORECAST_GROUP_VERSION
						WHERE OBJECT_ID = FORECAST_VERSION.OBJECT_ID );
END;
--~^UTDELIM^~--	
			 
BEGIN
-- Delete the records from FORECAST table.			   
	DELETE FROM FORECAST F 
	WHERE F.CLASS_NAME = 'FORECAST_PROD'  AND OBJECT_CODE  NOT LIKE 'ECSCENARIO' 
	AND EXISTS ( SELECT 1
					FROM FORECAST_GROUP
				    WHERE OBJECT_ID = F.OBJECT_ID );
END;			 
--~^UTDELIM^~--	
	COMMENT ON TABLE LOADING_ARM IS 'This table will hold LOADING ARM objects'
--~^UTDELIM^~--

	COMMENT ON TABLE LOADING_ARM_VERSION IS 'This table contains versioned attributes for Loading Arm objects.'
--~^UTDELIM^~--

	COMMENT ON TABLE PILOT IS 'This table will hold PILOT objects'
--~^UTDELIM^~--

	COMMENT ON TABLE PILOT_VERSION IS 'This table contains versioned attributes for Pilot objects.'
--~^UTDELIM^~--

	COMMENT ON TABLE PILOT_BOAT IS 'This table will hold PILOT BOAT objects'
--~^UTDELIM^~--

	COMMENT ON TABLE PILOT_BOAT_VERSION IS 'This table contains versioned attributes for Pilot boat objects.'
--~^UTDELIM^~--

	COMMENT ON TABLE TUG_BOAT IS 'This table will hold TUG_BOAT objects'
--~^UTDELIM^~--

	COMMENT ON TABLE TUG_BOAT_VERSION IS 'This table contains versioned attributes for TUG_BOAT objects.'
--~^UTDELIM^~--

	COMMENT ON TABLE MARINE_NOTICES IS 'This table will hold List of MARINE NOTICES'
--~^UTDELIM^~--

	COMMENT ON TABLE PORT_RES_RESTRICTION IS 'Port resources restriction'
--~^UTDELIM^~--

	COMMENT ON TABLE OPPORTUNITY  IS 'This table hold communication related to opportunities and can be used to track any negotiations related to the individual opportunities'
--~^UTDELIM^~--

	COMMENT ON TABLE STORAGE_PORT_RESOURCE IS 'This table holds connections between a storage and port resources needed for port resource assignment when doing ADP Planning'
--~^UTDELIM^~--

	COMMENT ON TABLE CHANNEL IS 'This table will hold Channel objects'
--~^UTDELIM^~--

	COMMENT ON TABLE CHANNEL_VERSION IS 'This table contains versioned attributes for Channel objects.'
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
DECLARE
  HASENTRY NUMBER;
     sqlQuery clob:='UPDATE CTRL_PROPERTY SET VALUE_STRING = ''DOWN_CONSTRAINT'' WHERE KEY = ''DEFERMENT_OVERLAP'' AND VALUE_STRING = ''Y''';
BEGIN

    SELECT COUNT(*) INTO HASENTRY FROM USER_TRIGGERS 
		WHERE TRIGGER_NAME = 'IU_CTRL_PROPERTY'; 
		IF HASENTRY > 0 THEN 
		EXECUTE IMMEDIATE 'ALTER TRIGGER IU_CTRL_PROPERTY DISABLE';
		END IF;
		
     EXECUTE IMMEDIATE sqlQuery;
	 
	 SELECT COUNT(*) INTO HASENTRY FROM USER_TRIGGERS 
		WHERE TRIGGER_NAME = 'IU_CTRL_PROPERTY'; 
		IF HASENTRY > 0 THEN 
		EXECUTE IMMEDIATE 'ALTER TRIGGER IU_CTRL_PROPERTY ENABLE';
		END IF;
     dbms_output.put_line('SUCCESS: ' || sqlQuery);
     dbms_output.put_line('No of Rows Updated:' || sql%rowcount);
     EXCEPTION
        WHEN OTHERS THEN
		IF HASENTRY > 0 THEN 
		EXECUTE IMMEDIATE 'ALTER TRIGGER IU_CTRL_PROPERTY ENABLE';
		END IF;
         --UPDATE_MILESTONE_WITH_ERROR('post_data_model');
         raise_application_error(-20000, 'ERROR: Some Other fatal error occured' || SQLERRM);
 END;
--~^UTDELIM^~--

DECLARE
     HASENTRY NUMBER;
     sqlQuery clob:='UPDATE WELL_DEFERMENT SET CLASS_NAME =''WELL_DEFERMENT_CHILD'' WHERE DEFERMENT_TYPE=''GROUP_CHILD'' AND CLASS_NAME IS NULL';
BEGIN

     SELECT COUNT(*) INTO HASENTRY FROM USER_TRIGGERS 
		WHERE TRIGGER_NAME = 'IU_WELL_DEFERMENT'; 
		IF HASENTRY > 0 THEN 
		EXECUTE IMMEDIATE 'ALTER TRIGGER IU_WELL_DEFERMENT DISABLE';
		END IF;
		
     EXECUTE IMMEDIATE sqlQuery;
	 
	  SELECT COUNT(*) INTO HASENTRY FROM USER_TRIGGERS 
		WHERE TRIGGER_NAME = 'IU_WELL_DEFERMENT'; 
		IF HASENTRY > 0 THEN 
		EXECUTE IMMEDIATE 'ALTER TRIGGER IU_WELL_DEFERMENT ENABLE';
		END IF;
		
     dbms_output.put_line('SUCCESS: ' || sqlQuery);
     dbms_output.put_line('No of Rows Updated:' || sql%rowcount);
     EXCEPTION
        WHEN OTHERS THEN
		IF HASENTRY > 0 THEN 
		EXECUTE IMMEDIATE 'ALTER TRIGGER IU_WELL_DEFERMENT ENABLE';
		END IF;
         --UPDATE_MILESTONE_WITH_ERROR('post_data_model');
         raise_application_error(-20000, 'ERROR: Some Other fatal error occured' || SQLERRM);
 END;
--~^UTDELIM^~--

DECLARE
   HASENTRY NUMBER;
     sqlQuery clob:='UPDATE WELL_DEFERMENT_JN SET CLASS_NAME =''WELL_DEFERMENT_CHILD'' WHERE DEFERMENT_TYPE=''GROUP_CHILD'' AND CLASS_NAME IS NULL';
BEGIN
  
       SELECT COUNT(*) INTO HASENTRY FROM USER_TRIGGERS 
		WHERE TRIGGER_NAME = 'IU_WELL_DEFERMENT_JN'; 
		IF HASENTRY > 0 THEN 
		EXECUTE IMMEDIATE 'ALTER TRIGGER IU_WELL_DEFERMENT_JN DISABLE';
		END IF;
		
     EXECUTE IMMEDIATE sqlQuery;
	 
	   SELECT COUNT(*) INTO HASENTRY FROM USER_TRIGGERS 
		WHERE TRIGGER_NAME = 'IU_WELL_DEFERMENT_JN'; 
		IF HASENTRY > 0 THEN 
		EXECUTE IMMEDIATE 'ALTER TRIGGER IU_WELL_DEFERMENT_JN ENABLE';
		END IF;
		
     dbms_output.put_line('SUCCESS: ' || sqlQuery);
     dbms_output.put_line('No of Rows Updated:' || sql%rowcount);
     EXCEPTION
        WHEN OTHERS THEN
		IF HASENTRY > 0 THEN 
		EXECUTE IMMEDIATE 'ALTER TRIGGER IU_WELL_DEFERMENT_JN ENABLE';
		END IF;
         --UPDATE_MILESTONE_WITH_ERROR('post_data_model');
         raise_application_error(-20000, 'ERROR: Some Other fatal error occured' || SQLERRM);
 END;
--~^UTDELIM^~--

DECLARE
        HASENTRY NUMBER;
     sqlQuery clob:='UPDATE WELL_DEFERMENT SET CLASS_NAME =''WELL_DEFERMENT'' WHERE DEFERMENT_TYPE IN (''GROUP'',''SINGLE'') AND CLASS_NAME IS NULL';
BEGIN

      SELECT COUNT(*) INTO HASENTRY FROM USER_TRIGGERS 
		WHERE TRIGGER_NAME = 'IU_WELL_DEFERMENT'; 
		IF HASENTRY > 0 THEN 
		EXECUTE IMMEDIATE 'ALTER TRIGGER IU_WELL_DEFERMENT DISABLE';
		END IF;
		
     EXECUTE IMMEDIATE sqlQuery;
	 
	  SELECT COUNT(*) INTO HASENTRY FROM USER_TRIGGERS 
		WHERE TRIGGER_NAME = 'IU_WELL_DEFERMENT'; 
		IF HASENTRY > 0 THEN 
		EXECUTE IMMEDIATE 'ALTER TRIGGER IU_WELL_DEFERMENT ENABLE';
		END IF;
		
	 
     dbms_output.put_line('SUCCESS: ' || sqlQuery);
     dbms_output.put_line('No of Rows Updated:' || sql%rowcount);
     EXCEPTION
        WHEN OTHERS THEN
		IF HASENTRY > 0 THEN 
		EXECUTE IMMEDIATE 'ALTER TRIGGER IU_WELL_DEFERMENT ENABLE';
		END IF;
         --UPDATE_MILESTONE_WITH_ERROR('post_data_model');
         raise_application_error(-20000, 'ERROR: Some Other fatal error occured' || SQLERRM);
 END;
--~^UTDELIM^~--

DECLARE
      HASENTRY NUMBER;
     sqlQuery clob:='UPDATE WELL_DEFERMENT_JN SET CLASS_NAME =''WELL_DEFERMENT'' WHERE DEFERMENT_TYPE IN (''GROUP'',''SINGLE'') AND CLASS_NAME IS NULL';
BEGIN

     
	  SELECT COUNT(*) INTO HASENTRY FROM USER_TRIGGERS 
		WHERE TRIGGER_NAME = 'IU_WELL_DEFERMENT_JN'; 
		IF HASENTRY > 0 THEN 
		EXECUTE IMMEDIATE 'ALTER TRIGGER IU_WELL_DEFERMENT_JN DISABLE';
		END IF;
		
     EXECUTE IMMEDIATE sqlQuery;
	 
	   SELECT COUNT(*) INTO HASENTRY FROM USER_TRIGGERS 
		WHERE TRIGGER_NAME = 'IU_WELL_DEFERMENT_JN'; 
		IF HASENTRY > 0 THEN 
		EXECUTE IMMEDIATE 'ALTER TRIGGER IU_WELL_DEFERMENT_JN ENABLE';
		END IF;
		
	 
     dbms_output.put_line('SUCCESS: ' || sqlQuery);
     dbms_output.put_line('No of Rows Updated:' || sql%rowcount);
     EXCEPTION
        WHEN OTHERS THEN
		IF HASENTRY > 0 THEN 
		EXECUTE IMMEDIATE 'ALTER TRIGGER IU_WELL_DEFERMENT_JN ENABLE';
		END IF;
         --UPDATE_MILESTONE_WITH_ERROR('post_data_model');
         raise_application_error(-20000, 'ERROR: Some Other fatal error occured' || SQLERRM);
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


	COMMENT ON TABLE FCST_SCENARIO_GRAPHS IS 'The table is used to store scenarios for comparison.'
--~^UTDELIM^~--

	COMMENT ON TABLE FCST_PROD_CURVES IS 'FORECAST PRODUCTION CURVE DATA'
--~^UTDELIM^~--

	COMMENT ON TABLE FCST_PROD_CURVES_SEGMENT IS 'FORECAST PRODUCTION CURVE DATA'
--~^UTDELIM^~--

	COMMENT ON TABLE FCST_AREA_DAY IS 'Daily Area forecast data'
--~^UTDELIM^~--

	COMMENT ON TABLE FCST_AREA_MTH IS 'Monthly Area forecast data'
--~^UTDELIM^~--

	COMMENT ON TABLE FCST_PRODUNIT_DAY IS 'Daily Production Unit forecast data'
--~^UTDELIM^~--

	COMMENT ON TABLE FCST_PRODUNIT_MTH IS 'Monthly Production Unit forecast data'
--~^UTDELIM^~--

	COMMENT ON TABLE FCST_SUB_AREA_DAY IS 'Daily Sub Area forecast data'
--~^UTDELIM^~--

	COMMENT ON TABLE FCST_SUB_AREA_MTH IS 'Monthly Sub Area forecast data'
--~^UTDELIM^~--

	COMMENT ON TABLE FCST_SUB_FIELD_DAY IS 'Daily Sub Field forecast data'
--~^UTDELIM^~--

	COMMENT ON TABLE FCST_SUB_FIELD_MTH IS 'Monthly Sub Field forecast data'
--~^UTDELIM^~--

	COMMENT ON TABLE FCST_SUB_PRODUNIT_DAY IS 'Daily Production Sub Unit forecast data'
--~^UTDELIM^~--

	COMMENT ON TABLE FCST_SUB_PRODUNIT_MTH IS 'Monthly Production Sub Unit forecast data'
--~^UTDELIM^~--

	COMMENT ON COLUMN PWEL_RESULT.GL_USC_PRESS IS 'Artificial Lift – Upstream Choke Pressure.'
--~^UTDELIM^~--

    COMMENT ON COLUMN PWEL_RESULT.GL_USC_TEMP IS 'Artificial Lift – Upstream Choke Temperature.'
--~^UTDELIM^~--

	COMMENT ON TABLE DEFERMENT_STATUS_LOG IS 'It will receive Well and Equipment status which will help system to create deferment or ends a deferment event automatically or at users will.'
--~^UTDELIM^~--

	COMMENT ON COLUMN DEFERMENT_STATUS_LOG.object_id IS 'It will received Well or equipment object_id for which status change is observed.'
--~^UTDELIM^~--

	COMMENT ON COLUMN DEFERMENT_STATUS_LOG.status IS 'It will receive status as either 0 for Running and 1 for Stopped'
--~^UTDELIM^~--

	COMMENT ON COLUMN DEFERMENT_STATUS_LOG.event_created IS 'It will carry value as N, representing "event not created" and Y for "event created"'
--~^UTDELIM^~--

	COMMENT ON COLUMN DEFERMENT_STATUS_LOG.err_log IS 'Maintain error log, ecncountered during creation of deferment event for corresponding proposed events'
--~^UTDELIM^~--


DECLARE
BEGIN
FOR F IN (SELECT * FROM PROD_FORECAST ORDER BY FCST_SCEN_NO) LOOP

-- New record will be added in FORECAST_GROUP using existing forecast records from PROD_FORECAST table.
INSERT INTO FORECAST_GROUP
        (OBJECT_CODE,
         FORECAST_TYPE,
         FORECAST_PERIOD,
         START_DATE,
         END_DATE,
         DESCRIPTION)
VALUES   ('MIG_FCST_'|| F.FCST_SCEN_NO,
         NVL(F.FORECAST_TYPE, ' '), -- Refer note 1
         F.SCENARIO,
         F.DAYTIME,
         ADD_MONTHS(F.DAYTIME, 48), -- Refer note 2
         NULL);
         
-- New record will be added in FORECAST_GROUP_VERSION using existing forecast records from PROD_FORECAST table.
INSERT INTO FORECAST_GROUP_VERSION
 (   object_id
    ,name 
    ,daytime  
    ,end_date
    ,comments 
    ,text_1  
    ,text_2  
    ,text_3  
    ,text_4  
    ,text_5  
    ,value_1  
    ,value_2  
    ,value_3  
    ,value_4  
    ,value_5  
    ,date_1 
    ,date_2 
    ,date_3 
    ,date_4 
    ,date_5 )
VALUES(
     ECDP_OBJECTS.GetObjIDFromCode ('FORECAST_GROUP','MIG_FCST_'||F.FCST_SCEN_NO)
    ,'MIG_FCST_'|| F.FCST_SCEN_NO
    ,f.daytime
    ,ADD_MONTHS(f.daytime, 48) -- refer note 2
    ,f.comments 
    ,f.text_1  
    ,f.text_2  
    ,f.text_3  
    ,f.text_4  
    ,f.text_5  
    ,f.value_1  
    ,f.value_2  
    ,f.value_3  
    ,f.value_4  
    ,f.value_5  
    ,f.date_1 
    ,f.date_2 
    ,f.date_3 
    ,f.date_4 
    ,f.date_5);
    
-- New record will be added in FORECAST using existing forecast records from PROD_FORECAST table.
INSERT INTO FORECAST (CLASS_NAME,OBJECT_CODE, START_DATE, END_DATE)
VALUES ('FORECAST_PROD','MIG_SCN_'||F.FCST_SCEN_NO, F.DAYTIME, ADD_MONTHS(F.DAYTIME, 48));

-- New record will be added in FORECAST_VERSION using existing forecast records from PROD_FORECAST table.
INSERT INTO FORECAST_VERSION (OBJECT_ID,NAME,DAYTIME, END_DATE)
VALUES (ECDP_OBJECTS.GetObjIDFromCode ('FORECAST_PROD','MIG_SCN_'||F.FCST_SCEN_NO),'MIG_SCN_'||F.FCST_SCEN_NO, F.DAYTIME, ADD_MONTHS(F.DAYTIME, 48));

-- New record will be added in FCST_PWEL_DAY using existing daily well records from PROD_WELL_FORECAST table.
INSERT INTO FCST_PWEL_DAY
 (   
    effective_daytime
    ,object_id
    ,daytime  
    ,forecast_id
    ,scenario_id
    ,net_oil_rate          
    ,gas_rate              
    ,cond_rate             
    ,water_rate            
    ,steam_inj_rate        
    ,steam_inj_mass_rate
    ,water_inj_rate        
    ,gas_inj_rate          
    ,diluent_rate          
    ,gas_lift_rate                 
    ,cond_mass_rate        
    ,gas_mass_rate         
    ,net_oil_mass_rate     
    ,water_mass_rate       
    ,co2_inj_rate       
    ,value_1
    ,value_2
    ,value_3
    ,value_4
    ,value_5
    ,value_6
    ,value_7
    ,value_8
    ,value_9
    ,value_10
    ,value_11 
    ,value_12 
    ,value_13 
    ,value_14 
    ,value_15 
    ,value_16 
    ,value_17 
    ,value_18 
    ,value_19 
    ,value_20 
    ,value_21 
    ,value_22 
    ,value_23 
    ,value_24 
    ,value_25 
    ,value_26 
    ,value_27 
    ,value_28 
    ,value_29 
    ,value_30 
    ,value_31 
    ,value_32 
    ,value_33 
    ,value_34 
    ,value_35 
    ,value_36 
    ,value_37 
    ,value_38 
    ,value_39 
    ,value_40 
    ,value_41 
    ,value_42 
    ,value_43 
    ,value_44 
    ,value_45 
    ,value_46 
    ,value_47 
    ,value_48 
    ,value_49 
    ,value_50 
    ,text_1
    ,text_2
    ,text_3
    ,text_4
    ,text_5   
    ,text_6   
    ,text_7   
    ,text_8   
    ,text_9   
    ,text_10  
    ,date_1
    ,date_2
    ,date_3
    ,date_4
    ,date_5        
)
SELECT   
     effective_daytime
    ,object_id
    ,daytime
    ,ECDP_OBJECTS.GetObjIDFromCode('FORECAST_GROUP','MIG_FCST_'||F.FCST_SCEN_NO)
    ,ECDP_OBJECTS.GetObjIDFromCode('FORECAST_PROD','MIG_SCN_'||F.FCST_SCEN_NO)
    ,net_oil_rate          
    ,gas_rate              
    ,cond_rate             
    ,water_rate            
    ,steam_inj_rate        
    ,steam_inj_rate_mass   
    ,water_inj_rate        
    ,gas_inj_rate          
    ,diluent_rate          
    ,gas_lift_rate                 
    ,cond_rate_mass        
    ,gas_rate_mass         
    ,net_oil_rate_mass     
    ,water_rate_mass       
    ,co2_inj_rate       
    ,value_1
    ,value_2
    ,value_3
    ,value_4
    ,value_5
    ,value_6
    ,value_7
    ,value_8
    ,value_9
    ,value_10
    ,value_11 
    ,value_12 
    ,value_13 
    ,value_14 
    ,value_15 
    ,value_16 
    ,value_17 
    ,value_18 
    ,value_19 
    ,value_20 
    ,value_21 
    ,value_22 
    ,value_23 
    ,value_24 
    ,value_25 
    ,value_26 
    ,value_27 
    ,value_28 
    ,value_29 
    ,value_30 
    ,value_31 
    ,value_32 
    ,value_33 
    ,value_34 
    ,value_35 
    ,value_36 
    ,value_37 
    ,value_38 
    ,value_39 
    ,value_40 
    ,value_41 
    ,value_42 
    ,value_43 
    ,value_44 
    ,value_45 
    ,value_46 
    ,value_47 
    ,value_48 
    ,value_49 
    ,value_50 
    ,text_1
    ,text_2
    ,text_3
    ,text_4
    ,text_5   
    ,text_6   
    ,text_7   
    ,text_8   
    ,text_9   
    ,text_10  
    ,date_1
    ,date_2
    ,date_3
    ,date_4
    ,date_5        
FROM  PROD_WELL_FORECAST PWF
WHERE PWF.FCST_SCEN_NO=F.FCST_SCEN_NO;

-- New record will be added in FCST_PWEL_DAY_JN using existing daily well records from PROD_WELL_FORECAST_JN table.
INSERT INTO FCST_PWEL_DAY_JN
 (   
     jn_operation
    ,jn_oracle_user
    ,jn_datetime
    ,jn_notes
    ,jn_appln
    ,jn_session
    ,effective_daytime
    ,object_id
    ,daytime  
    ,forecast_id
    ,scenario_id
    ,net_oil_rate          
    ,gas_rate              
    ,cond_rate             
    ,water_rate            
    ,steam_inj_rate        
    ,steam_inj_mass_rate
    ,water_inj_rate        
    ,gas_inj_rate          
    ,diluent_rate          
    ,gas_lift_rate                 
    ,cond_mass_rate        
    ,gas_mass_rate         
    ,net_oil_mass_rate     
    ,water_mass_rate       
    ,co2_inj_rate       
    ,value_1
    ,value_2
    ,value_3
    ,value_4
    ,value_5
    ,value_6
    ,value_7
    ,value_8
    ,value_9
    ,value_10
    ,value_11 
    ,value_12 
    ,value_13 
    ,value_14 
    ,value_15 
    ,value_16 
    ,value_17 
    ,value_18 
    ,value_19 
    ,value_20 
    ,value_21 
    ,value_22 
    ,value_23 
    ,value_24 
    ,value_25 
    ,value_26 
    ,value_27 
    ,value_28 
    ,value_29 
    ,value_30 
    ,value_31 
    ,value_32 
    ,value_33 
    ,value_34 
    ,value_35 
    ,value_36 
    ,value_37 
    ,value_38 
    ,value_39 
    ,value_40 
    ,value_41 
    ,value_42 
    ,value_43 
    ,value_44 
    ,value_45 
    ,value_46 
    ,value_47 
    ,value_48 
    ,value_49 
    ,value_50 
    ,text_1
    ,text_2
    ,text_3
    ,text_4
    ,text_5   
    ,text_6   
    ,text_7   
    ,text_8   
    ,text_9   
    ,text_10  
    ,date_1
    ,date_2
    ,date_3
    ,date_4
    ,date_5        
)
SELECT   
     jn_operation
	,jn_oracle_user
	,jn_datetime
	,jn_notes
	,jn_appln
	,jn_session
	,effective_daytime
	,object_id
	,daytime
	,ECDP_OBJECTS.GetObjIDFromCode('FORECAST_GROUP','MIG_FCST_'||F.FCST_SCEN_NO)
	,ECDP_OBJECTS.GetObjIDFromCode('FORECAST_PROD','MIG_SCN_'||F.FCST_SCEN_NO)
	,net_oil_rate          
	,gas_rate              
	,cond_rate             
	,water_rate            
	,steam_inj_rate        
	,steam_inj_rate_mass   
	,water_inj_rate        
	,gas_inj_rate          
	,diluent_rate          
	,gas_lift_rate                 
	,cond_rate_mass        
	,gas_rate_mass         
	,net_oil_rate_mass     
	,water_rate_mass       
	,co2_inj_rate       
	,value_1
	,value_2
	,value_3
	,value_4
	,value_5
	,value_6
	,value_7
	,value_8
	,value_9
	,value_10
	,value_11 
	,value_12 
	,value_13 
	,value_14 
	,value_15 
	,value_16 
	,value_17 
	,value_18 
	,value_19 
	,value_20 
	,value_21 
	,value_22 
	,value_23 
	,value_24 
	,value_25 
	,value_26 
	,value_27 
	,value_28 
	,value_29 
	,value_30 
	,value_31 
	,value_32 
	,value_33 
	,value_34 
	,value_35 
	,value_36 
	,value_37 
	,value_38 
	,value_39 
	,value_40 
	,value_41 
	,value_42 
	,value_43 
	,value_44 
	,value_45 
	,value_46 
	,value_47 
	,value_48 
	,value_49 
	,value_50 
	,text_1
	,text_2
	,text_3
	,text_4
	,text_5   
	,text_6   
	,text_7   
	,text_8   
	,text_9   
	,text_10  
	,date_1
	,date_2
	,date_3
	,date_4
	,date_5        
FROM  PROD_WELL_FORECAST_JN PWF
WHERE PWF.FCST_SCEN_NO=F.FCST_SCEN_NO;

-- New record will be added in FCST_PWEL_MTH using existing monthly well records from PROD_WELL_FORECAST table.
INSERT INTO FCST_PWEL_MTH
 (  
     effective_daytime
    ,object_id
    ,daytime  
    ,forecast_id
    ,scenario_id
    ,net_oil_rate          
    ,gas_rate              
    ,cond_rate             
    ,water_rate            
    ,steam_inj_rate        
    ,steam_inj_mass_rate
    ,water_inj_rate        
    ,gas_inj_rate          
    ,diluent_rate          
    ,gas_lift_rate                 
    ,cond_mass_rate        
    ,gas_mass_rate         
    ,net_oil_mass_rate     
    ,water_mass_rate       
    ,co2_inj_rate       
    ,value_1
    ,value_2
    ,value_3
    ,value_4
    ,value_5
    ,value_6
    ,value_7
    ,value_8
    ,value_9
    ,value_10
    ,value_11 
    ,value_12 
    ,value_13 
    ,value_14 
    ,value_15 
    ,value_16 
    ,value_17 
    ,value_18 
    ,value_19 
    ,value_20 
    ,value_21 
    ,value_22 
    ,value_23 
    ,value_24 
    ,value_25 
    ,value_26 
    ,value_27 
    ,value_28 
    ,value_29 
    ,value_30 
    ,value_31 
    ,value_32 
    ,value_33 
    ,value_34 
    ,value_35 
    ,value_36 
    ,value_37 
    ,value_38 
    ,value_39 
    ,value_40 
    ,value_41 
    ,value_42 
    ,value_43 
    ,value_44 
    ,value_45 
    ,value_46 
    ,value_47 
    ,value_48 
    ,value_49 
    ,value_50 
    ,text_1
    ,text_2
    ,text_3
    ,text_4
    ,text_5   
    ,text_6   
    ,text_7   
    ,text_8   
    ,text_9   
    ,text_10  
    ,date_1
    ,date_2
    ,date_3
    ,date_4
    ,date_5        
)
SELECT   
	 effective_daytime
	 ,object_id
	 ,daytime
	 ,ECDP_OBJECTS.GetObjIDFromCode('FORECAST_GROUP','MIG_FCST_'||F.FCST_SCEN_NO)
	 ,ECDP_OBJECTS.GetObjIDFromCode('FORECAST_PROD','MIG_SCN_'||F.FCST_SCEN_NO)
	 ,net_oil_rate_mth     
	 ,gas_rate_mth        
	 ,cond_rate_mth       
	 ,water_rate_mth      
	 ,steam_inj_rate_mth  
	 ,steam_inj_rate_mass
	 ,water_inj_rate_mth  
	 ,gas_inj_rate_mth    
	 ,diluent_rate_mth    
	 ,gas_lift_rate_mth       
	 ,cond_rate_mass_mth      
	 ,gas_rate_mass_mth    
	 ,net_oil_rate_mass_mth    
	 ,water_rate_mass_mth      
	 ,co2_inj_rate_mth     
	,value_1
	,value_2
	,value_3
	,value_4
	,value_5
	,value_6
	,value_7
	,value_8
	,value_9
	,value_10
	,value_11 
	,value_12 
	,value_13 
	,value_14 
	,value_15 
	,value_16 
	,value_17 
	,value_18 
	,value_19 
	,value_20 
	,value_21 
	,value_22 
	,value_23 
	,value_24 
	,value_25 
	,value_26 
	,value_27 
	,value_28 
	,value_29 
	,value_30 
	,value_31 
	,value_32 
	,value_33 
	,value_34 
	,value_35 
	,value_36 
	,value_37 
	,value_38 
	,value_39 
	,value_40 
	,value_41 
	,value_42 
	,value_43 
	,value_44 
	,value_45 
	,value_46 
	,value_47 
	,value_48 
	,value_49 
	,value_50 
	,text_1
	,text_2
	,text_3
	,text_4
	,text_5   
	,text_6   
	,text_7   
	,text_8   
	,text_9   
	,text_10  
	,date_1
	,date_2
	,date_3
	,date_4
	,date_5        
FROM  PROD_WELL_FORECAST PWF
WHERE PWF.FCST_SCEN_NO=F.FCST_SCEN_NO;

-- New record will be added in FCST_PWEL_MTH_JN using existing monthly well records from PROD_WELL_FORECAST_JN table.
INSERT INTO FCST_PWEL_MTH_JN
 (   jn_operation
    ,jn_oracle_user
    ,jn_datetime
    ,jn_notes
    ,jn_appln
    ,jn_session
    ,effective_daytime
    ,object_id
    ,daytime  
    ,forecast_id
    ,scenario_id
    ,net_oil_rate          
    ,gas_rate              
    ,cond_rate             
    ,water_rate            
    ,steam_inj_rate        
    ,steam_inj_mass_rate
    ,water_inj_rate        
    ,gas_inj_rate          
    ,diluent_rate          
    ,gas_lift_rate                 
    ,cond_mass_rate        
    ,gas_mass_rate         
    ,net_oil_mass_rate     
    ,water_mass_rate       
    ,co2_inj_rate       
    ,value_1
    ,value_2
    ,value_3
    ,value_4
    ,value_5
    ,value_6
    ,value_7
    ,value_8
    ,value_9
    ,value_10
    ,value_11 
    ,value_12 
    ,value_13 
    ,value_14 
    ,value_15 
    ,value_16 
    ,value_17 
    ,value_18 
    ,value_19 
    ,value_20 
    ,value_21 
    ,value_22 
    ,value_23 
    ,value_24 
    ,value_25 
    ,value_26 
    ,value_27 
    ,value_28 
    ,value_29 
    ,value_30 
    ,value_31 
    ,value_32 
    ,value_33 
    ,value_34 
    ,value_35 
    ,value_36 
    ,value_37 
    ,value_38 
    ,value_39 
    ,value_40 
    ,value_41 
    ,value_42 
    ,value_43 
    ,value_44 
    ,value_45 
    ,value_46 
    ,value_47 
    ,value_48 
    ,value_49 
    ,value_50 
    ,text_1
    ,text_2
    ,text_3
    ,text_4
    ,text_5   
    ,text_6   
    ,text_7   
    ,text_8   
    ,text_9   
    ,text_10  
    ,date_1
    ,date_2
    ,date_3
    ,date_4
    ,date_5        
)
SELECT   
	 jn_operation
	,jn_oracle_user
	,jn_datetime
	,jn_notes
	,jn_appln
	,jn_session
	,effective_daytime
	,object_id
	,daytime
	,ECDP_OBJECTS.GetObjIDFromCode('FORECAST_GROUP','MIG_FCST_'||F.FCST_SCEN_NO)
	,ECDP_OBJECTS.GetObjIDFromCode('FORECAST_PROD','MIG_SCN_'||F.FCST_SCEN_NO)
	,net_oil_rate_mth     
	,gas_rate_mth        
	,cond_rate_mth       
	,water_rate_mth      
	,steam_inj_rate_mth  
	,STEAM_INJ_RATE_MASS
	,water_inj_rate_mth  
	,gas_inj_rate_mth    
	,diluent_rate_mth    
	,gas_lift_rate_mth       
	,cond_rate_mass_mth      
	,gas_rate_mass_mth    
	,net_oil_rate_mass_mth    
	,water_rate_mass_mth      
	,co2_inj_rate_mth     
	,value_1
	,value_2
	,value_3
	,value_4
	,value_5
	,value_6
	,value_7
	,value_8
	,value_9
	,value_10
	,value_11 
	,value_12 
	,value_13 
	,value_14 
	,value_15 
	,value_16 
	,value_17 
	,value_18 
	,value_19 
	,value_20 
	,value_21 
	,value_22 
	,value_23 
	,value_24 
	,value_25 
	,value_26 
	,value_27 
	,value_28 
	,value_29 
	,value_30 
	,value_31 
	,value_32 
	,value_33 
	,value_34 
	,value_35 
	,value_36 
	,value_37 
	,value_38 
	,value_39 
	,value_40 
	,value_41 
	,value_42 
	,value_43 
	,value_44 
	,value_45 
	,value_46 
	,value_47 
	,value_48 
	,value_49 
	,value_50 
	,text_1
	,text_2
	,text_3
	,text_4
	,text_5   
	,text_6   
	,text_7   
	,text_8   
	,text_9   
	,text_10  
	,date_1
	,date_2
	,date_3
	,date_4
	,date_5        
FROM  PROD_WELL_FORECAST_JN PWF
WHERE PWF.FCST_SCEN_NO=F.FCST_SCEN_NO;


-- New record will be added in FCST_STREAM_DAY using existing daily stream records from PROD_STREAM_FORECAST table.
INSERT INTO FCST_STREAM_DAY
 (   effective_daytime
    ,object_id
    ,daytime  
    ,forecast_id
    ,scenario_id
    ,net_oil_rate          
    ,gas_rate              
    ,cond_rate             
    ,water_rate            
    ,steam_inj_rate        
    ,water_inj_rate        
    ,gas_inj_rate                                  
    ,cond_mass_rate        
    ,gas_mass_rate         
    ,net_oil_mass_rate     
    ,water_mass_rate           
    ,value_1
    ,value_2
    ,value_3
    ,value_4
    ,value_5
    ,value_6
    ,value_7
    ,value_8
    ,value_9
    ,value_10
    ,value_11 
    ,value_12 
    ,value_13 
    ,value_14 
    ,value_15 
    ,value_16 
    ,value_17 
    ,value_18 
    ,value_19 
    ,value_20 
    ,value_21 
    ,value_22 
    ,value_23 
    ,value_24 
    ,value_25 
    ,value_26 
    ,value_27 
    ,value_28 
    ,value_29 
    ,value_30 
    ,value_31 
    ,value_32 
    ,value_33 
    ,value_34 
    ,value_35 
    ,value_36 
    ,value_37 
    ,value_38 
    ,value_39 
    ,value_40 
    ,value_41 
    ,value_42 
    ,value_43 
    ,value_44 
    ,value_45 
    ,value_46 
    ,value_47 
    ,value_48 
    ,value_49 
    ,value_50 
    ,text_1
    ,text_2
    ,text_3
    ,text_4
    ,text_5   
    ,text_6   
    ,text_7   
    ,text_8   
    ,text_9   
    ,text_10  
    ,date_1
    ,date_2
    ,date_3
    ,date_4
    ,date_5        
)
SELECT   
	  effective_daytime
	 ,object_id
	 ,daytime
	 ,ECDP_OBJECTS.GetObjIDFromCode('FORECAST_GROUP','MIG_FCST_'||F.FCST_SCEN_NO)
	 ,ECDP_OBJECTS.GetObjIDFromCode('FORECAST_PROD','MIG_SCN_'||F.FCST_SCEN_NO)
	 ,net_oil_rate          
	,gas_rate              
	,cond_rate             
	,water_rate            
	,steam_inj_rate        
	,water_inj_rate        
	,gas_inj_rate                              
	,cond_mass_rate        
	,gas_mass_rate         
	,net_oil_mass_rate     
	,water_mass_rate          
	,value_1
	,value_2
	,value_3
	,value_4
	,value_5
	,value_6
	,value_7
	,value_8
	,value_9
	,value_10
	,value_11 
	,value_12 
	,value_13 
	,value_14 
	,value_15 
	,value_16 
	,value_17 
	,value_18 
	,value_19 
	,value_20 
	,value_21 
	,value_22 
	,value_23 
	,value_24 
	,value_25 
	,value_26 
	,value_27 
	,value_28 
	,value_29 
	,value_30 
	,value_31 
	,value_32 
	,value_33 
	,value_34 
	,value_35 
	,value_36 
	,value_37 
	,value_38 
	,value_39 
	,value_40 
	,value_41 
	,value_42 
	,value_43 
	,value_44 
	,value_45 
	,value_46 
	,value_47 
	,value_48 
	,value_49 
	,value_50 
	,text_1
	,text_2
	,text_3
	,text_4
	,text_5   
	,text_6   
	,text_7   
	,text_8   
	,text_9   
	,text_10  
	,date_1
	,date_2
	,date_3
	,date_4
	,date_5        
FROM  PROD_STRM_FORECAST PSF
WHERE PSF.FCST_SCEN_NO=F.FCST_SCEN_NO;

-- New record will be added in FCST_STREAM_DAY_JN using existing daily stream records from PROD_STREAM_FORECAST_JN table.
INSERT INTO FCST_STREAM_DAY_JN
 (   jn_operation
    ,jn_oracle_user
    ,jn_datetime
    ,jn_notes
    ,jn_appln
    ,jn_session
    ,effective_daytime
    ,object_id
    ,daytime  
    ,forecast_id
    ,scenario_id
    ,net_oil_rate          
    ,gas_rate              
    ,cond_rate             
    ,water_rate            
    ,steam_inj_rate        
    ,water_inj_rate        
    ,gas_inj_rate                                  
    ,cond_mass_rate        
    ,gas_mass_rate         
    ,net_oil_mass_rate     
    ,water_mass_rate           
    ,value_1
    ,value_2
    ,value_3
    ,value_4
    ,value_5
    ,value_6
    ,value_7
    ,value_8
    ,value_9
    ,value_10
    ,value_11 
    ,value_12 
    ,value_13 
    ,value_14 
    ,value_15 
    ,value_16 
    ,value_17 
    ,value_18 
    ,value_19 
    ,value_20 
    ,value_21 
    ,value_22 
    ,value_23 
    ,value_24 
    ,value_25 
    ,value_26 
    ,value_27 
    ,value_28 
    ,value_29 
    ,value_30 
    ,value_31 
    ,value_32 
    ,value_33 
    ,value_34 
    ,value_35 
    ,value_36 
    ,value_37 
    ,value_38 
    ,value_39 
    ,value_40 
    ,value_41 
    ,value_42 
    ,value_43 
    ,value_44 
    ,value_45 
    ,value_46 
    ,value_47 
    ,value_48 
    ,value_49 
    ,value_50 
    ,text_1
    ,text_2
    ,text_3
    ,text_4
    ,text_5   
    ,text_6   
    ,text_7   
    ,text_8   
    ,text_9   
    ,text_10  
    ,date_1
    ,date_2
    ,date_3
    ,date_4
    ,date_5        
)
SELECT   
	 jn_operation
	,jn_oracle_user
	,jn_datetime
	,jn_notes
	,jn_appln
	,jn_session
	,effective_daytime
	,object_id
	,daytime
	,ECDP_OBJECTS.GetObjIDFromCode('FORECAST_GROUP','MIG_FCST_'||F.FCST_SCEN_NO)
	,ECDP_OBJECTS.GetObjIDFromCode('FORECAST_PROD','MIG_SCN_'||F.FCST_SCEN_NO)
	,net_oil_rate          
	,gas_rate              
	,cond_rate             
	,water_rate            
	,steam_inj_rate        
	,water_inj_rate        
	,gas_inj_rate                              
	,cond_mass_rate        
	,gas_mass_rate         
	,net_oil_mass_rate     
	,water_mass_rate          
	,value_1
	,value_2
	,value_3
	,value_4
	,value_5
	,value_6
	,value_7
	,value_8
	,value_9
	,value_10
	,value_11 
	,value_12 
	,value_13 
	,value_14 
	,value_15 
	,value_16 
	,value_17 
	,value_18 
	,value_19 
	,value_20 
	,value_21 
	,value_22 
	,value_23 
	,value_24 
	,value_25 
	,value_26 
	,value_27 
	,value_28 
	,value_29 
	,value_30 
	,value_31 
	,value_32 
	,value_33 
	,value_34 
	,value_35 
	,value_36 
	,value_37 
	,value_38 
	,value_39 
	,value_40 
	,value_41 
	,value_42 
	,value_43 
	,value_44 
	,value_45 
	,value_46 
	,value_47 
	,value_48 
	,value_49 
	,value_50 
	,text_1
	,text_2
	,text_3
	,text_4
	,text_5   
	,text_6   
	,text_7   
	,text_8   
	,text_9   
	,text_10  
	,date_1
	,date_2
	,date_3
	,date_4
	,date_5        
FROM  PROD_STRM_FORECAST_JN PSF
WHERE PSF.FCST_SCEN_NO=F.FCST_SCEN_NO;

-- New record will be added in FCST_STREAM_MTH using existing monthly stream records from PROD_STREAM_FORECAST table.
INSERT INTO FCST_STREAM_MTH
 (   effective_daytime
    ,object_id
    ,daytime  
    ,forecast_id
    ,scenario_id
    ,net_oil_rate
    ,gas_rate        
    ,cond_rate       
    ,water_rate      
    ,steam_inj_rate  
    ,water_inj_rate  
    ,gas_inj_rate    
    ,value_1
    ,value_2
    ,value_3
    ,value_4
    ,value_5
    ,value_6
    ,value_7
    ,value_8
    ,value_9
    ,value_10
    ,value_11 
    ,value_12 
    ,value_13 
    ,value_14 
    ,value_15 
    ,value_16 
    ,value_17 
    ,value_18 
    ,value_19 
    ,value_20 
    ,value_21 
    ,value_22 
    , value_23 
    , value_24 
    , value_25 
    , value_26 
    , value_27 
    ,value_28 
    , value_29 
    , value_30 
    , value_31 
    , value_32 
    , value_33 
    ,value_34 
    , value_35 
    , value_36 
    , value_37 
    , value_38 
    , value_39 
    , value_40 
    , value_41 
    , value_42 
    , value_43 
    , value_44 
    , value_45 
    , value_46 
    , value_47 
    , value_48 
    , value_49 
    , value_50 
    ,text_1
    ,text_2
    ,text_3
    ,text_4
    ,text_5   
    ,text_6   
    ,text_7   
    ,text_8   
    ,text_9   
    ,text_10  
    ,date_1
    ,date_2
    ,date_3
    ,date_4
    ,date_5        
)
SELECT   
          EFFECTIVE_DAYTIME
         ,OBJECT_ID
         ,DAYTIME
         ,ECDP_OBJECTS.GetObjIDFromCode('FORECAST_GROUP','MIG_FCST_'||F.FCST_SCEN_NO)
         ,ECDP_OBJECTS.GetObjIDFromCode('FORECAST_PROD','MIG_SCN_'||F.FCST_SCEN_NO)
         ,net_oil_rate_mth     
         , gas_rate_mth        
         , cond_rate_mth       
         , water_rate_mth      
         , steam_inj_rate_mth  
         , water_inj_rate_mth  
         , gas_inj_rate_mth    
        ,VALUE_1
        ,VALUE_2
        ,VALUE_3
        ,VALUE_4
        ,VALUE_5
        ,VALUE_6
        ,VALUE_7
        ,VALUE_8
        ,VALUE_9
        ,VALUE_10
        ,value_11 
        ,value_12 
        ,value_13 
        , value_14 
        , value_15 
        , value_16 
        , value_17 
        , value_18 
        , value_19 
        , value_20 
        , value_21 
        , value_22 
        , value_23 
        , value_24 
        , value_25 
        , value_26 
        , value_27 
        ,value_28 
        , value_29 
        , value_30 
        , value_31 
        , value_32 
        , value_33 
        ,value_34 
        , value_35 
        , value_36 
        , value_37 
        , value_38 
        , value_39 
        , value_40 
        , value_41 
        , value_42 
        , value_43 
        , value_44 
        , value_45 
        , value_46 
        , value_47 
        , value_48 
        , value_49 
        , value_50 
        ,TEXT_1
        ,TEXT_2
        ,TEXT_3
        ,TEXT_4
        ,text_5   
        ,text_6   
        ,text_7   
        ,text_8   
        ,text_9   
        ,text_10  
        ,DATE_1
        ,DATE_2
        ,DATE_3
        ,DATE_4
        ,DATE_5        
FROM  PROD_STRM_FORECAST PSF
WHERE PSF.FCST_SCEN_NO=F.FCST_SCEN_NO;

-- New record will be added in FCST_STREAM_MTH_JN using existing monthly stream records from PROD_STREAM_FORECAST_JN table.
INSERT INTO FCST_STREAM_MTH_JN
 (   JN_OPERATION
    ,JN_ORACLE_USER
    ,JN_DATETIME
    ,JN_NOTES
    ,JN_APPLN
    ,JN_SESSION
    ,EFFECTIVE_DAYTIME
    ,OBJECT_ID
    ,DAYTIME  
    ,FORECAST_ID
    ,SCENARIO_ID
    ,net_oil_rate
    , gas_rate        
    , cond_rate       
    , water_rate      
    , steam_inj_rate  
    , water_inj_rate  
    , gas_inj_rate    
    ,VALUE_1
    ,VALUE_2
    ,VALUE_3
    ,VALUE_4
    ,VALUE_5
    ,VALUE_6
    ,VALUE_7
    ,VALUE_8
    ,VALUE_9
    ,VALUE_10
    ,value_11 
    ,value_12 
    ,value_13 
    , value_14 
    , value_15 
    , value_16 
    , value_17 
    , value_18 
    , value_19 
    , value_20 
    , value_21 
    , value_22 
    , value_23 
    , value_24 
    , value_25 
    , value_26 
    , value_27 
    ,value_28 
    , value_29 
    , value_30 
    , value_31 
    , value_32 
    , value_33 
    ,value_34 
    , value_35 
    , value_36 
    , value_37 
    , value_38 
    , value_39 
    , value_40 
    , value_41 
    , value_42 
    , value_43 
    , value_44 
    , value_45 
    , value_46 
    , value_47 
    , value_48 
    , value_49 
    , value_50 
    ,TEXT_1
    ,TEXT_2
    ,TEXT_3
    ,TEXT_4
    ,text_5   
    ,text_6   
    ,text_7   
    ,text_8   
    ,text_9   
    ,text_10  
    ,DATE_1
    ,DATE_2
    ,DATE_3
    ,DATE_4
    ,DATE_5        
)
SELECT   
          JN_OPERATION
         ,JN_ORACLE_USER
         ,JN_DATETIME
         ,JN_NOTES
         ,JN_APPLN
         ,JN_SESSION
         ,EFFECTIVE_DAYTIME
         ,OBJECT_ID
         ,DAYTIME
         ,ECDP_OBJECTS.GetObjIDFromCode('FORECAST_GROUP','MIG_FCST_'||F.FCST_SCEN_NO)
         ,ECDP_OBJECTS.GetObjIDFromCode('FORECAST_PROD','MIG_SCN_'||F.FCST_SCEN_NO)
         ,net_oil_rate_mth     
         , gas_rate_mth        
         , cond_rate_mth       
         , water_rate_mth      
         , steam_inj_rate_mth  
         , water_inj_rate_mth  
         , gas_inj_rate_mth    
        ,VALUE_1
        ,VALUE_2
        ,VALUE_3
        ,VALUE_4
        ,VALUE_5
        ,VALUE_6
        ,VALUE_7
        ,VALUE_8
        ,VALUE_9
        ,VALUE_10
        ,value_11 
        ,value_12 
        ,value_13 
        , value_14 
        , value_15 
        , value_16 
        , value_17 
        , value_18 
        , value_19 
        , value_20 
        , value_21 
        , value_22 
        , value_23 
        , value_24 
        , value_25 
        , value_26 
        , value_27 
        ,value_28 
        , value_29 
        , value_30 
        , value_31 
        , value_32 
        , value_33 
        ,value_34 
        , value_35 
        , value_36 
        , value_37 
        , value_38 
        , value_39 
        , value_40 
        , value_41 
        , value_42 
        , value_43 
        , value_44 
        , value_45 
        , value_46 
        , value_47 
        , value_48 
        , value_49 
        , value_50 
        ,TEXT_1
        ,TEXT_2
        ,TEXT_3
        ,TEXT_4
        ,text_5   
        ,text_6   
        ,text_7   
        ,text_8   
        ,text_9   
        ,text_10  
        ,DATE_1
        ,DATE_2
        ,DATE_3
        ,DATE_4
        ,DATE_5        
FROM  PROD_STRM_FORECAST_JN PSF
WHERE PSF.FCST_SCEN_NO=F.FCST_SCEN_NO;


-- New record will be added in FCST_FCTY_DAY using existing daily facility class1 forecast records from PROD_FCTY_FORECAST table.
INSERT INTO FCST_FCTY_DAY
 (   EFFECTIVE_DAYTIME
    ,OBJECT_ID
    ,DAYTIME  
    ,class_name
    ,FORECAST_ID
    ,SCENARIO_ID
     ,net_oil_rate          
    ,gas_rate              
    ,cond_rate             
    ,water_rate            
    ,steam_inj_rate        
    ,water_inj_rate        
    ,gas_inj_rate                              
    ,COND_MASS    
    ,GAS_ENERGY    
    ,GAS_INJ_MASS        
    ,NET_GAS_MASS
    ,NET_OIL_MASS         
    ,STEAM_INJ_MASS     
    ,WATER_INJ_MASS
    ,WATER_MASS        
    ,GAS_LIFT_RATE
    ,DILUENT_RATE         
    ,VALUE_1
    ,VALUE_2
    ,VALUE_3
    ,VALUE_4
    ,VALUE_5
    ,VALUE_6
    ,VALUE_7
    ,VALUE_8
    ,VALUE_9
    ,VALUE_10
    ,value_11 
    ,value_12 
    ,value_13 
    , value_14 
    , value_15 
    , value_16 
    , value_17 
    , value_18 
    , value_19 
    , value_20 
    , value_21 
    , value_22 
    , value_23 
    , value_24 
    , value_25 
    , value_26 
    , value_27 
    ,value_28 
    , value_29 
    , value_30 
    , value_31 
    , value_32 
    , value_33 
    ,value_34 
    , value_35 
    , value_36 
    , value_37 
    , value_38 
    , value_39 
    , value_40 
    , value_41 
    , value_42 
    , value_43 
    , value_44 
    , value_45 
    , value_46 
    , value_47 
    , value_48 
    , value_49 
    , value_50 
    ,TEXT_1
    ,TEXT_2
    ,TEXT_3
    ,TEXT_4
    ,text_5   
    ,text_6   
    ,text_7   
    ,text_8   
    ,text_9   
    ,text_10  
    ,DATE_1
    ,DATE_2
    ,DATE_3
    ,DATE_4
    ,DATE_5        
)
SELECT   
          EFFECTIVE_DAYTIME
         ,OBJECT_ID
         ,DAYTIME
         ,'FCST_FCTY1_DAY_STATUS' --class_name of new forecast 1 forecast
         ,ECDP_OBJECTS.GetObjIDFromCode('FORECAST_GROUP','MIG_FCST_'||F.FCST_SCEN_NO)
         ,ECDP_OBJECTS.GetObjIDFromCode('FORECAST_PROD','MIG_SCN_'||F.FCST_SCEN_NO)
         ,net_oil_rate          
        ,gas_rate              
        ,cond_rate             
        ,water_rate            
        ,steam_inj_rate        
        ,water_inj_rate        
        ,gas_inj_rate                              
        ,COND_MASS    
        ,GAS_ENERGY    
        ,GAS_INJ_MASS        
        ,NET_GAS_MASS
        ,NET_OIL_MASS         
        ,STEAM_INJ_MASS     
        ,WATER_INJ_MASS
        ,WATER_MASS        
        ,GAS_LIFT_RATE
        ,DILUENT_RATE
        ,VALUE_1
        ,VALUE_2
        ,VALUE_3
        ,VALUE_4
        ,VALUE_5
        ,VALUE_6
        ,VALUE_7
        ,VALUE_8
        ,VALUE_9
        ,VALUE_10
        ,value_11 
        ,value_12 
        ,value_13 
        , value_14 
        , value_15 
        , value_16 
        , value_17 
        , value_18 
        , value_19 
        , value_20 
        , value_21 
        , value_22 
        , value_23 
        , value_24 
        , value_25 
        , value_26 
        , value_27 
        ,value_28 
        , value_29 
        , value_30 
        , value_31 
        , value_32 
        , value_33 
        ,value_34 
        , value_35 
        , value_36 
        , value_37 
        , value_38 
        , value_39 
        , value_40 
        , value_41 
        , value_42 
        , value_43 
        , value_44 
        , value_45 
        , value_46 
        , value_47 
        , value_48 
        , value_49 
        , value_50 
        ,TEXT_1
        ,TEXT_2
        ,TEXT_3
        ,TEXT_4
        ,text_5   
        ,text_6   
        ,text_7   
        ,text_8   
        ,text_9   
        ,text_10  
        ,DATE_1
        ,DATE_2
        ,DATE_3
        ,DATE_4
        ,DATE_5        
FROM  PROD_FCTY_FORECAST PFF
WHERE PFF.FCST_SCEN_NO=F.FCST_SCEN_NO
AND CLASS_NAME='PROD_FCTY1_FORECAST';

-- New record will be added in FCST_FCTY_DAY_JN using existing daily facility class1 forecast records from PROD_FCTY_FORECAST_JN table.
INSERT INTO FCST_FCTY_DAY_JN
 (   JN_OPERATION
    ,JN_ORACLE_USER
    ,JN_DATETIME
    ,JN_NOTES
    ,JN_APPLN
    ,JN_SESSION
    ,EFFECTIVE_DAYTIME
    ,OBJECT_ID
    ,DAYTIME  
    ,class_name
    ,FORECAST_ID
    ,SCENARIO_ID
     ,net_oil_rate          
    ,gas_rate              
    ,cond_rate             
    ,water_rate            
    ,steam_inj_rate        
    ,water_inj_rate        
    ,gas_inj_rate                              
    ,COND_MASS    
    ,GAS_ENERGY    
    ,GAS_INJ_MASS        
    ,NET_GAS_MASS
    ,NET_OIL_MASS         
    ,STEAM_INJ_MASS     
    ,WATER_INJ_MASS
    ,WATER_MASS        
    ,GAS_LIFT_RATE
    ,DILUENT_RATE         
    ,VALUE_1
    ,VALUE_2
    ,VALUE_3
    ,VALUE_4
    ,VALUE_5
    ,VALUE_6
    ,VALUE_7
    ,VALUE_8
    ,VALUE_9
    ,VALUE_10
    ,value_11 
    ,value_12 
    ,value_13 
    , value_14 
    , value_15 
    , value_16 
    , value_17 
    , value_18 
    , value_19 
    , value_20 
    , value_21 
    , value_22 
    , value_23 
    , value_24 
    , value_25 
    , value_26 
    , value_27 
    ,value_28 
    , value_29 
    , value_30 
    , value_31 
    , value_32 
    , value_33 
    ,value_34 
    , value_35 
    , value_36 
    , value_37 
    , value_38 
    , value_39 
    , value_40 
    , value_41 
    , value_42 
    , value_43 
    , value_44 
    , value_45 
    , value_46 
    , value_47 
    , value_48 
    , value_49 
    , value_50 
    ,TEXT_1
    ,TEXT_2
    ,TEXT_3
    ,TEXT_4
    ,text_5   
    ,text_6   
    ,text_7   
    ,text_8   
    ,text_9   
    ,text_10  
    ,DATE_1
    ,DATE_2
    ,DATE_3
    ,DATE_4
    ,DATE_5        
)
SELECT   
          JN_OPERATION
         ,JN_ORACLE_USER
         ,JN_DATETIME
         ,JN_NOTES
         ,JN_APPLN
         ,JN_SESSION
         ,EFFECTIVE_DAYTIME
         ,OBJECT_ID
         ,DAYTIME
         ,'FCST_FCTY1_DAY_STATUS' --class_name of new forecast 1 forecast
         ,ECDP_OBJECTS.GetObjIDFromCode('FORECAST_GROUP','MIG_FCST_'||F.FCST_SCEN_NO)
         ,ECDP_OBJECTS.GetObjIDFromCode('FORECAST_PROD','MIG_SCN_'||F.FCST_SCEN_NO)
         ,net_oil_rate          
        ,gas_rate              
        ,cond_rate             
        ,water_rate            
        ,steam_inj_rate        
        ,water_inj_rate        
        ,gas_inj_rate                              
        ,COND_MASS    
        ,GAS_ENERGY    
        ,GAS_INJ_MASS        
        ,NET_GAS_MASS
        ,NET_OIL_MASS         
        ,STEAM_INJ_MASS     
        ,WATER_INJ_MASS
        ,WATER_MASS        
        ,GAS_LIFT_RATE
        ,DILUENT_RATE
        ,VALUE_1
        ,VALUE_2
        ,VALUE_3
        ,VALUE_4
        ,VALUE_5
        ,VALUE_6
        ,VALUE_7
        ,VALUE_8
        ,VALUE_9
        ,VALUE_10
        ,value_11 
        ,value_12 
        ,value_13 
        , value_14 
        , value_15 
        , value_16 
        , value_17 
        , value_18 
        , value_19 
        , value_20 
        , value_21 
        , value_22 
        , value_23 
        , value_24 
        , value_25 
        , value_26 
        , value_27 
        ,value_28 
        , value_29 
        , value_30 
        , value_31 
        , value_32 
        , value_33 
        ,value_34 
        , value_35 
        , value_36 
        , value_37 
        , value_38 
        , value_39 
        , value_40 
        , value_41 
        , value_42 
        , value_43 
        , value_44 
        , value_45 
        , value_46 
        , value_47 
        , value_48 
        , value_49 
        , value_50 
        ,TEXT_1
        ,TEXT_2
        ,TEXT_3
        ,TEXT_4
        ,text_5   
        ,text_6   
        ,text_7   
        ,text_8   
        ,text_9   
        ,text_10  
        ,DATE_1
        ,DATE_2
        ,DATE_3
        ,DATE_4
        ,DATE_5        
FROM  PROD_FCTY_FORECAST_JN PFF
WHERE PFF.FCST_SCEN_NO=F.FCST_SCEN_NO
AND CLASS_NAME='PROD_FCTY1_FORECAST';

-- New record will be added in FCST_FCTY_DAY using existing daily facility class2 forecast records from PROD_FCTY_FORECAST table.
INSERT INTO FCST_FCTY_DAY
 (  EFFECTIVE_DAYTIME
    ,OBJECT_ID
    ,DAYTIME  
    ,class_name
    ,FORECAST_ID
    ,SCENARIO_ID
     ,net_oil_rate          
    ,gas_rate              
    ,cond_rate             
    ,water_rate            
    ,steam_inj_rate        
    ,water_inj_rate        
    ,gas_inj_rate                              
    ,COND_MASS    
    ,GAS_ENERGY    
    ,GAS_INJ_MASS        
    ,NET_GAS_MASS
    ,NET_OIL_MASS         
    ,STEAM_INJ_MASS     
    ,WATER_INJ_MASS
    ,WATER_MASS        
    ,GAS_LIFT_RATE
    ,DILUENT_RATE       
    ,VALUE_1
    ,VALUE_2
    ,VALUE_3
    ,VALUE_4
    ,VALUE_5
    ,VALUE_6
    ,VALUE_7
    ,VALUE_8
    ,VALUE_9
    ,VALUE_10
    ,value_11 
    ,value_12 
    ,value_13 
    , value_14 
    , value_15 
    , value_16 
    , value_17 
    , value_18 
    , value_19 
    , value_20 
    , value_21 
    , value_22 
    , value_23 
    , value_24 
    , value_25 
    , value_26 
    , value_27 
    ,value_28 
    , value_29 
    , value_30 
    , value_31 
    , value_32 
    , value_33 
    ,value_34 
    , value_35 
    , value_36 
    , value_37 
    , value_38 
    , value_39 
    , value_40 
    , value_41 
    , value_42 
    , value_43 
    , value_44 
    , value_45 
    , value_46 
    , value_47 
    , value_48 
    , value_49 
    , value_50 
    ,TEXT_1
    ,TEXT_2
    ,TEXT_3
    ,TEXT_4
    ,text_5   
    ,text_6   
    ,text_7   
    ,text_8   
    ,text_9   
    ,text_10  
    ,DATE_1
    ,DATE_2
    ,DATE_3
    ,DATE_4
    ,DATE_5        
)
SELECT   
          EFFECTIVE_DAYTIME
         ,OBJECT_ID
         ,DAYTIME
         ,'FCST_FCTY2_DAY_STATUS' --class_name of new forecast 1 forecast
         ,ECDP_OBJECTS.GetObjIDFromCode('FORECAST_GROUP','MIG_FCST_'||F.FCST_SCEN_NO)
         ,ECDP_OBJECTS.GetObjIDFromCode('FORECAST_PROD','MIG_SCN_'||F.FCST_SCEN_NO)
        ,net_oil_rate          
        ,gas_rate              
        ,cond_rate             
        ,water_rate            
        ,steam_inj_rate        
        ,water_inj_rate        
        ,gas_inj_rate                              
        ,COND_MASS    
        ,GAS_ENERGY    
        ,GAS_INJ_MASS        
        ,NET_GAS_MASS
        ,NET_OIL_MASS         
        ,STEAM_INJ_MASS     
        ,WATER_INJ_MASS
        ,WATER_MASS        
        ,GAS_LIFT_RATE
        ,DILUENT_RATE        
        ,VALUE_1
        ,VALUE_2
        ,VALUE_3
        ,VALUE_4
        ,VALUE_5
        ,VALUE_6
        ,VALUE_7
        ,VALUE_8
        ,VALUE_9
        ,VALUE_10
        ,value_11 
        ,value_12 
        ,value_13 
        , value_14 
        , value_15 
        , value_16 
        , value_17 
        , value_18 
        , value_19 
        , value_20 
        , value_21 
        , value_22 
        , value_23 
        , value_24 
        , value_25 
        , value_26 
        , value_27 
        ,value_28 
        , value_29 
        , value_30 
        , value_31 
        , value_32 
        , value_33 
        ,value_34 
        , value_35 
        , value_36 
        , value_37 
        , value_38 
        , value_39 
        , value_40 
        , value_41 
        , value_42 
        , value_43 
        , value_44 
        , value_45 
        , value_46 
        , value_47 
        , value_48 
        , value_49 
        , value_50 
        ,TEXT_1
        ,TEXT_2
        ,TEXT_3
        ,TEXT_4
        ,text_5   
        ,text_6   
        ,text_7   
        ,text_8   
        ,text_9   
        ,text_10  
        ,DATE_1
        ,DATE_2
        ,DATE_3
        ,DATE_4
        ,DATE_5        
FROM  PROD_FCTY_FORECAST PFF
WHERE PFF.FCST_SCEN_NO=F.FCST_SCEN_NO
AND CLASS_NAME='PROD_FCTY2_FORECAST';

-- New record will be added in FCST_FCTY_DAY_JN using existing daily facility class2 forecast records from PROD_FCTY_FORECAST_JN table.
INSERT INTO FCST_FCTY_DAY_JN
 (   JN_OPERATION
    ,JN_ORACLE_USER
    ,JN_DATETIME
    ,JN_NOTES
    ,JN_APPLN
    ,JN_SESSION
    ,EFFECTIVE_DAYTIME
    ,OBJECT_ID
    ,DAYTIME  
    ,class_name
    ,FORECAST_ID
    ,SCENARIO_ID
     ,net_oil_rate          
    ,gas_rate              
    ,cond_rate             
    ,water_rate            
    ,steam_inj_rate        
    ,water_inj_rate        
    ,gas_inj_rate                              
    ,COND_MASS    
    ,GAS_ENERGY    
    ,GAS_INJ_MASS        
    ,NET_GAS_MASS
    ,NET_OIL_MASS         
    ,STEAM_INJ_MASS     
    ,WATER_INJ_MASS
    ,WATER_MASS        
    ,GAS_LIFT_RATE
    ,DILUENT_RATE       
    ,VALUE_1
    ,VALUE_2
    ,VALUE_3
    ,VALUE_4
    ,VALUE_5
    ,VALUE_6
    ,VALUE_7
    ,VALUE_8
    ,VALUE_9
    ,VALUE_10
    ,value_11 
    ,value_12 
    ,value_13 
    , value_14 
    , value_15 
    , value_16 
    , value_17 
    , value_18 
    , value_19 
    , value_20 
    , value_21 
    , value_22 
    , value_23 
    , value_24 
    , value_25 
    , value_26 
    , value_27 
    ,value_28 
    , value_29 
    , value_30 
    , value_31 
    , value_32 
    , value_33 
    ,value_34 
    , value_35 
    , value_36 
    , value_37 
    , value_38 
    , value_39 
    , value_40 
    , value_41 
    , value_42 
    , value_43 
    , value_44 
    , value_45 
    , value_46 
    , value_47 
    , value_48 
    , value_49 
    , value_50 
    ,TEXT_1
    ,TEXT_2
    ,TEXT_3
    ,TEXT_4
    ,text_5   
    ,text_6   
    ,text_7   
    ,text_8   
    ,text_9   
    ,text_10  
    ,DATE_1
    ,DATE_2
    ,DATE_3
    ,DATE_4
    ,DATE_5        
)
SELECT   
          JN_OPERATION
         ,JN_ORACLE_USER
         ,JN_DATETIME
         ,JN_NOTES
         ,JN_APPLN
         ,JN_SESSION
         ,EFFECTIVE_DAYTIME
         ,OBJECT_ID
         ,DAYTIME
         ,'FCST_FCTY2_DAY_STATUS' --class_name of new forecast 1 forecast
         ,ECDP_OBJECTS.GetObjIDFromCode('FORECAST_GROUP','MIG_FCST_'||F.FCST_SCEN_NO)
         ,ECDP_OBJECTS.GetObjIDFromCode('FORECAST_PROD','MIG_SCN_'||F.FCST_SCEN_NO)
        ,net_oil_rate          
        ,gas_rate              
        ,cond_rate             
        ,water_rate            
        ,steam_inj_rate        
        ,water_inj_rate        
        ,gas_inj_rate                              
        ,COND_MASS    
        ,GAS_ENERGY    
        ,GAS_INJ_MASS        
        ,NET_GAS_MASS
        ,NET_OIL_MASS         
        ,STEAM_INJ_MASS     
        ,WATER_INJ_MASS
        ,WATER_MASS        
        ,GAS_LIFT_RATE
        ,DILUENT_RATE        
        ,VALUE_1
        ,VALUE_2
        ,VALUE_3
        ,VALUE_4
        ,VALUE_5
        ,VALUE_6
        ,VALUE_7
        ,VALUE_8
        ,VALUE_9
        ,VALUE_10
        ,value_11 
        ,value_12 
        ,value_13 
        , value_14 
        , value_15 
        , value_16 
        , value_17 
        , value_18 
        , value_19 
        , value_20 
        , value_21 
        , value_22 
        , value_23 
        , value_24 
        , value_25 
        , value_26 
        , value_27 
        ,value_28 
        , value_29 
        , value_30 
        , value_31 
        , value_32 
        , value_33 
        ,value_34 
        , value_35 
        , value_36 
        , value_37 
        , value_38 
        , value_39 
        , value_40 
        , value_41 
        , value_42 
        , value_43 
        , value_44 
        , value_45 
        , value_46 
        , value_47 
        , value_48 
        , value_49 
        , value_50 
        ,TEXT_1
        ,TEXT_2
        ,TEXT_3
        ,TEXT_4
        ,text_5   
        ,text_6   
        ,text_7   
        ,text_8   
        ,text_9   
        ,text_10  
        ,DATE_1
        ,DATE_2
        ,DATE_3
        ,DATE_4
        ,DATE_5        
FROM  PROD_FCTY_FORECAST_JN PFF
WHERE PFF.FCST_SCEN_NO=F.FCST_SCEN_NO
AND CLASS_NAME='PROD_FCTY2_FORECAST';

-- New record will be added in FCST_FCTY_MTH using existing monthly facility class1 forecast records from PROD_FCTY_FORECAST table.
INSERT INTO FCST_FCTY_MTH
 (   EFFECTIVE_DAYTIME
    ,OBJECT_ID
    ,DAYTIME  
    ,class_name
    ,FORECAST_ID
    ,SCENARIO_ID
    ,net_oil_rate
    , gas_rate        
    , cond_rate       
    , water_rate      
    , steam_inj_rate  
    , water_inj_rate  
    , gas_inj_rate    
    ,VALUE_1
    ,VALUE_2
    ,VALUE_3
    ,VALUE_4
    ,VALUE_5
    ,VALUE_6
    ,VALUE_7
    ,VALUE_8
    ,VALUE_9
    ,VALUE_10
    ,value_11 
    ,value_12 
    ,value_13 
    , value_14 
    , value_15 
    , value_16 
    , value_17 
    , value_18 
    , value_19 
    , value_20 
    , value_21 
    , value_22 
    , value_23 
    , value_24 
    , value_25 
    , value_26 
    , value_27 
    ,value_28 
    , value_29 
    , value_30 
    , value_31 
    , value_32 
    , value_33 
    ,value_34 
    , value_35 
    , value_36 
    , value_37 
    , value_38 
    , value_39 
    , value_40 
    , value_41 
    , value_42 
    , value_43 
    , value_44 
    , value_45 
    , value_46 
    , value_47 
    , value_48 
    , value_49 
    , value_50 
    ,TEXT_1
    ,TEXT_2
    ,TEXT_3
    ,TEXT_4
    ,text_5   
    ,text_6   
    ,text_7   
    ,text_8   
    ,text_9   
    ,text_10  
    ,DATE_1
    ,DATE_2
    ,DATE_3
    ,DATE_4
    ,DATE_5        
)
SELECT   
         EFFECTIVE_DAYTIME
         ,OBJECT_ID
         ,DAYTIME
         ,'FCST_FCTY1_MTH_STATUS'
         ,ECDP_OBJECTS.GetObjIDFromCode('FORECAST_GROUP','MIG_FCST_'||F.FCST_SCEN_NO)
         ,ECDP_OBJECTS.GetObjIDFromCode('FORECAST_PROD','MIG_SCN_'||F.FCST_SCEN_NO)
         ,net_oil_rate_mth     
         , gas_rate_mth        
         , cond_rate_mth       
         , water_rate_mth      
         , steam_inj_rate_mth  
         , water_inj_rate_mth  
         , gas_inj_rate_mth    
        ,VALUE_1
        ,VALUE_2
        ,VALUE_3
        ,VALUE_4
        ,VALUE_5
        ,VALUE_6
        ,VALUE_7
        ,VALUE_8
        ,VALUE_9
        ,VALUE_10
        ,value_11 
        ,value_12 
        ,value_13 
        , value_14 
        , value_15 
        , value_16 
        , value_17 
        , value_18 
        , value_19 
        , value_20 
        , value_21 
        , value_22 
        , value_23 
        , value_24 
        , value_25 
        , value_26 
        , value_27 
        ,value_28 
        , value_29 
        , value_30 
        , value_31 
        , value_32 
        , value_33 
        ,value_34 
        , value_35 
        , value_36 
        , value_37 
        , value_38 
        , value_39 
        , value_40 
        , value_41 
        , value_42 
        , value_43 
        , value_44 
        , value_45 
        , value_46 
        , value_47 
        , value_48 
        , value_49 
        , value_50 
        ,TEXT_1
        ,TEXT_2
        ,TEXT_3
        ,TEXT_4
        ,text_5   
        ,text_6   
        ,text_7   
        ,text_8   
        ,text_9   
        ,text_10  
        ,DATE_1
        ,DATE_2
        ,DATE_3
        ,DATE_4
        ,DATE_5        
FROM  PROD_FCTY_FORECAST PFF
WHERE PFF.FCST_SCEN_NO=F.FCST_SCEN_NO
AND CLASS_NAME='PROD_FCTY1_FORECAST';

-- New record will be added in FCST_FCTY_MTH_JN using existing monthly facility class1 forecast records from PROD_FCTY_FORECAST_JN table.
INSERT INTO FCST_FCTY_MTH_JN
 (   JN_OPERATION
    ,JN_ORACLE_USER
    ,JN_DATETIME
    ,JN_NOTES
    ,JN_APPLN
    ,JN_SESSION
    ,EFFECTIVE_DAYTIME
    ,OBJECT_ID
    ,DAYTIME  
    ,class_name
    ,FORECAST_ID
    ,SCENARIO_ID
    ,net_oil_rate
    , gas_rate        
    , cond_rate       
    , water_rate      
    , steam_inj_rate  
    , water_inj_rate  
    , gas_inj_rate    
    ,VALUE_1
    ,VALUE_2
    ,VALUE_3
    ,VALUE_4
    ,VALUE_5
    ,VALUE_6
    ,VALUE_7
    ,VALUE_8
    ,VALUE_9
    ,VALUE_10
    ,value_11 
    ,value_12 
    ,value_13 
    , value_14 
    , value_15 
    , value_16 
    , value_17 
    , value_18 
    , value_19 
    , value_20 
    , value_21 
    , value_22 
    , value_23 
    , value_24 
    , value_25 
    , value_26 
    , value_27 
    ,value_28 
    , value_29 
    , value_30 
    , value_31 
    , value_32 
    , value_33 
    ,value_34 
    , value_35 
    , value_36 
    , value_37 
    , value_38 
    , value_39 
    , value_40 
    , value_41 
    , value_42 
    , value_43 
    , value_44 
    , value_45 
    , value_46 
    , value_47 
    , value_48 
    , value_49 
    , value_50 
    ,TEXT_1
    ,TEXT_2
    ,TEXT_3
    ,TEXT_4
    ,text_5   
    ,text_6   
    ,text_7   
    ,text_8   
    ,text_9   
    ,text_10  
    ,DATE_1
    ,DATE_2
    ,DATE_3
    ,DATE_4
    ,DATE_5        
)
SELECT   
         JN_OPERATION
         ,JN_ORACLE_USER
         ,JN_DATETIME
         ,JN_NOTES
         ,JN_APPLN
         ,JN_SESSION
         ,EFFECTIVE_DAYTIME
         ,OBJECT_ID
         ,DAYTIME
         ,'FCST_FCTY1_MTH_STATUS'
         ,ECDP_OBJECTS.GetObjIDFromCode('FORECAST_GROUP','MIG_FCST_'||F.FCST_SCEN_NO)
         ,ECDP_OBJECTS.GetObjIDFromCode('FORECAST_PROD','MIG_SCN_'||F.FCST_SCEN_NO)
         ,net_oil_rate_mth     
         , gas_rate_mth        
         , cond_rate_mth       
         , water_rate_mth      
         , steam_inj_rate_mth  
         , water_inj_rate_mth  
         , gas_inj_rate_mth    
        ,VALUE_1
        ,VALUE_2
        ,VALUE_3
        ,VALUE_4
        ,VALUE_5
        ,VALUE_6
        ,VALUE_7
        ,VALUE_8
        ,VALUE_9
        ,VALUE_10
        ,value_11 
        ,value_12 
        ,value_13 
        , value_14 
        , value_15 
        , value_16 
        , value_17 
        , value_18 
        , value_19 
        , value_20 
        , value_21 
        , value_22 
        , value_23 
        , value_24 
        , value_25 
        , value_26 
        , value_27 
        ,value_28 
        , value_29 
        , value_30 
        , value_31 
        , value_32 
        , value_33 
        ,value_34 
        , value_35 
        , value_36 
        , value_37 
        , value_38 
        , value_39 
        , value_40 
        , value_41 
        , value_42 
        , value_43 
        , value_44 
        , value_45 
        , value_46 
        , value_47 
        , value_48 
        , value_49 
        , value_50 
        ,TEXT_1
        ,TEXT_2
        ,TEXT_3
        ,TEXT_4
        ,text_5   
        ,text_6   
        ,text_7   
        ,text_8   
        ,text_9   
        ,text_10  
        ,DATE_1
        ,DATE_2
        ,DATE_3
        ,DATE_4
        ,DATE_5        
FROM  PROD_FCTY_FORECAST_JN PFF
WHERE PFF.FCST_SCEN_NO=F.FCST_SCEN_NO
AND CLASS_NAME='PROD_FCTY1_FORECAST';

-- New record will be added in FCST_FCTY_MTH using existing monthly facility class2 forecast records from PROD_FCTY_FORECAST table.
INSERT INTO FCST_FCTY_MTH
 (   EFFECTIVE_DAYTIME
    ,OBJECT_ID
    ,DAYTIME  
    ,class_name
    ,FORECAST_ID
    ,SCENARIO_ID
    ,net_oil_rate
    , gas_rate        
    , cond_rate       
    , water_rate      
    , steam_inj_rate  
    , water_inj_rate  
    , gas_inj_rate    
    ,VALUE_1
    ,VALUE_2
    ,VALUE_3
    ,VALUE_4
    ,VALUE_5
    ,VALUE_6
    ,VALUE_7
    ,VALUE_8
    ,VALUE_9
    ,VALUE_10
    ,value_11 
    ,value_12 
    ,value_13 
    , value_14 
    , value_15 
    , value_16 
    , value_17 
    , value_18 
    , value_19 
    , value_20 
    , value_21 
    , value_22 
    , value_23 
    , value_24 
    , value_25 
    , value_26 
    , value_27 
    ,value_28 
    , value_29 
    , value_30 
    , value_31 
    , value_32 
    , value_33 
    ,value_34 
    , value_35 
    , value_36 
    , value_37 
    , value_38 
    , value_39 
    , value_40 
    , value_41 
    , value_42 
    , value_43 
    , value_44 
    , value_45 
    , value_46 
    , value_47 
    , value_48 
    , value_49 
    , value_50 
    ,TEXT_1
    ,TEXT_2
    ,TEXT_3
    ,TEXT_4
    ,text_5   
    ,text_6   
    ,text_7   
    ,text_8   
    ,text_9   
    ,text_10  
    ,DATE_1
    ,DATE_2
    ,DATE_3
    ,DATE_4
    ,DATE_5        
)
SELECT   
          EFFECTIVE_DAYTIME
         ,OBJECT_ID
         ,DAYTIME
         ,'FCST_FCTY2_MTH_STATUS'
         ,ECDP_OBJECTS.GetObjIDFromCode('FORECAST_GROUP','MIG_FCST_'||F.FCST_SCEN_NO)
         ,ECDP_OBJECTS.GetObjIDFromCode('FORECAST_PROD','MIG_SCN_'||F.FCST_SCEN_NO)
         ,net_oil_rate_mth     
         , gas_rate_mth        
         , cond_rate_mth       
         , water_rate_mth      
         , steam_inj_rate_mth  
         , water_inj_rate_mth  
         , gas_inj_rate_mth    
        ,VALUE_1
        ,VALUE_2
        ,VALUE_3
        ,VALUE_4
        ,VALUE_5
        ,VALUE_6
        ,VALUE_7
        ,VALUE_8
        ,VALUE_9
        ,VALUE_10
        ,value_11 
        ,value_12 
        ,value_13 
        , value_14 
        , value_15 
        , value_16 
        , value_17 
        , value_18 
        , value_19 
        , value_20 
        , value_21 
        , value_22 
        , value_23 
        , value_24 
        , value_25 
        , value_26 
        , value_27 
        ,value_28 
        , value_29 
        , value_30 
        , value_31 
        , value_32 
        , value_33 
        ,value_34 
        , value_35 
        , value_36 
        , value_37 
        , value_38 
        , value_39 
        , value_40 
        , value_41 
        , value_42 
        , value_43 
        , value_44 
        , value_45 
        , value_46 
        , value_47 
        , value_48 
        , value_49 
        , value_50 
        ,TEXT_1
        ,TEXT_2
        ,TEXT_3
        ,TEXT_4
        ,text_5   
        ,text_6   
        ,text_7   
        ,text_8   
        ,text_9   
        ,text_10  
        ,DATE_1
        ,DATE_2
        ,DATE_3
        ,DATE_4
        ,DATE_5        
FROM  PROD_FCTY_FORECAST PFF
WHERE PFF.FCST_SCEN_NO=F.FCST_SCEN_NO
AND CLASS_NAME='PROD_FCTY2_FORECAST';

-- New record will be added in FCST_FCTY_MTH_JN using existing monthly facility class2 forecast records from PROD_FCTY_FORECAST_JN table.
INSERT INTO FCST_FCTY_MTH_JN
 (   JN_OPERATION
    ,JN_ORACLE_USER
    ,JN_DATETIME
    ,JN_NOTES
    ,JN_APPLN
    ,JN_SESSION
    ,EFFECTIVE_DAYTIME
    ,OBJECT_ID
    ,DAYTIME  
    ,class_name
    ,FORECAST_ID
    ,SCENARIO_ID
    ,net_oil_rate
    , gas_rate        
    , cond_rate       
    , water_rate      
    , steam_inj_rate  
    , water_inj_rate  
    , gas_inj_rate    
    ,VALUE_1
    ,VALUE_2
    ,VALUE_3
    ,VALUE_4
    ,VALUE_5
    ,VALUE_6
    ,VALUE_7
    ,VALUE_8
    ,VALUE_9
    ,VALUE_10
    ,value_11 
    ,value_12 
    ,value_13 
    , value_14 
    , value_15 
    , value_16 
    , value_17 
    , value_18 
    , value_19 
    , value_20 
    , value_21 
    , value_22 
    , value_23 
    , value_24 
    , value_25 
    , value_26 
    , value_27 
    ,value_28 
    , value_29 
    , value_30 
    , value_31 
    , value_32 
    , value_33 
    ,value_34 
    , value_35 
    , value_36 
    , value_37 
    , value_38 
    , value_39 
    , value_40 
    , value_41 
    , value_42 
    , value_43 
    , value_44 
    , value_45 
    , value_46 
    , value_47 
    , value_48 
    , value_49 
    , value_50 
    ,TEXT_1
    ,TEXT_2
    ,TEXT_3
    ,TEXT_4
    ,text_5   
    ,text_6   
    ,text_7   
    ,text_8   
    ,text_9   
    ,text_10  
    ,DATE_1
    ,DATE_2
    ,DATE_3
    ,DATE_4
    ,DATE_5        
)
SELECT   
          JN_OPERATION
         ,JN_ORACLE_USER
         ,JN_DATETIME
         ,JN_NOTES
         ,JN_APPLN
         ,JN_SESSION
         ,EFFECTIVE_DAYTIME
         ,OBJECT_ID
         ,DAYTIME
         ,'FCST_FCTY2_MTH_STATUS'
         ,ECDP_OBJECTS.GetObjIDFromCode('FORECAST_GROUP','MIG_FCST_'||F.FCST_SCEN_NO)
         ,ECDP_OBJECTS.GetObjIDFromCode('FORECAST_PROD','MIG_SCN_'||F.FCST_SCEN_NO)
         ,net_oil_rate_mth     
         , gas_rate_mth        
         , cond_rate_mth       
         , water_rate_mth      
         , steam_inj_rate_mth  
         , water_inj_rate_mth  
         , gas_inj_rate_mth    
        ,VALUE_1
        ,VALUE_2
        ,VALUE_3
        ,VALUE_4
        ,VALUE_5
        ,VALUE_6
        ,VALUE_7
        ,VALUE_8
        ,VALUE_9
        ,VALUE_10
        ,value_11 
        ,value_12 
        ,value_13 
        , value_14 
        , value_15 
        , value_16 
        , value_17 
        , value_18 
        , value_19 
        , value_20 
        , value_21 
        , value_22 
        , value_23 
        , value_24 
        , value_25 
        , value_26 
        , value_27 
        ,value_28 
        , value_29 
        , value_30 
        , value_31 
        , value_32 
        , value_33 
        ,value_34 
        , value_35 
        , value_36 
        , value_37 
        , value_38 
        , value_39 
        , value_40 
        , value_41 
        , value_42 
        , value_43 
        , value_44 
        , value_45 
        , value_46 
        , value_47 
        , value_48 
        , value_49 
        , value_50 
        ,TEXT_1
        ,TEXT_2
        ,TEXT_3
        ,TEXT_4
        ,text_5   
        ,text_6   
        ,text_7   
        ,text_8   
        ,text_9   
        ,text_10  
        ,DATE_1
        ,DATE_2
        ,DATE_3
        ,DATE_4
        ,DATE_5        
FROM  PROD_FCTY_FORECAST_JN PFF
WHERE PFF.FCST_SCEN_NO=F.FCST_SCEN_NO
AND CLASS_NAME='PROD_FCTY2_FORECAST';
                    

-- New record will be added in FCST_PRODUNIT_DAY using existing daily production unit forecast records from PROD_PRODUNIT_FORECAST table.                
INSERT INTO FCST_PRODUNIT_DAY
 (   EFFECTIVE_DAYTIME
    ,OBJECT_ID
    ,DAYTIME  
    ,FORECAST_ID
    ,SCENARIO_ID
    ,net_oil_rate          
    ,gas_rate              
    ,cond_rate             
    ,water_rate            
    ,steam_inj_rate        
    ,water_inj_rate        
    ,gas_inj_rate                                           
    ,VALUE_1
    ,VALUE_2
    ,VALUE_3
    ,VALUE_4
    ,VALUE_5
    ,VALUE_6
    ,VALUE_7
    ,VALUE_8
    ,VALUE_9
    ,VALUE_10
    ,value_11 
    ,value_12 
    ,value_13 
    , value_14 
    , value_15 
    , value_16 
    , value_17 
    , value_18 
    , value_19 
    , value_20 
    , value_21 
    , value_22 
    , value_23 
    , value_24 
    , value_25 
    , value_26 
    , value_27 
    ,value_28 
    , value_29 
    , value_30 
    , value_31 
    , value_32 
    , value_33 
    ,value_34 
    , value_35 
    , value_36 
    , value_37 
    , value_38 
    , value_39 
    , value_40 
    , value_41 
    , value_42 
    , value_43 
    , value_44 
    , value_45 
    , value_46 
    , value_47 
    , value_48 
    , value_49 
    , value_50 
    ,TEXT_1
    ,TEXT_2
    ,TEXT_3
    ,TEXT_4
    ,text_5   
    ,text_6   
    ,text_7   
    ,text_8   
    ,text_9   
    ,text_10  
    ,DATE_1
    ,DATE_2
    ,DATE_3
    ,DATE_4
    ,DATE_5        
    ,CREATED_BY
    ,CREATED_DATE    
)
SELECT   
          EFFECTIVE_DAYTIME
         ,OBJECT_ID
         ,DAYTIME
         ,ECDP_OBJECTS.GetObjIDFromCode('FORECAST_GROUP','MIG_FCST_'||F.FCST_SCEN_NO)
         ,ECDP_OBJECTS.GetObjIDFromCode('FORECAST_PROD','MIG_SCN_'||F.FCST_SCEN_NO)
         ,net_oil_rate          
        ,gas_rate              
        ,cond_rate             
        ,water_rate            
        ,steam_inj_rate        
        ,water_inj_rate        
        ,gas_inj_rate                              
        ,VALUE_1
        ,VALUE_2
        ,VALUE_3
        ,VALUE_4
        ,VALUE_5
        ,VALUE_6
        ,VALUE_7
        ,VALUE_8
        ,VALUE_9
        ,VALUE_10
        ,value_11 
        ,value_12 
        ,value_13 
        , value_14 
        , value_15 
        , value_16 
        , value_17 
        , value_18 
        , value_19 
        , value_20 
        , value_21 
        , value_22 
        , value_23 
        , value_24 
        , value_25 
        , value_26 
        , value_27 
        ,value_28 
        , value_29 
        , value_30 
        , value_31 
        , value_32 
        , value_33 
        ,value_34 
        , value_35 
        , value_36 
        , value_37 
        , value_38 
        , value_39 
        , value_40 
        , value_41 
        , value_42 
        , value_43 
        , value_44 
        , value_45 
        , value_46 
        , value_47 
        , value_48 
        , value_49 
        , value_50 
        ,TEXT_1
        ,TEXT_2
        ,TEXT_3
        ,TEXT_4
        ,text_5   
        ,text_6   
        ,text_7   
        ,text_8   
        ,text_9   
        ,text_10  
        ,DATE_1
        ,DATE_2
        ,DATE_3
        ,DATE_4
        ,DATE_5    
        ,CREATED_BY
        ,CREATED_DATE        
FROM  PROD_PRODUNIT_FORECAST PPF
WHERE PPF.FCST_SCEN_NO=F.FCST_SCEN_NO;    

-- New record will be added in FCST_PRODUNIT_DAY_JN using existing daily production unit forecast records from PROD_PRODUNIT_FORECAST_JN table.    
INSERT INTO FCST_PRODUNIT_DAY_JN
 (   JN_OPERATION
    ,JN_ORACLE_USER
    ,JN_DATETIME
    ,JN_NOTES
    ,JN_APPLN
    ,JN_SESSION
    ,EFFECTIVE_DAYTIME
    ,OBJECT_ID
    ,DAYTIME  
    ,FORECAST_ID
    ,SCENARIO_ID
    ,net_oil_rate          
    ,gas_rate              
    ,cond_rate             
    ,water_rate            
    ,steam_inj_rate        
    ,water_inj_rate        
    ,gas_inj_rate                                           
    ,VALUE_1
    ,VALUE_2
    ,VALUE_3
    ,VALUE_4
    ,VALUE_5
    ,VALUE_6
    ,VALUE_7
    ,VALUE_8
    ,VALUE_9
    ,VALUE_10
    ,value_11 
    ,value_12 
    ,value_13 
    , value_14 
    , value_15 
    , value_16 
    , value_17 
    , value_18 
    , value_19 
    , value_20 
    , value_21 
    , value_22 
    , value_23 
    , value_24 
    , value_25 
    , value_26 
    , value_27 
    ,value_28 
    , value_29 
    , value_30 
    , value_31 
    , value_32 
    , value_33 
    ,value_34 
    , value_35 
    , value_36 
    , value_37 
    , value_38 
    , value_39 
    , value_40 
    , value_41 
    , value_42 
    , value_43 
    , value_44 
    , value_45 
    , value_46 
    , value_47 
    , value_48 
    , value_49 
    , value_50 
    ,TEXT_1
    ,TEXT_2
    ,TEXT_3
    ,TEXT_4
    ,text_5   
    ,text_6   
    ,text_7   
    ,text_8   
    ,text_9   
    ,text_10  
    ,DATE_1
    ,DATE_2
    ,DATE_3
    ,DATE_4
    ,DATE_5        
    ,CREATED_BY
    ,CREATED_DATE    
)
SELECT   
          JN_OPERATION
         ,JN_ORACLE_USER
         ,JN_DATETIME
         ,JN_NOTES
         ,JN_APPLN
         ,JN_SESSION
         ,EFFECTIVE_DAYTIME
         ,OBJECT_ID
         ,DAYTIME
         ,ECDP_OBJECTS.GetObjIDFromCode('FORECAST_GROUP','MIG_FCST_'||F.FCST_SCEN_NO)
         ,ECDP_OBJECTS.GetObjIDFromCode('FORECAST_PROD','MIG_SCN_'||F.FCST_SCEN_NO)
         ,net_oil_rate          
        ,gas_rate              
        ,cond_rate             
        ,water_rate            
        ,steam_inj_rate        
        ,water_inj_rate        
        ,gas_inj_rate                              
        ,VALUE_1
        ,VALUE_2
        ,VALUE_3
        ,VALUE_4
        ,VALUE_5
        ,VALUE_6
        ,VALUE_7
        ,VALUE_8
        ,VALUE_9
        ,VALUE_10
        ,value_11 
        ,value_12 
        ,value_13 
        , value_14 
        , value_15 
        , value_16 
        , value_17 
        , value_18 
        , value_19 
        , value_20 
        , value_21 
        , value_22 
        , value_23 
        , value_24 
        , value_25 
        , value_26 
        , value_27 
        ,value_28 
        , value_29 
        , value_30 
        , value_31 
        , value_32 
        , value_33 
        ,value_34 
        , value_35 
        , value_36 
        , value_37 
        , value_38 
        , value_39 
        , value_40 
        , value_41 
        , value_42 
        , value_43 
        , value_44 
        , value_45 
        , value_46 
        , value_47 
        , value_48 
        , value_49 
        , value_50 
        ,TEXT_1
        ,TEXT_2
        ,TEXT_3
        ,TEXT_4
        ,text_5   
        ,text_6   
        ,text_7   
        ,text_8   
        ,text_9   
        ,text_10  
        ,DATE_1
        ,DATE_2
        ,DATE_3
        ,DATE_4
        ,DATE_5    
        ,CREATED_BY
        ,CREATED_DATE        
FROM  PROD_PRODUNIT_FORECAST_JN PPF
WHERE PPF.FCST_SCEN_NO=F.FCST_SCEN_NO;    

-- New record will be added in FCST_PRODUNIT_MTH using existing monthly production unit forecast records from PROD_PRODUNIT_FORECAST table.    
INSERT INTO FCST_PRODUNIT_MTH
 (   EFFECTIVE_DAYTIME
    ,OBJECT_ID
    ,DAYTIME  
    ,FORECAST_ID
    ,SCENARIO_ID
    ,net_oil_rate
    , gas_rate        
    , cond_rate       
    , water_rate      
    , steam_inj_rate  
    , water_inj_rate  
    , gas_inj_rate    
    ,VALUE_1
    ,VALUE_2
    ,VALUE_3
    ,VALUE_4
    ,VALUE_5
    ,VALUE_6
    ,VALUE_7
    ,VALUE_8
    ,VALUE_9
    ,VALUE_10
    ,value_11 
    ,value_12 
    ,value_13 
    , value_14 
    , value_15 
    , value_16 
    , value_17 
    , value_18 
    , value_19 
    , value_20 
    , value_21 
    , value_22 
    , value_23 
    , value_24 
    , value_25 
    , value_26 
    , value_27 
    ,value_28 
    , value_29 
    , value_30 
    , value_31 
    , value_32 
    , value_33 
    ,value_34 
    , value_35 
    , value_36 
    , value_37 
    , value_38 
    , value_39 
    , value_40 
    , value_41 
    , value_42 
    , value_43 
    , value_44 
    , value_45 
    , value_46 
    , value_47 
    , value_48 
    , value_49 
    , value_50 
    ,TEXT_1
    ,TEXT_2
    ,TEXT_3
    ,TEXT_4
    ,text_5   
    ,text_6   
    ,text_7   
    ,text_8   
    ,text_9   
    ,text_10  
    ,DATE_1
    ,DATE_2
    ,DATE_3
    ,DATE_4
    ,DATE_5        
    ,CREATED_BY
    ,CREATED_DATE    
)
SELECT   
          EFFECTIVE_DAYTIME
         ,OBJECT_ID
         ,DAYTIME
         ,ECDP_OBJECTS.GetObjIDFromCode('FORECAST_GROUP','MIG_FCST_'||F.FCST_SCEN_NO)
         ,ECDP_OBJECTS.GetObjIDFromCode('FORECAST_PROD','MIG_SCN_'||F.FCST_SCEN_NO)
         ,net_oil_rate_mth     
         , gas_rate_mth        
         , cond_rate_mth       
         , water_rate_mth      
         , steam_inj_rate_mth  
         , water_inj_rate_mth  
         , gas_inj_rate_mth    
        ,VALUE_1
        ,VALUE_2
        ,VALUE_3
        ,VALUE_4
        ,VALUE_5
        ,VALUE_6
        ,VALUE_7
        ,VALUE_8
        ,VALUE_9
        ,VALUE_10
        ,value_11 
        ,value_12 
        ,value_13 
        , value_14 
        , value_15 
        , value_16 
        , value_17 
        , value_18 
        , value_19 
        , value_20 
        , value_21 
        , value_22 
        , value_23 
        , value_24 
        , value_25 
        , value_26 
        , value_27 
        ,value_28 
        , value_29 
        , value_30 
        , value_31 
        , value_32 
        , value_33 
        ,value_34 
        , value_35 
        , value_36 
        , value_37 
        , value_38 
        , value_39 
        , value_40 
        , value_41 
        , value_42 
        , value_43 
        , value_44 
        , value_45 
        , value_46 
        , value_47 
        , value_48 
        , value_49 
        , value_50 
        ,TEXT_1
        ,TEXT_2
        ,TEXT_3
        ,TEXT_4
        ,text_5   
        ,text_6   
        ,text_7   
        ,text_8   
        ,text_9   
        ,text_10  
        ,DATE_1
        ,DATE_2
        ,DATE_3
        ,DATE_4
        ,DATE_5        
        ,CREATED_BY
        ,CREATED_DATE    
FROM  PROD_PRODUNIT_FORECAST PPF
WHERE PPF.FCST_SCEN_NO=F.FCST_SCEN_NO;    

-- New record will be added in FCST_PRODUNIT_MTH_JN using existing monthly production unit forecast records from PROD_PRODUNIT_FORECAST_JN table.    
INSERT INTO FCST_PRODUNIT_MTH_JN
 (   JN_OPERATION
    ,JN_ORACLE_USER
    ,JN_DATETIME
    ,JN_NOTES
    ,JN_APPLN
    ,JN_SESSION
    ,EFFECTIVE_DAYTIME
    ,OBJECT_ID
    ,DAYTIME  
    ,FORECAST_ID
    ,SCENARIO_ID
    ,net_oil_rate
    , gas_rate        
    , cond_rate       
    , water_rate      
    , steam_inj_rate  
    , water_inj_rate  
    , gas_inj_rate    
    ,VALUE_1
    ,VALUE_2
    ,VALUE_3
    ,VALUE_4
    ,VALUE_5
    ,VALUE_6
    ,VALUE_7
    ,VALUE_8
    ,VALUE_9
    ,VALUE_10
    ,value_11 
    ,value_12 
    ,value_13 
    , value_14 
    , value_15 
    , value_16 
    , value_17 
    , value_18 
    , value_19 
    , value_20 
    , value_21 
    , value_22 
    , value_23 
    , value_24 
    , value_25 
    , value_26 
    , value_27 
    ,value_28 
    , value_29 
    , value_30 
    , value_31 
    , value_32 
    , value_33 
    ,value_34 
    , value_35 
    , value_36 
    , value_37 
    , value_38 
    , value_39 
    , value_40 
    , value_41 
    , value_42 
    , value_43 
    , value_44 
    , value_45 
    , value_46 
    , value_47 
    , value_48 
    , value_49 
    , value_50 
    ,TEXT_1
    ,TEXT_2
    ,TEXT_3
    ,TEXT_4
    ,text_5   
    ,text_6   
    ,text_7   
    ,text_8   
    ,text_9   
    ,text_10  
    ,DATE_1
    ,DATE_2
    ,DATE_3
    ,DATE_4
    ,DATE_5        
    ,CREATED_BY
    ,CREATED_DATE    
)
SELECT   
          JN_OPERATION
         ,JN_ORACLE_USER
         ,JN_DATETIME
         ,JN_NOTES
         ,JN_APPLN
         ,JN_SESSION
         ,EFFECTIVE_DAYTIME
         ,OBJECT_ID
         ,DAYTIME
         ,ECDP_OBJECTS.GetObjIDFromCode('FORECAST_GROUP','MIG_FCST_'||F.FCST_SCEN_NO)
         ,ECDP_OBJECTS.GetObjIDFromCode('FORECAST_PROD','MIG_SCN_'||F.FCST_SCEN_NO)
         ,net_oil_rate_mth     
         , gas_rate_mth        
         , cond_rate_mth       
         , water_rate_mth      
         , steam_inj_rate_mth  
         , water_inj_rate_mth  
         , gas_inj_rate_mth    
        ,VALUE_1
        ,VALUE_2
        ,VALUE_3
        ,VALUE_4
        ,VALUE_5
        ,VALUE_6
        ,VALUE_7
        ,VALUE_8
        ,VALUE_9
        ,VALUE_10
        ,value_11 
        ,value_12 
        ,value_13 
        , value_14 
        , value_15 
        , value_16 
        , value_17 
        , value_18 
        , value_19 
        , value_20 
        , value_21 
        , value_22 
        , value_23 
        , value_24 
        , value_25 
        , value_26 
        , value_27 
        ,value_28 
        , value_29 
        , value_30 
        , value_31 
        , value_32 
        , value_33 
        ,value_34 
        , value_35 
        , value_36 
        , value_37 
        , value_38 
        , value_39 
        , value_40 
        , value_41 
        , value_42 
        , value_43 
        , value_44 
        , value_45 
        , value_46 
        , value_47 
        , value_48 
        , value_49 
        , value_50 
        ,TEXT_1
        ,TEXT_2
        ,TEXT_3
        ,TEXT_4
        ,text_5   
        ,text_6   
        ,text_7   
        ,text_8   
        ,text_9   
        ,text_10  
        ,DATE_1
        ,DATE_2
        ,DATE_3
        ,DATE_4
        ,DATE_5        
        ,CREATED_BY
        ,CREATED_DATE    
FROM  PROD_PRODUNIT_FORECAST_JN PPF
WHERE PPF.FCST_SCEN_NO=F.FCST_SCEN_NO;    

-- New record will be added in FCST_SUB_PRODUNIT_DAY using existing daily production sub unit forecast records from PROD_SUB_PRODUNIT_FCST table.    
INSERT INTO FCST_SUB_PRODUNIT_DAY
 (   EFFECTIVE_DAYTIME
    ,OBJECT_ID
    ,DAYTIME  
    ,FORECAST_ID
    ,SCENARIO_ID
    ,net_oil_rate          
    ,gas_rate              
    ,cond_rate             
    ,water_rate            
    ,steam_inj_rate        
    ,water_inj_rate        
    ,gas_inj_rate                                           
    ,VALUE_1
    ,VALUE_2
    ,VALUE_3
    ,VALUE_4
    ,VALUE_5
    ,VALUE_6
    ,VALUE_7
    ,VALUE_8
    ,VALUE_9
    ,VALUE_10
    ,value_11 
    ,value_12 
    ,value_13 
    , value_14 
    , value_15 
    , value_16 
    , value_17 
    , value_18 
    , value_19 
    , value_20 
    , value_21 
    , value_22 
    , value_23 
    , value_24 
    , value_25 
    , value_26 
    , value_27 
    ,value_28 
    , value_29 
    , value_30 
    , value_31 
    , value_32 
    , value_33 
    ,value_34 
    , value_35 
    , value_36 
    , value_37 
    , value_38 
    , value_39 
    , value_40 
    , value_41 
    , value_42 
    , value_43 
    , value_44 
    , value_45 
    , value_46 
    , value_47 
    , value_48 
    , value_49 
    , value_50 
    ,TEXT_1
    ,TEXT_2
    ,TEXT_3
    ,TEXT_4
    ,text_5   
    ,text_6   
    ,text_7   
    ,text_8   
    ,text_9   
    ,text_10  
    ,DATE_1
    ,DATE_2
    ,DATE_3
    ,DATE_4
    ,DATE_5        
)
SELECT   
          EFFECTIVE_DAYTIME
         ,OBJECT_ID
         ,DAYTIME
         ,ECDP_OBJECTS.GetObjIDFromCode('FORECAST_GROUP','MIG_FCST_'||F.FCST_SCEN_NO)
         ,ECDP_OBJECTS.GetObjIDFromCode('FORECAST_PROD','MIG_SCN_'||F.FCST_SCEN_NO)
         ,net_oil_rate          
        ,gas_rate              
        ,cond_rate             
        ,water_rate            
        ,steam_inj_rate        
        ,water_inj_rate        
        ,gas_inj_rate                              
        ,VALUE_1
        ,VALUE_2
        ,VALUE_3
        ,VALUE_4
        ,VALUE_5
        ,VALUE_6
        ,VALUE_7
        ,VALUE_8
        ,VALUE_9
        ,VALUE_10
        ,value_11 
        ,value_12 
        ,value_13 
        , value_14 
        , value_15 
        , value_16 
        , value_17 
        , value_18 
        , value_19 
        , value_20 
        , value_21 
        , value_22 
        , value_23 
        , value_24 
        , value_25 
        , value_26 
        , value_27 
        ,value_28 
        , value_29 
        , value_30 
        , value_31 
        , value_32 
        , value_33 
        ,value_34 
        , value_35 
        , value_36 
        , value_37 
        , value_38 
        , value_39 
        , value_40 
        , value_41 
        , value_42 
        , value_43 
        , value_44 
        , value_45 
        , value_46 
        , value_47 
        , value_48 
        , value_49 
        , value_50 
        ,TEXT_1
        ,TEXT_2
        ,TEXT_3
        ,TEXT_4
        ,text_5   
        ,text_6   
        ,text_7   
        ,text_8   
        ,text_9   
        ,text_10  
        ,DATE_1
        ,DATE_2
        ,DATE_3
        ,DATE_4
        ,DATE_5        
FROM  PROD_SUB_PRODUNIT_FORECAST PSPF
WHERE PSPF.FCST_SCEN_NO=F.FCST_SCEN_NO;    

-- New record will be added in FCST_SUB_PRODUNIT_DAY_JN using existing daily production sub unit forecast records from PROD_SUB_PRODUNIT_FCST_JN table.    
INSERT INTO FCST_SUB_PRODUNIT_DAY_JN
 (   JN_OPERATION
    ,JN_ORACLE_USER
    ,JN_DATETIME
    ,JN_NOTES
    ,JN_APPLN
    ,JN_SESSION
    ,EFFECTIVE_DAYTIME
    ,OBJECT_ID
    ,DAYTIME  
    ,FORECAST_ID
    ,SCENARIO_ID
    ,net_oil_rate          
    ,gas_rate              
    ,cond_rate             
    ,water_rate            
    ,steam_inj_rate        
    ,water_inj_rate        
    ,gas_inj_rate                                           
    ,VALUE_1
    ,VALUE_2
    ,VALUE_3
    ,VALUE_4
    ,VALUE_5
    ,VALUE_6
    ,VALUE_7
    ,VALUE_8
    ,VALUE_9
    ,VALUE_10
    ,value_11 
    ,value_12 
    ,value_13 
    , value_14 
    , value_15 
    , value_16 
    , value_17 
    , value_18 
    , value_19 
    , value_20 
    , value_21 
    , value_22 
    , value_23 
    , value_24 
    , value_25 
    , value_26 
    , value_27 
    ,value_28 
    , value_29 
    , value_30 
    , value_31 
    , value_32 
    , value_33 
    ,value_34 
    , value_35 
    , value_36 
    , value_37 
    , value_38 
    , value_39 
    , value_40 
    , value_41 
    , value_42 
    , value_43 
    , value_44 
    , value_45 
    , value_46 
    , value_47 
    , value_48 
    , value_49 
    , value_50 
    ,TEXT_1
    ,TEXT_2
    ,TEXT_3
    ,TEXT_4
    ,text_5   
    ,text_6   
    ,text_7   
    ,text_8   
    ,text_9   
    ,text_10  
    ,DATE_1
    ,DATE_2
    ,DATE_3
    ,DATE_4
    ,DATE_5        
)
SELECT   
          JN_OPERATION
         ,JN_ORACLE_USER
         ,JN_DATETIME
         ,JN_NOTES
         ,JN_APPLN
         ,JN_SESSION
         ,EFFECTIVE_DAYTIME
         ,OBJECT_ID
         ,DAYTIME
         ,ECDP_OBJECTS.GetObjIDFromCode('FORECAST_GROUP','MIG_FCST_'||F.FCST_SCEN_NO)
         ,ECDP_OBJECTS.GetObjIDFromCode('FORECAST_PROD','MIG_SCN_'||F.FCST_SCEN_NO)
         ,net_oil_rate          
        ,gas_rate              
        ,cond_rate             
        ,water_rate            
        ,steam_inj_rate        
        ,water_inj_rate        
        ,gas_inj_rate                              
        ,VALUE_1
        ,VALUE_2
        ,VALUE_3
        ,VALUE_4
        ,VALUE_5
        ,VALUE_6
        ,VALUE_7
        ,VALUE_8
        ,VALUE_9
        ,VALUE_10
        ,value_11 
        ,value_12 
        ,value_13 
        , value_14 
        , value_15 
        , value_16 
        , value_17 
        , value_18 
        , value_19 
        , value_20 
        , value_21 
        , value_22 
        , value_23 
        , value_24 
        , value_25 
        , value_26 
        , value_27 
        ,value_28 
        , value_29 
        , value_30 
        , value_31 
        , value_32 
        , value_33 
        ,value_34 
        , value_35 
        , value_36 
        , value_37 
        , value_38 
        , value_39 
        , value_40 
        , value_41 
        , value_42 
        , value_43 
        , value_44 
        , value_45 
        , value_46 
        , value_47 
        , value_48 
        , value_49 
        , value_50 
        ,TEXT_1
        ,TEXT_2
        ,TEXT_3
        ,TEXT_4
        ,text_5   
        ,text_6   
        ,text_7   
        ,text_8   
        ,text_9   
        ,text_10  
        ,DATE_1
        ,DATE_2
        ,DATE_3
        ,DATE_4
        ,DATE_5        
FROM  PROD_SUB_PRODUNIT_FORECAST_JN PSPF
WHERE PSPF.FCST_SCEN_NO=F.FCST_SCEN_NO;    

-- New record will be added in FCST_SUB_PRODUNIT_MTH using existing monthly production sub unit forecast records from PROD_SUB_PRODUNIT_FCST table.    
INSERT INTO FCST_SUB_PRODUNIT_MTH
 (   EFFECTIVE_DAYTIME
    ,OBJECT_ID
    ,DAYTIME  
    ,FORECAST_ID
    ,SCENARIO_ID
    ,net_oil_rate
    , gas_rate        
    , cond_rate       
    , water_rate      
    , steam_inj_rate  
    , water_inj_rate  
    , gas_inj_rate    
    ,VALUE_1
    ,VALUE_2
    ,VALUE_3
    ,VALUE_4
    ,VALUE_5
    ,VALUE_6
    ,VALUE_7
    ,VALUE_8
    ,VALUE_9
    ,VALUE_10
    ,value_11 
    ,value_12 
    ,value_13 
    , value_14 
    , value_15 
    , value_16 
    , value_17 
    , value_18 
    , value_19 
    , value_20 
    , value_21 
    , value_22 
    , value_23 
    , value_24 
    , value_25 
    , value_26 
    , value_27 
    ,value_28 
    , value_29 
    , value_30 
    , value_31 
    , value_32 
    , value_33 
    ,value_34 
    , value_35 
    , value_36 
    , value_37 
    , value_38 
    , value_39 
    , value_40 
    , value_41 
    , value_42 
    , value_43 
    , value_44 
    , value_45 
    , value_46 
    , value_47 
    , value_48 
    , value_49 
    , value_50 
    ,TEXT_1
    ,TEXT_2
    ,TEXT_3
    ,TEXT_4
    ,text_5   
    ,text_6   
    ,text_7   
    ,text_8   
    ,text_9   
    ,text_10  
    ,DATE_1
    ,DATE_2
    ,DATE_3
    ,DATE_4
    ,DATE_5        
)
SELECT   
          EFFECTIVE_DAYTIME
         ,OBJECT_ID
         ,DAYTIME
         ,ECDP_OBJECTS.GetObjIDFromCode('FORECAST_GROUP','MIG_FCST_'||F.FCST_SCEN_NO)
         ,ECDP_OBJECTS.GetObjIDFromCode('FORECAST_PROD','MIG_SCN_'||F.FCST_SCEN_NO)
         ,net_oil_rate_mth     
         , gas_rate_mth        
         , cond_rate_mth       
         , water_rate_mth      
         , steam_inj_rate_mth  
         , water_inj_rate_mth  
         , gas_inj_rate_mth    
        ,VALUE_1
        ,VALUE_2
        ,VALUE_3
        ,VALUE_4
        ,VALUE_5
        ,VALUE_6
        ,VALUE_7
        ,VALUE_8
        ,VALUE_9
        ,VALUE_10
        ,value_11 
        ,value_12 
        ,value_13 
        , value_14 
        , value_15 
        , value_16 
        , value_17 
        , value_18 
        , value_19 
        , value_20 
        , value_21 
        , value_22 
        , value_23 
        , value_24 
        , value_25 
        , value_26 
        , value_27 
        ,value_28 
        , value_29 
        , value_30 
        , value_31 
        , value_32 
        , value_33 
        ,value_34 
        , value_35 
        , value_36 
        , value_37 
        , value_38 
        , value_39 
        , value_40 
        , value_41 
        , value_42 
        , value_43 
        , value_44 
        , value_45 
        , value_46 
        , value_47 
        , value_48 
        , value_49 
        , value_50 
        ,TEXT_1
        ,TEXT_2
        ,TEXT_3
        ,TEXT_4
        ,text_5   
        ,text_6   
        ,text_7   
        ,text_8   
        ,text_9   
        ,text_10  
        ,DATE_1
        ,DATE_2
        ,DATE_3
        ,DATE_4
        ,DATE_5        
FROM  PROD_SUB_PRODUNIT_FORECAST PSPF
WHERE PSPF.FCST_SCEN_NO=F.FCST_SCEN_NO;    

-- New record will be added in FCST_SUB_PRODUNIT_MTH_JN using existing monthly production sub unit forecast records from PROD_SUB_PRODUNIT_FCST_JN table.    
INSERT INTO FCST_SUB_PRODUNIT_MTH_JN
 (   JN_OPERATION
    ,JN_ORACLE_USER
    ,JN_DATETIME
    ,JN_NOTES
    ,JN_APPLN
    ,JN_SESSION
    ,EFFECTIVE_DAYTIME
    ,OBJECT_ID
    ,DAYTIME  
    ,FORECAST_ID
    ,SCENARIO_ID
    ,net_oil_rate
    , gas_rate        
    , cond_rate       
    , water_rate      
    , steam_inj_rate  
    , water_inj_rate  
    , gas_inj_rate    
    ,VALUE_1
    ,VALUE_2
    ,VALUE_3
    ,VALUE_4
    ,VALUE_5
    ,VALUE_6
    ,VALUE_7
    ,VALUE_8
    ,VALUE_9
    ,VALUE_10
    ,value_11 
    ,value_12 
    ,value_13 
    , value_14 
    , value_15 
    , value_16 
    , value_17 
    , value_18 
    , value_19 
    , value_20 
    , value_21 
    , value_22 
    , value_23 
    , value_24 
    , value_25 
    , value_26 
    , value_27 
    ,value_28 
    , value_29 
    , value_30 
    , value_31 
    , value_32 
    , value_33 
    ,value_34 
    , value_35 
    , value_36 
    , value_37 
    , value_38 
    , value_39 
    , value_40 
    , value_41 
    , value_42 
    , value_43 
    , value_44 
    , value_45 
    , value_46 
    , value_47 
    , value_48 
    , value_49 
    , value_50 
    ,TEXT_1
    ,TEXT_2
    ,TEXT_3
    ,TEXT_4
    ,text_5   
    ,text_6   
    ,text_7   
    ,text_8   
    ,text_9   
    ,text_10  
    ,DATE_1
    ,DATE_2
    ,DATE_3
    ,DATE_4
    ,DATE_5        
)
SELECT   
          JN_OPERATION
         ,JN_ORACLE_USER
         ,JN_DATETIME
         ,JN_NOTES
         ,JN_APPLN
         ,JN_SESSION
         ,EFFECTIVE_DAYTIME
         ,OBJECT_ID
         ,DAYTIME
         ,ECDP_OBJECTS.GetObjIDFromCode('FORECAST_GROUP','MIG_FCST_'||F.FCST_SCEN_NO)
         ,ECDP_OBJECTS.GetObjIDFromCode('FORECAST_PROD','MIG_SCN_'||F.FCST_SCEN_NO)
         ,net_oil_rate_mth     
         , gas_rate_mth        
         , cond_rate_mth       
         , water_rate_mth      
         , steam_inj_rate_mth  
         , water_inj_rate_mth  
         , gas_inj_rate_mth    
        ,VALUE_1
        ,VALUE_2
        ,VALUE_3
        ,VALUE_4
        ,VALUE_5
        ,VALUE_6
        ,VALUE_7
        ,VALUE_8
        ,VALUE_9
        ,VALUE_10
        ,value_11 
        ,value_12 
        ,value_13 
        , value_14 
        , value_15 
        , value_16 
        , value_17 
        , value_18 
        , value_19 
        , value_20 
        , value_21 
        , value_22 
        , value_23 
        , value_24 
        , value_25 
        , value_26 
        , value_27 
        ,value_28 
        , value_29 
        , value_30 
        , value_31 
        , value_32 
        , value_33 
        ,value_34 
        , value_35 
        , value_36 
        , value_37 
        , value_38 
        , value_39 
        , value_40 
        , value_41 
        , value_42 
        , value_43 
        , value_44 
        , value_45 
        , value_46 
        , value_47 
        , value_48 
        , value_49 
        , value_50 
        ,TEXT_1
        ,TEXT_2
        ,TEXT_3
        ,TEXT_4
        ,text_5   
        ,text_6   
        ,text_7   
        ,text_8   
        ,text_9   
        ,text_10  
        ,DATE_1
        ,DATE_2
        ,DATE_3
        ,DATE_4
        ,DATE_5        
FROM  PROD_SUB_PRODUNIT_FORECAST_JN PSPF
WHERE PSPF.FCST_SCEN_NO=F.FCST_SCEN_NO;    

-- New record will be added in FCST_AREA_DAY using existing daily area forecast records from PROD_AREA_FORECAST table.    
INSERT INTO FCST_AREA_DAY
 (   EFFECTIVE_DAYTIME
    ,OBJECT_ID
    ,DAYTIME  
    ,FORECAST_ID
    ,SCENARIO_ID
    ,net_oil_rate          
    ,gas_rate              
    ,cond_rate             
    ,water_rate            
    ,steam_inj_rate        
    ,water_inj_rate        
    ,gas_inj_rate                                           
    ,VALUE_1
    ,VALUE_2
    ,VALUE_3
    ,VALUE_4
    ,VALUE_5
    ,VALUE_6
    ,VALUE_7
    ,VALUE_8
    ,VALUE_9
    ,VALUE_10
    ,value_11 
    ,value_12 
    ,value_13 
    , value_14 
    , value_15 
    , value_16 
    , value_17 
    , value_18 
    , value_19 
    , value_20 
    , value_21 
    , value_22 
    , value_23 
    , value_24 
    , value_25 
    , value_26 
    , value_27 
    ,value_28 
    , value_29 
    , value_30 
    , value_31 
    , value_32 
    , value_33 
    ,value_34 
    , value_35 
    , value_36 
    , value_37 
    , value_38 
    , value_39 
    , value_40 
    , value_41 
    , value_42 
    , value_43 
    , value_44 
    , value_45 
    , value_46 
    , value_47 
    , value_48 
    , value_49 
    , value_50 
    ,TEXT_1
    ,TEXT_2
    ,TEXT_3
    ,TEXT_4
    ,text_5   
    ,text_6   
    ,text_7   
    ,text_8   
    ,text_9   
    ,text_10  
    ,DATE_1
    ,DATE_2
    ,DATE_3
    ,DATE_4
    ,DATE_5        
    ,CREATED_BY
    ,CREATED_DATE
)
SELECT   
          EFFECTIVE_DAYTIME
         ,OBJECT_ID
         ,DAYTIME
         ,ECDP_OBJECTS.GetObjIDFromCode('FORECAST_GROUP','MIG_FCST_'||F.FCST_SCEN_NO)
         ,ECDP_OBJECTS.GetObjIDFromCode('FORECAST_PROD','MIG_SCN_'||F.FCST_SCEN_NO)
         ,net_oil_rate          
        ,gas_rate              
        ,cond_rate             
        ,water_rate            
        ,steam_inj_rate        
        ,water_inj_rate        
        ,gas_inj_rate                              
        ,VALUE_1
        ,VALUE_2
        ,VALUE_3
        ,VALUE_4
        ,VALUE_5
        ,VALUE_6
        ,VALUE_7
        ,VALUE_8
        ,VALUE_9
        ,VALUE_10
        ,value_11 
        ,value_12 
        ,value_13 
        , value_14 
        , value_15 
        , value_16 
        , value_17 
        , value_18 
        , value_19 
        , value_20 
        , value_21 
        , value_22 
        , value_23 
        , value_24 
        , value_25 
        , value_26 
        , value_27 
        ,value_28 
        , value_29 
        , value_30 
        , value_31 
        , value_32 
        , value_33 
        ,value_34 
        , value_35 
        , value_36 
        , value_37 
        , value_38 
        , value_39 
        , value_40 
        , value_41 
        , value_42 
        , value_43 
        , value_44 
        , value_45 
        , value_46 
        , value_47 
        , value_48 
        , value_49 
        , value_50 
        ,TEXT_1
        ,TEXT_2
        ,TEXT_3
        ,TEXT_4
        ,text_5   
        ,text_6   
        ,text_7   
        ,text_8   
        ,text_9   
        ,text_10  
        ,DATE_1
        ,DATE_2
        ,DATE_3
        ,DATE_4
        ,DATE_5        
        ,CREATED_BY
        ,CREATED_DATE
FROM  PROD_AREA_FORECAST PAF
WHERE PAF.FCST_SCEN_NO=F.FCST_SCEN_NO;    

-- New record will be added in FCST_AREA_DAY_JN using existing daily area forecast records from PROD_AREA_FORECAST_JN table.    
INSERT INTO FCST_AREA_DAY_JN
 (   JN_OPERATION
    ,JN_ORACLE_USER
    ,JN_DATETIME
    ,JN_NOTES
    ,JN_APPLN
    ,JN_SESSION
    ,EFFECTIVE_DAYTIME
    ,OBJECT_ID
    ,DAYTIME  
    ,FORECAST_ID
    ,SCENARIO_ID
    ,net_oil_rate          
    ,gas_rate              
    ,cond_rate             
    ,water_rate            
    ,steam_inj_rate        
    ,water_inj_rate        
    ,gas_inj_rate                                           
    ,VALUE_1
    ,VALUE_2
    ,VALUE_3
    ,VALUE_4
    ,VALUE_5
    ,VALUE_6
    ,VALUE_7
    ,VALUE_8
    ,VALUE_9
    ,VALUE_10
    ,value_11 
    ,value_12 
    ,value_13 
    , value_14 
    , value_15 
    , value_16 
    , value_17 
    , value_18 
    , value_19 
    , value_20 
    , value_21 
    , value_22 
    , value_23 
    , value_24 
    , value_25 
    , value_26 
    , value_27 
    ,value_28 
    , value_29 
    , value_30 
    , value_31 
    , value_32 
    , value_33 
    ,value_34 
    , value_35 
    , value_36 
    , value_37 
    , value_38 
    , value_39 
    , value_40 
    , value_41 
    , value_42 
    , value_43 
    , value_44 
    , value_45 
    , value_46 
    , value_47 
    , value_48 
    , value_49 
    , value_50 
    ,TEXT_1
    ,TEXT_2
    ,TEXT_3
    ,TEXT_4
    ,text_5   
    ,text_6   
    ,text_7   
    ,text_8   
    ,text_9   
    ,text_10  
    ,DATE_1
    ,DATE_2
    ,DATE_3
    ,DATE_4
    ,DATE_5        
    ,CREATED_BY
    ,CREATED_DATE
)
SELECT   
          JN_OPERATION
         ,JN_ORACLE_USER
         ,JN_DATETIME
         ,JN_NOTES
         ,JN_APPLN
         ,JN_SESSION
         ,EFFECTIVE_DAYTIME
         ,OBJECT_ID
         ,DAYTIME
         ,ECDP_OBJECTS.GetObjIDFromCode('FORECAST_GROUP','MIG_FCST_'||F.FCST_SCEN_NO)
         ,ECDP_OBJECTS.GetObjIDFromCode('FORECAST_PROD','MIG_SCN_'||F.FCST_SCEN_NO)
         ,net_oil_rate          
        ,gas_rate              
        ,cond_rate             
        ,water_rate            
        ,steam_inj_rate        
        ,water_inj_rate        
        ,gas_inj_rate                              
        ,VALUE_1
        ,VALUE_2
        ,VALUE_3
        ,VALUE_4
        ,VALUE_5
        ,VALUE_6
        ,VALUE_7
        ,VALUE_8
        ,VALUE_9
        ,VALUE_10
        ,value_11 
        ,value_12 
        ,value_13 
        , value_14 
        , value_15 
        , value_16 
        , value_17 
        , value_18 
        , value_19 
        , value_20 
        , value_21 
        , value_22 
        , value_23 
        , value_24 
        , value_25 
        , value_26 
        , value_27 
        ,value_28 
        , value_29 
        , value_30 
        , value_31 
        , value_32 
        , value_33 
        ,value_34 
        , value_35 
        , value_36 
        , value_37 
        , value_38 
        , value_39 
        , value_40 
        , value_41 
        , value_42 
        , value_43 
        , value_44 
        , value_45 
        , value_46 
        , value_47 
        , value_48 
        , value_49 
        , value_50 
        ,TEXT_1
        ,TEXT_2
        ,TEXT_3
        ,TEXT_4
        ,text_5   
        ,text_6   
        ,text_7   
        ,text_8   
        ,text_9   
        ,text_10  
        ,DATE_1
        ,DATE_2
        ,DATE_3
        ,DATE_4
        ,DATE_5        
        ,CREATED_BY
        ,CREATED_DATE
FROM  PROD_AREA_FORECAST_JN PAF
WHERE PAF.FCST_SCEN_NO=F.FCST_SCEN_NO;    

-- New record will be added in FCST_AREA_MTH using existing monthly area forecast records from PROD_AREA_FORECAST table.    
INSERT INTO FCST_AREA_MTH
 (   EFFECTIVE_DAYTIME
    ,OBJECT_ID
    ,DAYTIME  
    ,FORECAST_ID
    ,SCENARIO_ID
    ,net_oil_rate
    , gas_rate        
    , cond_rate       
    , water_rate      
    , steam_inj_rate  
    , water_inj_rate  
    , gas_inj_rate    
    ,VALUE_1
    ,VALUE_2
    ,VALUE_3
    ,VALUE_4
    ,VALUE_5
    ,VALUE_6
    ,VALUE_7
    ,VALUE_8
    ,VALUE_9
    ,VALUE_10
    ,value_11 
    ,value_12 
    ,value_13 
    , value_14 
    , value_15 
    , value_16 
    , value_17 
    , value_18 
    , value_19 
    , value_20 
    , value_21 
    , value_22 
    , value_23 
    , value_24 
    , value_25 
    , value_26 
    , value_27 
    ,value_28 
    , value_29 
    , value_30 
    , value_31 
    , value_32 
    , value_33 
    ,value_34 
    , value_35 
    , value_36 
    , value_37 
    , value_38 
    , value_39 
    , value_40 
    , value_41 
    , value_42 
    , value_43 
    , value_44 
    , value_45 
    , value_46 
    , value_47 
    , value_48 
    , value_49 
    , value_50 
    ,TEXT_1
    ,TEXT_2
    ,TEXT_3
    ,TEXT_4
    ,text_5   
    ,text_6   
    ,text_7   
    ,text_8   
    ,text_9   
    ,text_10  
    ,DATE_1
    ,DATE_2
    ,DATE_3
    ,DATE_4
    ,DATE_5        
    ,CREATED_BY
    ,CREATED_DATE
)
SELECT   
          EFFECTIVE_DAYTIME
         ,OBJECT_ID
         ,DAYTIME
         ,ECDP_OBJECTS.GetObjIDFromCode('FORECAST_GROUP','MIG_FCST_'||F.FCST_SCEN_NO)
         ,ECDP_OBJECTS.GetObjIDFromCode('FORECAST_PROD','MIG_SCN_'||F.FCST_SCEN_NO)
         ,net_oil_rate_mth     
         , gas_rate_mth        
         , cond_rate_mth       
         , water_rate_mth      
         , steam_inj_rate_mth  
         , water_inj_rate_mth  
         , gas_inj_rate_mth    
        ,VALUE_1
        ,VALUE_2
        ,VALUE_3
        ,VALUE_4
        ,VALUE_5
        ,VALUE_6
        ,VALUE_7
        ,VALUE_8
        ,VALUE_9
        ,VALUE_10
        ,value_11 
        ,value_12 
        ,value_13 
        , value_14 
        , value_15 
        , value_16 
        , value_17 
        , value_18 
        , value_19 
        , value_20 
        , value_21 
        , value_22 
        , value_23 
        , value_24 
        , value_25 
        , value_26 
        , value_27 
        ,value_28 
        , value_29 
        , value_30 
        , value_31 
        , value_32 
        , value_33 
        ,value_34 
        , value_35 
        , value_36 
        , value_37 
        , value_38 
        , value_39 
        , value_40 
        , value_41 
        , value_42 
        , value_43 
        , value_44 
        , value_45 
        , value_46 
        , value_47 
        , value_48 
        , value_49 
        , value_50 
        ,TEXT_1
        ,TEXT_2
        ,TEXT_3
        ,TEXT_4
        ,text_5   
        ,text_6   
        ,text_7   
        ,text_8   
        ,text_9   
        ,text_10  
        ,DATE_1
        ,DATE_2
        ,DATE_3
        ,DATE_4
        ,DATE_5    
        ,CREATED_BY
        ,CREATED_DATE
FROM  PROD_AREA_FORECAST PAF
WHERE PAF.FCST_SCEN_NO=F.FCST_SCEN_NO;    

-- New record will be added in FCST_AREA_MTH_JN using existing monthly area forecast records from PROD_AREA_FORECAST_JN table.
INSERT INTO FCST_AREA_MTH_JN
 (   JN_OPERATION
    ,JN_ORACLE_USER
    ,JN_DATETIME
    ,JN_NOTES
    ,JN_APPLN
    ,JN_SESSION
    ,EFFECTIVE_DAYTIME
    ,OBJECT_ID
    ,DAYTIME  
    ,FORECAST_ID
    ,SCENARIO_ID
    ,net_oil_rate
    , gas_rate        
    , cond_rate       
    , water_rate      
    , steam_inj_rate  
    , water_inj_rate  
    , gas_inj_rate    
    ,VALUE_1
    ,VALUE_2
    ,VALUE_3
    ,VALUE_4
    ,VALUE_5
    ,VALUE_6
    ,VALUE_7
    ,VALUE_8
    ,VALUE_9
    ,VALUE_10
    ,value_11 
    ,value_12 
    ,value_13 
    , value_14 
    , value_15 
    , value_16 
    , value_17 
    , value_18 
    , value_19 
    , value_20 
    , value_21 
    , value_22 
    , value_23 
    , value_24 
    , value_25 
    , value_26 
    , value_27 
    ,value_28 
    , value_29 
    , value_30 
    , value_31 
    , value_32 
    , value_33 
    ,value_34 
    , value_35 
    , value_36 
    , value_37 
    , value_38 
    , value_39 
    , value_40 
    , value_41 
    , value_42 
    , value_43 
    , value_44 
    , value_45 
    , value_46 
    , value_47 
    , value_48 
    , value_49 
    , value_50 
    ,TEXT_1
    ,TEXT_2
    ,TEXT_3
    ,TEXT_4
    ,text_5   
    ,text_6   
    ,text_7   
    ,text_8   
    ,text_9   
    ,text_10  
    ,DATE_1
    ,DATE_2
    ,DATE_3
    ,DATE_4
    ,DATE_5        
    ,CREATED_BY
    ,CREATED_DATE
)
SELECT   
          JN_OPERATION
         ,JN_ORACLE_USER
         ,JN_DATETIME
         ,JN_NOTES
         ,JN_APPLN
         ,JN_SESSION
         ,EFFECTIVE_DAYTIME
         ,OBJECT_ID
         ,DAYTIME
         ,ECDP_OBJECTS.GetObjIDFromCode('FORECAST_GROUP','MIG_FCST_'||F.FCST_SCEN_NO)
         ,ECDP_OBJECTS.GetObjIDFromCode('FORECAST_PROD','MIG_SCN_'||F.FCST_SCEN_NO)
         ,net_oil_rate_mth     
         , gas_rate_mth        
         , cond_rate_mth       
         , water_rate_mth      
         , steam_inj_rate_mth  
         , water_inj_rate_mth  
         , gas_inj_rate_mth    
        ,VALUE_1
        ,VALUE_2
        ,VALUE_3
        ,VALUE_4
        ,VALUE_5
        ,VALUE_6
        ,VALUE_7
        ,VALUE_8
        ,VALUE_9
        ,VALUE_10
        ,value_11 
        ,value_12 
        ,value_13 
        , value_14 
        , value_15 
        , value_16 
        , value_17 
        , value_18 
        , value_19 
        , value_20 
        , value_21 
        , value_22 
        , value_23 
        , value_24 
        , value_25 
        , value_26 
        , value_27 
        ,value_28 
        , value_29 
        , value_30 
        , value_31 
        , value_32 
        , value_33 
        ,value_34 
        , value_35 
        , value_36 
        , value_37 
        , value_38 
        , value_39 
        , value_40 
        , value_41 
        , value_42 
        , value_43 
        , value_44 
        , value_45 
        , value_46 
        , value_47 
        , value_48 
        , value_49 
        , value_50 
        ,TEXT_1
        ,TEXT_2
        ,TEXT_3
        ,TEXT_4
        ,text_5   
        ,text_6   
        ,text_7   
        ,text_8   
        ,text_9   
        ,text_10  
        ,DATE_1
        ,DATE_2
        ,DATE_3
        ,DATE_4
        ,DATE_5    
        ,CREATED_BY
        ,CREATED_DATE
FROM  PROD_AREA_FORECAST_JN PAF
WHERE PAF.FCST_SCEN_NO=F.FCST_SCEN_NO;    


-- New record will be added in FCST_SUB_AREA_DAY using existing daily sub area forecast records from PROD_SUB_AREA_FORECAST table.
INSERT INTO FCST_SUB_AREA_DAY
 (  EFFECTIVE_DAYTIME
    ,OBJECT_ID
    ,DAYTIME  
    ,FORECAST_ID
    ,SCENARIO_ID
    ,net_oil_rate          
    ,gas_rate              
    ,cond_rate             
    ,water_rate            
    ,steam_inj_rate        
    ,water_inj_rate        
    ,gas_inj_rate                                           
    ,VALUE_1
    ,VALUE_2
    ,VALUE_3
    ,VALUE_4
    ,VALUE_5
    ,VALUE_6
    ,VALUE_7
    ,VALUE_8
    ,VALUE_9
    ,VALUE_10
    ,value_11 
    ,value_12 
    ,value_13 
    , value_14 
    , value_15 
    , value_16 
    , value_17 
    , value_18 
    , value_19 
    , value_20 
    , value_21 
    , value_22 
    , value_23 
    , value_24 
    , value_25 
    , value_26 
    , value_27 
    ,value_28 
    , value_29 
    , value_30 
    , value_31 
    , value_32 
    , value_33 
    ,value_34 
    , value_35 
    , value_36 
    , value_37 
    , value_38 
    , value_39 
    , value_40 
    , value_41 
    , value_42 
    , value_43 
    , value_44 
    , value_45 
    , value_46 
    , value_47 
    , value_48 
    , value_49 
    , value_50 
    ,TEXT_1
    ,TEXT_2
    ,TEXT_3
    ,TEXT_4
    ,text_5   
    ,text_6   
    ,text_7   
    ,text_8   
    ,text_9   
    ,text_10  
    ,DATE_1
    ,DATE_2
    ,DATE_3
    ,DATE_4
    ,DATE_5        
)
SELECT   
          EFFECTIVE_DAYTIME
         ,OBJECT_ID
         ,DAYTIME
         ,ECDP_OBJECTS.GetObjIDFromCode('FORECAST_GROUP','MIG_FCST_'||F.FCST_SCEN_NO)
         ,ECDP_OBJECTS.GetObjIDFromCode('FORECAST_PROD','MIG_SCN_'||F.FCST_SCEN_NO)
         ,net_oil_rate          
        ,gas_rate              
        ,cond_rate             
        ,water_rate            
        ,steam_inj_rate        
        ,water_inj_rate        
        ,gas_inj_rate                              
        ,VALUE_1
        ,VALUE_2
        ,VALUE_3
        ,VALUE_4
        ,VALUE_5
        ,VALUE_6
        ,VALUE_7
        ,VALUE_8
        ,VALUE_9
        ,VALUE_10
        ,value_11 
        ,value_12 
        ,value_13 
        , value_14 
        , value_15 
        , value_16 
        , value_17 
        , value_18 
        , value_19 
        , value_20 
        , value_21 
        , value_22 
        , value_23 
        , value_24 
        , value_25 
        , value_26 
        , value_27 
        ,value_28 
        , value_29 
        , value_30 
        , value_31 
        , value_32 
        , value_33 
        ,value_34 
        , value_35 
        , value_36 
        , value_37 
        , value_38 
        , value_39 
        , value_40 
        , value_41 
        , value_42 
        , value_43 
        , value_44 
        , value_45 
        , value_46 
        , value_47 
        , value_48 
        , value_49 
        , value_50 
        ,TEXT_1
        ,TEXT_2
        ,TEXT_3
        ,TEXT_4
        ,text_5   
        ,text_6   
        ,text_7   
        ,text_8   
        ,text_9   
        ,text_10  
        ,DATE_1
        ,DATE_2
        ,DATE_3
        ,DATE_4
        ,DATE_5        
FROM  PROD_SUB_AREA_FORECAST PSAF
WHERE PSAF.FCST_SCEN_NO=F.FCST_SCEN_NO;    

-- New record will be added in FCST_SUB_AREA_DAY_JN using existing daily sub area forecast records from PROD_SUB_AREA_FORECAST_JN table.
INSERT INTO FCST_SUB_AREA_DAY_JN
 (   JN_OPERATION
    ,JN_ORACLE_USER
    ,JN_DATETIME
    ,JN_NOTES
    ,JN_APPLN
    ,JN_SESSION
    ,EFFECTIVE_DAYTIME
    ,OBJECT_ID
    ,DAYTIME  
    ,FORECAST_ID
    ,SCENARIO_ID
    ,net_oil_rate          
    ,gas_rate              
    ,cond_rate             
    ,water_rate            
    ,steam_inj_rate        
    ,water_inj_rate        
    ,gas_inj_rate                                           
    ,VALUE_1
    ,VALUE_2
    ,VALUE_3
    ,VALUE_4
    ,VALUE_5
    ,VALUE_6
    ,VALUE_7
    ,VALUE_8
    ,VALUE_9
    ,VALUE_10
    ,value_11 
    ,value_12 
    ,value_13 
    , value_14 
    , value_15 
    , value_16 
    , value_17 
    , value_18 
    , value_19 
    , value_20 
    , value_21 
    , value_22 
    , value_23 
    , value_24 
    , value_25 
    , value_26 
    , value_27 
    ,value_28 
    , value_29 
    , value_30 
    , value_31 
    , value_32 
    , value_33 
    ,value_34 
    , value_35 
    , value_36 
    , value_37 
    , value_38 
    , value_39 
    , value_40 
    , value_41 
    , value_42 
    , value_43 
    , value_44 
    , value_45 
    , value_46 
    , value_47 
    , value_48 
    , value_49 
    , value_50 
    ,TEXT_1
    ,TEXT_2
    ,TEXT_3
    ,TEXT_4
    ,text_5   
    ,text_6   
    ,text_7   
    ,text_8   
    ,text_9   
    ,text_10  
    ,DATE_1
    ,DATE_2
    ,DATE_3
    ,DATE_4
    ,DATE_5        
)
SELECT   
          JN_OPERATION
         ,JN_ORACLE_USER
         ,JN_DATETIME
         ,JN_NOTES
         ,JN_APPLN
         ,JN_SESSION
         ,EFFECTIVE_DAYTIME
         ,OBJECT_ID
         ,DAYTIME
         ,ECDP_OBJECTS.GetObjIDFromCode('FORECAST_GROUP','MIG_FCST_'||F.FCST_SCEN_NO)
         ,ECDP_OBJECTS.GetObjIDFromCode('FORECAST_PROD','MIG_SCN_'||F.FCST_SCEN_NO)
         ,net_oil_rate          
        ,gas_rate              
        ,cond_rate             
        ,water_rate            
        ,steam_inj_rate        
        ,water_inj_rate        
        ,gas_inj_rate                              
        ,VALUE_1
        ,VALUE_2
        ,VALUE_3
        ,VALUE_4
        ,VALUE_5
        ,VALUE_6
        ,VALUE_7
        ,VALUE_8
        ,VALUE_9
        ,VALUE_10
        ,value_11 
        ,value_12 
        ,value_13 
        , value_14 
        , value_15 
        , value_16 
        , value_17 
        , value_18 
        , value_19 
        , value_20 
        , value_21 
        , value_22 
        , value_23 
        , value_24 
        , value_25 
        , value_26 
        , value_27 
        ,value_28 
        , value_29 
        , value_30 
        , value_31 
        , value_32 
        , value_33 
        ,value_34 
        , value_35 
        , value_36 
        , value_37 
        , value_38 
        , value_39 
        , value_40 
        , value_41 
        , value_42 
        , value_43 
        , value_44 
        , value_45 
        , value_46 
        , value_47 
        , value_48 
        , value_49 
        , value_50 
        ,TEXT_1
        ,TEXT_2
        ,TEXT_3
        ,TEXT_4
        ,text_5   
        ,text_6   
        ,text_7   
        ,text_8   
        ,text_9   
        ,text_10  
        ,DATE_1
        ,DATE_2
        ,DATE_3
        ,DATE_4
        ,DATE_5        
FROM  PROD_SUB_AREA_FORECAST_JN PSAF
WHERE PSAF.FCST_SCEN_NO=F.FCST_SCEN_NO;    

-- New record will be added in FCST_SUB_AREA_MTH using existing monthly sub area forecast records from PROD_SUB_AREA_FORECAST table.
INSERT INTO FCST_SUB_AREA_MTH
 (   EFFECTIVE_DAYTIME
    ,OBJECT_ID
    ,DAYTIME  
    ,FORECAST_ID
    ,SCENARIO_ID
    ,net_oil_rate
    , gas_rate        
    , cond_rate       
    , water_rate      
    , steam_inj_rate  
    , water_inj_rate  
    , gas_inj_rate    
    ,VALUE_1
    ,VALUE_2
    ,VALUE_3
    ,VALUE_4
    ,VALUE_5
    ,VALUE_6
    ,VALUE_7
    ,VALUE_8
    ,VALUE_9
    ,VALUE_10
    ,value_11 
    ,value_12 
    ,value_13 
    , value_14 
    , value_15 
    , value_16 
    , value_17 
    , value_18 
    , value_19 
    , value_20 
    , value_21 
    , value_22 
    , value_23 
    , value_24 
    , value_25 
    , value_26 
    , value_27 
    ,value_28 
    , value_29 
    , value_30 
    , value_31 
    , value_32 
    , value_33 
    ,value_34 
    , value_35 
    , value_36 
    , value_37 
    , value_38 
    , value_39 
    , value_40 
    , value_41 
    , value_42 
    , value_43 
    , value_44 
    , value_45 
    , value_46 
    , value_47 
    , value_48 
    , value_49 
    , value_50 
    ,TEXT_1
    ,TEXT_2
    ,TEXT_3
    ,TEXT_4
    ,text_5   
    ,text_6   
    ,text_7   
    ,text_8   
    ,text_9   
    ,text_10  
    ,DATE_1
    ,DATE_2
    ,DATE_3
    ,DATE_4
    ,DATE_5        
)
SELECT   
         EFFECTIVE_DAYTIME
         ,OBJECT_ID
         ,DAYTIME
         ,ECDP_OBJECTS.GetObjIDFromCode('FORECAST_GROUP','MIG_FCST_'||F.FCST_SCEN_NO)
         ,ECDP_OBJECTS.GetObjIDFromCode('FORECAST_PROD','MIG_SCN_'||F.FCST_SCEN_NO)
         ,net_oil_rate_mth     
         , gas_rate_mth        
         , cond_rate_mth       
         , water_rate_mth      
         , steam_inj_rate_mth  
         , water_inj_rate_mth  
         , gas_inj_rate_mth    
        ,VALUE_1
        ,VALUE_2
        ,VALUE_3
        ,VALUE_4
        ,VALUE_5
        ,VALUE_6
        ,VALUE_7
        ,VALUE_8
        ,VALUE_9
        ,VALUE_10
        ,value_11 
        ,value_12 
        ,value_13 
        , value_14 
        , value_15 
        , value_16 
        , value_17 
        , value_18 
        , value_19 
        , value_20 
        , value_21 
        , value_22 
        , value_23 
        , value_24 
        , value_25 
        , value_26 
        , value_27 
        ,value_28 
        , value_29 
        , value_30 
        , value_31 
        , value_32 
        , value_33 
        ,value_34 
        , value_35 
        , value_36 
        , value_37 
        , value_38 
        , value_39 
        , value_40 
        , value_41 
        , value_42 
        , value_43 
        , value_44 
        , value_45 
        , value_46 
        , value_47 
        , value_48 
        , value_49 
        , value_50 
        ,TEXT_1
        ,TEXT_2
        ,TEXT_3
        ,TEXT_4
        ,text_5   
        ,text_6   
        ,text_7   
        ,text_8   
        ,text_9   
        ,text_10  
        ,DATE_1
        ,DATE_2
        ,DATE_3
        ,DATE_4
        ,DATE_5        
FROM  PROD_SUB_AREA_FORECAST PSAF
WHERE PSAF.FCST_SCEN_NO=F.FCST_SCEN_NO;

-- New record will be added in FCST_SUB_AREA_MTH_JN using existing monthly sub area forecast records from PROD_SUB_AREA_FORECAST_JN table.
INSERT INTO FCST_SUB_AREA_MTH_JN
 (   JN_OPERATION
    ,JN_ORACLE_USER
    ,JN_DATETIME
    ,JN_NOTES
    ,JN_APPLN
    ,JN_SESSION
    ,EFFECTIVE_DAYTIME
    ,OBJECT_ID
    ,DAYTIME  
    ,FORECAST_ID
    ,SCENARIO_ID
    ,net_oil_rate
    , gas_rate        
    , cond_rate       
    , water_rate      
    , steam_inj_rate  
    , water_inj_rate  
    , gas_inj_rate    
    ,VALUE_1
    ,VALUE_2
    ,VALUE_3
    ,VALUE_4
    ,VALUE_5
    ,VALUE_6
    ,VALUE_7
    ,VALUE_8
    ,VALUE_9
    ,VALUE_10
    ,value_11 
    ,value_12 
    ,value_13 
    , value_14 
    , value_15 
    , value_16 
    , value_17 
    , value_18 
    , value_19 
    , value_20 
    , value_21 
    , value_22 
    , value_23 
    , value_24 
    , value_25 
    , value_26 
    , value_27 
    ,value_28 
    , value_29 
    , value_30 
    , value_31 
    , value_32 
    , value_33 
    ,value_34 
    , value_35 
    , value_36 
    , value_37 
    , value_38 
    , value_39 
    , value_40 
    , value_41 
    , value_42 
    , value_43 
    , value_44 
    , value_45 
    , value_46 
    , value_47 
    , value_48 
    , value_49 
    , value_50 
    ,TEXT_1
    ,TEXT_2
    ,TEXT_3
    ,TEXT_4
    ,text_5   
    ,text_6   
    ,text_7   
    ,text_8   
    ,text_9   
    ,text_10  
    ,DATE_1
    ,DATE_2
    ,DATE_3
    ,DATE_4
    ,DATE_5        
)
SELECT   
          JN_OPERATION
         ,JN_ORACLE_USER
         ,JN_DATETIME
         ,JN_NOTES
         ,JN_APPLN
         ,JN_SESSION
         ,EFFECTIVE_DAYTIME
         ,OBJECT_ID
         ,DAYTIME
         ,ECDP_OBJECTS.GetObjIDFromCode('FORECAST_GROUP','MIG_FCST_'||F.FCST_SCEN_NO)
         ,ECDP_OBJECTS.GetObjIDFromCode('FORECAST_PROD','MIG_SCN_'||F.FCST_SCEN_NO)
         ,net_oil_rate_mth     
         , gas_rate_mth        
         , cond_rate_mth       
         , water_rate_mth      
         , steam_inj_rate_mth  
         , water_inj_rate_mth  
         , gas_inj_rate_mth    
        ,VALUE_1
        ,VALUE_2
        ,VALUE_3
        ,VALUE_4
        ,VALUE_5
        ,VALUE_6
        ,VALUE_7
        ,VALUE_8
        ,VALUE_9
        ,VALUE_10
        ,value_11 
        ,value_12 
        ,value_13 
        , value_14 
        , value_15 
        , value_16 
        , value_17 
        , value_18 
        , value_19 
        , value_20 
        , value_21 
        , value_22 
        , value_23 
        , value_24 
        , value_25 
        , value_26 
        , value_27 
        ,value_28 
        , value_29 
        , value_30 
        , value_31 
        , value_32 
        , value_33 
        ,value_34 
        , value_35 
        , value_36 
        , value_37 
        , value_38 
        , value_39 
        , value_40 
        , value_41 
        , value_42 
        , value_43 
        , value_44 
        , value_45 
        , value_46 
        , value_47 
        , value_48 
        , value_49 
        , value_50 
        ,TEXT_1
        ,TEXT_2
        ,TEXT_3
        ,TEXT_4
        ,text_5   
        ,text_6   
        ,text_7   
        ,text_8   
        ,text_9   
        ,text_10  
        ,DATE_1
        ,DATE_2
        ,DATE_3
        ,DATE_4
        ,DATE_5        
FROM  PROD_SUB_AREA_FORECAST_JN PSAF
WHERE PSAF.FCST_SCEN_NO=F.FCST_SCEN_NO;

-- New record will be added in FCST_FIELD_DAY using existing daily field forecast records from PROD_FIELD_FORECAST table.
INSERT INTO FCST_FIELD_DAY
 (   EFFECTIVE_DAYTIME
    ,OBJECT_ID
    ,DAYTIME  
    ,FORECAST_ID
    ,SCENARIO_ID
    ,net_oil_rate          
    ,gas_rate              
    ,cond_rate             
    ,water_rate            
    ,steam_inj_rate        
    ,water_inj_rate        
    ,gas_inj_rate                                           
    ,VALUE_1
    ,VALUE_2
    ,VALUE_3
    ,VALUE_4
    ,VALUE_5
    ,VALUE_6
    ,VALUE_7
    ,VALUE_8
    ,VALUE_9
    ,VALUE_10
    ,value_11 
    ,value_12 
    ,value_13 
    , value_14 
    , value_15 
    , value_16 
    , value_17 
    , value_18 
    , value_19 
    , value_20 
    , value_21 
    , value_22 
    , value_23 
    , value_24 
    , value_25 
    , value_26 
    , value_27 
    ,value_28 
    , value_29 
    , value_30 
    , value_31 
    , value_32 
    , value_33 
    ,value_34 
    , value_35 
    , value_36 
    , value_37 
    , value_38 
    , value_39 
    , value_40 
    , value_41 
    , value_42 
    , value_43 
    , value_44 
    , value_45 
    , value_46 
    , value_47 
    , value_48 
    , value_49 
    , value_50 
    ,TEXT_1
    ,TEXT_2
    ,TEXT_3
    ,TEXT_4
    ,text_5   
    ,text_6   
    ,text_7   
    ,text_8   
    ,text_9   
    ,text_10  
    ,DATE_1
    ,DATE_2
    ,DATE_3
    ,DATE_4
    ,DATE_5        
)
SELECT   
          EFFECTIVE_DAYTIME
         ,OBJECT_ID
         ,DAYTIME
         ,ECDP_OBJECTS.GetObjIDFromCode('FORECAST_GROUP','MIG_FCST_'||F.FCST_SCEN_NO)
         ,ECDP_OBJECTS.GetObjIDFromCode('FORECAST_PROD','MIG_SCN_'||F.FCST_SCEN_NO)
         ,net_oil_rate          
        ,gas_rate              
        ,cond_rate             
        ,water_rate            
        ,steam_inj_rate        
        ,water_inj_rate        
        ,gas_inj_rate                              
        ,VALUE_1
        ,VALUE_2
        ,VALUE_3
        ,VALUE_4
        ,VALUE_5
        ,VALUE_6
        ,VALUE_7
        ,VALUE_8
        ,VALUE_9
        ,VALUE_10
        ,value_11 
        ,value_12 
        ,value_13 
        , value_14 
        , value_15 
        , value_16 
        , value_17 
        , value_18 
        , value_19 
        , value_20 
        , value_21 
        , value_22 
        , value_23 
        , value_24 
        , value_25 
        , value_26 
        , value_27 
        ,value_28 
        , value_29 
        , value_30 
        , value_31 
        , value_32 
        , value_33 
        ,value_34 
        , value_35 
        , value_36 
        , value_37 
        , value_38 
        , value_39 
        , value_40 
        , value_41 
        , value_42 
        , value_43 
        , value_44 
        , value_45 
        , value_46 
        , value_47 
        , value_48 
        , value_49 
        , value_50 
        ,TEXT_1
        ,TEXT_2
        ,TEXT_3
        ,TEXT_4
        ,text_5   
        ,text_6   
        ,text_7   
        ,text_8   
        ,text_9   
        ,text_10  
        ,DATE_1
        ,DATE_2
        ,DATE_3
        ,DATE_4
        ,DATE_5        
FROM  PROD_FIELD_FORECAST PFF
WHERE PFF.FCST_SCEN_NO=F.FCST_SCEN_NO;


-- New record will be added in FCST_FIELD_DAY_JN using existing daily field forecast records from PROD_FIELD_FORECAST_JN table.
INSERT INTO FCST_FIELD_DAY_JN
 (   JN_OPERATION
    ,JN_ORACLE_USER
    ,JN_DATETIME
    ,JN_NOTES
    ,JN_APPLN
    ,JN_SESSION
    ,EFFECTIVE_DAYTIME
    ,OBJECT_ID
    ,DAYTIME  
    ,FORECAST_ID
    ,SCENARIO_ID
    ,net_oil_rate          
    ,gas_rate              
    ,cond_rate             
    ,water_rate            
    ,steam_inj_rate        
    ,water_inj_rate        
    ,gas_inj_rate                                           
    ,VALUE_1
    ,VALUE_2
    ,VALUE_3
    ,VALUE_4
    ,VALUE_5
    ,VALUE_6
    ,VALUE_7
    ,VALUE_8
    ,VALUE_9
    ,VALUE_10
    ,value_11 
    ,value_12 
    ,value_13 
    , value_14 
    , value_15 
    , value_16 
    , value_17 
    , value_18 
    , value_19 
    , value_20 
    , value_21 
    , value_22 
    , value_23 
    , value_24 
    , value_25 
    , value_26 
    , value_27 
    ,value_28 
    , value_29 
    , value_30 
    , value_31 
    , value_32 
    , value_33 
    ,value_34 
    , value_35 
    , value_36 
    , value_37 
    , value_38 
    , value_39 
    , value_40 
    , value_41 
    , value_42 
    , value_43 
    , value_44 
    , value_45 
    , value_46 
    , value_47 
    , value_48 
    , value_49 
    , value_50 
    ,TEXT_1
    ,TEXT_2
    ,TEXT_3
    ,TEXT_4
    ,text_5   
    ,text_6   
    ,text_7   
    ,text_8   
    ,text_9   
    ,text_10  
    ,DATE_1
    ,DATE_2
    ,DATE_3
    ,DATE_4
    ,DATE_5        
)
SELECT   
          JN_OPERATION
         ,JN_ORACLE_USER
         ,JN_DATETIME
         ,JN_NOTES
         ,JN_APPLN
         ,JN_SESSION
         ,EFFECTIVE_DAYTIME
         ,OBJECT_ID
         ,DAYTIME
         ,ECDP_OBJECTS.GetObjIDFromCode('FORECAST_GROUP','MIG_FCST_'||F.FCST_SCEN_NO)
         ,ECDP_OBJECTS.GetObjIDFromCode('FORECAST_PROD','MIG_SCN_'||F.FCST_SCEN_NO)
         ,net_oil_rate          
        ,gas_rate              
        ,cond_rate             
        ,water_rate            
        ,steam_inj_rate        
        ,water_inj_rate        
        ,gas_inj_rate                              
        ,VALUE_1
        ,VALUE_2
        ,VALUE_3
        ,VALUE_4
        ,VALUE_5
        ,VALUE_6
        ,VALUE_7
        ,VALUE_8
        ,VALUE_9
        ,VALUE_10
        ,value_11 
        ,value_12 
        ,value_13 
        , value_14 
        , value_15 
        , value_16 
        , value_17 
        , value_18 
        , value_19 
        , value_20 
        , value_21 
        , value_22 
        , value_23 
        , value_24 
        , value_25 
        , value_26 
        , value_27 
        ,value_28 
        , value_29 
        , value_30 
        , value_31 
        , value_32 
        , value_33 
        ,value_34 
        , value_35 
        , value_36 
        , value_37 
        , value_38 
        , value_39 
        , value_40 
        , value_41 
        , value_42 
        , value_43 
        , value_44 
        , value_45 
        , value_46 
        , value_47 
        , value_48 
        , value_49 
        , value_50 
        ,TEXT_1
        ,TEXT_2
        ,TEXT_3
        ,TEXT_4
        ,text_5   
        ,text_6   
        ,text_7   
        ,text_8   
        ,text_9   
        ,text_10  
        ,DATE_1
        ,DATE_2
        ,DATE_3
        ,DATE_4
        ,DATE_5        
FROM  PROD_FIELD_FORECAST_JN PFF
WHERE PFF.FCST_SCEN_NO=F.FCST_SCEN_NO;


-- New record will be added in FCST_FIELD_MTH using existing monthly field forecast records from PROD_FIELD_FORECAST table.
INSERT INTO FCST_FIELD_MTH
 (   EFFECTIVE_DAYTIME
    ,OBJECT_ID
    ,DAYTIME  
    ,FORECAST_ID
    ,SCENARIO_ID
    ,net_oil_rate
    , gas_rate        
    , cond_rate       
    , water_rate      
    , steam_inj_rate  
    , water_inj_rate  
    , gas_inj_rate    
    ,VALUE_1
    ,VALUE_2
    ,VALUE_3
    ,VALUE_4
    ,VALUE_5
    ,VALUE_6
    ,VALUE_7
    ,VALUE_8
    ,VALUE_9
    ,VALUE_10
    ,value_11 
    ,value_12 
    ,value_13 
    , value_14 
    , value_15 
    , value_16 
    , value_17 
    , value_18 
    , value_19 
    , value_20 
    , value_21 
    , value_22 
    , value_23 
    , value_24 
    , value_25 
    , value_26 
    , value_27 
    ,value_28 
    , value_29 
    , value_30 
    , value_31 
    , value_32 
    , value_33 
    ,value_34 
    , value_35 
    , value_36 
    , value_37 
    , value_38 
    , value_39 
    , value_40 
    , value_41 
    , value_42 
    , value_43 
    , value_44 
    , value_45 
    , value_46 
    , value_47 
    , value_48 
    , value_49 
    , value_50 
    ,TEXT_1
    ,TEXT_2
    ,TEXT_3
    ,TEXT_4
    ,text_5   
    ,text_6   
    ,text_7   
    ,text_8   
    ,text_9   
    ,text_10  
    ,DATE_1
    ,DATE_2
    ,DATE_3
    ,DATE_4
    ,DATE_5        
)
SELECT   
          EFFECTIVE_DAYTIME
         ,OBJECT_ID
         ,DAYTIME
         ,ECDP_OBJECTS.GetObjIDFromCode('FORECAST_GROUP','MIG_FCST_'||F.FCST_SCEN_NO)
         ,ECDP_OBJECTS.GetObjIDFromCode('FORECAST_PROD','MIG_SCN_'||F.FCST_SCEN_NO)
         ,net_oil_rate_mth     
         , gas_rate_mth        
         , cond_rate_mth       
         , water_rate_mth      
         , steam_inj_rate_mth  
         , water_inj_rate_mth  
         , gas_inj_rate_mth    
        ,VALUE_1
        ,VALUE_2
        ,VALUE_3
        ,VALUE_4
        ,VALUE_5
        ,VALUE_6
        ,VALUE_7
        ,VALUE_8
        ,VALUE_9
        ,VALUE_10
        ,value_11 
        ,value_12 
        ,value_13 
        , value_14 
        , value_15 
        , value_16 
        , value_17 
        , value_18 
        , value_19 
        , value_20 
        , value_21 
        , value_22 
        , value_23 
        , value_24 
        , value_25 
        , value_26 
        , value_27 
        ,value_28 
        , value_29 
        , value_30 
        , value_31 
        , value_32 
        , value_33 
        ,value_34 
        , value_35 
        , value_36 
        , value_37 
        , value_38 
        , value_39 
        , value_40 
        , value_41 
        , value_42 
        , value_43 
        , value_44 
        , value_45 
        , value_46 
        , value_47 
        , value_48 
        , value_49 
        , value_50 
        ,TEXT_1
        ,TEXT_2
        ,TEXT_3
        ,TEXT_4
        ,text_5   
        ,text_6   
        ,text_7   
        ,text_8   
        ,text_9   
        ,text_10  
        ,DATE_1
        ,DATE_2
        ,DATE_3
        ,DATE_4
        ,DATE_5        
FROM  PROD_FIELD_FORECAST PFF
WHERE PFF.FCST_SCEN_NO=F.FCST_SCEN_NO;

-- New record will be added in FCST_FIELD_MTH_JN using existing monthly field forecast records from PROD_FIELD_FORECAST_JN table.
INSERT INTO FCST_FIELD_MTH_JN
 (   JN_OPERATION
    ,JN_ORACLE_USER
    ,JN_DATETIME
    ,JN_NOTES
    ,JN_APPLN
    ,JN_SESSION
    ,EFFECTIVE_DAYTIME
    ,OBJECT_ID
    ,DAYTIME  
    ,FORECAST_ID
    ,SCENARIO_ID
    ,net_oil_rate
    , gas_rate        
    , cond_rate       
    , water_rate      
    , steam_inj_rate  
    , water_inj_rate  
    , gas_inj_rate    
    ,VALUE_1
    ,VALUE_2
    ,VALUE_3
    ,VALUE_4
    ,VALUE_5
    ,VALUE_6
    ,VALUE_7
    ,VALUE_8
    ,VALUE_9
    ,VALUE_10
    ,value_11 
    ,value_12 
    ,value_13 
    , value_14 
    , value_15 
    , value_16 
    , value_17 
    , value_18 
    , value_19 
    , value_20 
    , value_21 
    , value_22 
    , value_23 
    , value_24 
    , value_25 
    , value_26 
    , value_27 
    ,value_28 
    , value_29 
    , value_30 
    , value_31 
    , value_32 
    , value_33 
    ,value_34 
    , value_35 
    , value_36 
    , value_37 
    , value_38 
    , value_39 
    , value_40 
    , value_41 
    , value_42 
    , value_43 
    , value_44 
    , value_45 
    , value_46 
    , value_47 
    , value_48 
    , value_49 
    , value_50 
    ,TEXT_1
    ,TEXT_2
    ,TEXT_3
    ,TEXT_4
    ,text_5   
    ,text_6   
    ,text_7   
    ,text_8   
    ,text_9   
    ,text_10  
    ,DATE_1
    ,DATE_2
    ,DATE_3
    ,DATE_4
    ,DATE_5        
)
SELECT   
          JN_OPERATION
         ,JN_ORACLE_USER
         ,JN_DATETIME
         ,JN_NOTES
         ,JN_APPLN
         ,JN_SESSION
         ,EFFECTIVE_DAYTIME
         ,OBJECT_ID
         ,DAYTIME
         ,ECDP_OBJECTS.GetObjIDFromCode('FORECAST_GROUP','MIG_FCST_'||F.FCST_SCEN_NO)
         ,ECDP_OBJECTS.GetObjIDFromCode('FORECAST_PROD','MIG_SCN_'||F.FCST_SCEN_NO)
         ,net_oil_rate_mth     
         , gas_rate_mth        
         , cond_rate_mth       
         , water_rate_mth      
         , steam_inj_rate_mth  
         , water_inj_rate_mth  
         , gas_inj_rate_mth    
        ,VALUE_1
        ,VALUE_2
        ,VALUE_3
        ,VALUE_4
        ,VALUE_5
        ,VALUE_6
        ,VALUE_7
        ,VALUE_8
        ,VALUE_9
        ,VALUE_10
        ,value_11 
        ,value_12 
        ,value_13 
        , value_14 
        , value_15 
        , value_16 
        , value_17 
        , value_18 
        , value_19 
        , value_20 
        , value_21 
        , value_22 
        , value_23 
        , value_24 
        , value_25 
        , value_26 
        , value_27 
        ,value_28 
        , value_29 
        , value_30 
        , value_31 
        , value_32 
        , value_33 
        ,value_34 
        , value_35 
        , value_36 
        , value_37 
        , value_38 
        , value_39 
        , value_40 
        , value_41 
        , value_42 
        , value_43 
        , value_44 
        , value_45 
        , value_46 
        , value_47 
        , value_48 
        , value_49 
        , value_50 
        ,TEXT_1
        ,TEXT_2
        ,TEXT_3
        ,TEXT_4
        ,text_5   
        ,text_6   
        ,text_7   
        ,text_8   
        ,text_9   
        ,text_10  
        ,DATE_1
        ,DATE_2
        ,DATE_3
        ,DATE_4
        ,DATE_5        
FROM  PROD_FIELD_FORECAST_JN PFF
WHERE PFF.FCST_SCEN_NO=F.FCST_SCEN_NO;

-- New record will be added in FCST_SUB_FIELD_DAY using existing daily sub field forecast records from PROD_SUB_FIELD_FORECAST table.
INSERT INTO FCST_SUB_FIELD_DAY
 (   EFFECTIVE_DAYTIME
    ,OBJECT_ID
    ,DAYTIME  
    ,FORECAST_ID
    ,SCENARIO_ID
    ,net_oil_rate          
    ,gas_rate              
    ,cond_rate             
    ,water_rate            
    ,steam_inj_rate        
    ,water_inj_rate        
    ,gas_inj_rate                                           
    ,VALUE_1
    ,VALUE_2
    ,VALUE_3
    ,VALUE_4
    ,VALUE_5
    ,VALUE_6
    ,VALUE_7
    ,VALUE_8
    ,VALUE_9
    ,VALUE_10
    ,value_11 
    ,value_12 
    ,value_13 
    , value_14 
    , value_15 
    , value_16 
    , value_17 
    , value_18 
    , value_19 
    , value_20 
    , value_21 
    , value_22 
    , value_23 
    , value_24 
    , value_25 
    , value_26 
    , value_27 
    ,value_28 
    , value_29 
    , value_30 
    , value_31 
    , value_32 
    , value_33 
    ,value_34 
    , value_35 
    , value_36 
    , value_37 
    , value_38 
    , value_39 
    , value_40 
    , value_41 
    , value_42 
    , value_43 
    , value_44 
    , value_45 
    , value_46 
    , value_47 
    , value_48 
    , value_49 
    , value_50 
    ,TEXT_1
    ,TEXT_2
    ,TEXT_3
    ,TEXT_4
    ,text_5   
    ,text_6   
    ,text_7   
    ,text_8   
    ,text_9   
    ,text_10  
    ,DATE_1
    ,DATE_2
    ,DATE_3
    ,DATE_4
    ,DATE_5        
)
SELECT   
          EFFECTIVE_DAYTIME
         ,OBJECT_ID
         ,DAYTIME
         ,ECDP_OBJECTS.GetObjIDFromCode('FORECAST_GROUP','MIG_FCST_'||F.FCST_SCEN_NO)
         ,ECDP_OBJECTS.GetObjIDFromCode('FORECAST_PROD','MIG_SCN_'||F.FCST_SCEN_NO)
         ,net_oil_rate          
        ,gas_rate              
        ,cond_rate             
        ,water_rate            
        ,steam_inj_rate        
        ,water_inj_rate        
        ,gas_inj_rate                              
        ,VALUE_1
        ,VALUE_2
        ,VALUE_3
        ,VALUE_4
        ,VALUE_5
        ,VALUE_6
        ,VALUE_7
        ,VALUE_8
        ,VALUE_9
        ,VALUE_10
        ,value_11 
        ,value_12 
        ,value_13 
        , value_14 
        , value_15 
        , value_16 
        , value_17 
        , value_18 
        , value_19 
        , value_20 
        , value_21 
        , value_22 
        , value_23 
        , value_24 
        , value_25 
        , value_26 
        , value_27 
        ,value_28 
        , value_29 
        , value_30 
        , value_31 
        , value_32 
        , value_33 
        ,value_34 
        , value_35 
        , value_36 
        , value_37 
        , value_38 
        , value_39 
        , value_40 
        , value_41 
        , value_42 
        , value_43 
        , value_44 
        , value_45 
        , value_46 
        , value_47 
        , value_48 
        , value_49 
        , value_50 
        ,TEXT_1
        ,TEXT_2
        ,TEXT_3
        ,TEXT_4
        ,text_5   
        ,text_6   
        ,text_7   
        ,text_8   
        ,text_9   
        ,text_10  
        ,DATE_1
        ,DATE_2
        ,DATE_3
        ,DATE_4
        ,DATE_5        
FROM  PROD_SUB_FIELD_FORECAST PSFF
WHERE PSFF.FCST_SCEN_NO=F.FCST_SCEN_NO;

-- New record will be added in FCST_SUB_FIELD_DAY_JN using existing daily sub field forecast records from PROD_SUB_FIELD_FORECAST_JN table.
INSERT INTO FCST_SUB_FIELD_DAY_JN
 (   JN_OPERATION
    ,JN_ORACLE_USER
    ,JN_DATETIME
    ,JN_NOTES
    ,JN_APPLN
    ,JN_SESSION
    ,EFFECTIVE_DAYTIME
    ,OBJECT_ID
    ,DAYTIME  
    ,FORECAST_ID
    ,SCENARIO_ID
    ,net_oil_rate          
    ,gas_rate              
    ,cond_rate             
    ,water_rate            
    ,steam_inj_rate        
    ,water_inj_rate        
    ,gas_inj_rate                                           
    ,VALUE_1
    ,VALUE_2
    ,VALUE_3
    ,VALUE_4
    ,VALUE_5
    ,VALUE_6
    ,VALUE_7
    ,VALUE_8
    ,VALUE_9
    ,VALUE_10
    ,value_11 
    ,value_12 
    ,value_13 
    , value_14 
    , value_15 
    , value_16 
    , value_17 
    , value_18 
    , value_19 
    , value_20 
    , value_21 
    , value_22 
    , value_23 
    , value_24 
    , value_25 
    , value_26 
    , value_27 
    ,value_28 
    , value_29 
    , value_30 
    , value_31 
    , value_32 
    , value_33 
    ,value_34 
    , value_35 
    , value_36 
    , value_37 
    , value_38 
    , value_39 
    , value_40 
    , value_41 
    , value_42 
    , value_43 
    , value_44 
    , value_45 
    , value_46 
    , value_47 
    , value_48 
    , value_49 
    , value_50 
    ,TEXT_1
    ,TEXT_2
    ,TEXT_3
    ,TEXT_4
    ,text_5   
    ,text_6   
    ,text_7   
    ,text_8   
    ,text_9   
    ,text_10  
    ,DATE_1
    ,DATE_2
    ,DATE_3
    ,DATE_4
    ,DATE_5        
)
SELECT   
          JN_OPERATION
         ,JN_ORACLE_USER
         ,JN_DATETIME
         ,JN_NOTES
         ,JN_APPLN
         ,JN_SESSION
         ,EFFECTIVE_DAYTIME
         ,OBJECT_ID
         ,DAYTIME
         ,ECDP_OBJECTS.GetObjIDFromCode('FORECAST_GROUP','MIG_FCST_'||F.FCST_SCEN_NO)
         ,ECDP_OBJECTS.GetObjIDFromCode('FORECAST_PROD','MIG_SCN_'||F.FCST_SCEN_NO)
         ,net_oil_rate          
        ,gas_rate              
        ,cond_rate             
        ,water_rate            
        ,steam_inj_rate        
        ,water_inj_rate        
        ,gas_inj_rate                              
        ,VALUE_1
        ,VALUE_2
        ,VALUE_3
        ,VALUE_4
        ,VALUE_5
        ,VALUE_6
        ,VALUE_7
        ,VALUE_8
        ,VALUE_9
        ,VALUE_10
        ,value_11 
        ,value_12 
        ,value_13 
        , value_14 
        , value_15 
        , value_16 
        , value_17 
        , value_18 
        , value_19 
        , value_20 
        , value_21 
        , value_22 
        , value_23 
        , value_24 
        , value_25 
        , value_26 
        , value_27 
        ,value_28 
        , value_29 
        , value_30 
        , value_31 
        , value_32 
        , value_33 
        ,value_34 
        , value_35 
        , value_36 
        , value_37 
        , value_38 
        , value_39 
        , value_40 
        , value_41 
        , value_42 
        , value_43 
        , value_44 
        , value_45 
        , value_46 
        , value_47 
        , value_48 
        , value_49 
        , value_50 
        ,TEXT_1
        ,TEXT_2
        ,TEXT_3
        ,TEXT_4
        ,text_5   
        ,text_6   
        ,text_7   
        ,text_8   
        ,text_9   
        ,text_10  
        ,DATE_1
        ,DATE_2
        ,DATE_3
        ,DATE_4
        ,DATE_5        
FROM  PROD_SUB_FIELD_FORECAST_JN PSFF
WHERE PSFF.FCST_SCEN_NO=F.FCST_SCEN_NO;

-- New record will be added in FCST_SUB_FIELD_MTH using existing monthly sub field forecast records from PROD_SUB_FIELD_FORECAST table.
INSERT INTO FCST_SUB_FIELD_MTH
 (   EFFECTIVE_DAYTIME
    ,OBJECT_ID
    ,DAYTIME  
    ,FORECAST_ID
    ,SCENARIO_ID
    ,net_oil_rate
    , gas_rate        
    , cond_rate       
    , water_rate      
    , steam_inj_rate  
    , water_inj_rate  
    , gas_inj_rate    
    ,VALUE_1
    ,VALUE_2
    ,VALUE_3
    ,VALUE_4
    ,VALUE_5
    ,VALUE_6
    ,VALUE_7
    ,VALUE_8
    ,VALUE_9
    ,VALUE_10
    ,value_11 
    ,value_12 
    ,value_13 
    , value_14 
    , value_15 
    , value_16 
    , value_17 
    , value_18 
    , value_19 
    , value_20 
    , value_21 
    , value_22 
    , value_23 
    , value_24 
    , value_25 
    , value_26 
    , value_27 
    ,value_28 
    , value_29 
    , value_30 
    , value_31 
    , value_32 
    , value_33 
    ,value_34 
    , value_35 
    , value_36 
    , value_37 
    , value_38 
    , value_39 
    , value_40 
    , value_41 
    , value_42 
    , value_43 
    , value_44 
    , value_45 
    , value_46 
    , value_47 
    , value_48 
    , value_49 
    , value_50 
    ,TEXT_1
    ,TEXT_2
    ,TEXT_3
    ,TEXT_4
    ,text_5   
    ,text_6   
    ,text_7   
    ,text_8   
    ,text_9   
    ,text_10  
    ,DATE_1
    ,DATE_2
    ,DATE_3
    ,DATE_4
    ,DATE_5        
)
SELECT   
          EFFECTIVE_DAYTIME
         ,OBJECT_ID
         ,DAYTIME
         ,ECDP_OBJECTS.GetObjIDFromCode('FORECAST_GROUP','MIG_FCST_'||F.FCST_SCEN_NO)
         ,ECDP_OBJECTS.GetObjIDFromCode('FORECAST_PROD','MIG_SCN_'||F.FCST_SCEN_NO)
         ,net_oil_rate_mth     
         , gas_rate_mth        
         , cond_rate_mth       
         , water_rate_mth      
         , steam_inj_rate_mth  
         , water_inj_rate_mth  
         , gas_inj_rate_mth    
        ,VALUE_1
        ,VALUE_2
        ,VALUE_3
        ,VALUE_4
        ,VALUE_5
        ,VALUE_6
        ,VALUE_7
        ,VALUE_8
        ,VALUE_9
        ,VALUE_10
        ,value_11 
        ,value_12 
        ,value_13 
        , value_14 
        , value_15 
        , value_16 
        , value_17 
        , value_18 
        , value_19 
        , value_20 
        , value_21 
        , value_22 
        , value_23 
        , value_24 
        , value_25 
        , value_26 
        , value_27 
        ,value_28 
        , value_29 
        , value_30 
        , value_31 
        , value_32 
        , value_33 
        ,value_34 
        , value_35 
        , value_36 
        , value_37 
        , value_38 
        , value_39 
        , value_40 
        , value_41 
        , value_42 
        , value_43 
        , value_44 
        , value_45 
        , value_46 
        , value_47 
        , value_48 
        , value_49 
        , value_50 
        ,TEXT_1
        ,TEXT_2
        ,TEXT_3
        ,TEXT_4
        ,text_5   
        ,text_6   
        ,text_7   
        ,text_8   
        ,text_9   
        ,text_10  
        ,DATE_1
        ,DATE_2
        ,DATE_3
        ,DATE_4
        ,DATE_5        
FROM  PROD_SUB_FIELD_FORECAST PSFF
WHERE PSFF.FCST_SCEN_NO=F.FCST_SCEN_NO;

-- New record will be added in FCST_SUB_FIELD_MTH_JN using existing monthly sub field forecast records from PROD_SUB_FIELD_FORECAST_JN table.
INSERT INTO FCST_SUB_FIELD_MTH_JN
 (   JN_OPERATION
    ,JN_ORACLE_USER
    ,JN_DATETIME
    ,JN_NOTES
    ,JN_APPLN
    ,JN_SESSION
    ,EFFECTIVE_DAYTIME
    ,OBJECT_ID
    ,DAYTIME  
    ,FORECAST_ID
    ,SCENARIO_ID
    ,net_oil_rate
    , gas_rate        
    , cond_rate       
    , water_rate      
    , steam_inj_rate  
    , water_inj_rate  
    , gas_inj_rate    
    ,VALUE_1
    ,VALUE_2
    ,VALUE_3
    ,VALUE_4
    ,VALUE_5
    ,VALUE_6
    ,VALUE_7
    ,VALUE_8
    ,VALUE_9
    ,VALUE_10
    ,value_11 
    ,value_12 
    ,value_13 
    , value_14 
    , value_15 
    , value_16 
    , value_17 
    , value_18 
    , value_19 
    , value_20 
    , value_21 
    , value_22 
    , value_23 
    , value_24 
    , value_25 
    , value_26 
    , value_27 
    ,value_28 
    , value_29 
    , value_30 
    , value_31 
    , value_32 
    , value_33 
    ,value_34 
    , value_35 
    , value_36 
    , value_37 
    , value_38 
    , value_39 
    , value_40 
    , value_41 
    , value_42 
    , value_43 
    , value_44 
    , value_45 
    , value_46 
    , value_47 
    , value_48 
    , value_49 
    , value_50 
    ,TEXT_1
    ,TEXT_2
    ,TEXT_3
    ,TEXT_4
    ,text_5   
    ,text_6   
    ,text_7   
    ,text_8   
    ,text_9   
    ,text_10  
    ,DATE_1
    ,DATE_2
    ,DATE_3
    ,DATE_4
    ,DATE_5        
)
SELECT   
          JN_OPERATION
         ,JN_ORACLE_USER
         ,JN_DATETIME
         ,JN_NOTES
         ,JN_APPLN
         ,JN_SESSION
         ,EFFECTIVE_DAYTIME
         ,OBJECT_ID
         ,DAYTIME
         ,ECDP_OBJECTS.GetObjIDFromCode('FORECAST_GROUP','MIG_FCST_'||F.FCST_SCEN_NO)
         ,ECDP_OBJECTS.GetObjIDFromCode('FORECAST_PROD','MIG_SCN_'||F.FCST_SCEN_NO)
         ,net_oil_rate_mth     
         , gas_rate_mth        
         , cond_rate_mth       
         , water_rate_mth      
         , steam_inj_rate_mth  
         , water_inj_rate_mth  
         , gas_inj_rate_mth    
        ,VALUE_1
        ,VALUE_2
        ,VALUE_3
        ,VALUE_4
        ,VALUE_5
        ,VALUE_6
        ,VALUE_7
        ,VALUE_8
        ,VALUE_9
        ,VALUE_10
        ,value_11 
        ,value_12 
        ,value_13 
        , value_14 
        , value_15 
        , value_16 
        , value_17 
        , value_18 
        , value_19 
        , value_20 
        , value_21 
        , value_22 
        , value_23 
        , value_24 
        , value_25 
        , value_26 
        , value_27 
        ,value_28 
        , value_29 
        , value_30 
        , value_31 
        , value_32 
        , value_33 
        ,value_34 
        , value_35 
        , value_36 
        , value_37 
        , value_38 
        , value_39 
        , value_40 
        , value_41 
        , value_42 
        , value_43 
        , value_44 
        , value_45 
        , value_46 
        , value_47 
        , value_48 
        , value_49 
        , value_50 
        ,TEXT_1
        ,TEXT_2
        ,TEXT_3
        ,TEXT_4
        ,text_5   
        ,text_6   
        ,text_7   
        ,text_8   
        ,text_9   
        ,text_10  
        ,DATE_1
        ,DATE_2
        ,DATE_3
        ,DATE_4
        ,DATE_5        
FROM  PROD_SUB_FIELD_FORECAST_JN PSFF
WHERE PSFF.FCST_SCEN_NO=F.FCST_SCEN_NO;

-- New record will be added in FCST_STORAGE_DAY using existing daily storage forecast records from PROD_STORAGE_FORECAST table.
INSERT INTO FCST_STORAGE_DAY
 (  EFFECTIVE_DAYTIME
    ,OBJECT_ID
    ,DAYTIME  
    ,FORECAST_ID
    ,SCENARIO_ID
    ,net_oil_rate          
    ,gas_rate              
    ,cond_rate             
    ,water_rate            
    ,steam_inj_rate        
    ,water_inj_rate        
    ,gas_inj_rate                                           
    ,VALUE_1
    ,VALUE_2
    ,VALUE_3
    ,VALUE_4
    ,VALUE_5
    ,VALUE_6
    ,VALUE_7
    ,VALUE_8
    ,VALUE_9
    ,VALUE_10
    ,value_11 
    ,value_12 
    ,value_13 
    , value_14 
    , value_15 
    , value_16 
    , value_17 
    , value_18 
    , value_19 
    , value_20 
    , value_21 
    , value_22 
    , value_23 
    , value_24 
    , value_25 
    , value_26 
    , value_27 
    ,value_28 
    , value_29 
    , value_30 
    , value_31 
    , value_32 
    , value_33 
    ,value_34 
    , value_35 
    , value_36 
    , value_37 
    , value_38 
    , value_39 
    , value_40 
    , value_41 
    , value_42 
    , value_43 
    , value_44 
    , value_45 
    , value_46 
    , value_47 
    , value_48 
    , value_49 
    , value_50 
    ,TEXT_1
    ,TEXT_2
    ,TEXT_3
    ,TEXT_4
    ,text_5   
    ,text_6   
    ,text_7   
    ,text_8   
    ,text_9   
    ,text_10  
    ,DATE_1
    ,DATE_2
    ,DATE_3
    ,DATE_4
    ,DATE_5        
)
SELECT   
          EFFECTIVE_DAYTIME
         ,OBJECT_ID
         ,DAYTIME
         ,ECDP_OBJECTS.GetObjIDFromCode('FORECAST_GROUP','MIG_FCST_'||F.FCST_SCEN_NO)
         ,ECDP_OBJECTS.GetObjIDFromCode('FORECAST_PROD','MIG_SCN_'||F.FCST_SCEN_NO)
         ,net_oil_rate          
        ,gas_rate              
        ,cond_rate             
        ,water_rate            
        ,steam_inj_rate        
        ,water_inj_rate        
        ,gas_inj_rate                              
        ,VALUE_1
        ,VALUE_2
        ,VALUE_3
        ,VALUE_4
        ,VALUE_5
        ,VALUE_6
        ,VALUE_7
        ,VALUE_8
        ,VALUE_9
        ,VALUE_10
        ,value_11 
        ,value_12 
        ,value_13 
        , value_14 
        , value_15 
        , value_16 
        , value_17 
        , value_18 
        , value_19 
        , value_20 
        , value_21 
        , value_22 
        , value_23 
        , value_24 
        , value_25 
        , value_26 
        , value_27 
        ,value_28 
        , value_29 
        , value_30 
        , value_31 
        , value_32 
        , value_33 
        ,value_34 
        , value_35 
        , value_36 
        , value_37 
        , value_38 
        , value_39 
        , value_40 
        , value_41 
        , value_42 
        , value_43 
        , value_44 
        , value_45 
        , value_46 
        , value_47 
        , value_48 
        , value_49 
        , value_50 
        ,TEXT_1
        ,TEXT_2
        ,TEXT_3
        ,TEXT_4
        ,text_5   
        ,text_6   
        ,text_7   
        ,text_8   
        ,text_9   
        ,text_10  
        ,DATE_1
        ,DATE_2
        ,DATE_3
        ,DATE_4
        ,DATE_5        
FROM  PROD_STORAGE_FORECAST PSF
WHERE PSF.FCST_SCEN_NO=F.FCST_SCEN_NO;

-- New record will be added in FCST_STORAGE_DAY_JN using existing daily storage forecast records from PROD_STORAGE_FORECAST_JN table.
INSERT INTO FCST_STORAGE_DAY_JN
 (   JN_OPERATION
    ,JN_ORACLE_USER
    ,JN_DATETIME
    ,JN_NOTES
    ,JN_APPLN
    ,JN_SESSION
    ,EFFECTIVE_DAYTIME
    ,OBJECT_ID
    ,DAYTIME  
    ,FORECAST_ID
    ,SCENARIO_ID
    ,net_oil_rate          
    ,gas_rate              
    ,cond_rate             
    ,water_rate            
    ,steam_inj_rate        
    ,water_inj_rate        
    ,gas_inj_rate                                           
    ,VALUE_1
    ,VALUE_2
    ,VALUE_3
    ,VALUE_4
    ,VALUE_5
    ,VALUE_6
    ,VALUE_7
    ,VALUE_8
    ,VALUE_9
    ,VALUE_10
    ,value_11 
    ,value_12 
    ,value_13 
    , value_14 
    , value_15 
    , value_16 
    , value_17 
    , value_18 
    , value_19 
    , value_20 
    , value_21 
    , value_22 
    , value_23 
    , value_24 
    , value_25 
    , value_26 
    , value_27 
    ,value_28 
    , value_29 
    , value_30 
    , value_31 
    , value_32 
    , value_33 
    ,value_34 
    , value_35 
    , value_36 
    , value_37 
    , value_38 
    , value_39 
    , value_40 
    , value_41 
    , value_42 
    , value_43 
    , value_44 
    , value_45 
    , value_46 
    , value_47 
    , value_48 
    , value_49 
    , value_50 
    ,TEXT_1
    ,TEXT_2
    ,TEXT_3
    ,TEXT_4
    ,text_5   
    ,text_6   
    ,text_7   
    ,text_8   
    ,text_9   
    ,text_10  
    ,DATE_1
    ,DATE_2
    ,DATE_3
    ,DATE_4
    ,DATE_5        
)
SELECT   
          JN_OPERATION
         ,JN_ORACLE_USER
         ,JN_DATETIME
         ,JN_NOTES
         ,JN_APPLN
         ,JN_SESSION
         ,EFFECTIVE_DAYTIME
         ,OBJECT_ID
         ,DAYTIME
         ,ECDP_OBJECTS.GetObjIDFromCode('FORECAST_GROUP','MIG_FCST_'||F.FCST_SCEN_NO)
         ,ECDP_OBJECTS.GetObjIDFromCode('FORECAST_PROD','MIG_SCN_'||F.FCST_SCEN_NO)
         ,net_oil_rate          
        ,gas_rate              
        ,cond_rate             
        ,water_rate            
        ,steam_inj_rate        
        ,water_inj_rate        
        ,gas_inj_rate                              
        ,VALUE_1
        ,VALUE_2
        ,VALUE_3
        ,VALUE_4
        ,VALUE_5
        ,VALUE_6
        ,VALUE_7
        ,VALUE_8
        ,VALUE_9
        ,VALUE_10
        ,value_11 
        ,value_12 
        ,value_13 
        , value_14 
        , value_15 
        , value_16 
        , value_17 
        , value_18 
        , value_19 
        , value_20 
        , value_21 
        , value_22 
        , value_23 
        , value_24 
        , value_25 
        , value_26 
        , value_27 
        ,value_28 
        , value_29 
        , value_30 
        , value_31 
        , value_32 
        , value_33 
        ,value_34 
        , value_35 
        , value_36 
        , value_37 
        , value_38 
        , value_39 
        , value_40 
        , value_41 
        , value_42 
        , value_43 
        , value_44 
        , value_45 
        , value_46 
        , value_47 
        , value_48 
        , value_49 
        , value_50 
        ,TEXT_1
        ,TEXT_2
        ,TEXT_3
        ,TEXT_4
        ,text_5   
        ,text_6   
        ,text_7   
        ,text_8   
        ,text_9   
        ,text_10  
        ,DATE_1
        ,DATE_2
        ,DATE_3
        ,DATE_4
        ,DATE_5        
FROM  PROD_STORAGE_FORECAST_JN PSF
WHERE PSF.FCST_SCEN_NO=F.FCST_SCEN_NO;

-- New record will be added in FCST_STORAGE_MTH using existing monthly storage forecast records from PROD_STORAGE_FORECAST table.
INSERT INTO FCST_STORAGE_MTH
 (   EFFECTIVE_DAYTIME
    ,OBJECT_ID
    ,DAYTIME  
    ,FORECAST_ID
    ,SCENARIO_ID
    ,net_oil_rate
    , gas_rate        
    , cond_rate       
    , water_rate      
    , steam_inj_rate  
    , water_inj_rate  
    , gas_inj_rate    
    ,VALUE_1
    ,VALUE_2
    ,VALUE_3
    ,VALUE_4
    ,VALUE_5
    ,VALUE_6
    ,VALUE_7
    ,VALUE_8
    ,VALUE_9
    ,VALUE_10
    ,value_11 
    ,value_12 
    ,value_13 
    , value_14 
    , value_15 
    , value_16 
    , value_17 
    , value_18 
    , value_19 
    , value_20 
    , value_21 
    , value_22 
    , value_23 
    , value_24 
    , value_25 
    , value_26 
    , value_27 
    ,value_28 
    , value_29 
    , value_30 
    , value_31 
    , value_32 
    , value_33 
    ,value_34 
    , value_35 
    , value_36 
    , value_37 
    , value_38 
    , value_39 
    , value_40 
    , value_41 
    , value_42 
    , value_43 
    , value_44 
    , value_45 
    , value_46 
    , value_47 
    , value_48 
    , value_49 
    , value_50 
    ,TEXT_1
    ,TEXT_2
    ,TEXT_3
    ,TEXT_4
    ,text_5   
    ,text_6   
    ,text_7   
    ,text_8   
    ,text_9   
    ,text_10  
    ,DATE_1
    ,DATE_2
    ,DATE_3
    ,DATE_4
    ,DATE_5        
)
SELECT   
          EFFECTIVE_DAYTIME
         ,OBJECT_ID
         ,DAYTIME
         ,ECDP_OBJECTS.GetObjIDFromCode('FORECAST_GROUP','MIG_FCST_'||F.FCST_SCEN_NO)
         ,ECDP_OBJECTS.GetObjIDFromCode('FORECAST_PROD','MIG_SCN_'||F.FCST_SCEN_NO)
         ,net_oil_rate_mth     
         , gas_rate_mth        
         , cond_rate_mth       
         , water_rate_mth      
         , steam_inj_rate_mth  
         , water_inj_rate_mth  
         , gas_inj_rate_mth    
        ,VALUE_1
        ,VALUE_2
        ,VALUE_3
        ,VALUE_4
        ,VALUE_5
        ,VALUE_6
        ,VALUE_7
        ,VALUE_8
        ,VALUE_9
        ,VALUE_10
        ,value_11 
        ,value_12 
        ,value_13 
        , value_14 
        , value_15 
        , value_16 
        , value_17 
        , value_18 
        , value_19 
        , value_20 
        , value_21 
        , value_22 
        , value_23 
        , value_24 
        , value_25 
        , value_26 
        , value_27 
        ,value_28 
        , value_29 
        , value_30 
        , value_31 
        , value_32 
        , value_33 
        ,value_34 
        , value_35 
        , value_36 
        , value_37 
        , value_38 
        , value_39 
        , value_40 
        , value_41 
        , value_42 
        , value_43 
        , value_44 
        , value_45 
        , value_46 
        , value_47 
        , value_48 
        , value_49 
        , value_50 
        ,TEXT_1
        ,TEXT_2
        ,TEXT_3
        ,TEXT_4
        ,text_5   
        ,text_6   
        ,text_7   
        ,text_8   
        ,text_9   
        ,text_10  
        ,DATE_1
        ,DATE_2
        ,DATE_3
        ,DATE_4
        ,DATE_5        
FROM  PROD_STORAGE_FORECAST PSF
WHERE PSF.FCST_SCEN_NO=F.FCST_SCEN_NO;

-- New record will be added in FCST_STORAGE_MTH_JN using existing monthly storage forecast records from PROD_STORAGE_FORECAST_JN table.
INSERT INTO FCST_STORAGE_MTH_JN
 (   JN_OPERATION
    ,JN_ORACLE_USER
    ,JN_DATETIME
    ,JN_NOTES
    ,JN_APPLN
    ,JN_SESSION
    ,EFFECTIVE_DAYTIME
    ,OBJECT_ID
    ,DAYTIME  
    ,FORECAST_ID
    ,SCENARIO_ID
    ,net_oil_rate
    , gas_rate        
    , cond_rate       
    , water_rate      
    , steam_inj_rate  
    , water_inj_rate  
    , gas_inj_rate    
    ,VALUE_1
    ,VALUE_2
    ,VALUE_3
    ,VALUE_4
    ,VALUE_5
    ,VALUE_6
    ,VALUE_7
    ,VALUE_8
    ,VALUE_9
    ,VALUE_10
    ,value_11 
    ,value_12 
    ,value_13 
    , value_14 
    , value_15 
    , value_16 
    , value_17 
    , value_18 
    , value_19 
    , value_20 
    , value_21 
    , value_22 
    , value_23 
    , value_24 
    , value_25 
    , value_26 
    , value_27 
    ,value_28 
    , value_29 
    , value_30 
    , value_31 
    , value_32 
    , value_33 
    ,value_34 
    , value_35 
    , value_36 
    , value_37 
    , value_38 
    , value_39 
    , value_40 
    , value_41 
    , value_42 
    , value_43 
    , value_44 
    , value_45 
    , value_46 
    , value_47 
    , value_48 
    , value_49 
    , value_50 
    ,TEXT_1
    ,TEXT_2
    ,TEXT_3
    ,TEXT_4
    ,text_5   
    ,text_6   
    ,text_7   
    ,text_8   
    ,text_9   
    ,text_10  
    ,DATE_1
    ,DATE_2
    ,DATE_3
    ,DATE_4
    ,DATE_5        
)
SELECT   
          JN_OPERATION
         ,JN_ORACLE_USER
         ,JN_DATETIME
         ,JN_NOTES
         ,JN_APPLN
         ,JN_SESSION
         ,EFFECTIVE_DAYTIME
         ,OBJECT_ID
         ,DAYTIME
         ,ECDP_OBJECTS.GetObjIDFromCode('FORECAST_GROUP','MIG_FCST_'||F.FCST_SCEN_NO)
         ,ECDP_OBJECTS.GetObjIDFromCode('FORECAST_PROD','MIG_SCN_'||F.FCST_SCEN_NO)
         ,net_oil_rate_mth     
         , gas_rate_mth        
         , cond_rate_mth       
         , water_rate_mth      
         , steam_inj_rate_mth  
         , water_inj_rate_mth  
         , gas_inj_rate_mth    
        ,VALUE_1
        ,VALUE_2
        ,VALUE_3
        ,VALUE_4
        ,VALUE_5
        ,VALUE_6
        ,VALUE_7
        ,VALUE_8
        ,VALUE_9
        ,VALUE_10
        ,value_11 
        ,value_12 
        ,value_13 
        , value_14 
        , value_15 
        , value_16 
        , value_17 
        , value_18 
        , value_19 
        , value_20 
        , value_21 
        , value_22 
        , value_23 
        , value_24 
        , value_25 
        , value_26 
        , value_27 
        ,value_28 
        , value_29 
        , value_30 
        , value_31 
        , value_32 
        , value_33 
        ,value_34 
        , value_35 
        , value_36 
        , value_37 
        , value_38 
        , value_39 
        , value_40 
        , value_41 
        , value_42 
        , value_43 
        , value_44 
        , value_45 
        , value_46 
        , value_47 
        , value_48 
        , value_49 
        , value_50 
        ,TEXT_1
        ,TEXT_2
        ,TEXT_3
        ,TEXT_4
        ,text_5   
        ,text_6   
        ,text_7   
        ,text_8   
        ,text_9   
        ,text_10  
        ,DATE_1
        ,DATE_2
        ,DATE_3
        ,DATE_4
        ,DATE_5        
FROM  PROD_STORAGE_FORECAST_JN PSF
WHERE PSF.FCST_SCEN_NO=F.FCST_SCEN_NO;
END LOOP;
COMMIT;
END;
--~^UTDELIM^~--

BEGIN
UPDATE ptst_definition
   SET record_status     = 'P'
      ,last_updated_by   = last_updated_by
      ,last_updated_date = last_updated_date
 WHERE record_status <> 'P';
 
UPDATE PTST_DEFINITION_JN
SET RECORD_STATUS='P'
WHERE RECORD_STATUS<>'P';
END;
--~^UTDELIM^~--

BEGIN
UPDATE ptst_object
   SET record_status     = 'P'
      ,last_updated_by   = last_updated_by
      ,last_updated_date = last_updated_date
 WHERE record_status <> 'P';
 
UPDATE PTST_OBJECT_JN
SET RECORD_STATUS='P'
WHERE RECORD_STATUS<>'P';
END;
--~^UTDELIM^~--

BEGIN
UPDATE ptst_event
   SET record_status     = 'P'
      ,last_updated_by   = last_updated_by
      ,last_updated_date = last_updated_date
 WHERE record_status <> 'P';
 
UPDATE PTST_EVENT_JN
SET RECORD_STATUS='P'
WHERE RECORD_STATUS<>'P';
END;
--~^UTDELIM^~--

BEGIN
UPDATE fcst_fcty_day
   SET class_name        = 'FCST_FCTY1_DAY_STATUS'
      ,last_updated_by   = last_updated_by
      ,last_updated_date = last_updated_date
 WHERE class_name IS NULL;

UPDATE fcst_fcty_day_jn
   SET class_name = 'FCST_FCTY1_DAY_STATUS'
 WHERE class_name IS NULL;
END;
--~^UTDELIM^~--

BEGIN
UPDATE fcst_fcty_mth
   SET class_name        = 'FCST_FCTY1_MTH_STATUS'
      ,last_updated_by   = last_updated_by
      ,last_updated_date = last_updated_date
 WHERE class_name IS NULL;

UPDATE fcst_fcty_mth_jn
   SET class_name        = 'FCST_FCTY1_MTH_STATUS'
 WHERE class_name IS NULL;
END;
--~^UTDELIM^~--

BEGIN
UPDATE strm_set_list
   SET stream_set        = 'PP.0037'
      ,last_updated_by   = last_updated_by
      ,last_updated_date = last_updated_date
 WHERE stream_set = 'PP.0016';

UPDATE STRM_SET_LIST_JN
SET    STREAM_SET='PP.0037'
WHERE  STREAM_SET='PP.0016';
END;
--~^UTDELIM^~--

BEGIN 
    
      UPDATE FCST_COMPENSATION_EVENTS
      SET DAY = EcDp_ProductionDay.getProductionDay(NULL, OBJECT_ID, DAYTIME, ecdp_date_time.summertime_flag(DAYTIME, NULL, EcDp_ProductionDay.findProductionDayDefinition(NULL, OBJECT_ID, DAYTIME))) ,
          SUMMER_TIME = ecdp_date_time.summertime_flag(DAYTIME, NULL, EcDp_ProductionDay.findProductionDayDefinition(NULL, OBJECT_ID, DAYTIME)),
          LAST_UPDATED_BY = LAST_UPDATED_BY ,
          LAST_UPDATED_DATE = LAST_UPDATED_DATE           
      WHERE DAY IS NULL OR SUMMER_TIME IS NULL;  
      
  
      UPDATE FCST_COMPENSATION_EVENTS
      SET END_DAY = (CASE WHEN END_DATE = ecdp_productionday.getproductionday(NULL,  object_id,  end_date,  summer_time) + Ecdp_Productionday.getProductionDayOffset(null,  object_id,  end_date, summer_time) / 24
              THEN EcDp_ProductionDay.getProductionDay(NULL, object_id,  end_date,  summer_time) - 1
              ELSE EcDp_ProductionDay.getProductionDay(NULL, object_id,  end_date,  summer_time) END) ,
          LAST_UPDATED_BY = LAST_UPDATED_BY,
          LAST_UPDATED_DATE = LAST_UPDATED_DATE           
      WHERE END_DAY IS NULL  AND END_DATE IS NOT NULL ;  
  
END;
--~^UTDELIM^~--
	COMMENT ON TABLE NOMPNT_NP_DAY_NOMINATION IS 'This table is used for tracking of path nomination by linking the entry nomination point and exit nomination point.'
--~^UTDELIM^~--

	COMMENT ON TABLE TRAN_ZONE_OPLOC_CONN IS 'This table is used to maintain connections between Transport Zone to various object types.'
--~^UTDELIM^~--

	COMMENT ON TABLE OBJLOC_DAY_NP_NOM IS 'This table is used for storing Route (flow path) calculation.'
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

COMMENT ON TABLE ITST_DEFINITION IS 'Holds Injection Well performance test definition.'
--~^UTDELIM^~--

COMMENT ON COLUMN ITST_DEFINITION.DAYTIME IS 'Start datetime of the test.'
--~^UTDELIM^~--

COMMENT ON TABLE ITST_OBJECT IS 'Holds the test devices, wells and flowlines involved in the Injection test.'
--~^UTDELIM^~--

COMMENT ON TABLE ITST_RESULT IS 'Includes the essential data elements for a quick user identification of a Injection test result for a given stable period.'
--~^UTDELIM^~--

COMMENT ON TABLE TEST_DEVICE_INJ_RESULT IS 'Injection test result data for test device.'
--~^UTDELIM^~--

COMMENT ON TABLE IWEL_RESULT IS 'Injection test result data for a well.'
--~^UTDELIM^~--

COMMENT ON TABLE IFLW_RESULT IS 'Injection test result data for a flowline.'
--~^UTDELIM^~--

COMMENT ON TABLE WBI_INJ_RESULT IS 'Injection test result figures for a well bore interval.'
--~^UTDELIM^~--

COMMENT ON TABLE ITST_GRAPH_DEFINE IS 'Contains parameters for plot trace setup for test objects.'
--~^UTDELIM^~--

COMMENT ON TABLE TEST_DEVICE_INJ_SAMPLE IS 'Contains test device sample data for injection wells'
--~^UTDELIM^~--

COMMENT ON TABLE IFLW_SAMPLE IS 'Contains injection flowline sample data'
--~^UTDELIM^~--

COMMENT ON TABLE IWEL_SAMPLE IS 'Contains injection well sample data'
--~^UTDELIM^~--

COMMENT ON TABLE WBI_INJ_SAMPLE IS 'Contains injection well bore interval sample data'
--~^UTDELIM^~--

BEGIN
	UPDATE WELL SET CLASS_NAME='WELL'  WHERE CLASS_NAME IS NULL;
END;
--~^UTDELIM^~--

COMMENT ON TABLE NOMPNT_NP_DAY_DELIVERY IS 'GENERIC TABLE THAT HOLDS DELIVERIES TO PATHED NOMINATIONS.'
--~^UTDELIM^~--
COMMENT ON TABLE CNTR_DAY_CAP_TRADE IS 'This table is used for storing the data of Capacity Trading and Auctioning.'
--~^UTDELIM^~--
COMMENT ON TABLE OBJLOC_DAY_CNTR_NOM IS 'This table is used hold the pipeline segment contracted nominations.'
--~^UTDELIM^~--