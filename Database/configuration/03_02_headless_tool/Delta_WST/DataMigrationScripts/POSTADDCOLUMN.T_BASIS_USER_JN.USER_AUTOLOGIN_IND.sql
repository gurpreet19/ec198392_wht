-- MOVE DATA
--	UPDATE T_BASIS_USER_JN SET USER_AUTOLOGIN_IND = PKI_SSO_IND ;
DECLARE 
HASENTRY NUMBER;
BEGIN
  	SELECT COUNT(*) INTO HASENTRY FROM USER_TRIGGERS 
		WHERE TRIGGER_NAME = 'IU_T_BASIS_USER_JN'; 
		IF HASENTRY > 0 THEN 
		EXECUTE IMMEDIATE 'ALTER TRIGGER IU_T_BASIS_USER_JN DISABLE';
		END IF;
		
	FOR X IN ( SELECT COUNT(*) CNT FROM DUAL WHERE EXISTS 
		( SELECT 1 FROM USER_TAB_COLUMNS WHERE TABLE_NAME = 'T_BASIS_USER_JN' AND COLUMN_NAME = 'PKI_SSO_IND' ) ) LOOP
		IF ( X.CNT = 1 ) THEN
			EXECUTE IMMEDIATE 'UPDATE T_BASIS_USER_JN SET USER_AUTOLOGIN_IND = PKI_SSO_IND';
		END IF;
	END LOOP;
	
	SELECT COUNT(*) INTO HASENTRY FROM USER_TRIGGERS 
		WHERE TRIGGER_NAME = 'IU_T_BASIS_USER_JN'; 
		IF HASENTRY > 0 THEN 
		EXECUTE IMMEDIATE 'ALTER TRIGGER IU_T_BASIS_USER_JN ENABLE';
		END IF;
EXCEPTION
   WHEN OTHERS 
     THEN

       IF HASENTRY > 0 THEN 
           EXECUTE IMMEDIATE 'ALTER TRIGGER IU_T_BASIS_USER_JN ENABLE';
       END IF;
        
        raise_application_error(-20000,
                            'ERROR: Some Other fatal error occured :- '||SQLERRM);


END;
--~^UTDELIM^~--