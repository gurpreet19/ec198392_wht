SET SERVEROUTPUT ON;

begin
  for c in (SELECT * FROM USER_OBJECTS
					WHERE OBJECT_NAME IN (
				WITH DELETE_OBJECTS AS (
				  SELECT * FROM U_CLASS_CNFG C WHERE NOT EXISTS (SELECT 1 FROM CLASS_CNFG CC WHERE C.CLASS_NAME = CC.CLASS_NAME)
				)
				SELECT 
				CASE CLASS_TYPE
					WHEN 'OBJECT' THEN 'OV_'
					WHEN 'DATA' THEN 'DV_'
					WHEN 'TABLE' THEN 'TV_'
					WHEN 'INTERFACE' THEN 'IV_' END  || CLASS_NAME VIEW_NAME
				  FROM DELETE_OBJECTS 
				UNION ALL
				  SELECT
				  CASE CLASS_TYPE
					WHEN 'OBJECT' THEN 'OV_'
					WHEN 'DATA' THEN 'DV_'
					WHEN 'TABLE' THEN 'TV_'
					WHEN 'INTERFACE' THEN 'IV_' END  || CLASS_NAME || '_JN' VIEW_NAME
				  FROM  DELETE_OBJECTS
				UNION ALL 
				 SELECT 'RV_' || CLASS_NAME VIEW_NAME FROM DELETE_OBJECTS 
				UNION ALL 
				 SELECT 'EV_' || CLASS_NAME VIEW_NAME FROM  DELETE_OBJECTS
				UNION ALL
				 SELECT 
				  CASE CLASS_TYPE 
					WHEN 'OBJECT' THEN 
					'IUD_' 
					WHEN 'DATA' THEN 
					'IUD_' 
					WHEN 'TABLE' THEN 
					'IUV_' 
					WHEN 'INTERFACE' THEN 
					'IUD_' 
					END || CLASS_NAME TRIGGER_NAME FROM DELETE_OBJECTS  
				UNION ALL 
				  SELECT 'IUR_' || CLASS_NAME TRIGGER_NAME FROM DELETE_OBJECTS  
				UNION ALL   
				  SELECT 'AP_' || CLASS_NAME TRIGGER_NAME FROM DELETE_OBJECTS 
				UNION ALL 
				  SELECT 'JN_' || CLASS_NAME TRIGGER_NAME FROM  DELETE_OBJECTS 
				UNION ALL 
				  SELECT 'ECTP_' || CLASS_NAME PACKAGE_NAME FROM  DELETE_OBJECTS
				UNION ALL 
				  SELECT 'EC4E_' || CLASS_NAME PACKAGE_NAME FROM  DELETE_OBJECTS
				 UNION ALL 
				  SELECT 'ECCP_' || CLASS_NAME PACKAGE_NAME FROM  DELETE_OBJECTS
			)) loop
    for obj in (select * from user_objects where object_name = c.object_name)
      loop
	  BEGIN
		dbms_output.put_line('Dropping unused; '||obj.object_name);
		EXECUTE IMMEDIATE 'DROP ' || obj.object_type || ' ' || obj.object_name;
		EXCEPTION
			WHEN OTHERS THEN
			dbms_output.put_line('Dropping unused; skipping '||obj.object_name);
			--EcDp_DynSql.writetemptext('UPGRADE_PREUPGRADE', 'Dropping unused; skipping : [' || obj.object_name || ']');			
	  END;
    end loop;
  end loop;
end;
/

begin
  for c in (SELECT * FROM USER_OBJECTS
					WHERE OBJECT_NAME IN (
				WITH DELETE_OBJECTS AS (
				  SELECT * FROM U_CLASS_CNFG C WHERE EXISTS (SELECT 1 FROM CLASS_CNFG CC WHERE C.CLASS_NAME = CC.CLASS_NAME and c.class_type != cc.class_type)
				)
				SELECT 
				CASE CLASS_TYPE
					WHEN 'OBJECT' THEN 'OV_'
					WHEN 'DATA' THEN 'DV_'
					WHEN 'TABLE' THEN 'TV_'
					WHEN 'INTERFACE' THEN 'IV_' END  || CLASS_NAME VIEW_NAME
				  FROM DELETE_OBJECTS 
				UNION ALL
				  SELECT
				  CASE CLASS_TYPE
					WHEN 'OBJECT' THEN 'OV_'
					WHEN 'DATA' THEN 'DV_'
					WHEN 'TABLE' THEN 'TV_'
					WHEN 'INTERFACE' THEN 'IV_' END  || CLASS_NAME || '_JN' VIEW_NAME
				  FROM  DELETE_OBJECTS				
				UNION ALL
				 SELECT 
				  CASE CLASS_TYPE 
					WHEN 'OBJECT' THEN 
					'IUD_' 
					WHEN 'DATA' THEN 
					'IUD_' 
					WHEN 'TABLE' THEN 
					'IUV_' 
					WHEN 'INTERFACE' THEN 
					'IUD_' 
					END || CLASS_NAME TRIGGER_NAME FROM DELETE_OBJECTS  				
			)) loop
    for obj in (select * from user_objects where object_name = c.object_name)
      loop
	  BEGIN
		dbms_output.put_line('Dropping unused; '||obj.object_name);
		EXECUTE IMMEDIATE 'DROP ' || obj.object_type || ' ' || obj.object_name;
		EXCEPTION
			WHEN OTHERS THEN
			dbms_output.put_line('Dropping unused; skipping '||obj.object_name);
			--EcDp_DynSql.writetemptext('UPGRADE_PREUPGRADE', 'Dropping unused; skipping : [' || obj.object_name || ']');			
	  END;
    end loop;
  end loop;
end;
/


begin
  for c in (select *
              from user_objects
			 where object_name in (
				'TV_CLASS_ACL_JN',
				'TV_CLASS_ATTRIBUTE_JN',
				'TV_CLASS_ATTR_DB_MAPPING_JN',
				'TV_CLASS_ATTR_PRESENTATION_JN',
				'TV_CLASS_DB_MAPPING_JN',
				'TV_CLASS_DEPENDENCY_JN',
				'TV_CLASS_JN',
				'TV_CLASS_RELATION_ACL_JN',
				'TV_CLASS_RELATION_JN',
				'TV_CLASS_REL_DB_MAPPING_JN',
				'TV_CLASS_REL_PRESENTATION_JN',
				'TV_CLASS_TRIGGER_ACTION_JN',
				'TV_GROUP_MODEL_JN',
				'TV_GROUP_MODEL_PRESENTATION_JN',
				'TV_GROUP_TYPE_JN',
				'TV_ONLINE_HELP_CLASS_ATTR_JN',
				'TV_ONLINE_HELP_CLASS_ATT_DB_JN',
				'TV_ONLINE_HELP_CLASS_JN',
				'TV_ONLINE_HELP_TRIGGER_ACT_JN',
				'EC_CLASS_ATTR_PRES_CONFIG',
				'JN_CLASS_ATTR_PRES_CONFIG')) loop
    for obj in (select * from user_objects where object_name = c.object_name)
      loop
	  BEGIN
		dbms_output.put_line('Dropping unused; '||obj.object_name);
		EXECUTE IMMEDIATE 'DROP ' || obj.object_type || ' ' || obj.object_name;
		EXCEPTION
			WHEN OTHERS THEN
			dbms_output.put_line('Dropping unused; skipping '||obj.object_name);
			-- EcDp_DynSql.writetemptext('UPGRADE_PREUPGRADE', 'Dropping unused; skipping : [' || obj.object_name || ']');
		
	  END;
    end loop;
  end loop;
end;
/