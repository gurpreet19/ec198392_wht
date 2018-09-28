
BEGIN
     FOR ec IN (SELECT OBJECT_NAME FROM user_objects WHERE object_type IN ('PACKAGE') AND object_name LIKE 'RP_%' 
          )LOOP
        
        EXECUTE IMMEDIATE 'DROP PACKAGE ' || ec.OBJECT_NAME;
     
     END LOOP;
     
END; 
/
