DECLARE 
HASENTRY NUMBER;
BEGIN
	SELECT COUNT(*) INTO HASENTRY FROM USER_TRIGGERS 
		WHERE TRIGGER_NAME = 'IU_OBJLOC_SUB_DAY_NOMINATION'; 
		IF HASENTRY > 0 THEN 
		EXECUTE IMMEDIATE 'ALTER TRIGGER IU_OBJLOC_SUB_DAY_NOMINATION DISABLE';
		END IF;
	
	UPDATE OBJLOC_SUB_DAY_NOMINATION SET NOMINATION_SEQ = EcDp_System_Key.assignNextNumber('OBJLOC_SUB_DAY_NOMINATION') ;
	
	SELECT COUNT(*) INTO HASENTRY FROM USER_TRIGGERS 
		WHERE TRIGGER_NAME = 'IU_OBJLOC_SUB_DAY_NOMINATION'; 
		IF HASENTRY > 0 THEN 
		EXECUTE IMMEDIATE 'ALTER TRIGGER IU_OBJLOC_SUB_DAY_NOMINATION ENABLE';
		END IF;
		
	EXCEPTION
   WHEN OTHERS 
     THEN
       IF HASENTRY > 0 THEN 
           EXECUTE IMMEDIATE 'ALTER TRIGGER IU_OBJLOC_SUB_DAY_NOMINATION ENABLE';
       END IF;
        
        raise_application_error(-20000,
                            'ERROR: Some Other fatal error occured :- '||SQLERRM);
END;
--~^UTDELIM^~--

DECLARE 
HASENTRY NUMBER;
BEGIN	
--Updating DAY_NOM_SEQ column of table OBJLOC_SUB_DAY_NOMINATION */
	SELECT COUNT(*) INTO HASENTRY FROM USER_TRIGGERS 
		WHERE TRIGGER_NAME = 'IU_OBJLOC_SUB_DAY_NOMINATION'; 
		IF HASENTRY > 0 THEN 
		EXECUTE IMMEDIATE 'ALTER TRIGGER IU_OBJLOC_SUB_DAY_NOMINATION DISABLE';
		END IF;

		UPDATE OBJLOC_SUB_DAY_NOMINATION a SET a.day_nom_seq = 
		(
		SELECT b.NOMINATION_SEQ FROM OBJLOC_DAY_NOMINATION b
		WHERE  a.object_id = b.object_id
		AND a.production_day = b.DAYTIME
		AND a.summer_time = EcDp_Date_Time.summertime_flag(b.DAYTIME,NULL,a.OBJECT_ID) 
		);

	SELECT COUNT(*) INTO HASENTRY FROM USER_TRIGGERS 
		WHERE TRIGGER_NAME = 'IU_OBJLOC_SUB_DAY_NOMINATION'; 
		IF HASENTRY > 0 THEN 
		EXECUTE IMMEDIATE 'ALTER TRIGGER IU_OBJLOC_SUB_DAY_NOMINATION ENABLE';
		END IF;
		
		
	EXCEPTION
   WHEN OTHERS 
     THEN
       IF HASENTRY > 0 THEN 
           EXECUTE IMMEDIATE 'ALTER TRIGGER IU_OBJLOC_SUB_DAY_NOMINATION ENABLE';
       END IF;
        
        raise_application_error(-20000,
                            'ERROR: Some Other fatal error occured :- '||SQLERRM);
END;
--~^UTDELIM^~--