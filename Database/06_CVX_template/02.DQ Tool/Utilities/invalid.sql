PROMPT Recompiling Invalid Objects

DELETE FROM t_temptext
WHERE id LIKE 'INVALIDOBJECTS%';

-- Get invalid objects 
INSERT INTO t_temptext(id, line_number, text)
SELECT 'INVALIDOBJECTS2' AS id, ROWNUM AS line_number,
'alter package ' || object_name || ' compile' || chr(10) AS AlterStatement
FROM user_objects
WHERE status = 'INVALID'
AND object_type = 'PACKAGE'
UNION ALL
SELECT 'INVALIDOBJECTS3' AS id, ROWNUM AS line_number,
'alter package ' || object_name || ' compile body' || chr(10) AS AlterStatement
FROM user_objects
WHERE status = 'INVALID'
AND object_type = 'PACKAGE BODY'
UNION ALL
SELECT 'INVALIDOBJECTS4' AS id, ROWNUM AS line_number, 
'alter view ' || object_name || ' compile' AS AlterStatement
FROM user_objects
WHERE status = 'INVALID'
AND object_type = 'VIEW'
UNION ALL
SELECT 'INVALIDOBJECTS1' AS id, ROWNUM AS line_number, 
'alter trigger ' || object_name || ' compile' AS AlterStatement
FROM user_objects
WHERE status = 'INVALID'
AND object_type = 'TRIGGER';

-- Compile invalid objects

DECLARE

   CURSOR c_invalid_obj IS
   SELECT text FROM t_temptext WHERE id LIKE 'INVALIDOBJECTS%'
   ORDER BY id;
   
   lv2_sql      VARCHAR2(2000);
   ln_counter   NUMBER DEFAULT 0;

BEGIN   
   
   FOR curInv IN c_invalid_obj LOOP
      
      lv2_sql := curInv.text; 
      ln_counter := ln_counter + 1;
      
      BEGIN   
         EXECUTE IMMEDIATE lv2_sql;       
      EXCEPTION
        WHEN OTHERS THEN
        lv2_sql := NULL;
      END;           
  
   END LOOP;

END;
/
