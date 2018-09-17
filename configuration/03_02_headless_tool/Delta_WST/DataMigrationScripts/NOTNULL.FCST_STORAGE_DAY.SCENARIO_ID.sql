DECLARE
  HASENTRY NUMBER;
  LV2_OBJECT_ID        VARCHAR2(50);
  LV2_OBJECT_ID_CURSOR VARCHAR2(50);
  CURSOR C_FORECAST_PROD IS
    SELECT OBJECT_ID FROM FORECAST WHERE OBJECT_CODE = 'ECSCENARIO';
BEGIN
  LV2_OBJECT_ID := SYS_GUID();
  INSERT INTO FORECAST
    (OBJECT_ID,
     CLASS_NAME,
     OBJECT_CODE,
     START_DATE,
     END_DATE,
     CREATED_BY,
     CREATED_DATE)
    SELECT LV2_OBJECT_ID,
           'FORECAST_PROD',
           'ECSCENARIO',
           TO_DATE('01-01-2010', 'DD-MM-YYYY'),
           TO_DATE('01-01-2025', 'DD-MM-YYYY'),
           'User',
           SYSDATE
      FROM FORECAST WHERE NOT EXISTS
     (SELECT * FROM FORECAST
             WHERE CLASS_NAME LIKE 'FORECAST_PROD'
               AND OBJECT_CODE LIKE 'ECSCENARIO'
               AND START_DATE LIKE TO_DATE('01-01-2010', 'DD-MM-YYYY')
               AND END_DATE LIKE TO_DATE('01-01-2025', 'DD-MM-YYYY')
               AND CREATED_BY LIKE 'User')
       AND ROWNUM = 1;

  INSERT INTO FORECAST_VERSION
    (OBJECT_ID, NAME, DAYTIME, END_DATE, CREATED_BY, CREATED_DATE)
    SELECT LV2_OBJECT_ID,
           'EC Scenario',
           TO_DATE('01-01-2010', 'DD-MM-YYYY'),
           TO_DATE('01-01-2025', 'DD-MM-YYYY'),
           'User',
           SYSDATE
      FROM FORECAST_VERSION
     WHERE NOT EXISTS
     (SELECT * FROM FORECAST_VERSION
             WHERE NAME LIKE 'EC Scenario'
               AND DAYTIME LIKE TO_DATE('01-01-2010', 'DD-MM-YYYY')
               AND END_DATE LIKE TO_DATE('01-01-2025', 'DD-MM-YYYY')
               AND CREATED_BY LIKE 'User')
       AND ROWNUM = 1;

  FOR CUR_FORECAST IN C_FORECAST_PROD LOOP
    LV2_OBJECT_ID_CURSOR := CUR_FORECAST.OBJECT_ID;
  END LOOP;
  
  SELECT COUNT(*) INTO HASENTRY FROM USER_TRIGGERS 
		WHERE TRIGGER_NAME = 'IU_FCST_STORAGE_DAY'; 
		IF HASENTRY > 0 THEN 
		EXECUTE IMMEDIATE 'ALTER TRIGGER IU_FCST_STORAGE_DAY DISABLE';
		END IF;

  UPDATE FCST_STORAGE_DAY SET SCENARIO_ID = LV2_OBJECT_ID_CURSOR WHERE SCENARIO_ID IS NULL;
  
   SELECT COUNT(*) INTO HASENTRY FROM USER_TRIGGERS 
		WHERE TRIGGER_NAME = 'IU_FCST_STORAGE_DAY'; 
		IF HASENTRY > 0 THEN 
		EXECUTE IMMEDIATE 'ALTER TRIGGER IU_FCST_STORAGE_DAY ENABLE';
		END IF;
		
EXCEPTION
WHEN OTHERS THEN 	
	IF HASENTRY > 0 THEN 
        EXECUTE IMMEDIATE 'ALTER TRIGGER IU_FCST_STORAGE_DAY ENABLE';
    END IF;    
        raise_application_error(-20000,'ERROR: Some Other fatal error occured :- '||SQLERRM);
END;
--~^UTDELIM^~--