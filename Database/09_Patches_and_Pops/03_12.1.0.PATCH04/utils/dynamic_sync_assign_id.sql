create table ASSIGN_ID_MASTER as
select distinct
'p_insert_table' || upper(trim(regexp_replace(regexp_replace(regexp_replace(REGEXP_REPLACE(text,'(^[[:space:]]*|[[:space:]]*$)'),'EcDp_System_Key.assignNextNumber','',1,0,'i'),':new.', '''',1,0,'i'),'[$)]',''')'))) FINAL_TEXT
from user_source a where a.TYPE='TRIGGER' and a.NAME like 'IU_%'
 AND A.NAME NOT LIKE 'IUD_%'
  AND A.NAME NOT LIKE 'IUV_%'
  and a.NAME <> 'IU_SUMMARY_SETUP_LIST'
 AND UPPER(TRIM(A.TEXT)) LIKE '%ECDP_SYSTEM_KEY.ASSIGNNEXTNUMBER%' 
  and text not like '%DATASET_FLOW_DOC_CONN%' order by FINAL_TEXT;
  
CREATE OR REPLACE PROCEDURE p_insert_table(p_table_name_i IN VARCHAR2,p_column_name_i IN VARCHAR2)
  IS
   l_sql VARCHAR2(6000);
  BEGIN
     l_sql := 'insert into TEMP_ASSIGN_ID VALUES('||''''||p_table_name_i||''''||','||''''||p_column_name_i||''''||','||'(SELECT nvl(MAX('||p_column_name_i||')'||',0) FROM '||p_table_name_i||')'||')';
	 EXECUTE IMMEDIATE l_sql;
  EXCEPTION
   WHEN OTHERS THEN
        dbms_output.put_line(p_table_name_i || ' ' || sqlerrm);
  END;

 CREATE TABLE TEMP_ASSIGN_ID
(
  tablename VARCHAR2(1000),
  column_name    VARCHAR2(1000), 
  max_id    NUMBER
);


DECLARE
  CURSOR c_gtcur IS
  SELECT * FROM TEMP_ASSIGN_ID; 
  l_cnt NUMBER;
  v_sql varchar2(1000);
BEGIN
  DELETE FROM TEMP_ASSIGN_ID WHERE 1 = 1;
  
  begin 
for i  in (select * from assign_id_master ) 
    loop
   
v_sql:=' begin ' || i.final_text || ' end ; ' ;
  execute immediate v_sql ;
  
    end loop;
      end;
    
 
 FOR i IN c_gtcur LOOP
    l_cnt := null;
  
    BEGIN
      SELECT COUNT(1)
        INTO l_cnt
        FROM assign_id
      where tablename = i.tablename;
    EXCEPTION
      WHEN OTHERS THEN
        l_cnt := 0;
    END;
  
    IF l_cnt > 0 THEN
      BEGIN
        UPDATE assign_id
          SET max_id = i.max_id
        WHERE tablename = i.tablename;
      END;
    ELSE
      BEGIN
        INSERT INTO assign_id VALUES (i.tablename, nvl(i.max_id, 0));
      END;
    END IF;
  END LOOP;
  COMMIT;
END;
/

DROP TABLE TEMP_ASSIGN_ID;
DROP TABLE ASSIGN_ID_MASTER;
DROP PROCEDURE p_insert_table;