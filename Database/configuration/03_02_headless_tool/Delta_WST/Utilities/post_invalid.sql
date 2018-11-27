DECLARE
	cnt NUMBER;
BEGIN
  --Purge recycle bin to clear dropped database objects
  EXECUTE IMMEDIATE 'PURGE RECYCLEBIN';
  
  -- Compile invalid objects
  FOR curInv IN ( SELECT (CASE WHEN object_type = 'TYPE' THEN 0 
             WHEN object_type = 'TYPE' OR object_type = 'TYPE BODY' THEN 1
             WHEN object_type = 'TRIGGER' THEN 2
             WHEN object_type = 'PACKAGE' THEN 3
             WHEN object_type = 'PACKAGE BODY' THEN 4 
             ELSE 5   -- WHEN object_type = 'VIEW' 
        END) AS id
        , (CASE WHEN object_type = 'PACKAGE BODY' THEN  'ALTER PACKAGE ' || object_name || ' COMPILE BODY '
               WHEN object_type = 'TYPE BODY' THEN  'ALTER TYPE ' || object_name || ' COMPILE BODY '
               ELSE 'ALTER ' || object_type || ' ' || object_name || ' COMPILE ' 
             END )  AS text
  FROM user_objects
  WHERE status = 'INVALID' 	        AND 
  object_type IN ('PACKAGE', 'PACKAGE BODY', 'VIEW', 'TRIGGER', 'TYPE', 'TYPE BODY' ) ORDER BY 1  ) 
  LOOP
      BEGIN
        EXECUTE IMMEDIATE curInv.text ;
    EXCEPTION
        WHEN OTHERS THEN
        NULL ;
    END;
  END LOOP;
  
  SELECT COUNT(*) INTO cnt FROM user_objects WHERE status = 'INVALID' AND object_type IN ('PACKAGE', 'PACKAGE BODY', 'VIEW', 'TRIGGER', 'TYPE', 'TYPE BODY' );
  
  IF cnt > 0 THEN
    RAISE_APPLICATION_ERROR(-20000, 'Error when executing "post_invalid.sql". Correct errors in packages, views and triggers.');
  END IF;
  
END;


