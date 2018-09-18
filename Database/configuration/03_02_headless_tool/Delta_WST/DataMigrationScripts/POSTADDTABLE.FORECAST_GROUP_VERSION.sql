--- From 2016070601PROD\ECPD-33739_UPGRADE_SCRIPT_4.SQL
/*
PURPOSE: 1. This upgrade script is used to move the existing forecast records from FORECAST table to FORECAST_GROUP table, 
         and FORECAST_VERSION table to FORECAST_GROUP_VERSION table.
		 2. Remove existing records from FORECAST and FORECAST_VERSION

		 
IMPORTANT NOTES:
         1. The column FORECAST_GROUP.FORECAST_TYPE	is mandatory in FORECAST_GROUP. 
		    But FORECAST.FORECAST_TYPE column is NULLABLE,hence to avoid runtime ORA Error NVL is added. 
			Here FORECAST_GROUP.FORECAST_TYPE is inserted with space if value is null, in order to update the record with required value use below update command.
			
			UPDATE FORECAST_GROUP
			SET FORECAST_TYPE ='REQUIRED VALUE'
			WHERE OBJECT_ID = 'REQUIRED OBJECT_ID'
			
         2. The column FORECAST_GROUP.END_DATE	is mandatory i.e. NOT NULL in FORECAST_GROUP. 
		    But FORECAST.END_DATE column is NULLABLE,hence to avoid runtime ORA Error NVL is added. 
			Here FORECAST_GROUP.END_DATE is inserted with DATE after one year from START_DATE if value is null, i
			n order to update the record with required value use below update command.
			
			UPDATE FORECAST_GROUP
			SET END_DATE ='REQUIRED DATE'
			WHERE OBJECT_ID = 'REQUIRED OBJECT_ID'		

         3. Records from FORECAST_VERSION are removed first before FORECAST to avoid DELETE failure because of Constraints		

         4. The upgrade script is re-runnable.		 
*/

-- Insert records from FORECAST table to FORECAST_GROUP for existing forecast records.
BEGIN
	INSERT INTO FORECAST_GROUP
			( OBJECT_ID,
			 OBJECT_CODE,
			 FORECAST_TYPE,
			 FORECAST_PERIOD,
			 START_DATE,
			 END_DATE,
			 DESCRIPTION,
			 CREATED_BY,
			 CREATED_DATE,
			 REV_NO)
	SELECT   F.OBJECT_ID,
			 F.OBJECT_CODE,
			 NVL(F.FORECAST_TYPE, ' '), -- Refer note 1
			 F.PERIOD_TYPE,
			 F.START_DATE,
			 NVL(F.END_DATE, add_months(F.START_DATE, 12)), -- Refer note 2
			 F.DESCRIPTION,
			 User,
			 sysdate,
			 0
	FROM  FORECAST F
	WHERE F.CLASS_NAME = 'FORECAST_PROD'
	AND   NOT EXISTS ( SELECT 1
					   FROM FORECAST_GROUP
					   WHERE OBJECT_ID = F.OBJECT_ID );
END;
--~^UTDELIM^~--	

-- Insert records from FORECAST_VERSION table to FORECAST_GROUP_VERSION for existing forecast records.	
BEGIN
 INSERT INTO FORECAST_GROUP_VERSION
 (  OBJECT_ID  
	,NAME 
	,DAYTIME  
	,END_DATE
	,OFFICIAL 
	,FORECAST_STATUS 
	,COMMENTS 
	,TEXT_1  
	,TEXT_2  
	,TEXT_3  
	,TEXT_4  
	,TEXT_5  
	,TEXT_6  
	,TEXT_7  
	,TEXT_8  
	,TEXT_9  
	,TEXT_10 
	,VALUE_1  
	,VALUE_2  
	,VALUE_3  
	,VALUE_4  
	,VALUE_5  
	,DATE_1 
	,DATE_2 
	,DATE_3 
	,DATE_4 
	,DATE_5 
    ,REF_OBJECT_ID_1 
    ,REF_OBJECT_ID_2 
    ,REF_OBJECT_ID_3 
    ,REF_OBJECT_ID_4 
    ,REF_OBJECT_ID_5
	,RECORD_STATUS
	,CREATED_BY
	,CREATED_DATE
	,REV_NO  )
SELECT  OBJECT_ID  
	,NAME 
	,DAYTIME  
	,END_DATE
	,OFFICIAL_IND 
	,FORECAST_STATUS 
	,COMMENTS 
	,TEXT_1  
	,TEXT_2  
	,TEXT_3  
	,TEXT_4  
	,TEXT_5  
	,TEXT_6  
	,TEXT_7  
	,TEXT_8  
	,TEXT_9  
	,TEXT_10 
	,VALUE_1  
	,VALUE_2  
	,VALUE_3  
	,VALUE_4  
	,VALUE_5  
	,DATE_1 
	,DATE_2 
	,DATE_3 
	,DATE_4 
	,DATE_5 
	,REF_OBJECT_ID_1 
	,REF_OBJECT_ID_2 
	,REF_OBJECT_ID_3 
	,REF_OBJECT_ID_4 
	,REF_OBJECT_ID_5 
	,'P'
	,User
	,sysdate
	,0
FROM FORECAST_VERSION 
WHERE EXISTS ( SELECT 1 
               FROM FORECAST 
               WHERE FORECAST.OBJECT_ID = FORECAST_VERSION.OBJECT_ID 
               AND CLASS_NAME='FORECAST_PROD' )   
AND   NOT EXISTS (  SELECT 1
					FROM FORECAST_GROUP_VERSION
					WHERE OBJECT_ID = FORECAST_VERSION.OBJECT_ID );
END;	
--~^UTDELIM^~--	 

--FRom 2016062001PROD\01_ECPD_35846_ALTER_TABLES.sql
DECLARE
	LV2_OBJECT_ID VARCHAR2(50);
BEGIN
	LV2_OBJECT_ID := SYS_GUID();
	
	INSERT INTO FORECAST_GROUP (OBJECT_ID, OBJECT_CODE, FORECAST_TYPE, START_DATE, END_DATE, CREATED_BY, CREATED_DATE)
	VALUES (LV2_OBJECT_ID, 'ECFORECAST', 'FORECAST', TO_DATE('01-01-2010', 'DD-MM-YYYY'), TO_DATE('01-01-2025', 'DD-MM-YYYY'), 'User', SYSDATE);

	INSERT INTO FORECAST_GROUP_VERSION (OBJECT_ID, NAME, DAYTIME, END_DATE, CREATED_BY, CREATED_DATE)
	VALUES (LV2_OBJECT_ID, 'EC Forecast', TO_DATE('01-01-2010', 'DD-MM-YYYY'), TO_DATE('01-01-2025', 'DD-MM-YYYY'),'User', SYSDATE);

END;
--~^UTDELIM^~--