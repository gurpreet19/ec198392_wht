DECLARE
    lv2_operation  VARCHAR2(100) := '&operation';
BEGIN
	-- The owner name in the Oracle dictionary is in upper case, hence UPPER function is used. Get operation name. 
    lv2_operation := 'ECKERNEL_' || UPPER(lv2_operation); 
   
    -- for loop which creates synonyms for particular operation   
    FOR cur_rec IN ( 					
						WITH 
						object_data AS ( SELECT object_name, object_type 
										   FROM all_objects 
										   WHERE owner = lv2_operation
										   AND object_type IN ('PACKAGE','VIEW','TABLE','SEQUENCE','TYPE')
										   AND object_name not like 'MLOG$%'
										   AND object_name not like 'BIN$%'	 ),
						object_synonyms AS ( SELECT synonym_name
											 FROM user_synonyms 
											 WHERE  table_owner = lv2_operation ) 
						SELECT 'CREATE SYNONYM  ' ||  a.object_name || ' FOR ' || lv2_operation || '.' || a.object_name AS text  
						FROM object_data a
						WHERE NOT EXISTS (	SELECT 1 FROM object_synonyms us  WHERE us.synonym_name = a.object_name )
						UNION ALL
						SELECT 'DROP SYNONYM  ' || us.synonym_name AS text
						FROM object_synonyms us
						WHERE NOT EXISTS ( 	SELECT 1 FROM object_data a WHERE a.object_name = us.synonym_name  )
					)   
	LOOP
	  BEGIN
		 EXECUTE IMMEDIATE cur_rec.text;
	  EXCEPTION
		 WHEN OTHERS THEN
		  raise_application_error(-20000, 'Error when executing "sync_private_synonyms.sql". --- Create/Drop Synonym Error List --- ' || chr(10) || SUBSTR('Statement: [' || cur_rec.text || ']. Error msg: [' || SQLERRM || ']' , 1, 32767));
	  END;
    END LOOP;
END;
