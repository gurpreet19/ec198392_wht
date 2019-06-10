-- Test whether there are invalid packages in the database
prompt Test whether there are invalid packages in the database

SELECT '------------------------------------------------------------------' TEXT FROM DUAL
UNION ALL
SELECT
   'Number of invalid objects in the database are : ' || count(*) TEXT
FROM 
   user_objects
WHERE 
   status = 'INVALID'
   AND object_type IN ('PACKAGE', 'PACKAGE BODY', 'VIEW', 'TRIGGER')
UNION ALL
SELECT '------------------------------------------------------------------' TEXT FROM DUAL
;

SELECT '------------------------------------------------------------------' TEXT FROM DUAL
UNION ALL
SELECT '-- Invalid object are   ------------------------------------------' TEXT FROM DUAL
UNION ALL
SELECT '------------------------------------------------------------------' TEXT FROM DUAL
UNION ALL
SELECT
   'ORA-INVALID OBJECTS : ' || object_name || ' ' || subobject_name || ' ' || object_type TEXT
FROM 
   user_objects
WHERE 
   status = 'INVALID'
   AND object_type IN ('PACKAGE', 'PACKAGE BODY', 'VIEW', 'TRIGGER')
UNION ALL
SELECT '------------------------------------------------------------------' TEXT FROM DUAL
;
