--  Loading ./ECPD26769_WELL_REFERENCE...

ALTER TABLE WELL_REFERENCE_VALUE_JN ADD VENT_FACTOR_1 NUMBER
--~^UTDELIM^~--

DECLARE 
HASENTRY NUMBER;
BEGIN
	SELECT COUNT(*) INTO HASENTRY FROM USER_TRIGGERS 
		WHERE TRIGGER_NAME = 'IU_WELL_REFERENCE_VALUE_JN'; 
		IF HASENTRY > 0 THEN 
		EXECUTE IMMEDIATE 'ALTER TRIGGER IU_WELL_REFERENCE_VALUE_JN DISABLE';
		END IF;
	
	UPDATE WELL_REFERENCE_VALUE_JN SET VENT_FACTOR_1 = VENT_FACTOR;
	
	SELECT COUNT(*) INTO HASENTRY FROM USER_TRIGGERS 
		WHERE TRIGGER_NAME = 'IU_WELL_REFERENCE_VALUE_JN'; 
		IF HASENTRY > 0 THEN 
		EXECUTE IMMEDIATE 'ALTER TRIGGER IU_WELL_REFERENCE_VALUE_JN ENABLE';
		END IF;
EXCEPTION
   WHEN OTHERS 
     THEN

       IF HASENTRY > 0 THEN 
           EXECUTE IMMEDIATE 'ALTER TRIGGER IU_WELL_REFERENCE_VALUE_JN ENABLE';
       END IF;
        
        raise_application_error(-20000,
                            'ERROR: Some Other fatal error occured :- '||SQLERRM);

END;
--~^UTDELIM^~--	


ALTER TABLE WELL_REFERENCE_VALUE_JN DROP COLUMN VENT_FACTOR
--~^UTDELIM^~--

ALTER TABLE WELL_REFERENCE_VALUE_JN RENAME COLUMN VENT_FACTOR_1 TO VENT_FACTOR
--~^UTDELIM^~--