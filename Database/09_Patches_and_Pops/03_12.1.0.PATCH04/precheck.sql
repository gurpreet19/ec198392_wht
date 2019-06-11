/**
The script below will automatically detect if customer-specific changes will be overwritten
by the service pack scripts.
Check the file precheck_result.csv generated by this script. The file is in CSV format, which can
be opened with Microsoft Excel or any text editor.
If any row exists in the result, please check for the changes on the listed item.
For table content changes (except for new insert), do the following:

SELECT ecdp_pinc.getLiveSRC(T1.TYPE, T1.NAME, T1.TABLE_PK) "CURRENT SOURCE",
       ecdp_pinc.getLiveMd5(T1.TYPE, T1.NAME, T1.TABLE_PK) "CURRENT MD5",
       T1.OBJECT "EXPECTED SOURCE",
       t1.MD5SUM "EXPECTED MD5"
  FROM CTRL_PINC T1
 WHERE t1.TYPE = 'TABLE CONTENT'
   AND t1.name = '<Object Name>'
   and t1.table_pk = '<Table PK>'/'<ALTERNATE TABLE PK>'
   AND t1.daytime = (SELECT MAX(t2.daytime)
                       FROM ctrl_pinc t2
                      WHERE t2.type = t1.type
                        AND t2.name = t1.name
                        AND t2.table_pk = t1.table_pk
                        AND tag IS NOT NULL
                        AND tag NOT LIKE '12.1.0.PATCH04%')

Note that column "CURRENT SOURCE" and "EXPECTED SOURCE" is BLOB with text content. Please use
respective BLOB viewer to view the content.

For the actual sql script that perform the insert/update/delete action, please refer to the
service pack folder. Use Operating System's search facility.

For other objects (triggers, views, packages, tables, indexes)

SELECT ecdp_pinc.getLiveSRC(T1.TYPE, T1.NAME) "CURRENT SOURCE",
       ecdp_pinc.getLiveMd5(T1.TYPE, T1.NAME) "CURRENT MD5",
       T1.OBJECT "EXPECTED SOURCE",
       t1.MD5SUM "EXPECTED MD5"
  FROM CTRL_PINC T1
 WHERE t1.TYPE = '<Object Type>'
   AND t1.name = '<Object Name>'
   AND t1.daytime = (SELECT MAX(t2.daytime)
                       FROM ctrl_pinc t2
                      WHERE t2.type = t1.type
                        AND t2.name = t1.name
                        AND tag IS NOT NULL
                        AND tag NOT LIKE '12.1.0.PATCH04%')

Note that column "CURRENT SOURCE" and "EXPECTED SOURCE" is BLOB with text content. Please use
respective BLOB viewer to view the content.

For the actual sql script that perform update on the object, please refer to the service pack folder.
Use Operating System search facility.

------------------
ERRORS HANDLED
------------------

IF the database is imported from dump file with different username, one should change column
class_db_mapping.db_object_owner. When this is done, a number of error will be listed in precheck log for
the table. The error with name "CLASS_DB_MAPPING" then may be ignored.

IF the database is imported from a dump file with different character set that causing automatic
characterset conversion, the content of the object's source may change. This will cause the live
md5 calculation to be different than expected. If this is the case, one may expect a number of
false entry in the precheck log.

**/
WHENEVER OSERROR EXIT -1
WHENEVER SQLERROR EXIT SQL.SQLCODE

set long 9999
set heading off
set verify off
set feedback off
set echo off
set pagesize 9999
set lines 32000
set trimspool on
spool .\12.1.0.PATCH04_precheck_result.csv

SELECT '"EC VERSION",,,,' || DECODE((SELECT count(1) AS ln_count FROM CTRL_DB_VERSION WHERE DESCRIPTION='12.1.0.PATCH03'), 0, '"EC version is incorrect. Found ' ||  (select description from ctrl_db_version) || ', expecting 12.1.0.PATCH03"', '"EC Version is OK"') FROM dual;

--spool off(append)
spool off
set heading on
set verify on
set feedback on

DECLARE
lv_description varchar2(4000) := '12.1.0.PATCH03';        
lv_current_description varchar2(4000);

BEGIN
SELECT DESCRIPTION INTO lv_current_description from CTRL_DB_VERSION;

IF (lv_current_description <> lv_description) THEN
raise_application_error(-20643, 'EC version is incorrect'); 
END IF;
END;
/
			
ALTER TRIGGER ddl_eckernel DISABLE;

-- return Y if object updated
CREATE OR REPLACE FUNCTION isObjectUpdated(p_tag VARCHAR2, p_type VARCHAR2, p_name VARCHAR2)
RETURN VARCHAR2
IS
    ld_prev_tag_date DATE;
    ld_object_date DATE;
    ln_count NUMBER;
    
	CURSOR c_get_date IS
		SELECT daytime FROM ctrl_pinc
		WHERE type=p_type
		AND name=p_name
		--AND Nvl(table_pk, 'N')=Nvl(p_table_pk, 'N')
		AND tag IS NOT NULL
		--AND tag <> p_tag
		ORDER BY daytime DESC;

	CURSOR c_get_object_date(cp_prev_tag_date DATE) IS
		SELECT daytime FROM ctrl_pinc
		WHERE type=p_type
		AND name=p_name
		AND daytime > Nvl(cp_prev_tag_date, TO_DATE('1900-01-01', 'yyyy-mm-dd'))
		AND not (type='TABLE' and operation in ('TRUNCATE','ANALYZE') )
		--AND tag IS NULL
		--AND tag <> p_tag
		ORDER BY daytime DESC;

BEGIN
    ld_object_date := NULL;

    FOR one IN c_get_date LOOP
        ld_prev_tag_date := one.daytime;
        EXIT;
    END LOOP;

    FOR two IN c_get_object_date(ld_prev_tag_date) LOOP
        ld_object_date :=two.daytime;
        EXIT;
    END LOOP;

    IF Nvl(ld_object_date, TO_DATE('1900-01-01', 'yyyy-mm-dd')) > Nvl(ld_prev_tag_date, TO_DATE('1900-01-01', 'yyyy-mm-dd')) THEN
        RETURN 'Y';
    END IF;

    RETURN 'N';

END isObjectUpdated;
/

CREATE OR REPLACE FUNCTION convertOPToServerTimeZone(p_datetime DATE) 
RETURN DATE
--</EC-DOC>
IS

  lv2_db_time_zone VARCHAR2(100);
  lv2_op_time_zone VARCHAR2(100);
  
  cursor c_timezone is
  select pref_verdi from t_preferanse where pref_id = 'TIME_ZONE_REGION';
  
  CURSOR c_tz IS
  SELECT cast (dbtimezone AS VARCHAR2(100)) tz_string FROM dual;


BEGIN
  FOR cur_rec IN c_tz LOOP
    lv2_db_time_zone := cur_rec.tz_string;
  END LOOP;

  FOR curTZ in c_timezone LOOP
    lv2_op_time_zone := curTZ.pref_verdi; 
  END LOOP;
  
    RETURN p_datetime + (ecdp_date_time.getTZoffsetInDays(tz_offset(lv2_db_time_zone))- ecdp_date_time.getTZoffsetInDays(tz_offset(lv2_op_time_zone)));

END ConvertOPToServerTimeZone;
/

CREATE GLOBAL TEMPORARY TABLE t_ctrl_pinc
(
  tag VARCHAR2(32),
  type VARCHAR2(30),
  name VARCHAR2(240),
  md5sum VARCHAR2(32),
  table_pk VARCHAR2(2000),
  alt_table_pk VARCHAR2(2000),
  ref_rowid varchar2(100),
  ref_last_updated_date DATE,
  result VARCHAR2(2000),
  status VARCHAR2(10)
)
ON COMMIT DELETE ROWS
/

CREATE GLOBAL TEMPORARY TABLE t_table_content_pinc_row
(
  name VARCHAR2(240),
  table_pk VARCHAR2(2000),
  ref_rowid varchar2(100),
  pinc_daytime  DATE 
)
ON COMMIT DELETE ROWS
/

CREATE GLOBAL TEMPORARY TABLE INSERT_CLASS_CNFG
(
  TABLE_NAME VARCHAR2(240),
  CLASS_NAME VARCHAR2(240),
  ATTRIBUTE_NAME VARCHAR2(240),
  FROM_CLASS_NAME VARCHAR2(240),
  ROLE_NAME VARCHAR2(240),
  TO_CLASS_NAME VARCHAR2(240),
  SORT_ORDER VARCHAR2(240),
  TRIGGER_TYPE VARCHAR2(240),       
  TRIGGERING_EVENT VARCHAR2(240),
  CHILD_CLASS VARCHAR2(240),
  DEPENDENCY_TYPE VARCHAR2(240),
  PARENT_CLASS VARCHAR2(240)
)
ON COMMIT DELETE ROWS
/

@utils\load_pinc_list.sql
@utils\load_class_changes.sql

DECLARE
  lv_md5 VARCHAR2(32);
  lv_prev_md5 VARCHAR2(32);
  lv_tag VARCHAR2(32);
  lv_indexname VARCHAR2(30) := NULL;
  l_count INTEGER;

  CURSOR c_ctrl_pinc IS
    	SELECT * FROM t_ctrl_pinc WHERE type <> 'TABLE CONTENT' ORDER BY type, name
    FOR UPDATE;

  CURSOR c_index (cp_indexname VARCHAR2) IS
        SELECT index_name INTO lv_indexname FROM user_indexes WHERE index_name=cp_indexname;
BEGIN
    -- one.md5sum is null = expecting no record, lv_md5 <> 'N/A' = record exist in customer db
  FOR one IN c_ctrl_pinc LOOP
	IF one.type = 'VIEW' THEN
		-- for view, N/A is first time and loaded, null is completely new.. buggy
		IF isObjectUpdated(one.tag, one.type, one.name) = 'Y' THEN
			IF one.STATUS = 'NEW' THEN
				UPDATE t_ctrl_pinc SET result = 'View has already added by customer. The script will overwrite it.' WHERE CURRENT OF c_ctrl_pinc;
			ELSE
				SELECT COUNT(*) INTO l_count FROM USER_OBJECTS
				WHERE OBJECT_NAME = one.name;
				IF l_count = 0 THEN
					UPDATE t_ctrl_pinc SET result = 'View has unexpectedly dropped/deleted by customer.' WHERE CURRENT OF c_ctrl_pinc;
				ELSE
					UPDATE t_ctrl_pinc SET result = 'View has been modified by customer. The script will overwrite it.' WHERE CURRENT OF c_ctrl_pinc;
				END IF;
			END IF;
		END IF;
	ELSIF one.type = 'TRIGGER' THEN
		IF isObjectUpdated(one.tag, one.type, one.name) = 'Y' THEN
			IF one.STATUS = 'NEW' THEN
				UPDATE t_ctrl_pinc SET result = 'Trigger has already added by customer. The script will overwrite it.' WHERE CURRENT OF c_ctrl_pinc;
			ELSE
				SELECT COUNT(*) INTO l_count FROM USER_OBJECTS
				WHERE OBJECT_NAME = one.name;
				IF l_count = 0 THEN
					UPDATE t_ctrl_pinc SET result = 'Triggeer has unexpectedly dropped/deleted by customer.' WHERE CURRENT OF c_ctrl_pinc;
				ELSE
					UPDATE t_ctrl_pinc SET result = 'Trigger has been modified by customer. The script will overwrite it.' WHERE CURRENT OF c_ctrl_pinc;
				END IF;
			END IF;
		END IF;
	ELSIF one.type = 'PACKAGE' THEN
		IF isObjectUpdated(one.tag, one.type, one.name) = 'Y' THEN
			IF one.STATUS = 'NEW' THEN
				UPDATE t_ctrl_pinc SET result = 'Package has already added by customer. The script will overwrite it.' WHERE CURRENT OF c_ctrl_pinc;
			ELSE
				SELECT COUNT(*) INTO l_count FROM USER_OBJECTS
				WHERE OBJECT_NAME = one.name;
				IF l_count = 0 THEN
					UPDATE t_ctrl_pinc SET result = 'Package has unexpectedly dropped/deleted by customer.' WHERE CURRENT OF c_ctrl_pinc;
				ELSE
					UPDATE t_ctrl_pinc SET result = 'Package has been modified by customer. The script will overwrite it.' WHERE CURRENT OF c_ctrl_pinc;
				END IF;
	      	END IF;
		END IF;
	ELSIF one.type = 'PACKAGE BODY' THEN
		IF isObjectUpdated(one.tag, one.type, one.name) = 'Y' THEN
			IF one.STATUS = 'NEW' THEN
				UPDATE t_ctrl_pinc SET result = 'Package Body has already added by customer. The script will overwrite it.' WHERE CURRENT OF c_ctrl_pinc;
      		ELSE
				SELECT COUNT(*) INTO l_count FROM USER_OBJECTS
				WHERE OBJECT_NAME = one.name;
				IF l_count = 0 THEN
					UPDATE t_ctrl_pinc SET result = 'Package Body has unexpectedly dropped/deleted by customer.' WHERE CURRENT OF c_ctrl_pinc;
				ELSE
					UPDATE t_ctrl_pinc SET result = 'Package Body has been modified by customer. The script will overwrite it.' WHERE CURRENT OF c_ctrl_pinc;
				END IF;
        	END IF;
		END IF;
	ELSIF one.type = 'SEQUENCE' THEN
		IF isObjectUpdated(one.tag, one.type, one.name) = 'Y' THEN
			IF one.STATUS = 'NEW' THEN
        			UPDATE t_ctrl_pinc SET result = 'Sequence has already added by customer.' WHERE CURRENT OF c_ctrl_pinc;
      		ELSE
				SELECT COUNT(*) INTO l_count FROM USER_OBJECTS
				WHERE OBJECT_NAME = one.name;
				IF l_count = 0 THEN
					UPDATE t_ctrl_pinc SET result = 'Sequence has unexpectedly dropped/deleted by customer.' WHERE CURRENT OF c_ctrl_pinc;
				ELSE
					UPDATE t_ctrl_pinc SET result = 'Sequence has been modified by customer. The script will overwrite it.' WHERE CURRENT OF c_ctrl_pinc;
				END IF;
			END IF;
		END IF;
	ELSIF one.type = 'TYPE' THEN
		IF isObjectUpdated(one.tag, one.type, one.name) = 'Y' THEN
			IF one.STATUS = 'NEW' THEN
				UPDATE t_ctrl_pinc SET result = 'Type has already added by customer.' WHERE CURRENT OF c_ctrl_pinc;
			ELSE
				SELECT COUNT(*) INTO l_count FROM USER_OBJECTS
				WHERE OBJECT_NAME = one.name;
				IF l_count = 0 THEN
					UPDATE t_ctrl_pinc SET result = 'Type has unexpectedly dropped/deleted by customer.' WHERE CURRENT OF c_ctrl_pinc;
				ELSE
					UPDATE t_ctrl_pinc SET result = 'Type has been modified by customer. The script will overwrite it.' WHERE CURRENT OF c_ctrl_pinc;
				END IF;
			END IF;
		END IF;
	ELSIF one.type = 'TYPE BODY' THEN
		IF isObjectUpdated(one.tag, one.type, one.name) = 'Y' THEN
			IF one.STATUS = 'NEW' THEN
				UPDATE t_ctrl_pinc SET result = 'Type Body has already added by customer.' WHERE CURRENT OF c_ctrl_pinc;
			ELSE
				SELECT COUNT(*) INTO l_count FROM USER_OBJECTS
				WHERE OBJECT_NAME = one.name;
				IF l_count = 0 THEN
					UPDATE t_ctrl_pinc SET result = 'Type Body has unexpectedly dropped/deleted by customer.' WHERE CURRENT OF c_ctrl_pinc;
				ELSE
					UPDATE t_ctrl_pinc SET result = 'Type Body has been modified by customer. The script will overwrite it.' WHERE CURRENT OF c_ctrl_pinc;
				END IF;
			END IF;
		END IF;
	ELSIF one.type = 'TABLE' THEN
		IF isObjectUpdated(one.tag, one.type, one.name) = 'Y' THEN
			IF one.STATUS = 'NEW' THEN
				UPDATE t_ctrl_pinc SET result = 'Table has already added by customer.' WHERE CURRENT OF c_ctrl_pinc;
			ELSE
				SELECT COUNT(*) INTO l_count FROM USER_OBJECTS
				WHERE OBJECT_NAME = one.name;
				IF l_count = 0 THEN
					UPDATE t_ctrl_pinc SET result = 'Table has unexpectedly dropped/deleted by customer.' WHERE CURRENT OF c_ctrl_pinc;
				ELSE
					UPDATE t_ctrl_pinc SET result = 'Table has been modified by customer. The script will overwrite it.' WHERE CURRENT OF c_ctrl_pinc;
				END IF;
			END IF;
		END IF;
	ELSIF one.type = 'INDEX' THEN
		-- not properly handled yet!
		NULL;
	END IF;
    END LOOP;

    DELETE t_temptext WHERE id LIKE 'PINC%';

    FOR one IN (SELECT result FROM t_ctrl_pinc WHERE result IS NOT NULL) LOOP
        ecdp_dynsql.writeTempText('PINC_PRECHECK', one.result);
    END LOOP;
END;
/


DELETE t_temptext WHERE id LIKE 'PRECHECK%';

DECLARE
CURSOR c_table_content_tables
IS
SELECT name, table_pk, ref_rowid, ref_last_updated_date, status
FROM t_ctrl_pinc
WHERE type='TABLE CONTENT'
and name not in ('CLASS_CNFG','CLASS_ATTRIBUTE_CNFG','CLASS_RELATION_CNFG','CLASS_TRIGGER_ACTN_CNFG','CLASS_DEPENDENCY_CNFG','CLASS_PROPERTY_CNFG','CLASS_REL_PROPERTY_CNFG','CLASS_TRA_PROPERTY_CNFG','CLASS_ATTR_PROPERTY_CNFG')
FOR UPDATE;

CURSOR c_pink_table_content
IS
SELECT name,table_pk, max(daytime) max_daytime    
FROM ctrl_pinc p
WHERE type='TABLE CONTENT'
AND tag NOT IN (SELECT DISTINCT TAG FROM t_ctrl_pinc)
AND EXISTS (SELECT 1 FROM t_ctrl_pinc t 
            WHERE T.TYPE = 'TABLE CONTENT' 
            AND t.name = p.name)
and p.daytime <= (select max(cp.daytime) from ctrl_pinc cp
                 where tag like '12.1.0.PATCH03%')
GROUP BY name, table_pk;

ln_rowid ROWID;
ld_date  DATE;
ld_pinc_date DATE;
lv_status VARCHAR2(32);
lv_sql VARCHAR2(2000);
lv_actual_table_pk VARCHAR2(2000);

BEGIN
  FOR item IN c_table_content_tables LOOP
    ln_rowid := NULL;
    ld_date := NULL;
    ld_pinc_date := NULL;
    lv_sql := 'SELECT rowid, last_updated_date FROM ' || item.name || ' WHERE ' || item.table_pk;
    
    BEGIN
      EXECUTE IMMEDIATE lv_sql INTO ln_rowid, ld_date;
    EXCEPTION 
      WHEN no_data_found THEN
        IF item.status = 'MODIFIED' THEN 
          UPDATE t_ctrl_pinc SET result = 'Record unexpectedly removed from database' WHERE CURRENT OF c_table_content_tables;
        ELSE
          -- NEW
          NULL;
        END IF;
      WHEN too_many_rows THEN
        -- Non-unique UK
        ecdp_dynsql.writeTempText('PRECHECK', 'Query for unique record returns too many rows: [' || lv_sql || ']');
        EXECUTE IMMEDIATE lv_sql || ' AND rownum = 1' INTO ln_rowid, ld_date;
      WHEN OTHERS THEN
        ecdp_dynsql.writeTempText('PRECHECK', 'Name: [' || item.name || '], ORA: [' || SQLERRM || '], lv_sql: [' || lv_sql || ']');
    END;
    IF ln_rowid IS NOT NULL AND item.status = 'NEW' THEN
      UPDATE t_ctrl_pinc SET ref_rowid = ln_rowid, ref_last_updated_date = convertOPToServerTimeZone(ld_date), result='Table Content has been added by customer. ' WHERE CURRENT OF c_table_content_tables;
    ELSIF ln_rowid IS NOT NULL AND item.status = 'MODIFIED' THEN
      UPDATE t_ctrl_pinc SET ref_rowid = ln_rowid, ref_last_updated_date = convertOPToServerTimeZone(ld_date), status='Check' WHERE CURRENT OF c_table_content_tables;
    END IF;
  END LOOP;

  FOR item in c_pink_table_content LOOP
    ln_rowid := NULL;
    lv_sql := 'select rowid from ' || item.name || ' WHERE ' || item.table_pk;
    BEGIN
      EXECUTE IMMEDIATE lv_sql INTO ln_rowid;
    EXCEPTION 
      WHEN no_data_found THEN
        NULL;
      WHEN too_many_rows THEN
        NULL;
      WHEN OTHERS THEN
        ecdp_dynsql.writeTempText('PRECHECK_2', 'Name: [' || item.name || '], ORA: [' || SQLERRM || '], lv_sql: [' || lv_sql || ']');
    END;
    
    INSERT INTO t_table_content_pinc_row(name, table_pk, ref_rowid, pinc_daytime)  
      VALUES(item.name, item.table_pk,ln_rowid, item.max_daytime); 

  END LOOP;
  
  UPDATE  t_ctrl_pinc p 
  SET result = 'Table Content has been modified by customer.',
	  alt_table_pk = (select table_pk
		from t_table_content_pinc_row op
		where op.ref_rowid = p.ref_rowid) 
     WHERE   type = 'TABLE CONTENT'
     AND     status = 'Check'
     AND     ref_rowid IN 
       (SELECT ref_rowid 
        FROM t_table_content_pinc_row op
        WHERE op.name = p.name
        AND   op.ref_rowid = p.ref_rowid
        AND   Nvl(p.ref_last_updated_date, op.pinc_daytime -1) > op.pinc_daytime  );

END;
/

DECLARE
	ln_count NUMBER;
	ln_count2 NUMBER;
BEGIN
	SELECT count(*) INTO ln_count FROM class_cnfg WHERE app_space_cntx='EC_FRMW';
	IF ln_count < 20 THEN
		ecdp_dynsql.writeTempText('PINC_EXISTS', '"PRODUCT NOT INSTALLED",,,"Product Area EC_FRMW is not installed in the system"');
	END IF;
END;
/

DECLARE
  CURSOR c_INSERT_CLASS_CNFG
  IS
  SELECT * FROM INSERT_CLASS_CNFG WHERE TABLE_NAME='CLASS_CNFG';
  
  CURSOR c_INSERT_CLASS_ATTRIBUTE
  IS
  SELECT * FROM INSERT_CLASS_CNFG WHERE TABLE_NAME='CLASS_ATTRIBUTE_CNFG';
  
  CURSOR c_INSERT_CLASS_RELATION
  IS
  SELECT * FROM INSERT_CLASS_CNFG WHERE TABLE_NAME='CLASS_RELATION_CNFG';
  
  CURSOR c_INSERT_CLASS_TRIGGER_ACTION
  IS
  SELECT * FROM INSERT_CLASS_CNFG WHERE TABLE_NAME='CLASS_TRIGGER_ACTN_CNFG';
  
  CURSOR c_INSERT_CLASS_DEPENDENCY_CNFG
  IS
  SELECT * FROM INSERT_CLASS_CNFG WHERE TABLE_NAME='CLASS_DEPENDENCY_CNFG';
  
  lv_class_name VARCHAR2(32);
  lv_attribute_name VARCHAR2(32);
  lv_sql VARCHAR2(2000);
  lv2_sql VARCHAR2(5000);
  
  lv_from_class_name VARCHAR2(32);
  lv_role_name VARCHAR2(32);
  lv_to_class_name VARCHAR2(32);
  
  lv_triggering_event VARCHAR2(32);
  lv_trigger_type VARCHAR2(32);
  lv_sort_order VARCHAR2(32);
  
  lv_child_class VARCHAR2(32);
  lv_dependency_type VARCHAR2(32);
  lv_parent_class VARCHAR2(32);
  
BEGIN
  -- first loop for class_cnfg
  FOR item IN c_INSERT_CLASS_CNFG LOOP
	lv2_sql:=NULL;
    lv_class_name := NULL;
    lv_sql := 'SELECT class_name FROM ' || item.table_name || ' WHERE CLASS_NAME=''' || item.class_name || '''';
		
    BEGIN
      EXECUTE IMMEDIATE lv_sql INTO lv_class_name;
    EXCEPTION 
      WHEN OTHERS THEN
        NULL;
    END;
    IF lv_class_name IS NOT NULL THEN
	  INSERT INTO t_ctrl_pinc (result,NAME,TYPE,TABLE_PK) values ('Table Content has been added by customer.','CLASS_CNFG','TABLE CONTENT','CLASS_NAME=''' || item.class_name ||'''');
	END IF;
  END LOOP;
  
  -- second loop for class_attribute_cnfg
  FOR item IN c_INSERT_CLASS_ATTRIBUTE LOOP
	lv2_sql:=NULL;
    lv_class_name := NULL;
	lv_attribute_name := NULL;
    lv_sql := 'SELECT class_name,attribute_name FROM ' || item.table_name || ' WHERE CLASS_NAME=''' || item.class_name || ''' AND ATTRIBUTE_NAME=''' || item.attribute_name || '''';
		
    BEGIN
      EXECUTE IMMEDIATE lv_sql INTO lv_class_name,lv_attribute_name;
    EXCEPTION 
      WHEN OTHERS THEN
        NULL;
    END;
    IF lv_class_name IS NOT NULL AND lv_attribute_name IS NOT NULL THEN
	  INSERT INTO t_ctrl_pinc (result,NAME,TYPE,TABLE_PK) values ('Table Content has been added by customer.','CLASS_ATTRIBUTE_CNFG','TABLE CONTENT','CLASS_NAME=''' || item.class_name || ''' AND ATTRIBUTE_NAME=''' || item.attribute_name || '''');
	END IF;
  END LOOP;
  
  -- Third loop for class_relation_cnfg
  FOR item IN c_INSERT_CLASS_RELATION LOOP
	lv2_sql:=NULL;
    lv_from_class_name := NULL;
	lv_role_name := NULL;
	lv_to_class_name := NULL;
    
	lv_sql := 'SELECT from_class_name,role_name,to_class_name FROM ' || item.table_name || ' WHERE FROM_CLASS_NAME=''' || item.from_class_name || ''' AND ROLE_NAME=''' || item.role_name || ''' AND TO_CLASS_NAME=''' || item.to_class_name || '''';

	BEGIN
      EXECUTE IMMEDIATE lv_sql INTO lv_from_class_name,lv_role_name,lv_to_class_name;
    EXCEPTION 
      WHEN OTHERS THEN
        NULL;
    END;

    IF lv_from_class_name IS NOT NULL AND lv_role_name IS NOT NULL AND lv_to_class_name IS NOT NULL THEN
	  INSERT INTO t_ctrl_pinc (result,NAME,TYPE,TABLE_PK) values ('Table Content has been added by customer.','CLASS_RELATION_CNFG','TABLE CONTENT','FROM_CLASS_NAME=''' || item.from_class_name || ''' AND TO_CLASS_NAME=''' || item.to_class_name || ''' AND ROLE_NAME=''' || item.role_name || '''');
	END IF;
  END LOOP;
  
  -- Fourth loop for class_trigger_actn_cnfg
  FOR item IN c_INSERT_CLASS_TRIGGER_ACTION LOOP
	lv2_sql:=NULL;
    lv_class_name := NULL;
	lv_triggering_event := NULL;
	lv_trigger_type := NULL;
	lv_sort_order := NULL;
    lv_sql := 'SELECT class_name,triggering_event,trigger_type,sort_order FROM ' || item.table_name || ' WHERE CLASS_NAME=''' || item.class_name || ''' AND TRIGGERING_EVENT=''' || item.triggering_event || ''' AND TRIGGER_TYPE =''' || item.trigger_type || ''' AND SORT_ORDER=''' || item.sort_order || '''';
		
    BEGIN
      EXECUTE IMMEDIATE lv_sql INTO lv_class_name,lv_triggering_event,lv_trigger_type,lv_sort_order;
    EXCEPTION 
      WHEN OTHERS THEN
        NULL;
    END;
    IF lv_class_name IS NOT NULL AND lv_triggering_event IS NOT NULL AND lv_trigger_type IS NOT NULL AND lv_sort_order IS NOT NULL THEN
	  INSERT INTO t_ctrl_pinc (result,NAME,TYPE,TABLE_PK) values ('Table Content has been added by customer.','CLASS_TRIGGER_ACTN_CNFG','TABLE CONTENT','CLASS_NAME=''' || item.class_name || ''' AND TRIGGERING_EVENT=''' || item.triggering_event || ''' AND TRIGGER_TYPE=''' || item.trigger_type || ''' AND SORT_ORDER=' || item.sort_order || '.0000000000');
	  END IF;
  END LOOP;
  
  -- Fifth loop for class_dependency_cnfg
  FOR item IN c_INSERT_CLASS_DEPENDENCY_CNFG LOOP
	lv2_sql:= NULL;
    lv_child_class := NULL;
	lv_dependency_type := NULL;
	lv_parent_class := NULL;
    lv_sql := 'SELECT CHILD_CLASS,DEPENDENCY_TYPE,PARENT_CLASS FROM ' || item.table_name || ' WHERE CHILD_CLASS=''' || item.child_class || ''' AND DEPENDENCY_TYPE=''' || item.dependency_type || ''' AND PARENT_CLASS =''' || item.parent_class || '''';
		
    BEGIN
      EXECUTE IMMEDIATE lv_sql INTO lv_child_class,lv_dependency_type,lv_parent_class;
    EXCEPTION 
      WHEN OTHERS THEN
        NULL;
    END;
    IF lv_child_class IS NOT NULL AND lv_dependency_type IS NOT NULL AND lv_parent_class IS NOT NULL THEN
	  INSERT INTO t_ctrl_pinc (result,NAME,TYPE,TABLE_PK) values ('Table Content has been added by customer.','CLASS_DEPENDENCY_CNFG','TABLE CONTENT','PARENT_CLASS=''' || item.parent_class || ''' AND CHILD_CLASS=''' || item.child_class || ''' AND DEPENDENCY_TYPE=''' || item.dependency_type || '''');
	 END IF;
  END LOOP; 
  
END;
/


set long 9999
set heading off
set verify off
set feedback off
set echo off
set pagesize 9999
set lines 32000
set trimspool on
spool .\12.1.0.PATCH04_precheck_result.csv append;
SELECT text FROM t_temptext WHERE id IN ('PINC_EXISTS', 'PINC_PATCH-BEYOND');
SELECT '"OBJECT TYPE",','"OBJECT NAME",','"TABLE PK (from CTRL_PINC for Table Content)",','"ALTERNATE TABLE PK (for Table Content)",','"ERROR MESSAGE"' FROM DUAL;
SELECT '"' || type || '","' || name || '","' || table_pk || '","' || alt_table_pk || '","' || result || '"' FROM t_ctrl_pinc WHERE result IS NOT NULL ORDER BY TYPE, name, table_pk;
spool off
set heading on
set verify on
set feedback on

DROP TABLE t_ctrl_pinc;
DROP TABLE t_table_content_pinc_row;
DROP TABLE INSERT_CLASS_CNFG;
DROP FUNCTION isObjectUpdated;
DROP FUNCTION ConvertOPToServerTimeZone;
ALTER TRIGGER ddl_eckernel ENABLE;
/